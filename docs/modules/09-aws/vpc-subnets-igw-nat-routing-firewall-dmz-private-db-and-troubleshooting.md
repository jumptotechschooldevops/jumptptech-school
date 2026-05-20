---
title: "VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #1"
description: "🔥 LAB GOAL (PRODUCTION STYLE)   You will build:    Internet    ↓ Load Balancer (DMZ /..."
published: 2026-04-29
source: "https://dev.to/jumptotech/vpc-subnets-igw-nat-routing-firewall-dmz-private-db-and-troubleshooting-24og"
tags: []
---

# VPC, subnets, IGW, NAT, routing, firewall, DMZ, private DB, and troubleshooting part #1


# 🔥 LAB GOAL (PRODUCTION STYLE)

You will build:

```text
Internet
   ↓
Load Balancer (DMZ / Public)
   ↓
Web Server (Private)
   ↓
Database (Private)
```

With:

* Public subnets (DMZ)
* Private subnets (App + DB)
* NAT Gateway
* Security Groups (firewall)
* Route tables (routing)

---

# 🚀 STEP 0 — WHAT YOU MUST HAVE

Already created:

✔ VPC
✔ 2 Public subnets
✔ 2 Private subnets
✔ Internet Gateway
✔ NAT Gateway

---

# 🚀 STEP 1 — FIX ROUTING (VERY IMPORTANT)

## Public Route Table

Go to VPC → Route Tables → Public RT

Make sure:

```text
0.0.0.0/0 → Internet Gateway
```

Associate:

* Public Subnet 1
* Public Subnet 2

---

## Private Route Table

Make sure:

```text
0.0.0.0/0 → NAT Gateway
```

Associate:

* Private Subnet 1
* Private Subnet 2

---

### ✔ Result:

* Public = internet access
* Private = outbound only

---

# 🚀 STEP 2 — CREATE SECURITY GROUPS (FIREWALL DESIGN)

## 1. Load Balancer SG (`alb-sg`)

Allow:

```text
HTTP 80 → 0.0.0.0/0
```

---

## 2. Web Server SG (`web-sg`)

Allow:

```text
HTTP 80 → alb-sg
SSH 22 → your IP
```

---

## 3. Database SG (`db-sg`)

Allow:

```text
MySQL 3306 → web-sg
```

---

### ✔ Result:

* Internet → only ALB
* ALB → Web
* Web → DB
* Users CANNOT access DB

👉 This is real firewall architecture

---

# 🚀 STEP 3 — CREATE LOAD BALANCER (DMZ)

Use:
Application Load Balancer

### Where:

EC2 → Load Balancers → Create

---

### Config:

* Type: Application LB

* Scheme: Internet-facing

* Subnets:

  * Public Subnet 1
  * Public Subnet 2

* Security Group:

  * `alb-sg`

---

### ✔ Result:

👉 Entry point for users

---

# 🚀 STEP 4 — CREATE WEB SERVERS (PRIVATE)

Launch 2 EC2:

* Subnet:

  * private-subnet-1
  * private-subnet-2

* Security Group:

  * `web-sg`

* NO public IP

---

## Install nginx:

```bash
sudo apt update
sudo apt install nginx -y
```

---

## Customize page:

```bash
echo "Hello from Web Server 1" | sudo tee /var/www/html/index.html
```

---

### ✔ Result:

👉 Private app servers running

---

# 🚀 STEP 5 — CONNECT ALB → WEB

### Create Target Group:

* Type: Instance
* Port: 80

Add both EC2 instances

---

Attach to Load Balancer

---

### ✔ Result:

👉 ALB sends traffic to web servers

---

# 🚀 STEP 6 — TEST

Open:

```text
http://<ALB-DNS>
```

---

### ✔ Result:

👉 You see your web page

Refresh:
👉 It switches between servers

---

# 🚀 STEP 7 — CREATE DATABASE (SIMULATION)

You can use EC2 or:
Amazon RDS

---

### For simple lab (EC2 DB):

Launch EC2:

* Subnet: private-subnet-1
* SG: `db-sg`

---

### ✔ Result:

👉 Private DB server

---

# 🚀 STEP 8 — TEST NETWORK SECURITY

## Try:

From your laptop:

* Access DB → ❌ FAIL

From web EC2:

* Connect DB → ✔ WORK

---

👉 This proves firewall working

---

# 🚀 STEP 9 — TEST NAT (VERY IMPORTANT)

SSH into web EC2:

```bash
ping google.com
```

---

### ✔ Result:

👉 Works → NAT is correct

---

# 🚀 STEP 10 — BREAK & DEBUG (SRE LEVEL)

Now simulate failures:

---

## Scenario 1 — Remove NAT route

👉 Private EC2 cannot reach internet

Fix:
👉 Add NAT route back

---

## Scenario 2 — Remove SG rule (web → db)

👉 App cannot reach DB

Fix:
👉 Add rule back

---

## Scenario 3 — Stop one EC2

👉 App still works via ALB

---

👉 This is **real SRE behavior**

---

# 🔥 WHAT YOU JUST LEARNED

You implemented:

✔ VPC design
✔ Subnet segmentation (DMZ / Private)
✔ Routing (IGW + NAT)
✔ Firewall (SG)
✔ Load balancing
✔ Secure DB access
✔ Failure testing

---

# 💬 INTERVIEW ANSWER

> I built a multi-tier architecture in AWS with public and private subnets, configured routing using Internet Gateway and NAT Gateway, secured communication using security groups, deployed web servers behind an Application Load Balancer, and validated failover and connectivity through testing scenarios.



