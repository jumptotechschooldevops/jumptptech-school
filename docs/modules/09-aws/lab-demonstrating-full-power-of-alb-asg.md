---
title: "LAB: Demonstrating FULL POWER of ALB + ASG"
description: "🟢 PART 1 — Set Correct Production Settings (Very Important)   Go to:           EC2 → Auto..."
published: 2026-02-11
source: "https://dev.to/jumptotech/lab-demonstrating-full-power-of-alb-asg-158j"
tags: []
---

# LAB: Demonstrating FULL POWER of ALB + ASG





# 🟢 PART 1 — Set Correct Production Settings (Very Important)

Go to:

### EC2 → Auto Scaling Groups → asg-web → Edit

Set:

* **Min capacity = 2**
* **Desired capacity = 2**
* **Max capacity = 4**

Why?

DevOps NEVER runs production with 1 instance.
If 1 dies → downtime.
Minimum 2 = high availability.

Click Update.

Now confirm:

EC2 → Instances → You see 2 running instances in different AZs.

---

# 🟢 PART 2 — Enable Proper Health Checks (Professional Setup)

In ASG edit page:

Turn ON:

✅ Elastic Load Balancing health checks

Set:

Health check grace period: **60 seconds**

Why?

ASG must trust ALB health checks.
If ALB says instance unhealthy → ASG replaces it.

Click Update.

---

# 🟢 PART 3 — Set Instance Replacement Behavior

In ASG:

Go to:

Instance maintenance policy

Choose:

✅ **Prioritize availability (Launch before terminating)**

Why this is VERY important:

DevOps production rule:

> Always launch new instance first, then terminate old one.

This prevents 503.

Update.

---

# 🟢 PART 4 — Demonstration 1: Load Balancing (Traffic Distribution)

Open browser:

[http://alb-web-1868236258.us-east-2.elb.amazonaws.com](http://alb-web-1868236258.us-east-2.elb.amazonaws.com)

Refresh multiple times.

You should see:

Instance ID changing.

Explain to students:

ALB distributes traffic across multiple servers.
This is horizontal scaling.

Production meaning:
If 1,000 users connect → traffic is shared.

---

# 🟢 PART 5 — Demonstration 2: Self-Healing (Terminate Instance)

Now the powerful part.

Go to:

EC2 → Instances

Terminate ONE instance manually.

Now explain what is happening behind the scenes:

1. ALB detects instance unhealthy
2. Stops sending traffic
3. ASG sees capacity < desired
4. ASG launches new instance
5. New instance becomes healthy
6. Traffic resumes

Watch:

Target Group → Health

You will see:

* 1 draining/unhealthy
* 1 healthy
* New one launching

Refresh browser continuously.

It should NOT show 503 now (because you set min=2 and launch-before-terminate).

Explain:

This is high availability.

---

# 🟢 PART 6 — Demonstration 3: Manual Scaling

Go to:

ASG → Edit

Change:

Desired = 3

Update.

Watch:

New instance launches.

Refresh browser.

You will now see 3 instance IDs rotating.

Explain:

This is horizontal scaling.
More users → more servers.

---

# 🟢 PART 7 — Demonstration 4: Automatic Scaling (CPU Based)

Now we demonstrate real DevOps job.

Go to:

ASG → Automatic Scaling → Add Policy

Choose:

Target Tracking

Metric:

Average CPU Utilization

Set:

Target value: 40%

Save.

Now generate CPU load:

SSH into one instance:

```
sudo apt install stress -y
stress --cpu 2 --timeout 300
```

Watch:

CloudWatch → ASG → Metrics

When CPU > 40%:

ASG launches new instance automatically.

Explain:

In real production:
Scaling happens automatically.
DevOps configures policies.
We do not manually scale.

---

# 🟢 PART 8 — Demonstration 5: Show Why 503 Happens (Educational)

Temporarily set:

Min capacity = 1
Desired = 1

Update.

Terminate the instance.

Refresh browser.

You will see:

503

Explain:

ALB had zero healthy targets.

Lesson:

High availability requires minimum 2 instances.

Reset back to:

Min = 2
Desired = 2

---

# 🟢 PART 9 — Demonstrate Zero-Downtime Deployment (Professional Level)

Go to:

ASG → Instance Refresh → Start refresh

This simulates:

New AMI deployment.

Explain like 6-year DevOps:

We do immutable infrastructure.
We do not update servers manually.
We bake new AMI.
We roll instances gradually.

Browser should continue working.

---



"In production, ALB handles traffic distribution and health checks.
ASG guarantees desired capacity and replaces failed instances automatically.
We configure scaling policies based on CPU, memory, or custom metrics.
We use rolling refresh to deploy new AMIs without downtime."

---

# 🔵 What Each Component Does (Professional Summary)

| Component       | Real DevOps Responsibility     |
| --------------- | ------------------------------ |
| ALB             | Traffic routing + health check |
| Target Group    | Monitors instance health       |
| ASG             | Maintains capacity             |
| Launch Template | Defines infrastructure         |
| CloudWatch      | Monitors metrics               |
| Scaling Policy  | Controls automatic scaling     |

---

# 🏢 Real Company Structure

Usually:

Platform Team:

* Creates ALB
* Creates ASG
* Writes Terraform

DevOps:

* Maintains scaling policies
* Handles deployment automation
* Monitors health

Developers:

* Deploy application

SRE:

* Monitor uptime & reliability

---


You have done:

✅ Load balancing
✅ Multi-AZ redundancy
✅ Self-healing
✅ Manual scaling
✅ Automatic scaling
✅ Zero-downtime deployment
✅ Production architecture

This is already mid-level DevOps knowledge.


