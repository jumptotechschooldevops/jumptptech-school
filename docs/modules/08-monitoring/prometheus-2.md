---
title: "Prometheus #2"
description: "Installing Pushgateway on Windows and macOS (Mac)            1. Quick Review: What Is..."
published: 2026-02-01
source: "https://dev.to/jumptotech/prometheus-2-1j5i"
tags: []
---

# Prometheus #2



# Installing Pushgateway on Windows and macOS (Mac)

## 1. Quick Review: What Is Pushgateway?

Normally, **Prometheus** works by **scraping metrics** from targets (servers, applications, exporters).

However, **scraping is not always possible**.

### When Pushgateway Is Used

Pushgateway is designed for scenarios such as:

* **Short-lived jobs** (batch jobs, cron jobs)
* **Serverless workloads** (e.g., AWS Lambda)
* **Jobs behind load balancers**
* **Jobs that terminate before Prometheus can scrape them**

In these cases:

* The application **pushes metrics** instead of being scraped
* You use a **Prometheus client library** (Python, Go, Java, etc.)
* Metrics are sent to **Pushgateway**
* Prometheus **scrapes Pushgateway**

### Important Architecture Note

* Pushgateway **does NOT replace Prometheus**
* It is a **component that works with Prometheus**
* It **does not need to be on the same server**, but:

  * If you have one server, installing it together is fine

---

## 2. Downloading Pushgateway

### Step 1: Go to Prometheus Website

1. Open:
   👉 [https://prometheus.io](https://prometheus.io)
2. Navigate to **Downloads**
3. Scroll down to **Pushgateway**

You will see platform-specific packages.

---

## 3. Installing Pushgateway on Windows

### Step 1: Download

* Choose:
  **Windows → windows-amd64.zip**

### Step 2: Extract

* Unzip the file
* You will get a folder containing:

  * `pushgateway.exe`

### Step 3: Run Pushgateway

Open **Command Prompt** or **PowerShell**, navigate to the folder, and run:

```bash
pushgateway.exe --help
```

This confirms the binary works and shows available options.

---

## 4. Installing Pushgateway on macOS (Mac)

### Important Note About macOS

At the time of this lecture:

* Pushgateway is **NOT available via Homebrew**
* It is **NOT available via MacPorts**
* You must install it **manually**

### Step 1: Download

* Choose:
  **Darwin → darwin-amd64.tar.gz**

### Step 2: Extract

```bash
tar -xvzf pushgateway-*.tar.gz
cd pushgateway-*
```

You will see the binary named:

```bash
pushgateway
```

### Step 3: Run Pushgateway

```bash
./pushgateway --help
```

---

## 5. Running Pushgateway

### Default Behavior

* Pushgateway listens on **port 9091**
* Same port is used for:

  * **Pushing metrics**
  * **Scraping metrics**
* Default metrics endpoint:

  ```
  /metrics
  ```

### Example: Start Pushgateway on a Custom Port

To start Pushgateway on **port 9092**:

```bash
./pushgateway --web.listen-address=":9092"
```

### Verify Pushgateway Is Running

Open your browser:

```
http://localhost:9092/metrics
```

You should see **internal Pushgateway metrics**, which means it’s working.

---

## 6. Pushgateway Configuration Options (Brief Overview)

Run:

```bash
./pushgateway --help
```

You will notice:

* **Configuration file support** (experimental)
* **Admin API**

  * Used for deleting metrics
  * In production, this should usually be **disabled** for security

Example (disable admin API):

```bash
./pushgateway --web.enable-admin-api=false
```

---

## 7. Connecting Pushgateway to Prometheus

Pushgateway must be added as a **scrape target** in Prometheus.

### Step 1: Edit `prometheus.yml`

Add a new scrape job:

```yaml
scrape_configs:
  - job_name: "pushgateway"
    static_configs:
      - targets:
          - "localhost:9092"
```

### Step 2: Restart Prometheus

After restarting Prometheus:

* Go to **Prometheus UI**
* Navigate to **Status → Targets**
* You should see **pushgateway** listed as **UP**

---

## 8. Key Concept to Remember

* Pushgateway behaves like an **exporter**
* Prometheus **scrapes Pushgateway**
* Applications **push metrics to Pushgateway**
* Prometheus **never scrapes the application directly** in this model















# Installing Pushgateway on Ubuntu and Sending Metrics Using Python

## 1. What We Will Do in This Lecture

In this lecture, we will:

1. Install **Pushgateway** on an **Ubuntu server**
2. Run Pushgateway as a **systemd service**
3. Send custom metrics to Pushgateway using **Python**
4. Verify those metrics in **Prometheus**

In the **previous lecture**, we already:

* Installed Pushgateway on Mac/Windows
* Added Pushgateway as a **scrape target** in Prometheus

Now we move to **real metric pushing**.

---

## 2. Downloading Pushgateway for Ubuntu (Linux)

### Step 1: Go to Prometheus Downloads

1. Open:
   👉 [https://prometheus.io/download](https://prometheus.io/download)
2. Scroll down to **Pushgateway**
3. You will see three packages:

   * Windows
   * **Linux (middle option)**
   * macOS (Darwin)

We need the **Linux AMD64** package.

### Step 2: Copy the Download URL

Right-click the Linux Pushgateway link and **copy the full URL**.

---

## 3. Installing Pushgateway on Ubuntu

### Step 1: Connect to the Ubuntu Server

```bash
ssh ubuntu@<SERVER_IP>
```

(You can also connect as another user if applicable.)

---

### Step 2: Download Pushgateway

```bash
wget <PASTE_PUSHGATEWAY_LINUX_URL_HERE>
```

Example:

```bash
wget https://github.com/prometheus/pushgateway/releases/download/v1.7.0/pushgateway-1.7.0.linux-amd64.tar.gz
```

---

### Step 3: Extract the Package

```bash
tar -xvzf pushgateway-*.tar.gz
cd pushgateway-*
```

Inside the directory, you will see a binary named:

```bash
pushgateway
```

---

### Step 4: Verify the Binary

```bash
./pushgateway --help
```

**Why this is important:**

* Confirms you downloaded the correct binary
* Shows configuration options
* Confirms default port **9091**

Important defaults:

* **Port:** `9091`
* **Metrics endpoint:** `/metrics`
* Same port is used for **push + scrape**

---

## 4. Installing Pushgateway as a systemd Service

### Step 1: Move Binary to `/usr/local/bin`

```bash
sudo cp pushgateway /usr/local/bin/
```

---

### Step 2: Set Ownership (Recommended)

If Prometheus is running as user `prometheus`:

```bash
sudo chown prometheus:prometheus /usr/local/bin/pushgateway
```

> If Prometheus is **not** installed on this server, create a `prometheus` user and group first.

---

### Step 3: Create systemd Service File

```bash
sudo nano /etc/systemd/system/pushgateway.service
```

Paste the following:

```ini
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/pushgateway \
  --web.listen-address=":9091" \
  --web.enable-admin-api=false
Restart=always

[Install]
WantedBy=multi-user.target
```

Save and exit.

---

### Step 4: Reload systemd and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl start pushgateway
sudo systemctl enable pushgateway
```

---

### Step 5: Verify Service Status

```bash
systemctl status pushgateway
```

You should see:

```
Active: active (running)
```

---

### Step 6: Verify in Browser

Open:

```
http://<SERVER_IP>:9091/metrics
```

You should see **Pushgateway internal metrics**.

---

## 5. Sending Metrics to Pushgateway Using Python

Now we will **push custom metrics**.

---

## 6. Installing Prometheus Python Client

Make sure Python 3 and pip are installed.

```bash
pip3 install prometheus-client
```

---

## 7. Why We Need a Custom Registry

Prometheus has a **default registry**.

When pushing metrics:

* We **must NOT use the default registry**
* We must create a **new CollectorRegistry**
* This avoids **metric name collisions**

---

## 8. Python Code: Push Metrics to Pushgateway

Create a file:

```bash
nano push_metrics.py
```

Paste the following:

```python
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
import time

# Create a new registry (NOT default)
registry = CollectorRegistry()

# Create a Gauge metric
job_runtime = Gauge(
    'batch_job_runtime_seconds',
    'Runtime of batch job',
    registry=registry
)

# Set a value (example: current time)
job_runtime.set(time.time())

# Push metric to Pushgateway
push_to_gateway(
    'localhost:9091',
    job='demo_batch_job',
    registry=registry
)
```

Save and exit.

---

## 9. Run the Python Script

```bash
python3 push_metrics.py
```

This sends the metric to Pushgateway.

---

## 10. Verify Metric in Prometheus

1. Open Prometheus UI
2. Go to **Graph**
3. Enter metric name:

```text
batch_job_runtime_seconds
```

4. Click **Execute**

You should see your metric value.

---

## 11. Key Takeaways (Very Important)

* Pushgateway is used when **scraping is impossible**
* Applications **push metrics**
* Prometheus **scrapes Pushgateway**
* Always use a **custom CollectorRegistry**
* Pushgateway should be treated as **temporary storage**
* Do **not** use Pushgateway for long-running services














# Sending Metrics to Pushgateway from Jobs (Java & .NET)

In this lecture, we will learn how to **send metrics to Pushgateway from jobs**, instead of letting **Prometheus** scrape them directly.

We will cover:

* Sending metrics from a **Java job**
* Sending metrics from a **.NET console application**
* Understanding **Collector Registry / Registry**
* Verifying metrics in Prometheus

---

## 1. Why Pushgateway for Jobs?

Pushgateway is used when:

* Jobs are **short-lived**
* Jobs **start and exit** before Prometheus can scrape them
* Examples:

  * Batch jobs
  * CI/CD jobs
  * One-time scripts
  * Serverless executions

In these cases:

* The job **pushes metrics**
* Prometheus **scrapes Pushgateway**
* Pushgateway acts as **temporary storage**

---

## 2. Important Concept: Collector Registry (Very Important)

Prometheus stores metrics in a structure called a **Collector Registry**.

### Default Collector Registry

* Exists automatically
* Every metric you create is registered here by default

### Why Default Registry Cannot Be Used with Pushgateway

When pushing metrics:

* You **must not use the default registry**
* Otherwise:

  * Metrics may conflict
  * Old metrics may mix with new ones
  * Duplicate names cause problems

### Correct Approach

* Create a **new Collector Registry**
* Register your metrics **only** in that registry
* Push **that registry** to Pushgateway

This rule applies to:

* Java
* Python
* .NET
* Any Prometheus client

---

# PART 1: Sending Metrics from Java to Pushgateway

## 3. Java Project Setup (Quick Recap)

* Java project created
* Prometheus client already installed using **Maven**
* (Covered in earlier lecture, not repeated here)

---

## 4. Required Java Imports

```java
import io.prometheus.client.Gauge;
import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.exporter.PushGateway;
```

These give us:

* `Gauge` → metric type
* `CollectorRegistry` → custom registry
* `PushGateway` → pushing mechanism

---

## 5. Java Code: Push Metric to Pushgateway

```java
public class PushGatewayJob {

    public static void main(String[] args) throws Exception {

        // Create Pushgateway instance
        PushGateway pushGateway = new PushGateway("localhost:9091");

        // Create custom registry (NOT default)
        CollectorRegistry registry = new CollectorRegistry();

        // Create Gauge and register it to custom registry
        Gauge jobGauge = Gauge.build()
                .name("java_pushgateway_job_metric")
                .help("Sample metric pushed from Java job")
                .register(registry);

        // Set value (example: current time)
        jobGauge.set(System.currentTimeMillis());

        // Push metrics
        pushGateway.push(registry, "java_batch_job");
    }
}
```

---

## 6. Key Points (Java)

* `CollectorRegistry` is mandatory
* Metric is registered using:

  ```java
  .register(registry)
  ```
* `job` name is used for grouping
* Job can push once or repeatedly (loop if needed)

---

## 7. Verify in Prometheus

In Prometheus UI → Graph:

```text
java_pushgateway_job_metric
```

Click **Execute** → metric appears.

---

# PART 2: Sending Metrics from .NET to Pushgateway

Now let’s do the same thing using **.NET**.

---

## 8. Create .NET Console Application

* Create a new **Console App**
* Name it something like:

  ```
  PushGatewayDotNetSample
  ```

---

## 9. Install Prometheus .NET Client

Add NuGet package:

```text
prometheus-net
```

---

## 10. Registry Concept in .NET

In .NET:

* Registry is created using `Metrics.NewCustomRegistry()`
* Metrics are created using a **metric factory**
* Factory is bound to that registry

This ensures:

* Metrics do NOT go to default registry
* Only pushed metrics are included

---

## 11. .NET Code: Push Metrics to Pushgateway

```csharp
using Prometheus;
using System;
using System.Threading;

class Program
{
    static void Main(string[] args)
    {
        // Create custom registry
        var registry = Metrics.NewCustomRegistry();

        // Create metric factory bound to registry
        var factory = Metrics.WithCustomRegistry(registry);

        // Create Pushgateway pusher
        var pusher = new MetricPusher(
            endpoint: "http://localhost:9091/metrics",
            job: "dotnet_pushgateway_job",
            instance: "instance-1",
            registry: registry
        );

        pusher.Start();

        // Create Gauge metric
        var gauge = factory.CreateGauge(
            "dotnet_pushgateway_metric",
            "Sample metric pushed from .NET job"
        );

        // Push values in a loop
        while (true)
        {
            gauge.Set(DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
            Thread.Sleep(1000);
        }

        // pusher.Stop(); (not reached in infinite loop)
    }
}
```

---

## 12. Important .NET Notes

* `MetricPusher` must be:

  * Started → `Start()`
  * Stopped → `Stop()`
* Metrics must be created **after Start**
* Metrics must use **factory**, not static `Metrics.CreateX()`

---

## 13. Verify .NET Metrics in Prometheus

In Prometheus UI → Graph:

```text
dotnet_pushgateway_metric
```

You will see:

* Job label → `dotnet_pushgateway_job`
* Instance label → `instance-1`
* Metric values updating

---

## 14. Why Graph Looks “Simple”

* Values are random or timestamps
* Purpose is **data flow demonstration**
* Real use cases:

  * Job duration
  * Success/failure count
  * Records processed
  * Execution time

---

## 15. Key Takeaways (Very Important)

* Pushgateway is for **jobs**, not services
* Never push to **default registry**
* Always use:

  * Custom registry
  * Custom metric factory
* Job & instance labels matter
* Pushgateway stores metrics **until overwritten or deleted**














# Securing Prometheus and Its Components (Authentication & HTTPS)

One of the most crucial aspects of any software system is **authentication and security**, and **Prometheus** is no exception.

Prometheus exposes:

* A **Web UI**
* **HTTP APIs**
* **Exporters**
* **Pushgateway**

If these endpoints are not protected, **anyone with network access** can:

* View metrics
* Query APIs
* Scrape exporters
* Push fake metrics

In this section, we will learn **how to secure Prometheus and its surrounding components**.

---

## 1. Security Mechanisms in Prometheus

Prometheus supports multiple security mechanisms:

### 1. Basic Authentication

* Username + password
* Used for:

  * Prometheus Web UI
  * Prometheus HTTP APIs

### 2. OAuth 2.0 / OIDC

* Used mostly for exporters or reverse proxies
* Integrates with identity providers

### 3. TLS / mTLS (Mutual TLS)

* Encrypts traffic
* Authenticates servers and/or clients
* Used for:

  * Prometheus
  * Exporters
  * Pushgateway

In this lecture, we focus on:

* **Basic Authentication**
* **HTTPS (TLS)**
* **Securing exporters (Node Exporter example)**

---

# PART 1: Securing Prometheus with Basic Authentication

## 2. What Basic Authentication Protects

Basic authentication protects:

* Prometheus Web UI (`/graph`, `/targets`, etc.)
* Prometheus HTTP APIs (`/api/v1/...`)

After enabling it:

* Browser prompts for **username + password**
* API clients must send credentials

---

## 3. Steps to Enable Basic Authentication

1. Choose a **strong username and password**
2. Hash the password using **bcrypt**
3. Create a **web configuration file**
4. Start Prometheus with `--web.config.file`

---

## 4. Generating a bcrypt Password Hash

Prometheus requires **bcrypt** hashes.

### Option 1: Using `htpasswd` (Linux / macOS)

Check if Apache tools are installed:

```bash
htpasswd
```

If available, generate bcrypt hash:

```bash
htpasswd -nBC 10 admin
```

* `-B` → bcrypt
* `-C 10` → cost factor (required by Prometheus)
* `admin` → username

You will be prompted to enter the password twice.

Output example:

```text
admin:$2y$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

### Option 2: Online Tool (Non-Production Only)

You can use:

* bcrypt hash generators (e.g., bcrypt-generator)

⚠️ **Only for learning / testing**, never production.

Make sure:

* Cost factor = **10**

---

## 5. Creating Prometheus Web Config File

Create a file called:

```text
web.yml
```

Example content:

```yaml
basic_auth_users:
  admin: $2y$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Notes:

* Indentation matters
* Username → bcrypt hash
* You can add **multiple users**

Example:

```yaml
basic_auth_users:
  admin: $2y$10$xxxx
  readonly: $2y$10$yyyy
```

---

## 6. Starting Prometheus with Basic Auth

Prometheus supports a **web configuration file** via:

```bash
--web.config.file
```

### Example (manual start)

```bash
prometheus \
  --config.file=prometheus.yml \
  --web.config.file=web.yml
```

---

### If Prometheus Runs as a Service

* **Linux (systemd)**
  Edit Prometheus service file and add:

```text
--web.config.file=/path/to/web.yml
```

* **macOS (Homebrew)**
  Edit:

```text
/usr/local/etc/prometheus.args
```

Add:

```text
--web.config.file=/usr/local/etc/web.yml
```

Restart:

```bash
brew services restart prometheus
```

---

## 7. Verifying Basic Authentication

Open browser:

```text
http://localhost:9090
```

Result:

* Browser prompts for **username + password**
* Prometheus UI loads after authentication

---

# PART 2: Enabling HTTPS (TLS) for Prometheus

By default, Prometheus uses **HTTP only**.

This means:

* Credentials are sent in plain text
* APIs are unencrypted

We now enable **HTTPS**.

---

## 8. Why HTTPS Is Required

Without HTTPS:

* Browsers reject secure integrations
* Tools like Grafana cannot securely connect
* Credentials are exposed

---

## 9. TLS Certificates Options

### Production

* Buy certificate from a trusted **Certificate Authority (CA)**

### Practice / Internal Use

* Generate **self-signed certificates**

---

## 10. Generating TLS Certificates Using OpenSSL

On macOS / Linux:

```bash
openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
  -keyout prometheus.key \
  -out prometheus.crt \
  -subj "/CN=localhost"
```

This creates:

* `prometheus.key` → private key
* `prometheus.crt` → certificate

---

## 11. Updating Prometheus Web Config for HTTPS

Edit `web.yml`:

```yaml
tls_server_config:
  cert_file: prometheus.crt
  key_file: prometheus.key

basic_auth_users:
  admin: $2y$10$xxxxxxxxxxxxxxxx
```

Important:

* Certificate files must be **readable** by Prometheus user
* Use **absolute paths** if files are elsewhere

---

## 12. Restart Prometheus

After restart:

* HTTP no longer works
* HTTPS is required

```text
https://localhost:9090
```

Browser may warn about:

> Self-signed certificate

This is expected.

---

# PART 3: Securing Exporters (Node Exporter Example)

Now we secure **exporters**, using **Node Exporter** as an example.

Goal:

* Prometheus → Exporter communication via **HTTPS**

---

## 13. Create Web Config for Node Exporter

Create:

```text
node-web.yml
```

Content:

```yaml
tls_server_config:
  cert_file: /full/path/prometheus.crt
  key_file: /full/path/prometheus.key
```

---

## 14. Start Node Exporter with Web Config

### Windows

```bash
node_exporter.exe --web.config.file=node-web.yml
```

### Linux (systemd)

Edit node exporter service:

```text
--web.config.file=/path/node-web.yml
```

Restart service.

---

### macOS (Homebrew)

Edit:

```text
/usr/local/etc/node_exporter.args
```

Add:

```text
--web.config.file=/full/path/node-web.yml
```

Restart:

```bash
brew services restart node_exporter
```

---

## 15. Verify Exporter HTTPS

Open browser:

```text
https://localhost:9100/metrics
```

You should see metrics after accepting the certificate warning.

---

## 16. Updating Prometheus to Scrape HTTPS Exporter

Edit `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "node"
    scheme: https
    tls_config:
      ca_file: /full/path/prometheus.crt
      server_name: localhost
    static_configs:
      - targets: ["localhost:9100"]
```

Notes:

* `scheme: https` is mandatory
* `server_name` must match certificate CN
* `ca_file` required for self-signed certs

---

## 17. Restart Prometheus and Verify

* Restart Prometheus
* Open **Targets** page
* Node exporter should be **UP**

Test metric:

```text
node_cpu_seconds_total
```
















# Securing Pushgateway and Alertmanager (Authentication & HTTPS)

In this lecture, we will complete the security setup of the Prometheus ecosystem by protecting:

* **Pushgateway**
* **Alertmanager**

The goal is to ensure that:

* No unauthorized user can **push fake metrics**
* No malicious user can **trigger or delete alerts**
* All communication is **authenticated and encrypted**

---

## 1. Why Pushgateway Must Be Secured

If Pushgateway is not protected:

* Anyone who can reach its endpoint can:

  * Push **fake metrics**
  * Corrupt dashboards
  * Trigger false alerts

Pushgateway supports **the same security model** as:

* **Prometheus**
* **Node Exporter**

This includes:

* Basic authentication
* HTTPS (TLS)
* Web configuration files

---

## 2. Pushgateway Supports `--web.config.file`

Run:

```bash
pushgateway --help
```

You will see:

```text
--web.config.file
```

This is the **same option** used by:

* Prometheus
* Node Exporter
* Alertmanager

👉 **All Prometheus components share the same web config format**

---

## 3. Creating Web Config for Pushgateway

You do **not** need to create a new file from scratch.

If you already created a web config for Node Exporter, you can **reuse or duplicate it**.

### Example: `pushgateway-web.yml`

```yaml
tls_server_config:
  cert_file: /usr/local/etc/prometheus/prom.crt
  key_file: /usr/local/etc/prometheus/prom.key

basic_auth_users:
  admin: $2y$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Notes:

* Structure is identical across components
* Username/password are bcrypt-hashed
* TLS and Basic Auth are combined

---

## 4. Starting Pushgateway with Security Enabled

Example (manual start):

```bash
pushgateway \
  --web.config.file=/usr/local/etc/prometheus/pushgateway-web.yml
```

Pushgateway will now:

* Listen on port **9091**
* Require **HTTPS**
* Require **username + password**

---

## 5. Verifying Pushgateway Security

Open a private browser window:

```text
https://localhost:9091
```

Result:

* Browser prompts for credentials
* Lock icon appears
* Connection is encrypted

✅ Pushgateway is now secured

---

## 6. Updating Python Code to Authenticate with Pushgateway

Now that Pushgateway is protected, **clients must authenticate**.

---

## 7. Pushgateway Python Client: Authentication Support

The `push_to_gateway()` function supports a **custom handler**.

We use:

* `basic_auth_handler`

---

## 8. Updated Python Code with Basic Authentication

```python
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
from prometheus_client.exposition import basic_auth_handler
import time

def auth_handler(url, method, timeout, headers, data):
    return basic_auth_handler(
        url, method, timeout, headers, data,
        username="admin",
        password="password"
    )

registry = CollectorRegistry()

gauge = Gauge(
    'python_pushgateway_metric',
    'Metric pushed securely',
    registry=registry
)

gauge.set(time.time())

push_to_gateway(
    'https://localhost:9091',
    job='python_secure_job',
    registry=registry,
    handler=auth_handler
)
```

---

## 9. Handling Self-Signed Certificates in Python

If you see SSL errors due to self-signed certs:

```bash
export SSL_CERT_FILE=/usr/local/etc/prometheus/prom.crt
```

This allows Python to trust the certificate.

---

## 10. Updating Prometheus to Scrape Secured Pushgateway

Prometheus must also:

* Use **HTTPS**
* Authenticate with Pushgateway

### Update `prometheus.yml`

```yaml
scrape_configs:
  - job_name: "pushgateway"
    scheme: https
    basic_auth:
      username: admin
      password: password
    tls_config:
      ca_file: /usr/local/etc/prometheus/prom.crt
      server_name: localhost
    static_configs:
      - targets: ["localhost:9091"]
```

Restart Prometheus.

---

## 11. Verifying Pushgateway Target

In Prometheus UI → **Targets**:

* Pushgateway should now be **UP**
* Previously red targets turn green once HTTPS + auth are configured

Check metric:

```text
python_pushgateway_metric
```

---

# PART 2: Securing Alertmanager

## 12. Why Alertmanager Must Be Secured

If Alertmanager is not protected:

* Anyone can:

  * Trigger fake alerts
  * Delete active alerts
  * Abuse the Admin API

Alertmanager supports:

* HTTPS
* Basic authentication
* Web config file (same format)

---

## 13. Alertmanager Web Config File

You can **reuse an existing web config**.

Example: `alertmanager-web.yml`

```yaml
tls_server_config:
  cert_file: /usr/local/etc/prometheus/prom.crt
  key_file: /usr/local/etc/prometheus/prom.key

basic_auth_users:
  admin: $2y$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 14. Starting Alertmanager Securely

### Manual start

```bash
alertmanager \
  --config.file=alertmanager.yml \
  --web.config.file=alertmanager-web.yml
```

Alertmanager listens on **9093** by default.

---

### Ubuntu (systemd)

Edit Alertmanager service:

```text
--web.config.file=/path/alertmanager-web.yml
```

Reload and restart service.

---

### macOS (MacPorts)

1. Copy web config to:

```text
/opt/local/etc/prometheus/alertmanager/
```

2. Edit plist file:

```text
/opt/local/etc/launchd/alertmanager.plist
```

3. Add:

```text
--web.config.file=/opt/local/etc/prometheus/alertmanager/alertmanager-web.yml
```

Reload service:

```bash
sudo port unload alertmanager
sudo port load alertmanager
```

---

## 15. Updating Prometheus to Talk to Secured Alertmanager

Edit `prometheus.yml`:

```yaml
alerting:
  alertmanagers:
    - scheme: https
      basic_auth:
        username: admin
        password: password
      tls_config:
        ca_file: /usr/local/etc/prometheus/prom.crt
        server_name: localhost
      static_configs:
        - targets:
            - localhost:9093
```

Restart Prometheus.

---

## 16. Verification

* Prometheus starts without errors
* Alerts continue to work
* Alertmanager UI prompts for credentials
* Communication is encrypted

















# Introduction to Grafana and Installing Grafana on Windows

Up to this point, we have learned a lot about **Prometheus**:

* How to **scrape metrics**
* How to **push metrics** (Pushgateway)
* How PromQL functions work
* How to **create rules and alerts**
* How to secure Prometheus and its components

This is a good time to introduce **Grafana**.

After this section, we will come back to **advanced Prometheus topics**, but first we need better visualization.

---

## 1. Why Do We Need Grafana?

Prometheus **does have graphs**, but they are:

* Basic
* Limited in customization
* Not suitable for complex dashboards

Example:

* You can graph `node_cpu_seconds_total`
* You can see time-based data
* But dashboards are **not flexible or advanced**

Grafana solves this problem.

---

## 2. What Is Grafana?

Grafana is an **open-source visualization and dashboarding tool**.

It is designed to:

* Visualize **time-series data**
* Build **advanced dashboards**
* Combine data from **multiple sources**

### Time-Series Reminder

A time-series is:

* A metric
* With a **timestamp**
* Stored over time

Prometheus is a **time-series database**, and Grafana is one of the **best visualization tools** for it.

---

## 3. Grafana Data Sources (Very Important)

A single Grafana dashboard can pull data from **multiple sources**:

* Prometheus
* MySQL / PostgreSQL
* SQL Server
* Amazon CloudWatch
* Elasticsearch
* Loki (logs)
* Tempo (traces)

👉 This allows you to **correlate data** from different systems on one dashboard.

---

## 4. Alerts in Grafana vs Prometheus

Grafana can also:

* Create **alerts**
* Send notifications (email, Slack, PagerDuty, etc.)

So a common design question is:

> Should alerts live in **Prometheus** or **Grafana**?

Typical approach:

* **Prometheus** → service health & infrastructure alerts
* **Grafana** → visualization-driven or cross-datasource alerts

Both approaches are valid.

---

## 5. Organizations, Users, and Access Control

Grafana supports:

* Multiple **organizations**
* Multiple **teams**
* Fine-grained **RBAC**
* Read-only users
* Admin users

This makes Grafana suitable for **large organizations**.

---

## 6. Grafana Deployment Options

Before installing Grafana, you must choose **how** to run it.

### Option 1: Grafana Cloud

Grafana Cloud is a **fully managed observability platform**.

#### Advantages

* No installation or maintenance
* Always up to date
* Managed scalability
* Free tier is enough for learning

You can sign up at:

```
https://grafana.com/products/cloud
```

#### Disadvantages

* Can be expensive at scale
* Vendor lock-in
* Data stored outside your infrastructure
* Possible compliance issues (GDPR, regulations)

---

### Option 2: Self-Hosted Grafana (On-Prem / VM / EC2)

#### Advantages

* Full control over data
* Better security and compliance
* Highly customizable
* Open-source version is **free**

#### Disadvantages

* Maintenance overhead
* You must handle upgrades
* You must design scalability
* Requires operational knowledge

---

## 7. How to Decide Between Cloud and Self-Hosted

Ask yourself:

* Do we have engineers to maintain it?
* Do we need customization?
* Are there compliance restrictions?
* What is our budget?
* Do we want full control over data?

There is **no single correct answer**.

---

# Installing Grafana on Windows

Now let’s install **Grafana on Windows**.

---

## 8. Download Grafana for Windows

1. Go to:

```
https://grafana.com
```

2. Click **Get Grafana**
3. Navigate to **Download**
4. Select **Windows**

Download the **Windows Installer (.exe)**.

---

## 9. Install Grafana

1. Run the installer
2. Choose the installation directory
   👉 **Remember this location**
3. Complete the installation

Grafana will be installed as a **Windows service**.

---

## 10. Verify Grafana Service

1. Open **Services**
2. Look for:

```
Grafana
```

3. Ensure it is:

* Running
* Startup type = Automatic (recommended)

If it is stopped, start it manually.

---

## 11. Grafana Configuration File (Windows)

Navigate to the installation directory, usually:

```
C:\Program Files\GrafanaLabs\grafana\
```

Inside, you will find:

```
conf\
  └── defaults.ini
```

This is Grafana’s **default configuration file**.

⚠️ Best practice:

* Do NOT edit `defaults.ini` directly
* Copy it and override settings later if needed

For now, just be aware of it.

---

## 12. Default Grafana Port

Grafana listens on:

```
http://localhost:3000
```

You can change this later if:

* Port is occupied
* Firewall blocks it

---

## 13. First Login to Grafana

Open browser:

```
http://localhost:3000
```

Default credentials:

* **Username:** `admin`
* **Password:** `admin`

On first login:

* Grafana **forces password change**
* Choose a strong password














# Installing Grafana on macOS, Linux, and Docker

In this section, we will learn **multiple ways to install Grafana**, depending on your operating system and use case.

You can install Grafana on:

* macOS (Homebrew)
* Ubuntu
* Amazon Linux / Red Hat
* Docker (standalone or docker-compose)

The **core concepts and configuration files are the same** across all installations.

---

## Part 1: Installing Grafana on macOS (Homebrew – Recommended)

### 1. Verify Homebrew Is Installed

Open Terminal and run:

```bash
brew --version
```

If you see a version number, Homebrew is installed.

If not:

* Go to [https://brew.sh](https://brew.sh)
* Follow the installation instructions

---

### 2. Install Grafana Using Homebrew

```bash
brew install grafana
```

This installs **Grafana Open Source**, which is perfect for learning and most real-world use cases.

---

### 3. Grafana Configuration Location (macOS)

After installation, navigate to:

```bash
/usr/local/etc/grafana/
```

You will see:

```text
grafana.ini
```

This is Grafana’s **main configuration file**.

---

### 4. Best Practice: Use `custom.ini`

Do **not** edit `grafana.ini` directly.

Instead:

```bash
cp grafana.ini custom.ini
```

Always make changes in:

```text
custom.ini
```

This protects you from accidental misconfiguration and upgrades overwriting your settings.

---

### 5. Important Settings to Review (macOS)

Open `custom.ini` in an editor (nano or VS Code).

#### a) Server Port

```ini
[server]
http_port = 3000
```

* Default port: **3000**
* If you change the port:

  * **Remove the semicolon (`;`)**
  * Otherwise the line is ignored

---

#### b) Database Configuration

By default:

```ini
[database]
type = sqlite3
```

Other supported options:

* MySQL
* PostgreSQL

You may switch databases by:

* Removing the semicolon
* Changing `type`
* Providing host, user, password

SQLite is fine for:

* Single instance
* Learning
* Local setups

External DB is recommended when:

* Running Grafana in Docker
* Running multiple Grafana instances
* You need persistence across restarts

---

#### c) Logs Location

```ini
[paths]
logs = /var/log/grafana
```

Knowing this path is critical for:

* Debugging startup issues
* Plugin failures
* Authentication problems

---

### 6. Start / Restart Grafana (macOS)

Check service status:

```bash
brew services info grafana
```

Restart after config changes:

```bash
brew services restart grafana
```

---

### 7. Access Grafana (macOS)

Open browser:

```text
http://localhost:3000
```

Default credentials:

* Username: **admin**
* Password: **admin**

You will be forced to change the password on first login.

---

## Part 2: Installing Grafana on Ubuntu

### 8. Update Package Index (Important)

```bash
sudo apt update
```

This step is mandatory. Skipping it causes dependency failures.

---

### 9. Install Required Dependencies

```bash
sudo apt install -y adduser libfontconfig1 musl
```

`musl` is a critical C library required by Grafana.

---

### 10. Download Grafana Debian Package

Get the latest `.deb` package from Grafana documentation.

Example (amd64):

```bash
wget https://dl.grafana.com/oss/release/grafana_<version>_amd64.deb
```

If your system is ARM:

* Use `arm64` instead of `amd64`

---

### 11. Install Grafana

```bash
sudo dpkg -i grafana_*.deb
```

---

### 12. Enable and Start Grafana Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Verify:

```bash
sudo systemctl status grafana-server
```

You should see **active (running)**.

---

### 13. Access Grafana (Ubuntu)

Open browser:

```text
http://<SERVER_PUBLIC_IP>:3000
```

Make sure:

* Port **3000** is allowed in security groups / firewall

Login:

* admin / admin
* Change password on first login

---

## Part 3: Installing Grafana on Amazon Linux / Red Hat

The process is identical for **Amazon Linux** and **Red Hat**.

### 14. Install Grafana Using RPM

```bash
sudo yum install -y <GRAFANA_RPM_URL>
```

(The RPM link is provided in Grafana documentation.)

---

### 15. Enable and Start Service

```bash
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Verify:

```bash
sudo systemctl status grafana-server
```

---

### 16. Access Grafana

```text
http://<PUBLIC_IP>:3000
```

Ensure port 3000 is open.

---

## Part 4: Installing Grafana Using Docker

### 17. Prerequisite: Docker Desktop

Install **Docker Desktop** from:

```text
https://www.docker.com/products/docker-desktop
```

Make sure Docker Desktop is running.

---

### 18. Grafana Docker Images

Two official images exist:

* Open Source:

```text
grafana/grafana-oss
```

* Enterprise (requires license):

```text
grafana/grafana-enterprise
```

We use **OSS**.

---

### 19. Run Grafana with Docker

```bash
docker run -d \
  --name grafana \
  -p 3001:3000 \
  grafana/grafana-oss
```

* Host port: **3001**
* Container port: **3000**

Access:

```text
http://localhost:3001
```

Login:

* admin / admin

---

### 20. Important Docker Limitation

If Grafana runs in Docker:

* It **cannot access Prometheus on localhost**
* Unless Prometheus also runs in Docker

👉 Solution: **Docker Compose**

---

### 21. Docker Compose (Recommended for Labs)

Use a `docker-compose.yml` that includes:

* Prometheus
* Grafana
* Loki
* Shared Docker network (e.g., `monitoring`)

Example command:

```bash
docker compose up -d
```

All services:

* Share the same network
* Can communicate via container names

---

## Part 5: Grafana Configuration (All Platforms)

### 22. Configuration File Location (Same Everywhere)

Inside container or host:

```text
/etc/grafana/grafana.ini
```

Best practice:

```bash
cp grafana.ini custom.ini
```

---

### 23. Common Configuration Changes

#### a) Instance Name

Used when multiple Grafana instances exist.

#### b) Logs

```ini
[paths]
logs = /var/log/grafana
```

(Remove semicolon!)

#### c) Database (Critical for Docker / HA)

Use MySQL or PostgreSQL when:

* Running multiple instances
* Using Docker
* You need persistence

---

### 24. Restart Grafana After Changes

```bash
sudo systemctl restart grafana-server
```

Or stop/start for reliability:

```bash
sudo systemctl stop grafana-server
sudo systemctl start grafana-server
```

---

## 25. Key Takeaways

* Grafana installation varies, but **configuration is consistent**
* `custom.ini` is preferred over `grafana.ini`
* SQLite is fine for single instance
* External DB is required for HA and Docker
* Docker Compose is best for local observability stacks

















# Grafana Dashboard Design Best Practices & Getting Ready to Build Dashboards

Before we start creating dashboards and working with different Grafana panels, it is very important to understand **how dashboards should be designed** and **what layouts work best for different use cases**.

A well-designed dashboard:

* Tells a **story**
* Highlights **what matters first**
* Avoids clutter
* Helps humans make decisions quickly

---

## 1. Why Grafana Dashboards Matter

In **Prometheus**, we can:

* Query metrics
* Draw simple graphs
* Explore time-series data

However:

* Prometheus graphs are **basic**
* They are not ideal for large-scale observability
* They lack layout, grouping, and advanced UX

This is where **Grafana** shines.

Grafana allows us to:

* Build structured dashboards
* Combine multiple data sources
* Visualize metrics in meaningful ways
* Serve different audiences (engineers, SREs, business teams)

---

## 2. Types of Dashboards You Can Create

There is **no single dashboard design** that fits all needs.
Dashboards should be designed based on **purpose and audience**.

### Common Dashboard Categories

1. **Browser / Frontend Dashboards**

   * Angular, React, Vue apps
   * User-experience focused

2. **Application Performance Monitoring (APM) Dashboards**

   * Backend services
   * APIs and microservices

3. **Infrastructure Dashboards**

   * Hosts, VMs, containers
   * CPU, memory, disk, network

4. **Synthetic Monitoring Dashboards**

   * External checks
   * Availability and uptime

5. **Business / Operational Dashboards**

   * Sales
   * Revenue
   * Refunds
   * Conversion rates

Each category has **different priorities**.

---

## 3. Recommended Layout: Browser / Frontend Dashboards

### What Matters Most?

* Errors
* Performance
* Traffic
* User experience

### Suggested Layout

**Top section (most important):**

* Error rate
* Number of errors
* Top N errors

**Middle section:**

* Page load time
* Throughput (page views per minute)

**Bottom section:**

* Web Vitals:

  * LCP (Largest Contentful Paint)
  * FID (First Input Delay)
  * CLS (Cumulative Layout Shift)

### Design Principle

> If users are seeing errors or slow pages, that should be visible **immediately**.

---

## 4. Recommended Layout: APM / Backend Services

### Key Metrics

* API calls per minute
* Error rate
* Latency
* Logs volume
* Resource usage

### Suggested Layout

* **API calls per minute**
* **Error rate**
* **Log volume**
* **CPU & memory usage**
* **Hosts / containers running the service**

This layout helps answer:

> Is the service healthy, fast, and scalable?

---

## 5. Recommended Layout: Infrastructure Dashboards

### Top Summary Section

* Number of hosts
* Applications
* Events
* Alerts / warnings

### Core Metrics

* CPU usage
* Memory usage
* Disk usage
* Disk utilization

### Detail Section

* List of all hosts / VMs
* Container details
* Databases (MySQL, Redis, etc.)

Infrastructure dashboards are usually used by:

* SREs
* DevOps engineers
* Platform teams

---

## 6. Recommended Layout: Synthetic Monitoring Dashboards

Synthetic monitoring means:

> Monitoring **without instrumenting** applications or infrastructure.

### Examples

* HTTP checks
* Ping checks
* API health endpoints

### Suggested Panels

* Website availability (up/down)
* API health checks
* Page load time
* External dependencies (Redis, Kafka, RabbitMQ, cloud services)

Color matters here:

* Green → healthy
* Red → broken

This dashboard answers:

> Can users reach us right now?

---

## 7. Recommended Layout: Business Dashboards

Business dashboards are **not technical** dashboards.

### Typical Metrics

* Total sales count
* Total refund count
* Sales value
* Refund value
* Conversion rate
* Customer acquisition
* Abandoned checkouts
* Payment methods
* Average basket value

### Recommended Visuals

* Comparison with last week / last month
* Region-based breakdown
* Trends over time

These dashboards are often viewed by:

* Managers
* Executives
* Operations teams

---

## 8. Test Data for This Course: ShoeHub

To make dashboards realistic, we will use **test metrics** from an imaginary company:

### Company: **ShoeHub**

* Products:

  * Loafers
  * High heels
  * Boots
* Payment methods:

  * Credit card
  * PayPal
  * Cash
* Countries:

  * US
  * India
  * Australia

---

## 9. ShoeHub Metrics Generator

I have created a **sample application** that generates random metrics.

### Options to Run It

#### Option 1: Binary (Releases)

* Download from GitHub
* Choose your OS (Windows / Linux / macOS)
* Run the executable

Metrics endpoint:

```
http://localhost:5000/metrics
```

#### Option 2: Docker (Recommended)

```bash
docker pull asrf/shoehub
docker run -p 8030:8080 asrf/shoehub
```

Scrape:

```
http://localhost:8030/metrics
```

---

## 10. Verifying Metrics in Prometheus

Once scraped, in Prometheus:

* Go to **Targets** → target is UP
* Search for metrics starting with:

```
shoehub_
```

You will see:

* Country-based metrics
* Payment method metrics
* Product sales metrics

These are intentionally designed to support **different dashboard types**.

---

## 11. Connecting Grafana to Prometheus

### Add Prometheus as Data Source

1. Open Grafana
2. Hover over **Configuration (gear icon)**
3. Click **Data Sources**
4. Click **Add data source**
5. Select **Prometheus**

### Configuration

* URL:

```
http://localhost:9090
```

(or HTTPS if secured)

Optional:

* Basic authentication
* Custom headers
* TLS certificates

Click **Save & Test**

✅ Green checkmark means success.

---

## 12. Creating a Dashboard in Grafana

### Step 1: Create Folder (Optional)

* Dashboards → New Folder
* Example: `Tech Team`

### Step 2: Create Dashboard

* Dashboards → New Dashboard
* **Save immediately** (important!)

Name example:

```
ShoeHub
```

---

## 13. Dashboard Settings Best Practices

Open **Dashboard Settings (⚙️)**

* Title & description
* Tags (e.g. `shoehub`, `training`, `demo`)
* Time zone:

  * Recommended: **Default** or **Browser time**
* Read-only mode (for TV dashboards)

Save settings.

---

## 14. Using Rows for Layout

Rows help structure dashboards.

Example:

* Row 1: Technical Charts
* Row 2: Business Charts

Rows:

* Are collapsible
* Can have titles
* Can be repeated later using variables























# Working with Grafana Panels: From Basic to Advanced

Once you have:

* Created a dashboard
* Connected **Grafana** to **Prometheus**

…the next step is to **add visualizations**, which in Grafana are called **panels**.

👉 Any chart, graph, or visualization you add to a dashboard is called a **panel**.

---

## 1. Adding Your First Panel

To add a panel:

1. Hover over **Add**
2. Click **Add visualization**

You will see **three main sections** on the screen:

1. **Panel preview** (center)
2. **Panel properties** (right side)
3. **Query editor & data source** (bottom)

---

## 2. Panel Types (Visualization Types)

In the **panel type dropdown**, you will see many visualization options.

Some are used very frequently, others less so.

### Most Common Panel Types

* **Time series** (default and most used)
* Stat
* Gauge
* Bar chart
* Pie chart
* Table

### Time Series Panel

* Best for showing **trends over time**
* This is the default panel type
* Ideal for metrics like:

  * Response time
  * Throughput
  * CPU usage
  * Memory usage

---

## 3. Writing Queries for Panels

Each panel can have **multiple queries**:

* Query A
* Query B
* Query C
* …

Each query:

* Pulls data from Prometheus
* Can be visualized together in one panel

---

### Two Ways to Build Queries

#### Option 1: Query Builder

* UI-based
* Beginner-friendly
* Prometheus functions appear as **operations**

#### Option 2: Code (PromQL)

* Direct PromQL
* Faster
* Easier for complex logic
* Preferred by experienced users

Both approaches are valid and interchangeable.

---

## 4. Example: Simple Time Series Panel

Let’s create a **response time** panel.

1. Panel type: **Time series**
2. Data source: Prometheus
3. Paste a PromQL query (or build it)
4. Click **Run query**

The graph will appear immediately.

💡 Prometheus functions (like `rate`) appear as **operations** in the builder.

---

## 5. Saving and Organizing Panels

Important rules:

* **Always save early**
* **Always apply changes**

You can:

* Drag panels into rows
* Collapse and expand rows
* Move panels between rows

This helps keep dashboards clean and readable.

---

## 6. Improving Legends (Display Names)

By default, Grafana generates **very long legends** based on labels.

This is often **too noisy**.

### For Single-Query Panels

1. Edit panel
2. Go to **Standard options**
3. Set **Display name**

Example:

```
Response Time (ms)
```

---

## 7. Multi-Query Panels (Sales Example)

Now let’s build a panel with **multiple queries**.

### Example: Shoe Sales

We have metrics for:

* Boots
* High heels
* Loafers

Each metric:

* Uses `rate()`
* Uses the **same time range** (important!)

⚠️ If ranges differ (1m vs 24h), comparisons are meaningless.

---

## 8. Calculating Totals with PromQL

We can calculate **total sales** directly in PromQL.

### Example (Code Mode)

```promql
rate(shoehub_sales_boots[1m])
+ rate(shoehub_sales_high_heels[1m])
+ rate(shoehub_sales_loafers[1m])
```

This creates a **derived metric** without storing it in Prometheus.

---

## 9. Setting Legends for Multi-Query Panels

When a panel has **multiple queries**, you must set legends **per query**.

Steps:

1. Expand query options
2. Set **Legend → Custom**
3. Provide a name

Example:

* Query A → Boots
* Query B → High Heels
* Query C → Loafers
* Query D → Total

This makes the chart readable and professional.

---

## 10. Using Data Transformations (Very Important)

Instead of writing a **new PromQL query**, Grafana can calculate values **locally**.

### Why Use Transformations?

* Reduce query complexity
* Improve readability
* Reuse existing data
* Faster iteration

---

### Example: Total Sales via Transformation

1. Edit panel
2. Go to **Transformations**
3. Click **Add transformation**
4. Choose **Add field from calculation**
5. Mode: **Reduce row**
6. Operation: **Sum**
7. Alias: `Total Sales`

Result:

* Grafana calculates the total
* No new PromQL query required

---

## 11. Time Series vs Pie Charts

### Time Series Panels

Best for:

* Trends
* Changes over time
* Rate analysis

### Pie Charts

Best for:

* Distribution
* Percentages
* Contribution to total

---

## 12. Creating a Pie Chart Panel

Example: **Card Payments by Country**

1. Add visualization
2. Panel type: **Pie chart**
3. Title: `Card Payments by Country`

---

### Queries (One per Country)

Each query:

* Filters by country label
* Uses `rate()`

Example logic:

* Australia
* India
* United States

Now each slice represents **one country’s share**.

---

## 13. Pie Chart Customization Options

You can configure:

* Pie vs donut
* Labels:

  * Name
  * Value
  * Percentage
* Legend position
* Tooltip behavior
* Links (to dashboards or external URLs)

Pie charts are excellent for **business dashboards**.

---

## 14. Saving and Organizing Business Panels

Once created:

* Save & apply
* Move panel into **Business** row
* Keep technical and business metrics separate

This improves clarity and usability.

---

## 15. Key Takeaways

* Panels are the building blocks of Grafana dashboards
* Use **Time series** for trends
* Use **Pie charts** for proportions
* Prefer **code mode** for complex queries
* Use **transformations** to avoid unnecessary PromQL
* Always clean up legends and titles













# Comparing Metrics Across Time & Using Grafana Variables

In many real-world scenarios, we don’t just want to see **current values** — we want to **compare the same metric across different time periods**.

Examples:

* Network errors **today vs last week**
* Sales **this month vs last month**
* Latency **before vs after a deployment**

Grafana + Prometheus give us **two powerful tools** for this:

1. **PromQL time offsets**
2. **Grafana variables**

---

## 1. Comparing the Same Metric Across Time (Offset)

### Goal

Compare:

* Sales **now**
* Sales **in the past** (e.g., last week)

---

### Step 1: Create a New Panel

* Panel type: **Time series**
* Title:

  ```
  Sales Today vs Sales Last Week
  ```

---

### Step 2: First Query – Current Sales

Example metric (simplified):

```
shoehub_sales_loafers
```

Apply a rate:

```promql
rate(shoehub_sales_loafers[$__interval])
```

Why `$__interval`?

* It automatically adapts to the dashboard time range
* Makes the panel reusable and scalable

---

### Step 3: Second Query – Past Sales (Offset)

Duplicate the query and add an **offset**:

```promql
rate(shoehub_sales_loafers[$__interval]) offset 1m
```

> In production you would normally use:

* `offset 7d` (last week)
* `offset 30d` (last month)

Here we use `1m` only because historical data is limited.

---

### Result

* Two time series on the same panel
* One shifted backward in time
* Easy visual comparison of trends

You can now:

* Set custom legends (e.g. *Today*, *Last Week*)
* Move this panel into the **Business** section

---

## 2. Practice Review: Payment Method Percentage by Country

### Business Question

> Do any payment methods contribute **less than 5%** of total payments in the US?

If yes, the business may decide to remove them due to maintenance overhead.

---

### Step 1: Create a New Panel

* Panel type: **Time series**
* Title:

  ```
  Percentage of Payment Methods in the United States
  ```

---

### Step 2: Card Payments (Percentage)

```promql
sum(shoehub_payments{country_code="us", payment_method="card"})
/
sum(shoehub_payments{country_code="us"})
* 100
```

---

### Step 3: Duplicate for Other Methods

Repeat the same query for:

* `cash`
* `paypal`

Set **custom legends**:

* Card
* Cash
* PayPal

---

### Step 4: Improve Visualization

Under **Graph styles**:

* Line interpolation → **Smooth**

---

### Step 5: Add Thresholds

Under **Thresholds**:

* Mode: **Percentage**
* Threshold: `5`
* Display: *Filled region*
* Color: Red

✅ Now you can visually see:

* Which payment methods dip below 5%
* For how long they stay there

---

## 3. Introducing Grafana Variables

So far, our panels are **hard-coded**:

* Country = `us`

This is not scalable.

Grafana variables allow us to:

* Parameterize dashboards
* Reuse panels
* Avoid duplication

---

## 4. Creating a Dashboard Variable

### Step 1: Open Dashboard Settings

* Go to **Dashboard settings**
* Click **Variables**
* Click **Add variable**

---

### Step 2: Simple (Custom) Variable

Example:

* Name: `country`
* Type: **Custom**
* Values:

  ```
  au,in,us
  ```

This works — but it’s **not dynamic**.

---

## 5. Dynamic Variable Using Prometheus Labels (Recommended)

### Variable Configuration

* Type: **Query**
* Data source: Prometheus
* Query type: **Classic**
* Query:

  ```promql
  label_values(shoehub_payments{payment_method="card"}, country_code)
  ```

Result:

* Automatically detects all countries
* New countries appear without manual changes

Optional settings:

* Enable **Multi-value**
* Enable **Include All**
* Sort alphabetically

Save the variable.

---

## 6. Using Variables in Panels

### Update Panel Title

Change:

```
Percentage of Payment Methods in the US
```

To:

```
Percentage of Payment Methods in $country
```

---

### Update Queries

Replace hardcoded values:

```promql
country_code="us"
```

With:

```promql
country_code="$country"
```

Now:

* One panel
* Multiple countries
* No duplication

---

## 7. Repeating Panels (Auto-Scaling Dashboards)

Sometimes dashboards are displayed on TVs or NOC screens, and no one will manually change variables.

Grafana allows **panel repetition**.

---

### How to Repeat Panels

1. Edit panel
2. Go to **Panel options**
3. Enable **Repeat**
4. Choose variable: `country`
5. Direction:

   * Vertical
   * Horizontal
6. Set max panels per row

Now:

* One panel per country
* Automatically generated
* Fully dynamic

---

## 8. Practice Review: Payment Method Variable

### Goal

Show **payment amount by method** across all countries.

---

### Step 1: Create Variable

* Name: `payment_method`
* Type: Query
* Query:

  ```promql
  label_values(shoehub_payments, payment_method)
  ```
* Enable **Multi-value**

---

### Step 2: Panel Query

```promql
sum(shoehub_payments{payment_method="$payment_method"})
```

---

### Step 3: Dynamic Legend

Instead of hardcoding legend names, use labels:

```
{{payment_method}}
```

Grafana automatically substitutes the label value.

---

### Step 4: Repeat Panel by Payment Method

* Panel options → Repeat
* Repeat by: `payment_method`

Result:

* One panel per payment method
* Fully dynamic
* No hardcoding

---

## Key Takeaways

* **Offset** lets you compare metrics across time
* `$__interval` makes queries adaptive
* **Variables** eliminate hardcoding
* **Query-based variables** scale automatically
* **Repeating panels** create powerful dashboards with minimal effort





















# Grafana Loki – Log Aggregation & Analysis

## 1. What Is Grafana Loki?

**Grafana Loki** is an **open-source log aggregation system** designed to work seamlessly with **Grafana**.

Observability is not just about **metrics** — it includes:

* **Metrics** (Prometheus)
* **Logs** (Loki)
* **Traces** (Tempo / OpenTelemetry)

Loki focuses specifically on **logs**.

Important note:

* **Loki has no UI of its own**
* Logs are viewed and analyzed **inside Grafana**
* Loki acts as a **backend log store**

---

## 2. Key Features of Grafana Loki

### 🔹 Log Aggregation

* Collects logs from multiple sources
* Stores and indexes them efficiently

### 🔹 Fast Queries at Scale

* Designed to query **huge volumes of logs quickly**
* Optimized for label-based filtering

### 🔹 Prometheus-Inspired Design

* Similar concepts to Prometheus
* Uses **labels**, not full-text indexing
* Query language: **LogQL**

### 🔹 Native Grafana Integration

* Loki is added as a **Grafana data source**
* Logs can be correlated with:

  * Metrics
  * Dashboards
  * Alerts

### 🔹 Distributed & Scalable

* Horizontally scalable
* Suitable for large environments

### 🔹 Cost-Effective Storage

* Uses **chunk-based storage**
* Logs are compressed into chunks
* Much cheaper than traditional log systems (ELK)

---

## 3. Loki Architecture – How It Works

### Typical Flow

1. **Application / Backend Service**

   * Written in Python, Java, or .NET
   * Writes logs to disk
     Example:

     ```
     /var/log/myapp.log
     ```

2. **Log Shipping Agent**

   * Runs on the same machine as the application
   * Discovers and reads log files
   * Sends logs to Loki

3. **Grafana Loki**

   * Receives logs
   * Stores them
   * Makes them queryable

4. **Grafana**

   * Uses Loki as a data source
   * Displays logs in dashboards & Explore view

---

## 4. Promtail vs Grafana Alloy

### Promtail

* Official Loki log shipping agent
* Discovers log files using config
* Lightweight and simple
* Ideal for:

  * Metrics + logs only
  * Small to medium setups

### Grafana Alloy

* Next-generation agent
* Can collect:

  * Logs
  * Metrics
  * Traces (OpenTelemetry)
* More powerful and scalable
* Better for:

  * Large environments
  * Future-proof observability platforms

### Which One Should You Learn?

👉 **Both**

In this section:

* We use **Promtail**

Next section:

* Dedicated to **Grafana Alloy**

---

## 5. Ways to Use Grafana Loki

### Option 1: Grafana Cloud (SaaS)

* Fully managed Loki
* No backend maintenance
* Still requires **Promtail or Alloy** on your servers

Steps:

1. Go to **grafana.com**
2. Sign up / sign in
3. Products → Logs → Loki
4. Configure Promtail to ship logs to cloud Loki

Good for:

* Learning
* Fast setup
* Small teams

---

### Option 2: Self-Managed Loki (Local or Server)

You can install Loki:

* Locally
* On a VM
* Using Docker
* On Kubernetes

In this course:

* Docker (local learning)
* Linux (production-like setup)

---

## 6. Installing Loki with Docker (Recommended for Learning)

### Why Docker?

* Works on Mac, Windows, Linux
* Fast and clean setup
* Ideal for local labs

---

### Docker Architecture

Docker Compose stack includes:

* **Loki** (log store)
* **Promtail** (log shipper)
* **Grafana** (visualization)

All containers share a **Docker network**.

---

### Step 1: Download Docker Compose File

Use **curl**, **wget**, or browser:

```bash
curl -O https://raw.githubusercontent.com/grafana/loki/main/production/docker-compose.yaml
```

This file:

* Creates a Docker network
* Runs Loki on port **3100**
* Runs Grafana on port **3000**
* Mounts `/var/log` into Promtail

---

### Step 2: Start the Stack

```bash
docker compose up -d
```

Verify:

* Containers are running
* Docker network exists
* Logs appear in Docker Desktop

---

### Step 3: Access Grafana

Open browser:

```
http://localhost:3000
```

Login:

* Username: `admin`
* Password: `admin`

---

### Step 4: Verify Loki Data Source

Grafana → Connections → Data Sources
You should already see:

* **Loki**
* URL:

  ```
  http://loki:3100
  ```

If Grafana is **outside Docker**:

```
http://localhost:3100
```

---

## 7. Promtail Log Discovery (Docker)

### Default Behavior

* Promtail reads:

  ```
  /var/log/*.log
  ```
* Files must:

  * End with `.log`
  * Be plain text or JSON

### Volume Mapping

```yaml
volumes:
  - /var/log:/var/log
```

So:

* Logs written on your machine → visible inside Promtail container

---

## 8. Viewing Logs in Grafana

1. Open **Grafana**
2. Go to **Explore**
3. Select **Loki** as data source
4. Filter by label:

   * `filename`
5. Choose your `.log` file
6. Set time range (e.g. last 15 minutes)
7. Run query

You will see:

* Log lines
* Timestamps
* Metadata

---

## 9. Installing Loki & Promtail on Linux (Production-Like Setup)

### Architecture

* **Loki server** → stores logs
* **Application server** → runs Promtail

---

### Step 1: Install Loki (Loki Server)

```bash
sudo apt update
sudo apt install loki
```

Open port **3100** in security group.

Use **private IP** whenever possible.

---

### Step 2: Install Promtail (App Server)

Promtail is **not installed via apt**.

1. Go to Grafana Loki GitHub releases
2. Download Promtail binary
3. Unzip and move binary:

   ```bash
   sudo mv promtail-linux-amd64 /usr/local/bin/promtail
   sudo chmod +x /usr/local/bin/promtail
   ```

---

### Step 3: Promtail Configuration

Create config:

```bash
/etc/promtail/config.yaml
```

Key section:

```yaml
clients:
  - url: http://<LOKI_PRIVATE_IP>:3100/loki/api/v1/push
```

---

### Step 4: Create Promtail Service

```bash
/etc/systemd/system/promtail.service
```

Start & enable:

```bash
sudo systemctl start promtail
sudo systemctl enable promtail
```

Verify:

```bash
sudo systemctl status promtail
```

---

## 10. Generating Logs for Testing

Test app:

* Writes logs to:

  ```
  /var/log/loki_udemy.log
  ```
* Log levels:

  * INFO
  * WARNING
  * ERROR
* Components:

  * backend
  * database

Example log format:

```
2024-02-01T10:15:32Z ERROR backend Database connection failed
```

---

## 11. Verifying Logs in Loki

In Grafana:

* Explore → Loki
* Filter by `filename`
* Select `loki_udemy.log`
* Adjust time range
* Run query

You should see logs streaming in.

---

## 12. Important Observation

Right now:

* Only default labels exist (filename, job)

👉 **No structured labels yet**

In the **next lecture**, we will:

* Parse logs
* Add labels (level, component)
* Filter logs efficiently
* Write LogQL queries
















# Grafana Loki – Static Labels, Dynamic Labels & Log Visualizations

Up to this point, we have successfully **ingested logs into Loki** and verified that they appear in **Grafana → Explore**.

However, if you open any log entry, you will notice a limitation:

* Available labels:

  * `filename`
  * `job`
* Missing labels:

  * environment
  * team
  * component
  * log level (info / warning / error)

Without labels, logs are **hard to filter**, **slow to query**, and **difficult to analyze at scale**.

This lecture focuses on:

1. **Static labels**
2. **Dynamic labels (extracted from logs)**
3. **Using Loki logs in Grafana dashboards**

---

## 1. Static Labels in Promtail

### What Are Static Labels?

Static labels are **manually assigned labels** that do **not** come from the log content itself.

They are useful for:

* Environment (`prod`, `staging`, `dev`)
* Team ownership (`devops`, `backend`)
* Cluster or region metadata

These labels apply to **all logs collected by a job**.

---

### Where Are Static Labels Defined?

In **Promtail configuration**, under:

```yaml
scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*.log
```

---

### Adding Static Labels

Extend the `labels` section:

```yaml
labels:
  job: varlogs
  team: devops
  environment: prod
  __path__: /var/log/*.log
```

---

### Apply the Changes

* Save the config
* Restart Promtail

  * Docker: restart container
  * Linux: restart service

---

### Result in Grafana

Now in **Grafana → Explore**:

* You can filter by:

  * `environment="prod"`
  * `team="devops"`
* You can query logs across **all files**, ignoring filenames entirely

Static labels are extremely powerful for **environment-wide filtering**.

---

## 2. Searching Unstructured Logs (Without Labels)

At this stage, our logs are **unstructured text**, not JSON.

Example log line:

```
2024-01-20T10:15:22 ERROR component=database Connection failed
```

If you want to search for:

* `component=database`

You have two options:

1. **Text search (inefficient)**
2. **Logfmt parsing (recommended)**

---

### Text Search (Not Recommended)

You *can* search by text:

```
|= "database"
```

⚠️ Downsides:

* CPU intensive
* Not indexed
* Slow at scale

Use only for **small datasets**.

---

## 3. Logfmt – Client-Side Parsing in Grafana

Grafana provides **logfmt parsing** directly in queries.

Example:

```
| logfmt
| component="database"
```

This:

* Parses `key=value` pairs
* Extracts fields temporarily (client-side)
* Allows filtering without changing Promtail

✔ Useful for quick exploration
✖ Not indexed
✖ Not scalable for production

---

## 4. Dynamic Labels (Best Practice)

Now we move to the **correct, production-grade solution**:
👉 **Extract labels at ingestion time**

This is done using **Promtail pipelines**.

---

## 5. Promtail Pipelines – Core Concept

A **pipeline** is a sequence of stages applied to each log line **before it reaches Loki**.

Each stage:

* Modifies the log entry
* Extracts data
* Adds labels

Pipeline structure:

```yaml
pipeline_stages:
  - stage1
  - stage2
  - stage3
```

---

## 6. Extracting Labels Using `logfmt`

### Step 1: Add Pipeline Stages

Under the same `scrape_configs` job:

```yaml
pipeline_stages:
  - logfmt:
      mapping:
        component:
        level:
```

This:

* Parses `component=...`
* Parses `level=...`

---

### Step 2: Allow Labels in Static Config

Promtail requires labels to exist in the **label allowlist (label map)**.

Add empty labels:

```yaml
labels:
  job: varlogs
  component:
  level:
  __path__: /var/log/*.log
```

This is mandatory.

---

### Step 3: Attach Extracted Fields as Labels

Add a `labels` pipeline stage:

```yaml
pipeline_stages:
  - logfmt:
      mapping:
        component:
        level:
  - labels:
      component:
      level:
```

---

### Step 4: Restart Promtail

After restart:

* New logs will contain extracted labels
* Old logs will not (labels are not retroactive)

---

## 7. Verifying Dynamic Labels

In **Grafana → Explore**:

* Filter by `filename`
* Expand a log entry

You should now see:

* `component=backend`
* `component=database`
* `level=info`
* `level=error`

Filtering now works efficiently:

```
{component="database", level="error"}
```

This is **indexed**, **fast**, and **scalable**.

---

## 8. Using Loki Logs in Grafana Dashboards

Logs are not just for Explore — they can be **visualized**.

---

### 8.1 Logs Panel

* Add new panel
* Data source: Loki
* Visualization: **Logs**
* Query:

  ```
  {filename="loki_udemy.log"}
  ```
* Limit rows (e.g. 10)

This panel:

* Shows latest logs
* Expandable
* Perfect for dashboards

---

## 8.2 Turning Logs into Metrics

To visualize logs in **time series, bar charts, or pie charts**, logs must be converted into **numbers**.

### Why?

Charts require **time series vectors**, not raw log lines.

---

### Example: Error Count per Minute

Query:

```
{level="error", component="backend"}
```

❌ This returns logs, not metrics

Convert using `rate`:

```
rate({level="error", component="backend"}[1m])
```

Now:

* Each bar = number of errors per minute
* Fully compatible with charts

---

### Alternative Functions

* `rate()`
* `count_over_time()`

Both are valid.

---

## 9. Comparing Error Sources (Backend vs Database)

### Backend Errors

```
rate({level="error", component="backend"}[5m])
```

### Database Errors

```
rate({level="error", component="database"}[5m])
```

Ensure:

* Same time window
* Same function

This allows **accurate comparison**.

---

## 10. Pie Chart – Error Distribution

### Goal

Compare:

* Backend errors vs Database errors

---

### Queries

Backend:

```
rate({level="error", component="backend"}[1h])
```

Database:

```
rate({level="error", component="database"}[1h])
```

Visualization:

* Panel type: **Pie chart**

Result:

* Immediate insight into **where errors originate**
* Helps prioritize engineering effort

---

## 11. Key Takeaways

### Static Labels

* Added in `static_configs`
* Best for environment-wide metadata

### Dynamic Labels

* Extracted via pipelines
* Indexed
* Fast queries
* Production-ready

### Log Visualizations

* Logs panel → raw inspection
* Rate/count → metrics
* Charts → trends & comparisons




















# OpenTelemetry (OTel): What It Is and Why It Matters

In this lecture, we introduce **OpenTelemetry** and explain **why it is critical to modern observability** and how it fits into everything you’ve learned so far in this course.

---

## What Is OpenTelemetry?

**OpenTelemetry** is a **vendor-neutral, open-source observability framework**.

It is designed to help teams:

* Avoid **vendor lock-in**
* Standardize how telemetry data is produced
* Switch observability backends without rewriting applications

OpenTelemetry is:

* Open source
* Sponsored by the **Cloud Native Computing Foundation**
* Actively adopted across cloud-native ecosystems

---

## What Does OpenTelemetry Collect?

OpenTelemetry supports **all three pillars of observability**:

1. **Metrics**
2. **Logs**
3. **Traces**

⚠️ Important distinction:

> **OpenTelemetry is NOT a backend.**

It does **not** store data like:

* Prometheus
* Jaeger
* New Relic
* Splunk

Instead, OpenTelemetry focuses on:

* **Generating**
* **Collecting**
* **Exporting**

Telemetry data to *actual backends*.

---

## Two Perspectives: Developer vs DevOps

### 1. Developer Perspective (Code-Level Observability)

As a developer:

* You **instrument code**
* You explicitly generate:

  * Metrics
  * Traces
  * Logs

Example:

* Increment an `order_count` metric whenever an order is created
* Attach trace IDs to incoming HTTP requests

This is done using **OpenTelemetry SDKs**, available for:

* C++
* .NET
* Go
* Java
* JavaScript
* PHP
* Python
* Ruby
* Rust
* Swift

(Some community SDKs exist beyond this list.)

This approach gives:

* Maximum flexibility
* Custom business metrics
* Fine-grained tracing

---

### 2. DevOps / Platform Perspective (Zero-Code Observability)

As a DevOps engineer:

* You often **cannot modify application code**
* You still need:

  * Metrics
  * Logs
  * Traces

OpenTelemetry supports **auto-instrumentation**:

* Uses runtime profilers (Java, .NET, etc.)
* Extracts telemetry automatically
* No code changes required

⚠️ Trade-off:

* Less flexible than manual instrumentation
* Still extremely powerful for infrastructure and platforms

---

## Exporters and the OTLP Protocol

After telemetry is generated, it must be **exported**.

OpenTelemetry supports multiple exporters:

* Prometheus exporter
* New Relic exporter
* Splunk exporter
* Jaeger exporter

### OTLP (OpenTelemetry Protocol)

OTLP is the **standard protocol** for OpenTelemetry.

Key points:

* Unified format for metrics, logs, and traces
* Increasingly adopted by observability backends
* Preferred protocol going forward

---

## OpenTelemetry Collector: When and Why

If you have:

* A few services → exporters may be enough
* **Hundreds of services** → you need collectors

### What Does a Collector Do?

An **OpenTelemetry Collector**:

* Receives telemetry
* Processes data (filter, batch, enrich)
* Sends data to one or more backends

Collectors are essential for:

* Scalability
* Centralized control
* Multi-backend pipelines

---

## Introducing Grafana Alloy

In this course, the OpenTelemetry collector we use is **Grafana Alloy**.

**Grafana Alloy** is:

* Grafana’s distribution of the OpenTelemetry Collector
* Introduced at GrafanaCON 2024
* Designed as a **single, unified telemetry agent**

Built by **Grafana**

---

## What Makes Grafana Alloy Special?

Grafana Alloy:

* Fully compatible with OpenTelemetry (OTLP)
* Includes built-in Prometheus optimization
* Supports:

  * Metrics
  * Logs
  * Traces
  * Profiles

It can receive telemetry from:

* OpenTelemetry SDKs
* Prometheus exporters
* Linux / Windows
* Kubernetes
* Java / .NET
* Databases (Postgres, etc.)
* Cloud providers

It can send data to:

* Prometheus
* Grafana Loki (logs)
* Grafana Tempo (traces)
* Other OTLP backends

> **Alloy replaces Promtail, exporters, and multiple agents with one tool.**

---

## Push vs Pull: Key Concept Shift

So far in this course, we mostly used **Prometheus**, which is:

* **Pull-based**
* Scrapes targets on intervals

OpenTelemetry is different:

* **Push-based**
* Telemetry is sent outward

This changes how we design the pipeline.

---

## Why We Start From the Backend

Because OpenTelemetry **pushes**, we must configure **destinations first**.

In our case:

* Backend = Prometheus

Prometheus must accept incoming data via **Remote Write**.

---

## Prometheus Remote Write (Critical Concept)

**Remote Write** allows Prometheus to:

* Send metrics to:

  * Another Prometheus
  * Long-term storage
  * OpenTelemetry collectors

### How It Works Internally

1. Prometheus scrapes metrics
2. Metrics are written to disk
3. Metrics are duplicated into a **Write-Ahead Log (WAL)**
4. WAL is read by a remote-write process
5. Metrics are **pushed** to another system

### Remote Write Endpoint

```
http://<prometheus-host>:<port>/api/v1/write
```

Same host and port as the Prometheus UI, just a different path.

---

## How This Fits with OpenTelemetry Collectors

Think of the OpenTelemetry Collector (or Alloy) as:

* A smart receiver
* A processor
* A forwarder

Internally, it can:

* Receive OTLP
* Receive Prometheus metrics
* Forward via remote write
* Fan-out to multiple backends

---

## Mental Model (Very Important)

* **Prometheus** → Pull-based
* **OpenTelemetry** → Push-based
* **Grafana Alloy** → Bridge between worlds

Prometheus scraping still works
OpenTelemetry push pipelines still work
Alloy ties everything together



















# Installing Grafana Alloy on macOS (Step by Step)

In this lecture, we’ll install **Grafana Alloy** on a **Mac computer** and understand how its configuration works.

Most engineers use macOS for local development, so this is a very common setup.

---

## 1. Prerequisite: Homebrew

Grafana Alloy is installed using **Homebrew**, the macOS package manager.

### Check if Homebrew is Installed

Open Terminal and run:

```bash
brew --version
```

* If you see `Homebrew` with a version number → you’re good
* If not → install Homebrew

### Install Homebrew (if missing)

Go to:

```
https://brew.sh
```

Follow the instructions shown on the website.

---

## 2. Install Grafana Alloy

Once Homebrew is installed, run:

```bash
brew tap grafana/grafana
brew install grafana/grafana/alloy
```

This will:

* Download Grafana Alloy
* Install it as a system binary

The installation may take a few minutes.

---

## 3. Start Grafana Alloy as a Service

After installation:

```bash
brew services start alloy
```

This runs Alloy as a **background service**, which is how we want it for observability components.

You can verify it’s running with:

```bash
brew services list
```

---

## 4. Grafana Alloy Configuration File Location

Grafana Alloy reads its configuration from:

```text
/usr/local/etc/alloy/config.alloy
```

Open it with:

```bash
nano /usr/local/etc/alloy/config.alloy
```

### Default State

After installation, the config file:

* Contains **only logging configuration**
* Does **not** collect or export anything yet

That’s expected.

We now need to define:

* Receivers
* Processors
* Exporters

---

## 5. Grafana Alloy Architecture Refresher

Every OpenTelemetry collector (including Alloy) follows this model:

### 1. Receivers

* Receive signals (metrics, logs, traces)

### 2. Processors

* Transform data (batching, filtering, aggregation)

### 3. Exporters

* Send data to backends (Prometheus, Loki, Tempo, etc.)

Grafana Alloy uses **components**, and each component has:

* A **type**
* A **name**
* An **input/output connection**

You can chain components together like a pipeline.

---

## 6. Example: Alloy Configuration for Metrics (OTLP → Prometheus)

Below is a **minimal, working example** to receive metrics via OpenTelemetry and send them to Prometheus using **remote_write**.

### Receiver: OTLP (metrics)

```hcl
otelcol.receiver.otlp "default" {
  protocols {
    http {}
  }

  output {
    metrics = [otelcol.processor.batch.default.input]
  }
}
```

* Listens on **port 4318** (HTTP/Protobuf)
* Receives **metrics only**

---

### Processor: Batch

```hcl
otelcol.processor.batch "default" {
  output {
    metrics = [otelcol.exporter.prometheus.default.input]
  }
}
```

* Groups metrics for efficiency
* Almost always recommended

---

### Exporter: Prometheus Remote Write

```hcl
otelcol.exporter.prometheus "default" {
  forward_to = [prometheus.remote_write.default.receiver]
}
```

---

### Prometheus Remote Write Target

```hcl
prometheus.remote_write "default" {
  endpoint {
    url = "http://localhost:9090/api/v1/write"

    basic_auth {
      username = "admin"
      password = "admin"
    }
  }
}
```

Important:

* Uses Prometheus **remote write**
* Endpoint is always:

```
/api/v1/write
```

---

## 7. Restart Grafana Alloy

After editing the config file:

```bash
brew services restart alloy
```

Always restart Alloy after config changes.

---

## 8. Grafana Alloy Web UI

Grafana Alloy exposes a **web interface** on:

```
http://localhost:12345
```

### What You’ll See

* List of configured components
* Health status of each component
* Graph view showing data flow

If everything is configured correctly:

* All components show **Healthy**
* The graph shows signal flow from receiver → processor → exporter

---

## 9. Sending Metrics from a Microservice (OTLP)

To demonstrate OTLP ingestion, we use a **simple .NET microservice**.

### Key Points

* Uses OpenTelemetry .NET SDK
* Sends metrics to Alloy via:

  ```
  http://localhost:4318/v1/metrics
  ```
* Uses **HTTP/Protobuf**
* Only metrics (to keep it simple)

### OTLP Ports Reminder

| Protocol      | Port |
| ------------- | ---- |
| gRPC          | 4317 |
| HTTP/Protobuf | 4318 |

---

### Example Metric Behavior

* Counter name: `otel_order`
* Appears in Prometheus as:

  ```
  otel_order_total
  ```

You can verify in Prometheus:

```promql
rate(otel_order_total[5m])
```

---

## 10. Ingesting Logs with Grafana Alloy (Two Approaches)

Grafana Alloy supports **two ways** to ingest logs into Loki.

---

### Option 1: Native Loki Components (Stable)

#### Loki Writer

```hcl
loki.write "local" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
```

#### File Log Source

```hcl
loki.source.file "default" {
  targets = [{
    __path__ = "/var/log/shoehub/*.log",
    app = "shoehub"
  }]

  forward_to = [loki.write.local.receiver]
}
```

✅ Recommended for production
✅ Stable
✅ Simple

---

### Option 2: OpenTelemetry-Based Log Ingestion (Preview)

⚠️ **Important**
At the time of recording, this method is **experimental / preview**.

#### File Log Receiver (OTel)

```hcl
otelcol.receiver.filelog "default" {
  include = ["/var/log/shoehub/*.log"]

  output {
    logs = [otelcol.exporter.loki.default.input]
  }
}
```

#### Loki Exporter (OTel)

```hcl
otelcol.exporter.loki "default" {
  forward_to = [loki.write.local.receiver]
}
```

---

### When to Use Each

| Method                 | Use Case                                |
| ---------------------- | --------------------------------------- |
| Loki native components | Production, simplicity                  |
| OpenTelemetry logs     | Unified OTLP pipelines, experimentation |

---

## 11. Key Takeaways

* Grafana Alloy is installed easily on macOS via Homebrew
* Configuration is **component-based**
* Alloy supports **metrics, logs, and traces**
* Metrics → Prometheus via remote_write
* Logs → Loki via:

  * Native Loki components (recommended)
  * OpenTelemetry pipelines (preview)


















# Installing Grafana Alloy on Ubuntu (Easy & Safe Method)

In this lecture, we’ll install **Grafana Alloy on an Ubuntu server**.

The steps themselves are simple, but because Ubuntu requires:

* updating **keyrings**
* updating **APT repositories**
* adding **Grafana’s package source**

there’s always a risk of mistakes due to typos.

To avoid that, I’ve provided **a ready-made install script** in the **course GitHub repository**.

---

## 1. Use the Provided Installation Script (Recommended)

In the GitHub repository for this course:

```
Grafana-Udemy/
└── alloy/
    └── install.sh
```

### Steps

1. Open the file on GitHub
2. Click **Raw**
3. Copy the URL from your browser

Now, on your **Ubuntu server**:

```bash
wget <PASTE_RAW_FILE_URL_HERE>
```

Verify it downloaded:

```bash
ls
```

Now run it:

```bash
sudo sh install.sh
```

This script:

* Adds Grafana’s APT repository
* Updates keyrings
* Installs Grafana Alloy
* Enables and starts Alloy as a service

You *can* run these commands manually, but the script does everything safely for you.

---

## 2. Access the Alloy Configuration Directory

After installation, Alloy is installed under:

```bash
/etc/alloy
```

Check it:

```bash
ls /etc
```

You should see the `alloy` directory.

Because Alloy was installed with `sudo`, your current user may **not** own this directory.

Fix ownership:

```bash
sudo chown -R $(whoami):$(whoami) /etc/alloy
```

Now enter the directory:

```bash
cd /etc/alloy
```

You’ll find:

```text
config.alloy
```

Open it:

```bash
nano config.alloy
```

This file contains a **basic template**.
We will extend it with **receivers, processors, and exporters**.

---

## 3. Why Grafana Mimir Exists (Important Context)

Large companies generate **millions or billions of metrics per day**.

Prometheus:

* Is **single-node**
* Is **not horizontally scalable**
* Is **not suitable for long-term storage**

That’s why **Grafana Mimir** exists.

### What Grafana Mimir Provides

* High availability
* Horizontal scalability
* Long-term storage (S3, GCS, Azure Blob, etc.)
* Extremely fast queries
* Multi-tenancy
* 100% PromQL compatibility
* Remote Write API

Mimir **extends Prometheus**, it does **not replace it**.

---

## 4. Grafana Mimir – High-Level Architecture

### Write Path (Ingestion)

1. Prometheus scrapes metrics
2. Prometheus **remote_write** pushes metrics to:

   ```
   /api/v1/push
   ```
3. Mimir Distributor receives data
4. Data flows to Ingesters
5. Data is written to object storage (S3 / filesystem)
6. Compactor deduplicates and optimizes blocks

### Read Path (Querying)

1. Query → Query Frontend
2. Cache lookup
3. Query Scheduler (optional)
4. Querier reads:

   * Object storage
   * Ingesters (for recent data)
5. Results returned to Grafana

---

## 5. Installing Grafana Mimir Locally (Monolithic Mode)

This setup is **for learning only**, not production.

### Supported Platforms

* macOS (Intel or Apple Silicon)
* Linux
* ❌ Windows not supported

---

## 6. Download Grafana Mimir Binary

Go to:

```
https://github.com/grafana/mimir/releases
```

Under **Assets**, download the correct binary:

| Platform            | Binary       |
| ------------------- | ------------ |
| macOS Intel         | darwin-amd64 |
| macOS Apple Silicon | darwin-arm64 |
| Ubuntu              | linux-amd64  |
| Debian              | .deb         |

---

## 7. Download Using curl (Recommended)

Create a directory:

```bash
mkdir mimir
cd mimir
```

Download:

```bash
curl -L <MIMIR_BINARY_URL> -o mimir
```

Make it executable:

```bash
chmod +x mimir
```

Test it:

```bash
./mimir
```

Stop it with `Ctrl+C`.

> ⚠ macOS users:
> If macOS blocks execution, go to:
> **Settings → Privacy & Security → Allow Anyway**

---

## 8. Create Mimir Configuration File (Monolithic Mode)

Create a file:

```bash
nano config.yaml
```

### Minimal Working Config (Single-Tenant)

```yaml
multitenancy_enabled: false

server:
  http_listen_port: 9000

common:
  storage:
    backend: filesystem
    filesystem:
      dir: ./data/common

blocks_storage:
  backend: filesystem
  filesystem:
    dir: ./data/blocks

ingester:
  ring:
    replication_factor: 1
```

### Why These Settings Matter

* `multitenancy_enabled: false` → no org headers required
* `replication_factor: 1` → single-node mode
* `filesystem` backend → local learning setup

---

## 9. Start Mimir with Config

```bash
./mimir -config.file=config.yaml
```

You should see logs indicating:

* HTTP server started
* Listening on port **9000**

---

## 10. Configure Prometheus Remote Write → Mimir

Edit `prometheus.yml`:

```yaml
remote_write:
  - url: http://localhost:9000/api/v1/push
```

Restart Prometheus.

Now:

* Metrics scraped by Prometheus
* Automatically pushed to Mimir

---

## 11. Using Grafana with Mimir

### Important: Mimir Uses Prometheus API

In Grafana:

* **Do NOT create a “Mimir” data source**
* Create a **Prometheus** data source

### Data Source URL

```text
http://localhost:9000/prometheus
```

Grafana uses the Prometheus API compatibility layer.

---

## 12. Docker-Based Local Setup (Optional)

The course repository contains:

```
Grafana-Udemy/
└── docker/
```

Inside is a **wrapper script** that:

* Creates directories
* Sets permissions
* Runs Docker Compose safely

Run:

```bash
./run.sh
```

This will start:

* Grafana
* Mimir
* Supporting services

---

## 13. Verify Metrics in Grafana

Go to **Explore → Data Source → Prometheus (Mimir)**

Run:

```promql
shoehub_*
```

You should see all metrics previously scraped by Prometheus.

---

## Key Takeaways

* Grafana Alloy on Ubuntu is easiest via the provided script
* Grafana Mimir solves Prometheus scalability limitations
* Mimir is **PromQL compatible**
* Prometheus pushes metrics to Mimir via **remote_write**
* Grafana queries Mimir using the **Prometheus API**






















# Grafana Mimir Multi-Tenancy Explained (Step by Step)

Now that we have correctly installed and set up **Grafana Mimir**, let’s learn how **multi-tenancy** works and how to configure it properly.

---

## 1. What Is Multi-Tenancy in Grafana Mimir?

Multi-tenancy allows **multiple isolated organizations (tenants)** to store metrics in the **same Mimir cluster**, while keeping their data fully separated.

Each tenant:

* Has its **own metric namespace**
* Cannot see data from other tenants
* Is identified by an HTTP header

---

## 2. High-Level Architecture Example

Imagine a company with **two departments**:

* **IT Department**
* **Sales Department**

Each department:

* Uses a **different application**
* Produces **different metrics**
* Must **not see each other’s data**

### Important Rule

> **One Prometheus instance can write to only ONE tenant ID**

So to separate tenants:

* IT → Prometheus #1
* Sales → Prometheus #2

Both Prometheus instances push metrics to **the same Mimir cluster**, but with **different tenant IDs**.

---

## 3. How Tenant Identification Works

Grafana Mimir identifies tenants using an HTTP header:

```
X-Scope-OrgID
```

⚠️ **Case-sensitive**
⚠️ Must be identical everywhere it’s used

Examples:

```text
X-Scope-OrgID: it
X-Scope-OrgID: sales
```

---

## 4. Enable Multi-Tenancy in Mimir

By default, in our earlier setup, **multi-tenancy was disabled**.

### Update `config.yaml`

```yaml
multitenancy_enabled: true
```

⚠️ If this remains `false`:

* Tenant headers are ignored
* All data goes into the anonymous tenant

After changing this:

```bash
restart mimir
```

---

## 5. Configure Prometheus Remote Write (Per Tenant)

Each Prometheus instance must include **its own tenant header**.

### Example: IT Prometheus

```yaml
remote_write:
  - url: http://localhost:9000/api/v1/push
    headers:
      X-Scope-OrgID: it
```

### Example: Sales Prometheus

```yaml
remote_write:
  - url: http://localhost:9000/api/v1/push
    headers:
      X-Scope-OrgID: sales
```

Restart Prometheus after changes.

---

## 6. Configure Grafana Data Sources (Per Tenant)

Grafana **does not auto-detect tenants**.
You must create **one Prometheus data source per tenant**.

### Add Data Source → Prometheus

URL:

```text
http://localhost:9000/prometheus
```

HTTP Headers:

```text
X-Scope-OrgID = it
```

Save.

Repeat for `sales`.

---

## 7. Result

* IT dashboards → IT metrics only
* Sales dashboards → Sales metrics only
* Same Mimir backend
* Full isolation

---

# Common Storage vs Block Storage in Grafana Mimir

Understanding storage types is **critical** for production setups.

---

## 8. Common Storage (Metadata & Internal State)

Used for:

* Ruler
* Alertmanager
* Compactor metadata
* Admin APIs
* Internal coordination

⚠️ **Not metric data**

---

## 9. Block Storage (Metrics Data)

Used for:

* Time-series metrics
* Long-term retention
* Compaction
* Querying

This is where **actual Prometheus metrics live**.

---

## 10. Storage Backends

You can use:

* Local filesystem (learning only)
* Amazon S3
* Google Cloud Storage
* Azure Blob Storage

👉 In production, **S3/GCS/Azure is mandatory**

---

# Configuring AWS S3 for Grafana Mimir

---

## 11. Required AWS Resources

You need:

1. **2 S3 buckets minimum**

   * Common storage
   * Block storage
2. **IAM user OR IAM role**
3. **IAM policy**

Optional:

* Third bucket for Alertmanager

---

## 12. IAM Policy

A ready-made policy is provided in the course GitHub repo:

```
mimir/
└── iam-policy.json
```

⚠️ Remove comments (`#`) before pasting into AWS

Create policy:

* IAM → Policies → Create Policy → JSON
* Paste policy
* Save

---

## 13. Create IAM User

* IAM → Users → Create User
* Attach policy
* Generate **Access Key + Secret Key**

> If using **EC2 or EKS IAM roles**, do **NOT** use access keys.

---

## 14. Create S3 Buckets

Example:

* `grafana-mimir-common`
* `grafana-mimir-blocks`

Keep:

* **Private access**
* No public access

---

## 15. Mimir S3 Configuration Example

```yaml
common:
  storage:
    backend: s3
    s3:
      bucket_name: grafana-mimir-common
      endpoint: s3.amazonaws.com
      region: ap-southeast-2
      access_key_id: <KEY>
      secret_access_key: <SECRET>

blocks_storage:
  backend: s3
  s3:
    bucket_name: grafana-mimir-blocks
    endpoint: s3.amazonaws.com
    region: ap-southeast-2
    access_key_id: <KEY>
    secret_access_key: <SECRET>
```

---

## 16. Optional: S3 Bucket Policy (Extra Security)

You can restrict bucket access **only to the IAM user** created for Mimir.

Templates are provided in GitHub:

```
mimir/
└── s3-bucket-policy.json
```

---

# Grafana Mimir Microservices Architecture (Production)

---

## 17. Why Microservices Mode?

Benefits:

* Scale reads and writes independently
* High availability
* Fault isolation
* Production-grade reliability

Core components:

* Distributor
* Ingester
* Querier
* Query Frontend
* Ruler
* Compactor
* Store Gateway

---

## 18. Service Discovery Options

### Option 1: Load Balancers

* Each service behind an LB
* Simpler but expensive

### Option 2: KV Store (Recommended)

* Consul
* etcd
* Memberlist (testing only)

> **Memberlist = labs only**
> **Consul/etcd = production**

---

## 19. Kubernetes Is the Recommended Platform

Why?

* Built-in service discovery
* Load balancing
* Scaling
* Secrets
* Security
* Observability

In this course:

* We use **Kubernetes**
* We deploy Mimir via **Helm**
* We use **memberlist** for labs

---

# Preparing Kubernetes Locally (macOS)

---

## 20. Required Tools

### Homebrew

```bash
brew --version
```

Install if missing.

---

### Docker Desktop

Required for Minikube.

---

### Minikube

```bash
brew install minikube
minikube start --driver=docker
```

If HyperKit error:

```bash
minikube delete
```

---

### Enable Add-ons

```bash
minikube addons enable ingress
minikube addons enable dashboard
```

---

### Verify Cluster

```bash
kubectl get nodes
```

---

### Helm

```bash
brew install helm
```

---

## 21. Kubernetes Dashboard (Optional)

```bash
minikube dashboard
```



















## 1. Add Grafana Helm Repository

Helm needs access to Grafana’s official charts.

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

If the repo already exists, Helm will skip adding it.

---

## 2. Create a Custom `values.yaml`

Grafana Mimir **must not be deployed with default values**.
We must provide a **custom values file** that includes:

* Mimir configuration (`structuredConfig`)
* Storage configuration
* Replicas for microservices

### File name (example)

```text
custom-values.yaml
```

---

## 3. Add Mimir Configuration to Helm Values

Inside `custom-values.yaml`:

```yaml
mimir:
  structuredConfig:
    # Paste your existing Mimir config here
```

This config is the same one you used earlier when running Mimir locally, but now **embedded into Helm**.

---

## 4. Configure Microservice Replicas

Because we are deploying **distributed Mimir**, we must define replicas at the **root level** of the values file.

Example:

```yaml
ingester:
  replicas: 2

querier:
  replicas: 2

distributor:
  replicas: 2

store_gateway:
  replicas: 2

compactor:
  replicas: 1
```

These are Kubernetes Pods—each component scales independently.

---

## 5. Install Mimir Using Helm

Navigate to the folder containing `custom-values.yaml` and run:

```bash
helm install mimir grafana/mimir-distributed \
  --namespace mimir \
  --create-namespace \
  -f custom-values.yaml
```

If successful, Helm will print:

```
Welcome to Grafana Mimir
```

---

## 6. Verify Kubernetes Resources

### Check Pods

```bash
kubectl get pods -n mimir
```

You should see:

* distributor
* ingester
* querier
* query-frontend
* compactor
* store-gateway
* alertmanager
* ruler

Each pod is one Mimir microservice.

---

### Check Services

```bash
kubectl get svc -n mimir
```

All services are **ClusterIP** because:

* They are internal Kubernetes services
* External access requires port-forwarding or ingress

---

## 7. Access Mimir Services

### Option 1: Port Forward (Recommended for Labs)

Example: Expose distributor

```bash
kubectl port-forward svc/mimir-distributor 9009:9009 -n mimir
```

Prometheus remote_write must point to:

```text
http://localhost:9009/api/v1/push
```

---

### Option 2: Minikube Service URL

```bash
minikube service mimir-distributor -n mimir
```

Minikube will generate a temporary URL.

---

## 8. Update Prometheus Remote Write

In `prometheus.yml`:

```yaml
remote_write:
  - url: http://localhost:9009/api/v1/push
```

Restart Prometheus.

Now Prometheus writes metrics directly to **Grafana Mimir**.

---

# Why Use Grafana Alerting Instead of Prometheus Alertmanager?

Prometheus **cannot scale alerting** properly at enterprise scale and **does not support multi-tenancy**.

Grafana Mimir:

* Scales alert evaluation
* Supports multi-tenant alert isolation
* Avoids duplicate alerts
* Centralizes alert routing

---

## 9. Alerting Architecture in Mimir

### Components

| Component        | Responsibility                 |
| ---------------- | ------------------------------ |
| **Ruler**        | Evaluates alert rules          |
| **Alertmanager** | Deduplicates and routes alerts |

Flow:

```
Metrics → Ruler → Alertmanager → Slack / Email / PagerDuty
```

---

## 10. Alert Rules & Alertmanager Files

Mimir uses **standard Prometheus files**:

* Rule files (`rules.yaml`)
* Alertmanager config (`alertmanager.yaml`)

Nothing new to learn—**same syntax**.

---

## 11. Storage Requirements for Alerting

Ruler and Alertmanager **must persist state**.

They need storage:

* Filesystem (labs only)
* S3 / GCS / Azure (production)

---

## 12. Required Configuration Sections (Critical)

These are **not clearly documented** by Grafana, but **mandatory**.

You must configure **four sections**:

```yaml
ruler:
ruler_storage:
alertmanager:
alertmanager_storage:
```

---

## 13. Example: Ruler Configuration

```yaml
ruler:
  enable_api: true

ruler_storage:
  backend: filesystem
  filesystem:
    dir: /data/ruler
```

`enable_api: true` is required to push rules using **mimirtool**.

---

## 14. Example: Alertmanager Configuration

```yaml
alertmanager:
  enable_api: true
  fallback_config_file: /configs/alertmanager.yaml

alertmanager_storage:
  backend: filesystem
  filesystem:
    dir: /data/alertmanager
```

---

## 15. Rule File Structure (Per Tenant)

Example: `tenant-one-rules.yaml`

```yaml
groups:
- name: traffic-alerts
  interval: 30s
  rules:
  - alert: HighErrorRate
    expr: |
      rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "High HTTP error rate detected"
```

Each tenant has its **own rule file**.

---

## 16. Alertmanager Configuration Example (Slack)

```yaml
global:
  slack_api_url: https://hooks.slack.com/services/XXXX

route:
  receiver: main

receivers:
- name: main
  slack_configs:
  - channel: "#alerts"
```

---

# Loading Rules & Alertmanager Using `mimirtool`

---

## 17. Download `mimirtool`

From:

```
https://github.com/grafana/mimir/releases
```

Choose:

* macOS → Darwin
* Intel → amd64
* Apple Silicon → arm64

Make executable:

```bash
chmod +x mimirtool
```

---

## 18. Start Mimir with All Components (Monolithic Mode)

```bash
mimir \
  -target=alertmanager,distributor,ingester,querier,ruler,store-gateway,compactor \
  -config.file=config.yaml
```

---

## 19. Load Rules into Ruler

```bash
mimirtool rules sync \
  --address=http://localhost:9009 \
  --id=tenant-one \
  tenant-one-rules.yaml
```

Output example:

```
1 group created, 0 updated, 0 deleted
```

---

## 20. Verify Rules

```bash
mimirtool rules list \
  --address=http://localhost:9009 \
  --id=tenant-one
```

---

## 21. Query Alerts via API (Current Workaround)

Due to a known API issue:

```bash
curl http://localhost:9009/alertmanager/api/v2/alerts \
  -H "X-Scope-OrgID: tenant-one"
```

States:

* inactive
* pending
* firing

---

## 22. Alerts Delivered (Slack Example)

Slack receives alerts as expected once conditions are met.

---

# Final Summary

You now know how to:

* Deploy **Grafana Mimir on Kubernetes**
* Configure **multi-tenant metrics**
* Enable **enterprise-grade alerting**
* Load rules and alertmanager configs via API
* Use **GitOps-style automation**




















# Creating Alert Rules in Grafana

To work with alert rules in Grafana:

1. Open the **Grafana menu**
2. Go to **Alerting**
3. Click **Alert rules**

You will notice that Grafana already has several alert rules.
These are **internal alerts** used by Grafana to monitor the health of its own components.

---

## Creating a New Alert Rule

To create your own alert rule:

1. Click **New alert rule**
2. Select a **data source**
3. Write a query manually **or** use the **Query Builder**

You can also **reuse existing dashboard queries**, which is often the best approach.

---

## Creating an Alert from an Existing Panel

If you already have a panel with the query you want:

1. Open the **dashboard**
2. Click the panel
3. Choose **Edit**
4. Go to the **Alert** tab
5. Click **Create alert rule**

Grafana will automatically:

* Copy the query into the alert rule
* Use the panel name as the alert name (you can change it)

This ensures the alert logic stays consistent with the visualization.

---

## Query Evaluation Window & Frequency

When you click **Run queries**, Grafana shows how the query behaves.

Key concepts:

* **Evaluation window** (default: last 5 minutes)
  Grafana evaluates data over a time range to avoid false alerts.
* **Evaluation interval** (default: 15 seconds)
  How often Grafana checks the condition.

You can change these:

* 5 minutes → 15 min / 30 min
* 15s → 30s / 1m

---

## Why We Need Expressions

Alerts need a **single value** to evaluate.

Raw queries usually return **multiple data points**, so we must reduce them.

Grafana alert rules typically require:

1. **Reduce expression**
2. **Threshold or Math expression**

---

## Adding a Reduce Expression

1. Click **Add expression**
2. Select **Reduce**
3. Input: **A** (your query)
4. Reducer:

   * `Last` (default)
   * `Mean`, `Sum`, `Count`, etc.
5. Mode: **Strict**

This converts many data points into **one value**.

Grafana assigns this expression the name **B**.

---

## Adding a Threshold Expression

1. Click **Add expression**
2. Select **Threshold**
3. Input: **B** (the reduced value)
4. Example:

   * Condition: **Below**
   * Value: **400**

Grafana now draws a **red threshold line**.

* Expression evaluates to **1 → alert fires**
* Expression evaluates to **0 → no alert**

---

## Previewing Alert Behavior

Click **Preview** to see:

* Reduced values
* Threshold evaluation results

This helps verify that the alert logic works before saving.

---

## Evaluation Group & Pending Period

Alerts must belong to an **Evaluation Group**.

1. Create a new group (example: `card-payments`)
2. Evaluation interval: e.g. `20s`
3. Pending period: e.g. `1m`

Why this matters:

* Prevents alerts caused by short spikes
* Condition must be violated continuously before firing

---

## Labels, Summary, and Runbooks

You should always add labels:

```text
team = tech
```

Labels are critical because:

* Notification policies use them for routing
* Silences match against labels

You can also add:

* Summary
* Description
* Runbook URL (Confluence, SharePoint, GitHub)

---

## Saving the Alert Rule

After saving:

* **Green heart** → healthy
* **Orange** → pending evaluation
* **Red broken heart** → alert firing

Once the condition remains violated long enough, the alert becomes **firing**.

---

# Sending Alert Notifications

Alerts **do not send notifications automatically**.
You must configure:

1. **Contact points**
2. **Notification policies**

---

## Email Notifications (Using Mailtrap)

If you don’t have a real SMTP server, use **Mailtrap**.

### Configure Grafana SMTP

Edit `grafana.ini` (macOS example):

```text
/usr/local/etc/grafana/grafana.ini
```

Under `[smtp]`:

* Remove `;`
* Set `enabled = true`
* Provide host, username, password from Mailtrap

Restart Grafana.

---

## Creating a Contact Point

1. Go to **Alerting → Contact points**
2. Create new contact point
3. Type: **Email**
4. Name: `L2-support`
5. Add email addresses
6. Save

Status will show **Unused** until a policy references it.

---

## Creating a Notification Policy

1. Go to **Alerting → Notification policies**
2. Do **not** modify the default policy
3. Create a **nested policy**

Example matchers:

```text
team = tech
```

Choose contact point:

```text
L2-support
```

Save the policy.

Alerts now route correctly.

---

## Slack Notifications (Recommended)

Email is slow. Teams usually use **Slack**, **Teams**, **PagerDuty**, or **OpsGenie**.

---

### Creating a Slack Webhook

1. Open Slack workspace
2. Go to **Apps**
3. Search **Incoming Webhooks**
4. Install
5. Select channel
6. Copy **Webhook URL**

---

### Create Slack Contact Point in Grafana

1. Go to **Contact points**
2. Create new
3. Type: **Slack**
4. Channel name
5. Paste Webhook URL
6. Send test message
7. Save

---

### Update Notification Policy

Edit your policy:

* Replace email contact point
* Select **Slack**

Now all firing alerts appear in Slack.

---

## Silences (Suppress Notifications Temporarily)

Silences:

* Do **not** stop alert evaluation
* Only suppress notifications

You can silence by:

* Time range
* Labels
* Alert name
* Team
* Country code

Example:

```text
team = tech
__alertname__ = LowCardPayment
```

---

# Annotations in Grafana

Annotations **do not trigger notifications**.
They are used to **mark events on graphs**.

---

## Creating Annotations

### Single Point Annotation

* Windows: **Ctrl + Click**
* Mac: **Cmd + Click**

Example:

```text
Bad deployment
Tags: api, deployment
```

---

### Range Annotation

* Hold Ctrl (Windows) / Cmd (Mac)
* Drag across graph
* Example:

```text
Marketing campaign
```

---

## Managing Annotations

Annotations are stored in:

```text
-- Grafana --
```

You can:

* Disable annotations in **Dashboard settings**
* Re-enable anytime

Important:

* **Save the dashboard first**
* Unsaved dashboards cannot store annotations

---

# Key Takeaways

* Alert rules evaluate queries → expressions → thresholds
* Reduce expressions are mandatory
* Notifications require contact points + policies
* Labels control routing and silencing
* Slack is preferred over email
* Silences suppress notifications, not alerts
* Annotations document events, not incidents



















# AI in Observability and Grafana

One of the biggest technological breakthroughs of recent years—if not decades—is **Large Language Models (LLMs)** in machine learning, commonly referred to as **AI**.

Tools such as **ChatGPT**, **Google Gemini**, and **Microsoft Copilot** are interfaces that allow us to interact with these models.

Many companies are actively exploring how to integrate AI into their products to make them **smarter, more efficient, and easier to operate**—and **Grafana is no exception**.

In this section, we explore:

* What AI features exist in Grafana
* What is available in **Grafana Cloud vs Open Source**
* How we can use AI **even without Grafana Cloud**

---

## Challenges in Traditional Observability

Large, distributed systems—especially microservice architectures—face major observability challenges:

### 1. High Signal Volume

* Massive amounts of **metrics, logs, and traces**
* Difficult to manually analyze or correlate

### 2. Alert Fatigue

* Static thresholds generate **too many alerts**
* Engineers start ignoring alerts

### 3. Root Cause Analysis Is Hard

* Alerts tell *what* failed, not *why*
* Correlating signals across systems is time-consuming

### 4. Static Thresholds Are Inaccurate

* Workloads are **non-linear**
* Example:

  * E-commerce traffic spikes during holidays
  * Quiet periods during off-season
* Fixed thresholds cause:

  * False positives
  * Missed incidents

---

## How AI Improves Observability

AI brings capabilities beyond traditional threshold-based monitoring:

* **Real-time anomaly detection**
* **Pattern recognition over historical data**
* **Correlation across metrics, logs, and traces**
* **Predictive incident detection**
* **Log summarization**
* **Actionable insights and recommendations**

Large Language Models are especially good at **prediction and pattern recognition**, which makes them well-suited for observability use cases.

---

## AI Capabilities in Grafana

### Grafana Cloud (Managed / Enterprise)

Out-of-the-box AI features include:

* Adaptive alerts using ML models
* Automatic anomaly detection
* Alert tuning to reduce false positives
* Intelligent alert correlation
* Incident noise reduction
* ML-powered insights across metrics, logs, and traces

These features are **not available in Open Source Grafana**.

---

### Grafana Open Source (OSS) Limitations

Grafana OSS:

* ❌ No built-in machine learning
* ❌ No adaptive alerts
* ❌ No automatic anomaly detection
* ❌ No native log summarization

However…

Grafana OSS is **extensible**, and this is where AI can still be leveraged.

---

## Using AI with Grafana Open Source

There are **two practical approaches**:

---

### 1. External AI Tools (No Coding)

You can use:

* ChatGPT
* Google Gemini
* Microsoft Copilot

Use them to:

* Analyze metrics
* Explain PromQL queries
* Interpret logs
* Generate alert rules
* Suggest root causes

This approach requires **good prompt engineering**.

---

### 2. Grafana Plugin + AI APIs (Advanced)

If you know coding:

* Build a Grafana plugin
* Integrate with OpenAI, Gemini, etc.
* Display AI insights directly in Grafana

Grafana provides **Grafana LLM (LM) plugin** for secure AI access.

---

## Prompt Engineering for Observability

To get useful results from AI, structure your prompts properly.

### Key Prompting Techniques

#### 1. Contextual Framing

Provide system context:

```
Metric: http_request_duration_seconds
Source: Node Exporter
99th percentile is very high
What could cause this?
```

#### 2. Few-Shot Prompting

Provide examples:

```
This is a valid PromQL:
rate(http_requests_total[5m])
Now create one filtering status=500 and method=POST
```

#### 3. Chain-of-Thought

Ask for step-by-step reasoning:

```
Explain step by step how to debug CPU usage flatlining in Grafana
```

#### 4. Output Format Control

Specify format:

```
Output must be PromQL only
```

#### 5. Persona Prompting

Assign a role:

```
You are a Site Reliability Engineer
How would you configure disk IO alerts?
```

#### 6. Scoped Prompting

Limit responses:

```
Give only one PromQL query to detect CPU > 80% per pod
```

---

## Practical Example: Metric Analysis with ChatGPT

You expose metrics at:

```
/metrics
```

Instead of manually reading hundreds of metrics, you can:

**Prompt:**

```
You are a Prometheus and .NET expert.
Analyze these metrics and list the most important ones with explanations.
```

**Result:**

* Metric name
* Type (counter, gauge, histogram)
* Meaning
* Usage recommendations

This can save **30–60 minutes** of manual analysis.

---

## AI via Grafana Plugin (Advanced)

Grafana plugins:

* Frontend: **React**
* Backend: **Go**

Grafana provides **Grafana LLM (LM)**:

* Stores API keys securely
* Plugins never access AI APIs directly
* Supports OpenAI, Gemini, etc.

---

## Example Plugin: Alert AI Assistant

What the plugin does:

1. Uses Grafana APIs to:

   * Fetch firing alerts
   * Extract alert queries and thresholds
2. Builds a structured AI prompt:

   ```
   You are a senior SRE.
   An alert fired with these details...
   ```
3. Sends request through Grafana LM
4. Displays:

   * Severity classification
   * Root cause analysis
   * Remediation steps

**Result:**
Faster MTTR and better on-call experience.

---

## Grafana Administration Overview

Grafana is organized around **Organizations**.

### Core Concepts

* **Organizations**

  * Isolation boundary
* **Users**

  * Belong to organizations
* **Teams**

  * Group users
* **Dashboards**

  * Organization-scoped
* **Data Sources**

  * Organization-scoped
* **Service Accounts**

  * Replace API keys for automation

---

## Managing Organizations

* Default org: **Main Org**
* You can create additional orgs (e.g., DevOps)

Each organization has:

* Separate dashboards
* Separate data sources
* Separate users

Switch orgs using the dropdown.

---

## Managing Users

Two ways:

1. Create users manually
2. Invite users via email

Roles:

* Viewer
* Editor
* Admin
* No basic role

Users can belong to **multiple organizations** with different roles.

---

## Teams

Teams:

* Group users
* Simplify permissions
* Can override preferences (theme, timezone)

Admins can:

* Add/remove users
* Delete teams

---

## Organization Isolation

Dashboards and data sources are **not shared across orgs**.

This is critical for:

* Multi-team environments
* Security boundaries

---

## LDAP / Active Directory Authentication

Grafana supports **LDAP authentication**, commonly used with:

* Active Directory
* Apache Directory Services
* Other LDAP-compatible directories

---

### LDAP Authentication Flow

1. User enters credentials in Grafana
2. Grafana binds to LDAP using **bind user**
3. LDAP validates credentials
4. Grafana logs user in

---

### Required LDAP Components

* Domain Controller (or LDAP server)
* Bind user (non-admin)
* User accounts
* Optional: group-based role mapping

---

### Grafana LDAP Configuration

1. Enable LDAP in `grafana.ini`
2. Configure `ldap.toml`
3. Restart Grafana

Key fields:

* Host
* Port (389 default)
* Bind DN
* Bind password
* Search filter
* Base DN

---

### Group-Based Role Mapping

Example:

```
CN=grafana-admins,DC=grafana,DC=local → Admin
```

This allows:

* Automatic role assignment
* Organization mapping

---

## Final Outcome

After configuration:

* Users authenticate via Active Directory
* Roles assigned automatically
* Grafana access controlled centrally
* No local password management needed

---

## Summary

* AI enhances observability beyond static thresholds
* Grafana Cloud offers built-in ML
* Grafana OSS can still leverage AI via:

  * External tools
  * Custom plugins
* Prompt engineering is critical
* Grafana supports strong enterprise administration:

  * Orgs
  * Teams
  * LDAP
  * Service accounts




















# External Authentication, High Availability, Scalability, and Grafana Playground

## External Authentication in Grafana (Google OAuth)

Grafana supports **external authentication**, which means you do not have to create local Grafana users manually.
Instead, users can authenticate using external identity providers such as:

* Google (Google Workspace / Gmail)
* GitHub
* LDAP / Active Directory
* Other OAuth providers

In this lecture, we focus on **Google authentication**.

This is especially useful if your company uses **Google Workspace**, because administrators do not need to manage Grafana credentials manually.

---

### Step 1: Create OAuth Credentials in Google

1. Go to
   **[https://console.developers.google.com](https://console.developers.google.com)**

2. Make sure you have sufficient permissions.

3. From the left menu, select **Credentials**

4. Click **Create Credentials → OAuth Client ID**

5. Choose **Web application**

6. Set:

   * **Name**: `Grafana`
   * **Authorized JavaScript origins**
     Example:

     ```
     http://localhost:3000
     ```
   * **Authorized redirect URIs**

     ```
     http://localhost:3000/login/google
     ```

7. Click **Create**

You will receive:

* **Client ID**
* **Client Secret**

---

### Step 2: Configure Grafana for Google Authentication

Edit your Grafana configuration file:

* `grafana.ini`
* or `custom.ini`

Find the Google auth section:

```ini
[auth.google]
enabled = true
allow_sign_up = true
client_id = YOUR_CLIENT_ID
client_secret = YOUR_CLIENT_SECRET
```

#### Restrict Access to Your Organization (Recommended)

Without restrictions, **any Google user** could log in.

To limit access to your Google Workspace domain:

```ini
allowed_domains = mycompany.com
```

Only users with emails like:

```
user@mycompany.com
```

will be allowed.

---

### Step 3: Restart Grafana

After making changes, **restart Grafana**.

When you open Grafana again, you will see:

* **Sign in with Google**

Users logging in via Google will:

* Be created automatically
* Default to **Viewer** role
* Require admin approval for editor/admin privileges

---

### Benefits of External Authentication

* No manual user creation
* Centralized identity management
* Improved security
* Less administrative overhead

---

## High Availability (HA) in Grafana

When running Grafana in production, **high availability is critical**.

High availability means:

> Grafana continues working even if one instance fails.

---

### Grafana HA Architecture

A standard HA setup includes:

* **2 or more Grafana instances**
* **Load balancer** in front
* **Shared database** (PostgreSQL or MySQL)
* **Identical configuration across all instances**

Flow:

```
Browser → Load Balancer → Grafana Instance
```

---

### Shared Database Requirement

Grafana stores:

* Dashboards
* Alert rules
* Users
* Preferences

All Grafana instances **must use the same database**.

⚠️ The database itself must also be highly available
(e.g., primary + replica / failover).

---

### Shared Configuration Requirement

Each Grafana instance reads `grafana.ini`.

If instances have **different configs**, behavior will be inconsistent.

**Solution:**

* Store `grafana.ini` on a **shared network location**
* All instances read from the same file

---

## Unified Alerting in HA Mode

Grafana includes an internal **Alert Engine (Alertmanager)**.

Problem in HA:

* Each Grafana instance evaluates alerts
* Multiple instances may send **duplicate notifications**

---

### Enable Alertmanager Clustering

In `grafana.ini`, enable unified alerting:

```ini
[unified_alerting]
enabled = true
```

Configure HA peers:

```ini
ha_peers = grafana1:9094,grafana2:9094
```

⚠️ Port **9094** is the **Alertmanager port**, not Grafana UI.

This allows Alertmanagers to:

* Communicate
* Elect a leader
* Send only **one notification per alert**

---

### Limitation of Static HA Peers

If Grafana instances:

* Scale dynamically
* Use auto-scaling
* Have changing IPs

Hardcoding peers becomes impractical.

---

## Scalability with Redis (Dynamic HA)

For dynamic environments, use **Redis**.

Redis acts as:

* Shared state store
* Peer discovery mechanism

---

### Redis-Based HA Configuration

Instead of hardcoding peers, configure Redis:

```ini
[unified_alerting]
ha_redis_address = redis:6379
ha_redis_username = grafana
ha_redis_password = password
ha_redis_db = 0
ha_redis_prefix = grafana
```

Benefits:

* Supports auto-scaling
* Dynamic Grafana instances
* No manual peer management

---

## Scaling Grafana

### VM-Based Scaling

* AWS Auto Scaling Groups
* Azure VM Scale Sets

### Container-Based Scaling

* Kubernetes
* Amazon ECS
* Azure Container Apps

Grafana Docker images scale well in container platforms.

---

## Grafana Playground (Hands-On Lab)

To practice without installing anything locally, use the **Grafana Playground** hosted on Killer Coder.

### Key Characteristics

* Temporary environment (≈ 60 minutes)
* Ubuntu-based
* Docker-powered
* Preconfigured stack:

  * Grafana
  * Prometheus
  * Loki
  * Tempo
  * Example dashboards

---

### How the Playground Works

1. Open the playground URL
2. Select **Setup Grafana Stack**
3. Read instructions on the left
4. Execute commands using clickable tooltips
5. Validate each step
6. Open Grafana and Prometheus via provided links

---

### Login Credentials

* **Username**: `admin`
* **Password**: `admin`

(No need to change password – environment is temporary)

---

### What You Can Explore

* Dashboards with real data
* Prometheus metrics
* Loki logs
* Tempo traces
* Service graph visualization

Everything works end-to-end.

---

## Editing Configuration in the Playground

Use **nano** editor:

* `Ctrl + W` → Search
* `Ctrl + O` → Save
* `Ctrl + X` → Exit

After editing:

```bash
docker restart <container-name>
```

Example:

```bash
docker restart grafana
docker restart prometheus
```

---

## Final Thoughts

Prometheus + Grafana form an excellent **open-source observability stack**, but they require:

* Careful deployment
* Ongoing maintenance
* Scaling considerations

They are ideal for:

* Backend services
* Infrastructure monitoring

However, **frontend observability** and zero-maintenance setups can be complex.





















