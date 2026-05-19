---
title: "THE MOST IMPORTANT CONCEPT: MEASURING RELIABILITY: SLO, SLA, SLI"
description: "Site Reliability Engineering is not just monitoring or fixing servers.  It is:   Applying software..."
published: 2026-05-07
source: "https://dev.to/jumptotech/the-most-important-concept-measuring-reliability-slo-sla-sli-n0b"
tags: []
---

# THE MOST IMPORTANT CONCEPT: MEASURING RELIABILITY: SLO, SLA, SLI





Site Reliability Engineering is not just monitoring or fixing servers.

It is:

> **Applying software engineering principles to operations to make systems reliable at scale.**

That means:

* You don’t manually fix things → you **automate**
* You don’t guess → you **measure**
* You don’t react → you **design for failure**

---

## Core mindset

A normal engineer asks:

> “Is the system working?”

An SRE asks:

> “How well is it working, how often does it fail, and how much failure is acceptable?”

---

 
Before SRE existed, companies said:

```text
System should be reliable
```

That means nothing.

SRE changed that to:

```text
Reliability must be measurable
```

This is where **SLI, SLO, SLA** come in.

---

# 🧠 PART 3 — SLI (SERVICE LEVEL INDICATOR)

## What it really is

An SLI is:

> **A real measurement of user experience**

Not system metrics like CPU — but **user-facing metrics**.

---

## Examples

Instead of:

```text
CPU = 70%
```

We measure:

```text
Request success rate
Request latency
Error rate
```

---

## Real example

Imagine your API:

* 1000 requests
* 990 succeed
* 10 fail

Your SLI:

```text
Success rate = 99%
```

---

## Important rule

```text
SLI must reflect USER experience
```

If user is unhappy → your SLI is wrong

---

# 🧠 PART 4 — SLO (SERVICE LEVEL OBJECTIVE)

## What it really is

SLO is:

> **A target you set for your system performance**

---

## Example

You define:

```text
99.9% of requests must succeed
```

That is your SLO.

---

## Why SLO exists

Because perfection is impossible.

So instead of:

```text
System must never fail ❌
```

We say:

```text
System can fail within limits ✅
```

---

## Another example

Latency SLO:

```text
95% of requests < 200ms
```

---

## Key idea

```text
SLO defines acceptable reliability
```

---

# 🧠 PART 5 — SLA (SERVICE LEVEL AGREEMENT)

## What it really is

SLA is:

> **Business contract based on SLO**

---

## Example

```text
If uptime < 99.9% → customer gets refund
```

---

## Important difference

| Concept | Purpose           |
| ------- | ----------------- |
| SLI     | measurement       |
| SLO     | internal goal     |
| SLA     | external contract |

---

# 🧠 PART 6 — ERROR BUDGET (THIS IS SENIOR LEVEL)

This is the most important concept in SRE.

---

## What it is

If your SLO is:

```text
99.9% uptime
```

Then:

```text
0.1% failure is allowed
```

That is your **error budget**

---

## In real time

```text
~43 minutes downtime per month
```

---

## Why it matters

It creates balance:

```text
Developers → want speed
SRE → want stability
```

Error budget decides:

```text
If budget remains → deploy
If exhausted → stop releases
```

---

## Real rule

```text
No error budget = no deployments
```

---

# 🧠 PART 7 — HOW WE MEASURE AVAILABILITY

## Formula

Availability =

```text
(Total time - downtime) / total time
```

---

## Example

30 days = 720 hours
Downtime = 2 hours

```text
(720 - 2) / 720 = 99.72%
```

---

## SRE levels

| Level   | Meaning    |
| ------- | ---------- |
| 99%     | basic      |
| 99.9%   | production |
| 99.99%  | critical   |
| 99.999% | extreme    |

---

# 🧠 PART 8 — LATENCY (WHY AVERAGE IS WRONG)

Average lies.

---

## Example

```text
99 requests = 100ms
1 request = 10 seconds
```

Average looks fine — but system is broken.

---

## Solution

Use percentiles:

* P50 → normal
* P95 → slow users
* P99 → worst users

---

## Real SLO

```text
95% of requests < 200ms
```

---

# 🧠 PART 9 — MONITORING (WHAT SRE ACTUALLY WATCHES)

## Golden Signals (Google SRE)

1. Latency
2. Traffic
3. Errors
4. Saturation

---

## What this means

You monitor:

```text
How fast?
How many?
How broken?
How loaded?
```

---

## Tools

* Prometheus
* Grafana
* CloudWatch
* ELK

---

# 🧠 PART 10 — ALERTING (VERY IMPORTANT)

Bad alert:

```text
CPU > 80%
```

Good alert:

```text
Error rate > 5% for 5 minutes
```

---

## Rule

```text
Alert only when users are impacted
```

---

# 🧠 PART 11 — INCIDENT MANAGEMENT

Incident = system failure affecting users

---

## SRE process

1. Detect
2. Respond
3. Fix
4. Learn

---

## Postmortem

Must be:

```text
Blameless
```

---

## You document

* timeline
* root cause
* impact
* fix
* prevention

---

# 🧠 PART 12 — RELIABILITY ENGINEERING

You design systems that:

```text
Expect failure
```

---

## Example

Instead of 1 server:

```text
ALB → multiple EC2 → DB replicas
```

---

## Goal

```text
No single point of failure
```

---

# 🧠 PART 13 — SCALING

## Vertical

```text
bigger machine
```

## Horizontal

```text
more machines
```

---

## SRE prefers

```text
Horizontal scaling
```

---

# 🧠 PART 14 — NETWORKING (WHAT YOU DID)

You must understand:

* VPC
* routing
* NAT vs IGW
* TGW
* PrivateLink

---

# 🧠 PART 15 — AUTOMATION

Rule:

```text
If you repeat it → automate it
```

---

## Tools

* Terraform
* Bash
* Python

---

# 🧠 PART 16 — CI/CD

You must know:

* pipelines
* deployments
* rollback

---

## Strategies

* rolling
* blue/green
* canary

---

# 🧠 FINAL UNDERSTANDING

SRE is:

```text
Measure → Define → Monitor → Improve → Automate
```

---

# 💬 PERFECT INTERVIEW ANSWER

> SRE focuses on maintaining system reliability by defining measurable objectives like SLOs, monitoring system health, managing incidents, and automating infrastructure while balancing system stability with development velocity.


