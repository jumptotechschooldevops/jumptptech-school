---
title: "Terraform Infrastructure as Code (IaC) Lab – Multi Environment Deployment"
description: "task to learn:   variables tfvars data source locals functions count outputs               Step 1 —..."
published: 2026-03-13
source: "https://dev.to/jumptotech/terraform-infrastructure-as-code-iac-lab-multi-environment-deployment-3302"
tags: []
---

# Terraform Infrastructure as Code (IaC) Lab – Multi Environment Deployment





# 
task to learn:

* variables
* tfvars
* data source
* locals
* functions
* count
* outputs

---

# Step 1 — Create Project Folder

```bash
mkdir terraform-multi-env-lab
cd terraform-multi-env-lab
```

Create files

```bash
touch main.tf variables.tf locals.tf outputs.tf dev.tfvars prod.tfvars
```

Project structure

```plaintext
terraform-multi-env-lab
│
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── dev.tfvars
└── prod.tfvars
```

---

# variables.tf

 copy everything below.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "instance_types" {
  description = "Instance type per environment"
  type        = map(string)
}

variable "ports" {
  description = "Allowed ports"
  type        = list(number)
}

variable "availability_zones" {
  description = "AZ list"
  type        = set(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
}
```

---

# locals.tf

 copy this file.

```hcl
locals {

  instance_type = lookup(var.instance_types, var.environment)

  name_prefix = upper(var.environment)

  az_list = tolist(var.availability_zones)

}
```

Functions used

* lookup()
* upper()
* tolist()

---

# main.tf

Students copy **FULL file below**.

```hcl
provider "aws" {

  region = var.aws_region

}

#########################################
# DATA SOURCE
#########################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = ["amzn2-ami-hvm-*-x86_64-gp2"]

  }

}

#########################################
# SECURITY GROUP
#########################################

resource "aws_security_group" "web_sg" {

  name = "${var.environment}-web-sg"

  dynamic "ingress" {

    for_each = var.ports

    content {

      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }

}

#########################################
# EC2 INSTANCES
#########################################

resource "aws_instance" "servers" {

  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id

  instance_type = local.instance_type

  availability_zone = element(

    local.az_list,
    count.index

  )

  tags = {

    Name = "${var.project_name}-${local.name_prefix}-${count.index}"

  }

}
```

Concepts learn here

* provider
* data source
* dynamic blocks
* count
* count.index
* functions

---

# outputs.tf

 copy this file.

```hcl
output "instance_ids" {

  description = "IDs of instances"

  value = aws_instance.servers[*].id

}

output "public_ips" {

  description = "Public IP addresses"

  value = aws_instance.servers[*].public_ip

}
```

---

# dev.tfvars

 copy this file.

```hcl
aws_region = "us-east-2"

environment = "dev"

project_name = "jumptotech"

instance_count = 1

instance_types = {

  dev  = "t2.micro"
  prod = "t2.small"

}

ports = [

  22,
  80

]

availability_zones = [

  "us-east-2a",
  "us-east-2b"

]
```

---

# prod.tfvars

```hcl
aws_region = "us-east-2"

environment = "prod"

project_name = "jumptotech"

instance_count = 3

instance_types = {

  dev  = "t2.micro"
  prod = "t2.small"

}

ports = [

  22,
  80,
  443

]

availability_zones = [

  "us-east-2a",
  "us-east-2b",
  "us-east-2c"

]
```

---

# Step 2 — Initialize Terraform

```bash
terraform init
```

---

# Step 3 — Run DEV Environment

```bash
terraform plan -var-file="dev.tfvars"
```

Apply

```bash
terraform apply -var-file="dev.tfvars"
```

---

# Step 4 — Run PROD Environment

```bash
terraform plan -var-file="prod.tfvars"
```

Apply

```bash
terraform apply -var-file="prod.tfvars"
```

---

# What  Learn From This Lab

| Concept   | Used                           |
| --------- | ------------------------------ |
| string    | region                         |
| number    | instance_count                 |
| list      | ports                          |
| map       | instance_types                 |
| set       | availability_zones             |
| locals    | instance_type                  |
| functions | lookup, upper, tolist, element |
| data      | AMI                            |
| count     | instance creation              |
| outputs   | show results                   |


