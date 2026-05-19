---
title: "Kubernetes Services & Networking, probes"
description: "Kubernetes Probes — Liveness &amp; Startup            1. Why probes exist (the real..."
published: 2026-01-09
source: "https://dev.to/jumptotech/kubernetes-services-networking-1apj"
tags: []
---

# Kubernetes Services & Networking, probes




# Kubernetes Probes — Liveness & Startup



## 1. Why probes exist (the real problem)

Containers **do not fail cleanly**.

Things that happen in production:

* App process is running, **but logic is dead**
* App is stuck in **deadlock**
* JVM / Python app **needs 30–120s to start**
* App boots but **cannot accept traffic yet**
* App consumes CPU but **does nothing**

Kubernetes **cannot guess this**.

So Kubernetes needs **signals from YOU**.

That is what probes are.

---

## 2. The 3 probe types (mental model first)

| Probe         | Who uses it         | Purpose                     |
| ------------- | ------------------- | --------------------------- |
| **Startup**   | kubelet             | “Is the app done starting?” |
| **Liveness**  | kubelet             | “Is the app stuck or dead?” |
| **Readiness** | Service / Endpoints | “Can traffic go here?”      |

This lesson focuses on **Startup + Liveness**, but you must understand how they interact with Readiness.

---

## 3. Startup Probe (the most misunderstood)

### What it REALLY means

> “**Do NOT touch this container until startup is complete**.”

If **startupProbe exists**:

* **Liveness is disabled**
* **Readiness is disabled**
* kubelet **waits patiently**

### Why startupProbe exists

Without it:

* Liveness starts too early
* Kubernetes kills the container **while it’s still booting**
* You get **CrashLoopBackOff**
* DevOps says: *“It works locally”*

---

### Correct use cases

You SHOULD add a **startup probe** when:

* Java / Spring Boot
* .NET Core
* Python app loading ML models
* App performs DB migrations
* App needs secrets, config, cache warm-up
* App startup > 10–15 seconds

---

### Startup probe lifecycle

![Image](https://miro.medium.com/v2/resize%3Afit%3A1170/1%2Aoqt8GlUYvm-OrO7gNBJjNQ.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AYN4BP2119epQbhYj.png)

![Image](https://miro.medium.com/1%2AkvU3t_01FqvojFO22BZsOg.png)

Flow:

1. Container starts
2. Startup probe runs repeatedly
3. Until **success**
4. THEN liveness + readiness begin

---

### Example (safe production default)

```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 5
```

What this means:

* Kubernetes allows **150 seconds** for startup
* No restarts during this time
* No traffic yet

---

## 4. Liveness Probe (dangerous if misused)

### What it REALLY means

> “If this fails → **KILL the container**.”

Not restart the app logic.
Not reload config.
**Hard kill.**

---

### When to use liveness

You SHOULD use liveness when:

* App can **deadlock**
* App can hang on memory leaks
* App stops processing requests
* You want **self-healing**

You SHOULD NOT use liveness when:

* App is slow but working
* Dependency outages are expected
* Startup time is unpredictable (unless startupProbe exists)

---

### Liveness lifecycle

![Image](https://andrewlock.net/content/images/2020/k8s_probes.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/0%2AqRgabQe-QS2mIW4l.jpg)

![Image](https://miro.medium.com/1%2AdWiqOo0cwzh0vCz3oyCOPQ.png)

Flow:

1. Probe fails N times
2. kubelet kills container
3. Container restarts
4. Pod stays the same

---

### Example (safe liveness)

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3
```

This gives:

* 30 seconds of failure tolerance
* Prevents flapping
* Allows brief GC pauses

---

## 5. Why startup + liveness must work together

### BAD (common mistake)

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

Result:

* App takes 45s to start
* Liveness starts at 10s
* Kubernetes kills it
* Infinite CrashLoopBackOff

---

### GOOD (production pattern)

```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  periodSeconds: 10
```

Why this works:

* Startup probe shields the app
* Liveness only checks **after startup**
* Clean separation of concerns

---

## 6. Probe types (how checks are done)

### HTTP probe (MOST COMMON)

```yaml
httpGet:
  path: /health
  port: 8080
```

Used when:

* Web apps
* APIs
* Microservices

---

### TCP probe

```yaml
tcpSocket:
  port: 5432
```

Used when:

* Databases
* Message brokers
* Non-HTTP services

---

### Exec probe (RARE, risky)

```yaml
exec:
  command:
    - cat
    - /tmp/healthy
```

Used when:

* Legacy apps
* No health endpoint
* You accept performance overhead

---

## 7. Debugging probes (REAL production workflow)

### Step 1 — See probe failures

```bash
kubectl describe pod <pod>
```

Look for:

```
Liveness probe failed
Startup probe failed
```

---

### Step 2 — Check restart pattern

```bash
kubectl get pod <pod>
```

Indicators:

* `RESTARTS` increasing → liveness issue
* `CrashLoopBackOff` → probe or startup issue

---

### Step 3 — Check timing mismatch

Ask:

* How long does app REALLY start?
* Are probes aggressive?
* Is failureThreshold too low?

---

### Step 4 — Test inside container

```bash
kubectl exec -it <pod> -- curl localhost:8080/health
```

If this fails → **probe is correct**
If this works → **probe config is wrong**

---

### Step 5 — Temporarily disable liveness

During debugging:

```bash
kubectl patch deployment app --type=json -p='[
  {"op":"remove","path":"/spec/template/spec/containers/0/livenessProbe"}
]'
```

Never leave it disabled permanently.

---

## 8. Common outage patterns (interview GOLD)

### Pattern 1 — Endless restarts

Cause:

* Liveness without startup
  Fix:
* Add startupProbe

---

### Pattern 2 — Traffic hits broken pods

Cause:

* Missing readiness (not probe topic, but related)
  Fix:
* Add readinessProbe

---

### Pattern 3 — Healthy pods killed during GC

Cause:

* Aggressive liveness
  Fix:
* Increase failureThreshold / periodSeconds

---

### Pattern 4 — App stuck but not restarted

Cause:

* No liveness probe
  Fix:
* Add liveness with safe timing

---

## 9. What a 6-year DevOps engineer MUST articulate

You must be able to say:

* Startup probe **disables liveness temporarily**
* Liveness **kills containers**, not pods
* Probes run on **kubelet**
* Probes are **not monitoring**
* Bad probes cause **more outages than no probes**
* Readiness controls traffic, not liveness
* Probes must match **real app behavior**

---

## 10. Interview-ready summary (memorize)

> “Startup probes protect slow-starting applications from being killed prematurely. Liveness probes provide self-healing for hung or deadlocked processes. In production, startup probes must exist before aggressive liveness probes, otherwise Kubernetes causes crash loops. Probes should reflect application behavior, not infrastructure health.”








## Architecture Overview (Mental Model)


![Image](https://i.sstatic.net/xY184.png)


**Traffic flow:**

```
Browser
  ↓
Ingress
  ↓
Service
  ↓
Pod
  ↓
Container
```

Everything in this material builds around this flow.

---

# MODULE 1 — Kubernetes Services & Networking

## Why Services Exist

Pods:

* Have dynamic IPs
* Can be recreated at any time
* Must never be accessed directly

A **Service** provides:

* Stable IP
* Load balancing
* Pod discovery

---

## Service Types

| Type         | Purpose            | Production Usage |
| ------------ | ------------------ | ---------------- |
| ClusterIP    | Internal access    | Most common      |
| NodePort     | Direct node access | Debug / learning |
| LoadBalancer | Cloud LB           | External traffic |

---

## Project 1 — Service Traffic Flow

### Step 1 — Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=SERVICE WORKS"
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f deployment.yaml
```

---

### Step 2 — ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f service.yaml
```

Verify:

```bash
kubectl get svc
kubectl get endpoints web-svc
```

---

### Step 3 — Access Inside Cluster

```bash
kubectl run tmp --rm -it --image=busybox -- sh
wget -qO- http://web-svc
```

---

### Key Concepts Learned

* Services select Pods using labels
* Endpoints show real traffic targets
* Service failure usually means selector mismatch

---

# MODULE 2 — Ingress (Real Production Entry)

![Image](https://docs.nginx.com/nic/ic-high-level.png)

![Image](https://tetrate.io/.netlify/images?h=549\&q=90\&url=_astro%2Fimage-1024x549.Dst0COpw.png\&w=1024)

Ingress provides:

* Single entry point
* Path-based routing
* Host-based routing
* SSL termination

---

## Project 2 — Ingress Routing

### Step 1 — Deploy Two Versions

**Stable Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stable
spec:
  replicas: 2
  selector:
    matchLabels:
      app: echo
      version: stable
  template:
    metadata:
      labels:
        app: echo
        version: stable
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=STABLE VERSION"
        ports:
        - containerPort: 8080
```

**Canary Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
      version: canary
  template:
    metadata:
      labels:
        app: echo
        version: canary
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo:0.2.3
        args:
          - "-listen=:8080"
          - "-text=CANARY VERSION"
        ports:
        - containerPort: 8080
```

---

### Step 2 — Services

```yaml
apiVersion: v1
kind: Service
metadata:
  name: stable-svc
spec:
  selector:
    app: echo
    version: stable
  ports:
  - port: 80
    targetPort: 8080
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: canary-svc
spec:
  selector:
    app: echo
    version: canary
  ports:
  - port: 80
    targetPort: 8080
```

---

### Step 3 — Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: stable-svc
            port:
              number: 80
      - path: /canary
        pathType: Prefix
        backend:
          service:
            name: canary-svc
            port:
              number: 80
```

---

### Test

```bash
curl http://<INGRESS-IP>/
curl http://<INGRESS-IP>/canary
```

---

# MODULE 3 — ConfigMaps & Secrets

## Why Configuration Is External

Images must:

* Be immutable
* Work in all environments

Configuration must:

* Change without rebuilding images
* Be environment-specific

---

## Project 3 — ConfigMap Injection

### Step 1 — ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  MESSAGE: "CONFIGMAP VALUE"
```

---

### Step 2 — Deployment Using ConfigMap

```yaml
containers:
- name: app
  image: hashicorp/http-echo:0.2.3
  args:
    - "-listen=:8080"
    - "-text=$(MESSAGE)"
  env:
  - name: MESSAGE
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: MESSAGE
```

---

### Update Config Live

```bash
kubectl edit configmap app-config
kubectl rollout restart deployment web
```

---

# MODULE 4 — Resource Management

![Image](https://media.licdn.com/dms/image/D5612AQHE2ObtjTAz7A/article-cover_image-shrink_720_1280/0/1719982339960?e=2147483647\&t=GmjmEghOXWJQNG6PNOm-LmRX0-whZ3REcox5KmfU3QY\&v=beta)

![Image](https://cdn.prod.website-files.com/633e9bad8f71dfa75ae4c9db/67213dad99ee2f024125d3ae_637f31c66d501d5e01687258_pods_%2523g1735_blog.png)

![Image](https://cdn.prod.website-files.com/626a25d633b1b99aa0e1afa7/66c3581c6807ab2dd826addc_What%20is%20Kubernetes%20CPU%20throttling_%20%281%29.svg)

---

## Requests vs Limits

| Setting  | Meaning         |
| -------- | --------------- |
| requests | Guaranteed      |
| limits   | Maximum allowed |

---

## Project 4 — OOM Kill Demo

```yaml
resources:
  requests:
    memory: "32Mi"
    cpu: "50m"
  limits:
    memory: "64Mi"
    cpu: "100m"
```

Observe:

```bash
kubectl describe pod
```

---

# MODULE 5 — Autoscaling (HPA)

---

## Project 5 — CPU-Based Scaling

### Step 1 — Enable Metrics

```bash
kubectl get apiservices | grep metrics
```

---

### Step 2 — HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

---

### Generate Load

```bash
while true; do wget -qO- http://web-svc; done
```

Watch:

```bash
kubectl get hpa
kubectl get pods
```

---

# MODULE 6 — Logs & Troubleshooting

---

## Debug Order

1. Pod status
2. Events
3. Logs
4. Resource usage
5. Service endpoints

---

## Commands

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## Incident Simulation

* Pod is Running
* Browser shows nothing
* Endpoint list is empty
* Fix selector

---

# MODULE 7 — Security Basics

---

## Minimal SecurityContext

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

---

## Image Best Practices

* Never use `latest`
* Use fixed versions
* Use trusted registries

---

# Final Integrated Project

**Production Application Includes:**

* Deployment with readiness probe
* ClusterIP Service
* Ingress routing
* ConfigMap
* Resource limits
* HPA
* Logs & events
* Secure container settings

This mirrors how Kubernetes is used in real companies.


