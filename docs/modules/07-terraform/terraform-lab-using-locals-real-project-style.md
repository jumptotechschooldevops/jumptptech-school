---
title: "Terraform Lab: Using `locals` (Real Project Style)"
description: "📁 Project Structure      terraform-locals-lab/ ├── main.tf ├── variables.tf ├──..."
published: 2026-04-02
source: "https://dev.to/jumptotech/terraform-lab-using-locals-real-project-style-2lhl"
tags: []
---

# Terraform Lab: Using `locals` (Real Project Style)





# 📁 Project Structure

```plaintext
terraform-locals-lab/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
```

---

# 1️⃣ providers.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

---

# 2️⃣ variables.tf

👉 Only inputs (NO hardcoding)

```hcl
variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "bucket_suffix" {
  type = string
}
```

---

# 3️⃣ locals (MAIN PART)

👉 This is where magic happens

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  bucket_name = "${local.name_prefix}-${var.bucket_suffix}"
}
```

---

# 4️⃣ main.tf

```hcl
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = local.common_tags
}
```

---

# 5️⃣ terraform.tfvars

```hcl
aws_region    = "us-east-2"
project_name  = "jumptotech"
environment   = "dev"
bucket_suffix = "lab"
```

---

# 6️⃣ outputs.tf

```hcl
output "bucket_name" {
  value = local.bucket_name
}
```

---

# 🚀 How to Run

```bash
terraform init
terraform plan
terraform apply
```

---

# 🔍 What You Will See

Bucket created like:

```plaintext
jumptotech-dev-lab
```

👉 That name came from:

* variable + locals (NOT hardcoded)

---

# 🔁 Test Real DevOps Behavior

### Change environment:

```hcl
environment = "prod"
```

👉 Run again:

```bash
terraform apply
```

Now bucket becomes:

```plaintext
jumptotech-prod-lab
```

---

# 🧠 What You Learned

✔ No hardcoding
✔ Reusable naming
✔ Centralized logic
✔ Clean production code

---

# 🔥 Bonus (VERY IMPORTANT)

Add logic (real interview level):

```hcl
locals {
  is_prod = var.environment == "prod"
}
```

Use it:

```hcl
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = local.is_prod ? "Enabled" : "Suspended"
  }
}
```

👉 In prod → versioning ON
👉 In dev → OFF

---

# 🎯 Interview Ready Answer

👉 *"In this lab, locals are used to dynamically generate resource names, centralize tagging strategy, and control behavior like enabling versioning based on environment."*


