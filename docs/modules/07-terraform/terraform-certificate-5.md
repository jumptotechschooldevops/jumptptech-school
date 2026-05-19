---
title: "terraform certificate #5"
description: "Terraform Team Collaboration – Git-Based Workflow            1. Why This Topic Matters   In..."
published: 2025-12-18
source: "https://dev.to/jumptotech/terraform-certificate-5-5ed8"
tags: []
---

# terraform certificate #5



# Terraform Team Collaboration – Git-Based Workflow

## 1. Why This Topic Matters

In real organizations:

* **One person never manages the entire infrastructure**
* Multiple DevOps / Cloud engineers work on the **same Terraform code**
* Infrastructure changes must be:

  * Safe
  * Trackable
  * Shareable
  * Recoverable

**why local-only Terraform is dangerous** and **why Git is mandatory** in production.

---

## 2. Local-Only Terraform Approach (Bad Practice)

### What is Local-Only?

* Terraform files (`main.tf`, `variables.tf`, `terraform.tfvars`)
* Terraform state file (`terraform.tfstate`)
* Stored **only on your laptop**

### Example

```
/tmp/terraform/
  main.tf
  variables.tf
  terraform.tfvars
  terraform.tfstate
```

You run:

```bash
terraform init
terraform apply -auto-approve
```

Everything works — **but only on your machine**.

---

## 3. Problems with Local-Only Terraform

### ❌ Problem 1: Data Loss Risk

If:

* Laptop crashes
* Hard disk fails
* OS is reinstalled

You lose:

* Terraform code
* Terraform state (MOST IMPORTANT)

👉 Infrastructure becomes **unmanageable**

---

### ❌ Problem 2: No Team Collaboration

* Other engineers **cannot access your code**
* No one can:

  * Review
  * Improve
  * Fix
  * Extend your infrastructure

Terraform becomes **person-dependent**, not team-based.

---

### ❌ Problem 3: No Version History

* You change something today
* Infrastructure breaks after 3 days
* You forgot:

  * What changed
  * Who changed it
  * Why it changed

👉 No rollback
👉 No audit
👉 No accountability

---

## 4. Git-Based Terraform Approach (Production Standard)

### What Changes?

All Terraform **code** is stored in a Git repository.

```
terraform-repo/
  main.tf
  variables.tf
  terraform.tfvars
  outputs.tf
```

Every team member:

* Clones the repo
* Works on the same codebase
* Commits changes

---

## 5. Benefits of Using Git with Terraform

### ✅ 1. Centralized Access

* All team members see the same code
* No dependency on one laptop

---

### ✅ 2. Full Version History

Git tracks:

* What changed
* When it changed
* Who changed it

Example:

```
- managed from Terraform
+ managed from TF
```

You can:

* Review old versions
* Revert broken changes

---

### ✅ 3. Team Collaboration

* Multiple engineers work together
* Code sharing becomes simple
* Knowledge is not locked to one person

---

### ✅ 4. Code Review & Approvals

Using Pull Requests:

* One engineer proposes changes
* Others review
* Approved changes are merged

This prevents:

* Accidental deletes
* Dangerous updates
* Production outages

---

### ✅ 5. CI/CD Integration (Advanced)

Git enables:

* `terraform fmt`
* `terraform validate`
* `terraform plan`
* Policy checks

Before applying changes.

---

## 6. Real-World Rule: Always Commit Latest Changes

After:

* Editing Terraform files
* Applying infrastructure changes

You MUST:

```bash
git add .
git commit -m "Updated security group rules"
git push
```

Why?

* Other engineers must work with **latest code**
* Old code causes **infrastructure conflicts**

---

## 7. Very Important: What NOT to Commit

### ❌ Do NOT Commit Terraform State

```
terraform.tfstate
terraform.tfstate.backup
```

**Why (brief explanation):**

* Contains sensitive data
* Causes state conflicts
* Not designed for Git sharing

(Detailed explanation comes in later lectures)

---

### ❌ Do NOT Commit `.terraform/` Folder

This folder contains:

* Provider plugins
* Cached binaries

Size example:

* 800+ MB for just one provider

Why NOT commit?

* Huge size
* Every engineer can regenerate it using:

```bash
terraform init
```

---

## 8. Correct `.gitignore` for Terraform

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
```

This is **mandatory** in production.

---

## 9. Summary (Key Takeaways)

* ❌ Local-only Terraform is unsafe
* ✅ Git-based Terraform is mandatory
* Git provides:

  * Collaboration
  * Versioning
  * Safety
  * Auditability
* Commit:

  * `.tf` files
* Never commit:

  * `terraform.tfstate`
  * `.terraform/`













## 2. What Is Terraform State File?

Terraform state file (`terraform.tfstate`) is a **JSON file** that stores:

* What resources Terraform created
* Resource IDs
* Attributes returned by the provider
* **Sensitive values (passwords, tokens, secrets)**

Terraform **must** store this data to manage infrastructure.

---

## 3. Critical Security Risk: Secrets in Plain Text

### Important Fact

Terraform state file **can store secrets in plain text**.

Examples:

* Database passwords
* API tokens
* Access keys
* Private endpoints

### Why This Happens

When Terraform creates a resource (example: database), the provider returns full details.
Terraform **must save them** in the state file to manage updates and deletes later.

---

## 4. Real Example: RDS Database

### Terraform Configuration (Simplified)

```hcl
resource "aws_db_instance" "example" {
  engine         = "mysql"
  instance_class = "db.t3.micro"
  username       = "admin"
  password       = "mypassword123"
}
```

### What Happens After `terraform apply`

* AWS creates the database
* Terraform creates `terraform.tfstate`
* State file contains:

```json
"username": "admin",
"password": "mypassword123"
```

**Password is stored in plain text**

---

## 5. Why Committing State to Git Is Dangerous

### Scenario 1: Too Many Git Permissions

* New employee joins
* Given read access to Git
* Can now see:

  * Production DB password
  * Tokens
  * Credentials

---

### Scenario 2: Public or Exposed Repository

* Repo accidentally made public
* Repo shared incorrectly
* Repo compromised

➡ Leads to **data breach**

---

### Scenario 3: Compromised Laptop

* Developer pulls repo
* Laptop infected or stolen
* Secrets leaked

---

## 6. Common Mistake: “I’ll Hide the Password in a File”

Many engineers think:

> “I won’t hardcode password. I’ll use `file()` function.”

### Example

```hcl
password = file("outside/pass.txt")
```

Where `pass.txt` contains:

```
mypassword123
```

### Reality

Terraform still:

* Reads the password
* Sends it to AWS
* Stores it in **terraform.tfstate in plain text**

❌ This does NOT solve the problem.

---

## 7. Proof: Sensitive in Plan, Plain Text in State

* `terraform plan` shows:

  ```
  password = (sensitive value)
  ```
* But `terraform.tfstate` shows:

  ```
  "password": "mypassword123"
  ```

**Plan hides it. State does NOT.**

---

## 8. Why “It’s Fine Today” Is a Bad Argument

Many engineers say:

> “Our current state file has no secrets.”

Problem:

* Today → no secrets
* 6 months later → DB, tokens, certs added
* State file suddenly becomes sensitive

Best practice is **future-proofing**, not reacting after breach.

---

## 9. Conclusion (State File Security)

### Key Takeaways

* Terraform state can contain secrets
* Secrets are stored in plain text
* Git access = secret access
* File function does NOT protect secrets
* Never commit state to Git

---

# Terraform and `.gitignore`

## 10. Why `.gitignore` Is Mandatory

Humans make mistakes.

Without `.gitignore`:

* Sensitive files can be accidentally committed
* One mistake = permanent Git history leak

`.gitignore` acts as **a safety net**

---

## 11. Files You Should NEVER Commit

### ❌ Do NOT Commit

| File / Folder              | Reason                 |
| -------------------------- | ---------------------- |
| `.terraform/`              | Huge provider binaries |
| `terraform.tfstate`        | Secrets, conflicts     |
| `terraform.tfstate.backup` | Same as state          |
| `crash.log`                | Debug only             |
| `terraform.log`            | Temporary logs         |
| `*.plan`                   | Execution artifacts    |

---

## 12. What Is `.gitignore`?

`.gitignore` is a text file that tells Git:

> “Ignore these files even if they exist.”

Placed at **repo root**.

---

## 13. Simple `.gitignore` Example

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
crash.log
*.plan
```

---

## 14. Demo Concept (Non-Terraform Example)

Files:

```
01.txt
02.txt
secrets.txt
```

Without `.gitignore`:

* All files committed
* Secrets leaked

With `.gitignore`:

```
secrets.txt
```

Secrets never reach Git.

---

## 15. Terraform Default `.gitignore` (Best Practice)

GitHub provides ready-made Terraform `.gitignore`.

It ignores:

* `.terraform/`
* `terraform.tfstate`
* `*.backup`
* logs
* plan files

You can customize it per organization needs.

---

## 16. Files You SHOULD Commit

### ✅ Always Commit

| File                  | Why                      |
| --------------------- | ------------------------ |
| `*.tf`                | Terraform code           |
| `.terraform.lock.hcl` | Provider version locking |
| `.gitignore`          | Safety                   |
| `README.md`           | Documentation            |

---

## 17. Final Summary

* ❌ Never commit Terraform state
* ❌ Never commit `.terraform/`
* ✅ Always use `.gitignore`
* ✅ Always commit Terraform code
* Security mistakes in Git are **permanent**













# Terraform Backends – Where State Is Stored

## 1. What Is a Terraform Backend?

A **Terraform backend** determines:

> **Where and how Terraform stores its state file**

The state file (`terraform.tfstate`) is critical because it tracks:

* What resources exist
* Their IDs
* Their current configuration

---

## 2. Default Backend: Local Backend

### Important Rule

If **no backend is explicitly configured**, Terraform uses the **local backend by default**.

### What Does That Mean?

* State file is stored locally
* In the same directory as Terraform code

### Example Folder

```
jumptotech-terraform/
  sg.tf
  terraform.tfstate   ← created automatically
```

---

## 3. Simple Practical Example (Local Backend)

### Terraform File: `sg.tf`

```hcl
resource "aws_security_group" "prod" {
  name = "production-sg"
}
```

### Run Commands

```bash
terraform apply -auto-approve
```

### Result

* Security group created in AWS
* `terraform.tfstate` created in same folder

---

## 4. Why Local Backend Is a Problem in Teams

### Problem 1: No Team Collaboration

State file exists:

* Only on one developer’s laptop

Other team members:

* Cannot see current infrastructure state
* Cannot safely modify infrastructure

---

### Problem 2: Risk of State Loss

If:

* Laptop crashes
* Disk fails
* Files are deleted

➡ State file is lost
➡ Terraform can no longer manage resources properly

---

## 5. Production Architecture (Recommended)

### Correct Setup

* **Terraform code** → Central Git repository
* **Terraform state** → Central backend (remote)

### Visual Flow (Conceptual)

```
Developers
   |
Git Repository (Terraform code)
   |
Remote Backend (terraform.tfstate)
```

This allows:

* Collaboration
* Safety
* Consistency

---

## 6. Remote Backends in Terraform

Terraform supports **many backend types**.

### Common Backends

| Backend    | Used When           |
| ---------- | ------------------- |
| S3         | AWS environments    |
| AzureRM    | Azure environments  |
| GCS        | Google Cloud        |
| Consul     | HashiCorp ecosystem |
| Kubernetes | Cluster-based state |

---

## 7. Backend Configuration Depends on Type

Each backend has:

* Different configuration syntax
* Different authentication method
* Different features

### Example: S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Example: Kubernetes Backend

```hcl
terraform {
  backend "kubernetes" {
    namespace = "terraform"
  }
}
```

---

## 8. Why State Should NOT Be in Git

### Key Reason

Terraform state can contain:

* Passwords
* Tokens
* Secrets

Git repository:

* Has many users
* May be exposed
* May be compromised

➡ **State must be stored securely and encrypted**

---

## 9. Explicit Local Backend Configuration

Even though local backend is default, you can **explicitly configure it**.

### Why Would You Do This?

* Change state file name
* Store state in a different directory

---

## 10. Best Practice: Use `backend.tf`

Instead of placing backend config in resource files:

✅ Good practice:

```
backend.tf
sg.tf
```

---

## 11. Explicit Local Backend Example

### `backend.tf`

```hcl
terraform {
  backend "local" {
    path = "prod.tfstate"
  }
}
```

### Important Notes

* `terraform init` is REQUIRED after backend change
* Old state file should be removed manually

---

## 12. Workflow with Explicit Backend

```bash
terraform init
terraform apply -auto-approve
```

### Result

```
prod.tfstate
```

Instead of:

```
terraform.tfstate
```

---

## 13. Authentication with Remote Backends

Remote backends require **authentication**.

### Example: S3 Backend

Terraform must:

* Authenticate to AWS
* Have permission to:

  * Read state
  * Write state

Terraform uses:

* AWS credentials
* IAM roles
* Environment variables

---

## 14. Backend Features: State Locking

Some backends:

* Support **state locking**
* Prevent simultaneous updates

Others:

* Act as simple storage only

👉 Always check backend documentation.

---

# Terraform State Locking

## 15. Why State Locking Is Needed

### Problem

Multiple users running:

```bash
terraform apply
```

At the same time → **State corruption**

---

## 16. Simple Scenario

* Alice runs `terraform apply`
* Bob runs `terraform apply` at the same time

Both try to:

* Modify `terraform.tfstate`

➡ Inconsistencies
➡ Corrupted state

---

## 17. Real-Life Analogy

Like a phone call:

* You can talk to only **one person at a time**
* Multiple conversations cause confusion

Terraform state works the same way.

---

## 18. What Is State Locking?

**State locking** ensures:

> Only ONE Terraform operation can modify the state at a time

Other operations:

* Are blocked
* Must wait

---

## 19. State Locking Workflow

1. Terraform tries to acquire lock
2. If lock acquired:

   * Performs write operation
3. After completion:

   * Releases lock
4. Other users can proceed

---

## 20. State Locking Depends on Backend

### Examples

| Backend | Locking                |
| ------- | ---------------------- |
| Local   | `.lock.info` file      |
| S3      | DynamoDB-based locking |
| Consul  | Native locking         |
| GCS     | Native locking         |

---

## 21. Local Backend Locking Mechanism

Terraform creates:

```
terraform.tfstate.lock.info
```

This file:

* Indicates lock ownership
* Shows which user acquired lock
* Removed automatically after operation

---

## 22. Practical Demo: State Locking

### Resource: `sleep.tf`

```hcl
resource "time_sleep" "wait" {
  create_duration = "100s"
}
```

---

### Run Apply

```bash
terraform apply -auto-approve
```

During execution:

* `terraform.tfstate.lock.info` appears

---

### Second Terminal Attempt

```bash
terraform plan
```

### Error

```
Error acquiring the state lock
The process cannot access the file
because another process has locked it
```

---

## 23. Lock Release

After apply completes:

* Lock file is removed
* Other operations succeed

---

## 24. Important Clarification

### `terraform.lock.hcl` ≠ State Lock

| File                          | Purpose               |
| ----------------------------- | --------------------- |
| `terraform.lock.hcl`          | Provider version lock |
| `terraform.tfstate.lock.info` | State lock            |

---

## 25. Production Recommendation

When choosing a backend:

* MUST support state locking
* MUST support encryption
* MUST be centralized

Examples:

* S3 + DynamoDB
* Consul

---

## 26. Final Summary

### Backends

* Control where state is stored
* Default backend is local
* Production uses remote backends

### State Locking

* Prevents concurrent state updates
* Avoids corruption
* Mandatory for teams













# Terraform S3 Backend

## 1. What Is an S3 Backend?

An **S3 backend** allows Terraform to store its **state file (`.tfstate`) in an Amazon S3 bucket** instead of locally.

### Key Idea

* State is **not stored on a laptop**
* State is stored **centrally in AWS S3**
* Enables **team collaboration**, **security**, and **reliability**

---

## 2. Why Use S3 Backend?

### Problems with Local Backend

* State exists only on one machine
* Other team members cannot safely work
* Risk of state loss
* No locking by default

### Benefits of S3 Backend

* Centralized state
* Secure storage
* Supports state locking
* Works well with teams
* Production-ready

---

## 3. How Terraform Backends Work (Quick Recap)

All backends follow the same structure:

```hcl
terraform {
  backend "<backend_name>" {
    # backend specific config
  }
}
```

Only two things change:

1. Backend name (`local`, `s3`, `azurerm`, `gcs`, etc.)
2. Backend-specific configuration

---

## 4. S3 Backend Configuration Structure

```hcl
terraform {
  backend "s3" {
    bucket        = "example-bucket"
    key           = "production.tfstate"
    region        = "us-east-1"
    use_lockfile  = true
  }
}
```

### What Each Field Means

| Field          | Meaning                                |
| -------------- | -------------------------------------- |
| `bucket`       | S3 bucket name where state is stored   |
| `key`          | Path + filename of state inside bucket |
| `region`       | AWS region of the bucket               |
| `use_lockfile` | Enables state locking                  |

---

## 5. Creating the S3 Bucket

### Important Rule

**S3 bucket names must be globally unique**

Example:

```text
jumptotech-demo-bucket-007
```

You can create the bucket:

* Via AWS Console
* Or via AWS CLI

Once created:

* Note bucket name
* Note region

---

## 6. Best Practice: `backend.tf`

From production perspective:

* Backend configuration should be **isolated**

### Folder Structure

```
jumptotech-terraform/
  backend.tf
  sg.tf
```

This helps when:

* Project has many `.tf` files
* New engineers join the team

---

## 7. Example: `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket       = "jumptotech-demo-bucket-007"
    key          = "production.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

---

## 8. Example Resource File: `sg.tf`

```hcl
resource "aws_security_group" "prod" {
  name = "production-sg"
}
```

---

## 9. Initializing the S3 Backend

### Mandatory Step

Whenever backend configuration is added or changed:

```bash
terraform init
```

Terraform will:

* Validate backend config
* Connect to S3
* Prepare state storage

---

## 10. Applying the Configuration

```bash
terraform apply -auto-approve
```

### What Happens

* Resource is created
* State file is stored in S3
* No `.tfstate` exists locally

---

## 11. Verifying State Location

### Local Folder

```
No terraform.tfstate file
```

### S3 Bucket

```
production.tfstate
```

This confirms:

* Backend is working correctly
* State is remote

---

## 12. Authentication Requirement

Terraform must authenticate to AWS to access S3.

### Terraform Uses

* AWS credentials
* IAM role
* Environment variables

### Required Permissions

* Read state
* Write state
* Lock state (if enabled)

---

## 13. Backend Locking Support

S3 backend:

* **Supports state locking**
* Prevents concurrent updates

This is **mandatory in production environments**.

---

# Terraform State Management (Advanced)

## 14. Important Rule About State File

> **Never modify the Terraform state file manually**

Reasons:

* Easy to corrupt
* Hard to recover
* One mistake can break infrastructure

---

## 15. How to Safely Manage State

Terraform provides **state subcommands**:

```bash
terraform state <subcommand>
```

These allow:

* Safe inspection
* Safe modification
* No manual editing

---

## 16. `terraform state list`

### Purpose

Lists all resources currently tracked in state.

### Command

```bash
terraform state list
```

### Output Example

```
aws_iam_user.dev
aws_security_group.prod
```

### Use Case

* Large projects
* Quickly see what Terraform manages

---

## 17. `terraform state show`

### Purpose

Displays attributes of a single resource.

### Command

```bash
terraform state show aws_security_group.prod
```

### Why Useful

* View IDs, ARNs, VPC IDs
* Avoid opening state file
* Faster than AWS Console

---

## 18. `terraform state pull`

### Purpose

Fetches the current state from remote backend.

### Command

```bash
terraform state pull
```

### Use Case

* Inspect remote state
* Debug issues
* Avoid downloading from S3 manually

---

## 19. `terraform state rm`

### Purpose

Removes a resource from Terraform state **without destroying it**

### Common Use Case

* Resource modified manually many times
* Hard to reconcile with Terraform
* Want Terraform to stop managing it

### Command

```bash
terraform state rm aws_security_group.prod
```

### Result

* Resource stays in AWS
* Terraform forgets it exists

---

## 20. Safe Removal Workflow

1. Remove resource from state
2. Remove resource block from `.tf` file
3. Run `terraform plan`
4. No destruction occurs

---

## 21. `terraform state mv`

### Purpose

Move resource from one address to another.

### Problem Without `mv`

Changing name:

```hcl
aws_iam_user.dev → aws_iam_user.prod
```

Terraform tries:

* Destroy old
* Create new

### Solution

```bash
terraform state mv aws_iam_user.dev aws_iam_user.prod
```

Now:

* Resource preserved
* No recreation

---

## 22. `terraform state replace-provider`

### Purpose

Change provider reference inside state.

### Use Case

* Switching to custom provider
* Provider namespace changes

### Command

```bash
terraform state replace-provider \
  registry.terraform.io/hashicorp/aws \
  kplabs.in/internal/aws
```

⚠ **Dangerous Command**

* Always take backup
* Wrong usage can break project

---

## 23. Recovery After Replace Provider

If broken:

```bash
terraform state replace-provider \
  kplabs.in/internal/aws \
  registry.terraform.io/hashicorp/aws
```

---

## 24. Final Best Practices Summary

### S3 Backend

* Mandatory for production
* Centralized
* Secure
* Supports locking

### State Management

* Never edit state manually
* Always use `terraform state` commands
* Backup before advanced operations










1. **Remote State Data Source (Concept + Practical)**
2. **Terraform Import (Concept + New Auto-Generate Feature + Practical)**

Language is simple, production-focused, and suitable for teaching.

---

# Terraform Remote State Data Source

## 1. Why Remote State Data Source Is Important

In **medium to large organizations**:

* One team does **not** manage everything
* Multiple teams manage **different parts** of infrastructure
* All teams often use **Terraform**

### Example Teams

* **Networking team**
  Creates public IPs, VPCs, subnets
* **Security team**
  Manages firewalls and security groups

Each team:

* Has its **own Terraform project**
* Has its **own Terraform state**

---

## 2. Real-World Challenge

### Scenario

* Networking team creates **Elastic IPs** using Terraform
* Their state file is stored in **S3**
* They expose IPs via **Terraform outputs**

Security team needs:

* Those IPs
* To whitelist them in firewall rules

### Bad Approaches

* Copy-paste IPs manually
* Hardcode values in security code

❌ Manual
❌ Error-prone
❌ Not scalable

---

## 3. Solution: Remote State Data Source

Terraform provides:

> **terraform_remote_state data source**

This allows:

* One Terraform project
* To **read outputs** from another project’s state
* Stored in a **remote backend**

---

## 4. What Remote State Data Source Does

It allows Terraform code to:

1. Connect to a **remote backend**
2. Read the **state file**
3. Fetch **output values**
4. Use those values in configuration

---

## 5. High-Level Architecture

```
Networking Team
  └─ Terraform
     └─ S3 backend (eip.tfstate)
        └─ Outputs: public IPs

Security Team
  └─ Terraform
     └─ Reads networking state
     └─ Uses IPs in firewall rules
```

---

## 6. Practical Setup Overview

We create **two Terraform projects**:

### Project 1: networking-team

* Creates Elastic IP
* Stores state in S3
* Exposes IP via output

### Project 2: security-team

* Reads networking state from S3
* Fetches IP
* Whitelists it in security group

---

## 7. Networking Team – Code

### `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "kplabs-networking-bucket-demo"
    key    = "eip.tfstate"
    region = "us-east-1"
  }
}
```

### `eip.tf`

```hcl
resource "aws_eip" "public_ip" {
  domain = "vpc"
}

output "eip_addr" {
  value = aws_eip.public_ip.public_ip
}
```

### Apply

```bash
terraform init
terraform apply -auto-approve
```

### Result

* EIP created
* State stored in S3
* Output contains IP address

---

## 8. Security Team – Remote State Configuration

### `data.tf`

```hcl
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "kplabs-networking-bucket-demo"
    key    = "eip.tfstate"
    region = "us-east-1"
  }
}
```

This tells Terraform:

* Where the remote state lives
* Which backend to use

---

## 9. Using Remote State Output

### `sg.tf`

```hcl
resource "aws_security_group" "secure_sg" {
  name = "secure-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${data.terraform_remote_state.networking.outputs.eip_addr}/32"
    ]
  }
}
```

---

## 10. Validate the Workflow

```bash
terraform init
terraform plan
```

You will see:

* CIDR block automatically populated
* IP matches networking team output

---

## 11. Proof of Automation

1. Destroy EIP in networking team
2. Re-create EIP
3. New IP generated
4. Run `terraform plan` in security team

✅ New IP automatically fetched
✅ Firewall updated correctly

---

## 12. Key Takeaways (Remote State)

* Enables **cross-team dependency**
* Eliminates copy-paste
* Reads **outputs only**
* Works across backends (S3, GCS, etc.)
* Extremely common in real production setups

---

# Terraform Import (Modern & Practical)

---

## 13. Why Terraform Import Is Needed

Most organizations:

* Have **years of manually created resources**
* Want to adopt Terraform
* Do NOT want to recreate everything

### Question

> Can we bring existing resources under Terraform control?

Answer:

> **Yes – using Terraform Import**

---

## 14. Old Terraform Import (Before v1.5)

Earlier behavior:

* Imported **only state**
* Users had to **write Terraform code manually**

Problems:

* Thousands of resources
* Huge manual effort
* High error risk

---

## 15. New Terraform Import (v1.5+)

Terraform now supports:

* Importing **state**
* **Automatically generating Terraform code**

This is a **major improvement**

---

## 16. New Import Workflow

1. Resource exists manually
2. Define `import` block
3. Run `terraform plan -generate-config-out`
4. Terraform generates `.tf` file
5. Run `terraform apply`
6. Resource is now managed by Terraform

---

## 17. Practical Example – Manual Security Group

### Manually Created in AWS

* 3 inbound rules (80, 443, 22)
* Custom CIDR blocks
* Descriptions added manually

Goal:

* Manage this SG via Terraform

---

## 18. Import Configuration

### `import.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

import {
  to = aws_security_group.mysg
  id = "sg-0abc1234def56789"
}
```

* `id` → existing AWS resource ID
* `to` → Terraform resource address

---

## 19. Generate Terraform Code

```bash
terraform plan -generate-config-out=mysg.tf
```

Result:

* `mysg.tf` created automatically
* Contains full security group configuration

---

## 20. Apply Import

```bash
terraform apply -auto-approve
```

Terraform:

* Imports resource
* Creates state file
* No changes made to AWS

---

## 21. Verify Management

Modify generated code:

```hcl
description = "Managed via Terraform"
```

Apply again:

```bash
terraform apply -auto-approve
```

AWS Console shows:

* Updated description
* Terraform now controls resource

---

## 22. Important Notes

### Terraform Version

* Auto code generation works **only from v1.5+**

Check version:

```bash
terraform version
```

---

## 23. Best Practices for Import

* Always test in non-production first
* Review generated code
* Clean up formatting
* Add variables if needed
* Commit generated code to Git

---

## 24. Final Summary

### Remote State

* Enables team-to-team dependencies
* Reads outputs from remote backends
* Core production feature

### Import

* Brings existing infrastructure into Terraform
* New versions generate code automatically
* Massive time saver


