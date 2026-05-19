---
title: "LAB: DevOps API Pipeline"
description: "What You Will Learn    How DevOps runs API tests in pipeline How Docker is used How CI/CD..."
published: 2026-04-11
source: "https://dev.to/jumptotech/lab-devops-api-pipeline-2879"
tags: []
---

# LAB: DevOps API Pipeline




## What You Will Learn

* How DevOps runs API tests in pipeline
* How Docker is used
* How CI/CD validates backend before deploy
* Real workflow used in companies

---

# 1. PROJECT STRUCTURE

```bash
devops-api-pipeline/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── postman/
│   └── collection.json
├── .github/
│   └── workflows/
│       └── api-test.yml
```

---

# 2. BACKEND (same logic, slightly improved)

## backend/server.js

```javascript
const express = require('express');
const app = express();

app.use(express.json());

let users = [
  { id: 1, name: "John" },
  { id: 2, name: "Alice" }
];

// HEALTH CHECK (important in DevOps)
app.get('/health', (req, res) => {
  res.send("OK");
});

app.get('/users', (req, res) => {
  res.json(users);
});

app.post('/users', (req, res) => {
  const newUser = {
    id: users.length + 1,
    name: req.body.name
  };
  users.push(newUser);
  res.status(201).json(newUser);
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

---

## backend/package.json

```json
{
  "name": "devops-api",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

---

# 3. DOCKER (IMPORTANT)

## backend/Dockerfile

```dockerfile
FROM node:18

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

---

## Build & Run locally

```bash
cd backend

docker build -t devops-api .
docker run -p 3000:3000 devops-api
```

Test:

```plaintext
http://localhost:3000/health
```

---

# 4. POSTMAN COLLECTION (REAL TESTS)

## postman/collection.json

```json
{
  "info": {
    "name": "DevOps API Pipeline",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/health"
      }
    },
    {
      "name": "Get Users",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/users"
      }
    },
    {
      "name": "Create User",
      "request": {
        "method": "POST",
        "header": [
          { "key": "Content-Type", "value": "application/json" }
        ],
        "body": {
          "mode": "raw",
          "raw": "{ \"name\": \"CI User\" }"
        },
        "url": "http://localhost:3000/users"
      }
    }
  ]
}
```

---

# 5. CI/CD PIPELINE

## .github/workflows/api-test.yml

```yaml
name: API Test Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  test-api:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Build Docker image
      run: docker build -t devops-api ./backend

    - name: Run container
      run: |
        docker run -d -p 3000:3000 --name api devops-api
        sleep 5

    - name: Install Newman
      run: npm install -g newman

    - name: Run API tests
      run: newman run postman/collection.json
```

---

# 6. HOW THIS WORKS (IMPORTANT)

### Step-by-step:

1. Code pushed to GitHub
2. **GitHub Actions** triggers pipeline
3. Docker builds app
4. Container runs API
5. **Newman** tests endpoints
6. If tests fail → pipeline FAILS

---

# 7. WHY THIS IS REAL DEVOPS

This is exactly what companies do:

* Validate API before deployment
* Prevent broken code in production
* Automate testing

---

# 8. ADDITIONAL IMPROVEMENTS (REAL WORLD)

You can extend:

### Add assertions in Postman

Example:

```javascript
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});
```

---

### Add environment variables

```json
"url": "{{base_url}}/users"
```

---

### Add Docker push (ECR / GHCR)

---

# 9. INTERVIEW ANSWERS

**Q: How do you test APIs in CI/CD?**
→ Using Postman collections executed via Newman inside pipeline.

**Q: Why Docker here?**
→ To ensure same environment everywhere.

**Q: What if API fails?**
→ Pipeline stops → deployment blocked.

---

# 10. WHAT YOU JUST BUILT

You built:

* API
* Docker image
* Automated testing pipeline
* Real DevOps workflow


