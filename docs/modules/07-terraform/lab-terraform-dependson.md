---
title: "LAB: Terraform `depends_on`"
description: "Create:   VPC Subnet Security Group IAM Role EC2 Instance   And enforce:    EC2 → depends_on → SG +..."
published: 2026-04-02
source: "https://dev.to/jumptotech/lab-terraform-dependson-26hf"
tags: []
---

# LAB: Terraform `depends_on`



Create:

* VPC
* Subnet
* Security Group
* IAM Role
* EC2 Instance

And enforce:

```plaintext
EC2 → depends_on → SG + IAM Role
```

---

# Project Structure

```plaintext
terraform-depends-on-lab/
│
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
```

---

# 1. providers.tf

```hcl
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# 2. variables.tf

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}
```

---

# 3. locals.tf

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

---

# 4. main.tf

### VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}
```

---

### Subnet

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet"
  })
}
```

---

### Security Group

```hcl
resource "aws_security_group" "web_sg" {
  name   = "${local.name_prefix}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
```

---

### IAM Role

```hcl
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}
```

---

### IAM Instance Profile

```hcl
resource "aws_iam_instance_profile" "profile" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.ec2_role.name
}
```

---

### AMI (NO HARD CODING)

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

---

### EC2 Instance (KEY PART)

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name

  # 🔥 EXPLICIT DEPENDENCY
  depends_on = [
    aws_security_group.web_sg,
    aws_iam_role.ec2_role
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-instance"
  })
}
```

---

# 5. outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
```

---

# 6. terraform.tfvars

```hcl
aws_region   = "us-east-2"
project_name = "depends-lab"
environment  = "dev"
```

---

# How to Run

```bash
terraform init
terraform plan
terraform apply
```

---



### Without `depends_on`

Terraform may:

* Create EC2 before IAM is fully ready
* Cause intermittent failures

### With `depends_on`

Terraform guarantees:

```plaintext
1. SG created
2. IAM Role created
3. EC2 created LAST
```

---



1. Terraform usually auto-detects dependencies
2. Use `depends_on` only when needed
3. It controls **order**, not data
4. Very important for:

   * IAM
   * Networking
   * Cross-module dependencies

---

# Interview Question From This Lab

**Q:** Why did you use `depends_on` if SG is already referenced?

**Answer:**

> To guarantee creation order and avoid race conditions, especially for IAM resources and AWS eventual consistency issues.


