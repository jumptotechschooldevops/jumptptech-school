---
title: "API #2"
description: "1. What happens FIRST (Developer side)            Developer creates..."
published: 2026-04-07
source: "https://dev.to/jumptotech/api-2-57h9"
tags: []
---

# API #2



# 1. What happens FIRST (Developer side)

## Developer creates API

Example:

* Endpoint: `POST /orders`
* Logic: create order in DB
* Returns: JSON response

They define:

* Request format
* Response format
* Status codes

Often documented using:

* Swagger / OpenAPI

---

# 2. WHO validates APIs (very important)

| Role            | What they validate                               |
| --------------- | ------------------------------------------------ |
| Developer       | Basic functionality (unit tests)                 |
| QA Engineer     | Functional testing                               |
| DevOps Engineer | **System + deployment + integration validation** |

👉 DevOps is NOT replacing QA
👉 DevOps ensures **API works in real infrastructure**

---

# 3. WHEN DevOps validates APIs

### Timeline:

1. Developer writes API
2. Code pushed to Git
3. CI/CD pipeline starts
4. App deployed (Dev / Stage)
5. **DevOps validates APIs here**
6. Then production release

👉 DevOps validation happens:

* After deployment
* During pipeline
* After infra changes
* During incidents

---

# 4. WHERE DevOps tests APIs

| Environment | Purpose                   |
| ----------- | ------------------------- |
| Dev         | Early testing             |
| Stage       | Pre-production validation |
| Prod        | Monitoring / smoke tests  |

👉 DevOps ALWAYS tests across environments using variables

---

# 5. WHAT DevOps validates (THIS IS THE CORE)

## 1. API Availability

```bash
GET /health
```

Check:

* API is reachable
* No downtime

---

## 2. Status Codes

```http
200 → success  
400 → bad request  
401 → unauthorized  
500 → server error
```

👉 DevOps ensures:

* No unexpected 500 errors after deployment

---

## 3. Response Structure

Example:

```json
{
  "id": 123,
  "status": "created"
}
```

Check:

* Required fields exist
* No breaking changes

---

## 4. Authentication

Example:

```http
Authorization: Bearer token
```

Check:

* Token works
* Expired token fails
* Permissions enforced

---

## 5. Integration Between Services

Example:

* API → Database
* API → Kafka
* API → another microservice

👉 DevOps checks:

* Full flow works (not just API)

---

## 6. Performance / Latency

Check:

* Response time < expected (e.g., 200ms)

---

## 7. Error Handling

Send bad request:

```json
{
  "wrong": "data"
}
```

Check:

* Proper error message
* No crash

---

## 8. Idempotency / Stability

Run same request multiple times:

* Does it duplicate?
* Does it break?

---

# 6. HOW DevOps validates APIs (TOOLS + FLOW)

## Step 1: Use Postman for manual + automation

* Create collections
* Add tests
* Use environments

---

## Step 2: Automate using Newman

Run in pipeline:

```bash
newman run collection.json -e dev.json
```

---

## Step 3: Add into CI/CD

Example flow:

1. Code pushed
2. Build Docker image
3. Deploy to ECS / Kubernetes
4. Run API tests (Postman/Newman)
5. If failed → stop pipeline

---

## Step 4: Monitoring (after deployment)

Tools:

* CloudWatch
* Prometheus
* API Gateway logs

Check:

* API errors
* Latency
* Traffic

---

# 7. REAL DEVOPS FLOW (END-TO-END)

## Step-by-step:

### 1. Developer

* Writes API
* Pushes code

---

### 2. CI Pipeline

* Build app
* Run unit tests

---

### 3. CD Pipeline

* Deploy to Dev/Stage (ECS / EKS / VM)

---

### 4. DevOps Validation (THIS IS YOU)

You run:

### A. Smoke test

* API is up

### B. Functional test

* GET / POST works

### C. Integration test

* DB / Kafka works

### D. Security test

* Auth works

---

### 5. Automated Gate

If tests fail:

* ❌ STOP deployment

If pass:

* ✅ Continue to production

---

### 6. Production Monitoring

* Alerts if API fails
* Auto rollback possible

---

# 8. REAL EXAMPLE  Kafka project

 deployed backend API:

```http
POST /orders
GET /orders
```

### DevOps checks:

1. API reachable via ALB
2. Kafka receives message
3. Consumer processes data
4. Data stored in DB
5. API returns correct response

👉 This is **end-to-end validation**

---

# 9. COMMON INTERVIEW QUESTION (VERY IMPORTANT)

### Question:

“What does DevOps validate in APIs?”

### Answer:

> “DevOps engineers validate APIs after deployment by checking availability, status codes, authentication, response structure, and integration with downstream services. We automate these validations using tools like Postman/Newman in CI/CD pipelines to ensure reliable deployments.”

---

# 10. BIG PICTURE (REMEMBER THIS)

DevOps is responsible for:

* Not just “API works”
* But:

  * Works after deployment
  * Works with infrastructure
  * Works under load
  * Works securely
  * Works continuously








# What is Newman?

**Newman** is the **command-line tool for Postman collections**.

👉 In simple words:

> Postman = GUI (manual + design)
> Newman = CLI (automation + pipelines)

---

# Simple analogy

* Postman → like clicking buttons in browser
* Newman → like running script in terminal (automation)

---

# When do we use Postman?

## Use Postman when:

* You are developing APIs
* You are testing manually
* You are learning/debugging
* You are creating collections

### Example:

* Try GET /users
* Check response
* Write test scripts
* Save collection

👉 This is **interactive work**

---

# When do we use Newman?

## Use Newman when:

* Running tests automatically
* In CI/CD pipelines
* After deployment
* For regression testing

### Example:

```bash
newman run collection.json -e dev.json
```

👉 This is **automation (no clicking)**

---

# Real DevOps Workflow (IMPORTANT)

## Step 1 — In Postman (Preparation)

You create:

* Collection
* Requests (GET, POST, etc.)
* Tests (JavaScript)
* Environment variables

👉 Example:

* `POST /orders`
* Validate response = 200
* Save order ID

---

## Step 2 — Export from Postman

You export:

* Collection → `collection.json`
* Environment → `dev.json`

---

## Step 3 — Run with Newman

```bash
newman run collection.json -e dev.json
```

---

## Step 4 — Integrate into CI/CD

Example pipeline:

1. Build app
2. Deploy app
3. Run Newman
4. If failed → stop deployment

---

# Key Difference (VERY IMPORTANT)

| Feature        | Postman        | Newman     |
| -------------- | -------------- | ---------- |
| UI             | Yes            | No         |
| Manual testing | Yes            | No         |
| Automation     | Limited        | Yes        |
| CI/CD usage    | No             | Yes        |
| DevOps usage   | Design/testing | Automation |

---

# Real Example (Your Kafka project)

## In Postman:

You create:

* POST `/orders`
* GET `/orders`
* Add tests

---

## In Newman (CI/CD):

```bash
newman run kafka-tests.json -e prod.json
```

Pipeline checks:

* API works
* Kafka works
* DB works

If not:
❌ Deployment fails

---

# Why DevOps MUST use Newman

Because DevOps:

* Cannot manually click Postman every deployment
* Needs automation
* Needs repeatable tests

👉 Newman makes API testing:

* Scriptable
* Repeatable
* Pipeline-ready

---

# Installation

```bash
npm install -g newman
```

---

# Interview Answer (short, perfect)

> “Postman is used for designing and manually testing APIs, while Newman is used to run Postman collections from the command line. In DevOps, we use Newman in CI/CD pipelines to automate API validation after deployments.”











