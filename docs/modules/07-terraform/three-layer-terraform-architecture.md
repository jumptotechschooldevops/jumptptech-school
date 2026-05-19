---
title: "Three layer terraform architecture"
description: "Prerequisites Folder Structure Create this structure:   terraform-3layer-aws/ ├─ resource-modules/ │..."
published: 2025-12-06
source: "https://dev.to/jumptotech/three-layer-terraform-architecture-24g9"
tags: []
---

# Three layer terraform architecture

0. Prerequisites
1. Folder Structure
Create this structure:

terraform-3layer-aws/
├─ resource-modules/
│  ├─ storage/
│  │  └─ s3-backend/
│  ├─ database/
│  │  └─ dynamodb-backend/
│  ├─ security/
│  │  └─ kms-backend/
│  └─ network/
│     └─ vpc-basic/
├─ infra/
│  ├─ remote-backend/
│  └─ vpc/
└─ composition/
   ├─ remote-backend/
   │  └─ us-east-2/
   │     └─ prod/
   └─ vpc/
      └─ us-east-2/
         └─ prod/
We’ll fill these folders with .tf files now.

2. Resource Modules (Lowest Layer)
2.1 S3 Backend Bucket Module
Path: resource-modules/storage/s3-backend/main.tf

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
Path: resource-modules/storage/s3-backend/variables.tf

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy bucket"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
Path: resource-modules/storage/s3-backend/outputs.tf

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
What this does:
Creates an S3 bucket with:

versioning enabled
KMS encryption
public access blocked
This will be used for Terraform state.

2.2 DynamoDB Backend Table Module
Path: resource-modules/database/dynamodb-backend/main.tf

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
Path: resource-modules/database/dynamodb-backend/variables.tf

variable "table_name" {
  description = "Name of the DynamoDB table to use for state locking"
  type        = string
}
Path: resource-modules/database/dynamodb-backend/outputs.tf

output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}
What this does:
Creates a DynamoDB table with a LockID key, used by Terraform for state locking.

2.3 KMS Key Module
Path: resource-modules/security/kms-backend/main.tf

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
Path: resource-modules/security/kms-backend/variables.tf

variable "description" {
  description = "Description for the KMS key"
  type        = string
}
Path: resource-modules/security/kms-backend/outputs.tf

output "key_id" {
  value = aws_kms_key.this.key_id
}

output "key_arn" {
  value = aws_kms_key.this.arn
}
What this does:
Creates a KMS key with rotation enabled. We will use it to encrypt the S3 bucket.

2.4 Basic VPC Module (VPC + 3 Subnets + IGW + Public RT)
Path: resource-modules/network/vpc-basic/main.tf

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-vpc" }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-igw" }
  )
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.az

  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-public-subnet" }
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-private-subnet" }
  )
}

resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidr
  availability_zone = var.az

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-database-subnet" }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-public-rt" }
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
Path: resource-modules/network/vpc-basic/variables.tf

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "database_subnet_cidr" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
Path: resource-modules/network/vpc-basic/outputs.tf

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "database_subnet_id" {
  value = aws_subnet.database.id
}
What this does:
Creates:

1 VPC
1 public subnet (with IGW + route table)
1 private subnet
1 database subnet
You can later extend this to multi-AZ, NAT gateway, etc.

3. Infra Layer – Remote Backend Facade
This layer wraps the three backend-related resource modules and exposes one simple module.

Path: infra/remote-backend/variables.tf

variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}
Path: infra/remote-backend/main.tf

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

locals {
  bucket_name = "${var.project}-${var.environment}-tfstate-${random_integer.suffix.result}"
  table_name  = "${var.project}-${var.environment}-tf-lock"
}

module "kms_backend" {
  source      = "../../resource-modules/security/kms-backend"
  description = "KMS key for Terraform state encryption"
}

module "s3_backend" {
  source        = "../../resource-modules/storage/s3-backend"
  bucket_name   = local.bucket_name
  force_destroy = false
  kms_key_arn   = module.kms_backend.key_arn
}

module "dynamodb_backend" {
  source     = "../../resource-modules/database/dynamodb-backend"
  table_name = local.table_name
}
Path: infra/remote-backend/outputs.tf

output "backend_bucket_name" {
  value = module.s3_backend.bucket_name
}

output "backend_dynamodb_table_name" {
  value = module.dynamodb_backend.table_name
}

output "backend_kms_key_arn" {
  value = module.kms_backend.key_arn
}
What this does (facade idea):

Generates a unique bucket name using random_integer
Creates:
KMS key
S3 bucket (encrypted with KMS)
DynamoDB lock table
Exposes only:
bucket name
table name
kms key ARN
The composition layer only calls this module, not the raw resources.

4. Composition – Remote Backend (us-east-2 / prod)
This is your entry point for creating the backend in us-east-2.

Path: composition/remote-backend/us-east-2/prod/main.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # IMPORTANT: First run: keep backend local.
  # After S3/DynamoDB are created, you can configure backend "s3" here if you want.
  # backend "s3" {
  #   bucket         = "REPLACE_WITH_CREATED_BUCKET"
  #   key            = "tf/backend/us-east-2/prod/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "REPLACE_WITH_CREATED_TABLE"
  # }
}

provider "aws" {
  region = var.region
}

module "remote_backend" {
  source      = "../../../../../infra/remote-backend"
  project     = var.project
  environment = var.environment
  region      = var.region
}

output "backend_bucket_name" {
  value = module.remote_backend.backend_bucket_name
}

output "backend_dynamodb_table_name" {
  value = module.remote_backend.backend_dynamodb_table_name
}

output "backend_kms_key_arn" {
  value = module.remote_backend.backend_kms_key_arn
}
Path: composition/remote-backend/us-east-2/prod/variables.tf

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region"
}
Path: composition/remote-backend/us-east-2/prod/terraform.tfvars

project     = "my-demo"
environment = "prod"
region      = "us-east-2"
Explanation of this step:

This is the root where you run terraform init and terraform apply.
It defines:
Terraform version and providers (aws, random)
AWS provider configured to us-east-2
Calls the infra module infra/remote-backend
First run: backend block is commented, so Terraform uses local state.
After it creates S3 & DynamoDB, you can enable the backend "s3" block (optional).
5. Run the Remote Backend Stack
From the project root:

cd composition/remote-backend/us-east-2/prod

terraform init
terraform plan
terraform apply
You should see resources:

KMS key
S3 bucket (name includes random number)
DynamoDB table
The outputs should print:

backend_bucket_name
backend_dynamodb_table_name
backend_kms_key_arn
These are your real backend components in us-east-2.

If you want, you can now edit the backend "s3" block in this or another stack to use:

backend "s3" {
  bucket         = "<value of backend_bucket_name>"
  key            = "tf/backend/us-east-2/prod/terraform.tfstate"
  region         = "us-east-2"
  dynamodb_table = "<value of backend_dynamodb_table_name>"
}
Then run terraform init -migrate-state to migrate local → S3.
(That’s an advanced step; not required right now.)

6. Infra – VPC Facade
Now we build the VPC infra module which wraps the basic VPC resource module.

Path: infra/vpc/locals.tf

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
Path: infra/vpc/variables.tf

variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }

variable "cidr_block"  { type = string }
variable "az"          { type = string }

variable "public_subnet_cidr"   { type = string }
variable "private_subnet_cidr"  { type = string }
variable "database_subnet_cidr" { type = string }
Path: infra/vpc/main.tf

module "vpc_basic" {
  source = "../../resource-modules/network/vpc-basic"

  project              = var.project
  environment          = var.environment
  cidr_block           = var.cidr_block
  az                   = var.az
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  tags                 = local.common_tags
}
Path: infra/vpc/outputs.tf

output "vpc_id" {
  value = module.vpc_basic.vpc_id
}

output "public_subnet_id" {
  value = module.vpc_basic.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc_basic.private_subnet_id
}

output "database_subnet_id" {
  value = module.vpc_basic.database_subnet_id
}
Explanation:

This module wraps the vpc-basic resource module
It doesn’t know about environments like “us-east-2/prod”; it just takes inputs
It exposes clean outputs: VPC ID + subnet IDs
Later you can add security groups, NAT, etc., here
7. Composition – VPC (us-east-2 / prod)
Now we create the VPC using the infra module.

Path: composition/vpc/us-east-2/prod/main.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # OPTIONAL: once your backend S3 and DynamoDB exist, you can configure:
  # backend "s3" {
  #   bucket         = "YOUR_BACKEND_BUCKET"
  #   key            = "vpc/us-east-2/prod/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "YOUR_LOCK_TABLE"
  # }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../../../../infra/vpc"

  project              = var.project
  environment          = var.environment
  region               = var.region
  cidr_block           = var.cidr_block
  az                   = var.az
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "database_subnet_id" {
  value = module.vpc.database_subnet_id
}
Path: composition/vpc/us-east-2/prod/variables.tf

variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }
variable "cidr_block"  { type = string }
variable "az"          { type = string }

variable "public_subnet_cidr"   { type = string }
variable "private_subnet_cidr"  { type = string }
variable "database_subnet_cidr" { type = string }
Path: composition/vpc/us-east-2/prod/terraform.tfvars

project     = "my-demo"
environment = "prod"
region      = "us-east-2"

cidr_block  = "10.0.0.0/16"
az          = "us-east-2a"

public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
database_subnet_cidr = "10.0.3.0/24"
Explanation:

This is your entry point for creating the VPC in us-east-2
It defines provider aws with region = var.region
It calls the infra/vpc module
It passes in project, environment, CIDRs, AZ
It outputs VPC ID + subnet IDs (so you can plug them into ECS/EKS/etc. later)
8. Run the VPC Stack
From project root:

cd composition/vpc/us-east-2/prod

terraform init
terraform plan
terraform apply
You should see:

1 VPC in us-east-2
1 public subnet in us-east-2a with IGW and route
1 private subnet
1 database subnet
Outputs:

vpc_id
public_subnet_id
private_subnet_id
database_subnet_id
9. How This Matches the 3-Layer Architecture From the Lecture
Resource modules
s3-backend, dynamodb-backend, kms-backend, vpc-basic
Raw AWS resources, nothing about environments
Infra modules (facades)
infra/remote-backend
bundles S3 + DynamoDB + KMS
infra/vpc
bundles VPC + subnets (later SGs)
Composition layer (environments)
composition/remote-backend/us-east-2/prod
composition/vpc/us-east-2/prod
Each is an entry point for a specific env/region
This is the same concept as your chapter:
resource → infra → composition, just with shortened code so you can actually read and teach it.
Top comments (0)


