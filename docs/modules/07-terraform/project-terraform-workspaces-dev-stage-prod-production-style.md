---
title: "PROJECT: Terraform Workspaces – Dev / Stage / Prod (Production Style)"
description: "Project Goal    Use ONE Terraform codebase  Create multiple environments using..."
published: 2025-12-22
source: "https://dev.to/jumptotech/project-terraform-workspaces-dev-stage-prod-production-style-1pni"
tags: []
---

# PROJECT: Terraform Workspaces – Dev / Stage / Prod (Production Style)





## Project Goal 

* Use **ONE Terraform codebase**
* Create **multiple environments** using **workspaces**
* Keep **separate state files**
* Avoid code duplication
* Follow **Terraform Associate exam** expectations

---

## What this project simulates (real world)

A company wants:

* `dev`, `stage`, `prod`
* Same EC2 setup
* Same AWS account
* Same region
* Different **naming**, **tags**, **size**

✔ This is exactly what workspaces are designed for.

---

## 1️⃣ Project Structure 

```bash
terraform-workspaces-project/
│
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── providers.tf
```

👉 One folder
👉 One codebase
👉 No duplication

---

## 2️⃣ providers.tf

```hcl
provider "aws" {
  region = "us-east-1"
}
```

📌 Exam note:

* Workspaces **do NOT change providers**
* Same account, same region

---

## 3️⃣ variables.tf

```hcl
variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type_map" {
  description = "Instance type per environment"
  type        = map(string)
  default = {
    dev   = "t2.micro"
    stage = "t2.small"
    prod  = "t3.medium"
  }
}
```

📌 Production concept:

* Env-based configuration
* No hardcoding

---

## 4️⃣ locals.tf (KEY FILE – EXAM FAVORITE)

```hcl
locals {
  env = terraform.workspace

  instance_type = lookup(
    var.instance_type_map,
    local.env,
    "t2.micro"
  )
}
```

📌 What this teaches:

* `terraform.workspace`
* `lookup()` function
* Safe defaults
* Dynamic behavior per env

---

## 5️⃣ main.tf

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = local.instance_type

  tags = {
    Name        = "app-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

📌 Result:

* Same code
* Different EC2s
* Different names
* Different sizes

---

## 6️⃣ outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.app.id
}

output "environment" {
  value = terraform.workspace
}
```

---

## 7️⃣ How  RUN the Project (STEP BY STEP)

### Step 1: Init

```bash
terraform init
```

---

### Step 2: Create workspaces

```bash
terraform workspace create dev
terraform workspace create stage
terraform workspace create prod
```

---

### Step 3: Deploy DEV

```bash
terraform workspace select dev
terraform apply
```

✔ Creates:

* EC2 name: `app-dev`
* Type: `t2.micro`

---

### Step 4: Deploy STAGE

```bash
terraform workspace select stage
terraform apply
```

✔ Creates:

* EC2 name: `app-stage`
* Type: `t2.small`

---

### Step 5: Deploy PROD

```bash
terraform workspace select prod
terraform apply
```

✔ Creates:

* EC2 name: `app-prod`
* Type: `t3.medium`

---

## 8️⃣ What Terraform Does Internally (IMPORTANT)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AJZV49LQUvk73CYqwcsqMGA.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AMuGsWwueMBCqxtVK.png?utm_source=chatgpt.com)

![Image](https://k21academy.com/wp-content/uploads/2023/07/TF-WorkSpace-1024x487.webp?utm_source=chatgpt.com)

```text
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── stage/
│   └── terraform.tfstate
├── prod/
│   └── terraform.tfstate
```

✔ Same code
✔ Separate states
✔ Safe isolation

---

## 9️⃣ Why this is PRODUCTION-VALID

Used when:

* Same AWS account
* Same region
* Same infra shape
* Different env behavior

NOT used when:

* Different accounts
* Different providers
* Strong isolation required

---

## 🔟 Terraform Certificate Mapping (EXPLICIT)

This project covers:

✔ Workspaces
✔ State isolation
✔ `terraform.workspace`
✔ `locals`
✔ `lookup()`
✔ Variable maps
✔ Safe defaults

Exactly what appears in **Terraform Associate exam**.

---

## 1️⃣1️⃣ Interview Answer (MEMORIZE)

**Question:**
How do you manage dev, stage, and prod using Terraform?

**Answer:**

> I use Terraform workspaces when the infrastructure is the same but environments differ. Each workspace maintains its own state file while sharing the same code. I use `terraform.workspace` with locals and maps to adjust behavior like instance size and naming per environment.

---

## 1️⃣2️⃣ Common Interview Trap (IMPORTANT)

❌ “I use workspaces for different AWS accounts”
✅ Correct answer:

> For different accounts or regions, I prefer separate directories and remote state backends.



## Why THIS project is strong

* Real production logic
* Simple enough for students
* Direct exam relevance
* Interview-ready explanation
* No bad practices


