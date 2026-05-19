# Lab 2 · EC2 Deployment

**Duration:** ~60 minutes  
**Goal:** Launch an EC2 instance in a public subnet, configure security groups, SSH in, deploy nginx, and attach an IAM role to read from S3.

**Cost estimate:** < $0.02 if you terminate within 2 hours. t3.micro is free-tier eligible.

**Prerequisites:**
- Lab 1 completed (IAM role `EC2S3ReadProfile` exists)
- AWS CLI configured with `devops-admin` profile

---

## Part 1 — Create a key pair

A key pair lets you SSH into EC2 instances. The private key is generated once and never stored by AWS.

```bash
# Generate key pair and save private key locally
aws ec2 create-key-pair \
  --key-name devops-lab-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/devops-lab-key.pem

# Restrict permissions (SSH will refuse a world-readable key)
chmod 400 ~/.ssh/devops-lab-key.pem

# Verify
aws ec2 describe-key-pairs --key-names devops-lab-key
```

---

## Part 2 — Create a VPC and subnets

The default VPC works for learning, but we will create a proper one to understand the networking.

```bash
# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Name,Value=lab-vpc

echo "VPC: $VPC_ID"

# Enable DNS hostnames (required for public DNS names on instances)
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames

# Create public subnet in us-east-1a
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources $SUBNET_ID \
  --tags Key=Name,Value=lab-public-1a

# Auto-assign public IPs to instances launched in this subnet
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_ID \
  --map-public-ip-on-launch

echo "Subnet: $SUBNET_ID"
```

### Attach an Internet Gateway

```bash
# Create IGW
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

# Create and configure route table
RTB_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route \
  --route-table-id $RTB_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table \
  --route-table-id $RTB_ID \
  --subnet-id $SUBNET_ID

echo "IGW: $IGW_ID, RTB: $RTB_ID"
```

---

## Part 3 — Create a security group

```bash
# Create security group
SG_ID=$(aws ec2 create-security-group \
  --group-name lab-web-sg \
  --description "Lab web server" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

echo "Security Group: $SG_ID"

# Get your public IP
MY_IP=$(curl -s ifconfig.me)
echo "Your IP: $MY_IP"

# Allow SSH only from your IP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr ${MY_IP}/32

# Allow HTTP from anywhere
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Verify rules
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query 'SecurityGroups[0].IpPermissions'
```

---

## Part 4 — Launch the EC2 instance

### Find a current Amazon Linux 2023 AMI

```bash
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)

echo "AMI: $AMI_ID"
```

### Write a user data script

Save as `userdata.sh`:

```bash
#!/bin/bash
set -e

# Update and install nginx
dnf update -y
dnf install -y nginx

# Start and enable nginx
systemctl enable nginx
systemctl start nginx

# Write a custom index page showing instance metadata
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-type)

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>DevOps Lab</title></head>
<body>
  <h1>Hello from EC2!</h1>
  <p>Instance ID: ${INSTANCE_ID}</p>
  <p>Availability Zone: ${AZ}</p>
  <p>Instance Type: ${TYPE}</p>
</body>
</html>
EOF
```

### Launch the instance

```bash
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name devops-lab-key \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --iam-instance-profile Name=EC2S3ReadProfile \
  --user-data file://userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=lab-web-server}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance: $INSTANCE_ID"
```

Wait for the instance to be running:

```bash
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is running"

# Get public DNS name
PUBLIC_DNS=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicDnsName' \
  --output text)

echo "Public DNS: $PUBLIC_DNS"
```

---

## Part 5 — Connect via SSH

```bash
ssh -i ~/.ssh/devops-lab-key.pem ec2-user@$PUBLIC_DNS
```

Once connected, verify the setup:

```bash
# Check nginx is running
systemctl status nginx

# View the custom page
curl http://localhost

# Check user data logs if something went wrong
sudo cat /var/log/cloud-init-output.log | tail -50
```

---

## Part 6 — Verify the IAM role

From inside the instance, test that the IAM role is working:

```bash
# Who does the instance think it is?
aws sts get-caller-identity
# Should return the EC2S3ReadRole, not any user

# List S3 buckets (read access)
aws s3 ls

# Try to create a bucket (should fail — no write permission)
aws s3 mb s3://test-bucket-abc123
# Should return: AccessDenied
```

The instance can list S3 because of the attached role. It cannot create buckets because the role only has read access.

Exit the instance:
```bash
exit
```

---

## Part 7 — Test the web server

From your local machine:

```bash
# HTTP request
curl http://$PUBLIC_DNS

# Open in browser
open http://$PUBLIC_DNS   # macOS
xdg-open http://$PUBLIC_DNS  # Linux
```

You should see the HTML page showing the instance ID, AZ, and instance type.

---

## Part 8 — Assign an Elastic IP

Currently the instance has a public IP that changes every time it stops/starts. Elastic IP is a fixed public IP:

```bash
# Allocate
ALLOC_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

# Associate with instance
aws ec2 associate-address \
  --instance-id $INSTANCE_ID \
  --allocation-id $ALLOC_ID

# Get the EIP
EIP=$(aws ec2 describe-addresses \
  --allocation-ids $ALLOC_ID \
  --query 'Addresses[0].PublicIp' \
  --output text)

echo "Elastic IP: $EIP"
curl http://$EIP
```

---

## Part 9 — Explore instance metadata

The EC2 Instance Metadata Service (IMDS) provides information about the running instance. It is only accessible from within the instance.

```bash
ssh -i ~/.ssh/devops-lab-key.pem ec2-user@$EIP

# Get a token (IMDSv2 is more secure)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Query metadata
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/

# Specific fields
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id

curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/

exit
```

The IAM credentials endpoint shows the temporary credentials from the instance profile — this is how the SDK picks up credentials automatically.

---

## Verification checklist

- [ ] VPC created with public subnet and IGW
- [ ] Security group allows SSH from your IP and HTTP from anywhere
- [ ] EC2 instance is running with Amazon Linux 2023
- [ ] SSH connection works with key pair
- [ ] nginx is running and serves the custom page
- [ ] `curl http://<public-ip>` returns HTML with instance metadata
- [ ] `aws sts get-caller-identity` from inside instance shows the role
- [ ] `aws s3 mb` from inside instance returns AccessDenied
- [ ] Elastic IP assigned and working

---

## Cleanup

```bash
# Release EIP (must disassociate first)
aws ec2 disassociate-address --allocation-id $ALLOC_ID
aws ec2 release-address --allocation-id $ALLOC_ID

# Terminate instance
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

# Delete security group
aws ec2 delete-security-group --group-id $SG_ID

# Detach and delete IGW
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# Delete route table (disassociate first)
aws ec2 disassociate-route-table --association-id <assoc-id>
aws ec2 delete-route-table --route-table-id $RTB_ID

# Delete subnet and VPC
aws ec2 delete-subnet --subnet-id $SUBNET_ID
aws ec2 delete-vpc --vpc-id $VPC_ID

# Delete key pair
aws ec2 delete-key-pair --key-name devops-lab-key
rm ~/.ssh/devops-lab-key.pem
```
