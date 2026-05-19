---
title: "LAB: Terraform Alias + Workspace + Import (Production Style)"
description: "📁 Project Structure (Skeleton)      terraform-alias-workspace-import-lab/ │ ├──..."
published: 2026-04-01
source: "https://dev.to/jumptotech/lab-terraform-alias-workspace-import-production-style-8jm"
tags: []
---

# LAB: Terraform Alias + Workspace + Import (Production Style)







# 📁 Project Structure (Skeleton)

```plaintext
terraform-alias-workspace-import-lab/
│
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
│
├── backend.tf
│
└── scripts/
    └── import.sh
```

---

# 1️⃣ providers.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider (primary region)
provider "aws" {
  region = var.primary_region
}

# Alias provider (secondary region)
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

---

# 2️⃣ variables.tf (NO hardcoding)

```hcl
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "primary_region" {
  type = string
}

variable "secondary_region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
  default = {}
}
```

---

# 3️⃣ main.tf

### 🔹 Uses:

* workspace
* alias provider
* dynamic naming

```hcl
locals {
  env = terraform.workspace

  name_prefix = "${var.project_name}-${local.env}"

  tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = local.env
    ManagedBy   = "Terraform"
  })
}

# Primary region bucket
resource "aws_s3_bucket" "primary" {
  bucket = "${local.name_prefix}-primary"

  tags = local.tags
}

# Secondary region bucket (alias usage)
resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary

  bucket = "${local.name_prefix}-secondary"

  tags = local.tags
}
```

---

# 4️⃣ outputs.tf

```hcl
output "primary_bucket" {
  value = aws_s3_bucket.primary.bucket
}

output "secondary_bucket" {
  value = aws_s3_bucket.secondary.bucket
}

output "workspace" {
  value = terraform.workspace
}
```

---

# 5️⃣ terraform.tfvars.example

```hcl
project_name     = "jumptotech"
environment      = "dev"
primary_region   = "us-east-2"
secondary_region = "us-west-1"

common_tags = {
  Owner = "DevOpsTeam"
}
```

---

# 6️⃣ backend.tf (Optional but Production Style)

```hcl
terraform {
  backend "s3" {}
}
```


```shell
terraform init \
  -backend-config="bucket=YOUR-TF-STATE-BUCKET" \
  -backend-config="key=alias-workspace/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=terraform-locks"
```

---

# 7️⃣ scripts/import.sh

```bash
#!/bin/bash

# Usage:
# ./import.sh <bucket_name>

BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "Usage: ./import.sh <bucket_name>"
  exit 1
fi

echo "Importing existing S3 bucket..."

terraform import aws_s3_bucket.primary $BUCKET_NAME
```

---

# 🚀 STEP-BY-STEP EXECUTION

---

## Step 1: Initialize

```bash
terraform init
```

---

## Step 2: Create Workspaces

```bash
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod
```

Switch:

```bash
terraform workspace select dev
```

---

## Step 3: Plan & Apply

```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Step 4: Verify Workspace Behavior

Switch workspace:

```bash
terraform workspace select stage
terraform apply -var-file="terraform.tfvars"
```

👉 Creates **different buckets automatically**

---

## Step 5: IMPORT (IMPORTANT)

### 🔥 Scenario:

Bucket already exists (created manually)

```bash
aws s3 mb s3://jumptotech-dev-primary
```

Now import:

```bash
./scripts/import.sh jumptotech-dev-primary
```

---

## Step 6: Verify Import

```bash
terraform plan
```

Expected:

```plaintext
No changes. Infrastructure is up-to-date.
```

---

# 🧠 KEY CONCEPTS (Explain to Students)

---

## 🔹 1. Alias Provider

```hcl
provider = aws.secondary
```

➡️ Allows:

* Multi-region
* Multi-account

---

## 🔹 2. Workspace

```hcl
terraform.workspace
```

➡️ Automatically separates:

* dev
* stage
* prod

---

## 🔹 3. Import

```bash
terraform import RESOURCE_NAME RESOURCE_ID
```

➡️ Example:

```bash
terraform import aws_s3_bucket.primary my-bucket
```

---

## 🔹 4. Why Import is Critical

Without import:

* Terraform will try to **recreate resource**
* Can cause **data loss / conflicts**

---

## 🔹 5. No Hardcoding

Everything comes from:

* variables.tf
* tfvars
* workspace

---

# 🎯 REAL INTERVIEW QUESTIONS (FROM THIS LAB)

1. What is provider alias and when do you use it?
2. Difference between workspace and separate state files?
3. What happens if you don’t import existing resources?
4. Can you import into module?
5. How do you manage multi-region deployments?
6. What is terraform.workspace used for?


