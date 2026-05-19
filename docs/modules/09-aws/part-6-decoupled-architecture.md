---
title: "Part 6: Decoupled Architecture"
description: "Target Architecture     Client authenticates with Cognito → gets JWT token  Client calls API..."
published: 2026-03-03
source: "https://dev.to/jumptotech/part-6-decoupled-architecture-3jcb"
tags: []
---

# Part 6: Decoupled Architecture



# Target Architecture

1. **Client** authenticates with **Cognito** → gets **JWT token**
2. Client calls **API Gateway /uploads** with **Authorization: Bearer <JWT>**
3. API Gateway invokes **Lambda Upload Handler**
4. Lambda stores file/metadata to **S3 (uploads/...)**
5. Lambda publishes an event to **Kinesis Data Stream**
6. **Kinesis Consumer Lambda** processes and writes to **S3 (processed/...)** (or DynamoDB, etc.)

This avoids extra moving parts and makes Kinesis actually useful.

---

# Part A — Create Cognito (User Pool) and Protect API Gateway

## A1) Create a Cognito User Pool

AWS Console → **Cognito** → **Create user pool**

* Sign-in options: **Email**
* MFA: optional (you can enable later)
* App integration:

  * Create **App client** (no client secret for browser/mobile; for your curl tests it’s also easier without secret)
* Create pool

Write down:

* **User Pool ID** (example: `us-east-2_XXXX`)
* **App Client ID**

## A2) Create a test user

Cognito → Your User Pool → **Users** → **Create user**

* Email + temporary password
* Then you’ll set a new password on first login (or create with “permanent password” if you want).

---

## A3) Add Cognito Authorizer in API Gateway

API Gateway → your HTTP API (or REST API)

### If you use **HTTP API**

* **Authorization** → Create **JWT authorizer**

  * Issuer URL:

    * `https://cognito-idp.<region>.amazonaws.com/<USER_POOL_ID>`
  * Audience:

    * `<APP_CLIENT_ID>`
* Attach authorizer to route **POST /uploads**

### If you use **REST API**

* Create **Cognito User Pool Authorizer**
* Attach to method **POST /uploads** and enable authorization

Deploy API.

---

## A4) Test login to get JWT (from your Mac)

Use AWS CLI “cognito-idp” to authenticate and get an **IdToken**.

```bash
REGION="us-east-2"
CLIENT_ID="YOUR_APP_CLIENT_ID"
USERNAME="your-email@example.com"
PASSWORD="YourPermanentPassword"

aws cognito-idp initiate-auth \
  --region "$REGION" \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id "$CLIENT_ID" \
  --auth-parameters USERNAME="$USERNAME",PASSWORD="$PASSWORD"
```

From output, copy:

* `AuthenticationResult.IdToken`  (this is your JWT)

Now test API Gateway with auth header:

```bash
API="https://YOUR_API_ID.execute-api.us-east-2.amazonaws.com/uploads"
TOKEN="PASTE_ID_TOKEN_HERE"

curl -i -X POST "$API" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"filename":"test.txt","content":"hello from cognito"}'
```

If you see **401**, the authorizer settings (issuer/audience) or route attachment is wrong.

---

# Part B — Create Kinesis Stream

## B1) Create Data Stream

AWS Console → **Kinesis** → **Data streams** → Create

* Name: `uploads-stream`
* Capacity mode: **On-demand** (simplest for lab)

---

# Part C — Update Upload Lambda to Publish to Kinesis

## C1) Add IAM Permission to Upload Lambda Role

IAM → Roles → your upload lambda role → Add permissions:

Minimum policy (adjust region/account/stream name):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PutToKinesis",
      "Effect": "Allow",
      "Action": ["kinesis:PutRecord", "kinesis:PutRecords"],
      "Resource": "arn:aws:kinesis:us-east-2:YOUR_ACCOUNT_ID:stream/uploads-stream"
    }
  ]
}
```

(Keep your existing S3 permissions.)

---

## C2) Update Lambda Code (Node.js example)

In your **Upload Handler Lambda**, after writing to S3, send metadata to Kinesis.

```js
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { KinesisClient, PutRecordCommand } from "@aws-sdk/client-kinesis";
import crypto from "crypto";

const s3 = new S3Client({});
const kinesis = new KinesisClient({});

const UPLOAD_BUCKET = process.env.UPLOAD_BUCKET;
const STREAM_NAME = process.env.STREAM_NAME;

export const handler = async (event) => {
  // For HTTP API, body is JSON string
  const body = event.body ? JSON.parse(event.body) : {};
  const filename = body.filename || `file-${Date.now()}.txt`;
  const content = body.content || "empty";

  const key = `uploads/${filename}`;

  // 1) Save to S3
  await s3.send(new PutObjectCommand({
    Bucket: UPLOAD_BUCKET,
    Key: key,
    Body: content,
    ContentType: "text/plain"
  }));

  // 2) Publish event to Kinesis
  const record = {
    bucket: UPLOAD_BUCKET,
    key,
    uploadedAt: new Date().toISOString(),
    requestId: event.requestContext?.requestId,
    userSub: event.requestContext?.authorizer?.jwt?.claims?.sub // HTTP API JWT authorizer
  };

  await kinesis.send(new PutRecordCommand({
    StreamName: STREAM_NAME,
    PartitionKey: crypto.randomUUID(),
    Data: Buffer.from(JSON.stringify(record))
  }));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Uploaded and queued for processing",
      s3: { bucket: UPLOAD_BUCKET, key }
    })
  };
};
```

### Set Lambda environment variables

Lambda → Configuration → Environment variables:

* `UPLOAD_BUCKET` = your uploads bucket name
* `STREAM_NAME` = `uploads-stream`

Deploy.

---

# Part D — Create Kinesis Consumer Lambda (Processor)

## D1) Create a new Lambda: `kinesis-processor`

Runtime: Node.js (or Python)

Permissions needed:

* Read from Kinesis
* Write to processed S3 bucket (or DynamoDB)

Example IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadKinesis",
      "Effect": "Allow",
      "Action": [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListShards"
      ],
      "Resource": "arn:aws:kinesis:us-east-2:YOUR_ACCOUNT_ID:stream/uploads-stream"
    },
    {
      "Sid": "S3ReadWrite",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": [
        "arn:aws:s3:::YOUR_UPLOAD_BUCKET/*",
        "arn:aws:s3:::YOUR_PROCESSED_BUCKET/*"
      ]
    }
  ]
}
```

## D2) Add Event Source Mapping (Kinesis → Lambda)

Lambda → `kinesis-processor` → **Add trigger** → Kinesis

* Stream: `uploads-stream`
* Batch size: 10 (default OK)
* Starting position: **LATEST**

---

## D3) Processor Lambda Code (Node.js example)

This reads Kinesis records, fetches from S3, writes “processed” output to another bucket/prefix.

```js
import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({});
const PROCESSED_BUCKET = process.env.PROCESSED_BUCKET;

const streamToString = async (readable) => {
  const chunks = [];
  for await (const chunk of readable) chunks.push(chunk);
  return Buffer.concat(chunks).toString("utf-8");
};

export const handler = async (event) => {
  for (const r of event.Records) {
    const payload = JSON.parse(Buffer.from(r.kinesis.data, "base64").toString("utf-8"));

    const { bucket, key } = payload;

    // Read uploaded object
    const obj = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
    const content = await streamToString(obj.Body);

    // "Process" (simple example)
    const processed = content.toUpperCase();

    // Write processed object
    const outKey = key.replace("uploads/", "processed/");
    await s3.send(new PutObjectCommand({
      Bucket: PROCESSED_BUCKET,
      Key: outKey,
      Body: processed,
      ContentType: "text/plain"
    }));
  }

  return { ok: true };
};
```

Set env var:

* `PROCESSED_BUCKET` = your processed bucket name (or same bucket, different prefix)

---

# Part E — End-to-End Test

1. Get JWT token (A4)
2. Call API:

```bash
curl -i -X POST "$API" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"filename":"demo.txt","content":"hello kinesis"}'
```

3. Verify:

* S3 has `uploads/demo.txt`
* Kinesis stream has incoming records (Monitoring metrics)
* Processor Lambda logs show it ran
* S3 has `processed/demo.txt` (content becomes `HELLO KINESIS`)

---

# Common Issues (Fast Fixes)

* **401 Unauthorized**: authorizer not attached to route/method OR issuer/audience wrong.
* **Lambda can’t PutRecord**: missing `kinesis:PutRecord` permission OR wrong stream ARN/region.
* **Processor not triggering**: event source mapping disabled or starting position wrong.
* **S3 AccessDenied**: processor role missing `s3:GetObject` or `s3:PutObject`.


