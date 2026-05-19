---
title: "Lab: next lab sre"
description: "Current lab   You already have:   Network A Network B Router between them             Next..."
published: 2026-04-17
source: "https://dev.to/jumptotech/lab-next-lab-sre-26b6"
tags: []
---

# Lab: next lab sre






## Current lab

You already have:

* Network A
* Network B
* Router between them 

## Next lab

We will add these ideas:

1. **Service separation**
2. **Monitoring**
3. **Controlled access**
4. **Failure testing**
5. **Basic reliability thinking**

That is closer to SRE work.

---

# Why this helps for SRE

An SRE does not only ask:

> “Can these two PCs ping?”

An SRE asks:

* Is the service reachable?
* Who should be allowed to access it?
* How do I know when it fails?
* What happens if one link goes down?
* How do I reduce blast radius?
* How do I isolate problems quickly?



# New lab goal

We will convert your current topology into this:

* **Left subnet** = Clients / Users
* **Right subnet** = Services / Servers
* **Router** = traffic path between them
* One PC on right side becomes **Application Server**
* One PC on left or right side becomes **Monitoring Node**
* Add **ACL** to control access
* Test **failure scenarios**

---

# Final design

Use your same 2-subnet lab, but rename the purpose.

## Subnet 1

```text
192.168.1.0/24
```

Role:

* Users
* Clients
* Engineers’ laptops

## Subnet 2

```text
192.168.2.0/24
```

Role:

* App server
* Monitoring target
* Internal services

## Router interfaces

```text
G0/0 → 192.168.1.1
G0/1 → 192.168.2.1
```

This matches the structure of your current lab, which already uses two routed networks. 

---

# What each part means in SRE terms

## 1. Client subnet

This represents:

* users
* internal engineers
* systems sending requests

In real life:

* office users
* jump hosts
* admin machines
* frontend callers

## 2. Service subnet

This represents:

* backend services
* internal APIs
* databases
* monitoring targets

In real life:

* app tier
* DB tier
* private service network

## 3. Router

This represents:

* controlled traffic path
* segmentation between environments

In real life, similar idea:

* VPC routing
* service boundaries
* controlled network flow

## 4. ACL

This represents:

* security policy
* network restriction
* blast-radius control

In real life:

* security groups
* network ACLs
* firewall rules

## 5. Monitoring node

This represents:

* observability
* health checks
* alert source

In real life:

* Prometheus server
* blackbox exporter
* uptime monitoring

---

# Lab roadmap

We will do it in this order:

1. Keep your current routing lab working
2. Turn PCs into roles
3. Add monitoring checks
4. Add access control
5. Simulate failure
6. Document what happened
7. Explain why this is SRE work

---

# LAB: Next step after your subnetting lab

## Step 1 — Keep the existing lab exactly as it is

From your current file, the router has:

```bash
enable
configure terminal

interface g0/0
ip address 192.168.1.1 255.255.255.0
no shutdown

interface g0/1
ip address 192.168.2.1 255.255.255.0
no shutdown
```

And the PCs use:

* 192.168.1.x on left
* 192.168.2.x on right
* correct gateways 

Do not change that yet.

---

## Step 2 — Assign roles to devices

Use the devices you already have and rename them.

### Left side

* PC0 = Client-1
* PC1 = Client-2
* PC2 = Monitoring-Node

### Right side

* PC3 = App-Server
* PC4 = DB-Server
* PC5 = Backup-Server

This is still Packet Tracer, but now you are thinking like operations.

---

## Step 3 — Verify baseline connectivity

From Client-1, test:

```bash
ping 192.168.1.11
ping 192.168.2.10
ping 192.168.2.11
ping 192.168.2.12
```

### What this teaches

* same subnet traffic uses switch
* different subnet traffic uses router
* baseline must be healthy before security or monitoring changes

### SRE meaning

Before making changes, first confirm:

* what is working
* what is reachable
* what “healthy” looks like

That is exactly how incident response starts.

---

## Step 4 — Make one machine the “monitoring node”

Use PC2 as a monitoring machine.

From PC2, ping all service IPs:

```bash
ping 192.168.2.10
ping 192.168.2.11
ping 192.168.2.12
```

### What this represents

This is basic service health checking.

### What an SRE learns here

* Monitoring is just repeated checking
* If a server stops answering, that is a signal
* You need one trusted point that checks services regularly

### In real life

This becomes:

* blackbox monitoring
* ICMP checks
* TCP checks
* HTTP health endpoints

---

## Step 5 — Add controlled access with ACL

Now we simulate a real policy:

> Clients can access App-Server, but should not access DB-Server directly.

This is very important for SRE and production design.

### Example rule

Allow:

* 192.168.1.0/24 → App-Server (192.168.2.10)

Deny:

* 192.168.1.0/24 → DB-Server (192.168.2.11)

### Router config

On the router:

```bash
enable
configure terminal

access-list 101 permit icmp 192.168.1.0 0.0.0.255 host 192.168.2.10
access-list 101 deny icmp 192.168.1.0 0.0.0.255 host 192.168.2.11
access-list 101 permit ip any any

interface g0/0
ip access-group 101 in
```

### What this means

* clients may ping app server
* clients may not ping DB server directly
* everything else is allowed after that

### Why this matters for SRE

An SRE thinks:

* not every machine should reach every machine
* databases should be protected
* app tier and data tier should be separated

---

## Step 6 — Test the policy

From Client-1:

```bash
ping 192.168.2.10
ping 192.168.2.11
```

### Expected

* ping to 192.168.2.10 should work
* ping to 192.168.2.11 should fail

### What this teaches

Security is part of reliability.

Why? Because secure boundaries reduce:

* accidental damage
* attack spread
* wrong connections
* noisy failures

---

## Step 7 — Keep monitoring node more privileged

You may decide the monitoring node should still check both servers.

That teaches an important SRE concept:

> Monitoring systems often need broader visibility than ordinary clients.

To simulate that, put the monitoring node in the allowed list.

Example, if PC2 is 192.168.1.12:

```bash
enable
configure terminal
no access-list 101

access-list 101 permit icmp host 192.168.1.12 host 192.168.2.10
access-list 101 permit icmp host 192.168.1.12 host 192.168.2.11
access-list 101 permit icmp 192.168.1.0 0.0.0.255 host 192.168.2.10
access-list 101 deny icmp 192.168.1.0 0.0.0.255 host 192.168.2.11
access-list 101 permit ip any any

interface g0/0
ip access-group 101 in
```


* production traffic rules and monitoring rules are not always identical
* observability often needs special access

---

## Step 8 — Simulate a failure

Now we test the system when something breaks.

### Option A: bring down service-side router interface

On router:

```bash
enable
configure terminal
interface g0/1
shutdown
```

### What happens

* all right-side services become unreachable
* monitoring checks fail
* client traffic fails

### SRE lesson

This simulates:

* service subnet outage
* bad change
* interface failure
* network isolation incident

### What to observe

From Monitoring-Node:

```bash
ping 192.168.2.10
ping 192.168.2.11
ping 192.168.2.12
```

All should fail.

Now restore:

```bash
enable
configure terminal
interface g0/1
no shutdown
```

This is a simple fail-and-recover drill.

---

## Step 9 — Simulate partial failure

Instead of taking down the whole subnet, disconnect one service cable or power off one server PC.

### What happens

* one target fails
* others stay healthy

### SRE lesson

Learn to distinguish:

* total outage
* partial outage
* isolated host issue

This is critical in troubleshooting.

---

## Step 10 — Document expected behavior



| Test                          | Expected result | Why                        |
| ----------------------------- | --------------- | -------------------------- |
| Client-1 to Client-2          | Success         | Same subnet                |
| Client-1 to App-Server        | Success         | Routed and allowed         |
| Client-1 to DB-Server         | Fail            | Blocked by ACL             |
| Monitoring-Node to App-Server | Success         | Monitoring allowed         |
| Monitoring-Node to DB-Server  | Success         | Monitoring allowed         |
| After G0/1 shutdown           | Fail            | Service subnet unavailable |

This is how SREs think: define normal behavior before troubleshooting.

---

# What this lab teaches about SRE work

## 1. Segmentation

Not every host should talk to every host.

## 2. Access control

Protect sensitive systems.

## 3. Monitoring

Continuously check service availability.

## 4. Failure testing

Break things on purpose and observe behavior.

## 5. Troubleshooting

Determine whether failure is:

* network-wide
* subnet-wide
* service-specific
* policy-related

## 6. Reliability mindset

A working network is not enough.
You need:

* visibility
* control
* predictable behavior



## Stage 1 — Basic routing

“Two networks communicate through a router.”

## Stage 2 — Service roles

“One subnet acts like users, the other acts like services.”

## Stage 3 — Monitoring

“One node continuously checks whether services are reachable.”

## Stage 4 — ACL

“Not everybody is allowed to talk to everything.”

## Stage 5 — Failure drill

“We intentionally break connectivity and confirm how the system behaves.”

## Stage 6 — Recovery

“We restore service and confirm health again.”

That sequence is much closer to real SRE practice.


# Very simple SRE interview explanation

You can say:

> I would start with a routed two-subnet lab, then extend it by assigning service roles, adding monitoring checks, implementing ACL-based access control, and simulating failures. This helps demonstrate core SRE thinking: segmentation, observability, controlled access, outage detection, and recovery validation.


