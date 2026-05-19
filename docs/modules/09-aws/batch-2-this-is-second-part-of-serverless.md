---
title: "batch 2 this is second part of serverless"
description: "✅ STEP 1 — Install Homebrew (package manager for Mac)   Open Terminal and run:    /bin/bash..."
published: 2025-11-07
source: "https://dev.to/jumptotech/batch-2-this-is-second-part-of-serverless-28mk"
tags: []
---

# batch 2 this is second part of serverless



# ✅ **STEP 1 — Install Homebrew** (package manager for Mac)

Open **Terminal** and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install completes, run:

```bash
brew update
```

---

# ✅ **STEP 2 — Install Docker Desktop**

Docker is required so minikube can run containers.

Download and install:

[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

Then turn it ON.
Verify:

```bash
docker --version
```

If version shows → ✅ continue.

---

# ✅ **STEP 3 — Install Kubectl (Kubernetes CLI)**

```bash
brew install kubectl
```

Verify:

```bash
kubectl version --client
```

---

# ✅ **STEP 4 — Install Minikube**

```bash
brew install minikube
```

Start cluster:

```bash
minikube start --driver=docker
```

Check nodes:

```bash
kubectl get nodes
```

You should see:

```
minikube   Ready
```

✅ Kubernetes is now ready.

---

# ✅ **STEP 5 — Create a Test Deployment (check cluster works)**

```bash
kubectl create deployment hello --image=nginx
kubectl expose deployment hello --type=NodePort --port=80
```

Get URL:

```bash
minikube service hello --url
```

Open URL in browser → You should see **Welcome to Nginx**.

🎉 **Cluster working successfully.**

---

# ✅ **STEP 6 — Install OPA Gatekeeper (Security Policies)**

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

Check pods:

```bash
kubectl get pods -n gatekeeper-system
```

Wait until all are **Running**.

---

# ✅ **STEP 7 — Create First Policy**

### 7A: Create policy **template** (rule logic)

Create file:

```bash
nano k8s-require-limits-template.yaml
```

Paste:

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlimits
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLimits
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlimits

        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits.cpu
          msg := sprintf("CPU limit missing in container %v", [container.name])
        }
```

Apply:

```bash
kubectl apply -f k8s-require-limits-template.yaml
```

### 7B: Create **constraint** (activate rule)

```bash
nano k8s-require-limits-constraint.yaml
```

Paste:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLimits
metadata:
  name: require-cpu-and-memory-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

Apply:

```bash
kubectl apply -f k8s-require-limits-constraint.yaml
```

---

# ✅ **STEP 8 — Test Policy**

### 8A: Try to deploy **bad pod** (no limits)

```bash
kubectl run badpod --image=nginx
```

You should get:

```
Error: CPU limit missing in container nginx
```

### 8B: Deploy **good pod** (correct)

```bash
kubectl run goodpod --image=nginx --limits="cpu=200m,memory=128Mi"
kubectl get pods
```

✅ goodpod runs
❌ badpod blocked
**Gatekeeper is working.**

---

# 🎯 **STOP HERE — YOU HAVE ACHIEVED:**

| Component           | Status               |
| ------------------- | -------------------- |
| Kubernetes Cluster  | ✅ Running (Minikube) |
| Docker Runtime      | ✅ Installed          |
| kubectl CLI         | ✅ Ready              |
| OPA Gatekeeper      | ✅ Enforcing rules    |
| Security Governance | ✅ Working            |

This is **exactly what real DevOps teams use in companies**.


You already have **this architecture in AWS**:

```
Client → API Gateway → Lambda → DynamoDB
                              ↓
                         Step Functions
```

And you now have **this environment locally**:

```
Developer Laptop (Mac)
   → Docker
   → Minikube (Kubernetes Cluster)
   → Gatekeeper (OPA Policies)
```

Now we **correlate** them — showing how **DevOps** works across both.

---

# ✅ **1. Why Both Are Needed**

| AWS Serverless                                                        | Kubernetes + OPA                                                     |
| --------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Runs your **business logic** (Place Order, Validate, Charge, Confirm) | Runs your **infrastructure governance and application environments** |
| Handles scaling, event-driven workflows                               | Ensures **security rules**, compliance, deployments                  |
| DynamoDB stores profile/order data                                    | OPA ensures only safe, compliant workloads enter cluster             |
| Lambda functions process events                                       | K8s runs your long-running apps, dashboards, CI/CD agents            |

So, AWS = **core app backend**
Kubernetes = **runtime + governance platform**

---

# ✅ **2. What Goes Where in Real DevOps Projects**

| Component                            | Where It Runs                    | Why                             |
| ------------------------------------ | -------------------------------- | ------------------------------- |
| Profiles API (POST /profiles)        | **AWS Lambda**                   | Event-driven, lightweight       |
| PlaceOrder Step Function             | **AWS Step Functions**           | Business workflow orchestration |
| Profile + Order Data                 | **DynamoDB**                     | NoSQL scalable backend          |
| Frontend / Dashboard / Monitoring UI | **Kubernetes**                   | Stable long-running services    |
| CI/CD Pipelines                      | **Kubernetes or GitHub Actions** | Automate deployments            |
| Security Controls                    | **OPA Gatekeeper in Kubernetes** | Enforce organization rules      |

So your **serverless backend stays in AWS**
Your **applications and monitoring operate on K8s**
Gatekeeper **protects K8s workloads**.

---

# ✅ **3. Your Project Architecture (NOW)**

```
Users & Students
     ↓
     UI (to be deployed in Kubernetes)
     ↓
  API Gateway (AWS)
     ↓
  Lambda Functions
     ↓
  DynamoDB
     ↓
Step Functions (Place Order Workflow)
     ↓             ↑
   Events → S3, SNS, CloudWatch
```

And separately enforcing rules:

```
Kubernetes Cluster
   → Gatekeeper ensures:
      - CPU/memory limits set
      - No privileged pods
      - Only approved namespaces
```

---





# Project: Serverless Orders (DevOps Edition)

## What you’ll build

```
Frontend (React) → CloudFront → API Gateway
                                 ├─ POST /profiles → Lambda → DynamoDB (profiles)
                                 ├─ POST /orders   → Lambda → StepFunctions → 4 Lambdas → DynamoDB (order)
                                 └─ GET  /orders/{id} → Lambda → DynamoDB (order)
```

You’ll also run a **local Minikube cluster** with **OPA Gatekeeper** to show Kubernetes governance (what DevOps enforces in teams).

---

## 0) Prereqs you need once

* AWS account in **us-east-1**
* IAM user with programmatic access
* On your Mac: Homebrew, Git, Node.js LTS (>=18), AWS CLI, Docker Desktop (for Minikube)

```bash
# install basics (if missing)
brew install git awscli node
```

Login:

```bash
aws configure
# Region: us-east-1
```

---

## 1) Clone this repo structure locally

Create a new GitHub repo, e.g. `serverless-orders-devops`, then make this structure:

```
serverless-orders-devops/
│
├─ backend/
│  ├─ lambdas/
│  │  ├─ create-profile.py
│  │  ├─ create-order.py
│  │  ├─ get-order.py
│  │  ├─ validate-order.py
│  │  ├─ reserve-inventory.py
│  │  ├─ charge-payment.py
│  │  └─ confirm-order.py
│  ├─ stepfunctions/
│  │  └─ placeorder.json
│  └─ iam/
│     └─ lambda-execution-policy.json
│
├─ infra-notes/ (manual click steps you’ll do in console)
│  ├─ apigw-setup.md
│  ├─ dynamodb-setup.md
│  └─ stepfunctions-setup.md
│
├─ frontend/   (React app)
│  ├─ package.json
│  ├─ vite.config.js
│  ├─ index.html
│  └─ src/
│     ├─ main.jsx
│     └─ App.jsx
│
├─ k8s/   (Minikube + OPA Gatekeeper)
│  ├─ gatekeeper-install.md
│  ├─ k8s-require-limits-template.yaml
│  └─ k8s-require-limits-constraint.yaml
│
└─ .github/workflows/
   ├─ deploy-lambdas.yml
   └─ deploy-frontend.yml
```

---

## 2) DynamoDB (create tables once)

Create **profiles** and **order** tables in **us-east-1**:

* **profiles**: Partition key `userId` (String)
* **order**: Partition key `orderId` (String)

(You can create via console → DynamoDB → Tables → Create.)

---

## 3) Lambda functions (backend/lambdas)

All Lambdas use **us-east-1**. Copy these files:

### `create-profile.py`  (POST /profiles)

```python
import json, boto3
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('profiles')

def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    # expects { "userId": "...", "name": "...", "email": "..." }
    item = {
        "userId": body["userId"],
        "name": body.get("name",""),
        "email": body.get("email","")
    }
    table.put_item(Item=item)
    return {"statusCode": 200, "headers": {"Content-Type":"application/json"}, "body": json.dumps(item)}
```

### `create-order.py`  (POST /orders → starts Step Function)

> Add env var `STATE_MACHINE_ARN` in console later.

```python
import json, boto3, os
sf = boto3.client('stepfunctions', region_name='us-east-1')
STATE_MACHINE_ARN = os.environ['STATE_MACHINE_ARN']

def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    # expects { "orderId": "...", "userId": "...", "amount": 150, "items": ["x","y"] }
    data = {
        "orderId": body["orderId"],
        "userId": body["userId"],
        "amount": body.get("amount", 0),
        "items": body.get("items", [])
    }
    sf.start_execution(stateMachineArn=STATE_MACHINE_ARN, input=json.dumps(data))
    return {"statusCode": 202, "headers": {"Content-Type":"application/json"},
            "body": json.dumps({"orderId": data["orderId"], "status": "STARTED"})}
```

### `get-order.py`  (GET /orders/{id})

```python
import json, boto3
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    order_id = event["pathParameters"]["id"]
    resp = table.get_item(Key={"orderId": order_id})
    item = resp.get("Item")
    return {"statusCode": 200 if item else 404,
            "headers": {"Content-Type":"application/json"},
            "body": json.dumps(item or {"error": "not found"})}
```

### Step Functions worker Lambdas (called by state machine)

All four read the **direct** event (no Proxy wrapper because we’ll call with the simple `Resource` style):

#### `validate-order.py`

```python
def lambda_handler(event, context):
    # event: { orderId, userId, amount, items }
    # Basic validation
    if not all(k in event for k in ("orderId","userId","amount","items")):
        raise Exception("Missing fields")
    return event  # pass along
```

#### `reserve-inventory.py`

```python
import boto3
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    event["status"] = "RESERVED"
    table.put_item(Item=event)
    return event
```

#### `charge-payment.py`

```python
def lambda_handler(event, context):
    amt = int(event.get("amount", 0))
    if amt <= 0:
        raise Exception("Invalid amount")
    event["payment_status"] = "PAID"
    return event
```

#### `confirm-order.py`

```python
import boto3
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('order')

def lambda_handler(event, context):
    event["status"] = "CONFIRMED"
    table.put_item(Item=event)
    return event
```

---

## 4) Step Functions definition (backend/stepfunctions/placeorder.json)

Replace `YOUR_ACCOUNT_ID` with yours.

```json
{
  "Comment": "Serverless Order Processing Workflow",
  "StartAt": "Validate",
  "States": {
    "Validate": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:validate-order",
      "Next": "Reserve"
    },
    "Reserve": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:reserve-inventory",
      "Next": "Charge"
    },
    "Charge": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:charge-payment",
      "Next": "Confirm"
    },
    "Confirm": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:confirm-order",
      "End": true
    }
  }
}
```

---

## 5) Minimal IAM policy for Lambda exec (backend/iam/lambda-execution-policy.json)

Attach to each Lambda role (edit ARNs to your tables).

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], "Resource": "*" },
    { "Effect": "Allow", "Action": ["dynamodb:PutItem","dynamodb:GetItem","dynamodb:Scan","dynamodb:UpdateItem"], "Resource": [
      "arn:aws:dynamodb:us-east-1:*:table/order",
      "arn:aws:dynamodb:us-east-1:*:table/profiles"
    ]},
    { "Effect": "Allow", "Action": ["states:StartExecution"], "Resource": "arn:aws:states:us-east-1:*:stateMachine:PlaceOrder" }
  ]
}
```

---

## 6) Create Lambdas + Step Function + API Gateway (console steps)

**Lambdas**: Create 7 functions with names matching filenames (without `.py`). Paste code, set Python 3.11 runtime.

**Step Functions**: Create Standard state machine **PlaceOrder** → paste `placeorder.json`.
**Note:** publish Lambdas first so ARNs are valid.

**Env var:** In **create-order** Lambda set:

```
STATE_MACHINE_ARN = arn:aws:states:us-east-1:YOUR_ACCOUNT_ID:stateMachine:PlaceOrder
```

**API Gateway (REST)**:

* Create or open your existing API
* **Resource** `/profiles` → **POST** → Lambda proxy = `create-profile`
* **Resource** `/orders` → **POST** → Lambda proxy = `create-order`
* **Resource** `/orders/{id}` → **GET** → Lambda proxy = `get-order`
* **Enable CORS** for all three
* **Deploy** to stages **dev** and **prod** (start with dev)

**Test bodies:**

```json
# POST /profiles
{"userId": "user001", "name": "Emma", "email": "emma@example.com"}

# POST /orders
{"orderId": "order123", "userId": "user001", "amount": 150, "items": ["Phone","Charger"]}

# GET /orders/order123
```

You should see Step Functions executions and DynamoDB items updating.

---

## 7) React frontend (frontend/)

Initialize with Vite (already prefilled files below).

### `package.json`

```json
{
  "name": "orders-ui",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^5.4.0"
  }
}
```

### `vite.config.js`

```js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  build: { outDir: 'dist' }
})
```

### `index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Serverless Orders UI</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

### `src/main.jsx`

```jsx
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.jsx'
createRoot(document.getElementById('root')).render(<App />)
```

### `src/App.jsx`

```jsx
import React, { useState } from 'react'

// Set your API base once (no trailing slash), e.g.:
// const BASE_URL = "https://xxx.execute-api.us-east-1.amazonaws.com/dev";
const BASE_URL = "YOUR_API_BASE_URL";

export default function App() {
  const [profile, setProfile] = useState({ userId:'user001', name:'Emma', email:'emma@example.com' })
  const [order, setOrder] = useState({ orderId:'order123', userId:'user001', amount:150, items:'Phone, Charger' })
  const [getId, setGetId] = useState('order123')
  const [out1, setOut1] = useState('')
  const [out2, setOut2] = useState('')
  const [out3, setOut3] = useState('')

  const j = v => JSON.stringify(v, null, 2)

  const post = async (path, body, setOut) => {
    try {
      const res = await fetch(`${BASE_URL}${path}`, {
        method:'POST',
        headers:{ 'Content-Type':'application/json' },
        body: JSON.stringify(body)
      })
      setOut(`Status ${res.status}\n` + (await res.text()))
    } catch (e) {
      setOut('Error: ' + e.message)
    }
  }

  const get = async (path, setOut) => {
    try {
      const res = await fetch(`${BASE_URL}${path}`)
      setOut(`Status ${res.status}\n` + (await res.text()))
    } catch (e) {
      setOut('Error: ' + e.message)
    }
  }

  return (
    <div style={{fontFamily:'system-ui', maxWidth:960, margin:'24px auto', lineHeight:1.4}}>
      <h1>Serverless Orders</h1>
      <p><b>API Base:</b> {BASE_URL || '(set in App.jsx)'} </p>

      <section style={card}>
        <h2>1) Create / Update Profile (POST /profiles)</h2>
        <Row>
          <Field label="userId" value={profile.userId} onChange={v=>setProfile({...profile, userId:v})}/>
          <Field label="name"   value={profile.name}   onChange={v=>setProfile({...profile, name:v})}/>
          <Field label="email"  value={profile.email}  onChange={v=>setProfile({...profile, email:v})}/>
        </Row>
        <button onClick={()=>post('/profiles', profile, setOut1)}>Send</button>
        <Pre text={out1}/>
      </section>

      <section style={card}>
        <h2>2) Create Order (POST /orders)</h2>
        <Row>
          <Field label="orderId" value={order.orderId} onChange={v=>setOrder({...order, orderId:v})}/>
          <Field label="userId"  value={order.userId}  onChange={v=>setOrder({...order, userId:v})}/>
          <Field label="amount"  value={order.amount}  onChange={v=>setOrder({...order, amount:Number(v)})} type="number"/>
        </Row>
        <Field label="items (comma separated)" value={order.items} onChange={v=>setOrder({...order, items:v})}/>
        <button onClick={()=>{
          const payload = {...order, items: order.items.split(',').map(s=>s.trim()).filter(Boolean)}
          post('/orders', payload, setOut2)
        }}>Send</button>
        <Pre text={out2}/>
      </section>

      <section style={card}>
        <h2>3) Get Order Status (GET /orders/{'{id}'})</h2>
        <Field label="orderId" value={getId} onChange={setGetId}/>
        <button onClick={()=>get(`/orders/${encodeURIComponent(getId)}`, setOut3)}>Fetch</button>
        <Pre text={out3}/>
      </section>
    </div>
  )
}

const card = {border:'1px solid #e5e7eb', borderRadius:12, padding:16, margin:'16px 0'}
const Row  = ({children}) => <div style={{display:'flex', gap:12, flexWrap:'wrap'}}>{children}</div>
const Field = ({label, value, onChange, type='text'}) => (
  <label style={{display:'block', flex:'1 1 280px'}}>
    <div style={{fontWeight:600, margin:'8px 0 4px'}}>{label}</div>
    <input type={type} value={value} onChange={e=>onChange(e.target.value)} style={{width:'100%', padding:10, border:'1px solid #d1d5db', borderRadius:8}}/>
  </label>
)
const Pre = ({text}) => <pre style={{background:'#0b1021', color:'#e5e7eb', padding:12, borderRadius:10, overflow:'auto'}}>{text || '—'}</pre>
```

Install & run locally:

```bash
cd frontend
npm install
npm run dev
```

Open the local URL → set `BASE_URL` in `App.jsx` to your API stage, like:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/dev
```

Build for deploy:

```bash
npm run build
```

This produces `frontend/dist/`.

---

## 8) Host the React app (S3 + CloudFront)

* Create S3 bucket (e.g., `orders-ui-demo`) → **Block public access: off** for quick demo, or use OAC with CloudFront for production.
* Upload `frontend/dist/**` into the bucket root.
* Enable **Static Website Hosting** and set index `index.html`.
* Create CloudFront distribution → origin your S3. Set default root object `index.html`.
* Test the CloudFront URL.

---

## 9) GitHub Actions (CI/CD)

### A) Deploy all Lambda functions on push

`.github/workflows/deploy-lambdas.yml`

```yaml
name: Deploy Lambdas
on:
  push:
    branches: [ "main" ]
    paths:
      - 'backend/lambdas/**'
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Zip & Update Lambda code
        run: |
          cd backend/lambdas
          for f in *.py; do
            NAME="${f%.py}"
            zip -r "$NAME.zip" "$f"
            aws lambda update-function-code --function-name "$NAME" --zip-file "fileb://$NAME.zip"
          done
```

> Add repo secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.

### B) Build & deploy frontend to S3

`.github/workflows/deploy-frontend.yml`

```yaml
name: Deploy Frontend
on:
  push:
    branches: [ "main" ]
    paths:
      - 'frontend/**'
jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Build
        working-directory: frontend
        run: |
          npm ci
          npm run build
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Sync to S3
        run: |
          aws s3 sync frontend/dist s3://${{ secrets.FRONTEND_BUCKET }} --delete
      - name: Invalidate CloudFront (optional)
        if: ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID != '' }}
        run: |
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```

> Add repo secrets: `FRONTEND_BUCKET` and (optional) `CLOUDFRONT_DISTRIBUTION_ID`.

---

## 10) Minikube + OPA Gatekeeper (local governance)

### install

```bash
brew install kubectl minikube
minikube start --driver=docker
```

### OPA Gatekeeper

`k8s/gatekeeper-install.md` (run):

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
kubectl get pods -n gatekeeper-system
```

### Policy template

`k8s/k8s-require-limits-template.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlimits
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLimits
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlimits
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits.cpu
          msg := sprintf("CPU limit missing in container %v", [container.name])
        }
```

### Constraint (activate rule)

`k8s/k8s-require-limits-constraint.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLimits
metadata:
  name: require-cpu-and-memory-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

Apply:

```bash
kubectl apply -f k8s/k8s-require-limits-template.yaml
kubectl apply -f k8s/k8s-require-limits-constraint.yaml
```

Test:

```bash
kubectl run badpod --image=nginx   # should be blocked
kubectl run goodpod --image=nginx --limits="cpu=200m,memory=128Mi"  # should run
```

> Explain to students: Gatekeeper = cluster security guard. Blocks unsafe manifests before they run.

---

## 11) Monitoring (what DevOps owns)

* **CloudWatch Logs** for every Lambda (`/aws/lambda/...`)
* **Step Functions** executions (graph + errors)
* **API Gateway** 4xx/5xx and latency (enable detailed metrics)
* **DynamoDB** throttles (RCU/WCU alarms)
* (Optional) Create a **CloudWatch Dashboard** with these widgets

---

## 12) Quick “teach this” script (for class)

1. “We have 3 public endpoints: `/profiles`, `/orders`, `/orders/{id}`”
2. “When you POST `/orders`, it starts Step Functions (Validate → Reserve → Charge → Confirm)”
3. “DynamoDB stores final state in `order` table”
4. “React UI calls the API; we host it on CloudFront”
5. “CI/CD: on push, GitHub Actions deploys Lambdas & UI automatically”
6. “Kubernetes is separate runtime; OPA Gatekeeper enforces org rules”
7. “DevOps owns automation, observability, security guardrails, and reliability”

---

## 13) What to do **right now**

* Fill `YOUR_ACCOUNT_ID` in `placeorder.json`
* Set `STATE_MACHINE_ARN` env var on `create-order` Lambda
* Put your **API base URL** in `frontend/src/App.jsx`
* Create S3 + CloudFront, add GitHub secrets:

  * `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
  * `FRONTEND_BUCKET`, optional `CLOUDFRONT_DISTRIBUTION_ID`
* Push to `main` → CI/CD runs


