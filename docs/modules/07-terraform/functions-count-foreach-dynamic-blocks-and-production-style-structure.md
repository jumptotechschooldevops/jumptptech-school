---
title: "functions, count, for_each, dynamic blocks, and production-style structure,"
description: "1. Project Structure (Production Style)      terraform-devops-lab/ │ ├── main.tf ├──..."
published: 2026-03-16
source: "https://dev.to/jumptotech/functions-count-foreach-dynamic-blocks-and-production-style-structure-m67"
tags: []
---

# functions, count, for_each, dynamic blocks, and production-style structure,



# 1. Project Structure (Production Style)

```plaintext
terraform-devops-lab/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── security.tf
├── instances.tf
└── data.tf
```

Terraform reads **all `.tf` files together**, but we separate them for **clean architecture**.

---

# 2. provider.tf

Provider configuration and Terraform settings.

```hcl
terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# 3. variables.tf

Defines inputs.

```hcl
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_types" {

  type = map(string)

  default = {
    dev  = "t2.micro"
    prod = "t2.small"
  }

}

variable "servers" {

  type = list(string)

}

variable "ports" {

  type = list(number)

}
```

---

# 4. terraform.tfvars

Provides values.

```hcl
aws_region = "us-east-2"

environment = "dev"

servers = [
  "web",
  "api",
  "worker"
]

ports = [22,80,443]
```

---

# 5. data.tf

Production Terraform **never hardcodes AMIs**.

```hcl
data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

}
```

---

# 6. security.tf

Security group with **dynamic block**.

```hcl
resource "aws_security_group" "web" {

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
```

This automatically creates rules for:

```plaintext
22
80
443
```

---

# 7. instances.tf

Using both **count** and **for_each**.

### Count Example

```hcl
resource "aws_instance" "count_servers" {

  count = length(var.servers)

  ami           = data.aws_ami.amazon_linux.id
  instance_type = lookup(var.instance_types,var.environment)

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {

    Name = format(
      "%s-count-%s",
      var.environment,
      element(var.servers,count.index)
    )

  }

}
```

Functions used here:

```plaintext
length()
lookup()
element()
format()
```

---

### for_each Example

```hcl
resource "aws_instance" "foreach_servers" {

  for_each = toset(var.servers)

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {

    Name = "${var.environment}-foreach-${each.value}"

  }

}
```

---

# 8. main.tf

Local resource with **timestamp()**

```hcl
resource "local_file" "deployment_info" {

  filename = "deployment.txt"

  content = format(
    "Terraform deployment time: %s",
    timestamp()
  )

}
```

---

# 9. outputs.tf

Terraform outputs.

```hcl
output "server_count" {

  value = length(var.servers)

}

output "security_group_id" {

  value = aws_security_group.web.id

}

output "deployment_time" {

  value = timestamp()

}
```

---

# 10. Commands  Practice

Initialize providers

```shell
terraform init -upgrade
```

Create execution plan

```shell
terraform plan -out=infra.plan
```

Apply saved plan

```shell
terraform apply infra.plan
```

Target specific resource

```shell
terraform plan -target=local_file.deployment_info
terraform apply -target=local_file.deployment_info
terraform destroy -target=local_file.deployment_info
```

Create only security group

```shell
terraform apply -target=aws_security_group.web
```

Force recreation

```shell
terraform taint aws_instance.count_servers[0]
```

Show outputs

```shell
terraform output
```

Show dependency graph

```shell
terraform graph
```

Generate infrastructure diagram

```shell
terraform graph | dot -Tpng > graph.png
```

---

# 11. Architecture Created

```plaintext
           Data Source
        (Latest Amazon AMI)
                │
                ▼
        Security Group
        Dynamic Rules
      22 / 80 / 443
                │
                ▼
        EC2 Instances
        count + for_each
                │
                ▼
        Local File
       deployment.txt
                │
                ▼
             Outputs
```

---

# 12. Why This Lab Is Production-Ready

This lab teaches  **real Terraform patterns**:

* dynamic infrastructure
* environment configuration
* reusable variables
* data sources
* dependency graph
* count vs for_each
* tfvars separation
* organized file structure

This is **very close to how Terraform is used in DevOps teams**.


