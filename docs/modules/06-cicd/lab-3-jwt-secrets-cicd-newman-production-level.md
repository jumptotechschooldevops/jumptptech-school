---
title: "LAB 3 — JWT + Secrets + CI/CD + Newman (PRODUCTION LEVEL)"
description: "🔥 1. ARCHITECTURE (REAL FLOW)      Client → /login → JWT token        → /protected →..."
published: 2026-04-09
source: "https://dev.to/jumptotech/lab-3-jwt-secrets-cicd-newman-production-level-3odh"
tags: []
---

# LAB 3 — JWT + Secrets + CI/CD + Newman (PRODUCTION LEVEL)





# 🔥 1. ARCHITECTURE (REAL FLOW)

```plaintext
Client → /login → JWT token
       → /protected → validate token
       → Newman tests → CI/CD validation
```

---

# 🔥 2. PROJECT STRUCTURE

```plaintext
jwt-newman-lab/
├── app/
│   └── server.js
├── Dockerfile
├── package.json
├── collection.json
├── environment.json
├── .github/
│   └── workflows/
│       └── api-test.yml
```

---

# 🔥 3. STEP 1 — SECURE API WITH JWT

## 📄 `app/server.js`

```javascript
const express = require("express");
const jwt = require("jsonwebtoken");

const app = express();
app.use(express.json());

// 🔒 Secret from ENV (IMPORTANT)
const SECRET = process.env.JWT_SECRET || "dev-secret";

// LOGIN
app.post("/login", (req, res) => {
    const { username } = req.body;

    if (!username) {
        return res.status(400).json({ error: "Username required" });
    }

    const token = jwt.sign({ username }, SECRET, { expiresIn: "1h" });

    res.json({ token });
});

// PROTECTED ROUTE
app.get("/protected", (req, res) => {
    const auth = req.headers["authorization"];

    if (!auth) {
        return res.status(401).json({ error: "No token" });
    }

    const token = auth.split(" ")[1];

    try {
        const decoded = jwt.verify(token, SECRET);
        res.json({ message: "Access granted", user: decoded.username });
    } catch (err) {
        res.status(403).json({ error: "Invalid token" });
    }
});

app.listen(3000, () => {
    console.log("JWT API running on 3000");
});
```

---

# 🔥 4. STEP 2 — PACKAGE.JSON

```json
{
  "name": "jwt-api",
  "version": "1.0.0",
  "main": "app/server.js",
  "scripts": {
    "start": "node app/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0"
  }
}
```

---

# 🔥 5. STEP 3 — DOCKERFILE

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

# 🔥 6. STEP 4 — POSTMAN COLLECTION (IMPORTANT)

## Request 1 — LOGIN

```http
POST {{base_url}}/login
```

Body:

```json
{
  "username": "aisalkyn"
}
```

### Tests (SAVE TOKEN)

```javascript
let json = pm.response.json();
pm.environment.set("token", json.token);

pm.test("Token received", function () {
    pm.expect(json.token).to.exist;
});
```

---

## Request 2 — PROTECTED

```http
GET {{base_url}}/protected
```

Headers:

```http
Authorization: Bearer {{token}}
```

### Tests

```javascript
pm.test("Access granted", function () {
    pm.response.to.have.status(200);
});
```

---

# 🔥 7. STEP 5 — ENVIRONMENT FILE

```json
{
  "name": "local",
  "values": [
    { "key": "base_url", "value": "http://localhost:3000" },
    { "key": "token", "value": "" }
  ]
}
```

---

# 🔥 8. STEP 6 — RUN LOCALLY

```bash
docker build -t jwt-api .
docker run -d -p 3000:3000 -e JWT_SECRET=mysecret jwt-api

newman run collection.json -e environment.json
```

---

# 🔥 9. STEP 7 — GITHUB ACTIONS (REAL CI/CD)

## 📄 `.github/workflows/api-test.yml`

```yaml
name: JWT API Test

on:
  push:
    branches: [ main ]

jobs:
  test-api:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build & Run API
        run: |
          docker build -t jwt-api .
          docker run -d -p 3000:3000 -e JWT_SECRET=${{ secrets.JWT_SECRET }} jwt-api

      - name: Wait for API
        run: sleep 10

      - name: Install Newman
        run: npm install -g newman

      - name: Run Tests
        run: newman run collection.json -e environment.json
```

---

# 🔥 10. 🔐 SECRETS (VERY IMPORTANT)

In GitHub:

```plaintext
Settings → Secrets → Actions
```

Add:

```properties
JWT_SECRET = mysupersecret
```

---

# 🔥 11. WHY THIS IS REAL DEVOPS

You are doing:

* Secure API (JWT)
* No hardcoding secrets
* Pipeline validation
* Auth testing
* Fail-safe deployment

---

# 🔥 12. COMMON FAILURES (INTERVIEW GOLD)

### ❌ Token not saved

Newman fails because:

```plaintext
{{token}} is empty
```

---

### ❌ Wrong secret

Token created ≠ token verified

---

### ❌ Missing Authorization header

```http
401 Unauthorized
```

---

### ❌ Pipeline too fast

API not ready → tests fail

---

### ❌ Secrets not configured

GitHub:

```plaintext
JWT_SECRET undefined
```

---

# 🔥 13. WHAT YOU SAY IN INTERVIEW

Strong answer:

> "We test authenticated APIs using Postman and Newman. Token is dynamically generated and stored during test execution. In CI/CD, secrets are injected securely using GitHub Actions. This ensures secure and automated API validation before release."

---

# 🔥 14. WHAT YOU REPORT TO MANAGER

Example:

* Auth Test: PASS
* Protected Endpoint: PASS
* Token Validation: PASS
* Security: JWT verified
* Failures: 0

---

# 🔥 15. REAL PRODUCTION PIPELINE

```plaintext
Code Push
   ↓
Build Docker Image
   ↓
Deploy (ECS / Kubernetes)
   ↓
Run Newman (Auth + API tests)
   ↓
IF FAIL → rollback
IF PASS → production
```

-
