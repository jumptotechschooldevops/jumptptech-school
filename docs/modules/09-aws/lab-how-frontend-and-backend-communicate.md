---
title: "lab: how frontend and backend communicate"
description: "Build a small user application:   Browser opens frontend from S3 static website  Frontend sends HTTP..."
published: 2026-04-11
source: "https://dev.to/jumptotech/lab-how-frontend-and-backend-communicate-12b7"
tags: []
---

# lab: how frontend and backend communicate







Build a small user application:

* Browser opens frontend from **S3 static website**
* Frontend sends HTTP requests to **backend on EC2**
* Backend returns JSON
* You test API with **Postman**
* You automate tests with **Newman**

---

# Architecture

```text
User Browser
    |
    v
S3 Static Frontend
    |
    | HTTP request
    v
EC2 Backend API (Node.js / Express)
    |
    v
JSON Response
```

---

# What You Will Learn

## API

An API is a way for one system to talk to another.

Example:

* frontend asks backend: “give me users”
* backend sends JSON back

## HTTP

HTTP is the communication protocol used between:

* browser and server
* frontend and backend
* Postman and backend
* Newman and backend

## Methods

* **GET** = read data
* **POST** = create data
* **PUT** = update data
* **DELETE** = remove data

These methods exist so systems can clearly say what action they want.

---

# Final Project Structure

```text
aws-api-lab/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── frontend/
│   └── index.html
├── postman/
│   └── collection.json
└── README-commands.txt
```

---

# Part 1 — Backend API

## 1. Create `backend/package.json`

```json
{
  "name": "aws-api-lab",
  "version": "1.0.0",
  "description": "Simple API lab for DevOps engineers",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.19.2"
  }
}
```

---

## 2. Create `backend/server.js`

```javascript
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

let users = [
  { id: 1, name: "Aisalkyn" },
  { id: 2, name: "DevOps Student" }
];

// Health check
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// GET - Read all users
app.get("/users", (req, res) => {
  res.status(200).json(users);
});

// GET - Read one user
app.get("/users/:id", (req, res) => {
  const userId = Number(req.params.id);
  const user = users.find(u => u.id === userId);

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  res.status(200).json(user);
});

// POST - Create user
app.post("/users", (req, res) => {
  const { name } = req.body;

  if (!name || typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ message: "Name is required" });
  }

  const newUser = {
    id: users.length ? users[users.length - 1].id + 1 : 1,
    name: name.trim()
  };

  users.push(newUser);
  res.status(201).json(newUser);
});

// PUT - Update user
app.put("/users/:id", (req, res) => {
  const userId = Number(req.params.id);
  const { name } = req.body;

  const user = users.find(u => u.id === userId);

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  if (!name || typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ message: "Name is required" });
  }

  user.name = name.trim();
  res.status(200).json(user);
});

// DELETE - Remove user
app.delete("/users/:id", (req, res) => {
  const userId = Number(req.params.id);
  const existingLength = users.length;

  users = users.filter(u => u.id !== userId);

  if (users.length === existingLength) {
    return res.status(404).json({ message: "User not found" });
  }

  res.status(200).json({ message: "User deleted" });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on http://0.0.0.0:${PORT}`);
});
```

This code is simple and working. It includes:

* validation
* proper status codes
* health endpoint
* all major HTTP methods

---

## 3. Create `backend/Dockerfile`

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY server.js ./

EXPOSE 3000

CMD ["npm", "start"]
```

---

# Part 2 — Frontend

## Create `frontend/index.html`

Important: later you will replace `YOUR-EC2-PUBLIC-IP` with your real EC2 public IP.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>AWS API Lab</title>
</head>
<body>
  <h1>AWS API Lab</h1>

  <p>This frontend is hosted on S3 and talks to backend on EC2.</p>

  <button onclick="getUsers()">Get Users</button>
  <button onclick="createUser()">Create User</button>

  <h2>Users</h2>
  <pre id="output"></pre>

  <script>
    const API_BASE_URL = "http://YOUR-EC2-PUBLIC-IP:3000";

    async function getUsers() {
      try {
        const response = await fetch(`${API_BASE_URL}/users`);
        const data = await response.json();
        document.getElementById("output").textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        document.getElementById("output").textContent = "Error: " + error.message;
      }
    }

    async function createUser() {
      try {
        const response = await fetch(`${API_BASE_URL}/users`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({ name: "New AWS User" })
        });

        const data = await response.json();
        document.getElementById("output").textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        document.getElementById("output").textContent = "Error: " + error.message;
      }
    }
  </script>
</body>
</html>
```

---

# Part 3 — Postman Collection

## Create `postman/collection.json`

Replace `YOUR-EC2-PUBLIC-IP` before running.

```json
{
  "info": {
    "name": "AWS API Lab Collection",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "http://YOUR-EC2-PUBLIC-IP:3000/health",
          "protocol": "http",
          "host": ["YOUR-EC2-PUBLIC-IP"],
          "port": "3000",
          "path": ["health"]
        }
      }
    },
    {
      "name": "Get Users",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "http://YOUR-EC2-PUBLIC-IP:3000/users",
          "protocol": "http",
          "host": ["YOUR-EC2-PUBLIC-IP"],
          "port": "3000",
          "path": ["users"]
        }
      }
    },
    {
      "name": "Create User",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"Postman User\"\n}"
        },
        "url": {
          "raw": "http://YOUR-EC2-PUBLIC-IP:3000/users",
          "protocol": "http",
          "host": ["YOUR-EC2-PUBLIC-IP"],
          "port": "3000",
          "path": ["users"]
        }
      }
    },
    {
      "name": "Update User",
      "request": {
        "method": "PUT",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"Updated User\"\n}"
        },
        "url": {
          "raw": "http://YOUR-EC2-PUBLIC-IP:3000/users/1",
          "protocol": "http",
          "host": ["YOUR-EC2-PUBLIC-IP"],
          "port": "3000",
          "path": ["users", "1"]
        }
      }
    },
    {
      "name": "Delete User",
      "request": {
        "method": "DELETE",
        "header": [],
        "url": {
          "raw": "http://YOUR-EC2-PUBLIC-IP:3000/users/2",
          "protocol": "http",
          "host": ["YOUR-EC2-PUBLIC-IP"],
          "port": "3000",
          "path": ["users", "2"]
        }
      }
    }
  ]
}
```

---

# Part 4 — AWS Setup

## Step 1: Launch EC2

Create one EC2 instance:

* Ubuntu
* t2.micro or t3.micro
* allow:

  * SSH 22 from your IP
  * Custom TCP 3000 from anywhere for this lab
  * or HTTP 80 if you later use Nginx reverse proxy

For this simple lab, open:

* port 22
* port 3000

---

## Step 2: Connect to EC2

```bash
ssh -i your-key.pem ubuntu@YOUR-EC2-PUBLIC-IP
```

---

## Step 3: Install Docker on EC2

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
newgrp docker
docker --version
```

---

## Step 4: Upload backend files to EC2

From your local machine:

```bash
scp -i your-key.pem -r backend ubuntu@YOUR-EC2-PUBLIC-IP:/home/ubuntu/
```

---

## Step 5: Build and run backend on EC2

SSH into EC2 and run:

```bash
cd /home/ubuntu/backend
docker build -t aws-api-lab .
docker run -d --name api -p 3000:3000 aws-api-lab
```

Check:

```bash
docker ps
curl http://localhost:3000/health
curl http://localhost:3000/users
```

From your own laptop, also check:

```bash
curl http://YOUR-EC2-PUBLIC-IP:3000/health
```

You should get:

```json
{"status":"ok"}
```

---

# Part 5 — Host Frontend on S3

## Step 1: Create S3 bucket

Create an S3 bucket with a globally unique name, for example:

```text
aisalkyn-aws-api-lab-frontend
```

---

## Step 2: Enable static website hosting

In S3 bucket:

* go to Properties
* enable Static website hosting
* index document: `index.html`

---

## Step 3: Upload `frontend/index.html`

Before uploading, replace:

```javascript
http://YOUR-EC2-PUBLIC-IP:3000
```

with your real IP.

Then upload the file.

---

## Step 4: Make objects public

For a simple lab:

* disable block public access for this bucket
* allow read access to objects

Sample bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForWebsite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    }
  ]
}
```

Replace `YOUR-BUCKET-NAME`.

---

## Step 5: Open S3 website URL

Now open the static website endpoint from S3.

When you click:

* **Get Users** → frontend sends GET request to EC2 backend
* **Create User** → frontend sends POST request to EC2 backend

That is the full frontend-to-backend flow.

---

# Part 6 — Test with Postman

In Postman, use your EC2 public IP.

## Health

```http
GET http://YOUR-EC2-PUBLIC-IP:3000/health
```

## Get all users

```http
GET http://YOUR-EC2-PUBLIC-IP:3000/users
```

## Create

```http
POST http://YOUR-EC2-PUBLIC-IP:3000/users
Content-Type: application/json

{
  "name": "Aisalkyn API Student"
}
```

## Update

```http
PUT http://YOUR-EC2-PUBLIC-IP:3000/users/1
Content-Type: application/json

{
  "name": "Updated Name"
}
```

## Delete

```http
DELETE http://YOUR-EC2-PUBLIC-IP:3000/users/1
```

---

# Part 7 — Run with Newman

Install Newman on your laptop:

```bash
npm install -g newman
```

Run:

```bash
cd postman
newman run collection.json
```

This is how DevOps engineers automate API checks.

---

# Why Each HTTP Method Works

## GET

Used to read information.
It does not usually change data.

Example:

```http
GET /users
```

## POST

Used to create new data.

Example:

```http
POST /users
```

Body:

```json
{
  "name": "New User"
}
```

## PUT

Used to update existing data.

Example:

```http
PUT /users/1
```

## DELETE

Used to remove data.

Example:

```http
DELETE /users/1
```

These methods matter because backend code behaves differently depending on the request type.

---

# Why HTTP Is There

HTTP is there because systems need a standard language for communication.

Without HTTP:

* browser would not know how to ask server for data
* Postman would not know how to test endpoint
* frontend would not know how to send create/update/delete actions
* backend would not know how to interpret request type

HTTP gives structure:

* method
* URL
* headers
* body
* response code

---

# Important DevOps Understanding

A DevOps engineer does not always write large applications, but must understand:

* where frontend is hosted
* where backend is running
* how requests reach backend
* what ports are open
* what security groups allow traffic
* how to test health and endpoints
* how to automate checks with Newman
* how to troubleshoot if app fails

---

# Common Problems and Fixes

## 1. Frontend opens but cannot reach backend

Usually:

* EC2 security group does not allow port 3000
* wrong EC2 public IP in frontend file
* backend container is not running

Check:

```bash
docker ps
curl http://localhost:3000/health
```

---

## 2. Browser shows CORS error

You already included:

```javascript
app.use(cors());
```

That fixes most basic CORS problems for this lab.

---

## 3. Newman says request URL is empty

That usually means collection JSON does not contain full URL, or placeholder was not replaced.

---

## 4. Port 3000 not reachable

Check EC2 security group inbound rules.

---

# Commands Summary

## Local backend test

```bash
cd backend
npm install
node server.js
```

## Docker local

```bash
docker build -t aws-api-lab .
docker run -d -p 3000:3000 aws-api-lab
```

## EC2 Docker

```bash
cd /home/ubuntu/backend
docker build -t aws-api-lab .
docker run -d --name api -p 3000:3000 aws-api-lab
```

## Health check

```bash
curl http://YOUR-EC2-PUBLIC-IP:3000/health
```

## Newman

```bash
newman run collection.json
```

---

# Interview Value

This lab helps you answer questions like:

## What is an API?

An API allows systems like frontend, Postman, or other services to communicate with backend using HTTP requests and responses.

## Why do we use GET, POST, PUT, DELETE?

Because each method represents a different type of action on the resource: read, create, update, and delete.

## What does a DevOps engineer check here?

* backend availability
* port accessibility
* health endpoint
* status codes
* request/response correctness
* frontend-to-backend connectivity
* automated testing with Newman


