---
title: "SRE Monitoring Lab 2"
description: "Prometheus Alerting + AlertManager + Grafana Alerts   Now you will build a REAL SRE alerting..."
published: 2026-05-13
source: "https://dev.to/jumptotech/sre-monitoring-lab-2-536"
tags: []
---

# SRE Monitoring Lab 2


# Prometheus Alerting + AlertManager + Grafana Alerts

Now you will build a REAL SRE alerting system.

In production, monitoring without alerts is useless.

This lab teaches you:

* What alerts are
* How SRE engineers detect failures
* How Prometheus rules work
* How AlertManager works
* How alert routing works
* How to troubleshoot alerts
* How incidents are detected in production

You already have:

* Prometheus
* Grafana
* Node Exporter

running on your EC2 Ubuntu machine.

---

# WHAT SRE ENGINEERS MUST UNDERSTAND FIRST

# Why Monitoring Alone Is Not Enough

Dashboards are passive.

SRE engineers cannot stare at dashboards 24/7.

Instead:

```text id="1o63gz"
System detects problems automatically
→ sends alerts
→ engineers respond
```

---

# REAL PRODUCTION FLOW

```text id="j1lszy"
Node Exporter
      ↓
Prometheus scrapes metrics
      ↓
Alert Rules evaluate metrics
      ↓
AlertManager receives alerts
      ↓
Email / Slack / PagerDuty
```

---

# WHAT IS ALERTMANAGER?

Alertmanager handles alerts from Prometheus.

It:

* groups alerts
* deduplicates alerts
* routes alerts
* sends notifications

---

# WHAT SRE ENGINEERS MUST KNOW

Prometheus:

* stores metrics
* evaluates rules

AlertManager:

* handles notifications

Grafana:

* visualization

---

# LAB GOAL

You will create:

| Alert       | Trigger              |
| ----------- | -------------------- |
| High CPU    | CPU > 70%            |
| Node Down   | Exporter unavailable |
| High Memory | RAM low              |

Then intentionally break system and watch alerts fire.

---

# ARCHITECTURE

```text id="6utj9c"
Node Exporter
     ↓
Prometheus
     ↓
AlertManager
     ↓
Alert UI
```

---

# STEP 1 — DOWNLOAD ALERTMANAGER

SSH into EC2.

Go to:

```bash id="qg7s8h"
cd /tmp
```

Download:

```bash id="vgkg4j"
wget https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz
```

---

# STEP 2 — EXTRACT FILE

```bash id="gtu08m"
tar -xvf alertmanager-0.28.1.linux-amd64.tar.gz
```

---

# STEP 3 — MOVE BINARIES

```bash id="azebn4"
sudo mv alertmanager-0.28.1.linux-amd64/alertmanager /usr/local/bin/

sudo mv alertmanager-0.28.1.linux-amd64/amtool /usr/local/bin/
```

---

# WHAT IS AMTOOL?

CLI tool for testing AlertManager.

---

# STEP 4 — CREATE USER

```bash id="3ib5q9"
sudo useradd -rs /bin/false alertmanager
```

---

# STEP 5 — CREATE DIRECTORIES

```bash id="8dv8bd"
sudo mkdir /etc/alertmanager

sudo mkdir /var/lib/alertmanager
```

---

# STEP 6 — COPY CONFIG

```bash id="5q6l7r"
sudo cp /tmp/alertmanager-0.28.1.linux-amd64/alertmanager.yml /etc/alertmanager/
```

---

# STEP 7 — SET OWNERSHIP

```bash id="mgg5lr"
sudo chown -R alertmanager:alertmanager /etc/alertmanager

sudo chown -R alertmanager:alertmanager /var/lib/alertmanager
```

---

# STEP 8 — CREATE SYSTEMD SERVICE

```bash id="gtb4ny"
sudo nano /etc/systemd/system/alertmanager.service
```

Paste:

```ini id="w3ckzm"
[Unit]
Description=AlertManager
After=network.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

[Install]
WantedBy=multi-user.target
```

Save file.

---

# STEP 9 — START ALERTMANAGER

```bash id="6f9ok5"
sudo systemctl daemon-reload

sudo systemctl enable alertmanager

sudo systemctl start alertmanager
```

---

# STEP 10 — VERIFY SERVICE

```bash id="vc7qop"
sudo systemctl status alertmanager
```

You should see:

```text id="e3h2vj"
active (running)
```

---

# STEP 11 — OPEN SECURITY GROUP

Go to AWS Console.

---

## EC2 → Security Groups

Add:

| Port | Purpose      |
| ---- | ------------ |
| 9093 | AlertManager |

Source:

```text id="5h4yfx"
0.0.0.0/0
```

---

# STEP 12 — VERIFY ALERTMANAGER UI

Browser:

```text id="rqj3uw"
http://YOUR_PUBLIC_IP:9093
```

You should see AlertManager UI.

---

# WHAT SRE ENGINEERS MUST KNOW

| Port | Service       |
| ---- | ------------- |
| 9090 | Prometheus    |
| 9093 | AlertManager  |
| 9100 | Node Exporter |
| 3000 | Grafana       |

---

# STEP 13 — CONNECT PROMETHEUS TO ALERTMANAGER

Edit Prometheus config:

```bash id="kzkbbo"
sudo nano /etc/prometheus/prometheus.yml
```

Add:

```yaml id="qj4vdf"
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093
```

---

# STEP 14 — ADD RULE FILE

In same file add:

```yaml id="c81l7s"
rule_files:
  - "alert.rules.yml"
```

---

# FULL STRUCTURE

```yaml id="vl5vlx"
global:
  scrape_interval: 15s

rule_files:
  - "alert.rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093
```

---

# STEP 15 — CREATE ALERT RULE FILE

```bash id="3xkq4y"
sudo nano /etc/prometheus/alert.rules.yml
```

Paste:

```yaml id="q4ly2k"
groups:

- name: node_alerts

  rules:

  - alert: NodeDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Node Exporter Down"

  - alert: HighCPUUsage
    expr: 100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 70
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "High CPU Usage"

  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "High Memory Usage"
```

Save file.

---

# WHAT SRE ENGINEERS MUST UNDERSTAND

# ALERT RULE STRUCTURE

| Field       | Meaning             |
| ----------- | ------------------- |
| alert       | Alert name          |
| expr        | PromQL expression   |
| for         | Duration            |
| labels      | Severity            |
| annotations | Human-readable info |

---

# WHAT IS PROMQL?

Prometheus Query Language.

Used for:

* dashboards
* alerts
* troubleshooting

---

# CPU ALERT EXPLANATION

This calculates:

```text id="jlwm0v"
Non-idle CPU percentage
```

Meaning:

```text id="l2p8lz"
Actual CPU usage
```

---

# STEP 16 — VERIFY CONFIGURATION

Run:

```bash id="zhb2nf"
promtool check config /etc/prometheus/prometheus.yml
```

You should see:

```text id="rjlwmf"
SUCCESS
```

---

# STEP 17 — RESTART PROMETHEUS

```bash id="2y7z4u"
sudo systemctl restart prometheus
```

---

# STEP 18 — VERIFY ALERTS PAGE

Browser:

```text id="1jlwmn"
http://YOUR_PUBLIC_IP:9090/alerts
```

You should see alert rules.

State:

```text id="pu4lt6"
Inactive
```

---

# STEP 19 — TRIGGER CPU ALERT

Install stress tool if not installed:

```bash id="a8cnfx"
sudo apt install stress -y
```

Generate load:

```bash id="v1q6gh"
stress --cpu 4 --timeout 180
```

---

# WHAT HAPPENS?

CPU rises.

Prometheus evaluates:

```text id="zgtzth"
CPU > 70%
```

After 1 minute:

```text id="bxl09l"
Alert fires
```

---

# STEP 20 — WATCH ALERT

Go to:

```text id="s5fhzl"
http://YOUR_PUBLIC_IP:9090/alerts
```

You should see:

```text id="5hktc4"
FIRING
```

---

# STEP 21 — CHECK ALERTMANAGER

Open:

```text id="hxtg9t"
http://YOUR_PUBLIC_IP:9093
```

You should see alert there.

---

# WHAT SRE ENGINEERS MUST KNOW

Prometheus:

* evaluates rules

AlertManager:

* receives active alerts

---

# STEP 22 — TEST NODE DOWN ALERT

Stop exporter:

```bash id="djlwmq"
sudo systemctl stop node_exporter
```

Wait 1 minute.

Refresh:

```text id="k1kvsn"
/alerts
```

You should see:

```text id="fdjlwm"
NodeDown FIRING
```

---

# THIS IS REAL SRE INCIDENT DETECTION

Production example:

```text id="jlwmx8"
Kubernetes node dies
→ exporter unreachable
→ NodeDown fires
→ PagerDuty alerts SRE
```

---

# STEP 23 — TROUBLESHOOT AS SRE

---

# CHECK SERVICE

```bash id="jlwm0c"
sudo systemctl status node_exporter
```

---

# CHECK PORT

```bash id="3y5r5v"
ss -tulnp | grep 9100
```

---

# CHECK ENDPOINT

```bash id="jlwm4y"
curl localhost:9100/metrics
```

---

# CHECK PROMETHEUS TARGETS

```text id="xjlwm9"
http://YOUR_PUBLIC_IP:9090/targets
```

---

# WHAT SRE ENGINEERS MUST MEMORIZE

| Command    | Purpose       |
| ---------- | ------------- |
| systemctl  | services      |
| journalctl | logs          |
| curl       | endpoint test |
| ss         | ports         |
| top        | CPU           |
| free -m    | RAM           |
| df -h      | disk          |

---

# IMPORTANT SRE CONCEPTS

# Alert Fatigue

Too many alerts = engineers ignore alerts.

SRE engineers carefully tune:

* thresholds
* durations
* severities

---

# Severity Levels

| Severity | Meaning          |
| -------- | ---------------- |
| critical | immediate action |
| warning  | monitor          |
| info     | informational    |

---

# WHY "for: 1m"?

Prevents temporary spikes causing alerts.

Without it:

```text id="jlwm1x"
Tiny CPU spike
→ false alert
```

---

# WHAT REAL COMPANIES USE

| Tool         | Purpose       |
| ------------ | ------------- |
| AlertManager | routing       |
| PagerDuty    | on-call       |
| Opsgenie     | escalation    |
| Slack        | notifications |
| Email        | alerts        |

---

# REAL INTERVIEW QUESTIONS

# What is AlertManager?

Handles alerts from Prometheus.

---

# Difference Between Prometheus and AlertManager?

| Prometheus      | AlertManager         |
| --------------- | -------------------- |
| stores metrics  | handles alerts       |
| evaluates rules | routes notifications |

---

# What is PromQL?

Prometheus Query Language.

---

# Why use "for" in alerts?

Avoid false positives.

---

# What happens if Node Exporter stops?

Prometheus target becomes DOWN and alert fires.


