# Lab 2 — Your First Grafana Dashboard (Built from Scratch)

##  What you will build 

Panel | Type | What it measures  
---|---|---  
CPU usage % | Time series | How hard your cores are working  
System load (1m/5m/15m) | Time series | Load average trend  
Memory used vs available | Time series | RAM consumption  
Disk usage % | Gauge | How full your root partition is  
Network traffic (in/out) | Time series | Bytes per second on eth0  
Key metrics snapshot | Table | Current values side by side  
  
* * *

##  Part 1 — Connect Grafana to Prometheus 

  1. Open Grafana: `http://<EC2-PUBLIC-IP>:3000` (default login: `admin / admin`)
  2. Go to **Connections → Data sources → Add data source**
  3. Select **Prometheus**
  4. Set URL to `http://localhost:9090`
  5. Click **Save & test** — you should see a green success message


> Why `localhost`? Grafana and Prometheus live on the same machine. Using localhost avoids exposing Prometheus to the internet.

* * *

##  Part 2 — Panel 1: CPU Usage % 

**Visualization:** Time series  

[code] 
    100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

**Settings:** Unit → `Percent (0-100)` · Min `0` · Max `100` · Threshold warning at `70`, critical at `90`

**Verify:** Run `stress-ng --cpu 2 --timeout 60s` and watch the panel spike.

* * *

##  Part 3 — Panel 2: System Load Average 

**Visualization:** Time series — add 3 queries:  

[code] 
    node_load1    # legend: 1m load
    node_load5    # legend: 5m load
    node_load15   # legend: 15m load
    
[/code]

Enter fullscreen mode Exit fullscreen mode

**Settings:** Unit → `Short` · Add a threshold line at your core count (e.g. 2 for t2.micro)

> Load above core count = system is struggling to keep up.

* * *

##  Part 4 — Panel 3: Memory Usage 

**Visualization:** Time series — add 2 queries:  

[code] 
    node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes   # legend: Used
    node_memory_MemAvailable_bytes                                 # legend: Available
    
[/code]

Enter fullscreen mode Exit fullscreen mode

**Settings:** Unit → `bytes(IEC)` · Enable **Stack series**

**Verify:** `stress-ng --vm 1 --vm-bytes 400M --timeout 60s`

* * *

##  Part 5 — Panel 4: Disk Usage (Gauge) 

**Visualization:** Gauge  

[code] 
    100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="tmpfs"} 
          / node_filesystem_size_bytes{mountpoint="/",fstype!="tmpfs"}) * 100)
    
[/code]

Enter fullscreen mode Exit fullscreen mode

**Settings:** Unit → `Percent (0-100)` · Thresholds: `0` green → `70` yellow → `85` red

* * *

##  Part 6 — Panel 5: Network Traffic 

**Visualization:** Time series — add 2 queries:  

[code] 
    rate(node_network_receive_bytes_total{device="eth0"}[5m])    # legend: In
    rate(node_network_transmit_bytes_total{device="eth0"}[5m])   # legend: Out
    
[/code]

Enter fullscreen mode Exit fullscreen mode

**Settings:** Unit → `bytes/sec(IEC)`

> If your instance uses `ens5` instead of `eth0`, check with: `node_network_receive_bytes_total` in the Prometheus UI and look at the `device` label.

* * *

##  Part 7 — Panel 6: Key Metrics Table 

**Visualization:** Table — set each query to **Instant** , add Reduce transformation → Last  

[code] 
    100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)          # CPU %
    node_load1                                                                   # Load 1m
    (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) 
      / node_memory_MemTotal_bytes * 100                                        # Memory %
    100 - ((node_filesystem_avail_bytes{mountpoint="/"} 
          / node_filesystem_size_bytes{mountpoint="/"}) * 100)                 # Disk %
    
[/code]

Enter fullscreen mode Exit fullscreen mode

* * *

##  Part 8 — Save and stress test 

Save the dashboard as **EC2 System Health**. Set auto-refresh to `30s`.

Then run all three stressors simultaneously:  

[code] 
    stress-ng --cpu 2 --timeout 120s &
    stress-ng --vm 1 --vm-bytes 500M --timeout 120s &
    stress-ng --io 2 --timeout 120s
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Watch all panels respond in real time. After stress ends, verify metrics return to baseline.

* * *

##  Checkpoint questions 

Answer before moving to Lab 3:

  1. Why use `rate()` on `node_cpu_seconds_total` instead of the raw value?
  2. What does load average `4.0` mean on a 2-core machine?
  3. Why does the disk query use `avail_bytes` not `free_bytes`?
  4. What changes if you switch `[5m]` to `[1m]` in the CPU query?
  5. Why is `avg by(instance)` important in a multi-host setup?
