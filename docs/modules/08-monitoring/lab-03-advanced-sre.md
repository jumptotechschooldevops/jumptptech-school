# Advanced SRE Lab — Prometheus + Grafana + Node Exporter (6 Years Experience Level)

Goal:  
Learn monitoring and observability like a real Senior SRE.

You will simulate:

  * production incidents
  * CPU bottlenecks
  * memory pressure
  * disk saturation
  * exporter failures
  * alerting
  * troubleshooting
  * PromQL analysis


Architecture:  


```text id="9n3a7x"  
Linux EC2  
↓  
Node Exporter  
↓  
Prometheus  
↓  
Grafana
[code] 
    
    
    ---
    
    # Scenario
    
    You are Senior SRE on-call.
    
    Production application is slow.
    
    Your job:
    
    * detect issue
    * analyze metrics
    * identify bottleneck
    * troubleshoot
    * recover service
    
    ---
    
    # Phase 1 — Verify Monitoring Stack
    
    ## Task 1 — Verify Node Exporter
    
    Run:
    
    
    
    ```bash id="jlwm0k"
    curl localhost:9100/metrics | head
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Questions:

  * What does exporter expose?
  * Is it storing data?
  * Why plaintext metrics?


Expected understanding:

  * exporter only exposes metrics endpoint
  * stateless component
  * lightweight collector


* * *

#  Task 2 — Verify Prometheus Scraping 

Open:  


```text id="jlwm47"  
<http://YOUR_IP:9090/targets>
[code] 
    
    
    Check:
    
    * prometheus → UP
    * node_exporter → UP
    
    Questions:
    
    * Why pull model instead of push?
    * What happens if exporter dies?
    * What happens if Prometheus dies?
    
    ---
    
    # Task 3 — Prometheus Queries
    
    Open:
    
    
    
    ```text id="jlwm8v"
    http://YOUR_IP:9090
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Run:

##  CPU Utilization 

```text id="jlwm4t"  
100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
[code] 
    
    
    ## Memory Available
    
    
    
    ```text id="jlwmx7"
    node_memory_MemAvailable_bytes
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  Filesystem Usage 

```text id="jlwm4j"  
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)
[code] 
    
    
    Questions:
    
    * Why rate() used?
    * Why idle mode subtracted?
    * Why time-series important?
    
    ---
    
    # Phase 2 — Production Incident Simulation
    
    # Incident 1 — CPU Saturation
    
    ## Task
    
    Run:
    
    
    
    ```bash id="jlwm0m"
    stress --cpu 2 --timeout 180
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Observe in Grafana:

  * CPU Busy
  * Sys Load
  * CPU Pressure
  * Idle CPU


Questions:

  * Difference between CPU Busy vs Load?
  * Why pressure matters?
  * When does scaling become necessary?


Expected Senior SRE Analysis:

  * sustained high CPU
  * rising load average
  * scheduler contention
  * resource saturation


* * *

#  Incident 2 — Memory Pressure 

Run:  


```bash id="jlwmt9"  
stress --vm 1 --vm-bytes 300M --timeout 180
[code] 
    
    
    Observe:
    
    * RAM Used
    * Memory Pressure
    * Swap Used
    
    Then:
    
    
    
    ```bash id="jlwme5"
    dmesg | grep -i oom
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Questions:

  * What triggers OOM killer?
  * Difference between cache vs real memory exhaustion?
  * Why swap dangerous for latency-sensitive apps?


Expected Senior SRE Analysis:

  * memory pressure impacts performance before OOM
  * swap causes latency spikes
  * memory leaks vs burst usage


* * *

#  Incident 3 — Disk Saturation 

Create large files:  


```bash id="jlwmyk"  
fallocate -l 2G incidentfile
[code] 
    
    
    Observe:
    
    * Root FS Used
    * Disk IO
    * Filesystem metrics
    
    Questions:
    
    * What happens if Prometheus disk fills?
    * Why monitoring systems themselves need monitoring?
    * How retention policies work?
    
    ---
    
    # Phase 3 — Exporter Failure
    
    ## Task
    
    Stop exporter:
    
    
    
    ```bash id="jlwm2y"
    sudo systemctl stop node_exporter
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Observe:

  * Prometheus Targets → DOWN
  * Grafana panels fail


Questions:

  * Why dashboards fail?
  * Difference between exporter outage vs server outage?
  * How to alert on missing metrics?


Recover:  


```bash id="jlwmx8"  
sudo systemctl start node_exporter
[code] 
    
    
    ---
    
    # Phase 4 — Prometheus Storage Internals
    
    ## Task
    
    Inspect TSDB:
    
    
    
    ```bash id="jlwm6k"
    sudo du -sh /var/lib/prometheus
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Inspect contents:  


```bash id="jlwm3o"  
ls /var/lib/prometheus
[code] 
    
    
    Questions:
    
    * What is WAL?
    * Why chunk storage?
    * Why Prometheus disk grows over time?
    
    Expected understanding:
    Write-ahead logging
    
    ---
    
    # Phase 5 — Alerting
    
    ## Create CPU Alert
    
    Create:
    
    
    
    ```bash id="jlwmlo"
    sudo nano /etc/prometheus/alert.rules.yml
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Add:  


```yaml id="jlwm4u"  
groups:

  * name: sre-alerts rules: 
    * alert: HighCPUUsage expr: 100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 70 for: 1m labels: severity: critical annotations: summary: High CPU Usage ``` 


Add to prometheus.yml:  


```yaml id="jlwm0f"  
rule_files:

  * "alert.rules.yml" ``` 


Restart:  


```bash id="jlwmcl"  
sudo systemctl restart prometheus
[code] 
    
    
    Trigger stress again.
    
    Questions:
    
    * Why “for: 1m” important?
    * Why avoid noisy alerts?
    * Difference between symptom vs cause alerts?
    
    ---
    
    # Phase 6 — Real SRE Troubleshooting
    
    ## Scenario
    
    Dashboard shows:
    
    * CPU normal
    * Load high
    * IOwait high
    
    Questions:
    
    * What does that indicate?
    * Why app still slow?
    
    Expected answer:
    
    * storage bottleneck
    * tasks blocked waiting for IO
    * CPU not actual issue
    
    ---
    
    # Phase 7 — Capacity Planning
    
    Questions:
    
    * When scale vertically?
    * When scale horizontally?
    * Why t3.micro unsuitable for production monitoring?
    * How Prometheus retention affects storage sizing?
    
    ---
    
    # Senior SRE Concepts You Must Understand
    
    | Concept          | Expected Understanding  |
    | ---------------- | ----------------------- |
    | Pull model       | Prometheus scraping     |
    | Time-series DB   | metric history          |
    | Pressure metrics | resource contention     |
    | Load average     | runnable/waiting tasks  |
    | OOM killer       | memory protection       |
    | WAL              | crash-safe storage      |
    | Alert fatigue    | noisy alert problems    |
    | Cardinality      | metric explosion risk   |
    | Retention        | storage lifecycle       |
    | Observability    | metrics + logs + traces |
    
    ---
    
    # Final Senior-Level Goal
    
    You should now explain:
    
    
    
    ```text id="jlwm8z"
    How Linux metrics flow from kernel → exporter → Prometheus → Grafana → alerting → SRE response
    
[/code]

Enter fullscreen mode Exit fullscreen mode

That is real production observability engineering.
