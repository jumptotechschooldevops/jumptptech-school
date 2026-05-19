---
title: "Terraform Lab 2 – Deploy Multiple Servers Using for_each"
description: "Goal Instead of using count,  deploy multiple servers using a map configuration.  Each server will..."
published: 2026-03-13
source: "https://dev.to/jumptotech/terraform-lab-2-deploy-multiple-servers-using-foreach-22g1"
tags: []
---

# Terraform Lab 2 – Deploy Multiple Servers Using for_each





Goal
Instead of using `count`,  deploy **multiple servers using a map configuration**.

Each server will have:

* different name
* different instance type

This is **very common in real DevOps infrastructure**.

---

# Project Structure

 create a **new folder**.

```bash
mkdir terraform-foreach-lab
cd terraform-foreach-lab
```

Create files

```bash
touch main.tf variables.tf outputs.tf terraform.tfvars
```

Project structure

```plaintext
terraform-foreach-lab
│
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

# variables.tf

 copy everything below.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "servers" {

  description = "Server configuration"

  type = map(object({

    instance_type = string
    name          = string

  }))

}
```

Concept students learn:

* **map**
* **object**
* infrastructure configuration

---

# terraform.tfvars

 define servers.

```hcl
aws_region = "us-east-2"

servers = {

  web = {
    instance_type = "t2.micro"
    name          = "web-server"
  }

  api = {
    instance_type = "t2.micro"
    name          = "api-server"
  }

  worker = {
    instance_type = "t2.micro"
    name          = "worker-server"
  }

}
```

Now Terraform knows **3 servers must be created**.

---

# main.tf

 copy the full file.

```hcl
provider "aws" {

  region = var.aws_region

}

########################################
# DATA SOURCE
########################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = ["amzn2-ami-hvm-*-x86_64-gp2"]

  }

}

########################################
# EC2 INSTANCES
########################################

resource "aws_instance" "servers" {

  for_each = var.servers

  ami           = data.aws_ami.amazon_linux.id

  instance_type = each.value.instance_type

  tags = {

    Name = upper(each.value.name)

    Role = each.key

  }

}
```

Important concepts here:

| Concept      | Explanation                |
| ------------ | -------------------------- |
| `for_each`   | creates multiple resources |
| `each.key`   | map key                    |
| `each.value` | map value                  |
| function     | `upper()`                  |

---

# outputs.tf

```hcl
output "instance_ids" {

  value = {

    for server, instance in aws_instance.servers :

    server => instance.id

  }

}

output "public_ips" {

  value = {

    for server, instance in aws_instance.servers :

    server => instance.public_ip

  }

}
```

 learn:

* **for expressions**
* returning structured outputs

---

# Run the Lab

Initialize Terraform

```bash
terraform init
```

Preview infrastructure

```bash
terraform plan
```

Create infrastructure

```bash
terraform apply
```

---

# Result

Terraform creates **3 servers**

```plaintext
web-server
api-server
worker-server
```

Example output

```hcl
public_ips = {
  web    = 3.18.200.21
  api    = 18.220.45.11
  worker = 3.144.22.90
}
```

---

# What  Learn in Lab 2

| Concept     | Used                     |
| ----------- | ------------------------ |
| map         | server definitions       |
| object      | structured configuration |
| for_each    | multiple resources       |
| each.key    | map key                  |
| each.value  | map values               |
| functions   | upper()                  |
| data source | AMI lookup               |
| outputs     | structured output        |


