---
title: "7 labs that covers all topics of terraform cert, interview"
description: "Lab 1 — Remote Backend with S3 and DynamoDB            What this lab teaches   This lab..."
published: 2026-04-04
source: "https://dev.to/jumptotech/7-labs-that-covers-all-topics-of-terraform-cert-interview-1gp6"
tags: []
---

# 7 labs that covers all topics of terraform cert, interview




# Lab 1 — Remote Backend with S3 and DynamoDB

## What this lab teaches

This lab teaches how to move Terraform state from a local machine into AWS so a team can work safely.

It covers:

* remote state
* state locking
* backend configuration
* bootstrap concept

## Why a DevOps engineer needs this

In real projects, local state is not enough. If two engineers run `terraform apply` from different laptops, state can be corrupted or overwritten. A remote backend solves that problem.

This is one of the most common interview topics because it shows whether the candidate understands how Terraform is used in a team.

---

## Folder structure

```text
lab1-remote-backend/
├── bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── versions.tf
```

---

## File-by-file explanation

### `versions.tf`

This file defines the Terraform version and provider version.
We keep version rules separate so the project is easier to maintain and upgrade.

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

### `variables.tf`

This file defines all inputs.
We do this to avoid hardcoding values directly inside resources.

```hcl
variable "aws_region" {
  description = "AWS region where backend resources will be created"
  type        = string
}

variable "state_bucket_name" {
  description = "Unique S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to backend resources"
  type        = map(string)
  default     = {}
}
```

### `main.tf`

This file contains the actual backend infrastructure.

We create:

* an S3 bucket for the Terraform state file
* a DynamoDB table for state locking
* bucket versioning because state history matters
* bucket encryption because state may contain sensitive data

This is written this way because a senior DevOps engineer should protect Terraform state, not just store it.

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  tags = merge(var.common_tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name = var.lock_table_name
  })
}
```

### `outputs.tf`

This file exposes the names you will later use in backend configuration.

We keep outputs separate so the important values are easy to find after apply.

```hcl
output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.lock.name
}
```

### `terraform.tfvars`

This file holds environment-specific values.
This is where real values belong, not inside `main.tf`.

```hcl
aws_region        = "us-east-1"
state_bucket_name = "replace-with-your-unique-state-bucket-name"
lock_table_name   = "terraform-state-locks"

common_tags = {
  Project   = "terraform-lab1"
  ManagedBy = "Terraform"
  Owner     = "DevOps"
}
```

---

## How to run

```bash
cd lab1-remote-backend/bootstrap
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After apply, Terraform will show the bucket and table names.

---

you should be able to explain:

* why local state is risky
* why DynamoDB locking is needed
* why backend resources are usually created first in a bootstrap step
* why versioning and encryption are important for state

---

# Lab 2 — Reusable Module for EC2

## What this lab teaches

This lab teaches how to write and consume a Terraform module.

It covers:

* module structure
* variables
* outputs
* parent-child relationship
* reusable infrastructure

## Why a DevOps engineer needs this

In real teams, nobody wants the same EC2 resource copied 20 times in different folders. Modules reduce duplication and enforce standards.

This is heavily asked in interviews because it shows whether the candidate knows how to organize Terraform for scale.

---

## Folder structure

```text
lab2-modules-ec2/
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── envs/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── versions.tf
```

---

## File-by-file explanation

## Module files

### `modules/ec2/variables.tf`

This file defines what the module expects from the caller.



```hcl
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}
```

### `modules/ec2/main.tf`

This is the reusable EC2 logic.

We use variables instead of hardcoded values because a module should not know whether it is used in dev, stage, or prod.

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })
}
```

### `modules/ec2/outputs.tf`

This exposes useful values back to the parent.

A parent module often needs instance ID, private IP, or public IP.

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.this.public_ip
}
```

---

## Environment files

### `envs/dev/versions.tf`

Separate version file for the environment layer.

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

### `envs/dev/variables.tf`

Defines the inputs the environment will use.

```hcl
variable "aws_region" {
  description = "AWS region for this environment"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for dev instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for dev"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

### `envs/dev/main.tf`

This file is the caller of the module.

We place the provider here because this layer decides where the module will run.
We call the module with input values so the same module can be used again for other environments.

```hcl
provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
  common_tags   = var.common_tags
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}
```

### `envs/dev/terraform.tfvars`

Real values live here.

```hcl
aws_region    = "us-east-1"
ami_id        = "replace-with-valid-ami-id"
instance_type = "t2.micro"
instance_name = "lab2-dev-ec2"

common_tags = {
  Project   = "terraform-lab2"
  Environment = "dev"
  ManagedBy = "Terraform"
}
```

---

## How to run

```bash
cd lab2-modules-ec2/envs/dev
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

---



They should be able to explain:

* what a module is
* why modules reduce repetition
* why outputs are needed
* why provider stays in the root caller, not usually inside the child module

---

# Lab 3 — User Data with `templatefile()`

## What this lab teaches

This lab teaches how to use a script template to bootstrap an EC2 instance automatically.

It covers:

* `templatefile()`
* `user_data`
* variables inside scripts
* infrastructure plus basic server bootstrapping

## Why a DevOps engineer needs this

Manual server setup is not scalable. A DevOps engineer should be able to provision infrastructure and configure the instance at launch time.

This is useful for both interviews and real projects because it connects Terraform with actual machine configuration.

---

## Folder structure

```text
lab3-userdata-templatefile/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── user_data.sh.tpl
└── versions.tf
```

---

## File-by-file explanation

### `versions.tf`

Keeps version rules in one place.

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

### `variables.tf`

We define all configurable values here, including the message we want written by the script.

```hcl
variable "aws_region" {
  description = "AWS region"
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

variable "instance_name" {
  description = "EC2 name"
  type        = string
}

variable "startup_message" {
  description = "Message written by user_data"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

### `user_data.sh.tpl`

This is a template file, not a plain shell script.

We write `${startup_message}` here because Terraform will replace it dynamically when rendering the file.

```bash
#!/bin/bash
set -e

mkdir -p /tmp/terraform-lab
echo "${startup_message}" > /tmp/terraform-lab/message.txt
```

### `main.tf`

This is written with `templatefile()` because we want the script to stay readable and maintainable.
Inline multi-line shell scripts inside Terraform become messy quickly.

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    startup_message = var.startup_message
  })

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })
}
```

### `outputs.tf`

We expose useful information for verification.

```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

### `terraform.tfvars`

```hcl
aws_region      = "us-east-1"
ami_id          = "replace-with-valid-ami-id"
instance_type   = "t2.micro"
instance_name   = "lab3-userdata-instance"
startup_message = "Terraform user_data executed successfully"

common_tags = {
  Project   = "terraform-lab3"
  ManagedBy = "Terraform"
}
```

---

## How to run

```bash
cd lab3-userdata-templatefile
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After creation, connect to the instance and verify:

```bash
cat /tmp/terraform-lab/message.txt
```

---


you should be able to explain:

* why `templatefile()` is cleaner than a huge inline script
* what `user_data` does
* when `user_data` is enough and when configuration management tools may be needed

---

# Lab 4 — Networking Dependency, Lifecycle, and Outputs

## What this lab teaches

This lab teaches Terraform dependency flow by creating:

* a security group
* an EC2 instance attached to that security group

It covers:

* implicit dependency
* explicit dependency
* `lifecycle`
* outputs

## Why a DevOps engineer needs this

Dependency handling is one of Terraform’s most important concepts. Interviews often ask whether Terraform needs `depends_on` all the time, or when it should be used.

This lab shows the difference between Terraform understanding dependency automatically versus forcing order manually.

---

## Folder structure

```text
lab4-dependencies-lifecycle/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── versions.tf
```

---

## File-by-file explanation

### `versions.tf`

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

### `variables.tf`

We keep networking and compute inputs here so the resource code stays generic.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
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

variable "instance_name" {
  description = "EC2 name"
  type        = string
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

### `main.tf`

This file demonstrates dependency behavior.

The EC2 resource references the security group ID, so Terraform already knows the order. That is an **implicit dependency**.

I also included a `lifecycle` block because it is commonly discussed in interviews. Here we use `create_before_destroy` as an example of safe replacement strategy.

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web" {
  name        = var.security_group_name
  description = "Security group for lab4 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = var.security_group_name
  })
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })
}
```

### `outputs.tf`

Outputs help students see the created dependencies clearly.

```hcl
output "security_group_id" {
  value = aws_security_group.web.id
}

output "instance_id" {
  value = aws_instance.web.id
}
```

### `terraform.tfvars`

```hcl
aws_region          = "us-east-1"
vpc_id              = "replace-with-your-vpc-id"
ami_id              = "replace-with-valid-ami-id"
instance_type       = "t2.micro"
instance_name       = "lab4-web-instance"
security_group_name = "lab4-web-sg"
allowed_ssh_cidr    = "0.0.0.0/0"

common_tags = {
  Project   = "terraform-lab4"
  ManagedBy = "Terraform"
}
```

---

## How to run

```bash
cd lab4-dependencies-lifecycle
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

---

you should be able to explain:

* why the EC2 depends on the security group even without `depends_on`
* what implicit dependency means
* when `depends_on` is needed
* why `lifecycle` can reduce downtime or control replacement behavior

---

# Lab 5 — Import Existing Resource and Inspect State

## What this lab teaches

This lab teaches how to bring existing infrastructure under Terraform management.

It covers:

* `terraform import`
* state inspection
* understanding configuration vs state
* existing resource adoption

## Why a DevOps engineer needs this

In many real companies, infrastructure already exists before Terraform arrives. A DevOps engineer must know how to import resources instead of recreating them.

This is a common interview topic because it tests whether the candidate understands that Terraform is not only for new infrastructure.

---

## Folder structure

```text
lab5-import-state/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── versions.tf
```

---

## File-by-file explanation

### `versions.tf`

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

### `variables.tf`

We define the bucket name and region here because the configuration should match the imported object using variables, not literals spread around the code.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "bucket_name" {
  description = "Existing S3 bucket name to import"
  type        = string
}
```

### `main.tf`

This file defines the resource block Terraform needs in order to map the imported infrastructure.

This resource should describe the existing bucket, not create a new one with some random hardcoded settings.

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}
```

### `terraform.tfvars`

```hcl
aws_region  = "us-east-1"
bucket_name = "replace-with-existing-bucket-name"
```

---

## How to run

First initialize:

```bash
cd lab5-import-state
terraform init
terraform fmt
terraform validate
```

Then import the existing bucket:

```bash
terraform import aws_s3_bucket.existing replace-with-existing-bucket-name
```

Now inspect state:

```bash
terraform state list
terraform state show aws_s3_bucket.existing
```

Then compare configuration with actual resource:

```bash
terraform plan
```

If Terraform wants to change something, that means your configuration does not yet fully match the real bucket.

---

you should be able to explain:

* import does not write full configuration automatically
* import puts the resource into state
* configuration must still be written correctly
* `terraform state show` helps inspect imported objects
























# 🔥 LAB 1 — Remote Backend (S3 + DynamoDB)

## 🎯 Purpose

Safe team collaboration using remote state + locking

---

## 📁 Structure

```bash
lab1-remote-backend/
└── bootstrap/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── versions.tf
```

---

## 📄 versions.tf

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

---

## 📄 variables.tf

```hcl
variable "aws_region" {}
variable "state_bucket_name" {}
variable "lock_table_name" {}
```

---

## 📄 main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}

resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

---

## 📄 outputs.tf

```hcl
output "bucket" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.lock.name
}
```

---

## 📄 terraform.tfvars

```hcl
aws_region        = "us-east-1"
state_bucket_name = "REPLACE_UNIQUE_BUCKET"
lock_table_name   = "terraform-lock"
```

---

## ▶️ Run

```bash
cd lab1-remote-backend/bootstrap
terraform init
terraform apply
```

---

## 🧹 Destroy

```bash
terraform destroy
```

---

## 🎤 Interview Questions

* Why remote backend?
* What happens without locking?
* Why DynamoDB used?

---

# 🔥 LAB 2 — Modules (Reusable EC2)

## 🎯 Purpose

Reusable infrastructure design

---

## 📁 Structure

```bash
lab2-modules/
├── modules/ec2/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── envs/dev/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── versions.tf
```

---

## 📄 modules/ec2/main.tf

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

---

## 📄 modules/ec2/variables.tf

```hcl
variable "ami_id" {}
variable "instance_type" {}
variable "instance_name" {}
```

---

## 📄 modules/ec2/outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

---

## 📄 envs/dev/main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
}
```

---

## 📄 envs/dev/variables.tf

```hcl
variable "aws_region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "instance_name" {}
```

---

## 📄 envs/dev/terraform.tfvars

```hcl
aws_region    = "us-east-1"
ami_id        = "REPLACE_AMI"
instance_type = "t2.micro"
instance_name = "lab2-instance"
```

---

## 📄 envs/dev/versions.tf

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

---

## ▶️ Run

```bash
cd lab2-modules/envs/dev
terraform init
terraform apply
```

---

## 🧹 Destroy

```bash
terraform destroy
```

---

## 🎤 Interview Questions

* What is module?
* Why not copy paste resources?
* Module vs resource?

---

# 🔥 LAB 3 — User Data + Templatefile

## 🎯 Purpose

Automate server setup

---

## 📁 Structure

```bash
lab3-userdata/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── user_data.sh.tpl
└── versions.tf
```

---

## 📄 user_data.sh.tpl

```bash
#!/bin/bash
echo "${message}" > /tmp/info.txt
```

---

## 📄 main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    message = var.message
  })
}
```

---

## 📄 variables.tf

```hcl
variable "aws_region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "message" {}
```

---

## 📄 terraform.tfvars

```hcl
aws_region    = "us-east-1"
ami_id        = "REPLACE_AMI"
instance_type = "t2.micro"
message       = "Hello from Terraform"
```

---

## ▶️ Run

```bash
cd lab3-userdata
terraform init
terraform apply
```

---

## 🧹 Destroy

```bash
terraform destroy
```

---

## 🎤 Interview Questions

* What is user_data?
* Why templatefile?
* Difference user_data vs provisioner?

---

# 🔥 LAB 4 — Dependency + Lifecycle

## 🎯 Purpose

Understand resource order and safe replacement

---

## 📁 Structure

```bash
lab4-dependency/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── versions.tf
```

---

## 📄 main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "sg" {
  name   = var.sg_name
  vpc_id = var.vpc_id
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.sg.id]

  lifecycle {
    create_before_destroy = true
  }
}
```

---

## 📄 variables.tf

```hcl
variable "aws_region" {}
variable "vpc_id" {}
variable "ami_id" {}
variable "instance_type" {}
variable "sg_name" {}
```

---

## 📄 terraform.tfvars

```hcl
aws_region    = "us-east-1"
vpc_id        = "REPLACE_VPC"
ami_id        = "REPLACE_AMI"
instance_type = "t2.micro"
sg_name       = "lab4-sg"
```

---

## ▶️ Run

```bash
cd lab4-dependency
terraform init
terraform apply
```

---

## 🧹 Destroy

```bash
terraform destroy
```

---

## 🎤 Interview Questions

* What is implicit dependency?
* When use depends_on?
* What is lifecycle?

---

# 🔥 LAB 5 — Import + State

## 🎯 Purpose

Manage existing infrastructure

---

## 📁 Structure

```bash
lab5-import/
├── main.tf
├── variables.tf
├── terraform.tfvars
└── versions.tf
```

---

## 📄 main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}
```

---

## 📄 variables.tf

```hcl
variable "aws_region" {}
variable "bucket_name" {}
```

---

## 📄 terraform.tfvars

```hcl
aws_region  = "us-east-1"
bucket_name = "EXISTING_BUCKET"
```

---

## ▶️ Run

```bash
cd lab5-import
terraform init

terraform import aws_s3_bucket.existing EXISTING_BUCKET

terraform state list
terraform state show aws_s3_bucket.existing
```

---

## 🧹 Destroy

⚠️ Usually NOT recommended after import

---

## 🎤 Interview Questions

* What does import do?
* Does import create config?
* What is state drift?























# Lab  — Locals + Data Sources + for_each



This lab teaches how to:

* avoid repetition with `locals`
* read existing AWS information using `data` blocks
* create multiple resources cleanly with `for_each`

---

## Why a DevOps engineer needs this

### Why `locals`

In real projects, you repeat values like:

* project name
* environment
* common tags
* naming patterns

If you repeat them everywhere, code becomes messy and error-prone.
`locals` lets you define them once and reuse them.

### Why `data sources`

Not everything should be created by Terraform.
Sometimes DevOps engineers need to **read existing infrastructure**, such as:

* default VPC
* latest AMI
* existing subnet
* account information

That is what `data` blocks are for.

### Why `for_each`

In real environments, you often need:

* multiple security groups
* multiple buckets
* multiple IAM users
* multiple subnets

You should not copy and paste the same resource many times.
`for_each` lets you create many resources from a map or set in a clean way.

---

# What this lab builds

This lab will:

* read the **default VPC**
* read the **latest Amazon Linux 2023 AMI**
* define reusable naming and tags using `locals`
* create **multiple security groups** using `for_each`

This is a very realistic pattern.

---

# Folder structure

```text
lab6-locals-data-for-each/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── versions.tf
```

---

# File-by-file explanation

## 1) `versions.tf`

### Why we need this file

This file controls Terraform version and provider version.
It keeps version requirements separate from resource logic.

### Why the code is written this way

A professional Terraform project should pin provider versions so the code behaves predictably across laptops and pipelines.

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

---

## 2) `variables.tf`

### Why we need this file

This file defines all input values for the lab.
We keep inputs here so the main resource code stays reusable and clean.

### Why the code is written this way

Instead of hardcoding values like project name or region inside resources, we define them as variables and pass real values through `terraform.tfvars`.

```hcl
variable "aws_region" {
  description = "AWS region where resources will be managed"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, stage, or prod"
  type        = string
}

variable "security_groups" {
  description = "Map of security groups to create"
  type = map(object({
    description = string
  }))
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
```

---

## 3) `main.tf`

### Why we need this file

This is the main logic of the lab.
It contains:

* provider
* locals
* data sources
* resources created with `for_each`

### Why the code is written this way

Each section has a purpose:

* `provider` tells Terraform which AWS region to use
* `locals` reduces repetition
* `data` blocks read existing AWS information instead of creating it
* `for_each` creates multiple security groups from one resource block

```hcl
provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  merged_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}
```

---

## 4) `outputs.tf`

### Why we need this file

Outputs help students verify what Terraform created and what data Terraform read from AWS.

### Why the code is written this way

We expose:

* default VPC ID from the data source
* AMI ID from the data source
* security group IDs from the `for_each` resource

This helps students understand both reading and creating infrastructure.

```hcl
output "default_vpc_id" {
  description = "Default VPC ID read from AWS"
  value       = data.aws_vpc.default.id
}

output "latest_amazon_linux_2023_ami" {
  description = "Latest Amazon Linux 2023 AMI ID"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "security_group_ids" {
  description = "IDs of created security groups"
  value = {
    for sg_name, sg in aws_security_group.this : sg_name => sg.id
  }
}
```

---

## 5) `terraform.tfvars`

### Why we need this file

This file stores the real values for this lab.

### Why the code is written this way

We keep environment values here so students can change project name, environment, or security groups without touching the core Terraform code.

```hcl
aws_region   = "us-east-1"
project_name = "terraform-lab6"
environment  = "dev"

security_groups = {
  app = {
    description = "Security group for application servers"
  }
  db = {
    description = "Security group for database servers"
  }
  monitoring = {
    description = "Security group for monitoring tools"
  }
}

common_tags = {
  Owner = "DevOps"
}
```

---

# Exact run steps

## Step 1 — go to the lab folder

```bash
cd lab6-locals-data-for-each
```

## Step 2 — initialize Terraform

```bash
terraform init
```

## Step 3 — format the code

```bash
terraform fmt
```

## Step 4 — validate the code

```bash
terraform validate
```

## Step 5 — review execution plan

```bash
terraform plan
```

## Step 6 — create resources

```bash
terraform apply
```

Type:

```bash
yes
```

when Terraform asks for confirmation.

---

# How to verify

After apply, check the outputs:

```bash
terraform output
```

You should see:

* default VPC ID
* latest Amazon Linux 2023 AMI
* security group IDs

You can also check in AWS Console:

* VPC → Security Groups

You should see 3 security groups created:

* `terraform-lab6-dev-app`
* `terraform-lab6-dev-db`
* `terraform-lab6-dev-monitoring`

---

# Destroy steps

```bash
terraform destroy
```

Type:

```bash
yes
```

---



you should be able to explain:

### About `locals`

* `locals` are used to avoid repeating values
* they make naming and tagging cleaner
* they improve readability

### About `data sources`

* data sources read existing infrastructure
* they do not create resources
* they are used when Terraform must reference something AWS already has

### About `for_each`

* `for_each` creates multiple resources from one block
* it is better than copy-paste
* it is useful when each resource needs a unique name or configuration

---

# Interview questions for this lab

Use these with students:

1. What is the difference between a variable and a local?
2. Why would you use a data source instead of a resource?
3. What is the difference between `for_each` and `count`?
4. Why is `for_each` often preferred over copy-paste?
5. Can a data source create infrastructure?
6. Why is naming usually built with `locals`?
7. In a real project, what kinds of things do you read with data sources?

---

# Short interview-style answers

## What are locals in Terraform?

Locals are named values used inside a Terraform configuration to reduce repetition and improve readability.

## Why do we use data sources?

We use data sources to read existing infrastructure information, like a VPC, subnet, AMI, or account details, without creating those resources.

## Why use for_each?

We use `for_each` to create multiple similar resources from a map or set without duplicating code.

## for_each vs count?

`count` is index-based, while `for_each` is key-based. `for_each` is usually better when resources have unique names or identities.


