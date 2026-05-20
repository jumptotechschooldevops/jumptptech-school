---
title: "LAB: Terraform Workflow + Import (Production Style)"
description: "Create an AWS resource manually (outside Terraform)  Import it into Terraform state Manage it fully..."
published: 2026-03-31
source: "https://dev.to/jumptotech/lab-terraform-workflow-import-production-style-587i"
tags: []
---

# LAB: Terraform Workflow + Import (Production Style)




1. Create an AWS resource **manually (outside Terraform)**
2. Import it into Terraform state
3. Manage it fully using Terraform

---

# 📁 Project Structure (IMPORTANT)

```plaintext
terraform-import-lab/
│
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
│
└── README.md
```

---

# 🧠 Concept 

### 🔹 What is Terraform Import?

> Terraform import is used when:

* Resource already exists in AWS
* But Terraform DOES NOT manage it yet

👉 We "attach" Terraform to existing infrastructure

---

# 🚀 STEP 1 — Create Resource Manually (AWS Console)

Students MUST create manually:

### Create S3 Bucket:

* Go to AWS Console
* Create S3 bucket
* Give unique name (example):

```plaintext
my-import-lab-<yourname>-123
```

⚠️ Save the bucket name — you will use it later

---

# 📄 provider.tf

```terraform
provider "aws" {
  region = var.aws_region
}
```

---

# 📄 variables.tf

```terraform
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "bucket_name" {
  description = "Existing S3 bucket name"
  type        = string
}
```

---

# 📄 terraform.tfvars

👉 fill this manually

```hcl
aws_region  = "us-east-2"
bucket_name = "REPLACE_WITH_YOUR_BUCKET_NAME"
```

---

# 📄 main.tf

⚠️ IMPORTANT: This must match existing resource

```terraform
resource "aws_s3_bucket" "existing" {
  bucket = var.bucket_name

  tags = {
    ManagedBy = "Terraform"
    Project   = "ImportLab"
  }
}
```

---

# 📄 outputs.tf

```terraform
output "bucket_name" {
  value = aws_s3_bucket.existing.bucket
}
```

---

# 📄 README.md (for students)

```markdown
Terraform Import Lab

Steps:

1. terraform init

2. terraform plan
   (Expected: Terraform wants to CREATE bucket — BUT DON'T APPLY)

3. Import existing resource:
   terraform import aws_s3_bucket.existing <bucket_name>

4. Run:
   terraform plan

   (Expected: NO changes)

5. Modify tags in main.tf

6. Run:
   terraform apply
```

---

# ⚙️ STEP 2 — Initialize Terraform

```shell
terraform init
```

---

# ⚙️ STEP 3 — Plan (IMPORTANT MOMENT)

```shell
terraform plan
```

👉 You will see:

```diff
+ create aws_s3_bucket
```

⚠️ THIS IS WRONG (resource already exists)

---

# 🔥 STEP 4 — Import Resource

```terraform
terraform import aws_s3_bucket.existing <your-bucket-name>
```

Example:

```shell
terraform import aws_s3_bucket.existing my-import-lab-aisal-123
```

---

# ⚙️ STEP 5 — Plan Again

```shell
terraform plan
```

✅ Expected:

```plaintext
No changes. Infrastructure is up-to-date.
```

---

# 🎯 STEP 6 — Modify Resource (Real DevOps Scenario)

Update `main.tf`:

```hcl
tags = {
  ManagedBy = "Terraform"
  Project   = "ImportLab"
  Owner     = "Student"
}
```

---

# ⚙️ STEP 7 — Apply Changes

```shell
terraform apply
```

✅ Now Terraform **manages the resource**

---



### 1. Terraform Workflow

* `init` → setup
* `plan` → preview
* `apply` → execute

---

### 2. Import Concept

Before import:

* Terraform wants to CREATE resource ❌

After import:

* Terraform recognizes existing resource ✅

---

### 3. State File Role

👉 Import updates **terraform.tfstate**

---

### 4. Real DevOps Scenario

Used when:

* Company already has infrastructure
* You start using Terraform later

---

# 🚨 Common Mistakes (Teach Them)

### ❌ Wrong resource name

```terraform
aws_s3_bucket.wrong_name
```

### ❌ Wrong bucket name

### ❌ Skipping import and running apply

👉 This will FAIL

---



👉 Import IAM user

```terraform
resource "aws_iam_user" "example" {
  name = var.user_name
}
```

Command:

```terraform
terraform import aws_iam_user.example <username>
```

---

# 🧩 Interview Questions (from this lab)

1. What is terraform import?
2. Does import create resource?
3. What happens if configuration doesn’t match?
4. Can Terraform import automatically generate code?
5. Where is imported data stored?

---

# 💡 Real Production Insight

In real companies:

* 80% infra exists BEFORE Terraform
* Import is used during **Terraform adoption phase**


