---
title: "project: real production-style Terraform"
description: "1. Real Production Problem (WHY this approach exists)            Situation in real..."
published: 2025-12-19
source: "https://dev.to/jumptotech/project-real-production-style-terraform-2205"
tags: []
---

# project: real production-style Terraform



## 1. Real Production Problem (WHY this approach exists)

### Situation in real companies

In production you **never** have one Terraform project for everything.

Instead:

* **Networking team** → VPC, subnets, gateways
* **Security team** → IAM, security groups
* **App team** → EC2, ECS, ALB, databases

Each team:

* Works independently
* Deploys at different times
* Has separate CI/CD pipelines
* Must NOT break other teams’ infrastructure

### Problem if everything is in one Terraform project

* One mistake → destroys shared resources
* Teams block each other
* Huge state file → risky
* No ownership boundaries

### Solution used in production

**Each team owns its own Terraform project + state**
and **reads shared resources via data sources or remote state**.

---

## 2. Production Architecture (Simple but Real)

```
AWS Account (Production)
│
├── networking-terraform/
│   └── creates VPC
│
├── security-terraform/
│   └── creates Security Groups
│
└── app-team-terraform/
    └── creates EC2 (Ubuntu) using existing VPC + SG
```

We will focus on **App Team**.

---

## 3. App Team Goal (WHAT they do)

App team wants:

* Ubuntu EC2
* Region: **us-west-1**
* Use **existing VPC** (created by networking team)
* Use **existing Security Group**
* No hard-coded AMI

This is **exact real-world behavior**.

---

## 4. App Team Terraform – Production-Style Code

### Folder

```
app-team-ec2/
├── main.tf
├── variables.tf
└── terraform.tfvars
```

---

## 5. `main.tf` (Ubuntu AMI – us-west-1)

```hcl
terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-west-1"
}
```

---

### 🔹 Fetch Latest Ubuntu AMI (Production best practice)

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (official Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

Why this is **production-grade**:

* No hard-coding AMI
* Always gets latest patched OS
* Security compliant

---

### 🔹 Read Existing VPC (owned by networking team)

```hcl
data "aws_vpc" "prod" {
  tags = {
    Name = "prod-vpc"
  }
}
```

App team **does not create VPC**
They only **consume it**.

---

### 🔹 Read Existing Security Group (owned by security team)

```hcl
data "aws_security_group" "app_sg" {
  name   = "prod-app-sg"
  vpc_id = data.aws_vpc.prod.id
}
```

Security team controls:

* SSH rules
* HTTP/HTTPS rules
* Auditing & compliance

---

### 🔹 Create EC2 (App Team responsibility)

```hcl
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [
    data.aws_security_group.app_sg.id
  ]

  tags = {
    Name        = "prod-app-server"
    Team        = "app"
    Environment = "production"
  }
}
```

---

## 6. `variables.tf`

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}
```

---

## 7. `terraform.tfvars`

```hcl
subnet_id = "subnet-0abc123456789def"
```

Subnet comes from:

* Networking team
* AWS console
* Or remote state output

---

## 8. Commands App Team Runs (Real Production Flow)

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

No dependency on other teams’ pipelines.

---

## 9. Why This Is REAL Production Design

### Separation of ownership

| Team       | Owns            |
| ---------- | --------------- |
| Networking | VPC, Subnets    |
| Security   | Security Groups |
| App Team   | EC2, ECS, ALB   |

---

### Safety

* App team **cannot destroy VPC**
* App team **cannot modify SG rules**
* Least privilege IAM

---

### Scalability

* 50 teams → 50 Terraform states
* Parallel deployments
* Zero coordination overhead

---

## 10. Interview-Ready Explanation (Use This)

> In production, each team owns its own Terraform project and state.
> Shared infrastructure like VPC and security groups are created by core teams and consumed using data sources or remote state.
> This prevents accidental deletion, enables parallel deployments, and enforces clear ownership boundaries.

---

## 11. Why Ubuntu AMI via Data Source Is Mandatory in Prod

❌ Hard-coded AMI
✔️ Dynamic AMI lookup

Benefits:

* Automatic security patches
* Zero code change for OS updates
* CIS / SOC2 compliance

---

## 12. What This Demonstrates



* Real DevOps ownership model
* Data source vs resource
* Production safety patterns
* Terraform used **as companies use it**


