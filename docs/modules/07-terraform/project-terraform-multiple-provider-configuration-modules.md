---
title: "project: Terraform Multiple Provider Configuration (Modules)"
description: "Goal    Use multiple AWS regions (us-east-1 and us-west-1) Use provider aliases  Use..."
published: 2025-12-22
source: "https://dev.to/jumptotech/project-terraform-multiple-provider-configuration-modules-42mh"
tags: []
---

# project: Terraform Multiple Provider Configuration (Modules)




## Goal 

* Use **multiple AWS regions** (`us-east-1` and `us-west-1`)
* Use **provider aliases**
* Use **modules**
* Create **EC2 in each region**
* Understand **who owns providers** (root vs module)

---

## 1️⃣ Project Folder Structure (VERY IMPORTANT)


👉 *“First create folders exactly like this.”*

```bash
terraform-multi-provider/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
│
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

Students should **not guess paths**.
This structure removes confusion.

---

## 2️⃣ Root Level – providers.tf (Multiple Providers)

📍 **terraform-multi-provider/providers.tf**

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
```

### Explain to students

* Default provider → `us-east-1`
* Aliased provider → `aws.west`
* Terraform **does not auto-switch regions**
* Aliases are mandatory for multi-region

---

## 3️⃣ Root Level – main.tf (Calling Modules)

📍 **terraform-multi-provider/main.tf**

```hcl
module "ec2_east" {
  source        = "./modules/ec2"
  instance_name = "east-instance"
}

module "ec2_west" {
  source        = "./modules/ec2"

  providers = {
    aws = aws.west
  }

  instance_name = "west-instance"
}
```

### Explain clearly

| Module     | Region    | Why                   |
| ---------- | --------- | --------------------- |
| `ec2_east` | us-east-1 | Uses default provider |
| `ec2_west` | us-west-1 | Uses aliased provider |

👉 **providers block tells Terraform which provider to inject into the module**

---

## 4️⃣ Root Level – variables.tf

📍 **terraform-multi-provider/variables.tf**

```hcl
# Empty for now (kept for scalability)
```

Explain:

* Empty now
* Keeps structure future-proof
* Matches real production repos

---

## 5️⃣ Root Level – outputs.tf

📍 **terraform-multi-provider/outputs.tf**

```hcl
output "east_instance_id" {
  value = module.ec2_east.instance_id
}

output "west_instance_id" {
  value = module.ec2_west.instance_id
}
```

Explain:

* Outputs prove **both regions worked**
* Used in CI/CD and remote state later

---

## 6️⃣ Module – variables.tf

📍 **terraform-multi-provider/modules/ec2/variables.tf**

```hcl
variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}
```

Explain:

* Modules **never hardcode names**
* Everything is passed from root

---

## 7️⃣ Module – main.tf (NO PROVIDER BLOCK HERE)

📍 **terraform-multi-provider/modules/ec2/main.tf**

```hcl
resource "aws_instance" "this" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Amazon Linux 2 (example)
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
```

🚨 **Important rule (exam + interview)**
❌ Do **NOT** define provider inside module
✅ Provider is injected from root

---

## 8️⃣ Module – outputs.tf

📍 **terraform-multi-provider/modules/ec2/outputs.tf**

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

---

## 9️⃣ How Students Run This Project

```bash
terraform init
terraform plan
terraform apply
```

Expected result:

* 1 EC2 in **us-east-1**
* 1 EC2 in **us-west-1**

---

## 10️⃣ Interview Explanation (MEMORIZE THIS)

**Question:**
Why did you use multiple providers with modules?

**Answer:**

> In production, teams deploy infrastructure across multiple regions for availability and compliance. Terraform requires provider aliases to manage multiple regions. I defined providers in the root module and injected them into reusable modules to keep the module region-agnostic and production-ready.

---

## 11️⃣ Certification Key Points (Terraform Associate)

✔ Provider aliases
✔ Module provider injection
✔ Region-agnostic modules
✔ Clean folder structure
✔ Reusability

---

## THIS ONE PROJECT

* Real production layout
* How Terraform resolves providers
* Why modules should stay generic
* How multi-region infra is built
* How to explain it in interviews











# PROJECT: Publishable Terraform Module – AWS EC2

## Project Goal 

> Build a **reusable, production-ready EC2 module** and publish it to the **Terraform Registry**, following **all official requirements**.

What  will learn:

* Module structure
* Registry naming rules
* Variables & outputs
* Versioning with Git tags
* Registry publishing flow
* Interview-ready explanation

---

## 1️⃣ GitHub Repository Name (MANDATORY)

```text
terraform-aws-ec2
```

🚨 If the name is wrong → Terraform Registry will NOT detect it.

---

## 2️⃣ Project Folder Structure (FIRST THING STUDENTS CREATE)

```bash
terraform-aws-ec2/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

👉 No subfolders.
👉 Everything at root (required by Registry).

---

## 3️⃣ versions.tf (Provider + Terraform Version)

📍 `versions.tf`

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

Why this matters:

* Prevents breaking changes
* Required in real production modules
* Exam question topic

---

## 4️⃣ variables.tf (NO HARDCODED VALUES)

📍 `variables.tf`

```hcl
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
```

Teaching point:

* Modules must be flexible
* Everything configurable
* Defaults allowed, not required

---

## 5️⃣ main.tf (Core Module Logic)

📍 `main.tf`

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}
```

🚨 IMPORTANT:

* ❌ No provider block here
* ❌ No region here
* ✅ Region comes from root module

---

## 6️⃣ outputs.tf (Expose Important Values)

📍 `outputs.tf`

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.this.public_ip
}
```

Why outputs matter:

* Used by other modules
* Used by CI/CD
* Required for professional modules

---

## 7️⃣ README.md (REGISTRY READS THIS)

📍 `README.md`

````md
# terraform-aws-ec2

Reusable Terraform module for creating an AWS EC2 instance.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source  = "username/ec2/aws"
  version = "1.0.0"

  instance_name = "demo-ec2"
  instance_type = "t2.micro"
  ami_id        = "ami-0fc5d935ebf8bc3bc"

  tags = {
    Environment = "dev"
  }
}
````

## Inputs

| Name          | Description | Type        | Default  | Required |
| ------------- | ----------- | ----------- | -------- | -------- |
| instance_name | EC2 name    | string      | n/a      | yes      |
| instance_type | EC2 type    | string      | t2.micro | no       |
| ami_id        | AMI ID      | string      | n/a      | yes      |
| tags          | Extra tags  | map(string) | {}       | no       |

## Outputs

| Name        | Description |
| ----------- | ----------- |
| instance_id | EC2 ID      |
| public_ip   | Public IP   |

````

🚨 No README = module rejected

---

## 8️⃣ How Students Test Module (LOCAL)

Create a **separate test folder** (not published):

```bash
ec2-test/
│
├── main.tf
````

```hcl
provider "aws" {
  region = "us-east-1"
}

module "test_ec2" {
  source = "../terraform-aws-ec2"

  instance_name = "student-test"
  ami_id        = "ami-0fc5d935ebf8bc3bc"
}
```

Run:

```bash
terraform init
terraform apply
```

---

## 9️⃣ Git Versioning (CRITICAL FOR REGISTRY)

```bash
git init
git add .
git commit -m "Initial EC2 module"

git tag v1.0.0
git push origin main
git push origin v1.0.0
```

Terraform Registry uses:

```hcl
version = "1.0.0"
```

---

## 🔟 Publishing to Terraform Registry

1. Go to Terraform Registry
2. Sign in with GitHub
3. Click **Publish Module**
4. Select `terraform-aws-ec2`
5. Done

---

## 1️⃣1️⃣ Interview Explanation (MEMORIZE)

**Question:**
How do you publish a Terraform module?

**Answer:**

> I create a public GitHub repository following the `terraform-<provider>-<name>` naming convention. The module contains `main.tf`, `variables.tf`, `outputs.tf`, a `versions.tf`, and a well-documented README. Versions are managed using Git tags, and Terraform Registry automatically picks up the module.

---

## 1️⃣2️⃣ Why This Is a STRONG Project

✔ Registry compliant
✔ Real production pattern
✔ Certification aligned
✔ Interview-ready
✔ Student-friendly
✔ Reusable in real jobs


