---
title: "Part 2: Terraform State Backend"
description: S3 + DynamoDB remote state, workspace strategy, and encrypted state management
---

# Part 2: Terraform State Backend

**← [Part 1: IAM Foundation](enterprise-sre-lab-part1-iam.md) | [Part 3: VPC & Network Architecture →](enterprise-sre-lab-part3-vpc.md)**

---

## Objective

Configure a production-grade Terraform remote state backend using S3 + DynamoDB. Establish workspace strategy for dev/staging/prod environments and enforce state file encryption and access control.

---

## Why Remote State Matters

In production teams:
- Multiple engineers run Terraform simultaneously
- Without locking → **state corruption** and duplicate resources
- Without remote state → no collaboration, no CI/CD
- Without encryption → secrets in state files are exposed

```
Local state (never in production)
  └─ .terraform/terraform.tfstate
        └─ stored on developer laptop
        └─ no locking, no sharing, no encryption

Remote state (always in production)
  └─ S3 bucket (encrypted, versioned)
        └─ DynamoDB table (state locking)
        └─ IAM policies (access control)
        └─ shared across all engineers and CI/CD
```

---

## Step 1 — Bootstrap State Infrastructure

This is the only Terraform you apply **locally** — everything after this uses remote state.

### Directory structure

```
terraform/
├── bootstrap/          ← applied locally, ONCE
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── modules/
│   ├── vpc/
│   ├── ecs/
│   ├── rds/
│   └── security/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── global/             ← IAM roles, Route53 zones
```

### bootstrap/main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "shopflow-terraform-state-${local.account_id}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name       = "shopflow-terraform-state"
    ManagedBy  = "bootstrap"
    CostCenter = "platform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# KMS key for state encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name      = "shopflow-terraform-state-key"
    ManagedBy = "bootstrap"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/shopflow-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "shopflow-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  tags = {
    Name      = "shopflow-terraform-locks"
    ManagedBy = "bootstrap"
  }
}
```

### bootstrap/variables.tf

```hcl
variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}
```

### bootstrap/outputs.tf

```hcl
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

output "kms_key_arn" {
  value = aws_kms_key.terraform_state.arn
}
```

### Apply bootstrap

```bash
cd terraform/bootstrap
terraform init
terraform plan -out=bootstrap.plan
terraform apply bootstrap.plan
```

---

## Step 2 — Configure Remote Backend for Each Environment

### environments/prod/backend.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "shopflow-terraform-state-123456789012"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/shopflow-terraform-state"
    dynamodb_table = "shopflow-terraform-locks"
  }
}
```

### environments/staging/backend.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "shopflow-terraform-state-123456789012"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/shopflow-terraform-state"
    dynamodb_table = "shopflow-terraform-locks"
  }
}
```

### environments/dev/backend.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "shopflow-terraform-state-123456789012"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/shopflow-terraform-state"
    dynamodb_table = "shopflow-terraform-locks"
  }
}
```

---

## Step 3 — Environment-Specific Variables

### environments/prod/terraform.tfvars

```hcl
environment    = "prod"
aws_region     = "us-east-1"
aws_account_id = "123456789012"

# VPC
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ECS
api_service_desired_count      = 4
checkout_service_desired_count = 4
api_cpu                        = 1024
api_memory                     = 2048

# RDS
rds_instance_class    = "db.r6g.xlarge"
rds_backup_retention  = 14
rds_multi_az          = true

# ElastiCache
redis_node_type       = "cache.r6g.large"
redis_num_cache_nodes = 3

# Tags
tags = {
  env        = "prod"
  team       = "sre"
  cost-center = "platform"
  managed-by = "terraform"
}
```

### environments/dev/terraform.tfvars

```hcl
environment    = "dev"
aws_region     = "us-east-1"
aws_account_id = "111111111111"

vpc_cidr           = "10.10.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

api_service_desired_count      = 1
checkout_service_desired_count = 1
api_cpu                        = 256
api_memory                     = 512

rds_instance_class   = "db.t4g.medium"
rds_backup_retention = 3
rds_multi_az         = false

redis_node_type       = "cache.t4g.micro"
redis_num_cache_nodes = 1

tags = {
  env        = "dev"
  team       = "sre"
  cost-center = "platform"
  managed-by = "terraform"
}
```

---

## Step 4 — Reusable Module Pattern

All infrastructure is defined as reusable modules called from environment directories.

### environments/prod/main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "ecs" {
  source = "../../modules/ecs"

  environment                    = var.environment
  vpc_id                         = module.vpc.vpc_id
  private_subnet_ids             = module.vpc.private_subnet_ids
  public_subnet_ids              = module.vpc.public_subnet_ids
  api_service_desired_count      = var.api_service_desired_count
  checkout_service_desired_count = var.checkout_service_desired_count
  api_cpu                        = var.api_cpu
  api_memory                     = var.api_memory
  waf_web_acl_arn                = module.security.waf_web_acl_arn
}

module "rds" {
  source = "../../modules/rds"

  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_instance_class   = var.rds_instance_class
  rds_backup_retention = var.rds_backup_retention
  rds_multi_az         = var.rds_multi_az
  ecs_security_group   = module.ecs.ecs_security_group_id
}

module "redis" {
  source = "../../modules/redis"

  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  redis_node_type      = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  ecs_security_group   = module.ecs.ecs_security_group_id
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  ecs_cluster_id = module.ecs.cluster_id
  rds_cluster_id = module.rds.cluster_id
}
```

---

## Step 5 — State Access Control (IAM)

### IAM Policy for Terraform CI/CD Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3StateAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::shopflow-terraform-state-*",
        "arn:aws:s3:::shopflow-terraform-state-*/*"
      ]
    },
    {
      "Sid": "DynamoDBLocking",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:*:table/shopflow-terraform-locks"
    },
    {
      "Sid": "KMSStateDecrypt",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": "arn:aws:kms:us-east-1:*:key/*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```

---

## Step 6 — State Operations Cheatsheet

### View current state

```bash
terraform state list
terraform state show module.ecs.aws_ecs_service.api
```

### Import existing resource into state

```bash
terraform import module.vpc.aws_vpc.main vpc-0123456789abcdef0
```

### Move resource in state (after refactoring)

```bash
terraform state mv \
  module.ecs.aws_ecs_service.api \
  module.ecs.aws_ecs_service.api_v2
```

### Remove resource from state (without destroying)

```bash
terraform state rm module.rds.aws_db_subnet_group.main
```

### Force unlock (when lock is stuck)

```bash
# Get lock ID from error message
terraform force-unlock LOCK_ID
```

!!! warning "Force Unlock Risk"
    Only use `force-unlock` if you are **certain** no other process is running Terraform. A stuck lock usually means a previous run crashed. Check CI/CD logs first.

### Refresh state without apply

```bash
terraform refresh
```

---

## Step 7 — Cross-Environment Remote State References

Use `terraform_remote_state` to share outputs between environments (e.g., read VPC IDs from a shared networking account).

```hcl
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "shopflow-terraform-state-123456789012"
    key    = "shared/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Reference in resource
resource "aws_ecs_service" "api" {
  # ...
  network_configuration {
    subnets = data.terraform_remote_state.networking.outputs.private_subnet_ids
  }
}
```

---

## Verification Checklist — Part 2

```
[ ] S3 bucket created with versioning enabled
[ ] S3 bucket has server-side encryption with KMS
[ ] S3 bucket has all public access blocked
[ ] DynamoDB table created with PAY_PER_REQUEST billing
[ ] DynamoDB table has point-in-time recovery enabled
[ ] Remote backend configured for prod, staging, dev environments
[ ] Each environment has its own state key path
[ ] tfvars files created for each environment
[ ] IAM policy for Terraform CI/CD role scoped to state bucket
[ ] Module structure created: vpc, ecs, rds, redis, security, monitoring
[ ] terraform init succeeds with remote backend in each environment
```

---

**[Part 3: VPC & Network Architecture →](enterprise-sre-lab-part3-vpc.md)**
