---
title: "TERRAFORM MODULES – COMPLETE INTERVIEW Q&A"
description: "🟢 BEGINNER LEVEL            1. What is a Terraform module?   Answer: A Terraform module is a..."
published: 2026-03-19
source: "https://dev.to/jumptotech/terraform-modules-complete-interview-qa-5b30"
tags: []
---

# TERRAFORM MODULES – COMPLETE INTERVIEW Q&A





# 🟢 BEGINNER LEVEL

## 1. What is a Terraform module?

**Answer:**
A Terraform module is a reusable set of Terraform configuration files that defines infrastructure resources. It allows us to write code once and reuse it across multiple environments or teams.

---

## 2. What problem do modules solve?

**Answer:**
Modules solve:

* code duplication
* lack of standardization
* maintenance complexity

Without modules, teams copy-paste the same resources. With modules, we follow the **DRY principle (Don’t Repeat Yourself)**.

---

## 3. What is the DRY principle?

**Answer:**
DRY means:

> Do not repeat the same logic multiple times.

In Terraform, modules implement DRY by allowing reusable infrastructure code.

---

## 4. What is a root module?

**Answer:**
The root module is the main Terraform configuration where we run commands like:

```terraform
terraform init
terraform apply
```

It calls other modules.

---

## 5. What is a child module?

**Answer:**
A child module is any module that is called from another module (usually the root module).

---

## 6. How do you call a module?

**Answer:**

```hcl
module "ec2" {
  source = "../modules/ec2"
}
```

---

## 7. What is `source` in module?

**Answer:**
`source` defines where the module code is located:

* local path
* Git repository
* Terraform Registry

---

## 8. What files are inside a module?

**Answer:**
Typically:

* `main.tf` → resources
* `variables.tf` → inputs
* `outputs.tf` → outputs

---

# 🟡 INTERMEDIATE LEVEL

---

## 9. How do modules communicate?

**Answer:**
Modules communicate using:

* outputs (from one module)
* variables (input to another module)

Example:

```hcl
subnet_id = module.vpc.subnet_id
```

---

## 10. What are module inputs?

**Answer:**
Inputs are variables passed into a module.

Defined in:

```hcl
variable "instance_type" {}
```

---

## 11. What are module outputs?

**Answer:**
Outputs are values returned by a module.

Example:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

---

## 12. Can a module call another module?

**Answer:**
Yes. This is called **nested modules**.

---

## 13. What is a local module?

**Answer:**
A module stored locally:

```hcl
source = "../modules/ec2"
```

---

## 14. What is a remote module?

**Answer:**
A module stored remotely:

* GitHub
* Terraform Registry

Example:

```hcl
source = "terraform-aws-modules/vpc/aws"
```

---

## 15. Where are modules stored after `terraform init`?

**Answer:**
Inside:

```plaintext
.terraform/modules/
```

---

## 16. What happens during `terraform plan` with modules?

**Answer:**
Terraform:

* reads module code
* expands it into resources
* shows what will be created

Even if resources are not written in root module.

---

## 17. Why use modules in real-world projects?

**Answer:**

* reuse code
* enforce standards
* reduce errors
* simplify onboarding
* faster infrastructure deployment

---

# 🔵 ADVANCED LEVEL

---

## 18. How do you version Terraform modules?

**Answer:**
Using Git tags:

```hcl
source = "git::https://github.com/org/module.git?ref=v1.0.0"
```

---

## 19. Why is versioning important?

**Answer:**

* prevents breaking changes
* ensures stable deployments
* allows controlled upgrades

---

## 20. What is the difference between module and resource?

**Answer:**

| Module             | Resource         |
| ------------------ | ---------------- |
| reusable           | single component |
| multiple resources | one resource     |
| abstraction        | implementation   |

---

## 21. When should you NOT use modules?

**Answer:**

* very small one-time config
* simple demo scripts

---

## 22. What is a public module?

**Answer:**
A module from Terraform Registry:

```plaintext
registry.terraform.io
```

---

## 23. How do you choose a good module?

**Answer (IMPORTANT):**

* high downloads
* active GitHub repo
* many contributors
* good documentation
* version history

---

## 24. Why avoid random modules?

**Answer:**

* security risks
* unmaintained code
* breaking changes

---

## 25. What do companies do with public modules?

**Answer:**

* fork them
* customize
* maintain private versions

---

# 🔴 PRODUCTION / REAL-WORLD QUESTIONS

---

## 26. How do you structure Terraform in big companies?

**Answer:**

```bash
infra-modules/
infra-live/
```

* `infra-modules` → reusable code
* `infra-live` → environment configs

---

## 27. Why separate modules and environments?

**Answer:**

* avoids duplication
* easier updates
* version control
* scalability

---

## 28. What is a typical module design in production?

**Answer:**
Small, focused modules:

* VPC module
* EC2 module
* ALB module
* RDS module

---

## 29. What is a bad module design?

**Answer:**
One big module:

* VPC + EC2 + RDS + ALB together

Problems:

* not reusable
* hard to maintain
* hard to debug

---

## 30. How do teams use modules?

**Answer:**
Platform team:

* builds modules

Application teams:

* consume modules

---

## 31. How do you pass environment-specific values?

**Answer:**
Using:

* `terraform.tfvars`
* variables

---

## 32. How do you avoid hardcoding?

**Answer:**
Use:

* variables
* data sources
* SSM / secrets

---

## 33. How do you handle AMI in production?

**Answer:**

* data source
* SSM parameter
* golden AMI

---

## 34. How do you enforce standards using modules?

**Answer:**

* restrict inputs
* define defaults
* enforce tagging
* enforce security rules

---

## 35. What is module composition?

**Answer:**
Combining multiple modules together:

```hcl
module "vpc"
module "ec2"
module "alb"
```

---

## 36. How do you scale modules?

**Answer:**

* use `count` / `for_each`
* parameterize everything
* avoid hardcoding

---

## 37. How do you test modules?

**Answer:**

* `terraform validate`
* `terraform plan`
* test in dev
* CI pipelines

---

## 38. What is the biggest mistake engineers make with modules?

**Answer:**

* hardcoding values
* making modules too large
* not using outputs
* no versioning

---

# 🟣 SCENARIO QUESTIONS (VERY IMPORTANT)

---

## 39. You have 50 teams creating EC2 instances differently. What do you do?

**Answer:**
Create a centralized EC2 module and enforce its usage to standardize infrastructure.

---

## 40. You need to update instance type across all environments. How?

**Answer:**
Update module once → all environments inherit change.

---

## 41. Your module breaks after update. Why?

**Answer:**
No version pinning → module changed unexpectedly.

---

## 42. Multiple environments need different configs. Solution?

**Answer:**
Use:

* separate env folders
* tfvars files

---

## 43. How do you securely manage modules?

**Answer:**

* private Git repos
* code reviews
* restrict access
* scan code

---

# 🧠 PERFECT INTERVIEW ANSWER (USE THIS)

If they ask:

### “Explain Terraform modules in real-world”

**Answer:**

> Terraform modules are reusable infrastructure components that allow us to standardize and scale infrastructure across teams and environments. In production, we separate modules into a reusable repository and use environment-specific configurations to consume them. Modules help enforce best practices, reduce duplication, and simplify infrastructure management.

---

# 🔥 WHAT YOU MUST KNOW TO PASS

You MUST understand:

* module structure
* variables vs outputs
* root vs child module
* module communication
* local vs remote modules
* versioning
* infra-modules vs infra-live
* DRY principle
* real-world usage




