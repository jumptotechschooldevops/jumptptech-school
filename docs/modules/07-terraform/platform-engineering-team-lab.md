---
title: "PLATFORM ENGINEERING TEAM LAB"
description: "Big Ecommerce Organization — Production-Grade Terraform Modules            Company..."
published: 2026-03-25
source: "https://dev.to/jumptotech/platform-engineering-team-lab-3cim"
tags: []
---

# PLATFORM ENGINEERING TEAM LAB





## Big Ecommerce Organization — Production-Grade Terraform Modules

## Company Scenario

You are part of the **Platform Engineering team** for a large ecommerce company.

The company has:

* customer-facing web applications
* internal APIs
* background workers
* object storage
* monitoring
* security controls

Your job is **not** to create random Terraform resources.

Your job is to create a **production-grade reusable Terraform module**, the way real platform engineers do in companies.

Each engineer owns one module.

Each module must:

* be reusable
* use variables
* use outputs
* follow clean structure
* support tags
* support environment naming
* be pushed in your own branch
* be submitted through Pull Request

---

# COMMON RULES FOR ALL STUDENTS

## Repository workflow

Use only your own branch.

```bash
git fetch
git checkout YOUR_BRANCH
git pull origin YOUR_BRANCH
```

After work:

```bash
git add .
git commit -m "added production-grade <module-name> module"
git push origin YOUR_BRANCH
```

Then create Pull Request:

* base = `main`
* compare = your branch

---

## Required Terraform module structure

Every student must create this structure:

```bash
modules/<module-name>/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required production-grade standards

Every module must include:

* variables instead of hardcoded values
* tags support
* environment support
* project name support
* clear outputs
* reusable naming convention
* README with explanation

Recommended naming pattern:

```hcl
"${var.project_name}-${var.environment}-${var.name}"
```

Common tags pattern:

```hcl
tags = merge(var.tags, {
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "Terraform"
})
```

---

## README must include

Each student must explain:

1. What this module creates
2. Why this module is needed in ecommerce platform
3. What variables are required
4. What outputs are returned
5. Example usage

---

# STUDENT 1 — AISEL89

## Task: Create a Production-Grade S3 Module for Ecommerce Assets

### Business scenario

The ecommerce company needs a reusable module for S3 buckets used for:

* product images
* invoices
* exports
* uploaded customer files

You must build a reusable **S3 bucket module**.

---

## What your module must support

Your module must create:

* S3 bucket
* versioning
* server-side encryption
* block public access settings
* bucket tags

Optional if you want extra credit:

* lifecycle rule
* bucket policy toggle

---

## Folder structure

```bash
modules/s3_bucket/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required variables

Your `variables.tf` should include at least:

* `project_name`
* `environment`
* `bucket_name`
* `enable_versioning`
* `tags`

---

## Required outputs

Your `outputs.tf` should include:

* bucket id
* bucket arn
* bucket name

---

## Example usage to put in README

```hcl
module "product_assets_bucket" {
  source = "./modules/s3_bucket"

  project_name      = "ecommerce"
  environment       = "prod"
  bucket_name       = "product-assets"
  enable_versioning = true

  tags = {
    Team = "platform"
    App  = "catalog"
  }
}
```

---

## What you should explain in README

Explain:

* why versioning matters in production
* why encryption matters
* why public access should be blocked by default
* how this module can be reused by many teams

---

# STUDENT 2 — AIZADA88

## Task: Create a Production-Grade Security Group Module

### Business scenario

The ecommerce company needs a reusable module for security groups for:

* web tier
* app tier
* internal services
* admin access

You must create a reusable **security group module**.

---

## What your module must support

Your module must create:

* security group
* ingress rules using variables
* egress rules using variables
* tags
* reusable naming

The goal is to avoid hardcoding ports directly in resource blocks.

---

## Folder structure

```bash
modules/security_group/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required variables

Your module should support at least:

* `project_name`
* `environment`
* `name`
* `vpc_id`
* `ingress_rules`
* `egress_rules`
* `tags`

Example variable type idea:

```hcl
list(object({
  from_port   = number
  to_port     = number
  protocol    = string
  cidr_blocks = list(string)
  description = string
}))
```

---

## Required outputs

* security group id
* security group arn
* security group name

---

## Example usage for README

```hcl
module "web_sg" {
  source      = "./modules/security_group"
  project_name = "ecommerce"
  environment  = "prod"
  name         = "web"
  vpc_id       = "vpc-123456"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound"
    }
  ]

  tags = {
    Team = "platform"
  }
}
```

---

## What you should explain in README

Explain:

* why security groups should be reusable
* why dynamic ingress/egress rules are better than hardcoding
* how platform teams standardize security using modules

---

# STUDENT 3 — ASYLTASH

## Task: Create a Production-Grade EC2 Module for Application Nodes

### Business scenario

The ecommerce company runs internal application servers for legacy workloads and support tools.

You must create a reusable **EC2 module** for application instances.

---

## What your module must support

Your module must create:

* EC2 instance
* root volume configuration
* security group attachment
* subnet assignment
* tags
* environment-based naming

Optional extra credit:

* user_data support
* IAM instance profile support

---

## Folder structure

```bash
modules/ec2_instance/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required variables

At minimum:

* `project_name`
* `environment`
* `name`
* `ami_id`
* `instance_type`
* `subnet_id`
* `security_group_ids`
* `key_name`
* `tags`

Optional:

* `user_data`
* `volume_size`

---

## Required outputs

* instance id
* private ip
* public ip
* instance arn

---

## Example usage for README

```hcl
module "orders_app" {
  source             = "./modules/ec2_instance"
  project_name       = "ecommerce"
  environment        = "prod"
  name               = "orders-app"
  ami_id             = "ami-xxxxxxxx"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-xxxxxxxx"
  security_group_ids = ["sg-xxxxxxxx"]
  key_name           = "ecommerce-key"

  tags = {
    Team = "platform"
    App  = "orders"
  }
}
```

---

## What you should explain in README

Explain:

* why EC2 should be standardized through modules
* why platform teams avoid copy-paste EC2 code
* why variables and outputs make the module reusable

---

# STUDENT 4 — GULJANKA

## Task: Create a Production-Grade IAM Role Module for Application Access

### Business scenario

Applications in the ecommerce platform need IAM roles to access AWS services securely.

You must create a reusable **IAM role module**.

---

## What your module must support

Your module must create:

* IAM role
* assume role policy
* optional inline policy or attachable policy support
* tags
* reusable naming

Good example use cases:

* app can read from S3
* worker can write logs
* service can access SQS

---

## Folder structure

```bash
modules/iam_role/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required variables

At minimum:

* `project_name`
* `environment`
* `name`
* `assume_role_policy_json`
* `tags`

Optional:

* `policy_json`
* `managed_policy_arns`

---

## Required outputs

* role name
* role arn
* role id

---

## Example usage for README

```hcl
module "orders_app_role" {
  source                  = "./modules/iam_role"
  project_name            = "ecommerce"
  environment             = "prod"
  name                    = "orders-app-role"
  assume_role_policy_json = data.aws_iam_policy_document.ec2_assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Team = "platform"
    App  = "orders"
  }
}
```

---

## What you should explain in README

Explain:

* why IAM roles are better than access keys
* why reusable IAM modules are important in enterprise environments
* how least privilege applies in production

---

# STUDENT 5 — MIRACLESHAPPEN7

## Task: Create a Production-Grade VPC Module

### Business scenario

The ecommerce company needs a reusable network foundation for new environments.

You must create a reusable **VPC module**.

This is a foundational platform module.

---

## What your module must support

Your module must create:

* VPC
* public subnets
* private subnets
* internet gateway
* public route table
* route table associations
* tags
* naming convention

Optional extra credit:

* NAT gateway
* private route table

---

## Folder structure

```bash
modules/vpc/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## Required variables

At minimum:

* `project_name`
* `environment`
* `vpc_cidr`
* `public_subnet_cidrs`
* `private_subnet_cidrs`
* `availability_zones`
* `tags`

---

## Required outputs

* vpc id
* public subnet ids
* private subnet ids
* internet gateway id

---

## Example usage for README

```hcl
module "prod_vpc" {
  source               = "./modules/vpc"
  project_name         = "ecommerce"
  environment          = "prod"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["us-east-2a", "us-east-2b"]

  tags = {
    Team = "platform"
  }
}
```



## Step 2 — Write the module

Use:

* variables in `variables.tf`
* resources in `main.tf`
* outputs in `outputs.tf`
* explanation and example usage in `README.md`

---

## Step 3 — Validate your Terraform

From repository root:

```bash
terraform fmt -recursive
terraform validate
```

If validate does not work because there is no root config yet, at minimum run:

```bash
terraform fmt -recursive
```

And make sure syntax is correct.

---

## Step 4 — Push to your own branch

```bash
git add .
git commit -m "added production-grade <module-name> module"
git push origin YOUR_BRANCH
```

---

## Step 5 — Create Pull Request

Create PR from:

* your branch
* into `main`


This is not a basic resource-creation task.

This is a **real platform engineering exercise**.

In real companies:

* platform teams build reusable modules
* application teams consume those modules
* code must be clean, reusable, and production-ready
* everything goes through Git branches and Pull Requests

---

# FINAL SUBMISSION REQUIREMENTS FOR EVERY STUDENT

Each student must submit:

* `main.tf`
* `variables.tf`
* `outputs.tf`
* `README.md`

 module must show:

* reusability
* production naming
* tag support
* environment awareness
* good structure


After that:

* commit
* push to your own branch
* create Pull Request to `main`


