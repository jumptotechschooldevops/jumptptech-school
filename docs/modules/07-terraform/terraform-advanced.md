---
title: "terraform advanced"
description: "1️⃣ *Why Terraform? *   Terraform is used to automate cloud infrastructure so humans don’t..."
published: 2025-12-02
source: "https://dev.to/jumptotech/terraform-advanced-3kpe"
tags: []
---

# terraform advanced





## 1️⃣ **Why Terraform? **

Terraform is used to **automate cloud infrastructure** so humans don’t manually create:

* VPCs
* Subnets
* Security Groups
* ECS clusters
* Task definitions
* Load balancers
* IAM roles
* RDS
* S3
* DynamoDB
* Secrets
* ECR registries
* Route53
* CloudWatch alarms

In big companies:

### **Without Terraform**

* Engineers click around the console
* No history
* No review/tracking
* Accidental misconfiguration
* Hard to reproduce environments
* Hard to recover after failure
* Hard to scale
* Impossible to maintain dozens of environments

### **With Terraform**

* Everything is **code**
* The entire infrastructure is **repeatable**
* You can recreate the entire system from scratch
* Teams use Git history, PR reviews, CI/CD pipelines
* One command updates all cloud resources correctly

Your project has:

* **7 microservices (Python)**
* **ECS cluster**
* **ALB**
* **Couchbase**
* **Confluent Cloud**
* **PostgreSQL/RDS**
* **VPN / VPC**
* **Kafka Brokers**
* **Lambda (optional)**
* **S3 state backend**

This is exactly what Terraform is built for.

---

# 2️⃣ **Terraform Core Concepts EVERY Senior DevOps Must Know**

## **(A) Terraform is:**

### ✔️ Declarative

You describe **WHAT** you want, Terraform decides **HOW** to build it.

---

## **(B) Terraform Files**

### Your project has these:

| File           | Purpose                                      |
| -------------- | -------------------------------------------- |
| `provider.tf`  | AWS provider configuration                   |
| `backend.tf`   | S3 + DynamoDB state storage                  |
| `variables.tf` | Inputs used by your modules                  |
| `ecs.tf`       | ECS cluster, services, task definitions      |
| `alb.tf`       | Load balancer, listeners, target groups      |
| `rds.tf`       | PostgreSQL RDS instance                      |
| `network.tf`   | VPC + subnets (or reused existing VPC)       |
| `sg.tf`        | Security groups                              |
| `outputs.tf`   | Export useful values (ALB DNS, SG IDs, etc.) |






# ✅ **What Are Terraform Modules?**

**A Terraform module = a folder that contains Terraform configurations.**

Every Terraform project **already has a module**, even if you never created one.

Example:

```
main.tf
vars.tf
outputs.tf
vpc.tf
ecs.tf
```

**This whole project is already a module** → called the **root module**.

---

# ✅ **Why Do We Use Modules? (Real Senior DevOps Reasoning)**

Terraform modules solve real-world infrastructure problems:

### **1. Reusability**

You can write infrastructure *once* and reuse it in many environments:

* dev
* staging
* prod
* even across different projects

Example:

```
module "network" {
  source = "./modules/network"
}
```

That same module can be used 100 times.

---

### **2. Separation of Responsibility (Clean Architecture)**

In a real company:

* One team manages VPC networking
* Another team manages ECS
* Another team manages RDS
* Another team manages S3 & CloudFront

Modules allow each team to own a “box”.

---

### **3. Reduce Code Duplication**

Without modules you end up copying and pasting the same VPC code everywhere.

With modules you do:

```
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}
```

ONE VPC module. ZERO duplication.

---

### **4. Make Infrastructure Predictable & Standardized**

You enforce:

* naming conventions
* tags
* architecture patterns
* security rules

Everyone deploys infrastructure the same way.

---

### **5. Easier Maintenance**

When you fix a bug inside a module, it auto-propagates to all environments.

---

# 🇺🇸 **Simple Analogy**

Think of Terraform modules like **Python functions**.

If you didn't have functions, you would copy-paste the same code again and again:

```
def create_server():
    ...

# Instead of copy/paste 20 times
```

Terraform modules = **infrastructure functions**.

---

# 🔥 **Simple Example of Module Use**

## project/modules/s3_bucket/main.tf

```
resource "aws_s3_bucket" "this" {
  bucket = var.name
  tags   = var.tags
}
```

### project/modules/s3_bucket/variables.tf

```
variable "name" {}
variable "tags" { type = map(string) }
```

---

## Use it:

```
module "logs" {
  source = "./modules/s3_bucket"
  name   = "company-logs"
  tags   = {
    Project = "kafka-enterprise-orders"
  }
}
```

---

# 🎯 **In Senior DevOps Interviews: How to Explain Terraform Modules**

Here is the **perfect senior-level answer**:

> **Terraform modules help us structure, organize, and reuse infrastructure as code.
> They enable standardization, reduce duplication, enforce best practices, and allow multi-environment deployments with minimal effort.
> Without modules infrastructure becomes messy, unmaintainable, and inconsistent.
> With modules we build reusable building blocks—network, compute, database, observability—that can be consumed by multiple teams.**

This answer gets you a **10/10**.

---

# 📌 **Three types of modules**

### **1. Root Module**

Your main project (the folder where you run `terraform apply`).

### **2. Local Modules**

Stored inside your repo:

```
modules/vpc
modules/ecs
modules/rds
```

### **3. Remote Modules**

Come from Terraform Registry:

```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"
}
```

Companies use remote modules heavily.



# 3️⃣ **Terraform State — What Companies Expect You to Know**

Terraform keeps a “memory” of everything it created in:

```
terraform.tfstate
```

This file contains:

* All AWS resource IDs
* Dependencies between resources
* Current configuration
* Attributes of each resource

🚨 **This file is critical — losing it is catastrophic.**

That’s why **no one stores tfstate locally** in enterprises.

Instead, you stored it in:

### ✔️ S3 → stores the `.tfstate`

### ✔️ DynamoDB → manages locks

---

# 4️⃣ **Why S3 Backend? (Your Project Example)**

Your project has:

* **GitHub Actions**
* **Local development**
* **Different machines**
* **Multiple terraform apply executions**

If each machine stored **local tfstate**, then:

* One `apply` would overwrite another
* GitHub cannot see local changes
* Terraform gets confused
* Many resources would duplicate or destroy incorrectly

S3 fixes all of that:

### ✔️ One central state for all Terraform runs

### ✔️ GitHub Actions + your laptop read the same state

### ✔️ Safe to delete local `terraform.tfstate`

### ✔️ State is versioned → rollback possible

---

# 5️⃣ **Why DynamoDB Lock? (Your Exact Issue Today)**

Terraform must prevent **two applies at the same time**.

So when you run:

```
terraform plan
terraform apply
```

Terraform writes a lock into DynamoDB:

```
LockID = kafka-enterprise-orders-tfstate/terraform.tfstate
```

If GitHub Actions tries to run while your local run is running → **lock prevents corruption**.

If the previous run crashed → the lock **stays forever** → **you must delete it manually**.

This happened to you today.

---

# 6️⃣ **Terraform Apply Flow (Your Project Real Flow)**

Your CI/CD pipeline does:

### **STEP 1 — terraform init**

* Downloads AWS provider
* Reads backend config
* Connects to S3
* Connects to DynamoDB

### **STEP 2 — terraform plan**

* Compares desired infrastructure (code)
* With actual infrastructure (AWS)
* Shows changes

### **STEP 3 — terraform apply**

* Creates ECS task definitions
* Updates ECS services
* Updates ALB target groups
* Updates security groups
* Updates subnet associations
* Updates IAM roles
* Updates ECS service connections
* Creates RDS if needed
* Produces output (ALB DNS, SG IDs, etc.)

---

# 7️⃣ **Terraform Drift Detection (VERY important for senior roles)**

Terraform ALWAYS detects drift:

Examples:

### **Case 1 — A subnet was deleted**

You saw:

```
InvalidSubnetID.NotFound
```

Terraform sees that AWS changed behind its back → tries to fix it.

---

# 8️⃣ **Terraform Variables & Secrets (Your Project)**

You pass these from GitHub → terraform:

```
TF_VAR_container_image_producer
TF_VAR_container_image_payment
TF_VAR_container_image_fraud
TF_VAR_container_image_analytics
TF_VAR_web_backend_image
TF_VAR_web_frontend_image
TF_VAR_confluent_bootstrap_servers
TF_VAR_confluent_api_key
TF_VAR_confluent_api_secret
TF_VAR_rds_password
TF_VAR_existing_vpc_id
TF_VAR_existing_public_subnet_ids
TF_VAR_existing_private_subnet_ids
TF_VAR_existing_ecs_tasks_sg_id
TF_VAR_existing_alb_sg_id
TF_VAR_existing_rds_sg_id
```

This is **how code dynamically reads images for each deploy**.

When you push code → CI/CD builds images → pushes to GHCR → injects into Terraform → updates ECS.

---

# 9️⃣ **Terraform in Senior DevOps Interviews — What They Expect**

### **Must Know Topics**

✔ Terraform state
✔ Backends (S3, Azure Blob, GCS)
✔ Locking (DynamoDB)
✔ Modules
✔ Workspaces
✔ Providers
✔ Data sources
✔ Variables & outputs
✔ Dependency graph
✔ Lifecycle rules
✔ terraform import
✔ terraform taint
✔ terraform graph
✔ CI/CD pipelines
✔ Secrets management

### **Explain real examples**

Use your project:

> “Our Terraform manages ECS, ALB, VPC, RDS, SGs, and Kafka resources.
> State is centralized in S3 with DynamoDB locking to avoid concurrency issues.
> GitHub Actions injects images built in CI into ECS task definitions via TF_VAR_ variables.”

This is exactly what senior engineers say.

---

# 🔟 **Why Terraform Is Required in *Your Project***

Because you have **17+ dependent AWS resources**, and these must update together:

* Change a container image → ECS tasks update
* Change port → ALB target group updates
* Change AWS region → VPC + subnets + RDS must recreate
* Change Kafka clusters → environment variables update
* Change security groups → ECS & ALB update

Terraform guarantees everything deploys in the right order.

---

# 1️⃣1️⃣ **How Terraform Works Internally (“Graph Theory”)**

Terraform builds a dependency graph:

```
aws_vpc -> subnets -> route tables -> SG -> ALB -> ECS cluster -> ECS services -> tasks
```

Terraform then executes:

* **parallel where possible**
* **sequential where required**

---

# 1️⃣2️⃣ **Your ECS Errors Today — Terraform Detecting Infra Issues**

### ⛔ Invalid security group

You passed `"***"` in secrets
Terraform rejected it
Corrected.

### ⛔ Subnet deleted manually

Terraform warned you
You fixed by updating correct subnet IDs.

---

# 1️⃣3️⃣ **Terraform CI/CD — Your Pipeline**

Your GitHub Actions does:

1️⃣ Build Docker images
2️⃣ Push to GitHub Container Registry
3️⃣ Run Terraform
4️⃣ Update ECS
5️⃣ New containers deploy instantly

This is enterprise-grade.


