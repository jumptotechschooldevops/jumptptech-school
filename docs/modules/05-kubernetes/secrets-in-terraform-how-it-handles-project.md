---
title: "secrets in Terraform. How it handles. project."
description: "🔐 PROJECT 1 — AWS Secrets Manager            “Secure RDS Password in Production”           ..."
published: 2025-12-25
source: "https://dev.to/jumptotech/secrets-in-terraform-how-it-handles-project-4d96"
tags: []
---

# secrets in Terraform. How it handles. project.


# 🔐 PROJECT 1 — AWS Secrets Manager

## “Secure RDS Password in Production”

---

## 1️⃣ Company Type

**Mid–large company**

* SaaS company
* FinTech
* E-commerce platform
* Healthcare app

Example:
A company running **customer data** with compliance requirements (SOC2, HIPAA, PCI).

---

## 2️⃣ Real Company Situation

* Application uses **RDS (MySQL/Postgres)**
* Multiple engineers deploy infrastructure
* Password must:

  * NOT be in Git
  * NOT be visible to developers
  * Be rotatable later

---

## 3️⃣ Goal of This Project

👉 **Create an RDS database without hard-coding the password**

Terraform should:

* Read the password securely
* Never store it in code
* Only IAM-authorized services can access it

---

## 4️⃣ Step-by-Step (What to Do)

### Step 1 — Store Secret in AWS (One-time)

```bash
aws secretsmanager create-secret \
  --name prod/rds/db_password \
  --secret-string '{"password":"StrongProdPass123!"}'
```

✅ Done **outside Terraform**
(Important production rule)

---

### Step 2 — Configure Terraform Backend (Security)

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "rds/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Purpose:

* Encrypt state
* Prevent state corruption
* Team-safe deployments

---

### Step 3 — Read Secret in Terraform

```hcl
data "aws_secretsmanager_secret" "db" {
  name = "prod/rds/db_password"
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}
```

Terraform **does not create the secret**
Terraform **only reads it**

---

### Step 4 — Use Secret in RDS

```hcl
resource "aws_db_instance" "prod" {
  engine         = "mysql"
  instance_class = "db.t3.micro"
  username       = "admin"
  password = jsondecode(
    data.aws_secretsmanager_secret_version.db.secret_string
  )["password"]
}
```

---

## 5️⃣ Why Companies Do This

* Password rotation possible
* Auditing access via IAM
* Meets security compliance
* Zero secret exposure in Git

---

## 6️⃣ Interview Explanation

> “In production, database passwords are stored in AWS Secrets Manager. Terraform reads them at runtime using IAM permissions. This avoids hard-coding secrets and supports rotation and compliance.”

---

# 🔐 PROJECT 2 — AWS SSM Parameter Store

## “Secure API Key for EC2 Application”

---

## 1️⃣ Company Type

**Small–mid company**

* Startup
* Internal tools team
* Backend API team

---

## 2️⃣ Real Company Situation

* EC2 runs backend app
* App needs:

  * API key
  * Token
* User-data scripts must stay clean

---

## 3️⃣ Goal

👉 Securely pass secrets to EC2 **without exposing them**

---

## 4️⃣ Step-by-Step

### Step 1 — Store Secret

```bash
aws ssm put-parameter \
  --name /prod/app/api_key \
  --type SecureString \
  --value "api-key-123"
```

---

### Step 2 — EC2 IAM Role

Create role with:

```json
ssm:GetParameter
```

Attach role to EC2

---

### Step 3 — Read Parameter in Terraform

```hcl
data "aws_ssm_parameter" "api_key" {
  name            = "/prod/app/api_key"
  with_decryption = true
}
```

---

### Step 4 — Inject into EC2

```hcl
user_data = <<EOF
#!/bin/bash
export API_KEY=${data.aws_ssm_parameter.api_key.value}
EOF
```

---

## 5️⃣ Why Companies Use SSM

* Cheaper than Secrets Manager
* Simple secrets
* Tight EC2 IAM integration

---

## 6️⃣ Interview Explanation

> “For simple secrets, we use SSM SecureString. EC2 IAM roles allow secure access without exposing secrets in scripts or repositories.”

---

# 🔐 PROJECT 3 — CI/CD Secrets (GitHub Actions)

## “Terraform Deployments Without Local Secrets”

---

## 1️⃣ Company Type

**Modern DevOps teams**

* Remote teams
* Platform engineering teams

---

## 2️⃣ Situation

* Terraform runs in CI
* Developers must not have AWS keys locally

---

## 3️⃣ Goal

👉 Terraform deploys infrastructure **only via CI**

---

## 4️⃣ Step-by-Step

### Step 1 — Store Secrets in GitHub

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* DB_PASSWORD

---

### Step 2 — Terraform Variable

```hcl
variable "db_password" {
  sensitive = true
}
```

---

### Step 3 — GitHub Actions

```yaml
env:
  TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
```

---

### Step 4 — Terraform Apply Runs in CI

No local secrets
No local Terraform apply

---

## 5️⃣ Why Companies Do This

* Zero trust
* Audit logs
* Consistent deployments

---

## 6️⃣ Interview Explanation

> “Terraform runs only in CI pipelines. Secrets are injected at runtime from the CI secret manager, preventing local exposure.”

---

# 🔐 PROJECT 4 — Terraform Cloud

## “Team-Safe Terraform Execution”

---

## 1️⃣ Company Type

**Large teams**

* Enterprise
* Consulting companies

---

## 2️⃣ Situation

* Multiple engineers
* Risk of state conflicts
* Secret sprawl

---

## 3️⃣ Goal

👉 Centralize Terraform execution

---

## 4️⃣ Step-by-Step

### Step 1 — Create Terraform Cloud Workspace

* Link GitHub repo
* Select AWS provider

---

### Step 2 — Add Sensitive Variables

* Mark as **Sensitive**
* Encrypted storage

---

### Step 3 — Push Code → Auto Apply

Terraform runs remotely

---

## 5️⃣ Why Companies Use This

* No local Terraform
* State locking
* Encrypted secrets

---

## 6️⃣ Interview Explanation

> “Terraform Cloud centralizes execution and securely stores sensitive variables, making collaboration safe.”

---

# 🔐 PROJECT 5 — HashiCorp Vault (Advanced)

---

## 1️⃣ Company Type

**Banks / FinTech / Enterprises**

---

## 2️⃣ Situation

* Strict security
* Need short-lived credentials

---

## 3️⃣ Goal

👉 No long-lived secrets

---

## 4️⃣ Step-by-Step (Conceptual)

* Vault issues DB credentials
* Terraform reads credentials
* Credentials auto-expire

---

## 5️⃣ Why Companies Use Vault

* Zero trust
* Rotation
* Audit compliance

---

## 6️⃣ Interview Explanation

> “Vault provides dynamic secrets, reducing blast radius by issuing time-bound credentials.”

---

# 🧠 FINAL TEACHING SUMMARY 

| Tool            | When Used                  |
| --------------- | -------------------------- |
| Secrets Manager | Production DBs             |
| SSM             | Simple EC2 secrets         |
| CI Secrets      | Pipelines                  |
| Terraform Cloud | Team execution             |
| Vault           | High-security environments |


