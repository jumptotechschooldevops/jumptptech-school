---
title: "Lab Demo: Private S3 + EC2 + IAM Role"
description: "0) DevOps context   In DevOps, we store things like:   build artifacts (zip, jar, docker..."
published: 2026-02-05
source: "https://dev.to/jumptotech/lab-demo-private-s3-ec2-iam-role-35hi"
tags: []
---

# Lab Demo: Private S3 + EC2 + IAM Role






# 0) DevOps context 
In DevOps, we store things like:

* build artifacts (zip, jar, docker image manifests)
* backups and logs
* static website files
* Terraform state (in real projects)
  And we must do it **securely**:
* No public buckets
* No access keys on servers
* Use IAM Roles

---

# PART 1 — Create S3 Bucket (Private)

## Step 1.1 — Go to S3

1. AWS Console (top search bar) type: **S3**
2. Click **S3** (Service)

## Step 1.2 — Create bucket

1. Click **Create bucket**
2. **Bucket name**:
   Example:

   ```
   s3-ec2-iam-demo-aisalkyn
   ```
3. **AWS Region**: keep default (or choose your region)
4. Scroll to **Block Public Access settings for this bucket**

   * Keep **Block all public access = ON** ✅
5. Scroll down → click **Create bucket**

### Why DevOps cares

* S3 is frequently a source of security incidents when made public.
* DevOps must enforce: **private-by-default** storage.

---

## Step 1.3 — Upload hello.txt

1. Click the bucket name you created
2. Click **Upload**
3. Click **Add files**
4. Select `hello.txt` from your laptop

   * If you don’t have it: create a simple `hello.txt` file locally with:

     ```
     Hello from private S3 bucket
     ```
5. Click **Upload**

### Why DevOps cares

* Objects in S3 = artifacts/logs/backups.
* S3 is “serverless storage” (no EC2 needed).

---

## Step 1.4 — Prove it is private (Access Denied)

1. Click the uploaded file `hello.txt`
2. Find **Object URL**
3. Open it in a new tab

Expected result:

* **AccessDenied**

### Why DevOps cares

* This is correct security behavior.
* “AccessDenied” means bucket/object is protected.

---

# PART 2 — Create IAM Role (EC2 can read S3)

## Step 2.1 — Go to IAM

1. AWS Console search: **IAM**
2. Click **IAM**

## Step 2.2 — Create Role

1. Left menu → **Roles**
2. Click **Create role**
3. **Trusted entity**: select **AWS service**
4. **Use case**: choose **EC2**
5. Click **Next**

### Why DevOps cares

* Roles are how EC2 gets permissions securely.
* No secrets stored on the server.

---

## Step 2.3 — Add permissions

On “Add permissions” page:

1. Search policy: `AmazonS3ReadOnlyAccess`
2. Check it ✅
3. Click **Next**



## Step 2.4 — Name role

1. Role name:

   ```
   EC2-S3-ReadOnly-Role
   ```
2. Click **Create role**

### Why DevOps cares

* Least privilege: read-only is safer than full access.
* IAM policies = security boundaries.

---

# PART 3 — Launch EC2 and attach role

## Step 3.1 — Go to EC2

1. AWS Console search: **EC2**
2. Click **EC2**

## Step 3.2 — Launch instance

1. Click **Launch instance**
2. Name:

   ```
   s3-access-demo-ec2
   ```
3. AMI: **Ubuntu**
4. Instance type: **t2.micro** (or free tier eligible)
5. Key pair: select existing or create new (for SSH)

## Step 3.3 — Attach IAM Role (important screen)

Scroll to **Advanced details** (it’s near the bottom).

1. Find **IAM instance profile**
2. Select:

   ```
   EC2-S3-ReadOnly-Role
   ```

Then click **Launch instance**

### Why DevOps cares

* This is the production way: EC2 inherits permissions via role.
* Avoids access keys on disk (huge security risk).

---

# PART 4 — Connect to EC2

## Step 4.1 — Find Public IP

1. EC2 left menu → **Instances**
2. Click your instance
3. Copy **Public IPv4 address**

## Step 4.2 — SSH in

From your laptop terminal:

```bash
ssh -i yourkey.pem ubuntu@EC2_PUBLIC_IP
```

---

# PART 5 — Install AWS CLI (Real troubleshooting)

## Step 5.1 — If `aws` not found

If you see:
`aws: command not found`

That’s normal on Ubuntu.

### Install AWS CLI v2 (recommended)

```bash
cd /tmp
sudo apt update
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### Why DevOps cares

* Packages change; not everything is in apt.
* DevOps must install vendor tools reliably.

---

# PART 6 — Validate Role + Access S3

## Step 6.1 — List buckets (proves IAM works)

```bash
aws s3 ls
```

Expected: you see your bucket name.

### DevOps meaning

* IAM role is attached correctly
* EC2 has permission to call S3 APIs

---

## Step 6.2 — List objects in bucket (avoid 404)

```bash
aws s3 ls s3://s3-ec2-iam-demo-aisalkyn/
```

Expected: you see `hello.txt` (or exact object name)

### DevOps meaning

* Prevents mistakes like wrong filename or folder path

---

## Step 6.3 — Read file from S3

```bash
aws s3 cp s3://s3-ec2-iam-demo-aisalkyn/hello.txt -
```

Expected output:

```
Hello from private S3 bucket
```

### Why DevOps cares

* This is how servers fetch configs/artifacts securely in real systems.

---

# PART 7 — Troubleshooting rules (teach this clearly)

## If error is **403 AccessDenied**

Meaning:

* IAM policy is missing, OR
* Role not attached to EC2, OR
* Bucket policy blocks access

Fix checklist:

* EC2 → Instance → check IAM role attached
* IAM → Role → ensure S3 permissions exist
* S3 → Permissions → bucket policy not blocking

## If error is **404 Not Found**

Meaning:

* Permission is OK, but object name/path is wrong

Fix:

```bash
aws s3 ls s3://BUCKET/
```

Copy the exact name and retry.

### Key DevOps lesson

* 403 = permission/security issue
* 404 = path/object issue

---

# PART 8 — What DevOps uses this for (real-world examples)

DevOps uses S3 for:

* CI/CD artifacts (zip files, deploy packages)
* backups (DB dumps)
* logs archive
* static website hosting (docs/landing pages)
* cross-region replication and disaster recovery
* storing config templates (secured, not public)
* Terraform state (common pattern)

---

# PART 9 — Clean up (DevOps cost control)

## Delete EC2

* EC2 → Instances → select instance → **Terminate**

## Delete S3

* S3 → bucket → delete objects → delete bucket

## Delete IAM role (optional)

* IAM → Roles → delete `EC2-S3-ReadOnly-Role`

### Why DevOps cares

* Cost and security: unused resources are risk.


