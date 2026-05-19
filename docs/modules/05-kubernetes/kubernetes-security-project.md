---
title: "🔐 Kubernetes Security Project"
description: "RBAC + ServiceAccounts + NetworkPolicy (End-to-End)            🎯 Goal   Understand who can..."
published: 2026-01-21
source: "https://dev.to/jumptotech/kubernetes-security-project-31n7"
tags: []
---

# 🔐 Kubernetes Security Project





## RBAC + ServiceAccounts + NetworkPolicy (End-to-End)

### 🎯 Goal

Understand **who can do what** and **who can talk to whom** inside Kubernetes.

You will:

* Lock down API access using **RBAC**
* Restrict pod-to-pod traffic using **NetworkPolicy**
* See real failures (403, connection refused)
* Learn how **security incidents are prevented**

---

## Architecture

```
User
 ├─ kubectl (admin)
 │
 ├─ Pod A (frontend)
 │      ↓ allowed
 ├─ Pod B (backend)
 │      ↓ blocked
 └─ Pod C (db)
```

---

## 1️⃣ Create Namespace

```bash
kubectl create namespace secure-lab
```

---

## 2️⃣ Create ServiceAccount (Non-Admin)

```yaml
# sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: secure-lab
```

```bash
kubectl apply -f sa.yaml
```

---

## 3️⃣ Create Restricted Role (RBAC)

❌ No delete
❌ No secrets
✅ Only read pods & services

```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secure-lab
  name: read-only-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
```

---

## 4️⃣ Bind Role to ServiceAccount

```yaml
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-only-binding
  namespace: secure-lab
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: secure-lab
roleRef:
  kind: Role
  name: read-only-role
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f rolebinding.yaml
```

---

## 5️⃣ Test RBAC FROM INSIDE A POD

```bash
kubectl run test-pod \
  -n secure-lab \
  --image=bitnami/kubectl \
  --serviceaccount=app-sa \
  --restart=Never \
  --rm -it -- sh
```

Inside pod:

```bash
kubectl get pods      # ✅ allowed
kubectl delete pod x  # ❌ forbidden
kubectl get secrets   # ❌ forbidden
```

### Expected error

```
Error from server (Forbidden)
```

---

## 6️⃣ Deploy 3-Tier App

### Frontend

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: secure-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
```

---

### Backend

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: secure-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text=backend"]
```

---

### Database

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  namespace: secure-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text=db"]
```

---

## 7️⃣ Test Networking (NO NetworkPolicy Yet)

```bash
kubectl run curl \
  -n secure-lab \
  --image=curlimages/curl \
  --rm -it -- sh
```

```bash
curl backend
curl db
```

✅ Everything works (DEFAULT = allow all)

---

## 8️⃣ Apply NetworkPolicy (DENY ALL)

```yaml
# deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: secure-lab
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

```bash
kubectl apply -f deny-all.yaml
```

---

## 9️⃣ Allow ONLY frontend → backend

```yaml
# allow-frontend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: secure-lab
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

---

## 🔟 Test Again

```bash
curl backend   # ✅ works
curl db        # ❌ blocked
```

---

## 1️⃣1️⃣ What You Just Learned (INTERVIEW GOLD)

### RBAC

* Controls **API access**
* Based on **ServiceAccount**
* Prevents cluster takeover

### NetworkPolicy

* Controls **pod-to-pod traffic**
* Default allow → must deny explicitly
* Requires CNI support

---

## 🚨 Real Production Incident You Now Understand

> “A compromised pod could not access secrets or other services because RBAC and NetworkPolicy limited blast radius.”

---

## FINAL INTERVIEW ANSWER (MEMORIZE)

> “RBAC controls who can talk to the Kubernetes API.
> NetworkPolicies control who can talk on the network.
> Together they enforce least privilege and zero trust inside the cluster.”

---

## Cleanup

```bash
kubectl delete namespace secure-lab
```


