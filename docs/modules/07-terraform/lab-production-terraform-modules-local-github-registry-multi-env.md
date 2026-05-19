---
title: "LAB: Production Terraform Modules (Local + GitHub + Registry + Multi-Env)"
description: "In real companies:    You have multiple environments   dev stage prod        ❌ BAD:    terraform..."
published: 2026-03-23
source: "https://dev.to/jumptotech/lab-production-terraform-modules-local-github-registry-multi-env-2iii"
tags: []
---

# LAB: Production Terraform Modules (Local + GitHub + Registry + Multi-Env)






In real companies:

* You have **multiple environments**

  * dev
  * stage
  * prod


❌ BAD:

```plaintext
terraform apply (same folder)
→ prod overwrites dev
```

✅ GOOD (Production):

```plaintext
Separate state per environment
Separate execution per environment
Shared reusable modules
```

---

# 🔷 PART 2 — Final Architecture

```plaintext
terraform-prod-lab/
│
├── modules/                # LOCAL modules
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   └── backend.tf
│   │
│   └── prod/
│       ├── main.tf
│       └── backend.tf
│
└── README.md
```

---

# 🔷 PART 3 — LOCAL MODULE (modules/ec2)

## modules/ec2/main.tf

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name
    Env  = var.env
  }
}
```

## modules/ec2/variables.tf

```hcl
variable "ami" {}
variable "instance_type" {}
variable "name" {}
variable "env" {}
```

## modules/ec2/outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

---

# 🔷 PART 4 — DEV ENV (LOCAL MODULE CALL)

## envs/dev/main.tf

```hcl
provider "aws" {
  region = "us-east-2"
}

module "ec2_dev" {
  source = "../../modules/ec2"

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  name          = "dev-server"
  env           = "dev"
}
```

---

## envs/dev/backend.tf

```hcl
terraform {
  backend "local" {
    path = "dev.tfstate"
  }
}
```

---

# 🔷 PART 5 — PROD ENV (GITHUB MODULE)

Now simulate **production module reuse from GitHub**

## envs/prod/main.tf

```hcl
provider "aws" {
  region = "us-east-2"
}

module "ec2_prod" {
  source = "git::https://github.com/your-username/terraform-ec2-module.git"

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  name          = "prod-server"
  env           = "prod"
}
```

---

## envs/prod/backend.tf

```hcl
terraform {
  backend "local" {
    path = "prod.tfstate"
  }
}
```

---

# 🔷 PART 6 — REGISTRY MODULE (ADD S3)

Add real-world registry usage

## envs/dev/main.tf (ADD THIS)

```hcl
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "jumptotech-dev-bucket-12345"
}
```

---

## envs/prod/main.tf (ADD THIS)

```hcl
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "jumptotech-prod-bucket-12345"
}
```

---

# 🔷 PART 7 — RUNNING (CRITICAL PART)

## ✅ Deploy DEV

```bash
cd envs/dev

terraform init
terraform plan
terraform apply
```

---

## ✅ Deploy PROD

```bash
cd ../prod

terraform init
terraform plan
terraform apply
```

---

# 🔥 IMPORTANT RESULT

| Action       | What Happens      |
| ------------ | ----------------- |
| Apply dev    | Only dev created  |
| Apply prod   | Only prod created |
| Destroy prod | Dev stays SAFE    |
| Destroy dev  | Prod stays SAFE   |

👉 Because:

```plaintext
Separate state files
Separate folders
Separate execution
```

---

# 🔷 PART 8 — WHY THIS IS PRODUCTION STANDARD

## Key Concepts

### 1. State Isolation

Each environment has:

```plaintext
dev.tfstate
prod.tfstate
```

So Terraform does NOT mix resources.

---

### 2. Module Reuse

| Type     | Example               |
| -------- | --------------------- |
| Local    | ../../modules/ec2     |
| GitHub   | git::https://...      |
| Registry | terraform-aws-modules |

---

### 3. No Cross-Environment Impact

Terraform ONLY manages what is in:

```plaintext
current state file
```

---

# 🔷 PART 9 — INTERVIEW QUESTIONS

### Q1: How do you prevent dev destroying prod?

Answer:

```plaintext
Separate state files per environment
Separate folders or workspaces
```

---

### Q2: Where do modules come from?

```plaintext
Local filesystem
Git repositories
Terraform Registry
```

---

### Q3: Why use GitHub modules?

```plaintext
Version control
Team sharing
Reusable infrastructure
```

---

### Q4: What is best practice?

```plaintext
Separate repo for modules
Separate repo for environments (infra-live)
```

---

# 🔷 PART 10 — REAL COMPANY STRUCTURE (VERY IMPORTANT)

```plaintext
infra-modules/        (GitHub repo)
   ├── ec2
   ├── vpc
   └── rds

infra-live/           (GitHub repo)
   ├── dev
   ├── stage
   └── prod
```

---

# 🔥 BONUS — WHAT STUDENTS MUST UNDERSTAND

If they remember ONLY ONE thing:

👉 Terraform manages STATE, not resources

---

# 🔷 PART 11 — ADVANCED (OPTIONAL)

Production improvement:

* Use **S3 backend instead of local**
* Add **DynamoDB locking**
* Add **versions for Git modules**

Example:

```hcl
source = "git::https://github.com/org/module.git?ref=v1.0.0"
```

---

# ✅ FINAL RESULT


* Real module usage (ALL 3 types)
* Production environment separation
* State isolation
* GitHub module usage
* Registry usage
* Why Terraform does NOT destroy everything


