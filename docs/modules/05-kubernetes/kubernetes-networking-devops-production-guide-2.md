---
title: "Kubernetes Networking — Broken Labs & Incident Response"
description: "How to Think Like DevOps in Production   When traffic fails, never guess. Always follow this..."
published: 2026-01-09
source: "https://dev.to/jumptotech/kubernetes-networking-devops-production-guide-44k6"
devto_id: 3161561
---

# Kubernetes Networking — Broken Labs & Incident Response






## How to Think Like DevOps in Production

When traffic fails, **never guess**.
Always follow this order:

```
Ingress
↓
Service
↓
Endpoints
↓
Pod
↓
Container
```

If one layer fails, **everything above it fails**.

---

## LAB 1 — ClusterIP Service (Most Common Production Failure)

![Image](https://zesty.co/wp-content/uploads/2025/02/clusterIP.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AkAMuf7ryG81KEFWzQFwVDw.gif)

### Scenario

* Pods are **Running**
* Service exists
* Browser / curl returns **nothing**

---

### Broken Setup

**Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api-v1   # ❌ wrong label
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=API OK"
        ports:
        - containerPort: 8080
```

**Service**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-svc
spec:
  selector:
    app: api   # ❌ mismatch
  ports:
  - port: 80
    targetPort: 8080
```

---

### Symptoms

```bash
kubectl get pods
kubectl get svc
kubectl get endpoints api-svc
```

Output:

```
ENDPOINTS: <none>
```

---

### Root Cause

Service selector does not match Pod labels.

---

### Fix

```bash
kubectl edit deployment api
```

Change:

```yaml
labels:
  app: api
```

Verify:

```bash
kubectl get endpoints api-svc
```

---

### DevOps Interview Answer

**Q:** Service exists but no traffic, pods running. What do you check?
**A:** Endpoints. Empty endpoints indicate selector or readiness issues.

---

### When to Use ClusterIP

* Internal APIs
* Backend services
* Microservices

---

### Pros / Cons

**Pros**

* Secure
* Stable
* Scales

**Cons**

* Internal only

---

## LAB 2 — NodePort (Why It’s Dangerous)

![Image](https://zesty.co/wp-content/uploads/2025/02/nodeport.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2ACdyUtG-8CfGu2oFC5s0KwA.png)

### Scenario

* NodePort exposed
* Works sometimes
* Fails after node change

---

### Setup

```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-svc
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

---

### Symptoms

* Works on one node IP
* Fails on another
* Security team flags open ports

---

### Root Cause

* Port open on **all nodes**
* No routing control
* Node IP dependency

---

### DevOps Fix

* Replace NodePort with:

  * ClusterIP + Ingress
  * or LoadBalancer

---

### Interview Answer

**Q:** Why is NodePort rarely used in production?
**A:** It exposes every node, lacks security, routing, and doesn’t scale.

---

### When NodePort Is Acceptable

* Debugging
* Temporary access
* Learning environments

---

## LAB 3 — LoadBalancer Service (Cloud Reality)

![Image](https://www.densify.com/wp-content/uploads/article-k8s-capacity-kubernetes-service-overview.svg)

![Image](https://www.apptio.com/wp-content/uploads/overview-load-balancer-in-multi-cloud.png)

### Scenario

* External IP created
* App unreachable

---

### Setup

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lb-svc
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
```

---

### Symptoms

```bash
kubectl get svc
```

* External IP exists
* Browser timeout

---

### Troubleshooting

```bash
kubectl describe svc lb-svc
kubectl get endpoints lb-svc
```

Check cloud:

* Health checks
* Security groups
* Target port mismatch

---

### Root Cause

Cloud LB health check fails because:

* Wrong port
* App not listening
* Readiness probe failing

---

### DevOps Fix

* Align ports
* Add readiness probe
* Validate security groups

---

### Interview Answer

**Q:** Why not use LoadBalancer for every service?
**A:** Cost, lack of routing, and limited flexibility compared to Ingress.

---

## LAB 4 — Ingress (Most Interviewed Topic)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240506105314/Kubernetes-Ingress-Architecture-%281%29.webp)

![Image](https://devopscube.com/content/images/2025/03/image-3-57.png)

### Scenario

* Ingress created
* 404 error returned

---

### Broken Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: wrong-svc   # ❌ wrong name
            port:
              number: 80
```

---

### Symptoms

* Ingress IP works
* Always returns 404

---

### Troubleshooting

```bash
kubectl describe ingress
kubectl get svc
kubectl get pods -n ingress-nginx
```

---

### Root Cause

Ingress routes to non-existent service.

---

### Fix

Correct backend service name.

---

### Interview Answer

**Q:** Ingress returns 404, where do you check first?
**A:** Ingress rules, service name, service port, and controller logs.

---

## LAB 5 — DNS Failure (Hidden Killer)

![Image](https://picluster.ricsanfre.com/assets/img/core-dns-architecture.png)

![Image](https://coredns.io/images/query-processing.png)

### Scenario

* Services exist
* DNS name fails

---

### Test

```bash
kubectl run test --rm -it --image=busybox -- sh
nslookup api-svc
```

---

### Root Cause

* CoreDNS not running
* Wrong namespace
* Service deleted

---

### Fix

```bash
kubectl get pods -n kube-system | grep dns
```

Restart if needed.

---

### Interview Answer

**Q:** How do Pods discover services?
**A:** Via Kubernetes DNS resolving Service names to ClusterIP.

---

## INCIDENT RESPONSE PLAYBOOK (Real DevOps)

### Step-by-Step

1. Check Ingress
2. Check Service
3. Check Endpoints
4. Check Pod readiness
5. Check container logs

Never skip steps.

---

## FINAL DECISION MATRIX (Very Important)

| Requirement                 | Use          |
| --------------------------- | ------------ |
| Internal traffic            | ClusterIP    |
| External production traffic | Ingress      |
| Cloud simple exposure       | LoadBalancer |
| Debug only                  | NodePort     |

---

## INTERVIEW RAPID FIRE (Must Memorize)

**Q:** Empty endpoints means?
**A:** Selector or readiness failure

**Q:** Most used service in prod?
**A:** ClusterIP

**Q:** Why Ingress?
**A:** Routing, TLS, cost efficiency

**Q:** NodePort in prod?
**A:** Avoid

---

## REAL DEVOPS TRUTH

Networking issues are:

* Predictable
* Layered
* Always observable

The difference between struggling and solving fast is **methodical thinking**.


