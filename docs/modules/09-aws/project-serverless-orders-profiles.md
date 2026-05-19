---
title: "Project: Serverless Orders + Profiles"
description: "What you’ll build (final output)     Public API (GET /health) to verify the..."
published: 2025-11-04
source: "https://dev.to/jumptotech/project-serverless-orders-profiles-nj5"
tags: []
---

# Project: Serverless Orders + Profiles




## What you’ll build (final output)

1. **Public API** (`GET /health`) to verify the stack.
2. **Protected API** (`/profiles/*`, `/orders/*`) fronted by **API Gateway + Cognito**:

   * `POST /profiles` – create/update a user profile (DynamoDB)
   * `GET /profiles/{id}` – fetch profile (DynamoDB)
   * `POST /orders` – place an order (invokes **Step Functions** workflow)
   * `GET /orders/{id}` – fetch order status (DynamoDB)
3. **Background workflows**:

   * **Step Functions** orchestrates “Place Order” (validate → reserve → charge → confirm).
   * **EventBridge cron** runs a **serverless cleanup** Lambda hourly to expire “stale orders”.
   * **DynamoDB Streams → Lambda** sends a “welcome” log when a new profile is created.
4. **Data features**:

   * DynamoDB table with **On-Demand** capacity, **TTL** for sessions, **PITR backups**, **S3 export** demo.
5. **Edge customization**:

   * **CloudFront + CloudFront Function** adds a security header & redirects `/` → `/docs`.
6. **Performance knobs**:

   * **Reserved concurrency** on hot endpoints, **Provisioned Concurrency** on the checkout Lambda, and **SnapStart** (optional) for a Java “payment” Lambda.
7. **(Optional)** DB-triggered Lambda from **Aurora MySQL** or **RDS PostgreSQL** (data-level trigger pattern).

You’ll finish with:

* A working set of HTTPS endpoints
* A Cognito Hosted UI login
* State machine executions you can watch run
* CloudWatch logs & metrics you can show in interviews

---

## Architecture (mental map)

```
[User] ──HTTPS──> [CloudFront]* ──> [API Gateway (REST)]
                                  │
                                  ├─(Cognito Authorizer)──> [Cognito User Pool]
                                  │
                                  └─> [Lambda (proxy)] ──> [DynamoDB: profiles, orders]
                                           │                       │
                                           ├─> DynamoDB Streams ──┘ (Welcome event -> Lambda)
                                           └─> Step Functions (place-order workflow)
                                                   │
                                                   ├─> Lambda: validate
                                                   ├─> Lambda: reserve
                                                   ├─> Lambda: charge (SnapStart optional)
                                                   └─> Lambda: confirm → write order state (DDB)

[EventBridge Rule (cron)] ──> Lambda (cleanup stale orders)

* CloudFront Function at viewer-request: add headers/redirect.
```

---

## Prereqs

* AWS account with admin access
* Region: **us-east-1** (helps with CloudFront/edge defaults)
* Python 3 locally (for testing JWT decode if needed)
* Node.js optional (if you prefer Node Lambdas)
* You can do everything in the **AWS Console** (no CDK/Terraform required for this lab)

---

# Step-by-Step Build

### 1) DynamoDB tables

Create **two** tables (Console → DynamoDB → Create table):

* `profiles`

  * **Partition key**: `userId` (String)
  * Capacity: **On-Demand**
  * **Streams**: **NEW_AND_OLD_IMAGES** (enable)
  * **PITR**: enable
* `orders`

  * **Partition key**: `orderId` (String)
  * Capacity: **On-Demand**
  * **TTL attribute** (add later): `ttlEpoch` (Number)
  * **PITR**: enable

> Later: enable **Export to S3** from PITR snapshot to demo analytics export.

---

### 2) Cognito (auth)

**User Pool** (sign-in):

* Console → Cognito → Create user pool
* Name: `serverless-user-pool`
* Username sign-in + email verification (simple defaults)
* Create an **App client** (no secret), enable **Hosted UI**.
* Note the **User Pool ID** and **App Client ID**.

**(Optional) Identity Pool** (direct AWS access): skip for now; not needed for this API flow.

---

### 3) API Gateway (REST)

Create **REST API**:

* API Gateway → Create API → **REST API** → Build
* Name: `serverless-api`
* **Endpoint type**: **Regional**
* Create **Resources/Methods**:

  * `/health` → **GET** → **Lambda proxy** (public; no authorizer)
  * `/profiles` → **POST** → Lambda proxy (**Cognito Authorizer**)
  * `/profiles/{id}` → **GET** → Lambda proxy (**Cognito Authorizer**)
  * `/orders` → **POST** → Lambda proxy (**Cognito Authorizer**)
  * `/orders/{id}` → **GET** → Lambda proxy (**Cognito Authorizer**)

**Cognito Authorizer**:

* Authorizers → Create → Type: **Cognito**
* Select your **User Pool**
* Attach to the 4 protected methods.

Stage:

* **Deploy API** → Stage `dev`
* Save the **Invoke URL**.

---

### 4) Lambda functions (Python 3.11)

Create these functions (Console → Lambda → Create function):

**A. `health-handler`** (public)

```python
import json
def lambda_handler(event, context):
    return {"statusCode": 200,
            "headers": {"Content-Type":"application/json"},
            "body": json.dumps({"ok": True, "service": "serverless-api"})}
```

**B. `profiles-upsert`** (Cognito-protected)

```python
import os, json, boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('profiles')

def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    # From JWT (Cognito authorizer), API Gateway puts identity in requestContext
    claims = event["requestContext"]["authorizer"]["claims"]
    user_id = claims.get("sub")  # stable unique id
    item = {
        "userId": user_id,
        "name": body.get("name", ""),
        "email": claims.get("email", ""),
        "updatedAt": event["requestContext"]["requestTimeEpoch"]
    }
    table.put_item(Item=item)
    return {"statusCode": 200, "headers":{"Content-Type":"application/json"},
            "body": json.dumps({"message":"profile upserted","profile": item})}
```

**C. `profiles-get`** (Cognito-protected)

```python
import json, boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('profiles')

def lambda_handler(event, context):
    user_id = event["pathParameters"]["id"]
    resp = table.get_item(Key={"userId": user_id})
    item = resp.get("Item")
    return {"statusCode": 200 if item else 404,
            "headers":{"Content-Type":"application/json"},
            "body": json.dumps(item or {"error":"not found"})}
```

**D. `orders-create`** (starts Step Functions)

```python
import json, os, boto3, uuid, time
sf = boto3.client('stepfunctions')

STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

def lambda_handler(event, context):
    order_id = str(uuid.uuid4())
    body = json.loads(event.get("body") or "{}")
    # Pass through claims for personalization/authorization in workflow if needed
    claims = event["requestContext"]["authorizer"]["claims"]
    start_input = {
        "orderId": order_id,
        "userId": claims.get("sub"),
        "amount": body.get("amount", 0),
        "items": body.get("items", [])
    }
    sf.start_execution(stateMachineArn=STATE_MACHINE_ARN,
                       input=json.dumps(start_input))
    return {"statusCode": 202, "headers":{"Content-Type":"application/json"},
            "body": json.dumps({"orderId": order_id, "status":"STARTED"})}
```

**E. `orders-get`** (reads DynamoDB)

```python
import json, boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('orders')

def lambda_handler(event, context):
    order_id = event["pathParameters"]["id"]
    resp = table.get_item(Key={"orderId": order_id})
    item = resp.get("Item")
    return {"statusCode": 200 if item else 404,
            "headers":{"Content-Type":"application/json"},
            "body": json.dumps(item or {"error":"not found"})}
```

**F. Stream trigger: `profiles-stream-welcome`**

* Trigger: **DynamoDB Streams** on `profiles`

```python
import json, logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    for rec in event.get("Records", []):
        if rec["eventName"] == "INSERT":
            new = rec["dynamodb"]["NewImage"]
            logger.info(f"WELCOME: userId={new['userId']['S']} name={new.get('name',{}).get('S','')}")
    return {"statusCode":200, "body":"ok"}
```

**G. Cron cleanup: `orders-cleanup`** (EventBridge hourly)

```python
import json, time, boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('orders')

def lambda_handler(event, context):
    # Example: mark old PENDING orders as EXPIRED (toy logic)
    # In real life you'd use a GSI on status+timestamp and query instead of scan.
    scan = table.scan()
    now = int(time.time())
    updated = 0
    for item in scan.get("Items", []):
        if item.get("status") == "PENDING" and item.get("ttlEpoch", now) < now:
            item["status"] = "EXPIRED"
            table.put_item(Item=item)
            updated += 1
    return {"statusCode": 200, "body": json.dumps({"expired": updated})}
```

**Wire methods → functions** in API Gateway (Lambda proxy).
For `orders-create`, set **ENV** `STATE_MACHINE_ARN` (after you create it in next step).

**Permissions**: each Lambda needs minimal IAM (DynamoDB CRUD to the right tables, Step Functions `StartExecution` for `orders-create`, CloudWatch logs). You can attach inline policies per function.

---

### 5) Step Functions (Standard)

Console → Step Functions → Create state machine → **Write your workflow in ASL**:

**State machine name**: `PlaceOrder`

**Definition (paste):**

```json
{
  "Comment": "Place order workflow",
  "StartAt": "Validate",
  "States": {
    "Validate": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {"FunctionName": "validate-order", "Payload.$": "$"},
      "Next": "Reserve",
      "Retry": [{"ErrorEquals":["States.ALL"],"IntervalSeconds":2,"MaxAttempts":2,"BackoffRate":2.0}],
      "Catch": [{"ErrorEquals":["States.ALL"],"ResultPath":"$.error","Next":"Fail"}]
    },
    "Reserve": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {"FunctionName": "reserve-inventory", "Payload.$": "$"},
      "Next": "Charge"
    },
    "Charge": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {"FunctionName": "charge-payment", "Payload.$": "$"},
      "Next": "Confirm"
    },
    "Confirm": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {"FunctionName": "confirm-order", "Payload.$": "$"},
      "End": true
    },
    "Fail": { "Type":"Fail", "Cause":"OrderFailed" }
  }
}
```

Create **four small Lambdas** (`validate-order`, `reserve-inventory`, `charge-payment`, `confirm-order`) that just:

* Read `orderId`, `userId`
* Update `orders` table with `status`: `VALIDATED` → `RESERVED` → `CHARGED` → `CONFIRMED`

> **SnapStart (optional)**: make `charge-payment` a **Java** Lambda and enable **SnapStart on Published Versions** for a cold-start boost. Publish a version and point Step Functions to that version ARN.

---

### 6) EventBridge cron

Console → EventBridge → Rules → Create

* Schedule: **rate(1 hour)**
* Target: `orders-cleanup` Lambda

---

### 7) DynamoDB: TTL + Backups + Export

* **orders** table → Enable **TTL** on attribute `ttlEpoch`
* **PITR** already enabled
* **Export**: Go to Backups/Exports → Export latest PITR snapshot to **S3** (DynamoDB JSON).
  *(For a demo, you can query with Athena after creating a table & schema.)*

---

### 8) CloudFront + CloudFront Function (edge)

* Create a small S3 static bucket `serverless-docs` with an `index.html` explaining your API.
* **CloudFront distribution** → origin = your S3 website or S3 with OAC.
* **CloudFront Function** (viewer-request):

```js
function handler(event) {
  var req = event.request;
  if (req.uri === '/') {
    req.uri = '/docs'; // redirect-like rewrite
  }
  // Add a simple security header
  var headers = req.headers;
  headers['x-lab'] = {value: 'serverless-beginner-lab'};
  return req;
}
```

* Associate at **Viewer Request**.

*(You’re not calling API Gateway through CloudFront here; this is just to show edge customization. If you want, add another behavior that proxies API to API Gateway.)*

---

### 9) Concurrency settings

* For `orders-create` (front door hot path):

  * **Reserved Concurrency** = e.g., **50** (protects the account pool)
* For `charge-payment`:

  * **Provisioned Concurrency** = e.g., **5** (low latency & no cold starts)
* Demonstrate throttling: temporarily set **Reserved Concurrency = 0** on `health-handler` and call it → see `429 ThrottlingException`. Restore.

---

### 10) (Optional) DB-triggered Lambda (Aurora MySQL / RDS PostgreSQL)

* Create a tiny table `registrations`.
* Add the engine-specific integration/stored proc to **invoke Lambda** on insert.
* IAM role on DB cluster allowing `lambda:InvokeFunction`, and **network path** to Lambda (public invoke or VPC endpoint/NAT).
* Insert a row → Lambda logs “WELCOME FROM RDS”.

*(This is distinct from RDS **Event Notifications** which are infra-events, not row-level data.)*

---

# How to Test (copy/paste)

### A) Health (public)

```
curl https://{api_id}.execute-api.{region}.amazonaws.com/dev/health
```

### B) Login (Cognito Hosted UI)

* Go to your **User Pool** → **App client** → Open **Hosted UI** sign-in.
* Create a test user, sign in, copy the **ID token (JWT)**.

In calls below, set:

```
AUTH="Authorization: Bearer <ID_TOKEN>"
```

### C) Create Profile

```
curl -X POST \
 -H "Content-Type: application/json" \
 -H "$AUTH" \
 -d '{"name":"Aisalkyn Aidarova"}' \
 https://{api_id}.execute-api.{region}.amazonaws.com/dev/profiles
```

### D) Get Profile

```
curl -H "$AUTH" \
 https://{api_id}.execute-api.{region}.amazonaws.com/dev/profiles/<cognito-sub>
```

> `cognito-sub` is the user’s `sub` claim (UUID) from the token.

### E) Place Order (triggers Step Functions)

```
curl -X POST \
 -H "Content-Type: application/json" \
 -H "$AUTH" \
 -d '{"amount": 42.50, "items":[{"sku":"A-1","qty":2}]}' \
 https://{api_id}.execute-api.{region}.amazonaws.com/dev/orders
```

Note returned `orderId`. Watch the execution in **Step Functions Console**.

### F) Get Order

```
curl -H "$AUTH" \
 https://{api_id}.execute-api.{region}.amazonaws.com/dev/orders/<orderId>
```

You should see status progress to `CONFIRMED`.

### G) Streams & Logs

* Create profile → check CloudWatch logs of `profiles-stream-welcome` for the **WELCOME** line.

### H) Cron

* Manually set an `orders` item with past `ttlEpoch` and `status=PENDING`, then wait for the hourly rule (or run the function manually) → it sets `EXPIRED`.

---

# What to Show as “Final Output”

* **Screenshots**:

  * API Gateway stage URLs responding (health, profiles, orders)
  * Cognito Hosted UI login
  * Step Functions **graph view** with a **Succeeded** execution
  * DynamoDB tables with items
  * CloudWatch logs: WELCOME stream log
  * EventBridge rule
  * CloudFront Function associated on viewer-request
* **Talking points** (interview):

  * Why **On-Demand** capacity for unpredictable loads
  * **TTL** & **PITR** choices
  * **Streams → Lambda** vs **Kinesis** use cases
  * **Reserved vs Provisioned Concurrency**, **SnapStart** for cold starts
  * **Edge** customization vs Lambda@Edge
  * **Cognito User Pool** (auth) vs **Identity Pool** (AWS access)

---

## Cleanup (to avoid charges)

* Delete CloudFront distribution (takes time), S3 bucket(s)
* Delete API Gateway, Lambdas, Step Functions state machine
* Delete EventBridge rule, DynamoDB tables (stop export jobs first)
* Delete Cognito User Pool & App client


