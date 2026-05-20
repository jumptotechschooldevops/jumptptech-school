---
title: "LAB: Terraform EC2 with `user_data`"
description: "🎯 Goal   Provision an EC2 instance that:   Installs Nginx automatically Starts the..."
published: 2026-04-03
source: "https://dev.to/jumptotech/lab-terraform-ec2-with-userdata-8cd"
tags: []
---

# LAB: Terraform EC2 with `user_data`




## 🎯 Goal

Provision an EC2 instance that:

* Installs Nginx automatically
* Starts the service
* Serves a custom web page

👉 All using **`user_data` (bootstrapping)**

---

# 📁 Project Structure

```bash
terraform-userdata-lab/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── providers.tf
├── versions.tf
├── outputs.tf
└── user_data.sh.tpl
```

---

# 📄 versions.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

# 📄 providers.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

---

# 📄 variables.tf

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "instance_type" {
  type        = string
  description = "EC2 type"
}

variable "instance_name" {
  type        = string
  description = "Name of instance"
}

variable "web_message" {
  type        = string
  description = "Message shown on web page"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags"
}
```

---

# 📄 terraform.tfvars

```hcl
aws_region     = "us-east-2"
instance_type  = "t2.micro"
instance_name  = "userdata-lab"

web_message = "Hello from Terraform User Data!"

common_tags = {
  Project = "UserDataLab"
  Owner   = "Student"
}
```

---

# 📄 user_data.sh.tpl (IMPORTANT)

```bash
#!/bin/bash
yum update -y
yum install -y nginx

systemctl start nginx
systemctl enable nginx

echo "${web_message}" > /usr/share/nginx/html/index.html
```

---

# 📄 main.tf

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    web_message = var.web_message
  })

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })
}
```

---

# 📄 outputs.tf

```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "url" {
  value = "http://${aws_instance.web.public_ip}"
}
```

---

# 🧪 STEP-BY-STEP

---

## ✅ Step 1 — Initialize

```bash
terraform init
```

---

## ✅ Step 2 — Apply

```bash
terraform apply
```

---

## ✅ Step 3 — Open browser

Use output:

```bash
terraform output url
```

👉 Open in browser
👉 You will see:

```plaintext
Hello from Terraform User Data!
```

---

# 🔥 What is `user_data` (Important Explanation)

👉 `user_data` is a script that runs:

* Automatically when EC2 starts
* Only on first boot (by default)

---

# 🧠 Real DevOps Usage

Used for:

* Install packages (nginx, docker)
* Configure apps
* Pull code from Git
* Start services

---

# ⚠️ Important Notes

---

## ❗ Runs only once

If you change `user_data`:

👉 Terraform does NOT re-run it

---

## ❗ To re-run:

You must:

```bash
terraform taint aws_instance.web
terraform apply
```

OR change:

```hcl
user_data_replace_on_change = true
```

---

# 🔥 Bonus (VERY IMPORTANT FOR INTERVIEW)

Add this:

```hcl
user_data_replace_on_change = true
```

👉 Now:

* Any change in user_data → instance recreated

---

# 🎯 Interview Answer

**Q: What is user_data in Terraform?**

👉
`user_data` is a script passed to an EC2 instance that runs during the initial boot process, typically used to install software and configure the instance automatically.

---

# 🚀 Summary

| Feature           | Purpose           |
| ----------------- | ----------------- |
| user_data         | Bootstrap EC2     |
| templatefile      | Avoid hardcoding  |
| runs              | On first boot     |
| replace_on_change | Forces recreation |


