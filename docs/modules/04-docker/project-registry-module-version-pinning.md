---
title: "PROJECT : Registry Module + Version Pinning"
description: "Goal   Use a Terraform Registry module, pin its version, and understand why.             ..."
published: 2025-12-19
source: "https://dev.to/jumptotech/project-registry-module-version-pinning-5h7p"
tags: []
---

# PROJECT : Registry Module + Version Pinning







## Goal

Use a **Terraform Registry module**, pin its version, and understand why.

---

## What Certification Tests Here

* Registry modules
* `source` syntax
* `version` constraint
* Why pinning matters

---

## Code (`main.tf`)

```hcl
provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "cert-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a"]
  public_subnets  = ["10.0.1.0/24"]
}
```

---

## Commands

```bash
terraform init
terraform plan
terraform apply
```

---

## Exam Answers

**Q: Why use version in module block?**
✔️ Prevents breaking changes

**Q: Where is module code stored locally?**
✔️ `.terraform/modules/`

**Q: What happens if version is removed?**
✔️ Latest version may break infra

---

## Interview Line

> We pin registry module versions to avoid unexpected behavior caused by upstream changes.

---

# PROJECT 4 — **Remote State Consumption Between Teams**

✅ *Medium–large company standard*

---

## Goal

One team creates S3, another team reads it using **remote state**.

---

## Team A — Infra Team (creates S3)

### `infra/main.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "tf-state-aj"
    key    = "infra/s3.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "shared" {
  bucket = "shared-logs-aj"
}

output "bucket_name" {
  value = aws_s3_bucket.shared.bucket
}
```

---

## Team B — App Team (reads S3)

### `app/main.tf`

```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "tf-state-aj"
    key    = "infra/s3.tfstate"
    region = "us-west-1"
  }
}

output "bucket_from_infra" {
  value = data.terraform_remote_state.infra.outputs.bucket_name
}
```

---

## Exam Answers

**Q: Does remote state create resources?**
❌ No, it only reads

**Q: Why remote state vs data source?**
✔️ When resource is Terraform-managed elsewhere

---

## Interview Line

> We use terraform_remote_state to safely share outputs across team-owned Terraform projects.

---

# PROJECT 5 — **Module with Multiple Providers (Alias)**

✅ *Exam + real production*

---

## Goal

Create resources in **two AWS regions** using one module.

---

## Root Module (`main.tf`)

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

module "west_bucket" {
  source    = "./modules/s3"
  providers = { aws = aws.west }
  name      = "west-bucket-aj"
}

module "east_bucket" {
  source    = "./modules/s3"
  providers = { aws = aws.east }
  name      = "east-bucket-aj"
}
```

---

## Module (`modules/s3/main.tf`)

```hcl
variable "name" {}

resource "aws_s3_bucket" "this" {
  bucket = var.name
}
```

---

## Exam Answers

**Q: When do we use provider alias?**
✔️ Multi-region or multi-account

**Q: Can child modules inherit providers?**
✔️ Yes, unless overridden

---

## Interview Line

> Provider aliases allow us to deploy identical infrastructure across regions or accounts using the same module.

---

# PROJECT 6 — **Module Versioning + Upgrade Behavior**

✅ *Frequently misunderstood*

---

## Goal

Understand **how module upgrades work**.

---

## Code

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}
```

---

## Upgrade Scenario

```bash
terraform init -upgrade
```

---

## Exam Answers

**Q: Does Terraform auto-upgrade modules?**
❌ No

**Q: What command upgrades modules?**
✔️ `terraform init -upgrade`

**Q: Where are versions locked?**
✔️ `.terraform.lock.hcl`

---

## Interview Line

> Terraform locks module versions to ensure reproducible builds and requires explicit upgrade actions.

---

# FINAL CERTIFICATION CHEAT SHEET (MEMORIZE)

| Topic                 | Status |
| --------------------- | ------ |
| Root vs Child modules | ✅      |
| Local modules         | ✅      |
| Registry modules      | ✅      |
| Module inputs/outputs | ✅      |
| Module reuse          | ✅      |
| for_each + modules    | ✅      |
| Remote state          | ✅      |
| Provider alias        | ✅      |
| Version pinning       | ✅      |
| Upgrade behavior      | ✅      |

---

## What You Are Ready For Now

You can now:

* Answer **any Terraform module question**
* Pass **Terraform Associate module objectives**
* Explain **real production usage**
* Teach this to students


