---
title: "Prometheus #1"
description: "Why We Use Grafana Alongside Prometheus   In modern systems, we usually have servers and..."
published: 2026-01-31
source: "https://dev.to/jumptotech/prometheus-1-15ic"
tags: []
---

# Prometheus #1







## Why We Use Grafana Alongside Prometheus

In modern systems, we usually have **servers and workloads** running across different environments. From these systems, we want to:

* Collect **metrics**
* Store their **values**
* Keep track of **timestamps**
* Analyze trends over time

This type of data is called **time-series data**.

### Prometheus: Metrics Collection and Storage

Prometheus is a time-series database designed to:

* Scrape and store metrics
* Attach labels to metrics
* Store metrics efficiently over time
* Allow querying using **PromQL**
* Create **alerts** based on metric conditions

Prometheus is excellent at **collecting, storing, and querying metrics**.

However, Prometheus has a **very basic built-in UI**.
Its visualization capabilities are limited and **not sufficient for real-world dashboards**.

---









### The Visualization Problem

In real production environments:

* Metrics are **not stored in one place**
* You may have:

  * Metrics in Prometheus
  * Time-series data in **SQL databases**
  * Infrastructure metrics in **cloud platforms**

Examples:

* A SQL database like **SQL Server** or **MySQL**
* Cloud metrics in **Amazon CloudWatch**

You *can* move all these metrics into Prometheus, but:

* That adds **unnecessary complexity**
* It increases **maintenance overhead**
* It is only useful if you need to **combine metrics mathematically**

If your goal is **visualization only**, moving data into Prometheus is **not required**.

---

### Grafana: Unified Visualization Layer

Grafana is an open-source visualization and monitoring platform.

Grafana allows you to:

* Connect to **multiple data sources**
* Build **rich dashboards**
* Visualize metrics from different systems **in one place**

Supported data sources include:

* Prometheus
* SQL databases
* Cloud providers like Amazon CloudWatch
* Many others

![Image](https://grafana.com/media/grafana/images/grafana-dashboard-english.png)

![Image](https://prometheus.io/assets/docs/grafana_qps_graph.png)

![Image](https://raw.githubusercontent.com/cboudereau/grafana-dashboards/main/aws/sqs/graph-multiple-queues.png)

![Image](https://s3.amazonaws.com/a-us.storyblok.com/f/1022730/f2aa821a02/cloudwatch-metrics-meta.png)

### One Dashboard, Multiple Sources

In a single Grafana dashboard:

* One panel may show data from Prometheus
* Another panel may read from a SQL database
* Another panel may show CloudWatch metrics

All of this is displayed **together**, giving a complete system view.

---

### Alerting in Grafana

Grafana also provides:

* **Centralized alerting**
* Visual alert states on dashboards
* Unified alert management across data sources

This means:

* You don’t need separate alerting systems for each tool
* Teams can **see what’s broken and why** from one place

---

### Open Source and Enterprise Options

Grafana is:

* **Open source** (widely used in DevOps and SRE teams)
* Also available as an **enterprise offering** with advanced features

For more details, you can explore the official Grafana website.

---

### Summary

* **Prometheus** → collects and stores metrics
* **Grafana** → visualizes metrics from many sources
* Together, they provide:

  * Strong monitoring
  * Clear dashboards
  * Unified alerting
  * Real production-ready observability

This is why, in real DevOps environments, **Prometheus and Grafana are almost always used together**.








## How Prometheus Collects and Stores Metrics


## The Prometheus Architecture (High Level)

At a high level, we usually have:

* One **Prometheus server** (or a Prometheus cluster)
* Many **systems** we want to monitor:

  * Applications
  * Databases
  * Servers
  * Cloud services
  * Proxies, load balancers
  * IoT devices

Prometheus is a **pull-based time-series database**, meaning:

* Prometheus **always pulls metrics**
* Nothing ever pushes metrics **directly** into Prometheus

---

## Case 1: When You Have the Application Source Code

If you **own the application code**, things are easy.

You can:

* Add a **Prometheus client library** to the application
* Expose a `/metrics` endpoint

Client libraries exist for:

* Python
* Java
* Go
* Ruby
* .NET
* Many others

The application:

* Collects metrics internally
* Exposes them over HTTP
* Prometheus **scrapes** them

This approach works well **only when you control the source code**.

---

## Case 2: When You Do NOT Have the Source Code

In many real-world cases, you **cannot modify the code**.

Examples:

* Databases (MySQL, PostgreSQL, SQL Server)
* Cloud services like **Amazon CloudWatch**
* Proxies and load balancers
* Third-party systems
* IoT devices (sensors, meters, traffic lights)

You cannot:

* Add libraries
* Change the application logic
* Modify how metrics are exposed

---

## Why “Push to Prometheus” Is a Bad Idea

You might think:

> “Let’s write a script that collects data and sends it to Prometheus.”

This is **not a good solution** because:

* It does not scale
* Scripts fail silently
* Scheduling becomes complex
* Millions of devices pushing data can **overload Prometheus**

Prometheus is **not designed to accept pushed metrics**.

---

## Exporters: The Correct Solution

The correct solution is to use **exporters**.

### What Is an Exporter?

An **exporter** is a small service that:

* Knows how to talk to a system
* Collects metrics from it
* Exposes those metrics in Prometheus format

Examples:

* Node Exporter → Linux servers
* MySQL Exporter → MySQL databases
* Windows Exporter → Windows servers
* CloudWatch Exporter → AWS metrics
* Proxy exporters (NGINX, HAProxy, Envoy)

![Image](https://miro.medium.com/1%2AVEkGz7Ky9FwK-CC09c8FNQ.png)

![Image](https://signoz.io/img/guides/2024/07/how-does-prometheus-work-Untitled.webp)

![Image](https://volkovlabs.io/img/blog/2023-09-26-timeseries-dashboard/timeseries-prometheus.png)

---

## Where Exporters Run

* **On the same machine** (Linux, Windows)
* **Next to the system** (for cloud services, databases, proxies)
* **As a container**
* **As a Kubernetes Pod**

Prometheus then:

* Discovers the exporter
* Connects to it
* Pulls metrics

---

## Scraping: How Prometheus Pulls Metrics

The process of Prometheus pulling metrics from exporters is called **scraping**.

Key points:

* Configured in `prometheus.yml`
* Default scrape interval: **15 seconds**
* Prometheus:

  * Connects to exporters
  * Pulls metrics
  * Stores them as time-series data

Prometheus always controls **when** and **how often** data is collected.

---

## Case 3: Short-Lived Jobs and PushGateway

There is one special case:

* Batch jobs
* Cron jobs
* Short-lived processes

These jobs:

* Start
* Do work
* Exit
* Do not stay running long enough to be scraped

For this case, Prometheus provides **PushGateway**.

Prometheus Pushgateway

### How PushGateway Works

* Applications **push metrics to PushGateway**
* PushGateway stores them temporarily
* PushGateway exposes a `/metrics` endpoint
* Prometheus **scrapes PushGateway**

Important:

* Metrics are **not pushed to Prometheus**
* Prometheus still **pulls**
* PushGateway only acts as an **intermediate buffer**

---

## Important Design Rule

> **Prometheus is always pull-based. Always.**

PushGateway:

* Is optional
* Used only for short-lived jobs
* Should NOT be used for normal services or IoT streams

---

## Why This Design Matters

This model allows Prometheus to:

* Scale safely
* Control load
* Avoid overload
* Work with thousands of heterogeneous systems

It is ideal for:

* Large infrastructures
* Cloud-native systems
* Hybrid environments
* IoT at scale

---

## Summary

* Applications with source code → **Client libraries**
* Systems without source code → **Exporters**
* Short-lived jobs → **PushGateway**
* Prometheus → **Always pulls metrics**
* Scraping → Happens on a fixed interval (default 15s)

This is the foundation of **real-world Prometheus monitoring**.










## Node Exporter: Collecting Host Metrics with Prometheus

### What Is Node Exporter?

Node Exporter is an **official Prometheus exporter** used to collect **host-level metrics** from **Unix-based systems**.

Important clarification first:

> **Node Exporter has NOTHING to do with Node.js.**

In Prometheus terminology, a **“node”** means:

* Any machine running a Unix-based OS
* Examples: Linux servers, Ubuntu, Amazon Linux, macOS

So **Node Exporter = exporter for machine (host) metrics**.

---

## Why Node Exporter Exists

Applications expose **application metrics**.
Node Exporter exposes **machine metrics**.

Examples of metrics collected by Node Exporter:

* CPU usage
* Memory usage
* Disk usage
* Network I/O
* File system stats
* Load average
* System uptime

![Image](https://miro.medium.com/1%2Av-ohSTzLH_AWPBFRM44d5Q.png)

![Image](https://devopscube.com/content/images/2025/03/prometheus-architecture.gif)

![Image](https://miro.medium.com/1%2A9_XeHLdBdRveDxVVBPf_kA.png)

These metrics are critical for:

* Capacity planning
* Performance troubleshooting
* Infrastructure monitoring
* Alerting on system health

---

## Official vs Community Exporters

Node Exporter is **official**, meaning:

* It is part of the **Prometheus project**
* Maintained by the Prometheus team
* Stable and production-ready

Other exporters (MySQL, NGINX, CloudWatch, etc.) may be:

* Community maintained
* Vendor maintained
* Third-party maintained

---

## Where Node Exporter Is Installed

**Never install Node Exporter on the Prometheus server**
(unless you want to monitor Prometheus itself)

Correct setup:

* Prometheus server → central collector
* Node Exporter → installed on **each machine you want to monitor**

Example architecture:

![Image](https://miro.medium.com/v2/resize%3Afit%3A1120/1%2AvTPTAImV7tCt-es_Z51Gmw.png)

![Image](https://miro.medium.com/1%2Av-ohSTzLH_AWPBFRM44d5Q.png)

![Image](https://prometheus.io/assets/docs/architecture.svg)

This applies to:

* AWS
* GCP
* Azure
* On-prem
* Home lab
* macOS

---

## Network & Security (Very Important)

Node Exporter listens on **port 9100**.

### Security Rule (Best Practice)

> **Port 9100 must ONLY be accessible by Prometheus**

Why?

* Metrics include sensitive system information
* Opening 9100 to the internet exposes your server

In AWS:

* Open port **9100**
* Source = **Prometheus server security group**
* NOT `0.0.0.0/0`

This ensures:

* Only Prometheus can scrape metrics
* No public access

---

## Installing Node Exporter on Ubuntu / Linux

### 1. Update the system

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Download Node Exporter

From the official Prometheus download page.

```bash
wget https://github.com/prometheus/node_exporter/releases/download/vX.Y.Z/node_exporter-X.Y.Z.linux-amd64.tar.gz
```

### 3. Extract

```bash
tar xvf node_exporter-*.tar.gz
```

### 4. Run Node Exporter (temporary)

```bash
./node_exporter
```

You should see:

```
Listening on :9100
```

Visiting:

```
http://<server-ip>:9100/metrics
```

shows raw metrics (hard to read, but correct).

---

## Configuring Prometheus to Scrape Node Exporter

Edit Prometheus config:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Add under `scrape_configs`:

```yaml
- job_name: "application-server"
  static_configs:
    - targets: ["<APPLICATION_SERVER_IP>:9100"]
```

Restart Prometheus:

```bash
sudo systemctl restart prometheus
```

Verify in Prometheus UI:

* **Status → Targets**
* Target state should be **UP (green)**

If it’s DOWN:

* Check IP
* Check firewall / security group
* Check Node Exporter is running

---

## Running Node Exporter as a Service (Production)

Running Node Exporter in a terminal is **not acceptable** in production.

### Why?

* Terminal closes → exporter stops
* Server restarts → exporter stops

### Solution: systemd service

Steps:

1. Create user & group
2. Move binary to `/var/lib/node_exporter`
3. Create `node_exporter.service`
4. Enable & start service

After setup:

```bash
systemctl status node_exporter
```

Expected:

```
Active: active (running)
```

Now:

* Survives reboots
* Starts automatically
* Production-ready

---

## Node Exporter on macOS (Homebrew)

If Prometheus is installed via Homebrew:

### Install

```bash
brew install node_exporter
```

### Start as service

```bash
brew services start node_exporter
```

Verify:

```
http://localhost:9100/metrics
```

### Update Prometheus config

Prometheus config location (Homebrew):

```
/usr/local/etc/prometheus.yml
```

Add:

```yaml
- job_name: "mac-node"
  static_configs:
    - targets: ["localhost:9100"]
```

Restart Prometheus:

```bash
brew services restart prometheus
```

Check:

* Prometheus → Targets
* Both Prometheus and Node Exporter should be **UP**

---

## Key Takeaways

* Node Exporter = **host metrics**
* Not related to Node.js
* Installed on **machines**, not Prometheus
* Uses **port 9100**
* Must be **secured**
* Always run as a **service** in production
* Works on Linux and macOS



## Prometheus Data Model (Foundations)

To query metrics stored in Prometheus, you must first understand **how Prometheus stores data**.

### 1. Time Series Basics

Prometheus stores all data as **time series**.

A **time series** consists of:

* A **metric name**
* A **set of labels** (key–value pairs)
* A **timestamp** (Unix timestamp)
* A **value**

Each data point represents the value of a metric at a specific moment in time.

---

### 2. Metric Name

The **metric name** identifies *what* is being measured.

Examples:

* `http_requests_total`
* `cpu_usage_seconds_total`
* `authentication_api_hits_total`

The metric name is always required.

---

### 3. Labels (Key–Value Pairs)

Labels provide **dimensions** to a metric and allow you to slice and filter data.

* Labels are **optional**
* Each label is a **key = value** pair
* A metric can have **multiple labels**

Labels answer questions like:

* *Which service?*
* *Which user/account?*
* *Which endpoint?*
* *Which instance?*

---

### 4. Time Series Identity

In Prometheus, **a time series is uniquely identified by:**

```
metric name + full set of labels
```

Even if the metric name is the same, **different label combinations create different time series**.

---

### 5. Metric Format

The general format of a Prometheus metric is:

```
metric_name{label1="value1", label2="value2", label3="value3"}
```

* Metric name comes first
* Labels go inside `{ }`
* Labels are separated by commas

---

### 6. Example: Authentication API Metrics

Imagine an authentication API where we want to track how often it is called.

#### Metric name:

```
authentication_api_hits_total
```

#### Labels:

* `account_id="12345"`
* `response_time_ms="800"`

#### Full time series example:

```
authentication_api_hits_total{account_id="12345", response_time_ms="800"}
```

Each time the API is hit:

* The **counter increases by 1**
* A new data point is recorded with:

  * Current timestamp
  * Updated value

> Important:
> Labels describe *metadata*.
> The **metric value** (e.g., the counter increment) is stored separately, not as a label.

---

### 7. Key Takeaways

* Prometheus stores data as **time series**
* Every time series = **metric name + labels**
* Labels are **key–value pairs** used for filtering and aggregation
* Timestamps are automatically attached
* Different label values = different time series






# PromQL and Prometheus Data Types

Prometheus comes with a powerful query language called **PromQL (Prometheus Query Language)**.
Using PromQL, you can **read, filter, and calculate metrics** stored in Prometheus.

Before we deep-dive into writing PromQL queries, we must first understand the **data types** available in Prometheus.

These data types are used:

* When **storing metrics** in Prometheus
* When **retrieving metrics** using PromQL (via UI or API)

---

## 1. Scalar (Scalar Data Type)

A **scalar** is a **single numeric value**.

* Scalars can be **integers** or **floating-point numbers**
* In Prometheus, **all numbers are treated as floats**

Examples:

* `1`
* `1.5`
* `200`

---

## 2. Labels Are Always Strings

Labels in Prometheus are **always strings**, even if they look like numbers.

### Example Metric

```
prometheus_http_requests_total{code="200", job="prometheus"}
```

Here:

* `code="200"` → **string**, not a number
* `job="prometheus"` → string

Important:

* Label values **must be enclosed in quotes**
* Both **double quotes (" ")** and **single quotes (' ')** are accepted

---

## 3. String Matching vs Numeric Matching

### String Matching Example

```
prometheus_http_requests_total{job="prometheus", code=~"2.*"}
```

What this means:

* `code=~"2.*"` is a **regular expression**
* Match **any code starting with 2**

  * `200`, `201`, `204`, `205`, etc.

This works **only because `code` is a string**.

---

### Numeric Matching (Wrong Usage)

```
prometheus_http_requests_total{code=200}
```

This returns **no results**, because:

* `code` is stored as a **string**
* You are comparing it as a **number**

Lesson:

> Labels are metadata → always strings
> Metric values are numbers → used for calculations

---

## 4. Instant Vector

An **instant vector** is:

> A set of time series, each with **one single value** at a specific timestamp.

### How to Create an Instant Vector

* Use **only the metric name**
* Optionally apply label filters

Example:

```
auth_api_hits_total
```

Result:

* One value **per time series**
* All values sampled at the **same timestamp**

That’s why it’s called **instant**.

---

### Filtering an Instant Vector

```
auth_api_hits_total{count="1", time_taken="800"}
```

This:

* Selects only time series matching the labels
* Still returns **one value per series**

---

## 5. Range Vector

A **range vector** is similar to an instant vector, but:

> Instead of one value, it returns **multiple values over time**

### Syntax

```
metric_name[time_range]
```

Example:

```
auth_api_hits_total[5m]
```

Meaning:

* Return **all samples from the last 5 minutes**
* Time range is **always in the past**

---

### Supported Time Units (Case-Sensitive)

| Unit | Meaning      |
| ---- | ------------ |
| `ms` | milliseconds |
| `s`  | seconds      |
| `m`  | minutes      |
| `h`  | hours        |
| `d`  | days (24h)   |
| `w`  | weeks (7d)   |
| `y`  | years (365d) |

Notes:

* There is **no month unit**
* Units are **case-sensitive**

---

## 6. Range Vector Example in Prometheus UI

Example metric:

```
node_network_transmit_errs_total
```

### Instant Vector

```
node_network_transmit_errs_total
```

Result:

* Multiple rows
* Each row has **one value**
* Same timestamp
* Different label values (e.g., `device="eth0"`, `device="lo"`)

---

### Range Vector

```
node_network_transmit_errs_total[5m]
```

Result:

* Same metrics
* Each metric has **multiple values**
* Values depend on:

  1. Time range (`5m`)
  2. Scrape interval

---

### Scrape Interval Impact

If:

* Scrape interval = **15s**
* Time range = **5 minutes**

Then:

```
5 minutes ÷ 15 seconds = ~20 data points
```

---

## 7. PromQL Arithmetic Operators

PromQL supports arithmetic operations:

| Operator | Meaning        |
| -------- | -------------- |
| `+`      | addition       |
| `-`      | subtraction    |
| `*`      | multiplication |
| `/`      | division       |
| `%`      | modulo         |
| `^`      | power          |

---

## 8. Scalar + Instant Vector

When you apply a scalar to an instant vector:

> The scalar is applied to **every element** in the vector

Example:

```
node_cpu_seconds_total + 5
```

If values were:

```
5
6
```

Result:

```
10
11
```

Important:

* The **original vector is not modified**
* PromQL always returns a **new vector**

---

## 9. Instant Vector + Instant Vector

When applying arithmetic between two instant vectors:

* Prometheus matches **metric name + labels**
* Only **matching series appear in the result**

### Example

Vector A:

```
m1{label="a"} = 10
m1{label="b"} = 20
m1{label="c"} = 30
```

Vector B:

```
m1{label="a"} = 5
m1{label="b"} = 2
```

Query:

```
A + B
```

Result:

```
m1{label="a"} = 15
m1{label="b"} = 22
```

`label="c"` is **excluded** because it does not exist in both vectors.

---

## Key Takeaways

* Labels are **always strings**
* Scalars are **single numeric values**
* Instant vectors = one value per time series
* Range vectors = multiple values over time
* Arithmetic operations:

  * Scalar + Vector → applied to every element
  * Vector + Vector → matched by labels
* PromQL **never mutates existing data**









# PromQL Binary Operators, Filters, Aggregations, and Time Offset

To write **meaningful queries in Prometheus**, we need to understand:

1. **Binary comparison operators**
2. **Set binary operators**
3. **Label filtering (selectors)**
4. **Aggregation operators**
5. **Time offset**
6. **How Prometheus visualizes results**

---

## 1. Binary Comparison Operators

Prometheus supports **six comparison (binary) operators**:

| Operator | Meaning               |
| -------- | --------------------- |
| `==`     | equal                 |
| `!=`     | not equal             |
| `>`      | greater than          |
| `<`      | less than             |
| `>=`     | greater than or equal |
| `<=`     | less than or equal    |

How these operators behave depends on the **data types** on the left and right sides.

---

### Scalar vs Scalar Comparison

If you compare two scalar values:

```
10 == 10
```

Result:

```
1
```

In Prometheus:

* `1` represents **true**
* `0` represents **false**

Example:

```
10 == 5 → 0
```

---

### Instant Vector vs Scalar

Imagine an instant vector:

| Metric | Label | Value |
| ------ | ----- | ----- |
| `m`    | `a`   | 10    |
| `m`    | `b`   | 4     |

Query:

```
m == 10
```

Result:

* Only the time series where the value equals `10` remains

Output:

```
m{label="a"} = 10
```

The comparison is applied **to every element** in the instant vector.

---

### Instant Vector vs Instant Vector

When comparing **two instant vectors**:

* Only time series that **exist in both vectors** (same metric name + labels) are compared
* Only matching elements appear in the result

Example:

```
A == B
```

Result:

* Only elements present in **both A and B**
* Only if their values satisfy the comparison

If you use `>` instead of `==`:

* You get elements where the **left-side value is greater than the right-side value**

---

## 2. Set Binary Operators

Prometheus has **three set operators**:

| Operator | Meaning              |
| -------- | -------------------- |
| `and`    | intersection         |
| `or`     | union                |
| `unless` | left-only difference |

Important:

* **Case-sensitive**
* Work **only with instant vectors**
* Do NOT compare values — they compare **existence of time series**

---

### `and`

Returns only time series that exist **in both vectors**

```
A and B
```

---

### `or`

Returns the **union** of both vectors

```
A or B
```

---

### `unless`

Returns time series from the **left vector** that do NOT exist in the right vector

```
A unless B
```

---

## 3. Label Filtering (Selectors)

A PromQL query always looks like:

```
metric_name{label1="value1", label2="value2"}
```

Each comma means **AND**.

Example:

```
prometheus_http_requests_total{code="200", job="prometheus"}
```

Meaning:

* Metric name must match
* `code` must be `"200"`
* `job` must be `"prometheus"`

---

### Label Match Operators

| Operator | Meaning              |
| -------- | -------------------- |
| `=`      | exact match          |
| `!=`     | not equal            |
| `=~`     | regex match          |
| `!~`     | regex does NOT match |

---

### Regex Matching Example

```
code=~"2.*"
```

Matches:

* `200`, `201`, `204`, `205`

Important rule:

* Always ensure your regex **cannot match an empty string**
* Use `.*` when you want to ignore remaining characters

---

### Label Type Matters

Labels are **always strings**.

This works:

```
le="1000"
```

This does NOT work:

```
le=1000
```

Prometheus does **not auto-convert types**.

---

## 4. Aggregation Operators

Aggregation operators:

* Work on **a single instant vector**
* Return a **new instant vector**
* Usually reduce the number of time series

---

### Common Aggregation Operators

| Operator        | Description                   |
| --------------- | ----------------------------- |
| `sum`           | sum of values                 |
| `min`           | smallest value                |
| `max`           | largest value                 |
| `avg`           | average                       |
| `count`         | number of elements            |
| `group`         | group labels only (value = 1) |
| `count_values`  | count by value                |
| `topk(k, …)`    | top K largest                 |
| `bottomk(k, …)` | bottom K smallest             |
| `stddev`        | standard deviation            |
| `stdvar`        | variance                      |

---

### Basic Aggregation Syntax

```
sum(metric_name)
```

Example:

```
sum(node_cpu_seconds_total)
```

Result:

* One value (sum of all elements)

---

### Grouping with `by`

```
sum(metric_name) by (label)
```

Example:

```
sum(node_cpu_seconds_total) by (mode)
```

Result:

* One value **per mode**

---

### Excluding Labels with `without`

```
sum(metric_name) without (label)
```

This aggregates while **ignoring** a label.

---

### `topk` and `bottomk`

```
topk(3, node_cpu_seconds_total)
bottomk(3, node_cpu_seconds_total)
```

Returns:

* Largest or smallest values

---

### `group`

```
group(metric_name)
```

Important:

* Values are always `1`
* Only labels matter

```
group(metric_name) by (mode)
```

Returns one row per `mode`, value = `1`.

---

## 5. Time Offset

By default, Prometheus returns the **latest scrape**.

To query **past data**, use `offset`.

---

### Offset Syntax

```
metric_name offset 10m
```

Examples:

* `offset 10m`
* `offset 8h`
* `offset 10d`

Meaning:

> “Give me the value from that time in the past”

---

### Offset Example

```
prometheus_http_requests_total
```

Latest value:

```
21
```

```
prometheus_http_requests_total offset 8m
```

Past value:

```
20
```

---

### Important Offset Rule

**Offset must be applied directly to the metric**, NOT after aggregation.

Correct:

```
avg(prometheus_http_requests_total offset 8h) by (code)
```

Incorrect:

```
avg(prometheus_http_requests_total) by (code) offset 8h
```

---

## 6. Graph View vs Table View

* **Instant vectors** → can be graphed
* **Range vectors** → cannot be graphed directly

This fails:

```
metric_name[5m]
```

Because it returns a **range vector**.

---

### Aggregation Required for Graphs

This shows flat lines:

```
group(metric_name) by (code)
```

Because value = `1`.

This shows meaningful graphs:

```
avg(metric_name) by (code)
sum(metric_name) by (code)
count(metric_name) by (code)
```

---

## Final Key Takeaways

* Comparison operators return `1` or `0`
* Set operators work on **existence**, not values
* Labels are always **strings**
* Aggregations reduce vectors
* `group` always returns value = `1`
* `offset` must be applied **before aggregation**
* Graphs require numeric values










# PromQL Functions – Part 1 (Time & Utility Functions)

Now that we’ve learned about **operators in Prometheus**, it’s time to learn about **functions**.

PromQL functions are extremely important.
You will use them **constantly** when:

* Writing queries
* Building dashboards
* Creating alerts

In total, we will cover these functions across **four lectures**.
In this lecture, we’ll focus on **basic time-based and utility functions**.

---

## 1. `day_of_month()` and `day_of_week()`

These are **time-based functions**.

### Input

* Both functions accept an **instant vector**
* The value must represent **time in seconds (Unix timestamp)**
* Time is evaluated in **UTC**

---

### `day_of_month()`

```
day_of_month(<instant_vector>)
```

Returns:

* A number between **1 and 31**
* Represents the **day of the month**

---

### `day_of_week()`

```
day_of_week(<instant_vector>)
```

Returns:

* A number between **1 and 7**

Mapping:

* `1` → Monday
* `7` → Sunday

---

## 2. `delta()` and `idelta()`

These two functions are very similar.

### Important Rules

* They work **only on gauges**
* They do **NOT work on counters**
* They compare the **first and last samples** in the time window

---

### `delta()`

```
delta(<range_vector>)
```

* Accepts a **range vector**
* Calculates:

  ```
  last_value − first_value
  ```

Example:

```
delta(node_cpu_temp[2h])
```

Meaning:

> “How much did the CPU temperature change over the last 2 hours?”

---

### `idelta()`

```
idelta(<range_vector>)
```

* Uses **only the last two samples**
* More sensitive to short-term changes
* Useful for quick fluctuations

---

## 3. `absent()`

This is a **very important and commonly used function**, especially in alerts.

### Purpose

Check whether an **instant vector is empty**

⚠️ The behavior is **counterintuitive**, so pay attention.

---

### Behavior of `absent()`

```
absent(<instant_vector>)
```

| Input Vector  | Result                             |
| ------------- | ---------------------------------- |
| Has values    | **Empty result**                   |
| Has no values | **One time series with value = 1** |

So:

* If data exists → returns nothing
* If data is missing → returns `1`

---

### Example

```
absent(node_cpu_seconds_total)
```

Result:

* Empty (because data exists)

```
absent(node_cpu_seconds_total{cpu="fake"})
```

Result:

* One time series
* Value = `1`

This is how Prometheus detects **missing metrics**.

---

## 4. `absent_over_time()`

Same idea as `absent()`, but works with **range vectors**.

### Syntax

```
absent_over_time(<range_vector>)
```

Example:

```
absent_over_time(node_cpu_seconds_total[1h])
```

### Key Points

* Input: **range vector**
* Output: **instant vector**
* If data is missing → returns `1`
* If data exists → returns empty

You **cannot** use `absent()` with range vectors — that’s why this function exists.

---

## 5. Mathematical Functions

These functions modify **values inside an instant vector**.

---

### `abs()`

```
abs(<instant_vector>)
```

* Converts all values to **absolute values**
* Example:

  * `-5` → `5`

---

### `ceil()`

```
ceil(<instant_vector>)
```

* Rounds values **up**
* Example:

  * `1.6` → `2`

---

### `floor()`

```
floor(<instant_vector>)
```

* Rounds values **down**
* Example:

  * `1.6` → `1`

---

## 6. Clamp Functions (Very Important)

Clamp functions are extremely useful for **visualization and dashboards**.

They allow you to **trim values** that are too small or too large.

---

### `clamp()`

```
clamp(<instant_vector>, min, max)
```

* Removes values:

  * Less than `min`
  * Greater than `max`

---

### `clamp_min()`

```
clamp_min(<instant_vector>, min)
```

* Removes values **below min**
* Keeps everything else

---

### `clamp_max()`

```
clamp_max(<instant_vector>, max)
```

* Removes values **above max**
* Keeps everything else

---

### Examples

```
clamp_min(node_cpu_seconds_total, 300)
```

Result:

* All values < 300 are removed

```
clamp_max(node_cpu_seconds_total, 150000)
```

Result:

* All values > 150000 are removed

```
clamp(node_cpu_seconds_total, 300, 150000)
```

Result:

* Values are **trimmed between 300 and 150000**

---

### Why Clamp Is Useful

* Prevents outliers from ruining graphs
* Makes dashboards **clean and readable**
* Very common in **Grafana visualizations**

---

## Key Takeaways

* `day_of_month()` and `day_of_week()` work on time values
* `delta()` and `idelta()` work **only on gauges**
* `absent()` and `absent_over_time()` detect missing data
* Mathematical functions modify values
* Clamp functions are critical for **dashboard hygiene**
* Many functions accept **range vectors but return instant vectors**











# PromQL Functions – Part 2 (Math, Sorting, Time & Alerts)

In Prometheus, besides operators, we also have **many built-in functions**.
These functions are heavily used in **dashboards, alerts, and troubleshooting**.

In this lecture, we cover:

1. Logarithmic & utility functions
2. Sorting & time functions
3. Aggregation over time
4. Alerts and Alertmanager (concept + hands-on)

---

## 1. Logarithmic Functions

### `log2()`

```
log2(<instant_vector>)
```

* Returns the **binary logarithm** (base-2)
* Example:

  * Value = `2` → result = `1`
  * Value = `8` → result = `3`

---

### `log10()`

```
log10(<instant_vector>)
```

* Returns the **decimal logarithm**
* Example:

  * Value = `10` → result = `1`
  * Value = `100` → result = `2`

---

### `ln()`

```
ln(<instant_vector>)
```

* Returns the **natural logarithm**
* Base = **e**
* Function name is **lowercase**

---

## 2. Sorting Functions

### `sort()`

```
sort(<instant_vector>)
```

* Sorts values in **ascending order**

---

### `sort_desc()`

```
sort_desc(<instant_vector>)
```

* Sorts values in **descending order**

---

### Example

If you previously used:

```
clamp(node_cpu_seconds_total, 300, 150000)
```

Then:

```
sort(...)
```

→ starts from `300` → ends at `150000`

```
sort_desc(...)
```

→ starts from `150000` → ends at `300`

---

## 3. Time Functions

### `time()`

```
time()
```

* Returns the **current Unix timestamp**
* Not guaranteed to be exact current second

---

### `timestamp()`

```
timestamp(<instant_vector>)
```

* Returns the timestamp **when each sample was scraped**
* Output value = timestamp

---

### Offset + Timestamp Example

```
timestamp(node_cpu_seconds_total offset 1h)
```

* Returns timestamps from **one hour ago**
* Notice how timestamps change with `offset`

---

## 4. Aggregation Over Time Functions

Normal aggregation functions work on **instant vectors**.

When you use **range vectors**, you must use **`*_over_time` functions**.

---

### Common Aggregation-Over-Time Functions

| Function             | Purpose            |
| -------------------- | ------------------ |
| `avg_over_time()`    | average            |
| `sum_over_time()`    | sum                |
| `min_over_time()`    | minimum            |
| `max_over_time()`    | maximum            |
| `count_over_time()`  | number of samples  |
| `stddev_over_time()` | standard deviation |
| `stdvar_over_time()` | variance           |

---

### Example

This **fails**:

```
avg(node_cpu_seconds_total[2h])
```

Correct:

```
avg_over_time(node_cpu_seconds_total[2h])
```

---

### Filtering + Over Time

```
avg_over_time(node_cpu_seconds_total{cpu="0"}[2h])
```

* Averages CPU `0`
* Over the last **2 hours**
* Returns an **instant vector**

---

## 5. Why Alerts Matter

Imagine you are monitoring an API.

* Errors suddenly spike at **4:30 PM**
* Developer fixes it later
* Users experience failures before you notice

This is the **point of chaos**.

### Goal of Alerts

* Detect problems **before chaos**
* Give engineers **time to react**
* Avoid:

  * Too many alerts (noise)
  * Alerts too late (damage already done)

We define a **threshold**:

* Not too low (avoid flapping)
* Not too high (avoid late alerts)

---

## 6. Prometheus Alerts vs Alertmanager

### Prometheus

* Evaluates alert rules
* Shows alerts in the **UI only**

### Alertmanager

* Receives alerts from Prometheus
* Sends notifications:

  * Email
  * Slack
  * PagerDuty
  * OpsGenie
  * Webhooks
* Handles:

  * Deduplication
  * Grouping
  * Throttling

---

### Why Alertmanager Is Required

Without Alertmanager:

* Each Prometheus instance sends alerts independently
* Duplicate alerts everywhere

With Alertmanager:

* Same alerts are **grouped**
* Only **one notification** is sent
* Repeated alerts are **batched**

---

## 7. Creating an Alert Rule (YAML)

Alerts are defined in **YAML rule files**.

### Rule File Structure

```yaml
groups:
- name: alerts
  rules:
  - alert: NodeExporterDown
    expr: up{job="node_exporter"} == 0
```

Explanation:

* `groups` → required
* `rules` → list of alert rules
* `alert` → alert name
* `expr` → PromQL expression

This alert fires when:

* Node Exporter is **not reachable**

---

## 8. Linking Rules to Prometheus

In `prometheus.yml`:

```yaml
rule_files:
  - "rules/*.yml"
```

* Paths are **relative**
* You can load multiple rule files

---

## 9. Reloading Prometheus

After adding rules:

* Linux:

  ```
  systemctl restart prometheus
  ```
* Homebrew (macOS):

  ```
  brew services restart prometheus
  ```
* Windows:

  * Stop the process
  * Start Prometheus again

---

## 10. Viewing Alerts in Prometheus UI

Go to:

```
Status → Alerts
```

States:

* 🟢 **Inactive** → condition not met
* 🔴 **Firing** → alert active

Click the alert:

* See expression
* See duration
* Evaluate the query manually

---

## 11. Testing the Alert

Stop Node Exporter:

* Linux:

  ```
  systemctl stop node_exporter
  ```
* macOS:

  ```
  brew services stop node_exporter
  ```

After ~1 minute:

* Alert turns **red**
* Status = **Firing**

Restart Node Exporter:

* Alert returns to **green**

---

## 12. Pre-Built Alert Rules (Very Important Tip)

There is a **community-maintained repository** with ready-to-use alert rules for:

* Linux
* Windows
* Docker
* Kubernetes
* MySQL / PostgreSQL
* Kafka
* Elasticsearch
* RabbitMQ
* NGINX / Apache
* Cloud services

You **do not need to write alerts from scratch**.

Best practice:

* Copy
* Adjust labels / thresholds
* Use in production

This saves **huge amounts of time**.

---

## Key Takeaways

* Log functions help normalize values
* Sorting helps with visibility
* Aggregation-over-time works on range vectors
* Alerts detect issues **before chaos**
* Prometheus evaluates alerts
* Alertmanager sends notifications
* Deduplication prevents alert spam
* Always reuse community alert rules










# Improving Prometheus Alerts with `for`, Labels, Annotations & Alertmanager Setup

So far, we’ve learned how to write **basic alerts** in Prometheus.
Now it’s time to make our alerts **smarter, quieter, and more informative**.

In this lecture, we cover:

1. The `for` clause (time-based alert stability)
2. Using `absent()` vs comparisons
3. Adding **labels** and **annotations**
4. Alert templating (`$labels`, `$value`)
5. Alertmanager recap
6. Installing Alertmanager (Windows, macOS, Linux)

---

## 1. Why We Need the `for` Clause

In the previous lecture, we created an alert like this:

```yaml
expr: up{job="node_exporter"} == 0
```

By default:

* Prometheus evaluates alert rules **every 1 minute**
* If the expression is true for **one evaluation**, the alert fires

### The Problem

Some applications have:

* Temporary failures
* Intermittent network issues
* Self-healing behavior

We **do not want false alerts**.

---

## 2. Using the `for` Clause

The `for` clause tells Prometheus:

> “Only fire this alert if the condition stays true for a specific duration.”

### Syntax (YAML indentation matters!)

```yaml
for: 5m
```

Supported time units:

* `s` – seconds
* `m` – minutes
* `h` – hours
* `d` – days
* `w` – weeks
* `y` – years

---

### Updated Alert Example

```yaml
groups:
- name: alerts
  rules:
  - alert: NodeExporterDown
    expr: up{job="node_exporter"} == 0
    for: 5m
```

Meaning:

* The exporter must be down **continuously for 5 minutes**
* Only then does the alert fire

---

## 3. Using `absent()` Instead of Comparisons

Previously, we wrote:

```yaml
expr: up{job="node_exporter"} == 0
```

An alternative (often cleaner) approach is using `absent()`.

### Reminder: How `absent()` Works

* Returns **nothing** if data exists
* Returns **1** if data is missing
* In Prometheus: `1 = true`

### Cleaner Alert Expression

```yaml
expr: absent(up{job="node_exporter"})
```

This alert fires when:

* No target exists with `job="node_exporter"`

Both approaches are valid.
Use whichever is **more readable for your team**.

---

## 4. Adding Context with Labels

Alerts are often received by **people who didn’t write them**.

We must add **metadata**.

### Labels

Labels are key-value pairs attached to the alert.

```yaml
labels:
  team: team-alpha
  severity: critical
```

* `team` → who owns the alert
* `severity` → how serious it is

Labels are mainly used by **Alertmanager routing rules**.

---

## 5. Adding Context with Annotations

Annotations are **human-readable descriptions**.

```yaml
annotations:
  summary: "Node exporter is down"
  description: "Node exporter on {{ $labels.instance }} is not reachable"
```

* `summary` → short message
* `description` → detailed explanation

---

## 6. Alert Templating (`$labels`, `$value`)

Prometheus supports **templates** inside annotations.

### Available Variables

* `$labels` → all labels of the time series
* `$labels.instance` → specific label
* `$value` → result of the alert expression

⚠️ Always wrap templates in **quotes** in YAML.

---

### Example with Templates

```yaml
annotations:
  summary: "{{ $labels.instance }} node exporter is down"
  description: |
    Job: {{ $labels.job }}
    Instance: {{ $labels.instance }}
    Value: {{ $value }}
```

This gives **rich context** in Slack, email, PagerDuty, etc.

---

## 7. Full Alert Rule Example

```yaml
groups:
- name: alerts
  rules:
  - alert: NodeExporterDown
    expr: absent(up{job="node_exporter"})
    for: 5m
    labels:
      severity: critical
      team: team-alpha
    annotations:
      summary: "Node exporter down on {{ $labels.instance }}"
      description: "Node exporter has been unreachable for 5 minutes."
```

---

## 8. Seeing Alerts in Prometheus UI

Go to:

```
Status → Alerts
```

Alert states:

* 🟢 **Inactive** – condition not met
* 🔴 **Firing** – alert active

Clicking the alert shows:

* Expression
* Duration
* Labels
* Annotations
* Evaluation timestamp (UTC)

---

## 9. Alertmanager Recap

Alertmanager is an official Prometheus component.

### What It Does

* Converts **alerts → notifications**
* Sends alerts to:

  * Email
  * Slack
  * PagerDuty
  * OpsGenie
  * Webhooks
* Deduplicates alerts
* Groups related alerts
* Silences alerts during maintenance

Prometheus **does NOT send notifications** by itself.

---

## 10. Alertmanager UI

* Runs on port **1993**
* Example:

  ```
  http://localhost:1993
  ```
* UI is **read-only**
* Configuration happens only via YAML

---

## 11. Installing Alertmanager – Windows

1. Go to Prometheus download page
2. Download **Alertmanager (Windows AMD64)**
3. Extract the ZIP
4. Files inside:

   * `alertmanager.exe`
   * `alertmanager.yml`
5. Run:

   ```
   alertmanager.exe
   ```
6. Access UI:

   ```
   http://localhost:1993
   ```

---

## 12. Installing Alertmanager – macOS (MacPorts)

Homebrew does **not** support Alertmanager.

### Steps

1. Install MacPorts
2. Run:

   ```bash
   sudo port install alertmanager
   sudo port load alertmanager
   ```
3. Config file location:

   ```
   /opt/local/etc/alertmanager.yml
   ```
4. Restart after changes:

   ```bash
   sudo port unload alertmanager
   sudo port load alertmanager
   ```

---

## 13. Installing Alertmanager – Linux (Ubuntu)

### Steps Overview

1. Download Alertmanager binary

2. Extract files

3. Move to:

   ```
   /var/lib/alertmanager
   ```

4. Create:

   ```
   /var/lib/alertmanager/data
   ```

5. Set ownership:

   ```bash
   chown -R prometheus:prometheus /var/lib/alertmanager
   chmod -R 755 /var/lib/alertmanager
   ```

6. Create systemd service:

   ```
   /etc/systemd/system/alertmanager.service
   ```

7. Reload and start:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start alertmanager
   sudo systemctl enable alertmanager
   ```

8. Access UI:

   ```
   http://<server-ip>:1993
   ```

---

## Key Takeaways

* `for` prevents alert flapping
* `absent()` is cleaner for missing targets
* Labels route alerts
* Annotations explain alerts
* Templates add dynamic context
* Alertmanager handles notifications
* UI is **read-only**
* Configuration is always YAML-based











# Advanced Alerting: Routes, Matchers, Inhibition, Silencing & Recording Rules

In this lecture, we cover **how Alertmanager actually works internally**, how alerts are **routed**, how to **send notifications to different channels**, how to **silence and inhibit alerts**, and finally we introduce **recording rules**.

---

## 1. How Alertmanager Works Internally

We already know the high-level flow:

```
Prometheus → Alertmanager → Notifications
```

But inside **Alertmanager**, there is an important decision process.

### Internal Flow

1. Prometheus raises an alert
2. Alertmanager receives the alert
3. Alertmanager evaluates **routes**
4. Routes contain **matchers**
5. If a matcher matches alert labels:

   * Alert is sent to a **receiver**
6. Receiver sends notification to:

   * Email
   * Slack
   * PagerDuty
   * OpsGenie
   * Webhooks

---

## 2. Matchers and Routes

### Matchers

Matchers define **conditions** based on alert labels.

Examples:

* `severity = critical`
* `team = billing`
* Regex matches like `service =~ "billing.*"`

> Matchers work **only on alert labels**, not on metric values.

---

### Legacy vs Modern Matching

* **Deprecated (legacy)**:

  * `match`
  * `match_re`
* **Recommended (modern)**:

  * `matchers`

Always use **matchers** in new configurations.

---

### Route Concept

Each route has:

* Matchers (conditions)
* A receiver (destination)

If a route matches:

* Alert is sent to the configured receiver

---

## 3. Multiple Receivers Example (Email)

You can define multiple receivers:

```yaml
receivers:
- name: default-email
  email_configs:
  - to: ops@example.com

- name: urgent-email
  email_configs:
  - to: urgent@example.com
```

---

### Routing Based on Severity

```yaml
route:
  receiver: default-email
  routes:
  - receiver: urgent-email
    matchers:
    - severity="critical"
```

Behavior:

* All alerts → default email
* Critical alerts → urgent email

---

## 4. Sending Alerts to Slack (Incoming Webhooks)

Slack uses **Incoming Webhooks**.

### Steps in Slack

1. Create or choose a channel
2. Go to **Integrations**
3. Install **Incoming Webhooks**
4. Choose the channel
5. Copy the **Webhook URL**
6. (Optional) Customize icon or emoji

---

### Alertmanager Slack Receiver Example

```yaml
receivers:
- name: slack-alerts
  slack_configs:
  - api_url: "https://hooks.slack.com/services/XXX/YYY/ZZZ"
    channel: "#udemy-prometheus"
```

Restart Alertmanager → Alerts go to Slack.

---

## 5. PagerDuty Integration

PagerDuty is used for **on-call incident management**.

### Steps in PagerDuty

1. Go to **Services**
2. Select a service
3. Go to **Integrations**
4. Add integration → **Prometheus**
5. Copy the **Integration Key**

---

### PagerDuty Receiver Example

```yaml
receivers:
- name: pagerduty-alerts
  pagerduty_configs:
  - service_key: "PAGERDUTY_INTEGRATION_KEY"
```

Route alerts to PagerDuty using matchers as before.

---

## 6. Silencing Alerts (Temporary)

**Silencing**:

* Temporary
* Done via **Alertmanager UI**
* Used during maintenance or deployments

Examples:

* Silence alerts for 2 hours
* Silence alerts matching `team=billing`

Silencing does **not** change Prometheus behavior — only notifications.

---

## 7. Inhibiting Alerts (Permanent Logic)

**Inhibition**:

* Defined in Alertmanager config
* Suppresses alerts **based on other alerts**
* Used to reduce noise

---

### Inhibition Example Scenario

* Alert A: **Server is down**
* Alert B: **Website is down**

If the server is down:

* Website alert is redundant
* Suppress Alert B

---

### Inhibit Rule Example

```yaml
inhibit_rules:
- source_matchers:
  - team="team-alpha"
  target_matchers:
  - team="team-beta"
  equal:
  - instance
```

Meaning:

* If a Team Alpha alert is firing
* Suppress Team Beta alerts
* When `instance` label is equal

---

### Important Rule

* Inhibition happens **only in Alertmanager**
* Prometheus will still show both alerts
* Only notifications are suppressed

---

## 8. Recording Rules (Why We Need Them)

### Problem

PromQL calculations like:

* `avg()`
* `sum()`
* `count()`

can be **expensive** when:

* You have thousands of metrics
* Dashboards refresh frequently
* Data volume is large

---

### Solution: Recording Rules

**Recording rules precompute values** and store them as new metrics.

Instead of calculating:

```
avg(sensor_temperature)
```

Every time, you:

* Compute it once
* Store it as:

```
sensor_temperature_avg
```

---

### Real-World Example

Imagine:

* Thousands of IoT sensors
* Hundreds of hotels
* Constant dashboards

Calculating averages on demand becomes slow.

Recording rules:

* Compute periodically
* Store results
* Dashboards become fast

---

## 9. Recording Rule Concept

A recording rule:

* Runs a PromQL expression
* Saves the result as a **new metric**

Example idea:

```
iot_temperature_avg
```

Computed every scrape interval.

---

## 10. Recording Rules File Structure

Recording rules are defined in **YAML**, similar to alert rules.

Example:

```yaml
groups:
- name: iot-rules
  rules:
  - record: iot_temperature_avg
    expr: avg(iot_temperature)
```

---

## 11. Where Recording Rules Live

### Linux

```
/etc/prometheus/rules/
```

### macOS / Windows

* Same directory as `prometheus.yml`
* Create a `rules/` folder
* Reference it in config

---

### Prometheus Config

```yaml
rule_files:
  - "rules/*.yml"
```

Restart Prometheus after changes.

---

## 12. Alerting Rules vs Recording Rules

| Feature            | Alerting Rule | Recording Rule     |
| ------------------ | ------------- | ------------------ |
| Purpose            | Raise alerts  | Precompute metrics |
| Output             | Alert         | New metric         |
| Stored             | No            | Yes                |
| Used in dashboards | Indirect      | Yes                |
| Used in alerts     | Yes           | Yes                |

---

## Key Takeaways

* Routes decide **where alerts go**
* Matchers work on **labels**
* Slack & PagerDuty use webhooks
* Silencing = temporary
* Inhibition = rule-based suppression
* Recording rules improve performance
* Recording rules create **new metrics**











# Recording Rules and Prometheus Client Libraries (Python)

---

## Part 1: Writing a Recording Rule

### Why Recording Rules Matter

Recording rules are used to:

* **Precompute expensive PromQL expressions**
* Store the result as a **new metric**
* Improve **dashboard and alert performance**

Instead of repeatedly calculating:

```
avg(rate(node_cpu_seconds_total[5m])) by (cpu)
```

We compute it once and store it as:

```
cpu:node_cpu_seconds_total:avg_rate
```

---

## Step 1: Build the PromQL Expression First

Let’s start with an existing metric:

```
node_cpu_seconds_total
```

This metric:

* Is a **counter**
* Has many labels (`cpu`, `mode`, `instance`, etc.)

---

### ❌ This is not useful:

```
avg(node_cpu_seconds_total)
```

It returns **one number**, losing all context.

---

### ✅ Grouping makes it meaningful:

```
avg by (cpu) (node_cpu_seconds_total)
```

But this still doesn’t work well, because:

* Counters must use `rate()` or `irate()`
* We also need a **time window**

---

### ✅ Correct Expression for Recording Rule

```
avg by (cpu) (
  rate(node_cpu_seconds_total[5m])
)
```

This:

* Converts the counter into a rate (per second)
* Produces an **instant vector**
* Can be graphed
* Is ideal for recording rules

---

## Step 2: Create the Recording Rule File

### File Location

* Linux:

  ```
  /etc/prometheus/rules/
  ```
* macOS / Windows:

  * Create a `rules/` directory
  * Place it next to `prometheus.yml`

---

### Example File Name

```
recording-rules.yml
```

---

## Step 3: Recording Rule YAML Structure

```yaml
groups:
- name: node-exporter-recording-rules
  rules:
  - record: cpu:node_cpu_seconds_total:avg_rate
    expr: avg by (cpu) (
      rate(node_cpu_seconds_total[5m])
    )
    labels:
      exporter_type: node
```

### Naming Convention (Best Practice)

```
<labels>:<metric_name>:<operation>
```

Example:

```
cpu:node_cpu_seconds_total:avg_rate
```

---

## Step 4: Load the Rule in Prometheus

In `prometheus.yml`:

```yaml
rule_files:
  - "rules/*.yml"
```

Restart Prometheus:

* Linux:

  ```
  systemctl restart prometheus
  ```
* macOS:

  ```
  brew services restart prometheus
  ```
* Windows:
  Restart the Prometheus process

---

## Step 5: Verify the New Metric

In Prometheus UI:

```
cpu:node_cpu_seconds_total:avg_rate
```

This metric:

* Behaves like any normal metric
* Can be aggregated again
* Can be used in alerts and dashboards

Example:

```
sum(cpu:node_cpu_seconds_total:avg_rate)
```

---

## Key Takeaways (Recording Rules)

* Always build the query **first**
* Counters → `rate()` → aggregate
* Recording rules create **new metrics**
* Great for dashboards and alerts
* Reduce query load dramatically

---

# Part 2: Short-Lived Jobs & Client Libraries

---

## What Are Short-Lived Jobs?

Short-lived jobs:

* Do not run continuously
* Start → do work → exit
* Cannot always be scraped

Examples:

* Batch jobs
* Background tasks
* One-time functions

For these cases, Prometheus provides:

* **Client libraries**
* **Pushgateway** (covered later)

---

## Official Prometheus Client Libraries

Prometheus provides **official client libraries** for:

* Go
* Java
* Python
* Ruby

There are many **community-maintained libraries** as well (e.g., .NET).

---

# Part 3: Prometheus Client Library (Python)

---

## Step 1: Install the Client Library

```bash
pip install prometheus-client
```

---

## Step 2: Simple Python App (No Web Framework)

Prometheus client includes a **built-in HTTP server**, perfect for console apps.

---

### Example: Summary Metric

```python
from prometheus_client import start_http_server, Summary
import random
import time

REQUEST_TIME = Summary(
    'request_processing_seconds',
    'Time spent processing requests'
)

@REQUEST_TIME.time()
def process_request(t):
    time.sleep(t)

if __name__ == "__main__":
    start_http_server(8000)
    while True:
        process_request(random.random())
```

Visit:

```
http://localhost:8000/metrics
```

---

## Step 3: Counters

### Counter Basics

```python
from prometheus_client import Counter

MY_COUNTER = Counter(
    'my_counter',
    'Example counter'
)
```

⚠️ Prometheus **automatically adds `_total`** to counters.

---

### Incrementing Counters

```python
MY_COUNTER.inc()
MY_COUNTER.inc(5)
```

* Counters reset when the application restarts
* Values exist only while the app is running

---

### Counting Exceptions

```python
@MY_COUNTER.count_exceptions()
def process_request():
    raise Exception("error")
```

---

## Step 4: Gauges

### Gauge Definition

```python
from prometheus_client import Gauge

MY_GAUGE = Gauge(
    'my_gauge',
    'Example gauge'
)
```

---

### Gauge Operations

```python
MY_GAUGE.set(5)
MY_GAUGE.inc(5)
MY_GAUGE.dec(2)
```

Final value:

```
8
```

---

## Step 5: Adding Labels to Metrics

### Define Labels

```python
MY_COUNTER = Counter(
    'my_counter',
    'Counter with labels',
    ['name', 'age']
)
```

---

### Assign Label Values

```python
MY_COUNTER.labels(name="John", age="30").inc()
```

⚠️ All labels must be assigned values.

---

## Step 6: Expose App to Prometheus

### Prometheus Target

```yaml
- job_name: "python-app"
  static_configs:
  - targets: ["localhost:8000"]
```

Restart Prometheus.

---

### Verify in Prometheus

Query:

```
my_counter_total{name="John", age="30"}
```

You’ll also see:

* `job`
* `instance`

Labels added automatically by Prometheus.

---

## Key Takeaways (Client Libraries)

* Client libraries expose `/metrics`
* Python client works without Flask
* Counters, Gauges, Summaries are easy
* Labels add powerful dimensions
* App restart resets metrics
* Prometheus handles scraping










# Prometheus Client Libraries

## Java Client Library (Simpleclient) & .NET Client Library

---

## Part 1: Prometheus Java Client Library

### Overview

Prometheus provides an **official Java client library** called **simpleclient**.
It allows Java applications to expose metrics that Prometheus can scrape.

GitHub repository:

```
https://github.com/prometheus/client_java
```

### Key Java Client Modules

| Module                   | Purpose                                |
| ------------------------ | -------------------------------------- |
| simpleclient             | Core metrics (Counter, Gauge, Summary) |
| simpleclient_httpserver  | Embedded HTTP server for `/metrics`    |
| simpleclient_pushgateway | Push metrics (for short-lived jobs)    |

For this lecture we use:

* `simpleclient`
* `simpleclient_httpserver`

---

## Step 1: Add Maven Dependencies

In your `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>io.prometheus</groupId>
    <artifactId>simpleclient</artifactId>
    <version>0.16.0</version>
  </dependency>

  <dependency>
    <groupId>io.prometheus</groupId>
    <artifactId>simpleclient_httpserver</artifactId>
    <version>0.16.0</version>
  </dependency>
</dependencies>
```

---

## Step 2: Create a Basic Java Application

```java
import io.prometheus.client.Counter;
import io.prometheus.client.Gauge;
import io.prometheus.client.Summary;
import io.prometheus.client.exporter.HTTPServer;

public class PrometheusApp {

    static final Counter counter = Counter.build()
        .name("java_random_counter")
        .help("Example Java counter")
        .register();

    static final Gauge gauge = Gauge.build()
        .name("java_random_gauge")
        .help("Example Java gauge")
        .register();

    static final Summary summary = Summary.build()
        .name("java_process_time")
        .help("Time spent processing")
        .register();

    public static void main(String[] args) throws Exception {

        HTTPServer server = new HTTPServer(8000);

        counter.inc();
        counter.inc(4.5);

        gauge.set(100);
        gauge.inc(10);
        gauge.dec(5);

        Summary.Timer timer = summary.startTimer();
        try {
            Thread.sleep(1000);
        } finally {
            timer.observeDuration();
        }

        Thread.currentThread().join();
    }
}
```

---

## What Prometheus Sees

Visit:

```
http://localhost:8000/metrics
```

You will see:

* `java_random_counter_total = 5.5`
* `java_random_gauge = 105`
* `java_process_time_count = 1`
* `java_process_time_sum ≈ 1`

### Important Prometheus Behavior

* **Counters always end with `_total`**
* Metrics reset when the application restarts
* Summary produces:

  * `_count`
  * `_sum`

---

## Adding Labels (Java)

### Define Labels

```java
static final Counter labeledCounter = Counter.build()
    .name("java_labeled_counter")
    .help("Counter with labels")
    .labelNames("foo", "bar")
    .register();
```

### Use Labels (Mandatory!)

```java
labeledCounter.labels("1", "2").inc();
```

⚠️ Once labels are defined:

* You **must always use `.labels()`**
* Calling `.inc()` directly will throw an exception

---

## Summary (Java)

| Metric Type | Purpose              |
| ----------- | -------------------- |
| Counter     | Only increases       |
| Gauge       | Can go up/down       |
| Summary     | Duration & frequency |

---

# Part 2: Prometheus .NET Client Library

### Important Note

.NET is **not an official Prometheus client**, but the community library
**`prometheus-net`** is widely used and production-grade.

NuGet package:

```
prometheus-net
```

---

## Step 1: Install NuGet Package

```bash
Install-Package prometheus-net
```

---

## Step 2: Create Metrics in .NET Console App

```csharp
using Prometheus;

class Program
{
    private static readonly Counter counter =
        Metrics.CreateCounter("dotnet_counter", "Example counter");

    private static readonly Gauge gauge =
        Metrics.CreateGauge("dotnet_gauge", "Example gauge");

    private static readonly Summary summary =
        Metrics.CreateSummary("dotnet_summary", "Example summary");

    static void Main()
    {
        var server = new MetricServer(port: 8000);
        server.Start();

        counter.Inc();
        gauge.Set(100);
        gauge.Dec(10);

        using (summary.NewTimer())
        {
            Thread.Sleep(1000);
        }

        while (true)
        {
            Thread.Sleep(1000);
        }
    }
}
```

---

## Adding Labels (.NET)

### Dynamic Labels

```csharp
var labeledGauge = Metrics.CreateGauge(
    "dotnet_labeled_gauge",
    "Gauge with labels",
    new[] { "foo", "bar" }
);

labeledGauge
    .WithLabels("1", "2")
    .Set(100);
```

⚠️ Same rule:

* Once labels exist → **must always use `WithLabels()`**

---

## Static Labels (Per Metric)

```csharp
var gauge = Metrics.CreateGauge(
    "dotnet_env_gauge",
    "Gauge with static labels",
    new GaugeConfiguration
    {
        LabelNames = new[] { "foo", "bar" },
        StaticLabels = new Dictionary<string, string>
        {
            { "environment", "dev" }
        }
    }
);
```

---

## Global Static Labels (All Metrics)

```csharp
Metrics.DefaultRegistry.SetStaticLabels(
    new Dictionary<string, string>
    {
        { "country", "us" }
    }
);
```

Now **every metric** includes:

```
country="us"
```

---

## Counting Exceptions (.NET)

```csharp
counter.CountExceptions(() =>
{
    try
    {
        throw new NotImplementedException();
    }
    catch
    {
        // swallow exception
    }
});
```

* Exception still occurs
* Metric increments automatically
* Exception handling is **your responsibility**

---

## Prometheus Configuration

```yaml
scrape_configs:
  - job_name: "java"
    static_configs:
      - targets: ["localhost:8000"]

  - job_name: "dotnet"
    static_configs:
      - targets: ["localhost:8000"]
```

Restart Prometheus after changes.

---

## Final Key Takeaways

### Java

* Official Prometheus client
* Uses embedded HTTP server
* Strongly typed, explicit registration

### .NET

* Community-driven but mature
* Very flexible label handling
* Supports global static labels

### Universal Rules

* Counters reset on restart
* Labels must always be populated
* `/metrics` endpoint is mandatory
* Prometheus scrapes — clients only expose








# Prometheus with ASP.NET Core (.NET Core Web Application)

## Using `prometheus-net` to Expose Metrics to Prometheus

---

## Goal of This Lecture

In this lecture, we will learn how to:

* Use the **Prometheus .NET client library** (`prometheus-net`)
* Expose metrics from an **ASP.NET Core web application**
* Scrape those metrics using **Prometheus**
* Understand why **service discovery** and **Pushgateway** are needed later

---

## Step 1: Create an ASP.NET Core Web Application

1. Add a new project to your solution
2. Choose **ASP.NET Core Web Application**
3. Name it something like:

```
Prometheus.Web.Auth
```

4. Choose:

   * Authentication: **None**
   * HTTPS: optional
   * Framework: .NET 6 / .NET 7 (either is fine)

---

## Step 2: Add Required NuGet Packages

Open **NuGet Package Manager** and install:

### Required

* `prometheus-net`
* `prometheus-net.AspNetCore`

### Optional (Best Practice)

* `prometheus-net.AspNetCore.HealthChecks`

These packages allow:

* Metric creation
* `/metrics` endpoint
* Health check metrics

---

## Step 3: Expose `/metrics` Endpoint

Open `Startup.cs` (or `Program.cs` for minimal hosting).

Inside `Configure` (or middleware section):

```csharp
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
    endpoints.MapMetrics(); // exposes /metrics
});
```

This automatically creates:

```
/metrics
```

If you run the app and visit:

```
http://localhost:<port>/metrics
```

You will already see **default runtime metrics**, such as:

* Thread count
* GC collections
* Process CPU
* Memory usage

These are exposed automatically by `prometheus-net`.

---

## Step 4: Create a Custom Counter (Controller Example)

Imagine we want to count how many times an API endpoint is hit.

### Example: HomeController

```csharp
using Prometheus;
using Microsoft.AspNetCore.Mvc;

public class HomeController : Controller
{
    private static readonly Counter IndexCounter =
        Metrics.CreateCounter(
            "index_action_total",
            "Number of times Index action is called"
        );

    public IActionResult Index()
    {
        IndexCounter.Inc();
        return Ok("Hello from Prometheus!");
    }
}
```

Now:

* Every request increments the counter
* Metric appears automatically in `/metrics`
* Prometheus can scrape it without extra configuration

---

## Step 5: Add Health Checks (Best Practice)

### Register Health Checks

In `ConfigureServices`:

```csharp
services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy());
```

### Map Health Check Endpoint

```csharp
app.UseEndpoints(endpoints =>
{
    endpoints.MapHealthChecks("/health");
    endpoints.MapMetrics();
});
```

---

## Health Check Metrics in Prometheus

Prometheus automatically exposes health checks as metrics:

```
aspnetcore_healthcheck_status{name="self"} 1
```

Meaning:

* `1` → Healthy
* `0` → Unhealthy

This allows **monitoring health without polling `/health` manually**.

---

## Summary So Far

You now have:

* `/metrics` endpoint
* Default runtime metrics
* Custom counters and gauges
* Health checks exposed as Prometheus metrics

---

# Why Static Scrape Configs Are Not Enough

Up to now, we used static targets in `prometheus.yml`:

```yaml
static_configs:
  - targets: ["localhost:5000"]
```

This works **only if**:

* IPs never change
* Number of servers is fixed

### Problems in Cloud Environments

* Auto Scaling Groups
* VM scale-out / scale-in
* Ephemeral IPs
* Serverless functions (no IPs)

Prometheus **cannot scrape what it doesn’t know exists**.

---

# Solution 1: Service Discovery

Prometheus supports **native service discovery**, configured entirely in `prometheus.yml`.

Common discovery types:

* AWS EC2
* AWS Lightsail
* Kubernetes
* DNS
* File-based
* GCP
* Azure

No extra Prometheus components required.

---

## Why Load Balancers Don’t Work for Scraping

If Prometheus scrapes a **Load Balancer**:

* Requests are round-robin
* Metrics are mixed across instances
* You lose instance-level visibility
* Labels become unreliable

Prometheus **must scrape each instance directly**.

---

# Solution 2: Pushgateway (Special Cases)

Some workloads **cannot be scraped**:

* AWS Lambda
* Azure Functions
* Batch jobs
* Short-lived processes

### Pushgateway Solves This

* Applications **push** metrics
* Pushgateway stores them temporarily
* Prometheus scrapes Pushgateway

⚠️ Important:

> Pushgateway does **not** make Prometheus push-based
> It is a **buffer**, not a database

---

# Introduction to Service Discovery in Prometheus

Service discovery is configured in `prometheus.yml`.

Examples:

* `ec2_sd_configs`
* `kubernetes_sd_configs`
* `dns_sd_configs`
* `file_sd_configs`

---

## AWS EC2 Service Discovery (Concept)

```yaml
scrape_configs:
  - job_name: "ec2"
    ec2_sd_configs:
      - region: ap-southeast-2
        port: 9100
```

Prometheus:

* Discovers instances
* Updates targets dynamically
* Scrapes node exporters

---

## Filtering EC2 Instances (Important)

You rarely scrape *all* instances.

You filter using:

* Tags
* Instance state
* Availability zone
* Instance type

### Example: Filter by Tag

```yaml
filters:
  - name: tag:Environment
    values: ["prod"]
```

---

## Relabeling (Critical Skill)

Relabeling allows you to:

* Build labels
* Replace IPs
* Drop unwanted targets
* Control `__address__`

### Example: Use Public IP Instead of Private IP

```yaml
relabel_configs:
  - source_labels: [__meta_ec2_public_ip]
    target_label: __address__
    replacement: "$1:9100"
```

This is **mandatory** if Prometheus is **outside AWS**.

---

## File-Based Service Discovery

Used when:

* Cloud provider is unsupported
* Custom environments
* On-prem / hybrid setups

---

### Example File: `targets.yml`

```yaml
- targets:
  - localhost:9100
  labels:
    team: alpha
```

---

### Prometheus Config

```yaml
scrape_configs:
  - job_name: "file_sd"
    file_sd_configs:
      - files:
        - /etc/prometheus/file_sd/*.yml
```

Best practice:

* Use wildcard (`*`)
* Let automation update files
* No Prometheus restart required

---

## When to Use Each Method

| Method        | Use Case                    |
| ------------- | --------------------------- |
| Static        | Local dev, POC              |
| EC2 SD        | AWS VMs                     |
| Kubernetes SD | Kubernetes                  |
| File SD       | Custom / unsupported clouds |
| Pushgateway   | Serverless / batch jobs     |

---

## Final Takeaway

You now understand:

* How ASP.NET Core exposes metrics
* How Prometheus scrapes applications
* Why static configs fail in cloud
* When to use service discovery
* Why Pushgateway exists


