---
title: "lab: terraform final production grade"
description: "1. Lab order   Follow this exact order:           Phase A — Build repo locally    Create..."
published: 2026-03-26
source: "https://dev.to/jumptotech/lab-terraform-final-production-grade-2ank"
tags: []
---

# lab: terraform final production grade





# 1. Lab order

Follow this exact order:

## Phase A — Build repo locally

1. Create folders
2. Paste Terraform files
3. Bootstrap backend locally:

   * S3 bucket for state
   * DynamoDB lock table
4. Update backend config files
5. Test `dev` locally

## Phase B — Prepare GitHub + AWS trust

6. Create GitHub repo
7. Push code
8. Configure AWS OIDC provider
9. Create IAM role for GitHub Actions
10. Add GitHub secret and variable



# 🔵 STEP 1 — Create GitHub Repository

Go to:
👉 GitHub

### Click:

* **New repository**

### Fill:

```yaml
Repository name: terraform-platform
Visibility: Public or Private (your choice)
```

### Click:

✅ **Create repository**

---

# 🔵 STEP 2 — Push your code

On your Mac (inside project folder):

```bash
git init
git add .
git commit -m "initial terraform platform"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/terraform-platform.git
git push -u origin main
```

Now your repo is live.

---

# 🔴 STEP 3 — Configure AWS OIDC Provider (VERY IMPORTANT)

This allows GitHub → AWS without access keys.

---

## Go to:

👉 AWS Management Console
👉 IAM → **Identity providers**

### Click:

**Add provider**

---

## Fill EXACTLY:

```yaml
Provider type: OpenID Connect
Provider URL: https://token.actions.githubusercontent.com
Audience: sts.amazonaws.com
```

### Click:

✅ **Add provider**

---

✔️ Done: AWS now trusts GitHub.

---

# 🔴 STEP 4 — Create IAM Role for GitHub Actions

---

## Go to:

👉 IAM → **Roles** → **Create role**

---

## Step 1 — Select trusted entity

Choose:

```plaintext
Web identity
```

---

## Step 2 — Select provider

```yaml
Identity provider: token.actions.githubusercontent.com
Audience: sts.amazonaws.com
```

Click:
➡️ Next

---

## Step 3 — Attach permissions

For LAB (simple):

✅ Select:

```plaintext
AdministratorAccess
```

(Production → use least privilege later)

Click:
➡️ Next

---

## Step 4 — Name role

```yaml
Role name: github-actions-terraform-role
```

Click:
✅ Create role

---

# 🔴 STEP  — UPDATE TRUST POLICY (CRITICAL)

Now edit the role trust policy.

---

## Open role → Trust relationships → Edit

Replace everything with:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/terraform-platform:*"
        }
      }
    }
  ]
}
```

---

## Replace:

| Field           | Example          |
| --------------- | ---------------- |
| YOUR_ACCOUNT_ID | 123456789012     |
| YOUR_USERNAME   | aisalkynaidarova |

---

## Example FINAL:

```json
"Principal": {
  "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
},
"Condition": {
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:aisalkynaidarova/terraform-platform:*"
  }
}
```

---

Click:
✅ **Update policy**

---

# 🔴 STEP 9.2 — Copy ROLE ARN

After creating role, copy:

Example:

```plaintext
arn:aws:iam::123456789012:role/github-actions-terraform-role
```

---

# 🔵 STEP  — Configure GitHub Secrets & Variables

Go to your repo:

👉 Settings → **Secrets and variables → Actions**

---

## 🔐 Add SECRET

Click:
👉 **New repository secret**

```yaml
Name: AWS_ROLE_ARN
Value: arn:aws:iam::123456789012:role/github-actions-terraform-role
```

Click:
✅ Save

---

## ⚙️ Add VARIABLE

Click:
👉 **Variables → New repository variable**

```yaml
Name: AWS_REGION
Value: us-east-2
```

Click:
✅ Save

---

# 🔵 FINAL CHECKLIST

You must have:

### AWS:

✔ OIDC provider created
✔ IAM role created
✔ Trust policy updated
✔ Role ARN copied

---

### GitHub:

✔ Repo created
✔ Code pushed
✔ Secret added:

```plaintext
AWS_ROLE_ARN
```

✔ Variable added:

```plaintext
AWS_REGION
```

---

# 🔵 TEST (VERY IMPORTANT)

Create a branch:

```bash
git checkout -b test-ci
git add .
git commit -m "test github actions"
git push origin test-ci
```

👉 Open Pull Request

---

# 🔵 EXPECTED RESULT

Go to:
👉 GitHub → Actions

You should see:

```plaintext
Terraform Plan ✅
```

---

# 🔴 COMMON ERRORS (and fixes)

---

## ❌ ERROR: Not authorized to assume role

Fix:

* repo name wrong in trust policy
* username wrong
* missing OIDC provider

---

## ❌ ERROR: No credentials

Fix:
Workflow must have:

```yaml
permissions:
  id-token: write
```

---

## ❌ ERROR: AccessDenied (S3)

Fix:

* role missing permissions
* wrong bucket name

---

## ❌ ERROR: role-to-assume not working

Check:

```yaml
with:
  role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
```

---

# 🔵 HOW TO EXPLAIN (INTERVIEW)

Say:

“I configured GitHub Actions to authenticate to AWS using OIDC. Instead of storing AWS access keys, GitHub requests a short-lived token which AWS validates through an identity provider and IAM role trust policy.”



## Phase C — CI/CD

11. Add GitHub Actions workflows
12. Create a feature branch
13. Push branch
14. Open PR
15. Plan runs
16. Merge to main
17. Dev apply runs
18. Prod apply runs manually

---

# 2. Final project skeleton

```text
terraform-platform/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply-dev.yml
│       └── terraform-apply-prod.yml
│
├── bootstrap/
│   └── backend/
│       ├── versions.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
│
├── modules/
│   ├── network/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   │
│   ├── alb/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   │
│   ├── app/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   │
│   ├── rds/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   │
│   ├── dynamodb/
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   │
│   └── secrets/
│       ├── versions.tf
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
│
├── envs/
│   ├── dev/
│   │   ├── versions.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── backend.hcl
│   │   └── terraform.tfvars.example
│   │
│   ├── stage/
│   │   ├── versions.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── backend.hcl
│   │   └── terraform.tfvars.example
│   │
│   └── prod/
│       ├── versions.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── backend.hcl
│       └── terraform.tfvars.example
│
└── .gitignore
```

---

# 3. Create folders first

Run this first:

```bash
mkdir -p terraform-platform
cd terraform-platform

mkdir -p .github/workflows
mkdir -p bootstrap/backend
mkdir -p modules/{network,alb,app,rds,dynamodb,secrets}
mkdir -p envs/{dev,stage,prod}
```

---

# 4. Root file

## `.gitignore`

**Function:** prevents committing state files, tfvars, and local Terraform cache.

```gitignore
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraform.lock.hcl
.DS_Store
```

---

# 5. Bootstrap backend files

This folder is run **first**.
It creates:

* **S3 bucket** for Terraform state
* **DynamoDB table** for state lock

---

## `bootstrap/backend/versions.tf`

**Function:** defines Terraform and provider versions.

```hcl
terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## `bootstrap/backend/providers.tf`

**Function:** AWS provider for backend resources.

```hcl
provider "aws" {
  region = var.aws_region
}
```

## `bootstrap/backend/variables.tf`

**Function:** inputs for backend resources.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state lock"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

## `bootstrap/backend/main.tf`

**Function:** creates S3 backend bucket and DynamoDB lock table.

```hcl
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  tags = merge(var.common_tags, {
    Name      = var.state_bucket_name
    ManagedBy = "Terraform"
    Purpose   = "TerraformState"
  })
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name      = var.lock_table_name
    ManagedBy = "Terraform"
    Purpose   = "TerraformStateLock"
  })
}
```

## `bootstrap/backend/outputs.tf`

**Function:** shows created backend names.

```hcl
output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}
```

## `bootstrap/backend/terraform.tfvars.example`

**Function:** example values you copy to real `terraform.tfvars`.

```hcl
aws_region        = "us-east-2"
state_bucket_name = "CHANGE-ME-UNIQUE-terraform-state-bucket"
lock_table_name   = "terraform-state-locks"

common_tags = {
  Project   = "terraform-platform"
  Owner     = "devops"
  ManagedBy = "terraform"
}
```

HashiCorp’s S3 backend docs explicitly recommend S3 backend configuration for state storage and note that DynamoDB locking is deprecated while S3 lockfiles are supported; S3 bucket versioning is commonly used so older state can be recovered. ([HashiCorp Developer][1])

---

# 6. Reusable modules

---

## MODULE: network

### `modules/network/versions.tf`

**Function:** provider requirements for this module.

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/network/variables.tf`

**Function:** inputs for VPC, subnets, NAT.

```hcl
variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/network/main.tf`

**Function:** builds VPC, IGW, public/private subnets, NAT, route tables.

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt"
  })
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### `modules/network/outputs.tf`

**Function:** exports IDs to other modules.

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

---

## MODULE: alb

### `modules/alb/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/alb/variables.tf`

**Function:** inputs for ALB, target group, listener.

```hcl
variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/alb/main.tf`

**Function:** creates ALB, target group, listener.

```hcl
resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = merge(var.common_tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.name}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
```

### `modules/alb/outputs.tf`

**Function:** outputs ALB and target group values.

```hcl
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
```

---

## MODULE: app

### `modules/app/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/app/variables.tf`

**Function:** inputs for Launch Template and ASG.

```hcl
variable "name_prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "user_data" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/app/main.tf`

**Function:** creates Launch Template and Auto Scaling Group.

```hcl
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-app"
    })
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
```

### `modules/app/outputs.tf`

**Function:** outputs ASG name.

```hcl
output "asg_name" {
  value = aws_autoscaling_group.this.name
}
```

---

## MODULE: rds

This uses AWS-managed Secrets Manager for the DB master password instead of hardcoding a password in Terraform. Terraform Registry documents `manage_master_user_password`, and the related `master_user_secret` is available when that is enabled. ([Terraform Registry][3])

### `modules/rds/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/rds/variables.tf`

**Function:** inputs for RDS and subnet group.

```hcl
variable "identifier" {
  type = string
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "16.3"
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 100
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/rds/main.tf`

**Function:** creates DB subnet group and DB instance.

```hcl
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                   = var.identifier
  db_name                      = var.db_name
  username                     = var.username
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = var.security_group_ids
  multi_az                     = var.multi_az
  publicly_accessible          = false
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  manage_master_user_password  = true
  backup_retention_period      = 7
  auto_minor_version_upgrade   = true
  storage_encrypted            = true

  tags = merge(var.common_tags, {
    Name = var.identifier
  })
}
```

### `modules/rds/outputs.tf`

**Function:** outputs DB endpoint and the secret ARN created by RDS.

```hcl
output "db_instance_endpoint" {
  value = aws_db_instance.this.address
}

output "db_instance_port" {
  value = aws_db_instance.this.port
}

output "master_user_secret_arn" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}
```

---

## MODULE: dynamodb

### `modules/dynamodb/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/dynamodb/variables.tf`

**Function:** inputs for application DynamoDB table.

```hcl
variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/dynamodb/main.tf`

**Function:** creates application DynamoDB table.

```hcl
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = var.table_name
  })
}
```

### `modules/dynamodb/outputs.tf`

**Function:** outputs table info.

```hcl
output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}
```

Terraform Registry documents the DynamoDB table resource and supports point-in-time recovery and server-side encryption options for tables. ([Terraform Registry][4])

---

## MODULE: secrets

### `modules/secrets/versions.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

### `modules/secrets/variables.tf`

**Function:** inputs for application secret.

```hcl
variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "secret_string" {
  type = string
  sensitive = true
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

### `modules/secrets/main.tf`

**Function:** creates the secret and its current value.

```hcl
resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description

  tags = merge(var.common_tags, {
    Name = var.name
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}
```

### `modules/secrets/outputs.tf`

**Function:** outputs secret ARN and name.

```hcl
output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.this.name
}
```

Terraform Registry documents separate resources for secret metadata and secret value versioning in Secrets Manager. ([Terraform Registry][5])

---

# 7. Environment root files

You will use the same root structure for `dev`, `stage`, and `prod`.

---

## `envs/dev/versions.tf`

**Function:** sets Terraform version, backend, provider.

```hcl
terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## `envs/dev/providers.tf`

**Function:** AWS provider config for this environment.

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
```

## `envs/dev/variables.tf`

**Function:** all inputs for the dev stack.

```hcl
variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "allowed_http_cidrs" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_skip_final_snapshot" {
  type = bool
}

variable "app_secret_json" {
  type      = string
  sensitive = true
}
```

## `envs/dev/main.tf`

**Function:** connects all modules and creates security groups.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags          = local.common_tags
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "App security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "DB security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "Postgres from app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

module "alb" {
  source = "../../modules/alb"

  name               = "${local.name_prefix}-alb"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_port        = 80
  health_check_path  = "/"
  common_tags        = local.common_tags
}

module "app" {
  source = "../../modules/app"

  name_prefix        = local.name_prefix
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [aws_security_group.app.id]
  target_group_arns  = [module.alb.target_group_arn]
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  key_name           = var.key_name

  user_data = <<-EOT
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>${var.project_name} - ${var.environment}</h1>" > /usr/share/nginx/html/index.html
              EOT

  common_tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  identifier              = "${local.name_prefix}-postgres"
  db_name                 = var.db_name
  username                = var.db_username
  instance_class          = var.db_instance_class
  subnet_ids              = module.network.private_subnet_ids
  security_group_ids      = [aws_security_group.db.id]
  multi_az                = var.db_multi_az
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  common_tags             = local.common_tags
}

module "app_table" {
  source = "../../modules/dynamodb"

  table_name = "${local.name_prefix}-app-table"
  hash_key   = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  common_tags = local.common_tags
}

module "app_secret" {
  source = "../../modules/secrets"

  name          = "${local.name_prefix}/app/config"
  description   = "Application config secret"
  secret_string = var.app_secret_json
  common_tags   = local.common_tags
}
```

## `envs/dev/outputs.tf`

**Function:** shows useful outputs.

```hcl
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "app_asg_name" {
  value = module.app.asg_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "app_table_name" {
  value = module.app_table.table_name
}

output "app_secret_arn" {
  value = module.app_secret.secret_arn
}
```

## `envs/dev/backend.hcl`

**Function:** tells Terraform where to store this environment’s state.

```hcl
bucket         = "CHANGE-ME-terraform-state-bucket"
key            = "terraform-platform/dev/terraform.tfstate"
region         = "us-east-2"
encrypt        = true
dynamodb_table = "terraform-state-locks"
use_lockfile   = true
```

## `envs/dev/terraform.tfvars.example`

**Function:** sample values for dev.

```hcl
aws_region        = "us-east-2"
project_name      = "terraform-platform"
environment       = "dev"
owner             = "devops"

vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

instance_type    = "t3.micro"
desired_capacity = 1
min_size         = 1
max_size         = 2

key_name = null

allowed_http_cidrs = ["0.0.0.0/0"]

db_name                = "appdb"
db_username            = "appadmin"
db_instance_class      = "db.t3.micro"
db_multi_az            = false
db_deletion_protection = false
db_skip_final_snapshot = true

app_secret_json = "{\"APP_ENV\":\"dev\",\"LOG_LEVEL\":\"info\"}"
```

---

# 8. Stage and prod files

To keep this clean, use the **same file contents** for:

* `envs/stage/versions.tf`
* `envs/stage/providers.tf`
* `envs/stage/variables.tf`
* `envs/stage/main.tf`
* `envs/stage/outputs.tf`

and

* `envs/prod/versions.tf`
* `envs/prod/providers.tf`
* `envs/prod/variables.tf`
* `envs/prod/main.tf`
* `envs/prod/outputs.tf`

Then only change `backend.hcl` and `terraform.tfvars.example`.

## `envs/stage/backend.hcl`

```hcl
bucket         = "CHANGE-ME-terraform-state-bucket"
key            = "terraform-platform/stage/terraform.tfstate"
region         = "us-east-2"
encrypt        = true
dynamodb_table = "terraform-state-locks"
use_lockfile   = true
```

## `envs/stage/terraform.tfvars.example`

```hcl
aws_region        = "us-east-2"
project_name      = "terraform-platform"
environment       = "stage"
owner             = "devops"

vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]

instance_type    = "t3.micro"
desired_capacity = 1
min_size         = 1
max_size         = 2

key_name = null

allowed_http_cidrs = ["0.0.0.0/0"]

db_name                = "appdb"
db_username            = "appadmin"
db_instance_class      = "db.t3.micro"
db_multi_az            = false
db_deletion_protection = false
db_skip_final_snapshot = true

app_secret_json = "{\"APP_ENV\":\"stage\",\"LOG_LEVEL\":\"info\"}"
```

## `envs/prod/backend.hcl`

```hcl
bucket         = "CHANGE-ME-terraform-state-bucket"
key            = "terraform-platform/prod/terraform.tfstate"
region         = "us-east-2"
encrypt        = true
dynamodb_table = "terraform-state-locks"
use_lockfile   = true
```

## `envs/prod/terraform.tfvars.example`

```hcl
aws_region        = "us-east-2"
project_name      = "terraform-platform"
environment       = "prod"
owner             = "devops"

vpc_cidr             = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24"]
private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24"]

instance_type    = "t3.small"
desired_capacity = 2
min_size         = 2
max_size         = 4

key_name = null

allowed_http_cidrs = ["0.0.0.0/0"]

db_name                = "appdb"
db_username            = "appadmin"
db_instance_class      = "db.t3.small"
db_multi_az            = true
db_deletion_protection = true
db_skip_final_snapshot = false

app_secret_json = "{\"APP_ENV\":\"prod\",\"LOG_LEVEL\":\"warn\"}"
```

---

# 9. Local bootstrap steps

## Step 1

Go to backend bootstrap folder:

```bash
cd bootstrap/backend
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

* real bucket name
* real region

## Step 2

Run backend bootstrap:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Step 3

Copy the created names into:

* `envs/dev/backend.hcl`
* `envs/stage/backend.hcl`
* `envs/prod/backend.hcl`

---

# 10. Local environment test

Do this for dev first.

```bash
cd ../../envs/dev
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

When `dev` works locally, repeat for `stage` and `prod` later.

---

# 11. Push to GitHub

## Step 1 — create GitHub repo

Create a new empty GitHub repository named:

```text
terraform-platform
```

## Step 2 — connect local repo

```bash
cd ../../
git init
git add .
git commit -m "Initial production-grade Terraform platform repo"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/terraform-platform.git
git push -u origin main
```

The checkout action is the standard way to place your repository into `$GITHUB_WORKSPACE`, and HashiCorp’s setup action is the supported action for installing Terraform CLI in workflows. ([GitHub][6])

---

# 12. AWS setup for GitHub Actions

Now prepare AWS so GitHub can assume a role.

---

## Step 12.1 — Create OIDC provider in AWS

Go to:

**AWS Console → IAM → Identity providers → Add provider**

Use:

* Provider type: `OpenID Connect`
* Provider URL: `https://token.actions.githubusercontent.com`
* Audience: `sts.amazonaws.com`

GitHub’s AWS OIDC guide uses GitHub’s OIDC provider with audience `sts.amazonaws.com`. ([GitHub Docs][2])

---

## Step 12.2 — Create IAM role for GitHub Actions

Create an IAM role trusted by GitHub OIDC.

Use this trust policy and replace:

* `YOUR_ACCOUNT_ID`
* `YOUR_GITHUB_USERNAME`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/terraform-platform:*"
        }
      }
    }
  ]
}
```

GitHub documents that the cloud provider validates the OIDC token claims, including subject and audience, against the role trust configuration. ([GitHub Docs][7])

---

## Step 12.3 — Attach permissions to that IAM role

For a learning lab, attach a broad policy first so the workflow can create all resources, then reduce later.

Simplest lab option:

* `AdministratorAccess`

Better real-world option:

* custom least-privilege policy for:

  * S3
  * DynamoDB
  * EC2
  * ELB
  * Auto Scaling
  * RDS
  * Secrets Manager
  * IAM PassRole if needed later

---

# 13. What to add in GitHub

Go to:

**GitHub repo → Settings → Secrets and variables → Actions**

## Repository secret

Create this secret:

* `AWS_ROLE_ARN` = your IAM role ARN

Example:

```text
arn:aws:iam::123456789012:role/github-actions-terraform-role
```

## Repository variable

Create this variable:

* `AWS_REGION` = your region
  Example:

```text
us-east-2
```

That is all you need for this repo design.
You do **not** need `TF_DEV_DIR`, `TF_STAGE_DIR`, `TF_PROD_DIR` because the workflow below directly uses the folder paths, which reduces misconfiguration.

GitHub’s AWS guide and the `configure-aws-credentials` action both describe using OIDC plus a role ARN in the workflow, rather than long-lived AWS keys in repository secrets. ([GitHub Docs][2])

---

# 14. GitHub Actions workflows

---

## `.github/workflows/terraform-plan.yml`

**Function:** on PR, format, init, validate, and plan for all three environments.

```yaml
name: Terraform Plan

on:
  pull_request:
    branches:
      - main

permissions:
  contents: read
  id-token: write

jobs:
  plan-dev:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform fmt
        run: terraform fmt -check -recursive

      - name: Terraform init dev
        working-directory: envs/dev
        run: terraform init -backend-config=backend.hcl

      - name: Terraform validate dev
        working-directory: envs/dev
        run: terraform validate

      - name: Terraform plan dev
        working-directory: envs/dev
        run: terraform plan -no-color

  plan-stage:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform init stage
        working-directory: envs/stage
        run: terraform init -backend-config=backend.hcl

      - name: Terraform validate stage
        working-directory: envs/stage
        run: terraform validate

      - name: Terraform plan stage
        working-directory: envs/stage
        run: terraform plan -no-color

  plan-prod:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform init prod
        working-directory: envs/prod
        run: terraform init -backend-config=backend.hcl

      - name: Terraform validate prod
        working-directory: envs/prod
        run: terraform validate

      - name: Terraform plan prod
        working-directory: envs/prod
        run: terraform plan -no-color
```

---

## `.github/workflows/terraform-apply-dev.yml`

**Function:** after merge to `main`, apply dev automatically.

```yaml
name: Terraform Apply Dev

on:
  push:
    branches:
      - main
    paths:
      - 'modules/**'
      - 'envs/dev/**'
      - '.github/workflows/terraform-apply-dev.yml'
      - '.github/workflows/terraform-plan.yml'

permissions:
  contents: read
  id-token: write

jobs:
  apply-dev:
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform init
        working-directory: envs/dev
        run: terraform init -backend-config=backend.hcl

      - name: Terraform plan
        working-directory: envs/dev
        run: terraform plan -out=tfplan

      - name: Terraform apply
        working-directory: envs/dev
        run: terraform apply -auto-approve tfplan
```

---

## `.github/workflows/terraform-apply-prod.yml`

**Function:** manual production apply.

```yaml
name: Terraform Apply Prod

on:
  workflow_dispatch:

permissions:
  contents: read
  id-token: write

jobs:
  apply-prod:
    runs-on: ubuntu-latest
    environment: prod

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform init
        working-directory: envs/prod
        run: terraform init -backend-config=backend.hcl

      - name: Terraform plan
        working-directory: envs/prod
        run: terraform plan -out=tfplan

      - name: Terraform apply
        working-directory: envs/prod
        run: terraform apply -auto-approve tfplan
```

GitHub’s OIDC docs require `id-token: write`, and the `configure-aws-credentials` action recommends OIDC-based short-lived credentials. The checkout action checks out the repo for the workflow, and `hashicorp/setup-terraform` installs Terraform CLI. ([GitHub Docs][2])

---

# 15. GitHub environments

Create these GitHub environments:

* `dev`
* `prod`

Go to:

**Repo → Settings → Environments**

For `prod`, add required reviewers if you want approval before production deploy.

GitHub’s docs recommend environment protection together with OIDC trust restrictions for stronger deployment security. ([GitHub Docs][2])

---

# 16. First full run

## Local

1. bootstrap backend
2. update backend.hcl files
3. run `dev` locally and confirm success

## GitHub

4. push repo to GitHub
5. add `AWS_ROLE_ARN` secret
6. add `AWS_REGION` variable
7. create feature branch:

```bash
git checkout -b feature/test-ci
git add .
git commit -m "Add Terraform CI/CD"
git push -u origin feature/test-ci
```

8. open PR to `main`
9. `Terraform Plan` runs
10. merge PR
11. `Terraform Apply Dev` runs
12. run `Terraform Apply Prod` manually from Actions tab

---

# 17. Why each major part exists

## bootstrap/backend

Creates shared backend resources first so the rest of Terraform can use remote state.

## modules/network

Reusable networking foundation.

## modules/alb

Reusable load balancer layer.

## modules/app

Reusable compute layer with Launch Template + ASG.

## modules/rds

Reusable managed relational database layer.

## modules/dynamodb

Reusable NoSQL application table.

## modules/secrets

Reusable app secret storage.

## envs/dev stage prod

Root modules. This is where you choose actual values per environment.

## backend.hcl

Separates state file location by environment.

## GitHub workflows

Automate plan/apply safely.

---

# 18. Common mistakes that break the pipeline

These are the usual reasons it fails:

* bucket name in `backend.hcl` does not match real S3 bucket
* DynamoDB table name in `backend.hcl` does not match real lock table
* `AWS_ROLE_ARN` secret missing
* `AWS_REGION` variable missing
* OIDC provider not created in AWS
* IAM trust policy repo name does not match exact GitHub repo
* branch is wrong in workflow trigger
* `terraform.tfvars` missing locally when testing
* state bucket name is not globally unique
* using old Terraform that behaves differently around backend locking



# 20. Best next move

Copy these files exactly, then start with only this sequence:

```bash
cd terraform-platform/bootstrap/backend
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Then:

```bash
cd ../../envs/dev
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

After that, push to GitHub and enable the workflows.


[1]: https://developer.hashicorp.com/terraform/language/backend/s3?utm_source=chatgpt.com "Backend Type: s3 | Terraform"
[2]: https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services?utm_source=chatgpt.com "Configuring OpenID Connect in Amazon Web Services"
[3]: https://registry.terraform.io/providers/hashicorp/awS/6.37.0/docs/data-sources/db_instance?utm_source=chatgpt.com "aws_db_instance | Data Sources | hashicorp/aws | Terraform"
[4]: https://registry.terraform.io/providers/-/aws/6.37.0/docs/resources/dynamodb_table?utm_source=chatgpt.com "aws_dynamodb_table | Resources | hashicorp/aws | Terraform"
[5]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret?utm_source=chatgpt.com "aws_secretsmanager_secret - Terraform Registry"
[6]: https://github.com/actions/checkout?utm_source=chatgpt.com "actions/checkout: Action for checking out a repo"
[7]: https://docs.github.com/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect?utm_source=chatgpt.com "OpenID Connect"

