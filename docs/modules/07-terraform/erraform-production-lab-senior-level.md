---
title: "TERRAFORM PRODUCTION LAB (SENIOR LEVEL)"
description: "🎯 Objective   Build production-grade Terraform infrastructure with:   Remote state (S3 +..."
published: 2026-03-25
source: "https://dev.to/jumptotech/erraform-production-lab-senior-level-5eg9"
tags: []
---

# TERRAFORM PRODUCTION LAB (SENIOR LEVEL)




## 🎯 Objective

Build **production-grade Terraform infrastructure** with:

* Remote state (S3 + DynamoDB)
* Secure S3 bucket (encryption, versioning, blocking public access)
* DynamoDB locking
* ECR (container registry)
* Secrets management (SSM + Secrets Manager)
* Proper security practices

---

# 🔷 PART 1 — WHY THIS MATTERS (INTERVIEW ANSWER)

### ❓ Why S3 + DynamoDB?

**Answer (short, interview-ready):**

* S3 → stores Terraform state centrally
* DynamoDB → prevents concurrent runs (locking)
* Prevents corruption and race conditions
* Enables team collaboration

---

### ❓ Why ECR?

* Store Docker images securely
* Integrate with ECS/EKS
* IAM-controlled access
* Avoid public registries (security risk)

---

### ❓ Why Secrets Management?

❌ BAD:

```hcl
password = "admin123"
```

✅ GOOD:

* AWS SSM Parameter Store
* AWS Secrets Manager
* Avoid storing secrets in:

  * Terraform code
  * GitHub
  * state file (important!)

---

# 🔷 PART 2 — PROJECT STRUCTURE (PRODUCTION)

```plaintext
terraform-prod/
│
├── backend/
│   └── main.tf          # S3 + DynamoDB (bootstrap)
│
├── modules/
│   ├── s3/
│   ├── dynamodb/
│   ├── ecr/
│   └── secrets/
│
├── envs/
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       ├── variables.tf
│
└── README.md
```

---

# 🔷 PART 3 — BOOTSTRAP (CREATE BACKEND FIRST)

## backend/main.tf

```hcl
provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "jumptotech-tf-state-prod"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

---

## 🔥 RUN FIRST (BOOTSTRAP)

```bash
cd backend
terraform init
terraform apply -auto-approve
```

---

# 🔷 PART 4 — REMOTE BACKEND CONFIG

## envs/prod/backend.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "jumptotech-tf-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
```

---

# 🔷 PART 5 — ECR MODULE (PRODUCTION)

## modules/ecr/main.tf

```hcl
resource "aws_ecr_repository" "repo" {
  name = var.name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}
```

## modules/ecr/variables.tf

```hcl
variable "name" {}
```

---

# 🔷 PART 6 — SECRETS (CRITICAL PART)

## OPTION 1 — SSM Parameter Store

```hcl
resource "aws_ssm_parameter" "db_password" {
  name  = "/prod/db/password"
  type  = "SecureString"
  value = var.db_password
}
```

⚠️ PROBLEM:

* Stored in Terraform state → still risky

---

## ✅ BEST PRACTICE (SENIOR LEVEL)

### OPTION 2 — Secrets Manager (recommended)

```hcl
resource "aws_secretsmanager_secret" "db" {
  name = "prod-db-secret"
}

resource "aws_secretsmanager_secret_version" "db_value" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
  })
}
```

---

# 🔴 CRITICAL KNOWLEDGE (INTERVIEW)

### ❗ Terraform STILL stores secrets in state!

👉 Solution:

* Use:

  * External secret injection (CI/CD)
  * Vault
  * AWS IAM roles instead of passwords

---

# 🔷 PART 7 — USING ECR + SECRETS IN PROD

## envs/prod/main.tf

```hcl
provider "aws" {
  region = "us-east-2"
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "prod-backend"
}

module "secrets" {
  source      = "../../modules/secrets"
  db_password = var.db_password
}
```

---

# 🔷 PART 8 — VARIABLES

## envs/prod/variables.tf

```hcl
variable "db_password" {
  sensitive = true
}
```

---

## RUN

```bash
cd envs/prod

terraform init
terraform plan
terraform apply
```

---

# 🔷 PART 9 — HOW TO PASS SECRETS (PRODUCTION)

### ❌ NEVER DO THIS

```hcl
db_password = "mypassword"
```

---

### ✅ USE ENV VARIABLES

```bash
export TF_VAR_db_password="supersecure123"
terraform apply
```

---

### ✅ EVEN BETTER (CI/CD)

* GitLab / GitHub Actions secrets
* AWS IAM role (OIDC)
* No hardcoded secrets

---

# 🔷 PART 10 — SECURITY BEST PRACTICES (MUST KNOW)

## ✅ S3

* Versioning ENABLED
* Encryption ENABLED
* Public access BLOCKED
* Logging enabled (optional)

---

## ✅ DynamoDB

* Locking prevents corruption

---

## ✅ Terraform

* Use remote state
* Never commit `.tfstate`
* Use `.gitignore`

---

## ✅ Secrets

* Never in code
* Never in GitHub
* Prefer IAM roles over passwords

---

# 🔷 PART 11 — REAL INTERVIEW QUESTIONS

### 1. What is Terraform state?

→ Tracks real infrastructure vs code

---

### 2. What is state locking?

→ Prevents concurrent updates (DynamoDB)

---

### 3. What happens if two engineers run apply?

→ Without locking → corruption
→ With DynamoDB → one waits

---

### 4. Where is state stored in production?

→ S3 (remote backend)

---

### 5. Can Terraform manage secrets securely?

👉 BEST ANSWER:

* Terraform can create secrets
* BUT not ideal to store them
* Use external secret systems (Vault / AWS Secrets Manager / CI/CD)

---

### 6. Why ECR instead of Docker Hub?

* Private
* IAM integrated
* Secure
* No rate limits

---

### 7. What is drift?

→ Infrastructure changed outside Terraform

---

# 🔷 PART 12 — ADVANCED (SENIOR LEVEL)

## Must Know:

* Remote backend
* State locking
* Modules (reusable)
* Sensitive variables
* IAM roles (instead of passwords)
* CI/CD integration
* OIDC (GitLab → AWS)
* Drift detection
* Terraform plan in PR

---

# 🔷 FINAL REAL-WORLD FLOW

```plaintext
Developer → Git push
        ↓
CI/CD Pipeline
        ↓
terraform plan (MR)
        ↓
Approval
        ↓
terraform apply (protected branch)
        ↓
State stored in S3
        ↓
Locking via DynamoDB
```

---

# 🔥 WHAT MAKES THIS “6-YEAR ENGINEER LEVEL”

You are not just writing Terraform.

You understand:

* Security
* State management
* Team workflows
* CI/CD integration
* Secrets handling
* Production risks


