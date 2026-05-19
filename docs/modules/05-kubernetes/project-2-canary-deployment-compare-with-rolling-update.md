---
title: "Project 2 — Canary Deployment (Compare with Rolling Update)"
description: "Rolling update   Replaces pods gradually Users automatically move to new version No “choice” of who..."
published: 2026-01-06
source: "https://dev.to/jumptotech/project-2-canary-deployment-compare-with-rolling-update-1ljn"
tags: []
---

# Project 2 — Canary Deployment (Compare with Rolling Update)







**Rolling update**

* Replaces pods gradually
* Users automatically move to new version
* No “choice” of who sees the new version

**Canary deployment**

* **Only a small % of traffic** goes to the new version
* You **observe metrics**
* You **decide** to promote or rollback

This project shows **WHY DevOps prefers Canary for risky changes**.

---

## Architecture (keep this picture in mind)

![Image](https://miro.medium.com/v2/resize%3Afit%3A2000/1%2AWG0jvAOdkOfER60FygS6qQ.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AkQEAKUXMcCy5DtysZkiM0A.jpeg)

![Image](https://media2.dev.to/dynamic/image/width%3D1000%2Cheight%3D420%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fm3jwliwz5ukau69r75kd.png)

```
User
 │
 ▼
Service
 │
 ├── 90% → app-v1 pods
 └── 10% → app-v2 pods (CANARY)
```

---

## Tools used

* Minikube
* kubectl
* hashicorp/http-echo 

---

## Step 1 — Deploy STABLE version (v1)

### `stable.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
spec:
  replicas: 9
  selector:
    matchLabels:
      app: echo
      version: v1
  template:
    metadata:
      labels:
        app: echo
        version: v1
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=STABLE v1"
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f stable.yaml
```

---

## Step 2 — Create CANARY version (v2)

### `canary.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
      version: v2
  template:
    metadata:
      labels:
        app: echo
        version: v2
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=CANARY v2"
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f canary.yaml
```

---

## Step 3 — ONE Service (this is the key difference)

### `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: echo-svc
spec:
  selector:
    app: echo
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f service.yaml
```

Important:

* The Service selects **both v1 and v2**
* Kubernetes load-balances **by pod count**
* 9 pods vs 1 pod → ~90/10 traffic split

---

## Step 4 — Access the service

```bash
minikube service echo-svc
```

Or:

```bash
URL=$(minikube service echo-svc --url)
```

---

## Step 5 — Watch Canary behavior (LIVE demo)

### Continuous traffic test

```bash
while true; do
  curl -s $URL
  sleep 0.2
done
```

### Expected output

```
STABLE v1
STABLE v1
STABLE v1
CANARY v2
STABLE v1
STABLE v1
```

This is the **money moment** of the demo.

---

## Compare: Rolling vs Canary (DevOps perspective)

| Feature                | Rolling Update | Canary Deployment   |
| ---------------------- | -------------- | ------------------- |
| User control           | ❌ None         | ✅ Partial           |
| Risk                   | Medium         | Low                 |
| Metrics-based decision | ❌              | ✅                   |
| Rollback speed         | Medium         | Fast                |
| Complexity             | Low            | Medium              |
| Used in prod?          | Yes            | **YES (preferred)** |

---

## DevOps job during Canary

You **do NOT touch code**.

You:

1. Watch logs

   ```bash
   kubectl logs -l version=v2
   ```
2. Watch errors / latency
3. Decide:

   * Promote
   * Pause
   * Rollback

---

## Step 6 — Promote Canary to Full Release

### Option A — Scale up v2

```bash
kubectl scale deployment app-v2 --replicas=10
kubectl scale deployment app-v1 --replicas=0
```

### Option B — Delete v1

```bash
kubectl delete deployment app-v1
```

Traffic now:

```
CANARY v2
CANARY v2
CANARY v2
```

---

## Step 7 — Rollback scenario (very important)

Simulate failure:

```bash
kubectl delete deployment app-v2
```

Result:

* Traffic instantly returns to v1
* No downtime
* No rollout undo logic needed

---

## Why Canary beats Rolling in real production

Rolling update:

* You **find bugs after users complain**

Canary:

* You **detect issues before users notice**
* You protect revenue
* You protect brand

That’s why:

* Netflix
* Google
* Amazon
  all use **Canary or Progressive Delivery**

---



