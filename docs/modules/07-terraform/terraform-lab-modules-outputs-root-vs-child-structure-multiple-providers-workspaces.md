---
title: "Terraform Lab: Modules, Outputs, Root vs Child, Structure, Multiple Providers, Workspaces"
description: "In this lab you will learn how to build Terraform modules the way real organizations do.  You will..."
published: 2026-03-20
source: "https://dev.to/jumptotech/terraform-lab-modules-outputs-root-vs-child-structure-multiple-providers-workspaces-3jmi"
tags: []
---

# Terraform Lab: Modules, Outputs, Root vs Child, Structure, Multiple Providers, Workspaces





In this lab you will learn how to build Terraform modules the way real organizations do.

You will practice:

* creating reusable **child modules**
* calling them from the **root module**
* exposing values using **outputs**
* using **multiple AWS providers**
* switching environments using **Terraform workspaces**
* following a **production-ready module structure**
* understanding how modules are designed for real teams
* understanding how modules are published to the **Terraform Registry**

---

# PART 1 — What You Are Building

You will build this architecture:

* **network module**

  * creates a security group
* **compute module**

  * creates an EC2 instance
* **root module**

  * calls both modules
  * creates an Elastic IP
  * attaches the EIP to the EC2 instance using the **module output**
* **multiple providers**

  * default AWS provider for one region
  * aliased AWS provider for another region
* **workspaces**

  * dev and prod use different instance types

---

# PART 2 — Why Module Outputs Matter

## Real production problem

In real companies:

* one module creates networking
* another creates compute
* another creates database
* another creates DNS

These modules must share data.

Examples:

* EC2 module needs subnet ID from VPC module
* EIP needs instance ID from compute module
* ALB module needs security group ID from network module
* Route53 module needs load balancer DNS from ALB module

Without outputs, modules become isolated.

---

## What is a module output?

A module output is a value exported from a child module so the root module or another module can use it.

Example:

Inside child module:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

In root module:

```hcl
module.compute.instance_id
```

That is the whole idea.

---

# PART 3 — Root Module vs Child Module

## Root module

The **root module** is the directory where you run:

```bash
terraform init
terraform plan
terraform apply
```

It is the main entry point.

## Child module

A **child module** is a reusable Terraform module called by another module.

Example:

```hcl
module "compute" {
  source = "./modules/compute"
}
```

Here, `./modules/compute` is a child module.

## Very important exam point

Every Terraform configuration has:

* exactly **one root module**
* zero or more **child modules**

---

# PART 4 — Production Folder Structure

This is the structure you should create.

```bash
terraform-modules-production-lab/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── locals.tf
├── terraform.tfvars.example
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── examples/
    └── basic/
        └── example-usage.md
```

---

# PART 5 — Why Each File Exists

## Root files

### `versions.tf`

Defines Terraform version and provider requirements.

### `providers.tf`

Defines AWS providers, including aliases.

### `variables.tf`

All input variables for root module.

### `locals.tf`

Contains computed values, including workspace-based values.

### `main.tf`

Calls child modules and creates root resources.

### `outputs.tf`

Exposes final values from root module.

### `terraform.tfvars.example`

Sample variable values for users.

### `README.md`

Explains how to use the project.

---

## Module files

### `main.tf`

Contains actual resources.

### `variables.tf`

Defines what inputs the module accepts.

### `outputs.tf`

Exposes module values to callers.

### `README.md`

Documents how the module works.

---

# PART 6 — Create the Root Module Files

---

## 1. `versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Why this file matters

* locks minimum Terraform version
* locks provider source
* avoids random provider behavior across machines
* production best practice

---

## 2. `providers.tf`

```hcl
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

### What this does

* default provider uses `primary_region`
* aliased provider named `secondary` uses another region

This is required for the multi-provider part.

---

## 3. `variables.tf`

```hcl
variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name. Usually derived from workspace, but can be used for tags"
  type        = string
  default     = "default"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region used by aliased provider"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID where EC2 instance will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance in primary region"
  type        = string
}

variable "key_name" {
  description = "Existing AWS key pair name for EC2 access"
  type        = string
}

variable "instance_type_by_workspace" {
  description = "Map of workspace to EC2 instance type"
  type        = map(string)

  default = {
    default = "t2.micro"
    dev     = "t2.micro"
    prod    = "t3.small"
  }
}
```

### Why no hardcoding?

Because in real production:

* VPC already exists
* subnet already exists
* AMI varies by region
* key pair differs by account
* CIDR must be configurable

So we pass them as variables.

---

## 4. `locals.tf`

```hcl
locals {
  workspace_name = terraform.workspace

  instance_type = lookup(
    var.instance_type_by_workspace,
    terraform.workspace,
    var.instance_type_by_workspace["default"]
  )

  common_tags = {
    Project     = var.project_name
    Environment = local.workspace_name
    ManagedBy   = "Terraform"
  }
}
```

### Why use locals?

Locals help:

* avoid repeating logic
* keep code clean
* centralize naming and tag logic
* map workspace to instance size

---

## 5. `main.tf`

```hcl
module "network_primary" {
  source = "./modules/network"

  providers = {
    aws = aws
  }

  name             = "${var.project_name}-${local.workspace_name}-primary-sg"
  vpc_id           = var.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  ingress_ports    = [22, 80]
  tags             = local.common_tags
}

module "network_secondary" {
  source = "./modules/network"

  providers = {
    aws = aws.secondary
  }

  name             = "${var.project_name}-${local.workspace_name}-secondary-sg"
  vpc_id           = var.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  ingress_ports    = [22]
  tags             = merge(local.common_tags, { RegionRole = "secondary" })
}

module "compute" {
  source = "./modules/compute"

  providers = {
    aws = aws
  }

  name               = "${var.project_name}-${local.workspace_name}-ec2"
  ami_id             = var.ami_id
  instance_type      = local.instance_type
  subnet_id          = var.subnet_id
  security_group_ids = [module.network_primary.security_group_id]
  key_name           = var.key_name
  tags               = local.common_tags
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = module.compute.instance_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${local.workspace_name}-eip"
  })
}
```

---

## Important explanation

### Why does this line work?

```hcl
instance = module.compute.instance_id
```

Because `instance_id` is explicitly exposed from the compute child module.

Without that output, Terraform cannot access the resource inside the module.

---

## What dependency is happening automatically?

* EC2 instance must exist first
* then EIP can attach to it

Terraform understands this automatically because:

```hcl
aws_eip.this -> module.compute.instance_id
```

That reference creates dependency.

---

## 6. `outputs.tf`

```hcl
output "primary_security_group_id" {
  description = "Security group ID from primary region module"
  value       = module.network_primary.security_group_id
}

output "secondary_security_group_id" {
  description = "Security group ID from secondary region module"
  value       = module.network_secondary.security_group_id
}

output "instance_id" {
  description = "EC2 instance ID from compute module"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Elastic IP attached to the instance"
  value       = aws_eip.this.public_ip
}

output "workspace_name" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}
```

---

## 7. `terraform.tfvars.example`

```hcl
project_name      = "modules-lab"
environment       = "dev"
primary_region    = "us-east-1"
secondary_region  = "us-east-2"
vpc_id            = "vpc-xxxxxxxx"
subnet_id         = "subnet-xxxxxxxx"
allowed_ssh_cidr  = "0.0.0.0/0"
ami_id            = "ami-xxxxxxxx"
key_name          = "my-existing-keypair"

instance_type_by_workspace = {
  default = "t2.micro"
  dev     = "t2.micro"
  prod    = "t3.small"
}
```

Rename this file to:

```bash
terraform.tfvars
```

and replace placeholder values with your real AWS values.

---

# PART 7 — Child Module 1: Network Module

Create folder:

```bash
mkdir -p modules/network
```

---

## `modules/network/main.tf`

```hcl
resource "aws_security_group" "this" {
  name        = var.name
  description = "Managed by Terraform module"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Ingress for port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
```

---

## `modules/network/variables.tf`

```hcl
variable "name" {
  description = "Security group name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for ingress"
  type        = string
}

variable "ingress_ports" {
  description = "List of ingress ports to open"
  type        = list(number)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
```

---

## `modules/network/outputs.tf`

```hcl
output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.this.id
}

output "security_group_name" {
  description = "Created security group name"
  value       = aws_security_group.this.name
}
```

---

## `modules/network/README.md`

```md
# Network Module

Creates a reusable AWS Security Group.

## Inputs
- name
- vpc_id
- allowed_ssh_cidr
- ingress_ports
- tags

## Outputs
- security_group_id
- security_group_name
```

---

# PART 8 — Child Module 2: Compute Module

Create folder:

```bash
mkdir -p modules/compute
```

---

## `modules/compute/main.tf`

```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = merge(var.tags, {
    Name = var.name
  })
}
```

---

## `modules/compute/variables.tf`

```hcl
variable "name" {
  description = "EC2 instance name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instance will be created"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Existing key pair name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
```

---

## `modules/compute/outputs.tf`

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.this.private_ip
}
```

---

## `modules/compute/README.md`

```md
# Compute Module

Creates a reusable EC2 instance.

## Inputs
- name
- ami_id
- instance_type
- subnet_id
- security_group_ids
- key_name
- tags

## Outputs
- instance_id
- private_ip
```

---

# PART 9 — Multiple Providers: What Is Happening Here?

## Default provider

```hcl
provider "aws" {
  region = var.primary_region
}
```

This becomes the inherited provider for child modules unless told otherwise.

## Aliased provider

```hcl
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

This is not inherited automatically.

So for a module to use it, you must explicitly pass it:

```hcl
module "network_secondary" {
  source = "./modules/network"

  providers = {
    aws = aws.secondary
  }

  ...
}
```

---

## Important rule

### Default provider

Inherited automatically

### Aliased provider

Must be passed explicitly

That is one of the most important Terraform interview points.

---

# PART 10 — Do We Need `configuration_aliases` in the Child Module Here?

In this exact lab, the child module resources simply use the provider name `aws`, and the root module remaps it like this:

```hcl
providers = {
  aws = aws.secondary
}
```

That works.

---

## When do you need `configuration_aliases`?

You need it when the child module itself refers to aliased provider names like this:

```hcl
provider = aws.prod
```

Then the child module must declare:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.prod]
    }
  }
}
```

---

## Example theory version for interview

### Root

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "prod"
  region = "ap-south-1"
}

module "network" {
  source = "./modules/network"

  providers = {
    aws.prod = aws.prod
  }
}
```

### Child

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.prod]
    }
  }
}

resource "aws_security_group" "prod" {
  provider = aws.prod
  name     = "prod-sg"
  vpc_id   = var.vpc_id
}
```

---

# PART 11 — Workspaces

## Why workspaces?

You want:

* same code
* different environments
* separate state files

Instead of copying code for dev and prod.

---

## Workspace commands

### List workspaces

```bash
terraform workspace list
```

### Show current workspace

```bash
terraform workspace show
```

### Create dev

```bash
terraform workspace new dev
```

### Create prod

```bash
terraform workspace new prod
```

### Switch to dev

```bash
terraform workspace select dev
```

### Switch to prod

```bash
terraform workspace select prod
```

---

## Where workspace states are stored

Terraform stores workspace state files in:

```bash
terraform.tfstate.d/<workspace>/
```

Example:

```bash
terraform.tfstate.d/dev/terraform.tfstate
terraform.tfstate.d/prod/terraform.tfstate
```

The `default` workspace uses:

```bash
terraform.tfstate
```

in the root directory.

---

## How workspace affects this lab

In `locals.tf`:

```hcl
locals {
  instance_type = lookup(
    var.instance_type_by_workspace,
    terraform.workspace,
    var.instance_type_by_workspace["default"]
  )
}
```

So:

* `dev` workspace can use `t2.micro`
* `prod` workspace can use `t3.small`

Same code, different results.

---

# PART 12 — Step-by-Step Build Instructions

## Step 1 — Create project folder

```bash
mkdir terraform-modules-production-lab
cd terraform-modules-production-lab
```

---

## Step 2 — Create files and folders

```bash
touch README.md versions.tf providers.tf variables.tf locals.tf main.tf outputs.tf terraform.tfvars.example
mkdir -p modules/network modules/compute examples/basic
touch modules/network/main.tf modules/network/variables.tf modules/network/outputs.tf modules/network/README.md
touch modules/compute/main.tf modules/compute/variables.tf modules/compute/outputs.tf modules/compute/README.md
touch examples/basic/example-usage.md
```

---

## Step 3 — Paste code into each file

Use the code blocks above exactly.

---

## Step 4 — Copy tfvars example

```bash
cp terraform.tfvars.example terraform.tfvars
```

Now edit it:

```bash
vim terraform.tfvars
```

or

```bash
nano terraform.tfvars
```

Replace:

* `vpc-xxxxxxxx`
* `subnet-xxxxxxxx`
* `ami-xxxxxxxx`
* `my-existing-keypair`

with real values from your AWS account.

---

## Step 5 — Initialize Terraform

```bash
terraform init
```

---

## Step 6 — Validate configuration

```bash
terraform validate
```

---

## Step 7 — Format files

```bash
terraform fmt -recursive
```

---

## Step 8 — See current workspace

```bash
terraform workspace show
```

---

## Step 9 — Create dev workspace

```bash
terraform workspace new dev
```

---

## Step 10 — Plan in dev

```bash
terraform plan
```

Or save the plan:

```bash
terraform plan -out=dev.plan
```

---

## Step 11 — Apply in dev

```bash
terraform apply
```

Or from saved plan:

```bash
terraform apply dev.plan
```

---

## Step 12 — View outputs

```bash
terraform output
```

Specific output:

```bash
terraform output instance_id
terraform output instance_public_ip
terraform output workspace_name
```

---

## Step 13 — Switch to prod

```bash
terraform workspace new prod
```

or if already created:

```bash
terraform workspace select prod
```

---

## Step 14 — Plan in prod

```bash
terraform plan -out=prod.plan
```

You should see a different instance type if your map is different for prod.

---

## Step 15 — Destroy dev or prod when done

Example for current workspace:

```bash
terraform destroy
```

To destroy dev:

```bash
terraform workspace select dev
terraform destroy
```

To destroy prod:

```bash
terraform workspace select prod
terraform destroy
```

---

# PART 13 — How to Visually Explain This Lab to Students

## Flow

1. root module runs Terraform
2. root module calls child modules
3. network module creates security group
4. compute module creates EC2 instance
5. compute module exports instance ID
6. root module reads that output
7. root module attaches EIP to the instance
8. workspaces change instance size
9. multiple providers allow different regions

---

## Simple architecture diagram

```text
                ROOT MODULE
                     |
      ---------------------------------
      |                               |
      v                               v
 module.network_primary         module.compute
      |                               |
      |                               |
      v                               v
 aws_security_group            aws_instance.this
                                      |
                                      | output "instance_id"
                                      v
                              module.compute.instance_id
                                      |
                                      v
                                aws_eip.this
```

---

# PART 14 — Why This Is a Good Production Design

## Good design choices here

* modules are **small and focused**
* root module composes infrastructure
* variables are externalized
* outputs expose only necessary values
* workspace logic is centralized
* provider regions are configurable
* nothing critical is hardcoded

---

## Bad design to avoid

### One giant module for everything

Bad because:

* hard to reuse
* hard to test
* hard to maintain
* hard to update independently

### Hardcoded AMIs, VPCs, subnets, regions

Bad because:

* not portable
* breaks across accounts
* not reusable across environments

### No outputs

Bad because:

* modules cannot integrate
* dependencies become impossible

---

# PART 15 — Real-World Best Practice: Module Boundaries

In real organizations you usually separate modules like this:

* `vpc`
* `subnets`
* `security-group`
* `ec2`
* `alb`
* `rds`
* `iam-role`
* `route53`
* `autoscaling`
* `eks`

Each module should do one clear thing.

That is how big infrastructure stays manageable.

---

# PART 16 — Registry Publishing Theory

## What is Terraform Registry?

Terraform Registry is a place where users can discover and use Terraform modules.

It gives:

* versioned reusable modules
* documentation rendering
* examples
* source code reference

---

## Who can publish?

Anyone can publish **public modules** if:

* repo is on GitHub
* repo is public
* naming is correct
* version tags are present

---

## Required naming convention

Repository name must follow:

```text
terraform-<provider>-<name>
```

Examples:

```text
terraform-aws-vpc
terraform-aws-security-group
terraform-aws-ec2-instance
```

Bad examples:

```text
aws-vpc
my-module
terraform-module
```

---

## Required structure

Minimal recommended:

```text
README.md
main.tf
variables.tf
outputs.tf
```

Larger modules may also include:

```text
versions.tf
examples/
modules/
```

---

## Version tags

Terraform Registry reads **Git tags**, not branches.

Good examples:

```text
v1.0.0
1.2.3
0.9.1
```

Bad examples:

```text
release-final
version1
latest-final
```

---

## High-level publish flow

1. create GitHub public repo
2. use proper repository name
3. add standard module structure
4. write README
5. push code
6. create semantic version tag
7. sign in to Terraform Registry with GitHub
8. publish the module

---

# PART 17 — Example README Content for a Production Module

Use something like this for your module README.

````md
# terraform-aws-security-group

Reusable Terraform module to create an AWS Security Group.

## Features
- configurable ingress ports
- configurable VPC
- configurable tags

## Usage

```hcl
module "network" {
  source = "github.com/your-org/terraform-aws-security-group"

  name             = "my-sg"
  vpc_id           = "vpc-123"
  allowed_ssh_cidr = "0.0.0.0/0"
  ingress_ports    = [22, 80]
  tags = {
    Environment = "dev"
  }
}
````

## Inputs

| Name | Description         | Type   |
| ---- | ------------------- | ------ |
| name | Security group name | string |

## Outputs

| Name              | Description               |
| ----------------- | ------------------------- |
| security_group_id | Created security group ID |

````hcl

---

# PART 18 — Interview Questions and Answers

## 1. What is a module output?

A module output exposes values created inside a child module so the root module or other modules can consume them.

---

## 2. Why are outputs important?

Outputs allow modules to share data. Without outputs, resources created inside child modules cannot be referenced outside those modules.

---

## 3. What is the root module?

The root module is the main Terraform working directory where Terraform commands such as `init`, `plan`, and `apply` are executed.

---

## 4. What is a child module?

A child module is any module called by another module.

---

## 5. How do you reference a child module output?

```hcl
module.<module_name>.<output_name>
````

Example:

```hcl
module.compute.instance_id
```

---

## 6. Are aliased providers inherited automatically?

No. Only the default provider is inherited automatically. Aliased providers must be explicitly passed to child modules.

---

## 7. Why do we use standard module structure?

It improves readability, predictability, reusability, and maintainability.

---

## 8. What is a Terraform workspace?

A workspace allows the same Terraform configuration to manage multiple separate state files.

---

## 9. Does each workspace have its own state?

Yes. Each workspace has its own state file.

---

## 10. How do you get the current workspace inside Terraform?

```hcl
terraform.workspace
```

---

## 11. Are workspaces recommended for large enterprises?

Usually not for strong isolation needs. Large enterprises often prefer separate directories, separate backends, separate accounts, and separate pipelines.

---

## 12. When do you use `configuration_aliases`?

When the child module itself needs to refer to aliased provider names such as `aws.prod`.

---

# PART 19 — Common Errors and Fixes

## Error 1: Unsupported attribute

Example:

```hcl
module.compute.id
```

but child module does not define output `id`.

### Fix

Define output in child module:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

Then use:

```hcl
module.compute.instance_id
```

---

## Error 2: Provider configuration not present

Usually happens when aliased provider is not passed into module.

### Fix

Pass provider explicitly:

```hcl
providers = {
  aws = aws.secondary
}
```

---

## Error 3: Invalid AMI

This happens if AMI does not exist in the selected region.

### Fix

Use a valid AMI for your chosen `primary_region`.

---

## Error 4: InvalidSubnet or InvalidVpcID

Your subnet or VPC variable is wrong or belongs to another region/account.

### Fix

Use real values from the same region and account.

---

# PART 20 — Commands You Should Know for This Lab

## Formatting and validation

```bash
terraform fmt -recursive
terraform validate
```

## Initialization

```bash
terraform init
terraform init -upgrade
```

## Planning

```bash
terraform plan
terraform plan -out=dev.plan
```

## Apply

```bash
terraform apply
terraform apply dev.plan
```

## Outputs

```bash
terraform output
terraform output instance_id
```

## Workspaces

```bash
terraform workspace list
terraform workspace show
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
terraform workspace select prod
```

## Destroy

```bash
terraform destroy
```

---

# PART 21 — Example Teaching Script

You can explain it like this:

> The root module is the main controller. It does not need to define every resource directly. Instead, it calls child modules. Each child module handles one specific responsibility, such as network or compute. When one module creates something that another resource needs, the module must expose that value through outputs. Then the root module can consume it using `module.<name>.<output>`. This is how real Terraform infrastructure is composed safely and cleanly.

---

# PART 22 — Final Clean Copy of the Whole Code

 Root `versions.tf`

hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


 Root `providers.tf`

```hcl
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}


 Root `variables.tf`

hcl
variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name. Usually derived from workspace, but can be used for tags"
  type        = string
  default     = "default"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region used by aliased provider"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID where EC2 instance will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance in primary region"
  type        = string
}

variable "key_name" {
  description = "Existing AWS key pair name for EC2 access"
  type        = string
}

variable "instance_type_by_workspace" {
  description = "Map of workspace to EC2 instance type"
  type        = map(string)

  default = {
    default = "t2.micro"
    dev     = "t2.micro"
    prod    = "t3.small"
  }
}


 Root `locals.tf`

hcl
locals {
  workspace_name = terraform.workspace

  instance_type = lookup(
    var.instance_type_by_workspace,
    terraform.workspace,
    var.instance_type_by_workspace["default"]
  )

  common_tags = {
    Project     = var.project_name
    Environment = local.workspace_name
    ManagedBy   = "Terraform"
  }
}


 Root `main.tf`

hcl
module "network_primary" {
  source = "./modules/network"

  providers = {
    aws = aws
  }

  name             = "${var.project_name}-${local.workspace_name}-primary-sg"
  vpc_id           = var.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  ingress_ports    = [22, 80]
  tags             = local.common_tags
}

module "network_secondary" {
  source = "./modules/network"

  providers = {
    aws = aws.secondary
  }

  name             = "${var.project_name}-${local.workspace_name}-secondary-sg"
  vpc_id           = var.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  ingress_ports    = [22]
  tags             = merge(local.common_tags, { RegionRole = "secondary" })
}

module "compute" {
  source = "./modules/compute"

  providers = {
    aws = aws
  }

  name               = "${var.project_name}-${local.workspace_name}-ec2"
  ami_id             = var.ami_id
  instance_type      = local.instance_type
  subnet_id          = var.subnet_id
  security_group_ids = [module.network_primary.security_group_id]
  key_name           = var.key_name
  tags               = local.common_tags
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = module.compute.instance_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${local.workspace_name}-eip"
  })
}


Root `outputs.tf`

hcl
output "primary_security_group_id" {
  description = "Security group ID from primary region module"
  value       = module.network_primary.security_group_id
}

output "secondary_security_group_id" {
  description = "Security group ID from secondary region module"
  value       = module.network_secondary.security_group_id
}

output "instance_id" {
  description = "EC2 instance ID from compute module"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Elastic IP attached to the instance"
  value       = aws_eip.this.public_ip
}

output "workspace_name" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}


Module `modules/network/main.tf`

hcl
resource "aws_security_group" "this" {
  name        = var.name
  description = "Managed by Terraform module"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Ingress for port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}


Module `modules/network/variables.tf`

hcl
variable "name" {
  description = "Security group name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for ingress"
  type        = string
}

variable "ingress_ports" {
  description = "List of ingress ports to open"
  type        = list(number)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}


Module `modules/network/outputs.tf`

hcl
output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.this.id
}

output "security_group_name" {
  description = "Created security group name"
  value       = aws_security_group.this.name
}


 Module `modules/compute/main.tf`

hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = merge(var.tags, {
    Name = var.name
  })
}


Module `modules/compute/variables.tf`

hcl
variable "name" {
  description = "EC2 instance name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instance will be created"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Existing key pair name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}


Module `modules/compute/outputs.tf`

hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.this.private_ip
}



