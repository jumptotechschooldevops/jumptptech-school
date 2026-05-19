---
title: "Project: One App — Three Probes — Real Failures"
description: "Visual mental model (keep this in mind first)         Traffic rule (critical):   ❌ Startup..."
published: 2026-01-09
source: "https://dev.to/jumptotech/project-one-app-three-probes-real-failures-5fgo"
tags: []
---

# Project: One App — Three Probes — Real Failures



## Visual mental model (keep this in mind first)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240516152819/K8s-probes.webp)

![Image](https://cdn-images-1.medium.com/max/1500/1%2AWDJmiyarVfcsDp6X1-lLFQ.png)

![Image](https://andrewlock.net/content/images/2020/k8s_probes.png)

**Traffic rule (critical):**

* ❌ Startup probe FAIL → container is NOT checked by liveness/readiness
* ❌ Readiness probe FAIL → pod gets **NO traffic**
* ❌ Liveness probe FAIL → pod is **RESTARTED**

---

# 

## What you will demonstrate

You will run **one app** that:

* Starts **slowly** (startup probe needed)
* Can become **temporarily unavailable** (readiness probe needed)
* Can become **stuck** (liveness probe needed)

This mirrors **real production behavior**.

---

## Step 0 — Prerequisites

```bash
minikube start
kubectl get nodes
```

---

## Step 1 — Demo application (intentionally imperfect)

We’ll use a small HTTP app that:

* Takes **20 seconds** to start
* Has `/ready` and `/health` endpoints

### `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe-demo
  template:
    metadata:
      labels:
        app: probe-demo
    spec:
      containers:
      - name: app
        image: ghcr.io/stefanprodan/podinfo:6.5.3
        ports:
        - containerPort: 9898
```

Apply:

```bash
kubectl apply -f deployment.yaml
kubectl get pods
```

At this point:

* App starts slowly
* Kubernetes **does not know**
* Traffic could hit it too early

---

## Step 2 — Expose the app

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-demo-svc
spec:
  selector:
    app: probe-demo
  ports:
  - port: 80
    targetPort: 9898
  type: NodePort
```

```bash
kubectl apply -f service.yaml
minikube service probe-demo-svc
```

---

# Now the REAL learning starts

---

## STARTUP PROBE

### What it is

> “Don’t judge this container until it has fully started.”

### Why DevOps needs it

Without startup probe:

* Liveness probe may **restart slow apps endlessly**
* JVM, Python, DB-connected apps suffer most

### Add startup probe

```yaml
startupProbe:
  httpGet:
    path: /health
    port: 9898
  failureThreshold: 30
  periodSeconds: 1
```

Meaning:

* Kubernetes waits **30 seconds**
* Liveness & readiness are **disabled** until startup succeeds

### Demonstrate failure (remove it)

```bash
kubectl delete pod -l app=probe-demo
kubectl describe pod
```

What you’ll see:

* Pod restarts before finishing startup
* Classic **CrashLoopBackOff for slow apps**

---

## READINESS PROBE

### What it is

> “Can this pod receive traffic RIGHT NOW?”

### Why DevOps cares

* Prevents traffic during deploys
* Prevents broken pods from serving users
* Required for zero-downtime rolling updates

### Add readiness probe

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 9898
  initialDelaySeconds: 5
  periodSeconds: 3
```

### Observe

```bash
kubectl get pods
kubectl describe pod
kubectl get endpoints probe-demo-svc
```

When readiness fails:

* Pod stays **Running**
* But is **removed from Service endpoints**
* No traffic sent

### Demonstrate issue if missing

Remove readiness probe → deploy new version:

* Traffic hits half-started pods
* Users see 502 / empty responses

---

## LIVENESS PROBE

### What it is

> “Is this container still healthy or stuck?”

### Why DevOps needs it

* Apps can hang forever
* Memory leaks
* Deadlocks
* Kubernetes must restart them automatically

### Add liveness probe

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 9898
  initialDelaySeconds: 20
  periodSeconds: 5
```

### Demonstrate restart

Simulate failure:

```bash
kubectl exec -it pod-name -- kill 1
```

Observe:

```bash
kubectl get pods
```

You will see:

* Pod restarted automatically
* No manual intervention

### Without liveness probe

* Pod stays Running
* App is dead
* Kubernetes does NOTHING

---

## Final combined (production-correct)

```yaml
startupProbe:
  httpGet:
    path: /health
    port: 9898
  failureThreshold: 30
  periodSeconds: 1

readinessProbe:
  httpGet:
    path: /ready
    port: 9898
  periodSeconds: 3

livenessProbe:
  httpGet:
    path: /health
    port: 9898
  initialDelaySeconds: 20
  periodSeconds: 5
```

---

# DevOps engineer checklist (this is interview-level)

You MUST know:

* Startup → protects slow boot apps
* Readiness → controls traffic
* Liveness → auto-recovery
* Readiness ≠ Liveness (most common mistake)
* Missing readiness = downtime
* Missing liveness = silent failure
* Wrong startup = endless restarts

---

## How to explain this in production terms

> “Startup protects initialization, readiness protects users, liveness protects the platform.”


