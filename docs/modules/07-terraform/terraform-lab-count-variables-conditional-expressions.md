---
title: "Terraform Lab: Count, Variables, Conditional Expressions"
description: "Lab Goal    Terraform variable data types  How to use count  How to use count.index  How to..."
published: 2026-03-12
source: "https://dev.to/jumptotech/terraform-lab-count-variables-conditional-expressions-57m0"
tags: []
---

# Terraform Lab: Count, Variables, Conditional Expressions




## Lab Goal



1. Terraform variable **data types**
2. How to use **count**
3. How to use **count.index**
4. How to use **conditional expressions**
5. How to deploy different infrastructure using
   `dev.tfvars` and `prod.tfvars`

---

# Architecture

DEV
→ 1 EC2 instance

PROD
→ 3 EC2 instances

---

# Step 1 — Create Project Folder

```bash
mkdir terraform-count-lab
cd terraform-count-lab
```

Create files:

```plaintext
main.tf
variables.tf
outputs.tf
dev.tfvars
prod.tfvars
```

---

# Step 2 — variables.tf (Data Types)

This file defines **variable types**.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
}

variable "instance_names" {
  description = "List of instance names"
  type        = list(string)
}
```

Important **data types  should know**:

| Type   | Example           |
| ------ | ----------------- |
| string | `"t2.micro"`      |
| number | `3`               |
| bool   | `true`            |
| list   | `["web1","web2"]` |
| map    | `{env="dev"}`     |

---

# Step 3 — main.tf

This file creates EC2 instances using **count**.

```hcl
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {

  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name = "${var.environment}-server-${count.index}"
  }
}
```

---

# Step 4 — Understanding count

```hcl
count = var.instance_count
```

If

```hcl
instance_count = 3
```

Terraform creates

```plaintext
web[0]
web[1]
web[2]
```

---

# Step 5 — Understanding count.index

```hcl
Name = "${var.environment}-server-${count.index}"
```

Example output:

DEV

```plaintext
dev-server-0
```

PROD

```plaintext
prod-server-0
prod-server-1
prod-server-2
```

---

# Step 6 — Conditional Expression

Add this in `main.tf`.

Example:

```hcl
instance_type = var.environment == "prod" ? "t2.small" : "t2.micro"
```

Meaning:

If environment is **prod**

```plaintext
t2.small
```

Else

```plaintext
t2.micro
```

This is called **Terraform ternary conditional**.

Structure:

```hcl
condition ? true_value : false_value
```

Example:

```hcl
var.environment == "prod" ? 3 : 1
```

---

# Step 7 — dev.tfvars

```hcl
aws_region = "us-east-2"

environment = "dev"

instance_type = "t2.micro"

instance_count = 1

instance_names = ["dev-server"]
```

---

# Step 8 — prod.tfvars

```hcl
aws_region = "us-east-2"

environment = "prod"

instance_type = "t2.small"

instance_count = 3

instance_names = ["prod-server1","prod-server2","prod-server3"]
```

---

# Step 9 — outputs.tf

```hcl
output "instance_ids" {
  value = aws_instance.web[*].id
}

output "instance_public_ip" {
  value = aws_instance.web[*].public_ip
}
```

---

# Step 10 — Initialize Terraform

```bash
terraform init
```

---

# Step 11 — Deploy DEV

```bash
terraform plan -var-file="dev.tfvars"
```

```bash
terraform apply -var-file="dev.tfvars"
```

Result:

```plaintext
1 EC2 instance
```

---

# Step 12 — Deploy PROD

```bash
terraform plan -var-file="prod.tfvars"
```

```bash
terraform apply -var-file="prod.tfvars"
```

Result:

```plaintext
3 EC2 instances
```

---

# Step 13 — Destroy

DEV

```bash
terraform destroy -var-file="dev.tfvars"
```

PROD

```bash
terraform destroy -var-file="prod.tfvars"
```


