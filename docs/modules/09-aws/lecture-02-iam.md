# Lecture 2 · IAM — Identity and Access Management

IAM controls who can do what in your AWS account. Get it wrong and either nothing works (too restrictive) or everything is exposed (too permissive). The SAA-C04 exam dedicates 30% of questions to security — IAM is central to all of them.

---

## Core concepts

### The IAM root user

When you create an AWS account, you get a root user tied to your email address. The root user has unrestricted access to everything in the account and **cannot be limited by any IAM policy**.

Rules for root:
- Enable MFA immediately
- Create an IAM admin user and use that for daily work
- Never create access keys for root
- Store root credentials somewhere safe and rarely touch them

AWS will fail you on the exam if you pick an answer that uses root credentials for application access.

### IAM Users

An IAM user is an identity with a name and credentials. Users can have:

- A **password** for console access
- **Access keys** (access key ID + secret access key) for CLI/API access

Users have no permissions by default. You must explicitly grant permissions via policies.

### IAM Groups

A group is a collection of users. Attach a policy to a group and every user in that group inherits those permissions. Never attach policies directly to individual users when a group makes sense — it doesn't scale.

```
Group: Developers
  ├── Policy: AmazonEC2ReadOnlyAccess
  ├── Policy: AmazonS3FullAccess
  └── Users: alice, bob, carol
```

Groups cannot be nested (no groups within groups).

### IAM Roles

A role is an identity that can be **assumed** by:

- AWS services (EC2 instances, Lambda functions, ECS tasks)
- IAM users in the same or different accounts (cross-account access)
- Federated identities (SAML, OIDC — for SSO)

Roles have no password or access keys. When something assumes a role, AWS issues **temporary security credentials** (via STS) that expire after a configurable duration (15 minutes to 12 hours).

This is the correct pattern for giving an EC2 instance access to S3 — attach an IAM role to the instance, not access keys embedded in the application.

---

## IAM Policies

Policies are JSON documents that define permissions.

### Policy structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ReadOnOurBucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-app-bucket",
        "arn:aws:s3:::my-app-bucket/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

Every statement has:

- **Effect** — `Allow` or `Deny`
- **Action** — which API calls (e.g., `s3:GetObject`, `ec2:*`, `*`)
- **Resource** — which ARNs the action applies to (`*` means all)
- **Condition** — optional constraints (MFA required, source IP, time of day)

### Policy evaluation logic

1. By default, all access is **denied**
2. An explicit `Allow` grants access
3. An explicit `Deny` always overrides an `Allow` — even in another policy

```
Default DENY → explicit ALLOW → explicit DENY wins
```

This matters when multiple policies apply to a user (via groups, attached policies, resource policies).

### Policy types

| Type | Attached to | Use case |
|------|------------|----------|
| Identity-based | User, group, role | What this identity can do |
| Resource-based | S3 bucket, SQS queue, KMS key | Who can access this resource |
| Permission boundaries | User or role | Maximum permissions a user/role can ever have |
| SCPs (Service Control Policies) | OU or account in AWS Organizations | Organisation-wide guardrails |
| Session policies | Temporary credentials | Limit what a role session can do |

### Managed vs inline policies

- **AWS managed policies** — created and maintained by AWS (e.g., `AmazonEC2ReadOnlyAccess`)
- **Customer managed policies** — you create them, reusable across multiple identities
- **Inline policies** — embedded directly in a single user/group/role, deleted when the identity is deleted; avoid these

Prefer customer managed policies over inline policies. Prefer managed policies over writing everything from scratch.

---

## ARNs

Every AWS resource has an Amazon Resource Name (ARN) — a unique identifier:

```
arn:partition:service:region:account-id:resource-type/resource-id

arn:aws:iam::123456789012:user/alice
arn:aws:s3:::my-bucket
arn:aws:ec2:us-east-1:123456789012:instance/i-0abc123def456789
arn:aws:iam::123456789012:role/LambdaExecutionRole
```

`iam` and `s3` ARNs omit the region because they are global.

---

## IAM Roles in practice

### EC2 instance profile

The correct way to give an application running on EC2 access to AWS services:

```bash
# 1. Create a role with EC2 as the trusted service
# Trust policy (who can assume this role):
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}

# 2. Attach a permissions policy to the role
# 3. Attach the role to the EC2 instance at launch (or after)

# Inside the EC2 instance, the SDK automatically picks up credentials
# from the instance metadata service — no config needed
aws s3 ls  # works because the instance has a role
```

### Cross-account access

Company has two accounts: `prod` (111111111111) and `dev` (222222222222). A developer in `dev` needs to read S3 in `prod`:

```json
// Role in prod account — trust policy allows dev account to assume it
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::222222222222:root" },
    "Action": "sts:AssumeRole"
  }]
}
```

```bash
# Developer in dev account assumes the prod role
aws sts assume-role \
  --role-arn arn:aws:iam::111111111111:role/ReadS3Prod \
  --role-session-name my-session

# Returns temporary credentials (AccessKeyId, SecretAccessKey, SessionToken)
# Export these and use them normally
```

---

## MFA

Multi-factor authentication adds a second factor (TOTP code from an app like Authy or Google Authenticator) on top of a password.

Enable MFA on:
- Root user — mandatory
- All IAM users with console access — required for any serious account

You can enforce MFA in policy using a condition:

```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "BoolIfExists": {
      "aws:MultiFactorAuthPresent": "false"
    }
  }
}
```

This denies all actions if the user has not authenticated with MFA. Attach it to a group that all users belong to.

---

## IAM best practices

1. **Never use root for anything except account tasks** (billing, account closure, creating first IAM admin)
2. **Least privilege** — grant only the permissions required for the task
3. **Use roles instead of access keys** for applications running on AWS
4. **Rotate access keys** if you must use them; prefer short-lived credentials via roles
5. **Enable MFA** for all human users with console access
6. **Use groups** to manage permissions at scale
7. **Review unused permissions** with IAM Access Analyzer and remove them
8. **Separate accounts** per environment using AWS Organizations (dev, staging, prod)

---

## AWS Organizations and SCPs

AWS Organizations lets you manage multiple AWS accounts centrally. You arrange accounts in Organisational Units (OUs) and apply **Service Control Policies (SCPs)** to limit what accounts can do regardless of their IAM policies.

```
Root
├── OU: Production
│   ├── Account: prod-us-east-1
│   └── Account: prod-eu-west-1
├── OU: Development
│   ├── Account: dev
│   └── Account: staging
└── OU: Security
    └── Account: log-archive
```

An SCP on the `Development` OU that prevents creating resources outside `us-east-1`:

```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "StringNotEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }
}
```

Even if a developer has `AdministratorAccess` in their dev account, the SCP blocks them from creating resources in other regions.

!!! tip "Exam tip"
    SCPs do not affect the management account (root account of the organisation). They apply to member accounts only. An SCP cannot grant permissions — it can only restrict what member accounts are allowed to do. The effective permission is the intersection of SCPs and identity-based policies.

!!! tip "Exam tip"
    When a question asks how to give an EC2 instance permissions to call AWS services, the answer is always an **IAM role attached to the instance** — never access keys hardcoded or stored on the instance.

!!! tip "Exam tip"
    Resource-based policies (like S3 bucket policies) specify a `Principal`. Identity-based policies do not — the identity they are attached to is the principal. This distinction matters for cross-account access questions.
