# Lecture 1 · Computer Hardware for SRE Engineers

Understanding the physical machine underneath your containers and VMs changes how you read metrics, size capacity, and diagnose incidents. This lecture maps each hardware component to the Linux commands that expose it and the failure modes you will face on call.

---

## Memory hierarchy

Before diving into individual components, internalise this hierarchy. Every performance problem ultimately traces back to it.

```
Latency (approx.)   Storage
─────────────────   ─────────────────────────────────
  ~1 ns             L1 cache  (32–64 KB per core)
  ~4 ns             L2 cache  (256 KB – 1 MB per core)
  ~30 ns            L3 cache  (8–64 MB, shared across cores)
  ~100 ns           RAM       (DDR4/DDR5, GBs to TBs)
  ~100 µs           NVMe SSD
  ~500 µs           SATA SSD
  ~5–10 ms          HDD
  ~40–200 ms        Network (cross-datacenter)
```

The rule: **the further down data is, the slower it is to retrieve**. A CPU stall waiting for RAM takes 100× longer than an L1 hit. An application waiting on HDD I/O wastes millions of CPU cycles.

As an SRE you use this hierarchy to explain:
- Why a service slows down when its working set no longer fits in RAM (it starts hitting disk)
- Why a database with a hot dataset in the buffer pool is fast (L3/RAM hits)
- Why container colocation causes CPU cache thrash between tenants

---

## CPU

### Cores, threads, and hyperthreading

A modern server CPU is a single physical chip containing multiple **cores**. Each core is an independent execution unit that can run one instruction stream at a time.

**Hyperthreading** (Intel) / **SMT** (AMD) exposes each physical core as two logical processors to the OS. The two logical threads share the core's execution units and cache. Under real workloads this provides ~20–30% throughput improvement — but the two logical threads compete for resources, so a CPU-bound workload on one thread hurts the other.

```bash
# Count logical CPUs (cores × threads-per-core)
nproc

# Full CPU topology
lscpu

# Example output fields to note:
# CPU(s):                  64
# Thread(s) per core:      2     ← hyperthreading is on
# Core(s) per socket:      16
# Socket(s):               2
# L1d cache:               32K
# L2 cache:                1024K
# L3 cache:                22528K

# Raw kernel view
cat /proc/cpuinfo | grep -E "model name|cpu cores|siblings" | sort -u
```

### Cache levels

| Level | Size (typical) | Latency | Scope |
|-------|---------------|---------|-------|
| L1 | 32–64 KB | ~1–4 ns | Per core, split into data and instruction caches |
| L2 | 256 KB – 1 MB | ~4–12 ns | Per core |
| L3 | 8–64 MB | ~30–40 ns | Shared across all cores on a socket |

Cache misses are invisible in application code but show up in profiling. A cache-unfriendly data structure (linked list vs array) can reduce throughput by 10×.

### Monitoring CPU

#### top — live overview

```bash
top

# Key fields in the header:
# %us  — user space (your application)
# %sy  — kernel (system calls, interrupts)
# %id  — idle
# %wa  — I/O wait (CPU is idle because it is waiting for disk or network)
# %hi  — hardware interrupt handling
# %si  — software interrupt handling
# %st  — steal time (CPU cycles stolen by the hypervisor — important on VMs)

# Interactive: press 1 to expand per-CPU view
# Press P to sort by CPU, M for memory
```

High `%wa` means the CPU is not the bottleneck — storage or network is.  
High `%st` (steal) on a VM means the host is overcommitted; escalate to cloud provider or resize.

#### mpstat — per-CPU statistics

```bash
# Install: apt install sysstat
mpstat -P ALL 1          # per-CPU stats every 1 second
mpstat -P ALL 1 5        # 5 samples

# Example output:
# CPU    %usr   %sys  %iowait  %irq  %soft  %idle
# all    12.5    3.2      0.4   0.1    0.3   83.5
#   0    25.0    4.1      0.2   0.2    0.1   70.4
#   1     0.1    2.3      0.6   0.0    0.5   96.5
```

Uneven per-CPU load (one core at 100%, others idle) indicates a single-threaded bottleneck or interrupt affinity problem.

#### perf — low-level profiling

```bash
# Install: apt install linux-tools-$(uname -r)

# Count CPU performance events for 5 seconds
perf stat -a sleep 5

# Key metrics in output:
# task-clock           — how many ms of CPU time
# context-switches     — how often threads swapped
# cpu-migrations       — threads bouncing between cores (cache thrash)
# cache-misses         — L3 cache miss rate
# instructions         — total instructions executed
# cycles               — total CPU cycles

# Profile which functions consume most CPU (30 seconds)
perf record -g -a sleep 30
perf report

# Flame graph (requires FlameGraph tool)
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

#### SRE CPU troubleshooting pattern

```bash
# Step 1: Is CPU actually the bottleneck?
uptime
# Load > nproc means processes are queuing

# Step 2: Which process is consuming it?
top -b -n 1 | head -20

# Step 3: Which core / is it symmetric?
mpstat -P ALL 1 3

# Step 4: User or kernel space?
# High %us → application logic, check perf
# High %sy → syscall overhead (often network or I/O heavy apps)
# High %si → interrupt storm, often NIC-related

# Step 5: Profile the offending PID
perf top -p <PID>
```

---

## RAM

### How RAM works for an SRE

Linux never lets RAM sit idle. The kernel uses free memory as a **page cache** — recently read files are cached in RAM so repeated reads are served from memory. When an application needs more RAM than is free, the kernel reclaims page cache first. If that is not enough, it may use swap.

```bash
# Instant memory summary
free -h

#               total    used    free   shared  buff/cache   available
# Mem:           31Gi    8.1Gi  1.2Gi    350Mi       22Gi      22Gi
# Swap:           8Gi      0Gi  8.0Gi

# "available" is what matters — it includes reclaimable cache
# "free" alone is almost always misleadingly small

# Kernel's view
cat /proc/meminfo

# Key fields:
# MemTotal:     — total physical RAM
# MemAvailable: — what new processes can actually use
# Cached:       — page cache (can be reclaimed)
# SwapTotal/SwapFree — swap space
# HugePages_Total — huge pages configured (databases love these)
```

### vmstat — memory and CPU pressure together

```bash
vmstat 1          # print one row per second
vmstat 1 10       # 10 samples

# Columns:
# r  — runnable processes (waiting for CPU)
# b  — blocked processes (waiting for I/O)
# swpd — swap in use (KB)
# free — free memory (KB)
# buff — buffer memory
# cache — page cache
# si   — swap in (KB/s) — pages being read from swap
# so   — swap out (KB/s) — pages being written to swap
# bi   — blocks in from disk (reads)
# bo   — blocks out to disk (writes)
# cs   — context switches/s
# us/sy/id/wa — same as top

# Red flags:
# si/so > 0 consistently → swap is active → memory pressure
# b > 0 consistently     → I/O bottleneck
# r >> nproc             → CPU saturation
```

### Swap

Swap is disk space used to extend virtual memory. When the kernel writes an inactive memory page to swap, it is called **swapping out**. Reading it back is **swapping in**.

```bash
# View swap partitions / files
swapon --show

# Add a swap file (temporary — survives until reboot if added to /etc/fstab)
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# How aggressively the kernel uses swap (0 = avoid swap, 100 = swap freely)
cat /proc/sys/vm/swappiness
# Default: 60. For servers with ample RAM: set to 10
sysctl vm.swappiness=10

# Check what is in swap
smem -r | head      # or /proc/<pid>/smaps
```

On production application servers, sustained swap activity is a symptom to fix, not to tune around. The real fix is more RAM or less memory usage.

### OOM killer

When the system runs out of both RAM and swap, the kernel **OOM killer** (Out-Of-Memory killer) terminates a process to recover memory. It chooses the process with the highest **oom_score** — roughly proportional to memory usage.

```bash
# Check if OOM killer has fired recently
dmesg | grep -i "oom\|killed process\|out of memory"
journalctl -k | grep -i oom

# Example OOM message in dmesg:
# Out of memory: Kill process 18345 (java) score 892 or sacrifice child

# Check OOM score of a running process
cat /proc/<PID>/oom_score          # current score (0–1000)
cat /proc/<PID>/oom_score_adj      # adjustment (-1000 to +1000)

# Protect a critical process from being OOM-killed
echo -1000 > /proc/<PID>/oom_score_adj

# Make a process more likely to be killed first
echo 1000 > /proc/<PID>/oom_score_adj
```

#### SRE RAM troubleshooting pattern

```bash
# Is there memory pressure right now?
free -h                      # check "available"
vmstat 1 5                   # watch si/so columns

# What is consuming memory?
ps aux --sort=-%mem | head -10
# or
smem -r | head -10           # RSS + shared memory

# Has OOM killed anything?
dmesg -T | grep -i oom | tail -20

# Per-process detailed breakdown
cat /proc/<PID>/status | grep -i vm
# VmRSS = physical RAM currently used
# VmSwap = how much of this process is in swap
```

---

## Storage

### HDD vs SSD vs NVMe

| Type | Interface | Random 4KB IOPS | Sequential read | Latency |
|------|-----------|-----------------|-----------------|---------|
| HDD (7200 RPM) | SATA | ~100–150 | ~150 MB/s | 5–10 ms |
| SATA SSD | SATA | ~50,000–100,000 | ~550 MB/s | ~0.1 ms |
| NVMe SSD | PCIe | ~500,000–1,000,000 | ~3,500 MB/s | ~0.02 ms |

**IOPS** (I/O Operations Per Second) matters more than throughput for databases and small-file workloads. A Postgres instance doing random 8 KB reads is IOPS-bound, not bandwidth-bound.

HDDs use a spinning magnetic disk with a physical read/write head. Seek time (moving the head to the right track) is the dominant cost. SSDs and NVMe have no moving parts — they use NAND flash cells. NVMe bypasses the legacy SATA controller and talks directly to the CPU over PCIe lanes.

### iostat — disk I/O statistics

```bash
# Install: apt install sysstat
iostat -x 1              # extended stats, 1-second interval
iostat -x 1 5            # 5 samples for device sda

# Key columns in -x output:
# rrqm/s  — read requests merged per second
# wrqm/s  — write requests merged per second
# r/s     — read IOPS
# w/s     — write IOPS
# rMB/s   — read throughput (MB/s)
# wMB/s   — write throughput (MB/s)
# await   — average I/O latency (ms) ← most important
# %util   — how busy the device is (100% = saturated)

# Drill into specific device
iostat -xz 1 -d sda

# Red flags:
# await > 10ms on SSD  → SSD degrading or queue depth too high
# await > 20ms on HDD  → normal for random I/O but investigate at 50ms+
# %util near 100%      → device is saturated
```

### Finding what is doing the I/O

```bash
# Which processes are hitting disk most?
iotop -o          # only show processes with active I/O (needs root)
iotop -boa        # batch mode, only active, accumulated stats

# Which files are being read/written?
lsof +D /var/lib/mysql    # all files open in a directory
fatrace                    # trace file access live (requires root)

# Block device queue depth
cat /sys/block/sda/queue/nr_requests

# Check filesystem usage
df -h
df -i             # inode usage — a full inode table prevents new files even with free space

# Find large files eating disk
du -sh /var/log/* | sort -rh | head -10
find /var -type f -size +100M -exec ls -lh {} \;
```

### SRE storage troubleshooting pattern

```bash
# Step 1: Is disk the bottleneck?
iostat -x 1 5          # watch %util and await

# Step 2: Who is doing the I/O?
iotop -o

# Step 3: Is it reads or writes?
# Reads: page cache cold (after reboot, or working set too large)
# Writes: application writing too much, or fsync() on every transaction

# Step 4: Check filesystem health
dmesg | grep -iE "ext4|xfs|btrfs|error|corrupt"

# Step 5: Check physical drive health
smartctl -a /dev/sda   # install: apt install smartmontools
# Look for: Reallocated_Sector_Ct, Pending_Sector_Count, Offline_Uncorrectable
```

---

## NIC (Network Interface Card)

### Bandwidth, throughput, and packet drops

Every NIC has a **line rate** — the maximum bits per second it can physically transmit. Common server NICs: 1 Gbps, 10 Gbps, 25 Gbps, 100 Gbps.

A 10 Gbps NIC can transmit:
- ~1,250 MB/s of throughput
- But at small packet sizes (e.g., 64-byte UDP), it is limited by **PPS** (packets per second) — typically ~14.9 million PPS for 10 Gbps at minimum packet size

Packet drops occur when:
1. The NIC ring buffer fills up (kernel is not draining it fast enough)
2. The network switch is congested (drops upstream)
3. CPU interrupt handling is too slow

```bash
# Current interface stats
ip -s link show eth0
# Or for all interfaces:
ip -s link

# Key counters:
# RX/TX bytes         — cumulative bytes transferred
# RX/TX packets       — cumulative packet count
# RX errors           — receive errors (hardware, CRC, etc.)
# RX dropped          — packets dropped in kernel (ring buffer full)
# RX overrun          — hardware buffer overflow
# TX errors/dropped   — transmit-side drops

# Watch in real time (1-second deltas)
watch -n1 "ip -s link show eth0"
```

### Monitoring network throughput

```bash
# Bandwidth utilisation — live
nload eth0           # install: apt install nload
iftop                # install: apt install iftop (shows per-connection breakdown)
nethogs              # per-process network usage (install: apt install nethogs)

# Using ss (socket statistics)
ss -s               # summary: total TCP, UDP, listening, established
ss -tnp             # all TCP connections with process names
ss -tnp state established | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head
# → top remote IPs consuming connections

# Check for TCP retransmits (sign of network congestion or packet loss)
ss -tin             # shows retransmit count per connection
netstat -s | grep -i retransmit

# NIC queue and ring buffer sizes
ethtool -g eth0     # RX and TX ring buffer sizes
ethtool eth0        # link speed, duplex, auto-negotiation
```

### /proc/net/dev — raw counters

```bash
cat /proc/net/dev

# Format: interface | RX(bytes packets errs drop fifo frame compressed multicast) | TX(...)
# Script to compute per-second rate:
awk 'NR==1{old=$0; next} /eth0/{print $2-prev; prev=$2}' \
  <(cat /proc/net/dev; sleep 1; cat /proc/net/dev)
```

### SRE NIC troubleshooting pattern

```bash
# Step 1: Are we near the bandwidth limit?
# Bandwidth used / line rate = utilisation %
ethtool eth0 | grep Speed        # get line rate
sar -n DEV 1 5                   # rx/tx KB/s (install sysstat)

# Step 2: Are packets being dropped?
ip -s link show eth0 | grep -A2 "RX:"
# If RX dropped > 0 and increasing: kernel ring buffer problem

# Fix: increase ring buffer
ethtool -G eth0 rx 4096

# Step 3: Is it TCP retransmit (upstream congestion)?
ss -tin | grep retrans

# Step 4: Per-process breakdown
nethogs eth0

# Step 5: Check for interrupt imbalance
cat /proc/interrupts | grep eth0
# NIC interrupts should be spread across multiple CPUs
# If all on CPU0: configure IRQ affinity or enable RSS/RPS
```

---

## Putting it together: SRE troubleshooting workflow

When a service is slow or an alert fires, follow this decision tree before touching application code:

```
Is the host the bottleneck?
    uptime              → load average > nproc? → CPU saturated
    free -h             → available < 10% total? → memory pressure
    iostat -x 1 3       → %util near 100%?      → disk saturated
    sar -n DEV 1 3      → near line rate?        → NIC saturated

CPU saturated:
    top -b -n1          → which PID?
    mpstat -P ALL       → which core?
    perf top -p <PID>   → which function?

Memory pressure:
    vmstat 1 5          → si/so > 0?            → swapping
    dmesg | grep oom    → OOM fires?
    ps aux --sort=-%mem → which process?

Disk saturated:
    iotop -o            → which process?
    iostat -x           → reads or writes? await how high?
    lsof +D /path       → which files?

NIC saturated:
    iftop               → which connections?
    nethogs             → which processes?
    ss -tin             → retransmits (packet loss)?
```

### Baseline everything

You cannot know if a metric is abnormal without a baseline. Establish baselines during normal operation:

```bash
# Capture a 10-minute baseline to a file
sar -A 1 600 > /tmp/baseline-$(hostname)-$(date +%Y%m%d).txt

# Schedule regular captures (add to cron)
# 0 * * * * /usr/bin/sar -A 1 60 >> /var/log/sar/hourly.log
```

### Quick reference — key commands per subsystem

| Subsystem | Quick check | Deep dive |
|-----------|-------------|-----------|
| CPU | `top`, `uptime` | `mpstat -P ALL 1`, `perf stat` |
| RAM | `free -h` | `vmstat 1`, `smem -r` |
| Swap / OOM | `swapon --show` | `dmesg \| grep oom`, `vmstat` si/so |
| Disk I/O | `iostat -x 1` | `iotop -o`, `smartctl -a /dev/sdX` |
| NIC | `ip -s link` | `iftop`, `nethogs`, `ss -tin` |
| All at once | `dstat` | `sar -A 1 60` |

```bash
# dstat — combines all subsystems in one output
apt install dstat
dstat -cdngy 1        # cpu, disk, net, page, system — 1s interval

# sar — system activity reporter (historical + live)
sar -u 1 5            # CPU (same as mpstat)
sar -r 1 5            # memory
sar -d 1 5            # disk (like iostat)
sar -n DEV 1 5        # network
sar -B 1 5            # paging / swap
```

---

## Summary

- The memory hierarchy (L1 → L2 → L3 → RAM → disk) explains most performance problems. When data is not in a faster tier, latency multiplies.
- CPUs expose cores (physical) and threads (logical via hyperthreading). Use `lscpu`, `top`, `mpstat`, and `perf` to find which layer is the bottleneck.
- Linux uses free RAM as page cache. The **available** column in `free -h` is what matters, not **free**. OOM kills are the kernel's last resort — watch for them with `dmesg | grep oom`.
- Storage performance is measured in IOPS (random) and throughput (sequential). `iostat -x` and `iotop` identify disk bottlenecks. NVMe is ~100× faster in IOPS than spinning HDDs.
- NICs have hard bandwidth limits. Packet drops in `ip -s link` and TCP retransmits in `ss -tin` are early warning signs of saturation.
- Always establish baselines with `sar`. Metrics only have meaning in context.
