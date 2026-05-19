---
title: "PRODUCTION LAB — Using `user_data` (BEST PRACTICE)"
description: "Instead of:    Terraform → SSH → install nginx        Enter fullscreen mode            Exit..."
published: 2026-03-18
source: "https://dev.to/jumptotech/production-lab-using-userdata-best-practice-49ln"
tags: []
---

# PRODUCTION LAB — Using `user_data` (BEST PRACTICE)



Instead of:

```text
Terraform → SSH → install nginx
```

We use:

```text
Terraform → EC2 boots → user_data runs automatically
```

👉 No SSH
👉 No keys
👉 Faster
👉 Production-ready

---

# 📁 Folder structure

```bash
terraform-userdata/
└── main.tf
```

---

# ✅ FULL `main.tf` (COPY EXACTLY)

```hcl
provider "aws" {
  region = "us-east-2"
}

# -----------------------------
# GET LATEST AMAZON LINUX AMI
# -----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -----------------------------
# SECURITY GROUP
# -----------------------------
resource "aws_security_group" "web_sg" {
  name = "userdata-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ❗ Notice: NO SSH (port 22 removed)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# EC2 INSTANCE (NO KEY, NO SSH)
# -----------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # -----------------------------
  # USER DATA (RUNS AT BOOT)
  # -----------------------------
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome from Terraform User Data</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "userdata-lab"
  }
}
```

---

# 🚀 STEP-BY-STEP

## 1. Create folder

```bash
mkdir terraform-userdata
cd terraform-userdata
```

---

## 2. Create file

```bash
touch main.tf
```

Paste code.

---

## 3. Run Terraform

```bash
terraform init
terraform apply -auto-approve
```

---

# 🔍 VERIFY

## Step 1 — Get Public IP

From Terraform output or AWS console

---

## Step 2 — Open browser

```text
http://<PUBLIC_IP>
```

👉 You will see:

```html
Welcome from Terraform User Data
```

---

# 🔥 WHAT HAPPENED (IMPORTANT)

When EC2 started:

1. AWS executed `user_data`
2. Installed Apache
3. Started service
4. Created webpage

👉 No SSH
👉 No provisioners
👉 Fully automatic

---

# ⚡ Compare (VERY IMPORTANT )

| Feature     | Provisioner    | user_data  |
| ----------- | -------------- | ---------- |
| SSH needed  | Yes            | No         |
| Key needed  | Yes            | No         |
| Runs when   | After creation | At boot    |
| Production  | ❌ Avoid        | ✅ Standard |
| Speed       | Slower         | Faster     |
| Reliability | Medium         | High       |

---

# 🎤 Interview Answer (GOLD)

We use user_data in production because it runs automatically during instance initialization, does not require SSH, and provides a more reliable and scalable way to configure instances compared to provisioners.

---

# 🧠 Real Production Flow

```text
Terraform → create EC2
        → EC2 boots
        → user_data runs automatically
        → application ready
```



# 🎯 FINAL TAKEAWAY

Provisioners = learning tool
user_data = real production standard


