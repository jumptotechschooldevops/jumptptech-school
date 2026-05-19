---
title: "PRODUCTION TERRAFORM MODULES LAB"
description: "Build a real-world architecture using modules:   VPC (network) Security Group EC2 (app layer) ALB..."
published: 2026-03-19
source: "https://dev.to/jumptotech/production-terraform-modules-lab-1oo6"
tags: []
---

# PRODUCTION TERRAFORM MODULES LAB





Build a **real-world architecture using modules**:

* VPC (network)
* Security Group
* EC2 (app layer)
* ALB (load balancer)
* Multi-environment structure (dev/prod)
* Remote-ready structure (like companies)

---

# 🏗️ REAL-WORLD STRUCTURE (VERY IMPORTANT)

```bash
terraform-production-lab/
│
├── infra-modules/              # reusable modules (shared)
│   ├── vpc/
│   ├── ec2/
│   ├── security-group/
│   └── alb/
│
└── infra-live/                 # environments (what we deploy)
    ├── dev/
    └── prod/
```

---

# 🧠 WHY THIS STRUCTURE (INTERVIEW GOLD)

Companies **separate code**:

### 1. infra-modules

* reusable
* versioned
* no environment-specific values

### 2. infra-live

* environment-specific (dev, prod)
* small configs
* calls modules

👉 This avoids duplication and supports scaling

---

# 📁 STEP 1 — CREATE STRUCTURE

```bash
mkdir -p terraform-production-lab/infra-modules/{vpc,ec2,security-group,alb}
mkdir -p terraform-production-lab/infra-live/{dev,prod}
cd terraform-production-lab
```

---

# 🔷 MODULE 1 — VPC (Production Version)

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

---

## variables.tf

```hcl
variable "cidr_block" { type = string }
variable "public_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "name" { type = string }
variable "tags" { type = map(string) }
```

---

## outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}
```

---

# 🔷 MODULE 2 — SECURITY GROUP

## infra-modules/security-group/main.tf

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

---

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

---

# 🔷 MODULE 3 — EC2 (Production Version)

## infra-modules/ec2/main.tf

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

---

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

---

## outputs.tf

```hcl
output "instance_ids" {
  value = aws_instance.this[*].id
}
```

---

# 🔷 MODULE 4 — ALB (IMPORTANT FOR INTERVIEW)

## infra-modules/alb/main.tf

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

---

# 🔷 DEV ENVIRONMENT

## infra-live/dev/main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

module "vpc" {
  source          = "../../infra-modules/vpc"
  cidr_block      = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
  name            = "dev-vpc"
  tags            = { Environment = "dev" }
}

module "sg" {
  source = "../../infra-modules/security-group"

  name   = "dev-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { port = 22, cidr_blocks = ["0.0.0.0/0"] },
    { port = 80, cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "ec2" {
  source = "../../infra-modules/ec2"

  ami            = data.aws_ami.latest.id
  instance_type  = "t3.micro"
  subnet_ids     = module.vpc.public_subnets
  sg_ids         = [module.sg.this_id]
  instance_count = 2
  name           = "dev-app"
  tags           = { Environment = "dev" }
}
```

---

# ⚙️ COMMANDS (PRODUCTION FLOW)

```bash
cd infra-live/dev

terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=dev.plan
terraform apply dev.plan

terraform state list
terraform graph | dot -Tpng > graph.png

terraform output
terraform destroy
```

---

# 🎯 INTERVIEW QUESTIONS (MUST KNOW)

## BASIC

* What is a module?
* Root vs child module?
* Why use modules?

## INTERMEDIATE

* How do modules communicate?
  👉 outputs + variables

* Can modules call modules?
  👉 YES (nested modules)

* Local vs remote module?
  👉 local path vs Git/registry

## ADVANCED

* How do you version modules?
  👉 Git tags (`?ref=v1.0.0`)

* How do you structure large Terraform code?
  👉 infra-modules + infra-live

* How do you avoid duplication?
  👉 reusable modules

* When NOT to use modules?
  👉 very small/simple config

---

# 🔥 WHAT YOU MUST SAY TO PASS INTERVIEW

### 1. Module definition

> A module is a reusable Terraform configuration that groups related resources and allows parameterization using variables and outputs.

---

### 2. Production structure

> In production, we separate modules into a reusable repository and environments into another repository to avoid duplication and enable versioning.

---

### 3. Communication

> Modules communicate using outputs and variables. For example, VPC outputs subnet IDs, which are passed into EC2 module.

---

### 4. Best practices

* no hardcoding
* use variables
* use outputs
* small focused modules
* version modules
* separate environments

---

### 5. Real-world design

> I designed modules for VPC, EC2, ALB, and security groups. The root module connects them and manages environment-specific configuration.

---

# 🚨 COMMON MISTAKES (INTERVIEW TRAPS)

* hardcoded AMI
* giant modules
* no outputs
* no variables
* mixing environments
* no versioning
* using modules incorrectly

---

# 🚀 IF YOU MASTER THIS LAB

You are ready for:

* DevOps interviews
* Terraform Associate
* Real company projects


