# 🏗️ Enterprise SRE Lab: E-Commerce Platform on AWS
## Complete Step-by-Step Guide for Senior SRE Engineers (6+ Years Experience)

---

> **How to Use This Guide**
> Every step tells you: WHERE to go, WHAT to click/type, WHY you're doing it, and WHAT the expected outcome is.
> Pay attention to the **🔴 SRE ALERT** boxes — these are real production gotchas that get people fired or paged at 3am.
> **Interview callouts** are marked with 🎯

---

## 📐 Architecture Overview

```
Internet
    │
    ▼
[Route 53] ──── DNS / Health-Based Routing / Failover
    │
    ▼
[CloudFront CDN] ──── WAF (Web Application Firewall) ──── Shield Advanced
    │
    ▼
[Application Load Balancer - Public] ──── access logs to S3 ──── TLS 1.3 only
    │
    ├── /api/*    ─→ [ECS Fargate: API Service]  ──── Auto Scaling
    ├── /auth/*   ─→ [ECS Fargate: Auth Service] ──── Auto Scaling
    ├── /checkout ─→ [ECS Fargate: Checkout]     ──── Auto Scaling
    └── /static/* ─→ [S3 + CloudFront]
              │
              ▼
    [Internal ALB - Private Subnet]
              │
              ├── [ECS: Product Catalog Service]
              ├── [ECS: Inventory Service]
              ├── [ECS: Order Service]
              └── [ECS: Notification Service]
                        │
                        ▼
              [Data Layer - Private Subnet]
              ├── [RDS Aurora MySQL - Multi-AZ Writer + 2 Readers]
              ├── [ElastiCache Redis Cluster - Session/Cache]
              ├── [DynamoDB - Cart, Sessions, Feature Flags]
              └── [SQS + SNS - Async Order Processing]

[Monitoring VPC / Same Region]
├── [EC2: Prometheus Server] ──── scrapes all targets
├── [EC2: Grafana Server]    ──── dashboards / alerting
├── [Node Exporter]          ──── on every EC2 instance
└── [CloudWatch] ──── Lambda, ECS, RDS metrics → Prometheus via exporter

[Security Services]
├── AWS Config ──── compliance rules
├── Security Hub ──── aggregated findings
├── GuardDuty ──── threat detection
├── Macie ──── PII data detection in S3
├── Inspector ──── EC2 vulnerability scanning
└── CloudTrail ──── all API call audit log

[CI/CD Pipeline]
GitHub → GitHub Actions → ECR → ECS Rolling Deploy
                       → Terraform Plan/Apply
                       → Prometheus Alerting Rules Update
```

---

## 📋 Table of Contents

1. [AWS Account Bootstrap & IAM Foundation](#1-aws-account-bootstrap--iam-foundation)
2. [Terraform Setup & State Backend](#2-terraform-setup--state-backend)
3. [VPC & Network Architecture](#3-vpc--network-architecture)
4. [Security Hardening Layer](#4-security-hardening-layer)
5. [IAM Roles, Policies & Permission Boundaries](#5-iam-roles-policies--permission-boundaries)
6. [E-Commerce Application Infrastructure](#6-e-commerce-application-infrastructure)
7. [Database Layer (RDS Aurora, Redis, DynamoDB)](#7-database-layer)
8. [Monitoring Stack: Prometheus + Grafana + Node Exporter](#8-monitoring-stack)
9. [GitHub Repository & GitHub Actions CI/CD](#9-github-repository--github-actions-cicd)
10. [Runbooks & Troubleshooting Scenarios](#10-runbooks--troubleshooting-scenarios)
11. [SRE Interview Q&A Deep Dive](#11-sre-interview-qa-deep-dive)

---

## 1. AWS Account Bootstrap & IAM Foundation

### 1.1 Why We Start With IAM — Not With EC2

As a 6-year SRE, your first instinct should be **least privilege by default**. Every mistake I see mid-level engineers make is spinning up infrastructure first and bolting security on later. In an e-commerce org, a misconfigured S3 bucket or an over-permissioned role is a data breach, a GDPR fine, and a board-level incident. **We build security in from day zero.**

---

### 1.2 AWS Organizations Setup

**Where to go:** Log into your root AWS account → Services → AWS Organizations

**What to do:**

1. Click **"Create organization"** → Enable all features
2. Create the following Organizational Units (OUs):

```
Root
├── Security OU          ← Security tooling account (GuardDuty, Security Hub master)
├── Infrastructure OU    ← Terraform state, shared services
├── Production OU        ← Production workloads
├── Staging OU           ← Staging/pre-prod
├── Development OU       ← Dev accounts per team
└── Logging OU           ← Centralized CloudTrail, VPC Flow Logs
```

**Why:** Multi-account strategy gives you blast radius containment. If a dev account is compromised, it cannot affect production. Service Control Policies (SCPs) on each OU enforce guardrails that **even account admins cannot override**.

**What to type in the Organizations console — create SCP to prevent disabling CloudTrail:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCloudTrailDisable",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyLeaveOrganization",
      "Effect": "Deny",
      "Action": [
        "organizations:LeaveOrganization"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyRootAccountActions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
```

**Click:** AWS Organizations → Policies → Service Control Policies → Create Policy → paste JSON above → name it `DenySecurityDegradation` → Attach to Root OU.

**🔴 SRE ALERT:** Never use your root account for day-to-day work. The root account should have MFA enabled, no access keys, and its credentials stored in a physical safe. If your team uses the root account regularly, that is a Severity 1 security finding.

---

### 1.3 Bootstrap IAM Users — Human Access

**Where to go:** AWS Console → IAM → Users

**What we're building:** A tiered human access model.

```
Human Users
├── SRE Engineers   → SRE-Role (read all, write infra, no IAM changes)
├── Developers      → Developer-Role (ECS, ECR, CloudWatch only)
├── Security Team   → Security-Role (read-only + Security Hub + GuardDuty)
└── On-Call Lead    → Break-Glass-Role (time-limited, full access, auto-revoke)
```

**Go to:** IAM → Policies → Create Policy → JSON tab

**Create the SRE Base Policy:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SREReadAll",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ecs:Describe*",
        "ecs:List*",
        "rds:Describe*",
        "elasticache:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "cloudwatch:Describe*",
        "logs:Describe*",
        "logs:Get*",
        "logs:Filter*",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketLogging",
        "s3:GetBucketPolicy",
        "iam:Get*",
        "iam:List*",
        "config:Get*",
        "config:Describe*",
        "config:List*",
        "securityhub:Get*",
        "securityhub:List*",
        "guardduty:Get*",
        "guardduty:List*",
        "elasticloadbalancing:Describe*",
        "route53:Get*",
        "route53:List*",
        "cloudfront:Get*",
        "cloudfront:List*",
        "wafv2:Get*",
        "wafv2:List*",
        "ssm:Describe*",
        "ssm:Get*",
        "secretsmanager:Describe*",
        "secretsmanager:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SREInfraWrite",
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ecs:UpdateService",
        "ecs:RunTask",
        "ecs:StopTask",
        "rds:RebootDBInstance",
        "rds:FailoverDBCluster",
        "elasticache:RebootCacheCluster",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:UpdateAutoScalingGroup",
        "ssm:StartSession",
        "ssm:SendCommand"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyIAMWrite",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutUserPolicy",
        "iam:PutRolePolicy",
        "iam:CreateAccessKey"
      ],
      "Resource": "*"
    }
  ]
}
```

**Name it:** `SRE-Base-Policy` → Create Policy

**Why:** SREs need to read everything to diagnose issues. They need limited write to fix things during incidents. But they must never be able to escalate their own privileges — that's what the `DenyIAMWrite` section enforces. A compromised SRE credential is bad; a compromised SRE credential that can create admin users is catastrophic.

---

### 1.4 Create IAM Groups and Assign Policies

**Go to:** IAM → User Groups → Create Group

**Group: `sre-engineers`**
- Attach: `SRE-Base-Policy`
- Attach: `AWSSupportAccess` (so SREs can open support tickets)

**Group: `developers`**
- Create a separate policy `Developer-Policy`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DeveloperECSAccess",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyAllIAM",
      "Effect": "Deny",
      "Action": "iam:*",
      "Resource": "*"
    },
    {
      "Sid": "DenyProductionDeployWithoutTag",
      "Effect": "Deny",
      "Action": "ecs:UpdateService",
      "Resource": "arn:aws:ecs:us-east-1:*:service/production-*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

**🎯 INTERVIEW QUESTION:** "Why do you have both an Allow and a Deny for IAM in the developer policy?"
**Answer:** AWS IAM evaluation logic: an **explicit Deny always wins** over an Allow, regardless of where the Allow comes from (inline policy, group policy, role). The Deny ensures that even if someone attaches a managed policy that grants IAM access, this explicit deny overrides it. It's defense-in-depth.

---

### 1.5 Enable MFA Enforcement Policy

**Go to:** IAM → Policies → Create Policy → JSON

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowViewAccountInfo",
      "Effect": "Allow",
      "Action": [
        "iam:GetAccountPasswordPolicy",
        "iam:ListVirtualMFADevices"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowManageOwnMFA",
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::*:mfa/${aws:username}",
        "arn:aws:iam::*:user/${aws:username}"
      ]
    },
    {
      "Sid": "DenyAllWithoutMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

**Name it:** `Force-MFA-Policy` → Attach to ALL groups

**Why:** This policy blocks any AWS action (except MFA setup itself) if the session doesn't have MFA present. This means even if someone steals a user's access key from their laptop, they cannot do anything without the TOTP code. This is the single most impactful security control for human users.

---

## 2. Terraform Setup & State Backend

### 2.1 Why Terraform for an E-Commerce Platform

You cannot have reproducible, auditable infrastructure with click-ops. Every resource must be defined in code, version-controlled, peer-reviewed via pull request, and deployed through an automated pipeline. This is table stakes at any serious e-commerce company where infrastructure changes touch revenue.

### 2.2 Install Terraform Locally

```bash
# On your workstation (Mac with Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform --version
# Expected: Terraform v1.7.x or higher

# Install tfenv for version management across projects
brew install tfenv
tfenv install 1.7.5
tfenv use 1.7.5
```

**Why tfenv:** Different projects use different Terraform versions. Without version management, a terraform upgrade breaks your state files and causes a production incident. We pin the version in `.terraform-version` file in each repo.

### 2.3 Bootstrap Terraform State Backend

**This is done MANUALLY first, before any Terraform.** You cannot use Terraform to create the S3 bucket that stores Terraform's own state.

**Go to:** AWS Console → S3 → Create Bucket

**Click through:**
- Bucket name: `ecommerce-terraform-state-<your-account-id>`  (must be globally unique)
- Region: `us-east-1`
- Object Ownership: **ACLs disabled**
- Block Public Access: **Block all public access** ✅ (check all 4 checkboxes)
- Versioning: **Enable** ← CRITICAL — this lets you roll back to previous state
- Default encryption: **SSE-S3** (or SSE-KMS for stricter environments)
- Click Create bucket

**Then go to:** S3 → your bucket → Permissions → Bucket Policy → Edit → paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyNonSSL",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::ecommerce-terraform-state-<account-id>",
        "arn:aws:s3:::ecommerce-terraform-state-<account-id>/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AllowTerraformRoleOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/TerraformExecutionRole"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "arn:aws:s3:::ecommerce-terraform-state-<account-id>",
        "arn:aws:s3:::ecommerce-terraform-state-<account-id>/*"
      ]
    }
  ]
}
```

**Why:** The state bucket contains every secret your infrastructure has ever had — database passwords, TLS keys, everything. Restricting it to only the Terraform execution role and enforcing SSL means nobody can exfiltrate it even with AWS credentials. Versioning means you can see what state looked like before a botched `terraform apply`.

**Now create DynamoDB table for state locking:**

**Go to:** AWS Console → DynamoDB → Create Table

- Table name: `ecommerce-terraform-locks`
- Partition key: `LockID` (String)
- Table class: DynamoDB Standard
- Capacity mode: **On-demand** (state locking has bursty unpredictable traffic)
- Encryption: **AWS owned key** (or CMK for strict compliance)
- Click Create

**Why:** Without DynamoDB locking, two engineers running `terraform apply` simultaneously corrupt the state file. This has caused real production outages. The lock is acquired before any operation and released after. If a pipeline crashes mid-apply, you manually delete the lock from DynamoDB.

**🔴 SRE ALERT — Stale State Lock:**
```bash
# When you see: "Error acquiring the state lock"
# Check who has the lock:
aws dynamodb get-item \
  --table-name ecommerce-terraform-locks \
  --key '{"LockID": {"S": "ecommerce-terraform-state-<account-id>/global/s3/terraform.tfstate"}}' \
  --region us-east-1

# If the lock is stale (pipeline died), force-unlock:
terraform force-unlock <lock-id>
# ALWAYS verify the previous run actually failed before doing this
```

### 2.4 Terraform Project Structure

```bash
mkdir -p ~/projects/ecommerce-infra
cd ~/projects/ecommerce-infra

# Create directory structure
mkdir -p {modules,environments}/{vpc,security,ecs,rds,monitoring,cdn}
mkdir -p modules/{alb,ecs-service,rds-aurora,redis,security-group,iam-role}
mkdir -p environments/{production,staging,development}
```

**Final structure:**
```
ecommerce-infra/
├── .terraform-version          # Pin Terraform version
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml  # On PR: plan only
│       └── terraform-apply.yml # On merge to main: apply
├── modules/
│   ├── alb/                    # Reusable ALB module
│   ├── ecs-service/            # Reusable ECS Fargate service
│   ├── rds-aurora/             # Aurora MySQL cluster
│   ├── redis/                  # ElastiCache Redis
│   ├── security-group/         # Security group with standard rules
│   └── iam-role/               # IAM role with trust + permissions
└── environments/
    ├── production/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf          # State backend config
    │   └── terraform.tfvars    # Environment-specific values
    ├── staging/
    └── development/
```

**Create `.terraform-version`:**
```bash
echo "1.7.5" > .terraform-version
```

### 2.5 Backend Configuration

**Create `environments/production/backend.tf`:**
```hcl
terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ecommerce-terraform-state-<account-id>"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecommerce-terraform-locks"
    encrypt        = true
    # kms_key_id = "arn:aws:kms:us-east-1:<account-id>:key/<key-id>"  # Uncomment for CMK
  }
}

provider "aws" {
  region = var.aws_region

  # All resources get these tags automatically
  default_tags {
    tags = {
      Environment    = var.environment
      Project        = "ecommerce"
      ManagedBy      = "terraform"
      CostCenter     = "platform-engineering"
      DataClass      = "confidential"
      OnCallTeam     = "sre"
      LastUpdatedBy  = data.aws_caller_identity.current.arn
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
```

**Why default_tags:** Every resource in the account gets environment, cost center, and on-call team tags automatically. This means your AWS Cost Explorer shows which team owns which spend, and your alert routing knows who to page. Without tags, cost allocation in a large e-commerce org becomes impossible.

---

## 3. VPC & Network Architecture

### 3.1 Network Design Philosophy

E-commerce traffic flow requires **strict network segmentation**:
- Public internet should only ever reach the load balancers
- Application servers should never be publicly accessible
- Databases should only accept connections from application servers
- Monitoring should be on a separate subnet with dedicated security groups

### 3.2 VPC Terraform Module

**Create `modules/vpc/main.tf`:**

```hcl
locals {
  # Calculate subnets from the VPC CIDR
  # For 10.0.0.0/16 (65,536 IPs), we create /24 subnets (256 IPs each)
  az_count = length(var.availability_zones)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr                 # e.g., "10.0.0.0/16"
  enable_dns_hostnames = true   # Required for RDS, ECS service discovery
  enable_dns_support   = true   # Required for Route 53 private hosted zones

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

# Public subnets — ONLY load balancers and NAT Gateways live here
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  # cidrsubnet("10.0.0.0/16", 8, 0) = "10.0.0.0/24"
  # cidrsubnet("10.0.0.0/16", 8, 1) = "10.0.1.0/24"
  # cidrsubnet("10.0.0.0/16", 8, 2) = "10.0.2.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false  # NEVER auto-assign public IPs

  tags = {
    Name = "${var.project}-${var.environment}-public-${var.availability_zones[count.index]}"
    Tier = "public"
    # Required tag for AWS Load Balancer Controller (if using EKS)
    "kubernetes.io/role/elb" = "1"
  }
}

# Private application subnets — ECS tasks, Lambda, etc.
resource "aws_subnet" "private_app" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  # 10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project}-${var.environment}-private-app-${var.availability_zones[count.index]}"
    Tier = "private-app"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private data subnets — RDS, ElastiCache, DynamoDB VPC endpoints
resource "aws_subnet" "private_data" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  # 10.0.20.0/24, 10.0.21.0/24, 10.0.22.0/24
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project}-${var.environment}-private-data-${var.availability_zones[count.index]}"
    Tier = "private-data"
  }
}

# Monitoring subnet — isolated for Prometheus/Grafana
resource "aws_subnet" "monitoring" {
  count = 1  # Only need 1 AZ for monitoring (cost optimization, not stateless)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 30)
  # 10.0.30.0/24
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project}-${var.environment}-monitoring"
    Tier = "monitoring"
  }
}

# Internet Gateway — only for public subnet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-igw"
  }
}

# Elastic IPs for NAT Gateways (one per AZ for HA)
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project}-${var.environment}-nat-eip-${count.index}"
  }
}

# NAT Gateways — private subnets use these to reach the internet
# ONE PER AZ — this is critical for AZ independence
resource "aws_nat_gateway" "main" {
  count = var.az_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id  # NAT GW lives in PUBLIC subnet

  tags = {
    Name = "${var.project}-${var.environment}-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Public traffic goes to IGW
  }

  tags = {
    Name = "${var.project}-${var.environment}-public-rt"
  }
}

# One private route table PER AZ — so if one NAT GW fails, only that AZ is affected
resource "aws_route_table" "private_app" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id  # Goes through AZ-local NAT GW
  }

  tags = {
    Name = "${var.project}-${var.environment}-private-app-rt-${count.index}"
  }
}

# Route table associations
resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# VPC Flow Logs — log ALL traffic for security investigations
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"  # Log ACCEPT, REJECT, and all traffic
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name = "${var.project}-${var.environment}-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/flow-logs/${var.project}-${var.environment}"
  retention_in_days = 90  # 90 days for security investigation SLA

  tags = {
    Name = "${var.project}-${var.environment}-flow-logs"
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.project}-${var.environment}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# VPC Endpoints — keep traffic on AWS backbone, don't route through NAT GW
# This reduces cost AND improves security (no internet traversal)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"  # Free! Gateway endpoints don't cost per-hour

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private_app[*].id
  )

  tags = {
    Name = "${var.project}-${var.environment}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"  # Interface endpoints cost ~$7/month each
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true  # So code uses the same ECR hostname, no changes needed

  tags = {
    Name = "${var.project}-${var.environment}-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.environment}-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.environment}-secretsmanager-endpoint"
  }
}

# Security group for VPC endpoints — only allow traffic from app subnets
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.private_app : s.cidr_block]
    description = "HTTPS from private app subnets only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-vpc-endpoints-sg"
  }
}

data "aws_region" "current" {}
```

**Why VPC Endpoints matter for SREs:**
- ECR endpoint: Without it, ECS Fargate tasks pull container images through the NAT Gateway, which costs $0.045/GB out + NAT time. A deployment pulling a 2GB image × 100 deploys/day = real money. The endpoint routes traffic on AWS backbone for free (after the hourly endpoint cost).
- SecretsManager endpoint: Your app fetches DB passwords on startup through the endpoint, not the internet. If internet is down, your app still starts.

**🎯 INTERVIEW QUESTION:** "What happens to your ECS tasks if the NAT Gateway fails?"
**Answer:** Tasks in private subnets lose internet access. Existing connections may hang. Healthchecks from the ALB still work (internal). If you have VPC endpoints for ECR and SecretsManager, new task launches still work. Tasks can't reach external APIs (payment gateways, shipping, etc.). Mitigation: ALB health checks detect task failure, ASG scales in healthy AZ. For payments, implement circuit breakers with fallback to retry queues.

---

## 4. Security Hardening Layer

### 4.1 Security Groups — The Firewall at Every Resource

**Rule:** Every security group must have the minimum possible access. Every rule must have a description. Every rule must reference another security group (not a CIDR) where possible.

**Create `modules/security/security_groups.tf`:**

```hcl
# ALB Security Group — accepts internet traffic
resource "aws_security_group" "alb_public" {
  name        = "${var.project}-${var.environment}-alb-public-sg"
  description = "Public ALB: accepts HTTPS from internet, HTTP redirects to HTTPS"
  vpc_id      = var.vpc_id

  # HTTP — redirected to HTTPS by ALB listener rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet - redirected to HTTPS"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project}-${var.environment}-alb-public-sg"
  }
}

# ECS Tasks SG — only receives traffic from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-${var.environment}-ecs-tasks-sg"
  description = "ECS Fargate tasks: accepts traffic from public ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080  # Application port, not 80
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public.id]  # Reference SG, not CIDR
    description     = "App traffic from public ALB only"
  }

  # Prometheus scraping — from monitoring SG
  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
    description     = "Prometheus metrics scraping"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound for ECR pulls, Secrets Manager, external APIs"
  }

  tags = {
    Name = "${var.project}-${var.environment}-ecs-tasks-sg"
  }
}

# RDS Security Group — only from ECS tasks
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "RDS Aurora: accepts MySQL connections from ECS tasks only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
    description     = "MySQL from ECS tasks"
  }

  # Allow from monitoring for RDS exporter
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
    description     = "MySQL from Prometheus RDS exporter"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-rds-sg"
  }
}

# ElastiCache Security Group
resource "aws_security_group" "redis" {
  name        = "${var.project}-${var.environment}-redis-sg"
  description = "ElastiCache Redis: accepts connections from ECS tasks only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
    description     = "Redis from ECS tasks"
  }

  tags = {
    Name = "${var.project}-${var.environment}-redis-sg"
  }
}

# Monitoring Security Group — Prometheus, Grafana, Node Exporter
resource "aws_security_group" "monitoring" {
  name        = "${var.project}-${var.environment}-monitoring-sg"
  description = "Monitoring: Prometheus server and Grafana"
  vpc_id      = var.vpc_id

  # Grafana UI — accessible from VPN/bastion only, not from internet
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]  # Your VPN range, e.g., "10.100.0.0/16"
    description = "Grafana UI from VPN"
  }

  # Prometheus UI — internal access only
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Prometheus UI from within VPC"
  }

  # Node Exporter — Prometheus scrapes this from monitoring hosts
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Node Exporter metrics within VPC"
  }

  # SSH from bastion only (or SSM, which requires no SSH)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from bastion only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-monitoring-sg"
  }
}

# Bastion Host SG — SSH jump box (prefer SSM Session Manager instead)
resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.environment}-bastion-sg"
  description = "Bastion host: SSH from office IPs only"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks  # ["203.0.113.0/24"] — your office IPs
    description = "SSH from office network only"
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH to internal instances only"
  }

  tags = {
    Name = "${var.project}-${var.environment}-bastion-sg"
  }
}
```

### 4.2 AWS WAF Configuration

**Why WAF:** An e-commerce site without WAF is a sitting duck for SQL injection on checkout forms, XSS on product reviews, and bot attacks on inventory (scalpers). WAF sits in front of CloudFront and inspects every request before it hits your ALB.

```hcl
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project}-${var.environment}-waf"
  description = "WAF for e-commerce platform"
  scope       = "CLOUDFRONT"  # Must be us-east-1 for CloudFront WAFs
  
  default_action {
    allow {}  # Default allow; rules below block bad traffic
  }

  # Rule 1: AWS Managed Rules — Common Web Exploits
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}  # Use the rule group's own action (Count/Block)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # Override specific rules to Count instead of Block during initial rollout
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}  # Count first, analyze logs, then switch to Block
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: SQL Injection protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: Rate limiting — prevents brute force on /auth/login
  rule {
    name     = "RateLimitLoginEndpoint"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100   # Max 100 requests per 5 minutes per IP to /auth/login
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "/auth/login"
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LoginRateLimit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Block known bad IPs (malicious bot networks)
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationList"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: Bot Control — blocks scrapers, crawlers hitting /api/products en masse
  rule {
    name     = "AWSManagedRulesBotControlRuleSet"
    priority = 5

    override_action {
      count {}  # Start in count mode; analyze before blocking
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        
        managed_rule_group_configs {
          aws_managed_rules_bot_control_rule_set {
            inspection_level = "COMMON"  # TARGETED costs more, use for high-risk endpoints
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BotControl"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-waf"
  }
}

# WAF Logging to S3
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  # Redact sensitive fields from WAF logs (GDPR compliance)
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}
```

**🔴 SRE ALERT — WAF Count Mode Strategy:**
Always deploy WAF rules in Count mode first. Let traffic run for 48 hours, then query CloudWatch WAF logs:
```bash
aws logs filter-log-events \
  --log-group-name "aws-waf-logs-ecommerce" \
  --filter-pattern '{ $.action = "COUNT" }' \
  --query 'events[*].message' \
  | jq '.ruleGroupList[].nonTerminatingMatchingRules'
```
Review what legitimate traffic would be blocked, add exceptions, then switch to Block. A hasty Block deployment on an e-commerce checkout during Black Friday is a P0 incident.

### 4.3 GuardDuty, Security Hub, Macie

```hcl
# GuardDuty — ML-based threat detection
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true  # Detect malicious S3 access patterns
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true  # Automatically scan EC2 for malware when GuardDuty finds something
        }
      }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"  # Production: faster is better
}

# Security Hub — aggregate findings from all security services
resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "cis" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"
}

resource "aws_securityhub_standards_subscription" "pci_dss" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:us-east-1::standards/pci-dss/v/3.2.1"
  # PCI DSS is mandatory for any org that handles credit card data
}

# Macie — detect PII data in S3
resource "aws_macie2_account" "main" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

resource "aws_macie2_classification_job" "s3_scan" {
  job_type = "SCHEDULED"
  name     = "ecommerce-pii-scan"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.app_data.bucket]
    }
  }

  schedule_frequency {
    weekly_schedule = "MONDAY"  # Scan every Monday
  }
}
```

---

## 5. IAM Roles, Policies & Permission Boundaries

### 5.1 ECS Task Execution Role

This role is used by ECS itself (the control plane) to pull images from ECR and write logs to CloudWatch. **Not by your application code.**

```hcl
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-${var.environment}-ecs-task-execution-role"

  # Trust policy: only ECS tasks can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      # Condition to prevent confused deputy attacks
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  # Boundary policy — even if someone expands this role's permissions,
  # it can never go beyond what this boundary allows
  permissions_boundary = aws_iam_policy.ecs_boundary.arn

  tags = {
    Name    = "${var.project}-${var.environment}-ecs-task-execution-role"
    Purpose = "ECS control plane operations (image pull, log write)"
  }
}

# Attach AWS managed policy for standard ECS execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional: allow reading secrets for injection into container env vars
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "secrets-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project}/${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.secrets.arn  # KMS key for secrets encryption
        ]
      }
    ]
  })
}
```

### 5.2 ECS Task Role (Application Role)

This role is what **your application code** uses to call AWS APIs. Different from execution role.

```hcl
resource "aws_iam_role" "ecs_task_api_service" {
  name = "${var.project}-${var.environment}-api-service-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
        }
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  permissions_boundary = aws_iam_policy.ecs_boundary.arn
}

resource "aws_iam_role_policy" "api_service_policy" {
  name = "api-service-permissions"
  role = aws_iam_role.ecs_task_api_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # DynamoDB access — cart and sessions
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.cart.arn,
          aws_dynamodb_table.sessions.arn,
          "${aws_dynamodb_table.cart.arn}/index/*",
          "${aws_dynamodb_table.sessions.arn}/index/*"
        ]
      },
      # SQS — publish order events
      {
        Sid    = "SQSPublish"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.order_events.arn
        ]
      },
      # S3 — product images and order receipts
      {
        Sid    = "S3ProductImages"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.product_assets.arn}/*"
        ]
        Condition = {
          # Only allow PUT of images, not code or executables
          StringNotEquals = {
            "s3:prefix" = ["scripts/", "terraform/", "*.sh", "*.py"]
          }
        }
      },
      # Deny everything else
      {
        Sid    = "DenyAllOtherActions"
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "account:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Permission Boundary — hard ceiling on what any ECS role can do
resource "aws_iam_policy" "ecs_boundary" {
  name        = "${var.project}-${var.environment}-ecs-permission-boundary"
  description = "Hard boundary for all ECS task roles — cannot escalate beyond this"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowedServices"
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "sqs:*",
          "sns:*",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "logs:*",
          "cloudwatch:PutMetricData",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyPrivilegedActions"
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "account:*",
          "sts:AssumeRole"  # ECS tasks cannot assume other roles
        ]
        Resource = "*"
      }
    ]
  })
}
```

**🎯 INTERVIEW QUESTION:** "What is the difference between an ECS Task Execution Role and an ECS Task Role?"

**Answer:** The **Task Execution Role** is used by the ECS agent (AWS infrastructure) to perform setup work: pulling container images from ECR, writing startup logs to CloudWatch, fetching secrets from Secrets Manager to inject as environment variables. Your application code never uses this role. The **Task Role** is what your application code inside the container uses when it calls AWS SDK. For example, when your order service calls `dynamodb.putItem()`, it authenticates using the Task Role's credentials — not the execution role. They should be separate because the execution role needs ECR/CloudWatch/Secrets permissions, while the task role needs DynamoDB/SQS/S3 permissions. Mixing them violates least privilege.

---

## 6. E-Commerce Application Infrastructure

### 6.1 ECS Cluster & Services

```hcl
# ECS Cluster with Container Insights (sends metrics to CloudWatch)
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"  # Costs extra but gives CPU/Memory/Network per container
  }

  tags = {
    Name = "${var.project}-${var.environment}-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2  # Always keep 2 tasks on regular Fargate (not Spot)
  }
}

# ECS Service: API Service
resource "aws_ecs_task_definition" "api_service" {
  family                   = "${var.project}-${var.environment}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"       # Required for Fargate; each task gets its own ENI
  cpu                      = 1024           # 1 vCPU = 1024 units
  memory                   = 2048           # 2 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_api_service.arn

  # Ephemeral storage — default is 20GB, increase for log-heavy apps
  ephemeral_storage {
    size_in_gib = 30
  }

  container_definitions = jsonencode([
    {
      name      = "api-service"
      image     = "${aws_ecr_repository.api_service.repository_url}:${var.app_version}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
          name          = "api-port"  # Name required for service connect
        }
      ]

      # Environment variables — non-sensitive config
      environment = [
        { name = "APP_ENV",              value = var.environment },
        { name = "APP_PORT",             value = "8080" },
        { name = "DB_HOST",              value = aws_rds_cluster.main.endpoint },
        { name = "DB_READ_HOST",         value = aws_rds_cluster.main.reader_endpoint },
        { name = "REDIS_HOST",           value = aws_elasticache_replication_group.main.primary_endpoint_address },
        { name = "DYNAMODB_REGION",      value = var.aws_region },
        { name = "SQS_ORDER_QUEUE_URL",  value = aws_sqs_queue.order_events.url },
        { name = "LOG_LEVEL",            value = "info" },
        { name = "METRICS_PORT",         value = "9090" }  # Prometheus metrics endpoint
      ]

      # Secrets — fetched from Secrets Manager at task launch; never in plaintext
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.jwt_secret.arn}:secret::"
        },
        {
          name      = "STRIPE_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.stripe_key.arn}:key::"
        }
      ]

      # CloudWatch log configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project}/${var.environment}/api-service"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
          # Mode: blocking (drop logs if buffer full) vs non-blocking
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "25m"  # Don't let logging crash the app
        }
      }

      # Health check — ECS uses this to restart unhealthy tasks
      healthCheck = {
        command     = ["CMD-SHELL", "curl -sf http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60  # Grace period for JVM warmup, DB connection pool init
      }

      # Resource limits — prevent a runaway task from starving other containers
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]

      # Read-only root filesystem — security hardening
      readonlyRootFilesystem = true

      # Mount writable temp dir
      mountPoints = [
        {
          containerPath = "/tmp"
          sourceVolume  = "tmp-volume"
          readOnly      = false
        }
      ]

      # Linux capabilities — drop all, add only what's needed
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []  # Add specific caps only if application requires
        }
        initProcessEnabled = true  # Proper PID 1 signal handling, prevents zombie processes
      }
    }
  ])

  volume {
    name = "tmp-volume"
  }

  tags = {
    Name = "${var.project}-${var.environment}-api-task"
  }
}

resource "aws_ecs_service" "api_service" {
  name            = "${var.project}-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_service.arn
  desired_count   = 3  # Minimum 3 across 3 AZs for HA

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 2  # 2:1 ratio — 2 on Fargate, 1 on Spot
    base              = 2
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1  # Spot for extra scale-out tasks (cost saving)
  }

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false  # NEVER assign public IP to app tasks
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_service.arn
    container_name   = "api-service"
    container_port   = 8080
  }

  # Deployment configuration — rolling update strategy
  deployment_minimum_healthy_percent = 100  # Never go below 100% capacity during deploy
  deployment_maximum_percent         = 200  # Double capacity during rollout

  deployment_circuit_breaker {
    enable   = true  # Automatically rollback if deploy fails
    rollback = true
  }

  # ECS Exec — allows `aws ecs execute-command` for live debugging
  enable_execute_command = true  # Only in non-production environments ideally

  # Spread tasks across AZs for resilience
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # Service Connect — ECS service discovery and load balancing
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn

    service {
      port_name      = "api-port"
      discovery_name = "api-service"
      client_alias {
        port     = 8080
        dns_name = "api-service"
      }
    }
  }

  # Lifecycle: ignore task definition changes (managed by CI/CD)
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [aws_lb_listener.https]

  tags = {
    Name = "${var.project}-${var.environment}-api-service"
  }
}

# Auto Scaling for ECS Service
resource "aws_appautoscaling_target" "api_service" {
  max_capacity       = 20  # Maximum tasks
  min_capacity       = 3   # Minimum tasks (HA — 1 per AZ)
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Scale based on CPU
resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "${var.project}-${var.environment}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api_service.resource_id
  scalable_dimension = aws_appautoscaling_target.api_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60.0   # Scale out when CPU > 60%
    scale_in_cooldown  = 300    # Wait 5 minutes before scaling in
    scale_out_cooldown = 60     # Scale out quickly (user-facing service)
  }
}

# Scale based on ALB request count per target
resource "aws_appautoscaling_policy" "api_requests" {
  name               = "${var.project}-${var.environment}-api-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api_service.resource_id
  scalable_dimension = aws_appautoscaling_target.api_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.public.arn_suffix}/${aws_lb_target_group.api_service.arn_suffix}"
    }
    target_value       = 500   # Scale when > 500 req/minute per task
    scale_in_cooldown  = 300
    scale_out_cooldown = 30    # Very aggressive scale-out for checkout
  }
}
```

---

## 7. Database Layer

### 7.1 RDS Aurora MySQL — Multi-AZ Cluster

```hcl
resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project}-${var.environment}-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"  # Pin to specific patch version
  
  # Credentials — never hardcoded, always from Secrets Manager
  database_name   = "ecommerce"
  master_username = "ecommerce_admin"
  manage_master_user_password = true  # AWS manages rotation automatically

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Backup configuration
  backup_retention_period      = 35     # 35 days (beyond monthly reporting cycles)
  preferred_backup_window      = "03:00-04:00"  # Low traffic window (UTC)
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  # Deletion protection — prevents accidental destroy
  deletion_protection = true  # Must be false before destroy in emergency

  # Point-in-time recovery
  enable_global_write_forwarding = false
  
  # Encryption at rest
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn  # Customer managed key (CMK)

  # Enhanced monitoring and logging
  enabled_cloudwatch_logs_exports = [
    "audit",       # Who queried what
    "error",       # MySQL errors
    "general",     # All queries (verbose — use for debugging, not production long-term)
    "slowquery"    # Queries > long_query_time
  ]

  # Performance Insights — 1 year retention for capacity planning
  performance_insights_enabled          = true
  performance_insights_retention_period = 365
  performance_insights_kms_key_id       = aws_kms_key.rds.arn

  # Serverless V2 auto-scaling — scales 0.5 to 32 ACUs
  serverlessv2_scaling_configuration {
    min_capacity = 0.5   # 0.5 ACU ≈ 0.5 vCPU + 1GB RAM — minimum
    max_capacity = 16    # 16 ACU ≈ 16 vCPU + 32GB RAM — maximum
  }

  # IAM database authentication — allows ECS tasks to auth without passwords
  iam_database_authentication_enabled = true

  tags = {
    Name = "${var.project}-${var.environment}-aurora-cluster"
  }
}

# Writer instance
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.project}-${var.environment}-aurora-writer"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverlessv2"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  monitoring_interval = 60  # Enhanced monitoring every 60 seconds
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled = true

  tags = {
    Name = "${var.project}-${var.environment}-aurora-writer"
    Role = "writer"
  }
}

# Reader instances — in different AZs for reads and HA failover
resource "aws_rds_cluster_instance" "reader" {
  count = 2  # 2 readers = writer can fail over to either

  identifier         = "${var.project}-${var.environment}-aurora-reader-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverlessv2"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  
  # Promotion tier — reader 0 is promoted to writer on failover first
  promotion_tier = count.index

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = {
    Name           = "${var.project}-${var.environment}-aurora-reader-${count.index}"
    Role           = "reader"
    PromotionTier  = tostring(count.index)
  }
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids  = var.private_data_subnet_ids  # Data subnets, NOT app subnets

  tags = {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  }
}

# KMS key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS Aurora encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true  # Rotate annually — compliance requirement

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.environment}-rds-kms-key"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project}-${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}
```

### 7.2 ElastiCache Redis — Session Store & Cache

```hcl
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project}-${var.environment}-redis"
  description          = "Redis cluster for session store and caching"

  node_type               = "cache.r7g.large"  # Memory optimized, Graviton3 for cost
  port                    = 6379
  parameter_group_name    = aws_elasticache_parameter_group.redis7.name
  
  num_cache_clusters      = 3    # 1 primary + 2 replicas (3 AZs)
  automatic_failover_enabled = true
  multi_az_enabled        = true

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true  # TLS in transit
  kms_key_id                 = aws_kms_key.redis.arn

  # Auth — Redis AUTH token (password)
  auth_token             = random_password.redis_auth.result
  auth_token_update_strategy = "ROTATE"  # Supports seamless token rotation

  # Snapshot
  snapshot_retention_limit = 7  # 7 days of daily snapshots
  snapshot_window          = "03:30-04:30"

  # Maintenance
  maintenance_window = "sun:05:00-sun:06:00"

  # Log delivery
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  tags = {
    Name = "${var.project}-${var.environment}-redis"
  }
}

resource "aws_elasticache_parameter_group" "redis7" {
  name   = "${var.project}-${var.environment}-redis7"
  family = "redis7"

  # Key performance and security parameters
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"  # Evict least recently used keys when memory full
    # For session store: volatile-lru (only evict keys with TTL)
    # For pure cache: allkeys-lru
  }

  parameter {
    name  = "slowlog-log-slower-than"
    value = "10000"  # Log commands slower than 10ms (10000 microseconds)
  }

  parameter {
    name  = "latency-tracking"
    value = "yes"
  }
}
```

---

## 8. Monitoring Stack

### 8.1 Prometheus Server Setup

**Go to:** AWS Console → EC2 → Launch Instance

**OR in Terraform (`environments/production/monitoring.tf`):**

```hcl
resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.large"  # 2 vCPU, 8GB RAM — handles 100+ scrape targets

  subnet_id                   = var.monitoring_subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  iam_instance_profile        = aws_iam_instance_profile.prometheus.name
  associate_public_ip_address = false
  monitoring                  = true  # Enable detailed CloudWatch monitoring

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100   # Prometheus TSDB storage
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = aws_kms_key.ebs.arn
    delete_on_termination = false  # CRITICAL: don't lose metrics on instance replace
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"    # IMDSv2 required — prevents SSRF attacks
    http_put_response_hop_limit = 1             # 1 = container can't reach IMDS
  }

  user_data = base64encode(templatefile("${path.module}/scripts/prometheus-setup.sh", {
    environment = var.environment
    region      = var.aws_region
  }))

  tags = {
    Name = "${var.project}-${var.environment}-prometheus"
    Role = "monitoring"
  }
}
```

**Create `scripts/prometheus-setup.sh`:**

```bash
#!/bin/bash
# Prometheus Server Setup Script
# Run as: user-data on EC2 instance
# Outcome: Prometheus running as systemd service, scraping all targets

set -euo pipefail
exec > >(tee /var/log/prometheus-setup.log) 2>&1
echo "=== Prometheus Setup Started: $(date) ==="

# ─── System Updates ──────────────────────────────────────────────────
dnf update -y
dnf install -y wget tar curl jq aws-cli

# ─── Create prometheus user ─────────────────────────────────────────
# Why: Never run Prometheus as root. Dedicated system user with no shell access.
useradd --system --no-create-home --shell /bin/false prometheus

# ─── Create directories ──────────────────────────────────────────────
mkdir -p /etc/prometheus        # Config files
mkdir -p /var/lib/prometheus    # TSDB data storage
chown -R prometheus:prometheus /var/lib/prometheus

# ─── Download Prometheus ─────────────────────────────────────────────
PROMETHEUS_VERSION="2.50.1"
cd /tmp
wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

# Verify checksum before extracting (supply chain security)
# In production, download and verify the SHA256SUMS file
tar xzf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
cd "prometheus-${PROMETHEUS_VERSION}.linux-amd64"

# Install binaries
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/
cp -r consoles /etc/prometheus/
cp -r console_libraries /etc/prometheus/

# Verify installation
prometheus --version

# ─── Prometheus Configuration ────────────────────────────────────────
cat > /etc/prometheus/prometheus.yml << 'PROMCONFIG'
global:
  scrape_interval:     15s     # Scrape every 15 seconds
  evaluation_interval: 15s     # Evaluate alerting rules every 15s
  scrape_timeout:      10s     # Timeout after 10s (must be <= scrape_interval)

  external_labels:
    cluster:     'production'  # All metrics tagged with cluster name
    region:      '${region}'
    environment: '${environment}'

# Alertmanager integration
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']  # Alertmanager on same host for simplicity

# Load alert rules
rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:

  # ── Prometheus self-monitoring ──────────────────────────────────
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    metrics_path: '/metrics'

  # ── Node Exporter — all EC2 instances ──────────────────────────
  # Uses AWS EC2 Service Discovery — auto-discovers EC2 instances by tag
  - job_name: 'node-exporter'
    ec2_sd_configs:
      - region: ${region}
        port: 9100
        filters:
          - name: "tag:Environment"
            values: ["${environment}"]
          - name: "tag:NodeExporter"
            values: ["enabled"]
          - name: "instance-state-name"
            values: ["running"]
    relabel_configs:
      # Use EC2 instance name tag as instance label
      - source_labels: [__meta_ec2_tag_Name]
        target_label: instance
      # Add AZ label for AZ-level dashboards
      - source_labels: [__meta_ec2_availability_zone]
        target_label: availability_zone
      # Add instance type for capacity planning
      - source_labels: [__meta_ec2_instance_type]
        target_label: instance_type

  # ── ECS Fargate Tasks ────────────────────────────────────────────
  # ECS tasks expose metrics on port 9090 at /metrics
  - job_name: 'ecs-tasks'
    # ECS doesn't have Prometheus SD natively — use file_sd with a sidecar updater
    file_sd_configs:
      - files:
          - '/etc/prometheus/sd/ecs-targets.json'
        refresh_interval: 30s  # Re-read file every 30s for new task discovery

  # ── RDS — via CloudWatch exporter ───────────────────────────────
  - job_name: 'rds'
    static_configs:
      - targets: ['localhost:9106']  # CloudWatch exporter local port
    metrics_path: '/metrics'

  # ── Redis — via Redis exporter ───────────────────────────────────
  - job_name: 'redis'
    static_configs:
      - targets: ['localhost:9121']  # Redis exporter local port

  # ── ALB — via CloudWatch exporter ───────────────────────────────
  - job_name: 'alb'
    static_configs:
      - targets: ['localhost:9106']
    params:
      region: ['${region}']
    metrics_path: '/metrics'

PROMCONFIG

# Validate config before starting
promtool check config /etc/prometheus/prometheus.yml

# ─── Alerting Rules ──────────────────────────────────────────────────
mkdir -p /etc/prometheus/rules

cat > /etc/prometheus/rules/ecommerce.yml << 'ALERTRULES'
groups:
  - name: ecommerce-critical
    interval: 15s  # Check every 15s for critical alerts
    rules:

      # API Service Down
      - alert: APIServiceDown
        expr: up{job="ecs-tasks", service="api-service"} == 0
        for: 1m   # Must be down for 1 minute before alerting (avoids flapping)
        labels:
          severity: critical
          team: sre
        annotations:
          summary: "API Service is DOWN"
          description: "API service {{ $labels.instance }} has been unreachable for 1 minute."
          runbook: "https://runbooks.internal/api-service-down"
          dashboard: "https://grafana.internal/d/api-service"

      # High Error Rate
      - alert: HighAPIErrorRate
        expr: |
          sum(rate(http_requests_total{job="ecs-tasks", status_code=~"5.."}[5m]))
          /
          sum(rate(http_requests_total{job="ecs-tasks"}[5m]))
          > 0.01
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "API error rate > 1%"
          description: "Error rate is {{ $value | humanizePercentage }} over last 5 minutes."

      # High Latency
      - alert: HighAPILatencyP99
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket{job="ecs-tasks"}[5m])) by (le)
          ) > 2.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "API P99 latency > 2s"
          description: "P99 latency is {{ $value }}s"

      # Checkout Service — Extra sensitive (revenue impact)
      - alert: CheckoutHighLatency
        expr: |
          histogram_quantile(0.95,
            rate(http_request_duration_seconds_bucket{service="checkout", path="/checkout"}[5m])
          ) > 3.0
        for: 2m
        labels:
          severity: critical
          revenue_impact: "true"
        annotations:
          summary: "Checkout P95 latency > 3s — revenue impact"

      # Database Connection Exhaustion
      - alert: RDSConnectionsHigh
        expr: |
          aws_rds_database_connections_average{dbcluster_identifier="production-aurora"}
          > 800
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "RDS connections > 800"
          description: "Current connections: {{ $value }}. Max: 1000. Risk of connection exhaustion."

      # Redis Memory High
      - alert: RedisMemoryHigh
        expr: |
          redis_memory_used_bytes / redis_memory_max_bytes > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage > 85%"

      # SQS Queue Depth — order processing backup
      - alert: OrderQueueDepthHigh
        expr: |
          aws_sqs_approximate_number_of_messages_visible_maximum{queue_name="order-events"} > 1000
        for: 5m
        labels:
          severity: critical
          revenue_impact: "true"
        annotations:
          summary: "Order queue depth > 1000 — orders not processing"

      # Disk space on Prometheus server
      - alert: PrometheusDiskSpaceLow
        expr: |
          (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.15
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Prometheus disk < 15% free"

ALERTRULES

promtool check rules /etc/prometheus/rules/ecommerce.yml

# ─── Systemd Service ─────────────────────────────────────────────────
cat > /etc/systemd/system/prometheus.service << 'SYSTEMD'
[Unit]
Description=Prometheus Monitoring Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --storage.tsdb.retention.time=90d \
  --storage.tsdb.retention.size=80GB \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=http://prometheus.internal:9090 \
  --web.enable-lifecycle \
  --web.enable-admin-api

# Restart on crash, not on clean stop
Restart=on-failure
RestartSec=5s

# Security hardening for the systemd unit
NoNewPrivileges=yes
ProtectSystem=full
ProtectHome=yes
PrivateTmp=yes
CapabilityBoundingSet=

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl is-active prometheus && echo "✅ Prometheus is running"

echo "=== Prometheus Setup Complete: $(date) ==="
```

### 8.2 Node Exporter Setup

**Why Node Exporter:** Prometheus collects application metrics, but you need OS-level metrics — CPU, memory, disk I/O, network, file descriptors, load average. Node Exporter exposes all of this. **Every EC2 instance must run Node Exporter.**

```bash
# ── Add to your EC2 user-data scripts or Ansible playbook ──

NODE_EXPORTER_VERSION="1.7.0"
cd /tmp
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
useradd --system --no-create-home --shell /bin/false node_exporter

cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
  --collector.systemd \
  --collector.processes \
  --collector.diskstats \
  --collector.filesystem \
  --collector.meminfo \
  --collector.netstat \
  --collector.cpu \
  --web.listen-address=0.0.0.0:9100 \
  --web.telemetry-path=/metrics
Restart=on-failure
NoNewPrivileges=yes
ProtectSystem=full
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Add EC2 tags so Prometheus SD discovers this instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
aws ec2 create-tags \
  --resources "$INSTANCE_ID" \
  --tags Key=NodeExporter,Value=enabled \
  --region "$REGION"
```

### 8.3 Grafana Setup

```bash
# ── Grafana installation on a separate EC2 or same monitoring host ──

GRAFANA_VERSION="10.4.0"

# Add Grafana YUM repository
cat > /etc/yum.repos.d/grafana.repo << 'EOF'
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

dnf install -y grafana

# ── Configure Grafana ─────────────────────────────────────────────────
cat > /etc/grafana/grafana.ini << 'EOF'
[server]
domain = grafana.internal.ecommerce.com
root_url = https://%(domain)s/
serve_from_sub_path = false

[security]
admin_user = admin
# admin_password set via environment variable: GF_SECURITY_ADMIN_PASSWORD
secret_key = ${grafana_secret_key}      # Random 32-char string
cookie_secure = true
cookie_samesite = strict
strict_transport_security = true
x_content_type_options = true
x_xss_protection = true
content_security_policy = true

[users]
allow_sign_up = false    # No self-registration
auto_assign_org = true
auto_assign_org_role = Viewer  # Default role is Viewer, not Admin

[auth]
disable_login_form = false
oauth_auto_login = false

[auth.github]
enabled = true           # SSO via GitHub for team access
allow_sign_up = true
client_id = ${github_client_id}
client_secret = ${github_client_secret}
scopes = user:email,read:org
auth_url = https://github.com/login/oauth/authorize
token_url = https://github.com/login/oauth/access_token
api_url = https://api.github.com/user
allowed_organizations = your-org-name  # Only your GitHub org members

[smtp]
enabled = true
host = email-smtp.us-east-1.amazonaws.com:587
user = ${ses_smtp_user}
password = ${ses_smtp_password}
from_address = grafana@ecommerce.com
from_name = Grafana Alerts

[alerting]
enabled = true

[unified_alerting]
enabled = true

[database]
type = postgres
host = ${rds_endpoint}:5432
name = grafana
user = grafana
password = ${grafana_db_password}
ssl_mode = require

[log]
mode = console file
level = info
EOF

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

# ── Provision Prometheus datasource automatically ──────────────────
mkdir -p /etc/grafana/provisioning/datasources

cat > /etc/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    access: proxy
    isDefault: true
    editable: false
    jsonData:
      httpMethod: POST
      timeInterval: "15s"
      queryTimeout: "30s"
      prometheusType: Prometheus
      prometheusVersion: "2.50.0"
EOF

# ── Provision Dashboards ───────────────────────────────────────────
mkdir -p /etc/grafana/provisioning/dashboards

cat > /etc/grafana/provisioning/dashboards/ecommerce.yml << 'EOF'
apiVersion: 1
providers:
  - name: 'ecommerce-dashboards'
    orgId: 1
    folder: 'E-Commerce'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Dashboard JSON files go in /var/lib/grafana/dashboards/
# Import from grafana.com: Dashboard ID 1860 (Node Exporter Full)
# Import from grafana.com: Dashboard ID 763 (Redis)
# Import from grafana.com: Dashboard ID 14057 (ECS)
```

**Key Grafana Dashboards to Build:**

1. **E-Commerce Overview Dashboard** — Orders/min, Revenue/min, Error Rate, P99 Latency
2. **Infrastructure Dashboard** — CPU, Memory, Disk per host
3. **Database Dashboard** — RDS connections, query latency, replication lag
4. **Redis Dashboard** — Hit rate, memory, evictions
5. **SRE SLO Dashboard** — Availability %, Error budget burn rate

---

## 9. GitHub Repository & GitHub Actions CI/CD

### 9.1 Repository Structure

```bash
# Your e-commerce services repo
ecommerce-services/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # On PR: test, lint, build, security scan
│   │   ├── deploy-staging.yml        # On merge to main: deploy to staging
│   │   ├── deploy-production.yml     # On git tag: deploy to production
│   │   ├── terraform-plan.yml        # Infra PRs: show terraform plan
│   │   └── prometheus-rules.yml      # Update alerting rules on change
│   └── CODEOWNERS                    # SRE team owns infra and monitoring files
├── services/
│   ├── api-service/
│   │   ├── Dockerfile
│   │   ├── src/
│   │   └── package.json
│   ├── checkout-service/
│   └── order-service/
├── infrastructure/                   # Symlink to ecommerce-infra repo (or submodule)
└── monitoring/
    ├── prometheus/
    │   ├── rules/                    # Alerting rules (synced to Prometheus server)
    │   └── prometheus.yml
    └── grafana/
        └── dashboards/              # Dashboard JSON files
```

### 9.2 GitHub Actions — CI Pipeline

**Create `.github/workflows/ci.yml`:**

```yaml
name: CI — Build, Test, Security Scan

on:
  pull_request:
    branches: [main, staging]
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com

jobs:
  # ─── Lint & Unit Tests ─────────────────────────────────────────────
  test:
    name: Test — ${{ matrix.service }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api-service, checkout-service, order-service]
      fail-fast: false   # Don't cancel other services if one fails

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: services/${{ matrix.service }}/package-lock.json

      - name: Install dependencies
        working-directory: services/${{ matrix.service }}
        run: npm ci  # ci is faster than install and uses lockfile

      - name: Run linter
        working-directory: services/${{ matrix.service }}
        run: npm run lint

      - name: Run unit tests with coverage
        working-directory: services/${{ matrix.service }}
        run: npm run test:coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: services/${{ matrix.service }}/coverage/lcov.info
          flags: ${{ matrix.service }}

  # ─── Security Scanning ─────────────────────────────────────────────
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: test

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # Dependency vulnerability scanning
      - name: Run npm audit
        run: |
          for service in api-service checkout-service order-service; do
            echo "=== Scanning $service ==="
            cd services/$service
            npm audit --audit-level=high  # Fail on HIGH or CRITICAL vulnerabilities
            cd ../..
          done

      # SAST — Static Application Security Testing
      - name: Run Semgrep SAST
        uses: semgrep/semgrep-action@v1
        with:
          config: |
            p/javascript
            p/nodejs
            p/owasp-top-ten
            p/sql-injection
          generateSarif: "1"

      - name: Upload SARIF to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: semgrep.sarif

      # Secret scanning — ensure no API keys in code
      - name: Detect secrets with Trufflehog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          extra_args: --debug --only-verified

  # ─── Docker Build & Push to ECR ────────────────────────────────────
  build:
    name: Build & Push — ${{ matrix.service }}
    runs-on: ubuntu-latest
    needs: [test, security-scan]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    permissions:
      id-token: write    # Required for OIDC authentication with AWS
      contents: read

    strategy:
      matrix:
        service: [api-service, checkout-service, order-service]

    outputs:
      image-tag: ${{ steps.meta.outputs.version }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # OIDC authentication — no long-lived AWS access keys in GitHub Secrets
      # This is the CORRECT way to authenticate GitHub Actions with AWS
      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsECRRole
          aws-region: ${{ env.AWS_REGION }}
          # Session duration: 15 minutes is enough for a build and push
          role-session-name: github-actions-build-${{ github.run_id }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Extract metadata for Docker image
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.ECR_REGISTRY }}/ecommerce-${{ matrix.service }}
          tags: |
            type=sha,prefix=sha-,format=short
            type=ref,event=branch
            type=semver,pattern={{version}}
            # Always tag with git SHA for traceability
            type=raw,value=${{ github.sha }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: services/${{ matrix.service }}
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          # Build args — bake metadata into the image
          build-args: |
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            GIT_COMMIT=${{ github.sha }}
            GIT_BRANCH=${{ github.ref_name }}
            VERSION=${{ steps.meta.outputs.version }}
          # Cache layers in ECR — drastically speeds up builds
          cache-from: type=registry,ref=${{ env.ECR_REGISTRY }}/ecommerce-${{ matrix.service }}:buildcache
          cache-to: type=registry,ref=${{ env.ECR_REGISTRY }}/ecommerce-${{ matrix.service }}:buildcache,mode=max
          provenance: true    # SLSA provenance attestation
          sbom: true          # Software Bill of Materials

      # Container vulnerability scan AFTER build
      - name: Run Trivy container scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.ECR_REGISTRY }}/ecommerce-${{ matrix.service }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail the build if CRITICAL/HIGH CVEs found

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  # ─── Deploy to Staging ─────────────────────────────────────────────
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: staging
      url: https://staging.ecommerce.com

    permissions:
      id-token: write
      contents: read
      deployments: write

    steps:
      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsDeployRole
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy api-service to ECS Staging
        run: |
          IMAGE="${{ env.ECR_REGISTRY }}/ecommerce-api-service:${{ github.sha }}"
          
          # Get current task definition
          TASK_DEF=$(aws ecs describe-task-definition \
            --task-definition ecommerce-staging-api \
            --query 'taskDefinition' \
            --output json)
          
          # Update image in task definition
          NEW_TASK_DEF=$(echo $TASK_DEF | jq --arg IMAGE "$IMAGE" '
            .containerDefinitions[0].image = $IMAGE |
            del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)
          ')
          
          # Register new task definition revision
          NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
            --cli-input-json "$NEW_TASK_DEF" \
            --query 'taskDefinition.taskDefinitionArn' \
            --output text)
          
          echo "New task definition: $NEW_TASK_DEF_ARN"
          
          # Update ECS service to use new task definition
          aws ecs update-service \
            --cluster ecommerce-staging \
            --service ecommerce-staging-api \
            --task-definition "$NEW_TASK_DEF_ARN" \
            --force-new-deployment
          
          # Wait for deployment to stabilize (max 10 minutes)
          aws ecs wait services-stable \
            --cluster ecommerce-staging \
            --services ecommerce-staging-api
          
          echo "✅ Staging deployment complete"

      # Smoke tests against staging
      - name: Run smoke tests
        run: |
          BASE_URL="https://staging.ecommerce.com"
          
          # Health check
          HTTP_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" "$BASE_URL/health")
          if [ "$HTTP_STATUS" != "200" ]; then
            echo "❌ Health check failed: $HTTP_STATUS"
            exit 1
          fi
          
          # API responds
          HTTP_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" "$BASE_URL/api/products?limit=1")
          if [ "$HTTP_STATUS" != "200" ]; then
            echo "❌ Products API failed: $HTTP_STATUS"
            exit 1
          fi
          
          echo "✅ Smoke tests passed"

  # ─── Production Deployment (manual approval required) ──────────────
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:
      name: production       # GitHub environment requires manual approval
      url: https://ecommerce.com

    permissions:
      id-token: write
      contents: read

    steps:
      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsDeployRole
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to Production ECS (Blue/Green)
        run: |
          IMAGE="${{ env.ECR_REGISTRY }}/ecommerce-api-service:${{ github.sha }}"
          
          # Same process as staging but to production cluster
          TASK_DEF=$(aws ecs describe-task-definition \
            --task-definition ecommerce-production-api \
            --query 'taskDefinition' \
            --output json)
          
          NEW_TASK_DEF=$(echo $TASK_DEF | jq --arg IMAGE "$IMAGE" '
            .containerDefinitions[0].image = $IMAGE |
            del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)
          ')
          
          NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
            --cli-input-json "$NEW_TASK_DEF" \
            --query 'taskDefinition.taskDefinitionArn' \
            --output text)
          
          aws ecs update-service \
            --cluster ecommerce-production \
            --service ecommerce-production-api \
            --task-definition "$NEW_TASK_DEF_ARN" \
            --deployment-configuration "minimumHealthyPercent=100,maximumPercent=200"
          
          aws ecs wait services-stable \
            --cluster ecommerce-production \
            --services ecommerce-production-api \
            --timeout 600  # 10 minute timeout

      # Post-deploy: verify key metrics haven't degraded
      - name: Post-deploy health verification
        run: |
          echo "Waiting 2 minutes for metrics to stabilize..."
          sleep 120
          
          # Query Prometheus for error rate
          ERROR_RATE=$(curl -sf "http://prometheus.internal:9090/api/v1/query" \
            --data-urlencode 'query=sum(rate(http_requests_total{status_code=~"5.."}[2m])) / sum(rate(http_requests_total[2m]))' \
            | jq -r '.data.result[0].value[1]')
          
          echo "Current error rate: $ERROR_RATE"
          
          # Fail if error rate > 1%
          if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
            echo "❌ Error rate spike detected after deploy: $ERROR_RATE"
            echo "Initiating automatic rollback..."
            
            PREV_TASK_DEF=$(aws ecs describe-services \
              --cluster ecommerce-production \
              --services ecommerce-production-api \
              --query 'services[0].deployments[?status==`PRIMARY`].taskDefinition' \
              --output text | head -1)
            
            aws ecs update-service \
              --cluster ecommerce-production \
              --service ecommerce-production-api \
              --task-definition "$PREV_TASK_DEF"
            
            exit 1
          fi
          
          echo "✅ Production deployment verified"

  # ─── Terraform Plan (on infra PRs) ────────────────────────────────
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.labels.*.name, 'infrastructure')

    permissions:
      id-token: write
      contents: read
      pull-requests: write

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsTerraformRole
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.7.5"

      - name: Terraform Init
        run: |
          cd infrastructure/environments/production
          terraform init -reconfigure

      - name: Terraform Format Check
        run: |
          cd infrastructure
          terraform fmt -check -recursive  # Fail if files aren't formatted

      - name: Terraform Validate
        run: |
          cd infrastructure/environments/production
          terraform validate

      - name: Terraform Plan
        id: plan
        run: |
          cd infrastructure/environments/production
          terraform plan -out=tfplan -no-color 2>&1 | tee plan-output.txt
          echo "exitcode=$?" >> $GITHUB_OUTPUT
        continue-on-error: true

      # Post plan as PR comment so engineers can review before approving
      - name: Comment PR with Terraform Plan
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('infrastructure/environments/production/plan-output.txt', 'utf8');
            const truncated = plan.length > 60000 ? plan.substring(0, 60000) + '\n... (truncated)' : plan;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🏗️ Terraform Plan Results\n\n<details><summary>Show Plan</summary>\n\n\`\`\`hcl\n${truncated}\n\`\`\`\n</details>\n\n${process.env.PLAN_EXIT_CODE === '0' ? '✅ Plan successful' : '❌ Plan failed'}`
            })
```

### 9.3 GitHub OIDC Trust — AWS Role

This allows GitHub Actions to authenticate to AWS **without storing long-lived access keys in GitHub Secrets**. This is the modern, correct way.

```hcl
# Create OIDC Identity Provider in IAM
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint (verify at: https://token.actions.githubusercontent.com/.well-known/openid-configuration)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Role for GitHub Actions builds (ECR push)
resource "aws_iam_role" "github_actions_ecr" {
  name = "GitHubActionsECRRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # ONLY allow from your org/repo — CRITICAL security constraint
          "token.actions.githubusercontent.com:sub" = "repo:your-org/ecommerce-services:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push-policy"
  role = aws_iam_role.github_actions_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages"
        ]
        # Only for your ecommerce repositories
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/ecommerce-*"
      }
    ]
  })
}
```

---

## 10. Runbooks & Troubleshooting Scenarios

### Scenario 1: ECS Tasks Are Failing to Start

**Symptoms:** Deployment stuck, tasks going from PENDING → STOPPED immediately.

**Step-by-step investigation:**

```bash
# Step 1: Check stopped task reasons
aws ecs describe-tasks \
  --cluster ecommerce-production \
  --tasks $(aws ecs list-tasks \
    --cluster ecommerce-production \
    --service-name ecommerce-production-api \
    --desired-status STOPPED \
    --query 'taskArns[0]' \
    --output text) \
  --query 'tasks[0].{Status: lastStatus, StopCode: stopCode, Reason: stoppedReason, Containers: containers[*].{Name: name, Reason: reason, ExitCode: exitCode}}'

# Common reasons and fixes:
# "CannotPullContainerError" → ECR pull failed
#   → Check ECR VPC endpoint, check ECS execution role has ECR permissions
#   → Check the image tag exists: aws ecr describe-images --repository-name ecommerce-api-service

# "ResourceInitializationError: unable to pull secrets"
#   → Secrets Manager VPC endpoint missing or execution role lacks secretsmanager:GetSecretValue
#   → Verify: aws secretsmanager describe-secret --secret-id ecommerce/production/db-password

# "essential container exited" → your application crashed on startup
#   → Check CloudWatch logs:

# Step 2: Check CloudWatch logs
aws logs get-log-events \
  --log-group-name "/ecs/ecommerce/production/api-service" \
  --log-stream-name "ecs/api-service/$(aws ecs describe-tasks \
    --cluster ecommerce-production \
    --tasks $(aws ecs list-tasks \
      --cluster ecommerce-production \
      --service-name ecommerce-production-api \
      --desired-status STOPPED \
      --query 'taskArns[0]' --output text) \
    --query 'tasks[0].taskArn' --output text | awk -F/ '{print $NF}')" \
  --limit 50 \
  --query 'events[*].message' \
  --output text

# Step 3: Check ECS service events
aws ecs describe-services \
  --cluster ecommerce-production \
  --services ecommerce-production-api \
  --query 'services[0].events[0:10]'

# Step 4: Check if security group blocks connections
# Go to: AWS Console → EC2 → Security Groups → find ecs-tasks-sg
# Verify inbound rule: port 8080 from alb-public-sg
# Verify there's NO deny rule for ECR (port 443) outbound

# Step 5: Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names ecommerce-production-api-tg \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
```

---

### Scenario 2: Database Connection Exhaustion

**Symptoms:** App logs show "Too many connections", 503s on API, Prometheus alert `RDSConnectionsHigh` fired.

```bash
# Step 1: Check current connection count in RDS
# Go to: AWS Console → RDS → ecommerce-production-aurora → Monitoring tab
# Look at: "DatabaseConnections" metric

# Or via CLI:
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBClusterIdentifier,Value=ecommerce-production-aurora \
  --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 \
  --statistics Maximum \
  --output table

# Step 2: Connect to RDS and check who's using connections
# Use SSM Session Manager to get to a bastion/monitoring host
aws ssm start-session --target i-0123456789abcdef0

# From monitoring host, connect to RDS:
mysql -h ecommerce-production-aurora.cluster-xxx.us-east-1.rds.amazonaws.com \
  -u ecommerce_admin -p ecommerce << 'SQL'
-- Who has connections open?
SELECT user, host, db, command, time, state, info
FROM information_schema.processlist
ORDER BY time DESC
LIMIT 50;

-- Count by user and host
SELECT user, host, COUNT(*) as connections
FROM information_schema.processlist
GROUP BY user, host
ORDER BY connections DESC;

-- Kill idle connections (CAREFULLY — only idle ones)
-- SELECT CONCAT('KILL ', id, ';') FROM information_schema.processlist
-- WHERE command = 'Sleep' AND time > 300;
SQL

# Step 3: Check connection pool settings in app
# The issue is usually the connection pool is set too high
# Each ECS task should have: pool size = (max_connections / num_tasks) * 0.7
# With 10 tasks and 1000 max connections: pool = 70 per task

# Step 4: Immediate mitigation — reduce connection pool via SSM Parameter Store
# Your app should read pool size from environment on restart
aws ssm put-parameter \
  --name "/ecommerce/production/db_pool_size" \
  --value "30" \
  --type "String" \
  --overwrite

# Force ECS service restart to pick up new config
aws ecs update-service \
  --cluster ecommerce-production \
  --service ecommerce-production-api \
  --force-new-deployment

# Step 5: Long-term fix — implement RDS Proxy
# RDS Proxy multiplexes connections — 1000 app connections → 50 actual DB connections
# See: aws rds create-db-proxy ...
```

---

### Scenario 3: High Latency Investigation

**Symptoms:** Prometheus alert `HighAPILatencyP99` fired. P99 > 2 seconds.

```bash
# Step 1: Narrow down which service/endpoint is slow
# Query Prometheus:
curl -G http://prometheus.internal:9090/api/v1/query \
  --data-urlencode 'query=histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job="ecs-tasks"}[5m])) by (le, service, path))' \
  | jq '.data.result[] | {service: .metric.service, path: .metric.path, p99_latency: .value[1]}'

# Step 2: Check if it's DB latency
# Query: average DB query latency
curl -G http://prometheus.internal:9090/api/v1/query \
  --data-urlencode 'query=aws_rds_read_latency_average{dbcluster_identifier="ecommerce-production-aurora"}' \
  | jq '.data.result[0].value[1]'

# Step 3: Check Redis hit rate (low hit rate = more DB queries)
curl -G http://prometheus.internal:9090/api/v1/query \
  --data-urlencode 'query=redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)' \
  | jq '.data.result[0].value[1]'

# Step 4: Check if it's a specific task (noisy neighbor)
# If one task has high CPU, it affects response times
curl -G http://prometheus.internal:9090/api/v1/query \
  --data-urlencode 'query=rate(process_cpu_seconds_total{job="ecs-tasks"}[5m]) by (instance)' \
  | jq '.data.result[] | {instance: .metric.instance, cpu: .value[1]}'

# Step 5: X-Ray distributed tracing (if enabled)
# Go to: AWS Console → X-Ray → Service Map
# Look for the red/yellow nodes showing high latency

# Step 6: Check ALB access logs for slow requests
# Logs are in S3: s3://ecommerce-alb-logs/production/AWSLogs/
aws s3 select \
  --bucket ecommerce-alb-logs \
  --key "production/AWSLogs/.../2024/01/01/...log.gz" \
  --expression "SELECT * FROM S3Object s WHERE CAST(s.request_processing_time AS DECIMAL) > 1.0 LIMIT 20" \
  --expression-type SQL \
  --input-serialization '{"CSV": {"FileHeaderInfo": "NONE", "FieldDelimiter": " "}, "CompressionType": "GZIP"}' \
  --output-serialization '{"CSV": {}}' \
  --output text
```

---

### Scenario 4: Prometheus Scraping Failing

**Symptoms:** Grafana shows "No data" for some panels. Prometheus targets page shows targets as DOWN.

```bash
# Step 1: Check Prometheus targets page
# Go to: http://prometheus.internal:9090/targets
# Look for targets in "DOWN" state, click on the error

# Step 2: Common errors and fixes:

# Error: "context deadline exceeded"
# → Scrape timeout (10s) exceeded. Fix: increase scrape_timeout in prometheus.yml
# → Or optimize the metrics endpoint in the app

# Error: "connection refused"
# → Node Exporter not running:
systemctl status node_exporter
journalctl -u node_exporter -n 50

# Error: "no route to host"  
# → Security group blocking port 9100 from Prometheus to target
# Check security group allows 9100 from monitoring-sg

# Error: "dial tcp: lookup hostname: no such host"
# → DNS resolution failing. Check VPC DNS settings.

# Step 3: Test scrape manually from Prometheus host
curl -f http://10.0.11.45:9100/metrics | head -20
# If this fails but the host is reachable, Node Exporter isn't running
# If this times out, check security groups and NACLs

# Step 4: Reload Prometheus config after changes (no restart needed)
curl -X POST http://localhost:9090/-/reload
# Returns: Reloading configuration file... 

# Step 5: Verify alert rules are loaded
curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].name'

# Step 6: Check Prometheus disk usage (storage can fill up)
df -h /var/lib/prometheus
du -sh /var/lib/prometheus/

# If disk is full:
# Option A: Increase EBS volume (AWS Console → EC2 → Volumes → Modify)
# Option B: Reduce retention: prometheus --storage.tsdb.retention.time=30d
```

---

## 11. SRE Interview Q&A Deep Dive

### 🎯 The Questions You WILL Be Asked

---

**Q1: "Walk me through your on-call rotation and how you handle incidents."**

**Answer framework:**
- **Alerting:** Prometheus alerts → Alertmanager → PagerDuty (P1/P2) or Slack (P3/P4). SLO-based alerting, not threshold-based for primary alerts.
- **Response:** ACK within 5 min (P1), 15 min (P2). First action: communicate on the incident Slack channel. Second: triage, not fix.
- **Triage order:** (1) Check dashboards for anomaly timing, (2) Correlate with recent deploys/changes, (3) Check error logs, (4) Check dependencies.
- **Communication:** Update stakeholders every 15 minutes during P1. No "we're looking into it" — give specific findings.
- **Postmortem:** Blameless, within 48 hours, with timeline, root cause, 5 whys, and action items with owners and due dates.

---

**Q2: "How do you define and measure SLOs for an e-commerce platform?"**

**Answer:**
SLOs should map to what users care about, not what's convenient to measure.

For e-commerce:
- **Availability SLO:** 99.9% of requests to `/api/*` return non-5xx responses (measured over 30-day rolling window)
- **Latency SLO:** 95% of checkout requests complete in under 2 seconds
- **Checkout Success SLO:** 99.5% of checkout attempts that enter the checkout flow result in either a successful order or an explicit user abandon

Error budget = 1 - SLO target. For 99.9% = 0.1% error budget = 43.8 minutes/month.
Error budget burn rate determines alert urgency: burning 2 weeks of budget in 1 hour = page immediately.

---

**Q3: "How do you handle a situation where Terraform wants to destroy a production RDS instance?"**

**Answer:**
First: Don't panic, don't run it.

1. Use `deletion_protection = true` on the resource (we showed this in our config).
2. Run `terraform plan` and look for `-/+` on the RDS resource. Understand WHY it wants to replace it (usually a change to `engine_version`, `cluster_identifier`, or moving between security groups).
3. Check if the change can be avoided: Can you use `lifecycle { ignore_changes = [...] }` for this attribute?
4. If replacement is necessary: plan the migration. Snapshot first. Rename the cluster to preserve the current one. Let Terraform create the new one. Run data validation. Switch app endpoint. Destroy old only after 24-hour validation.
5. **The `prevent_destroy` lifecycle block** is your second line of defense after deletion_protection.

---

**Q4: "Your checkout service P99 latency spiked from 500ms to 4s at 2pm on Black Friday. Walk me through your investigation."**

**Answer (structured timeline):**

T+0: Alert fires. I ACK and post in #incidents.

T+2: Check Grafana "E-Commerce Overview" dashboard. Confirm: checkout P99 up to 4s. Error rate flat (no 5xx). So requests ARE completing, just slowly.

T+3: Check the timing. Did a deploy happen? `aws ecs describe-services --query 'services[0].deployments'`. No recent deploy. Did traffic spike? Yes — Black Friday.

T+5: Check dependency dashboards. RDS latency? Normal. Redis hit rate? Dropped from 95% to 60%. 

T+6: Redis hit rate drop on Black Friday = cache stampede or cache warming after cold start. Check ElastiCache events. No evictions — but memory at 89%.

T+8: MaxMemory policy was `allkeys-lru`, evicting working set keys. Fix: increase ElastiCache node type immediately.

T+10: Go to ElastiCache → Modify → Scale vertically to r7g.xlarge. Scaling in-place.

T+15: Cache hit rate recovering. P99 dropping. 

T+30: P99 back to 600ms. Update stakeholders. RCA: cache eviction under Black Friday load due to undersized cluster. Action: pre-scale for known load events.

---

**Q5: "How do you ensure your Terraform doesn't accidentally break production?"**

**Answer:**
Multi-layer strategy:
1. **Workspaces / separate state per environment** — staging and production are separate state files. A plan in staging can't affect production.
2. **PR-based workflow** — all changes go through PRs. Terraform plan output is posted as PR comment. Required reviewers: 2 SREs minimum for production infra PRs.
3. **`prevent_destroy`** on databases, S3 buckets, Route53 zones.
4. **`deletion_protection`** on RDS.
5. **Terraform Sentinel/OPA policies** — policy-as-code that runs pre-apply and blocks dangerous patterns (e.g., opening 0.0.0.0/0 on RDS security group).
6. **Automated drift detection** — run `terraform plan` nightly in CI. Alert if drift is detected. Drift = someone made manual changes and didn't go through Terraform.
7. **State locking** via DynamoDB prevents concurrent applies.

---

**Q6: "Explain IMDSv2 and why it matters for your ECS tasks."**

**Answer:**
IMDSv1 (Instance Metadata Service version 1) allowed any process on an EC2 instance to call `http://169.254.169.254/latest/meta-data/iam/security-credentials/role-name` with a simple GET request and get the instance role's temporary credentials. This was used in multiple high-profile data breaches (Capital One 2019) via SSRF vulnerabilities — a bad actor tricks the server into making that GET request.

IMDSv2 requires a session-oriented approach: first do a PUT request with a TTL header to get a session token, then use that token in subsequent GET requests. A simple SSRF using GET can't do the PUT first.

In our Terraform:
```hcl
metadata_options {
  http_tokens = "required"              # Require IMDSv2
  http_put_response_hop_limit = 1       # Prevents container-in-container from reaching IMDS
}
```

The hop limit of 1 means the IMDS response can't traverse a network hop — so if a compromised container tries to reach IMDS, the packet TTL expires before it gets a response.

---

**Q7: "How would you design the monitoring for a Black Friday event with 10x normal traffic?"**

**Answer:**
**Pre-event (2 weeks before):**
- Load test: run Locust/k6 at 10x normal traffic in staging. Identify bottlenecks.
- Pre-warm ElastiCache: load product catalog into Redis manually before traffic hits.
- Pre-scale ECS services: increase `min_capacity` from 3 to 15 tasks (don't rely on auto-scaling ramp-up time during the rush).
- Pre-provision RDS — Aurora Serverless v2 should have its min ACU set higher for the period.
- Create a Black Friday Grafana dashboard with: orders/minute, revenue/minute, conversion rate, payment success rate.

**During the event:**
- War room: SRE on-call + lead developer in a video call for the first 2 hours.
- Reduce auto-scale cool-down to 30 seconds for scale-out.
- Disable non-critical background jobs (report generation, email digests) to free resources.
- Increase Prometheus scrape interval to 10s for finer resolution.

**Post-event:**
- Scale back down gradually (don't scale to 0 — keep 2x normal).
- Run full postmortem even if nothing went wrong: what did we learn?

---

**Q8: "What is a confused deputy attack in IAM and how do you prevent it?"**

**Answer:**
A confused deputy attack is when a less-privileged entity tricks a more-privileged entity (the "confused deputy") into performing actions on its behalf.

In AWS: Imagine service A has a cross-account role that allows any AWS account to assume it. A malicious account B calls `sts:AssumeRole` for service A's role and gets elevated permissions it shouldn't have.

Prevention using `aws:SourceArn` and `aws:SourceAccount` conditions in trust policies:

```json
{
  "Condition": {
    "ArnLike": {
      "aws:SourceArn": "arn:aws:ecs:us-east-1:123456789012:*"
    },
    "StringEquals": {
      "aws:SourceAccount": "123456789012"
    }
  }
}
```

This means: only ECS tasks from THIS account can assume this role — not any other account that might try to use ECS as a vehicle for privilege escalation.

---

**Q9: "How do you rotate database credentials without downtime?"**

**Answer:**
With AWS Secrets Manager automatic rotation:

1. Secrets Manager supports Lambda-based rotation. AWS provides a pre-built Lambda for RDS.
2. The rotation Lambda creates a new password, tests it, updates the secret, then invalidates the old password.
3. During rotation, both old and new passwords work (there's a window of dual-valid credentials).
4. Your application calls `GetSecretValue` at runtime — not at startup and cached forever. Implement a cache with a 5-minute TTL so the app gets the new password within 5 minutes of rotation.
5. The `AWSCURRENT` staging label = new password. `AWSPREVIOUS` = old password. Both work until the next rotation.

For zero-downtime in practice:
- Use connection pooling with reconnect logic
- Implement a secret cache that refreshes on `InvalidClientTokenId` exceptions
- Test the rotation in staging before enabling in production

---

**Q10: "What's your approach to cost optimization on AWS as an SRE?"**

**Answer:**
Cost is a reliability concern — running out of budget means you can't scale.

My approach:
1. **Tagging everything** (we showed `default_tags` in our Terraform provider). Without tags, you can't allocate costs.
2. **Right-sizing:** Use AWS Compute Optimizer recommendations weekly. Don't over-provision — but do load test to confirm sizing.
3. **Spot/FARGATE_SPOT for non-critical tasks:** Batch jobs, report generation, dev environments → 70% cheaper. Our CI/CD and non-stateful dev tasks use Spot.
4. **VPC Endpoints:** ECR endpoint alone can save hundreds of dollars/month in NAT Gateway charges for a large ECS cluster.
5. **S3 Intelligent-Tiering:** Old order documents, log archives → move to Glacier automatically.
6. **Reserved capacity or Savings Plans:** Once traffic is predictable (3+ months of data), commit to 1-year Compute Savings Plan for 30-40% discount.
7. **CloudWatch Log retention policies:** Logs at $0.50/GB. Set 30-day retention on dev, 90-day on production, 1-year for audit logs in S3 (much cheaper than CloudWatch).
8. **Idle resource detection:** Run Lambda weekly to find EC2 instances with <5% CPU over 2 weeks, RDS instances not connected to, unattached EBS volumes. SNS notification to team.

---

## 📋 Final Checklist — "Is This Production-Ready?"

Before any go-live, an SRE with 6 years of experience should verify:

**Security**
- [ ] All S3 buckets have Block Public Access enabled
- [ ] All S3 buckets have bucket policies denying non-SSL requests  
- [ ] All EBS volumes are encrypted with KMS CMK
- [ ] All RDS instances are encrypted with KMS CMK
- [ ] IMDSv2 enforced on all EC2 instances
- [ ] No EC2 instances with public IPs (use SSM Session Manager instead)
- [ ] GuardDuty enabled in all regions
- [ ] CloudTrail enabled with log file integrity validation
- [ ] WAF deployed in front of ALB and CloudFront
- [ ] MFA enforced for all IAM users
- [ ] No long-lived access keys (use OIDC for CI/CD)
- [ ] Security Hub enabled with CIS benchmark and PCI DSS

**Reliability**
- [ ] Resources deployed across 3 AZs minimum
- [ ] ALB health checks configured with appropriate thresholds
- [ ] ECS deployment circuit breaker enabled
- [ ] RDS deletion_protection = true
- [ ] RDS automated backups enabled (35-day retention)
- [ ] Redis cluster mode enabled with replicas
- [ ] Route53 health checks and failover configured
- [ ] SQS dead-letter queues configured for all queues
- [ ] ECS auto-scaling policies (CPU + request count)

**Monitoring**
- [ ] Prometheus scraping all targets successfully
- [ ] Grafana dashboards for all key services
- [ ] Alert rules defined for all SLOs
- [ ] Alertmanager configured with appropriate routing
- [ ] PagerDuty/OpsGenie integration tested
- [ ] On-call rotation documented and tested
- [ ] Runbooks linked from all alerts
- [ ] Synthetic monitoring (CloudWatch Synthetics) on critical paths
- [ ] Log retention policies configured
- [ ] VPC Flow Logs enabled

**Operations**
- [ ] Terraform state backed up and versioned
- [ ] All infrastructure in version control
- [ ] CI/CD pipeline with automated tests
- [ ] Container images scanned for vulnerabilities
- [ ] Secrets rotation configured
- [ ] Incident response runbooks written and tested
- [ ] GameDay/chaos engineering exercises scheduled
- [ ] Load testing completed (verify 3x peak capacity)
- [ ] Black Friday runbook exists

---

*This lab guide was written for SREs with 6+ years of experience preparing for senior/staff SRE interviews at e-commerce companies. Every configuration shown reflects patterns used in real production environments handling millions of transactions.*
