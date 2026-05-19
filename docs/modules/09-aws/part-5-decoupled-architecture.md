---
title: "Part 5: Decoupled Architecture"
description: "Lab: Enterprise Upgrade — CloudFront + SQS DLQ for Serverless Upload Pipeline           ..."
published: 2026-02-27
source: "https://dev.to/jumptotech/part-5-decoupled-architecture-499f"
tags: []
---

# Part 5: Decoupled Architecture



# Lab: Enterprise Upgrade — CloudFront + SQS DLQ for Serverless Upload Pipeline

## Starting point (your current working lab)

* **HTTP API Gateway** route: `POST /presign`
* **Web Lambda** returns presigned **PUT** URL to S3 `uploads/`
* Client uploads to S3 `uploads/`
* **Worker Lambda** moves file to `processed/`

We will add:

1. **CloudFront** for fast + secure download of `processed/`
2. **SQS + DLQ** between S3 and Worker for reliability + reprocessing

---

# Part A — Add CloudFront (CDN) for processed downloads

## Why DevOps does this

* **Performance:** CloudFront caches globally, faster downloads.
* **Security:** Keep S3 bucket private; CloudFront is the only reader.
* **Scalability:** Offloads S3 and handles spikes (enterprise traffic).

## What you will achieve

After worker moves objects to `processed/`, students can download via:

`https://<cloudfront-domain>/processed/<file>`

### A1) Create CloudFront Distribution (with OAC)

1. Go to **CloudFront → Create distribution**
2. **Origin**

   * Origin domain: select your bucket `student-upload-bucket-aj`
   * Origin access: choose **Origin access control (OAC)**
   * Click **Create new OAC**
   * Save
3. **Default cache behavior**

   * Viewer protocol policy: **Redirect HTTP to HTTPS**
   * Allowed HTTP methods: **GET, HEAD**
   * Cache policy: **CachingOptimized**
4. Create distribution

✅ Output: CloudFront gives you a domain like `dxxxx.cloudfront.net`

### A2) Lock S3 bucket so ONLY CloudFront can read (OAC bucket policy)

1. Open the new distribution details.
2. Find the OAC section where CloudFront offers a button like **“Copy policy”** (or instructions).
3. Go to **S3 → your bucket → Permissions → Bucket policy**
4. Paste the policy CloudFront provides and **Save**.

✅ Result:

* S3 stays private
* Only CloudFront can read objects

### A3) Test CloudFront download

After you upload a file and worker moves it to `processed/`, test:

```bash
aws s3 ls s3://student-upload-bucket-aj/processed/ --region us-east-2 | tail
```

Pick one processed filename, then open in browser:

`https://dxxxx.cloudfront.net/processed/<filename>`

**Tip for teaching:** CloudFront caching can take a minute the first time. After that it’s fast.

---

# Part B — Add SQS + DLQ (decouple + reliability)

## Why DevOps does this

Enterprise reason: **don’t lose events**, and don’t overload workers.

* **Buffering:** SQS holds events if worker is slow/down.
* **Retries:** automatic retries if Lambda fails.
* **DLQ:** after N failures, messages go to DLQ (no silent loss).
* **Reprocessing:** DevOps can inspect DLQ messages and replay them after a fix.

## What you will change

Instead of:

* S3 → Worker Lambda directly

You will use:

* S3 → **SQS main queue** → Worker Lambda
* failures → **DLQ**

---

## B1) Create SQS queues (Main + DLQ)

Go to **SQS → Create queue**:

### Create DLQ first

* Type: Standard
* Name: `uploads-dlq`

Create.

### Create Main queue

* Type: Standard
* Name: `uploads-queue`
* Open “Dead-letter queue” section:

  * Enable DLQ
  * Choose `uploads-dlq`
  * Set **maxReceiveCount = 3** (good for lab)

Create.

**What maxReceiveCount=3 means**

* If your worker fails to process a message 3 times, it goes to DLQ.

---

## B2) Configure S3 bucket to send events to SQS

Go to **S3 → bucket → Properties → Event notifications → Create event notification**

* Name: `uploads-to-sqs`
* Event type: **All object create events**
* Prefix filter: `uploads/`
* Destination: **SQS queue**
* Select: `uploads-queue`

Save.

---

## B3) Allow S3 to send messages to SQS (Queue Policy)

S3 cannot send to SQS unless SQS allows it.

Go to **SQS → uploads-queue → Access policy** and add a policy like this
(replace placeholders):

* `YOUR_ACCOUNT_ID` = your account (example: `021399177326`)
* `YOUR_BUCKET_NAME` = `student-upload-bucket-aj`
* `YOUR_QUEUE_ARN` = from queue details

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3SendMessage",
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "sqs:SendMessage",
      "Resource": "YOUR_QUEUE_ARN",
      "Condition": {
        "StringEquals": { "aws:SourceAccount": "YOUR_ACCOUNT_ID" },
        "ArnLike": { "aws:SourceArn": "arn:aws:s3:::YOUR_BUCKET_NAME" }
      }
    }
  ]
}
```

Save.

---

## B4) Connect Worker Lambda to SQS

Go to **Lambda → worker-move-lambda → Add trigger**

* Trigger: **SQS**
* Choose queue: `uploads-queue`
* Batch size: 1 (good for learning)
* Enable trigger

Save.

---

## B5) IMPORTANT: Remove the old S3 trigger from worker

If you leave it, you’ll process twice.

Go to **Lambda → worker-move-lambda → Triggers**

* Remove the direct **S3 trigger**
* Keep only **SQS trigger**

---

## B6) Update Worker Lambda code (SQS event format)

SQS message body coming from S3 event contains the S3 event JSON. Your worker must parse it.

Use this worker code (Python) for SQS-triggered worker:

```python
import json
import boto3
from urllib.parse import unquote_plus

s3 = boto3.client("s3")

DEST_PREFIX = "processed/"

def lambda_handler(event, context):
    for record in event["Records"]:
        # SQS message body contains the S3 event as JSON string
        body = json.loads(record["body"])

        # body is an S3 event notification structure
        for s3rec in body.get("Records", []):
            bucket = s3rec["s3"]["bucket"]["name"]
            key = unquote_plus(s3rec["s3"]["object"]["key"])

            if not key.startswith("uploads/"):
                print(f"Skip non-uploads key: {key}")
                continue

            filename = key.split("/", 1)[1]
            new_key = f"{DEST_PREFIX}{filename}"

            print(f"Move {bucket}/{key} -> {bucket}/{new_key}")

            # Copy to processed
            s3.copy_object(
                Bucket=bucket,
                CopySource={"Bucket": bucket, "Key": key},
                Key=new_key
            )

            # Delete original from uploads
            s3.delete_object(Bucket=bucket, Key=key)

            print(f"Moved OK: {new_key}")

    return {"status": "ok"}
```

### Worker Lambda IAM permissions (must have)

Your worker role needs:

* `s3:GetObject` on `uploads/*`
* `s3:PutObject` on `processed/*`
* `s3:DeleteObject` on `uploads/*`

(You already had this from your previous worker—keep it.)

Also, when Lambda reads from SQS, AWS usually auto-manages needed permissions when you attach SQS trigger. If not, ensure the Lambda execution role includes:

* `sqs:ReceiveMessage`
* `sqs:DeleteMessage`
* `sqs:GetQueueAttributes`

---

# Part C — Testing the full enterprise pipeline

## C1) Get a presigned upload URL

```bash
curl -s -X POST https://YOUR_API_ID.execute-api.us-east-2.amazonaws.com/prod/presign > /tmp/presign.json
cat /tmp/presign.json
```

Extract values:

```bash
UPLOAD_URL=$(python3 -c 'import json; print(json.load(open("/tmp/presign.json"))["uploadUrl"])')
S3KEY=$(python3 -c 'import json; print(json.load(open("/tmp/presign.json"))["s3Key"])')
echo "S3KEY=$S3KEY"
```

## C2) Upload to S3 using presigned URL

```bash
curl -i -X PUT "$UPLOAD_URL" --data-binary "hello-$(date +%s)"
```

Expected: `HTTP/1.1 200 OK`

## C3) Confirm it moved to processed

Because worker moves it, uploads may be empty quickly.

Search:

```bash
aws s3 ls s3://student-upload-bucket-aj/ --region us-east-2 --recursive | grep "$(echo $S3KEY | awk -F/ '{print $2}')"
```

Or list processed:

```bash
aws s3 ls s3://student-upload-bucket-aj/processed/ --region us-east-2 | tail
```

## C4) Download via CloudFront

Open:
`https://<cloudfront-domain>/processed/<filename>`

---

# Part D — DLQ Demo (Teach students why it matters)

## D1) Force a failure

Temporarily break worker code (example: change `DEST_PREFIX = "processed/"` to `"processedx/"` but IAM doesn’t allow it) or raise an error:

```python
raise Exception("Lab test failure")
```

Upload a file again. Worker fails.

## D2) Watch retries and DLQ

* SQS main queue: message will retry
* After **3 receives**, message goes to DLQ

Check DLQ messages:
SQS → `uploads-dlq` → “Send and receive messages” → **Poll**

Explain to students:

* This is how enterprise systems avoid silent data loss.
* DevOps monitors DLQ and sets alarms.

## D3) Reprocess (enterprise ops)

After fixing code:

* move message back from DLQ to main queue (console) or re-drive policy (advanced)
* re-run processing

---

# Part E — What DevOps is responsible for (talk-track)

Use this in your class:

1. **Security**

* S3 private + CloudFront OAC
* Least privilege IAM roles for Lambdas
* Short-lived presigned URLs

2. **Reliability**

* SQS buffering so spikes don’t break worker
* DLQ to catch “poison messages”
* Ability to reprocess after fixing bugs

3. **Scalability**

* Lambda auto scales
* SQS absorbs bursts
* CloudFront scales downloads

4. **Observability**

* CloudWatch logs for worker + web Lambda
* Queue depth monitoring
* DLQ alarms




