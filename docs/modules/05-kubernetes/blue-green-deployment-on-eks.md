---
title: "Blue-Green Deployment on EKS"
description: "What is EKS (in simple words)       EKS = Managed Kubernetes by Amazon Web Services  EKS..."
published: 2026-01-08
source: "https://dev.to/jumptotech/blue-green-deployment-on-eks-4l2j"
tags: []
---

# Blue-Green Deployment on EKS




## What is EKS (in simple words)

![Image](https://www.flexera.com/blog/wp-content/uploads/2025/10/1-complete-guide-aws-eks-architecture-pricing-tips.png)

![Image](https://docs.aws.amazon.com/images/eks/latest/best-practices/images/reliability/eks-data-plane-connectivity.jpeg)



**EKS = Managed Kubernetes by Amazon Web Services**

EKS gives you:

* Kubernetes **control plane** (API server, scheduler)
* AWS manages it for you

You still need:

* **Worker nodes (EC2)** → to run Pods
* **kubectl** → to talk to the cluster
* **YAML** → to tell Kubernetes what to run

### Very important mental model

```
Your laptop (kubectl)
        |
        v
EKS API Server (managed by AWS)
        |
        v
Worker Nodes (EC2) → Pods → Containers
```

You NEVER SSH into nodes.

---

## Step 1 — Create EKS manually (AWS Console, no tools)

### 1. Open AWS Console → EKS

* Choose region (example: us-east-1)
* Click **Create cluster**

### 2. Cluster configuration

Fill only:

* **Name**: `bluegreen-demo`
* **Kubernetes version**: default
* **Cluster service role**:
  If AWS shows one → select
  If not → click **Create role** (AWS auto-creates it)

Click **Next**

### 3. Networking

Use **defaults**:

* Default VPC
* At least 2 subnets
* Public endpoint access

Click **Create**

⏳ Wait until **ACTIVE**

At this point:

* Kubernetes exists
* BUT nothing can run yet

---

## Step 2 — Create worker nodes (THIS creates EC2)

### Why we need this

Kubernetes schedules Pods onto **nodes**.
No nodes = no Pods.

### Create Node Group

Inside your cluster:

* Go to **Compute → Add node group**

Fill:

* Name: `bg-nodes`
* IAM role: create/select default worker role

Node settings:

* Instance type: `t3.medium`
* Desired: 2
* Min: 2
* Max: 3

Create node group → wait until **ACTIVE**

Now EC2 exists automatically.

---

## Step 3 — Connect kubectl (this is how DevOps works)

From your laptop:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name bluegreen-demo
```

Verify:

```bash
kubectl get nodes
```

If you see nodes → you are connected.

From now on:

* AWS Console is almost irrelevant
* Everything is done with `kubectl`

---

## Why deployment strategies exist (VERY IMPORTANT)

### Before Kubernetes (old world)

* Stop app
* Deploy new version
* Start app again
* Users see downtime
* Rollback is slow

### Problems DevOps had

* Downtime during deploys
* Users getting errors
* No fast rollback
* Fear of deployments

### Kubernetes solved:

* Pods
* Services
* Self-healing
* BUT deployment strategy decides **how traffic moves**

That’s why **deployment strategies exist**.

---

## What is Blue-Green Strategy (simple)

**Blue-Green = two versions running at the same time**

* **Blue** → current production
* **Green** → new version, tested
* Traffic switches **all at once**

No partial traffic.
No slow rollout.

---

## Why Blue-Green is used in DevOps

### Benefits

* Zero downtime
* Instant rollback
* Safe releases
* Easy to understand
* Predictable behavior

### When DevOps chooses Blue-Green

* Critical applications
* APIs
* Financial systems
* Internal platforms
* When failure is expensive

---

## How Blue-Green works in Kubernetes (simple truth)

Kubernetes already gives us the tool:
👉 **Service**

A Service decides:

> “Which Pods receive traffic?”

Blue-Green = **change Service selector**

That’s it.

---

## Blue-Green deployment (from scratch)

### 1️⃣ Blue Deployment (v1 – live)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
      color: blue
  template:
    metadata:
      labels:
        app: demo
        color: blue
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-text=BLUE v1"]
        ports:
        - containerPort: 5678
```

---

### 2️⃣ Green Deployment (v2 – not live)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
      color: green
  template:
    metadata:
      labels:
        app: demo
        color: green
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args: ["-text=GREEN v2"]
        ports:
        - containerPort: 5678
```

---

### 3️⃣ Service (production traffic)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prod-svc
spec:
  selector:
    app: demo
    color: blue   # LIVE VERSION
  ports:
  - port: 80
    targetPort: 5678
```

This is the **control switch**.

---

## Deploy everything

```bash
kubectl apply -f blue.yaml
kubectl apply -f green.yaml
kubectl apply -f service.yaml
```

Traffic → **BLUE**

---

## The deployment itself (Blue → Green)

Change one line:

```yaml
color: green
```

Apply again:

```bash
kubectl apply -f service.yaml
```

Traffic switches instantly.

No Pod restart.
No downtime.

---

## Rollback (DevOps safety)

Change back:

```yaml
color: blue
```

Apply → rollback complete.

---

## Where DevOps uses Blue-Green in real life

| Area              | Usage                   |
| ----------------- | ----------------------- |
| Kubernetes        | Service selector        |
| AWS               | ALB target group switch |
| CI/CD             | Release promotion       |
| Monitoring        | Validate before switch  |
| Incident response | Instant rollback        |

---

## Compare with other strategies (simple)

| Strategy       | How traffic moves |
| -------------- | ----------------- |
| Rolling        | Gradually         |
| Canary         | Small % first     |
| **Blue-Green** | **All at once**   |

---

## Key DevOps takeaway (this is gold)

> Kubernetes does not deploy applications.
> **Kubernetes deploys traffic behavior.**

Deployment strategies are about **traffic control**, not containers.


