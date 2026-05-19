---
title: "lab part 1: legacy system production-grade Terraform modules + GitLab"
description: "how to connect a GitLab Runner to an EC2 instance step-by-step.              ✅ Step 1 — Launch..."
published: 2026-02-23
source: "https://dev.to/jumptotech/lab-legacy-system-production-grade-terraform-modules-gitlab-1g3m"
tags: []
---

# lab part 1: legacy system production-grade Terraform modules + GitLab



**how to connect a GitLab Runner to an EC2 instance** step-by-step.

---

# ✅ Step 1 — Launch EC2

Create an EC2 instance:

* Ubuntu 22.04 or 24.04
* Public subnet
* Auto-assign Public IP = Enabled
* Security Group:

  * Inbound: SSH (22) from your IP
  * Outbound: Allow all (default)

SSH into it:

```bash
ssh -i key.pem ubuntu@<PUBLIC-IP>
```

Test internet:

```bash
curl -I https://gitlab.com
```

It must work.

---

# ✅ Step 2 — Install GitLab Runner on EC2

Download runner:

```bash
curl -L --output gitlab-runner \
https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
```

Move and make executable:

```bash
sudo mv gitlab-runner /usr/local/bin/
sudo chmod +x /usr/local/bin/gitlab-runner
```

Check version:

```bash
gitlab-runner --version
```

---

# ✅ Step 3 — Install Runner as Service

Create runner user and install service:

```bash
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash || true

sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

Check status:

```bash
sudo gitlab-runner status
```

It should say:

```
Service is running
```

---

# ✅ Step 4 — Create Runner in GitLab

Go to:

**Project → Settings → CI/CD → Runners → Create project runner**

Set:

* Tags: `terraform,aws`
* Run untagged jobs: OFF
* Lock to current project: ON

Click **Create runner**

Copy the registration token.

---

# ✅ Step 5 — Register Runner on EC2

On EC2 run:

```bash
sudo gitlab-runner register
```

Enter:

GitLab URL:

```
https://gitlab.com/
```

Registration token:

```
<PASTE TOKEN>
```

Runner name:

```
infra-live-ec2-runner
```

Executor:

```
shell
```

You will see:

```
Runner registered successfully
```

---

# ✅ Step 6 — Verify Connection

Run:

```bash
sudo gitlab-runner verify
```

Then go to GitLab UI.

You should see:

🟢 Runner Online











## Lab Story (Legacy System)

Your company has a legacy app running on 1 EC2 instance with manual changes and no IaC. You must move to **production-grade Infrastructure-as-Code**:

* **Networking**: VPC, public/private subnets, NAT, routing
* **Compute**: EC2 (legacy app) behind ALB + AutoScaling (still “legacy-style” but stabilized)
* **Data**: RDS (optional) or keep “legacy local DB” (phase-based)
* **Observability**: CloudWatch logs/alarms, ALB access logs
* **Security**: least-privilege IAM, encrypted storage, SSM access instead of SSH
* **Process**: GitLab CI pipelines, approvals, “plan on MR / apply only on protected branches”, drift detection

---

## Target Architecture (Production Style)

**3 environments**: `dev`, `stage`, `prod`

* Each env has its own state and variables
* `prod` is protected: manual apply + approvals + protected branches
* Modules are versioned and reused

---

# What you will build (Repositories)

## Repo 1: `infra-modules` (shared modules)

Contains reusable modules:

* `modules/vpc`
* `modules/alb`
* `modules/asg_legacy_app`
* `modules/iam_baseline`
* `modules/observability`

## Repo 2: `infra-live` (environment deployments)

Contains:

* `envs/dev`
* `envs/stage`
* `envs/prod`

Each env references modules via git tag, e.g. `?ref=v1.0.0`.

---

# Phase 0 — GitLab Setup (Production Controls)

## A) Create GitLab Projects

1. Create group: `company-infra`
2. Create project: `infra-modules`
3. Create project: `infra-live`

## B) Protect branches

In both repos:

* Protect `main`
* Allow merge to `main` only with approvals (at least 1–2)

In `infra-live`:

* Protect `prod` (or keep everything on `main` but require manual job + approvals)
* Only Maintainers can run “apply-prod”

## C) CI/CD Variables (GitLab)

In `infra-live` → Settings → CI/CD → Variables:

* `AWS_ACCOUNT_ID`
* `AWS_REGION` (e.g. `us-east-2`)
* `TF_STATE_BUCKET`
* `TF_LOCK_TABLE`
* `TF_STATE_KMS_KEY_ARN` (optional but production-grade)
* If using role assumption:

  * `AWS_ROLE_ARN` (recommended)
* If using GitLab OIDC to AWS (best practice):

  * configure AWS IAM OIDC provider + role trust for GitLab (students can do later as “advanced”)

---

# Phase 1 — Remote State (Production Feature)

**Goal:** store Terraform state in S3 with DynamoDB locking.

Create (one time) with AWS CLI (run locally or in a bootstrap pipeline):

```bash
aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

aws s3api put-bucket-versioning --bucket $TF_STATE_BUCKET \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name $TF_LOCK_TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

(Production add-ons: bucket encryption, block public access, access logging, KMS.)

---

# Phase 2 — `infra-modules` Repository (Module Development)

## Repo structure

```
infra-modules/
  modules/
    vpc/
      main.tf
      variables.tf
      outputs.tf
      versions.tf
    alb/
    asg_legacy_app/
    iam_baseline/
    observability/
  .gitlab-ci.yml
  README.md
```

## Example: `modules/vpc/versions.tf`

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

## Example: `modules/vpc/main.tf` (minimal but production-ready skeleton)

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

/*
For teaching: add public/private subnets, NAT, route tables.
Keep it in the module, not in live.
*/
```

## Example: `modules/vpc/variables.tf`

```hcl
variable "name" { type = string }
variable "vpc_cidr" { type = string }
variable "tags" { type = map(string), default = {} }
```

## Example: `modules/vpc/outputs.tf`

```hcl
output "vpc_id" { value = aws_vpc.this.id }
```

### Module versioning rule (production)

* Merge to `main` → tag release: `v1.0.0`, `v1.0.1`
* `infra-live` references tags only (never “latest main”)

---

# Phase 3 — `infra-live` Repository (Environments)

## Repo structure

```
infra-live/
  envs/
    dev/
      main.tf
      backend.tf
      providers.tf
      dev.tfvars
    stage/
      ...
    prod/
      ...
  .gitlab-ci.yml
  scripts/
    tf.sh
```

## `envs/dev/providers.tf`

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

provider "aws" {
  region = var.aws_region
}
```

## `envs/dev/backend.tf`

Use partial backend config (recommended) and pass details via CI:

```hcl
terraform {
  backend "s3" {}
}
```

## `envs/dev/main.tf` (calls modules by tag)

```hcl
module "vpc" {
  source   = "git::https://gitlab.com/company-infra/infra-modules.git//modules/vpc?ref=v1.0.0"
  name     = "legacy-dev"
  vpc_cidr = "10.10.0.0/16"
  tags = {
    env     = "dev"
    system  = "legacy"
    owner   = "platform"
  }
}

# Next modules:
# module "alb" { ... }
# module "asg_legacy_app" { ... }  (EC2 behind ALB, autoscaling, launch template)
# module "iam_baseline" { ... }    (SSM, minimal access)
# module "observability" { ... }   (alarms, logs)
```

## `envs/dev/variables.tf`

```hcl
variable "aws_region" { type = string }
```

---

# Phase 4 — GitLab CI/CD (Production Pipeline)

## Pipeline goals

* On **merge request**: `fmt`, `validate`, `security scan`, `plan`
* On **main** (or env branches): allow `apply-dev` automatically, `apply-stage` manual, `apply-prod` manual + protected

### `scripts/tf.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ENV_DIR="${1:?env dir required (e.g. envs/dev)}"
ACTION="${2:?action required (init|validate|plan|apply)}"
TFVARS="${3:-}"

cd "$ENV_DIR"

terraform --version

# Backend config injected from CI variables
terraform init -input=false \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${CI_PROJECT_NAME}/${ENV_DIR}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="dynamodb_table=${TF_LOCK_TABLE}"

terraform fmt -check -recursive

case "$ACTION" in
  validate)
    terraform validate
    ;;
  plan)
    terraform plan -input=false -out=tfplan ${TFVARS:+-var-file="$TFVARS"}
    ;;
  apply)
    terraform apply -input=false -auto-approve tfplan
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
```

Make executable:

```bash
chmod +x scripts/tf.sh
```

---

## `infra-live/.gitlab-ci.yml` (production-grade pattern)

```yaml
stages:
  - lint
  - validate
  - security
  - plan
  - apply
  - drift

default:
  image: hashicorp/terraform:1.7
  before_script:
    - apk add --no-cache bash curl git
    - terraform -version

variables:
  TF_IN_AUTOMATION: "true"
  AWS_REGION: "$AWS_REGION"

workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH

fmt:
  stage: lint
  script:
    - terraform fmt -check -recursive
  rules:
    - changes:
        - envs/**/*

validate:dev:
  stage: validate
  script:
    - bash scripts/tf.sh envs/dev validate
  rules:
    - changes: [ "envs/dev/**/*", "scripts/**/*" ]

validate:stage:
  stage: validate
  script:
    - bash scripts/tf.sh envs/stage validate
  rules:
    - changes: [ "envs/stage/**/*", "scripts/**/*" ]

validate:prod:
  stage: validate
  script:
    - bash scripts/tf.sh envs/prod validate
  rules:
    - changes: [ "envs/prod/**/*", "scripts/**/*" ]

# Security scanning (choose one or both)
tfsec:
  stage: security
  image: aquasec/tfsec:latest
  script:
    - tfsec envs
  allow_failure: false
  rules:
    - changes: [ "envs/**/*" ]

checkov:
  stage: security
  image: bridgecrew/checkov:latest
  script:
    - checkov -d envs
  allow_failure: false
  rules:
    - changes: [ "envs/**/*" ]

plan:dev:
  stage: plan
  script:
    - bash scripts/tf.sh envs/dev plan envs/dev/dev.tfvars
  artifacts:
    paths: [ "envs/dev/tfplan" ]
    expire_in: 1 day
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes: [ "envs/dev/**/*", "scripts/**/*" ]
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/dev/**/*", "scripts/**/*" ]

apply:dev:
  stage: apply
  script:
    - bash scripts/tf.sh envs/dev apply
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/dev/**/*", "scripts/**/*" ]
  when: on_success

plan:stage:
  stage: plan
  script:
    - bash scripts/tf.sh envs/stage plan envs/stage/stage.tfvars
  artifacts:
    paths: [ "envs/stage/tfplan" ]
    expire_in: 1 day
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes: [ "envs/stage/**/*", "scripts/**/*" ]
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/stage/**/*", "scripts/**/*" ]

apply:stage:
  stage: apply
  script:
    - bash scripts/tf.sh envs/stage apply
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/stage/**/*", "scripts/**/*" ]
  when: manual
  allow_failure: false

plan:prod:
  stage: plan
  script:
    - bash scripts/tf.sh envs/prod plan envs/prod/prod.tfvars
  artifacts:
    paths: [ "envs/prod/tfplan" ]
    expire_in: 1 day
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes: [ "envs/prod/**/*", "scripts/**/*" ]
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/prod/**/*", "scripts/**/*" ]

apply:prod:
  stage: apply
  script:
    - bash scripts/tf.sh envs/prod apply
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      changes: [ "envs/prod/**/*", "scripts/**/*" ]
  when: manual
  allow_failure: false
  environment:
    name: production

# Drift detection (scheduled pipeline)
drift:prod:
  stage: drift
  script:
    - bash scripts/tf.sh envs/prod plan envs/prod/prod.tfvars
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  allow_failure: true
```

**Production grading points** your students must implement:

* `apply:prod` is **manual**
* `main` is **protected**
* `prod` has **approval requirement**
* remote state + locking is used
* security scanners run and block merges on critical findings

---

# Phase 5 — Production Features Checklist (Grading Rubric)

Give students points for each:

### IaC Quality

* Modules separated cleanly (`infra-modules`)
* Inputs/outputs are minimal and consistent
* No hardcoded ARNs, IDs, or CIDRs in modules (only in env tfvars)

### State & Environment Isolation

* S3 backend with versioning
* DynamoDB locking
* Separate state keys per env

### Security & Compliance

* tfsec/checkov passing (or documented exceptions)
* Encryption enabled (EBS, logs, S3)
* No SSH allowed (SSM session manager)
* IAM least privilege (no `AdministratorAccess`)

### CI/CD Production Controls

* Plan on MR
* Apply only from main
* Prod apply manual + approvals
* Protected branches/tags
* Artifacts stored for plan output

### Ops

* Drift detection scheduled pipeline
* Logging/alarms exist (at least CPU high, 5xx on ALB, instance unhealthy)
* Tagging standard (env/system/owner/costcenter)

---

# Phase 6 — “Legacy App” Simulation (What runs on EC2)

Keep the app simple: return instance ID + hostname (helps show load balancing).

User-data example (in `asg_legacy_app` module):

```bash
#!/bin/bash
set -eux
apt-get update -y
apt-get install -y nginx
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(hostname)
cat > /var/www/html/index.html <<EOF
<h1>Legacy App</h1>
<p>instance: $INSTANCE_ID</p>
<p>hostname: $HOSTNAME</p>
EOF
systemctl enable nginx
systemctl restart nginx
```

Now your ALB shows different instances when you refresh.

---

# Phase 7 — Advanced Production Add-ons (Extra Credit)

Pick 2–4:

1. **GitLab OIDC to AWS** (no static AWS keys in CI)
2. **Policy-as-Code**: Open Policy Agent (OPA) / Sentinel-like rules (example: deny public S3, deny 0.0.0.0/0 on SSH)
3. **Cost estimation**: Infracost on MR (comment results)
4. **Blue/Green** using ASG + target group swapping
5. **Secrets**: store DB password in SSM Parameter Store (SecureString) + KMS
6. **Multi-account**: networking in shared account, app in workload account (real enterprise style)

---

## Deliverables students must submit

* GitLab MR link for `infra-modules` tagged release (e.g., `v1.0.0`)
* `infra-live` MR that updates envs to use that tag
* Screenshot of GitLab pipeline showing:

  * fmt/validate/security/plan passed
  * prod apply is manual and protected
* ALB URL showing legacy app pages (instance ID changes on refresh)



