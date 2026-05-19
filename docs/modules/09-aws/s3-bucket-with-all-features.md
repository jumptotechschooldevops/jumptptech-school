---
title: "S3 bucket with all features"
description: "Part 1 — Create the bucket (base)            Create main bucket    AWS Console → search..."
published: 2026-02-18
source: "https://dev.to/jumptotech/s3-bucket-with-all-features-4k3j"
tags: []
---

# S3 bucket with all features




# Part 1 — Create the bucket (base)

### Create main bucket

1. AWS Console → search **S3**
2. Click **Buckets** → **Create bucket**
3. **Bucket name:** `jumptotech-lab-app-bucket-2026`
4. **AWS Region:** choose your region (example: us-east-2)
5. **Block Public Access settings:** keep **ON** for now (safer).
6. Click **Create bucket**

You now have your main bucket.

---

# Part 2 — Bucket Versioning

### Why DevOps uses it

* Rollback deleted/overwritten files (configs, artifacts)
* Required for **replication**
* Helps protect important objects (like backups)

### Enable it (clicks)

1. S3 → **Buckets** → click your bucket
2. Go to **Properties**
3. Scroll to **Bucket Versioning**
4. Click **Edit**
5. Select **Enable**
6. Click **Save changes**

### How to use / verify

1. Go to **Objects** tab
2. Click **Upload** → upload a file `app.zip`
3. Upload the **same name** `app.zip` again (different content if possible)
4. In **Objects** list, enable **Show versions**
5. You’ll see multiple versions of `app.zip`

---

# Part 3 — Default Encryption (SSE-S3 or SSE-KMS)

### Why DevOps uses it

* Compliance/security: data encrypted at rest
* Many companies require KMS keys for audit controls

### Enable default encryption (clicks)

1. Bucket → **Properties**
2. Scroll to **Default encryption**
3. Click **Edit**
4. Check **Enable**
5. Choose one:

   * **SSE-S3** (simple, AWS-managed)
   * **SSE-KMS** (stronger control; uses KMS key)
6. If **SSE-KMS**:

   * Choose **AWS managed key (aws/s3)** (easy start), or your CMK later
7. Click **Save changes**

### How to verify

1. Upload a new file
2. Click the file → look at **Server-side encryption** in details (it should show SSE-S3 or SSE-KMS)

---

# Part 4 — Intelligent-Tiering + Archive (using Lifecycle Rules)

> Intelligent-Tiering itself is a storage class. “Archive” happens through **Archive Access tiers** and/or lifecycle transitions (Glacier/Deep Archive).

### Why DevOps uses it

* Cuts cost automatically for data that’s not used often (logs, backups)

### Setup (clicks)

1. Bucket → **Management**
2. **Lifecycle rules** → click **Create lifecycle rule**
3. **Lifecycle rule name:** `int-tier-and-archive`
4. **Choose a rule scope**

   * Select **Apply to all objects in the bucket**
5. Scroll to **Lifecycle rule actions**

   * Check **Transition current versions of objects between storage classes**
6. Set transitions:

   * **After 0 days** → transition to **Intelligent-Tiering**
   * **After 30 days** → transition to **Glacier Flexible Retrieval** (or Glacier Instant Retrieval)
   * **After 90 days** → transition to **Deep Archive**
7. Click **Create rule**

### How to verify

* Lifecycle transitions don’t happen instantly. For teaching:

  * Show students the rule exists and explain AWS transitions occur “later” based on time.

---

# Part 5 — Server Access Logging

### Why DevOps uses it

* Records requests to your bucket (who/what accessed)
* Useful for security audits and troubleshooting

### Step A: create a log bucket (required)

1. S3 → **Buckets** → **Create bucket**
2. Name: `jumptotech-lab-s3-logs-2026`
3. Keep **Block Public Access ON**
4. Create

### Step B: enable access logging on main bucket (clicks)

1. Open your **main bucket**
2. Go to **Properties**
3. Scroll to **Server access logging**
4. Click **Edit**
5. Select **Enable**
6. **Target bucket:** choose `jumptotech-lab-s3-logs-2026`
7. **Target prefix:** `access-logs/`
8. Click **Save changes**

### How to verify

1. Use main bucket (upload/download a file)
2. Wait a bit
3. Open log bucket → you should see log files under `access-logs/`

---

# Part 6 — AWS CloudTrail Data Events (S3 object-level logging)

### Why DevOps uses it

* Tracks API actions like **GetObject, PutObject, DeleteObject**
* This is the audit log many security teams require

### Enable Data Events (clicks)

1. AWS Console → search **CloudTrail**
2. Click **Trails**
3. If you have a trail already, click it. If not:

   * Click **Create trail**
   * Name: `org-trail` (example)
   * Storage: choose/create S3 bucket for CloudTrail logs
   * Create trail
4. Open your trail → click **Edit**
5. Find **Data events** → click **Add data event**
6. **Data event type:** choose **S3**
7. Choose **Specific S3 buckets**
8. Select your main bucket `jumptotech-lab-app-bucket-2026`
9. Choose event types:

   * **Read** events
   * **Write** events
10. Save

### How to verify

1. Upload/delete/download an object in the bucket
2. CloudTrail → **Event history**
3. Filter:

   * Event source: `s3.amazonaws.com`
   * Look for `PutObject`, `GetObject`, etc.

---

# Part 7 — Event Notifications (S3 → SNS/SQS/Lambda)

### Why DevOps uses it

* Trigger automation when a file arrives:

  * CI artifacts uploaded → trigger pipeline
  * Image uploaded → trigger Lambda processing

### Example beginner setup: S3 → SNS Topic

**Step A: Create SNS topic**

1. AWS Console → search **SNS**
2. Click **Topics** → **Create topic**
3. Type: **Standard**
4. Name: `s3-upload-topic`
5. Create

**Step B: Add S3 event notification**

1. Go to S3 bucket → **Properties**
2. Scroll to **Event notifications**
3. Click **Create event notification**
4. Name: `on-upload`
5. **Event types:** select **All object create events**
6. **Destination:** choose **SNS topic**
7. Pick `s3-upload-topic`
8. Save

### How to verify

* In SNS, create a subscription (email) to see messages:

  1. SNS → topic → **Create subscription**
  2. Protocol: **Email**
  3. Enter your email → Create
  4. Confirm email subscription
* Upload a file to S3 → you should get an email notification.

---

# Part 8 — Amazon EventBridge integration

### Why DevOps uses it

* Central event bus routing to many targets (Step Functions, Lambda, SQS)
* Better than many direct S3 notifications when you scale

### Enable (clicks)

1. S3 bucket → **Properties**
2. Scroll to **Amazon EventBridge**
3. Click **Edit**
4. Enable **Send events to EventBridge**
5. Save

### Create a rule (clicks)

1. AWS Console → search **EventBridge**
2. Click **Rules** → **Create rule**
3. Name: `s3-object-created-rule`
4. Event bus: **default**
5. Rule type: **Rule with an event pattern**
6. Event source: **AWS events**
7. **AWS service:** **Simple Storage Service (S3)**
8. **Event type:** **Object Created**
9. (Optional) filter by bucket name (if the UI allows)
10. **Target:** choose **SNS** or **Lambda**
11. Create rule

### Verify

* Upload file → check target receives event (SNS email or Lambda logs)

---

# Part 9 — Transfer Acceleration

### Why DevOps uses it

* Faster global uploads (teams in other countries, large files)

### Enable (clicks)

1. S3 bucket → **Properties**
2. Scroll to **Transfer acceleration**
3. Click **Edit**
4. Choose **Enable**
5. Save

### How to use

* You upload using the accelerate endpoint:

  * `https://<bucketname>.s3-accelerate.amazonaws.com`
* In CLI you can enable accelerate usage in certain tooling (advanced), but for beginners show the concept + endpoint.

---

# Part 10 — Static Website Hosting

### Why DevOps uses it

* Host simple frontend (HTML/JS) cheaply
* Used for training demos and static sites

### Enable (clicks)

1. S3 bucket → **Properties**
2. Scroll to **Static website hosting**
3. Click **Edit**
4. Select **Enable**
5. Hosting type: **Host a static website**
6. **Index document:** `index.html`
7. **Error document:** `error.html`
8. Save

### Upload website files

1. Go to **Objects** tab
2. **Upload**
3. Upload `index.html` and `error.html`

### Make it accessible (IMPORTANT)

Static website needs public read. For a beginner lab you can do it, but explain it’s not recommended for sensitive data.

Option A (simple lab, public bucket policy):

1. Bucket → **Permissions**
2. **Block public access** → **Edit**
3. Uncheck **Block all public access** (lab only)
4. Save (type confirm)
5. Still in **Permissions** → **Bucket policy** → **Edit**
6. Paste (replace bucket name):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForWebsite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::jumptotech-lab-app-bucket-2026/*"
    }
  ]
}
```

7. Save

### How to open it

1. Bucket → **Properties**
2. Static website hosting section shows **Website endpoint**
3. Open that URL in browser

---

# Part 11 — Access Control List (ACL)

### Why DevOps cares

* ACL is legacy. Many companies disable it to avoid confusion and security issues.

### Where to see it / set it

1. Bucket → **Permissions**
2. Scroll to **Access control list (ACL)**

You will often see it disabled/limited when Object Ownership is “Bucket owner enforced”.

---

# Part 12 — CORS (Cross-Origin Resource Sharing)

### Why DevOps uses it

* Frontend hosted on one domain needs to call files from S3 (browser security)
* Common for web apps pulling images/files from S3

### Configure (clicks)

1. Bucket → **Permissions**
2. Scroll to **Cross-origin resource sharing (CORS)**
3. Click **Edit**
4. Paste (beginner example):

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": [],
    "MaxAgeSeconds": 3000
  }
]
```

5. Save

### How to verify

* In real verification you test from a browser app. For beginners: explain “without CORS, browser blocks cross-domain requests.”

---

# Part 13 — Object Ownership (recommended setting)

### Why DevOps uses it

* Prevents “uploaded object is owned by someone else” problems
* Lets you **disable ACLs** and manage permissions with policies only

### Set it (clicks)

1. Bucket → **Permissions**
2. Scroll to **Object Ownership**
3. Click **Edit**
4. Choose **Bucket owner enforced (ACLs disabled)**
5. Save

This is the best practice for most modern setups.

---

# Part 14 — Lifecycle rules (separate example: delete old logs)

You already created one lifecycle rule for tiering. Now add a second rule for cleanup.

### Why DevOps uses it

* Automatically delete junk/old logs to control costs

### Create rule (clicks)

1. Bucket → **Management**
2. **Lifecycle rules** → **Create lifecycle rule**
3. Name: `delete-old-logs`
4. Scope: apply to **prefix** `logs/` (optional) or all objects
5. Actions:

   * Check **Expire current versions of objects**
   * Set **365 days**
6. Create rule

---

# Part 15 — Replication rules (Cross-Region Replication)

### Why DevOps uses it

* Disaster recovery
* Compliance (copy data to another region)

### Requirements

* Versioning must be enabled (you already did)
* Need a destination bucket in another region

### Step A: Create destination bucket

1. S3 → Create bucket
2. Name: `jumptotech-lab-app-bucket-2026-dr`
3. Region: pick another region (example: **us-east-1**)
4. Create bucket
5. Enable **Versioning** on destination bucket too:

   * Destination bucket → Properties → Versioning → Enable

### Step B: Create replication rule

1. Open **source (main) bucket**
2. Go to **Management**
3. Scroll to **Replication rules**
4. Click **Create replication rule**
5. Rule name: `replicate-to-dr`
6. Choose **Entire bucket** (or prefix-based)
7. Destination:

   * Choose **Bucket in another account/this account** (usually this account)
   * Select destination bucket `...-dr`
8. IAM role:

   * Choose **Create new role** (recommended)
9. Encryption:

   * If using SSE-KMS, you must allow replication for KMS (advanced); for beginner lab SSE-S3 is easiest
10. Create rule

### Verify

* Upload a new object to source bucket
* Check destination bucket after a few minutes → object should appear

---

# Part 16 — Inventory configurations

### Why DevOps uses it

* Daily/weekly report of objects (CSV/Parquet)
* Helps audit, cost review, security checks

### Setup (clicks)

1. Bucket → **Management**
2. Scroll to **Inventory configurations**
3. Click **Create inventory configuration**
4. Name: `daily-inventory`
5. Scope: **Current version only** (or include versions)
6. Destination bucket: choose your log bucket (or another inventory bucket)
7. Destination prefix: `inventory/`
8. Frequency: **Daily**
9. Output format: **CSV**
10. Additional fields: select things like Size, Last modified, Storage class (helpful)
11. Create

### Verify

* Inventory file appears later (not immediate). Show students where it will land.

---

# Part 17 — Create an Access Point

### Why DevOps uses it

* Microservices can have **different endpoints + policies** for the same bucket
* Avoids giving broad bucket access

### Create (clicks)

1. S3 Console (left menu) → **Access Points**
2. Click **Create access point**
3. Access point name: `app-uploads-ap`
4. Choose your bucket `jumptotech-lab-app-bucket-2026`
5. Network origin: **Internet** (for lab; VPC-only is production)
6. (Optional) Add an access point policy (example: only allow uploads to `uploads/`)
7. Create

### How to use

* Applications can use the access point ARN/alias rather than the bucket name.
* In IAM, you grant permissions to the access point instead of bucket-wide access (cleaner).

---

# Summary: what DevOps should remember

* **Versioning** = rollback + required for replication
* **Encryption** = compliance
* **Lifecycle + Intelligent-Tiering + Archive** = cost control
* **Access logs + CloudTrail data events** = audit & security
* **Event notifications + EventBridge** = automation
* **Static website hosting + CORS** = frontend hosting & browser access
* **Object ownership (bucket owner enforced)** = best practice, disable ACL confusion
* **Replication** = DR
* **Inventory** = reporting and governance
* **Access points** = microservice-friendly permissions


