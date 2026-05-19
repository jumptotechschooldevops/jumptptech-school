---
title: "project canary strategy in deployment"
description: "What this project demonstrates (clearly)    What Canary deployment really is How..."
published: 2026-01-06
source: "https://dev.to/jumptotech/project-canary-strategy-in-deployment-1ocf"
tags: []
---

# project canary strategy in deployment



![Image](https://miro.medium.com/v2/resize%3Afit%3A2000/1%2AWG0jvAOdkOfER60FygS6qQ.png)

![Image](https://i.sstatic.net/xY184.png)

![Image](https://miro.medium.com/0%2AM41gQ7P3kbXVr2h1)

## What this project demonstrates (clearly)

* What **Canary deployment** really is
* How **traffic is split** between versions
* Why Canary exists (real production reason)
* What a **DevOps engineer must watch carefully**
* What can **break in production** if Canary is done wrong

---

# 1️⃣ What is Canary (plain DevOps explanation)

**Canary deployment = release a new version to a SMALL % of users first.**

Instead of:

* Replacing everything at once (Rolling)
* Or running two full stacks (Blue/Green)

You:

* Keep **v1 (stable)** running
* Add **v2 (canary)** with **fewer replicas**
* Let Kubernetes **naturally split traffic**

If something goes wrong → **delete canary instantly**
If all is good → **scale canary up, scale v1 down**

> DevOps goal: **reduce blast radius**

---

# 2️⃣ When DevOps uses Canary (real life)

You use Canary when:

* New feature touches **payments, auth, Kafka consumers**
* Schema or config change is risky
* You want **real user traffic**, not test traffic
* Monitoring & rollback must be **instant**

You DO NOT use Canary when:

* App is stateless and tiny
* No monitoring
* No rollback process
* Small internal tools

---

# 3️⃣ Canary Demo Project (what you will build)

You will deploy:

* **v1** → returns `VERSION 1`
* **v2 (canary)** → returns `VERSION 2`
* One **Service**
* Traffic split via **replica count**

---

# 4️⃣ Step-by-step implementation (smallest YAML possible)

## Step 1 — Stable version (v1)

### `deploy-v1.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
      version: v1
  template:
    metadata:
      labels:
        app: demo
        version: v1
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args:
          - "-listen=:8080"
          - "-text=VERSION 1"
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f deploy-v1.yaml
```

---

## Step 2 — Canary version (v2)

### `deploy-v2-canary.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2-canary
spec:
  replicas: 1   # 🔑 THIS is the canary
  selector:
    matchLabels:
      app: demo
      version: v2
  template:
    metadata:
      labels:
        app: demo
        version: v2
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args:
          - "-listen=:8080"
          - "-text=VERSION 2 (CANARY)"
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f deploy-v2-canary.yaml
```

---

## Step 3 — Single Service (traffic split happens here)

### `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-svc
spec:
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f service.yaml
```

---

# 5️⃣ Live traffic observation (MOST IMPORTANT PART)

Expose service:

```bash
minikube service demo-svc
```

Now run **continuous traffic**:

```URL=http://127.0.0.1:64589

while true; do
  date +"%H:%M:%S"
  curl -s $URL
  echo
  sleep 0.3
done

```

### What you will SEE

```
VERSION 1
VERSION 1
VERSION 1
VERSION 2 (CANARY)
VERSION 1
VERSION 1
```

This is Canary **in action**.

---

# 6️⃣ How traffic splitting really works (DevOps reality)

Kubernetes:

* Does **NOT** split by percentage
* It splits by **number of Pods**

Here:

* v1 = 3 pods
* v2 = 1 pod

≈ **25% traffic → canary**

---

# 7️⃣ DevOps responsibilities during Canary (this is the key part)

As DevOps, you must **watch these live**:

### 🔍 Metrics

* Error rate (5xx)
* Latency increase
* Pod restarts
* CPU / memory spikes

### 📜 Logs

* App exceptions
* Kafka lag
* DB connection failures

### 🚦 Health

* Readiness probe failures
* CrashLoopBackOff
* Partial availability

---

# 8️⃣ Simulate failure (important demo)

Delete canary immediately:

```bash
kubectl delete deployment app-v2-canary
```

Traffic instantly returns to:

```
VERSION 1
VERSION 1
VERSION 1
```

👉 **No rollback needed**
👉 **No downtime**
👉 **This is why Canary exists**

---

# 9️⃣ Promote Canary to full release

If everything looks good:

```bash
kubectl scale deployment app-v2-canary --replicas=3
kubectl scale deployment app-v1 --replicas=0
```

Now:

* v2 becomes main
* v1 gone
* Users never noticed

---

# 🔟 Common Canary mistakes (real production issues)

❌ No monitoring
❌ Canary has no readinessProbe
❌ Same DB migration for v1 & v2
❌ Canary runs longer than needed
❌ No instant delete plan

---

# Final DevOps takeaway (important)

Canary is not YAML.
Canary is **risk management**.

Your real job:

* Control exposure
* Detect failure early
* Kill bad releases fast
* Protect users & business


