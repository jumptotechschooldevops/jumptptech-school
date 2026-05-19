# Lab 1 · IAM Setup

**Duration:** ~45 minutes  
**Goal:** Set up a least-privilege IAM user, configure the AWS CLI, enable MFA, and verify access works correctly.

**Prerequisites:**
- AWS account (root user access to complete initial setup)
- AWS CLI v2 installed
- An MFA app (Authy, Google Authenticator, or similar)

---

## Part 1 — Secure the root user

Before creating any IAM resources, lock down root.

### Enable MFA on root

1. Sign in to the AWS console as root
2. Click your account name → **Security credentials**
3. Under **Multi-factor authentication (MFA)**, click **Assign MFA device**
4. Choose **Authenticator app**, scan the QR code, enter two consecutive codes
5. Click **Add MFA**

Root now requires a password + MFA code to sign in. Write down the backup codes and store them securely.

### Do not create root access keys

If root access keys exist, delete them immediately:

```bash
# List root access keys (run as root)
aws iam list-access-keys --user-name root

# Delete any that exist
aws iam delete-access-key --access-key-id AKIAIOSFODNN7EXAMPLE
```

---

## Part 2 — Create an admin IAM user

This user will replace root for day-to-day administration.

```bash
# Log into AWS console as root and open CloudShell (or use the CLI)

# Create the admin user
aws iam create-user --user-name devops-admin

# Create a login profile (console password)
aws iam create-login-profile \
  --user-name devops-admin \
  --password "$(openssl rand -base64 20)" \
  --password-reset-required

# Attach the AdministratorAccess policy
aws iam attach-user-policy \
  --user-name devops-admin \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Note down the temporary password — you will change it on first login.

### Create access keys for CLI

```bash
aws iam create-access-key --user-name devops-admin
# Note the AccessKeyId and SecretAccessKey — they are shown only once
```

---

## Part 3 — Configure the AWS CLI

On your local machine:

```bash
aws configure --profile devops-admin
# AWS Access Key ID: <paste key from above>
# AWS Secret Access Key: <paste secret>
# Default region: us-east-1
# Default output format: json
```

Verify it works:

```bash
aws sts get-caller-identity --profile devops-admin
```

Expected output:
```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/devops-admin"
}
```

Set this profile as your default for this lab:

```bash
export AWS_PROFILE=devops-admin
aws sts get-caller-identity  # should work without --profile now
```

---

## Part 4 — Create a least-privilege developer user

A real developer does not need AdministratorAccess. Create a user with only the permissions needed for this module's labs.

### Create a policy

Save this as `devops-student-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Access",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:AssociateAddress"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:PutBucketWebsite",
        "s3:PutBucketVersioning",
        "s3:PutPublicAccessBlock"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMReadOnly",
      "Effect": "Allow",
      "Action": [
        "iam:List*",
        "iam:Get*"
      ],
      "Resource": "*"
    }
  ]
}
```

```bash
# Create the policy
aws iam create-policy \
  --policy-name DevOpsStudentPolicy \
  --policy-document file://devops-student-policy.json

# Note the policy ARN in the output
```

### Create a group and add the user

```bash
# Create group
aws iam create-group --group-name devops-students

# Attach policy to group
aws iam attach-group-policy \
  --group-name devops-students \
  --policy-arn arn:aws:iam::123456789012:policy/DevOpsStudentPolicy

# Create student user
aws iam create-user --user-name student-01

# Add to group
aws iam add-user-to-group \
  --user-name student-01 \
  --group-name devops-students

# Create access keys for student
aws iam create-access-key --user-name student-01
```

---

## Part 5 — Test the policy

Configure a second CLI profile for the student:

```bash
aws configure --profile student-01
# Enter the student's access key and secret
```

Test that allowed actions work:

```bash
# Should succeed
aws ec2 describe-instances --profile student-01
aws s3 ls --profile student-01

# Should fail (Action not in policy)
aws iam create-user --user-name test --profile student-01
```

Expected error for the last command:
```
An error occurred (AccessDenied) when calling the CreateUser operation: 
User: arn:aws:iam::123456789012:user/student-01 is not authorized to perform: iam:CreateUser
```

This confirms least-privilege is working.

---

## Part 6 — Enforce MFA via policy

Add a policy that denies all actions if MFA is not active:

Save as `require-mfa.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSelfServiceMFA",
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::*:mfa/${aws:username}",
        "arn:aws:iam::*:user/${aws:username}"
      ]
    },
    {
      "Sid": "DenyWithoutMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
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

```bash
aws iam create-policy \
  --policy-name RequireMFA \
  --policy-document file://require-mfa.json

aws iam attach-group-policy \
  --group-name devops-students \
  --policy-arn arn:aws:iam::123456789012:policy/RequireMFA
```

With this policy attached, students must set up MFA before they can use any other action.

---

## Part 7 — Create an IAM role for EC2

In Lab 2 you will launch an EC2 instance that reads from S3. Create the role now:

```bash
# Create role with EC2 trust policy
aws iam create-role \
  --role-name EC2S3ReadRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach S3 read policy
aws iam attach-role-policy \
  --role-name EC2S3ReadRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile (wrapper required for EC2)
aws iam create-instance-profile --instance-profile-name EC2S3ReadProfile
aws iam add-role-to-instance-profile \
  --instance-profile-name EC2S3ReadProfile \
  --role-name EC2S3ReadRole
```

---

## Verification checklist

- [ ] Root user has MFA enabled and no access keys
- [ ] `devops-admin` user exists with `AdministratorAccess`
- [ ] AWS CLI configured with `devops-admin` profile
- [ ] `student-01` user exists in `devops-students` group
- [ ] `aws ec2 describe-instances --profile student-01` returns results
- [ ] `aws iam create-user --profile student-01` returns AccessDenied
- [ ] `EC2S3ReadRole` role exists with S3 read permissions
- [ ] `EC2S3ReadProfile` instance profile exists

---

## Cleanup

Leave IAM resources in place for Labs 2 and 3. After completing all labs:

```bash
# Remove access keys
aws iam delete-access-key \
  --user-name student-01 \
  --access-key-id AKIA...

# Detach policies from group
aws iam detach-group-policy \
  --group-name devops-students \
  --policy-arn arn:aws:iam::123456789012:policy/DevOpsStudentPolicy

# Remove user from group and delete
aws iam remove-user-from-group --user-name student-01 --group-name devops-students
aws iam delete-user --user-name student-01

# Delete group
aws iam delete-group --group-name devops-students

# Delete policies
aws iam delete-policy --policy-arn arn:aws:iam::123456789012:policy/DevOpsStudentPolicy
aws iam delete-policy --policy-arn arn:aws:iam::123456789012:policy/RequireMFA
```
