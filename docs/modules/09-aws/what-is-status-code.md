---
title: "What is Status Code?"
description: "When frontend calls backend, server responds with:    Status Code + Response        Enter fullscreen..."
published: 2026-04-11
source: "https://dev.to/jumptotech/what-is-status-code-31d7"
tags: []
---

# What is Status Code?




When frontend calls backend, server responds with:

```id="rbr78x"
Status Code + Response
```

👉 Status code tells:

* success
* error
* what happened

---

# ✅ 1xx — Informational (Rare)

| Code | Meaning             |
| ---- | ------------------- |
| 100  | Continue            |
| 101  | Switching Protocols |

👉 Usually not used in your API testing

---

# ✅ 2xx — SUCCESS (Most Important)

| Code | Meaning    | When used                    |
| ---- | ---------- | ---------------------------- |
| 200  | OK         | GET success                  |
| 201  | Created    | POST success                 |
| 202  | Accepted   | Request accepted (async)     |
| 204  | No Content | Success but no response body |

---

### 🔥 Examples

```http id="hwl2wr"
GET /users → 200 OK
```

```http id="tsmz92"
POST /users → 201 Created
```

```http id="21npr6"
DELETE /users/4 → 204 No Content
```

---

# ✅ 3xx — REDIRECTION

| Code | Meaning                    |
| ---- | -------------------------- |
| 301  | Moved Permanently          |
| 302  | Found (temporary redirect) |
| 304  | Not Modified               |

👉 Mostly browser-related, not common in API testing

---

# ✅ 4xx — CLIENT ERRORS (VERY IMPORTANT)

👉 Problem from **user/request side**

| Code | Meaning              | Example            |
| ---- | -------------------- | ------------------ |
| 400  | Bad Request          | Missing JSON field |
| 401  | Unauthorized         | No login/token     |
| 403  | Forbidden            | No permission      |
| 404  | Not Found            | Wrong URL or ID    |
| 405  | Method Not Allowed   | Wrong HTTP method  |
| 409  | Conflict             | Duplicate data     |
| 422  | Unprocessable Entity | Validation failed  |

---

### 🔥 Examples

```http id="33rrv1"
GET /users/999 → 404 Not Found
```

```http id="9flkqn"
POST without body → 400 Bad Request
```

---

# ✅ 5xx — SERVER ERRORS (VERY IMPORTANT)

👉 Problem from **backend/server**

| Code | Meaning               |
| ---- | --------------------- |
| 500  | Internal Server Error |
| 502  | Bad Gateway           |
| 503  | Service Unavailable   |
| 504  | Gateway Timeout       |

---

### 🔥 Examples

```http id="2lm9mt"
Database crash → 500
```

```http id="d4bf3k"
Server overloaded → 503
```

---

# 🔥 WHAT YOU SHOULD USE IN YOUR API

### Your current backend:

#### GET

```js id="tj9xjs"
res.json(users);
```

👉 Returns:

```id="d3m7v9"
200 OK
```

---

#### POST

```js id="hcn8wp"
res.status(201).json(newUser);
```

👉 Correct:

```id="kxj6h8"
201 Created
```

---

#### PUT

```js id="c3yo0x"
res.json(user);
```

👉 Should be:

```id="h9n83j"
200 OK
```

---

#### DELETE

Right now:

```js id="bzgk4x"
res.send("User deleted");
```

👉 Better (production):

```js id="2p5b6q"
res.status(204).send();
```

---

# 🔥 INTERVIEW ANSWERS (IMPORTANT)

### ❓ What status code for POST?

> 201 Created

---

### ❓ What status code if user not found?

> 404 Not Found

---

### ❓ What status code for server error?

> 500 Internal Server Error

---

### ❓ What status code for successful GET?

> 200 OK

---

# 🔥 DEVOPS VIEW

You monitor APIs using status codes:

* 200 → healthy
* 4xx → client issue
* 5xx → system failure (critical alert)

---

# 🔥 QUICK CHEAT SHEET

```id="vz8s89"
200 → OK
201 → Created
204 → No Content
400 → Bad Request
401 → Unauthorized
403 → Forbidden
404 → Not Found
500 → Server Error
```


