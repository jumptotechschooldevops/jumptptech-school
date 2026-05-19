---
title: "production-style infrastructure: ALB module infra-modules + infra-live separation environment-based deployment"
description: "🏗️ FINAL STRUCTURE      terraform-production-lab/ │ ├── infra-modules/ │   ├── vpc/ │   ├──..."
published: 2026-03-19
source: "https://dev.to/jumptotech/production-style-infrastructure-alb-module-infra-modules-infra-live-separation-51eh"
tags: []
---

# production-style infrastructure: ALB module infra-modules + infra-live separation environment-based deployment





# 🏗️ FINAL STRUCTURE

```bash
terraform-production-lab/
│
├── infra-modules/
│   ├── vpc/
│   ├── security-group/
│   ├── ec2/
│   └── alb/
│
└── infra-live/
    ├── dev/
    └── prod/
```

---

# 🧠 IDEA (VERY IMPORTANT)

* `infra-modules` → reusable (write once)
* `infra-live` → environment-specific (dev/prod)

---

# ⚙️ STEP 1 — CREATE STRUCTURE

```bash
mkdir -p terraform-production-lab/infra-modules/{vpc,security-group,ec2,alb}
mkdir -p terraform-production-lab/infra-live/{dev,prod}
cd terraform-production-lab
```

---

# 🔷 MODULE 1 — VPC

## infra-modules/vpc/main.tf

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-public-${count.index}"
  })
}
```

## variables.tf

```hcl
variable "cidr_block" { type = string }
variable "public_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "name" { type = string }
variable "tags" { type = map(string) }
```

## outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = aws_subnet.public[*].id
}
```

---

# 🔷 MODULE 2 — SECURITY GROUP

## main.tf

```hcl
resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## variables.tf

```hcl
variable "name" { type = string }
variable "vpc_id" { type = string }

variable "ingress_rules" {
  type = list(object({
    port        = number
    cidr_blocks = list(string)
  }))
}
```

## outputs.tf (IMPORTANT FIX)

```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```

---

# 🔷 MODULE 3 — EC2 (SCALING)

## main.tf

```hcl
resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.sg_ids

  tags = merge(var.tags, {
    Name = "${var.name}-${count.index}"
  })
}
```

## variables.tf

```hcl
variable "ami" { type = string }
variable "instance_type" { type = string }
variable "subnet_ids" { type = list(string) }
variable "sg_ids" { type = list(string) }
variable "instance_count" { type = number }
variable "name" { type = string }
variable "tags" { type = map(string) }
```

## outputs.tf

```hcl
output "instance_ids" {
  value = aws_instance.this[*].id
}
```

---

# 🔷 MODULE 4 — ALB

## main.tf

```hcl
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.sg_ids
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
```

## variables.tf

```hcl
variable "name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "sg_ids" { type = list(string) }
variable "vpc_id" { type = string }
```

---

# 🌍 DEV ENVIRONMENT

## infra-live/dev/main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

# dynamic AMI
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

# VPC
module "vpc" {
  source = "../../infra-modules/vpc"

  cidr_block     = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
  name           = "dev-vpc"
  tags           = { Environment = "dev" }
}

# SG
module "sg" {
  source = "../../infra-modules/security-group"

  name   = "dev-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { port = 22, cidr_blocks = ["0.0.0.0/0"] },
    { port = 80, cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# EC2
module "ec2" {
  source = "../../infra-modules/ec2"

  ami            = data.aws_ami.latest.id
  instance_type  = "t3.micro"
  subnet_ids     = module.vpc.subnet_ids
  sg_ids         = [module.sg.sg_id]
  instance_count = 2
  name           = "dev-app"
  tags           = { Environment = "dev" }
}

# ALB
module "alb" {
  source = "../../infra-modules/alb"

  name       = "dev-alb"
  subnet_ids = module.vpc.subnet_ids
  sg_ids     = [module.sg.sg_id]
  vpc_id     = module.vpc.vpc_id
}
```

---

# ⚙️ FULL COMMAND FLOW

```bash
cd infra-live/dev

terraform fmt -recursive
terraform init
terraform validate

terraform plan -out=dev.plan
terraform show dev.plan

terraform apply dev.plan

terraform state list
terraform state show module.ec2.aws_instance.this[0]

terraform graph | dot -Tpng > graph.png
open graph.png

terraform output

terraform apply -replace="module.ec2.aws_instance.this[0]"

terraform destroy -auto-approve
```

---

# 🎯 WHAT THIS LAB COVERS

You now understand:

✅ DRY principle
✅ module reuse
✅ module communication
✅ infra-modules vs infra-live
✅ scaling (count)
✅ dynamic blocks (security group)
✅ dynamic AMI
✅ ALB integration
✅ production structure

---

# 🧠 INTERVIEW CONNECTION

If interviewer asks:

👉 “Design Terraform modules for large company”

You answer:

> I separate infrastructure into reusable modules like VPC, EC2, ALB, and security groups. These modules are stored in a central repository and versioned. Then I use environment-specific configurations (dev, prod) to call these modules. Modules communicate through outputs and variables, and I avoid hardcoding by using dynamic inputs and data sources.


