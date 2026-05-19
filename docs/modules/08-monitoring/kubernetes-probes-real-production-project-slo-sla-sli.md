---
title: "Kubernetes Probes — REAL Production Project. SLO, SLA, SLI"
description: "Mental Model         Kubernetes does NOT know your app logic. It only knows..."
published: 2026-01-11
source: "https://dev.to/jumptotech/kubernetes-probes-real-production-project-slo-sla-sli-57hj"
tags: []
---

# Kubernetes Probes — REAL Production Project. SLO, SLA, SLI





## Mental Model 

![Image](https://miro.medium.com/v2/resize%3Afit%3A1170/1%2Aoqt8GlUYvm-OrO7gNBJjNQ.png)

![Image](https://andrewlock.net/content/images/2020/k8s_probes.png)

![Image](https://k21academy.com/wp-content/uploads/2021/06/Container-Lifecycle-Time.png)

**Kubernetes does NOT know your app logic.**
It only knows **signals**.

| Probe          | Question Kubernetes asks               |
| -------------- | -------------------------------------- |
| startupProbe   | “Is the app done starting?”            |
| readinessProbe | “Should I send traffic?”               |
| livenessProbe  | “Is this app stuck and needs restart?” |

---

# PROJECT OVERVIEW

### App behavior 

* App takes **15 seconds to start**
* App has `/health`
* App can **freeze internally** (simulated bug)
* App sometimes accepts connections but **should NOT get traffic**

This mimics **real production issues**.

---

# PART 1 — Create the Demo App (Python)

### app.py

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
import time
import threading

READY = False
BROKEN = False

def startup():
    global READY
    time.sleep(15)   # simulate slow startup
    READY = True

def break_app():
    global BROKEN
    time.sleep(40)   # simulate runtime bug
    BROKEN = True

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            if READY:
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"OK")
            else:
                self.send_response(503)
                self.end_headers()
                self.wfile.write(b"NOT READY")
        else:
            if BROKEN:
                time.sleep(999)  # freeze
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"APP RESPONSE")

threading.Thread(target=startup).start()
threading.Thread(target=break_app).start()

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
```

---

### Dockerfile

```dockerfile
FROM python:3.11-slim
COPY app.py /app.py
CMD ["python", "/app.py"]
```

Build & push:

```bash
docker build -t <your-dockerhub>/probe-demo .
docker push <your-dockerhub>/probe-demo
```

---

# PART 2 — Deployment WITHOUT PROBES (INTENTIONAL FAILURE)

### deployment-no-probes.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
spec:
  replicas: 2
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
        image: <your-dockerhub>/probe-demo
        ports:
        - containerPort: 8080
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-demo
spec:
  selector:
    app: probe-demo
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f .
```

---

## 🔴 What breaks (observe carefully)

```bash
kubectl get pods -w
```

* Pods become **Running immediately**
* Traffic starts **before app is ready**
* Browser shows **timeouts / empty responses**
* Later, app freezes → **pods stay Running**
* Kubernetes does **NOT restart anything**

### This is how outages happen without probes.

---

# PART 3 — Add startupProbe (Fix slow startup)

### Why?

Without it:

* Liveness may kill app during startup
* Readiness may allow traffic too early

### startupProbe

```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 30
  periodSeconds: 1
```

Meaning:

* Kubernetes gives **30 seconds** to start
* No restarts during startup phase

---

# PART 4 — Add readinessProbe (Protect users)

### readinessProbe

```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 1
  periodSeconds: 2
```

What happens now:

```bash
kubectl get endpoints probe-demo
```

* Pod **NOT added to service** until ready
* No traffic leaks
* Zero user impact during startup

---

# PART 5 — Add livenessProbe (Self-healing)

### livenessProbe

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 20
  periodSeconds: 5
  failureThreshold: 3
```

When app freezes:

* `/health` stops responding
* Kubernetes restarts container
* Service stays stable

---

# FINAL FULL DEPLOYMENT (PRODUCTION-READY)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
spec:
  replicas: 2
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
        image: <your-dockerhub>/probe-demo
        ports:
        - containerPort: 8080

        startupProbe:
          httpGet:
            path: /health
            port: 8080
          failureThreshold: 30
          periodSeconds: 1

        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          periodSeconds: 2

        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
          failureThreshold: 3
```

---

# PART 6 — How DevOps Troubleshoots Probes in PROD

### Pod restarting?

```bash
kubectl describe pod <pod>
```

Look for:

```
Liveness probe failed
```

### Traffic issues?

```bash
kubectl get endpoints probe-demo
```

### App alive but no traffic?

→ readiness failing

### App stuck but pod running?

→ missing liveness

### Pod never ready?

→ bad readiness path or timing

---

# WHEN TO USE WHICH (INTERVIEW-LEVEL ANSWER)

| Scenario                          | Probe             |
| --------------------------------- | ----------------- |
| Slow JVM / Spring / DB migrations | startupProbe      |
| Protect users from half-ready app | readinessProbe    |
| Recover from deadlocks / freezes  | livenessProbe     |
| Batch jobs                        | NO liveness       |
| Stateful DBs                      | careful readiness |
| APIs                              | all three         |

---

# DEVOPS RULES 

* **Never expose traffic without readiness**
* **Never use liveness without understanding startup**
* **Never copy probe values blindly**
* **Probes are part of SLO, not YAML decoration**








![Image](https://pagertree.com/learn/assets/images/SLA%20vs%20SLO%20vs%20SLI-c43c8163c626355d78c0f9dec3561e19.png)

![Image](https://dz2cdn1.dzone.com/storage/temp/14389271-1612327757556.png)

![Image](https://i0.wp.com/jinaldesai.com/wp-content/uploads/2025/02/sli-sla-slos-pyramid-cover.png?resize=1200%2C675\&ssl=1)

### **SLI — Service Level Indicator (MEASUREMENT)**

> A **metric** that tells you how the system behaves.

Examples:

* Request success rate
* Latency (p95, p99)
* Error rate
* Availability
* Health check success

📌 **SLI = what you measure**

---

### **SLO — Service Level Objective (ENGINEERING TARGET)**

> The **goal** you want to meet for an SLI.

Examples:

* 99.9% requests succeed
* p95 latency < 500ms
* Error rate < 0.1%

📌 **SLO = what DevOps/SRE designs for**

---

### **SLA — Service Level Agreement (LEGAL PROMISE)**

> A **contract** with users/customers.

Examples:

* “99.9% uptime monthly”
* “Credits if breached”

📌 **SLA = legal & business, not technical**

---

### 🔑 Golden rule (INTERVIEW ANSWER)

> **You engineer for SLOs, not SLAs.
> SLAs are derived from SLOs.**

---

## 2️⃣ Real Production Flow (How companies ACTUALLY use them)

```
SLI  →  SLO  →  SLA
metric   target   contract
```

### Example: API service

**SLI**

* `/health` success rate
* HTTP 5xx error %

**SLO**

* 99.9% healthy responses per month

**SLA**

* “99.5% uptime guaranteed to customers”

Why SLA < SLO?
👉 Safety margin.

---

## 3️⃣ Where Kubernetes Probes Fit (THIS IS THE KEY)

Kubernetes probes **directly affect SLIs**.

| Probe          | Affects which SLI             |
| -------------- | ----------------------------- |
| readinessProbe | Availability, success rate    |
| livenessProbe  | Availability, MTTR            |
| startupProbe   | Cold start latency, stability |

👉 **Bad probes = bad SLIs = SLO breach = SLA penalty**

---

## 4️⃣ Concrete Example (REAL PROD SCENARIO)

### Business SLO

> **99.9% successful requests monthly**

That means:

* ~43 minutes downtime per month allowed

---

### Without readinessProbe

* App starts
* Traffic sent too early
* Users get 500 / timeouts

❌ SLI drops
❌ SLO breached
❌ SLA credits paid

---

### With readinessProbe

* Pod not added to Service until ready
* Users never hit half-ready app

✅ SLI stable
✅ SLO met
✅ SLA safe

📌 **Readiness protects SLO directly**

---

## 5️⃣ LivenessProbe & Error Budgets

### Error Budget (important SRE concept)

If SLO = 99.9%
→ Error budget = 0.1%

You are **allowed** some failures.

---

### Liveness without thinking (BAD)

* Restarts too aggressively
* Causes cascading failures
* Burns error budget faster

---

### Liveness done correctly (GOOD)

* Detects real deadlocks
* Restarts only when needed
* Improves MTTR (Mean Time To Recovery)

📌 **LivenessProbe protects SLO by reducing recovery time**

---

## 6️⃣ StartupProbe & SLO (Often missed in interviews)

### Without startupProbe

* Liveness kills slow-starting app
* CrashLoopBackOff
* App never becomes available

❌ Availability SLI destroyed

---

### With startupProbe

* Kubernetes waits
* No false restarts
* Stable startup

✅ Startup SLI protected
✅ Availability SLO met

---

## 7️⃣ How DevOps USES SLOs Practically (Not theory)

### Step 1 — Define SLIs

Examples:

* `% of requests with HTTP < 500`
* `/health` success
* p95 latency

---

### Step 2 — Set SLOs

Examples:

* 99.9% success
* p95 < 500ms

---

### Step 3 — Design Kubernetes accordingly

* readinessProbe → traffic safety
* livenessProbe → self-healing
* startupProbe → stability
* replicas → fault tolerance
* rollout strategy → limit blast radius

---

### Step 4 — Alert on SLO burn, not raw metrics

Bad alert:

> CPU 80%

Good alert:

> Error budget burn rate > 2x

---

## 8️⃣ Interview-Level Mapping (VERY IMPORTANT)

### Interview question:

**“How do probes relate to SLO/SLA?”**

### Strong answer:

> “Probes directly impact SLIs like availability and success rate.
> Readiness protects user-facing SLIs, liveness reduces MTTR, and startup prevents false restarts.
> We design probes based on SLOs, not arbitrarily, to avoid burning error budget and breaching SLA.”

That answer = **senior level**

---

## 9️⃣ Simple Table (Memorize this)

| Concept | Owner          | Purpose            |
| ------- | -------------- | ------------------ |
| SLI     | DevOps/SRE     | Measure reality    |
| SLO     | DevOps/SRE     | Engineering target |
| SLA     | Business/Legal | Customer promise   |
| Probes  | DevOps         | Protect SLOs       |

---

## 10️⃣ Final DevOps Truth (Production mindset)

* Probes are **not YAML decorations**
* Probes are **reliability controls**
* Every probe decision = **business impact**
* Bad probes cost **real money**


