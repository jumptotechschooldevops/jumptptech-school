---
title: "Terraform Three-Layer Architecture"
description: "1. Why should we care about multi-layer Terraform design?   When infrastructure gets big..."
published: 2025-12-05
source: "https://dev.to/jumptotech/terraform-three-layer-architecture-24fe"
tags: []
---

# Terraform Three-Layer Architecture




# **1. Why should we care about multi-layer Terraform design?**

When infrastructure gets big (VPC, ECS, RDS, KMS, SGs, ALB, Route53, IAM, etc.):

* Your **main.tf becomes too long**
* Responsibility becomes **mixed** (EC2 + IAM + SG + R53 in same file)
* The **blast radius increases** (changing one resource breaks others)
* Reusability becomes low
* Hard to manage environments: `dev`, `stage`, `prod`

So we need a way to **group resources by responsibility**, reduce noise, and make Terraform more modular.

---

# **2. Three Core Concepts Explained**

### **(1) Resource Modules**

These are **low-level modules** that each manage only *one AWS service*.

Examples:

```
modules/
  ec2/
     main.tf   (only EC2 resources)
  vpc/
     main.tf   (only VPC resources)
  kms/
     main.tf   (only KMS resources)
  rds/
     main.tf   (only RDS resources)
```

**Rules:**

* Must contain *only one* AWS resource type (EC2 OR SG OR IAM etc.)
* Very clean, very small
* Similar to “classes containing private methods”

---

### **(2) Infra Modules (Middle Layer)**

These are **business-logic modules** that combine multiple resource modules together.

Example:
To create a **Bastion Host**, you actually need:

* EC2 instance
* Security group
* IAM role
* IAM instance profile
* Parameter Store entry (IP address)
* Key pair

Instead of calling all of them from the root `main.tf`, we create:

```
infra/
  bastion/
      main.tf   ← calls resource modules like ec2, sg, iam, parameter store
```

So **infra modules act like a class** that hides all internal implementation.

Root should not know about IAM roles or SG logic.
Root should only know:

```
module "bastion" {
  source = "../infra/bastion"
}
```

This is **abstraction**.

---

### **(3) Composition Layer (Root Layer)**

This is the **environment layer**:

```
composition/
   dev/
      main.tf
   staging/
      main.tf
   prod/
      main.tf
```

Each `main.tf` simply calls infra modules:

```
module "bastion" {
  source = "../../infra/bastion"
  subnet_id = ...
}
module "alb" {
  source = "../../infra/alb"
}
module "rds" {
  source = "../../infra/rds"
}
```

This layer becomes **very small and clean**.

It does NOT call resource modules directly.
It ONLY calls infra modules.

---

# **3. Why 3 Layers Are Needed — Key Problems Solved**

---

## **Problem 1 — Breaking Single Responsibility**

Example: creating a Bastion EC2 needs:

* EC2 instance (compute)
* IAM role (identity)
* Security group (network)
* Parameter store (SSM)

If you put IAM + SG inside `ec2 module` → it violates SRP
Each resource type must live in its own module.

**Three-layer design fixes this:**
Resource modules stay clean → all combined inside an infra module.

---

## **Problem 2 — Main.tf Becomes Too Noisy**

If root directly calls everything:

```
module "bastion_ec2" { }
module "bastion_sg" { }
module "bastion_iam" { }
module "bastion_ssm" { }
module "rds" { }
module "rds_sg" { }
module "kms" { }
module "alb" { }
...
```

Root (composition) becomes 500+ lines — impossible to maintain.

**Solution:**
Composition layer becomes very small:

```
module "bastion" { }
module "rds"     { }
module "alb"     { }
```

---

## **Problem 3 — Huge Blast Radius**

When you edit root `main.tf`:

* Terraform plan touches everything
* Very risky
* Easy to break infrastructure

When using 3 layers:

* Only infra module changes affect resources
* Root remains untouched

This reduces accidents in production.

---

# **4. How the Three Layers Work Together (Simple Diagram)**

```
                   ┌─────────────────────────┐
                   │   Composition Layer      │
                   │  (Environment: prod)     │
                   └──────────────┬───────────┘
                                  │ uses
                                  ▼
                   ┌─────────────────────────┐
                   │     Infra Modules        │
                   │  (bastion, alb, rds...)  │
                   └──────────────┬───────────┘
                                  │ calls
                                  ▼
                   ┌─────────────────────────┐
                   │    Resource Modules      │
                   │ (ec2, sg, iam, kms...)   │
                   └──────────────────────────┘
```

---

# **5. Example: Creating Bastion Host in 3-Layer Structure**

### **Resource Modules**:

```
modules/ec2
modules/sg
modules/iam
modules/ssm
```

### **Infra Module: bastion/**

```
infra/bastion/main.tf
   → module "ec2"
   → module "sg"
   → module "iam"
   → module "ssm"
```

### **Composition Layer**

```
composition/prod/main.tf

module "bastion" {
  source = "../../infra/bastion"
}
```

Root does not know ANY internal details.

---

# **6. Benefits of This Architecture**

### **1. Cleanest `main.tf` possible**

Only 10–20 lines.

### **2. High modularity**

Change bastion logic → update `infra/bastion/main.tf` only.

### **3. Reduced blast radius**

Changing IAM in Bastion module does NOT touch ALB, RDS, etc.

### **4. Reusability**

You can reuse `infra/bastion` in:

* dev
* staging
* prod
* other projects

### **5. Clearly separated responsibilities**

Great for large companies and multiple engineers.

---

# **7. Summary—The Core Idea in One Sentence**

**Instead of having root call all AWS resources directly, we introduce middle-layer modules that hide complexity and group related resources into meaningful units (Bastion, ALB, RDS), making the architecture maintainable, extensible, and production-ready.**






## Chapter: Creating Terraform Remote Backend with 3-Layer Module Architecture

we’ll **create a Terraform remote backend** (S3 + DynamoDB + KMS) using the **three-layer module architecture**:

* **Composition layer**
* **Infra (infrastructure) modules layer**
* **Resource modules layer**

The idea:
Before we start creating things like **VPC**, **EC2**, etc., we first need a **remote backend** so Terraform state can be stored safely in **S3**, with **DynamoDB for state locking**, and optionally **KMS for encryption**.

We’ll implement even this backend using the same **3-layer architecture** we discussed earlier.

---

## 1. Overall Structure for the Backend

We will organize the code like this:

### **1) Composition layer**

This is the **top-level (entry point)**, per environment and per region.

Example:

```text
composition/
  remote-backend/        # Business meaning: remote backend setup
    ap-northeast-1/      # Region folder (e.g., ap-northeast-1, us-east-1, etc.)
      prod/              # Environment (dev, staging, prod...)
        main.tf          # Entry point (main function)
```

* `remote-backend` – tells you this composition is for backend.
* Inside, we break down by **region** (e.g., `ap-northeast-1`, `us-east-1`).
* Inside region, we break down by **environment** (e.g., `prod`).
* `main.tf` is the **entry point** for that environment/region.
  It will call the **infra module**.

---

### **2) Infra modules layer**

This layer represents the **“facade”** — a business-oriented module that bundles all the pieces required for the backend.

Example:

```text
infra/
  remote-backend/
    main.tf   # Facade module – wires together S3 bucket, DynamoDB, KMS using resource modules
    variables.tf
    outputs.tf
```

This `infra/remote-backend/main.tf` will:

* Create **S3 bucket** for Terraform state
* Create **DynamoDB table** for state locking
* Create **KMS key** if we want to encrypt objects
* Possibly add required policies, tags, etc.

So from a business point of view:

> “I want a Terraform remote backend” → this infra module hides all details.

---

### **3) Resource modules layer**

This is the **lowest level**, where we place **plain Terraform resources**, one AWS service per module.

Example:

```text
resource-modules/
  s3-backend-bucket/
    main.tf      # resource "aws_s3_bucket" ...
  dynamodb-lock-table/
    main.tf      # resource "aws_dynamodb_table" ...
  kms-key/
    main.tf      # resource "aws_kms_key" ...
```

Here we will **copy the native Terraform resource blocks** (like from documentation or existing code) and keep them as simple and atomic as possible.

---

## 2. What Resources Make Up the Remote Backend?

To create a **Terraform remote backend** on AWS, we typically need:

* **S3 bucket** – to store the Terraform state file
* **DynamoDB table** – for **state locking** (so multiple people can’t modify at once)
* **KMS key** – to encrypt the state at rest (optional, but good practice)

In this architecture:

* Each of these is a **resource module**
* They are **combined in the infra module** `remote-backend`
* The **composition layer main.tf** just calls the infra module

---

## 3. Implementation Strategy (Bottom-Up Approach)

We’ll build this in **three steps**, starting from the bottom (resource modules) and going up.

---

### **Step 1 — Create resource modules (lowest level)**

> “Replicate the Terraform modules in local resource modules.”

For simple services like **S3**, **KMS**, **DynamoDB**, we don’t need remote (external) modules from the Registry.
We can easily create **local resource modules**.

Example (conceptually):

1. `resource-modules/s3-backend-bucket/main.tf`

   * `resource "aws_s3_bucket" "this" { ... }`
2. `resource-modules/dynamodb-lock-table/main.tf`

   * `resource "aws_dynamodb_table" "this" { ... }`
3. `resource-modules/kms-key/main.tf`

   * `resource "aws_kms_key" "this" { ... }`

This is the **foundation**.

---

### **Step 2 — Create infra module (facade for backend)**

> “Create a facade-like Terraform remote backend infra module.”

Here we build `infra/remote-backend/main.tf` which **consumes** the resource modules created in Step 1.

Inside this file:

* Call the **S3 bucket module**
* Call the **DynamoDB module**
* Call the **KMS module**
* Wire inputs/outputs between them as needed
* Expose clean outputs (e.g. bucket name, DynamoDB table, KMS key)

This module acts like a **class** that knows how to construct the **entire remote backend**.

The composition layer will simply call:

```hcl
module "remote_backend" {
  source = "../../infra/remote-backend"

  region        = "ap-northeast-1"
  environment   = "prod"
  project_name  = "your-project"
}
```

---

### **Step 3 — Create composition layer (top-level main.tf)**

> “Create the composition layer and define all required inputs to integrate modules in main.tf.”

Now we go to:

```text
composition/remote-backend/ap-northeast-1/prod/main.tf
```

This `main.tf` is the **entry point** that:

* Sets the **AWS provider** and region
* Calls the **infra/remote-backend** module with correct variables (environment, region, names, tags)
* Optionally contains the **`terraform` block** pointing to the backend (once created)

This is where we run:

```bash
terraform init
terraform apply
```

to **create the backend infrastructure**.

---

## 4. Why Are We Using the 3-Layer Architecture Even for Backend?

You might think:

> “Backend is small – S3 + DynamoDB + KMS – why not do it in a single `main.tf`?”

The reason we still use 3 layers:

* To **practice the same architecture** we’ll use for VPC, ECS, RDS, etc.
* To keep **consistency** across the whole project
* To show students how even a small feature can be modeled with:

  * **Resource modules** (low-level AWS resources)
  * **Infra modules** (business functions like “remote backend”)
  * **Composition layer** (environment/region specific entrypoints)

It’s a bit more complex at first, but:

* **Easier to extend** later
* **Cleaner separation** of responsibilities
* **Better for production** setups








# ✅ **Step 1 — Replicate the Multi-Tiered Remote Modules Into Local Resource Modules**

Before we build **infra modules** and **composition layers**, the very first step is to create **resource modules** — the smallest, most atomic building blocks.

These are the modules that directly contain:

* `resource "aws_s3_bucket"...`
* `resource "aws_dynamodb_table"...`
* `resource "aws_kms_key"...`



> Terraform Registry modules are powerful, but for **simple services** like S3/DynamoDB/KMS, we want small, clean **local resource modules** so we can reuse them later.

---

# ✅ **1. Organize Your Resource Modules by AWS Category**

The instructor follows **AWS Console categories** for clarity:

| AWS Service | Category       | Your Local Folder                     |
| ----------- | -------------- | ------------------------------------- |
| S3 bucket   | Storage        | `resource-modules/storage/s3/`        |
| DynamoDB    | Database       | `resource-modules/database/dynamodb/` |
| EC2         | Compute        | `resource-modules/compute/ec2/`       |
| KMS         | Security / IAM | `resource-modules/security/kms/`      |

This is exactly how AWS organizes services internally.

### Why this folder structure?

Because later, when you have **100 modules**, this makes everything easier:

* You can find resources by category quickly
* The hierarchy stays clean
* Students immediately understand where resources belong
* Infra modules become easier to build

---

# ✅ **2. Create Resource Modules By Copying From Official Terraform Registry**

### Example: S3 Backend

The official AWS Terraform module (`terraform-aws-modules/s3-bucket`) is long (279 lines).
If you used it directly, it would complicate the course.

So instead:

1. Open the registry link.
2. Click **Raw** on each file (`main.tf`, `variables.tf`, `outputs.tf`).
3. Copy those contents.
4. Paste them into your local module:

### Folder:

```
resource-modules/
 └── storage/
      └── s3/
           ├── main.tf
           ├── variables.tf
           └── outputs.tf
```

---

# ⚠️ Important:

The instructor **already externalized all variables** (converted them from hardcoded values).
You must do the same whenever you copy modules.

---

# 🔍 **3. Understanding Externalizing Variables**

The professor references this technique:

> Enable multi-cursor, select each attribute value, convert `"something"` into `var.something`.

This makes the module **reusable**.

### Before (hardcoded):

```hcl
bucket = "my-hardcoded-bucket"
```

### After externalizing:

```hcl
bucket = var.bucket
```

### Why?

Because later you'll pass different values from infra modules and environment-level composition:

* bucket name for dev
* bucket name for prod
* bucket name for region ap-northeast-1

Without externalization → the module becomes useless outside one scenario.

---

# ✅ **4. Repeat for DynamoDB and KMS**

### DynamoDB

* Very simple: create table, PK, capacity, encryption, etc.
* Same process: copy raw → extract → externalize variables

Folder:

```
resource-modules/database/dynamodb/
   ├── main.tf
   ├── variables.tf
   └── outputs.tf
```

### KMS

KMS registry modules are often more customized.

Instructor says:

> I already externalized everything for you.

Meaning:

* Removed all hardcoded alias names
* Exposed all arguments in `variables.tf`
* Created outputs properly

Folder:

```
resource-modules/security/kms/
   ├── main.tf
   ├── variables.tf
   └── outputs.tf
```

---

# 🎯 **5. Why Step 1 Matters (Purpose of Resource Modules)**

Resource modules must be:

* **Atomic** → only ONE AWS service per module
* **Stateless** → nothing depends on higher layers
* **Reusable** → only variables and outputs, no business logic
* **Clean** → no hardcoded values

These modules form the foundational building blocks for:

* Infra modules (middle layer)
* Composition layer (entry points)
* All future resources (VPC, ECS, RDS, KMS, S3, etc.)

---

# 🧠 **6. Summary (One Sentence)**

> Step 1 creates the clean, atomic resource modules by copying Terraform registry modules, externalizing all variables, and organizing them into AWS-style categories, forming the foundation for the 3-layer architecture.







# ✅ **STEP 2 — Create Infrastructure Modules (The FACADE Layer)**

In Step 1, you created **resource modules**:

```
resource-modules/
  storage/s3/...
  database/dynamodb/...
  security/kms/...
```

These modules contain ONLY atomic AWS resources.
They are NOT used directly by the environment.

Now in **Step 2**, you create the **infrastructure module** — a layer that **consumes the resource modules** and **wraps them together into one logical unit**.

This is called the **Facade Layer**.

---

# 🎯 **Purpose of the Infra Module**

Your professor says this many times:

> “The infra module acts like a facade. It hides all subsystem details and provides a simple interface to the client.”

Meaning:

* The **client** = composition layer (`prod/main.tf`, `dev/main.tf`, etc.)
* The **complex internals** = S3, DynamoDB, KMS
* The **infra module** = wrapper that combines everything

So instead of the composition layer calling:

```
module s3
module dynamodb
module kms
```

It just calls:

```
module "remote_backend" {
  source = "../../infra/remote-backend"
}
```

This is the same as the **Facade Pattern** in software engineering.

---

# 📁 Step 2 Folder Structure

```
infra/
  remote-backend/
    main.tf
    variables.tf
    outputs.tf
    data.tf
```

This module:

* **Does NOT contain resources directly**, except for:

  * `random_integer` (to avoid S3 bucket name collisions)
* Calls all resource modules:

  * S3 module
  * DynamoDB module
  * KMS module

---

# 🔍 Inside infra/remote-backend/main.tf

This is the heart of step 2.

### ✔ It *must* call the S3 module:

```hcl
module "s3_backend_bucket" {
  source = "../../resource-modules/storage/s3"

  bucket = local.s3_bucket_name
  acl    = "private"
  # other variables…
}
```

### ✔ It *must* call the DynamoDB module:

```hcl
module "dynamodb_state_lock" {
  source       = "../../resource-modules/database/dynamodb"
  name         = local.lock_table_name
  read_capacity  = 5
  write_capacity = 5
}
```

### ✔ It *must* call the KMS module:

```hcl
module "kms_backend_key" {
  source = "../../resource-modules/security/kms"

  description = "KMS key for encrypting Terraform backend"
  # other variables…
}
```

### ✔ It *may* contain a random_integer resource

Because the S3 bucket name **must be globally unique**.

Example:

```hcl
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}
```

### ✔ It constructs the bucket name using locals:

```hcl
locals {
  s3_bucket_name = "${var.project}-${var.env}-${var.region}-${random_integer.rand.result}"
}
```

This ensures:

* Every student gets a unique bucket name
* No S3 bucket naming collisions

---

# 🔍 What About data.tf?

Your professor referenced this:

* `data.tf` may contain `data "aws_region"` or other read-only lookups.
* It also may contain the usage of `random_integer`.

This file is where local variables are used to construct meaningful names:

```hcl
locals {
  lock_table_name = "${var.project}-state-lock-${var.env}"
}
```

---

# 🔍 variables.tf in Infra Layer

The infra module needs **input variables** such as:

* `region`
* `environment`
* `project`
* other backend identifiers

The professor explains:

> Some variables are local (internal), others are input variables.
> If the client should be able to configure a value → use `var`.
> If the value should be hidden → use `local`.

Meaning:

### Use **var** when:

The caller (composition layer) should be able to define:

* environment (`dev`, `prod`)
* project name
* region (`us-east-1`)
* capacity settings (optional)

### Use **local** when:

The value should be computed internally:

* bucket naming patterns
* full ARNs created from pieces
* table naming conventions

---

# 🔍 outputs.tf in Infra Layer

Infra layer must output:

* S3 bucket name → for backend config
* DynamoDB table name → for state locking
* KMS key ID / ARN

BUT IMPORTANT:

> The output names in infra module **cannot collide** with the resource module outputs.

Example:

Resource module output:

```hcl
output "id" {}
```

Infra module output must make it unique:

```hcl
output "dynamodb_state_lock_id" {
  value = module.dynamodb_state_lock.id
}
```

This prevents:

```
Error: Duplicate output name "id"
```

---

# ⚠️ IMPORTANT CONCEPT

Your teacher emphasized:

> “You must bubble outputs UP.”

This means:

1. Resource module outputs → go to
   **infra module outputs**
2. Infra module outputs → go to
   **composition layer outputs**

This is how Terraform modules pass values upward.

---

# 🧠 Summary of Step 2

### ✔ You create an **infra module** (`infra/remote-backend/`)

### ✔ It contains:

* **main.tf** → calls S3, Dynamo, KMS modules
* **data.tf** → helps construct names, uses random integer
* **variables.tf** → inputs from composition layer
* **outputs.tf** → outputs to composition layer

### ✔ This module is a **facade** (wrapper)

### ✔ It simplifies the composition layer

Instead of the composition layer calling 10 modules, it calls only:

```hcl
module "remote_backend" {
  source = "../../infra/remote-backend"
}
```








# ✅ **STEP 3 — Create the Composition Layer and Pass Inputs to Infra Module**

At this point:

* **Step 1** → Resource modules created (S3, DynamoDB, KMS)
* **Step 2** → Infra module created (`infra/remote-backend/`), where you wired together S3 + DynamoDB + KMS through a façade module

Now:

> **Step 3:** Create the *composition layer* and define all required inputs for the infra module.

The composition layer is the **entry point** — the only place where `terraform apply` is executed.

---

# 🎯 **Purpose of the Composition Layer**

The composition layer:

* Contains **one single module call**
* Passes input values into the **infra module**
* Does NOT know anything about the S3, DynamoDB, or KMS internals
* Is the “client” of the whole architecture
* Represents an **environment** (prod, dev) and **region** (us-east-1, ap-northeast-1)

This layer is extremely small — and that is the **beauty of the 3-layer architecture**.

---

# 📁 **Composition Layer Folder**

Example:

```
composition/
  remote-backend/
    ap-northeast-1/
      prod/
        main.tf
        variables.tf
        terraform.tfvars
        outputs.tf
```

Only this folder is used to **run** Terraform.

---

# 🧩 **main.tf (Entry Point)**

Inside `main.tf`, we call just ONE module:

```hcl
module "terraform_remote_backend" {
  source = "../../../infra/remote-backend"

  region                 = var.region
  project                = var.project
  environment            = var.environment
  acl                    = var.acl
  force_destroy          = var.force_destroy
  read_capacity          = var.read_capacity
  write_capacity         = var.write_capacity
}
```

### 🔥 Important:

* The **left-hand side** (`region`, `acl`, etc.) = infra module input variable name
* The **right-hand side** (`var.region`) = values coming from the **composition layer**

Your instructor warns:

> “ACL on left means infra module variable; ACL on right means composition variable.”

This can be confusing.
Just remember:

```
infra-layer var = composition-layer var
```

---

# 🧩 **variables.tf (Composition Layer)**

This file defines inputs that the composition layer accepts:

```hcl
variable "region" {}
variable "project" {}
variable "environment" {}
variable "acl" {}
variable "force_destroy" {}
variable "read_capacity" {}
variable "write_capacity" {}
```

These are passed down to the infra module.

---

# 🧩 **terraform.tfvars (Actual Runtime Values)**

The instructor’s example:

```hcl
region        = "ap-northeast-1"
project       = "terraform-demo"
environment   = "prod"
acl           = "private"
force_destroy = true

read_capacity  = 5
write_capacity = 5
```

These are the **real values** fed into variables.tf → main.tf → down into infra module.

This is where you specify:

* region
* environment
* project name
* S3 configuration
* DynamoDB throughput

---

# 🧩 **outputs.tf (Bubble Outputs Upwards)**

Because infra module outputs values (bucket name, DynamoDB ARN, KMS key ID),
we must **bubble them up** to the composition layer:

```hcl
output "backend_bucket" {
  value = module.terraform_remote_backend.backend_bucket
}

output "dynamodb_lock_table" {
  value = module.terraform_remote_backend.dynamodb_lock_table
}

output "kms_key_arn" {
  value = module.terraform_remote_backend.kms_key_arn
}
```

> This is why we only use **three layers max** — bubbling outputs up multiple times becomes redundant and confusing.

---

# 🧪 **Running Terraform in Step 3**

Since the backend does not exist yet, we **must use local state** for the very first apply.

### 1️⃣ Initialize without backend

```bash
terraform init
```

This uses local `.terraform/terraform.tfstate` because S3 is not created yet.

---

### 2️⃣ Plan

```bash
terraform plan
```

Terraform will show:

* S3 bucket creation
* DynamoDB table creation
* KMS key creation
* Random integer resource
* Bucket policy
* KMS key policy

---

### 3️⃣ Apply

```bash
terraform apply
```

Terraform will:

* Create DynamoDB
* Create KMS
* Create bucket
* Apply bucket policy
* Apply KMS policy
* Generate random integer suffix (to avoid bucket name collisions)

---

# 📤 **Outputs Show Everything Was Created Correctly**

Your instructor mentioned:

* Outputs appear in **alphabetical order**
* Prefixes (e.g., `kms_`, `dynamo_`, `s3_`) help keep them grouped
* These outputs come from infra module → composition layer

Example output:

```
backend_bucket = "terraform-demo-prod-apne1-83932"
dynamodb_lock_table = "terraform-lock-prod"
kms_key_arn = "arn:aws:kms:ap-northeast-1:123456789:key/abcd..."
```

---

# 🗄️ **State File Notes**

Terraform state is **still local** at this moment:

```
terraform.tfstate
```

You CAN now upload this manually to S3 if needed, but typically:

* In next step (after backend creation),
* You update Terraform configuration in the **project root** to use remote backend
* Run `terraform init -migrate-state` to move state from local → S3

---

# 🎯 **Step 3 Summary (Perfect For Teaching)**

1. **Composition layer** = entry point for environment + region
2. It calls **only ONE module** from infra layer
3. Composition layer defines required input variables
4. Values are provided in **terraform.tfvars**
5. Outputs are bubbled up again
6. Run Terraform locally to create backend
7. After creation, the backend can be switched to S3

This finalizes **Chapter 3** and completes the **three-layer Terraform architecture** for backend creation.







# ✅ **STEP 1 (NEW): Re-create Multi-Tier Terraform Modules for VPC & Security Group in Resource Modules**

We already completed Step 1 for:

* S3
* DynamoDB
* KMS

Now we repeat the exact same process for:

* **VPC module**
* **Security Group module**

These are large, complex modules — so unlike S3 or DynamoDB, we **do not rewrite them manually**.

Instead, we **copy them exactly** from the Terraform Registry.

---

# 🎯 **Goal of This Step**

Create two new resource modules inside your folder structure:

```
resource-modules/
  network/
    vpc/
  network/
    security-group/
```

These modules will later be used by:

* Infra Layer (`infra/network-vpc`)
* Composition Layer (`composition/prod/network-vpc`)

---

# 📁 Resource Module Folder Layout

The recommended structure:

```
resource-modules/
  network/
    vpc/
      main.tf
      variables.tf
      outputs.tf
      modules/          ← sometimes exists inside registry module
    security-group/
      main.tf
      variables.tf
      outputs.tf
```

Your instructor says:

> “Do NOT skip any .tf files. Copy EVERYTHING exactly from the registry.”

This includes:

* `main.tf`
* `variables.tf`
* `outputs.tf`
* `versions.tf` (if present)
* `modules/` subfolder (if present)

---

# 🔍 **Why Copy-Paste? Why Not Write Our Own?**

Because:

* VPC module contains **hundreds of lines**
* Security group module contains **complex logic**, especially:

  * computed ingress rules
  * conditional expressions
  * NAT gateways
  * endpoints
  * flow logs
  * tagging
* Rewriting this from scratch is not realistic

Terraform remote modules already implement:

* All AWS best practices
* All edge cases
* All conditional logic
* Many optional features

So we simply **copy the module** into our resource-module folder.

This allows us to:

* Learn multi-layer architecture
* Keep 100% of module functionality
* Later build infra layer and composition layer on top of it

---

# 📌 **Important: You DO NOT modify these local modules**

Instructor says:

> “You DO NOT edit any of these files. These are straight from remote modules.”

Why?

Because resource modules are meant to be **stable foundation blocks**.

Changes must happen in:

* The infra layer
* Or the composition layer

Not here.

---

# 🧩 **WHERE to get these modules**

### VPC Module

You go to:

```
terraform-aws-modules/vpc/aws
```

Steps:

1. Open module
2. Open each `.tf` file
3. Click **Raw**
4. Copy → paste into your `resource-modules/network/vpc/` folder

---

### Security Group Module

You go to:

```
terraform-aws-modules/security-group/aws
```

Steps:

1. Open module
2. Open `.tf` files
3. Copy everything
4. If the module has subfolder `modules/`, copy that too (not always required)

---

# 🧠 Understanding the Examples (Very Important)

Your instructor explains:

> “You cannot go through every variable manually. There are too many.”

For example, the VPC module has:

* 80+ variables
* dozens of resources
* conditional expressions
* flow log support
* NAT gateway support
* subnet calculations
* endpoint support

### So how do you know what to use?

→ **Look at the examples folder in the GitHub repository.**

For VPC module:

```
examples/complete/main.tf
```

This shows:

* Required variables
* Optional variables
* How to structure subnets
* How availability zones work
* How to enable endpoints
* How to enable logs

This is how you learn to configure the module.

Same for Security Group module:

```
examples/complete/main.tf
```

This example shows:

* multiple ingress rule formats
* computed rules
* references to other SGs
* EC2 → SG usage
* IPv4 vs IPv6 rules

---

# 🔥 Extremely important distinction: "computed" vs "non-computed" rules

Your instructor explains something many people get wrong:

### **Non-Computed Ingress/Egress rules**

Example:

```hcl
ingress_with_source_security_group_id = [
  {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    source_security_group_id = module.alb_sg.id
  }
]
```

Used when:

* The SG we reference **already exists**

---

### **Computed Ingress/Egress rules**

Example:

```hcl
computed_ingress_with_source_security_group_id = [
  {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    source_security_group_id = module.instance_sg.id
  }
]

number_of_computed_ingress_with_source_security_group_id = 1
```

Used when:

* The referenced SG **may not exist yet at plan time**
* Terraform must resolve dependencies dynamically

This is why computed rules require:

```
number_of_computed_ingress_with_source_security_group_id
```

Terraform needs the **array length** ahead of time.

This confuses almost everyone at first — your instructor is explaining it so you don’t panic.

---

# 💡 Key Point

**You are not building infra modules yet.**
This step is ONLY:

* Copy
* Paste
* Verify folder structure

No thinking required here.

The thinking happens in **Step 2 (infra)**.

---

# 🎉 Summary of This Step

### ✔ Copy the full VPC module → resource-modules/network/vpc

### ✔ Copy the full Security Group module → resource-modules/network/security-group

### ✔ Do NOT modify these modules

### ✔ Use GitHub “examples” folder to learn how to use variables

### ✔ Computed rules exist when dependencies are not known at plan time

### ✔ This completes Step 1 for network modules








# ✅ **STEP 2 — INFRA MODULE FOR VPC (`infra/vpc/main.tf`)**

In Step 1, you copied the **VPC** and **Security Group** *resource modules* from the Terraform Registry into:

```
resource-modules/network/vpc/
resource-modules/network/security-group/
```

Now in **Step 2**, you create the **infra module** — a *facade* that wraps multiple resource modules to create a complete networking stack:

* VPC
* Public subnets
* Private subnets
* Database subnets
* Internet gateway
* NAT gateway(s)
* Route tables
* Route table associations
* Security groups (public/private/database)

This infra module acts like a **single class** that hides hundreds of lines of resource configuration.

---

# 🎯 **Why an Infra Module?**

Because your VPC module is **massive** (≈1000 lines).
Your Security Group module is also massive (≈500 lines).

If you used them directly from the composition layer, the config would become unreadable.

So:

### 🔹 The **resource modules** handle AWS low-level resources

### 🔹 The **infra module** wraps them into a meaningful “network stack”

### 🔹 The **composition layer** only calls ONE module

This is exactly the **Facade Design Pattern**:

> “Simplify access to a complex subsystem by presenting a single high-level API.”

---

# 📁 **Infra Module Structure**

```
infra/
  vpc/
    main.tf
    variables.tf
    data.tf
    outputs.tf
```

---

# 🧩 **main.tf — Calling the VPC Resource Module**

This is where we call your VPC module:

```hcl
module "vpc" {
  source = "../../resource-modules/network/vpc"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  database_subnets     = var.database_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs
  enable_flow_log         = var.enable_flow_log
  flow_log_destination_arn = var.flow_log_destination_arn

  tags = var.tags
}
```

Because we copied the entire VPC module, this one module automatically creates:

* VPC
* IGW
* NAT gateway(s)
* Route tables
* Subnets
* NACLs
* Flow logs
* DNS settings
* Endpoints (if later enabled)

So the infra module does NOT need to write any of this logic.

---

# ⚠️ Why we DO NOT change the VPC module itself

Because it’s:

* stable
* tested
* maintained
* feature complete

Your infra module only **configures** it.

---

# 🧩 **main.tf — Defining Security Groups**

We reuse the same `security-group` module **three times**:

### 🔹 Public Security Group (Internet-facing)

Allows:

* HTTP 80
* HTTPS 443
* (Optionally SSH)

Example:

```hcl
module "public_sg" {
  source = "../../resource-modules/network/security-group"

  name        = "${var.project}-public-sg"
  description = "Public subnet security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = ["all-all"]
}
```

---

### 🔹 Private Security Group

Only receives traffic from the public SG.

**Why computed_ingress?**

Because when Terraform runs:

* The *public SG module* might not exist yet.
* So Terraform cannot resolve `public_sg.id` at plan-time.

Therefore the computed version is used:

```hcl
module "private_sg" {
  source = "../../resource-modules/network/security-group"

  name        = "${var.project}-private-sg"
  description = "Private subnet security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.public_sg.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  egress_rules = ["all-all"]
}
```

Your instructor’s warning is correct:

> “If you change the number of rules, you MUST manually change `number_of_computed_ingress_with_source_security_group_id`.”

---

### 🔹 Database Security Group

This is intentionally flexible:

* You might choose MySQL, PostgreSQL, MongoDB, Redis, Aurora, DocumentDB…
* Different DBs have different ports
* So these rules should be configurable

Therefore the infra layer defines:

```hcl
local db_ingress_rules = concat(
  [
    # default recommended rules
    {
      rule                     = "self"
      source_security_group_id = null
    }
  ],
  var.db_custom_ingress_rules
)
```

And then:

```hcl
module "database_sg" {
  source = "../../resource-modules/network/security-group"

  name        = "${var.project}-database-sg"
  description = "Database subnet security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = local.db_ingress_rules
  number_of_computed_ingress_with_source_security_group_id = length(local.db_ingress_rules)

  egress_rules = ["all-all"]
}
```

This allows the composition layer to inject DB ports, for example:

```hcl
db_custom_ingress_rules = [
  {
    rule = "postgresql-tcp"
    source_security_group_id = module.private_sg.security_group_id
  }
]
```

---

# 🧠 **Local Variables vs Input Variables (Very Important)**

Your instructor explains:

* “Some values should be `locals`, some should be `vars`.”
* You must decide what the *client* (composition layer) should control.

### ❌ Public SG rules → usually NOT configurable

This is standard for every VPC.

### ❌ Private SG rules → usually template-based

### ❌ DNS settings → usually internal logic

### ✔ VPC CIDR, subnets, AZs → MUST be variables

Because environments differ.

### ✔ Database ingress → MUST be variable

Because DB port differs per project.

---

# 🧩 **data.tf — Constructing Names and Internal Variables**

Example:

```hcl
locals {
  public_sg_name   = "${var.project}-public-sg"
  private_sg_name  = "${var.project}-private-sg"
  database_sg_name = "${var.project}-database-sg"

  # Dynamic database ingress logic
  db_ingress = concat(
    [
      { rule = "self", source_security_group_id = null }
    ],
    var.db_custom_ingress_rules
  )
}
```

This file contains:

* naming logic
* tag logic
* internal-only variables
* computed lists for security group rules

Users (composition layer) should NOT see this complexity.

---

# 🧩 **variables.tf — What Infra Module Expects**

This file exposes only what the *client* must configure:

```
variable "project" {}
variable "region" {}

variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "database_subnets" {}

variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "enable_flow_log" {}
variable "flow_log_destination_arn" {}

variable "db_custom_ingress_rules" {
  type = list(object({
    rule                     = string
    source_security_group_id = string
  }))
}
```

Everything else is handled internally.

---

# 🧩 **outputs.tf — Bubbled Upwards**

We expose:

* VPC ID
* Subnet IDs
* SG IDs
* Route table IDs

Example:

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_sg_id" {
  value = module.public_sg.security_group_id
}

output "private_sg_id" {
  value = module.private_sg.security_group_id
}

output "database_sg_id" {
  value = module.database_sg.security_group_id
}
```

These outputs go to:

* composition layer
* application modules (ECS/EKS/EC2/etc.)

---

# 🎉 **Summary of Step 2 (VPC Infra Module)**

### ✔ The infra module acts as a facade

Hides 1000 lines of internal VPC logic.

### ✔ It reuses security group module 3 times

* Public SG
* Private SG
* Database SG

### ✔ Uses computed ingress rules

Because SGs may not exist at plan-time.

### ✔ Uses locals to hide complexity

Internal naming, subnet tagging, SG concatenation.

### ✔ Bubbles up only necessary outputs

Simplifies the composition layer.

### ✔ This is not beginner Terraform






This is the continuation of your 3-layer Terraform architecture:
**resource modules → infra modules → composition layer**.

---

# ✅ **CHAPTER 4 — Creating a Full VPC (Public, Private, Database Subnets) Using the Three-Layer Terraform Architecture**

Now that the Terraform **remote backend** is finished, we move to the **core infrastructure** of any AWS deployment:

### ✔ VPC

### ✔ public subnets

### ✔ private subnets

### ✔ database subnets

### ✔ security groups

We are now building **the networking layer** where services like ECS, EC2, and EKS worker nodes will live.

This chapter uses the **same 3-layer modular architecture** you've been practicing:

```
composition/
infra/
resource-modules/
```

---

# 🎯 **Why We Create VPC Before ECS, EKS, RDS, etc.**

Every AWS compute platform requires a VPC with subnets:

* **EKS worker nodes** require **private subnets**
* **ALB** requires **public subnets**
* **RDS** must reside in **database subnets**
* **EC2** instances often use **private subnets** and NAT
* **ECS Fargate** needs properly tagged subnets

Therefore:

> VPC with 3-tier subnet structure must be created before any real application or compute resources.

---

# 🚀 **Chapter 4 Architecture Overview**

Nothing changes in the architecture structure:

```
resource-modules/
infra/
composition/
```

We continue using:

* **resource modules** → raw AWS resource definitions
* **infra modules** → facades that wrap multiple modules
* **composition layer** → the environment entry point (prod, dev)

---

# 🧩 **STEP 1 — Replicate Remote Modules for VPC + Security Group (Local Resource Modules)**

You already did this.

We created:

```
resource-modules/
  network/
    vpc/             ← 1000+ lines, copied exactly from terraform-aws-modules/vpc/aws  
    security-group/   ← 400+ lines, copied exactly from terraform-aws-modules/security-group/aws 
```

These modules contain:

### VPC module includes:

* VPC
* IGW
* NAT gateway(s)
* public/private/db subnets
* route tables
* subnet tagging
* optional flow logs
* optional endpoints

### Security Group module includes:

* dynamic ingress rules
* dynamic egress rules
* computed ingress rules
* IPv4 vs IPv6 logic
* many argument combinations
* reusable patterns

Your instructor emphasizes:

> “These modules are far too advanced to rewrite. You must copy/paste them exactly.”

So Step 1 is only **copy and organize**.

---

# 🧩 **STEP 2 — Create the Infra Module (VPC Facade) under `infra/vpc`**

This is where the real architecture happens.

We create a **new folder**:

```
infra/vpc/
  main.tf
  variables.tf
  outputs.tf
  data.tf
```

Your instructor stresses:

> “This is NOT the same as the previous `infra/remote-backend`.
> That folder was only for Terraform backend setup.
> This new folder is for REAL infrastructure.”

This new module:

### ✔ Wraps the VPC resource module

### ✔ Wraps the Security Group resource module (multiple times)

### ✔ Combines them into a single 3-tier VPC system

---

# 🧠 **Why This Infra Module Is a Facade**

The VPC resource module creates:

* VPC
* all subnets
* gateways
* routing
* subnet tags

But **VPC alone does not create security groups**.

Your application needs:

* public SG
* private SG
* database SG

So the infra module:

* calls **one** VPC module
* calls the **security-group module** 3 times
* abstracts all complexity
* outputs a clean interface to the composition layer

Meaning:

The **composition layer** doesn't know anything about:

* NAT gateways
* route tables
* CIDRs
* SG ingress rules
* subnet IDs

It only calls:

```hcl
module "vpc" {
  source = "../../infra/vpc"
}
```

This is the entire point of 3-layer Terraform.

---

# 🧩 **Inside `infra/vpc/main.tf`**

### It calls the VPC module:

```hcl
module "vpc" {
  source = "../../resource-modules/network/vpc"

  name                 = var.name
  cidr                 = var.cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  database_subnets     = var.database_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log = var.enable_flow_log
  flow_log_destination_arn = var.flow_log_destination_arn

  tags = var.tags
}
```

---

# 🧩 **It creates 3 Security Groups**

### 1️⃣ Public Security Group

Logic:

* Allow HTTP/HTTPS from the Internet
* Allow everything outbound

### 2️⃣ Private Security Group

Logic:

* Allow inbound only from the public SG
* Use **computed_ingress_with_source_security_group_id**
* Why?

  * Because at plan time, the public SG may not exist yet
  * Terraform resolves it dynamically

### 3️⃣ Database Security Group

Logic:

* Allow rules based on DB type (MySQL/PG/etc.)
* Use **locals** to merge internal defaults + user-provided rules
* Allow extension via `db_custom_ingress_rules`

---

# 🧩 **data.tf — Internal Computed Variables**

Contains naming, tags, lists, and DB ingress logic:

```hcl
locals {
  public_sg_name   = "${var.project}-public"
  private_sg_name  = "${var.project}-private"
  database_sg_name = "${var.project}-db"

  db_ingress = concat(
    [
      { rule = "self", source_security_group_id = null }
    ],
    var.db_custom_ingress_rules
  )
}
```

### Why locals?

* Hide complexity
* Keep main.tf readable
* Prevent exporting internal logic

---

# 🧩 **variables.tf — What the Composition Layer Must Provide**

These include:

* region
* project name
* VPC CIDR
* AZs
* subnet CIDRs
* optional DB-port rules
* optional flow log settings

Your instructor notes:

> "Expose only what the client should configure. Everything else stays internal."

---

# 🧩 **outputs.tf — Expose Only Useful Outputs**

These include:

* vpc_id
* subnet IDs
* the 3 SG IDs
* route table IDs

The composition layer will use these outputs to build:

* ALBs
* EKS nodes
* ECS services
* EC2 instances
* RDS

---

# 🧠 **Separation between Old Infra (remote backend) and New Infra (VPC)**

Your instructor is very clear:

> “remote-backend/ is not REAL infra.
> It is just Terraform-required setup.
> VPC infra is ACTUAL infrastructure.
> Do not mix the folders.”

So you now have:

```
infra/
  remote-backend/   ← auxiliary Terraform setup
  vpc/              ← real infrastructure
```

Very important for large projects.

---

# 🏁 **STEP 3 — Composition Layer for VPC**

Your instructor ends the chapter by saying:

> “Next step: composition layer for VPC.”

Meaning:

```
composition/
  vpc/
    ap-northeast-1/
      prod/
        main.tf
        variables.tf
        terraform.tfvars
```

Where you call:

```hcl
module "vpc" {
  source = "../../../infra/vpc"

  project           = var.project
  region            = var.region
  cidr              = var.cidr
  azs               = var.azs
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  database_subnets  = var.database_subnets
}
```

This is Chapter 4’s final outcome.








## 0. Prerequisites


## 1. Folder Structure

Create this structure:

```text
terraform-3layer-aws/
├─ resource-modules/
│  ├─ storage/
│  │  └─ s3-backend/
│  ├─ database/
│  │  └─ dynamodb-backend/
│  ├─ security/
│  │  └─ kms-backend/
│  └─ network/
│     └─ vpc-basic/
├─ infra/
│  ├─ remote-backend/
│  └─ vpc/
└─ composition/
   ├─ remote-backend/
   │  └─ us-east-2/
   │     └─ prod/
   └─ vpc/
      └─ us-east-2/
         └─ prod/
```

We’ll fill these folders with `.tf` files now.

---

## 2. Resource Modules (Lowest Layer)



### 2.1 S3 Backend Bucket Module

**Path:** `resource-modules/storage/s3-backend/main.tf`

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
```

**Path:** `resource-modules/storage/s3-backend/variables.tf`

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy bucket"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
```

**Path:** `resource-modules/storage/s3-backend/outputs.tf`

```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

**What this does:**
Creates an S3 bucket with:

* versioning enabled
* KMS encryption
* public access blocked

This will be used for **Terraform state**.

---

### 2.2 DynamoDB Backend Table Module

**Path:** `resource-modules/database/dynamodb-backend/main.tf`

```hcl
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

**Path:** `resource-modules/database/dynamodb-backend/variables.tf`

```hcl
variable "table_name" {
  description = "Name of the DynamoDB table to use for state locking"
  type        = string
}
```

**Path:** `resource-modules/database/dynamodb-backend/outputs.tf`

```hcl
output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}
```

**What this does:**
Creates a DynamoDB table with a `LockID` key, used by Terraform for **state locking**.

---

### 2.3 KMS Key Module

**Path:** `resource-modules/security/kms-backend/main.tf`

```hcl
resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
```

**Path:** `resource-modules/security/kms-backend/variables.tf`

```hcl
variable "description" {
  description = "Description for the KMS key"
  type        = string
}
```

**Path:** `resource-modules/security/kms-backend/outputs.tf`

```hcl
output "key_id" {
  value = aws_kms_key.this.key_id
}

output "key_arn" {
  value = aws_kms_key.this.arn
}
```

**What this does:**
Creates a KMS key with rotation enabled. We will use it to encrypt the S3 bucket.

---

### 2.4 Basic VPC Module (VPC + 3 Subnets + IGW + Public RT)

**Path:** `resource-modules/network/vpc-basic/main.tf`

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-vpc" }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-igw" }
  )
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.az

  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-public-subnet" }
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-private-subnet" }
  )
}

resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidr
  availability_zone = var.az

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-database-subnet" }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.project}-${var.environment}-public-rt" }
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**Path:** `resource-modules/network/vpc-basic/variables.tf`

```hcl
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "database_subnet_cidr" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

**Path:** `resource-modules/network/vpc-basic/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "database_subnet_id" {
  value = aws_subnet.database.id
}
```

**What this does:**
Creates:

* 1 VPC
* 1 public subnet (with IGW + route table)
* 1 private subnet
* 1 database subnet

You can later extend this to multi-AZ, NAT gateway, etc.

---

## 3. Infra Layer – Remote Backend Facade

This layer **wraps the three backend-related resource modules** and exposes one simple module.

**Path:** `infra/remote-backend/variables.tf`

```hcl
variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}
```

**Path:** `infra/remote-backend/main.tf`

```hcl
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

locals {
  bucket_name = "${var.project}-${var.environment}-tfstate-${random_integer.suffix.result}"
  table_name  = "${var.project}-${var.environment}-tf-lock"
}

module "kms_backend" {
  source      = "../../resource-modules/security/kms-backend"
  description = "KMS key for Terraform state encryption"
}

module "s3_backend" {
  source        = "../../resource-modules/storage/s3-backend"
  bucket_name   = local.bucket_name
  force_destroy = false
  kms_key_arn   = module.kms_backend.key_arn
}

module "dynamodb_backend" {
  source     = "../../resource-modules/database/dynamodb-backend"
  table_name = local.table_name
}
```

**Path:** `infra/remote-backend/outputs.tf`

```hcl
output "backend_bucket_name" {
  value = module.s3_backend.bucket_name
}

output "backend_dynamodb_table_name" {
  value = module.dynamodb_backend.table_name
}

output "backend_kms_key_arn" {
  value = module.kms_backend.key_arn
}
```

**What this does (facade idea):**

* Generates a unique bucket name using `random_integer`
* Creates:

  * KMS key
  * S3 bucket (encrypted with KMS)
  * DynamoDB lock table
* Exposes only:

  * bucket name
  * table name
  * kms key ARN

The **composition layer only calls this module**, not the raw resources.

---

## 4. Composition – Remote Backend (us-east-2 / prod)

This is your **entry point** for creating the backend in `us-east-2`.

**Path:** `composition/remote-backend/us-east-2/prod/main.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # IMPORTANT: First run: keep backend local.
  # After S3/DynamoDB are created, you can configure backend "s3" here if you want.
  # backend "s3" {
  #   bucket         = "REPLACE_WITH_CREATED_BUCKET"
  #   key            = "tf/backend/us-east-2/prod/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "REPLACE_WITH_CREATED_TABLE"
  # }
}

provider "aws" {
  region = var.region
}

module "remote_backend" {
  source      = "../../../../../infra/remote-backend"
  project     = var.project
  environment = var.environment
  region      = var.region
}

output "backend_bucket_name" {
  value = module.remote_backend.backend_bucket_name
}

output "backend_dynamodb_table_name" {
  value = module.remote_backend.backend_dynamodb_table_name
}

output "backend_kms_key_arn" {
  value = module.remote_backend.backend_kms_key_arn
}
```

**Path:** `composition/remote-backend/us-east-2/prod/variables.tf`

```hcl
variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region"
}
```

**Path:** `composition/remote-backend/us-east-2/prod/terraform.tfvars`

```hcl
project     = "my-demo"
environment = "prod"
region      = "us-east-2"
```

**Explanation of this step:**

* This is the root where you run `terraform init` and `terraform apply`.
* It defines:

  * Terraform version and providers (`aws`, `random`)
  * AWS provider configured to `us-east-2`
  * Calls the infra module `infra/remote-backend`
* First run: backend block is commented, so Terraform uses **local state**.
* After it creates S3 & DynamoDB, you can enable the `backend "s3"` block (optional).

---

## 5. Run the Remote Backend Stack

From the project root:

```bash
cd composition/remote-backend/us-east-2/prod

terraform init
terraform plan
terraform apply
```

You should see resources:

* KMS key
* S3 bucket (name includes random number)
* DynamoDB table

The outputs should print:

* backend_bucket_name
* backend_dynamodb_table_name
* backend_kms_key_arn

These are your **real backend components** in `us-east-2`.

If you want, you can now edit the `backend "s3"` block in this or another stack to use:

```hcl
backend "s3" {
  bucket         = "<value of backend_bucket_name>"
  key            = "tf/backend/us-east-2/prod/terraform.tfstate"
  region         = "us-east-2"
  dynamodb_table = "<value of backend_dynamodb_table_name>"
}
```

Then run `terraform init -migrate-state` to migrate local → S3.
(That’s an advanced step; not required right now.)

---

## 6. Infra – VPC Facade

Now we build the **VPC infra module** which wraps the basic VPC resource module.

**Path:** `infra/vpc/locals.tf`

```hcl
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
```

**Path:** `infra/vpc/variables.tf`

```hcl
variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }

variable "cidr_block"  { type = string }
variable "az"          { type = string }

variable "public_subnet_cidr"   { type = string }
variable "private_subnet_cidr"  { type = string }
variable "database_subnet_cidr" { type = string }
```

**Path:** `infra/vpc/main.tf`

```hcl
module "vpc_basic" {
  source = "../../resource-modules/network/vpc-basic"

  project              = var.project
  environment          = var.environment
  cidr_block           = var.cidr_block
  az                   = var.az
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  tags                 = local.common_tags
}
```

**Path:** `infra/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value = module.vpc_basic.vpc_id
}

output "public_subnet_id" {
  value = module.vpc_basic.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc_basic.private_subnet_id
}

output "database_subnet_id" {
  value = module.vpc_basic.database_subnet_id
}
```

**Explanation:**

* This module **wraps** the `vpc-basic` resource module
* It doesn’t know about environments like “us-east-2/prod”; it just takes inputs
* It exposes clean outputs: VPC ID + subnet IDs
* Later you can add security groups, NAT, etc., here

---

## 7. Composition – VPC (us-east-2 / prod)

Now we create the VPC using the infra module.

**Path:** `composition/vpc/us-east-2/prod/main.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # OPTIONAL: once your backend S3 and DynamoDB exist, you can configure:
  # backend "s3" {
  #   bucket         = "YOUR_BACKEND_BUCKET"
  #   key            = "vpc/us-east-2/prod/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "YOUR_LOCK_TABLE"
  # }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../../../../infra/vpc"

  project              = var.project
  environment          = var.environment
  region               = var.region
  cidr_block           = var.cidr_block
  az                   = var.az
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "database_subnet_id" {
  value = module.vpc.database_subnet_id
}
```

**Path:** `composition/vpc/us-east-2/prod/variables.tf`

```hcl
variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }
variable "cidr_block"  { type = string }
variable "az"          { type = string }

variable "public_subnet_cidr"   { type = string }
variable "private_subnet_cidr"  { type = string }
variable "database_subnet_cidr" { type = string }
```

**Path:** `composition/vpc/us-east-2/prod/terraform.tfvars`

```hcl
project     = "my-demo"
environment = "prod"
region      = "us-east-2"

cidr_block  = "10.0.0.0/16"
az          = "us-east-2a"

public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
database_subnet_cidr = "10.0.3.0/24"
```

**Explanation:**

* This is your **entry point** for creating the VPC in `us-east-2`
* It defines provider `aws` with `region = var.region`
* It calls the **infra/vpc** module
* It passes in project, environment, CIDRs, AZ
* It outputs VPC ID + subnet IDs (so you can plug them into ECS/EKS/etc. later)

---

## 8. Run the VPC Stack

From project root:

```bash
cd composition/vpc/us-east-2/prod

terraform init
terraform plan
terraform apply
```

You should see:

* 1 VPC in `us-east-2`
* 1 public subnet in `us-east-2a` with IGW and route
* 1 private subnet
* 1 database subnet

Outputs:

* `vpc_id`
* `public_subnet_id`
* `private_subnet_id`
* `database_subnet_id`

---

## 9. How This Matches the 3-Layer Architecture From the Lecture

* **Resource modules**

  * `s3-backend`, `dynamodb-backend`, `kms-backend`, `vpc-basic`
  * Raw AWS resources, nothing about environments

* **Infra modules (facades)**

  * `infra/remote-backend`

    * bundles S3 + DynamoDB + KMS
  * `infra/vpc`

    * bundles VPC + subnets (later SGs)

* **Composition layer (environments)**

  * `composition/remote-backend/us-east-2/prod`
  * `composition/vpc/us-east-2/prod`
  * Each is an entry point for a specific env/region

This is the **same concept** as your chapter:
`resource → infra → composition`, just with shortened code so you can actually read and teach it.





