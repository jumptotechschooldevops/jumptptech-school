# Lecture 2 · State, Modules & Workspaces

## Terraform state

Terraform stores the mapping between your configuration and the real infrastructure in a **state file** (`terraform.tfstate`). This file is how Terraform knows what it manages and what it does not.

Every time you run `terraform apply`, Terraform:

1. Reads the current state file
2. Reads the real infrastructure (refresh)
3. Compares the desired state (your `.tf` files) against the actual state
4. Plans and applies changes to close the gap
5. Writes the new state back to the state file

### Why the state file matters

The state file contains sensitive information — IP addresses, database endpoints, sometimes passwords. It must be treated as secret.

More critically: the state file must be the single source of truth, shared by everyone on your team. If each developer has their own local state file, you will have conflicts and out-of-sync infrastructure.

### Remote backends

Store state in a shared, remote location — not on your laptop:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true          # encrypt at rest
    dynamodb_table = "terraform-locks"  # state locking
  }
}
```

The DynamoDB table prevents two people from running `apply` simultaneously (which would corrupt the state):

```bash
# Create the S3 bucket and DynamoDB table first
aws s3 mb s3://my-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
    --bucket my-terraform-state \
    --versioning-configuration Status=Enabled

aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

Other backend options: GCS (Google Cloud Storage), Azure Blob Storage, Terraform Cloud.

### State commands

```bash
# List all resources in state
terraform state list

# Show a specific resource
terraform state show aws_instance.web

# Remove a resource from state (without destroying it)
# Use this if the resource was deleted outside of Terraform
terraform state rm aws_instance.web

# Import an existing resource into state
terraform import aws_instance.web i-0123456789abcdef

# Move a resource in state (after refactoring)
terraform state mv aws_instance.web module.webserver.aws_instance.main
```

!!! danger
    Never edit the state file manually. Use `terraform state` commands only.

---

## Modules

A module is a reusable collection of Terraform resources. You have already been using modules — the root configuration is itself a module. But you can create and call child modules to encapsulate patterns.

### Creating a module

```
modules/
  vpc/
    main.tf
    variables.tf
    outputs.tf
```

```hcl
# modules/vpc/variables.tf
variable "cidr_block" {
  type = string
}
variable "environment" {
  type = string
}
variable "public_subnet_count" {
  type    = number
  default = 2
}
```

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = { Name = "${var.environment}-vpc" }
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.environment}-public-${count.index}" }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.environment}-igw" }
}
```

```hcl
# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
```

### Calling a module

```hcl
# main.tf
module "vpc_staging" {
  source = "./modules/vpc"

  cidr_block          = "10.1.0.0/16"
  environment         = "staging"
  public_subnet_count = 2
}

module "vpc_production" {
  source = "./modules/vpc"

  cidr_block          = "10.2.0.0/16"
  environment         = "production"
  public_subnet_count = 3
}

# Use module outputs
resource "aws_instance" "web" {
  subnet_id = module.vpc_production.public_subnet_ids[0]
}
```

### Public registry modules

The Terraform Registry has thousands of community modules:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
}
```

Pin module versions just like provider versions. Unpinned modules can change under you.

---

## Workspaces

Workspaces let you use the same Terraform configuration with different state files — useful for managing multiple environments with one configuration.

```bash
# List workspaces (default always exists)
terraform workspace list

# Create and switch to staging
terraform workspace new staging
terraform workspace select staging

# Now apply — uses staging.tfvars or workspace-conditional logic
terraform apply -var-file="staging.tfvars"

# Switch to production
terraform workspace new production
terraform workspace select production
terraform apply -var-file="production.tfvars"

# Current workspace in configuration
resource "aws_instance" "web" {
  tags = {
    Environment = terraform.workspace
  }
}
```

Each workspace has its own state file under the backend key:

```
my-terraform-state/
  production/
    terraform.tfstate        # default workspace
  env:/
    staging/
      production/
        terraform.tfstate   # staging workspace
```

### Workspaces vs separate configurations

Workspaces work well when environments are nearly identical. When environments differ significantly (different region, different account, different architecture), separate Terraform configurations (separate directories) are cleaner and safer.

**Danger with workspaces:** If you forget which workspace you are in and run `apply` with production `.tfvars` while in the staging workspace, you may overwrite production state with staging resources. Many teams prefer separate state files with separate directories and explicit backend key differentiation.

---

## Best practices

### Directory structure

```
infrastructure/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
├── environments/
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
└── shared/
    └── state-backend/   # state bucket and DynamoDB table
```

### Naming conventions

```hcl
# Resource type + name + environment
resource "aws_security_group" "web_api_production" {}

# Or use name tags + local name prefix
locals {
  name = "${var.project}-${var.environment}"
}
resource "aws_security_group" "web" {
  name = "${local.name}-web-sg"
}
```

### Sensitive values

```hcl
# Mark outputs as sensitive
output "db_password" {
  value     = random_password.db.result
  sensitive = true
}

# Use environment variables for secrets
variable "db_password" {
  sensitive = true
}
# Set with: export TF_VAR_db_password=mypassword
```

### terraform.lock.hcl

```bash
# Always commit this file — it pins provider versions like a lockfile
git add .terraform.lock.hcl
```

---

## Summary

- State is Terraform's single source of truth. Store it in a shared remote backend (S3 + DynamoDB for AWS).
- State locking prevents concurrent modifications. DynamoDB provides this for S3 backends.
- Modules encapsulate reusable patterns. Pin module versions.
- Workspaces give each environment its own state. Use separate directories for very different environments.
- Commit `.terraform.lock.hcl`. Never commit `.terraform/` or `*.tfstate`.
