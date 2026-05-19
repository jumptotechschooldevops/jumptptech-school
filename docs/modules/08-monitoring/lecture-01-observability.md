# Lecture 1 · Observability Principles

## Monitoring vs observability

These terms are often used interchangeably, but they are different concepts.

**Monitoring** is knowing that something is wrong. You set up metrics and thresholds: if CPU > 90%, alert. If error rate > 1%, page someone. Monitoring answers: "Is the system healthy?"

**Observability** is understanding *why* something is wrong. An observable system lets you ask arbitrary questions about its internal state from the outside, without having to deploy new instrumentation. Observability answers: "Why is this particular user's request failing?"

A highly monitored system might have 200 dashboards showing CPU, memory, and request rates — and still leave you completely unable to debug a subtle performance regression affecting 0.1% of requests.

A highly observable system has metrics, logs, and traces that are correlated by request ID, allowing you to trace a single user's request from the load balancer to the database and back, seeing every step.

For most teams getting started, monitoring comes first. But design your systems to be observable from the start.

---

## The three pillars

### Metrics

Metrics are numerical measurements over time. They answer questions like:
- How many requests per second is the API serving?
- What is the p99 latency?
- What percentage of requests are returning errors?
- How much memory is this service using?

Metrics are cheap to store and query, and great for dashboards and alerting. They are bad for understanding individual requests.

Types of metrics:
- **Counter** — monotonically increasing (total requests, total errors). Never decreases except on restart.
- **Gauge** — can increase or decrease (current memory usage, queue depth).
- **Histogram** — samples distribution (request duration, response size). Allows percentile queries.
- **Summary** — similar to histogram, computed client-side (avoid in Prometheus — use histograms).

### Logs

Logs are textual records of events. They answer questions like:
- What error occurred at 14:32:15?
- Which requests resulted in a 500 error?
- What did the application do before it crashed?

Logs provide full context but are expensive to store and slow to query at scale. Structured logs (JSON) are much more useful than plain text — they can be filtered and aggregated by field.

```json
{
  "timestamp": "2026-05-18T14:32:15.123Z",
  "level": "error",
  "request_id": "req-abc123",
  "user_id": "usr-456",
  "method": "POST",
  "path": "/api/payment",
  "status": 500,
  "duration_ms": 2341,
  "error": "database connection timeout",
  "trace_id": "1234abcd5678efgh"
}
```

### Traces

Traces follow a single request as it moves through a distributed system. A trace is composed of **spans** — each operation (HTTP call, database query, cache lookup) is a span with a start time, duration, and attributes.

Traces answer: "Why did this specific request take 2 seconds when most take 50ms?"

Distributed tracing tools: Jaeger, Zipkin, Tempo (Grafana), AWS X-Ray.

---

## SLIs, SLOs, and SLAs

### SLI — Service Level Indicator

A quantitative measure of service behaviour. The number you actually measure.

Good SLIs:
- **Availability** — percentage of requests that succeeded
- **Latency** — percentage of requests that completed within a threshold
- **Error rate** — percentage of requests that returned an error
- **Throughput** — requests per second

### SLO — Service Level Objective

A target value for an SLI. Your internal commitment to performance.

```
Availability SLO: 99.9% of requests succeed
Latency SLO: 95% of requests complete in < 200ms
             99% of requests complete in < 500ms
```

99.9% availability allows ~43 minutes of downtime per month.
99.99% allows ~4.3 minutes per month.
100% is not achievable — do not promise it.

### Error budget

Your error budget is the flip side of your SLO:

```
99.9% SLO → 0.1% error budget
            → 43.8 minutes of downtime per month
```

Spending the error budget means you are burning through your allowed downtime. When the budget is nearly exhausted, you stop taking risks (new deployments, experiments) and focus on reliability. When the budget is healthy, you can move fast.

### SLA — Service Level Agreement

A contract with a customer. Consequences (credits, penalties) if the SLA is violated. SLAs should always be weaker than your SLOs — your internal target should be harder than your external commitment.

---

## Designing useful alerts

Most monitoring implementations have too many alerts. Every alert that fires must be actionable — if nobody acts on it, it is noise. Noise trains teams to ignore alerts, which means critical alerts get missed.

**A good alert:**
- Is always actionable — someone can do something right now
- Has a clear title explaining what is broken
- Has a runbook link explaining what to do
- Has the right severity (page someone at 2am only if the business is losing money right now)

**A bad alert:**
- "CPU is high" — so what? Is it causing problems?
- "Memory usage at 75%" — this is fine for most services
- "Deploy finished" — this is not an alert, it is a notification

### Alert categories

| Category | Severity | Example |
|----------|----------|---------|
| Symptom-based | High | Error rate > 5% for 5 minutes |
| Cause-based | Medium | Database connection pool exhausted |
| Capacity | Low | Disk usage > 80% |
| Absence | High | No data received for 10 minutes |

Always prefer symptom-based alerts (user impact) over cause-based alerts (internal behaviour). Users do not care that your CPU is high — they care if the site is slow or returning errors.

---

## The USE method (for resources)

For every resource (CPU, memory, disk, network):

- **Utilisation** — how busy is it?
- **Saturation** — how much work is queued?
- **Errors** — are there errors?

```
CPU:
  Utilisation: CPU usage %
  Saturation: load average / number of CPUs
  Errors: CPU machine check errors (rare)

Disk:
  Utilisation: disk I/O %
  Saturation: disk queue length
  Errors: disk errors in dmesg

Network:
  Utilisation: bandwidth used / capacity
  Saturation: dropped packets
  Errors: interface errors
```

## The RED method (for services)

For every service (API endpoint, microservice):

- **Rate** — requests per second
- **Errors** — failed requests per second
- **Duration** — distribution of request latencies

These map directly to what users experience.

---

## Summary

- Observability ≠ monitoring. Monitoring tells you something is wrong. Observability tells you why.
- Three pillars: metrics (numbers over time), logs (events with context), traces (request flows).
- SLIs measure behaviour. SLOs are targets. Error budgets balance reliability and velocity.
- Good alerts are actionable. Page people only for symptoms with user impact.
- USE method for resources. RED method for services. Both together give complete coverage.
