---
title: "aws alb with asg lab"
description: "🧠 First: what we are building   We will build this real production architecture:    User..."
published: 2026-02-09
source: "https://dev.to/jumptotech/aws-alb-with-asg-lab-43c"
tags: []
---

# aws alb with asg lab





# 🧠 First: what we are building 

We will build this **real production architecture**:

```
User Browser
   ↓
Application Load Balancer (ALB)
   ↓
Target Group
   ↓
Auto Scaling Group (ASG)
   ↓
EC2 Ubuntu instances with NGINX
```

Why:

* **ALB** = traffic control
* **ASG** = instance control
* **DevOps** = builds & maintains this so apps never go down

---

![Image](https://docs.aws.amazon.com/images/autoscaling/ec2/userguide/images/elb-tutorial-architecture-diagram.png)

![Image](https://d2908q01vomqb2.cloudfront.net/da4b9237bacccdf19c0760cab7aec4a8359010b0/2019/10/06/illustration-2.png)

![Image](https://miro.medium.com/1%2AED7vqfsL1FiShGf06kh2qg.png)

---

# PART 1 — WHY ASG ALONE IS NOT ENOUGH (very important)

### Auto Scaling Group does ONLY this:

* Keeps **N EC2 instances running**
* Replaces a dead instance

### Auto Scaling Group does NOT:

* Give users a website address
* Balance traffic
* Check if the **application** is broken
* Support HTTPS
* Route traffic safely

### ALB does:

* Gives **ONE stable DNS**
* Sends traffic to **healthy instances only**
* Works across **multiple AZs**
* Enables zero-downtime deployments

👉 **This is why DevOps ALWAYS uses ALB + ASG together**

---

# PART 2 — REGION SETUP (VERY IMPORTANT)

### Set region to **us-east-2**

Top right corner of AWS Console → select:

```
US East (Ohio) us-east-2
```

Everything must be created in **the same region**.

---

# PART 3 — STEP 1: CREATE SECURITY GROUPS

We need **2 security groups**:

1. For ALB (public)
2. For EC2 (private, only ALB allowed)

---

## 🔐 Step 1A — Create ALB Security Group

1. AWS Console → Search **EC2**
2. Click **EC2**
3. Left menu → **Security Groups**
4. Click **Create security group**

### Fill in:

* **Security group name**: `alb-sg`
* **Description**: Allow HTTP from internet
* **VPC**: Default VPC (or your VPC)

### Inbound rules

Click **Add rule**

* Type: **HTTP**
* Port: **80**
* Source: **Anywhere-IPv4 (0.0.0.0/0)**

Leave outbound as default.

Click **Create security group**

✔️ This allows users to reach the ALB.

---

## 🔐 Step 1B — Create EC2 Security Group

1. Still in **Security Groups**
2. Click **Create security group**

### Fill in:

* **Name**: `ec2-web-sg`
* **Description**: Allow HTTP only from ALB
* **VPC**: same as ALB

### Inbound rules

Click **Add rule**

* Type: **HTTP**
* Port: **80**
* Source: **Security group**
* Select: `alb-sg`

Outbound: leave default.

Click **Create security group**

✔️ EC2 is protected — only ALB can talk to it.

---

# PART 4 — STEP 2: CREATE LAUNCH TEMPLATE (UBUNTU + NGINX)

Launch Template defines **how EC2 instances are created**.

---

## 🚀 Step 2A — Create Launch Template

1. EC2 → **Launch Templates**
2. Click **Create launch template**

### Template name

```
lt-ubuntu-nginx
```

### AMI

* Click **Browse AMIs**
* Choose **Ubuntu**
* Select **Ubuntu Server 22.04 LTS**
* Architecture: x86_64

### Instance type

```
t2.micro
```

### Key pair

* Choose existing key OR
* Create new (optional if using Session Manager)

### Network settings

* Security group: **ec2-web-sg**

---

## 🧾 Step 2B — User Data (VERY IMPORTANT)

Scroll down → **Advanced details** → **User data**

Paste **EXACTLY this**:

```bash
#!/bin/bash
apt update -y
apt install -y nginx

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /var/www/html/index.html
<h1>ALB DEMO</h1>
<p>Instance ID: $INSTANCE_ID</p>
<p>Availability Zone: $AZ</p>
<p>Private IP: $IP</p>
EOF

systemctl enable nginx
systemctl restart nginx
```

This does:

* Installs NGINX
* Creates a web page
* Shows **which instance served the request**

Click **Create launch template**

---

# PART 5 — STEP 3: CREATE AUTO SCALING GROUP (ASG)

---

## ⚙️ Step 3A — Create ASG

1. EC2 → **Auto Scaling Groups**
2. Click **Create Auto Scaling group**

### Name

```
asg-web
```

### Launch template

* Select: `lt-ubuntu-nginx`
* Version: Latest

Click **Next**

---

### Network

* VPC: Default VPC
* Subnets: **Select 2 public subnets in different AZs**
  (example: us-east-2a and us-east-2b)

Click **Next**

---

### Desired capacity

* Desired: **2**
* Minimum: **2**
* Maximum: **4**

Scaling policy:

* Keep default (we’ll add later)

Click **Skip to review** → **Create Auto Scaling group**

✔️ You now have **2 Ubuntu EC2 instances running NGINX**

---

# PART 6 — STEP 4: CREATE TARGET GROUP

---

1. EC2 → **Target Groups**
2. Click **Create target group**

### Configuration

* Type: **Instances**
* Name: `tg-web`
* Protocol: **HTTP**
* Port: **80**
* VPC: same VPC

Health check:

* Path: `/`

Click **Next**
⚠️ Do NOT register instances manually
Click **Create target group**

---

# PART 7 — STEP 5: ATTACH TARGET GROUP TO ASG

1. EC2 → **Auto Scaling Groups**
2. Click `asg-web`
3. Tab: **Load balancing**
4. Click **Edit**
5. Attach target group: `tg-web`
6. Click **Update**

---

# PART 8 — STEP 6: CREATE APPLICATION LOAD BALANCER (ALB)

---

1. EC2 → **Load Balancers**
2. Click **Create load balancer**
3. Choose **Application Load Balancer**

### Basic config

* Name: `alb-web`
* Scheme: **Internet-facing**
* IP type: IPv4

### Network

* VPC: same
* Subnets: select **same 2 public subnets**

### Security group

* Select: `alb-sg`

### Listener

* HTTP : 80
* Forward to: `tg-web`

Click **Create load balancer**

---

# PART 9 — STEP 7: VERIFY & OPEN IN BROWSER

---

## 🔍 Check health

1. EC2 → **Target Groups**
2. Click `tg-web`
3. Tab: **Targets**

You should see:

```
2 instances → Healthy
```

---

## 🌐 Open in browser

1. EC2 → **Load Balancers**
2. Click `alb-web`
3. Copy **DNS name**

Paste into browser:

```
http://<ALB-DNS-NAME>
```

You should see:

* Instance ID
* AZ
* Private IP

---

# PART 10 — DEMOS TO SHOW “POWER OF ALB”

## Demo 1 — Load balancing

* Refresh page multiple times
* Instance ID changes

## Demo 2 — High availability

* EC2 → terminate one instance
* Refresh browser → still works
* ASG creates new instance automatically

## Demo 3 — Health check

* Stop nginx on one instance
* Target becomes unhealthy
* ALB stops sending traffic to it

---

# PART 11 — DEVOPS ROLE & TEAM STRUCTURE

### DevOps responsibilities here:

* Design ALB + ASG
* Secure networking
* Ensure uptime
* Enable scaling
* Prepare HTTPS, monitoring, CI/CD

### Who owns this in companies:

| Team              | Owns                    |
| ----------------- | ----------------------- |
| DevOps / Platform | ALB, ASG, VPC           |
| Backend           | App code                |
| Security          | WAF, TLS                |
| SRE               | Reliability (if exists) |

### Team size (real life):

* 1 DevOps per **8–12 engineers**

---

## FINAL INTERVIEW SENTENCE 

> “Auto Scaling keeps instances running.
> Application Load Balancer keeps the application available.
> DevOps builds this platform so developers focus only on code.”











# 🧪 LAB: Application Load Balancer + Auto Scaling Group (REAL DEMO)

## 🎯 Lab Goal 

By the end of this lab, you will:

* Understand **why ALB is needed even when ASG exists**
* See **real EC2 instances behind ALB**
* Prove **load balancing + self-healing**
* Learn **IMDSv2 (modern AWS requirement)**
* Understand **why AMIs matter in Auto Scaling**

---

## 🏗️ Architecture

```
Browser
   |
ALB (DNS name)
   |
Target Group
   |
Auto Scaling Group
   |
EC2 (Nginx + PHP)
   |
AWS Metadata (IMDSv2)
```

---

## 🔹 PART 1 — Create Base EC2 Instance (Golden Instance)

### Step 1: Launch EC2

* AMI: **Ubuntu 22.04**
* Instance type: `t2.micro`
* Security Group:

  * Allow **HTTP (80)** from `0.0.0.0/0`
  * Allow **SSH (22)** from your IP
* Subnet: public

SSH into instance:

```bash
ssh ubuntu@<EC2_PUBLIC_IP>
```

---

## 🔹 PART 2 — Install Nginx + PHP (Web Stack)

```bash
sudo apt update
sudo apt install -y nginx php-fpm
```

Verify:

```bash
systemctl status nginx
ls /run/php/
```

You should see:

```
php8.3-fpm.sock
```

---

## 🔹 PART 3 — Configure Nginx 

Edit config:

```bash
sudo vim /etc/nginx/sites-available/default
```

**DELETE EVERYTHING** and paste:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }

    location ~ /\. {
        deny all;
    }
}
```

Test and restart:

```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
```

---

## 🔹 PART 4 — Create Dynamic Page (IMDSv2 SAFE)

Create app:

```bash
sudo vim /var/www/html/index.php
```

Paste **IMDSv2-safe code**:

```php
<?php
function meta($path) {
    $token = shell_exec("curl -s -X PUT 'http://169.254.169.254/latest/api/token' \
        -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600'");
    return shell_exec("curl -s -H 'X-aws-ec2-metadata-token: $token' \
        http://169.254.169.254/latest/meta-data/$path");
}
?>

<!DOCTYPE html>
<html>
<head>
  <title>JumpToTech School - ALB DEMO</title>
</head>
<body>
  <h1>JumpToTech School - ALB DEMO</h1>

  <p><b>Instance ID:</b> <?php echo meta("instance-id"); ?></p>
  <p><b>Availability Zone:</b> <?php echo meta("placement/availability-zone"); ?></p>
  <p><b>Private IP:</b> <?php echo meta("local-ipv4"); ?></p>
  <p><b>Hostname:</b> <?php echo gethostname(); ?></p>
  <p><b>Generated:</b> <?php echo date("Y-m-d H:i:s"); ?></p>
</body>
</html>
```

Test locally:

```bash
curl localhost
```

✅ You must see **Instance ID, AZ, Private IP**

---

## 🔹 PART 5 — Create AMI (CRITICAL STEP)

This instance is now your **golden image**.

AWS Console:

1. EC2 → Instances
2. Select instance
3. Actions → Image and templates → **Create image**
4. Name:

   ```
   alb-demo-nginx-php-imdsv2
   ```

Wait until AMI = **Available**

---

## 🔹 PART 6 — Create Launch Template

1. EC2 → Launch Templates → Create
2. AMI: **new AMI**
3. Instance type: `t2.micro`
4. Security Group: HTTP + SSH
5. Save template

---

## 🔹 PART 7 — Create Auto Scaling Group

1. Auto Scaling → Create ASG
2. Select Launch Template
3. Subnets: **at least 2 AZs**
4. Desired: `2`
5. Min: `1`
6. Max: `3`

---

## 🔹 PART 8 — Create Target Group

* Type: **Instance**
* Protocol: HTTP
* Port: 80
* Health check path: `/`

---

## 🔹 PART 9 — Create Application Load Balancer

1. Type: **Application Load Balancer**
2. Scheme: Internet-facing
3. Listener: HTTP 80
4. AZs: same as ASG
5. Listener → Forward to **Target Group**

---

## 🔹 PART 10 — Attach ASG to Target Group

* ASG → Edit
* Load balancing → Attach **existing target group**
* Save

Wait until:

* Targets = **healthy**

---

## 🔹 PART 11 — FINAL DEMO (THIS IS THE MAGIC)

Open ALB DNS:

```
alb-web-xxxx.us-east-2.elb.amazonaws.com
```

Refresh page multiple times.

You will see:

* Instance ID changes
* Private IP changes
* AZ changes

Terminate one instance:

* ASG creates new one
* Refresh page → **new Instance ID**

---

## 🎓 WHAT DEVOPS MUST EXPLAIN (IMPORTANT)



* ALB does **traffic routing**
* ASG does **instance lifecycle**
* Instances are **stateless**
* Metadata proves **which server handled request**
* AMI ensures **identical infrastructure**

---

## 🧠 COMMON MISTAKES 

| Mistake            | Lesson          |
| ------------------ | --------------- |
| Edit one EC2       | ASG ignores it  |
| IMDS empty         | IMDSv2 required |
| ALB shows old data | Old AMI         |
| One AZ only        | No HA           |

---

## 🧪 OPTIONAL EXTENSIONS (NEXT LABS)

* ALB stickiness ON vs OFF
* Deregistration delay demo
* Blue/Green deployment
* CloudWatch ALB metrics
* Broken AMI debugging lab

---

## ✅ FINAL CHECKLIST (INTERVIEW READY)

* Can explain ALB vs ASG ✔
* Can trace traffic path ✔
* Can debug empty metadata ✔
* Can explain IMDSv2 ✔
* Can explain AMI importance ✔















