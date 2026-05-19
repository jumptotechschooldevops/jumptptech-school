---
title: "CKA DEPLOYMENT & SERVICE LAB #2"
description: "GLOBAL RULES    Do NOT use kubectl edit  Do NOT recreate resources unless asked Fix issues..."
published: 2026-01-08
source: "https://dev.to/jumptotech/cka-deployment-service-lab-2-21mg"
tags: []
---

# CKA DEPLOYMENT & SERVICE LAB #2







## GLOBAL RULES

* Do **NOT** use `kubectl edit`
* Do **NOT** recreate resources unless asked
* Fix issues using **kubectl patch / set / scale / rollout**
* Namespace must be used
* Treat this like a **real CKA exam**

---

# 🟢 BASELINE (RUN ON EVERY MACHINE)

### Step 0 — Start cluster

```bash
minikube start --driver=docker
```

---

### Step 1 — Namespace

```bash
kubectl create namespace cka-lab
kubectl config set-context --current --namespace=cka-lab
```

---

### Step 2 — Apply BASE WORKLOAD (DO NOT MODIFY)

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF
```

---

### Step 3 — Apply BASE SERVICE (DO NOT MODIFY)

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
```

---

### Step 4 — Traffic test pod (keep running)

```bash
kubectl run traffic --image=busybox -it --rm -- sh
```

Inside:

```sh
while true; do
  wget -qO- web-svc
  echo "-----"
  sleep 1
done
```

---

# 🧪 TASK 1 — ROLLING UPDATE MISCONFIGURATION

### PROBLEM SETUP

```bash
kubectl patch deployment web-app -p '
{
  "spec": {
    "strategy": {
      "type": "RollingUpdate",
      "rollingUpdate": {
        "maxUnavailable": 4,
        "maxSurge": 0
      }
    }
  }
}'
```

### TASK

* Fix the deployment strategy
* Ensure **no downtime** during image updates

### SUCCESS CRITERIA

* Traffic loop never stops
* At least one pod always available

---

# 🧪 TASK 2 — BROKEN IMAGE DEPLOYMENT

### PROBLEM SETUP

```bash
kubectl set image deployment/web-app nginx=nginx:doesnotexist
```

### TASK

* Restore the deployment to a healthy state
* Do NOT delete the deployment

### SUCCESS CRITERIA

* All pods Running
* No CrashLoopBackOff
* Traffic loop stable

---

# 🧪 TASK 3 — MISSING READINESS PROBE

### PROBLEM SETUP

```bash
kubectl patch deployment web-app --type=json -p='[
  {
    "op": "remove",
    "path": "/spec/template/spec/containers/0/readinessProbe"
  }
]'
```

### TASK

* Ensure traffic is only sent to ready pods
* Do NOT restart the cluster

### SUCCESS CRITERIA

* During rollout, traffic never hits unready pods

---

# 🧪 TASK 4 — SERVICE TRAFFIC FAILURE

### PROBLEM SETUP

```bash
kubectl patch svc web-svc -p '
{
  "spec": {
    "selector": {
      "app": "wrong"
    }
  }
}'
```

### TASK

* Restore service traffic
* Do NOT recreate the service

### SUCCESS CRITERIA

* `Endpoints` populated
* Traffic loop resumes

---

# 🧪 TASK 5 — CANARY DEPLOYMENT (TRAFFIC LEAK)

### PROBLEM SETUP

```bash
kubectl create deployment web-app-canary --image=nginx:1.27 --replicas=1
kubectl label deployment web-app-canary track=canary
```

### TASK

* Canary must receive traffic
* Stable workload must remain untouched

### SUCCESS CRITERIA

* Service routes traffic to **both versions**
* No service recreation

---

# 🧪 TASK 6 — CANARY ROLLBACK

### PROBLEM SETUP

(canary from previous task is faulty)

### TASK

* Remove canary from traffic immediately
* Stable version must continue serving traffic

### SUCCESS CRITERIA

* Traffic uninterrupted
* Only stable pods receive traffic

---

# 🧪 TASK 7 — PAUSED ROLLOUT INCIDENT

### PROBLEM SETUP

```bash
kubectl rollout pause deployment web-app
kubectl set image deployment/web-app nginx=nginx:1.26
```

### TASK

* Identify why rollout is stuck
* Complete the deployment

### SUCCESS CRITERIA

* New image fully deployed
* Deployment not paused

---

# 🧪 TASK 8 — NODEPORT ACCESS FAILURE

### PROBLEM SETUP

```bash
kubectl patch svc web-svc -p '
{
  "spec": {
    "type": "NodePort"
  }
}'
```

Traffic still unreachable.

### TASK

* Make application reachable from browser
* Do NOT recreate Service or Deployment

### SUCCESS CRITERIA

* Browser access works
* NodePort correctly assigned

---

# 🧪 TASK 9 — SCALING INCIDENT

### PROBLEM SETUP

```bash
kubectl scale deployment web-app --replicas=0
```

### TASK

* Restore service availability
* Do NOT recreate pods manually

### SUCCESS CRITERIA

* Pods running
* Traffic restored

---

# 🧪 TASK 10 — FINAL CLEANUP

### TASK

* Remove **all** resources created in this lab
* Namespace must be empty

### SUCCESS CRITERIA

```bash
kubectl get all
```

→ No resources found


