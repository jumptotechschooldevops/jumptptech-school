---
title: "LAB: Build + Test API (Full Flow)"
description: "What You Will Learn    How API receives HTTP requests How frontend talks to backend How..."
published: 2026-04-11
source: "https://dev.to/jumptotech/lab-build-test-api-full-flow-1n4m"
tags: []
---

# LAB: Build + Test API (Full Flow)




## What You Will Learn

* How API receives HTTP requests
* How frontend talks to backend
* How DevOps tests APIs
* Why GET / POST / PUT / DELETE exist

---

# 1. PROJECT STRUCTURE

Create folder:

```plaintext
devops-api-lab/
├── backend/
│   └── server.js
├── frontend/
│   └── index.html
├── postman/
│   └── collection.json
```

---

# 2. BACKEND (API SERVER)

## Install Node.js

Download from: Node.js

---

## Create `backend/server.js`

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// Fake database
let users = [
  { id: 1, name: "John" },
  { id: 2, name: "Alice" }
];

// GET (READ)
app.get('/users', (req, res) => {
  res.json(users);
});

// POST (CREATE)
app.post('/users', (req, res) => {
  const newUser = {
    id: users.length + 1,
    name: req.body.name
  };
  users.push(newUser);
  res.status(201).json(newUser);
});

// PUT (UPDATE)
app.put('/users/:id', (req, res) => {
  const user = users.find(u => u.id == req.params.id);
  if (!user) return res.status(404).send("User not found");

  user.name = req.body.name;
  res.json(user);
});

// DELETE (REMOVE)
app.delete('/users/:id', (req, res) => {
  users = users.filter(u => u.id != req.params.id);
  res.send("User deleted");
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
```

---

## Install dependencies

```bash
cd backend
npm init -y
npm install express
node server.js
```

---

# 3. FRONTEND (UI)

## Create `frontend/index.html`

```html
<!DOCTYPE html>
<html>
<head>
  <title>DevOps API Lab</title>
</head>
<body>

<h2>Users</h2>
<button onclick="getUsers()">Get Users</button>
<button onclick="addUser()">Add User</button>

<ul id="list"></ul>

<script>
async function getUsers() {
  const res = await fetch('http://localhost:3000/users');
  const data = await res.json();

  const list = document.getElementById('list');
  list.innerHTML = '';

  data.forEach(user => {
    const li = document.createElement('li');
    li.innerText = user.name;
    list.appendChild(li);
  });
}

async function addUser() {
  await fetch('http://localhost:3000/users', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ name: "New User" })
  });

  getUsers();
}
</script>

</body>
</html>
```

---

## Run frontend

Just open file in browser:

```plaintext
frontend/index.html
```

---

# 4. WHAT IS HAPPENING (IMPORTANT)

## HTTP FLOW

### GET

```http
GET /users
```

* Used to **READ data**
* No body

---

### POST

```http
POST /users
```

* Used to **CREATE**
* Sends JSON body

---

### PUT

```http
PUT /users/1
```

* Used to **UPDATE**

---

### DELETE

```http
DELETE /users/1
```

* Used to **REMOVE**

---

## WHY HTTP EXISTS

HTTP is:

* Standard communication protocol
* Used between:

  * Browser → Backend
  * Frontend → API
  * DevOps tools → Services

---

# 5. TEST WITH POSTMAN

Open **Postman**

### Create requests:

### GET

```http
GET http://localhost:3000/users
```

---

### POST

```http
POST http://localhost:3000/users
Body:
{
  "name": "DevOps User"
}
```

---

### PUT

```http
PUT http://localhost:3000/users/1
Body:
{
  "name": "Updated User"
}
```

---

### DELETE

```http
DELETE http://localhost:3000/users/1
```

---

# 6. AUTOMATION WITH NEWMAN

Install:

```bash
npm install -g newman
```

---

## Create `postman/collection.json`

```json
{
  "info": {
    "name": "DevOps API Lab",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
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
          "raw": "{ \"name\": \"Newman User\" }"
        },
        "url": "http://localhost:3000/users"
      }
    }
  ]
}
```

---

## Run Newman

```bash
cd postman
newman run collection.json
```

---

# 7. REAL DEVOPS CONNECTION

This lab simulates real work:

* CI/CD pipeline runs Newman tests
* Backend deployed on AWS EC2 / ECS
* Frontend hosted on S3
* DevOps validates API before deployment

---

# 8. INTERVIEW ANSWER (SHORT)

**Q: What is API?**
API allows communication between frontend and backend using HTTP methods.

**Q: Why GET vs POST?**

* GET → fetch data
* POST → create data
* PUT → update
* DELETE → remove

**Q: What do DevOps test?**

* API availability
* Response correctness
* Status codes
* Performance


