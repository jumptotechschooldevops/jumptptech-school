---
title: "lab with Newman API"
description: "When you push code → pipeline will:   Install Node.js Install Newman Run your exported Postman..."
published: 2026-04-07
source: "https://dev.to/jumptotech/lab-with-newman-api-hlg"
tags: []
---

# lab with Newman API





When you push code → pipeline will:

1. Install Node.js
2. Install Newman
3. Run your exported Postman collection
4. Fail if API tests fail

---

# Step 1 — Prepare your repo

Create a GitHub repo (or use existing)

Structure:

```bash
project/
├── .github/
│   └── workflows/
│       └── api-test.yml
├── devops-lab.json
```

👉 Put your exported file here:

```bash
devops-lab.json
```

---

# Step 2 — Create GitHub Actions file

Create file:

```bash
.github/workflows/api-test.yml
```

---

# Step 3 — Add this code (READY, CLEAN)

```yaml
name: API Tests with Newman

on:
  push:
    branches: [ "main" ]

jobs:
  run-api-tests:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install Newman
        run: npm install -g newman

      - name: Run Postman Collection
        run: newman run devops-lab.json
```

---

# Step 4 — Push to GitHub

```bash
git add .
git commit -m "add api test pipeline"
git push origin main
```

---

# Step 5 — Go to GitHub

👉 Open your repo
👉 Click **Actions tab**

You will see:

```text
API Tests with Newman → Running
```

---

# Expected result

If everything works:

```text
✔ Status is 200
✔ Response is not empty
```

Job status:

```text
✅ SUCCESS
```

---

# What happens if API breaks?

Example:

* API returns 500
* Test fails

Then:

```text
❌ FAILED
```

👉 Pipeline stops
👉 Deployment blocked

---

# Real DevOps Flow (IMPORTANT)

```text
Developer pushes code
        ↓
GitHub Actions runs
        ↓
Deploy app (optional step)
        ↓
Run Newman tests
        ↓
If FAIL → stop
If PASS → continue
```

---

# Step 6 — (OPTIONAL but PRO LEVEL)

Add environment file:

```bash
dev.json
```

Then run:

```yaml
- name: Run Postman Collection
  run: newman run devops-lab.json -e dev.json
```

---

# Interview answer (use this)

> “I integrate Postman collections into GitHub Actions using Newman. The pipeline runs API tests automatically after code changes and fails the build if any validation fails.”


