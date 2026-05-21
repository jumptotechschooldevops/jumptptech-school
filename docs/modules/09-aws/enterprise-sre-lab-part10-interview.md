---
title: "Part 10: SRE Interview Q&A — Senior Level (6+ Years)"
description: 10 in-depth SRE interview questions with full production-quality answers covering AWS, reliability, incident management, and architecture
---

# Part 10: SRE Interview Q&A — Senior Level

**← [Part 9: Runbooks](enterprise-sre-lab-part9-runbooks.md) | [Back to Lab Overview →](enterprise-sre-lab-ecommerce-platform.md)**

---

## How to Use This Section

These questions are asked at companies like Amazon, Google, Stripe, Datadog, and other companies that hire Senior SRE / Platform engineers. For each question:

- Read the **full answer** — it shows what a senior engineer actually says, not just the textbook definition
- Note the **depth markers** — senior answers connect theory to production experience
- Practice saying the answer out loud — SRE interviews are conversational

---

## Q1: How would you design the monitoring strategy for a high-traffic e-commerce platform?

### Full Answer

I start with the **four golden signals** from Google SRE: latency, traffic, errors, and saturation. But in practice, the way I prioritize and implement them depends on the business context.

For an e-commerce platform, the most business-critical SLI is **checkout success rate** — that directly maps to revenue. If 99.9% of checkout attempts succeed, that's my top SLO. Every other metric exists to help me detect and prevent degradation in that SLO.

**For the monitoring stack, I use layers:**

1. **Application metrics** (Prometheus + custom counters/histograms): I instrument the application to emit `http_requests_total`, `http_request_duration_seconds_bucket`, and business events like `checkout_orders_total{status="success|failed"}`. These give me RED metrics per endpoint.

2. **Infrastructure metrics** (CloudWatch Container Insights, RDS metrics): CPU, memory, connection counts — these tell me when saturation is approaching before users feel it.

3. **Distributed tracing** (AWS X-Ray): When I see high latency, I need to know which downstream service caused it — the DB query? Redis? An external payment API? Traces answer this in seconds instead of hours.

4. **Log aggregation** (CloudWatch Logs Insights): For debugging specific errors. I don't alert on logs (too noisy) but I use them during incident investigation.

**For alerting, I use multi-window burn rate:**

Rather than alerting on "error rate > 1% for 5 minutes," I alert on SLO burn rate. A fast burn (14.4x over 1 hour) triggers P1 — my error budget is burning so fast I'll be out in 5 days. A slow burn (3x over 6 hours) triggers P2. This approach reduces false positives dramatically compared to simple threshold alerts.

**The principle I never compromise on:** the monitoring system itself must have an SLO. I run backup CloudWatch alarms so that if Prometheus goes down, I still get paged. Monitoring your monitoring is not optional at senior level.

---

## Q2: An alert fires: API p99 latency jumped from 200ms to 800ms. Walk me through your investigation.

### Full Answer

I follow the **USE/RED** method and work from the outside in — start at the user-facing symptom and drill down to root cause.

**First 60 seconds — scope the problem:**

Is this affecting all users or a subset? All endpoints or one? I check Grafana immediately: is latency high across all routes or just one? Is the checkout service also affected? This tells me whether it's infrastructure (affects everything) or application logic (affects specific paths).

**Next 2 minutes — eliminate quick wins:**

I check if a deployment happened in the last 30 minutes. If yes, that's my first suspect. I check the ECS deployment events and compare task definition revisions. A bad deployment is the most common cause of sudden latency spikes.

**Parallel investigation — the four suspects:**

1. **CPU saturation on ECS tasks**: Check Container Insights. If CPU > 85%, the app is starving for compute. Fix: trigger auto-scaling manually (`aws ecs update-service --desired-count N`).

2. **Database latency**: Check `aws cloudwatch get-metric-statistics` for RDS `ReadLatency` and `WriteLatency`. If DB is slow, I look for long-running queries or lock contention via `SHOW ENGINE INNODB STATUS`. A sudden slow query usually means a missing index, or a table grew large enough that a query plan changed.

3. **Cache miss rate**: Check Redis `keyspace_hits` vs `keyspace_misses`. If the cache hit rate dropped from 95% to 50%, every request is now hitting the DB instead of Redis. This is usually caused by a Redis restart (data evicted) or a cache invalidation bug in a recent deploy.

4. **External dependencies**: Check X-Ray traces. If a third-party payment API or shipping provider started responding slowly, the latency shows up in my app's p99 even though my code is fine.

**The key senior insight:** I never blame the infrastructure first. Most latency spikes come from application changes — a new query that runs on every request, a missing cache warming step after deployment, a synchronous call that was previously async. I correlate the latency spike with deployment timing before digging into infrastructure metrics.

---

## Q3: What is an error budget and how do you use it operationally?

### Full Answer

An error budget is the **maximum allowable unreliability** implied by your SLO. If your SLO is 99.95% availability over 30 days, your error budget is 0.05% of requests — which works out to about 21.6 minutes of downtime per month.

**Why it matters operationally:**

The error budget is the key tool that prevents the SRE vs development tension from becoming adversarial. Instead of the SRE team saying "you can't deploy, it might break things," we say "you have X minutes of error budget left this month — do you want to spend it on this deployment, or save it?"

**How I use it in practice:**

I build a Grafana dashboard that shows error budget as a percentage remaining and as a burn rate. The burn rate tells me how fast we're consuming the budget relative to what's sustainable.

When the budget is healthy (> 50% remaining), we're in "innovation mode" — teams can deploy frequently, try experiments, and accept some risk. When the budget is low (< 20%), we shift to "reliability mode" — freeze non-critical deployments, focus engineering attention on stability improvements.

**The burn rate alerts:**

I use two alerting windows. The fast burn alert (14.4x over 1 hour) pages the on-call immediately — at this rate, we'd exhaust the monthly budget in about 5 days. The slow burn alert (3x over 6 hours) pages the team to investigate during business hours — less urgent but still concerning.

**The key insight that distinguishes senior SREs:** the error budget is a tool for *productive conversations*, not just a metric. When I present error budget data to leadership, I frame it as: "we can either invest in reliability work to restore the budget, or accept the risk of P1 incidents and reduced deployment velocity."

---

## Q4: How does AWS WAF protect against SQL injection differently from parameterized queries?

### Full Answer

They operate at completely different layers, and a mature security posture requires both.

**Parameterized queries** (prepared statements) are the correct fix at the **application layer**. When you use `SELECT * FROM users WHERE id = ?` with a bound parameter, the database treats the parameter value as pure data — it never interprets it as SQL syntax, regardless of what the user submitted. This is the definitive protection against SQLi.

**AWS WAF** operates at the **HTTP layer**, before the request reaches your application. It inspects request patterns — query strings, body, headers, URI — and blocks requests that match known SQL injection signatures. WAF catches:
- Obvious injection attempts (`1' OR '1'='1`)
- Known bad payloads from vulnerability scanners
- Encoded variations (`1%27+OR+%271%27%3D%271`)

**Why you need both:**

WAF is a *shield*, not a cure. If WAF is your only SQLi protection and your application uses string concatenation to build queries, an attacker who studies your WAF's rule patterns can craft an injection that bypasses the rules. WAF rules are signatures — they can be evaded with enough creativity.

Parameterized queries are a *structural fix* — they make injection impossible by design, regardless of input.

**In my ShopFlow setup:** I enable the AWS Managed Rules SQLi Rule Set in WAF to catch and block known attack patterns in the perimeter. But I also enforce parameterized queries in code review — WAF blocking a SQLi attempt is a warning signal; an SQLi that would succeed if WAF were removed represents a vulnerability.

Additionally, WAF provides a **rate-limiting benefit** that parameterized queries don't — if a scanner is hammering the API trying injections at 1000 req/min, WAF rate rules can block the IP before it burns through error budget.

---

## Q5: Explain ECS Fargate vs EC2 launch type — when do you choose each?

### Full Answer

Both run containers, but the operational model is fundamentally different.

**ECS Fargate:** AWS manages the underlying EC2 instances. You specify CPU and memory per task, and AWS figures out placement. You never see the hosts, never patch them, never worry about cluster capacity.

**ECS EC2 launch type:** You manage a cluster of EC2 instances. You're responsible for right-sizing the instances, keeping the ECS agent updated, handling instance failures, and managing cluster capacity.

**I choose Fargate by default for most workloads because:**

1. **No capacity management**: In Fargate, I can deploy from 2 tasks to 50 tasks without worrying about whether the cluster has enough EC2 capacity. In EC2 mode, if I scale out and there's no available instance, my tasks stay PENDING until a new instance joins the cluster.

2. **Security isolation**: Each Fargate task runs in its own micro-VM (using Firecracker). Task-to-task lateral movement attacks that are possible on shared EC2 hosts are not possible in Fargate. For an e-commerce platform handling payment data, this matters.

3. **Operational simplicity**: No patching, no AMI management, no ECS agent upgrades. My SRE team can focus on the application, not the substrate.

**I choose EC2 launch type when:**

1. **I need GPU instances** (ML inference, video processing) — Fargate doesn't support GPUs.
2. **Very high resource requirements** (tasks that need 32+ vCPUs or 240+ GB RAM) — Fargate has limits per task.
3. **Extremely predictable workloads where Spot Instance savings matter** — EC2 Auto Scaling Groups with Spot instances can be significantly cheaper at scale (30-70%), and the workload can tolerate Spot interruptions gracefully.
4. **Specific networking requirements** — certain network modes and host-level features are only available on EC2.

**In ShopFlow:** I use Fargate for the API and checkout services (default, 80% FARGATE_SPOT + 20% FARGATE for cost savings). If I were building a recommendation ML service that needed GPU inference, I'd use EC2.

---

## Q6: A junior engineer asks: "Why do we have 3 NAT Gateways instead of 1? That's 3x the cost." How do you explain the tradeoff?

### Full Answer

This is one of the most common cost vs. availability conversations I have with engineers.

**The cost:** Each NAT Gateway in us-east-1 costs approximately $0.045/hour + data processing charges. Three NAT Gateways cost roughly $100/month more than one, plus the data processing difference.

**The risk of a single NAT Gateway:**

If you have one NAT Gateway in `us-east-1a`, and `us-east-1a` has an availability zone outage (these happen — AWS has had AZ failures), all your private subnets in `us-east-1b` and `us-east-1c` lose their ability to reach the internet. Your ECS tasks in those AZs can no longer:
- Pull Docker images from ECR (even with VPC endpoints, some fallback paths go through NAT)
- Reach Secrets Manager (if the VPC endpoint is also in 1a)
- Send metrics to CloudWatch
- Make outbound API calls to payment processors

So during an AZ outage, you still have healthy ECS tasks running in `us-east-1b` and `us-east-1c`, but they can't function because their network path through `us-east-1a` is broken.

**My math for a Senior SRE:**

ShopFlow processes $50,000 in orders per day, or roughly $35/minute. One AZ outage per year that lasts 30 minutes = $1,050 in lost revenue. The cost of two extra NAT Gateways is ~$1,200/year. On pure math, it's break-even — and that's assuming you only care about revenue, not SLO violations and customer trust.

For a high-traffic e-commerce platform with a 99.95% SLO, a single NAT Gateway is a single point of failure that makes the SLO impossible to achieve. You can't have 99.95% availability if your architecture has a component that, when it fails, takes down 2/3 of your capacity.

**My actual answer to the junior engineer:** "The $100/month buys us architectural multi-AZ correctness. If we have a single NAT Gateway and AZ-a fails during Black Friday, we will regret saving $100/month very quickly."

---

## Q7: How do you implement zero-downtime deployments on ECS?

### Full Answer

Zero-downtime deployment on ECS requires getting several pieces right simultaneously.

**The ECS deployment mechanism:**

ECS rolling deployments work by starting new tasks with the new task definition, waiting for them to pass health checks, and then stopping old tasks. The `deployment_maximum_percent = 200` and `deployment_minimum_healthy_percent = 100` settings mean: "double the capacity temporarily during deployment, but never go below 100% of desired healthy tasks."

**The ALB connection draining:**

When ECS deregisters an old task from the ALB target group, the ALB starts refusing new connections to that target but waits for in-flight requests to complete. The `deregistration_delay = 30` seconds on the target group gives existing requests time to finish. If you set this to 0, in-flight requests get killed mid-checkout — not zero-downtime.

**The application contract:**

The application itself must handle graceful shutdown. When ECS sends `SIGTERM`, the app should:
1. Stop accepting new requests
2. Finish processing in-flight requests
3. Close database connections cleanly
4. Exit with code 0

If the app ignores `SIGTERM` and ECS has to send `SIGKILL` after 30 seconds (the `stopTimeout`), any in-flight requests are killed. I set `stopTimeout = 30` in the task definition and ensure the app handles `SIGTERM` correctly.

**Health checks — the gating mechanism:**

The new task only receives traffic after passing both the ECS container health check AND the ALB health check. The ECS health check (`healthCheck.startPeriod = 60`) gives the app 60 seconds to start up before marking it unhealthy. Without this, slow-starting apps get killed on first deployment.

**The circuit breaker:**

Even with all this, a bad deployment can still cause issues (health check passes but requests fail in production). I enable the ECS deployment circuit breaker — if more than half of the new tasks fail within a deployment, ECS automatically stops the deployment and triggers a rollback to the last stable task definition.

**What I also do:** Smoke tests in the CI/CD pipeline that run for 60 seconds against production after deployment, checking error rates. This catches the "health check passes but real users get 500s" scenario.

---

## Q8: Your team is considering moving from Aurora MySQL to DynamoDB for the orders table. What's your analysis?

### Full Answer

This is a real architecture tradeoff that comes up frequently in high-growth companies. My analysis depends on the access patterns.

**Why Aurora MySQL is good for orders:**

Orders data is highly relational. An order has a customer, line items referencing product catalog, a shipping address, payment info, discount codes, and status history. MySQL lets you express these relationships with foreign keys, join queries like "get all orders for this customer with items and status," and ACID transactions that guarantee an order's payment record and inventory decrement happen atomically.

For a 50,000 orders/day platform, Aurora MySQL with connection pooling via RDS Proxy handles this volume easily — you're looking at maybe 2-5 writes per second, well within Aurora's capabilities.

**When DynamoDB makes sense:**

DynamoDB shines when you have:
1. A known, simple access pattern (get order by order ID, or list orders by customer ID)
2. Massive scale (millions of orders/day, not tens of thousands)
3. Variable load that benefits from DynamoDB's auto-scaling (no cold start latency with Aurora Serverless v2 either, so this is less of a differentiator now)

**The gotchas of migrating orders to DynamoDB:**

- No ad-hoc queries. Any new query pattern requires a GSI planned in advance. If your analytics team wants "orders by product in the last 30 days for customers in California," you need a GSI that was designed for that — you can't write it ad-hoc.
- No multi-table transactions unless you use DynamoDB Transactions (has performance cost and 25-item limit).
- DynamoDB's consistency model (eventual vs strong consistent reads) requires your application to handle read-your-writes scenarios explicitly.

**My recommendation:**

For ShopFlow at current scale, stay on Aurora MySQL. Introduce DynamoDB for specific read-heavy, simple-access patterns — session storage, product catalog cache, user preferences. These fit DynamoDB's model perfectly.

If orders volume grew to 500K+/day and analytics queries were causing load on the operational database, I'd consider splitting into Aurora (for operational OLTP writes) + Aurora DSQL or DynamoDB (for time-series order reads) — not a wholesale migration.

---

## Q9: How do you handle secrets rotation in a production system without downtime?

### Full Answer

This is a genuinely difficult operations problem because you have a brief window where the old secret is revoked but some application instances haven't picked up the new one.

**The strategy I use in ShopFlow:**

AWS Secrets Manager can rotate secrets automatically. For database credentials, Aurora's native rotation generates a new password, updates it in the database, and updates the secret — all without you touching anything. But the application still needs to re-read the secret.

**The rotation window problem:**

If your app reads the DB password once at startup and caches it in memory, rotation doesn't help — the app is still using the old password. After the old password is revoked, the app gets authentication failures until it restarts.

**My solution — live secret reloading:**

I build applications to use a **secret client with caching and refresh**. AWS Secrets Manager client libraries support caching with a TTL. I set the TTL to 5 minutes. During rotation:
1. Secrets Manager creates a new password
2. Updates both old and new passwords in Aurora (grace period — both are valid)
3. Updates the secret in Secrets Manager
4. Deletes the old password from Aurora after the grace period

During the grace period (default 6 hours), both passwords work. The app's 5-minute cache TTL means within 5 minutes, all instances pick up the new password. After that, the old password is revoked. No downtime.

**For ECS specifically:**

ECS injects secrets at task start. A running task that's been up for 3 months has the old password in memory. The fix is: secrets rotation triggers a rollout of new ECS tasks (via EventBridge → Lambda → `aws ecs update-service --force-new-deployment`). New tasks start with the new secret. Old tasks drain gracefully.

**The operational process:**

```
Week 1: Both DB passwords valid
        App instances refresh from Secrets Manager every 5 minutes
        New ECS deployment starts → new tasks get new password
        
Week 2: Old password revoked from DB
        All running tasks now using new password
        No authentication failures
```

**One thing I always test:** I never trust that rotation works until I've done a rotation drill in staging, verified zero authentication errors, and confirmed the new password is being used.

---

## Q10: You've been asked to reduce AWS costs by 30% without reducing reliability. What do you do?

### Full Answer

Cost optimization without reliability regression is one of the most valuable things a Senior SRE can deliver. I approach it with data first — never guess.

**Step 1 — Cost visibility:**

I enable AWS Cost Explorer with resource-level tagging and identify the top 5 cost drivers. For a typical e-commerce stack, it's usually: EC2/Fargate compute, RDS, data transfer, ElastiCache, and CloudWatch. I also enable AWS Compute Optimizer to get machine-learning-based rightsizing recommendations.

**The biggest wins, in rough order of impact:**

**1. Spot/Fargate Spot (potential 40-70% compute savings):**

This is the highest-leverage lever. If I move 70% of ECS tasks to FARGATE_SPOT (with 30% FARGATE for baseline), I save 40-60% on compute costs. The key is designing for Spot interruptions: the app handles `SIGTERM` gracefully, ECS automatically replaces interrupted tasks, and I keep at least 2 non-Spot tasks in the minimum capacity.

For ShopFlow, I'd run: base = 2 FARGATE tasks (always stable), scale = FARGATE_SPOT up to 20.

**2. RDS Serverless v2:**

If the prod RDS cluster is sized for peak but idles during off-hours, Aurora Serverless v2 scales ACUs (Aurora Capacity Units) down to 0.5 ACU at 3am and up to 64 ACU during peak. For workloads with variable traffic, savings are 30-50% on RDS costs.

**3. Data transfer costs:**

VPC Gateway Endpoints for S3 are free — and S3 data transfer from the VPC is free via the endpoint. If ECS tasks are downloading large assets from S3 without an endpoint, you're paying $0.09/GB. This is often a quick win.

**4. Rightsizing:**

Compute Optimizer often finds tasks running at 10-20% CPU with 256 MB memory requests but 1 vCPU/2 GB memory allocations. Reducing to match actual usage saves Fargate costs proportionally.

**5. CloudWatch Logs retention:**

Logs stored for 365 days vs 30 days costs ~12x more per GB. Most production systems keep 30 days hot, archive to S3 with S3 lifecycle to Glacier after 90 days.

**What I don't cut:**

- Multi-AZ for RDS (the cost of a single outage exceeds months of savings)
- NAT Gateways per AZ (same logic as Q6)
- Monitoring infrastructure — being blind during an incident costs more than the monitoring stack

**The 30% target:**

With Spot for compute + Serverless v2 for RDS + data transfer optimization, 30% reduction is very achievable on a typical stack. I would track the actual savings in Cost Explorer weekly and present a before/after to stakeholders, since cost savings are a concrete SRE business case.

---

## Summary: What Makes Senior-Level SRE Answers

| Junior | Senior |
|--------|--------|
| "WAF blocks SQL injection" | "WAF is a perimeter shield; parameterized queries are the structural fix — you need both" |
| "Use CloudWatch for monitoring" | "Use multi-window burn rate alerts against SLO; CloudWatch is backup when Prometheus is down" |
| "NAT Gateway routes private traffic" | "One NAT Gateway is a single point of failure for multi-AZ HA; the $100/month cost is justified" |
| "Fargate manages servers for you" | "Fargate's task-level isolation provides security guarantees that shared EC2 doesn't; the tradeoff is GPU/large instance support" |
| "Rotate secrets with Secrets Manager" | "Rotation requires the app to reload secrets, not just rotate them; design for grace periods and force ECS redeployment" |

---

**← [Back to Lab Overview](enterprise-sre-lab-ecommerce-platform.md)**
