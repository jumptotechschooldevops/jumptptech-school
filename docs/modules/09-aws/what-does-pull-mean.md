---
title: "What Does “Pull” Mean?"
description: "Pull means:    Prometheus goes and asks for metrics.        Enter fullscreen mode            Exit..."
published: 2026-05-12
source: "https://dev.to/jumptotech/what-does-pull-mean-50fb"
tags: []
---

# What Does “Pull” Mean?





Pull means:

```plaintext
Prometheus goes and asks for metrics.
```

Prometheus INITIATES the request.

---

# Example

Node Exporter runs on:

```text id="j74vrl"
10.0.1.10:9100
```

Prometheus server says:

```text id="31qj3u"
"Hey Node Exporter,
give me CPU, RAM, Disk metrics."
```

So Prometheus sends HTTP requests.

That is PULL.

---

# Visualization

```text id="4fqgzh"
Prometheus  --------->  Node Exporter
             requests metrics
```

Prometheus PULLS metrics from exporter.

---

# Real Example

Prometheus config:

```yaml id="gn5ghh"
scrape_configs:
  - job_name: 'node'

    static_configs:
      - targets: ['10.0.1.10:9100']
```

Every 15 seconds Prometheus does:

```text id="e5brgq"
GET http://10.0.1.10:9100/metrics
```

Exporter responds with metrics.

---

# What Metrics Look Like

When Prometheus calls:

```text id="4vv84k"
http://10.0.1.10:9100/metrics
```

Exporter returns:

```text id="e0xv9z"
node_cpu_seconds_total 23423
node_memory_MemFree_bytes 34343434
node_filesystem_avail_bytes 83838383
```

Prometheus stores them in database.

---

# Why Pull Model?

Because Prometheus wants:

* Centralized monitoring
* Easier management
* Automatic service discovery
* Easier troubleshooting
* Better scalability

---

# Push vs Pull

| Pull                        | Push                 |
| --------------------------- | -------------------- |
| Prometheus requests metrics | Server sends metrics |
| Centralized                 | Distributed          |
| Easier monitoring           | Harder at scale      |
| Prometheus uses this        | Some tools use this  |

---

# Pull Example

```text id="r6wv7n"
Prometheus → "Give me metrics"
```

---

# Push Example

```text id="43n5ci"
Server → "Here are my metrics"
```

---

# Real-Life Analogy

## Pull

Teacher asks students:

```text id="7l2gwp"
"Give me your homework."
```

Teacher initiates.

That is pull.

---

## Push

Students automatically send homework to teacher.

That is push.

---

# Why Prometheus Pull Is Powerful

Prometheus can:

* Check if target is alive
* Automatically discover servers
* Retry failed requests
* Control scrape intervals
* Detect unhealthy exporters

---

# What Happens If Exporter Is Down?

Prometheus tries:

```text id="zj6t07"
GET http://10.0.1.10:9100/metrics
```

No response.

Then target becomes:

```text id="8znvv4"
DOWN
```

You can see it in:

```text id="l0q00q"
http://PROMETHEUS_IP:9090/targets
```

---

# Important Interview Question

## Why does Prometheus use pull model?

Good answer:

Because pull allows centralized monitoring, easier service discovery, health checking, scalability, and better control over metric collection.

---

# Another Important Thing

Prometheus mainly uses pull.

BUT there is also:

## Pushgateway

Used for:

* Short-lived jobs
* Cron jobs
* Batch jobs

Because short jobs may finish before Prometheus scrapes them.

Then job PUSHES metrics to Pushgateway.

But normal monitoring uses pull.

