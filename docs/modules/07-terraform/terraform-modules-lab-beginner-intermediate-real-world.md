---
title: "Terraform Modules Lab (Beginner Intermediate Real-world)"
description: "Objective   Build reusable Terraform modules and deploy infrastructure using them.  You..."
published: 2026-03-18
source: "https://dev.to/jumptotech/terraform-modules-lab-beginner-intermediate-real-world-1eld"
tags: []
---

# Terraform Modules Lab (Beginner Intermediate Real-world)



## Objective

Build reusable Terraform modules and deploy infrastructure using them.

You will:

* create a `vpc` module
* create an `ec2` module
* reuse modules from the root module
* understand **variables, outputs, source, module communication**
* run Terraform commands to inspect and manage infrastructure

---



```bash
terraform-modules-lab/
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── env/
    └── dev/
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

---

# 2. Idea of Modules

A module is a **reusable block of Terraform code**.

Think like this:

* `modules/vpc` = builds networking
* `modules/ec2` = builds server
* `env/dev` = root module that calls both modules

## Flow

```text
env/dev
   ↓
calls vpc module
calls ec2 module
   ↓
vpc module creates VPC + subnet
ec2 module creates security group + instance
   ↓
vpc outputs subnet_id and vpc_id
ec2 uses those outputs
```

---

# 3. Create the Project

Run these commands in your terminal:

```bash
mkdir -p terraform-modules-lab/modules/vpc
mkdir -p terraform-modules-lab/modules/ec2
mkdir -p terraform-modules-lab/env/dev
cd terraform-modules-lab
```

To verify structure:

```bash
tree
```

If `tree` is not installed on Mac:

```bash
brew install tree
tree
```

---

# 4. VPC Module

## File: `modules/vpc/main.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.az

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-subnet"
    }
  )
}
```

## Why this file is written like this

`main.tf` contains the **actual resources**.

This module creates:

* one VPC
* one subnet

Why use `var.cidr_block`, `var.subnet_cidr`, `var.az`, `var.name`?

Because modules should not be hardcoded.
They should accept input and be reusable.

Why use `merge(var.tags, {...})`?

Because in production we usually pass common tags like:

* Environment
* Project
* Owner
* ManagedBy

and also add a specific `Name`.

---

## File: `modules/vpc/variables.tf`

```hcl
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "az" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "name" {
  description = "Name tag for VPC resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

## Why this file exists

This file defines the **inputs** to the module.

A module is like a function:

* variables = input arguments
* outputs = returned values

Without `variables.tf`, your module becomes fixed and not reusable.

---

## File: `modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
```

## Why this file exists

Outputs are how one module shares data with another module or with the root module.

Example:

* VPC module creates subnet
* EC2 module needs subnet ID
* root module gets `module.vpc.subnet_id` and passes it into EC2 module

Without outputs, modules cannot communicate cleanly.

---

# 5. EC2 Module

## File: `modules/ec2/main.tf`

```hcl
resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
```

## Why this file is written like this

This module creates:

* one security group
* one EC2 instance

Why security group inside EC2 module?

Because for a beginner-intermediate lab it keeps the module self-contained:

* EC2 needs network rules
* security group belongs directly to this server setup

Why `vpc_id = var.vpc_id`?

Because a security group must be created inside a VPC.

Why `subnet_id = var.subnet_id`?

Because EC2 must be launched in a subnet.

Why `vpc_security_group_ids = [aws_security_group.web.id]`?

That attaches the created security group to the instance.

---

## File: `modules/ec2/variables.tf`

```hcl
variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be created"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "name" {
  description = "Name tag for EC2 instance"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

## Why this file exists

These are the module inputs.

The EC2 module does not know:

* which AMI to use
* which subnet to use
* which VPC to use
* what instance size to use

The root module passes all of that in.

---

## File: `modules/ec2/outputs.tf`

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

## Why this file exists

It returns the EC2 instance ID.

Even if you do not use it right now, in real projects outputs are useful for:

* monitoring
* DNS
* load balancer attachment
* troubleshooting
* later expansion

---

# 6. Root Module: Dev Environment

The `env/dev` folder is the **root module**.

This is where Terraform starts.

It:

* configures provider
* gets AMI dynamically
* calls child modules
* wires outputs from one module into inputs of another

---

## File: `env/dev/main.tf`

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

provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  cidr_block  = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  az          = var.az
  name        = var.vpc_name
  tags        = var.tags
}

module "ec2" {
  source        = "../../modules/ec2"
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.subnet_id
  vpc_id        = module.vpc.vpc_id
  name          = var.ec2_name
  tags          = var.tags
}
```

## Why this file is written like this

Why `terraform {}` block?

To define:

* required Terraform version
* required provider version

This is important in production so teams use predictable versions.

Why provider is here and not inside modules?

Because provider configuration usually belongs in the **root module**.

Why `data "aws_ami"`?

Because hardcoding an AMI is bad.
AMIs can change, be region-specific, or be deleted.

Using a data source gets the latest matching AMI dynamically.

Why:

```hcl
subnet_id = module.vpc.subnet_id
vpc_id    = module.vpc.vpc_id
```

Because this is how modules communicate.

VPC module returns values through outputs.
Root module passes those values into EC2 module.

---

## File: `env/dev/variables.tf`

```hcl
variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

variable "az" {
  description = "Availability Zone"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "ec2_name" {
  description = "EC2 name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
```

## Why this file exists

This file makes your root module cleaner.

Instead of hardcoding values in `main.tf`, you separate:

* logic in `main.tf`
* values in `terraform.tfvars`

This is better for real-world work.

---

## File: `env/dev/terraform.tfvars`

```hcl
region        = "us-east-1"
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
az            = "us-east-1a"
vpc_name      = "dev-vpc"
ec2_name      = "dev-server"
instance_type = "t2.micro"

tags = {
  Environment = "dev"
  Project     = "terraform-modules-lab"
  ManagedBy   = "Terraform"
}
```

## Why this file exists

This file stores the actual values for the root module variables.

In real environments:

* `dev` will have one tfvars
* `stage` another
* `prod` another

That is how the same code can be reused across environments.

---

# 7. Full Final Skeleton Again

```bash
terraform-modules-lab/
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── env/
    └── dev/
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

---

# 8. Commands to Run the Lab

Go into the root module:

```bash
cd terraform-modules-lab/env/dev
```

---

## A. Commands Before `terraform init`

### Check file structure

```bash
pwd
ls
ls ../../modules/vpc
ls ../../modules/ec2
tree ../..
```

### See file content

```bash
cat main.tf
cat variables.tf
cat terraform.tfvars
cat ../../modules/vpc/main.tf
cat ../../modules/ec2/main.tf
```

### Validate Terraform formatting

```bash
terraform fmt -recursive
```

This formats all `.tf` files in the project.

---

## B. Initialize

```bash
terraform init
```

What it does:

* downloads AWS provider
* initializes `.terraform/`
* prepares backend/provider/modules

Useful variations:

```bash
terraform init -upgrade
terraform init -reconfigure
```

* `-upgrade` upgrades provider versions
* `-reconfigure` reinitializes backend/provider config

---

## C. Validate

```bash
terraform validate
```

This checks syntax and internal configuration correctness.

---

## D. See the Plan

```bash
terraform plan
```

This shows what Terraform will create.

Useful variations:

```bash
terraform plan -out=dev.plan
terraform plan -var="instance_type=t3.micro"
terraform plan -target=module.vpc
terraform plan -target=module.ec2
```

What they do:

* `-out=dev.plan` saves the plan to a file
* `-var=...` overrides a variable
* `-target=module.vpc` only plans that module
* `-target=module.ec2` only plans that module

To inspect a saved plan:

```bash
terraform show dev.plan
```

To see it without colors:

```bash
terraform show -no-color dev.plan
```

---

## E. Apply

```bash
terraform apply
```

Or from saved plan:

```bash
terraform apply dev.plan
```

Auto approve:

```bash
terraform apply -auto-approve
```

---

# 9. Commands to See the Result After Apply

## Show Terraform state summary

```bash
terraform show
```

## See only outputs

Right now root module does not define outputs, so this may be empty unless you add outputs to `env/dev`.
You can still inspect state/resources with the commands below.

## List all resources in state

```bash
terraform state list
```

Expected result will be similar to:

```text
data.aws_ami.amazon_linux
module.ec2.aws_instance.web
module.ec2.aws_security_group.web
module.vpc.aws_subnet.public
module.vpc.aws_vpc.main
```

## Show one specific resource from state

```bash
terraform state show module.vpc.aws_vpc.main
terraform state show module.vpc.aws_subnet.public
terraform state show module.ec2.aws_security_group.web
terraform state show module.ec2.aws_instance.web
```

These commands are very useful for teaching because students can see all attributes.

---

## Show dependency graph

```bash
terraform graph
```

Save graph to image:

```bash
terraform graph | dot -Tpng > graph.png
open graph.png
```

On Mac, if `dot` is missing:

```bash
brew install graphviz
terraform graph | dot -Tpng > graph.png
open graph.png
```

---

# 10. Commands to Manipulate the Infrastructure

## Reformat files

```bash
terraform fmt -recursive
```

## Revalidate

```bash
terraform validate
```

## Refresh state against real infrastructure

```bash
terraform plan -refresh-only
```

Apply refreshed state only:

```bash
terraform apply -refresh-only
```

---

## Replace a resource

If you want Terraform to recreate the EC2 instance:

```bash
terraform apply -replace="module.ec2.aws_instance.web"
```

Recreate security group:

```bash
terraform apply -replace="module.ec2.aws_security_group.web"
```

---

## Target a module

Only create or update VPC module:

```bash
terraform apply -target=module.vpc
```

Only create or update EC2 module:

```bash
terraform apply -target=module.ec2
```

Important: in production, `-target` should be used carefully, mostly for troubleshooting.

---

## Inspect providers

```bash
terraform providers
```

---

## Show workspace

```bash
terraform workspace show
```

List workspaces:

```bash
terraform workspace list
```

Create a workspace:

```bash
terraform workspace new test
```

Switch workspace:

```bash
terraform workspace select default
```

For this lab, workspace is optional because you already separate environment by folders.

---

# 11. Add Root Outputs So `terraform output` Works

Add one more file:

## File: `env/dev/outputs.tf`

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.subnet_id
}

output "instance_id" {
  value = module.ec2.instance_id
}
```

Now you can run:

```bash
terraform output
terraform output vpc_id
terraform output subnet_id
terraform output instance_id
```

JSON format:

```bash
terraform output -json
```

---

# 12. Commands to Change Values

Edit `terraform.tfvars` and change:

```hcl
instance_type = "t3.micro"
```

Then run:

```bash
terraform plan
terraform apply
```

Or override at command line:

```bash
terraform plan -var="instance_type=t3.small"
terraform apply -var="instance_type=t3.small"
```

---

# 13. Commands to Troubleshoot

## Enable logs

Mac/Linux:

```bash
export TF_LOG=DEBUG
terraform plan
```

More detailed:

```bash
export TF_LOG=TRACE
terraform plan
```

Save logs to file:

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=terraform.log
terraform plan
```

Disable logs:

```bash
unset TF_LOG
unset TF_LOG_PATH
```

---

## Show current state file resources

```bash
terraform state list
```

## Pull raw state

```bash
terraform state pull
```

## Move a resource in state

Advanced use:

```bash
terraform state mv old.address new.address
```

## Remove a resource from state only

```bash
terraform state rm module.ec2.aws_instance.web
```

This does **not** delete real AWS resource.
It only removes it from Terraform state.

---

# 14. Commands to Clean Up

## Destroy everything

```bash
terraform destroy
```

Auto approve:

```bash
terraform destroy -auto-approve
```

Destroy only EC2 module:

```bash
terraform destroy -target=module.ec2
```

Destroy only VPC module:

```bash
terraform destroy -target=module.vpc
```

Be careful: if EC2 depends on VPC resources, destroy order matters.

---

# 15. Expected Result

After `terraform apply`, you should get:

* 1 VPC
* 1 subnet
* 1 security group
* 1 EC2 instance

---

# 16. Best Teaching Flow for Class

Use this exact order:

```bash
cd terraform-modules-lab/env/dev
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
terraform state list
terraform state show module.vpc.aws_vpc.main
terraform state show module.vpc.aws_subnet.public
terraform state show module.ec2.aws_security_group.web
terraform state show module.ec2.aws_instance.web
terraform output
terraform graph | dot -Tpng > graph.png
open graph.png
terraform destroy
```

---

# 17. Interview Points You Must Know

## What is a module?

A reusable Terraform configuration block.

## Root module vs child module

* root module = where Terraform commands run
* child module = module called by root module

## How do modules communicate?

Through outputs and input variables.

Example:

```hcl
subnet_id = module.vpc.subnet_id
```

## Why use modules?

* reuse
* standardization
* easier maintenance
* less duplication

## Why not hardcode AMI?

Because AMIs are region-specific and may become invalid.

## Why separate variables.tf, main.tf, outputs.tf?

Because each file has one purpose:

* `main.tf` = resources/logic
* `variables.tf` = input definitions
* `outputs.tf` = returned values

---

# 18. One More Useful Command Set

To see all Terraform-related files in current folder:

```bash
ls -la
```

After init you will see things like:

* `.terraform/`
* `.terraform.lock.hcl`
* `terraform.tfstate`
* `terraform.tfstate.backup`

To inspect them:

```bash
cat .terraform.lock.hcl
cat terraform.tfstate
```

Usually `terraform.tfstate` is large, so better:

```bash
less terraform.tfstate
```

---

# 19. Final Short Explanation of the Design

This lab is written this way because:

* `modules/vpc` has only VPC-related logic
* `modules/ec2` has only EC2-related logic
* `env/dev` acts as the controller
* variables make modules reusable
* outputs allow modules to connect
* dynamic AMI avoids hardcoding problems
* security group makes the server actually usable
* tags make the infrastructure closer to production style


