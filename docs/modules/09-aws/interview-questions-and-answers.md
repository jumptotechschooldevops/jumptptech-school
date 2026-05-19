---
title: "interview questions and answers"
description: "1️⃣ AWS Lambda            Beginner   Q1: What is Lambda? Lambda is a serverless compute..."
published: 2026-03-02
source: "https://dev.to/jumptotech/interview-questions-and-answers-1hd3"
tags: []
---

# interview questions and answers



# 1️⃣ AWS Lambda

## Beginner

**Q1: What is Lambda?**
Lambda is a serverless compute service that runs code in response to events without managing servers. AWS handles provisioning, scaling, patching, and availability.

**Q2: When would you use Lambda?**
For event-driven workloads like S3 uploads, API Gateway triggers, scheduled jobs, stream processing, and lightweight microservices.

---

## Intermediate

**Q3: How does Lambda scale?**
Lambda scales automatically by creating concurrent execution environments per request. Each request can trigger a new instance. Concurrency limits apply per region.

**Q4: What is cold start?**
Cold start occurs when Lambda initializes a new execution environment. It includes runtime startup and code initialization. It is higher in VPC-enabled Lambdas.

**Q5: How do you secure Lambda?**
Using IAM execution roles, resource-based policies, environment variable encryption (KMS), VPC security groups, and least privilege access.

---

## Advanced

**Q6: How do you share files between Lambda instances?**
Using EFS (Elastic File System) mounted to Lambda.

**Q7: How do you reduce cold start?**
Provisioned Concurrency, keeping package small, avoiding VPC unless needed, and using lighter runtimes.

---

# 2️⃣ EFS (Elastic File System)

## Beginner

**Q1: What is EFS?**
EFS is a managed NFS file system for Linux workloads that can be mounted to multiple EC2 or Lambda instances simultaneously.

---

## Intermediate

**Q2: Difference between EFS and EBS?**

| EFS                  | EBS                          |
| -------------------- | ---------------------------- |
| Shared               | Single instance (by default) |
| NFS-based            | Block storage                |
| Scales automatically | Fixed size                   |

---

## Advanced

**Q3: When would you use EFS with Lambda?**
When application needs shared state, large ML models, or persistent file storage across executions.

---

# 3️⃣ S3

## Beginner

**Q1: What is S3?**
Object storage service for storing files with high durability (11 9’s).

**Q2: What are storage classes?**
Standard, IA, Glacier, Intelligent-Tiering.

---

## Intermediate

**Q3: What is S3 versioning?**
Keeps multiple versions of an object to prevent accidental deletion.

**Q4: What is pre-signed URL?**
Temporary access to private S3 object.

---

## Advanced

**Q5: How do you encrypt S3 data?**

* SSE-S3
* SSE-KMS
* Client-side encryption

---

# 4️⃣ EBS

**Q1: What is EBS?**
Block storage attached to EC2.

**Q2: Can you attach EBS to multiple instances?**
Only Multi-Attach volumes (io1/io2), otherwise single instance.

**Q3: How do you back up EBS?**
Using EBS snapshots stored in S3.

---

# 5️⃣ RDS

## Beginner

**Q1: What is RDS?**
Managed relational database service (MySQL, PostgreSQL, etc.)

---

## Intermediate

**Q2: What is Multi-AZ?**
Standby replica in another Availability Zone for failover.

**Q3: What is Read Replica?**
Used for scaling reads.

---

## Advanced

**Q4: How do you rotate database credentials securely?**
Using AWS Secrets Manager + IAM.

---

# 6️⃣ MongoDB

**Q1: SQL vs MongoDB?**
SQL = relational, fixed schema.
MongoDB = NoSQL, document-based, flexible schema.

**Q2: What is sharding?**
Horizontal scaling by distributing data across nodes.

---

# 7️⃣ CloudFront

## Beginner

**Q1: What is CloudFront?**
Content Delivery Network (CDN) to cache content globally.

---

## Intermediate

**Q2: What is edge location?**
Physical data center location where content is cached.

---

## Advanced

**Q3: How does CloudFront improve security?**
WAF integration, signed URLs, OAC/OAI for S3, HTTPS.

---

# 8️⃣ Global Accelerator

## Beginner

**Q1: What is Global Accelerator?**
Improves availability and performance using AWS global network.

---

## Advanced

**Q2: Difference between CloudFront and Global Accelerator?**

| CloudFront     | Global Accelerator  |
| -------------- | ------------------- |
| CDN            | TCP/UDP accelerator |
| Caches content | Does not cache      |
| HTTP/HTTPS     | Any TCP/UDP         |

---

# 9️⃣ EC2

**Q1: What is EC2?**
Virtual machine in AWS.

**Q2: What is Auto Scaling Group?**
Automatically adjusts EC2 capacity.

**Q3: What is Launch Template?**
Template defining instance configuration.

---

# 🔟 Security Groups

**Q1: What is Security Group?**
Stateful firewall attached to EC2.

**Q2: Stateful vs Stateless?**
SG = Stateful
NACL = Stateless

---

# 1️⃣1️⃣ API Gateway

**Q1: What is API Gateway?**
Managed service to create REST/HTTP/WebSocket APIs.

**Q2: How does it integrate with Lambda?**
Triggers Lambda via proxy integration.

---

# 1️⃣2️⃣ Serverless Architecture

**Q1: What is serverless?**
No server management, event-driven, pay-per-use.

**Senior Answer:**
Serverless is operational abstraction. AWS manages infrastructure while we focus on code and business logic.

---

# 1️⃣3️⃣ Edge Location

Edge location is a data center used by CloudFront and Route53 for low-latency response.

---

# 1️⃣4️⃣ KMS & SSE-KMS

## KMS

AWS Key Management Service manages encryption keys.

## SSE-KMS

Server-side encryption using KMS-managed keys.

**Difference SSE-S3 vs SSE-KMS?**

* SSE-S3 → AWS-managed key
* SSE-KMS → Customer-controlled key + audit trail (CloudTrail)

---

# 1️⃣5️⃣ IAM

## Beginner

**What is IAM?**
Identity and Access Management.

---

## Intermediate

**What is least privilege?**
Grant minimum permissions required.

---

## Advanced

**Explain IAM Role vs Policy?**
Policy = permission document.
Role = identity that can be assumed.

---

# 🔥 Architect-Level Scenario Question

**Design a secure serverless image processing system.**

Answer structure:

Client → API Gateway → Lambda → S3
S3 → Event → Worker Lambda → Store processed image
CloudFront → Serve content globally
KMS → Encrypt data
IAM → Least privilege
Global Accelerator → Multi-region resilience
RDS/MongoDB → Metadata storage


