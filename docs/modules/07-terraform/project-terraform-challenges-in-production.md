---
title: "PROJECT: Terraform Challenges in Production"
description: "0) Create folders   terraform-prod-challenges/ ├── 00-baseline/ ├──..."
published: 2025-12-22
source: "https://dev.to/jumptotech/project-terraform-challenges-in-production-580k"
tags: []
---

# PROJECT: Terraform Challenges in Production



# 0) Create folders

terraform-prod-challenges/
├── 00-baseline/
├── 01-drift-and-refresh/
├── 02-import-existing/
├── 03-rename-without-destroy-state-mv/
├── 04-address-change-count-to-foreach/
├── 05-prevent-destroy-safety/
├── 06-backend-change-reconfigure/
├── 07-state-locking-simulation/
├── 08-partial-apply-and-recovery/
├── 09-outputs-remote-state-contract/
│   ├── platform/
│   └── app/
└── 10-provider-version-lock-file/


---

# 00-baseline (baseline resource)

## ✅ Code

**00-baseline/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "app_config" {
  filename = "${path.module}/app.conf"
  content  = "version=1\nowner=platform\n"
}
```

**00-baseline/outputs.tf**

```hcl
output "config_path" {
  value = local_file.app_config.filename
}
```

## Detailed explanation 

### What problem is this?

No problem yet. This is your **“Hello World”**.

### Where it happens?

Everywhere: dev/stage/prod. This is **how Terraform starts**.

### When it matters?

* at the beginning of a project
* in onboarding
* before release automation

### Interview answer

> “I start with a simple baseline to show Terraform init/plan/apply and state. It helps new engineers understand how Terraform manages infrastructure.”

---

# 01-drift-and-refresh (drift in prod)

## ✅ Code

**01-drift-and-refresh/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "drift_demo" {
  filename = "${path.module}/drift.txt"
  content  = "managed_by=terraform\nvalue=100\n"
}
```

**01-drift-and-refresh/README.txt**

```text
Steps:

1) terraform init
2) terraform apply

3) Manually edit drift.txt and change value=100 to value=999

4) terraform plan

Terraform will detect drift and plan to restore desired state.
```

## Detailed explanation 

### What is the issue?

**Drift** means: resource was changed outside Terraform.

### Where it happens?

Mostly **production**, because people:

* change AWS Console settings
* hotfix security group rules
* patch something quickly during outage

### When it happens?

* during incident response (outage)
* after release (someone “fixes” prod)
* anytime manual change happens

### Why dangerous?

Next `terraform apply` can:

* revert the manual fix (break prod again)
* create confusion: “Why did it change back?”

### How Terraform solves it?

`terraform plan` compares:

* code (desired)
* real file (actual)
  and shows difference.

### Interview answer

> “Drift happens when someone changes infra manually. I detect it using terraform plan, then decide: either accept the change (update code) or revert back to code.”

---

# 02-import-existing (resource exists already)

## ✅ Code

**02-import-existing/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "import_me" {
  filename = "${path.module}/existing.txt"
  content  = "this_is_now_managed\n"
}
```

**02-import-existing/README.txt**

```text
Steps:

1) Create file first (outside Terraform):
   echo "i already existed" > existing.txt

2) terraform init

3) Import it into state:
   terraform import local_file.import_me existing.txt

4) terraform plan

Key point:
Import updates Terraform STATE. After import, ensure Terraform code matches reality.
```

## Detailed explanation 

### What is the issue?

In real life, Terraform is introduced **after infrastructure already exists**.

### Where it happens?

* old AWS accounts
* inherited projects
* manual infra created before IaC

### When it happens?

* onboarding Terraform into existing company environment
* migration from CloudFormation/manual to Terraform
* before big release, company wants standardization

### Why dangerous?

If you don’t import:

* Terraform will try to create duplicate resources
* naming collisions
* conflicts, downtime risk

### How Terraform solves it?

`terraform import` connects an existing object to Terraform state.

### Interview answer

> “Many resources exist before Terraform. I use terraform import to bring them under Terraform management, then I update code to match real configuration.”

---

# 03-rename-without-destroy-state-mv (refactor safely)

## ✅ Code

**03-rename-without-destroy-state-mv/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "old_name" {
  filename = "${path.module}/name.txt"
  content  = "hello\n"
}
```

**03-rename-without-destroy-state-mv/README.txt**

```text
Steps:

1) terraform init
2) terraform apply

3) Rename resource in code:
   local_file.old_name -> local_file.new_name

4) terraform plan  (it will show destroy/create)

Correct fix:
terraform state mv local_file.old_name local_file.new_name

Then:
terraform plan
terraform apply
```

## Detailed explanation 

### What is the issue?

Developer refactors code: changes resource name.
Terraform thinks:

* old resource removed => destroy
* new resource added => create

### Where it happens?

* in dev branch refactoring
* module cleanup
* team renaming standards

### When it happens?

* during release preparation
* during large refactor PR
* migration to modules

### Why dangerous?

Can delete prod resources by mistake.

### How Terraform solves it?

`terraform state mv` updates state address without changing real resource.

### Interview answer

> “When we refactor Terraform labels, we migrate state addresses using terraform state mv to avoid destroying production resources.”

---

# 04-address-change-count-to-foreach (classic breaking change)

## ✅ Code (Start with COUNT)

**04-address-change-count-to-foreach/main.tf (COUNT version first)**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "names" {
  type    = list(string)
  default = ["orders", "payments"]
}

resource "local_file" "svc" {
  count    = length(var.names)
  filename = "${path.module}/${var.names[count.index]}.txt"
  content  = "service=${var.names[count.index]}\n"
}
```

**04-address-change-count-to-foreach/README.txt**

```text
Steps:

1) terraform init
2) terraform apply

3) Edit main.tf to FOREACH version:

resource "local_file" "svc" {
  for_each = toset(var.names)
  filename = "${path.module}/${each.value}.txt"
  content  = "service=${each.value}\n"
}

4) terraform plan (will show recreate)

Fix with state mv:
terraform state mv 'local_file.svc[0]' 'local_file.svc["orders"]'
terraform state mv 'local_file.svc[1]' 'local_file.svc["payments"]'

Then:
terraform plan
terraform apply
```

## Detailed explanation (students)

### What is the issue?

Terraform identifies resources by **address**.
With count: `svc[0]`, `svc[1]`
With for_each: `svc["orders"]`, `svc["payments"]`

So Terraform thinks they are new resources.

### Where it happens?

* when code matures
* when teams want stable keys
* in modules during refactor

### When it happens?

* before release (refactor PR)
* during standardization
* while adding new services

### Why dangerous?

Terraform may destroy and recreate resources:

* downtime (ALB, ECS, RDS settings)
* lost data (if storage resource recreated)
* production outage risk

### How Terraform solves it?

State migration: map old addresses to new addresses.

### Interview answer

> “Count-to-for_each migration changes resource addresses. To avoid recreation, I migrate state with terraform state mv so production resources remain untouched.”

---

# 05-prevent-destroy-safety (guardrail)

## ✅ Code

**05-prevent-destroy-safety/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "critical" {
  filename = "${path.module}/critical.txt"
  content  = "do_not_delete\n"

  lifecycle {
    prevent_destroy = true
  }
}
```

**05-prevent-destroy-safety/README.txt**

```text
Steps:
1) terraform init
2) terraform apply
3) terraform destroy

It will fail because prevent_destroy blocks deletion.
```

## Detailed explanation 

### What is the issue?

Accidental deletion in Terraform code or wrong apply.

### Where it happens?

Production, especially for:

* S3 state bucket
* DynamoDB lock table
* RDS
* IAM critical roles

### When it happens?

* release time
* cleanup tasks
* refactor mistakes
* wrong workspace selected

### How Terraform solves it?

`prevent_destroy` blocks deletion even if plan says destroy.

### Interview answer

> “For critical resources, we set lifecycle prevent_destroy to avoid accidental deletion during CI/CD or refactoring.”

---

# 06-backend-change-reconfigure (safe + always runnable)

## ✅ Code (NO provider needed)

**06-backend-change-reconfigure/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "backend_note" {
  input = "backend demo"
}
```

**06-backend-change-reconfigure/README.txt**

```text
Production behavior:

If backend config changes:
terraform init -reconfigure

If moving state to a new backend:
terraform init -migrate-state
```

## Detailed explanation (students)

### What is the issue?

Terraform state location changed:

* local -> S3
* S3 bucket name changed
* key path changed
* region changed

### Where it happens?

* production pipelines
* team collaboration setups

### When it happens?

* moving from local dev to shared backend
* company security policy update
* migration to new AWS account

### Why dangerous?

Wrong backend = wrong state:

* Terraform may create duplicates
* or destroy wrong resources

### How Terraform solves it?

* `terraform init -reconfigure` tells Terraform to accept new backend settings
* `terraform init -migrate-state` moves state safely

### Interview answer

> “Backend changes require terraform init -reconfigure. If we move state, we use -migrate-state to prevent losing track of production resources.”

---

# 07-state-locking-simulation 

## ✅ Code

**07-state-locking-simulation/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

resource "time_sleep" "simulate_long_apply" {
  create_duration = "60s"
}
```

**07-state-locking-simulation/README.txt**

```text
Terminal 1:
terraform init
terraform apply

While it's running, Terminal 2:
terraform apply

Local backend won't show real locks.
In production with S3 + DynamoDB locks: it prevents concurrent apply.
```

## Detailed explanation 

### What is the issue?

Two engineers (or CI + human) run `terraform apply` at same time.

### Where it happens?

* production pipelines
* shared infrastructure repos
* busy teams

### When it happens?

* during release
* hotfix while pipeline is running
* multiple PR merges at once

### Why dangerous?

Concurrent apply can corrupt state or cause inconsistent infra.

### Real production solution

S3 backend + DynamoDB locking:

* DynamoDB ensures only one apply at a time

### Interview answer

> “In production we use DynamoDB state locking to prevent concurrent terraform apply and avoid state corruption.”

---

# 08-partial-apply-and-recovery (apply fails mid-way)

## ✅ Code

**08-partial-apply-and-recovery/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "step1" {}

resource "null_resource" "step2_fail" {
  provisioner "local-exec" {
    command = "echo 'simulating failure' && exit 1"
  }
}
```

**08-partial-apply-and-recovery/README.txt**

```text
Steps:
1) terraform init
2) terraform apply (will fail)

Inspect state:
terraform state list

Fix demo: change exit 1 to exit 0 then apply again.
```

## Detailed explanation (students)

### What is the issue?

Terraform started creating resources, then it failed.
So some resources exist, others don’t.

### Where it happens?

Mostly **production** because APIs fail:

* IAM permissions missing
* AWS rate limits
* timeouts
* dependency errors
* networking issues

### When it happens?

* during release
* during delivery pipeline apply
* during disaster recovery changes

### Why dangerous?

Now infra is in “half created” state.

### How Terraform solves it?

Terraform state records what succeeded.
After fixing problem, run `apply` again.

### Interview answer

> “Partial applies happen. We check terraform state list, fix root cause, then rerun apply to converge infrastructure.”

---

# 09-outputs-remote-state-contract (platform vs app teams)

## ✅ Code

### Platform

**09-outputs-remote-state-contract/platform/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "platform" {
  filename = "${path.module}/platform.txt"
  content  = "subnet_id=subnet-123\n"
}
```

**09-outputs-remote-state-contract/platform/outputs.tf**

```hcl
output "subnet_id" {
  value = "subnet-123"
}
```

### App (NO null provider; uses terraform_data)

**09-outputs-remote-state-contract/app/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"
}

data "terraform_remote_state" "platform" {
  backend = "local"
  config = {
    path = "../platform/terraform.tfstate"
  }
}

resource "terraform_data" "use_contract" {
  input = {
    subnet = data.terraform_remote_state.platform.outputs.subnet_id
  }
}
```

**09-outputs-remote-state-contract/app/README.txt**

```text
Steps:

1) Run platform:
cd platform
terraform init
terraform apply

2) Run app:
cd ../app
terraform init
terraform apply

Break contract:
Rename output subnet_id -> public_subnet_id in platform outputs.tf
Apply platform again

App will fail until it is updated.

Lesson:
Outputs are API contracts between teams.
```

## Detailed explanation (students)

### What is the issue?

App team depends on platform output names.
If platform renames output, app breaks.

### Where it happens?

Real org structure:

* networking team outputs subnet IDs
* security team outputs IAM role ARN
* app team reads them via remote state

### When it happens?

* release time when platform changes
* platform upgrade
* refactoring outputs

### Why dangerous?

App deployment pipeline fails.
Delayed release.

### How Terraform solves it?

Not automatic. This is process + design:

* treat outputs as versioned API
* communicate changes
* create backward compatible outputs

### Interview answer

> “Remote state outputs act like API contracts. If platform changes output names, application stacks break, so we version and communicate output changes.”

---

# 10-provider-version-lock-file (consistency across engineers and CI)

## ✅ Code

**10-provider-version-lock-file/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_id" "demo" {
  byte_length = 4
}

output "id" {
  value = random_id.demo.hex
}
```

**10-provider-version-lock-file/README.txt**

```text
Steps:
terraform init
ls -la .terraform.lock.hcl

The lock file pins provider versions.
Commit it to Git so all engineers and CI use same provider builds.
```

## Detailed explanation 

### What is the issue?

Different machines install different provider versions.
CI runs with one version, laptop runs with another.

### Where it happens?

* CI/CD pipelines
* multi-engineer teams
* long-lived repos

### When it happens?

* release time (CI suddenly breaks)
* provider update got released yesterday
* new engineer runs init

### How Terraform solves it?

`.terraform.lock.hcl` records exact provider version + hashes.
Commit it to Git.

### Interview answer

> “We commit .terraform.lock.hcl so CI and all engineers use the same provider versions, avoiding surprises during release.”

---

# How students should run everything

Each lab is independent:

```bash
cd 01-drift-and-refresh
terraform init
terraform apply
```

For lab 09, order matters:

```bash
cd 09-outputs-remote-state-contract/platform
terraform init
terraform apply

cd ../app
terraform init
terraform apply
```

---

# One interview story that covers everything (simple words)

> “In production, Terraform problems usually come from drift, state, or team changes. Drift happens when someone changes infra manually. Imports happen because infra existed before Terraform. Refactors like rename, count-to-for_each require state migrations to prevent destroy. We protect critical resources with prevent_destroy. We use S3 backend and DynamoDB locks to avoid concurrent apply. Apply can fail mid-way, so we fix issue and rerun apply to converge. Outputs are contracts between teams, so we version them. And we commit lock files so CI and developers use the same provider versions.”


