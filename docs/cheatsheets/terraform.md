# Terraform Cheatsheet

## Core workflow

```bash
terraform init                    # initialise — download providers, modules
terraform init -upgrade           # upgrade providers to latest allowed versions
terraform init -migrate-state     # re-init and migrate state (e.g. new backend)

terraform validate                # validate HCL syntax
terraform fmt                     # format all .tf files
terraform fmt -check              # check formatting (exit 1 if not formatted)

terraform plan                    # show what will change
terraform plan -out=plan.tfplan   # save plan to file
terraform plan -var="env=staging" # override a variable
terraform plan -var-file="staging.tfvars"

terraform apply                   # apply changes (prompts for confirmation)
terraform apply -auto-approve     # skip confirmation (CI use only)
terraform apply plan.tfplan       # apply a saved plan

terraform destroy                 # destroy all managed resources
terraform destroy -target=aws_instance.web  # destroy specific resource
```

## State

```bash
terraform state list              # list all resources in state
terraform state show aws_vpc.main # inspect a resource's state
terraform state rm aws_instance.old  # remove from state (doesn't destroy)
terraform state mv old.name new.name # rename/move in state
terraform state pull              # download remote state locally
terraform state push local.tfstate  # upload local state to remote

terraform import aws_instance.web i-0abc123  # import existing resource
terraform refresh                 # sync state with real infrastructure
```

## Workspaces

```bash
terraform workspace list          # list workspaces
terraform workspace new staging   # create workspace
terraform workspace select staging  # switch workspace
terraform workspace show          # current workspace
terraform workspace delete staging  # delete workspace
```

## Output

```bash
terraform output                  # show all outputs
terraform output vpc_id           # specific output
terraform output -json            # JSON format
terraform output -raw vpc_id      # raw value (no quotes)
```

## HCL — Common syntax

```hcl
# String
name = "myapp-${var.environment}"

# Number
count = 3

# Boolean
enable_dns = true

# List
subnets = ["10.0.1.0/24", "10.0.2.0/24"]

# Map
tags = {
  Environment = "production"
  ManagedBy   = "terraform"
}

# Heredoc
user_data = <<-EOF
  #!/bin/bash
  apt-get install -y nginx
EOF

# Conditional
instance_type = var.environment == "production" ? "t3.medium" : "t2.micro"

# For expression (list)
subnet_ids = [for s in aws_subnet.public : s.id]

# For expression (map)
subnet_map = {for s in aws_subnet.public : s.availability_zone => s.id}

# Splat operator
subnet_ids = aws_subnet.public[*].id

# Null coalescing
name = coalesce(var.name, "default-name")
```

## Variables

```hcl
# Declare
variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Must be staging or production."
  }
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "db_password" {
  type      = string
  sensitive = true
}
```

```bash
# Provide values
terraform apply -var="environment=production"
terraform apply -var-file="production.tfvars"
export TF_VAR_db_password="mysecret"  # environment variable
```

## Outputs

```hcl
output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the web server"
}

output "database_password" {
  value     = var.db_password
  sensitive = true  # masked in output, visible in state
}
```

## Locals

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}
```

## Data sources

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
# Usage: data.aws_caller_identity.current.account_id
```

## Modules

```hcl
# Call a local module
module "vpc" {
  source = "./modules/vpc"

  cidr_block   = "10.0.0.0/16"
  environment  = var.environment
}

# Call a registry module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}

# Use module outputs
resource "aws_instance" "web" {
  subnet_id = module.vpc.public_subnet_ids[0]
}
```

## Count and for_each

```hcl
# count
resource "aws_subnet" "public" {
  count      = 3
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id     = aws_vpc.main.id
}

# Reference: aws_subnet.public[0].id
# All IDs: aws_subnet.public[*].id

# for_each with set of strings
resource "aws_security_group_rule" "ingress" {
  for_each    = toset(["80", "443", "22"])
  type        = "ingress"
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# for_each with map
variable "instances" {
  default = {
    web = "t2.micro"
    api = "t2.small"
  }
}
resource "aws_instance" "servers" {
  for_each      = var.instances
  instance_type = each.value
  tags          = { Name = each.key }
}
# Reference: aws_instance.servers["web"].id
```

## Backend configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Lifecycle rules

```hcl
resource "aws_instance" "web" {
  # ...
  lifecycle {
    create_before_destroy = true   # create new before destroying old
    prevent_destroy       = true   # block destroy (error if attempted)
    ignore_changes        = [tags] # ignore external changes to tags
  }
}
```

## Dependencies

```hcl
# Implicit (Terraform detects automatically)
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id  # depends on aws_vpc.main
}

# Explicit (for non-visible dependencies)
resource "aws_instance" "web" {
  depends_on = [aws_internet_gateway.main]
}
```

## Common AWS resources

```hcl
# EC2
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.main.key_name
  user_data              = file("user_data.sh")
  tags                   = { Name = "web-server" }
}

# Security Group
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress { from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0;  to_port = 0;  protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = "my-unique-bucket-name"
}
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}
```

## Files to commit / ignore

```gitignore
# .gitignore for Terraform

# Local state (use remote backend instead)
*.tfstate
*.tfstate.backup

# Terraform working directory
.terraform/

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Variable files with secrets
*.tfvars          # uncomment if using tfvars for secrets
# terraform.tfvars  # but commit this if it doesn't have secrets

# Crash log
crash.log

# Generated plans
*.tfplan

# COMMIT this file:
# .terraform.lock.hcl
```
