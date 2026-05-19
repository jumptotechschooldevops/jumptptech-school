---
title: "DevOps Monitoring & Alerting — Real-World Lab (Prometheus + Grafana)"
description: "1) Why DevOps sets up email notifications   Dashboards are passive. Alerts + email are..."
published: 2026-02-04
source: "https://dev.to/jumptotech/devops-monitoring-alerting-real-world-lab-prometheus-grafana-44ph"
tags: []
---

# DevOps Monitoring & Alerting — Real-World Lab (Prometheus + Grafana)



# 1) Why DevOps sets up email notifications

Dashboards are passive. Alerts + email are active.

You need email notifications when:

* You are **on-call** and must know about incidents immediately
* The system is **unattended** (night/weekend)
* You need **evidence** for SLAs and incident reports

DevOps goal:

* Detect problems **before users complain**
* Reduce MTTR (mean time to recovery)
* Avoid “silent failure” (monitoring is broken but nobody knows)

---

# 2) What must be true before email notifications can work

Email notification depends on 4 layers:

1. **Exporter / Metrics exist** (node_exporter up)
2. **Prometheus scrapes** (Targets show UP)
3. **Grafana alert rule fires** (Normal → Pending → Firing)
4. **Notification delivery** (SMTP works + contact point + policy routes alerts)

In real life, most failures happen at layer 4.

---

# 3) Step-by-step: Configure SMTP on Grafana server (DevOps setup)

This is done **on the machine running Grafana** (your “monitor” instance).

## Step 3.1 — SSH to the Grafana server

```bash
ssh -i ~/Downloads/keypaircalifornia.pem ubuntu@<GRAFANA_PUBLIC_IP>
```

## Step 3.2 — Edit Grafana config

```bash
sudo nano /etc/grafana/grafana.ini
```

## Step 3.3 — Add/enable SMTP section

For Gmail SMTP (lab-friendly):

```ini
[smtp]
enabled = true
host = smtp.gmail.com:587
user = YOUR_SENDER_GMAIL@gmail.com
password = YOUR_GMAIL_APP_PASSWORD
from_address = YOUR_SENDER_GMAIL@gmail.com
from_name = Grafana Alerts
skip_verify = true
startTLS_policy = OpportunisticStartTLS
```

### DevOps notes (what matters)

* `host`: SMTP server + port
* `user`: mailbox used to send alerts (sender)
* `password`: **App Password**, not normal Gmail password
* `from_address`: must match sender for best deliverability
* `startTLS_policy`: enables encryption for SMTP

## Step 3.4 — Restart Grafana to load changes

```bash
sudo systemctl restart grafana-server
sudo systemctl status grafana-server
```

If Grafana fails to start, your config has a syntax problem.

## Step 3.5 — Watch Grafana logs while testing (DevOps habit)

```bash
sudo journalctl -u grafana-server -f
```

You keep this open when testing notifications.

---

# 4) Step-by-step: Gmail App Password (Most common failure)

Your error:
`535 5.7.8 Username and Password not accepted (BadCredentials)`

That means you used a normal password or Gmail blocked the sign-in.

## Step 4.1 — Enable 2-Step Verification (required)

Google Account → Security → 2-Step Verification ON

## Step 4.2 — Create App Password

Google Account → Security → App passwords → create one for “Mail”
Copy the **16-character** app password.

## Step 4.3 — Put that App Password in grafana.ini

Paste it **without spaces**.

Restart Grafana again.

### DevOps tip

When you see:

* `535 BadCredentials` → wrong password/app password missing
* `534-5.7.9 Application-specific password required` → needs app password
* `connection timeout` → network egress blocked / wrong SMTP host/port

---

# 5) Step-by-step: Configure Grafana UI (Contact point + policy)

SMTP is server-side. UI decides WHO gets notified.

## Step 5.1 — Create Contact Point

Grafana → Alerting → Contact points → Create contact point

* Type: Email
* Addresses: your receiver email (example: [aisalkynaidarova8@gmail.com](mailto:aisalkynaidarova8@gmail.com))
* Save

## Step 5.2 — Test Contact Point (mandatory)

Click **Test**.

### Expected:

* UI: “Test notification sent”
* Inbox: “Grafana test notification”
* Logs: show email send attempt

### If it fails:

* Look at the UI error + logs
* Fix SMTP first

## Step 5.3 — Configure Notification Policy (routing)

Grafana → Alerting → Notification policies

Ensure there is a policy that routes alerts to your contact point.
Options:

* Put your email contact point in the **Default policy**
  or
* Create a policy that matches labels like:

  * `severity = critical`
  * `team = devops`

### DevOps rule

No policy route → no notification, even if contact point exists.

---

# 6) Step-by-step: Create a “real” alert and trigger it

## Step 6.1 — Create alert rule (example: High CPU)

Use Prometheus datasource and query:

CPU %:

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Condition:

* IS ABOVE 80
* For 1m

Labels (important for routing):

* `severity = warning` or `critical`
* `team = devops`

Save rule.

## Step 6.2 — Trigger CPU load on target machine

On node exporter VM:

```bash
sudo apt update
sudo apt install -y stress
stress --cpu 2 --timeout 180
```

## Step 6.3 — Watch alert state

Grafana → Alerting → Active alerts:

* Normal → Pending → Firing

## Step 6.4 — Confirm email arrives

You should get:

* FIRING email
* RESOLVED email after load ends

---

# 7) How DevOps reads an alert email (what matters)

When an alert email comes, DevOps must answer:

## A) What is the problem?

* “High CPU”
* “Node down”
* “Disk almost full”

This tells urgency and type of incident.

## B) Which system/server?

Look for:

* `instance` label (IP:port)
* `job` label (node/prometheus)
* environment label (prod/dev) if you use it

In your lab, the most important is:

* `instance="172.31.x.x:9100"`

## C) How bad is it?

Look for:

* Severity label: warning vs critical
* Actual value (CPU 92%, disk 95%)
* “For 1m” or “For 5m” indicates persistence

## D) Is it new or recurring?

Check:

* Start time
* Frequency
* Similar previous emails

## E) What action should I take first?

DevOps initial actions should be fast:

For High CPU:

1. SSH to server
2. Check top processes:

   ```bash
   top
   ps aux --sort=-%cpu | head
   ```
3. Identify cause: deployment? runaway job? attack?
4. Mitigation: restart service, scale out, stop job

For Node Down:

1. Check if host is reachable (ping/ssh)
2. AWS instance status checks
3. Security group changes?
4. node_exporter service status

For Disk Full:

1. Find biggest usage:

   ```bash
   df -h
   sudo du -xh / | sort -h | tail
   ```
2. Clean logs / expand disk / rotate logs

---

# 8) What DevOps must pay attention to (best practices)

## 1) Always alert on monitoring failures

Critical alert:

```promql
up{job="node"} == 0
```

Because if node exporter dies, you become blind.

## 2) Avoid noisy alerts

Use:

* `FOR 1m` or `FOR 5m`
* Use `avg` / rate windows
  Otherwise you get spam and ignore alerts.

## 3) Include context in alerts

Use labels/annotations:

* summary: “CPU above 80% on {{ $labels.instance }}”
* description: “Check top, deployments, scaling”

## 4) Test notifications regularly

DevOps must test after:

* SMTP changes
* Grafana upgrades
* firewall changes
* password rotations

## 5) Separate “Warning” vs “Critical”

Example:

* warning: CPU > 80% for 5m
* critical: CPU > 95% for 2m

---

# 9) Mini checklist 

✅ SMTP configured in `/etc/grafana/grafana.ini`
✅ Gmail App Password (not normal password)
✅ Grafana restarted
✅ Contact point created + Test succeeded
✅ Notification policy routes alerts to contact point
✅ Alert rule has correct query + labels
✅ Trigger event causes Firing + email received


















# 🧪 PromQL LAB: Why Node Exporter Is Mandatory for DevOps



# 🔁 Architecture Reminder (Before Lab)

```
[ Linux Server ]
   └── node_exporter (system metrics)
            ↓
        Prometheus (scrapes metrics)
            ↓
        Grafana (query + alert + notify)
```

---

# LAB PART 1 — What Prometheus Knows WITHOUT Node Exporter

## Step 1 — Open Prometheus UI

```
http://<PROMETHEUS_IP>:9090
```

Go to **Graph** tab.

---

## Step 2 — Run this query

```promql
up
```

### Expected result:

You will see something like:

```
up{job="prometheus"} = 1
```

### DevOps explanation:

* Prometheus knows **itself**
* It knows nothing about CPU, memory, disk
* `up` only means “can I scrape this endpoint?”

👉 **Important DevOps truth:**

> Prometheus by itself only knows if targets are reachable, not how the system behaves.

---

## Step 3 — Try this query (WITHOUT node_exporter)

```promql
node_cpu_seconds_total
```

### Expected result:

❌ **No data**

### Why?

* Prometheus does not collect OS metrics
* Prometheus is **not an agent**
* It only pulls what is exposed

👉 **DevOps conclusion:**

> Prometheus is a collector, not a sensor.

---

# LAB PART 2 — What Node Exporter Adds

Now node_exporter is installed and running on the target machine.

---

## Step 4 — Confirm node exporter is scraped

```promql
up{job="node"}
```

### Expected result:

```
up{instance="172.31.x.x:9100", job="node"} = 1
```

### DevOps meaning:

* Prometheus can reach node_exporter
* Metrics are available
* Monitoring is alive

---

# LAB PART 3 — CPU Metrics (Most Common Incident)

## Step 5 — Raw CPU metric

```promql
node_cpu_seconds_total
```

### What students see:

* Multiple time series
* Labels:

  * `cpu="0"`
  * `mode="idle" | user | system | iowait`

### DevOps explanation:

* Linux CPU time is cumulative
* Metrics grow forever
* We must use `rate()` to make sense of it

---

## Step 6 — CPU usage percentage (REAL DEVOPS QUERY)

```promql
100 - (
  avg by (instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  ) * 100
)
```

### What this shows:

* CPU usage %
* Per server

### DevOps interpretation:

* 0–30% → normal
* 50–70% → watch
* > 80% → alert
* > 95% → incident

👉 **Why DevOps needs this:**

* High CPU causes:

  * Slow apps
  * Timeouts
  * Failed deployments

---

# LAB PART 4 — Memory Metrics (Silent Killers)

## Step 7 — Total memory

```promql
node_memory_MemTotal_bytes
```

### Interpretation:

* Physical RAM installed
* Does NOT change

---

## Step 8 — Available memory

```promql
node_memory_MemAvailable_bytes
```

### DevOps meaning:

* How much memory apps can still use
* Much better than “free memory”

---

## Step 9 — Memory usage percentage

```promql
(
  1 - (
    node_memory_MemAvailable_bytes
    /
    node_memory_MemTotal_bytes
  )
) * 100
```

### DevOps interpretation:

* Memory > 80% → danger
* Memory leaks show slow increase
* OOM kills happen suddenly

👉 **Why DevOps needs this:**

> Memory issues crash apps without warning if not monitored.

---

# LAB PART 5 — Disk Metrics (Most Dangerous)

## Step 10 — Disk usage %

```promql
100 - (
  node_filesystem_avail_bytes{mountpoint="/"}
  /
  node_filesystem_size_bytes{mountpoint="/"}
) * 100
```

### DevOps interpretation:

* Disk full = app crashes
* Databases stop
* Logs can’t write
* OS can become unstable

👉 **This alert is mandatory in production**

---

# LAB PART 6 — Network Metrics (Hidden Bottlenecks)

## Step 11 — Network receive rate

```promql
rate(node_network_receive_bytes_total[5m])
```

## Step 12 — Network transmit rate

```promql
rate(node_network_transmit_bytes_total[5m])
```

### DevOps interpretation:

* Sudden spikes → traffic surge or attack
* Drops → network issues
* Used in:

  * DDoS detection
  * Load testing validation

---

# LAB PART 7 — Proving Why Node Exporter Is REQUIRED

## Question to students:

> “Why can’t Prometheus do this alone?”

### Answer:

Prometheus:

* ❌ Does not know CPU
* ❌ Does not know memory
* ❌ Does not know disk
* ❌ Does not know network
* ❌ Does not run on every server

Node Exporter:

* ✅ Reads `/proc`, `/sys`
* ✅ Exposes OS internals safely
* ✅ Lightweight
* ✅ Industry standard

👉 **DevOps conclusion:**

> Prometheus without exporters is blind.

---

# LAB PART 8 — Real Incident Simulation

## Step 13 — Generate CPU load

```bash
stress --cpu 2 --timeout 120
```

## Step 14 — Watch PromQL graph change

```promql
100 - avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100
```

### DevOps observation:

* CPU spikes
* Alert transitions to Firing
* Email notification sent

---

# WHAT DEVOPS MUST PAY ATTENTION TO

## 1️⃣ Always monitor exporters themselves

```promql
up{job="node"} == 0
```

Because:

> If exporter dies, monitoring dies silently.

---

## 2️⃣ Use time windows correctly

* `rate(...[1m])` → fast reaction
* `rate(...[5m])` → stable alerts

---

## 3️⃣ Avoid raw counters

Bad:

```promql
node_cpu_seconds_total
```

Good:

```promql
rate(node_cpu_seconds_total[5m])
```

---

## 4️⃣ Labels matter

* `instance` → which server
* `job` → which role
* `mountpoint` → which disk

---



> “Prometheus collects metrics,
> node_exporter exposes system data,
> PromQL turns numbers into insight,
> alerts turn insight into action.”












# 📘 JumpToTech Lab

## Monitoring KIND Kubernetes from EC2 Prometheus using Node Exporter + SSH Tunnel

**Level:** Real DevOps 



1. **Prometheus itself** (self-monitoring)
2. **EC2 Linux VM** (node exporter on EC2)
3. **Local KIND Kubernetes cluster** (node exporter inside Kubernetes)

⚠️ **Key challenge**
Prometheus runs on **EC2**
KIND runs on **your laptop**
They are on **different networks**

👉 We solve this using **Node Exporter + SSH port forwarding**

---

## 🧠 Architecture (Explain before typing)

```
[KIND Nodes]
   |
[node-exporter DaemonSet]
   |
[NodePort 9100]
   |
[kubectl port-forward → 19100]
   |
[SSH tunnel -L 9101]
   |
[EC2 Prometheus]
```

**DevOps Rule:**

> Prometheus must reach `/metrics` over the network.
> If networking is wrong → monitoring is fake.

---

# PHASE 0 — Prerequisites

### On Laptop

* Docker running
* KIND cluster running
* kubectl configured to `kind-kind`
* SSH key for EC2 (`keypaircalifornia.pem`)

### On EC2

* Prometheus binary installed
* Node exporter running on EC2
* Port **9090** open in security group

---

# PHASE 1 — Verify KIND Cluster Context

```bash
kubectl config get-contexts
```

✔️ You **MUST** see:

```
* kind-kind
```

If not:

```bash
kubectl config use-context kind-kind
```

---

# PHASE 2 — Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

**Why (DevOps view):**

* Monitoring is infrastructure
* Must be isolated from app workloads

---

# PHASE 3 — Deploy Node Exporter on KIND (DaemonSet)

### Create file

```bash
vim node-exporter-kind.yaml
```

### Paste **FULL and CORRECT** YAML

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostPID: true
      hostNetwork: true
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          args:
            - "--path.procfs=/host/proc"
            - "--path.sysfs=/host/sys"
            - "--path.rootfs=/host/root"
          ports:
            - containerPort: 9100
              hostPort: 9100
          volumeMounts:
            - name: proc
              mountPath: /host/proc
              readOnly: true
            - name: sys
              mountPath: /host/sys
              readOnly: true
            - name: root
              mountPath: /host/root
              readOnly: true
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys
        - name: root
          hostPath:
            path: /
```

### Apply

```bash
kubectl apply -f node-exporter-kind.yaml
```

### Verify

```bash
kubectl get pods -n monitoring -o wide
```

✔️ You must see **one pod per KIND node**

**DevOps rule:**
If a node has no exporter → **you are blind on that node**

---

# PHASE 4 — Expose Node Exporter via Service

### Create Service

```bash
vim node-exporter-svc.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    app: node-exporter
  ports:
    - name: metrics
      port: 9100
      targetPort: 9100
```

```bash
kubectl apply -f node-exporter-svc.yaml
```

---

# PHASE 5 — Port-forward Node Exporter to Laptop

⚠️ **Why port-forward?**
EC2 cannot reach Docker/KIND directly.

```bash
kubectl port-forward -n monitoring svc/node-exporter 19100:9100
```

✔️ Terminal stays **open**
✔️ This is expected

### Test locally

```bash
curl http://localhost:19100/metrics | head
```

You MUST see:

```
node_cpu_seconds_total
node_memory_MemAvailable_bytes
```

If this fails → STOP. Prometheus will fail too.

---

# PHASE 6 — Create SSH Tunnel to EC2

⚠️ **This is the MOST IMPORTANT PART**

We forward:

```
EC2:9101 → Laptop:19100
```

### Run on **Laptop**

```bash
ssh -i keypaircalifornia.pem \
  -N \
  -L 9101:localhost:19100 \
  ubuntu@50.18.133.118
```

✔️ **No output** = SUCCESS
✔️ Terminal stays open = SUCCESS

---

# PHASE 7 — Configure Prometheus on EC2

### SSH into EC2

```bash
ssh -i keypaircalifornia.pem ubuntu@50.18.133.118
```

### Create directory (important!)

```bash
sudo mkdir -p /etc/prometheus
```

### Write config (vim often fails → use tee)

```bash
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "node-ec2"
    static_configs:
      - targets:
          - "172.31.28.122:9100"

  - job_name: "node-kind"
    static_configs:
      - targets:
          - "localhost:9101"
EOF
```

---

# PHASE 8 — Restart Prometheus

⚠️ Reload API is **NOT enabled**, so restart manually.

```bash
ps aux | grep prometheus
sudo kill <PID>
```

Then:

```bash
cd /tmp/prometheus-2.48.1.linux-amd64
./prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address="0.0.0.0:9090"
```

---

# PHASE 9 — Verify Targets (BIG SUCCESS MOMENT)

Open in browser:

```
http://<EC2_PUBLIC_IP>:9090
```

Go to:

```
Status → Targets
```

You MUST see **ALL UP**:

* `node-ec2`
* `node-kind`
* `prometheus`

🎉 **This proves cross-network monitoring works**

---

# PHASE 10 — PromQL Verification (Teach This)

### Is KIND node visible?

```promql
up{job="node-kind"}
```

### CPU Usage

```promql
100 - (
  avg by (instance)(
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  ) * 100
)
```

### Memory Usage

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Disk Usage

```promql
100 - (
  node_filesystem_avail_bytes{mountpoint="/"}
  /
  node_filesystem_size_bytes{mountpoint="/"}
) * 100
```

---

# 🧯 TROUBLESHOOTING (REAL ISSUES YOU HIT)

### ❌ `E212: Can't open file for writing`

Cause:

* Directory does not exist
* No sudo

Fix:

```bash
sudo mkdir -p /etc/prometheus
sudo tee ...
```

---

### ❌ Port already in use

```bash
lsof -i :19100
kill <PID>
```

---

### ❌ KIND not reachable

```bash
kubectl config use-context kind-kind
docker ps
```

---

### ❌ SSH tunnel shows no output

✅ This is **normal**
It means tunnel is active

---

### ❌ Prometheus reload fails

Reason:

```
Lifecycle API is not enabled
```

Fix:
Restart Prometheus process

---


* Monitoring **fails silently**
* Network visibility > dashboards
* Kubernetes hides node problems
* SSH tunnels are real production tools
* If `/metrics` is unreachable → alerts are lies


