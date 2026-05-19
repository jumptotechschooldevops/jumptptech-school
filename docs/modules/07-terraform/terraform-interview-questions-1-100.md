---
title: "Terraform Interview Questions (1–100)"
description: "Terraform is created and maintained by HashiCorp.           🟢 BEGINNER (1–25)            1. What is..."
published: 2026-01-26
source: "https://dev.to/jumptotech/terraform-interview-questions-1-100-1eng"
tags: []
---

# Terraform Interview Questions (1–100)



Terraform is created and maintained by HashiCorp.



## 🟢 BEGINNER (1–25)

### 1. What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool that allows you to define, provision, and manage infrastructure using declarative configuration files.

---

### 2. What language does Terraform use?

Terraform uses **HCL (HashiCorp Configuration Language)**.

---

### 3. What is Infrastructure as Code?

IaC means managing infrastructure using code instead of manual configuration.

---

### 4. What are Terraform providers?

Providers are plugins that allow Terraform to interact with APIs (AWS, Azure, GCP, Kubernetes, etc.).

---

### 5. What is a Terraform resource?

A resource represents a real infrastructure object (EC2, S3, VPC, etc.).

---

### 6. What is `terraform init`?

Initializes a Terraform project by downloading providers and modules.

---

### 7. What is `terraform plan`?

Shows what Terraform **will change** without applying it.

---

### 8. What is `terraform apply`?

Applies the planned infrastructure changes.

---

### 9. What is `terraform destroy`?

Deletes all resources managed by Terraform.

---

### 10. What is a Terraform state file?

State (`terraform.tfstate`) tracks real infrastructure vs configuration.

---

### 11. Why is state important?

Terraform uses state to **detect drift** and plan changes accurately.

---

### 12. What is a variable in Terraform?

A parameter used to make configurations reusable.

---

### 13. How do you define a variable?

```hcl
variable "instance_type" {
  type = string
}
```

---

### 14. What is `terraform.tfvars`?

File used to assign values to variables.

---

### 15. What is an output in Terraform?

Outputs expose values after apply.

---

### 16. How do you define an output?

```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

---

### 17. What is a data source?

Used to **read existing infrastructure**.

---

### 18. Difference between resource and data source?

Resource = create/manage
Data source = read only

---

### 19. What is provider version pinning?

Locking provider versions for consistency.

---

### 20. What is `required_providers`?

Defines provider source and version constraints.

---

### 21. What is `terraform validate`?

Checks syntax and configuration correctness.

---

### 22. What is `terraform fmt`?

Formats Terraform code.

---

### 23. What is `.terraform` directory?

Stores provider binaries and metadata.

---

### 24. Can Terraform manage existing infrastructure?

Yes, using `terraform import`.

---

### 25. What is drift?

When real infrastructure differs from Terraform state.

---

## 🟡 INTERMEDIATE (26–60)

### 26. What is a Terraform module?

A reusable collection of Terraform files.

---

### 27. Why use modules?

Reusability, consistency, and abstraction.

---

### 28. How do you call a module?

```hcl
module "vpc" {
  source = "./vpc"
}
```

---

### 29. What is `count`?

Creates multiple instances of a resource.

---

### 30. What is `for_each`?

Creates resources using a map or set.

---

### 31. Difference between `count` and `for_each`?

`for_each` is safer for resource identity.

---

### 32. What is `depends_on`?

Forces explicit dependency order.

---

### 33. What is implicit dependency?

Terraform infers dependency from references.

---

### 34. What is a backend?

Defines **where state is stored**.

---

### 35. What is remote state?

State stored in remote storage (S3, Terraform Cloud).

---

### 36. Why use remote state?

Collaboration, locking, security.

---

### 37. What is state locking?

Prevents concurrent state modifications.

---

### 38. How does S3 backend locking work?

Uses DynamoDB for locking.

---

### 39. What is `terraform refresh`?

Syncs state with real infrastructure.

---

### 40. What is `terraform taint`?

Marks a resource for recreation.

---

### 41. What is `terraform import`?

Brings existing infra under Terraform control.

---

### 42. What is `lifecycle` block?

Controls resource behavior.

---

### 43. Common lifecycle arguments?

* `create_before_destroy`
* `prevent_destroy`
* `ignore_changes`

---

### 44. What is `ignore_changes`?

Prevents Terraform from updating certain fields.

---

### 45. What is a workspace?

Allows multiple environments using same code.

---

### 46. Default workspace?

`default`

---

### 47. Are workspaces recommended for prod?

Usually **no** (prefer separate state files).

---

### 48. What is interpolation?

Using values inside strings.

---

### 49. What are locals?

Computed values reused in config.

---

### 50. What is `terraform output`?

Displays output values.

---

### 51. How do you pass variables via CLI?

```bash
terraform apply -var="env=dev"
```

---

### 52. What is sensitive variable?

Hidden from CLI output.

---

### 53. How to mark variable sensitive?

```hcl
sensitive = true
```

---

### 54. What is `terraform graph`?

Visualizes resource dependencies.

---

### 55. What is `terraform providers`?

Shows provider usage.

---

### 56. Can Terraform roll back automatically?

No (manual rollback required).

---

### 57. How does Terraform detect changes?

By comparing **state vs plan vs real infra**.

---

### 58. What is provider alias?

Multiple configurations for same provider.

---

### 59. Use case for provider alias?

Multi-region or multi-account deployments.

---

### 60. What is `terraform console`?

Interactive debugging shell.

---

## 🔴 ADVANCED & SCENARIO-BASED (61–100)

### 61. Terraform vs CloudFormation?

Terraform is **cloud-agnostic**, CF is AWS-only.

---

### 62. How do you structure Terraform for large teams?

* Modules
* Remote state
* Separate repos
* CI/CD

---

### 63. What is remote state data source?

Reads outputs from another state.

---

### 64. Why avoid shared state?

Risk of accidental destruction.

---

### 65. How do you manage secrets?

Use Vault, AWS Secrets Manager, or environment variables.

---

### 66. Terraform with CI/CD?

Plan → review → apply using pipelines.

---

### 67. What is policy as code in Terraform?

Using Sentinel or OPA to enforce rules.

---

### 68. What is Terraform Cloud?

Managed Terraform with state, locking, policies.

---

### 69. What is Sentinel?

Policy-as-code framework.

---

### 70. How do you prevent `terraform destroy`?

Use `prevent_destroy`.

---

### 71. What happens if state is deleted?

Terraform may recreate everything.

---

### 72. How do you recover state?

From backend versioning or backup.

---

### 73. Terraform apply failed halfway—what now?

Re-run `terraform apply`.

---

### 74. How do you handle multiple environments?

Separate states or repos.

---

### 75. What is blue/green with Terraform?

Deploy parallel infra and switch traffic.

---

### 76. Can Terraform manage Kubernetes?

Yes, via Kubernetes provider.

---

### 77. Terraform vs Ansible?

Terraform = provisioning
Ansible = configuration management

---

### 78. What is immutable infrastructure?

Recreate instead of modifying.

---

### 79. What is `null_resource`?

Executes provisioners without real resource.

---

### 80. Are provisioners recommended?

No (last resort).

---

### 81. Why avoid provisioners?

Non-idempotent and unreliable.

---

### 82. Terraform with multiple AWS accounts?

Use provider aliases and assume roles.

---

### 83. How to handle breaking changes?

Version pinning + staged rollouts.

---

### 84. What is `terraform state rm`?

Removes resource from state only.

---

### 85. When would you use `state mv`?

Renaming or refactoring resources.

---

### 86. Terraform dependency cycle—how to fix?

Refactor resources or use `depends_on`.

---

### 87. How do you enforce naming standards?

Use variables and locals.

---

### 88. How do you validate Terraform code?

`terraform validate`, `tflint`, `checkov`.

---

### 89. What is drift detection strategy?

Regular `plan` in CI.

---

### 90. Can Terraform handle rollbacks?

Not automatically.

---

### 91. Terraform vs Pulumi?

Terraform = declarative
Pulumi = real programming languages

---

### 92. What is partial apply?

Some resources created, others failed.

---

### 93. How do you manage cost with Terraform?

Tagging + budgets + policy checks.

---

### 94. Terraform state security best practice?

Encrypt backend + restrict access.

---

### 95. How do you rotate secrets?

Update source → reapply → redeploy.

---

### 96. Terraform in production—biggest risk?

State mismanagement.

---

### 97. Can Terraform delete resources created outside it?

No, unless imported.

---

### 98. What is `-target`?

Applies only specific resources (avoid in prod).

---

### 99. When should you use `-refresh=false`?

Rare cases (speed or broken APIs).

---

### 100. Terraform golden rule?

**State is the source of truth—protect it.**


