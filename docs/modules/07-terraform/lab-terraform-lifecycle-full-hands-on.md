---
title: "LAB: Terraform Lifecycle (FULL HANDS-ON)"
description: "✅ What is lifecycle (quick recap)   lifecycle block controls how Terraform handles resource..."
published: 2026-04-03
source: "https://dev.to/jumptotech/lab-terraform-lifecycle-full-hands-on-20ph"
tags: []
---

# LAB: Terraform Lifecycle (FULL HANDS-ON)


# ✅ What is `lifecycle` (quick recap)

`lifecycle` block controls how Terraform handles resource changes:

```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy       = true
  ignore_changes        = [...]
}
```

---

# 🚀 
## 🎯 Goal

You will:

1. Create EC2 instance
2. Modify it → see replacement behavior
3. Protect resource from deletion
4. Ignore specific changes

---

# 📁 Project Structure

```plaintext
terraform-lifecycle-lab/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── providers.tf
├── outputs.tf
└── versions.tf
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
  description = "AWS region"
  type        = string
}

variable "instance_name" {
  description = "EC2 name"
  type        = string
}

variable "instance_type" {
  description = "EC2 type"
  type        = string
}

variable "common_tags" {
  description = "Tags"
  type        = map(string)
}
```

---

# 📄 terraform.tfvars

```hcl
aws_region     = "us-east-2"
instance_name  = "lifecycle-lab-instance"
instance_type  = "t2.micro"

common_tags = {
  Project = "LifecycleLab"
  Owner   = "Student"
}
```

---

# 📄 main.tf (CORE LAB)

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })

  lifecycle {

    # ✅ 1. Create new before destroying old
    create_before_destroy = true

    # ✅ 2. Prevent accidental deletion
    prevent_destroy = false

    # ✅ 3. Ignore changes to tags
    ignore_changes = [
      tags
    ]
  }
}
```

---

# 📄 outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
```

---

# 🧪 STEP-BY-STEP TESTING

---

## ✅ Step 1 — Initialize

```bash
terraform init
```

---

## ✅ Step 2 — Create Resource

```bash
terraform apply
```

---

## 🔥 TEST 1 — create_before_destroy

### Change instance type:

```hcl
instance_type = "t3.micro"
```

### Run:

```bash
terraform apply
```

### ✅ What happens:

* New EC2 created FIRST
* Old EC2 destroyed AFTER

👉 Without this → downtime
👉 With this → zero downtime (important for production)

---

## 🔥 TEST 2 — prevent_destroy

### Change:

```hcl
prevent_destroy = true
```

### Now run:

```bash
terraform destroy
```

### ❌ Result:

Terraform will fail:

```plaintext
Error: Instance cannot be destroyed
```

👉 This protects production resources (RDS, S3, etc.)

---

## 🔥 TEST 3 — ignore_changes

### Step:

1. Go to AWS Console
2. Change tag manually (e.g., Name)

### Run:

```bash
terraform plan
```

### ✅ Result:

No changes detected

👉 Terraform ignores drift for tags

---

# 🧠 REAL DEVOPS USAGE

| Lifecycle Rule        | Real Use Case                    |
| --------------------- | -------------------------------- |
| create_before_destroy | Zero downtime deploy (ASG, ALB)  |
| prevent_destroy       | Protect RDS, S3, DB              |
| ignore_changes        | External systems modify resource |

---

# ⚠️ IMPORTANT INTERVIEW POINTS

**Q: When should NOT use `ignore_changes`?**
👉 When drift matters (security groups, IAM)

**Q: Risk of `prevent_destroy`?**
👉 Blocks CI/CD destroy → must manually disable

**Q: Does Terraform automatically use lifecycle?**
👉 No — must be explicitly defined



