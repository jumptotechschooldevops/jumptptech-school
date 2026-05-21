---
title: "Part 1: AWS Organizations & IAM Foundation"
description: Multi-account structure, SCPs, IAM roles, and permission boundaries for enterprise e-commerce platform
---

# Part 1: AWS Organizations & IAM Foundation

**← [Back to Lab Overview](enterprise-sre-lab-ecommerce-platform.md) | [Part 2: Terraform State Backend →](enterprise-sre-lab-part2-terraform.md)**

---

## Objective

Set up a production-grade multi-account AWS structure for ShopFlow with proper organizational units, service control policies, and IAM foundations that enforce least-privilege access.

---

## Step 1 — AWS Organizations Setup

### 1.1 Create the Organization

In the management account:

```bash
aws organizations create-organization --feature-set ALL
```

### 1.2 Create Organizational Units

```bash
# Create top-level OUs
aws organizations create-organizational-unit \
  --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) \
  --name "Production"

aws organizations create-organizational-unit \
  --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) \
  --name "Non-Production"

aws organizations create-organizational-unit \
  --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) \
  --name "Security"
```

### 1.3 OU Structure

```
Root
├── Management (billing, CloudTrail aggregation)
├── Security (GuardDuty delegated admin, Security Hub)
├── Production
│   └── prod-account (ShopFlow production)
└── Non-Production
    ├── dev-account
    └── staging-account
```

### 1.4 Create Member Accounts

```bash
aws organizations create-account \
  --email prod@shopflow.com \
  --account-name "ShopFlow-Production" \
  --iam-user-access-to-billing ALLOW

aws organizations create-account \
  --email staging@shopflow.com \
  --account-name "ShopFlow-Staging" \
  --iam-user-access-to-billing ALLOW

aws organizations create-account \
  --email dev@shopflow.com \
  --account-name "ShopFlow-Dev" \
  --iam-user-access-to-billing ALLOW
```

---

## Step 2 — Service Control Policies (SCPs)

SCPs act as guardrails — they define the **maximum permissions** any account in an OU can grant. Even if an IAM role has `AdministratorAccess`, SCPs can block specific actions.

### 2.1 Deny Disabling CloudTrail

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCloudTrailDisable",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    }
  ]
}
```

```bash
aws organizations create-policy \
  --name "DenyCloudTrailDisable" \
  --type SERVICE_CONTROL_POLICY \
  --description "Prevent disabling CloudTrail in any account" \
  --content file://scp-deny-cloudtrail-disable.json
```

### 2.2 Deny Root Account Usage

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootAccess",
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

### 2.3 Restrict to Approved Regions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnapprovedRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    }
  ]
}
```

### 2.4 Apply SCPs to OUs

```bash
PROD_OU_ID="ou-xxxx-xxxxxxxx"
POLICY_ID="p-xxxxxxxxxxxx"

aws organizations attach-policy \
  --target-id $PROD_OU_ID \
  --policy-id $POLICY_ID
```

---

## Step 3 — AWS IAM Identity Center (SSO)

Modern enterprises use **IAM Identity Center** (formerly AWS SSO) instead of individual IAM users.

### 3.1 Enable IAM Identity Center

```bash
aws sso-admin list-instances
```

Enable via console: AWS Console → IAM Identity Center → Enable

### 3.2 Create Permission Sets

**SRE Engineers:**

```bash
aws sso-admin create-permission-set \
  --instance-arn arn:aws:sso:::instance/ssoins-xxxx \
  --name "SREEngineer" \
  --description "Full read + operational write for SRE team" \
  --session-duration PT8H
```

**Read-Only (for developers viewing prod):**

```bash
aws sso-admin create-permission-set \
  --instance-arn arn:aws:sso:::instance/ssoins-xxxx \
  --name "ReadOnly" \
  --description "Read-only access to production" \
  --session-duration PT4H
```

### 3.3 Inline Policy for SRE Permission Set

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECSOperations",
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:List*",
        "ecs:UpdateService",
        "ecs:StopTask",
        "ecs:RunTask"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RDSReadAndReboot",
      "Effect": "Allow",
      "Action": [
        "rds:Describe*",
        "rds:RebootDBInstance",
        "rds:FailoverDBCluster"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchFullRead",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*",
        "logs:*",
        "xray:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Step 4 — IAM Roles for Services

### 4.1 ECS Task Execution Role

This role is used by the ECS agent to pull images and write logs. It is **not** the same as the task role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```bash
aws iam create-role \
  --role-name shopflow-ecs-execution-role \
  --assume-role-policy-document file://ecs-trust-policy.json

aws iam attach-role-policy \
  --role-name shopflow-ecs-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Allow reading secrets from Secrets Manager
aws iam attach-role-policy \
  --role-name shopflow-ecs-execution-role \
  --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite
```

### 4.2 ECS Task Role (API Service)

This is what your application code uses at runtime. Use **least privilege** — only what the service actually needs.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::shopflow-assets-prod/*"
    },
    {
      "Sid": "SecretsManager",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:shopflow/prod/*"
    },
    {
      "Sid": "SQSPublish",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:us-east-1:*:shopflow-orders-*"
    },
    {
      "Sid": "XRay",
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Step 5 — Permission Boundaries

Permission boundaries are a **maximum permissions policy** attached to a role. Even if someone gives a role `AdministratorAccess`, the boundary caps what it can actually do.

### 5.1 Developer Permission Boundary

Apply this to any roles created by developers so they cannot escalate privileges:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedServices",
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "sqs:*",
        "sns:*",
        "lambda:*",
        "cloudwatch:*",
        "logs:*",
        "xray:*",
        "ecs:Describe*",
        "ecs:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyPrivilegeEscalation",
      "Effect": "Deny",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PassRole",
        "organizations:*",
        "account:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyProductionDestruction",
      "Effect": "Deny",
      "Action": [
        "rds:DeleteDBCluster",
        "rds:DeleteDBInstance",
        "ecs:DeleteCluster",
        "ecs:DeleteService",
        "ec2:TerminateInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/env": "prod"
        }
      }
    }
  ]
}
```

```bash
aws iam create-policy \
  --policy-name DeveloperPermissionBoundary \
  --policy-document file://developer-boundary.json

# Attach boundary when creating a role
aws iam create-role \
  --role-name some-developer-role \
  --assume-role-policy-document file://trust.json \
  --permissions-boundary arn:aws:iam::123456789012:policy/DeveloperPermissionBoundary
```

---

## Step 6 — CloudTrail Setup

CloudTrail records all API calls across your accounts. Essential for audit, incident investigation, and compliance.

### 6.1 Create Organization Trail

From the management account:

```bash
aws cloudtrail create-trail \
  --name shopflow-org-trail \
  --s3-bucket-name shopflow-cloudtrail-logs \
  --is-organization-trail \
  --is-multi-region-trail \
  --include-global-service-events \
  --enable-log-file-validation

aws cloudtrail start-logging --name shopflow-org-trail
```

### 6.2 Enable CloudWatch Logs Integration

```bash
aws cloudtrail update-trail \
  --name shopflow-org-trail \
  --cloud-watch-logs-log-group-arn arn:aws:logs:us-east-1:MGMT_ACCT:log-group:cloudtrail-logs:* \
  --cloud-watch-logs-role-arn arn:aws:iam::MGMT_ACCT:role/CloudTrailToCloudWatchRole
```

### 6.3 Create Metric Filter for Root Login

```bash
aws logs put-metric-filter \
  --log-group-name cloudtrail-logs \
  --filter-name RootAccountLogin \
  --filter-pattern '{ $.userIdentity.type = "Root" && $.eventType != "AwsServiceEvent" }' \
  --metric-transformations \
    metricName=RootAccountLoginCount,metricNamespace=ShopFlow/Security,metricValue=1
```

---

## Verification Checklist — Part 1

```
[ ] AWS Organization created with 3 accounts (prod, staging, dev)
[ ] OUs created: Production, Non-Production, Security
[ ] SCPs applied: deny CloudTrail disable, deny root, restrict regions
[ ] IAM Identity Center enabled and permission sets created
[ ] ECS execution role created with correct managed policies
[ ] ECS task role created with least-privilege inline policy
[ ] Developer permission boundary created and tested
[ ] CloudTrail organization trail enabled with log validation
[ ] CloudWatch Logs metric filter for root login created
```

---

**[Part 2: Terraform State Backend →](enterprise-sre-lab-part2-terraform.md)**
