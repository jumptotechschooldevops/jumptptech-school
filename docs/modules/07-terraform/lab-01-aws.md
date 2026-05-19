# Lab 1 · Provision AWS Infrastructure

**Duration:** ~90 minutes  
**Goal:** Provision a complete network stack and a running web server on AWS using Terraform.

**Cost estimate:** < $1 if you destroy within 2 hours. t2.micro is free tier eligible.

**Prerequisites:**
- AWS account with IAM user credentials
- Terraform >= 1.8: `terraform -version`
- AWS CLI configured: `aws sts get-caller-identity` (should return your account)

---

## Part 1 — Project setup

```bash
mkdir -p ~/terraform-lab/aws-webserver
cd ~/terraform-lab/aws-webserver

# Create standard directory structure
touch main.tf variables.tf outputs.tf versions.tf
```

### versions.tf

```hcl
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
```

### variables.tf

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "lab"
}

variable "project" {
  type        = string
  description = "Project name — used in resource names"
  default     = "devops-lab"
}

variable "your_ip" {
  type        = string
  description = "Your public IP for SSH access (run: curl ifconfig.me)"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

---

## Part 2 — Network configuration

Create the VPC, subnets, internet gateway, and routing:

```hcl
# In main.tf

provider "aws" {
  region = var.aws_region
}

# --- Data sources ---

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Locals ---

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- VPC ---

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# --- Subnets (one per AZ, up to 2) ---

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# --- Route table ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

---

## Part 3 — Security groups

```hcl
# --- Security group for the web server ---

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from your IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.your_ip}/32"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
  })
}
```

---

## Part 4 — SSH key pair

```bash
# Generate an SSH key pair (skip if you already have one)
ssh-keygen -t ed25519 -f ~/.ssh/devops-lab -C "devops-lab-key" -N ""
```

```hcl
# --- Key pair ---

resource "aws_key_pair" "lab" {
  key_name   = "${local.name_prefix}-key"
  public_key = file("~/.ssh/devops-lab.pub")

  tags = local.common_tags
}
```

---

## Part 5 — EC2 instance

```hcl
# --- User data script (runs on first boot) ---

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Install nginx
    yum update -y
    yum install -y nginx

    # Create a custom index page
    cat > /usr/share/nginx/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>DevOps Lab Server</title></head>
    <body>
      <h1>JumptpTech DevOps Lab</h1>
      <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
      <p>Region: ${var.aws_region}</p>
      <p>Environment: ${var.environment}</p>
      <p>Provisioned by Terraform</p>
    </body>
    </html>
    HTML

    # Create health check endpoint
    echo 'OK' > /usr/share/nginx/html/health

    # Start and enable nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# --- EC2 instance ---

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.lab.key_name

  user_data = local.user_data

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # IMDSv2 — more secure
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web"
  })
}
```

---

## Part 6 — Outputs

```hcl
# In outputs.tf

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS of the web server"
  value       = aws_instance.web.public_dns
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/devops-lab ec2-user@${aws_instance.web.public_ip}"
}

output "http_url" {
  description = "HTTP URL to test the server"
  value       = "http://${aws_instance.web.public_ip}/"
}
```

---

## Part 7 — Provision

### Create the tfvars file

```bash
# Get your public IP
MY_IP=$(curl -s ifconfig.me)
echo "Your IP: $MY_IP"

cat > terraform.tfvars << EOF
aws_region    = "us-east-1"
environment   = "lab"
project       = "devops-lab"
your_ip       = "$MY_IP"
instance_type = "t2.micro"
EOF
```

### Initialise and plan

```bash
# Initialise — downloads the AWS provider
terraform init

# Validate HCL syntax
terraform validate

# Format all .tf files
terraform fmt

# Plan — review carefully
terraform plan
```

Read the plan output carefully. Verify:
- 1 VPC
- 2 subnets
- 1 internet gateway
- 1 route table + 2 associations
- 1 security group
- 1 key pair
- 1 EC2 instance

### Apply

```bash
terraform apply
# Review the plan one more time, then type: yes
```

This takes 2–3 minutes. When done:

```bash
terraform output
```

### Test the server

```bash
PUBLIC_IP=$(terraform output -raw public_ip)

# Wait for user_data to finish (about 60 seconds)
until curl -sf http://$PUBLIC_IP/health; do echo "Waiting..."; sleep 5; done

# Test the web page
curl http://$PUBLIC_IP/
```

Open the URL in your browser.

### SSH to the server

```bash
ssh -i ~/.ssh/devops-lab ec2-user@$PUBLIC_IP

# On the server:
systemctl status nginx
cat /var/log/cloud-init-output.log   # user_data execution log
curl http://localhost/health
exit
```

---

## Part 8 — Make a change

See what happens when you modify infrastructure:

```bash
# Add port 8080 to the security group
# Edit the security group in main.tf, add:

#  ingress {
#    description = "App port"
#    from_port   = 8080
#    to_port     = 8080
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

terraform plan   # should show 1 resource to change
terraform apply
```

Notice the plan shows an in-place update (not destroy and recreate) for the security group — adding a rule does not require replacement.

---

## Part 9 — Clean up

```bash
terraform destroy
# Type: yes

# Verify everything is gone
aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=devops-lab" \
    --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name}"
```

**Always destroy lab infrastructure when finished.** EC2 instances cost money even when idle.

---

## Bonus — Remote state

If you have an S3 bucket available, set up remote state:

```bash
# Create state bucket (replace with a globally unique name)
aws s3 mb s3://YOUR_NAME-terraform-state-lab

# Add to versions.tf:
cat >> versions.tf << 'EOF'
  backend "s3" {
    bucket = "YOUR_NAME-terraform-state-lab"
    key    = "aws-webserver/terraform.tfstate"
    region = "us-east-1"
  }
EOF

# Reinitialise to migrate state to S3
terraform init -migrate-state
```

Now your state is stored in S3 and safe if you lose your laptop.
