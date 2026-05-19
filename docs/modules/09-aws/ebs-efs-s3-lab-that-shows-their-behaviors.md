---
title: "EBS, EFS, S3 lab that shows their behaviors"
description: "Behavior differences Performance behavior Sharing capability Persistence behavior Failure..."
published: 2026-02-11
source: "https://dev.to/jumptotech/ebs-efs-s3-lab-that-shows-their-behaviors-4gnn"
tags: []
---

# EBS, EFS, S3 lab that shows their behaviors



* Behavior differences
* Performance behavior
* Sharing capability
* Persistence behavior
* Failure behavior
* Production use cases
* Interview-ready explanations

This will be 100% hands-on.

---

# 🧠 PART 0 — Quick Theory (Interview Foundation)

| Feature   | EBS               | EFS                 | S3                    |
| --------- | ----------------- | ------------------- | --------------------- |
| Type      | Block storage     | Network file system | Object storage        |
| Attach to | One EC2 (per AZ)  | Many EC2 (multi-AZ) | Anywhere via API      |
| Mount as  | `/dev/xvdf`       | `/mnt/efs`          | Not mounted (API/CLI) |
| Shared?   | ❌ No              | ✅ Yes               | ✅ Yes                 |
| Multi-AZ? | ❌ No              | ✅ Yes               | ✅ Yes                 |
| Use Case  | Database, OS disk | Shared web files    | Backups, artifacts    |

Now we prove all of this practically.

---

# 🚀 LAB ARCHITECTURE

We will create:

* 2 EC2 instances
* 1 EBS volume
* 1 EFS file system
* 1 S3 bucket

Region: `us-east-2`

---

# 🔵 PART 1 — EBS Behavior Lab

## Step 1 — Create EC2 #1 (Ubuntu)

Install Nginx:

```bash
sudo apt update
sudo apt install nginx -y
```

---

## Step 2 — Create EBS Volume

EC2 → Elastic Block Store → Volumes → Create

* Size: 5GB
* AZ: same as EC2
* Type: gp3

Attach to EC2 #1

---

## Step 3 — Format and Mount EBS

```bash
lsblk
```

You’ll see something like:

```
xvdf
```

Format it:

```bash
sudo mkfs -t ext4 /dev/xvdf
```

Create mount directory:

```bash
sudo mkdir /mnt/ebs
sudo mount /dev/xvdf /mnt/ebs
```

---

## Step 4 — Write Data

```bash
echo "EBS DATA from $(hostname)" | sudo tee /mnt/ebs/test.txt
```

Check:

```bash
cat /mnt/ebs/test.txt
```

---

## 🔥 EBS Behavior Test

### Try attaching same EBS to EC2 #2

You CANNOT.

👉 Interview Question:
Why can’t EBS attach to multiple instances?

Answer:
Because EBS is block storage — it behaves like a physical disk.

---

## 🔥 Stop EC2

Stop instance → Start again

Check:

```bash
cat /mnt/ebs/test.txt
```

Data still exists.

👉 Behavior:
EBS persists even if instance stops.

---

## 🔥 Terminate EC2

If you enabled “Delete on Termination” → EBS deleted
If not → EBS remains

👉 Production:
Database volumes disable auto-delete.

---

# 🟢 PART 2 — EFS Behavior Lab

## What is EFS?

![Image](https://miro.medium.com/1%2AGig18TiVgWdxXeedc778UA.png)

![Image](https://docs.aws.amazon.com/images/efs/latest/ug/images/efs-ec2-how-it-works-OneZone.png)

![Image](https://miro.medium.com/0%2APjGIKwAyBwiBPdpy.png)

![Image](https://cloudonaut.io/images/2018/04/efs-overview.png)

---

## Step 1 — Create EFS

Go to:

Amazon Web Services → EFS → Create File System

Select VPC.

---

## Step 2 — Install EFS Utils on BOTH EC2s

```bash
sudo apt install amazon-efs-utils -y
```

---

## Step 3 — Mount EFS

```bash
sudo mkdir /mnt/efs
sudo mount -t efs fs-XXXX:/ /mnt/efs
```

Do this on BOTH instances.

---

## Step 4 — Test Sharing Behavior

On EC2 #1:

```bash
echo "EFS Shared Data" | sudo tee /mnt/efs/shared.txt
```

On EC2 #2:

```bash
cat /mnt/efs/shared.txt
```

🔥 You see the same file.

---

## 🔥 Stop Instance #1

File still accessible from #2.

---

## 🔥 Delete EC2 #1

File still exists in EFS.

---

👉 Interview Question:
Why is EFS good for web servers?

Answer:
Because multiple EC2 instances can share the same file system.

---

# 🟡 PART 3 — S3 Behavior Lab

## What is S3?

![Image](https://cdn.prod.website-files.com/6758716c1db67a29ec00ebb4/681c9b5b592d590a9a5502d5_Amazon%20S3.png)

![Image](https://d2908q01vomqb2.cloudfront.net/b6692ea5df920cad691c20319a6fffd7a4a766b8/2016/10/12/ParquetRename.png)

![Image](https://media.amazonwebservices.com/blog/2017/s3e_access_sort_1.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AmrwasfZOEwDkjb9T9CFVmQ.png)

Amazon Web Services → S3 → Create Bucket

---

## Step 1 — Upload File

Upload:

```
test.txt
```

---

## Step 2 — Access via CLI

On EC2:

```bash
aws s3 ls
aws s3 cp s3://your-bucket/test.txt .
```

---

## 🔥 Behavior Test

### Try mounting S3 as disk

You cannot normally.

Because S3 is object storage.

---

## 🔥 Delete EC2

Your S3 object remains.

---

## 🔥 Multi-AZ test

S3 automatically replicates across AZs.

You don’t manage AZ for S3.

---

# 🎯 FULL BEHAVIOR COMPARISON TEST

| Test                    | EBS | EFS | S3 |
| ----------------------- | --- | --- | -- |
| Share between instances | ❌   | ✅   | ✅  |
| Acts like disk          | ✅   | ✅   | ❌  |
| Access via HTTP         | ❌   | ❌   | ✅  |
| Multi-AZ automatic      | ❌   | ✅   | ✅  |
| Good for DB             | ✅   | ❌   | ❌  |
| Good for shared app     | ❌   | ✅   | ❌  |
| Good for backup         | ❌   | ❌   | ✅  |

---

# 🧠 Real Production Use Cases

### EBS

* RDS storage
* EC2 OS disk
* Databases
* Stateful Kubernetes workloads

### EFS

* Shared WordPress uploads
* Shared Docker volumes
* ML training shared storage

### S3

* Terraform state
* CI/CD artifacts
* Backups
* Static websites

---

# 🎓 Interview Questions They Ask

1. Why can’t EBS be attached to multiple instances?
2. When would you use EFS over S3?
3. Why is S3 cheaper?
4. What happens if AZ fails?
5. How does EFS achieve high availability?
6. How do you secure S3?
7. Difference between gp2 and gp3?
8. Can you resize EBS?
9. Can you encrypt EFS?
10. How do you mount EFS in Auto Scaling?

---

# 💥 Advanced Production Twist (Very Important)

For DevOps:

### Terraform Remote State

We store:

* Terraform state in S3
* Locking in DynamoDB
* Application shared files in EFS
* Databases on EBS

This is real architecture.






















# ✅ Architecture: ALB + ASG + EFS (Shared Storage)

```
Internet
   ↓
ALB
   ↓
Auto Scaling Group (2+ EC2 instances)
   ↓
All instances mount same EFS
```

This demonstrates:

* High availability
* Horizontal scaling
* Shared file system
* Real production pattern

Region: **us-east-2**

---

# 🏗️ FINAL ARCHITECTURE

![Image](https://docs.aws.amazon.com/images/autoscaling/ec2/userguide/images/elb-tutorial-architecture-diagram.png)

![Image](https://labresources.whizlabs.com/4fa7a3ee3cab75f658cdd0f3cb72a43a/alb_with_asg.png)

![Image](https://miro.medium.com/0%2APjGIKwAyBwiBPdpy.png)

![Image](https://i.sstatic.net/kW0cS.jpg)

Services used:

* Amazon Web Services
* Amazon EC2
* Amazon EFS
* Elastic Load Balancing

---

# 🚀 PART 1 — Create EFS (Shared Storage)

### 1️⃣ Go to EFS → Create File System

* Choose your VPC
* Enable mount targets in all subnets
* Keep default settings

After creation, copy:

```
fs-xxxxxxx
```

---

# 🚀 PART 2 — Create Launch Template

Go to EC2 → Launch Templates → Create

### Configuration:

* AMI: Ubuntu
* Instance type: t2.micro
* Security Group:

  * SSH (22)
  * HTTP (80)
  * NFS (2049) allowed from VPC

### 🔥 VERY IMPORTANT — Add User Data

This auto-installs Nginx + mounts EFS:

```bash
#!/bin/bash
apt update -y
apt install nginx -y
apt install amazon-efs-utils -y

mkdir /mnt/efs
mount -t efs fs-XXXX:/ /mnt/efs

echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" > /mnt/efs/index.html

rm /var/www/html/index.nginx-debian.html
ln -s /mnt/efs/index.html /var/www/html/index.html

systemctl restart nginx
```

Replace:

```
fs-XXXX
```

This ensures:

All instances write to SAME file.

---

# 🚀 PART 3 — Create Target Group

EC2 → Target Groups → Create

* Type: Instances
* Protocol: HTTP
* Port: 80
* Health check path: /

---

# 🚀 PART 4 — Create ALB

EC2 → Load Balancers → Create

Type: Application Load Balancer

* Scheme: Internet-facing
* Select at least 2 subnets
* Attach security group (HTTP open)
* Attach Target Group

After creation → Copy ALB DNS name.

---

# 🚀 PART 5 — Create Auto Scaling Group

EC2 → Auto Scaling Groups → Create

* Choose Launch Template
* Select 2 subnets
* Attach to existing ALB target group
* Desired capacity: 2
* Min: 2
* Max: 4

---

# 🎉 TEST

Open:

```
http://your-alb-dns
```

Refresh multiple times.

You will see:

Same content from shared EFS.

---

# 🔥 BEHAVIOR DEMONSTRATION

### 1️⃣ SSH into one instance

```bash
echo "Updated at $(date)" > /mnt/efs/index.html
```

Refresh ALB.

ALL instances reflect change.

That proves:

EFS is shared.

---

### 2️⃣ Terminate one instance manually

ASG automatically launches new one.

Refresh ALB → still works.

Because:

* New instance mounts same EFS
* Same data available

---

### 3️⃣ Scale ASG to 3

Watch:

New instance comes up
Mounts EFS
Works instantly

---

# 🎓 WHAT THIS LAB PROVES (Interview)

### Why not use EBS here?

Because EBS cannot be shared between instances.

### Why not use S3?

Because application needs POSIX file system behavior.

### Why ALB?

* Distributes traffic
* Health checks
* SSL termination
* Path routing

### Why ASG?

* Self-healing
* Horizontal scaling

---

# 🧠 REAL PRODUCTION USE CASES

This pattern is used for:

* WordPress
* CMS systems
* Shared upload directories
* Microservices with shared config
* ML shared models

---

# 💼 WHAT DEVOPS TEAM DOES HERE

DevOps responsibilities:

* Create Launch Templates
* Write User Data scripts
* Configure EFS permissions
* Configure security groups
* Configure health checks
* Monitor scaling behavior
* Add CloudWatch alarms
* Secure NFS properly

Developers:

* Only care about app code

---

# 🔥 Interview Scenario Question

Q:
Users upload images. Suddenly images disappear after scaling. Why?

Answer:
Because they used EBS instead of shared EFS.

---

# ⚡ Production-Level Improvement

Next level:

* Add HTTPS with ACM
* Add Auto Scaling policy (CPU-based)
* Add CloudWatch alarms
* Add lifecycle hook
* Add EFS access points
* Mount using IAM role instead of open NFS



