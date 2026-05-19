---
title: "Prometheus + Node Exporter on Two EC2 Instances"
description: "📘 Prometheus + Node Exporter on Ubuntu (AWS EC2)            1️⃣ Architecture Overview (What..."
published: 2026-02-02
source: "https://dev.to/jumptotech/prometheus-node-exporter-on-two-ec2-instances-4d0n"
tags: []
---

# Prometheus + Node Exporter on Two EC2 Instances


# 📘 Prometheus + Node Exporter on Ubuntu (AWS EC2)



## 1️⃣ Architecture Overview (What we are building)

### EC2 #1 — **TARGET (Ubuntu)**

* Purpose: expose system metrics
* Tool: **Node Exporter**
* Port: **9100**

### EC2 #2 — **MONITOR (Ubuntu)**

* Purpose: collect and display metrics
* Tool: **Prometheus**
* Port: **9090**

```
Browser
   ↓
Prometheus (Ubuntu, :9090)
   ↓ scrape
Node Exporter (Ubuntu, :9100)
```

---

## 2️⃣ AWS SECURITY GROUP SETUP (LAB MODE)

> ⚠️ **This is NOT secure for production**
> ✔ Used only for training & demos

### 2.1 Create Security Group (Same steps for both EC2s)

AWS Console → **EC2 → Security Groups → Create security group**

**Inbound Rules**

| Type        | Protocol | Port | Source      |
| ----------- | -------- | ---- | ----------- |
| All traffic | All      | All  | `0.0.0.0/0` |

**Outbound Rules**

* Keep default: **All traffic → 0.0.0.0/0**

Attach this SG to:

* Monitor EC2
* Target EC2

---

## 3️⃣ TARGET EC2 (Ubuntu) — Install Node Exporter



### 3.2 Download Node Exporter

```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
```

---

### 3.3 Extract & install

```bash
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
cd node_exporter-1.7.0.linux-amd64
sudo mv node_exporter /usr/local/bin/
```

---

### 3.4 Start Node Exporter (foreground demo)

```bash
node_exporter
```

You should see:

```
Listening on :9100
```

---

### 3.5 Verify Node Exporter

```bash
ss -tulnp | grep 9100
```

Test metrics:

```bash
curl http://localhost:9100/metrics | head
```

✔ Node Exporter is ready

---

## 4️⃣ MONITOR EC2 (Ubuntu) — Install Prometheus

### 4.1 Connect to MONITOR EC2

```bash
ssh ubuntu@<MONITOR_PUBLIC_IP>
```

---

### 4.2 Download Prometheus

```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
```

---

### 4.3 Extract files

```bash
tar -xvf prometheus-2.48.1.linux-amd64.tar.gz
cd prometheus-2.48.1.linux-amd64
```

---

### 4.4 Create directories

```bash
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
```

---

### 4.5 Install binaries

```bash
sudo mv prometheus promtool /usr/local/bin/
prometheus --version
```

---

### 4.6 Move config files

```bash
sudo mv prometheus.yml /etc/prometheus/
sudo mv consoles console_libraries /etc/prometheus/
```

Verify:

```bash
ls /etc/prometheus
```

Expected:

```
prometheus.yml
consoles
console_libraries
```

---

## 5️⃣ Configure Prometheus (Ubuntu)

### 5.1 Edit config

```bash
sudo nano /etc/prometheus/prometheus.yml
```

### 5.2 Replace EVERYTHING with this

(Change `<TARGET_PUBLIC_IP>`)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files: []

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["<TARGET_PUBLIC_IP>:9100"]
```

Save:

* `CTRL + O`
* Enter
* `CTRL + X`

---

### 5.3 Validate config (VERY IMPORTANT)

```bash
promtool check config /etc/prometheus/prometheus.yml
```

Expected:

```
SUCCESS
```

---

## 6️⃣ Start Prometheus (Ubuntu)

```bash
prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus
```

Look for:

```
Server is ready to receive web requests.
```

---

## 7️⃣ Access Prometheus UI

Open browser:

```
http://<MONITOR_PUBLIC_IP>:9090
```

Navigate to:
**Status → Targets**

### ✅ Expected result

```
prometheus     UP
node           UP
```

This confirms:

* Networking works
* Security group works
* Metrics are being scraped

---

## 8️⃣ Live Demonstration Queries (Ubuntu Lab)

Go to **Graph** tab.

### 8.1 Check targets

```promql
up
```

---

### 8.2 CPU usage (%)

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

### 8.3 Memory usage (%)

```promql
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) 
/ node_memory_MemTotal_bytes * 100
```

---

### 8.4 Disk usage (%)

```promql
100 * (1 - (node_filesystem_avail_bytes{mountpoint="/"} 
/ node_filesystem_size_bytes{mountpoint="/"}))
```

---


> Node Exporter exposes system metrics on port 9100
> Prometheus scrapes metrics on intervals
> If Targets are UP, monitoring is working
> Security Groups control access, not Linux

---

## 10️⃣ What We Deliberately Allowed (Lab Mode)

| Component  | Allowed     |
| ---------- | ----------- |
| SG inbound | All traffic |
| IPv4       | 0.0.0.0/0   |
| Ports      | 9090, 9100  |

✔ Easy learning
❌ Not secure for prod







# 📊 Grafana Placement & Setup (Ubuntu, AWS EC2)

## 🔹 WHERE does Grafana go?

👉 **Grafana is installed on the MONITOR EC2**, together with Prometheus.

### Final architecture (very important)

```
TARGET EC2 (Ubuntu)
└── Node Exporter
    └── :9100 (/metrics)

MONITOR EC2 (Ubuntu)
├── Prometheus
│   └── :9090 (scrapes node exporter)
└── Grafana
    └── :3000 (visualizes Prometheus data)
```

### Why Grafana goes on MONITOR EC2

* Grafana **does NOT collect metrics**
* Grafana **only visualizes**
* Prometheus is the data source
* Putting Grafana next to Prometheus:

  * simpler networking
  * real production pattern
  * easier teaching

✅ **Correct**: Prometheus + Grafana on same EC2
❌ **Wrong**: Grafana on target node

---

# 🧩 STEP-BY-STEP: Install Grafana on Ubuntu (MONITOR EC2)

## 1️⃣ Connect to MONITOR EC2

```bash
ssh ubuntu@<MONITOR_PUBLIC_IP>
```

---

## 2️⃣ Update system

```bash
sudo apt update
```

---

## 3️⃣ Install required packages

```bash
sudo apt install -y apt-transport-https software-properties-common wget
```

---

## 4️⃣ Add Grafana GPG key

```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```

Expected:

```
OK
```

---

## 5️⃣ Add Grafana repository

```bash
echo "deb https://packages.grafana.com/oss/deb stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list
```

---

## 6️⃣ Install Grafana

```bash
sudo apt update
sudo apt install -y grafana
```

---

## 7️⃣ Start & enable Grafana

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

Check status:

```bash
sudo systemctl status grafana-server
```

Expected:

```
Active: active (running)
```

---

## 8️⃣ Open Grafana port in Security Group (LAB MODE)

On **MONITOR EC2 Security Group**, ensure inbound rule exists:

| Type        | Protocol | Port | Source    |
| ----------- | -------- | ---- | --------- |
| All traffic | All      | All  | 0.0.0.0/0 |

(You already allowed all traffic, so Grafana will open automatically.)

---

## 9️⃣ Access Grafana UI

From your browser:

```
http://<MONITOR_PUBLIC_IP>:3000
```

### Default login

* **Username**: `admin`
* **Password**: `admin`
* You’ll be asked to set a new password

---

# 🔗 Connect Grafana to Prometheus

## 10️⃣ Add Prometheus as Data Source

In Grafana UI:

1. ⚙️ **Settings**
2. **Data Sources**
3. **Add data source**
4. Select **Prometheus**

### Configure:

* **Name**: Prometheus
* **URL**:

  ```
  http://localhost:9090
  ```
* Click **Save & Test**

Expected:

```
Data source is working
```

---

## 📈 Import Node Exporter Dashboard (DEMO GOLD)

## 11️⃣ Import Dashboard ID 1860

1. Click **+ (Create)** → **Import**
2. Enter Dashboard ID:

   ```
   1860
   ```
3. Click **Load**
4. Select **Prometheus** as data source
5. Click **Import**

🎉 You now see:

* CPU usage
* Memory usage
* Disk usage
* Network traffic
* Load average

This is the **industry-standard Node Exporter dashboard**.

---



> Prometheus collects metrics
> Grafana visualizes metrics
> Node Exporter exposes system data
> Targets UP = data is flowing



* Prometheus → Status → Targets (UP)
* Grafana → Dashboard → live graphs

---

# 🧠 Common Issues & Fixes

### Grafana page doesn’t open

* Check port 3000 in Security Group
* Check service:

```bash
sudo systemctl status grafana-server
```

### No data in Grafana

* Check Prometheus data source URL
* Must be:

```
http://localhost:9090
```

### Dashboard empty

* Prometheus targets must be **UP**
* Wait 1–2 minutes (data fills over time)






# 🧪 DEVOPS LAB: Node Exporter → Prometheus → Grafana 


## 🔴 LAB SETUP (MANDATORY CONTEXT)

You have **2 Ubuntu EC2 servers**:

### 🟢 SERVER 1 — TARGET (Application / Infra Node)

* Ubuntu
* Runs **Node Exporter**
* Port: **9100**
* Purpose: **Expose system metrics**

### 🟢 SERVER 2 — MONITOR (Observability Node)

* Ubuntu
* Runs **Prometheus**
* Runs **Grafana**
* Ports:

  * 9090 → Prometheus
  * 3000 → Grafana
* Purpose: **Collect + Visualize metrics**

---

# 🔹 PART 1 — NODE EXPORTER (TARGET SERVER)

## ✅ Goal

Prove:

* Metrics exist
* They are machine-readable
* Node Exporter does NOT store data

---

## 📍 WHERE

👉 **SSH into TARGET server**

```bash
ssh ubuntu@<TARGET_PUBLIC_IP>
```

---

## 🧾 WHAT TO TYPE

### 1️⃣ Check Node Exporter is running

```bash
ps -ef | grep node_exporter
```

### ✅ WHAT YOU SHOULD SEE

```
/usr/local/bin/node_exporter
```

### 🔍 DEVOPS ANALYSIS

✔ Exporter is running
✔ Metrics endpoint should exist

---

### 2️⃣ Check port 9100

```bash
ss -tulnp | grep 9100
```

### ✅ EXPECTED OUTPUT

```
LISTEN 0 4096 *:9100
```

### 🔍 DEVOPS ANALYSIS

✔ Node Exporter is reachable
✔ Ready to be scraped

---

### 3️⃣ View raw metrics

```bash
curl http://localhost:9100/metrics | head
```

### ✅ EXPECTED OUTPUT

```
# HELP node_cpu_seconds_total ...
# TYPE node_cpu_seconds_total counter
```

### 🔍 DEVOPS ANALYSIS (VERY IMPORTANT)

❌ Hard to read
❌ No history
❌ No visualization

✅ **Conclusion:** Node Exporter only exposes current values

---

# 🔹 PART 2 — PROMETHEUS (MONITOR SERVER)

## ✅ Goal

Prove:

* Prometheus pulls metrics
* Stores time-series data
* Knows target health

---

## 📍 WHERE

👉 **SSH into MONITOR server**

```bash
ssh ubuntu@<MONITOR_PUBLIC_IP>
```

---

## 🧾 WHAT TO TYPE

### 4️⃣ Confirm Prometheus is running

```bash
ps -ef | grep prometheus
```

### ✅ EXPECTED OUTPUT

```
/usr/local/bin/prometheus
```

### 🔍 DEVOPS ANALYSIS

✔ Prometheus engine is active

---

### 5️⃣ Open Prometheus UI (BROWSER)

```
http://<MONITOR_PUBLIC_IP>:9090
```

---

### 6️⃣ Check scrape status

UI → **Status → Targets**

### ✅ EXPECTED UI STATE

```
node        UP
prometheus  UP
```

### 🔍 DEVOPS ANALYSIS (CRITICAL)

| State | Meaning                  |
| ----- | ------------------------ |
| UP    | Prometheus can scrape    |
| DOWN  | Network / exporter issue |

**This page is the FIRST place DevOps checks.**

---

# 🔹 PART 3 — PROMQL (HOW DEVOPS QUERIES DATA)

## 📍 WHERE

👉 Prometheus UI → **Graph**

---

### 7️⃣ Check system health

```promql
up
```

### ✅ EXPECTED RESULT

```
node = 1
prometheus = 1
```

### 🔍 DEVOPS ANALYSIS

✔ Monitoring pipeline is healthy

---

### 8️⃣ Inspect CPU metrics

```promql
node_cpu_seconds_total
```

### 🔍 DEVOPS ANALYSIS

❌ Raw counter
❌ Not useful directly

---

### 9️⃣ Calculate CPU usage (%)

```promql
100 - (
  avg by (instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  ) * 100
)
```

### ✅ EXPECTED OUTPUT

Graph showing CPU %

### 🔍 DEVOPS ANALYSIS

✔ Detect CPU saturation
✔ Identify performance issues

---

### 🔟 Memory usage

```promql
(node_memory_MemTotal_bytes -
 node_memory_MemAvailable_bytes)
 / node_memory_MemTotal_bytes * 100
```

### 🔍 DEVOPS ANALYSIS

✔ Memory leaks
✔ Capacity planning

---

### 1️⃣1️⃣ Disk usage

```promql
100 * (1 -
 node_filesystem_avail_bytes{mountpoint="/"} /
 node_filesystem_size_bytes{mountpoint="/"})
```

### 🔍 DEVOPS ANALYSIS

✔ Disk full = production outage risk

---

# 🔹 PART 4 — WHY PROMETHEUS UI IS NOT ENOUGH

## ❓ QUESTION TO STUDENTS

> Can you easily compare CPU + Memory + Disk?

Answer: ❌ NO

### 🔍 DEVOPS CONCLUSION

Prometheus = **database & engine**, not dashboards

---

# 🔹 PART 5 — GRAFANA (VISUALIZATION)

## 📍 WHERE

👉 Browser

```
http://<MONITOR_PUBLIC_IP>:3000
```

Login:

```
admin / admin
```

---

### 1️⃣2️⃣ Add Prometheus datasource

Grafana → **Settings → Data Sources → Prometheus**

URL:

```
http://localhost:9090
```

Click **Save & Test**

### 🔍 DEVOPS ANALYSIS

✔ Grafana can query Prometheus

---

### 1️⃣3️⃣ Import dashboard

Grafana → **Create → Import**

Dashboard ID:

```
1860
```

---

### ✅ WHAT YOU SHOULD SEE

* CPU graphs
* Memory graphs
* Disk graphs
* Network graphs

### 🔍 DEVOPS ANALYSIS

✔ One screen
✔ Real-time visibility
✔ Executive-friendly dashboards

---

# 🔹 PART 6 — FAILURE ANALYSIS (REAL DEVOPS TEST)

## 📍 WHERE

👉 TARGET server

### 1️⃣4️⃣ Stop Node Exporter

```bash
sudo systemctl stop node_exporter
```

---

## 📍 WHERE

👉 Prometheus UI → Targets

### ❌ EXPECTED

```
node → DOWN
```

---

## 📍 WHERE

👉 Grafana dashboard

### ❌ EXPECTED

* Graphs freeze
* No new data

---

### 🔍 DEVOPS ANALYSIS (MOST IMPORTANT SKILL)

| Symptom       | Conclusion          |
| ------------- | ------------------- |
| Target DOWN   | Exporter or network |
| Grafana empty | Upstream issue      |
| Prometheus UP | Collector fine      |

---

### 1️⃣5️⃣ Restore service

```bash
sudo systemctl start node_exporter
```

Targets → **UP again**

---

# 🧠 FINAL DEVOPS TAKEAWAYS (MEMORIZE)

> Node Exporter exposes metrics
> Prometheus pulls and stores metrics
> PromQL analyzes metrics
> Grafana visualizes metrics
> Targets page = first troubleshooting step





