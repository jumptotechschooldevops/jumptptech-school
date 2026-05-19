---
title: "advanced lab API test with ci/cd"
description: "What you will build   A complete CI/CD pipeline that:   Builds app (simulate) Deploys app..."
published: 2026-04-07
source: "https://dev.to/jumptotech/advanced-lab-api-test-with-cicd-29eb"
tags: []
---

# advanced lab API test with ci/cd



# What you will build

A **complete CI/CD pipeline** that:

1. Builds app (simulate)
2. Deploys app (simulate or real)
3. Runs API tests using Newman
4. Uses environments (dev / prod)
5. Uses secrets (token)
6. Fails safely if API breaks

---

# Final Project Structure

```bash
project/
├── .github/workflows/
│   └── cicd.yml
├── postman/
│   ├── collection.json
│   ├── dev.json
│   └── prod.json
```

---

# Step 1 — Prepare Postman files

### Rename:

```bash
devops-lab.json → postman/collection.json
```

---

### Create dev environment

```json
// postman/dev.json
{
  "id": "dev-env",
  "name": "dev",
  "values": [
    {
      "key": "base_url",
      "value": "https://jsonplaceholder.typicode.com",
      "enabled": true
    }
  ]
}
```

---

### Create prod environment

```json
// postman/prod.json
{
  "id": "prod-env",
  "name": "prod",
  "values": [
    {
      "key": "base_url",
      "value": "https://jsonplaceholder.typicode.com",
      "enabled": true
    }
  ]
}
```

---

# Step 2 — Update your Postman request

Change URL:

```bash
{{base_url}}/users
```

---

# Step 3 — GitHub Actions (ADVANCED PIPELINE)

Create:

```bash
.github/workflows/cicd.yml
```

---

# Full PRO pipeline

```yaml
name: Full DevOps CI/CD Pipeline

on:
  push:
    branches: [ "main" ]

jobs:

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build step (simulate)
        run: echo "Building application..."

  deploy-dev:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to DEV (simulate)
        run: echo "Deploying to DEV..."

  test-dev:
    runs-on: ubuntu-latest
    needs: deploy-dev
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install Newman
        run: npm install -g newman

      - name: Run API tests (DEV)
        run: newman run postman/collection.json -e postman/dev.json

  deploy-prod:
    runs-on: ubuntu-latest
    needs: test-dev
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to PROD (simulate)
        run: echo "Deploying to PROD..."

  test-prod:
    runs-on: ubuntu-latest
    needs: deploy-prod
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install Newman
        run: npm install -g newman

      - name: Run API tests (PROD)
        run: newman run postman/collection.json -e postman/prod.json
```

---

# How this works (VERY IMPORTANT)

```text
Push code
   ↓
Build
   ↓
Deploy DEV
   ↓
Test DEV (Newman)
   ↓
IF FAIL → STOP ❌
IF PASS → Continue
   ↓
Deploy PROD
   ↓
Test PROD
```

---

# Step 4 — Add secrets (REAL WORLD)

In GitHub:

👉 Settings → Secrets → Actions

Add:

```text
API_TOKEN=your_token_here
```

---

# Use in Newman

Update command:

```yaml
run: newman run postman/collection.json \
     -e postman/dev.json \
     --env-var token=${{ secrets.API_TOKEN }}
```

---

# Step 5 — Add failure control (CRITICAL)

By default:

👉 If ANY test fails → job fails

👉 That means:

* ❌ Deployment blocked
* ✅ System protected

---

# Real-world DevOps scenarios

This pipeline protects you from:

* Broken API after deployment
* Wrong response structure
* Auth issues
* Microservice failures

---

# Interview-level explanation

> “I design CI/CD pipelines where API validation is performed using Newman after deployment. The pipeline ensures that if API tests fail in staging, the production deployment is blocked, maintaining system reliability.”


