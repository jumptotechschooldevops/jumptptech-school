# Lecture 8 · Security & Encryption

Security is 30% of the SAA-C04 exam. AWS gives you the building blocks to encrypt everything, audit everything, and detect threats automatically. This lecture covers the services that implement security controls in a real production account.

---

## KMS (Key Management Service)

KMS is a managed service for creating and controlling cryptographic keys. It is the foundation of encryption across AWS services.

### Key types

| Key type | Who manages it | Use case |
|----------|---------------|---------|
| AWS managed key | AWS | Default encryption for S3, EBS, RDS (key name: `aws/s3`, `aws/ebs`) |
| Customer managed key (CMK) | You | Custom key policies, rotation control, cross-account use |
| Imported key material | You bring the key | Compliance requirements where you must own the raw key bytes |

### Key policies

Every KMS key has a resource-based policy that controls who can use and manage it:

```json
{
  "Statement": [
    {
      "Sid": "Enable root account administration",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:root"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow EC2 use for EBS encryption",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:role/ec2-role"},
      "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
      "Resource": "*"
    }
  ]
}
```

### Envelope encryption

KMS does not encrypt your data directly — it encrypts a **data key** that encrypts your data. This is envelope encryption:

```
1. Call KMS: GenerateDataKey(KeyId)
   → KMS returns: plaintext data key + encrypted data key

2. Use plaintext data key to encrypt your data locally
3. Store: encrypted data key alongside encrypted data
4. Discard plaintext data key from memory

To decrypt:
1. Send encrypted data key to KMS: Decrypt
   → KMS returns plaintext data key
2. Use plaintext data key to decrypt data locally
```

This pattern is efficient: KMS only handles key operations, not bulk data encryption. Bulk encryption/decryption happens in your application using the data key.

### Key rotation

```bash
# Enable automatic annual rotation
aws kms enable-key-rotation --key-id arn:aws:kms:us-east-1:123456789012:key/abc-123

# Manual rotation: create a new key, update all services to use new key
# Old key is disabled (not deleted) so old ciphertext can still be decrypted
```

Automatic rotation creates a new key material but keeps the same key ID. Old versions are retained to decrypt old data.

### Cross-region

KMS keys are regional. For cross-region encryption:
- **Multi-region keys** (replicated): same key material in multiple regions, share a key ID prefix
- **Copy and re-encrypt**: copy a snapshot cross-region and re-encrypt with a key in the target region

---

## Secrets Manager

Secrets Manager stores and manages secrets (database passwords, API keys, tokens) with automatic rotation.

```bash
# Store a secret
aws secretsmanager create-secret \
  --name prod/myapp/db-password \
  --secret-string '{"username":"admin","password":"s3cr3t"}'

# Retrieve in application
import boto3
import json

client = boto3.client('secretsmanager')
response = client.get_secret_value(SecretId='prod/myapp/db-password')
secret = json.loads(response['SecretString'])
db_password = secret['password']
```

### Automatic rotation

Secrets Manager can rotate secrets automatically using a Lambda function. AWS provides rotation Lambda functions for RDS, Redshift, and DocumentDB out of the box.

```bash
aws secretsmanager rotate-secret \
  --secret-id prod/myapp/db-password \
  --rotation-lambda-arn arn:aws:lambda:...:function:SecretsManagerRotation \
  --rotation-rules AutomaticallyAfterDays=30
```

### Secrets Manager vs SSM Parameter Store

| | Secrets Manager | SSM Parameter Store |
|--|----------------|---------------------|
| Cost | $0.40/secret/month | Free (standard), $0.05/parameter/month (advanced) |
| Rotation | Built-in, automatic | Manual (invoke Lambda yourself) |
| Cross-account | Yes (resource policy) | No |
| KMS integration | Always | Optional |
| Best for | Credentials needing rotation | Config values, feature flags |

Use Secrets Manager for credentials. Use Parameter Store for non-sensitive config and for cost-sensitive workloads with many small values.

---

## SSM Parameter Store

Parameter Store stores configuration data hierarchically:

```bash
# Store parameters
aws ssm put-parameter \
  --name /myapp/prod/database/host \
  --value "mydb.cluster.us-east-1.rds.amazonaws.com" \
  --type String

aws ssm put-parameter \
  --name /myapp/prod/database/password \
  --value "s3cr3t" \
  --type SecureString \  # Encrypted with KMS
  --key-id alias/myapp-key

# Get all parameters for an app/environment
aws ssm get-parameters-by-path \
  --path /myapp/prod/ \
  --with-decryption \
  --recursive
```

Lambda, ECS, and EC2 can fetch parameters at runtime using IAM permissions — no secrets baked into code or environment variables in the task definition.

---

## ACM (AWS Certificate Manager)

ACM provisions and renews TLS/SSL certificates for use with:
- ALB and NLB
- API Gateway
- CloudFront
- Elastic Beanstalk

```bash
# Request a public certificate
aws acm request-certificate \
  --domain-name example.com \
  --subject-alternative-names "*.example.com" \
  --validation-method DNS

# ACM adds a CNAME record to Route 53 for validation
# Once validated, the certificate auto-renews
```

ACM public certificates are free. The private key never leaves AWS — you cannot export it. Use ACM Private CA if you need certificates for internal services.

---

## WAF (Web Application Firewall)

WAF filters HTTP traffic at Layer 7. You create rules that inspect requests and allow, block, or count them.

Common rule types:
- **IP set rules**: block/allow specific IP ranges
- **Rate-based rules**: block IPs sending more than N requests per 5-minute window (DDoS mitigation)
- **Managed rule groups**: AWS and third-party pre-built rules (OWASP Top 10, known bad IPs, bot detection)
- **Custom rules**: match any request attribute (URI, headers, body, query string)

WAF integrates with: CloudFront, ALB, API Gateway, AppSync.

```bash
# Create a rate-based rule: block IPs making > 1000 req/5min
aws wafv2 create-web-acl \
  --name my-web-acl \
  --scope CLOUDFRONT \
  --default-action Allow={} \
  --rules '[{
    "Name": "RateLimit",
    "Priority": 1,
    "Action": {"Block": {}},
    "Statement": {
      "RateBasedStatement": {
        "Limit": 1000,
        "AggregateKeyType": "IP"
      }
    },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "RateLimit"
    }
  }]' \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=my-acl
```

---

## Shield

AWS Shield provides DDoS protection.

- **Shield Standard**: automatically included for all AWS customers, at no cost. Protects against common Layer 3/4 DDoS attacks (SYN floods, UDP reflection).
- **Shield Advanced**: paid ($3,000/month). Protects against larger, more sophisticated attacks. Includes:
  - 24/7 access to AWS DDoS Response Team
  - Financial protection against scaled-up charges during an attack
  - Advanced detection for EC2, ELB, CloudFront, Route 53, Global Accelerator

For most workloads, Shield Standard plus WAF is sufficient.

---

## GuardDuty

GuardDuty is a threat detection service that continuously analyses:
- CloudTrail logs (API activity)
- VPC Flow Logs (network traffic)
- DNS logs (domain queries)
- S3 data events (object-level activity)
- EKS audit logs

It uses ML and threat intelligence to identify:
- Unusual API calls from unexpected locations
- Compromised credentials (calls from known malicious IPs)
- EC2 instances communicating with C&C servers
- Bitcoin mining activity
- S3 bucket exfiltration patterns

Enable it with a single API call — no infrastructure to deploy:

```bash
aws guardduty create-detector --enable
```

GuardDuty findings appear in the console and can trigger EventBridge rules to automate response (isolate instance, revoke credentials, etc.).

---

## CloudTrail

CloudTrail records every API call made to your AWS account — who did what, when, from where.

```json
{
  "eventTime": "2024-11-15T14:22:33Z",
  "userIdentity": {
    "type": "IAMUser",
    "arn": "arn:aws:iam::123456789012:user/alice"
  },
  "eventName": "DeleteBucket",
  "requestParameters": {"bucketName": "prod-data"},
  "sourceIPAddress": "203.0.113.5",
  "userAgent": "aws-cli/2.x"
}
```

### Configuration

```bash
# Create a trail that delivers logs to S3
aws cloudtrail create-trail \
  --name org-trail \
  --s3-bucket-name cloudtrail-logs-123456789012 \
  --is-multi-region-trail \
  --enable-log-file-validation

aws cloudtrail start-logging --name org-trail
```

Enable **log file validation** — it creates a digest file that lets you prove logs have not been tampered with (required for many compliance frameworks).

**Management events** (free): API calls that manage AWS resources (CreateBucket, RunInstances, etc.)
**Data events** (charged): object-level operations on S3 and Lambda invocations. Enable these if you need to audit who accessed which S3 objects.

---

## AWS Config

Config continuously records the configuration of your AWS resources and evaluates them against rules.

Unlike CloudTrail (who did what), Config answers: **what does my infrastructure look like right now, and has it drifted from policy?**

Example managed rules:
- `encrypted-volumes`: all EBS volumes must be encrypted
- `s3-bucket-public-read-prohibited`: no S3 bucket may be publicly readable
- `restricted-ssh`: security groups must not allow SSH from 0.0.0.0/0
- `rds-multi-az-support`: all RDS instances must have Multi-AZ enabled

Config rules can trigger automatic remediation via SSM Automation documents:

```bash
aws configservice put-remediation-configurations \
  --remediation-configurations '[{
    "ConfigRuleName": "s3-bucket-public-read-prohibited",
    "TargetType": "SSM_DOCUMENT",
    "TargetId": "AWS-DisableS3BucketPublicReadWrite",
    "Automatic": true
  }]'
```

---

## Inspector

Amazon Inspector automatically scans:
- EC2 instances for OS vulnerabilities (CVEs) and network exposure
- ECR container images for software vulnerabilities
- Lambda functions for package vulnerabilities

It generates findings with severity scores. Integrate with Security Hub to aggregate findings across accounts.

---

## Security Hub

Aggregates security findings from GuardDuty, Inspector, Macie, Config, Firewall Manager, and third-party tools into a single dashboard. Scores your account against security standards (CIS AWS Foundations, AWS Foundational Security Best Practices, PCI DSS).

---

## Macie

Macie uses ML to discover, classify, and protect sensitive data (PII, credit card numbers, credentials) in S3. It identifies buckets with sensitive data that are publicly accessible or unencrypted.

!!! tip "Exam tip"
    Know the difference between these services: **CloudTrail** = who made API calls. **AWS Config** = what is the current/historical state of resources. **GuardDuty** = is anything suspicious happening? **Inspector** = do my EC2/containers/Lambda have known vulnerabilities?

!!! tip "Exam tip"
    Secrets Manager is the answer when a question mentions **automatic rotation of database credentials**. Parameter Store is the answer when the question mentions **cost-effective storage of configuration values**.

!!! tip "Exam tip"
    For encryption key questions: if the answer needs cross-account access to a KMS key, the key policy must explicitly allow the external account's principal. IAM policies alone in the external account are insufficient — both the key policy AND the IAM policy must allow access.
