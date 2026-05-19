---
title: "lab: centralized terraform module support"
description: "Real Production Idea   A platform team maintains one Terraform repository.  Application..."
published: 2026-03-23
source: "https://dev.to/jumptotech/lab-centralized-terraform-module-support-28"
tags: []
---

# lab: centralized terraform module support



# Real Production Idea

A platform team maintains one Terraform repository.

Application teams do **not** copy Terraform code.

Instead:

* platform team writes reusable modules
* root module calls the centralized module for each team and region
* adding a team means adding one config entry
* Terraform sees new keys and creates only new resources

This is how you avoid:

* code duplication
* inconsistent environments
* dangerous changes
* one team overwriting another team

---

# Final Project Structure

```bash
terraform-centralized-modules-lab/
├── modules/
│   └── ecr_repositories/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── envs/
│   └── prod/
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── versions.tf
│       └── outputs.tf
│
└── README.md
```

---

# Architecture

We will create:

* same centralized child module
* called once for **us-east-2**
* called once for **us-west-1**
* each module call creates repositories for **all teams defined for that region**

Example:

* team1 in us-east-2
* team2 in us-east-2 and us-west-1
* team3 later added

When you add team3:

* Terraform creates only team3 repositories
* existing team1 and team2 remain untouched

That is the key production behavior.

---

# PART 1 — versions.tf

File:

`envs/prod/versions.tf`

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

# PART 2 — providers.tf

File:

`envs/prod/providers.tf`

```hcl
provider "aws" {
  alias  = "use2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "usw1"
  region = "us-west-1"
}
```

Why aliases?

Because this is how Terraform manages **multiple AWS regions** in one configuration.

A senior DevOps engineer must know:

* one default provider is not enough for multi-region
* provider aliases are required
* modules can receive a specific aliased provider

---

# PART 3 — root variables.tf

File:

`envs/prod/variables.tf`

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "teams_by_region" {
  description = "Team configuration organized by region"
  type = map(map(object({
    repositories = list(string)
    scan_on_push = bool
    mutable_tags = bool
    max_images   = number
    team_owner   = string
  })))
}
```

---

# PART 4 — root terraform.tfvars

File:

`envs/prod/terraform.tfvars`

```hcl
environment = "prod"

common_tags = {
  ManagedBy   = "Terraform"
  Environment = "prod"
  Project     = "central-ecr-platform"
}

teams_by_region = {
  us-east-2 = {
    team-alpha = {
      repositories = ["frontend", "backend", "worker"]
      scan_on_push = true
      mutable_tags = false
      max_images   = 20
      team_owner   = "team-alpha"
    }

    team-beta = {
      repositories = ["api", "jobs"]
      scan_on_push = true
      mutable_tags = false
      max_images   = 15
      team_owner   = "team-beta"
    }
  }

  us-west-1 = {
    team-beta = {
      repositories = ["api", "jobs"]
      scan_on_push = true
      mutable_tags = false
      max_images   = 15
      team_owner   = "team-beta"
    }

    team-gamma = {
      repositories = ["payments", "reporting"]
      scan_on_push = true
      mutable_tags = true
      max_images   = 10
      team_owner   = "team-gamma"
    }
  }
}
```

This file is the whole idea.

Production teams usually just update configuration like this.

They do **not** rewrite resource code.

---

# PART 5 — child module variables.tf

File:

`modules/ecr_repositories/variables.tf`

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region for repository creation"
  type        = string
}

variable "teams" {
  description = "Teams and their repository configuration for this region"
  type = map(object({
    repositories = list(string)
    scan_on_push = bool
    mutable_tags = bool
    max_images   = number
    team_owner   = string
  }))
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
```

---

# PART 6 — child module main.tf

File:

`modules/ecr_repositories/main.tf`

```hcl
locals {
  repo_matrix = merge([
    for team_name, team_data in var.teams : {
      for repo_name in team_data.repositories :
      "${team_name}-${repo_name}" => {
        team_name    = team_name
        repo_name    = repo_name
        scan_on_push = team_data.scan_on_push
        mutable_tags = team_data.mutable_tags
        max_images   = team_data.max_images
        team_owner   = team_data.team_owner
      }
    }
  ]...)
}

resource "aws_ecr_repository" "this" {
  for_each = local.repo_matrix

  name                 = "${var.environment}/${each.value.team_name}/${each.value.repo_name}"
  image_tag_mutability = each.value.mutable_tags ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  force_delete = false

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${each.value.team_name}-${each.value.repo_name}"
      Team        = each.value.team_name
      TeamOwner   = each.value.team_owner
      Repository  = each.value.repo_name
      Region      = var.region
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = local.repo_matrix

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last ${each.value.max_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.max_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

---

# Why this design is production-safe

The most important part is this:

```hcl
for_each = local.repo_matrix
```

And keys like:

```hcl
"${team_name}-${repo_name}"
```

That means Terraform tracks resources using **stable keys**.

Example:

* `team-alpha-frontend`
* `team-alpha-backend`
* `team-beta-api`

If later you add:

* `team-delta-api`

Terraform creates only:

* `team-delta-api`

It does **not** renumber existing resources.

This is why `for_each` is safer than `count`.

---

# PART 7 — child module outputs.tf

File:

`modules/ecr_repositories/outputs.tf`

```hcl
output "repository_urls" {
  description = "Map of repository URLs"
  value = {
    for k, v in aws_ecr_repository.this : k => v.repository_url
  }
}

output "repository_names" {
  description = "Map of repository names"
  value = {
    for k, v in aws_ecr_repository.this : k => v.name
  }
}
```

---

# PART 8 — root main.tf

File:

`envs/prod/main.tf`

```hcl
module "ecr_use2" {
  source = "../../modules/ecr_repositories"

  providers = {
    aws = aws.use2
  }

  environment = var.environment
  region      = "us-east-2"
  teams       = lookup(var.teams_by_region, "us-east-2", {})
  common_tags = var.common_tags
}

module "ecr_usw1" {
  source = "../../modules/ecr_repositories"

  providers = {
    aws = aws.usw1
  }

  environment = var.environment
  region      = "us-west-1"
  teams       = lookup(var.teams_by_region, "us-west-1", {})
  common_tags = var.common_tags
}
```

This is the centralized pattern:

* same child module
* multiple regions
* different provider aliases
* region-specific team maps

---

# PART 9 — root outputs.tf

File:

`envs/prod/outputs.tf`

```hcl
output "us_east_2_repository_urls" {
  value = module.ecr_use2.repository_urls
}

output "us_west_1_repository_urls" {
  value = module.ecr_usw1.repository_urls
}
```

---

# PART 10 — How to run

Go into prod folder:

```bash
cd terraform-centralized-modules-lab/envs/prod
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Format:

```bash
terraform fmt -recursive
```

See plan:

```bash
terraform plan
```

Save plan:

```bash
terraform plan -out=tfplan
```

Apply:

```bash
terraform apply tfplan
```

See outputs:

```bash
terraform output
```

Destroy attempt:

```bash
terraform destroy
```

You will notice destroy will fail for protected repositories because of:

```hcl
lifecycle {
  prevent_destroy = true
}
```

That is intentional production safety.

---

# PART 11 — How to prove adding one team does not destroy others

## First apply

Start with:

* team-alpha
* team-beta
* team-gamma

Run:

```bash
terraform plan
terraform apply
```

## Then add new team

Edit `terraform.tfvars` and add:

```hcl
    team-delta = {
      repositories = ["orders", "billing"]
      scan_on_push = true
      mutable_tags = false
      max_images   = 25
      team_owner   = "team-delta"
    }
```

For example under `us-east-2`.

Run again:

```bash
terraform plan
```

You should see only new resources like:

* prod/team-delta/orders
* prod/team-delta/billing

No existing team should be destroyed.

That is exactly the production behavior you wanted.

---

# PART 12 — Why resources get destroyed in bad designs

Bad design usually comes from:

## 1. Using `count`

Example:

```hcl
count = length(var.teams)
```

If list order changes:

* team-alpha moves from index 0 to 1
* Terraform may think old resource must be destroyed and recreated

That is dangerous.

## 2. Using lists instead of maps

Bad:

```hcl
teams = ["team-alpha", "team-beta"]
```

Good:

```hcl
teams = {
  team-alpha = {...}
  team-beta  = {...}
}
```

Maps give stable keys.

## 3. Renaming keys carelessly

If you change:

```hcl
team-alpha
```

to

```hcl
team-a
```

Terraform sees that as:

* old resource removed
* new resource added

In production, that can be destructive.

---

# PART 13 — What a 6-year DevOps engineer must know about modules

A strong DevOps engineer should know these deeply.

## 1. What a module is

A module is a reusable Terraform package.

It contains:

* resources
* variables
* outputs

Types:

* root module
* child module

---

## 2. Root module vs child module

**Root module**

* the directory where you run Terraform commands

**Child module**

* called by the root module or another module

Example:

```hcl
module "ecr_use2" {
  source = "../../modules/ecr_repositories"
}
```

Here:

* `envs/prod` is root
* `modules/ecr_repositories` is child

---

## 3. Why modules matter in production

Modules solve:

* duplication
* standardization
* security consistency
* tagging consistency
* easier maintenance
* onboarding of new teams
* platform engineering scale

Without modules, every team writes resources differently.

That becomes chaos.

---

## 4. Input variables and outputs

Inputs:

* let callers customize the module

Outputs:

* expose created values back to caller

Example:

* module creates ECR repo
* output exposes repo URL
* another module or pipeline uses it

---

## 5. `for_each` vs `count`

Experienced engineers must know:

Use `for_each` when resources have identity.

Use `count` only for simple repeated identical resources.

For teams, services, repositories, users, buckets:

* prefer `for_each`

Why:

* stable keys
* safer changes
* less accidental destroy

---

## 6. Module versioning

In production you should version modules.

Examples:

```hcl
source = "git::https://github.com/company/terraform-modules.git//ecr?ref=v1.2.0"
```

Why version?

* reproducibility
* change control
* rollback
* safer promotion

A 6-year engineer should never blindly point production to moving `main` branch unless there is a deliberate platform process.

---

## 7. Backward compatibility

When updating modules:

* do not remove variables carelessly
* do not rename outputs casually
* do not change resource addresses without planning
* use `moved` blocks when refactoring

Example:

```hcl
moved {
  from = aws_ecr_repository.repo
  to   = aws_ecr_repository.this
}
```

This prevents unnecessary destroy/recreate during refactor.

---

## 8. Provider inheritance and aliases

Senior engineers must know:

* modules inherit providers from root unless overridden
* multi-region needs aliased providers
* multi-account often also uses aliased providers

Example:

```hcl
providers = {
  aws = aws.use2
}
```

---

## 9. Module composition

Good production design often composes modules:

* networking module
* IAM module
* ECR module
* ECS module
* monitoring module

One module should do one logical job.

Do not build one giant “everything module”.

That becomes hard to reuse and hard to test.

---

## 10. State implications

All module resources are still tracked in Terraform state.

Modules do not create separate state automatically.

A senior engineer must understand:

* module organization is not state isolation
* state isolation comes from separate root modules / workspaces / backends
* production often separates state by environment or domain

---

## 11. Safe production patterns

Strong patterns:

* `for_each` with maps
* explicit tags
* module version pinning
* separate env roots
* remote backend
* locking
* code review
* plan before apply
* protected production changes
* prevent_destroy on critical resources

---

## 12. Anti-patterns

A 6-year DevOps engineer should recognize these as bad signs:

* giant monolithic module
* hardcoded region/account
* no version pinning
* too many unrelated resources in one module
* list-based `count` for business objects
* no outputs
* weak naming conventions
* root module full of copy-pasted resources
* modules depending on hidden side effects
* using modules without README/examples

---

# PART 14 — Interview questions and answers

## Q1. What is a Terraform module?

A Terraform module is a reusable collection of Terraform resources, variables, and outputs used to standardize and scale infrastructure provisioning.

## Q2. What is the difference between root and child module?

The root module is the directory where Terraform commands are executed. A child module is called by another module using a `module` block.

## Q3. Why do we use modules in production?

To reduce duplication, enforce standards, improve reusability, simplify maintenance, and allow platform teams to provide safe infrastructure patterns for many application teams.

## Q4. Why is `for_each` preferred over `count` for team-based resources?

Because `for_each` uses stable keys, which prevents accidental destroy/recreate when items are added, removed, or reordered.

## Q5. How do you avoid destroying existing team resources when adding a new team?

Use `for_each` with stable map keys such as `team-name` or `team-repo`. Then adding a new key creates only the new resources.

## Q6. How do modules work in multi-region deployments?

Use provider aliases in the root module and pass the correct aliased provider into the child module.

## Q7. Does using modules isolate Terraform state?

No. Modules organize code, but state isolation depends on backend and root-module design.

## Q8. What is module versioning and why is it important?

Module versioning means pinning a module to a specific version, tag, or commit. It prevents unexpected changes and makes deployments reproducible.

## Q9. What is a good module boundary?

A good module encapsulates one logical responsibility, such as ECR, VPC, IAM baseline, ECS service, or monitoring.

## Q10. What happens if you rename a `for_each` key?

Terraform sees it as old resource removed and new resource added, unless handled with a `moved` block or state migration.

## Q11. When would you use `prevent_destroy`?

For critical production resources like repositories, databases, KMS keys, or state buckets where accidental destroy would be costly.

## Q12. What should be inside a good production module?

At minimum:

* main.tf
* variables.tf
* outputs.tf
* clear inputs
* useful outputs
* tags
* documentation
* examples or root usage

---



Terraform modules are like reusable infrastructure templates.

Instead of every team writing its own ECR, VPC, or IAM code, the platform team writes one centralized module.

Then teams only provide input values like:

* team name
* region
* repository names
* lifecycle settings

Terraform uses the same tested code for everyone.

When a new team is added, Terraform compares the state and creates only the new team’s resources.

Because we used `for_each` with stable keys, it does not destroy existing teams.

That is how real production Terraform should be designed.

---

# PART 16 — Production improvements beyond this lab

In a real company, next improvements would be:

* remote backend with S3 + DynamoDB lock
* module version pinning via Git tags
* CI/CD pipeline
* separate env folders for dev/stage/prod
* OPA or policy checks
* pre-commit hooks
* terraform-docs
* automated tagging policies
* team onboarding through pull requests
* cross-account deployment with assume role
* module publishing through private registry

---

# PART 17 — Most important production lesson

The biggest lesson is this:

**Do not model business entities with `count`. Model them with `for_each` and stable keys.**

For teams, services, repos, users, policies, subnets, alarms:

* `for_each` is usually the production-safe choice.

That is what prevents:

* accidental destroy
* reindexing issues
* unstable plans
* bad production changes

---

# PART 18 — Quick test commands

After apply, check repositories:

```bash
aws ecr describe-repositories --region us-east-2
```

```bash
aws ecr describe-repositories --region us-west-1
```

See lifecycle policies:

```bash
aws ecr get-lifecycle-policy \
  --repository-name prod/team-alpha/frontend \
  --region us-east-2
```

---

# PART 19 — Final summary for interview

If interviewer asks:

**How would you design Terraform for multi-team, multi-region production?**

You can answer:

I would create reusable child modules owned by the platform team and call them from environment-specific root modules. For multi-region deployments I would use aliased providers. For team onboarding I would model team configurations as maps and use `for_each` with stable keys, not `count`, so adding a new team creates only new resources without affecting existing ones. I would version modules, separate state per environment, use remote backend locking, enforce tagging and naming standards, and apply `prevent_destroy` to critical production resources.


