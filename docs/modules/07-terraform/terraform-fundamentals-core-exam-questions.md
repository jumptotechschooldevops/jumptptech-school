---
title: "TERRAFORM FUNDAMENTALS (Core Exam Questions)"
description: "Q1: What is Terraform?   Answer: Infrastructure as Code (IaC) tool that allows you to..."
published: 2026-03-31
source: "https://dev.to/jumptotech/terraform-fundamentals-core-exam-questions-2ieg"
tags: []
---

# TERRAFORM FUNDAMENTALS (Core Exam Questions)




### Q1: What is Terraform?

**Answer:**
Infrastructure as Code (IaC) tool that allows you to define, provision, and manage infrastructure using configuration files.

---

### Q2: What are the main components of Terraform?

**Answer:**

* Provider → AWS, Azure, GCP
* Resource → infrastructure object
* Module → reusable code block
* State → current infra snapshot
* Variables → input values
* Outputs → returned values

---

### Q3: Difference between `terraform init`, `plan`, `apply`

**Answer:**

* `init` → initializes provider/plugins/backend
* `plan` → shows execution plan
* `apply` → executes changes

---

### Q4: What is Terraform State?

**Answer:**
A file that maps your configuration to real infrastructure.

---

### Q5: Why is state important?

**Answer:**

* Tracks resources
* Enables updates instead of recreation
* Stores dependencies

---

# 2. STATE & BACKEND (VERY IMPORTANT)

### Q6: What is remote backend?

**Answer:**
Stores state remotely (S3, Terraform Cloud).

---

### Q7: Why use S3 + DynamoDB?

**Answer:**

* S3 → store state
* DynamoDB → locking (prevent conflicts)

---

### Q8: What is state locking?

**Answer:**
Prevents multiple users from modifying state at same time.

---

### Q9: What is `terraform.tfstate` vs `.backup`?

**Answer:**

* tfstate → current state
* backup → previous version

---

### Q10: What is drift?

**Answer:**
Difference between real infrastructure and Terraform state.

---

# 3. VARIABLES & OUTPUTS

### Q11: Types of variables?

**Answer:**

* string
* number
* bool
* list
* map
* object

---

### Q12: Ways to pass variables?

**Answer:**

* terraform.tfvars
* CLI (`-var`)
* environment variables
* default values

---

### Q13: What are outputs used for?

**Answer:**
Expose values (e.g., ALB DNS, RDS endpoint)

---

# 4. MODULES (VERY IMPORTANT FOR INTERVIEW)

### Q14: What is a module?

**Answer:**
Reusable Terraform code block.

---

### Q15: Types of modules?

**Answer:**

* Root module
* Child module
* Public module (registry)

---

### Q16: How to call module?

```hcl
module "vpc" {
  source = "./modules/vpc"
}
```

---

### Q17: Why modules?

**Answer:**

* Reusability
* Standardization
* Clean architecture

---

# 5. PROVIDERS & RESOURCES

### Q18: What is provider?

**Answer:**
Plugin to interact with cloud APIs.

---

### Q19: Example:

```hcl
provider "aws" {
  region = "us-east-2"
}
```

---

### Q20: What is resource lifecycle?

**Answer:**

* create
* read
* update
* delete

---

# 6. DEPENDENCIES

### Q21: How Terraform handles dependencies?

**Answer:**

* Automatically (reference-based)
* Explicit (`depends_on`)

---

### Q22:

```hcl
depends_on = [aws_vpc.main]
```

---

# 7. IMPORT (VERY COMMON QUESTION)

### Q23: What is terraform import?

**Answer:**
Bring existing resource into Terraform state.

---

### Q24: Command:

```bash
terraform import aws_instance.example i-123456
```

---

### Q25: Why use import?

**Answer:**

* Manage existing infra
* Avoid recreation

---

# 8. WORKSPACES

### Q26: What are workspaces?

**Answer:**
Multiple environments using same code.

---

### Q27:

```bash
terraform workspace new dev
```

---

### Q28: When NOT to use workspaces?

**Answer:**
Production multi-environment → use separate backend instead.

---

# 9. ADVANCED (CERTIFICATION LEVEL)

### Q29: What is `-target`?

**Answer:**
Apply only specific resource (not recommended in prod)

---

### Q30: What is `terraform graph`?

**Answer:**
Shows dependency graph

---

### Q31: What is `.terraform.lock.hcl`?

**Answer:**
Locks provider versions

---

---

# 10. SCENARIO-BASED QUESTIONS (REAL INTERVIEW STYLE)

---

## Scenario 1: State Conflict

**Q:** Two engineers run `terraform apply` at same time. What happens?

**Answer:**

* Without locking → corruption
* With DynamoDB → one waits

---

## Scenario 2: Production Mistake

**Q:** Someone manually deleted EC2 from AWS. What happens?

**Answer:**

* Terraform still thinks it exists
* Next `apply` → recreates

---

## Scenario 3: Drift Detection

**Q:** How do you detect drift?

**Answer:**

```bash
terraform plan
```

---

## Scenario 4: Multi-Environment Setup

**Q:** Dev, Stage, Prod — how to design?

**Answer:**

* Separate backends
* Separate folders
* Shared modules

---

## Scenario 5: Large Organization

**Q:** How to design Terraform for 10 teams?

**Answer:**

* Centralized modules
* Remote state
* CI/CD pipelines
* Naming conventions

---

## Scenario 6: CI/CD Pipeline

**Q:** How Terraform works in GitHub Actions?

**Answer:**

1. Checkout code
2. Configure AWS (OIDC)
3. terraform init
4. terraform plan
5. terraform apply

---

## Scenario 7: Secrets Management

**Q:** Where to store DB password?

**Answer:**

* AWS Secrets Manager
* NOT in Terraform code

---

## Scenario 8: Module Reuse

**Q:** Same VPC for multiple environments?

**Answer:**

* Create module
* Pass variables

---

## Scenario 9: Error Handling

**Q:** `Reference to undeclared module`

**Answer:**

* Module not defined in root
* Wrong path

---

## Scenario 10: Backend Problem

**Q:** S3 returns 403 in GitHub Actions

**Answer:**

* Missing IAM permissions
* Wrong role (OIDC issue)

---

# 11. REAL DEVOPS INTERVIEW QUESTIONS

---

### Q: How do you secure Terraform?

**Answer:**

* Remote backend
* Encryption (S3)
* IAM roles
* No hardcoded secrets

---

### Q: How do you handle Terraform in team?

**Answer:**

* Git workflow
* Pull requests
* Plan before apply
* State locking

---

### Q: How do you rollback Terraform?

**Answer:**

* Revert code
* Apply again

---

### Q: Difference Terraform vs CloudFormation?

**Answer:**

* Terraform → multi-cloud
* CloudFormation → AWS only

---

---

# 12. TRICK QUESTIONS (VERY IMPORTANT)

---

### Q: Does Terraform store secrets?

**Answer:**
YES → in state file (danger!)

---

### Q: Is Terraform imperative or declarative?

**Answer:
Declarative**

---

### Q: Does Terraform recreate everything?

**Answer:
No, only changes**

---

---

# 13. PRACTICAL COMMAND QUESTIONS

---

### Q: Show outputs

```bash
terraform output
```

---

### Q: Validate code

```bash
terraform validate
```

---

### Q: Format code

```bash
terraform fmt
```

---

---




