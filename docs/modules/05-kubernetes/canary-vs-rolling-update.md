---
title: "canary vs rolling update"
description: "Step 0: First rule (MOST IMPORTANT)   👉 Kubernetes never routes traffic by percentage 👉..."
published: 2026-01-06
source: "https://dev.to/jumptotech/canary-vs-rolling-update-2dea"
tags: []
---

# canary vs rolling update





![Image](https://cdn.sanity.io/images/6icyfeiq/production/b0d01c6c9496b910ab29d2746f9ab109d10fb3cf-1320x588.png?auto=format\&dpr=2\&fit=max\&h=424\&q=75\&w=952)

![Image](https://humansreadcode.com/post/2020-12-30-lambda-deploy-canary/canary-deployment.webp)



# Step 0: First rule (MOST IMPORTANT)

👉 **Kubernetes never routes traffic by percentage**
👉 **It routes traffic by pod IPs**
👉 **Traffic ≠ replicas**

This single rule explains everything.

---

# Step 1: How traffic ACTUALLY flows in Kubernetes

```
User
 ↓
Service (virtual IP)
 ↓
Random Pod IP
```

The Service:

* does **NOT** know versions
* does **NOT** know risk
* does **NOT** know percentages

It just picks **any Ready pod**.

---

# Step 2: Rolling Update — what you THINK vs what happens

## You THINK

> “I have 10 pods. Kubernetes adds 1 new pod.
> So only ~10% traffic goes to new version.”

❌ **Wrong assumption**

---

## What ACTUALLY happens

Let’s say:

* 10 pods total
* Kubernetes creates **1 new pod (v2)**
* Now you have **11 pods**

### Traffic reality:

* One user opens browser
* Makes **100 requests**
* Service keeps sending them to **same pod** (connection reuse)

📌 That one user may hit **v2 for ALL requests**

So:

* 1 pod can receive **0% traffic**
* or **80% traffic**

Kubernetes makes **NO promise**.

---

# Step 3: Why “extra pod” does NOT mean safety

Rolling update guarantees:

* Pods don’t all die at once
* Capacity stays up

Rolling update does **NOT** guarantee:

* Who gets new code
* How many users are affected
* That errors are limited

So it is:

> **availability-safe**, not **user-safe**

---

# Step 4: Concrete failure example (very real)

### Scenario: Auth Service

* v1 → works
* v2 → token validation bug

### Rolling Update

1. 1 v2 pod comes up
2. First real user hits it
3. Login fails
4. User retries → same pod
5. User locked out
6. Support ticket created
7. You rollback — damage already done

💥 Even **1 user failure** is too much in auth/payment systems.

---

# Step 5: Canary — what changes fundamentally

Canary **does NOT rely on randomness**.

You say:

* “ONLY 5% traffic goes to v2”

This is **intentional exposure**.

---

# Step 6: What “percentage” REALLY means

### Canary traffic means:

Out of **1000 requests**:

* 950 → v1
* 50 → v2

Not:

* “maybe”
* “roughly”
* “if lucky”

But:

> **ENFORCED routing**

This is done via:

* Ingress rules
* Load balancer weights
* Service mesh

---

# Step 7: Why replica-based canary is only educational

Replica-based canary:

```text
4 v1 pods
1 v2 pod
```

⚠️ This is **NOT true percentage**
It only:

* reduces probability
* does not guarantee limits

That’s why real production uses **traffic weighting**, not replicas.

---

# Step 8: Another real example (payments)

### Rolling Update

* v2 pod live
* Stripe API timeout
* One customer pays → request stuck
* Money deducted but order not created
* Finance nightmare

### Canary

* 1% traffic
* Latency spikes immediately
* Canary stopped
* 99% customers safe

---

# Step 9: Readiness probe misconception

Readiness only checks:

* “Is the process alive?”

It does NOT check:

* correctness
* latency
* external systems
* business logic

Your app can be:
✅ Ready
❌ Broken

---

# Step 10: Simple analogy (real life)

### Rolling Update = elevator test

You replace elevator parts **while people are inside**
Hope it works.

### Canary = test ride

You let **one employee ride first**, observe, then allow others.

---

# Step 11: Final crystal-clear difference

| Question              | Rolling Update   | Canary                |
| --------------------- | ---------------- | --------------------- |
| Who gets new version? | Anyone           | Only selected traffic |
| How much traffic?     | Random           | Controlled            |
| Risk size             | Unknown          | Known & limited       |
| Rollback damage       | Already happened | Minimal               |
| Used for              | Safe changes     | Risky changes         |

---

# One sentence to lock it in (memorize this)

> **Rolling update controls how pods are replaced.
> Canary controls how users are exposed.**



* **Readiness probe** answers only **one question**
  👉 *“Should Kubernetes send traffic to this pod?”*

* **Canary** answers a **completely different question**
  👉 *“Is this new version SAFE for users?”*

They solve **different problems**.

---

## What a Readiness Probe REALLY does

A readiness probe checks **technical availability**, not correctness.

Typical probes:

```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8080
```

or

```yaml
tcpSocket:
  port: 8080
```

### What Kubernetes concludes

* Probe passes → pod is **Ready**
* Probe fails → pod is **Removed from Service**

That’s it.

---

## What Readiness Probe CAN detect

* Process started
* Port is open
* Web server responds
* Container didn’t crash
* App finished startup

---

## What Readiness Probe CANNOT detect (very important)

Readiness **does NOT know** if:

* Business logic is wrong
* Payments fail
* Kafka consumer logic is broken
* External API returns errors
* Response time is terrible
* Data is corrupted
* Feature behavior is incorrect

Your app can respond:

```
HTTP 200 OK
```

and still be **functionally broken**.

---

## Concrete example (auth service)

### Readiness endpoint

```http
GET /health
200 OK
```

### Real login endpoint

```http
POST /login
500 ERROR
```

👉 Kubernetes sees **READY**
👉 Users see **FAILURE**

---

## So what does Canary do then?

Canary does **NOT** “check logic” automatically.
This is important.

### Canary itself does NOT test anything.

Instead:

* Canary **exposes real users**
* Monitoring **observes behavior**
* DevOps **decides** whether to continue

---

## Think of Canary as a controlled experiment

```
Small traffic
   ↓
Real requests
   ↓
Real behavior
   ↓
Metrics & alerts
   ↓
Decision
```

---

## Example: payment logic bug

* Readiness: ✅ Ready
* Canary traffic (5%): ❌ 20% errors
* Alert fires
* Canary stopped
* Stable version continues

Without canary:

* 100% traffic affected

---

## Key distinction (this clears confusion)

| Tool            | Purpose                              |
| --------------- | ------------------------------------ |
| Readiness probe | “Can this pod receive traffic?”      |
| Canary          | “Should users receive this version?” |

---

## Very important clarification

❌ Canary does **NOT** replace readiness
❌ Readiness does **NOT** replace canary

They are **complementary**.

---

## Real DevOps rule

> Readiness protects Kubernetes.
> Canary protects users.

---

interview questions?

> “Readiness probes only verify that a pod is technically ready to receive traffic. Canary deployments validate application behavior using real production traffic and metrics.”

---

## Final mental picture

* Readiness = engine started
* Canary = test drive on highway

Engine running ≠ car safe at 80 mph.


