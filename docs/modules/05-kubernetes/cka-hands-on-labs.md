---
title: "CKA HANDS-ON LABS"
description: "📘   Topic Coverage:   Startup / Readiness / Liveness Probes ConfigMaps Secrets Configuration..."
published: 2026-01-09
source: "https://dev.to/jumptotech/cka-hands-on-labs-152m"
tags: []
---

# CKA HANDS-ON LABS


# 📘 
**Topic Coverage:**

* Startup / Readiness / Liveness Probes
* ConfigMaps
* Secrets
* Configuration mistakes & fixes

**Environment:**

* Minikube
* kubectl
* Local machine (Mac / Linux / Windows)

---

## LAB 0 — Environment Check (MANDATORY)

```bash
minikube start
kubectl get nodes
```

Expected:

```
STATUS: Ready
```

---

# 🧪 LAB 1 — STARTUP PROBE (CrashLoopBackOff ISSUE)

## 🎯 Goal

Understand why **slow apps restart endlessly** and how startup probe fixes it.

---

## Step 1 — Deploy a slow application (BROKEN)

```yaml
# lab1-broken.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slow-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: slow
  template:
    metadata:
      labels:
        app: slow
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sh", "-c"]
        args:
          - sleep 30; echo STARTED; sleep 3600
        livenessProbe:
          exec:
            command: ["sh", "-c", "echo ok"]
          initialDelaySeconds: 5
          periodSeconds: 5
```

Apply:

```bash
kubectl apply -f lab1-broken.yaml
kubectl get pods
```

---

## ❌ What breaks

* Pod enters **CrashLoopBackOff**
* Liveness probe runs **before app finishes startup**

Check:

```bash
kubectl describe pod
```

---

## Step 2 — FIX using startup probe

```yaml
# lab1-fixed.yaml
startupProbe:
  exec:
    command: ["sh", "-c", "echo ok"]
  failureThreshold: 40
  periodSeconds: 1
```

Add this under the container spec.

Apply:

```bash
kubectl apply -f lab1-fixed.yaml
kubectl get pods
```

---

## ✅ Expected Result

* Pod starts successfully
* No restarts

---

## 💡 CKA LESSON

* Startup probe **blocks liveness**
* Mandatory for slow apps (Java, DB, migrations)

---

# 🧪 LAB 2 — READINESS PROBE (TRAFFIC ISSUE)

## 🎯 Goal

Stop traffic to unhealthy pods **without restarting them**

---

## Step 1 — Deploy app WITHOUT readiness

```yaml
# lab2-broken.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ready-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ready
  template:
    metadata:
      labels:
        app: ready
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=HELLO"
        ports:
        - containerPort: 8080
```

Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ready-svc
spec:
  selector:
    app: ready
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f lab2-broken.yaml
kubectl apply -f service.yaml
```

---

## ❌ What breaks

* Pod always receives traffic
* No way to stop traffic during issues

Check:

```bash
kubectl get endpoints ready-svc
```

---

## Step 2 — FIX using readiness probe

```yaml
readinessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 3
```

Apply fix.

---

## ✅ Expected Result

* When readiness fails → pod removed from endpoints
* Pod still Running

---

## 💡 CKA LESSON

* Readiness controls **traffic**
* Required for zero downtime

---

# 🧪 LAB 3 — LIVENESS PROBE (HUNG APP)

## 🎯 Goal

Restart stuck containers automatically

---

## Step 1 — Deploy app WITHOUT liveness

```yaml
# lab3-broken.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hang-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hang
  template:
    metadata:
      labels:
        app: hang
    spec:
      containers:
      - name: app
        image: nginx
```

Apply:

```bash
kubectl apply -f lab3-broken.yaml
```

---

## ❌ Simulate hang

```bash
kubectl exec -it pod-name -- kill 1
kubectl get pods
```

Result:

* Pod stays **Running**
* App is dead

---

## Step 2 — FIX using liveness probe

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 10
  periodSeconds: 5
```

Apply fix.

---

## ✅ Expected Result

* Pod restarts automatically

---

## 💡 CKA LESSON

* Liveness = self-healing
* Without it, Kubernetes does nothing

---

# 🧪 LAB 4 — CONFIGMAP (CONFIG NOT APPLIED ISSUE)

## 🎯 Goal

Understand why config changes don’t apply automatically

---

## Step 1 — Create ConfigMap

```bash
kubectl create configmap app-config \
  --from-literal=APP_COLOR=blue
```

---

## Step 2 — Inject via env (BROKEN EXPECTATION)

```yaml
env:
- name: APP_COLOR
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_COLOR
```

Apply deployment.

---

## ❌ What breaks

```bash
kubectl edit configmap app-config
```

Change value → app does NOT change.

---

## Step 3 — FIX

```bash
kubectl rollout restart deployment app
```

---

## 💡 CKA LESSON

* Env vars are immutable
* Restart required

---

# 🧪 LAB 5 — CONFIGMAP AS FILE (RELOAD CONFUSION)

## 🎯 Goal

Understand mounted config behavior

---

## Step 1 — Mount ConfigMap

```yaml
volumes:
- name: config
  configMap:
    name: app-config

volumeMounts:
- name: config
  mountPath: /etc/config
```

---

## Step 2 — Update ConfigMap

```bash
kubectl edit configmap app-config
```

---

## ❌ Observation

* File updates
* App behavior does NOT change

---

## 💡 CKA LESSON

* Kubernetes updates file
* App must reload manually

---

# 🧪 LAB 6 — SECRETS (SECURITY TRAP)

## 🎯 Goal

Handle secrets correctly

---

## Step 1 — Create Secret

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_PASS=secret123
```

---

## Step 2 — Inject as env

```yaml
env:
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: DB_PASS
```

---

## ❌ Common mistake

```bash
kubectl describe pod
```

Secrets visible in plain text.

---

## 💡 CKA LESSON

* Secrets are base64
* RBAC is mandatory
* Never commit secrets

---

# ✅ FINAL CHECKLIST 

✔ Startup vs readiness vs liveness
✔ ConfigMap injection methods
✔ Why config updates fail
✔ Secret handling risks
✔ Rollout restarts
✔ Debug using `describe`, `logs`, `exec`


