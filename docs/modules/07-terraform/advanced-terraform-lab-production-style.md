---
title: "Advanced Terraform Lab (Production Style)"
description: "Topics covered:   for_each map variables locals dynamic blocks terraform workspaces multi-environment..."
published: 2026-03-12
source: "https://dev.to/jumptotech/advanced-terraform-lab-production-style-52ce"
tags: []
---

# Advanced Terraform Lab (Production Style)


Topics covered:

* `for_each`
* `map variables`
* `locals`
* `dynamic blocks`
* `terraform workspaces`
* multi-environment deployment

---

# 

## Goal

Deploy multiple EC2 servers with different configurations using:

* `for_each`
* `map variables`
* `locals`
* `dynamic blocks`
* `terraform workspaces`



# Architecture

DEV

```plaintext
1 EC2 instance
t2.micro
```

PROD

```plaintext
3 EC2 instances
t2.small
```

Security group rules created dynamically.

---

# Step 1 — Create Project

```bash
mkdir terraform-advanced-lab
cd terraform-advanced-lab
```

Create files

```plaintext
main.tf
variables.tf
outputs.tf
```

---

# Step 2 — variables.tf

Introduce **map and list data types**.

```hcl
variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "instances" {
  description = "EC2 instances configuration"
  type = map(object({
    instance_type = string
    name          = string
  }))
}

variable "security_ports" {
  type = list(number)
}
```

This introduces students to **complex data structures**.

Example structure:

```hcl
map(object({
instance_type
name
}))
```

---

# Step 3 — main.tf

Provider configuration.

```hcl
provider "aws" {
  region = var.aws_region
}
```

---

## Get Latest AMI

```hcl
data "aws_ami" "amazon_linux" {

  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

---

# Step 4 — Locals

Locals help create **environment logic**.

```hcl
locals {

  environment = terraform.workspace

  instance_config = local.environment == "prod" ? {

    web1 = {
      instance_type = "t2.small"
      name = "prod-web1"
    }

    web2 = {
      instance_type = "t2.small"
      name = "prod-web2"
    }

    web3 = {
      instance_type = "t2.small"
      name = "prod-web3"
    }

  } : {

    web1 = {
      instance_type = "t2.micro"
      name = "dev-web1"
    }

  }

}
```

This is **real enterprise logic**.

Environment decides infrastructure size.

---

# Step 5 — Security Group

```hcl
resource "aws_security_group" "web_sg" {

  name = "web-security-group"

  dynamic "ingress" {

    for_each = var.security_ports

    content {

      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }

}
```

This uses **dynamic blocks**.

If ports list is:

```json
[22,80,443]
```

Terraform creates **3 ingress rules automatically**.

---

# Step 6 — EC2 Instances using for_each

```hcl
resource "aws_instance" "web" {

  for_each = local.instance_config

  ami           = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  tags = {
    Name = each.value.name
    Environment = local.environment
  }

}
```

Important:

| Concept    | Meaning                    |
| ---------- | -------------------------- |
| for_each   | creates resources from map |
| each.key   | map key                    |
| each.value | map value                  |

Example Terraform creates:

```hcl
aws_instance.web["web1"]
aws_instance.web["web2"]
aws_instance.web["web3"]
```

---

# Step 7 — outputs.tf

```hcl
output "instance_public_ips" {

  value = {
    for instance in aws_instance.web :
    instance.tags.Name => instance.public_ip
  }

}
```

Example output:

```properties
prod-web1 = 18.120.x.x
prod-web2 = 3.19.x.x
prod-web3 = 54.193.x.x
```

---

# Step 8 — Initialize Terraform

```bash
terraform init
```

---

# Step 9 — Create Workspaces

DEV workspace

```bash
terraform workspace new dev
```

Switch

```bash
terraform workspace select dev
```

Deploy

```bash
terraform apply
```

Result:

```plaintext
1 EC2 instance
```

---

# Step 10 — Create PROD Environment

Create workspace

```bash
terraform workspace new prod
```

Switch

```bash
terraform workspace select prod
```

Deploy

```bash
terraform apply
```

Result:

```plaintext
3 EC2 instances
```

---

# Step 11 — Verify Workspaces

```bash
terraform workspace list
```

Output

```plaintext
default
dev
prod
```

---

# What Students Learn

This lab teaches **real production Terraform skills**:

| Concept        | Why Important                               |
| -------------- | ------------------------------------------- |
| for_each       | used in almost every real Terraform project |
| locals         | simplify environment logic                  |
| dynamic blocks | avoid repeated code                         |
| maps & objects | advanced variable types                     |
| workspaces     | multi-environment infrastructure            |

---

# DevOps Interview Questions from this Lab

1️⃣ Difference between **count vs for_each**

2️⃣ What is **terraform workspace**

3️⃣ What are **locals**

4️⃣ What are **dynamic blocks**

5️⃣ When should you use **map vs list**

6️⃣ Why is **for_each safer than count**


