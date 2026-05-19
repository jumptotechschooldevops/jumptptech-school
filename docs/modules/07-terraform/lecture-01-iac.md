# Lecture 1 · Infrastructure as Code

## The problem with manual infrastructure

Imagine you set up a production database: you log into the AWS console, click through the RDS creation wizard, configure the instance class, storage, backups, parameter groups, and security groups. It works. A month later, you need to set up staging. You try to recreate the same configuration from memory. You get most of it right but miss the parameter group change that prevented connection timeouts. Staging behaves differently from production.

Three months later, someone from your team makes a "quick change" to the production security group to debug an issue. They forget to revert it. Nobody knows it happened.

IaC solves all of these:

- Infrastructure is defined in code → reproducible, consistent environments
- Changes go through version control → full audit trail
- Changes go through code review → no unreviewed modifications
- You can `terraform plan` before applying → see what will change before it changes

---

## Terraform basics

### HCL syntax

HCL (HashiCorp Configuration Language) is the language Terraform uses. It looks like JSON but is more readable:

```hcl
# A block
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name        = "web-server"
    Environment = "production"
  }
}

# Strings with interpolation
name = "web-${var.environment}"

# Numbers and booleans
count             = 3
enable_monitoring = true

# Lists
availability_zones = ["us-east-1a", "us-east-1b"]

# Maps
tags = {
  team    = "platform"
  project = "devops-school"
}
```

### The workflow

```bash
# 1. Initialise — download providers and modules
terraform init

# 2. Plan — see what will change
terraform plan

# 3. Apply — make the changes
terraform apply

# 4. Destroy — remove all managed resources
terraform destroy
```

`terraform plan` shows you exactly what Terraform will create, modify, or destroy. It is like `git diff` for infrastructure. You should always read the plan output before applying.

---

## Providers

A provider is a plugin that knows how to talk to a specific API. There are providers for AWS, GCP, Azure, Kubernetes, GitHub, Cloudflare, Datadog, and hundreds of others.

```hcl
terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # any 5.x version
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Credentials come from environment variables or ~/.aws/credentials
  # NEVER hardcode access keys here
}
```

---

## Resources

Resources are the things Terraform manages. Each resource type has a specific schema.

```hcl
# An AWS VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# A subnet that depends on the VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id   # reference to the VPC above
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
```

`aws_vpc.main.id` is an attribute reference — Terraform knows the VPC must be created first because the subnet depends on its ID. Dependency tracking is automatic.

---

## Variables

Variables make configurations reusable:

```hcl
# variables.tf
variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be staging or production."
  }
}

variable "instance_type" {
  type    = string
  default = "t2.micro"   # optional — used if not provided
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}
```

Providing values:

```bash
# Command line
terraform apply -var="environment=staging"

# Variable file (recommended)
terraform apply -var-file="staging.tfvars"

# Environment variable (TF_VAR_ prefix)
export TF_VAR_environment=staging
terraform apply
```

```hcl
# staging.tfvars
environment     = "staging"
instance_type   = "t2.micro"
allowed_ssh_cidrs = ["10.0.0.0/8"]
```

---

## Outputs

Outputs expose values after apply — useful for passing information to other systems:

```hcl
# outputs.tf
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the main VPC"
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "connection_string" {
  value     = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.web.public_ip}"
  sensitive = false
}

output "database_password" {
  value     = aws_db_instance.main.password
  sensitive = true   # masked in terminal output, but in state
}
```

```bash
terraform output                 # all outputs
terraform output vpc_id          # specific output
terraform output -json           # JSON format (for scripts)
```

---

## Data sources

Data sources read information from the provider without creating anything. Use them to reference existing infrastructure:

```hcl
# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use it in a resource
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  # ...
}
```

Other common data sources:
- `data.aws_availability_zones.available` — list AZs in the current region
- `data.aws_caller_identity.current` — get your AWS account ID
- `data.terraform_remote_state.vpc` — read outputs from another Terraform state

---

## Local values

Local values compute intermediate values to avoid repetition:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "devops-school"
    ManagedBy   = "terraform"
  }

  name_prefix = "${var.project}-${var.environment}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}
```

---

## Count and for_each

Create multiple similar resources:

```hcl
# count — creates N identical resources, indexed 0 to N-1
resource "aws_subnet" "public" {
  count             = 3
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
}

# for_each — creates resources from a map or set
variable "environments" {
  type = map(object({
    cidr          = string
    instance_type = string
  }))
  default = {
    staging    = { cidr = "10.1.0.0/16", instance_type = "t2.micro" }
    production = { cidr = "10.2.0.0/16", instance_type = "t2.small" }
  }
}

resource "aws_vpc" "env" {
  for_each   = var.environments
  cidr_block = each.value.cidr
  tags        = { Name = each.key }
}
```

Prefer `for_each` over `count` for named resources. Removing an item from the middle of a `count` list renumbers all subsequent resources, potentially destroying and recreating things you did not intend to touch.

---

## Summary

- Terraform uses HCL to declare infrastructure. Plan → Apply → Destroy.
- Providers are plugins for specific APIs. Pin provider versions.
- Resources reference each other by attribute — Terraform builds the dependency graph automatically.
- Variables make configurations reusable. Use `.tfvars` files for environment-specific values.
- Data sources read existing infrastructure without managing it.
- Never hardcode credentials in Terraform files.
