---
title: "LAB 1 — Your FIRST Newman Execution (from zero)"
description: "Create API test in Postman Export it Run it using Newman               Step 1 — Create Collection in..."
published: 2026-04-07
source: "https://dev.to/jumptotech/lab-1-your-first-newman-execution-from-zero-3363"
tags: []
---

# LAB 1 — Your FIRST Newman Execution (from zero)





* Create API test in Postman
* Export it
* Run it using Newman

---

# Step 1 — Create Collection in Postman

### 1. Open Postman

### 2. Create Collection:

* Name: `devops-newman-lab`

### 3. Add request:

* Name: `Get Users`
* Method: **GET**
* URL:

```bash
https://jsonplaceholder.typicode.com/users
```

---

# Step 2 — Add Tests (IMPORTANT)

Go to **Tests tab** and add:

```javascript
pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response is not empty", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.length).to.be.above(0);
});
```

Click **Send** → make sure it passes

---

# Step 3 — Export Collection

1. Click Collection → `...`
2. Click **Export**
3. Save as:

```bash
devops-lab-collection.json
```

---

# Step 4 — Install Newman

In your terminal (Mac):

```bash
npm install -g newman
```

Check:

```bash
newman -v
```

---

# Step 5 — Run with Newman

```bash
newman run devops-lab-collection.json
```

---

# Expected Output

```text
✔ Status is 200
✔ Response is not empty

2 tests passed
```

---

# What you just learned (IMPORTANT)

You:

* Created API test
* Automated validation
* Ran it via CLI

👉 This is **exact DevOps behavior**

---

# LAB 2 — Add Environment (REAL DEVOPS)

## Goal

Remove hardcoding

---

# Step 1 — Create Environment in Postman

Name: `dev`

Add variable:

| KEY      | VALUE                                                                        |
| -------- | ---------------------------------------------------------------------------- |
| base_url | [https://jsonplaceholder.typicode.com](https://jsonplaceholder.typicode.com) |

---

# Step 2 — Update Request

Change URL:

```bash
{{base_url}}/users
```

Test again → should work

---

# Step 3 — Export Environment

Save as:

```bash
dev-environment.json
```

---

# Step 4 — Run with Newman

```bash
newman run devops-lab-collection.json -e dev-environment.json
```

---

# Why this matters

Now:

* Same test works for dev / stage / prod
* No hardcoding (like Terraform best practice)

---

# LAB 3 — Add POST Request (REAL FLOW)

## Step 1 — Add request

* Name: `Create User`
* Method: POST
* URL:

```bash
{{base_url}}/users
```

### Body → JSON:

```json
{
  "name": "Aisalkyn",
  "job": "DevOps Engineer"
}
```

---

# Step 2 — Add Tests

```javascript
pm.test("Status is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("User created", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.name).to.eql("Aisalkyn");
});
```

---

# Step 3 — Export again

Overwrite:

```bash
devops-lab-collection.json
```

---

# Step 4 — Run Newman

```bash
newman run devops-lab-collection.json -e dev-environment.json
```

---

# LAB 4 — Save Data Between Requests (IMPORTANT)

## Goal:

Take `id` from POST → use in GET

---

# Step 1 — In POST Tests:

```javascript
let jsonData = pm.response.json();
pm.environment.set("user_id", jsonData.id);
```

---

# Step 2 — Add GET request

* Name: `Get User by ID`
* URL:

```bash
{{base_url}}/users/{{user_id}}
```

---

# Step 3 — Add test:

```javascript
pm.test("User fetched", function () {
    pm.response.to.have.status(200);
});
```

---

# Step 4 — Run again

```bash
newman run devops-lab-collection.json -e dev-environment.json
```

---

# LAB 5 — DevOps Simulation (Pipeline Style)

Now imagine this runs automatically:

```bash
#!/bin/bash

echo "Running API tests..."

newman run devops-lab-collection.json -e dev-environment.json

if [ $? -ne 0 ]; then
  echo "Tests failed. Deployment stopped."
  exit 1
fi

echo "Tests passed. Continue deployment."
```

---

# What you learned (BIG PICTURE)

You now know:

* How DevOps validates APIs
* How to automate API tests
* How to remove hardcoding
* How to chain requests
* How CI/CD works with APIs


