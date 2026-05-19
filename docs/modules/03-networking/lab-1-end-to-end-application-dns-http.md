---
title: "LAB 1 — End-to-End Application + DNS + HTTP"
description: "Goal   Simulate a real application flow           What to build    Use your existing..."
published: 2026-04-22
source: "https://dev.to/jumptotech/lab-1-end-to-end-application-dns-http-1fen"
tags: []
---

# LAB 1 — End-to-End Application + DNS + HTTP




## Goal

Simulate a **real application flow**

## What to build

* Use your existing server
* Turn ON:

  * **HTTP service**
  * **DNS service**

## Steps

1. On Server → Services → HTTP → ON
2. Create DNS record:

   ```plaintext
   app.local → 192.168.50.10
   ```
3. On PC → Desktop → Web Browser:

   ```plaintext
   http://app.local
   ```

## What you demonstrate (SRE mindset)

* DNS resolution
* Application reachability
* End-to-end flow:

  ```plaintext
  DNS → Routing → HTTP
  ```

---

# 🔥 LAB 2 — Failure Simulation (MOST IMPORTANT FOR SRE)

## Goal

Break things and troubleshoot

## Scenarios to test

### ❌ Scenario 1 — DNS failure

* Turn OFF DNS service

Test:

```console
ping app.local  → FAIL
ping 192.168.50.10 → WORKS
```

👉 You prove:

* Network works
* DNS is the problem

---

### ❌ Scenario 2 — DHCP failure

* Turn OFF DHCP

Test:

* PC gets no IP

👉 You prove:

* Infra dependency (DHCP is critical)

---

### ❌ Scenario 3 — VLAN mismatch

* Change PC port to wrong VLAN

👉 Result:

* No connectivity

---

### ❌ Scenario 4 — Remove `ip helper-address`

👉 Result:

* DHCP fails across VLANs

---

## What you demonstrate

👉 This is REAL SRE work:

* isolate problem
* layer-by-layer debugging

---

# 🔥 LAB 3 — Monitoring & Logs (Simulated)

## Goal

Think like observability engineer

## What to simulate

You don’t have real Prometheus in Packet Tracer, but you can simulate:

* Continuous ping:

  ```batchfile
  ping 192.168.50.10 -t
  ```

* Then break network:

  * shutdown interface
  * remove trunk

👉 Observe:

* packet loss
* downtime

---

## What you explain (interview gold)

* health checks
* uptime monitoring
* alerting concept

---

# 🔥 LAB 4 — Redundancy Concept (Important for SRE)

## Goal

High availability thinking

## Simulation

* Add second server (192.168.50.11)
* Create DNS:

  ```plaintext
  app.local → 192.168.50.10
  app.local → 192.168.50.11
  ```

👉 Simulate:

* one server down
* traffic still resolves

---

## What you explain

* load balancing (basic)
* fault tolerance
* HA design

---

# 🔥 LAB 5 — Security (Basic SRE)

## Goal

Control traffic

## Example

Block VLAN 10 from accessing server

On router:

```bash
access-list 100 deny ip 192.168.10.0 0.0.0.255 any
access-list 100 permit ip any any

interface g0/0.10
ip access-group 100 in
```

---

## What you demonstrate

* network security
* access control
* isolation

---

# 🔥 LAB 6 — Real SRE Troubleshooting Scenario

## Scenario

“User says: App is down”

## Your process:

### Step 1

```bash
ping app.local
```

### Step 2

```bash
ping 192.168.50.10
```

### Step 3

Check:

* DHCP?
* DNS?
* Routing?
* VLAN?
* Server service?

---

## What you show

👉 Structured debugging




