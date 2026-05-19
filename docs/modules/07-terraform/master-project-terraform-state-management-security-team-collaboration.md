---
title: "MASTER PROJECT: Terraform State Management, Security & Team Collaboration"
description: "In production, companies usually have multiple Git repositories. Platform (or Cloud) engineers create..."
published: 2025-12-22
source: "https://dev.to/jumptotech/master-project-terraform-state-management-security-team-collaboration-3oba"
tags: []
---

# MASTER PROJECT: Terraform State Management, Security & Team Collaboration




In production, companies usually have multiple Git repositories.
Platform (or Cloud) engineers create shared infrastructure repos, and DevOps or application teams have their own repos that consume those shared resources.

This is **industry standard**.

---

## 🧠 Real Production Model (MOST COMMON)

### Typical setup:

```text
GitHub Organization
│
├── terraform-platform-networking   (Platform team)
│
├── terraform-platform-security     (Platform team)
│
├── terraform-app-orders            (App / DevOps team)
│
├── terraform-app-payments          (App / DevOps team)
│
└── terraform-app-analytics         (App / DevOps team)
```

---

## 👥 Who owns what?

### 🟦 Platform / Cloud Engineering Team

Owns:

* VPC
* Subnets
* Routing
* Shared IAM
* Shared EKS clusters
* Shared logging / monitoring
* Terraform backends (S3 + DynamoDB)

Examples:

* `terraform-platform-networking`
* `terraform-platform-security`

---

### 🟩 DevOps / Application Teams

Own:

* EC2 / ECS / EKS workloads
* RDS / DynamoDB
* App-specific IAM roles
* Autoscaling / ALB

Examples:

* `terraform-app-orders`
* `terraform-app-payments`

They **do NOT create VPCs** — they **consume them**.

---

## 🔁 How teams collaborate (KEY CONCEPT)

They collaborate via **Remote State Data Source**:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-company-prod"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
```

✔ No hardcoding
✔ Loose coupling
✔ Safe separation
✔ Production-grade

---

## 🔐 Why state is centralized

| Component        | Owner             |
| ---------------- | ----------------- |
| S3 state bucket  | Platform team     |
| DynamoDB locking | Platform team     |
| Backend config   | All teams         |
| State files      | Isolated per repo |

---

## 🚫 Why NOT one repo in production?

| Reason         | Explanation                            |
| -------------- | -------------------------------------- |
| Access control | Not all teams should touch networking  |
| Blast radius   | Mistake in one repo ≠ break everything |
| Team autonomy  | Teams deploy independently             |
| CI/CD          | Separate pipelines                     |
| Scaling        | Hundreds of services                   |

---

### Single repo is used for:

* Learning Terraform concepts
* Seeing full picture
* Exam preparation
* Student labs

### Multi-repo is used for:

* Real production
* Enterprise environments
* Interviews

👉 **Both are correct depending on context.**

---

## 🎯 Interview-Perfect Answer (MEMORIZE)

> In production, we typically use multiple Terraform repositories. Platform engineers manage shared infrastructure like networking and backends, while DevOps or application teams have separate repositories for their services. Teams collaborate using remote state stored in S3 with DynamoDB locking.

---

## 🧠 One-Sentence Summary (VERY STRONG)

> Platform teams build the foundation, application teams build on top of it.

---

## ✅ Certificate Alignment (Terraform Associate)

The exam expects you to know:

* Multiple repos exist
* Remote state enables collaboration
* State must be secured
* Teams are isolated

---

## What this project covers

✔ Git team collaboration
✔ Why Terraform state must NOT be in Git
✔ `.gitignore`
✔ Terraform backend
✔ S3 backend
✔ DynamoDB state locking
✔ Terraform state management
✔ Remote state data source
✔ Cross-project collaboration
✔ Terraform import
✔ Interview & certification alignment

---

## Real-World Scenario

A company has multiple teams:

* Networking team → creates VPC
* Application team → creates EC2
* Teams collaborate using remote state
* State is stored securely in S3
* Git is used safely by multiple engineers

---

## High-Level Architecture

```text
GitHub (Code Only)
      |
Terraform
      |
S3 (State Files)
      |
DynamoDB (Locking)
      |
Networking Project (VPC)
      |
Application Project (EC2)
```

---

## 1️⃣ Create ONE parent directory

```bash
mkdir terraform-team-collaboration
cd terraform-team-collaboration
```

---

## FINAL PROJECT STRUCTURE

```text
terraform-team-collaboration/
│
├── terraform-networking/
│   ├── backend.tf
│   ├── provider.tf
│   ├── vpc.tf
│   ├── subnet.tf
│   └── outputs.tf
│
└── terraform-application/
    ├── backend.tf
    ├── provider.tf
    ├── data.tf
    └── ec2.tf
```

---

# PART 1 — Networking Project (Platform Team)

### `terraform-networking/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-company-prod"
    key            = "networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

### `terraform-networking/provider.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### `terraform-networking/vpc.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}
```

---

### `terraform-networking/subnet.tf`

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
```

---

### `terraform-networking/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
```

---

### ▶ Run networking

```bash
cd terraform-networking
terraform init
terraform apply
```

---

# PART 2 — Application Project (DevOps Team)

### `terraform-application/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-company-prod"
    key            = "application/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

### `terraform-application/provider.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### `terraform-application/data.tf`

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-company-prod"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

### `terraform-application/ec2.tf`

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"

  subnet_id = data.terraform_remote_state.network.outputs.subnet_id

  tags = {
    Name = "app-server"
  }
}
```

---

### ▶ Run application

```bash
cd ../terraform-application
terraform init
terraform apply
```

---

## PART 3 — State Locking (DynamoDB)

* Two engineers run `terraform apply`
* Second engineer gets **state lock error**
* Infrastructure is protected

---

## PART 4 — Terraform Import (Overview)

```bash
terraform import aws_instance.app i-0abcd1234
terraform plan
```

✔ Existing infra now managed
✔ No recreation

---

## PART 5 — Terraform State Management

```bash
terraform state list
terraform state show aws_vpc.main
terraform state rm aws_instance.app
terraform refresh
```


