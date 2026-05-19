---
title: "lab part 4: legacy system production-grade Terraform modules + GitLab"
description: "🏗 1️⃣ What Each Environment Means            🟢 dev (Development..."
published: 2026-02-26
source: "https://dev.to/jumptotech/lab-part-3-legacy-system-production-grade-terraform-modules-gitlab-166e"
tags: []
---

# lab part 4: legacy system production-grade Terraform modules + GitLab



# 🏗 1️⃣ What Each Environment Means

## 🟢 dev (Development Environment)

Purpose:

* Developers test infrastructure changes
* Safe place to experiment
* Lower cost
* Can break things

What runs here:

* New VPCs
* New EKS test cluster
* Experimental modules
* Terraform refactors

Who works here:

* DevOps engineers daily
* Developers testing infrastructure changes

Typical workflow:

```
Create feature branch → modify dev → CI plan → apply automatically
```

In dev:

* Auto-apply is acceptable
* No strict approval needed
* Frequent changes

---

## 🟡 stage (Staging / Pre-Production)

Purpose:

* Mirror production
* Validate before prod
* Final integration testing

What runs here:

* Same EKS version as prod
* Same modules as prod
* Similar scaling settings

Who works here:

* DevOps before production release
* QA testing deployments

Typical workflow:

```
Merge to stage branch → CI plan → manual apply → validate → promote to prod
```

In stage:

* Apply should be manual
* Requires review
* No experimentation

---

## 🔵 prod (Production)

Purpose:

* Real business workloads
* Customer-facing
* Mission-critical

What runs here:

* Production EKS
* Production ALB
* Production scaling
* Monitoring + logging

Who works here:

* Senior DevOps only
* Changes via approved merge requests

Typical workflow:

```
Merge to main → CI plan → approval → manual apply
```

In prod:

* Never auto-apply
* Always require approval
* prevent_destroy enabled
* Branch protected

---

## 🔴 legacy (Adopted Infrastructure)

This is special.

Purpose:

* Onboard old infrastructure
* Transitional state
* Temporary environment

Right now your legacy folder represents:

* Existing 5-year EKS cluster

After validation, legacy should become prod.

In enterprise, legacy is NOT permanent.

It’s a migration stage.

---

# 🧭 2️⃣ Correct Migration Flow

You should follow this order:

Step 1 — Adopt legacy (done ✅)

Step 2 — Validate in CI (done ✅)

Step 3 — Rename legacy → prod (after confidence)

So final structure should look like:

```
envs/
  dev/
  stage/
  prod/   ← former legacy
```

Legacy folder is temporary.

---

# 🔄 3️⃣ How Promotion Should Work

Real DevOps promotion flow:

```
dev  →  stage  →  prod
```

Meaning:

1. Develop in dev
2. Validate in stage
3. Promote same code to prod

Important:
We do NOT copy code.
We reuse modules with different tfvars.

---

# 🧠 4️⃣ Where DevOps Actually Works

As DevOps engineer:

You work in:

* infra-modules (building reusable modules)
* infra-live/dev (testing changes)
* infra-live/stage (validation)
* infra-live/prod (controlled releases)

You rarely edit prod directly.

Instead:

You modify modules.
Then test in dev.
Then promote.

---

# 🧱 5️⃣ Proper Enterprise Structure (Final Goal)

infra-modules:
Reusable building blocks

infra-live:
Environment-specific instantiation

Example:

infra-modules/modules/eks/

infra-live/envs/dev/main.tf:

```
module "eks" {
  source = "git::https://gitlab.com/jumptotech/infra-modules.git//modules/eks?ref=v1.0.0"
}
```

Same module used in stage and prod.

Only variables differ.

---

# 🏛 6️⃣ What You Should Do Now

Right now:

You have legacy EKS fully adopted.

Next correct move:

1. Move legacy configuration into prod folder.
2. Keep prevent_destroy.
3. Keep manual apply.
4. Remove legacy folder after validation.

So structure becomes:

```
envs/
  dev/
  stage/
  prod/   ← adopted EKS
```

Legacy folder should not exist long-term.

---

# 🔐 7️⃣ CI Strategy Per Environment

DEV:

* plan + auto apply allowed

STAGE:

* plan
* manual apply

PROD:

* plan
* approval required
* manual apply
* protected branch


Which env for what?

dev → experimentation & daily changes
stage → validation before production
prod → real production infrastructure
legacy → temporary adoption folder (remove after migration)

Where do we work as DevOps?

* Build modules in infra-modules
* Test in dev
* Validate in stage
* Release in prod












# ✅ 1️⃣ CI Success — What Does It Mean?

Your CI output shows:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

That means:

* Remote backend works
* CI can assume AWS role
* Terraform state is correct
* No drift
* Infrastructure is managed
* Apply executed safely

So yes — your legacy adoption is complete.

---

# 🟢 2️⃣ Rename `legacy` → `prod`





Because:

* `legacy` was only a temporary adoption folder.
* Now that it’s managed by Terraform + CI,
* It should become your `prod` environment.

---

## 🔁 How To Safely Rename

Do this carefully:

### Step 1 — Move folder

```bash
mv envs/legacy envs/prod
```

### Step 2 — Update backend key

Inside `backend.tf` change:

```hcl
key = "legacy/terraform.tfstate"
```

to:

```hcl
key = "prod/terraform.tfstate"
```

### ⚠️ Important

Since state is already in S3 under:

```
legacy/terraform.tfstate
```

You must either:

Option A (Simple):
Keep key name as `legacy/terraform.tfstate`
even if folder is prod.

OR

Option B (Clean):
Move state file in S3 from:

```
legacy/terraform.tfstate
```

to:

```
prod/terraform.tfstate
```

Then reinitialize with:

```bash
terraform init -migrate-state
```

---

# 🟡 3️⃣ Are We Skipping Staging?

Technically yes — for now.

In real companies:

```
dev → stage → prod
```

But since you are migrating an existing production cluster,
there is no staging copy of that cluster.

So skipping stage during adoption is normal.

Later, when building new infrastructure,
you should follow:

```
dev → stage → prod
```

---

# 🏗 4️⃣ When Do We Create Terraform Modules?

You create modules when:

* You have repeated infrastructure
* You want reusable patterns
* You want standardization
* You want environment consistency

You already have:

```
infra-modules/
  modules/
    vpc/
    alb/
    asg_legacy_app/
    iam_baseline/
```

That is correct structure.

---

# 🧱 5️⃣ What Is the Purpose of Terraform Modules?

Modules solve 5 major problems:

---

## 1️⃣ Reusability

Instead of writing this 3 times:

```hcl
resource "aws_vpc" ...
resource "aws_subnet" ...
resource "aws_igw" ...
```

You write it once inside:

```
modules/vpc/
```

Then reuse:

```hcl
module "vpc" {
  source = "../../modules/vpc"
}
```

---

## 2️⃣ Environment Standardization

Dev, stage, prod use the same logic:

Only variables change:

```
dev → small instance
prod → bigger instance
```

---

## 3️⃣ Version Control of Infrastructure Patterns

You can use:

```hcl
source = "git::https://.../infra-modules.git//modules/vpc?ref=v1.0.0"
```

Now:

* v1.0.0 = stable
* v1.1.0 = improvement

Production can stay on stable version.

---

## 4️⃣ Team Scalability

Modules allow:

* Junior DevOps to use approved modules
* Senior DevOps to maintain module code

Clear separation of responsibility.

---

## 5️⃣ Safer Changes

Change module → test in dev → promote to stage → promote to prod.

Not directly editing prod environment.

---

# 🏛 6️⃣ Proper Enterprise Architecture (Your Final Goal)

Eventually you want:

```
infra-modules/
  modules/
    vpc/
    eks/
    alb/
    monitoring/

infra-live/
  envs/
    dev/
      main.tf (calls modules)
    stage/
      main.tf (calls modules)
    prod/
      main.tf (calls modules)
```

Environments DO NOT define resources directly.
They call modules.

---

# 🎯 7️⃣ Where DevOps Actually Works

As DevOps engineer:

* Build modules in `infra-modules`
* Test modules in `dev`
* Validate in `stage`
* Release in `prod`

You rarely edit `prod` directly.

---

# 🚀 8️⃣ What I Recommend For You Now

Since your legacy cluster is production:

✔ Rename `legacy` → `prod`
✔ Keep prevent_destroy
✔ Make apply manual
✔ Protect branch

Then:

Next phase:

Create new `dev` EKS cluster using module pattern.
That is how you grow infrastructure cleanly.

---

# 🧠 Big Picture

You just:

Manual Infra (5 years old)
→ Imported into Terraform
→ Remote backend
→ CI-controlled
→ Production-protected

That is real DevOps modernization.









