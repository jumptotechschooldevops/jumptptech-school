# SRE Monitoring Lab 1

#  Install Node Exporter + Connect Prometheus + Build Grafana Dashboard on AWS EC2 

This is your FIRST real observability/SRE production-style lab.

You already have:

  * Prometheus
  * Grafana


installed on one Ubuntu EC2 machine.

Now you will:

  1. Install Node Exporter
  2. Configure Prometheus scraping
  3. Connect Grafana
  4. Import production dashboard
  5. Generate load
  6. Analyze metrics
  7. Troubleshoot failures like real SRE engineers


* * *

#  WHAT SRE ENGINEERS MUST UNDERSTAND FIRST 

* * *

#  What Is Monitoring? 

Monitoring means:  


```text id="w7r46n"  
Watching infrastructure and applications continuously.
[code] 
    
    
    Example:
    
    * Is CPU high?
    * Is memory full?
    * Is disk almost full?
    * Is network overloaded?
    * Is server healthy?
    * Is service down?
    
    ---
    
    # What Is Observability?
    
    Observability means:
    
    
    
    ```text id="xl5k5f"
    Understanding WHY something failed.
    
[/code]

Enter fullscreen mode Exit fullscreen mode

SRE engineers use:

Tool | Purpose  
---|---  
Metrics | Numbers over time  
Logs | Events/messages  
Traces | Request flow  
Dashboards | Visualization  
Alerts | Notifications  
  
* * *

#  HOW THIS LAB WORKS 

```text id="2h8l1u"  
Node Exporter  
↓  
Prometheus scrapes metrics  
↓  
Prometheus stores metrics  
↓  
Grafana visualizes metrics
[code] 
    
    
    ---
    
    # WHAT IS NODE EXPORTER?
    
    Node Exporter is a Linux metrics collector.
    
    It exposes metrics on:
    
    
    
    ```text id="w97dhf"
    PORT 9100
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Example metrics:  


```text id="09f9ii"  
CPU usage  
Memory usage  
Disk usage  
Filesystem  
Processes  
Load average  
Network traffic
[code] 
    
    
    ---
    
    # WHAT SRE ENGINEERS MUST KNOW
    
    ## Prometheus is PULL based
    
    Meaning:
    
    
    
    ```text id="ic4qxu"
    Prometheus goes and asks for metrics.
    
[/code]

Enter fullscreen mode Exit fullscreen mode

NOT:  


```text id="u0wyoh"  
Server pushes metrics.
[code] 
    
    
    Prometheus periodically scrapes:
    
    
    
    ```text id="vv4ybh"
    http://target:9100/metrics
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  LAB ARCHITECTURE 

```text id="0nnml1"  
EC2 Ubuntu Instance  
│  
├── Prometheus :9090  
├── Grafana :3000  
└── Node Exporter :9100
[code] 
    
    
    ---
    
    # STEP 1 — LOGIN TO AWS
    
    Go to:
    
    [AWS Console](https://console.aws.amazon.com?utm_source=chatgpt.com)
    
    ---
    
    # STEP 2 — OPEN EC2
    
    Click:
    
    
    
    ```text id="tyt5hv"
    Services
    → EC2
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 3 — FIND YOUR INSTANCE 

Click:  


```text id="v7y40j"  
Instances
[code] 
    
    
    Find your Ubuntu server.
    
    You should see:
    
    | Column         | Example           |
    | -------------- | ----------------- |
    | Instance State | Running           |
    | Public IPv4    | 3.xx.xx.xx        |
    | Name           | monitoring-server |
    
    ---
    
    # STEP 4 — CONNECT TO EC2
    
    Select instance.
    
    Click:
    
    
    
    ```text id="cgnv0y"
    Connect
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Choose:  


```text id="gzwu0d"  
EC2 Instance Connect
[code] 
    
    
    Click:
    
    
    
    ```text id="pw3kpa"
    Connect
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Terminal opens.

* * *

#  STEP 5 — VERIFY PROMETHEUS 

Run:  


```bash id="f1jlsm"  
sudo systemctl status prometheus
[code] 
    
    
    You should see:
    
    
    
    ```text id="q0ovv5"
    active (running)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 6 — VERIFY GRAFANA 

Run:  


```bash id="0v8cwe"  
sudo systemctl status grafana-server
[code] 
    
    
    You should see:
    
    
    
    ```text id="z1r6cc"
    active (running)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 7 — INSTALL NODE EXPORTER 

* * *

##  Go to /tmp 

```bash id="jupzwy"  
cd /tmp
[code] 
    
    
    ---
    
    ## Download Node Exporter
    
    
    
    ```bash id="u1t3n6"
    wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
    
[/code]

Enter fullscreen mode Exit fullscreen mode

SRE understanding:

Part | Meaning  
---|---  
wget | download file  
tar.gz | compressed archive  
linux-amd64 | Linux 64-bit version  
  
* * *

#  STEP 8 — EXTRACT FILE 

```bash id="dbkewd"  
tar -xvf node_exporter-1.9.1.linux-amd64.tar.gz
[code] 
    
    
    Meaning:
    
    | Flag | Meaning |
    | ---- | ------- |
    | x    | extract |
    | v    | verbose |
    | f    | file    |
    
    ---
    
    # STEP 9 — MOVE BINARY
    
    
    
    ```bash id="cz5yya"
    sudo mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/
    
[/code]

Enter fullscreen mode Exit fullscreen mode

SRE understanding:  


```text id="11k31t"  
/usr/local/bin
[code] 
    
    
    stores executables.
    
    ---
    
    # STEP 10 — CREATE SERVICE USER
    
    
    
    ```bash id="euhlkj"
    sudo useradd -rs /bin/false node_exporter
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  WHY? 

SRE engineers NEVER run services as root unless required.

Security best practice:  


```text id="8c69v7"  
Least privilege
[code] 
    
    
    ---
    
    # STEP 11 — CREATE SYSTEMD SERVICE
    
    Run:
    
    
    
    ```bash id="o7pyvf"
    sudo nano /etc/systemd/system/node_exporter.service
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Paste:  


```ini id="txyh6y"  
[Unit]  
Description=Node Exporter  
After=network.target

[Service]  
User=node_exporter  
Group=node_exporter  
Type=simple  
ExecStart=/usr/local/bin/node_exporter

[Install]  
WantedBy=multi-user.target
[code] 
    
    
    ---
    
    # WHAT SRE ENGINEERS MUST KNOW
    
    ## systemd
    
    Linux service manager.
    
    Controls:
    
    * starting services
    * stopping services
    * restarting services
    * logs
    * boot startup
    
    ---
    
    # SAVE FILE
    
    Press:
    
    
    
    ```text id="p5agkm"
    CTRL + X
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Then:  


```text id="l0t7zv"  
Y
[code] 
    
    
    Then:
    
    
    
    ```text id="v5zzdn"
    ENTER
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 12 — START NODE EXPORTER 

Run:  


```bash id="68l7yd"  
sudo systemctl daemon-reload
[code] 
    
    
    Meaning:
    
    
    
    ```text id="g10qeo"
    Reload systemd configs.
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

Enable startup:  


```bash id="5qihkg"  
sudo systemctl enable node_exporter
[code] 
    
    
    Start service:
    
    
    
    ```bash id="f6h6gw"
    sudo systemctl start node_exporter
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 13 — VERIFY SERVICE 

```bash id="31d9g8"  
sudo systemctl status node_exporter
[code] 
    
    
    You should see:
    
    
    
    ```text id="2ww4vc"
    active (running)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 14 — CHECK PORT 

Run:  


```bash id="h44jl6"  
ss -tulnp | grep 9100
[code] 
    
    
    You should see:
    
    
    
    ```text id="mty7sf"
    LISTEN
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  SRE UNDERSTANDING 

Command | Purpose  
---|---  
ss | socket statistics  
-t | TCP  
-u | UDP  
-l | listening  
-n | numeric  
-p | process  
  
* * *

#  STEP 15 — OPEN SECURITY GROUP 

Go back to AWS.

* * *

##  Click: 

```text id="x3xv11"  
EC2  
→ Instances  
→ Select instance
[code] 
    
    
    ---
    
    ## Bottom Tab
    
    Click:
    
    
    
    ```text id="61jmtq"
    Security
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

##  Click Security Group 

Under:  


```text id="c4g9nr"  
Security groups
[code] 
    
    
    click the SG.
    
    ---
    
    # STEP 16 — EDIT INBOUND RULES
    
    Click:
    
    
    
    ```text id="m8n6d7"
    Edit inbound rules
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Add:

Type | Port | Source  
---|---|---  
Custom TCP | 3000 | 0.0.0.0/0  
Custom TCP | 9090 | 0.0.0.0/0  
Custom TCP | 9100 | 0.0.0.0/0  
  
Click:  


```text id="d7fw5v"  
Save rules
[code] 
    
    
    ---
    
    # WHAT SRE ENGINEERS MUST KNOW
    
    | Port | Service       |
    | ---- | ------------- |
    | 3000 | Grafana       |
    | 9090 | Prometheus    |
    | 9100 | Node Exporter |
    
    ---
    
    # STEP 17 — TEST NODE EXPORTER
    
    Browser:
    
    
    
    ```text id="m8db1x"
    http://YOUR_PUBLIC_IP:9100/metrics
    
[/code]

Enter fullscreen mode Exit fullscreen mode

You should see THOUSANDS of metrics.

* * *

#  IMPORTANT SRE CONCEPT 

Metrics format:  


```text id="dcew0u"  
metric_name value
[code] 
    
    
    Example:
    
    
    
    ```text id="3b1fmb"
    node_cpu_seconds_total
    node_memory_MemAvailable_bytes
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 18 — CONFIGURE PROMETHEUS 

Terminal:  


```bash id="2d3a4m"  
sudo nano /etc/prometheus/prometheus.yml
[code] 
    
    
    Find:
    
    
    
    ```yaml id="m1cljx"
    scrape_configs:
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Add:  


```yaml id="mnjgx0"

  * job_name: "node_exporter"

static_configs:

    * targets: ["localhost:9100"] ``` 


* * *

#  WHAT SRE ENGINEERS MUST KNOW 

##  scrape_configs 

Defines WHAT Prometheus monitors.

* * *

##  targets 

Defines WHERE metrics exist.

* * *

#  STEP 19 — RESTART PROMETHEUS 

```bash id="zv1rxn"  
sudo systemctl restart prometheus
[code] 
    
    
    Verify:
    
    
    
    ```bash id="2t6x4x"
    sudo systemctl status prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 20 — CHECK TARGETS 

Browser:  


```text id="4n0h5v"  
<http://YOUR_PUBLIC_IP:9090/targets>
[code] 
    
    
    You should see:
    
    
    
    ```text id="ajut3e"
    node_exporter UP
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  WHAT DOES UP MEAN? 

Prometheus successfully scraped metrics.

* * *

#  IF DOWN? 

Possible reasons:

Problem | Meaning  
---|---  
Wrong IP | Incorrect target  
Firewall | Port blocked  
SG | AWS blocked  
Service stopped | Exporter down  
Wrong port | Misconfiguration  
  
* * *

#  STEP 21 — OPEN GRAFANA 

Browser:  


```text id="3m90yo"  
<http://YOUR_PUBLIC_IP:3000>
[code] 
    
    
    Login:
    
    
    
    ```text id="e8lqq9"
    admin
    admin
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Change password.

* * *

#  STEP 22 — ADD PROMETHEUS DATASOURCE 

Left menu:  


```text id="ez94oq"  
Connections  
→ Data Sources
[code] 
    
    
    Click:
    
    
    
    ```text id="3bupw0"
    Add data source
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Choose:  


```text id="1zj5df"  
Prometheus
[code] 
    
    
    ---
    
    # STEP 23 — CONFIGURE DATASOURCE
    
    URL:
    
    
    
    ```text id="th62k4"
    http://localhost:9090
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Scroll down.

Click:  


```text id="u9jx3o"  
Save & Test
[code] 
    
    
    You should see:
    
    
    
    ```text id="a7n1s8"
    Data source is working
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  STEP 24 — IMPORT DASHBOARD 

Left menu:  


```text id="d8g2gs"  
Dashboards
[code] 
    
    
    Click:
    
    
    
    ```text id="7vvjlwm"
    Import
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Dashboard ID:  


```text id="vh7q0h"  
1860
[code] 
    
    
    Click:
    
    
    
    ```text id="fhp88p"
    Load
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Choose datasource.

Click:  


```text id="0xyvdo"  
Import
[code] 
    
    
    ---
    
    # NOW YOU WILL SEE
    
    Real-time:
    
    * CPU
    * Memory
    * Disk
    * Filesystem
    * Network
    * Load Average
    * Processes
    
    ---
    
    # STEP 25 — GENERATE CPU LOAD
    
    Now act like SRE engineer.
    
    Install stress tool:
    
    
    
    ```bash id="zwukbd"
    sudo apt install stress -y
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Generate load:  


```bash id="dvv1tb"  
stress --cpu 2 --timeout 60
[code] 
    
    
    ---
    
    # WHAT HAPPENS?
    
    
    
    ```text id="1ux1a8"
    CPU usage increases.
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Go to Grafana dashboard.

Watch graphs move LIVE.

THIS is real observability.

* * *

#  WHAT SRE ENGINEERS ANALYZE 

Metric | Meaning  
---|---  
CPU | Processing usage  
Memory | RAM consumption  
Disk IO | Read/write operations  
Network | Traffic  
Load Average | System pressure  
Filesystem | Disk usage  
  
* * *

#  STEP 26 — BREAK THINGS 

Stop exporter:  


```bash id="yu8y1g"  
sudo systemctl stop node_exporter
[code] 
    
    
    Go to:
    
    
    
    ```text id="3o8l4f"
    http://YOUR_PUBLIC_IP:9090/targets
    
[/code]

Enter fullscreen mode Exit fullscreen mode

You should see:  


```text id="n72nci"  
DOWN
[code] 
    
    
    ---
    
    # THIS IS REAL SRE TROUBLESHOOTING
    
    SRE engineers always ask:
    
    
    
    ```text id="o4njzi"
    Why is target DOWN?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  TROUBLESHOOTING FLOW 

##  Step 1 

Check service:  


```bash id="xen6ko"  
sudo systemctl status node_exporter
[code] 
    
    
    ---
    
    ## Step 2
    
    Check listening port:
    
    
    
    ```bash id="s4rfp0"
    ss -tulnp | grep 9100
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

##  Step 3 

Check metrics endpoint:  


```bash id="8bjv4r"  
curl localhost:9100/metrics
[code] 
    
    
    ---
    
    ## Step 4
    
    Check Prometheus logs:
    
    
    
    ```bash id="eotnlc"
    journalctl -u prometheus -f
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

#  WHAT SRE ENGINEERS MUST MEMORIZE 

Tool | Purpose  
---|---  
systemctl | Service management  
ss | Check ports  
curl | Test endpoint  
journalctl | Logs  
top | CPU  
free -m | Memory  
df -h | Disk  
  
* * *

#  MOST IMPORTANT INTERVIEW QUESTIONS 

* * *

#  What is Node Exporter? 

Exports Linux system metrics for Prometheus.

* * *

#  Why use exporters? 

Prometheus cannot directly understand Linux metrics.

* * *

#  Why is Prometheus pull based? 

Prometheus periodically scrapes targets.

Advantages:

  * centralized
  * easier troubleshooting
  * better reliability
  * service discovery support


* * *

#  Difference Between Grafana and Prometheus? 

Tool | Purpose  
---|---  
Prometheus | stores metrics  
Grafana | visualizes metrics  
  
* * *

#  What is a target? 

A monitored endpoint.

Example:  


```text id="m34fbe"  
localhost:9100
[code] 
    
    
    
[/code]

Enter fullscreen mode Exit fullscreen mode
