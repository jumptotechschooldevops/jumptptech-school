---
title: "ADVANCED LAB — AWS REAL PROJECT (ECS + ALB + API + Postman + CI/CD)"
description: "🎯 Scenario (REAL COMPANY)   You deployed:   Backend API (FastAPI / Node) Running on Amazon..."
published: 2026-04-10
source: "https://dev.to/jumptotech/advanced-lab-aws-real-project-ecs-alb-api-postman-cicd-p5h"
tags: []
---

# ADVANCED LAB — AWS REAL PROJECT (ECS + ALB + API + Postman + CI/CD)





## 🎯 Scenario (REAL COMPANY)

You deployed:

* Backend API (FastAPI / Node)
* Running on **Amazon ECS**
* Behind **Application Load Balancer**
* Logs in **Amazon CloudWatch**

👉 Your job:
Validate API BEFORE production traffic hits it

---

# 🧠 ARCHITECTURE (WHAT YOU ARE TESTING)

```plaintext
User → ALB → ECS Service → Container → Database
```

Example endpoint:

```bash
http://your-alb-123.us-east-1.elb.amazonaws.com
```

---

# 🧠 STEP 1 — FIND YOUR API (REAL)

### In AWS Console:

1. Go to **ECS**
2. Open your service
3. Find **Load Balancer DNS**

👉 This is your API base URL

---

# 🧠 STEP 2 — DEFINE API CONTRACT (CRITICAL)

Example API:

| Endpoint       | Expected             |
| -------------- | -------------------- |
| `/health`      | `{ "status": "ok" }` |
| `/login`       | `{ "token": "..." }` |
| `/orders`      | list of orders       |
| `/orders/{id}` | single order         |

👉 DevOps MUST know expected output (from devs / Swagger)

---

# 🚀 STEP 3 — POSTMAN COLLECTION (PRO LEVEL)

---

## 📁 ENVIRONMENT

```json
{
  "base_url": "http://your-alb-url",
  "auth_token": ""
}
```

---

# ✅ TEST 1 — HEALTH CHECK (LOAD BALANCER LEVEL)

```http
GET {{base_url}}/health
```

### Tests:

```javascript
pm.test("Service is healthy", () => {
    pm.response.to.have.status(200);
});

const json = pm.response.json();

pm.test("Health status OK", () => {
    pm.expect(json.status).to.eql("ok");
});
```

---

👉 If FAIL:

* ECS task crashed
* Container not running
* ALB health check failing

---

# 🔐 TEST 2 — LOGIN (AUTH FLOW)

```http
POST {{base_url}}/login
```

Body:

```json
{
  "username": "admin",
  "password": "password"
}
```

---

### Tests:

```javascript
const json = pm.response.json();

pm.test("Login success", () => {
    pm.response.to.have.status(200);
});

pm.test("Token exists", () => {
    pm.expect(json.token).to.exist;
});

pm.environment.set("auth_token", json.token);
```

---

👉 If FAIL:

* Auth service broken
* DB connection issue
* Env variables missing in ECS

---

# 🔥 TEST 3 — CORE BUSINESS API (ORDERS)

```http
GET {{base_url}}/orders
Authorization: Bearer {{auth_token}}
```

---

### Tests:

```javascript
pm.test("Orders fetched", () => {
    pm.response.to.have.status(200);
});

const data = pm.response.json();

pm.test("Orders not empty", () => {
    pm.expect(data.length).to.be.above(0);
});
```

---

👉 If FAIL:

* DB not connected
* Wrong security group
* Backend error

---

# ❌ TEST 4 — SECURITY TEST

(no token)

```http
GET {{base_url}}/orders
```

```javascript
pm.test("Unauthorized blocked", () => {
    pm.response.to.have.status(401);
});
```

---

👉 If FAIL:
🚨 Your API is OPEN → SECURITY ISSUE

---

# ⚡ TEST 5 — PERFORMANCE CHECK

```javascript
pm.test("Fast response", () => {
    pm.expect(pm.response.responseTime).to.be.below(400);
});
```

---

👉 If FAIL:

* DB slow
* Container CPU high
* Network latency

---

# 💣 TEST 6 — FAILURE DETECTION

```http
GET {{base_url}}/orders/999999
```

```javascript
pm.test("Handle invalid ID", () => {
    pm.expect(pm.response.code).to.be.oneOf([404, 400]);
});
```

---

👉 If FAIL:

* App not handling errors properly

---

# 🚨 STEP 4 — REAL DEVOPS DEBUGGING

---

## If `/health` fails:

Check:

```bash
aws ecs list-tasks
aws ecs describe-tasks
```

---

## Logs:

Check in:
👉 Amazon CloudWatch

---

## Container logs:

Look for:

* DB connection errors
* Missing env variables
* Crash loops

---

# 🚀 STEP 5 — AUTOMATION (CI/CD)

---

## Install Newman:

```bash
npm install -g newman
```

---

## Run:

```bash
newman run collection.json -e environment.json
```

---

# 🔥 GITHUB ACTIONS (REAL)

```yaml
name: API Validation

on:
  workflow_dispatch:

jobs:
  test-api:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install Newman
        run: npm install -g newman

      - name: Run API Tests
        run: newman run collection.json -e environment.json
```

---

# 💣 REAL PRODUCTION FLOW

1. Developer deploys ECS service
2. Pipeline runs Postman tests
3. If ANY fails → ❌ deployment blocked
4. Fix → redeploy

---

# 🧠 WHAT SENIOR DEVOPS DOES HERE

✔ Validates ALB routing
✔ Checks ECS tasks health
✔ Verifies auth + security
✔ Ensures DB connectivity
✔ Automates API validation
✔ Blocks bad deployments

---

# 🎯 INTERVIEW LEVEL ANSWER

If asked:

**"How do you test APIs in AWS?"**

Say:

> I retrieve the API endpoint from the Application Load Balancer or API Gateway, validate health endpoints, authentication flows, and protected APIs using Postman. Then I automate these tests using Newman in CI/CD pipelines to ensure that ECS deployments are stable and do not break functionality.


