---
title: "Lab: Installing Prometheus & Grafana"
description: "We want this:    Your Machine (Mac) │ ├── Prometheus (collects metrics) │ ├── Grafana (shows..."
published: 2026-01-30
source: "https://dev.to/jumptotech/lab-installing-prometheus-grafana-2254"
tags: []
---

# Lab: Installing Prometheus & Grafana








![Image](https://miro.medium.com/1%2AVEkGz7Ky9FwK-CC09c8FNQ.png)

![Image](https://signoz.io/img/guides/2024/07/is-prometheus-monitoring-push-or-pull-Untitled.webp)

![Image](https://miro.medium.com/1%2AJr1U0Lpz4_uju71uhMtotQ.jpeg)

We want this:

```
Your Machine (Mac)
│
├── Prometheus (collects metrics)
│
├── Grafana (shows graphs)
│
└── Node Exporter (gives CPU / memory data)
```

Key ideas:

* **Prometheus = collects numbers**
* **Grafana = draws graphs**
* **Prometheus pulls data**, nothing pushes to it

---


### 1️⃣ Docker must work

```bash
docker --version
docker ps
```

If Docker is not running → **nothing else works**

---

## 🧩  Create working directory

```bash
mkdir prometheus-grafana-demo
cd prometheus-grafana-demo
```

We will keep **all configs here**.

---

##  Prometheus configuration (first mistake usually happens here)

Create file:

```bash
nano prometheus.yml
```

Paste:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["prometheus:9090"]
```



* `localhost` ❌ (inside containers this breaks)
* `prometheus` ✅ (Docker DNS name)

This mistake caused your **403 + connection issues earlier**.

---

##  Docker networking (CRITICAL STEP)





### ✅ Correct way

Create a Docker network:

```bash
docker network create monitoring
```

This step **fixed your Grafana → Prometheus connection problem**.

---

## 🧩  Run Prometheus

```bash
docker run -d \
  --name prometheus \
  --network monitoring \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

Check:

```bash
docker ps
```

Open browser:

```
http://localhost:9090
```

### Test Prometheus

In Prometheus UI, run:

```
up
```

Expected:

```
up = 1
```

If not → config or container problem.

---

##  Run Grafana 



Grafana was **not running**, so:

```
http://localhost:3000 → not reachable
```

### ✅ Correct command

```bash
docker run -d \
  --name grafana \
  --network monitoring \
  -p 3000:3000 \
  grafana/grafana
```

Check:

```bash
docker ps
```

Open:

```
http://localhost:3000
```

Login:

```
admin / admin
```

---

## Connect Grafana to Prometheus (MAJOR TROUBLESHOOTING POINT)

### ❌ What caused 403 error

You used:

```
http://host.docker.internal:9090
```

Prometheus rejected it.

### ✅ Correct URL (THIS IS KEY)

In Grafana → Data sources → Prometheus:

```
http://prometheus:9090
```

Click **Save & Test**

Expected:

```
Data source is working
```


##  Verify metrics 

Grafana → **Explore** → Prometheus
Run:

```promql
up
```

You should see:

* prometheus = 1

This proves:

* Grafana ↔ Prometheus works

---

##  Add Node Exporter 

Without this, you only monitor Prometheus itself.

Run:

```bash
docker run -d \
  --name node-exporter \
  --network monitoring \
  -p 9100:9100 \
  prom/node-exporter
```

---

##  Update Prometheus to scrape Node Exporter

Edit `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["prometheus:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["node-exporter:9100"]
```

Restart Prometheus:

```bash
docker restart prometheus
```

---

## 🧩 PART 11 — Verify Node metrics

In Prometheus UI:

```promql
node_cpu_seconds_total
```

You saw a **big table** — that is **raw CPU data**.

Important lesson:

* Raw metrics ≠ graphs
* We must **calculate** values

---

##  First real graph (CPU %)

In Grafana → Explore → **Code mode**, paste:

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Switch to **Graph**.



* `rate()` = speed over time
* CPU % is **derived**, not stored directly

---

## Dashboards vs Explore 

### Explore

* Temporary
* Testing queries

### Dashboards

* Saved
* Production view

---

## Save graph to dashboard 

From **Explore**:

```
Share → Add to dashboard → New dashboard → Open dashboard
```

OR

From Dashboards:

```
Add visualization
```

Both are correct.

---

## Make the graph readable

Panel settings:

* Visualization: **Time series**
* Unit: **Percent (0–100)**
* Min: `0`
* Max: `100`
* Title: `CPU Usage (%)`

This turns “data” into **monitoring**.

---

## 🧩 PART 16 — Common mistakes we FIXED (important summary)

| Problem                    | Why it happened       | Fix                          |
| -------------------------- | --------------------- | ---------------------------- |
| Grafana UI not opening     | Container not running | `docker ps`                  |
| 403 Forbidden              | Wrong Prometheus URL  | Use `http://prometheus:9090` |
| No metrics                 | Not scraping exporter | Edit `prometheus.yml`        |
| Confusing numbers          | Raw counters          | Use `rate()`                 |
| Can't reach argocd-metrics | K8s DNS               | Prometheus must run in K8s   |

---

##  Argo CD confusion 



> did I connect Argo CD with Prometheus?

### Answer 

* **Yes**, because you saw Argo CD metrics
* The reason it was confusing:

  * Prometheus ran on your Mac
  * Argo CD ran in Kubernetes
  * Different networks

### Production rule (memorize):

> Prometheus must run in the **same network** as what it monitors.

---

##  When to use which setup

### Docker Prometheus

* Learning
* Interviews
* Demos

### Kubernetes Prometheus

* Real jobs
* Argo CD monitoring
* Alerts

---

## 🧠 FINAL SUMMARY (ONE PARAGRAPH)

> Prometheus collects metrics using a pull model, exporters expose data, Grafana visualizes it, and correct networking is the most common source of problems. Containers must share a network, Kubernetes services are not reachable outside the cluster, and most monitoring issues come from misunderstanding where Prometheus runs.







## ✅ Your CURRENT directory (unchanged)

You have this now:

```
argocd-docs/
├── grade-api-app.yaml
├── grade-api-gitops/
│   └── deployment.yaml
└── k8s-ci-build/
    ├── Dockerfile
    ├── README.md
    └── src/
```

We will **NOT touch** any of this.

---

## 🎯 What we will ADD (monitoring)

We will add **one new folder**:

```
argocd-docs/
├── grade-api-app.yaml
├── grade-api-gitops/
│   └── deployment.yaml
├── k8s-ci-build/
│   └── ...
└── monitoring/
    ├── namespace.yaml
    ├── prometheus/
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── grafana/
    │   ├── deployment.yaml
    │   └── service.yaml
    └── monitoring-app.yaml
```

This keeps things **clean, teachable, and GitOps-friendly**.

---

# 🧩 STEP 1 — Create folders

From `argocd-docs`:

```bash
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana
```

---

# 🧩 STEP 2 — Monitoring namespace

Create `monitoring/namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

---

# 🧩 STEP 3 — Prometheus ConfigMap (VERY IMPORTANT)

Create `monitoring/prometheus/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["prometheus.monitoring.svc.cluster.local:9090"]

      - job_name: "argocd"
        static_configs:
          - targets:
              - argocd-metrics.argocd.svc.cluster.local:8082
              - argocd-server-metrics.argocd.svc.cluster.local:8083
```

👉 This is the **connection point** between Prometheus and Argo CD.

---

# 🧩 STEP 4 — Prometheus Deployment

Create `monitoring/prometheus/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: config
              mountPath: /etc/prometheus
      volumes:
        - name: config
          configMap:
            name: prometheus-config
```

---

# 🧩 STEP 5 — Prometheus Service

Create `monitoring/prometheus/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
    - port: 9090
```

---

# 🧩 STEP 6 — Grafana Deployment

Create `monitoring/grafana/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana
          ports:
            - containerPort: 3000
```

---

# 🧩 STEP 7 — Grafana Service

Create `monitoring/grafana/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
    - port: 3000
```

---

# 🧩 STEP 8 — Argo CD Application (THIS IS THE KEY FILE)

Create `monitoring/monitoring-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_GITHUB_USERNAME/argocd-docs.git
    targetRevision: main
    path: monitoring
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

# 🧩 STEP 9 — Apply ONLY the Argo CD app

```bash
kubectl apply -f monitoring/monitoring-app.yaml
```

Now open **Argo CD UI**.

You should see:

* App name: **monitoring**
* Status: **Syncing → Healthy**

---

# 🧩 STEP 10 — Verify (simple checks)

```bash
kubectl get pods -n monitoring
```

You should see:

* prometheus
* grafana

Access Grafana:

```bash
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

Browser:

```
http://localhost:3000
```

Login:

```
admin / admin
```

---

## ✅ FINAL PROOF (ONE QUERY)

In Grafana → Explore → Prometheus:

```promql
argocd_app_info
```

If you see data → **DONE** 🎉

---

## 🧠 What you can now confidently say

> “I manage Prometheus and Grafana using Argo CD itself. Prometheus scrapes Argo CD metrics inside the cluster, and Grafana visualizes GitOps health.”

This is **real DevOps**, not a toy demo.


