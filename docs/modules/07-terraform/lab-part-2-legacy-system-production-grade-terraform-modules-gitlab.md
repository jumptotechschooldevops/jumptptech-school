---
title: "lab part 2: legacy system production-grade Terraform modules + GitLab"
description: "🎓 Case Study: Onboarding 5-Year Legacy EKS into Terraform (Enterprise Practice)             ..."
published: 2026-02-25
source: "https://dev.to/jumptotech/lab-part-2-legacy-system-production-grade-terraform-modules-gitlab-34j3"
tags: []
---

# lab part 2: legacy system production-grade Terraform modules + GitLab



# 🎓 Case Study: Onboarding 5-Year Legacy EKS into Terraform (Enterprise Practice)

---

# 1️⃣ The Situation (Real Company Scenario)

Company has:

* 5-year-old EKS cluster: `jum-eks`
* Created manually (console or scripts)
* Running production workloads
* No Infrastructure as Code
* No remote state
* No CI/CD integration

Goal:

> Bring legacy infrastructure under Terraform management safely.

---

# 2️⃣ Why We Cannot Just “Start Using Terraform”

If we write this:

```hcl
resource "aws_eks_cluster" "legacy" {
  name = "jum-eks"
}
```

And run:

```bash
terraform apply
```

Terraform will try to CREATE a new cluster.

But the cluster already exists.

This leads to:

* Conflicts
* Duplicate resources
* Possible destruction
* Production outage

So we must **adopt**, not recreate.

---

# 3️⃣ What Is Terraform Adoption?

Terraform adoption means:

1. Write code that exactly matches reality
2. Import existing resources into state
3. Verify zero drift
4. Move state to remote backend
5. Integrate into CI

---

# 4️⃣ Phase 1 — Isolated Adoption (Safe Mode)

We first created:

```
legacy-import/
  main.tf
  terraform.tfstate
```

We:

* Wrote full EKS cluster block
* Wrote full node group block
* Ran:

```bash
terraform import aws_eks_cluster.legacy jum-eks
terraform import aws_eks_node_group.legacy_nodes "jum-eks:nodes"
```

Then:

```bash
terraform plan
```

Output:

```
No changes.
```

That means:

```
Code = AWS Reality
```

At this point:

Terraform fully manages EKS — but only locally.

---

# 5️⃣ Why Local State Is Not Enterprise Ready

Local state means:

* Only your laptop knows infra
* No locking
* No team collaboration
* No CI integration
* Risk of state loss

Enterprise requires:

* Remote state
* Locking
* Centralized backend
* CI/CD integration

---

# 6️⃣ Phase 2 — Move to Enterprise Structure

You structured repo properly:

```
infra-live/
  envs/
    dev/
    stage/
    prod/
    legacy/
```

This is real enterprise pattern:

Each environment = separate state.

---

# 7️⃣ Phase 3 — Configure Remote Backend

We configured:

S3 bucket:

```
jumptotech-terraform-state-021399177326
```

DynamoDB table:

```
terraform-lock-table
```

Backend config:

```hcl
terraform {
  backend "s3" {}
}
```

Then initialized with:

```bash
terraform init -reconfigure \
  -backend-config="bucket=jumptotech-terraform-state-021399177326" \
  -backend-config="key=legacy/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=terraform-lock-table" \
  -backend-config="encrypt=true"
```

Now state is:

* Stored in S3
* Locked by DynamoDB
* Safe for team usage

---

# 8️⃣ Important Lesson: State Does NOT Automatically Move

When we moved code to `infra-live/envs/legacy`:

Terraform showed:

```
+ create aws_eks_cluster
```

Why?

Because:

New folder = new Terraform root = empty state.

Terraform does NOT know about resources unless:

* You migrate state
  OR
* You import again

So we imported again:

```bash
terraform import aws_eks_cluster.legacy jum-eks
terraform import aws_eks_node_group.legacy_nodes "jum-eks:nodes"
```

Then:

```bash
terraform plan
```

Result:

```
No changes.
```

Now adoption is complete.

---

# 9️⃣ What We Fixed Along The Way

### ✅ Terraform version mismatch

Upgraded to 1.14.x to match CI.

### ✅ Duplicate provider blocks

Separated:

* `providers.tf`
* `main.tf`

Enterprise structure requires:

providers.tf:

```hcl
terraform { required_providers {} }
provider "aws" {}
```

main.tf:
Only resources.

### ✅ Variable handling

Created:

```
terraform.tfvars
```

With:

```hcl
aws_region = "us-east-2"
```

No interactive variable input in production.

---

# 🔟 What “Fully Managed by Terraform” Now Means

Now:

* If someone manually changes cluster
* If someone scales node group manually
* If someone changes endpoint access

Terraform will detect drift:

```bash
terraform plan
```

And show differences.

Terraform is now:

The single source of truth.

---

# 1️⃣1️⃣ Enterprise Best Practices You Followed

You correctly:

✔ Onboarded legacy in isolated folder
✔ Matched configuration exactly
✔ Verified no drift
✔ Moved to remote backend
✔ Enabled locking
✔ Structured environments properly
✔ Avoided applying blindly
✔ Re-imported into correct backend

This is exactly how real companies migrate legacy systems.

---

# 1️⃣2️⃣ Final Architecture After Migration

```
infra-live/
  envs/
    legacy/   ← Adopted 5-year production EKS
    dev/
    stage/
    prod/
```

Backend:

```
S3 state storage
+
DynamoDB state locking
```

CI can now safely:

* Run plan
* Require approval
* Apply changes
* Prevent accidental destroy



* What is Terraform state
* What is backend
* What is drift detection
* What is resource import
* Why local state is dangerous
* Why migration must be isolated
* Why enterprise separates environments
* How to safely onboard legacy systems

This is real DevOps work — not toy examples.

---

# 1️⃣4️⃣ Final Production Rule

Never:

* Directly connect legacy infra to CI
* Apply without verifying plan
* Mix environments in same state
* Ignore provider version alignment

---



Legacy infrastructure onboarding requires:

1. Write exact Terraform code
2. Import resources
3. Verify no changes
4. Move to remote backend
5. Enable locking
6. Structure environments
7. Integrate into CI
8. Enforce code-based changes only


