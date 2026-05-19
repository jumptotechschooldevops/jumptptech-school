---
title: "PROJECT : Module Reuse + Outputs Consumption"
description: "(IAM User module reused + output consumed)   This project answers:   Root vs Child..."
published: 2025-12-19
source: "https://dev.to/jumptotech/project-module-reuse-outputs-consumption-1c4f"
tags: []
---

# PROJECT : Module Reuse + Outputs Consumption




### (IAM User module reused + output consumed)

This project answers:

* Root vs Child module
* Inputs & Outputs
* Module reuse
* How root consumes child output
* State behavior

---

## 1️⃣ Project Structure (CERTIFICATION STYLE)

```
project-1-iam-reuse/
├── main.tf
└── modules/
    └── iam-user/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 2️⃣ Child Module — IAM User

### `modules/iam-user/variables.tf`

```hcl
variable "user_name" {
  type = string
}
```

### `modules/iam-user/main.tf`

```hcl
resource "aws_iam_user" "this" {
  name = var.user_name
}
```

### `modules/iam-user/outputs.tf`

```hcl
output "user_arn" {
  value = aws_iam_user.this.arn
}
```

---

## 3️⃣ Root Module — Reusing SAME Module Twice

### `main.tf`

```hcl
provider "aws" {
  region = "us-west-1"
}

module "dev_user" {
  source    = "./modules/iam-user"
  user_name = "dev-user"
}

module "prod_user" {
  source    = "./modules/iam-user"
  user_name = "prod-user"
}

output "dev_user_arn" {
  value = module.dev_user.user_arn
}

output "prod_user_arn" {
  value = module.prod_user.user_arn
}
```

---

## 4️⃣ Commands (EXAM EXPECTED)

```bash
terraform init
terraform plan
terraform apply
```

---

## 5️⃣ What This Project Demonstrates (EXAM MAPPING)

| Exam Topic         | Demonstrated               |
| ------------------ | -------------------------- |
| Root module        | `main.tf`                  |
| Child module       | `modules/iam-user`         |
| Module reuse       | Same module twice          |
| Input variables    | `user_name`                |
| Outputs            | `user_arn`                 |
| Output consumption | `module.dev_user.user_arn` |
| State behavior     | Both users in same state   |

---

## 6️⃣ Answers to Exam Questions (FROM THIS PROJECT)

**Q: Can same module be reused multiple times?**
✔️ YES — demonstrated by `dev_user` and `prod_user`

**Q: Where are module outputs stored?**
✔️ Terraform state

**Q: Does deleting root module delete child resources?**
✔️ YES — all resources tracked in state

---

# PROJECT 2 — **Module + for_each + Environment Pattern**

### (S3 module used for dev/prod with `for_each`)

This project answers:

* Module + for_each
* Environment separation
* Count vs for_each
* Certification-favorite pattern

---

## 1️⃣ Project Structure

```
project-2-s3-env/
├── main.tf
└── modules/
    └── s3-bucket/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 2️⃣ Child Module — S3 Bucket

### `modules/s3-bucket/variables.tf`

```hcl
variable "bucket_name" {
  type = string
}
```

### `modules/s3-bucket/main.tf`

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}
```

### `modules/s3-bucket/outputs.tf`

```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
```

---

## 3️⃣ Root Module — for_each Over Environments

### `main.tf`

```hcl
provider "aws" {
  region = "us-west-1"
}

locals {
  environments = {
    dev  = "dev-app-bucket-aj"
    prod = "prod-app-bucket-aj"
  }
}

module "s3" {
  source = "./modules/s3-bucket"
  for_each = local.environments

  bucket_name = each.value
}

output "bucket_names" {
  value = {
    for env, mod in module.s3 :
    env => mod.bucket_name
  }
}
```

---

## 4️⃣ Commands

```bash
terraform init
terraform plan
terraform apply
```

---

## 5️⃣ What This Project Demonstrates (EXAM MAPPING)

| Exam Topic                      | Demonstrated |
| ------------------------------- | ------------ |
| Module + for_each               | YES          |
| Environment pattern             | dev / prod   |
| locals usage                    | YES          |
| Output map                      | YES          |
| Deterministic resource creation | YES          |

---

## 6️⃣ Answers to Exam Questions (FROM THIS PROJECT)

**Q: When should for_each be used instead of count?**
✔️ When using named keys (dev/prod)

**Q: Can modules be used with for_each?**
✔️ YES — fully supported

**Q: What does `module.s3["dev"]` represent?**
✔️ Dev environment module instance

---

# FINAL CERTIFICATION SUMMARY (MEMORIZE THIS)

> Terraform modules encapsulate reusable infrastructure logic.
> Root modules compose child modules, pass inputs, and consume outputs.
> Modules can be reused, versioned, and instantiated using count or for_each.
> All module resources are tracked in a single Terraform state.


