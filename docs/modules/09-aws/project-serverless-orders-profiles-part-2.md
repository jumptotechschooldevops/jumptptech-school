---
title: "Project: Serverless Orders + Profiles part 2"
description: "This project implements a fully serverless Order Processing system on AWS:  - Users can create..."
published: 2025-11-05
source: "https://dev.to/jumptotech/project-serverless-orders-profiles-part-2-jno"
tags: []
---

# Project: Serverless Orders + Profiles part 2






```
This project implements a fully serverless Order Processing system on AWS:

- Users can create profiles.
- Users can place orders.
- Orders trigger a Step Functions workflow:
    1) Validate order data
    2) Reserve inventory
    3) Charge payment
    4) Confirm order
- All order & profile data is stored in DynamoDB.
- Everything is exposed via API Gateway as REST endpoints.
- CI/CD pipeline automatically deploys Lambda code from GitHub → AWS.
```

---

# 2) **Architecture Diagram**

```
     (Client / UI / Postman)
                |
        +----------------+
        | API Gateway    |
        +----------------+
           |     |     |
   POST /profiles   POST /orders   GET /orders/{id}
           |     |     |
           |     |     |
       create-profile   create-order
                         |
                         v
                   Step Functions Workflow
                +------- Validate -------+
                |                        |
                v                        v
            Reserve Lambda  →  Charge Lambda  →  Confirm Lambda
                |                        |
                +---------- Writes to DynamoDB --------+
```

---

# 3) **DynamoDB Tables**

| Table Name   | Partition Key      | Used For                |
| ------------ | ------------------ | ----------------------- |
| **profiles** | `userId` (String)  | Store user profiles     |
| **order**    | `orderId` (String) | Store each order record |

Ensure **order table name is lowercase**: `order`

---

# 4) **Lambda Functions (Final Code)**

### 4.1 validate-order

```python
import json

def lambda_handler(event, context):
    # Just return the input to pass to next state
    return event
```

### 4.2 reserve-inventory

```python
import boto3
import json

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    event["status"] = "IN_PROGRESS"
    table.put_item(Item=event)
    return event
```

### 4.3 charge-payment

```python
import json

def lambda_handler(event, context):
    event["payment_status"] = "PAID"
    return event
```

### 4.4 confirm-order

```python
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    event["status"] = "CONFIRMED"
    table.put_item(Item=event)
    return event
```

### 4.5 create-profile

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('profiles')

def lambda_handler(event, context):
    body = json.loads(event["body"])
    table.put_item(Item=body)
    return {"statusCode": 200, "body": json.dumps(body)}
```

### 4.6 create-order (starts step function)

```python
import json
import boto3
import os

sfn = boto3.client('stepfunctions', region_name='us-east-1')
STATE_MACHINE_ARN = os.environ['STATE_MACHINE_ARN']

def lambda_handler(event, context):
    body = json.loads(event["body"])
    sfn.start_execution(stateMachineArn=STATE_MACHINE_ARN, input=json.dumps(body))
    return {"statusCode": 200, "body": json.dumps({"message": "Order started"})}
```

### 4.7 get-order

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    orderId = event["pathParameters"]["id"]
    response = table.get_item(Key={"orderId": orderId})
    return {"statusCode": 200, "body": json.dumps(response.get("Item", {}))}
```

---

# 5) **Step Functions Definition (Copy-Paste)**

```json
{
  "Comment": "Serverless Order Processing",
  "StartAt": "Validate",
  "States": {
    "Validate": {
      "Type": "Task",
      "Resource": "<VALIDATE_LAMBDA_ARN>",
      "Next": "Reserve"
    },
    "Reserve": {
      "Type": "Task",
      "Resource": "<RESERVE_LAMBDA_ARN>",
      "Next": "Charge"
    },
    "Charge": {
      "Type": "Task",
      "Resource": "<CHARGE_LAMBDA_ARN>",
      "Next": "Confirm"
    },
    "Confirm": {
      "Type": "Task",
      "Resource": "<CONFIRM_LAMBDA_ARN>",
      "End": true
    }
  }
}
```

Replace ARN placeholders.

---

# 6) **API Gateway Final Endpoints**

| Action           | Method | URL          |
| ---------------- | ------ | ------------ |
| Create Profile   | POST   | /profiles    |
| Create Order     | POST   | /orders      |
| Get Order Status | GET    | /orders/{id} |

Deploy to **prod** stage.

---

# 7) **Repo Structure (Copy-Paste)**

```
serverless-orders/
│
├── lambdas/
│   ├── validate-order.py
│   ├── reserve-inventory.py
│   ├── charge-payment.py
│   ├── confirm-order.py
│   ├── create-profile.py
│   ├── create-order.py
│   └── get-order.py
│
└── .github/
    └── workflows/
        └── deploy.yml
```

---

# 8) **CI/CD Pipeline (GitHub Actions)**

Create file:

`.github/workflows/deploy.yml`

```yaml
name: Deploy Lambda Functions

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Deploy Lambdas
        run: |
          for f in lambdas/*.py; do
            FUNCTION_NAME=$(basename $f .py)
            zip $FUNCTION_NAME.zip $f
            aws lambda update-function-code --function-name $FUNCTION_NAME --zip-file fileb://$FUNCTION_NAME.zip
          done
```

---

# 9) **Set GitHub Secrets**

Go to:
**GitHub → Repo → Settings → Secrets → Actions → New Secret**

Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Use IAM user with Lambda + Step Functions + DynamoDB permissions.

---

# ✅ Your project is now complete with:

* Serverless backend
* API Gateway
* Step Functions workflow
* DynamoDB storage
* Full CI/CD deployment pipeline


