---
title: "API part #1"
description: "1. What is API Testing (Core Idea)     UI Testing (Frontend) → Testing what user sees..."
published: 2026-04-01
source: "https://dev.to/jumptotech/api-part-1-27km"
tags: []
---

# API part #1



# 1. What is API Testing (Core Idea)

* **UI Testing (Frontend)** → Testing what user sees (browser)
* **API Testing (Backend)** → Testing logic behind the application
* **Database Testing** → Testing stored data

### Key Point:

* UI = Presentation layer
* API = Business logic layer
* DB = Data layer 

---

# 2. Types of Applications

There are **3 types**:

1. **Desktop Applications**

   * Runs locally (Excel, Notepad)
   * No internet required

2. **Web Applications**

   * Browser-based
   * Uses client-server architecture

3. **Mobile Applications**

   * Apps like WhatsApp, LinkedIn
   * Use APIs heavily 

---

# 3. Client vs Server (Very Important)

### Client

* Sends request
* Example: Browser, mobile app

### Server

* Receives request
* Processes request
* Sends response

**Flow:**

```plaintext
Client → Request → Server → Response → Client
```

---

# 4. Architecture Types

### 1-Tier

* Everything on one system
* Example: Notepad

### 2-Tier

* Client + Database
* Example: Bank internal systems

### 3-Tier (Most Important)

* Client (UI)
* Application (API / logic)
* Database

This is what modern apps use. 

---

# 5. 3 Layers of Web Application

### 1. Presentation Layer

* HTML, CSS, JavaScript
* UI / browser

### 2. Application Layer

* Business logic (APIs)
* Written in Java, Python, .NET

### 3. Data Layer

* Databases (MySQL, Postgres)

**Important:**
API sits between UI and DB. 

---

# 6. What is an API (Interview Definition)

**API = Application Programming Interface**

### Simple Definition:

* A **messenger** between frontend and backend

### Real Flow:

```plaintext
User → UI → API → Database → API → UI
```

Example:

* Login → API checks DB → returns success/fail 

---

# 7. Why API Testing is Important

### Old Approach:

* 70% UI testing
* 30% API testing

### Modern Approach:

* 70% API testing
* 30% UI testing

### Why?

* APIs are ready before UI
* Faster testing
* More stable
* Covers core logic 

---

# 8. Real-Life API Example

### Restaurant Analogy

| Role     | Real System |
| -------- | ----------- |
| Customer | Client      |
| Waiter   | API         |
| Chef     | Server      |

Flow:

```plaintext
Customer → Waiter(API) → Chef(DB/logic) → Waiter → Customer
```

---

# 9. Types of APIs

### 1. Public (Open APIs)

* Available to everyone
* Example: Google Maps API

### 2. Private APIs

* Inside company only
* Not accessible publicly

### 3. Partner APIs

* Shared with partners
* Example: Uber using Google Maps

### 4. Composite APIs

* Combine multiple APIs into one request 

---

# 10. API vs Web Service vs Microservice

### API

* Interface for communication

### Web Service

* API exposed on internet

### Microservice

* Small piece of functionality

### Relationship:

```plaintext
Microservices → communicate via APIs → exposed as Web Services
```

---

# 11. REST API (Most Important)

Modern systems use **REST APIs (90%)**

### Why REST?

* Fast
* Lightweight (JSON)
* Flexible

### SOAP (Old)

* Uses XML only
* Heavy and slower 

---

# 12. HTTP Methods (CRUD Operations)

| Method | Meaning        |
| ------ | -------------- |
| GET    | Read data      |
| POST   | Create data    |
| PUT    | Update data    |
| PATCH  | Partial update |
| DELETE | Remove data    |

---

# 13. Request vs Response

### Request

* What you send

### Response

* What you receive

### Payload

* Request payload → data you send
* Response payload → data you receive 

---

# 14. HTTP vs HTTPS

| HTTP       | HTTPS     |
| ---------- | --------- |
| Not secure | Secure    |
| Plain text | Encrypted |

Always use HTTPS for sensitive data.

---

# 15. Status Codes (VERY IMPORTANT)

### 1xx → Processing

### 2xx → Success

### 3xx → Redirect

### 4xx → Client error

### 5xx → Server error

Examples:

* 200 → OK
* 404 → Not Found
* 500 → Server Error 

---

# 16. What You Validate in API Testing

When testing APIs, always validate:

* Status Code
* Response Body
* Response Time
* Headers
* Data correctness

---

# 17. API Testing Flow

```plaintext
Client → Request → API → Server → DB → Response → Client
```

---

# 18. Key DevOps Takeaways (Very Important for You)

For a **6+ year DevOps engineer**, API knowledge is critical:

* Debug microservices communication
* Work with API Gateway, Lambda
* Automate API testing in CI/CD
* Troubleshoot distributed systems
* Validate integrations (SNS, SQS, Kafka, etc.)



# 1. What is Postman

**Postman = API Testing Tool**

* Used for **manual API testing**
* Supports **automation (basic) using JavaScript**
* Industry standard tool

### Key capability:

* Send request → Get response → Validate response 

---

# 2. Why DevOps Engineers Must Know Postman

For you (DevOps perspective):

* Debug microservices
* Test APIs before deployment
* Validate API Gateway / Lambda
* Troubleshoot integrations (Kafka, SNS, SQS)
* Use in CI/CD pipelines

---

# 3. Postman Types

### 1. Desktop App

* Installed locally

### 2. Web Version

* Runs in browser

### Important:

* Both use **Postman Cloud**
* All data stored in cloud (collections, requests) 

---

# 4. Postman Core Concepts (Very Important)

## 1. Workspace

* Like a **project environment**

## 2. Collection

* Group of requests
* Like a **folder or project module**

## 3. Request

* Actual API call

### Structure:

```id="g7k1p0"
Workspace → Collection → Request
```

---

# 5. What is a Collection

### Definition:

* Collection = **group of API requests**

Inside collection:

* Requests
* Folders (optional)

Example:

```id="v8f2lm"
Collection: User API
   ├── GET Users
   ├── POST User
   ├── PUT User
   └── DELETE User
```

---

# 6. Types of Requests (Hands-on)

### GET

* Retrieve data

### POST

* Create data

### PUT

* Update full record

### PATCH

* Update partial record

### DELETE

* Remove data 

---

# 7. Request vs Response (Postman View)

## Request

* URL
* Method (GET/POST…)
* Headers
* Body (payload)

## Response

* Body (data)
* Status Code
* Headers
* Response Time

---

# 8. Demo API Used

You used:

```plaintext
https://reqres.in
```

This is a **public testing API** (very important for beginners).

---

# 9. GET Request Example

### URL:

```id="s9k2pq"
https://reqres.in/api/users?page=2
```

### Result:

* Returns list of users
* Status: 200

### Important:

* No payload required

---

# 10. POST Request Example

### URL:

```id="l0f3dn"
https://reqres.in/api/users
```

### Body (JSON):

```json
{
  "name": "Aisalkyn",
  "job": "DevOps Engineer"
}
```

### Result:

* Creates new user
* Returns:

  * ID
  * Created timestamp

### Status:

```http
201 Created
```

---

# 11. PUT Request Example

### URL:

```id="z3x9pl"
https://reqres.in/api/users/76
```

### Body:

```json
{
  "name": "Aisalkyn",
  "job": "Senior DevOps Engineer"
}
```

### Result:

* Updates record

### Status:

```http
200 OK
```

---

# 12. DELETE Request Example

### URL:

```id="k1d8fs"
https://reqres.in/api/users/76
```

### Result:

* Deletes record

### Status:

```http
204 No Content
```

---

# 13. Query vs Path Parameters

### Query Parameter

```id="r2m7qa"
?page=2
```

* Used for filtering

### Path Parameter

```id="p9x1ke"
users/2
```

* Direct resource access

---

# 14. Request Payload vs Response Payload

### Request Payload

* Data you send
* Example: JSON body

### Response Payload

* Data you receive

---

# 15. Where Payload is Used

| Request Type | Payload    |
| ------------ | ---------- |
| GET          | Usually no |
| POST         | Yes        |
| PUT          | Yes        |
| DELETE       | No         |

---

# 16. Postman UI Important Sections

* **URL bar**
* **Method dropdown**
* **Body tab**
* **Headers tab**
* **Authorization tab**
* **Response panel**

---

# 17. Why NOT Use Browser for API Testing

Browser only shows:

* Response data

But Postman shows:

* Status code
* Headers
* Cookies
* Response time
* Full validation

---

# 18. Key DevOps Insight

In real projects:

* APIs may require:

  * API keys
  * Tokens (JWT)
  * OAuth

* You will test:

  * Security
  * Performance
  * Integration

---

# 19. Important Interview Points

Be ready to answer:

* What is Postman?
* Difference between PUT and PATCH
* What is payload?
* What is collection?
* What is status code 200 / 201 / 204?
* Difference between query vs path param

---

# 20. What You Should Practice Now

Do this before next step:

1. Install Postman
2. Create:

   * 1 Workspace
   * 1 Collection
3. Add:

   * GET request
   * POST request
   * PUT request
   * DELETE request
4. Test with `reqres.in`












# 1. Why DevOps Engineers Need This

This lecture is **VERY IMPORTANT** because:

* You won’t always get real APIs
* You must:

  * Mock APIs
  * Test locally
  * Validate responses
  * Debug pipelines

So this topic = **real DevOps work**

---

# 2. How to Create Your Own API (Local API)

## Required Components

You need 3 things:

### 1. Node.js

* Runtime to run JavaScript

### 2. npm (Node Package Manager)

* Comes with Node.js

### 3. JSON Server

* Tool to convert JSON → API

---

## Installation Flow

### Step 1 — Install Node.js

* Download → install

### Step 2 — Verify

```bash
node --version
npm --version
```

### Step 3 — Install JSON Server

```bash
npm install -g json-server
```

---

# 3. Creating Your First API

## Step 1 — Create JSON File

Example: `students.json`

```json
{
  "students": [
    {
      "id": 1,
      "name": "John",
      "location": "India"
    },
    {
      "id": 2,
      "name": "Anna",
      "location": "USA"
    }
  ]
}
```

---

## Step 2 — Run API

```bash
json-server --watch students.json
```

### Output:

* API runs on:

```http
http://localhost:3000
```

---

## Step 3 — Available Endpoints

| Action  | URL                  |
| ------- | -------------------- |
| Get all | `/students`          |
| Get one | `/students/1`        |
| Create  | POST `/students`     |
| Update  | PUT `/students/1`    |
| Delete  | DELETE `/students/1` |

---

## IMPORTANT

* API runs only while terminal is open
* Close terminal → API stops

---

# 4. Testing in Postman (Real DevOps Workflow)

## GET Single

```http
GET /students/1
```

→ Returns one record

---

## GET All

```http
GET /students
```

→ Returns list

---

## POST (Create)

Body:

```json
{
  "name": "Aisalkyn",
  "location": "USA"
}
```

→ Status: `201 Created`

---

## PUT (Update)

```http
PUT /students/4
```

→ Replace data

---

## DELETE

```http
DELETE /students/4
```

→ Status:

* 200 OK
* or 204 No Content

---

# 5. What DevOps Must Validate (CRITICAL)

When you send request → validate:

### 1. Status Code

* 200 → OK
* 201 → Created
* 404 → Not Found

### 2. Response Time

* Performance check

### 3. Response Size

* Data correctness

### 4. Headers

* Content-Type
* Auth

### 5. Body (MOST IMPORTANT)

* Data correctness

### 6. Cookies (if applicable)

---

# 6. What is JSON

## Definition

**JSON = JavaScript Object Notation**

Used for:

* Data exchange
* API communication 

---

## Why JSON (DevOps reason)

* Lightweight
* Fast
* Human-readable
* Works with REST APIs

---

# 7. JSON Data Types (VERY IMPORTANT)

## 1. String

```json
"name": "John"
```

## 2. Number

```json
"age": 30
```

## 3. Boolean

```json
"isActive": true
```

## 4. Null

```json
"value": null
```

---

# 8. JSON Structures

## 1. Object

```json
{
  "name": "John",
  "city": "NY"
}
```

→ Key-value pairs

---

## 2. Array

```json
"skills": ["Java", "Python"]
```

→ Multiple values

---

## 3. Nested Object

```json
"address": {
  "city": "NY",
  "zip": "10001"
}
```

---

## 4. Array of Objects

```json
"books": [
  { "title": "Java" },
  { "title": "Python" }
]
```

---

# 9. JSON Path (VERY IMPORTANT FOR DEVOPS)

## Why Needed?

Because:

* You must extract data
* Then validate it

---

## Example JSON

```json
{
  "store": {
    "book": [
      { "title": "Java" },
      { "title": "Python" }
    ]
  }
}
```

---

## JSON Path Basics

### Root

```plaintext
$
```

---

### Access Field

```plaintext
$.store
```

---

### Access Array

```plaintext
$.store.book[0]
```

---

### Access Value

```plaintext
$.store.book[1].title
```

→ Output: `"Python"`

---

## Important Symbols

| Symbol | Meaning      |
| ------ | ------------ |
| `$`    | Root         |
| `.`    | Child        |
| `[]`   | Array index  |
| `*`    | All elements |

---

# 10. Real DevOps Example

You get response:

```json
{
  "name": "John",
  "location": "India"
}
```

You validate:

```javascript
pm.test("Check location", function () {
    pm.expect(pm.response.json().location).to.eql("India");
});
```

---

# 11. Key Interview Questions

Be ready:

* What is JSON?
* Difference JSON vs XML?
* What is JSON Path?
* How to extract array value?
* What is PUT vs PATCH?
* What validations do you perform on API?

---

# 12. DevOps Real-World Mapping

You will use this in:

* CI/CD pipelines
* API Gateway testing
* Lambda debugging
* Microservices validation
* Kafka / Event-driven systems
* Terraform outputs validation

---

# 13. Most Important Takeaways

* You can create your own API (no backend needed)
* JSON = core of API communication
* JSON Path = required for validation
* Postman = testing tool
* Validation = DevOps responsibility

















> After receiving API response → we must validate everything
> using **Postman + JavaScript + Chai assertions** 

---

# 2. Types of API Response Validations (DevOps Standard)

You MUST know these **6 categories (interview critical)**:

### 1. Status Code

### 2. Headers

### 3. Cookies

### 4. Response Time

### 5. Response Body

### 6. Schema Validation

This is exactly what senior DevOps / QA engineers do.

---

# 3. Where Do We Write Validations in Postman?

In Postman:

* **Pre-request script** → runs BEFORE request
* **Post-response script** → runs AFTER response (VALIDATIONS HERE)

So:

> All validations = inside **Post-response script** 

---

# 4. Core Syntax (VERY IMPORTANT)

Everything starts with:

```javascript
pm.test("Test Name", () => {
   // validation
});
```

Inside → we use:

```javascript
pm.expect(...)
```

This comes from **Chai assertion library**

---

# 5. Status Code Validation

## Exact match

```javascript
pm.test("Status is 200", () => {
    pm.response.to.have.status(200);
});
```

---

## Multiple possible status codes

```javascript
pm.test("Status is valid", () => {
    pm.expect(pm.response.code).to.be.oneOf([200, 201, 202]);
});
```

---

## Status text

```javascript
pm.test("Status text is OK", () => {
    pm.response.to.have.status("OK");
});
```

---

# 6. Header Validation

## Check header exists

```javascript
pm.test("Content-Type exists", () => {
    pm.response.to.have.header("Content-Type");
});
```

---

## Validate header value

```javascript
pm.test("Content-Type is JSON", () => {
    pm.expect(pm.response.headers.get("Content-Type"))
        .to.eql("application/json");
});
```

---

## Partial match (IMPORTANT)

```javascript
pm.test("Content-Type contains JSON", () => {
    pm.expect(pm.response.headers.get("Content-Type"))
        .to.include("json");
});
```

---

# 7. Cookies Validation

## Cookie exists

```javascript
pm.test("Language cookie exists", () => {
    pm.expect(pm.cookies.has("language")).to.be.true;
});
```

---

## Cookie value

```javascript
pm.test("Language cookie value", () => {
    pm.expect(pm.cookies.get("language")).to.eql("en-GB");
});
```

---

# 8. Response Time Validation

```javascript
pm.test("Response time < 200ms", () => {
    pm.expect(pm.response.responseTime).to.be.below(200);
});
```

IMPORTANT:

* You NEVER check exact time
* Always check **threshold**

---

# 9. Response Body Validation

## Step 1 — Capture response

```javascript
const jsonData = pm.response.json();
```

---

## Step 2 — Validate structure

```javascript
pm.test("Response is object", () => {
    pm.expect(jsonData).to.be.an("object");
});
```

---

## Step 3 — Validate data types

```javascript
pm.test("Data types", () => {
    pm.expect(jsonData.name).to.be.a("string");
    pm.expect(jsonData.id).to.be.a("number");
    pm.expect(jsonData.courses).to.be.an("array");
});
```

---

## Step 4 — Validate values

```javascript
pm.test("Data validation", () => {
    pm.expect(jsonData.name).to.eql("John");
    pm.expect(jsonData.location).to.eql("India");
});
```

---

# 10. Array Validation (VERY IMPORTANT)

## Check value exists

```javascript
pm.test("Course contains Java", () => {
    pm.expect(jsonData.courses).to.include("Java");
});
```

---

## Check multiple values

```javascript
pm.test("Courses match", () => {
    pm.expect(jsonData.courses).to.have.members(["Java", "Selenium"]);
});
```

---

# 11. Schema Validation (INTERVIEW FAVORITE)

## What is Schema?

Schema = **structure of data**

Example:

| Field   | Type   |
| ------- | ------ |
| id      | number |
| name    | string |
| courses | array  |

---

## Why Important?

Instead of validating each field →
you validate **entire structure at once**

---

## How it works

1. Generate schema (tool)
2. Compare response with schema

---

## Example (TV4 library)

```javascript
pm.test("Schema validation", () => {
    pm.expect(tv4.validate(jsonData, schema)).to.be.true;
});
```

---

# 12. Real DevOps Flow

When API response comes → you validate:

```plaintext
1. Status → OK?
2. Headers → correct?
3. Time → fast enough?
4. Body → correct data?
5. Schema → structure valid?
```

---

# 13. Interview Answer (IMPORTANT)

If they ask:

### “What do you validate in API response?”

Answer:

> I validate status codes, headers, cookies, response time, response body data, and schema. I also verify data types, values, and structure using JSON path and Postman scripts.

---

# 14. Most Important Takeaways

* Postman uses **JavaScript + Chai**
* All validations = **pm.test()**
* Always validate:

  * Status
  * Headers
  * Time
  * Body
  * Schema
* Use:

  * `pm.response`
  * `pm.expect()`
  * `pm.response.json()`


















* Variables = placeholders to store reusable data
* Scripts = automation logic using JavaScript
* Two script types:

  * **Pre-request script → before API call**
  * **Post-response script → after API response** 

---

# 🧠 2. What is a Variable (DevOps Definition)

A variable is:

> A container that stores data and can be reused across requests to avoid duplication and hardcoding 

---

# 🚀 3. Why Variables Are CRITICAL in DevOps

You use variables for:

* Base URLs (dev / QA / prod)
* API keys / tokens
* Dynamic IDs (userId, orderId)
* Reusable test data

### Example:

Instead of this:

```plaintext
https://api.dev.company.com/users
```

You use:

```plaintext
{{base_url}}/users
```

---

# 🧱 4. 5 Types of Variables (VERY IMPORTANT)

## 1. Global Variable

* Scope: entire workspace
* Use case: shared across all collections

---

## 2. Environment Variable

* Scope: depends on selected environment (QA / DEV / PROD)
* Must **switch environment to use it**

---

## 3. Collection Variable

* Scope: inside one collection only

---

## 4. Local Variable

* Scope: single request
* Created using script only

---

## 5. Data Variable

* From CSV / JSON (data-driven testing)

---

# 📊 5. Variable Hierarchy (INTERVIEW GOLD)

From lowest → highest:

```plaintext
Local < Collection < Environment < Global
```

Meaning:

* Local overrides everything
* Global is accessible everywhere

---

# ⚙️ 6. How to Use Variables

Syntax (same for all types):

```javascript
{{variable_name}}
```

---

# 💻 7. Creating Variables Using JavaScript (REAL DEVOPS WAY)

## 🔹 Global Variable

```javascript
pm.globals.set("user_id_global", "2");
```

---

## 🔹 Environment Variable

```javascript
pm.environment.set("user_id_env", "2");
```

⚠️ Works only if environment is selected

---

## 🔹 Collection Variable

```javascript
pm.collectionVariables.set("user_id_collection", "2");
```

---

## 🔹 Local Variable

```javascript
pm.variables.set("user_id_local", "2");
```

---

# 🔁 8. Accessing Variables in Request

Example:

```plaintext
https://api.com/users/{{user_id_global}}
```

---

# 🧩 9. Where Variables Are Created (IMPORTANT)

👉 Always in:

## Pre-request Script

Why?

> Because variables must exist BEFORE request is sent 

---

# 🔥 10. Scripts in Postman

## Two types:

### 1. Pre-request Script

* Runs BEFORE request
* Used for:

  * Creating variables
  * Generating tokens
  * Dynamic data

---

### 2. Post-response Script

* Runs AFTER response
* Used for:

  * Validations
  * Assertions
  * Cleanup (delete variables)

---

# 🧠 11. Execution Order (VERY IMPORTANT)

If scripts exist at:

* Collection
* Folder
* Request

### Execution order:

## BEFORE request:

```plaintext
Collection → Folder → Request
```

## AFTER response:

```plaintext
Collection → Folder → Request
```

---

# 🧹 12. Getting & Deleting Variables

## Get value

```javascript
pm.globals.get("user_id_global");
```

---

## Delete variable

```javascript
pm.globals.unset("user_id_global");
```

---

# 📦 13. Using Variables in Request Body

## Example (POST API)

### Pre-request:

```javascript
pm.variables.set("name", "Aisalkyn");
pm.variables.set("job", "DevOps Engineer");
```

---

### Body:

```json
{
  "name": "{{name}}",
  "job": "{{job}}"
}
```

---

# ✅ 14. Validations (Post-response)

```javascript
pm.test("Status code is 201", () => {
    pm.response.to.have.status(201);
});
```

---

## Validate Response Body

```javascript
const jsonData = pm.response.json();

pm.test("Validate data", () => {
    pm.expect(jsonData.name).to.eql("Aisalkyn");
    pm.expect(jsonData.job).to.eql("DevOps Engineer");
});
```

---

# 🔥 15. Real DevOps Scenario

Example flow:

1. Login API → get token
2. Save token in variable
3. Use token in next API

```javascript
// Post-response (login)
const res = pm.response.json();
pm.environment.set("token", res.token);
```

---

# 🎯 16. Interview Questions (You MUST Know)

### Q1: Where do you create variables?

👉 Pre-request script

---

### Q2: Where do you validate responses?

👉 Post-response script

---

### Q3: Difference between global and environment variable?

👉 Environment requires switching, global does not

---

### Q4: Why use variables?

👉 Avoid hardcoding + reuse + dynamic data

---

### Q5: What is execution order of scripts?

👉 Collection → Folder → Request

---

# 🧠 17. Most Important Takeaways

* Variables = reusable dynamic data
* Scripts = automation logic
* Pre-request = create data
* Post-response = validate + clean
* Use JavaScript (not UI in real projects)
* Always use `{{variable}}` syntax











# 🔥 1. What is API Chaining

### Definition:

> API chaining is executing multiple API requests in sequence where the output of one request becomes the input of another 

---

# 🧠 2. Simple Real Flow (VERY IMPORTANT)

```text
POST → GET → PUT → DELETE
```

### Step-by-step:

1. **POST** → Create resource → returns `id`
2. **GET** → Use `id` → fetch resource
3. **PUT** → Use same `id` → update resource
4. **DELETE** → Use same `id` → remove resource

---

# 📊 3. Why API Chaining is Critical for DevOps

You will use this in:

* Microservices communication
* CI/CD API validation
* AWS Lambda workflows
* Kafka event pipelines
* Integration testing

---

# ⚙️ 4. Real Example (From Your Lecture)

### Step 1 — Create User (POST)

Request:

```json
{
  "name": "{{user_name}}",
  "email": "{{user_email}}",
  "gender": "male",
  "status": "active"
}
```

---

## Pre-request Script (Create dynamic data)

```javascript
pm.collectionVariables.set("user_name", "abcxyz");

const text = Math.random().toString(36).substring(2);
const email = text + "@gmail.com";

pm.collectionVariables.set("user_email", email);
```

---

## Post-response Script (Capture ID)

```javascript
const jsonData = pm.response.json();

pm.collectionVariables.set("user_id", jsonData.id);
```

---

# 🔑 5. Authentication (VERY IMPORTANT)

You used **Bearer Token**

### Where to add:

👉 Collection level (best practice)

```plaintext
Authorization → Bearer Token → paste token
```

✔ Applies to all requests automatically

---

# 🔗 6. Step 2 — Get User (Using ID)

### URL:

```text
/users/{{user_id}}
```

---

## Post-response Validation

```javascript
const jsonData = pm.response.json();

pm.test("Validate user data", () => {
    pm.expect(jsonData.id)
        .to.eql(pm.collectionVariables.get("user_id"));

    pm.expect(jsonData.name)
        .to.eql(pm.collectionVariables.get("user_name"));

    pm.expect(jsonData.email)
        .to.eql(pm.collectionVariables.get("user_email"));
});
```

---

# 🔄 7. Step 3 — Update User (PUT)

### Body:

```json
{
  "name": "{{user_name}}",
  "email": "{{user_email}}",
  "status": "active"
}
```

---

## Pre-request (Generate NEW data)

```javascript
const text = Math.random().toString(36).substring(2);

pm.collectionVariables.set("user_name", "updated_" + text);
pm.collectionVariables.set("user_email", text + "@gmail.com");
```

---

## Validation (same as GET)

---

# 🗑️ 8. Step 4 — Delete User

### URL:

```text
/users/{{user_id}}
```

---

## Post-response (Cleanup variables)

```javascript
pm.collectionVariables.unset("user_name");
pm.collectionVariables.unset("user_email");
pm.collectionVariables.unset("user_id");
```

---

# 🔁 9. Full Flow (IMPORTANT)

```text
1. Create user → get ID
2. Store ID in variable
3. Use ID in next requests
4. Validate data
5. Update same resource
6. Delete resource
7. Clean variables
```

---

# 🧠 10. Key DevOps Concepts Behind This

### 1. Dynamic Data Handling

* No hardcoding
* Always generate runtime data

---

### 2. State Management

* Variables store state between APIs

---

### 3. Dependency Handling

* Request depends on previous response

---

### 4. Automation Ready

* Can run in CI/CD pipelines

---

# ⚠️ 11. Common Mistakes (Interview Trap)

❌ Using local variables (won’t work across requests)
✔ Use collection/environment variables

❌ Hardcoding IDs
✔ Always extract from response

❌ Not handling auth globally
✔ Add token at collection level

---

# 🎯 12. Interview Questions (MUST KNOW)

### Q1: What is API chaining?

👉 Using response of one API as input for another

---

### Q2: Where do you store ID?

👉 In collection/environment variable

---

### Q3: Why not local variable?

👉 Scope is limited to one request

---

### Q4: Where do you capture response?

👉 Post-response script

---

### Q5: Where do you generate dynamic data?

👉 Pre-request script

---

# 🧠 13. Real DevOps Scenario

### Example:

```text
Login API → get JWT token
↓
Store token
↓
Call protected APIs using token
↓
Validate responses
```

---

# 🔥 14. Most Important Takeaways

* API chaining = sequence + dependency
* Always use variables
* Capture response → store → reuse
* Pre-request = prepare data
* Post-response = validate + store
* Collection variables = best for chaining
















# 🧠 2. Execution Order in Postman

## Default Behavior

```text
Requests run in the order they are created
```

---

## Problem

Sometimes you need custom flow:

```text
Create Token → Submit Order → Get Order → Update → Delete
```

NOT the default order.

---

# ⚙️ 3. How to Control Execution Order

## Method:

```javascript
pm.execution.setNextRequest("Request Name");
```

---

## Example Flow

### Create Token → next = Submit Order

```javascript
pm.execution.setNextRequest("Submit Order");
```

---

### Submit Order → next = Get Single Order

```javascript
pm.execution.setNextRequest("Get Single Order");
```

---

### Last Request → STOP

```javascript
pm.execution.setNextRequest(null);
```

---

## 🔥 IMPORTANT

If you DON’T use `null`:

* Postman may execute next request automatically
* Especially if more requests exist

---

# 🧠 4. Why DevOps Engineers Use This

* Control workflows
* Build pipelines
* Simulate real system behavior

Example:

```text
Auth → Create Resource → Validate → Cleanup
```

---

# 📊 5. Data-Driven Testing (VERY IMPORTANT)

## Problem

You don’t want:

```text
Run same API 5 times manually ❌
```

---

## Solution

```text
Run 1 request with multiple data sets ✅
```

---

# 📁 6. Supported Data Files

* CSV
* JSON

---

# 📄 7. Example CSV

```csv
bookId,customerName
1,John
2,Alice
3,Bob
4,Emma
5,David
```

---

# 🧠 8. Key Rule (VERY IMPORTANT)

Column names MUST match variables:

```json
{
  "bookId": "{{bookId}}",
  "customerName": "{{customerName}}"
}
```

---

# ⚙️ 9. How It Works (NO CODE REQUIRED)

You DO NOT write JavaScript to read file.

Postman does it automatically.

---

# 🚀 10. Running Data-Driven Collection

## Steps:

1. Click **Run Collection**
2. Set:

### Iterations

```text
= number of rows in file
```

### Delay

```text
1–2 seconds (recommended)
```

### Select File

* Upload CSV / JSON

---

# 📊 11. Example Execution

If:

* 5 rows
* 3 requests

Then:

```text
Total executions = 5 × 3 = 15 requests
```

---

# 📈 12. Validation Count Logic

Example:

* Submit Order → 1 test
* Get Order → 2 tests
* Delete Order → 1 test

Total per iteration:

```text
1 + 2 + 1 = 4 tests
```

For 5 iterations:

```text
4 × 5 = 20 tests
```

---

# 🧠 13. DevOps-Level Understanding

### What is happening internally:

```text
Loop:
  Take row 1 → run all requests
  Take row 2 → run all requests
  ...
```

---

# 🔄 14. Full Flow Example

```text
Iteration 1:
  Submit Order → Get Order → Delete

Iteration 2:
  Submit Order → Get Order → Delete

...
```

---

# ⚠️ 15. Common Mistakes

❌ Column name mismatch
✔ Must match exactly

---

❌ No delay → API failures
✔ Add delay

---

❌ Hardcoded data
✔ Use external files

---

❌ Forgetting token
✔ Add auth properly

---

# 🔐 16. Token Handling (Best Practice)

Instead of hardcoding:

```text
Bearer {{access_token}}
```

---

✔ Store once → reuse everywhere

---

# 🧠 17. Real DevOps Use Cases

This is used in:

### 1. CI/CD Pipelines

* Run API tests with datasets

### 2. Load Simulation

* Multiple users/orders

### 3. Integration Testing

* Microservices validation

### 4. E-commerce Systems

* Orders → payments → delivery

---

# 🎯 18. Interview Questions (VERY IMPORTANT)

### Q1: What is data-driven testing?

👉 Running same API with multiple datasets

---

### Q2: How does Postman read CSV?

👉 Automatically during collection run

---

### Q3: Do you need scripting?

👉 No (only variable mapping)

---

### Q4: What is iteration?

👉 Number of times collection runs

---

### Q5: Why delay is important?

👉 Prevent API throttling / failures

---

### Q6: How to control execution order?

👉 `pm.execution.setNextRequest()`

---

# 🔥 19. Most Important Takeaways

* Execution order can be customized
* Data-driven testing = real-world automation
* No scripting needed for CSV/JSON
* Variables must match column names
* Iterations control execution count
* Delay prevents failures













# 🔥 1. File Upload APIs (VERY IMPORTANT)

## 🧠 What Happens Internally

When you upload a file from UI:

```text
UI → API → Server → Storage (disk/cloud)
```

👉 API is doing the real work 

---

# 📤 2. Single File Upload (Postman)

## Request

```text
POST /uploadFile
```

---

## Body (IMPORTANT)

👉 NOT JSON
👉 Use **form-data**

```text
Key: file
Type: File
Value: choose file
```

---

## Response Example

```json
{
  "fileName": "test.txt",
  "fileDownloadUri": "...",
  "fileType": "text/plain",
  "size": 770
}
```

---

## 🔥 Key DevOps Point

* File upload = multipart/form-data
* Not JSON
* Works for:

  * txt
  * csv
  * pdf
  * excel

---

# 📥 3. File Download

## Request

```text
GET /download/{filename}
```

---

## Response

* Returns file content
* Or triggers download (browser)

---

# 📤📤 4. Multiple File Upload

## Request

```text
POST /uploadMultipleFiles
```

---

## Body

```text
Key: files
Type: File
Select multiple files
```

---

## Response

```json
[
  { "fileName": "file1.txt" },
  { "fileName": "file2.txt" }
]
```

---

# ⚠️ Common Mistakes

❌ Using JSON body
✔ Use form-data

❌ Wrong key name
✔ Must match API (file / files)

---

# 🔐 5. Authentication vs Authorization

## Difference

| Concept        | Meaning             |
| -------------- | ------------------- |
| Authentication | Who are you         |
| Authorization  | What you can access |

---

# 🔥 6. Types of Authentication (MUST KNOW)

From your lecture, these are the main ones:

---

# 1️⃣ Basic Authentication

## How it works

```text
Client → username/password → Server → Response
```

---

## In Postman

```text
Authorization → Basic Auth
```

---

## Key Points

* Encoded (not secure)
* Used in simple systems

---

# 2️⃣ Digest Authentication

## Difference from Basic

* Uses encryption
* More secure

---

## Flow

```text
Client → encrypted credentials → Server
```

---

## DevOps Tip

👉 Rarely used in modern systems

---

# 3️⃣ API Key Authentication

## Example: Weather API

## Request

```text
GET /weather?q=Chicago&appid=API_KEY
```

---

## In Postman

```text
Authorization → API Key
Key: appid
Value: <your_key>
Add to: Query Params
```

---

## Flow

```text
Client → API Key → Server → Response
```

---

## 🔥 Real Use Cases

* Weather APIs
* Payment APIs
* SaaS platforms

---

# 4️⃣ Bearer Token (VERY IMPORTANT)

## Flow

```text
Login → Get Token → Use Token in requests
```

---

## Example

```text
Authorization: Bearer <token>
```

---

## Where used

* GitHub API
* AWS APIs
* Microservices

---

## DevOps Reality

👉 MOST COMMON in production

---

# 5️⃣ OAuth 2.0 (VERY IMPORTANT)

## 🔥 Key Concept

Requires 3 things:

```text
1. Client ID
2. Client Secret
3. Access Token
```

---

## Flow

```text
1. Login to app
2. Register app
3. Get client_id + client_secret
4. Generate token
5. Use token to call API
```

---

## In Postman

```text
Authorization → OAuth 2.0 → Get New Access Token
```

---

## 🔥 Real Systems Using OAuth2

* Google APIs
* Facebook
* LinkedIn
* PayPal

---

# 📊 7. Comparison (INTERVIEW GOLD)

| Type         | Security  | Usage         |
| ------------ | --------- | ------------- |
| Basic        | Low       | Legacy        |
| Digest       | Medium    | Rare          |
| API Key      | Medium    | Public APIs   |
| Bearer Token | High      | Microservices |
| OAuth 2.0    | Very High | Enterprise    |

---

# 🧠 8. DevOps Real-World Mapping

## You will use:

### CI/CD Pipelines

* API key / token for deployments

---

### Microservices

* Bearer tokens between services

---

### Cloud APIs

* AWS / Azure → token-based auth

---

### External Integrations

* OAuth2 (Google, Slack, etc.)

---

# 🔥 9. Internal Flow Summary

### Basic

```text
Request → Username/Password → Response
```

---

### Token

```text
Login → Token → Request → Response
```

---

### OAuth2

```text
Login → Client ID/Secret → Token → API Call
```

---

# ⚠️ 10. Interview Questions

### Q1: Difference Basic vs Bearer?

👉 Basic uses credentials
👉 Bearer uses token

---

### Q2: Why OAuth2?

👉 More secure, delegated access

---

### Q3: Where is API key sent?

👉 Query params or headers

---

### Q4: What is Bearer token?

👉 Access token used in Authorization header

---

### Q5: File upload API content type?

👉 multipart/form-data

---

# 🚀 11. Most Important Takeaways

* File upload = form-data
* Authentication is critical in APIs
* Bearer + OAuth2 = most important
* API keys = common for external services
* OAuth2 = enterprise-level security













# 🚀 FULL API PROJECT FLOW (REAL DEVOPS PROCESS)

This is NOT just Postman — this is how real companies work.

---

# 🧭 1. Where Do You Start?

👉 NOT Postman
👉 NOT automation

### ✅ You start from:

```text
Technical Design Document
```

Because:

* You need to understand APIs first
* You cannot test what you don’t understand

---

# 📄 2. Technical Document (VERY IMPORTANT)

From your file:

👉 It defines:

* Endpoints
* Request types
* Data models
* Functional requirements 

---

## 🧠 Key Concept: Endpoint

```text
Base URL + Endpoint = Full API URL
```

### Example:

```text
https://api.store.com   → Base URL
/products               → Endpoint
```

👉 Endpoint = resource (data you want)

---

# 🧱 3. Modules in Project

From your doc:

### 1. Product Module

* Get products
* Add product
* Update product
* Delete product

---

### 2. Cart Module

* Add to cart
* Get cart
* Filter cart

---

### 3. User Module

* Login
* Get user
* Create user

---

# 🔥 4. CRUD Mapping (INTERVIEW MUST)

| Operation | API Method  |
| --------- | ----------- |
| Create    | POST        |
| Read      | GET         |
| Update    | PUT / PATCH |
| Delete    | DELETE      |

---

# 📊 5. Data Model (VERY IMPORTANT)

Example:

```json
{
  "id": 1,
  "title": "Product",
  "price": 100
}
```

👉 Used for:

* Validation
* Schema testing

---

# 🧪 6. Test Case Design (CRITICAL SKILL)

From your doc, structure:

---

## Template

| Field        | Meaning       |
| ------------ | ------------- |
| Test ID      | Unique        |
| Description  | What to test  |
| Method       | GET/POST      |
| Endpoint     | API path      |
| Auth         | Token/API key |
| Query Params | limit, sort   |
| Headers      | JSON, auth    |
| Body         | POST data     |
| Expected     | Response      |
| Status Code  | 200/201       |
| Validation   | Assertions    |

---

# 🔥 Example

### Get All Products

```text
Method: GET
Endpoint: /products
Expected: Array of products
Status: 200
```

---

### Add Product

```json
POST /products
{
  "title": "...",
  "price": 100
}
```

---

# ⚠️ IMPORTANT RULE (DEVOPS GOLD)

```text
❌ NEVER hardcode values
✔ ALWAYS use variables
```

---

# 🧠 7. Variables Strategy

## Types

### 1. Global Variables

Used everywhere:

```text
base_url
username
password
```

---

### 2. Collection Variables

Used per module:

```text
product_id
title
price
```

---

# 📁 8. External Data (VERY IMPORTANT)

From your file:

👉 Data comes from:

* JSON → single dataset
* CSV → multiple datasets (data-driven) 

---

## Example JSON

```json
{
  "id": 1,
  "title": "Phone",
  "price": 500
}
```

---

## Example CSV

```text
id,title,price
1,Phone,500
2,Laptop,1000
```

---

# 🔁 9. Data-Driven Testing

## JSON → 1 iteration

## CSV → multiple iterations

👉 Example:

```text
12 requests × 2 rows = 24 executions
```

---

# 🧪 10. Postman Collection Flow

## Step-by-step

```text
1. Create Workspace
2. Create Collection
3. Add Requests
4. Add Variables
5. Add Scripts (validation)
6. Run Collection
```

---

# 🔥 11. Validations (MOST IMPORTANT)

From your doc:

---

## Must-have validations

### 1. Status Code

```javascript
pm.response.to.have.status(200);
```

---

### 2. Response Not Empty

```javascript
pm.expect(jsonData).to.not.be.empty;
```

---

### 3. Schema Validation

```javascript
pm.expect(jsonData).to.be.jsonSchema(schema);
```

---

### 4. Business Logic Validation

Example:

```javascript
pm.expect(jsonData.id).to.eql(expectedId);
```

---

### 5. Array Length

```javascript
pm.expect(jsonData.length).to.eql(20);
```

---

# 🔥 12. Advanced Validation (VERY IMPORTANT)

From your lecture:

👉 Loop through response:

```javascript
jsonData.forEach(item => {
    pm.expect(item).to.have.property("id");
});
```

---

# 🚀 13. Running Collection

## Manual Run

```text
Run Collection → Select Data File → Run
```

---

## Results

* Total tests
* Passed
* Failed
* Execution time

---

# 📊 14. Output Example

```text
Iterations: 2
Total tests: 100
Passed: 100
Failed: 0
```

---

# ⚠️ 15. Important Behavior

### If one request fails:

* Independent → others continue
* Dependent → chain fails

---

# 🔗 16. Dependency Example

```text
POST product → PUT product → DELETE product
```

👉 If POST fails → others fail

---

# 📦 17. Export & Sharing

You can export:

* Collection
* Results (JSON)

---

# 🔥 18. Real DevOps Integration

From your doc:

* GitHub → store collections
* Jenkins → run tests
* Newman → CLI execution 

---

# 🧠 19. Important Concepts You Learned

### You now understand:

* API design
* Test case writing
* Postman collections
* Variables
* Data-driven testing
* Validation scripting















# 🔥 1. WHAT IS NEWMAN?

👉 From your file:

* Newman = CLI tool for running Postman collections
* Built on Node.js
* Used for automation + CI/CD 

---

## 💡 Simple Definition (Interview)

```text
Newman is a command-line tool used to run Postman collections outside Postman,
mainly for automation and CI/CD pipelines.
```

---

# 🧱 2. WHY DEVOPS NEEDS NEWMAN

Because:

| Without Newman | With Newman         |
| -------------- | ------------------- |
| Manual testing | Automated testing   |
| UI only        | CLI + pipeline      |
| No reports     | HTML reports        |
| No CI/CD       | Jenkins integration |

---

# ⚙️ 3. PREREQUISITES (VERY IMPORTANT)

From your lecture:

### You MUST install:

1. Node.js
2. Newman
3. Newman HTML Reporter 

---

## Commands:

```bash
npm install -g newman
npm install -g newman-reporter-html-extra
```

---

# 📦 4. BEFORE RUNNING — EXPORT FROM POSTMAN

You CANNOT run directly.

You must export:

### Required files:

```text
1. Collection → products.json
2. Data file → JSON / CSV
3. Global variables → global.json
4. (Optional) Environment variables
```

---

# 🧠 KEY RULE

```text
Collection variables → automatic
Global & Environment → must export manually
```

---

# 🚀 5. CORE NEWMAN COMMAND

## Basic:

```bash
newman run collection.json
```

---

## With Data + Variables:

```bash
newman run collection.json \
-d data.json \
-g globals.json
```

---

## With Report (VERY IMPORTANT):

```bash
newman run collection.json \
-d data.json \
-g globals.json \
-r html-extra
```

---

# 📊 6. OUTPUT TYPES

### 1. CLI Output

```text
✔ Requests passed
✔ Assertions passed
✔ Execution time
```

👉 Visible in terminal

---

### 2. HTML Report (IMPORTANT)

👉 Generated file:

```text
/newman/report.html
```

👉 Contains:

* Full request details
* Response body
* Assertions
* Errors

---

# 🔥 7. ADVANCED REPORT CUSTOMIZATION

From your file:

```bash
--reporter-html-extra-export ./result/report.html
--reporter-html-extra-title "API Report"
--reporter-html-extra-browserTitle "Store API"
```

👉 You can control:

* Folder
* File name
* UI title

---

# 🔁 8. DATA-DRIVEN EXECUTION

### JSON → 1 iteration

### CSV → multiple iterations

Example:

```text
CSV with 10 rows → 10 executions
```

---

# ⚠️ IMPORTANT DEVOPS INSIGHT

```text
Postman = Development
Newman = Automation
```

---

# 🔗 9. DEVOPS FLOW (REAL WORLD)

From your lecture:

```text
Postman → Export → Newman → GitHub → Jenkins → Reports
```

---

# 📦 FULL PIPELINE

### Step-by-step:

```text
1. Create collection in Postman
2. Export JSON files
3. Store in GitHub
4. Jenkins pulls repo
5. Jenkins runs Newman
6. Generate report
```

---

# 🧰 10. GIT FLOW (VERY IMPORTANT)

From your file:

```bash
git init
git remote add origin <repo>
git add .
git commit -m "message"
git push origin master
```

👉 DevOps must know this.

---

# 🔥 11. JENKINS EXECUTION

## In Jenkins:

### Build Step:

```bash
newman run collection.json -d data.json -g globals.json -r html-extra
```

---

## Plugins REQUIRED:

* NodeJS plugin
* HTML Publisher plugin 

---

# 📊 12. REPORT IN JENKINS

👉 After build:

```text
Post-build → Publish HTML report
```

👉 You will see:

* Report link in Jenkins UI
* Same HTML dashboard

---

# 🧠 13. TWO REAL DEVOPS SCENARIOS

---

## 🔹 Scenario 1 (LOCAL READY)

You already have:

* Node.js
* Newman

👉 Jenkins just runs command

---

## 🔹 Scenario 2 (PRODUCTION)

You DON'T have anything

👉 Jenkins installs:

* Node.js
* Newman
* Reporter

👉 Runs pipeline

---

# 🔥 14. MOST IMPORTANT DEVOPS INTERVIEW POINT

```text
How do you automate API testing in CI/CD?

Answer:
- Create Postman collection
- Export JSON
- Use Newman CLI
- Integrate with Jenkins
- Generate HTML reports
```

---

# 🚀 FINAL SUMMARY (VERY IMPORTANT)

### You now know:

* API testing automation
* Newman CLI usage
* Data-driven testing
* Report generation
* Git + GitHub integration
* Jenkins pipeline execution


















# 🔥 1. CORE DIFFERENCE (MOST IMPORTANT)

## 🧠 Newman vs Postman CLI

### 🔹 Newman (OLD WAY)

```text
Postman → Export JSON → Run via CLI → GitHub → Jenkins
```

✔ Needs export
✔ Uses JSON file
✔ Needs GitHub

---

### 🔹 Postman CLI (NEW WAY)

```text
Postman → Share → Get URL/ID → Run directly → Jenkins
```

✔ NO export
✔ Uses cloud
✔ NO GitHub needed

👉 THIS is the biggest difference.

---

# ⚡ 2. EXPORT vs SHARE (CRITICAL CONCEPT)

## Export (Newman)

```text
Collection → JSON file → physical file
```

👉 You run file locally or via Jenkins

---

## Share (Postman CLI)

```text
Collection → Cloud → URL + Collection ID
```

👉 You run directly from cloud

---

## 🔥 Interview Answer

```text
Newman uses exported JSON files,
Postman CLI uses shared collections from Postman cloud.
```

---

# 🔐 3. REQUIRED FOR POSTMAN CLI

From your lecture:

👉 You MUST have:

1. Postman CLI installed
2. API Key
3. Collection ID



---

## 🧠 VERY IMPORTANT

### API Key ≠ API authentication

```text
This is NOT for API request,
This is for Postman login via CLI
```

---

# 🔑 4. HOW EXECUTION WORKS

## Step 1 — Login

```bash
postman login --api-key YOUR_KEY
```

---

## Step 2 — Run Collection

```bash
postman collection run COLLECTION_ID
```

---

## Step 3 — With Data + Variables

```bash
postman collection run COLLECTION_ID \
-d data.json \
-g globals.json
```

---

# ⚠️ CRITICAL LIMITATION

👉 Even though collection is in cloud:

```text
Data files (CSV/JSON) → MUST be local
Variables → MUST be local
```

---

# 🔥 5. WHAT YOU ACHIEVE

From your file:

✔ Run collection from CLI
✔ Run in Jenkins
✔ Generate reports
✔ No GitHub required



---

# 🚀 6. REPORTING (DIFFERENCE)

## Newman

✔ HTML EXTRA (beautiful report)

---

## Postman CLI

✔ Only basic HTML / JSON / XML
❌ No HTML-extra

---

# 🔥 7. HUGE ADVANTAGE OF POSTMAN CLI

👉 THIS IS VERY IMPORTANT

```text
Postman CLI automatically uploads results to Postman cloud
```

✔ You see results inside Postman UI
✔ No external reporting needed



---

# 🔄 8. DEVOPS PIPELINE FLOW

## With Postman CLI

```text
Postman Cloud
     ↓
CLI Login (API Key)
     ↓
Run Collection (ID)
     ↓
Jenkins Pipeline
     ↓
Results auto-uploaded
```

---

# 🧱 9. JENKINS PIPELINE (IMPORTANT)

From your file:

### 3 stages:

```text
1. Install CLI
2. Login to Postman
3. Run collection
```



---

## Example Flow

```groovy
stage('Login') {
    postman login --api-key KEY
}

stage('Run') {
    postman collection run ID -d data.json -g globals.json
}
```

---

# 🧠 10. DEVOPS INTERVIEW GOLD ANSWER

### Question:

**How do you automate API testing?**

### Answer:

```text
We use Postman for API development,
Newman or Postman CLI for automation.

Newman requires exporting collections,
Postman CLI runs directly from cloud using API key and collection ID.

We integrate it with Jenkins pipelines
to automate API testing in CI/CD.
```

---

# 📊 11. NEWMAN vs POSTMAN CLI (FINAL TABLE)

| Feature             | Newman   | Postman CLI |
| ------------------- | -------- | ----------- |
| Requires export     | Yes      | No          |
| Uses cloud          | No       | Yes         |
| Needs GitHub        | Yes      | No          |
| API key required    | No       | Yes         |
| Open source         | Yes      | No          |
| Reports             | Advanced | Basic       |
| Postman integration | No       | Yes         |

---

# 📚 12. FINAL PROJECT FLOW (VERY IMPORTANT)

From your lecture summary:

```text
1. Requirements
2. Test cases
3. Collections
4. Requests + validations
5. Run:
   - Postman UI
   - Newman CLI
   - Postman CLI
6. Jenkins CI/CD
7. Documentation
```



---

# 🔥 13. LAST PART: SWAGGER (IMPORTANT)

## Two types of documentation:

### 1. Static

```text
Word / Excel / Notes
```

❌ Cannot execute API

---

### 2. Interactive (Swagger)

```text
Swagger UI
```

✔ Send request
✔ Get response
✔ Test APIs

---

## 🔥 Why Swagger is important

```text
Used by developers + testers
Single source of truth
Helps write test cases
Supports API testing directly
```

---

# 🚀 FINAL SUMMARY

### You now understand:

✔ Newman vs Postman CLI
✔ Export vs Share
✔ API Key usage
✔ Collection ID usage
✔ Jenkins pipeline integration
✔ Swagger basics













# 🚀 PART 1 — MOCKING (VERY IMPORTANT CONCEPT)

## 🔹 What is Mocking?

👉 Mocking = **Simulation of API behavior**

From your file:

* Mocking = *simulate API request/response* 

---

## 🧠 Simple DevOps Explanation

```text
Real API → Not ready ❌
Mock API → Simulated response ✅
```

👉 You create a **fake server (mock server)** that behaves like real API.

---

## 🔥 Real Flow (Without Mocking)

```text
Client → API → Database → Response
```

---

## 🔥 With Mocking

```text
Client → Mock Server → Fake Response
```

---

## ⚡ WHY MOCKING IS USED

From your lecture:

✔ API not developed yet
✔ Development delayed
✔ QA wants to start testing
✔ You already have:

* endpoints
* request format
* expected response



---

## 💡 REAL DEVOPS SCENARIO

👉 Backend team is late
👉 QA / DevOps cannot wait

So you:

✔ Create mock server
✔ Simulate API
✔ Start automation + pipeline

---

## 🔥 KEY POINT (INTERVIEW GOLD)

```text
Mocking allows testing API behavior without real backend.
```

---

# ⚠️ IMPORTANT LIMITATION

👉 Mock API is:

❌ NOT real
❌ NOT dynamic
✔ STATIC response

From your file:

* response is **hardcoded**
* same output every time 

---

## 🧠 Example

```json
GET /employee/5
```

👉 Mock response:

```json
{
  "id": 3,
  "name": "John"
}
```

Even if ID = 5 → still returns 3

✔ Because it's fake

---

# 🔄 WHEN REAL API IS READY

👉 You DO NOT change logic

Just:

```text
Change Base URL
Mock → Real API
```

✔ Same collection
✔ Same tests
✔ Same validations

---

## 🔥 SUPER IMPORTANT (DevOps Insight)

```text
Mock → 90% work done early
Real API → final validation
```

---

# 🧱 MOCKING = STUB CONCEPT

From your file:

👉 Mock = Stub

```text
Temporary replacement of real component
```



---

# 🚀 PART 2 — PERFORMANCE TESTING (CRITICAL FOR DEVOPS)

---

## 🔹 What is Performance Testing?

👉 Testing **speed + scalability of API**

---

## 🧠 Difference

| Type        | Meaning              |
| ----------- | -------------------- |
| Functional  | Does it work?        |
| Performance | How fast under load? |



---

## ⚡ KEY IDEA

👉 1 user test ≠ real world

Real world:

```text
1000 users → same time → same API
```

---

# 🚨 BIG PROBLEMS (REAL WORLD)

From your lecture:

### ❌ Problem 1

Need many machines

### ❌ Problem 2

Cannot hit API at same exact time



---

# 💡 SOLUTION → VIRTUAL USERS

## 🔹 What is Virtual User?

👉 Fake user behaving like real user

✔ No physical machine
✔ Scales easily

---

## 🧠 Example

```text
3 virtual users → 3 parallel requests
```

---

# 🔥 KEY PARAMETERS

### 1. Virtual Users

Number of simulated users

### 2. Duration

How long test runs

---

# 🚀 LOAD PROFILES (VERY IMPORTANT)

This is **INTERVIEW CRITICAL**

---

## 1️⃣ FIXED

```text
Same users all the time
```

Example:

```text
10 users → constant → 5 min
```

---

## 2️⃣ RAMP-UP

```text
Gradually increase users
```

Example:

```text
1 → 2 → 3 → ... → 10
```

---

## 3️⃣ SPIKE

```text
Increase → then decrease
```

Example:

```text
1 → 10 → 1
```

---

## 4️⃣ PEAK

```text
Increase → stay → decrease
```

Example:

```text
1 → 10 → stay → 1
```

---

## 🔥 VISUAL UNDERSTANDING

```text
Fixed     ─────────────

Ramp-up   /---------

Spike     /\

Peak      /───\
```

---

# 📊 WHAT METRICS YOU GET

From your testing:

✔ Total requests
✔ Requests/sec
✔ Avg response time
✔ Error rate



---

## 🔥 MOST IMPORTANT METRIC

```text
Error Rate = 0% → GOOD
```

---

# 🧠 DEVOPS INTERVIEW ANSWER

### Question:

How do you test API performance?

### Answer:

```text
We use tools like Postman or JMeter.

We simulate multiple users using virtual users,
apply load profiles like fixed, ramp-up, spike, and peak,
and analyze metrics like response time, throughput, and error rate.

If performance is poor, developers optimize APIs.
```

---

# 🚀 REAL INDUSTRY TRUTH

From your lecture:

✔ Functional team → basic testing
✔ Performance team → specialized



---

## 💡 DevOps Role

👉 You may:

✔ Run tests
✔ Generate reports
✔ Share results

❌ Not deep analysis

---

# 🧾 FINAL SUMMARY

## Mocking

✔ Simulates API
✔ Used before backend ready
✔ Static response
✔ Saves time

---

## Performance Testing

✔ Tests speed under load
✔ Uses virtual users
✔ Uses load profiles
✔ Generates metrics


