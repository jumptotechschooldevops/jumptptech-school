# Prometheus & Grafana: Complete Senior DevOps/SRE Curriculum (6+ YOE)

Prometheus and Grafana are the backbone of modern observability stacks. Whether you're targeting a Senior DevOps or SRE role, this guide covers everything from fundamentals to production-grade operations — written for engineers aiming at 6+ years of experience level.

* * *

##  Chapter 1: Foundations & Philosophy 

###  The Observability Triad 

Observability is the ability to understand the internal state of a system from its external outputs. The three pillars:

  * **Metrics** — Numeric time-series data. Cheapest to store, best for dashboards and alerting. Prometheus specializes here.
  * **Logs** — Timestamped records of events. High cardinality, expensive but rich in detail. (ELK, Loki)
  * **Traces** — Request-level journey across distributed systems. (Jaeger, Tempo, Zipkin)


> **Senior Engineer Rule:** Metrics catch _WHAT_ is broken. Logs tell you _WHY_. Traces show _WHERE_.

###  Monitoring vs Observability 

  * **Monitoring** = watching predefined things you already know to watch.
  * **Observability** = being able to ask questions you didn't know you'd need to ask.
  * **Legacy monitoring** (Nagios, Zabbix): push-based, check-based, host-centric.
  * **Prometheus** : pull-based, metrics-centric, service discovery-native, cloud-native first.


**Why Prometheus won:**

  * Born inside SoundCloud (2012), donated to CNCF (2016)
  * Second CNCF graduated project after Kubernetes
  * Native integration with the cloud-native ecosystem
  * PromQL is expressive and composable
  * Federation and remote write enable scale-out


###  The Four Golden Signals (SRE Bible) 

From Google's SRE Book — the minimum you must monitor for any service:

Signal | Description | Example PromQL  
---|---|---  
**Latency** | How long requests take | `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))\`  
**Traffic** | How much demand (RPS) | `rate(http_requests_total[5m])\`  
**Errors** | Rate of failed requests | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])\`  
**Saturation** | How "full" your service is | `1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))\`  
  
###  RED Method & USE Method 

**RED Method** (for microservices — Tom Wilkie, Grafana Labs):

  * **R** ate — requests per second
  * **E** rrors — error rate
  * **D** uration — latency distribution


**USE Method** (for infrastructure — Brendan Gregg):

  * **U** tilization — % time resource is busy
  * **S** aturation — extra work queued
  * **E** rrors — error events count


> Rule of thumb: Use RED for services, USE for hosts/infrastructure.

* * *

##  Chapter 2: Prometheus Architecture 

###  Core Components 

**Prometheus Server** — The brain. Scrapes, stores, evaluates rules.

  * Scrape engine: HTTP GET /metrics on targets
  * TSDB: time-series database (local disk, not distributed)
  * Rule evaluator: recording & alerting rules


**Pushgateway** — For short-lived jobs (batch, crons) that can't be scraped. Push metrics here; Prometheus scrapes the gateway. _Do not use as a general intermediary._

**Alertmanager** — Receives alerts, deduplicates, groups, routes, and silences. Routes to PagerDuty, Slack, OpsGenie, email, etc.

**Critical Exporters:**

  * `node_exporter\` → OS metrics (CPU, memory, disk, network)
  * `kube-state-metrics\` → Kubernetes object states
  * `blackbox_exporter\` → probe HTTP/DNS/ICMP externally
  * `mysqld_exporter\` / `postgres_exporter\` → database metrics
  * `kafka_exporter\` → consumer group lag
  * `redis_exporter\` → Redis memory, hit rate, replication


###  Pull vs Push Model 

Prometheus **pulls** (scrapes) metrics from targets.

**Advantages of pull:**

  * Prometheus controls scrape interval — prevents metric floods
  * Easy to detect if a target is down (scrape fails)
  * Simpler firewall rules (Prometheus initiates)


**When pull doesn't work:**

  * Short-lived batch jobs → use Pushgateway
  * Network segmented environments → use Grafana Agent / Agent Mode
  * Massive scale (100k+ targets) → use federation or Thanos


###  TSDB Internals 

  * **Chunks** : 2-hour blocks on disk
  * **Head block** : last 2h in memory (mmap'd)
  * **Compaction** : blocks merged into larger chunks over time
  * **Retention config** : `--storage.tsdb.retention.time=30d\`


> ⚠️ **CRITICAL — Cardinality:** High cardinality labels (`user_id\`, `request_id\`, `email\`) WILL kill Prometheus. Labels must have bounded, predictable value sets. This is the #1 production issue.

###  Service Discovery 

Static configs are for demos. Production uses service discovery:

  * `kubernetes_sd_configs\` — pods, services, endpoints, nodes, ingresses
  * `ec2_sd_configs\` — AWS EC2 instances
  * `consul_sd_configs\` — HashiCorp Consul
  * `file_sd_configs\` — custom SD via JSON/YAML files


**relabel_configs** — Transform discovered metadata into labels BEFORE scraping.  
**metric_relabel_configs** — Transform metrics AFTER scraping (drop, rename, filter).

`\``yaml

#  Drop high-cardinality label after scraping 

metric_relabel_configs:

  * source_labels: [request_id] action: labeldrop ``\`


* * *

##  Chapter 3: PromQL — The Query Language 

###  Data Types 

Type | Description | Example  
---|---|---  
Instant vector | Single sample per series at evaluation time | `http_requests_total{job="api"}\`  
Range vector | Range of samples over a time window | `http_requests_total[5m]\`  
Scalar | Single float | `1.5\`  
  
**Label matchers:**

  * `=\` exact match, `!=\` not equal
  * `=~\` regex match: `{status=~"5.."}\`
  * `!~\` regex not match: `{env!~"dev|staging"}\`


###  Functions You Must Know 

`\``promql

#  Per-second rate of a counter (use this, not instant value) 

rate(http_requests_total[5m])

#  p99 latency from histograms 

histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

#  Total increase over a window 

increase(http_requests_total[1h])

#  Aggregation 

sum by (job) (rate(http_requests_total[5m]))  
topk(5, rate(http_requests_total[5m]))

#  Will disk fill in 4 hours? 

predict_linear(node_filesystem_free_bytes[1h], 4*3600) < 0

#  Alert when metric is missing 

absent(up{job="critical-service"})  
``\`

###  Binary Operators & Vector Matching 

`\``promql

#  Error ratio by method 

sum by (method) (rate(http_requests_total{status=~"5.."}[5m]))  
/  
sum by (method) (rate(http_requests_total[5m]))

#  Many-to-one matching 

method_code:http_errors:rate5m / on(method) group_left method:http_requests:rate5m  
``\`

###  Recording Rules 

Pre-compute expensive queries and save as new metrics. Makes dashboards fast.

`\``yaml  
groups:

  * name: http_metrics  
interval: 1m  
rules:

    * record: job:http_requests:rate5m expr: sum by (job) (rate(http_requests_total[5m]))
    * record: job:http_error_rate:ratio5m expr: | sum by (job) (rate(http_requests_total{status=~"5.."}[5m])) / sum by (job) (rate(http_requests_total[5m])) ``\`


**Naming convention:** `level:metric:operation\` (e.g., `job:http_requests:rate5m\`)

* * *

##  Chapter 4: Alerting & Alertmanager 

###  Writing Effective Alerting Rules 

`\``yaml  
groups:

  * name: api_alerts  
rules:

    * alert: HighErrorRate expr: job:http_error_rate:ratio5m > 0.05 for: 5m labels: severity: critical team: backend annotations: summary: "High error rate on {{ $labels.job }}" description: "Error rate is {{ $value | humanizePercentage }} for 5 minutes." runbook_url: "<https://wiki.company.com/runbooks/high-error-rate>" dashboard_url: "<https://grafana.company.com/d/api-overview>" ``\`
      * `for:\` — Must be pending for this duration before firing (reduces flapping)
      * `labels\` — Used for routing in Alertmanager
      * `annotations\` — Human-readable context; NOT used for routing
      * **Alert states:** inactive → pending → firing


###  Alertmanager Configuration 

`\``yaml  
route:  
receiver: 'slack-general'  
group_by: ['alertname', 'job']  
group_wait: 30s  
group_interval: 5m  
repeat_interval: 3h  
routes:  
\- match:  
severity: critical  
receiver: pagerduty-oncall

inhibit_rules:

  * source_match: severity: 'critical' target_match: severity: 'warning' equal: ['job', 'instance'] ``\`


###  SLO-Based Alerting — Multi-Window Multi-Burn-Rate 

This is **senior-level alerting**. Forget simple threshold alerts.

  * **SLO** — Service Level Objective. E.g., 99.9% of requests succeed over 30 days.
  * **Error budget** — 0.1% of 30 days = 43.8 minutes allowed.
  * **Burn rate** — How fast you're consuming error budget. Rate 1 = exactly on budget.


Window | Burn Rate | Alert Type  
---|---|---  
1h + 5m | 14x | Critical — page immediately  
6h + 30m | 6x | Critical — page  
1d + 2h | 3x | Warning — ticket  
3d + 6h | 1x | Info — FYI  
  
`\``promql

#  14x burn rate on a 0.1% error budget 

(  
rate(http_requests_total{status=~"5.."}[1h])  
/  
rate(http_requests_total[1h])  
) > 14 * 0.001  
``\`

> Tools: **Sloth** , **Pyrra** , **OpenSLO**. Every serious SRE team uses SLO-based alerting. Know this cold.

###  Deadman's Switch Pattern 

Alert when a metric STOPS being reported:

`\``promql  
absent(batch_job_last_success_timestamp)  
or  
time() - batch_job_last_success_timestamp > 3600  
\``\`

* * *

##  Chapter 5: Scaling Prometheus 

###  Federation 

Single Prometheus handles ~1M samples/sec, ~10M active series. Beyond that:

`\``yaml  
scrape_configs:

  * job_name: 'federate' honor_labels: true metrics_path: '/federate' params: match[]: \- 'job:http_requests:rate5m' static_configs: 
    * targets: 
      * 'prometheus-cluster1:9090'
      * 'prometheus-cluster2:9090' ``\`


> Only federate aggregated **recording rules** , not raw metrics.

###  Thanos Architecture 

Thanos extends Prometheus with global query view and long-term storage.

Component | Purpose  
---|---  
**Sidecar** | Runs next to Prometheus; uploads 2h blocks to S3/GCS/Azure  
**Store Gateway** | Serves data from object storage  
**Querier** | Merges + deduplicates results from all sources  
**Compactor** | Compacts, downsamples, enforces retention  
**Ruler** | Evaluates rules against Thanos data  
**Receive** | Remote write ingestion endpoint  
  
**Alternatives:** Grafana Mimir (recommended), Cortex, VictoriaMetrics

###  Prometheus Agent Mode 

Lightweight scraper — no local storage, no PromQL. Perfect for edge environments.

`\``bash  
prometheus --enable-feature=agent  
\``\`

`\``yaml  
remote_write:

  * url: "<https://mimir.company.com/api/v1/push>" queue_config: max_shards: 30 max_samples_per_send: 2000 write_relabel_configs: 
    * source_labels: [**name**] regex: "unnecessary_metric_.*" action: drop ``\`


###  kube-prometheus-stack (Kubernetes) 

`\``bash  
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack  
\``\`

Includes: Prometheus Operator, Prometheus HA pair, Alertmanager HA, Grafana, node_exporter, kube-state-metrics, pre-built alerting rules.

**Prometheus Operator CRDs:**

  * `ServiceMonitor\` — Auto-discover services via label selectors
  * `PodMonitor\` — Scrape pods directly
  * `PrometheusRule\` — Rules as Kubernetes objects
  * `AlertmanagerConfig\` — Routing as Kubernetes objects


* * *

##  Chapter 6: Exporters & Instrumentation 

###  The 4 Metric Types 

`\``python  
from prometheus_client import Counter, Gauge, Histogram, Summary

#  Counter — only goes up (requests, errors, bytes) 

requests_total = Counter('http_requests_total', 'Total requests',  
['method', 'status'])  
requests_total.labels(method='GET', status='200').inc()

#  Gauge — can go up or down (queue size, active connections) 

queue_size = Gauge('queue_size', 'Queue depth', ['queue_name'])  
queue_size.labels(queue_name='jobs').set(42)

#  Histogram — latency, request size (enables percentiles) 

request_latency = Histogram('request_duration_seconds', 'Latency',  
['endpoint'],  
buckets=[.005, .01, .025, .05, .1, .25, .5, 1])  
with request_latency.labels(endpoint='/api').time():  
do_work()  
``\`

> ⚠️ **Histogram vs Summary:** Prefer Histogram in distributed systems. Histograms can be aggregated across instances; Summaries cannot.

###  TLS Certificate Expiry Alert 

`\``promql

#  Alert 14 days before cert expires 

probe_ssl_earliest_cert_expiry - time() < 86400 * 14  
``\`

Never let a cert expire in production. Add this to every HTTPS endpoint.

* * *

##  Chapter 7 & 8: Grafana — Foundations to Advanced 

###  Panel Types Reference 

Panel | Best For  
---|---  
Time series | Any metric over time (default choice)  
Stat | Single current value — KPIs, NOC screens  
Gauge | Utilization % (CPU, memory, disk)  
Heatmap | Latency distribution over time  
Table | Top-N, alert states, comparison tables  
Logs | Log lines alongside metrics (Loki)  
Node Graph | Service topology / service map  
  
###  3-Tier Dashboard Hierarchy 

Tier | Audience | Content  
---|---|---  
**Tier 1: Fleet Overview** | Managers, NOC | All services status, global golden signals  
**Tier 2: Service Detail** | Engineers | Full 4 golden signals, resources, queues  
**Tier 3: Debugging** | Incident response | Detailed metrics, logs, traces, ad-hoc  
  
###  Dashboard as Code 

`\``hcl

#  Terraform 

resource "grafana_dashboard" "api_overview" {  
config_json = file("dashboards/api-overview.json")  
folder = grafana_folder.production.id  
}  
``\`

`\``yaml

#  Grafana Provisioning 

apiVersion: 1  
datasources:

  * name: Prometheus type: prometheus url: <http://prometheus:9090> isDefault: true editable: false ``\`


###  The LGTM Stack 

Letter | Component | Purpose  
---|---|---  
**L** | Loki | Log aggregation. LogQL. Promtail agent.  
**G** | Grafana | Visualization for the entire stack  
**T** | Tempo | Distributed tracing. OpenTelemetry compatible.  
**M** | Mimir | Horizontally scalable Prometheus. Multi-tenant.  
  
> **OpenTelemetry (OTel)** is the vendor-neutral standard for instrumentation — one SDK for traces, metrics, and logs. Senior engineers must know OTel. It's replacing vendor-specific SDKs.

* * *

##  Chapter 9: Production Operations 

###  Security Hardening 

`\``yaml

#  Prometheus web.yml — TLS + Basic Auth 

tls_server_config:  
cert_file: /etc/prometheus/certs/tls.crt  
key_file: /etc/prometheus/certs/tls.key  
basic_auth_users:  
prometheus: $2b$12$hashed_password_bcrypt  
``\`

**Grafana security checklist:**

  * SSO via OIDC/SAML (Google, Okta, Azure AD)
  * RBAC: Viewer, Editor, Admin roles per folder
  * Service accounts for API automation
  * Audit log for compliance
  * Network policies to restrict access


###  Capacity Planning 

Samples/sec | RAM (head block) | Notes  
---|---|---  
100k | ~1 GB | Small deployment  
500k | ~5 GB | Medium deployment  
1M | ~10 GB | Large — consider sharding  
10M+ | 100+ GB | Use Thanos/Mimir sharding  
  
`\``promql

#  Detect cardinality explosion — top 10 metrics by series count 

topk(10, count by (**name**) ({**name** =~".+"}))  
``\`

###  HA & Disaster Recovery 

Run 2 identical Prometheus instances + Thanos Sidecar. Querier deduplicates. No data loss if one goes down.

`\``yaml

#  Alertmanager 3-node gossip cluster 

alerting:  
alertmanagers:  
\- static_configs:  
\- targets:  
\- alertmanager-0:9093  
\- alertmanager-1:9093  
\- alertmanager-2:9093  
``\`

###  Incident Response — 10-Step Flow 

  1. Alert triggers → Alertmanager routes to PagerDuty/Slack
  2. Acknowledge → stops repeat notifications
  3. Open Grafana → navigate to alert's dashboard link
  4. Identify timeframe → when did it start? Correlate with deployments?
  5. Check golden signals → which of the 4 is affected?
  6. Drill down → use Explore for ad-hoc PromQL queries
  7. Correlate → check logs in Loki, traces in Tempo
  8. Mitigate → rollback, scale, circuit break, redirect traffic
  9. Resolve → silence alert if still noisy after fix
  10. Post-mortem → timeline, root cause, action items


`\``promql

#  What changed recently? 

changes(kube_deployment_spec_replicas[30m]) > 0

#  Memory leak detection 

predict_linear(container_memory_working_set_bytes[1h], 3600)

> container_spec_memory_limit_bytes  
>  ``\`

* * *

##  Chapter 10: Career Prep — Interview Topics 

###  PromQL Questions You Will Be Asked 

  * Explain the difference between `rate()\` and `irate()\`
  * How does `histogram_quantile()\` work? What are bucket boundaries?
  * Write PromQL for p99 latency across all instances of a service
  * What is vector matching? When would you use `group_left\`?
  * How do recording rules improve dashboard performance?


###  Architecture Questions 

  * Why does Prometheus use a pull model? What are the tradeoffs?
  * How would you handle 10M active time series?
  * Explain Thanos architecture. How does deduplication work?
  * What is cardinality and why does it matter?
  * How do you do HA for Prometheus? For Alertmanager?


###  Real-World War Stories 

**The Cardinality Bomb:** Developer adds `user_id\` as a label. 1M users = 1M new series. Prometheus OOMs. Solution: cardinality limits, label governance, pre-deploy PromQL review.

**The Counter Reset Problem:** Pod restarts → counter resets. `rate()\` handles resets automatically — always use `rate()\` on counters, never raw instant values.

**The Pushgateway Anti-Pattern:** Stale metrics persist forever in Pushgateway. Solution: add last-push timestamp metric, set up deletion via admin API.

**The Alert Deduplication Failure:** Two HA Prometheus fire the same alert, both page. Solution: Alertmanager cluster with gossip deduplication.

###  The Full Observability Ecosystem 

Category | Tools  
---|---  
Metrics Collection | Prometheus, Grafana Agent, OpenTelemetry Collector  
Long-term Storage | Thanos, Grafana Mimir, Cortex, VictoriaMetrics, AWS AMP  
Logs | Grafana Loki, ELK Stack, Splunk  
Traces | Jaeger, Grafana Tempo, Zipkin, AWS X-Ray  
Alerting | Alertmanager, Grafana Unified Alerting, PagerDuty, OpsGenie  
SLO Management | Sloth, Pyrra, OpenSLO, Grafana SLO  
Visualization | Grafana (dominant), Kibana, Honeycomb  
  
###  90-Day Learning Roadmap 

**Days 1–15:** Core Prometheus — install locally, query node metrics, write alerting rules, set up Slack integration.

**Days 16–30:** PromQL mastery — complete PromlLabs PromQL Quiz, write histogram queries, instrument a Python/Go app with all 4 metric types.

**Days 31–50:** Kubernetes integration — deploy kube-prometheus-stack, write ServiceMonitors and PrometheusRules, explore kube-state-metrics.

**Days 51–70:** Grafana deep dive — build 3-tier dashboard hierarchy, dashboard-as-code with Terraform, set up SSO, explore Loki.

**Days 71–90:** Scale & production — deploy Thanos, implement SLO-based alerting with Sloth, practice incident response, build a public GitHub portfolio.

* * *

_This curriculum covers everything expected of a Senior DevOps/SRE engineer with 6+ years of experience. Go build. Go break things. Go learn._
