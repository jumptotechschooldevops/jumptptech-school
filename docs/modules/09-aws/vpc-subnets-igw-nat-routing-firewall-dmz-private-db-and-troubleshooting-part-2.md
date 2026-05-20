---
title: "VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #2"
description: "User (Internet)    ↓ DNS (:contentReference[oaicite:0]{index=0})    ↓ WAF (optional)    ↓ Load..."
published: 2026-04-30
source: "https://dev.to/jumptotech/vpc-subnets-igw-nat-routing-firewall-dmz-private-db-and-troubleshooting-part-2-5a7g"
tags: []
---

# VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #2





```text
User (Internet)
   ↓
DNS (:contentReference[oaicite:0]{index=0})
   ↓
WAF (optional)
   ↓
Load Balancer (Public / DMZ)
   ↓
Private Web Tier (EC2 / App)
   ↓
Private DB Tier
   ↓
Private AWS Services (via VPC Endpoint)

Cross-VPC / Hybrid:
   ↔ VPC Peering / :contentReference[oaicite:1]{index=1}
   ↔ :contentReference[oaicite:2]{index=2}
   ↔ VPN / Direct Connect
```

---

# 🚀 STEP 11 — ADD DNS (Route 53)

## Why SRE adds this

Users should never access ALB DNS directly.
They use domain like:

```text
app.company.com
```

---

## Go to:

```text
Route 53 → Hosted Zones → Create Hosted Zone
```

If you already have domain → use it

---

## Create record

```text
Record name: app
Type: A
Alias: YES
Target: ALB
```

---

## Expected result

```bash
nslookup app.yourdomain.com
```

Output:

```text
Name: app.yourdomain.com
Address: ALB IP
```

---

## Why this matters

Now flow is:

```text
User → DNS → ALB → Web
```

---

## SRE troubleshooting

If site down:

```bash
dig app.yourdomain.com
```

Check:

* does it resolve?
* correct ALB?
* TTL delay?

---

# 🚀 STEP 12 — ADD WAF (SECURITY LAYER)

## Why

Security Groups = network firewall
WAF = application firewall (Layer 7)

---

## Go to:

```text
WAF → Create Web ACL
```

Attach to:

```text
ALB
```

---

## Add rules

* AWS Managed Rules
* Rate limiting (1000 req/min)

---

## Result

Now:

```text
Bad traffic blocked BEFORE app
```

---

## SRE troubleshooting

If users blocked:

* check WAF logs
* check rule priority
* false positives

---

# 🚀 STEP 13 — ADD CLOUDWATCH + ALB LOGS

## Why

SRE must **see traffic**

---

## Enable ALB logs

```text
EC2 → Load Balancer → Attributes → Enable Access Logs
```

Store in S3

---

## Expected log

```text
client_ip request_path target_status_code latency
```

---

## Why important

You can debug:

* 500 errors
* slow requests
* bad clients

---

# 🚀 STEP 14 — ADD VPC FLOW LOGS

## Already partially covered — now use it

Go to:

```text
VPC → Flow Logs → Create
```

---

## Example output

```text
ACCEPT TCP 10.0.3.10 → 10.0.5.20 3306
REJECT TCP 1.2.3.4 → 10.0.5.20 3306
```

---

## Why this matters

You can prove:

* traffic allowed
* traffic blocked

---

# 🚀 STEP 15 — ADD VPC ENDPOINT (PRIVATE AWS ACCESS)

## Why

Private EC2 should NOT go through internet for AWS services

---

## Go to:

```text
VPC → Endpoints → Create
```

Service:

```text
S3
Type: Gateway
```

Attach:

```text
Private route table
```

---

## Result

```text
Private EC2 → S3 (no NAT, no internet)
```

---

## SRE importance

* secure
* cheaper
* required in enterprise

---

# 🚀 STEP 16 — ADD VPC PEERING (MULTI-VPC)

## Scenario

You have:

```text
VPC-A → your app
VPC-B → shared services
```

---

## Create second VPC

CIDR:

```text
10.1.0.0/16
```

---

## Go to:

```text
VPC → Peering → Create
```

---

## Update routes BOTH SIDES

```text
10.1.0.0/16 → peering
10.0.0.0/16 → peering
```

---

## Result

```text
Private communication between VPCs
```

---

## SRE troubleshooting

* routes missing?
* SG blocking?
* CIDR overlap?

---

# 🚀 STEP 17 — ADD TRANSIT GATEWAY (ENTERPRISE LEVEL)

Instead of many peerings:

---

## Go to:

```text
VPC → Transit Gateway → Create
```

---

## Attach VPCs

```text
Attach VPC-A
Attach VPC-B
```

---

## Result

```text
Central network hub
```

---

## Why SRE uses this

* scalable
* cleaner architecture
* used in large companies

---

# 🚀 STEP 18 — ADD PRIVATELINK (ADVANCED)

## Scenario

Expose ONLY service, not full network

---

## Flow

```text
Consumer VPC → Endpoint → NLB → Service VPC
```

---

## Why

* secure
* no full VPC access
* SaaS architecture

---

## Difference

```text
Peering → full network
PrivateLink → one service
```

---

# 🚀 STEP 19 — ADD VPN (HYBRID CLOUD)

## Scenario

Company has on-prem server

---

## Go to:

```text
VPC → VPN → Create Site-to-Site VPN
```

---

## Result

```text
On-prem → encrypted → AWS
```

---

## SRE checks

* tunnel UP?
* routes correct?
* firewall open?

---

# 🚀 STEP 20 — ADD DIRECT CONNECT (THEORY)

## What

Private fiber connection

---

## When used

* banks
* large companies

---

## Difference

```text
VPN → internet
Direct Connect → private line
```

---

# 🚀 STEP 21 — FINAL SRE TESTING (REAL SCENARIOS)

---

## Scenario 1 — ALB down

Check:

```text
DNS → OK?
ALB → Active?
Target → Healthy?
```

---

## Scenario 2 — App slow

Check:

```text
ALB logs
Latency
DB connection
```

---

## Scenario 3 — DB not reachable

Check:

```text
SG rules
Port 3306
Private routing
```

---

## Scenario 4 — Private EC2 no internet

Check:

```text
NAT
Route table
IGW
```

---

## Scenario 5 — DNS issue

```bash
dig app.domain.com
```

---

# 🔥 WHAT YOU HAVE NOW (REAL SRE LEVEL)

You built:

✔ Multi-tier architecture
✔ DMZ design
✔ Private networking
✔ Load balancing
✔ Firewall (SG + WAF)
✔ DNS routing
✔ Observability (logs + flow logs)
✔ Private AWS access (VPC endpoint)
✔ Multi-VPC (peering + transit)
✔ Service exposure (PrivateLink)
✔ Hybrid cloud (VPN)

---

# 💬 FINAL INTERVIEW ANSWER

You say:

I built a production-grade AWS architecture with DNS using Route 53, public access through an Application Load Balancer in DMZ subnets, private application and database tiers, secure communication using security groups, outbound internet via NAT Gateway, private AWS access via VPC endpoints, and network observability using VPC Flow Logs and ALB logs. I also implemented multi-VPC connectivity using VPC peering and Transit Gateway, and secure service exposure using PrivateLink, along with hybrid connectivity using VPN.

-
