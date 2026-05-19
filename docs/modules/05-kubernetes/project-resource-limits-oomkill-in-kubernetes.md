---
title: "Project: Resource Limits & OOMKill in Kubernetes"
description: "Architecture      User → Pod (stress container)         ├─ CPU stress         └─ Memory..."
published: 2026-01-21
source: "https://dev.to/jumptotech/project-resource-limits-oomkill-in-kubernetes-31kg"
tags: []
---

# Project: Resource Limits & OOMKill in Kubernetes




## Architecture

```
User → Pod (stress container)
        ├─ CPU stress
        └─ Memory stress
```

---

## 1️⃣ Create Namespace

```bash
kubectl create namespace limits-lab
```

---

## 2️⃣ Deployment with STRICT Limits

### file: `stress-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress-app
  namespace: limits-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      - name: stress
        image: polinux/stress
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        command:
        - /bin/sh
        - -c
        - |
          echo "Starting stress..."
          stress --vm 1 --vm-bytes 200M --cpu 2 --timeout 300
```

Apply it:

```bash
kubectl apply -f stress-deployment.yaml
```

---

## 3️⃣ Observe Pod Behavior

```bash
kubectl get pods -n limits-lab -w
```

### Expected result

```
STATUS: OOMKilled → Restarting
```

---

## 4️⃣ Explain What Happened (IMPORTANT)

### Memory

* Limit = **128Mi**
* App tried to allocate **200Mi**
* Linux kernel kills container
* Kubernetes restarts pod

```bash
kubectl describe pod <pod-name> -n limits-lab
```

You will see:

```
Reason: OOMKilled
Exit Code: 137
```

---

## 5️⃣ CPU Throttling (No Restart)

Update deployment:

```yaml
stress --cpu 2 --timeout 300
```

Then watch:

```bash
kubectl top pod -n limits-lab
```

### Key learning

* CPU limit **does NOT kill pod**
* Kernel throttles CPU via **CFS**
* App becomes slow but stays Running

---

## 6️⃣ Remove Memory Limit (Compare)

Change:

```yaml
limits:
  cpu: "200m"
```

(no memory limit)

### Result

* Pod does **NOT** get OOMKilled
* Can consume large memory
* Node risk increases

---

## 7️⃣ Interview-Ready Explanation

### Requests

* Used by **scheduler**
* Guarantees minimum resources
* Pod may run without them

### Limits

* Enforced by **kernel**
* Memory limit → OOMKill
* CPU limit → Throttling

---

## 8️⃣ Production Scenario (SRE Question)

**Q:** Pod restarts randomly, no app logs
**A:**

* Check `kubectl describe pod`
* Look for `OOMKilled`
* Compare memory usage vs limit
* Increase limit or fix memory leak

---

## 9️⃣ Bonus: HPA Interaction

Why HPA fails sometimes:

* HPA scales on **requests**
* Low CPU request + high usage = aggressive scaling

---

## 10️⃣ Cleanup

```bash
kubectl delete namespace limits-lab
```

---

## Final Summary (Say This in Interviews)

> “Kubernetes requests affect scheduling, limits affect runtime.
> Memory limit violations cause OOMKills and restarts,
> CPU limits cause throttling without restarts.
> I debug resource issues using describe, events, and metrics.”


