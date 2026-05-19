---
title: "terraform certificate #6"
description: "Terraform Multiple Provider Configuration (Alias)            1. Problem Statement (Why we..."
published: 2025-12-18
source: "https://dev.to/jumptotech/terraform-certificate-6-1hh2"
tags: []
---

# terraform certificate #6


# Terraform Multiple Provider Configuration (Alias)

## 1. Problem Statement (Why we need this)

By default:

* Terraform uses **one provider**
* All resources are created in **one region**

### ❌ Default behavior

```hcl
provider "aws" {
  region = "ap-southeast-1"
}
```

➡️ **ALL resources** go to `us-east-2`

---

### Real-world requirement

In production, this happens often:

| Resource       | Region              |
| -------------- | ------------------- |
| Security Group | Tokio (to-west-1) |
| EC2 Instance   | USA (us-east-1)     |

But Terraform **does not allow multiple providers of same type** unless we use **alias**.

---

## 2. What is Provider Alias?

**Alias** allows you to:

* Define **multiple configurations** of the same provider
* Each with **different region / account**
* Reference them **explicitly** in resources

---

## 3. Rule You Must Remember

❌ This is **NOT allowed**

```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  region = "us-east-1"
}
```

Terraform error:

```
Duplicate provider configuration
```

---

## 4. Correct Way: Using Alias

### Step 1: Define Multiple Providers with Alias

```hcl
provider "aws" {
  region = "ap-southeast-1"   # default provider
}

provider "aws" {
  alias  = "Tokio"
  region = "to-west-1"
}

provider "aws" {
  alias  = "usa"
  region = "us-east-1"
}
```

### Meaning

| Provider Reference | Region    |
| ------------------ | --------- |
| aws (default)      | Singapore |
| aws.tokio          | Tokio     |
| aws.usa            | USA       |

---

## 5. Important Rule (Very Common Exam Question)

> If you **do NOT specify provider inside a resource**, Terraform uses **default provider**

---

## 6. Simplest Practical Example (Security Groups)

### Goal

| Resource         | Region |
| ---------------- | ------ |
| prod_firewall    | USA    |
| staging_firewall | Tokio  |

---

### Full Working Code

```hcl
provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "usa"
  region = "us-east-1"
}

resource "aws_security_group" "prod_firewall" {
  provider = aws.usa

  name        = "prod_firewall"
  description = "Production firewall"
}

resource "aws_security_group" "staging_firewall" {
  provider = aws.mumbai

  name        = "staging_firewall"
  description = "Staging firewall"
}
```

---

## 7. Key Line to Understand (Most Important)

```hcl
provider = aws.usa
```

### Meaning:

* `aws` → provider type
* `usa` → alias name

➡️ Create this resource using **AWS provider configured for us-east-2**

---

## 8. Execution Commands 

```bash
terraform init
terraform validate
terraform apply -auto-approve
```

---

## 9. Verification in AWS Console

| Region     | Expected Resource |
| ---------- | ----------------- |
| us-east-1  | prod_firewall     |
| to -west-1 | staging_firewall  |

---

## 10. Common Mistakes (Interview + Exams)

### ❌ Same resource name

```hcl
resource "aws_security_group" "sg" {}
resource "aws_security_group" "sg" {}
```

Terraform error:

```
Duplicate resource configuration
```

✔️ Solution: unique local names

---

### ❌ Alias defined but not used

```hcl
provider "aws" {
  alias = "mumbai"
}
```

But resource has no `provider = aws.mumbai`

➡️ Resource still goes to **default region**

---

## 11. When Alias is Used in Real Production

* Multi-region deployments
* DR (Disaster Recovery)
* Cross-account resources
* Centralized networking/security teams
* Shared Terraform codebase

---

## 12. Exam-Ready Summary (Memorize)

* Terraform allows **only one default provider**
* Multiple providers of same type require **alias**
* Alias is referenced as:

```hcl
provider = aws.<alias_name>
```

* Without provider reference → default provider is used











# Terraform Sensitive Parameters (Security Topic)

## 1. Why This Topic Is Important

By default, Terraform **prints values in plain text** during:

* `terraform plan`
* `terraform apply`
* logs
* outputs

This can **leak secrets** such as:

* passwords
* API keys
* tokens
* database credentials

👉 In production, this is **unacceptable**.

---

## 2. Problem Demonstration (Default Behavior)

### Example: Local File with Password

```hcl
resource "local_file" "password_file" {
  filename = "password.txt"
  content  = "supersecretpassw0rd"
}
```

### Terraform Plan Output (❌ Bad)

```text
content = "supersecretpassw0rd"
```

✔ Password is visible
❌ Security risk

---

## 3. Common Mistake (Using Variable Only)

Many beginners think variables hide secrets.

```hcl
variable "password" {
  default = "supersecretpassw0rd"
}

resource "local_file" "password_file" {
  filename = "password.txt"
  content  = var.password
}
```

### Result (❌ Still visible)

```text
content = "supersecretpassw0rd"
```

👉 Terraform **evaluates variables** before showing output.

---

## 4. Correct Solution: `sensitive = true`

### Step 1: Mark Variable as Sensitive

```hcl
variable "password" {
  default   = "supersecretpassw0rd"
  sensitive = true
}
```

### Step 2: Use Variable in Resource

```hcl
resource "local_file" "password_file" {
  filename = "password.txt"
  content  = var.password
}
```

### Terraform Plan Output (✔ Secure)

```text
content = (sensitive value)
```

✔ Secret hidden in CLI
✔ Still written to file

---

## 5. Important Rule (EXAM QUESTION)

> **Sensitive values are hidden only from CLI & logs**
> ❌ They are **NOT hidden from the state file**

---

## 6. Alternative: `local_sensitive_file` Resource

Terraform provides **special resource types** for sensitive data.

### Example

```hcl
resource "local_sensitive_file" "password_file" {
  filename = "password.txt"
  content  = "supersecretpassw0rd"
}
```

### Result

* No need for `sensitive = true`
* Terraform **automatically hides content**

```text
content = (sensitive value)
```

### When to Use

> If documentation says:
> **“Use **sensitive** resource when content is sensitive”**

---

## 7. Sensitive Values and Outputs (Very Important)

### ❌ This Will FAIL

```hcl
output "password" {
  value = var.password
}
```

Terraform error:

```text
Sensitive value cannot be displayed in output
```

---

## 8. Correct Way to Use Sensitive Outputs

```hcl
output "password" {
  value     = var.password
  sensitive = true
}
```

### Result

* Terraform does **not fail**
* CLI shows:

```text
password = (sensitive value)
```

---

## 9. Why Sensitive Outputs Exist (Real Production Use)

Sensitive outputs are used because:

* Other Terraform projects read outputs
* `terraform_remote_state` needs values
* CI/CD pipelines consume outputs
* Teams share state, not CLI

📌 **CLI hides it, state keeps it**

---

## 10. Sensitive Data in State File (Critical Concept)

Even with `sensitive = true`:

```text
terraform.tfstate
```

❌ Still contains real values:

```json
"password": "supersecretpassw0rd"
```

### Conclusion

> Sensitive flag **does NOT encrypt state**

State protection is a **separate topic**:

* S3 backend
* encryption
* IAM
* restricted access

---

## 11. Provider-Level Automatic Sensitivity (AWS Example)

Terraform providers may **auto-detect secrets**.

### Example: AWS RDS

```hcl
resource "aws_db_instance" "db" {
  allocated_storage = 20
  engine            = "mysql"
  username          = "admin"
  password          = "mypassword123"
}
```

### Terraform Plan Output

```text
username = "admin"
password = (sensitive value)
```

✔ Password hidden automatically
✔ Username visible

---

## 12. Making Username Sensitive Too

```hcl
variable "db_user" {
  default   = "admin"
  sensitive = true
}

resource "aws_db_instance" "db" {
  username = var.db_user
  password = "mypassword123"
}
```

### Result

```text
username = (sensitive value)
password = (sensitive value)
```

---

## 13. Exam & Interview Summary (Memorize)

* `sensitive = true` hides values from:

  * CLI
  * logs
  * outputs
* ❌ Does NOT hide from `terraform.tfstate`
* Some providers auto-mark secrets
* Outputs with sensitive values **must also be marked sensitive**
* `_sensitive_` resources exist for some providers

---

## 14. Real Production Best Practice

✔ Use:

* sensitive variables
* sensitive outputs
* provider auto-detection
* secure backend (S3 + encryption + IAM)

❌ Never:

* hardcode secrets
* commit tfstate
* rely on variables alone












# Part 1: HashiCorp Vault – High-Level Overview

## 1. What Is HashiCorp Vault?

**HashiCorp Vault** is a secrets management system used to:

* Securely store secrets
* Control access to secrets
* Generate secrets dynamically
* Rotate and revoke secrets automatically

### Examples of Secrets

* Database usernames & passwords
* AWS access & secret keys
* API tokens
* Certificates
* Encryption keys

---

## 2. The Core Problem Vault Solves

### ❌ Common (Bad) Practice

* Secrets stored in:

  * Notepad
  * Slack
  * Email
  * Plain text files
  * Hardcoded in code

This leads to:

* Credential leaks
* Data breaches
* No rotation
* No audit trail

---

## 3. Vault’s Biggest Feature: Dynamic Secrets

### What Are Dynamic Secrets?

Secrets that are:

* Generated **on demand**
* Have a **limited lifetime**
* Automatically **revoked or rotated**

---

### Example 1: Database Credentials

* Developer requests DB access
* Vault generates:

  * Username
  * Password
* Credential validity: **24 hours / 1 hour**
* After expiry:

  * Credential is deleted
  * Developer must request again

✅ Reduced blast radius
✅ No long-lived credentials
✅ High security

---

### Example 2: AWS IAM Credentials

* Developer clicks **Generate**
* Vault provides:

  * Access Key
  * Secret Key
* Keys auto-expire
* Vault deletes them automatically

---

### Example 3: Linux SSH Access

* Developer requests access
* Vault generates:

  * Username
  * SSH key
* Used for login
* Revoked automatically after lease

---

## 4. Vault GUI (Why It Matters)

Initially:

* Vault was **CLI-only**
* Hard for beginners

Now:

* Vault provides a **full GUI**
* Easy to:

  * Generate secrets
  * View leases
  * Encrypt/decrypt data
  * Manage engines

This improves:

* Learning
* Usability
* Operations

---

## 5. Vault Encryption as a Service

Vault can:

* Encrypt data
* Decrypt data
* Hash data
* Generate random values

### Use Case

Instead of writing encryption logic in your application:

* App sends data to Vault
* Vault encrypts/decrypts it
* App stays simple

---

## 6. Organizational Benefit of Vault

Imagine:

* 200–300 developers
* Each needs DB access

❌ Without Vault:

* DB admin manually creates credentials
* Time-consuming
* Error-prone

✅ With Vault:

* Developers self-serve
* Automatic rotation
* Centralized access control

---

# Part 2: Terraform Vault Provider – High-Level Overview

## 7. What Is the Vault Provider in Terraform?

The **Vault provider** allows Terraform to:

* Read secrets from Vault
* Write secrets to Vault
* Configure Vault resources
* Inject secrets into infrastructure

---

## 8. Typical Use Case

### Scenario

* Vault stores database credentials:

  ```
  secret/db_creds
  ├── username = admin
  └── password = password123
  ```

* Terraform needs these credentials to:

  * Create a database
  * Configure RDS
  * Pass secrets to applications

---

## 9. Vault Provider Configuration (Basic)

```hcl
provider "vault" {
  address = "http://127.0.0.1:8200"
}
```

This tells Terraform:

* Where Vault is running
* How to connect to it

---

## 10. Reading Secrets from Vault in Terraform

### Vault Secret Path

```
secret/db_creds
```

### Terraform Code

```hcl
data "vault_generic_secret" "db" {
  path = "secret/db_creds"
}
```

---

## 11. Accessing Vault Data in Terraform

```hcl
output "vault_secret" {
  value     = data.vault_generic_secret.db.data_json
  sensitive = true
}
```

### Result

* Terraform reads:

  * username
  * password
* Output hidden from CLI
* Data stored in state

---

## 12. Important Behavior (Very Important for Exam)

> Any secret read from Vault using Terraform is stored in:
> **terraform.tfstate**

### Sensitive flag:

* ❌ Does NOT encrypt state
* ✔️ Only hides CLI output

---

## 13. Terraform State File Risk

Example:

```json
"outputs": {
  "vault_secret": {
    "value": {
      "username": "admin",
      "password": "password123"
    }
  }
}
```

👉 This is why:

* Terraform state **must be secured**
* Use:

  * S3 backend
  * Encryption
  * Restricted IAM access

---

## 14. Vault AWS Secrets Engine + Terraform

Vault can generate:

* Temporary AWS IAM credentials

Terraform can:

* Fetch those credentials
* Use them to manage AWS

### Result

* No AWS keys in:

  * Terraform code
  * Environment variables
  * Files

Terraform dynamically authenticates via Vault.

---

## 15. Real-World Terraform + Vault Flow

1. Terraform connects to Vault
2. Vault generates AWS credentials
3. Terraform uses credentials
4. Credentials expire automatically
5. No hardcoded secrets anywhere

---

## 16. Exam-Ready Summary (Memorize This)

### HashiCorp Vault

* Centralized secrets management
* Dynamic secrets
* Automatic rotation & revocation
* Encryption as a service
* GUI + CLI

### Vault Provider in Terraform

* Read/write secrets from Vault
* Secrets stored in Terraform state
* Sensitive flag hides CLI only
* State security is critical

---

## 17. Important Exam Warning

> Using Vault with Terraform **does NOT eliminate secrets from state files**.

You must:

* Secure backend
* Encrypt state
* Restrict access
















# Terraform Dependency Lock File (`.terraform.lock.hcl`)

## 1. What Is the Dependency Lock File?

When you run:

```bash
terraform init
```

Terraform automatically creates a file called:

```text
.terraform.lock.hcl
```

This file is called the **dependency lock file**.

---

## 2. Why This File Exists (Core Problem)

### Key Reality

* Terraform **core** and **provider plugins** are released **independently**
* Providers have their **own release cycles**
* New provider versions can be released **without Terraform changing**

---

### Example Scenario

| Component    | Version                       |
| ------------ | ----------------------------- |
| Terraform    | 1.2                           |
| AWS Provider | v1 → v2 → v3 (released later) |

Your code:

* Was written
* Tested
* Validated
  with **AWS provider v1**

Weeks later:

* Someone clones the repo
* Runs `terraform init`
* Terraform downloads **latest provider (v3)**

❌ Code may break
❌ Unexpected behavior
❌ Production risk

---

## 3. First Line of Defense: Version Constraints

Inside Terraform code, you define **version constraints**.

### Example

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

### Meaning of `~> 4.0`

* Allows: `4.0`, `4.1`, `4.2`, `4.6`
* Disallows: `5.x`

But this **alone is not enough**.

---

## 4. What Happens During First `terraform init`

1. Terraform reads version constraints
2. Terraform selects **one exact provider version**
3. Provider is downloaded
4. Terraform **locks that version** into:

```text
.terraform.lock.hcl
```

---

## 5. What Is Stored in `.terraform.lock.hcl`

Example:

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version     = "4.62.0"
  constraints = "~> 4.0"
  hashes = [
    "h1:abcd...",
    "zh:1234..."
  ]
}
```

### Important Details

* Exact provider version used
* Original version constraints
* Cryptographic hashes (checksums)
* Platform-specific signatures

---

## 6. Why the Lock File Is Critical (Main Benefit)

### Without Lock File

* Every `terraform init` may download a **newer provider**
* Code behavior may change
* Builds become non-reproducible

---

### With Lock File

* Terraform always installs **exact same provider version**
* Even if newer versions exist
* Ensures:

  * Consistency
  * Stability
  * Predictability

---

## 7. Real-World Team Scenario

1. Developer A:

   * Runs `terraform init`
   * AWS provider `4.62.0` installed
   * Lock file committed to GitHub

2. Developer B (months later):

   * Runs `terraform init`
   * AWS provider `4.70.0` exists
   * Terraform still installs **4.62.0**

✔ Same behavior
✔ Same results
✔ No surprises

---

## 8. What If Code Version Changes but Lock File Doesn’t?

### Scenario

* `.terraform.lock.hcl` has:

  ```text
  version = 4.62.0
  ```
* Code updated to:

  ```hcl
  version = "= 4.60.0"
  ```

Now versions **do not match**.

---

### What Happens?

```bash
terraform init
```

❌ Terraform fails with error
Because:

* Lock file version ≠ required version

---

## 9. Correct Way to Upgrade or Downgrade Provider

You must explicitly tell Terraform to update providers.

### Command

```bash
terraform init -upgrade
```

### What This Does

* Re-evaluates version constraints
* Downloads matching provider version
* Updates `.terraform.lock.hcl`

---

## 10. Very Important Security Aspect (Checksums)

The lock file also contains **hashes**:

* Validates provider integrity
* Prevents tampered or malicious binaries
* If checksum mismatch occurs:

  * `terraform init` fails

✔ Supply-chain security
✔ Verified binaries only

---

## 11. Important Limitation (Exam Question)

> `.terraform.lock.hcl` **ONLY tracks provider dependencies**

It **does NOT** lock:

* Remote module versions

Modules still follow:

* Version constraints
* Latest compatible version is chosen

---

## 12. Best Practices (Production)

✔ Always commit `.terraform.lock.hcl`
✔ Never delete it casually
✔ Use `terraform init -upgrade` intentionally
✔ Review provider changelogs before upgrade

❌ Do not rely only on version constraints
❌ Do not ignore lock file errors

---

## 13. Exam-Ready Summary (Memorize)

* Terraform core and providers have **independent release cycles**
* Version constraints define **allowed range**
* `.terraform.lock.hcl` locks **exact provider version**
* Ensures reproducible builds
* Prevents accidental provider upgrades
* Stores cryptographic hashes
* Tracks **providers only**, not modules
* Use `terraform init -upgrade` to change versions


