---
title: "Terraform Project: Simple EC2 + Security Group"
description: "📁 Project Structure      terraform-project/ │── main.tf │── variables.tf │──..."
published: 2025-12-04
source: "https://dev.to/jumptotech/terraform-project-simple-ec2-security-group-2bj0"
tags: []
---

# Terraform Project: Simple EC2 + Security Group







![Image](https://www.tecracer.com/blog/img/2023/04/security-group-diagram-from-terraform-result.png?utm_source=chatgpt.com)

![Image](https://miro.medium.com/1%2AmTZdwo3YM6NO-cdk2b_dNA.jpeg?utm_source=chatgpt.com)

---

# 📁 **Project Structure**

```
terraform-project/
│── main.tf
│── variables.tf
│── outputs.tf
│── providers.tf
│── terraform.tfvars
│── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

---

# 1️⃣ **providers.tf**

Defines AWS provider + region.

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# 2️⃣ **variables.tf**

All input variables.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Tag for resources"
  type        = string
  default     = "tf-demo"
}
```

---

# 3️⃣ **main.tf**

Calls module + passes variables.

```hcl
module "ec2_demo" {
  source        = "./modules/ec2"
  instance_type = var.instance_type
  project_name  = var.project_name
}
```

---

# 4️⃣ **outputs.tf**

```hcl
output "ec2_public_ip" {
  description = "Public IP of EC2"
  value       = module.ec2_demo.public_ip
}

output "ec2_id" {
  description = "EC2 Instance ID"
  value       = module.ec2_demo.instance_id
}
```

---

# 5️⃣ **terraform.tfvars** (optional inputs)

```hcl
aws_region     = "us-east-2"
instance_type  = "t2.micro"
project_name   = "students-demo"
```

---

# 📦 **MODULE: modules/ec2/main.tf**

This module creates:

* Security group
* EC2 instance
* Tags

```hcl
resource "aws_security_group" "demo_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH"
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "demo" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 us-east-2
  instance_type = var.instance_type
  security_groups = [aws_security_group.demo_sg.name]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
```

---

# 📦 **MODULE: modules/ec2/variables.tf**

```hcl
variable "instance_type" {
  type = string
}

variable "project_name" {
  type = string
}
```

---

# 📦 **MODULE: modules/ec2/outputs.tf**

```hcl
output "public_ip" {
  value = aws_instance.demo.public_ip
}

output "instance_id" {
  value = aws_instance.demo.id
}
```

---

# ▶️ **How to Run (Teaching Steps)**

### 1. Initialize Terraform

```
terraform init
```

### 2. Validate configuration

```
terraform validate
```

### 3. Show what will be created

```
terraform plan
```

### 4. Create resources

```
terraform apply -auto-approve
```

### 5. After EC2 is created

```
terraform output
```

### 6. Destroy environment

```
terraform destroy -auto-approve
```

---

# 🎓 **What Students Learn From This Project**

| Component                             | What it Teaches            |
| ------------------------------------- | -------------------------- |
| **providers.tf**                      | Provider setup, versions   |
| **variables.tf**                      | Variables, types, defaults |
| **terraform.tfvars**                  | Override values            |
| **main.tf**                           | Calling modules            |
| **modules/**                          | Real production design     |
| **EC2 + SG**                          | Simple infrastructure      |
| **outputs.tf**                        | Exporting values           |
| **terraform init/apply/plan/destroy** | Full workflow              |

















#  Terraform Fundamentals **

Terraform is a **declarative Infrastructure-as-Code (IaC) tool**.
“Declarative” means *you describe the final desired state, and Terraform figures out how to create it.*

### ✔ What Terraform Actually Does

Terraform takes your `.tf` files and compares them to:

* What exists in the cloud (real infrastructure)
* What you defined in code (desired infrastructure)

Then Terraform:

1. **Generates an execution plan**
2. **Applies changes**
3. **Tracks everything in the state file**

This allows Terraform to know:

* What needs to be created
* What needs to be modified
* What needs to be destroyed

### ✔ Why Enterprises Use Terraform

Terraform solves 6 major problems in real companies:

| Problem                         | How Terraform Solves It                  |
| ------------------------------- | ---------------------------------------- |
| Manual deployments              | Use code instead of AWS Console          |
| Inconsistent environments       | Use versioned, repeatable templates      |
| Configuration drift             | Automatically detect drift               |
| No audit trail                  | Infrastructure changes stored in Git     |
| No standardization              | Modules enforce approved patterns        |
| Expensive provisioning mistakes | Plan shows cost & resources before apply |

### ✔ Where Terraform is used

* Deploying VPCs, EKS clusters, ECS, RDS
* Setting up CI/CD infrastructure
* Managing IAM and KMS policies
* Creating enterprise-wide networking
* Multi-account AWS deployment automation
* Managing serverless workloads

---

#  Terraform Workflow **

## **1️⃣ terraform init — “Prepare Terraform to work”**

### What happens internally:

* Downloads the **AWS provider** plugin
* Reads your backend config (S3, etc.)
* Sets up caching folders
* Creates `.terraform` directory

### When seniors use it:

* First time running Terraform
* After adding a new provider
* After upgrading provider versions

---

## **2️⃣ terraform validate — “Check your code quality”**

This command:

* Detects syntax errors
* Validates resource arguments
* Ensures you didn’t miss required fields

Used:

* In CI pipelines (GitHub Actions, Jenkins)
* Before pushing code to Git

---

## **3️⃣ terraform plan — “Show what Terraform will do BEFORE doing it”**

### Why it is CRITICAL for senior DevOps:

* Prevents accidental production outages
* Shows which resources will be recreated
* Helps teams approve changes
* Enforces change review processes

Terraform plan outputs:

* Create (new resources)
* Update in-place
* Replace (delete + recreate) — **very dangerous**
* Destroy

**Senior engineers MUST know how to read a plan.**

---

## **4️⃣ terraform apply — “Execute the changes”**

Apply:

* Creates the resources in order of dependency
* Updates the state file
* Displays outputs

### How apply works inside:

Terraform builds a **graph** of resources and executes them in the correct order based on dependency relationships.

---

## **5️⃣ terraform destroy — “Tear down everything”**

Destroys infrastructure but follows:

* Dependencies
* Order
* Prevent-destroy lifecycle rules

Used in:

* Temporary environments
* Development testing
* Automated cleanup jobs

---

# Terraform State (Most Important Topic for Senior DevOps)**

The **state file** is Terraform’s “memory”.
It tracks all real-world resources Terraform manages.

### ✔ What is in the state file?

* Resource IDs (EC2 instance IDs, VPC IDs, RDS ARNs)
* Dependencies
* Provider metadata
* Managed & unmanaged objects

### ✔ Why the state file exists

Terraform MUST keep track of:

* What it created
* What already exists
* What must be reconciled

Without the state:
Terraform cannot find resources and will recreate everything.

---

## **Remote State — Enterprise Standard**

### Why local state is **not acceptable**:

* Not shared across team
* Not secure
* Can be overwritten
* No locking
* Breaks CI/CD

### Remote state benefits:

* Collaboration
* Locking
* Versioning
* Audit history
* Security

#### Example AWS backend:

```hcl
backend "s3" {
  bucket = "tf-state-prod"
  key    = "networking/vpc/terraform.tfstate"
  region = "us-east-2"
  dynamodb_table = "terraform-locks"
}
```

---

## **State Locking**

### Why locking is needed:

To prevent **two engineers** from running `apply` at the same time.

Example:
Engineer A applies a VPC change, Engineer B applies security group changes → potential destruction or corruption.

State locks prevent this.

---

## **State Commands (Deep Usage)**

### ✔ terraform state list

Shows resources Terraform knows about.

Used for:

* Troubleshooting
* Comparing with AWS console
* Audits

### ✔ terraform state rm

Removes a resource from state **without deleting it in AWS**.

Used when:

* Resource should no longer be managed by Terraform
* Resource was migrated to another module

### ✔ terraform state mv

Moves resources between modules or states.

Example:

```
terraform state mv aws_instance.web module.ec2.aws_instance.web
```

This is used when restructuring modules **without recreating infrastructure**.

### ✔ terraform import

Brings unmanaged resources under Terraform control.

Used when:

* Migrating from manually created AWS infrastructure
* Cleaning legacy environments

Example:

```
terraform import aws_s3_bucket.mybucket my-bucket-name
```

---

#  Terraform Modules **

Modules help you build **standardized, reusable components**.

A module is a folder with:

* main.tf
* variables.tf
* outputs.tf

Used to create:

* VPC modules
* ECS service modules
* EKS cluster modules
* RDS database modules
* IAM role modules

---

## **Why Enterprises Require Modules**

1. Standardization
   Same VPC module for all accounts.

2. Security
   Modules embed secure defaults:

   * Encryption
   * Logging
   * IAM boundaries

3. Compliance
   No developer can bypass rules.

4. Version control
   Modules can be versioned:

```
source = "git::https://github.com/company/vpc.git?ref=v3.1.0"
```

5. Faster onboarding
   Junior engineers use modules without deep AWS knowledge.

---

## **3-Layer Terraform Architecture (REQUIRED SKILL AT SENIOR LEVEL)**

This is a very important concept in big companies.

### ⭐ Layer 1: **Resource Modules**

Small building blocks:
`ec2/`, `vpc/`, `s3/`, `lambda/`, etc.

### ⭐ Layer 2: **Infrastructure Modules**

Group resources logically:

* networking
* application
* monitoring

### ⭐ Layer 3: **Composition Layer**

Final deployment:

```
environments/dev
environments/staging
environments/prod
```

This allows:

* Multiple environments
* Multiple AWS accounts
* Different configurations

---

# 🟦 **SECTION 5 — Terraform Language Deep Dive**

## **Variables**

### Why variables exist

To avoid hardcoding and allow configuration across environments.

Types:

* string
* number
* bool
* list
* map
* object

Example:

```
variable "subnets" {
  type = list(string)
}
```

---

## **Outputs**

Used to expose values for:

* CI/CD pipelines
* Other modules
* Developers

Example:

```
output "db_endpoint" {
  value = aws_rds_instance.db.endpoint
}
```

---

## **Locals**

Used to simplify repeated logic.

```
locals {
  common_tags = {
    project = var.project
    owner   = var.owner
  }
}
```

---

## **Functions**

Terraform functions are extremely powerful.
Used to calculate:

* CIDR ranges (`cidrsubnet`)
* Map lookups
* String formatting
* Conditional logic

Example using `cidrsubnet`:

```
cidrsubnet(var.vpc_cidr, 4, 1)
```

---

# 🟦 **SECTION 6 — for_each vs count (Most Asked Interview Topic)**

### ✔ count

Used when resources are identical and indexed numerically.

```
count = 3
```

Problem:

* Changing order recreates resources.

### ✔ for_each

Used for logically unique items.

```
for_each = var.subnets
```

Advantages:

* Stable addresses
* No accidental recreation
* Easier modification

Use **for_each** almost always in production.

---

# 🟦 **SECTION 7 — Dynamic Blocks (Real Use Case Explanation)**

Used when nested blocks repeat.

Example: Repeating security group rules:

```
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port = ingress.value.from
    to_port   = ingress.value.to
    protocol  = "tcp"
    cidr_blocks = ingress.value.cidr
  }
}
```

Used when:

* Rules come from variables
* Policies generate dynamic behavior

---

# 🟦 **SECTION 8 — Terraform + AWS Architecture (Where Terraform is Used)**

A senior DevOps MUST know how to use Terraform to deploy:

### ✔ Networking (VPC):

* Subnets
* Route tables
* NAT / IGW
* NACLs
* Security groups

### ✔ Compute:

* EC2
* Auto Scaling
* Launch templates

### ✔ Load Balancing:

* ALB
* NLB

### ✔ Databases:

* RDS
* Auroras
* Parameter groups

### ✔ Container Services:

* ECS Fargate
* EKS

### ✔ Serverless:

* Lambda
* API Gateway

### ✔ Identity:

* IAM
* Roles for ECS/EKS
* Policies

### ✔ Storage:

* S3
* Encryption & lifecycle rules

---

# 🟦 **SECTION 9 — Terraform Best Practices in Enterprise**

### 1. Follow naming conventions

### 2. Use tags for cost allocation

### 3. Enforce security defaults

### 4. Never put secrets in `.tf` files

Use:

* SSM Parameter Store
* Secrets Manager

### 5. Use `lifecycle` rules

Example:

```
lifecycle {
  prevent_destroy = true
}
```

Used for:

* Production databases
* VPCs
* Shared subnets

### 6. Version lock everything

To avoid breaking changes:

```
version = "~> 5.0"
```

---

# 🟦 SECTION 10 — Terraform in CI/CD Pipelines (Deep Explanation)

### Why CI/CD is required:

* Reduce human error
* Enforce approvals
* Enforce policies
* Provide audit trails

### Pipeline steps:

### Step 1 — Format & Lint

* `terraform fmt -check`
* `tflint`

### Step 2 — Security Scan

* Checkov
* OPA / Conftest
* Terraform Cloud Sentinel

### Step 3 — Plan

PR (pull request) shows plan for review.

### Step 4 — Approve

Team lead approves.
Prevents bad infra from going to prod.

### Step 5 — Apply

Executed only after approval.

---

# 🟦 **SECTION 11 — Policy-as-Code (Enterprises REQUIRE this)**

Used to enforce:

* No open security groups
* Mandatory tagging
* Encryption required
* Only approved AMIs
* IAM policies must be least-privilege

### Tools:

* OPA Rego
* Conftest
* Terraform Cloud Sentinel

### Where used:

* Compliance
* Regulated industries (finance, healthcare)
* Security governance

---

# 🟦 **SECTION 12 — Debugging & Troubleshooting Terraform**

### Common problems senior DevOps solve:

❌ Circular dependencies
❌ State drift
❌ Incorrect `for_each` maps
❌ Resources being recreated accidentally
❌ Provider version conflicts
❌ Module version conflicts
❌ Network resources stuck in "pending"

### Important debugging tools:

```
TF_LOG=debug terraform apply
terraform plan -refresh-only
terraform refresh
```

---

# 🟦 **SECTION 13 — Senior-Level Interview Questions (Explained)**

### ✔ “How do you structure Terraform in a large company?”

Use 3-layer modular architecture.
Separate environments.
Use remote state.
Use pipelines.

### ✔ “How do you prevent accidental production outages?”

* Use `plan` + approvals
* Use `prevent_destroy`
* Use modules
* Version-lock providers

### ✔ “How do you manage secrets?”

Never store in Terraform.
Use AWS Secrets Manager or SSM.

### ✔ “How do you handle state drift?”

* `terraform plan -refresh-only`
* Detect differences
* Fix manually or apply changes






#  VPC + EC2 Deployment Using a 3-Layer Architecture**

We will create:

* **Layer 1 — Resource Modules**
  (small reusable building blocks)

* **Layer 2 — Infrastructure Modules**
  (grouped resources: networking, compute)

* **Layer 3 — Environments**
  (dev, prod)

---

# 📁 **FINAL PROJECT STRUCTURE**

```
terraform-3layer/
├── modules/                 <-- LAYER 1 (resource modules)
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── infrastructure/          <-- LAYER 2 (infra modules)
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│
└── environments/            <-- LAYER 3 (deployable envs)
    ├── dev/
    │   ├── main.tf
    │   ├── backend.tf
    │   ├── variables.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        ├── backend.tf
        ├── variables.tf
        └── terraform.tfvars
```

---

# 🟦 **LAYER 1 — RESOURCE MODULES**

These are small modules that create *one thing only*.
They are reusable everywhere.

---

# 1️⃣ **Module: VPC**

📁 `modules/vpc/main.tf`

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public"
  }
}
```

📁 `modules/vpc/variables.tf`

```hcl
variable "cidr" {}
variable "public_subnet" {}
variable "name" {}
```

📁 `modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}
```

---

# 2️⃣ **Module: EC2**

📁 `modules/ec2/main.tf`

```hcl
resource "aws_instance" "server" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    Name = var.name
  }
}
```

📁 `modules/ec2/variables.tf`

```hcl
variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "name" {}
```

📁 `modules/ec2/outputs.tf`

```hcl
output "public_ip" {
  value = aws_instance.server.public_ip
}
```

---

# 🟦 **LAYER 2 — INFRASTRUCTURE MODULES**

These combine **resource modules** into higher-level architecture.

---

# 3️⃣ **Infrastructure: networking**

📁 `infrastructure/networking/main.tf`

```hcl
module "vpc" {
  source         = "../../modules/vpc"
  cidr           = var.vpc_cidr
  public_subnet  = var.public_subnet
  name           = "demo-vpc"
}
```

📁 `infrastructure/networking/variables.tf`

```hcl
variable "vpc_cidr" {}
variable "public_subnet" {}
```

📁 `infrastructure/networking/outputs.tf`

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}
```

---

# 4️⃣ **Infrastructure: compute**

📁 `infrastructure/compute/main.tf`

```hcl
module "ec2" {
  source        = "../../modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  name          = "demo-ec2"
}
```

📁 `infrastructure/compute/variables.tf`

```hcl
variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
```

📁 `infrastructure/compute/outputs.tf`

```hcl
output "ec2_ip" {
  value = module.ec2.public_ip
}
```

---

# 🟦 **LAYER 3 — ENVIRONMENTS**

These are **deployable environments**: dev, prod, qa, etc.

---

# 5️⃣ **Environment: dev**

📁 `environments/dev/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
  }
}
```

📁 `environments/dev/main.tf`

```hcl
provider "aws" {
  region = "us-east-2"
}

module "networking" {
  source       = "../../infrastructure/networking"
  vpc_cidr     = var.vpc_cidr
  public_subnet = var.public_subnet
}

module "compute" {
  source        = "../../infrastructure/compute"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.networking.public_subnet_id
}
```

📁 `environments/dev/variables.tf`

```hcl
variable "vpc_cidr" {}
variable "public_subnet" {}
variable "ami" {}
variable "instance_type" {}
```

📁 `environments/dev/terraform.tfvars`

```hcl
vpc_cidr      = "10.0.0.0/16"
public_subnet = "10.0.1.0/24"
ami           = "ami-0c02fb55956c7d316"
instance_type = "t2.micro"
```

---

# 6️⃣ **Environment: prod** (exact same structure, different tfvars)

📁 `environments/prod/terraform.tfvars`

```hcl
vpc_cidr      = "10.1.0.0/16"
public_subnet = "10.1.1.0/24"
ami           = "ami-0c02fb55956c7d316"
instance_type = "t3.medium"
```

---

# 🟦 **WHAT YOU JUST BUILT — FULL EXPLANATION**

### ✔ Layer 1 — Resource Modules

Small reusable building blocks.

You created:

* vpc module
* ec2 module

They do *one job only* each → clean, testable, reusable.

---

### ✔ Layer 2 — Infrastructure Modules

Bundles resource modules into logical infrastructure groups.

You created:

* networking module → calls vpc
* compute module → calls ec2

These modules represent “subsystems.”

---

### ✔ Layer 3 — Environments

Deployable folders:

* dev
* prod

These call the infrastructure modules and provide values.

---

# 🟦 **DEPLOYING THE PROJECT**

Go to the dev folder:

```
cd environments/dev
terraform init
terraform plan
terraform apply
```

Go to prod:

```
cd environments/prod
terraform init
terraform apply
```

Now you have **two isolated environments** using the same modules.

---

# 🟦 **WHY THIS ARCHITECTURE IS POWERFUL**

### 🔹 DRY (Don’t Repeat Yourself)

dev, prod, staging all use the same modules.

### 🔹 Security

All infrastructure goes through controlled modules.

### 🔹 Simplicity

Beginners only edit Layer 3 → safe.

### 🔹 Scalability

Add ECS, RDS, Lambda easily in Layer 2.

### 🔹 Enterprise compliance

Matches structure used by:

* Bank of America
* Capital One
* AWS ProServe
* Deloitte


