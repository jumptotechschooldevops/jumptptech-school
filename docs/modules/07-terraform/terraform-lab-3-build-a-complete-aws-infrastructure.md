---
title: "Terraform Lab 3: Build a Complete AWS Infrastructure"
description: "Goal Deploy a simple web infrastructure:  Architecture    Internet    │ Internet Gateway    │ Public..."
published: 2026-03-13
source: "https://dev.to/jumptotech/terraform-lab-3-build-a-complete-aws-infrastructure-13h7"
tags: []
---

# Terraform Lab 3: Build a Complete AWS Infrastructure






Goal
Deploy a simple **web infrastructure**:

Architecture

```plaintext
Internet
   │
Internet Gateway
   │
Public Subnet
   │
EC2 Web Server
```

Resources created:

* VPC
* Subnet
* Internet Gateway
* Route Table
* Security Group
* EC2 Instance

Concepts:
* VPC infrastructure
* resource dependencies
* variables
* data sources
* outputs
* Infrastructure as Code architecture

---

# Step 1 — Create Project

```bash
mkdir terraform-vpc-lab
cd terraform-vpc-lab
```

Create files

```bash
touch main.tf variables.tf outputs.tf terraform.tfvars
```

Project structure

```plaintext
terraform-vpc-lab
│
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

# variables.tf

Students copy this file.

```hcl
variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "project_name" {
  type = string
}
```

---

# terraform.tfvars

 copy this file.

```hcl
aws_region    = "us-east-2"

vpc_cidr      = "10.0.0.0/16"

subnet_cidr   = "10.0.1.0/24"

instance_type = "t2.micro"

project_name  = "jumptotech"
```

---

# main.tf

 copy the **entire file**.

```terraform
provider "aws" {

  region = var.aws_region

}

############################################
# DATA SOURCE
############################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = ["amzn2-ami-hvm-*-x86_64-gp2"]

  }

}

############################################
# VPC
############################################

resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  tags = {

    Name = "${var.project_name}-vpc"

  }

}

############################################
# SUBNET
############################################

resource "aws_subnet" "public" {

  vpc_id     = aws_vpc.main.id

  cidr_block = var.subnet_cidr

  map_public_ip_on_launch = true

  tags = {

    Name = "${var.project_name}-public-subnet"

  }

}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "${var.project_name}-igw"

  }

}

############################################
# ROUTE TABLE
############################################

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

}

############################################
# ROUTE TABLE ASSOCIATION
############################################

resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public.id

  route_table_id = aws_route_table.public_rt.id

}

############################################
# SECURITY GROUP
############################################

resource "aws_security_group" "web_sg" {

  name   = "${var.project_name}-web-sg"

  vpc_id = aws_vpc.main.id

  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

}

############################################
# EC2 INSTANCE
############################################

resource "aws_instance" "web_server" {

  ami           = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [

    aws_security_group.web_sg.id

  ]

  tags = {

    Name = "${var.project_name}-web-server"

  }

}
```

---

# outputs.tf

 copy this file.

```hcl
output "vpc_id" {

  value = aws_vpc.main.id

}

output "public_subnet" {

  value = aws_subnet.public.id

}

output "web_server_ip" {

  value = aws_instance.web_server.public_ip

}
```

---

# Run Terraform

Initialize

```console
terraform init
```

Preview

```console
terraform plan
```

Create infrastructure

```console
terraform apply
```

---

# Result

Terraform will create:

* 1 VPC
* 1 Public Subnet
* 1 Internet Gateway
* 1 Route Table
* 1 Security Group
* 1 EC2 Web Server

  get output like:

```plaintext
web_server_ip = 18.221.44.15
```

They can open browser

```plaintext
http://PUBLIC_IP
```

---

# Why This Lab Is Important for DevOps 

 understand:

| Concept                | Learned                       |
| ---------------------- | ----------------------------- |
| Infrastructure as Code | Terraform                     |
| Networking             | VPC + subnet                  |
| Internet access        | IGW                           |
| Security               | Security Groups               |
| Compute                | EC2                           |
| Dependencies           | Terraform resource references |

This is the **first real DevOps infrastructure project**.


