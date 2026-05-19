---
title: "Lab: High Availability + Scalability with ASG (EC2) in AWS"
description: "Goal     High Availability (HA): app stays up when an instance fails (and/or when an AZ has..."
published: 2026-02-06
source: "https://dev.to/jumptotech/lab-high-availability-scalability-with-asg-ec2-in-aws-2jfc"
tags: []
---

# Lab: High Availability + Scalability with ASG (EC2) in AWS



# 
## Goal 
* **High Availability (HA):** app stays up when an instance fails (and/or when an AZ has problems)
* **Scalability:** app adds/removes capacity automatically

**Core services**

* **Launch Template** (blueprint)
* **Auto Scaling Group (ASG)** (desired-state engine + self-healing + scaling)
* (Optional but recommended for real HA) **Application Load Balancer (ALB)** + **Target Group**

---

# Phase 1 — Launch Template (Blueprint)



EC2 → **Launch templates** → **Create launch template**

### 1. Name

Example:

* `ha-scalability-lt`

**DevOps attention**

* Name clearly (env/app/team)
* Avoid spaces/special chars

**Interview**

* “What is a launch template and why do we use it with ASG?”
* Answer: “It’s the versioned blueprint ASG uses to launch identical instances (AMI, type, SG, user data, IAM profile).”

---

### 2. AMI (OS image)

You selected **Ubuntu 24.04** .

**DevOps attention**

* Pick correct architecture (x86_64 vs arm64)
* Keep AMI updated / patched
* Understand cost implications of Marketplace AMIs

**Interview**

* “How do you roll out a new AMI?”
* Expected: “Create new launch template version and do an instance refresh / rolling update.”

---

### 3. Instance type

You used:

* `t2.micro`

**DevOps attention**

* Free tier vs real workloads
* Burstable CPU behavior (credits)
* In real systems, define multiple instance types / mixed instances policy

**Interview**

* “Why would t2/t3 be risky for production?”
* Answer: “CPU credits can throttle performance under sustained load.”

---

### 4. Key pair (login)



**DevOps attention**

* Prefer **SSM Session Manager** in production (no SSH open)
* If SSH is used, restrict to your IP and rotate keys

**Interview**

* “How do you avoid opening SSH to the internet?”
* Answer: “Use IAM + SSM, private subnets, bastion, VPN, etc.”

---

### 5. Network settings (IMPORTANT)



* **Subnet: Don’t include in launch template**
* **Availability Zone: don’t choose** (not applicable for ASG)

**DevOps attention**

* This is a common mistake: setting subnet/AZ in the template breaks HA
* ASG decides placement based on the AZs/subnets you pick in ASG

**Interview**

* “Where do you choose AZs for Auto Scaling?”
* Answer: “In the ASG, by selecting subnets across multiple AZs.”

---

### 6. Security Group (Firewall)



For the web demo, SG should include:

* Inbound HTTP 80 from `0.0.0.0/0` (public demo)
* Inbound SSH 22 from *your IP only* (optional)
* Outbound: allow all (default)

**DevOps attention**

* Never open SSH to 0.0.0.0/0 in real life
* Use least privilege, document ports
* Security groups are stateful

**Interview**

* “How do you secure an internet-facing app?”
* Answer: “ALB in public subnet, instances in private subnet, SG rules allow ALB→instances only, WAF, TLS, etc.”

---

### 7. User Data (MOST IMPORTANT for demo)

This is the script that auto-installs the web server.

For Ubuntu:

```bash
#!/bin/bash
apt-get update -y
apt-get install -y apache2
echo "Hello from $(hostname)" > /var/www/html/index.html
systemctl enable apache2
systemctl start apache2
```

**DevOps attention**

* User data must be idempotent (safe if re-run)
* Logs: `/var/log/cloud-init-output.log`
* Keep it simple for labs; use config management for production

**Interview**

* “How do you debug user-data not running?”
* Answer: “Check cloud-init logs, instance system logs, ensure package repos reachable, correct shebang, correct OS commands.”

---

### 8. IAM Instance Profile 



**When needed**

* S3 access, CloudWatch agent, SSM, pulling secrets, etc.

**DevOps attention**

* Prefer IAM role over access keys
* Least privilege policies

**Interview**

* “How does EC2 access S3 without access keys?”
* Answer: “Instance profile / IAM role + policy attached.”

---

### 9. Create launch template

You clicked **Create launch template**.

**Key concept**

* Launch template does **not** create EC2.
* It’s just a saved recipe.

---

# Phase 2 — Auto Scaling Group (Desired State + HA + Self-Healing)

EC2 → **Auto Scaling Groups** → **Create Auto Scaling group**

### 1. Select launch template

You chose:

* `ha-scalability-lt`

**DevOps attention**

* Use template versions (don’t overwrite silently)
* Change template by creating a new version

**Interview**

* “How do you update ASG instances when template changes?”
* Answer: “Instance refresh / rolling update + health checks.”

---

### 2. Choose VPC

You used **Default VPC**.

**DevOps attention**

* Default VPC ok for labs
* In real work: custom VPC, public/private subnets, NAT, routing, NACLs

**Interview**

* “Why put instances in private subnets?”
* Answer: “Reduce attack surface; only ALB public.”

---

### 3. Choose Availability Zones and Subnets (CRITICAL HA STEP)

You selected **subnets in at least 2 different AZs** (example: us-east-2a and us-east-2b).

**DevOps attention**

* This is where HA really happens
* Pick 2+ AZs
* Ensure subnets are correct (public vs private depending on architecture)

**Interview**

* “What is the minimum for HA?”
* Answer: “At least two AZs with independent subnets + load balancing.”

---

### 4. AZ distribution

You selected:

* **Balanced best effort**

**DevOps attention**

* Good default
* Helps when one AZ has capacity issues

**Interview**

* “What happens if an AZ can’t launch instances?”
* Answer: “ASG tries other subnets/AZs depending on settings.”

---

### 5. Health checks

You saw:

* **EC2 health checks always enabled**
* Grace period: **300 seconds**


**DevOps attention**

* Grace period prevents early replacement while bootstrapping
* Real systems: also use **ELB health checks** after attaching ALB

**Interview**

* “EC2 vs ELB health checks—difference?”
* Answer: “EC2 checks instance health; ELB checks app endpoint readiness. ELB is closer to real user health.”

---

### 6. Instance maintenance policy

You kept:

* **No policy** (default)

**DevOps attention**

* “Launch before terminate” increases availability but can increase cost
* “Terminate and launch” can reduce availability temporarily

**Interview**

* “How do you do zero-downtime replacements?”
* Answer: “Launch before terminate + health checks + rolling update.”

---

### 7. Capacity settings (you currently have 1/1/1)

You created ASG with:

* Min = 1
* Desired = 1
* Max = 1

**Important:**

* With 1 instance you cannot demonstrate HA properly.
* For demo, change to:

  * Min = 2
  * Desired = 2
  * Max = 3 or 4

**DevOps attention**

* Desired is current target
* Min is safety floor (availability)
* Max is budget ceiling (cost control)

**Interview**

* “Explain min/desired/max.”
* Answer should be confident and practical.

---

# Phase 3 — Demonstrations 

## Demo A — Self-healing (best first demo)

1. Ensure Desired/Min are 2 (recommended)
2. EC2 → terminate one ASG instance
3. ASG automatically launches a replacement

**What to say**

* “In Auto Scaling, servers are disposable.”
* “ASG maintains desired state.”

**Interview**

* “What happens when an instance becomes unhealthy?”
* Answer: “ASG replaces it based on health checks.”

---

## Demo B — High Availability (real HA requires ALB)

Without ALB, you don’t have a single stable URL and real traffic distribution.

**Correct HA demo includes:**

* Application Load Balancer (ALB)
* Target Group
* ASG attached to target group
* Health checks

Then:

* Open ALB DNS
* Refresh → may hit different backend
* Terminate an instance → ALB still serves traffic

**Interview**

* “How do you design HA web architecture on AWS?”
* Answer: “ALB across 2+ AZs + ASG across 2+ AZs + health checks + private instances.”

---

## Demo C — Scalability (scale out/in)

1. Add scaling policy (CPU > 60%)
2. Generate CPU load (`stress`)
3. Watch new instances launch
4. Stop load → instances scale back in

**Interview**

* “How do you scale on metrics other than CPU?”
* Answer: “ALB request count, custom CloudWatch metrics, queue depth, etc.”

---

# DevOps Checklist (What to pay attention to)

## Availability

* 2+ AZs selected in ASG
* Min capacity set to maintain HA
* Health check grace period correct
* (Best practice) ALB health checks enabled

## Security

* SG: no SSH from world
* Use IAM roles not keys
* Prefer SSM over SSH
* Keep instances patched (AMI lifecycle)

## Cost

* Max capacity limits cost
* t2/t3 credits behavior
* Avoid “Unlimited” credits for labs if worried about charges
* Delete ALB/ASG after lab

## Operations

* Use Launch Template versions
* Use rolling updates (instance refresh)
* Monitor logs (cloud-init output)
* Use Activity history as audit trail

---

# Interview Questions (mapped to this lab)

1. **What is the difference between Launch Template and ASG?**
2. **Where do you choose Availability Zones?**
3. **Min vs Desired vs Max — explain with example.**
4. **How does ASG replace failed instances?**
5. **EC2 health checks vs ELB health checks.**
6. **How do you do a rolling update with a new AMI?**
7. **How do you secure instances (no SSH / IAM roles)?**
8. **How do you prevent unexpected costs?**
9. **Why not pick a subnet/AZ inside the Launch Template?**
10. **What is “desired state” and why is it important?**

---



> “Launch Template defines how to build servers, Auto Scaling Group maintains the desired number of healthy servers across multiple AZs, and a Load Balancer provides a stable endpoint and routes traffic only to healthy targets.”


