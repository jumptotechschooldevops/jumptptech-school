---
title: "Part 7: Decoupled Architecture"
description: "1. Goal of Today’s Architecture   Today we enhanced an existing serverless architecture by..."
published: 2026-03-05
source: "https://dev.to/jumptotech/part-7-decoupled-architecture-56l7"
tags: []
---

# Part 7: Decoupled Architecture



# 1. Goal of Today’s Architecture

Today we enhanced an existing serverless architecture by adding:

* **Authentication layer** → Cognito
* **Streaming/event layer** → Kinesis

This allows the system to:

* authenticate users securely
* accept API requests
* process events asynchronously
* store files in S3
* scale automatically

---

# 2. Final Architecture

The full architecture now looks like this:

```
Client
   │
   │ Login
   ▼
Amazon Cognito
(Authentication)
   │
   │ JWT Token
   ▼
Amazon API Gateway
(API + JWT validation)
   │
   │ Authorized request
   ▼
AWS Lambda (API Logic)
   │
   │ PutRecord()
   ▼
Amazon Kinesis Data Stream
(Event pipeline)
   │
   │ Stream processing
   ▼
Worker / Lambda
   │
   ▼
Amazon S3
(File storage)
```

---

# 3. Step-by-Step 

## Step 1 — User Authentication with Cognito

We create a **user authentication system**.

Service used:

* Amazon Cognito

Process:

1. User logs in through Cognito Hosted UI
2. Cognito authenticates the user
3. Cognito returns a **JWT token**

Example redirect:

```
http://localhost:3000/?code=xxxx
```

Then we exchanged that code for a token using:

```bash
curl /oauth2/token
```

This returned:

```
id_token
access_token
refresh_token
```

The **access token** is used to access APIs.

---

# 4. Step 2 — Secure API with API Gateway

We configured **Amazon API Gateway**.

API Gateway was configured with:

JWT Authorizer using Cognito.

This means:

```
API request → token validation → allow/deny
```

Only authenticated users can call the API.

Example request:

```bash
curl -X POST API_URL \
-H "Authorization: Bearer ACCESS_TOKEN"
```

---

# 5. Step 3 — Lambda API Backend

The API triggers **AWS Lambda**.

Lambda responsibilities:

* receive API request
* generate file key
* push event to Kinesis
* return response

Example response:

```
{
 "message": "File uploaded and event sent",
 "file_key": "uploads/uuid.txt"
}
```

---

# 6. Step 4 — Event Streaming with Kinesis

We integrated **Amazon Kinesis Data Streams**.

Lambda sends events using:

```
PutRecord()
```

Example event flow:

```
Lambda
   │
   │ PutRecord
   ▼
Kinesis Stream
```

Kinesis acts as an **event buffer**.

Benefits:

* decoupling
* scaling
* async processing
* durability

---

# 7. Step 5 — Storage in S3

Files are stored in:

* Amazon S3

Example object:

```
uploads/cc501bd4-e4b2-43bb-b0a7-0297fb0930ba.txt
```

S3 provides:

* durable storage
* scalability
* low cost

---

# 8. Security Improvements We Added

Before today:

```
Client → API Gateway → Lambda → S3
```

Now we added **security + streaming**.

New architecture:

```
Client
 ↓
Cognito (Authentication)
 ↓
API Gateway (Authorization)
 ↓
Lambda
 ↓
Kinesis (Event streaming)
 ↓
Worker processing
 ↓
S3
```

---

# 9. Why Kinesis Was Added

Kinesis allows **decoupling**.

Instead of:

```
API → Direct processing
```

We now have:

```
API → Event Stream → Worker
```

Benefits:

* asynchronous processing
* high scalability
* fault tolerance
* replay capability

---

# 10. Key DevOps Concepts Demonstrated

This lab demonstrates real production concepts:

### Authentication

Cognito + JWT tokens

### API security

API Gateway authorizers

### Serverless compute

Lambda

### Event-driven architecture

Kinesis streaming

### Durable storage

S3

### Decoupling

Producer / Consumer pattern

---

# 11. How to Explain This in an Interview

Example answer:

> We implemented a secure event-driven serverless architecture. Users authenticate using Cognito and receive a JWT token. API Gateway validates the token before allowing access to the API. The API triggers a Lambda function which generates a file key and sends an event to a Kinesis Data Stream. The stream decouples ingestion from processing and allows scalable event handling. Downstream services consume the events and store the results in S3. This design improves scalability, security, and fault tolerance.

---

# 12. Real Systems That Use This Architecture

This architecture is used in:

* image upload pipelines
* video processing
* IoT ingestion systems
* log processing platforms
* ML data pipelines


