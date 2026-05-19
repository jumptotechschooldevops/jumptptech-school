---
title: "Part 4: Decoupled Architecture"
description: "Lab: Serverless “Web + Worker” File Pipeline (API Gateway + Lambda + S3)           ..."
published: 2026-02-27
source: "https://dev.to/jumptotech/part-4-decoupled-architecture-2i0c"
tags: []
---

# Part 4: Decoupled Architecture



# Lab: Serverless “Web + Worker” File Pipeline (API Gateway + Lambda + S3)

## Goal

 build a serverless architecture where:

1. Client calls **API Gateway** endpoint: `POST /presign`
2. **Web Lambda** returns a **presigned S3 PUT URL**
3. Client uploads a file to S3 using the presigned URL into `uploads/`
4. **Worker Lambda** automatically moves the file to `processed/`

### Architecture

Client → API Gateway (HTTP API) → Web Lambda (presign) → S3 (uploads/)
S3 event → Worker Lambda → S3 (processed/)

---

# Part 0 — Prerequisites

* AWS account
* AWS CLI configured (`aws configure`) on Mac
* Python 3 available (`python3 --version`)
* Region: **yours**

**Check your AWS account identity:**

```bash
aws sts get-caller-identity
```

---

# Part 1 — Create S3 Bucket + Folders

1. Create bucket (console):

* S3 → Create bucket
* Name: `student-upload-bucket-<initials>` (example: `student-upload-bucket-aj`)
* Region: **us-east-2**
* Keep defaults

2. Create prefixes (folders):

* In bucket, create folder: `uploads/`
* Create folder: `processed/`

---

# Part 2 — Create Web Lambda (Presign URL Generator)

## 2.1 Create IAM Role for Web Lambda

IAM → Roles → Create role:

* Trusted entity: **Lambda**
* Permissions: create policy or attach inline policy:

Replace BUCKET with your bucket name:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPutToUploadsPrefix",
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::BUCKET/uploads/*"
    }
  ]
}
```

Name role: `lambda-web-presign-role`

## 2.2 Create Lambda Function

Lambda → Create function:

* Name: `web-presign-lambda`
* Runtime: Python 3.10/3.11
* Role: use `lambda-web-presign-role`

## 2.3 Add Environment Variables

Lambda → Configuration → Environment variables:

* `BUCKET_NAME` = `student-upload-bucket-aj` (your bucket)
* `UPLOAD_PREFIX` = `uploads/`
* `EXPIRES_IN` = `300`

## 2.4 Paste Web Lambda Code (Correct / Working)

This version does **NOT** sign Content-Type (prevents SignatureDoesNotMatch).

```python
import json
import os
import uuid
import boto3

BUCKET = os.environ.get("BUCKET_NAME")
PREFIX = os.environ.get("UPLOAD_PREFIX", "uploads/")
EXPIRES_IN = int(os.environ.get("EXPIRES_IN", "300"))

s3 = boto3.client("s3")

def lambda_handler(event, context):
    key = f"{PREFIX}upload-{uuid.uuid4()}.txt"

    upload_url = s3.generate_presigned_url(
        ClientMethod="put_object",
        Params={"Bucket": BUCKET, "Key": key},
        ExpiresIn=EXPIRES_IN
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST"
        },
        "body": json.dumps({"uploadUrl": upload_url, "s3Key": key})
    }
```

Click **Deploy**.

---

# Part 3 — Create API Gateway (HTTP API) and Connect to Web Lambda

## 3.1 Create API Gateway HTTP API

API Gateway → Create API → **HTTP API**

* Name: `presign-upload-api`

## 3.2 Add Integration

* Integration type: **Lambda**
* Choose: `web-presign-lambda`

## 3.3 Create Route

* Route: **POST /presign**
* Attach integration to web lambda

## 3.4 Create Stage

* Stage name: `prod`
* Auto-deploy: Enabled

You will get Invoke URL like:
`https://xxxx.execute-api.us-east-2.amazonaws.com/prod`

---

# Part 4 — Create Worker Lambda (Moves uploads → processed)

## 4.1 Create IAM Role for Worker

IAM Role policy (replace BUCKET):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadUploads",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::BUCKET/uploads/*"
    },
    {
      "Sid": "WriteProcessed",
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::BUCKET/processed/*"
    },
    {
      "Sid": "DeleteUploads",
      "Effect": "Allow",
      "Action": ["s3:DeleteObject"],
      "Resource": "arn:aws:s3:::BUCKET/uploads/*"
    }
  ]
}
```

Role name: `lambda-worker-role`

## 4.2 Create Worker Lambda

Lambda → Create function:

* Name: `worker-move-lambda`
* Runtime: Python 3.x
* Role: `lambda-worker-role`

## 4.3 Worker Lambda Code (S3-triggered)

This runs when a new object is created in `uploads/`.

```python
import boto3
import os
from urllib.parse import unquote_plus

s3 = boto3.client("s3")

PROCESSED_PREFIX = os.environ.get("PROCESSED_PREFIX", "processed/")

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])

        # Only process uploads/
        if not key.startswith("uploads/"):
            print(f"Skipping non-uploads key: {key}")
            continue

        filename = key.split("/", 1)[1]
        new_key = f"{PROCESSED_PREFIX}{filename}"

        print(f"Moving: {key} -> {new_key}")

        # Copy
        s3.copy_object(
            Bucket=bucket,
            CopySource={"Bucket": bucket, "Key": key},
            Key=new_key
        )

        # Delete original
        s3.delete_object(Bucket=bucket, Key=key)

        print(f"Moved successfully: {new_key}")

    return {"status": "ok"}
```

Add environment variable:

* `PROCESSED_PREFIX=processed/`

Deploy.

---

# Part 5 — Add S3 Trigger to Worker Lambda

Lambda → `worker-move-lambda` → Add trigger:

* Trigger: S3
* Bucket: `student-upload-bucket-aj`
* Event type: **All object create events**
* Prefix: `uploads/`
* (Optional) Suffix: `.txt`

Save.

Now worker automatically moves uploads to processed.

---

# Part 6 —  Testing (Correct Extraction + Upload)

## 6.1 Call API Gateway to get presigned URL

Replace INVOKE_URL with yours:

```bash
curl -s -X POST https://YOUR_API_ID.execute-api.us-east-2.amazonaws.com/prod/presign
```

Response example:

```json
{"uploadUrl":"https://...S3...X-Amz-Signature=...","s3Key":"uploads/upload-xxxx.txt"}
```

### Critical rule:

 use **ONLY the uploadUrl** string for PUT.
Do NOT include `", "s3Key": ...`

---

## 6.2 Best method (no copy mistakes): automatically extract URL and upload

```bash
curl -s -X POST https://YOUR_API_ID.execute-api.us-east-2.amazonaws.com/prod/presign > /tmp/presign.json

UPLOAD_URL=$(python3 -c 'import json; print(json.load(open("/tmp/presign.json"))["uploadUrl"])')
S3KEY=$(python3 -c 'import json; print(json.load(open("/tmp/presign.json"))["s3Key"])')

echo "S3KEY=$S3KEY"

curl -i -X PUT "$UPLOAD_URL" --data-binary "hello-$(date +%s)"
```

Expected:

* `HTTP/1.1 200 OK`

---

## 6.3 Verify result

Because worker moves immediately, file might not remain in uploads/.

Check processed:

```bash
aws s3 ls s3://student-upload-bucket-aj/processed/ --region us-east-2 | tail
```

Or search by key ID:

```bash
aws s3 ls s3://student-upload-bucket-aj/ --region us-east-2 --recursive | grep upload-
```

---

# Common  Mistakes (Include these in your lab handout)

### Mistake 1: Calling stage root

Calling:
`/prod`
returns `{"message":"Not Found"}`

Fix: Must call:
`POST /prod/presign`

### Mistake 2: Using GET instead of POST

`curl https://.../prod/presign` (GET) may fail.

Fix:

```bash
curl -X POST https://.../prod/presign
```

### Mistake 3: Copying only the base S3 URL (missing query string)

Wrong:
`https://bucket.s3.amazonaws.com/uploads/file.txt`

Correct:
Must include `?X-Amz-...&X-Amz-Signature=...`

### Mistake 4: URL expired (Expires=300)

If they wait > 5 minutes, upload fails.

Fix: request a new presigned URL.

### Mistake 5: “I uploaded but it’s not in uploads/”

Because worker moved it to `processed/`.

Fix: check `processed/`.



