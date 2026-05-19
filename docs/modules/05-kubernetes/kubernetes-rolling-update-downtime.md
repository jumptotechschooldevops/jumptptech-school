---
title: "Kubernetes Rolling Update & Downtime"
description: "Key Kubernetes Truth   Kubernetes does NOT guarantee zero downtime by default.  Zero..."
published: 2026-01-06
source: "https://dev.to/jumptotech/kubernetes-rolling-update-downtime-319e"
tags: []
---

# Kubernetes Rolling Update & Downtime










### Key Kubernetes Truth

Kubernetes does **NOT** guarantee zero downtime by default.

Zero downtime requires:

* More than one replica
* Correct deployment strategy
* Correct **readinessProbe**

Without readinessProbe:

* Kubernetes **guesses** when a pod is ready
* Guessing can be wrong
* Traffic can hit nothing → downtime

---

## 2. Architecture We Will Build

```
User Traffic
    |
 Service (NodePort / Port-Forward)
    |
 Deployment (RollingUpdate)
    |
 Pods (http-echo)
```

---

## 3. Tooling Requirements

* macOS
* Docker
* Minikube
* kubectl

Verify:

```bash
kubectl version --client
minikube status
```

---

## 4. Demo #1 — NO readinessProbe

### Goal

Get a baseline working app before breaking anything.

---

### 4.1 Create Deployment (Version 1)

Create file: **`rolling-no-readiness.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: rolling
  template:
    metadata:
      labels:
        app: rolling
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - -listen=:8080
          - -text=ROLLING v1
        ports:
          - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: rolling-svc
spec:
  selector:
    app: rolling
  ports:
    - port: 80
      targetPort: 8080
  type: NodePort
```

Apply:

```bash
kubectl apply -f rolling-no-readiness.yaml
```

Verify:

```bash
kubectl get pods
```

---

## 5. Traffic Monitoring (This Is Critical)

### Why browser is NOT enough

Browsers:

* Cache
* Refresh slowly
* Hide failures

DevOps uses **continuous traffic**.

---

### 5.1 Start Port Forward (Fixed URL)

Terminal 1:

```bash
kubectl port-forward svc/rolling-svc 8080:80
```

Browser:

```
http://localhost:8080
```

You should see:

```
ROLLING v1
```

---

### 5.2 Start Traffic Loop (Terminal 2)

```bash
while true; do
  curl -s http://localhost:8080 || echo DOWN
  sleep 0.3
done
```

Output:

```
ROLLING v1
ROLLING v1
```

---

## 6. Demo #2 — Rolling Update WITHOUT readinessProbe (BREAK IT)

### Goal

Show **real downtime** during rolling update.

---

### 6.1 Trigger Version Change

Edit **same file**:

```yaml
-text=ROLLING v2
```

Apply:

```bash
kubectl apply -f rolling-no-readiness.yaml
```

---

### 6.2 What you MUST See

Traffic terminal:

```
ROLLING v1
ROLLING v1
DOWN
DOWN
ROLLING v2
ROLLING v2
```

Port-forward terminal:

```
error: lost connection to pod
```

Browser:

```
Safari can't connect to the server
```

---

## 7. WHY Downtime Happened 


> Kubernetes assumed the new pod was ready immediately.
> The old pod was terminated.
> The new pod was not ready yet.
> The Service had **zero endpoints**.
> Traffic had nowhere to go.

This is **expected behavior** without readinessProbe.

---

## 8. Mistakes 

### Mistake 1 — Re-applying same YAML

```bash
deployment unchanged
```

➡ No rollout happens.

### Mistake 2 — Changing annotations only

➡ Rollout happens, app behavior does NOT change.

### Mistake 3 — Wrong YAML structure

```
unknown field "containers"
```

➡ containers must be under `spec.template.spec`.

### Mistake 4 — Wrong readinessProbe

➡ Misconfigured probe causes **total outage**.

---

## 9. Demo #3 — FIX Downtime with readinessProbe

### Goal

Same rollout, **NO downtime**.

---

### 9.1 Create Correct File

Create **`rolling-with-readiness.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: rolling
  template:
    metadata:
      labels:
        app: rolling
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - -listen=:8080
          - -text=ROLLING v3
        ports:
          - containerPort: 8080
        readinessProbe:
          tcpSocket:
            port: 8080
          initialDelaySeconds: 2
          periodSeconds: 1
---
apiVersion: v1
kind: Service
metadata:
  name: rolling-svc
spec:
  selector:
    app: rolling
  ports:
    - port: 80
      targetPort: 8080
  type: NodePort
```

Apply:

```bash
kubectl apply -f rolling-with-readiness.yaml
```

---

### 9.2 

Traffic terminal:

```
ROLLING v2
ROLLING v2
ROLLING v3
ROLLING v3
```

🚫 No DOWN
🚫 No connection loss
✅ Zero downtime

---


> The readiness probe tells Kubernetes when the pod is actually ready.
> Kubernetes keeps the old pod alive until the new pod passes readiness.
> Traffic is never routed to an unready pod.

---

## 11. Readiness vs Liveness (Short Explanation)

| Probe          | Purpose                            |
| -------------- | ---------------------------------- |
| readinessProbe | Controls traffic                   |
| livenessProbe  | Restarts broken containers         |
| startupProbe   | Delays other probes during startup |

---

## 12. Interview-Ready Summary 

> RollingUpdate does not guarantee zero downtime.
> Zero downtime requires readinessProbe.
> A wrong readinessProbe is worse than no readinessProbe.


