---
title: "PROJECT: Linux Log Monitoring & Auto-Alert System (Bash)"
description: "📌 Real-World Context (Very Important)   Company type: SaaS / FinTech / E-commerce..."
published: 2025-12-30
source: "https://dev.to/jumptotech/project-linux-log-monitoring-auto-alert-system-bash-426f"
tags: []
---

# PROJECT: Linux Log Monitoring & Auto-Alert System (Bash)




## 📌 Real-World Context (Very Important)

**Company type:**
SaaS / FinTech / E-commerce company

**Problem in production:**

* Servers generate **huge log files**
* Engineers must:

  * Detect **errors**
  * Count how often they occur
  * Alert **before customers complain**
* Bash is often the **first line of defense** before fancy tools (ELK, Datadog)

This project simulates **what DevOps engineers really do** on EC2 / Linux servers.

---

## 🧠 

| Topic                           | Where Used               |                 |
| ------------------------------- | ------------------------ | --------------- |
| Variables                       | Config paths, thresholds |                 |
| Environment variables           | Reusable config          |                 |
| `$PATH`                         | Script execution         |                 |
| `> >> <                         | `                        | Logs, pipelines |
| `grep awk sed cut sort uniq wc` | Log analysis             |                 |
| `if / for / while`              | Logic & loops            |                 |
| Functions                       | Clean, reusable code     |                 |
| Cron jobs                       | Automation in production |                 |

---

## 🏗 Project Architecture (Simple)

```
/opt/log-monitor/
├── logs/
│   └── app.log
├── scripts/
│   └── monitor.sh
└── reports/
    └── daily_report.txt
```

---

## STEP 1: Create Sample Production Log

```bash
sudo mkdir -p /opt/log-monitor/logs /opt/log-monitor/scripts /opt/log-monitor/reports

sudo tee /opt/log-monitor/logs/app.log <<EOF
INFO User login success
INFO User login success
ERROR Database connection failed
INFO Payment processed
ERROR Payment timeout
ERROR Database connection failed
WARN Slow API response
INFO User logout
EOF

```

🔹 **Why DevOps cares:**
Logs are the **source of truth** during outages.

---

## STEP 2: Bash Script Skeleton

Create script:

```bash
nano /opt/log-monitor/scripts/monitor.sh
```

```bash
#!/bin/bash
```

Make executable:

```bash
chmod +x /opt/log-monitor/scripts/monitor.sh
```

---

## STEP 3: Variables & Environment Variables

```bash
LOG_FILE="/opt/log-monitor/logs/app.log"
REPORT_FILE="/opt/log-monitor/reports/daily_report.txt"
ERROR_THRESHOLD=2
```

### Environment variable example:

```bash
export ALERT_EMAIL="devops@company.com"
```

🔹 **Why in prod:**

* Same script works in **dev / staging / prod**
* Only env vars change

---

## STEP 4: $PATH (Production Reality)

Move script into PATH:

```bash
sudo ln -s /opt/log-monitor/scripts/monitor.sh /usr/local/bin/log-monitor
```

Now you can run:

```bash
log-monitor
```

🔹 **Why in prod:**
DevOps scripts must run **without full paths** (cron, automation)

---

## STEP 5: Redirection & Pipes (Core Skill)

Count errors:

```bash
grep "ERROR" "$LOG_FILE" | wc -l
```

Append report:

```bash
echo "Log Report - $(date)" >> "$REPORT_FILE"
```

🔹 **Why in prod:**
Almost **every DevOps task uses pipes**

---

## STEP 6: Text Processing (Real Log Analysis)

### Count each error type:

```bash
grep "ERROR" "$LOG_FILE" \
| awk '{print $2}' \
| sort \
| uniq -c
```

### Extract message only:

```bash
grep "ERROR" "$LOG_FILE" | cut -d' ' -f2-
```

🔹 **Why in prod:**
You rarely read logs manually — **you filter and summarize**

---

## STEP 7: Functions (Clean Production Code)

```bash
count_errors() {
  grep "ERROR" "$LOG_FILE" | wc -l
}

generate_report() {
  echo "------ ERROR SUMMARY ------" >> "$REPORT_FILE"
  grep "ERROR" "$LOG_FILE" | awk '{print $2}' | sort | uniq -c >> "$REPORT_FILE"
}
```

🔹 **Why in prod:**
Large scripts must be **readable and maintainable**

---

## STEP 8: if Condition (Decision Making)

```bash
ERROR_COUNT=$(count_errors)

if [ "$ERROR_COUNT" -ge "$ERROR_THRESHOLD" ]; then
  echo "ALERT: Too many errors ($ERROR_COUNT)" >> "$REPORT_FILE"
fi
```

🔹 **Interview question:**


---

## STEP 9: for Loop (Multiple Files Scenario)

```bash
for file in /opt/log-monitor/logs/*.log; do
  echo "Processing $file"
done
```

🔹 **Why in prod:**
Applications often have **many log files**

---

## STEP 10: while Loop (Streaming Logs)

```bash
tail -f "$LOG_FILE" | while read line; do
  echo "$line"
done
```

🔹 **Why in prod:**
Live debugging during incidents

---

## STEP 11: Final Script (Clean & Complete)

```bash
#!/bin/bash

LOG_FILE="/opt/log-monitor/logs/app.log"
REPORT_FILE="/opt/log-monitor/reports/daily_report.txt"
ERROR_THRESHOLD=2

count_errors() {
  grep "ERROR" "$LOG_FILE" | wc -l
}

generate_report() {
  echo "Log Report - $(date)" > "$REPORT_FILE"
  echo "-------------------------" >> "$REPORT_FILE"
  grep "ERROR" "$LOG_FILE" | awk '{print $2}' | sort | uniq -c >> "$REPORT_FILE"
}

ERROR_COUNT=$(count_errors)
generate_report

if [ "$ERROR_COUNT" -ge "$ERROR_THRESHOLD" ]; then
  echo "ALERT: High error rate ($ERROR_COUNT errors)" >> "$REPORT_FILE"
fi
```

Run:

```bash
log-monitor
```

---

## STEP 12: Cron Job (Production Automation)

```bash
crontab -e
```

Run every 5 minutes:

```bash
*/5 * * * * /usr/local/bin/log-monitor
```

🔹 **Why DevOps uses cron:**

* Health checks
* Log cleanup
* Backups
* Monitoring

---

## 🎯 How to Explain This to Students

**Simple explanation:**

> “DevOps engineers use Bash to watch servers automatically.
> This script checks logs, finds problems, and reports them — without human effort.”

---

## 💼 Interview Mapping (Very Important)

**Question:**
“How do you use Bash in production?”

**Answer:**

> “I use Bash for automation like log monitoring, alerting, backups, and health checks.
> For example, I wrote scripts that analyze logs using grep/awk, run via cron, and trigger alerts when error thresholds are exceeded.”


