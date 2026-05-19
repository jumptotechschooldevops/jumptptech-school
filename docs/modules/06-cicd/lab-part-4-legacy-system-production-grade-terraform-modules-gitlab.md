---
title: "lab part 5: legacy system production-grade Terraform modules + GitLab"
description: "1) Enterprise repo model            infra-modules (reusable building..."
published: 2026-02-26
source: "https://dev.to/jumptotech/lab-part-4-legacy-system-production-grade-terraform-modules-gitlab-1fd1"
tags: []
---

# lab part 5: legacy system production-grade Terraform modules + GitLab



## 1) Enterprise repo model

### `infra-modules` (reusable building blocks)

```text
infra-modules/
└── modules/
    ├── vpc/
    ├── alb/
    ├── iam_baseline/
    ├── eks/                 <-- NEW (we’ll create)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    └── ...
```

### `infra-live` (env instantiation + state separation)

```text
infra-live/
└── envs/
    ├── dev/
    ├── stage/
    └── prod/
```

**Rule:** `infra-live` should mostly be **module calls**, not long resource blocks.

---

## 2) Full enterprise GitLab CI for multi-env

### GitLab CI variables (Settings → CI/CD → Variables)

Set these:

* `AWS_REGION = us-east-2`
* `TF_STATE_BUCKET = jumptotech-terraform-state-021399177326`
* `TF_LOCK_TABLE = terraform-lock-table`

(Your OIDC assume role script stays: `scripts/assume_role.sh`)

---

### `.gitlab-ci.yml` (enterprise multi-env)

This gives:

* plan on MR + main
* apply manual (stage/prod), optional auto-apply dev
* tfsec + OPA conftest guardrails
* per-env backend keys

```yaml
stages:
  - lint
  - security
  - plan
  - policy
  - apply

default:
  image: hashicorp/terraform:1.7
  before_script:
    - apk add --no-cache bash curl jq aws-cli git
    - . scripts/assume_role.sh
    - terraform version

workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"

variables:
  TF_IN_AUTOMATION: "true"
  TF_INPUT: "false"

# ---------- helpers (YAML anchors) ----------
.tf_init_dev: &tf_init_dev
  - cd envs/dev
  - terraform init -reconfigure
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=dev/terraform.tfstate"
      -backend-config="region=$AWS_REGION"
      -backend-config="dynamodb_table=$TF_LOCK_TABLE"
      -backend-config="encrypt=true"

.tf_init_stage: &tf_init_stage
  - cd envs/stage
  - terraform init -reconfigure
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=stage/terraform.tfstate"
      -backend-config="region=$AWS_REGION"
      -backend-config="dynamodb_table=$TF_LOCK_TABLE"
      -backend-config="encrypt=true"

.tf_init_prod: &tf_init_prod
  - cd envs/prod
  - terraform init -reconfigure
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=prod/terraform.tfstate"
      -backend-config="region=$AWS_REGION"
      -backend-config="dynamodb_table=$TF_LOCK_TABLE"
      -backend-config="encrypt=true"

# ---------- lint ----------
fmt:
  stage: lint
  script:
    - terraform fmt -recursive -check
  rules:
    - when: always

validate_dev:
  stage: lint
  script:
    - *tf_init_dev
    - terraform validate
  rules:
    - when: always

validate_stage:
  stage: lint
  script:
    - *tf_init_stage
    - terraform validate
  rules:
    - when: always

validate_prod:
  stage: lint
  script:
    - *tf_init_prod
    - terraform validate
  rules:
    - when: always

# ---------- security: tfsec ----------
tfsec:
  stage: security
  image: alpine:3.19
  before_script:
    - apk add --no-cache bash curl git
    - curl -sSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | sh
  script:
    - tfsec --version
    - tfsec .
  rules:
    - when: always

# ---------- plan (generate JSON too, for policies/cost) ----------
plan_dev:
  stage: plan
  script:
    - *tf_init_dev
    - terraform plan -var="aws_region=$AWS_REGION" -out=tfplan
    - terraform show -json tfplan > tfplan.json
  artifacts:
    paths: [ "envs/dev/tfplan", "envs/dev/tfplan.json" ]
    expire_in: 1 day
  rules:
    - when: always

plan_stage:
  stage: plan
  script:
    - *tf_init_stage
    - terraform plan -var="aws_region=$AWS_REGION" -out=tfplan
    - terraform show -json tfplan > tfplan.json
  artifacts:
    paths: [ "envs/stage/tfplan", "envs/stage/tfplan.json" ]
    expire_in: 1 day
  rules:
    - when: always

plan_prod:
  stage: plan
  script:
    - *tf_init_prod
    - terraform plan -var="aws_region=$AWS_REGION" -out=tfplan
    - terraform show -json tfplan > tfplan.json
  artifacts:
    paths: [ "envs/prod/tfplan", "envs/prod/tfplan.json" ]
    expire_in: 1 day
  rules:
    - when: always

# ---------- policy: OPA conftest on tfplan.json ----------
opa_policy:
  stage: policy
  image: alpine:3.19
  before_script:
    - apk add --no-cache bash curl
    - curl -sSL https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_0.56.0_Linux_x86_64.tar.gz | tar -xz
    - mv conftest /usr/local/bin/conftest
    - conftest --version
  script:
    # validate all env plans if present
    - |
      for p in envs/*/tfplan.json; do
        echo "Policy check: $p"
        conftest test "$p" -p policy/ --parser json
      done
  rules:
    - when: always

# ---------- apply (promotion model) ----------
apply_dev:
  stage: apply
  script:
    - *tf_init_dev
    - terraform apply -auto-approve -var="aws_region=$AWS_REGION"
  rules:
    # Dev can auto-apply only on main (optional)
    - if: $CI_COMMIT_BRANCH == "main"
      when: on_success
    - when: never

apply_stage:
  stage: apply
  script:
    - *tf_init_stage
    - terraform apply -auto-approve -var="aws_region=$AWS_REGION"
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
    - when: never

apply_prod:
  stage: apply
  script:
    - *tf_init_prod
    - terraform apply -auto-approve -var="aws_region=$AWS_REGION"
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
    - when: never
```

### Add a `policy/` folder (OPA rules)

Example guardrails (simple but strong):

* deny public 0.0.0.0/0 on sensitive SG rules
* deny destroying EKS cluster
* require tags

**policy/deny_destroy.rego**

```rego
package terraform

deny[msg] {
  some r
  r := input.resource_changes[_]
  r.change.actions[_] == "delete"
  contains(r.type, "aws_eks_cluster")
  msg := sprintf("Deny destroy: %s.%s", [r.type, r.name])
}
```

**policy/require_tags.rego**

```rego
package terraform

required := {"Environment", "System"}

deny[msg] {
  some r
  r := input.resource_changes[_]
  after := r.change.after
  after.tags == null
  msg := sprintf("Missing tags on %s.%s", [r.type, r.name])
}

deny[msg] {
  some r, k
  r := input.resource_changes[_]
  after := r.change.after
  after.tags[k] == null
  k := required[_]
  msg := sprintf("Missing required tag %s on %s.%s", [k, r.type, r.name])
}
```

---

## 3) Convert PROD EKS into reusable module

### Create module: `infra-modules/modules/eks`

**versions.tf**

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**variables.tf**

```hcl
variable "cluster_name" { type = string }
variable "cluster_role_arn" { type = string }
variable "kubernetes_version" { type = string }

variable "subnet_ids" { type = list(string) }
variable "endpoint_public_access" { type = bool }
variable "endpoint_private_access" { type = bool }
variable "public_access_cidrs" { type = list(string) }

variable "node_group_name" { type = string }
variable "node_role_arn" { type = string }
variable "instance_types" { type = list(string) }
variable "ami_type" { type = string }
variable "disk_size" { type = number }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }

variable "tags" { type = map(string) default = {} }
```

**main.tf**

```hcl
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = var.instance_types
  ami_type       = var.ami_type
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
```

**outputs.tf**

```hcl
output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn"  { value = aws_eks_cluster.this.arn }
output "node_group_arn" { value = aws_eks_node_group.this.arn }
```

---

## 4) Update `infra-live/envs/prod` to call the module

In `envs/prod/main.tf` replace resources with module call:

```hcl
module "eks" {
  source = "git::https://gitlab.com/jumptotech/infra-modules.git//modules/eks?ref=v1.0.0"

  cluster_name        = "jum-eks"
  cluster_role_arn    = "arn:aws:iam::021399177326:role/eks-admin-role"
  kubernetes_version  = "1.34"

  subnet_ids              = ["subnet-07378454a0b7e50ab","subnet-0b7b72eb9bdb0786a","subnet-0d8b4bfe228a38a18"]
  endpoint_public_access  = true
  endpoint_private_access = true
  public_access_cidrs     = ["0.0.0.0/0"]

  node_group_name = "nodes"
  node_role_arn   = "arn:aws:iam::021399177326:role/node-roles"

  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20
  desired_size   = 0
  min_size       = 0
  max_size       = 1

  tags = {
    Environment = "prod"
    System      = "legacy"
    ManagedBy   = "Terraform"
  }
}
```

### Critical step: move state addresses

Right now your state has:

* `aws_eks_cluster.legacy`
* `aws_eks_node_group.legacy_nodes`

After module, Terraform expects:

* `module.eks.aws_eks_cluster.this`
* `module.eks.aws_eks_node_group.this`

So run (in `envs/prod`):

```bash
terraform state mv aws_eks_cluster.legacy module.eks.aws_eks_cluster.this
terraform state mv aws_eks_node_group.legacy_nodes module.eks.aws_eks_node_group.this
```

Then:

```bash
terraform plan
```

You want:

* **No changes**

---

## 5) Build dev → stage → prod promotion model

### Simple enterprise promotion rules

* **Feature branches**: run plan only
* **Merge to main**:

  * dev apply can be auto (optional)
  * stage apply is manual (always)
  * prod apply is manual + approvals (always)

### How DevOps works day-to-day

* You develop module changes in `infra-modules`
* You bump module version `ref=v1.0.1`
* You test in `envs/dev`
* You promote to `envs/stage`
* You finally promote to `envs/prod`

**Promotion is not copying files.**
It’s “same module + different tfvars”.

---

## 6) Guardrails: security + cost

### Security guardrails

* `terraform fmt -check`
* `terraform validate`
* `tfsec` (already in CI)
* `OPA conftest` on `tfplan.json` (already in CI)











We will **not recreate** anything. We will:

1. create a module in `infra-modules`
2. update `infra-live/envs/prod` to call the module
3. **move Terraform state addresses** (`terraform state mv`)
4. run `plan` → must show **No changes**

---

# Step 0 — Do this in a branch (safety)

In **infra-live**:

```bash
git checkout -b refactor-prod-eks-module
```

In **infra-modules**:

```bash
git checkout -b add-eks-module
```

---

# Step 1 — Create EKS module in `infra-modules`

Create folder:

```bash
mkdir -p modules/eks
```

### `infra-modules/modules/eks/versions.tf`

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### `infra-modules/modules/eks/variables.tf`

```hcl
variable "cluster_name" { type = string }
variable "cluster_role_arn" { type = string }
variable "kubernetes_version" { type = string }

variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) default = [] }
variable "endpoint_public_access" { type = bool }
variable "endpoint_private_access" { type = bool }
variable "public_access_cidrs" { type = list(string) }

variable "service_ipv4_cidr" { type = string default = "10.100.0.0/16" }

variable "node_group_name" { type = string }
variable "node_role_arn" { type = string }
variable "instance_types" { type = list(string) }
variable "ami_type" { type = string }
variable "disk_size" { type = number }

variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }

variable "max_unavailable" { type = number default = 1 }

variable "tags" { type = map(string) default = {} }
```

### `infra-modules/modules/eks/main.tf`

```hcl
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = []

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.service_ipv4_cidr

    elastic_load_balancing {
      enabled = false
    }
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types
  ami_type       = var.ami_type
  disk_size      = var.disk_size
  version        = var.kubernetes_version

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  node_repair_config {
    enabled = false
  }

  labels = {}
  tags   = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
```

### `infra-modules/modules/eks/outputs.tf`

```hcl
output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn"  { value = aws_eks_cluster.this.arn }
output "node_group_arn" { value = aws_eks_node_group.this.arn }
```

Commit and push module branch:

```bash
git add modules/eks
git commit -m "Add eks module"
git push -u origin add-eks-module
```

Then merge to main (or tag `v1.0.1`). If you prefer tags:

```bash
git tag v1.0.1
git push --tags
```

---

# Step 2 — Update `infra-live/envs/prod/main.tf` to use the module

Replace your prod EKS resources with this module call:

```hcl
module "eks" {
  source = "git::https://gitlab.com/jumptotech/infra-modules.git//modules/eks?ref=v1.0.1"

  cluster_name       = "jum-eks"
  cluster_role_arn   = "arn:aws:iam::021399177326:role/eks-admin-role"
  kubernetes_version = "1.34"

  subnet_ids = [
    "subnet-07378454a0b7e50ab",
    "subnet-0b7b72eb9bdb0786a",
    "subnet-0d8b4bfe228a38a18"
  ]

  security_group_ids      = []
  endpoint_public_access  = true
  endpoint_private_access = true
  public_access_cidrs     = ["0.0.0.0/0"]

  node_group_name = "nodes"
  node_role_arn   = "arn:aws:iam::021399177326:role/node-roles"

  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20

  desired_size = 0
  min_size     = 0
  max_size     = 1

  max_unavailable = 1

  tags = {
    Environment = "prod"
    System      = "legacy"
    ManagedBy   = "Terraform"
  }
}
```

---

# Step 3 — Move state addresses (THIS is the key step)

Go to prod folder:

```bash
cd envs/prod
terraform init
```

Now move state from old addresses to module addresses.

Your old addresses (from your earlier main.tf) were:

* `aws_eks_cluster.legacy`
* `aws_eks_node_group.legacy_nodes`

New addresses are:

* `module.eks.aws_eks_cluster.this`
* `module.eks.aws_eks_node_group.this`

Run:

```bash
terraform state mv aws_eks_cluster.legacy module.eks.aws_eks_cluster.this
terraform state mv aws_eks_node_group.legacy_nodes module.eks.aws_eks_node_group.this
```

---

# Step 4 — Confirm: plan must be zero changes

```bash
terraform plan
```

Expected:

```text
No changes. Your infrastructure matches the configuration.
```

If you see **create/destroy**, stop and paste the plan.

---

# Step 5 — Commit infra-live changes and let CI run plan

Back in `infra-live`:

```bash
git add envs/prod/main.tf
git commit -m "Refactor prod EKS to use eks module"
git push -u origin refactor-prod-eks-module
```

Open MR → pipeline runs → apply stays manual.

---

## What’s next after module conversion

Once prod is module-based, the enterprise path is:

1. **Create dev EKS** using the same module but cheaper (smaller node types)
2. **Create stage** mirroring prod (same module, slightly reduced scaling)
3. **Promotion model** becomes just “same module, different tfvars”
4. Add guardrails (tfsec + OPA) on the plan JSON










Go to:

```
infra-modules/modules/eks/variables.tf
```

Replace ALL one-line variable blocks with proper multi-line format.

---

## ✅ Correct `variables.tf`

```hcl
variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_private_access" {
  type = bool
}

variable "public_access_cidrs" {
  type = list(string)
}

variable "service_ipv4_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "node_group_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "instance_types" {
  type = list(string)
}

variable "ami_type" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "max_unavailable" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

---

# 🚀 After Fixing

In `infra-modules`:

```bash
git add modules/eks/variables.tf
git commit -m "Fix variable block formatting in eks module"
git push
```

If you're using tag `v1.0.1`, either:

* Update tag to `v1.0.2`
  OR
* Change ref in prod to new commit branch

Recommended (clean way):

```bash
git tag v1.0.2
git push --tags
```

Then update in `infra-live`:

```hcl
ref=v1.0.2
```

---

# 🔁 Then Back in infra-live/envs/prod

Run again:

```bash
terraform init -reconfigure \
  -backend-config="bucket=jumptotech-terraform-state-021399177326" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=terraform-lock-table" \
  -backend-config="encrypt=true"
```

If it initializes successfully:

Run:

```bash
terraform state list
```










Your trust policy only allows:

```json
"gitlab.com:sub": "project_path:jumptotech/infra-live:ref_type:branch:ref:main"
```

That means:

👉 Only branch `main` can assume this role
👉 Any other branch (like `refactor-prod-eks-module`) is blocked
👉 That is why you get **AccessDenied**

---

# 🔥 Why It Failed

You ran pipeline on:

```
refactor-prod-eks-module
```

But AWS only allows:

```
main
```

So AWS correctly denied it.

This means your OIDC setup is actually working correctly — it’s just restricted.

---

# ✅ Fix Option 1 (Recommended for Learning)

Allow all branches of this project:

Update trust policy to:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::021399177326:oidc-provider/gitlab.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.com:aud": "https://gitlab.com"
        },
        "StringLike": {
          "gitlab.com:sub": "project_path:jumptotech/infra-live:*"
        }
      }
    }
  ]
}
```

This allows:

* Any branch
* Any tag
* But only inside this project

This is safe and common.

















