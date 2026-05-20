---
title: "VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #3"
description: "Real Outage Simulation: SRE Networking Debugging   Architecture:    User  ↓ Route 53 DNS ..."
published: 2026-04-30
source: "https://dev.to/jumptotech/vpc-subnets-igw-nat-routing-firewall-dmz-private-db-and-troubleshooting-part-3-35n7"
tags: []
---

# VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #3

# Real Outage Simulation: SRE Networking Debugging

Architecture:

```text
User
 ↓
Route 53 DNS
 ↓
ALB public subnet / DMZ
 ↓
Web EC2 private subnet
 ↓
DB private subnet
```

Your SRE troubleshooting order:

```text
1. DNS
2. WAF / ALB
3. Target Group health
4. Security Groups
5. Route Tables
6. NAT / IGW
7. EC2 / Nginx
8. DB
9. Logs / Flow Logs
```

---

# OUTAGE 1 — Website Completely Down

## Symptom

User says:

```text
app.company.com is not opening.
```

Browser shows:

```text
This site can’t be reached
```

## Step 1 — Check DNS

From your laptop:

```bash
nslookup app.company.com
```

Expected good output:

```text
Name: app.company.com
Address: ALB-DNS or ALB IPs
```

Bad output:

```text
server can't find app.company.com
```

## Root cause

Route 53 record deleted or wrong.

## Fix

Go to:

```text
Route 53 → Hosted Zone → Create Record
```

Create:

```text
Record type: A
Alias: Yes
Target: Application Load Balancer
```

## SRE explanation

DNS was not resolving to the ALB, so traffic never reached AWS infrastructure.

---

# OUTAGE 2 — ALB Returns 503

## Symptom

Browser opens, but shows:

```text
503 Service Temporarily Unavailable
```

## Meaning

ALB is reachable, but it has no healthy backend targets.

## Step 1 — Check Target Group

Go to:

```text
EC2 → Target Groups → sre-app-tg → Targets
```

Bad output:

```text
Unhealthy
```

## Step 2 — Check health reason

Possible reasons:

```text
Health checks failed
Request timed out
Target.ResponseCodeMismatch
```

## Step 3 — Check app server

Connect to private EC2 using SSM or bastion.

Run:

```bash
sudo systemctl status nginx
```

Bad output:

```text
inactive (dead)
```

## Fix

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Check:

```bash
curl localhost
```

Expected:

```text
Hello from Web Server 1
```

## SRE explanation

ALB returned 503 because the target group had no healthy instances. The web service was stopped, so the health check failed.

---

# OUTAGE 3 — ALB Target Unhealthy Because Security Group Is Wrong

## Symptom

ALB returns:

```text
503
```

Target group shows:

```text
Unhealthy
Health check timeout
```

## Check Security Group

Go to:

```text
EC2 → Security Groups → web-sg → Inbound rules
```

Correct rule should be:

```text
HTTP 80 from alb-sg
```

Bad rule example:

```text
HTTP 80 from your IP
```

## Root cause

ALB cannot reach web server because web SG does not allow traffic from ALB SG.

## Fix

Edit web-sg inbound:

```text
Type: HTTP
Port: 80
Source: alb-sg
```

Wait 1–2 minutes.

Expected:

```text
Target health: Healthy
```

## SRE explanation

The application itself was fine, but the firewall blocked ALB-to-web traffic.

---

# OUTAGE 4 — Private EC2 Cannot Install Packages

## Symptom

On private EC2:

```bash
sudo apt update
```

Bad output:

```text
Temporary failure resolving
or
Connection timed out
```

## Step 1 — Check route table

Go to:

```text
VPC → Route Tables → private-rt → Routes
```

Correct:

```text
0.0.0.0/0 → NAT Gateway
```

Bad:

```text
No default route
```

## Step 2 — Check NAT

Go to:

```text
VPC → NAT Gateways
```

Expected:

```text
State: Available
Subnet: Public subnet
Elastic IP: attached
```

## Step 3 — Check public route table

Public subnet must have:

```text
0.0.0.0/0 → Internet Gateway
```

## Fix

Add route:

```text
Private Route Table
0.0.0.0/0 → NAT Gateway
```

## SRE explanation

Private EC2 had no outbound internet because the private subnet was missing the NAT route.

---

# OUTAGE 5 — Public EC2 / ALB Not Reachable

## Symptom

Browser cannot reach ALB DNS.

## Check ALB Security Group

Go to:

```text
EC2 → Security Groups → alb-sg
```

Correct inbound:

```text
HTTP 80 from 0.0.0.0/0
```

Bad:

```text
No inbound rule
```

## Fix

Add:

```text
HTTP 80 → 0.0.0.0/0
```

## SRE explanation

The ALB was healthy, but its security group blocked public HTTP traffic.

---

# OUTAGE 6 — Web Server Cannot Connect to DB

## Symptom

Application shows:

```text
Database connection failed
```

## Step 1 — From web EC2 test DB port

```bash
nc -vz <db-private-ip> 3306
```

Bad output:

```text
connection timed out
```

Good output:

```text
succeeded
```

## Step 2 — Check DB SG

Correct inbound rule:

```text
MySQL 3306 from web-sg
```

Bad rule:

```text
MySQL 3306 from your IP
or
No MySQL rule
```

## Fix

Edit db-sg:

```text
Inbound:
MySQL/Aurora
Port: 3306
Source: web-sg
```

## SRE explanation

The database was private and secure, but the app tier was not allowed by the DB security group.

---

# OUTAGE 7 — One Web Server Down, Site Still Works

## Symptom

Stop one EC2:

```text
sre-web-1 stopped
```

User still sees website.

## Why?

ALB sends traffic only to healthy targets.

Check:

```text
Target group:
web-1 → unused/unhealthy
web-2 → healthy
```

## SRE explanation

This proves high availability. One instance failed, but ALB removed it from rotation and continued sending traffic to the healthy instance.

---

# OUTAGE 8 — Both Web Servers in Same AZ

## Symptom

Application works normally, but during AZ failure everything goes down.

## Root cause

Both web servers are in one Availability Zone.

Bad design:

```text
web-1 → us-east-1a
web-2 → us-east-1a
```

Good design:

```text
web-1 → us-east-1a
web-2 → us-east-1b
```

## Fix

Launch web servers across different private subnets in different AZs.

## SRE explanation

High availability requires spreading resources across multiple Availability Zones.

---

# OUTAGE 9 — Wrong Health Check Path

## Symptom

Website works manually:

```bash
curl http://private-ip
```

Output:

```text
Hello from Web Server
```

But ALB target is unhealthy.

## Check health check path

Go to:

```text
Target Group → Health checks
```

Bad path:

```text
/health
```

But app only serves:

```text
/
```

## Fix

Change health check path to:

```text
/
```

Or create `/health` endpoint.

## SRE explanation

The application was running, but ALB health check was using a path that did not exist.

---

# OUTAGE 10 — NACL Blocks Return Traffic

## Symptom

Security groups look correct. Route tables look correct. Still traffic times out.

## Check NACL

Go to:

```text
VPC → Network ACLs
```

Remember:

```text
NACL is stateless
Inbound and outbound both must be allowed
```

For HTTP, allow:

Inbound:

```text
80 from source
1024-65535 ephemeral ports
```

Outbound:

```text
80
1024-65535 ephemeral ports
```

## Root cause

NACL allowed inbound request but blocked return traffic.

## Fix

Allow ephemeral ports.

## SRE explanation

Security groups are stateful, but NACLs are stateless. Return traffic must be explicitly allowed.

---

# OUTAGE 11 — VPC Peering Not Working

## Symptom

EC2 in VPC A cannot reach EC2 in VPC B.

## Check 1 — Peering status

```text
VPC → Peering Connections
```

Expected:

```text
Active
```

Bad:

```text
Pending acceptance
```

## Check 2 — Route tables

VPC A route table:

```text
10.1.0.0/16 → peering connection
```

VPC B route table:

```text
10.0.0.0/16 → peering connection
```

## Check 3 — CIDR overlap

Bad:

```text
VPC A: 10.0.0.0/16
VPC B: 10.0.0.0/16
```

Peering will not work.

## SRE explanation

VPC peering requires non-overlapping CIDR ranges, active peering, routes on both sides, and firewall rules allowing traffic.

---

# OUTAGE 12 — PrivateLink Works for One Service Only

## Symptom

Consumer VPC can access one API through endpoint, but cannot reach other private EC2s in provider VPC.

## Explanation

This is expected.

PrivateLink is not full network connectivity.

```text
PrivateLink → service-level access
VPC Peering → network-level access
Transit Gateway → large network hub
```

## SRE explanation

PrivateLink exposes only a specific service through an endpoint. It does not allow full VPC-to-VPC communication.

---

# OUTAGE 13 — VPN Tunnel Down

## Symptom

On-prem users cannot reach AWS private app.

## Check

In AWS:

```text
VPC → Site-to-Site VPN Connections
```

Bad output:

```text
Tunnel 1: DOWN
Tunnel 2: DOWN
```

Check:

```text
Customer gateway public IP correct?
On-prem firewall allows IPsec?
BGP routes advertised?
AWS route table has route to on-prem CIDR?
```

## SRE explanation

VPN issues usually come from tunnel status, BGP route advertisement, firewall rules, or missing route table entries.

---

# OUTAGE 14 — DNS Points to Old ALB

## Symptom

New deployment completed, but users still hit old app.

## Check

```bash
dig app.company.com
```

Compare with current ALB DNS.

## Root cause

Route 53 record points to old ALB or DNS cache TTL has not expired.

## Fix

Update Route 53 alias record.

Lower TTL before planned migration.

## SRE explanation

The application was not broken. DNS was pointing users to the wrong load balancer.

---

# OUTAGE 15 — WAF Blocks Real Users

## Symptom

Some users get:

```text
403 Forbidden
```

## Check

Go to:

```text
AWS WAF → Web ACL → Logs / Sampled requests
```

Look for:

```text
Blocked rule
Source IP
URI path
User agent
```

## Fix

Options:

```text
Adjust managed rule
Add allowlist
Change rule priority
Tune rate limit
```

## SRE explanation

WAF protects the app, but rules can create false positives. SRE must verify blocked requests before disabling protection.

---

# Final SRE Outage Debugging Script

In interview, say:

```text
When an outage happens, I do not guess. I follow the request path. First I check DNS resolution, then ALB status, listener, security group, target group health, application service, route tables, NAT or IGW, then database connectivity. I also use ALB logs, VPC Flow Logs, CloudWatch metrics, and application logs to prove where the traffic is failing.
```

# Best Practice Summary

```text
DNS issue       → dig / nslookup
ALB issue       → listener, SG, target group
503             → no healthy targets
504             → backend timeout
Private no net  → NAT route
DB issue        → DB SG from web SG
NACL issue      → remember stateless
Peering issue   → routes both sides
VPN issue       → tunnel + BGP + routes
WAF issue       → check blocked rules
```

# Very strong interview answer

I troubleshoot production outages by following the traffic path from user to backend: DNS, WAF, load balancer, target group, security groups, route tables, NACLs, EC2 service, and database. I verify each layer with tools like dig, curl, nc, ALB health checks, CloudWatch metrics, ALB logs, and VPC Flow Logs. My goal is to quickly identify whether the problem is DNS, routing, firewall, load balancer, application, or database, then restore service and document the root cause.

