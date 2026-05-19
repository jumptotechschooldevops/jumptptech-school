---
title: "LAB: Terraform Dependencies (Implicit vs Explicit)"
description: "📁 Project Structure      terraform-dependency-lab/ │ ├── main.tf ├── variables.tf ├──..."
published: 2026-04-03
source: "https://dev.to/jumptotech/lab-terraform-dependencies-implicit-vs-explicit-ag2"
tags: []
---

# LAB: Terraform Dependencies (Implicit vs Explicit)







# 📁 Project Structure

```plaintext
terraform-dependency-lab/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── providers.tf
```

---

# 🔹 1. providers.tf

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

provider "aws" {
  region = var.aws_region
}
```

---

# 🔹 2. variables.tf (NO HARDCODING)

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}
```

---

# 🔹 3. terraform.tfvars

```hcl
aws_region    = "us-east-2"
project_name  = "dep-lab"
instance_type = "t2.micro"

common_tags = {
  Owner = "Student"
  Lab   = "Dependencies"
}
```

---

# 🔹 4. main.tf

## 🔸 Part 1: Implicit Dependency

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id   # ✅ IMPLICIT DEPENDENCY
  cidr_block = "10.0.1.0/24"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-subnet"
  })
}
```

### 👉 Explanation:

* `aws_subnet` depends on `aws_vpc` automatically
* No `depends_on` needed

---

## 🔸 Part 2: Explicit Dependency (Real Scenario)

```hcl
resource "aws_security_group" "sg" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
```

---

## 🔸 EC2 Instance

```hcl
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2"
  })
}
```

---

## 🔸 Data Source (Dynamic AMI)

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

---

# 🔹 5. Explicit Dependency Example (FORCE ORDER)

## ⚠️ Simulate hidden dependency

```hcl
resource "null_resource" "setup" {
  provisioner "local-exec" {
    command = "echo EC2 should be ready"
  }

  depends_on = [aws_instance.ec2]   # ✅ EXPLICIT DEPENDENCY
}
```

---

# 🔹 6. outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "ec2_id" {
  value = aws_instance.ec2.id
}
```

---

# 🔹 🚀 How to Run (Step-by-Step)

```bash
cd terraform-dependency-lab

terraform init
terraform plan
terraform apply
```

---



## ✅ Implicit Dependency

* VPC → Subnet → EC2 created in order
* No `depends_on` used

## ✅ Parallel Execution

* Security group may create in parallel with subnet

## ✅ Explicit Dependency

* `null_resource` runs **only after EC2**

---


### Show graph:

```bash
terraform graph | dot -Tpng > graph.png
```

Explain:

* Arrows = dependencies
* Graph = Terraform brain

---

# 🔹 💡 Interview-Level Takeaways

* Terraform uses **implicit dependencies via references**
* Builds **dependency graph (DAG)**
* Executes **parallel when possible**
* Uses `depends_on` when dependency is hidden

---



