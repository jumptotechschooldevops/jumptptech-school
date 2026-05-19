---
title: "lab part 3: legacy system production-grade Terraform modules + GitLab"
description: "🎯 Goal   When you push to GitLab:   CI runs terraform plan for envs/legacy  It uses remote..."
published: 2026-02-25
source: "https://dev.to/jumptotech/lab-part-2-legacy-system-production-grade-terraform-modules-gitlab-4p78"
tags: []
---

# lab part 3: legacy system production-grade Terraform modules + GitLab


# 🎯 Goal

When you push to GitLab:

* CI runs `terraform plan` for `envs/legacy`
* It uses remote S3 backend
* It assumes AWS role (OIDC)
* It does NOT auto-apply
* Apply is manual + protected

---

# 🏗 Current Structure (Correct)

```bash
infra-live/
├── envs/
│   ├── legacy/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── .terraform.lock.hcl
├── scripts/
│   └── assume_role.sh
├── .gitlab-ci.yml
└── .gitignore
```

Backend already configured:

```hcl
backend "s3" {}
```

State is already in S3. Good.

---

# 🟢 STEP 1 — Make Sure CI Has AWS Access

Your pipeline already uses OIDC:

```bash
scripts/assume_role.sh
```

It should:

* Assume IAM role
* Export AWS credentials
* Print caller identity

In CI logs you should see:

```bash
aws sts get-caller-identity
```

If that works → AWS access is ready.

---

# 🟢 STEP 2 — Add Legacy Plan Job in `.gitlab-ci.yml`

Add this block:

```yaml
stages:
  - plan
  - apply

legacy-plan:
  stage: plan
  image: hashicorp/terraform:1.7
  before_script:
    - apk add --no-cache bash curl jq aws-cli
    - . scripts/assume_role.sh
  script:
    - cd envs/legacy
    - terraform init \
        -backend-config="bucket=$TF_STATE_BUCKET" \
        -backend-config="key=legacy/terraform.tfstate" \
        -backend-config="region=$AWS_REGION" \
        -backend-config="dynamodb_table=$TF_LOCK_TABLE" \
        -backend-config="encrypt=true"
    - terraform plan -var="aws_region=$AWS_REGION"
  only:
    - main
```

---

# 🟢 STEP 3 — Add Manual Apply (Protected)

```yaml
legacy-apply:
  stage: apply
  image: hashicorp/terraform:1.7
  before_script:
    - apk add --no-cache bash curl jq aws-cli
    - . scripts/assume_role.sh
  script:
    - cd envs/legacy
    - terraform init \
        -backend-config="bucket=$TF_STATE_BUCKET" \
        -backend-config="key=legacy/terraform.tfstate" \
        -backend-config="region=$AWS_REGION" \
        -backend-config="dynamodb_table=$TF_LOCK_TABLE" \
        -backend-config="encrypt=true"
    - terraform apply -auto-approve -var="aws_region=$AWS_REGION"
  when: manual
  only:
    - main
```

Important:

```yaml
when: manual
```

This prevents automatic production changes.

---

# 🟢 STEP 4 — Add CI Variables in GitLab

Go to:

GitLab → Settings → CI/CD → Variables

Add:

```
AWS_REGION = us-east-2
TF_STATE_BUCKET = jumptotech-terraform-state-021399177326
TF_LOCK_TABLE = terraform-lock-table
```

Do NOT hardcode these in YAML.

---

# 🟢 STEP 5 — Protect Main Branch

GitLab → Settings → Repository → Protected Branches

* Protect `main`
* Require merge request
* Require approval
* Disable direct push

Enterprise rule:

> No direct push to production branch.

---

# 🟢 STEP 6 — Test It

Make a small harmless change:

Example:

```hcl
tags = {
  ManagedBy = "Terraform"
}
```

Commit and push:

```bash
git add .
git commit -m "Test CI plan"
git push
```

Pipeline should:

* Run `legacy-plan`
* Show plan output
* NOT auto-apply

Then manually click:

```
legacy-apply
```

If needed.

---

# 🔐 Safety Checklist Before Running CI

Before first CI apply:

* `terraform plan` locally shows NO destroy
* `prevent_destroy` added
* Branch protected
* Apply job is manual

---

# 🏁 Final Result

After this:

```text
Developer push → CI plan → MR approval → Manual apply → Production update
```

That is correct enterprise workflow.











Perfect ✅
Your CI just did this:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

That means:

* CI successfully assumed role
* Backend S3 is working
* DynamoDB locking is working
* State is correct
* No drift
* Infrastructure matches code

You are officially running Terraform from CI.

---

# 🎯 What Is Next?

Now we move from:

> “CI works”

to

> “Production is protected and controlled”

There are 4 important next steps.

---

# 🟢 1️⃣ STOP Auto-Apply in Production

Right now your job runs:

```bash
terraform apply -auto-approve
```

This is NOT safe for production.

Change it to:

```yaml
legacy-apply:
  stage: apply
  when: manual
```

So apply must be clicked manually in GitLab UI.

Enterprise rule:

> Production changes must never auto-apply on push.

---

# 🟢 2️⃣ Add `prevent_destroy` Protection

In `envs/legacy/main.tf` add to BOTH resources:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This prevents accidental deletion of:

* EKS cluster
* Node group

Now even if someone writes:

```hcl
resource removed accidentally
```

Terraform will refuse to destroy.

---

# 🟢 3️⃣ Protect `main` Branch

Go to:

GitLab → Settings → Repository → Protected Branches

Protect:

```
main
```

Enable:

* No direct push
* Merge request required
* Approval required

Now production cannot be modified without review.

---

# 🟢 4️⃣ Test Drift Detection (Very Important)

Now simulate a real-world scenario:

1. Go to AWS Console
2. Change node group desired size from `0` → `1`
3. Push nothing
4. Run CI plan

It should show:

```diff
~ desired_size: 1 → 0
```

That proves:

Terraform is the source of truth.

---

# 🏗 Big Picture — Where You Are Now

You have:

* Legacy production cluster adopted
* Remote state
* Locked backend
* CI-controlled plan
* Working apply
* Clean Git repo

This is real enterprise DevOps.

---

# 🔮 What Comes After This?

Now you can move into advanced level:

1. Convert legacy folder into `prod`
2. Refactor into reusable EKS module
3. Add separate `dev`, `stage`, `prod`
4. Introduce environment variables instead of hardcoded ARNs
5. Add cost monitoring
6. Add security scanning in CI
7. Simulate Kubernetes version upgrade

---

# 🚀 Immediate Action For You

Before moving forward:

* Change apply to manual
* Add prevent_destroy
* Protect branch

After that, your production infrastructure is enterprise-grade safe.
















This is production-safe.

---

# ✅ `envs/legacy/main.tf` (with `prevent_destroy`)

```hcl
############################################################
# EXISTING EKS CLUSTER (LEGACY - IMPORTED)
############################################################

resource "aws_eks_cluster" "legacy" {
  name     = "jum-eks"
  role_arn = "arn:aws:iam::021399177326:role/eks-admin-role"
  version  = "1.34"

  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = []

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"

    elastic_load_balancing {
      enabled = false
    }
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = [
      "subnet-07378454a0b7e50ab",
      "subnet-0b7b72eb9bdb0786a",
      "subnet-0d8b4bfe228a38a18"
    ]

    security_group_ids      = []
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  zonal_shift_config {
    enabled = false
  }

  tags = {}

  ##########################################################
  # PRODUCTION PROTECTION
  ##########################################################
  lifecycle {
    prevent_destroy = true
  }
}

############################################################
# EXISTING NODE GROUP (LEGACY - IMPORTED)
############################################################

resource "aws_eks_node_group" "legacy_nodes" {
  cluster_name    = "jum-eks"
  node_group_name = "nodes"

  node_role_arn = "arn:aws:iam::021399177326:role/node-roles"

  subnet_ids = [
    "subnet-07378454a0b7e50ab",
    "subnet-0b7b72eb9bdb0786a",
    "subnet-0d8b4bfe228a38a18"
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20
  version        = "1.34"

  scaling_config {
    min_size     = 0
    max_size     = 1
    desired_size = 0
  }

  update_config {
    max_unavailable = 1
  }

  node_repair_config {
    enabled = false
  }

  labels = {}
  tags   = {}

  ##########################################################
  # PRODUCTION PROTECTION
  ##########################################################
  lifecycle {
    prevent_destroy = true
  }
}
```

---

# 🔒 What `prevent_destroy` Does

If someone:

* Deletes the resource block
* Changes name
* Tries to destroy via CI
* Runs `terraform destroy`

Terraform will fail with:

```
Error: Instance cannot be destroyed
Resource has lifecycle.prevent_destroy set
```

This protects your production EKS.

---

# 🟢 Next Steps

After saving this file:

```bash
git add envs/legacy/main.tf
git commit -m "Add prevent_destroy to legacy EKS resources"
git push
```

Pipeline will run plan.

You should see:

```
No changes.
```

Because `lifecycle` does not change infrastructure — it only affects Terraform behavior.



















