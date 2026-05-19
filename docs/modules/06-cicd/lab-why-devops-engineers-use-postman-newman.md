---
title: "lab: WHY DevOps Engineers Use Postman + Newman"
description: "Postman (Manual + Design Phase)   Used by DevOps to:   Test APIs before deployment Validate..."
published: 2026-04-09
source: "https://dev.to/jumptotech/lab-why-devops-engineers-use-postman-newman-2ioj"
tags: []
---

# lab: WHY DevOps Engineers Use Postman + Newman


 
### Postman (Manual + Design Phase)

Used by DevOps to:

* Test APIs before deployment
* Validate endpoints (GET, POST, DELETE)
* Work with developers (API contract testing)
* Save collections for automation

### Newman (Automation Phase)

CLI tool to:

* Run Postman collections in CI/CD
* Validate APIs after deployment
* Block bad releases automatically

👉 **Key Idea:**

* Postman = Manual testing
* Newman = Automated testing in pipeline

---

# 🔥 2. WHAT TESTS DEVOPS ENGINEERS DO

### 1. Health Check Test

```http
GET /health
```

Check:

* API is alive
* Returns 200

---

### 2. Functional Test

```http
POST /users
```

Check:

* Response contains correct data
* Fields match expected

---

### 3. Status Code Validation

```javascript
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});
```

---

### 4. Response Body Validation

```javascript
pm.test("User created", function () {
    let json = pm.response.json();
    pm.expect(json.name).to.eql("Aisalkyn DevOps");
});
```

---

### 5. Performance Check (Basic)

```javascript
pm.test("Response time < 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});
```

---

### 6. Schema Validation (Advanced DevOps)

Validate structure:

```javascript
pm.test("Response has id", function () {
    let json = pm.response.json();
    pm.expect(json).to.have.property("id");
});
```

---

### 7. Negative Testing

```http
POST /users (invalid body)
```

Check:

* API rejects bad input
* Returns 400

---

# 🔥 3. LAB — COMPLETE STRUCTURE (REAL DEVOPS)

### 📁 Project Structure

```plaintext
postman-newman-lab/
├── .github/
│   └── workflows/
│       └── api-test.yml
├── collection.json
├── environment.json
└── README.md
```

---

# 🔥 4. STEP-BY-STEP LAB

## ✅ Step 1 — Create Postman Collection

Use API:

```plaintext
https://reqres.in/api/users
```

### POST Request

Body:

```json
{
  "name": "Aisalkyn DevOps",
  "job": "Cloud Engineer"
}
```

---

## ✅ Step 2 — Add Tests in Postman

Go to **Tests tab**:

```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("Response has name", function () {
    let json = pm.response.json();
    pm.expect(json.name).to.eql("Aisalkyn DevOps");
});
```

---

## ✅ Step 3 — Create Environment

```shell
base_url = https://reqres.in/api
```

---

## ✅ Step 4 — Export Files

Export:

* Collection → `collection.json`
* Environment → `environment.json`

---

## ✅ Step 5 — Install Newman

```bash
npm install -g newman
```

Run locally:

```bash
newman run collection.json -e environment.json
```

---

# 🔥 5. GITHUB ACTIONS (REAL PIPELINE)

## `.github/workflows/api-test.yml`

```yaml
name: API Tests

on:
  push:
    branches:
      - main

jobs:
  test-api:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install Newman
        run: npm install -g newman

      - name: Run API Tests
        run: newman run collection.json -e environment.json
```

---

# 🔥 6. WHY IT WORKS IN POSTMAN BUT FAILS IN GITHUB ACTIONS

### ❌ 1. Missing Environment Variables

Postman has:

```plaintext
{{base_url}}
```

GitHub → doesn't know it

👉 Fix:

* Ensure `environment.json` is included

---

### ❌ 2. Hardcoded Localhost

Works locally:

```plaintext
http://localhost:3000
```

Fails in CI because:

* No local server running

---

### ❌ 3. Authentication Missing

Postman:

* Uses saved token

GitHub:

* No token

---

### ❌ 4. Collection Uses Variables Not Defined

Example:

```plaintext
{{user_id}}
```

---

### ❌ 5. Network Restrictions / API Down

---

# 🔥 7. WHY WE PUSH TO GITHUB

We push because:

### 1. CI/CD Automation

* Every push → API tested automatically

### 2. Prevent Broken Deployments

* If tests fail → pipeline fails

### 3. Team Collaboration

* Everyone uses same tests

### 4. Version Control

* Track API changes

---

# 🔥 8. WHAT OUTPUT WE GIVE TO MANAGER

### Example Report:

**API Test Report**

* Total Requests: 10
* Passed: 9
* Failed: 1
* Success Rate: 90%
* Avg Response Time: 320ms

**Failed Endpoint:**

```plaintext
POST /users → 500 error
```

---

### Newman Report Command (Advanced)

```bash
newman run collection.json \
-e environment.json \
-r cli,html \
--reporter-html-export report.html
```

👉 You send:

* HTML report
* Logs
* Pipeline status

---

# 🔥 9. REAL DEVOPS SCENARIO

Pipeline flow:

```plaintext
Developer pushes code
        ↓
Build (Docker)
        ↓
Deploy (ECS / Kubernetes)
        ↓
Run Newman Tests
        ↓
IF FAIL → rollback
IF PASS → release
```

---

# 🔥 10. WHAT INTERVIEWERS EXPECT

You should say:

* "We use Postman for API validation and Newman in CI/CD pipelines"
* "We validate status codes, response body, schema, and performance"
* "Newman helps prevent bad deployments"
* "Failures in CI usually happen due to missing env variables or auth"



