# Module 00 · Fundamentals

Before diving into Git, Linux, containers, and cloud infrastructure, you need a solid mental model of the machine itself. This module covers the hardware layer that every other tool runs on top of — the CPU, RAM, storage, and network interface card — and shows you how to measure and troubleshoot each one from the Linux command line.

## What you will learn

- How CPUs are structured (cores, threads, cache levels) and how to profile them
- How Linux manages RAM, the page cache, swap, and the OOM killer
- The real performance difference between HDD, SSD, and NVMe storage
- How to measure NIC bandwidth and detect packet drops
- The memory hierarchy and why it dictates application performance
- A systematic SRE troubleshooting workflow for host-level bottlenecks

## Lectures

| # | Title | Topics |
|---|-------|--------|
| L1 | [Computer Hardware for SRE Engineers](lecture-01-hardware.md) | CPU, RAM, Storage, NIC, Memory hierarchy, `top`, `mpstat`, `perf`, `vmstat`, `iostat`, `iotop`, `ip link` |
