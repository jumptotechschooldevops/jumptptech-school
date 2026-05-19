---
title: "Prometheus-Grafana project"
description: "Prometheus + Grafana on Kubernetes            What you’ll accomplish    Install a..."
published: 2025-10-30
source: "https://dev.to/jumptotech/prometheus-grafana-project-52n2"
tags: []
---

# Prometheus-Grafana project



#  Prometheus + Grafana on Kubernetes

## What you’ll accomplish

1. Install a production-style monitoring stack (Prometheus, Alertmanager, Grafana, Node Exporter, Kube-State-Metrics)
2. Explore Prometheus UI and run PromQL queries
3. Import Grafana dashboards and see live cluster metrics
4. Create and test an alert (Slack optional)
5. Stress the cluster to “see the graphs move”
6. (Optional) Expose your own application metric `/metrics`

---

## Agenda (you can keep time with this)

| Time      | Topic                                    |
| --------- | ---------------------------------------- |
| 0:00–0:10 | Monitoring basics (what & why)           |
| 0:10–0:25 | Prometheus & Grafana concepts            |
| 0:25–0:35 | Cluster prep (K8s, kubectl, Helm)        |
| 0:35–1:05 | Install kube-prometheus-stack (Helm)     |
| 1:05–1:25 | Prometheus UI + PromQL basics            |
| 1:25–1:45 | Grafana dashboards (import & explore)    |
| 1:45–2:05 | Alerts: create, load, test               |
| 2:05–2:25 | Slack notifications (optional but great) |
| 2:25–2:45 | Load test to trigger alert (wow moment)  |
| 2:45–3:00 | Troubleshooting, cleanup, next steps     |

---

## Section 0 — Prerequisites (very clear)

You need:

* A Kubernetes cluster (any of these is fine)

  * **EKS** (AWS), **Minikube**, **Docker Desktop (Kubernetes enabled)**, kind, or kubeadm
* `kubectl` connected to that cluster
* `helm` installed (v3+)

### Quick start (Minikube) — Mac or Linux

```bash
# Install minikube if needed (Mac via Homebrew)
brew install minikube

# Start a local cluster with 3 nodes (better metrics variety)
minikube start --nodes=3 --cpus=2 --memory=4096
```

### Quick check

```bash
kubectl get nodes
# Expect to see Ready nodes
```

---

## Section 1 — Monitoring basics (10 min, explain in your words)

* **Why monitor?** To detect issues early (CPU/memory saturation, errors, latency).
* **Metrics vs Logs vs Traces**

  * Metrics = numbers over time (cheap, fast to aggregate)
  * Logs = text events (debug detail)
  * Traces = end-to-end request path (latency analysis)
* **Where metrics come from?** Exporters & app endpoints (usually `/metrics`).

---

## Section 2 — Concepts you’ll need (clear & short)

* **Prometheus**: scrapes endpoints periodically, stores time-series.
* **Exporters**: programs exposing metrics (node-exporter, kube-state-metrics, blackbox).
* **PromQL**: query language to analyze numbers over time.
* **Alertmanager**: routes alerts (Slack/Email/PagerDuty).
* **Grafana**: dashboards for visualization.

**Pull model**: Prometheus **pulls** data from targets (easier to scale, discover via service discovery).

---

## Section 3 — Install kube-prometheus-stack (the easy + standard way)

> This Helm chart bundles: Prometheus, Alertmanager, Grafana, Node Exporter, Kube-State-Metrics, rules & dashboards.

### 3.1 Add Helm repo & update

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 3.2 Install into its own namespace

```bash
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

**What happens:**

* Namespace `monitoring` created
* Deployments/DaemonSets/Services for Prometheus, Grafana, Alertmanager, exporters
* Default recording/alerting rules installed

### 3.3 Verify pods

```bash
kubectl get pods -n monitoring
```

Expect to see pods like:

* `prometheus-kube-prometheus-stack-...`
* `alertmanager-kube-prometheus-stack-...`
* `grafana-...`
* `kube-state-metrics-...`
* `prometheus-node-exporter-...` (DaemonSet, one per node)

If some are **Pending**, your cluster may be resource-constrained. Increase Minikube resources or add nodes.

---

## Section 4 — Accessing the UIs (local port-forward)

### 4.1 Prometheus UI

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-stack-prometheus 9090:9090
```

Open: `http://localhost:9090`

### 4.2 Grafana UI

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Open: `http://localhost:3000`

**Default credentials** (from this chart):

* Username: `admin`
* Password: `prom-operator`

> If login fails, fetch the real password:

```bash
kubectl get secret -n monitoring monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

---

## Section 5 — Prometheus UI & PromQL basics (20 min)

In `http://localhost:9090` → **Graph** tab → **Expression** box.

Try these (type & Execute):

1. **All node exporter metrics** (discover metric names)

```
up
```

* Shows if Prometheus can reach targets (1 = up, 0 = down).

2. **CPU usage (raw counter)**

```
node_cpu_seconds_total
```

* A monotonically increasing counter per CPU mode (user/system/idle).
* Counters require *rates* to become meaningful.

3. **CPU usage (rate over 5 minutes)**

```
rate(node_cpu_seconds_total[5m])
```

* Rate = how fast the counter increases.
* You’ll get a series per `mode` (user/system/idle). Filter mode:

4. **Idle CPU % (convert to percent)**

```
avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100
```

5. **Non-idle CPU %**

```
(1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100
```

6. **Memory available %**

```
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100
```

7. **Disk space used %**

```
100 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} * 100)
```

> Tip to teach:
>
> * **Counters** → `rate()` or `irate()`
> * **Gauges** (values go up/down) → use directly (no `rate`)
> * `sum by(...)`, `avg by(...)` to aggregate over labels
> * Range selectors `[5m]` define the lookback window

---

## Section 6 — Grafana: import high-value dashboards (20 min)

Open `http://localhost:3000` → Log in → **Dashboards** → **Import** → enter IDs below:

* **Node Exporter Full** (comprehensive host metrics): **1860**
* **Kubernetes / Compute Resources / Cluster** (comes prepackaged; you’ll see a list in the stack)

After import:

* Choose **Prometheus** as the data source
* Save

Explore panels (CPU, memory, disk, network). Point out legends and labels.

---

## Section 7 — Create an alert rule (Prometheus rule file) (20 min)

We’ll alert when **non-idle CPU > 85%** for 2 minutes.

Create `cpu-alert.yaml`:

```yaml
groups:
- name: cpu-alerts
  rules:
  - alert: HighCPUUsage
    expr: (1 - avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100 > 85
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage (>85%) on {{ $labels.instance }}"
      description: "Instance {{ $labels.instance }} CPU usage has been >85% for 2 minutes."
```

Apply:

```bash
kubectl apply -n monitoring -f cpu-alert.yaml
```

**What this does**

* Prometheus continuously evaluates the expression
* If it stays true for `for: 2m`, it **fires** and sends to **Alertmanager**

> Where does it send? By default, Alertmanager stores & shows active alerts (no external receivers yet). We’ll add Slack next.

Check Prometheus → **Alerts** tab: you should see **HighCPUUsage** (inactive yet).

---

## Section 8 — (Optional) Slack notifications (20 min)

### 8.1 Create a Slack incoming webhook

* In Slack → Apps → **Incoming Webhooks** → Add to workspace → choose channel → copy **Webhook URL** (looks like `https://hooks.slack.com/services/T000/B000/XXXXXXXX`)

### 8.2 Create Alertmanager config

Create `alertmanager-slack.yaml`:

```yaml
alertmanager:
  config:
    route:
      receiver: "slack-default"
      group_by: ["alertname", "instance"]
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 3h
    receivers:
      - name: "slack-default"
        slack_configs:
          - send_resolved: true
            api_url: "https://hooks.slack.com/services/REPLACE/ME/HERE"
            channel: "#your-alerts-channel"
            title: "{{ .CommonAnnotations.summary }}"
            text: >-
              *Description:* {{ .CommonAnnotations.description }}
              *Status:* {{ .Status }}
              *Labels:* {{ .CommonLabels }}
```

### 8.3 Apply via Helm upgrade (best practice)

```bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f alertmanager-slack.yaml
```

Wait for Alertmanager pods to roll:

```bash
kubectl get pods -n monitoring -w
```

### 8.4 Verify in Alertmanager UI (optional)

Port-forward:

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-stack-alertmanager 9093:9093
```

Open: `http://localhost:9093`

You should see the route and receiver.

---

## Section 9 — Trigger the alert (load test) (15–20 min)

We’ll create a CPU-burning pod.

### Option A — Busybox burn (simplest)

```bash
kubectl run load --image=busybox -- /bin/sh -c "while true; do :; done"
```

### Option B — Stress image (more aggressive)

```bash
kubectl run stress --image=ghcr.io/shenxianpeng/stress -- -c 2 -t 600
# -c 2 -> 2 CPU workers, -t 600 -> 10 minutes
```

Now watch:

* Grafana dashboards (CPU climbing)
* Prometheus → **Alerts** tab: **HighCPUUsage** → Pending → Firing
* Slack: notification in your channel (if configured)

> Teach: alerts have states: **inactive → pending → firing** (pending = condition true but not long enough to trigger `for:` window).

Clean test pods when done:

```bash
kubectl delete pod load stress --ignore-not-found
```

---

## Section 10 — (Optional) Add your app metric in 5 minutes

### 10.1 Tiny Python web app exposing `/metrics`

Create `app.py`:

```python
from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUESTS = Counter('app_requests_total', 'Total app requests')

@app.route("/")
def home():
    REQUESTS.inc()
    return "Hello, Prometheus!"

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

`Dockerfile`:

```dockerfile
FROM python:3.11-slim
RUN pip install flask prometheus_client
COPY app.py /app.py
CMD ["python", "/app.py"]
```

Build & push (replace `<yourrepo>`):

```bash
docker build -t <yourrepo>/prom-app:v1 .
docker push <yourrepo>/prom-app:v1
```

K8s manifest `prom-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prom-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prom-app
  template:
    metadata:
      labels:
        app: prom-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "5000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: prom-app
        image: <yourrepo>/prom-app:v1
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: prom-app
spec:
  selector:
    app: prom-app
  ports:
  - port: 5000
    targetPort: 5000
```

Apply:

```bash
kubectl apply -f prom-app.yaml
```

**Why those annotations?**
kube-prometheus-stack includes Kubernetes service discovery. The `prometheus.io/scrape: "true"` annotation tells Prometheus to scrape the pod on that port/path automatically.

Check Prometheus UI → **Targets** → find `prom-app` target Up.
Try PromQL:

```
app_requests_total
rate(app_requests_total[5m])
```

Generate traffic:

```bash
kubectl run curl --image=curlimages/curl -it --rm -- \
  sh -lc 'for i in $(seq 1 100); do curl -s http://prom-app:5000/ >/dev/null; done'
```

---

## Section 11 — Troubleshooting (common real issues)

* **Grafana password wrong**

  * Get it from the secret:

    ```bash
    kubectl get secret -n monitoring monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo
    ```

* **Port-forward hangs / connection refused**

  * Ensure service names are correct (`kubectl get svc -n monitoring`)
  * Check pods are Ready:

    ```bash
    kubectl get pods -n monitoring
    kubectl describe pod <name> -n monitoring
    ```

* **Prometheus “Targets down”**

  * Check network policy (if any), Service/Endpoints exist
  * In Prometheus UI → **Status → Targets** → look at error messages

* **No metrics in Grafana panels**

  * Verify Prometheus is set as data source (Grafana → Connections → Data sources)
  * Query directly in Prometheus to confirm metric presence

* **Alerts not reaching Slack**

  * Open Alertmanager UI `http://localhost:9093` (port-forward svc)
  * Check **Status → Config** for your Slack receiver
  * Validate webhook URL & channel
  * Confirm alert is **Firing** in Prometheus

* **CrashLoopBackOff for exporters**

  * `kubectl logs` and `describe` to check permissions / resources
  * Node exporter is a DaemonSet; ensure tolerations if needed on special nodes

---

## Section 12 — Cleanup (leave cluster clean)

```bash
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
kubectl delete pod load stress --ignore-not-found
kubectl delete -f prom-app.yaml --ignore-not-found
```

---

## Section 13 — Interview crib notes (quick, crisp)

* **What is Prometheus?** Time-series monitoring: scrapes metrics, stores locally, queried via PromQL; pull model; integrates with Alertmanager.
* **Key exporters:** node-exporter (host metrics), kube-state-metrics (K8s objects), cAdvisor (containers), blackbox (HTTP/TCP/ICMP probes).
* **K8s deployment:** Helm chart `kube-prometheus-stack` (bundles Prometheus, Alertmanager, Grafana, rules, dashboards).
* **Grafana:** dashboards & alerts; Prometheus as data source.
* **Alerting:** write Prometheus rules; Alertmanager routes to Slack/Email/PagerDuty with grouping & inhibition.
* **PromQL essentials:** `rate()`, `sum by(...)`, `avg by(...)`, filters with `{label="value"}`, range selectors `[5m]`.

---

## Section 14 — What students should be able to do (outcomes)

* Explain Prometheus architecture and pull model
* Install kube-prometheus-stack and verify exporters
* Navigate Prometheus UI; write basic PromQL
* Import Grafana dashboards and interpret panels
* Create a simple alert and route it to Slack
* Instrument a toy app with `/metrics` and see it in Prometheus




