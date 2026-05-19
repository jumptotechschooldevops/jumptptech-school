---
title: "LAB 2 — Docker + Newman (REAL DEVOPS PIPELINE)"
description: "🎯 What you will learn    Run API in Docker Test API using Newman Simulate real CI/CD..."
published: 2026-04-09
source: "https://dev.to/jumptotech/lab-2-docker-newman-real-devops-pipeline-28o2"
tags: []
---

# LAB 2 — Docker + Newman (REAL DEVOPS PIPELINE)




## 🎯 What you will learn

* Run API in Docker
* Test API using Newman
* Simulate real CI/CD validation
* Understand why pipelines fail

---

# 🔥 1. PROJECT STRUCTURE

```plaintext
docker-newman-lab/
├── app/
│   └── server.js
├── Dockerfile
├── collection.json
├── environment.json
├── package.json
└── .github/
    └── workflows/
        └── api-test.yml
```

---

# 🔥 2. STEP 1 — CREATE SIMPLE API

## 📄 `app/server.js`

```javascript
const express = require("express");
const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
    res.status(200).json({ status: "UP" });
});

app.post("/users", (req, res) => {
    const { name, job } = req.body;

    if (!name || !job) {
        return res.status(400).json({ error: "Missing fields" });
    }

    res.status(201).json({
        id: Date.now(),
        name,
        job
    });
});

app.listen(3000, () => {
    console.log("Server running on port 3000");
});
```

---

# 🔥 3. STEP 2 — PACKAGE FILE

## 📄 `package.json`

```json
{
  "name": "devops-api",
  "version": "1.0.0",
  "main": "app/server.js",
  "scripts": {
    "start": "node app/server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

---

# 🔥 4. STEP 3 — DOCKERFILE

## 📄 `Dockerfile`

```Dockerfile
FROM node:18

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

---

# 🔥 5. STEP 4 — BUILD & RUN

```bash
docker build -t devops-api .
docker run -d -p 3000:3000 devops-api
```

Test:

```bash
curl http://localhost:3000/health
```

Expected:

```json
{"status":"UP"}
```

---

# 🔥 6. STEP 5 — POSTMAN COLLECTION

## 📄 `collection.json`

### Request 1 — Health

```http
GET {{base_url}}/health
```

Tests:

```javascript
pm.test("Status 200", function () {
    pm.response.to.have.status(200);
});
```

---

### Request 2 — Create User

```http
POST {{base_url}}/users
```

Body:

```json
{
  "name": "Aisalkyn",
  "job": "DevOps Engineer"
}
```

Tests:

```javascript
pm.test("User created", function () {
    pm.response.to.have.status(201);
});

pm.test("Response has name", function () {
    let json = pm.response.json();
    pm.expect(json.name).to.eql("Aisalkyn");
});
```

---

# 🔥 7. STEP 6 — ENVIRONMENT FILE

## 📄 `environment.json`

```json
{
  "id": "env-id",
  "name": "local",
  "values": [
    {
      "key": "base_url",
      "value": "http://localhost:3000",
      "enabled": true
    }
  ]
}
```

---

# 🔥 8. STEP 7 — RUN NEWMAN LOCALLY

```bash
npm install -g newman

newman run collection.json -e environment.json
```

---

# 🔥 9. STEP 8 — GITHUB ACTIONS (REAL CI/CD)

## 📄 `.github/workflows/api-test.yml`

```yaml
name: API Docker Test

on:
  push:
    branches: [ main ]

jobs:
  test-api:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Start Docker container
        run: |
          docker build -t devops-api .
          docker run -d -p 3000:3000 devops-api

      - name: Wait for API
        run: sleep 10

      - name: Install Newman
        run: npm install -g newman

      - name: Run Tests
        run: newman run collection.json -e environment.json
```

---

# 🔥 10. WHY THIS LAB IS IMPORTANT (REAL DEVOPS)

You are simulating:

```plaintext
Code → Docker → Deploy → Test → Validate
```

---

# 🔥 11. COMMON FAILURES (VERY IMPORTANT)

### ❌ 1. API not ready

Pipeline runs too fast

Fix:

```yaml
sleep 10
```

---

### ❌ 2. Wrong base_url

```plaintext
localhost ≠ container network
```

---

### ❌ 3. Port not exposed

Docker missing:

```docker
EXPOSE 3000
```

---

### ❌ 4. Container crashed

Check logs:

```bash
docker logs <container_id>
```

---

# 🔥 12. WHAT YOU TELL INTERVIEWER

Short answer (perfect):

> "We deploy application in Docker, then run Newman tests to validate API endpoints like health, functional, and response validation. If tests fail, pipeline blocks deployment."

---

# 🔥 13. WHAT YOU GIVE TO MANAGER

Example:

* Deployment Status: SUCCESS
* API Health: PASS
* Functional Tests: PASS
* Response Time: 220ms
* Failures: 0


