---
title: "terraform certification #4"
description: "Terraform Modules            1. What Problem Do Terraform Modules Solve?            Problem..."
published: 2025-12-18
source: "https://dev.to/jumptotech/terraform-certification-4-ejk"
tags: []
---

# terraform certification #4



# Terraform Modules 

## 1. What Problem Do Terraform Modules Solve?

### Problem in real organizations

In **mid to large companies**:

* Many teams (10, 50, 100+)
* Each team writes **their own Terraform code**
* All teams create **similar resources** (EC2, VPC, RDS, EKS)

### Result without modules

* Same EC2 code copied everywhere
* Hard to maintain
* No standards
* Security risks
* One change = update hundreds of files

---

## 2. DRY Principle (Foundation Concept)

**DRY = Don’t Repeat Yourself**

Meaning:

* Do not duplicate logic
* Write once, reuse everywhere

### Why DRY matters

* Smaller codebase
* Easier maintenance
* Fewer bugs
* Consistent behavior

Terraform Modules are **Terraform’s way to apply DRY**.

---

## 3. Problem Without Modules (Team-Based Example)

### Example: 10 Teams

Each team writes this:

```hcl
resource "aws_instance" "ec2" {
  ami           = "ami-123"
  instance_type = "t2.micro"
}
```

### Problems this causes

1. **Code repetition**

   * Same EC2 block copied everywhere

2. **Mass changes**

   * If AWS provider changes → all teams must update code

3. **No standardization**

   * Different AMIs
   * Different security groups
   * Different tagging standards

4. **Hard to manage**

   * No central control

5. **Hard for developers**

   * Everyone must understand low-level AWS details

---

## 4. Solution: Terraform Modules

### What is a Terraform Module?

A **module is a reusable Terraform template** that:

* Defines resources once
* Accepts inputs
* Can be reused by many teams

Think of a module as:

> “A reusable Terraform blueprint”

---

## 5. Centralized Template Approach (Best Practice)

### How organizations do it

* DevOps / Platform team creates:

  * EC2 module
  * VPC module
  * EKS module
* Stores them in:

  * GitHub
  * GitLab
  * Terraform Registry

### Teams only reference the module

Instead of writing full EC2 code, teams write:

```hcl
module "ec2" {
  source = "../modules/ec2"
}
```

That’s it.

---

## 6. Simple Module Structure (Mental Model)

### Folder structure

```
modules/
 └── ec2/
     ├── main.tf
     ├── variables.tf
     └── outputs.tf
```

### `main.tf` (inside module)

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

### `variables.tf`

```hcl
variable "ami" {}
variable "instance_type" {}
```

---

## 7. How Teams Use the Module

### Team’s Terraform code

```hcl
module "team1_ec2" {
  source         = "../modules/ec2"
  ami            = "ami-0abc"
  instance_type  = "t3.micro"
}
```

### Important point

* EC2 logic → inside module
* Team only passes values
* Team does NOT care about implementation details

---

## 8. What Happens During `terraform plan`?

* Terraform reads the module
* Expands it into real resources
* Creates EC2 using module logic
* Team never sees internal complexity



> EC2 is created even though EC2 code is not written in the root file.

---

## 9. Multiple Modules in One Project (Real-World)

A real project may use:

```hcl
module "vpc" {
  source = "../modules/vpc"
}

module "ec2" {
  source = "../modules/ec2"
}

module "rds" {
  source = "../modules/rds"
}
```

### Benefits

* Clean root code
* Easy to understand
* Easy to scale
* Easy onboarding for new teams

---

## 10. Public Modules (Terraform Registry)

Terraform provides **ready-made modules** at:
👉 **registry.terraform.io**

Popular modules:

* VPC
* IAM
* EKS
* RDS

### Example: EKS

Without module:

* You write:

  * IAM roles
  * Node groups
  * Security groups
  * Networking
  * Policies

With module:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
}
```

Thousands of lines of code reused safely.

---

## 11. Why Modules Are Critical in Production

### Key Benefits

* DRY (no duplication)
* Centralized control
* Security standards enforced
* Easy upgrades
* Faster infrastructure delivery
* Cleaner Terraform code

---

## 12. Interview-Ready One-Line Answer

> **Terraform modules allow teams to reuse standardized infrastructure code, reduce duplication, enforce best practices, and simplify infrastructure management across multiple projects and teams.**

---

## 13. When You Should Use Modules

Use modules when:

* Same resource used multiple times
* Multiple environments (dev/stage/prod)
* Multiple teams
* Production infrastructure

Avoid modules only for:

* Very small one-time demos









# Terraform Modules – Practical Usage with Registry Modules

## 1. Goal of This Practical

**Requirement:**

* Create **EC2 instance**
* Create **Security Group**
* Do it **quickly**
* Avoid writing Terraform code from scratch

**Solution:**
Use a **ready-made Terraform module** from the **Terraform Registry**.

---

## 2. Why Use Ready-Made Modules First?

Before creating **custom modules**, every Terraform engineer must understand:

* How modules are **used**
* How Terraform **downloads** them
* How Terraform **expands** them into real resources
* Where module code is stored locally

This is exactly what this practical demonstrates.

---

## 3. Terraform Registry Overview

Website:
👉 **registry.terraform.io**

### What you’ll find there:

* Hundreds of **production-grade modules**
* Modules for:

  * EC2
  * VPC
  * IAM
  * EKS
  * RDS
  * KMS
* Download counts show **real-world usage**

Example:

* IAM module → **100M+ downloads**
* EC2 module → **30M+ downloads**

This confirms:

> Terraform modules are heavily used in real organizations.

---

## 4. Choosing the Right Module (Important Rule)

**Do NOT blindly trust every module.**

Best practices:

* Prefer:

  * High download count
  * Active contributors
  * Good documentation
  * GitHub source available
* Avoid:

  * Unknown authors
  * Poor docs
  * Low adoption

---

## 5. Selected Module for This Demo

**Module chosen:**

```
terraform-aws-modules/ec2-instance/aws
```

Why?

* Very popular
* Actively maintained
* Extensive documentation
* Supports:

  * Single EC2
  * Multiple EC2
  * Spot instances

---

## 6. Project Setup (Clean Slate)

### Create file

```bash
ec2.tf
```

### Minimal module usage

```hcl
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"
}
```

Key points:

* `source` → where module lives
* `version` → lock module version (VERY important in production)

---

## 7. Initialize Terraform

```bash
terraform init
```

### What happens here?

* Terraform:

  * Initializes backend
  * Initializes provider
  * **Downloads module code**
* Module code is pulled from:

  * registry.terraform.io
  * stored locally

This is the **first major module workflow step**.

---

## 8. Terraform Plan – First Error (Very Important Learning)

```bash
terraform plan
```

### Error:

> Multiple EC2 instances matched. Use additional constraints…

### Meaning:

* Module needs **subnet_id**
* Terraform doesn’t know **where** to launch EC2

---

## 9. Fixing the Error – Provide Subnet ID

### Why subnet_id is needed

* EC2 **must** be launched in a subnet
* Module does NOT auto-select subnet in this version

### Get subnet ID

AWS Console:

```
VPC → Subnets → Copy subnet-id
```

### Update module

```hcl
module "ec2_instance" {
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "~> 5.0"
  subnet_id  = "subnet-xxxxxxxx"
}
```

---

## 10. Terraform Plan (Successful)

```bash
terraform plan
```

### Terraform will show:

Resources to be created:

1. EC2 instance
2. Security group
3. Security group rules

**Important:**
You never wrote EC2 or SG resources yourself — module did it.

---

## 11. Terraform Apply

```bash
terraform apply -auto-approve
```

### Result:

* EC2 instance created
* Security group created
* SG attached to EC2

---

## 12. Verify in AWS Console

Go to:

```
EC2 → Instances
```

You will see:

* EC2 instance running
* Security group attached
* Default outbound rules created

---

## 13. Where Is the Actual EC2 Code?

### Local filesystem

```
.terraform/
 └── modules/
     └── ec2_instance/
         └── main.tf
```

### Open `main.tf`

* ~800+ lines of code
* Handles:

  * Single EC2
  * Multiple EC2
  * Spot instances
  * Networking
  * Tags
  * Volumes
  * Advanced options

This proves:

> Registry modules are **production-grade**, not toy examples.

---

## 14. Registry Also Provides Examples

On registry page you’ll find:

* Single EC2 example
* Multiple EC2 example
* Spot instance example

You do **NOT** need GitHub for basic usage — registry mirrors examples.

---

## 15. Cleanup (VERY IMPORTANT)

Always destroy resources to avoid AWS charges:

```bash
terraform destroy -auto-approve
```

---

## 16. Why This Topic Is Extremely Important

### Real World

* All mid & large companies use modules
* Platform teams build modules
* Application teams consume modules

### Interviews

Common questions:

* What is a Terraform module?
* How do you use modules?
* Difference between root module and child module?
* Where are modules stored locally?

### Terraform Professional Certification

* **Scenario-based**
* **Practical**
* Modules are heavily tested
* Requires deep understanding

---

## 17. One-Line Interview Answer

> Terraform modules allow reusable, standardized infrastructure definitions that simplify deployment, enforce best practices, and scale across multiple teams and environments.










# Terraform Modules — Choosing the Right Module & Creating Your Own

---

## PART 1: How to Choose the Right Terraform Module

### Why This Matters

Terraform Registry has **hundreds of modules** for the same service (EC2, IAM, VPC, etc.).
Choosing the **wrong module** can lead to:

* Security risks
* Unmaintained code
* Breaking changes
* Operational failures

---

## 1. Check Total Downloads (First Filter)

**Why**

* High downloads = real-world usage
* Early signal of trust & stability

**Example**

* EC2 module with **14+ million downloads** → strong signal
* Module with **2K downloads** → risky

**Rule**

> Always prefer modules with high adoption unless you have strong reasons not to.

---

## 2. Check the GitHub Repository (Critical Step)

Every serious module links to GitHub. Inspect it.

### What to check:

#### a) Contributors

* ❌ Single contributor → risky
* ✅ Multiple contributors (20–50+) → healthy

Why:

* Single maintainer may abandon project
* Multiple contributors = continuity

---

#### b) Issues (Open vs Closed)

Look at:

* Open issues count
* Closed issues count

**Good sign**

* Few open issues
* Many closed issues

Example:

* 3 open / 187 closed → very healthy

---

## 3. Avoid Single-Maintainer Modules

**Why**

* Providers evolve (AWS, Azure)
* Arguments change
* Bugs appear

**Risk**

* Module may stop working
* No updates
* No security patches

**Rule**

> Avoid production use of modules maintained by one person.

---

## 4. Check Documentation Quality

Well-maintained modules always have:

* Clear README
* Usage examples
* Input/output documentation
* Multiple examples (single EC2, multiple EC2, spot, etc.)

**Red flag**

* Poor README
* No examples
* Vague instructions

---

## 5. Check Version History

**Why**

* Active modules release versions regularly
* Version history = maintenance history

### Compare:

* ✅ Many versions (v1.x → v5.x)
* ❌ Only v1.0.0

**Rule**

> No version evolution = module likely abandoned.

---

## 6. Inspect Code Quality (Optional but Powerful)

Open `main.tf`:

* Clean structure
* Logical grouping
* Variables instead of hardcoding
* Comments where needed

Well-written modules look **professional**, not experimental.

---

## 7. Check Community Signals (Stars & Forks)

On GitHub:

* ⭐ Stars → popularity
* 🍴 Forks → adoption & contribution

**Rule**

> Higher stars + forks = stronger community trust.

---

## 8. HashiCorp Partner Modules (Trusted Source)

Some modules are maintained by **HashiCorp Partners**:

* Partner badge in registry
* Higher trust
* Enterprise usage

However:

* Partner badge ≠ only good modules
* Many **non-partner modules** (like terraform-aws-modules) are industry standard

---

## 9. Security Warning (Very Important)

❌ Never use random modules blindly
❌ Never skip reading source code

**Why**

* Modules can contain malicious logic
* Sensitive data leakage risk
* Backdoor provisioning

**Rule**

> If unsure → read the code or don’t use the module.

---

## 10. What Do Real Organizations Do?

Most real organizations:

* **Do NOT rely on public modules directly**
* Fork public modules
* Modify heavily
* Maintain **private internal modules**
* Publish them in **private registries**

This ensures:

* Security
* Stability
* Customization

---

# PART 2: Designing Your Own Module Structure

---

## 1. Why Create Your Own Modules?

Organizations need:

* Custom standards
* Controlled updates
* Restricted inputs
* Consistent architecture

Hence, **internal modules** are preferred.

---

## 2. Base Folder Structure (Industry Standard)

```
kplabs-terraform-modules/
│
├── modules/
│   ├── ec2/
│   ├── vpc/
│   ├── sg/
│   └── iam/
│
└── teams/
    ├── team-a/
    └── team-b/
```

---

## 3. Purpose of Each Folder

### `modules/`

* Contains **reusable infrastructure logic**
* Written once
* Used by many teams

### `teams/`

* Environment / team-specific code
* Calls modules
* No resource logic here

---

## 4. How Teams Use Modules (Conceptual)

Example:

* Team A needs EC2 → calls EC2 module
* Team B needs SG → calls SG module

Teams **do not write resources directly**.

---

# PART 3: Creating Your First Custom EC2 Module

---

## 1. Modules Are NOT Complex

**Important clarity**

> A module is just normal Terraform code placed in a reusable folder.

No new syntax.
No extra complexity.

---

## 2. Creating EC2 Module

### Step 1: Go to module folder

```
modules/ec2/
```

### Step 2: Create `main.tf`

```hcl
resource "aws_instance" "this" {
  ami           = "ami-0abcdef"
  instance_type = "t2.micro"
}
```

That’s it.
This **is a valid Terraform module**.

---

## 3. Common Question: “Is This Too Small for a Module?”

**Answer: YES, it’s perfectly valid.**

Modules can be:

* 3 lines
* 30 lines
* 600+ lines

It depends on:

* Organizational needs
* Required flexibility

---

## 4. Why Public Modules Are Huge (600+ Lines)

Public modules:

* Support all possible options
* Support all organizations
* Cover every edge case

Example EC2 options:

* tags
* subnet_id
* user_data
* metadata_options
* maintenance_options
* spot instances

Internal modules:

* Only support **what you need**
* Smaller
* Easier to maintain

---

## 5. Key Design Principle

> Public modules = generic & flexible
> Internal modules = opinionated & minimal

---

## 6. What Comes Next

Next logical step:

* Call EC2 module from `teams/team-a`
* Pass inputs
* Understand module inputs & outputs

This will complete the **full module lifecycle**.

---

# Interview-Ready Summary (One Paragraph)

Terraform modules help standardize infrastructure, reduce duplication, enforce security and best practices, and allow teams to reuse infrastructure code efficiently. In production, organizations typically fork or create their own internal modules instead of relying directly on public registry modules, ensuring better control, stability, and security.











# Terraform Module Sources & Referencing (Complete Guide)

---

## PART 1: What Is a Module Source?

A **module source** tells Terraform **where the module code lives**.

Terraform supports **multiple source locations**, including:

1. **Terraform Registry**
2. **Local filesystem (local path)**
3. **Git repositories (GitHub, GitLab, Bitbucket)**
4. **HTTP URLs**
5. **S3 buckets**
6. **Private registries**

Regardless of source type:

* You **must** use a `module` block
* You **must** specify a `source` argument

---

## PART 2: Basic Module Syntax (Always the Same)

```hcl
module "ec2" {
  source = "LOCATION_OF_MODULE"
}
```

Only the **source value changes**, depending on where the module is stored.

---

## PART 3: Common Module Source Types (With Examples)

### 1. Terraform Registry (Most Common)

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.8.0"
}
```

Used when:

* Module is public
* Stable & well maintained
* You want version locking

---

### 2. Local Path (Most Common in Organizations)

**Rule (EXAM IMPORTANT):**

> Local paths **must start with `./` or `../`**

Example:

```hcl
module "ec2" {
  source = "../../modules/ec2"
}
```

Meaning:

* `../` → go up one directory
* `../../` → go up two directories

---

### 3. GitHub Repository

Correct format:

```hcl
module "ec2" {
  source = "github.com/zealvora/sample-kplabs-terraform-ec2-module"
}
```

❌ Incorrect:

```hcl
source = "https://github.com/..."
```

Why?

* Terraform expects **VCS shorthand**, not full HTTPS URL

---

### 4. Generic Git Repositories

```hcl
module "ec2" {
  source = "git::https://example.com/my-module.git"
}
```

Used for:

* GitLab
* Bitbucket
* Internal Git servers

---

### 5. HTTP URLs

```hcl
module "ec2" {
  source = "https://example.com/modules/ec2.zip"
}
```

Less common but supported.

---

### 6. S3 Buckets

```hcl
module "ec2" {
  source = "s3::https://s3.amazonaws.com/mybucket/ec2-module.zip"
}
```

Used in:

* Enterprises
* Air-gapped environments
* Internal artifact storage

---

## PART 4: How to Know the Correct Source Format?

**Answer: Terraform Documentation**

Terraform provides **exact syntax** for each source type:

* Local path
* Git
* Registry
* HTTP
* S3

📌 **Never guess source format — always check docs**

---

## PART 5: Using Version Constraint (VERY IMPORTANT)

### Why version matters

* Prevents breaking changes
* Ensures reproducibility
* Required for production & exams

### Example:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.8.0"
}
```

Meaning:

* Terraform pulls **exact version**
* Not latest
* Predictable behavior

---

## PART 6: Referencing Internal Modules Using Local Path

### Folder Structure Recap

```
kplabs-terraform-modules/
│
├── modules/
│   └── ec2/
│       └── main.tf
│
└── teams/
    └── team-a/
        └── module.tf
```

---

### `team-a/module.tf`

```hcl
module "ec2" {
  source = "../../modules/ec2"
}
```

Explanation:

* From `team-a`
* `../` → teams
* `../` → root
* `/modules/ec2` → module location

---

### Terraform Commands

```bash
terraform init
terraform plan
```

Terraform will:

* Load module
* Expand EC2 resource
* Create infrastructure

---

## PART 7: First Module Improvement – Hardcoded Values (MAJOR ISSUE)

### Problem

Module contains hardcoded values:

```hcl
resource "aws_instance" "this" {
  ami           = "ami-123"
  instance_type = "t2.micro"
}
```

### Result

* Developer **cannot override**
* Passing arguments fails:

```hcl
instance_type = "t2.large" ❌
```

Terraform error:

> argument not expected

---

### Rule (EXAM & REAL WORLD)

> **Hardcoded values inside modules are a big NO**

Especially for:

* Public modules
* Shared internal modules

---

## PART 8: Second Module Improvement – Provider Hardcoding (CRITICAL)

### Problematic Code

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Issues:

* Forces region
* Overrides caller intent
* Breaks multi-region usage

---

### What Happens If Caller Tries to Override?

Caller:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

Terraform behavior:

* **Module provider wins**
* Resource created in `us-east-1`
* No error shown
* Very dangerous in production

---

## PART 9: Correct Way to Handle Providers in Modules

### DO NOT define provider with region in module

### Instead use `required_providers`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5"
    }
  }
}
```

This means:

* Module declares compatibility
* Caller controls region
* Clean & predictable behavior

---

## PART 10: Key Improvements Summary (Must Remember)

### ❌ Avoid in modules

* Hardcoded AMI
* Hardcoded instance type
* Hardcoded region
* Provider blocks with region

### ✅ Use instead

* Variables
* Required providers
* Version constraints
* Inputs & outputs

---

## Interview & Exam One-Liners

### Module source

> Terraform module source defines where Terraform fetches module code from, such as registry, local path, Git, S3, or HTTP.

### Local path rule

> Local module sources must begin with `./` or `../`.

### Provider best practice

> Modules should declare required providers but not hardcode provider configuration like region.

### Why version block matters

> Module version ensures predictable and stable infrastructure behavior.









# Terraform Modules – Variables & Provider Best Practices

---

## PART 1: Why Variables Are Mandatory in Modules

### The Problem with Hard-Coding

When values are hard-coded inside a module:

* Users **cannot override** them
* Module becomes **rigid**
* Module becomes **unusable across teams**

Example (❌ bad):

```hcl
resource "aws_instance" "this" {
  ami           = "ami-0abc"
  instance_type = "t2.micro"
}
```

If a team needs:

* `m5.large`
* a different AMI
  → **Impossible to override**

---

## PART 2: Solution – Use Variables

### Convert Hard-Coded Values to Variables

Example (✅ good):

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

Now:

* Module becomes reusable
* Teams can pass values
* Same module works for many environments

---

## PART 3: Why Professional Modules Use Many Variables

If you open any **production-grade EC2 module**:

* Almost every argument is a variable
* Example:

  * `instance_type`
  * `ami`
  * `hibernation`
  * `user_data`
  * `tags`
  * `monitoring`

Reason:

> Thousands of users → thousands of requirements

---

## PART 4: Do ALL Values Need to Be Variables?

❌ No — not always.

### Best Practice Rule

* **Public modules** → maximum flexibility → many variables
* **Internal org modules** → only required flexibility

Use variables **intentionally**, not blindly.

---

## PART 5: Provider Hard-Coding Problem in Modules

### ❌ Bad Practice (Hard-coded provider)

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Why This Is Dangerous

* Caller **cannot control region**
* Even if caller sets `ap-south-1`
* Terraform silently uses **module’s provider**
* Leads to **unexpected resource creation**

---

## PART 6: Correct Way – `required_providers`

### ✅ Best Practice for Modules

Remove provider block
Add **required_providers** instead

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}
```

### What This Does

* Declares compatibility
* Prevents incompatible provider versions
* Allows caller to control region & credentials

---

## PART 7: Refactoring the EC2 Module (Practical)

### `modules/ec2/main.tf`

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

### Variable Declarations (same file for simplicity)

```hcl
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "region" {
  type = string
}
```

> In production, variables should be in `variables.tf`

---

## PART 8: What Happens After Adding Variables?

Run:

```bash
terraform plan
```

Terraform error:

```
Missing required argument
ami
instance_type
region
```

✅ This is expected
Now the **caller must pass values**

---

## PART 9: Team Overrides Values (Caller Side)

### `teams/team-a/module.tf`

```hcl
provider "aws" {
  region = "ap-south-1"
}

module "ec2" {
  source = "../../modules/ec2"

  ami           = "ami-123"
  instance_type = "t2.micro"
}
```

---

## PART 10: Verifying Overrides

Change value:

```hcl
instance_type = "t2.large"
```

Run:

```bash
terraform plan
```

✔ Output shows:

* `instance_type = t2.large`
* Module is now **fully flexible**

---

## PART 11: Key Improvements Achieved

### Before

* Hard-coded values
* Hard-coded region
* Inflexible module

### After

* Variables for customization
* Caller controls provider
* Reusable across teams
* Production-ready design

---

## PART 12: Critical Best-Practice Summary (EXAM + INTERVIEW)

### Variables

> Modules should avoid hard-coded values and use variables to allow caller customization.

### Provider

> Modules should declare `required_providers` and never hard-code provider configuration like region.

### Flexibility

> A good module balances flexibility with simplicity, based on organizational needs.

---

## Interview-Ready One-Liners

**Why variables in modules?**

> To make modules reusable and allow teams to override configuration values.

**Why not hard-code provider in module?**

> Because it prevents callers from controlling region and credentials.

**What does `required_providers` do?**

> It declares provider compatibility without enforcing configuration.










# Terraform Modules – Outputs, Root vs Child, Structure & Multiple Providers

---

## PART 1: Module Outputs – Why They Matter

### The Real Problem Modules Solve

In real organizations:

* You have **multiple modules**
* You have **multiple projects**
* Resources in one module often depend on resources from another module

To make this work, **data must flow between modules**.

That is exactly what **module outputs** enable.

---

## PART 2: What Is a Module Output?

A **module output**:

* Exposes values created **inside a child module**
* Allows the **root module** (or another module) to consume those values

Conceptually:

> Module outputs work exactly like Terraform outputs — just across module boundaries.

---

## PART 3: The Challenge Without Module Outputs

### Scenario

* EC2 instance is created **inside a module**
* Elastic IP is created **in the root module**
* EIP must attach to the EC2 instance

### Attempt (❌ does NOT work)

```hcl
instance = module.ec2.id
```

### Error

Terraform cannot access:

* Resource attributes inside a module
* Unless they are **explicitly exposed**

---

## PART 4: Solution – Define Outputs in the Child Module

### Child module (`modules/ec2/outputs.tf`)

```hcl
output "instance_id" {
  value = aws_instance.myec2.id
}
```

This exposes:

* EC2 instance ID
* To whoever calls this module

---

## PART 5: Using Module Outputs in Root Module

### Root module

```hcl
resource "aws_eip" "this" {
  instance = module.ec2.instance_id
}
```

Syntax to remember:

```
module.<module_name>.<output_name>
```

✔ Cross-module dependency now works
✔ Terraform understands ordering automatically

---

## PART 6: Why Module Outputs Are Critical in Production

Module outputs enable:

* Cross-project collaboration
* Clean separation of responsibilities
* Reusable infrastructure building blocks

Without outputs:

* Modules become isolated
* Infrastructure composition breaks

---

## PART 7: Root Module vs Child Module (EXAM FAVORITE)

### Root Module

* Entry point of Terraform execution
* The directory where you run:

  ```bash
  terraform init
  terraform apply
  ```
* Calls other modules

Example:

```hcl
module "ec2" {
  source = "../../modules/ec2"
}
```

---

### Child Module

* A module **called by another module**
* Contains reusable resource definitions

Example:

```
modules/ec2/
```

📌 **Every Terraform configuration has exactly one root module**
📌 **All other modules are child modules**

---

## PART 8: Standard Terraform Module Structure (Best Practice)

### Minimal Recommended Structure

```
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

### Why This Structure Matters

* Predictability
* Easier onboarding
* Faster debugging
* Industry standard

---

## PART 9: What Each File Does

### `main.tf`

* Core resource definitions

### `variables.tf`

* Input variables for customization

### `outputs.tf`

* Values exposed to callers

### `README.md`

* Documentation
* Usage examples
* Inputs & outputs explanation

---

## PART 10: Designing Modules for Real Organizations

❌ **Wrong approach**

* One giant module deploying everything

✅ **Correct approach**

* Small, focused modules per service

Example:

* IAM module
* Networking module
* Compute module
* Database module
* DNS module

Benefits:

* Reusability
* Independent updates
* Easier testing
* Cleaner architecture

---

## PART 11: Multiple Provider Configurations with Modules

### Default Behavior

* Child modules inherit the **default provider** from root
* Simple but limited

---

## PART 12: When You Need Multiple Providers

Example:

* `dev` resources → us-east-1
* `prod` resources → ap-south-1

Both resources live **inside the same module**.

Default inheritance is not enough.

---

## PART 13: Step 1 – Define Multiple Providers in Root Module

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}
```

---

## PART 14: Step 2 – Pass Providers to Module

```hcl
module "network" {
  source = "./modules/network"

  providers = {
    aws.prod = aws.mumbai
  }
}
```

📌 Provider aliases are **NOT inherited automatically**

---

## PART 15: Step 3 – Declare Configuration Aliases in Child Module

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws.prod]
    }
  }
}
```

---

## PART 16: Step 4 – Use Provider Meta-Argument in Resources

```hcl
resource "aws_security_group" "prod" {
  provider = aws.prod
}
```

Result:

* `dev` SG → us-east-1
* `prod` SG → ap-south-1

---

## PART 17: Critical Rules (MUST REMEMBER)

### Provider Passing Rules

* Default provider → inherited
* Aliased providers → must be passed explicitly

### Providers vs Resource Provider

* Resource:

  ```hcl
  provider = aws.prod
  ```
* Module:

  ```hcl
  providers = { aws.prod = aws.mumbai }
  ```

Module uses a **map** because:

* It may accept multiple providers

---

## PART 18: Interview & Exam One-Liners

**What is a module output?**

> A module output exposes values from a child module so other modules or the root module can consume them.

**What is a root module?**

> The root module is the main working directory where Terraform is executed.

**Are provider aliases inherited by child modules?**

> No, provider aliases must be explicitly passed to child modules.

**Why follow standard module structure?**

> It improves readability, reusability, and maintainability.








# PART 1: Publishing a Module to Terraform Registry (Theory)

## 1. What Is Terraform Registry?

Terraform Registry is a **central place to discover and share Terraform modules**.

It provides:

* Public modules for many providers (AWS, Azure, GCP, etc.)
* Versioning
* Auto-generated documentation
* Examples and README rendering
* Source code links (usually GitHub)

---

## 2. Who Can Publish Modules?

> **Anyone can publish a public module** to Terraform Registry.

Important notes:

* Registry authentication is done via **GitHub**
* Modules must be **public repositories**
* Private repos cannot be published to the **public registry**

---

## 3. High-Level Publishing Flow

1. Create a **public GitHub repository**
2. Follow **naming conventions**
3. Follow **standard module structure**
4. Add **semantic version tags**
5. Sign in to Terraform Registry with GitHub
6. Publish module

---

## 4. Mandatory Requirements for Publishing (EXAM IMPORTANT)

### 1. GitHub (Mandatory)

* Module **must be hosted on GitHub**
* Repository **must be public**

---

### 2. Repository Naming Convention (VERY IMPORTANT)

Format:

```
terraform-<PROVIDER>-<NAME>
```

Examples:

* `terraform-aws-vpc`
* `terraform-aws-eks`
* `terraform-aws-security-group`

❌ Invalid:

* `aws-vpc`
* `my-terraform-module`

---

### 3. Repository Description

* GitHub repository description is used as:

  * **Short description** in Terraform Registry

---

### 4. Semantic Version Tags (X.Y.Z)

Terraform Registry uses **Git tags** for versions.

Valid examples:

* `v1.0.0`
* `1.2.3`
* `0.9.2`

❌ Invalid:

* `version1`
* `release-final`

Registry reads **tags**, not branches.

---

### 5. Standard Module Structure (Mandatory)

Terraform strongly recommends a **standard module layout**.

---

## 5. Standard Module Structure (Best Practice)

### Minimal Module Structure

```
.
├── README.md
├── main.tf
├── variables.tf
└── outputs.tf
```

This is the **minimum requirement** for reusable modules.

---

### Complete Module Structure

```
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── modules/
│   └── nested-module/
├── examples/
│   └── basic/
```

Used for:

* Large modules
* Enterprise modules
* Public reusable modules

---

## 6. Why Standard Structure Matters

* Easier onboarding
* Predictable layout
* Easier reviews
* Better documentation
* Required for registry publishing

---

## 7. Real-World Module Design (Important Best Practice)

❌ **Bad approach**

* One huge module for everything

✅ **Correct approach**

* Small, focused modules per service

Example:

* IAM module
* VPC module
* Compute (EC2) module
* Database module
* DNS module

This allows:

* Reuse
* Independent evolution
* Easier maintenance

---

## 8. Exam Summary (Publishing Modules)

You must remember:

* GitHub public repo required
* `terraform-<provider>-<name>` naming
* Semantic version tags (X.Y.Z)
* Standard module structure
* README is required

---

# PART 2: Terraform Workspaces (Theory + Practical)

---

## 1. What Is a Terraform Workspace?

Terraform Workspace allows:

* **Multiple state files**
* **Single Terraform configuration**
* **Multiple environments**

Think of it as:

> Same code, different environments, separate states

---

## 2. Problem Without Workspaces

Without workspaces:

* You must duplicate code for:

  * dev
  * prod
  * staging
* Risk of inconsistency
* More maintenance

---

## 3. What Workspaces Solve

With workspaces:

* One configuration
* Multiple environments
* Each workspace has **its own state file**

Example:

* `dev` → dev.tfstate
* `prod` → prod.tfstate

---

## 4. Workspace Concept Diagram (Mental Model)

```
Same Terraform Code
        |
   Terraform Workspace
        |
   -------------------
   |       |        |
 default   dev     prod
 state     state    state
```

---

## 5. Workspace Commands (EXAM IMPORTANT)

### List workspaces

```bash
terraform workspace list
```

### Show current workspace

```bash
terraform workspace show
```

### Create workspace

```bash
terraform workspace new dev
terraform workspace new prod
```

### Switch workspace

```bash
terraform workspace select dev
terraform workspace select prod
```

---

## 6. Workspace State Storage

Terraform creates:

```
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── prod/
│   └── terraform.tfstate
```

Default workspace:

* Uses `terraform.tfstate` in root directory

---

## 7. Key Workspace Behavior (VERY IMPORTANT)

* Each workspace:

  * Has **separate state**
  * Does NOT know about resources in other workspaces
* Switching workspace changes:

  * Which state file Terraform uses

---

## 8. Workspace + Environment-Specific Configuration

### Real Requirement

* Dev → small instance
* Prod → large instance
* Same code

---

## 9. Using `terraform.workspace` with `locals`

### Example Code

```hcl
locals {
  instance_type = {
    default = "t2.nano"
    dev     = "t2.micro"
    prod    = "m5.large"
  }
}
```

### Use in Resource

```hcl
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = local.instance_type[terraform.workspace]
}
```

---

## 10. Result

| Workspace | Instance Type |
| --------- | ------------- |
| default   | t2.nano       |
| dev       | t2.micro      |
| prod      | m5.large      |

Same code. Different environments.

---

## 11. Advantages of Workspaces

* No code duplication
* Clean environment separation
* Easier management for small/medium setups
* Fast experimentation

---

## 12. Important Limitations (Interview Point)

Workspaces are **not recommended** for:

* Large enterprises
* Strong isolation needs
* Separate AWS accounts

In such cases:

* Use separate directories
* Use separate backends
* Use separate pipelines

---

## 13. Exam & Interview One-Liners

**What is Terraform Workspace?**

> A Terraform feature that allows managing multiple state files for the same configuration.

**Does each workspace have its own state file?**

> Yes, each workspace has a separate state file.

**How do you access current workspace name?**

> `terraform.workspace`

**Where are workspace state files stored?**

> In `terraform.tfstate.d/<workspace>/`


