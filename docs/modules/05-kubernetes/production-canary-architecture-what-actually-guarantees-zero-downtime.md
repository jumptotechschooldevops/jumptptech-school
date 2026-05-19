---
title: "Production Canary Architecture (what actually guarantees zero downtime)"
description: "Client   ↓ Ingress (NGINX / ALB)   ↓ Service   ↓ Pods    ├─ Stable (v1) 90%    └─ Canary..."
published: 2026-01-07
source: "https://dev.to/jumptotech/production-canary-architecture-what-actually-guarantees-zero-downtime-37bk"
tags: []
---

# Production Canary Architecture (what actually guarantees zero downtime)



![Image](https://earthly.dev/blog/assets/images/canary-deployment-in-k8s/laz6hB1.png)

![Image](https://gateway-api.sigs.k8s.io/images/simple-split.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2A--e02oOXmbnKbpsA2mjU_w.png)

![Image](https://andrewlock.net/content/images/2020/k8s_probes.png)

```
Client
  ↓
Ingress (NGINX / ALB)
  ↓
Service
  ↓
Pods
   ├─ Stable (v1) 90%
   └─ Canary (v2) 10%
```

**Zero downtime comes from 4 protections working together:**

1. Readiness probe
2. Rolling pod startup
3. Traffic splitting at ingress
4. Fast rollback

---

# COMPONENTS (Production Required)

| Component                    | Why                    |
| ---------------------------- | ---------------------- |
| Deployment (stable + canary) | Parallel versions      |
| Readiness probe              | Prevents early traffic |
| Service                      | Stable endpoint        |
| Ingress (NGINX / ALB)        | Traffic split          |
| Canary weight                | Controlled exposure    |
| Fast rollback                | Safety net             |

---

## 1️⃣ STABLE Deployment (v1)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: web
      track: stable
  template:
    metadata:
      labels:
        app: web
        track: stable
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=STABLE v1"
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 2
```

Why this is production-safe:

* Old pods stay serving traffic
* New pods join only when ready

---

## 2️⃣ CANARY Deployment (v2)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
      track: canary
  template:
    metadata:
      labels:
        app: web
        track: canary
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=CANARY v2"
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 2
```

Key:

* Canary pods exist
* But **traffic is NOT automatic**

---

## 3️⃣ SERVICES (split by label)

### Stable Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-stable
spec:
  selector:
    app: web
    track: stable
  ports:
  - port: 80
    targetPort: 8080
```

### Canary Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-canary
spec:
  selector:
    app: web
    track: canary
  ports:
  - port: 80
    targetPort: 8080
```

---

## 4️⃣ INGRESS WITH TRAFFIC SPLITTING (PRODUCTION CORE)

### NGINX Ingress Canary (10%)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-stable
spec:
  rules:
  - host: web.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-stable
            port:
              number: 80
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: web.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-canary
            port:
              number: 80
```

Result:

* 90% → stable
* 10% → canary
* **No restart**
* **No downtime**

---

## 5️⃣ LIVE TRAFFIC VERIFICATION

```bash
while true; do
  curl -s http://web.local
  sleep 0.3
done
```

Expected:

```
STABLE v1
STABLE v1
CANARY v2
STABLE v1
```

---

## 6️⃣ METRICS & OBSERVATION (DevOps responsibility)

You monitor:

* Error rate
* Latency
* Logs

```bash
kubectl logs -l track=canary
kubectl get pods
```

If metrics are clean → promote.

---

## 7️⃣ PROMOTION (ZERO DOWNTIME)

Increase canary traffic:

```yaml
nginx.ingress.kubernetes.io/canary-weight: "50"
```

Then:

```yaml
nginx.ingress.kubernetes.io/canary-weight: "100"
```

Finally:

* Scale stable down
* Rename canary → stable

```bash
kubectl scale deploy app-stable --replicas=0
kubectl scale deploy app-canary --replicas=6
```

---

## 8️⃣ ROLLBACK (INSTANT, ZERO DOWNTIME)

One command:

```bash
kubectl delete ingress web-canary
```

Traffic instantly:

* 100% → stable
* Canary pods still exist (for debugging)

This is **why canary is safer than rolling**.

---

## Why this is 100% no downtime

| Protection      | Result             |
| --------------- | ------------------ |
| Readiness probe | No early traffic   |
| Parallel pods   | No replacement gap |
| Ingress split   | Gradual exposure   |
| Fast rollback   | Instant recovery   |

---

## What REAL companies add on top

Production teams usually add:

* Prometheus + alerts
* Auto-promotion
* Error budget checks
* Argo Rollouts

But **this design already meets production SRE standards**.

---

## Final DevOps rule (remember this)

> Rolling update replaces pods.
> Canary **protects users**.


