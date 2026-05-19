# Lecture 4 · S3 — Simple Storage Service

S3 is AWS's object storage service. It stores files (objects) in containers (buckets) and is the backbone of data pipelines, static websites, backups, and application assets. S3 is one of the most tested services on the SAA-C04 exam.

---

## Fundamentals

### Objects and buckets

- An **object** is a file plus metadata. Max object size: 5 TB. Objects above 5 GB must use multipart upload.
- A **bucket** is a globally uniquely named container in a specific region.
- The **key** is the full path of an object within a bucket: `images/2024/logo.png`

S3 is flat — there are no real directories. The `/` in keys is a UI convention that the console renders as folders.

```bash
# Create a bucket (bucket names must be globally unique)
aws s3 mb s3://my-app-assets-prod-123456

# Upload a file
aws s3 cp logo.png s3://my-app-assets-prod-123456/images/logo.png

# List objects
aws s3 ls s3://my-app-assets-prod-123456/images/

# Sync a directory
aws s3 sync ./dist s3://my-app-assets-prod-123456/ --delete
```

### S3 URLs

```
# Path-style (being deprecated)
https://s3.amazonaws.com/bucket-name/key

# Virtual-hosted-style (preferred)
https://bucket-name.s3.amazonaws.com/key
https://bucket-name.s3.us-east-1.amazonaws.com/key
```

---

## Storage classes

Choose the storage class based on access frequency and retrieval requirements.

| Class | Use case | Retrieval | Min duration | Cost (approx) |
|-------|---------|-----------|--------------|--------------|
| Standard | Frequently accessed | Milliseconds | None | $0.023/GB |
| Intelligent-Tiering | Unknown/changing access | Milliseconds | None | $0.023/GB + monitoring fee |
| Standard-IA | Infrequent, rapid retrieval | Milliseconds | 30 days | $0.0125/GB |
| One Zone-IA | Infrequent, single AZ OK | Milliseconds | 30 days | $0.01/GB |
| Glacier Instant Retrieval | Archives, quarterly access | Milliseconds | 90 days | $0.004/GB |
| Glacier Flexible Retrieval | Archives, hours OK | 1–12 hours | 90 days | $0.0036/GB |
| Glacier Deep Archive | Long-term archives | 12–48 hours | 180 days | $0.00099/GB |

**Intelligent-Tiering** automatically moves objects between tiers based on access patterns. It has a small monitoring fee per object per month but no retrieval fees. Use it when you can't predict access patterns.

**One Zone-IA**: data lives in a single AZ. If that AZ fails, data is lost. Acceptable for reproducible data (thumbnails, derived artifacts).

---

## Versioning

Versioning keeps all versions of an object in a bucket. Once enabled it cannot be disabled (only suspended).

```bash
# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# List all versions
aws s3api list-object-versions --bucket my-bucket --prefix images/logo.png

# Download a specific version
aws s3api get-object \
  --bucket my-bucket \
  --key images/logo.png \
  --version-id "v3xyzABC" \
  logo-v3.png
```

Deleting a versioned object places a **delete marker** — the object is hidden but all versions remain. To permanently delete, you must delete a specific version ID.

Versioning is required for:
- Cross-region replication
- S3 Object Lock (WORM)

---

## Lifecycle policies

Lifecycle policies automatically transition or expire objects based on age.

```json
{
  "Rules": [
    {
      "Id": "archive-old-logs",
      "Status": "Enabled",
      "Filter": { "Prefix": "logs/" },
      "Transitions": [
        { "Days": 30,  "StorageClass": "STANDARD_IA" },
        { "Days": 90,  "StorageClass": "GLACIER_IR" },
        { "Days": 365, "StorageClass": "DEEP_ARCHIVE" }
      ],
      "Expiration": { "Days": 2555 }
    }
  ]
}
```

This moves log files from Standard to IA after 30 days, to Glacier after 90 days, to Deep Archive after 365 days, and deletes them after 7 years — a common compliance pattern.

---

## Replication

### Cross-Region Replication (CRR)

Copies objects from a source bucket in one region to a destination bucket in another region asynchronously. Requires versioning enabled on both buckets.

Use cases: disaster recovery, reduce latency for distant users, comply with data residency.

### Same-Region Replication (SRR)

Copies within the same region. Use for: log aggregation from multiple accounts into one, maintain a live copy in a separate account for compliance.

---

## Security

S3 is private by default. All objects are inaccessible publicly unless you explicitly grant access.

### Bucket policies

Resource-based JSON policies attached to the bucket. They apply to all objects in the bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForWebsite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website-bucket/*"
    }
  ]
}
```

Denying all access except from a specific VPC endpoint:

```json
{
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Resource": [
    "arn:aws:s3:::my-private-bucket",
    "arn:aws:s3:::my-private-bucket/*"
  ],
  "Condition": {
    "StringNotEquals": {
      "aws:SourceVpce": "vpce-0abc123"
    }
  }
}
```

### Block Public Access

A safety net that overrides any bucket policy or ACL that would make objects public. Enable it on all buckets that should not be public (which is most buckets).

```bash
aws s3api put-public-access-block \
  --bucket my-private-bucket \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

Enable it at the account level to prevent any bucket in the account from being made public accidentally.

### Pre-signed URLs

Generate a time-limited URL that grants temporary access to a private object without changing the bucket policy.

```bash
# URL valid for 1 hour
aws s3 presign s3://my-bucket/report.pdf --expires-in 3600
```

Use this to give users direct download links without proxying through your server, or to allow uploads to specific keys from a browser.

### Access Control Lists (ACLs)

Legacy mechanism — prefer bucket policies. ACLs can grant access to specific AWS accounts or predefined groups (AllUsers, AuthenticatedUsers). With Block Public Access enabled, ACLs granting public access are ignored.

---

## Encryption

### Server-side encryption (SSE)

Objects are encrypted at rest. S3 decrypts transparently when you read.

| Type | Key management |
|------|---------------|
| SSE-S3 (AES-256) | AWS manages keys automatically |
| SSE-KMS | You control keys via KMS (audit trail, key rotation) |
| SSE-C | You provide the key with each request (AWS doesn't store it) |
| DSSE-KMS | Dual-layer KMS encryption (compliance requirements) |

Default encryption: you can set a default encryption configuration on a bucket. Any new object without an explicit encryption header will use the bucket default.

```bash
aws s3api put-bucket-encryption \
  --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789012:key/abc-123"
      },
      "BucketKeyEnabled": true
    }]
  }'
```

**Bucket Key**: reduces KMS API calls (and cost) by generating a short-lived data key per bucket rather than per object.

### Client-side encryption

You encrypt data before sending it to S3. AWS never sees the plaintext. Use the AWS Encryption SDK or implement your own scheme. Required when you need end-to-end encryption guarantees.

---

## Static website hosting

S3 can serve static websites (HTML, CSS, JS, images) directly:

1. Enable static website hosting on the bucket
2. Set the index document (`index.html`) and error document (`404.html`)
3. Add a bucket policy allowing public `s3:GetObject`
4. Use the website endpoint: `http://bucket-name.s3-website-us-east-1.amazonaws.com`

The S3 website endpoint does not support HTTPS. For HTTPS, front it with CloudFront (see Lab 3).

---

## S3 Transfer Acceleration

Routes uploads through CloudFront edge locations for faster long-distance transfers. The file travels over AWS's private network backbone from the nearest edge location to S3.

Enable per-bucket:
```bash
aws s3api put-bucket-accelerate-configuration \
  --bucket my-bucket \
  --accelerate-configuration Status=Enabled
```

Then use the accelerated endpoint: `bucket-name.s3-accelerate.amazonaws.com`

Useful when your users upload from across the world to a single-region bucket.

---

## S3 Select and Glacier Select

Query structured data inside objects (CSV, JSON, Parquet) with SQL without downloading the entire object:

```bash
aws s3api select-object-content \
  --bucket my-bucket \
  --key data/sales.csv \
  --expression "SELECT * FROM S3Object WHERE revenue > 10000" \
  --expression-type SQL \
  --input-serialization '{"CSV": {"FileHeaderInfo": "Use"}}' \
  --output-serialization '{"CSV": {}}' \
  output.csv
```

Reduces data transfer and costs when you only need a subset of a large file.

!!! tip "Exam tip"
    S3 is eventually consistent for overwrite PUTs and DELETEs in versioned buckets, but provides **strong read-after-write consistency** for new object uploads. If a question asks what happens immediately after `PUT object` — you will read the new version. This changed in December 2020; some old resources still describe eventual consistency.

!!! tip "Exam tip"
    Know the difference between SSE-S3, SSE-KMS, and SSE-C. Questions about key auditing/rotation → SSE-KMS. Questions about controlling keys without AWS having access → SSE-C. Questions about simplest encryption → SSE-S3.

!!! tip "Exam tip"
    For cost optimisation with variable access patterns, **S3 Intelligent-Tiering** is almost always the correct answer. It has no retrieval fees and automatically moves objects.
