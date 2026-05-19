---
title: "LAB: DevOps API Testing with Postman (FULL REAL SCENARIO)"
description: "🎯 Goal   You are a DevOps engineer validating an API before deployment.  You..."
published: 2026-04-10
source: "https://dev.to/jumptotech/lab-devops-api-testing-with-postman-full-real-scenario-1gp7"
tags: []
---

# LAB: DevOps API Testing with Postman (FULL REAL SCENARIO)



 

## 🎯 Goal

You are a DevOps engineer validating an API before deployment.

You will:

1. Discover API
2. Test manually
3. Validate response
4. Add automation tests
5. Run in CLI (Newman)
6. Integrate into CI/CD mindset

---

# 🧠 PART 1 — What is API (DevOps perspective)

👉 API = **endpoint where services communicate**

Example:

```plaintext
Frontend → API → Backend → Database
```

Real example:

```http
https://jsonplaceholder.typicode.com/users
```

* `https://` → protocol
* `jsonplaceholder.typicode.com` → API server
* `/users` → endpoint

---

# 🧠 PART 2 — Where DevOps finds API

DevOps gets API from:

* Developers (Swagger / OpenAPI)
* GitHub repo (README)
* Environment variables
* Load balancer (ALB DNS)
* Kubernetes Ingress
* API Gateway (AWS)

👉 Example in AWS:

```http
http://my-alb-123.us-east-1.elb.amazonaws.com/users
```

---

# 🧠 PART 3 — What DevOps tests (IMPORTANT)

DevOps DOES NOT test UI
DevOps tests:

### ✅ 1. Availability

* API reachable?
* Status = 200?

### ✅ 2. Correct response

* JSON format correct?
* Required fields exist?

### ✅ 3. Performance (basic)

* Response time < 500ms?

### ✅ 4. Security basics

* Unauthorized access blocked?

### ✅ 5. Integration

* Does backend connect to DB?

---

# 🚀 PART 4 — HANDS-ON LAB

---

## 📁 Step 1 — Create Postman Collection

1. Open Postman
2. Click **New → Collection**
3. Name: `devops-api-lab`

---

## 📁 Step 2 — Create Environment

Environment:

```python
base_url = https://jsonplaceholder.typicode.com
```

---

## 📁 Step 3 — CREATE REQUESTS

---

# ✅ TEST 1 — GET USERS (Availability Test)

### Request:

```http
GET {{base_url}}/users
```

---

### Tests tab (IMPORTANT):

```javascript
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response is JSON", function () {
    pm.response.to.be.json;
});

pm.test("Response time < 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});
```

---

# ✅ TEST 2 — VALIDATE DATA STRUCTURE

```javascript
pm.test("User has required fields", function () {
    const jsonData = pm.response.json();
    
    pm.expect(jsonData[0]).to.have.property("id");
    pm.expect(jsonData[0]).to.have.property("name");
    pm.expect(jsonData[0]).to.have.property("email");
});
```

---

# ✅ TEST 3 — CREATE USER (POST)

### Request:

```http
POST {{base_url}}/users
```

### Body (JSON):

```json
{
  "name": "DevOps Engineer",
  "job": "Cloud Engineer"
}
```

---

### Tests:

```javascript
pm.test("Created successfully", function () {
    pm.response.to.have.status(201);
});
```

---

# ✅ TEST 4 — NEGATIVE TEST (DevOps important)

### Request:

```http
GET {{base_url}}/invalid-endpoint
```

### Tests:

```javascript
pm.test("Should return 404", function () {
    pm.response.to.have.status(404);
});
```

---

# 🧠 PART 5 — HOW DEVOPS THINKS

DevOps checks:

| Check         | Why                 |
| ------------- | ------------------- |
| 200 OK        | Service is alive    |
| JSON valid    | Backend works       |
| Fields exist  | Contract not broken |
| Response time | Performance         |
| 404/401       | Security + routing  |

---

# 🚀 PART 6 — AUTOMATION (VERY IMPORTANT)

Export your collection:

```json
collection.json
environment.json
```

---

## Run with Newman:

```bash
npm install -g newman
```

Run:

```bash
newman run collection.json -e environment.json
```

---

# 🚨 REAL DEVOPS SCENARIO

Pipeline step:

```yaml
- name: Run API Tests
  run: newman run collection.json -e environment.json
```

👉 If tests fail → deployment FAILS

---

# 🧠 PART 7 — HOW TO KNOW WHAT OUTPUT SHOULD BE

DevOps gets expected output from:

1. Swagger (OpenAPI)
2. Developer documentation
3. Existing production API
4. Contract testing

Example expected:

```json
{
  "id": 1,
  "name": "Leanne Graham"
}
```

---

# 🧠 PART 8 — HOW TO FIND API IN REAL SYSTEM

### In Kubernetes:

```bash
kubectl get svc
kubectl get ingress
```

### In AWS:

* ALB DNS
* API Gateway URL

### In Docker:

```bash
docker logs container
```

---

# 🔥 FINAL UNDERSTANDING

### DevOps API Testing Level:

* NOT deep functional testing (QA job)
* YES:

  * Health checks
  * Contract validation
  * Automation in pipeline
  * Basic security & performance

---

# 💡 BONUS (REAL INTERVIEW ANSWER)

👉 If interviewer asks:

**"What do DevOps test with Postman?"**

Answer:

> DevOps engineers use Postman to validate API availability, response correctness, status codes, and response time. We also automate these tests using Newman in CI/CD pipelines to ensure deployments don’t break existing functionality.


