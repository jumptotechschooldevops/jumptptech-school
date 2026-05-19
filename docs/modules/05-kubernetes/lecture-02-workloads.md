# Lecture 2 · Workloads & Config

## Workload resources

Beyond Deployments, Kubernetes has specialised workload types for different use cases.

### StatefulSet

StatefulSets manage pods that need stable identities and persistent storage. Unlike Deployment pods which are interchangeable, StatefulSet pods have:

- Stable network names: `mydb-0`, `mydb-1`, `mydb-2`
- Ordered startup and shutdown (pod 0 before pod 1, etc.)
- Stable storage — each pod gets its own PVC that survives rescheduling

Use StatefulSets for: databases (PostgreSQL, MySQL, Cassandra), Kafka, ZooKeeper, Redis Cluster.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless   # must match a headless service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:              # each pod gets its own PVC
    - metadata:
        name: data
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 10Gi
```

### DaemonSet

A DaemonSet runs exactly one pod on every node (or on a subset of nodes matching a selector). When new nodes join the cluster, the DaemonSet pod is automatically scheduled there.

Use DaemonSets for: log collectors (Fluentd, Filebeat), metrics agents (node-exporter), network plugins, storage daemons.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true    # access host network interfaces
      hostPID: true        # access host process namespace
      containers:
        - name: node-exporter
          image: prom/node-exporter:v1.8.0
          ports:
            - containerPort: 9100
              hostPort: 9100
```

### Jobs and CronJobs

A Job runs a pod to completion. When the pod finishes successfully, the job is done. Failed pods are retried up to `backoffLimit` times.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-migration
spec:
  backoffLimit: 3
  template:
    spec:
      restartPolicy: Never    # Jobs require Never or OnFailure
      containers:
        - name: migrate
          image: myapp:v2
          command: ["python", "manage.py", "migrate"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database_url
```

A CronJob creates Jobs on a schedule:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-report
spec:
  schedule: "0 2 * * *"       # 2am every night (cron syntax)
  concurrencyPolicy: Forbid   # do not run if previous is still running
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: reporter
              image: myapp:latest
              command: ["python", "report.py", "--send-email"]
```

---

## ConfigMaps

ConfigMaps store non-sensitive configuration data — feature flags, service URLs, tuning parameters. They decouple configuration from the container image.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: info
  MAX_CONNECTIONS: "100"
  FEATURE_DARK_MODE: "true"
  app.properties: |
    server.port=8000
    cache.ttl=300
    retry.max=3
```

Use ConfigMaps as environment variables:

```yaml
spec:
  containers:
    - name: app
      image: myapp:v1
      # Reference individual keys
      env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: LOG_LEVEL
      # Or load all keys as environment variables
      envFrom:
        - configMapRef:
            name: app-config
```

Use ConfigMaps as mounted files:

```yaml
      volumeMounts:
        - name: config
          mountPath: /etc/app
  volumes:
    - name: config
      configMap:
        name: app-config
        items:
          - key: app.properties
            path: app.properties
```

The file `/etc/app/app.properties` in the container contains the multi-line value from the ConfigMap.

---

## Secrets

Secrets are like ConfigMaps but for sensitive data: passwords, API keys, TLS certificates.

!!! warning
    By default, Kubernetes Secrets are base64-encoded, not encrypted. They are stored in etcd without encryption unless you explicitly configure encryption at rest. For production, use a secrets manager (HashiCorp Vault, AWS Secrets Manager) or enable etcd encryption.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:                    # base64-encodes automatically
  database_url: "postgresql://user:password@host:5432/db"
  api_key: "sk-abc123"
```

Use secrets as environment variables:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: database_url
```

TLS secrets for HTTPS:

```bash
kubectl create secret tls my-tls \
    --cert=cert.pem \
    --key=key.pem
```

Image pull secrets for private registries:

```bash
kubectl create secret docker-registry registry-credentials \
    --docker-server=ghcr.io \
    --docker-username=myuser \
    --docker-password=mytoken
```

---

## Resource requests and limits

Every container should declare resource requests and limits:

```yaml
resources:
  requests:
    memory: "128Mi"   # guaranteed minimum
    cpu: "100m"       # 100 millicores = 0.1 CPU core
  limits:
    memory: "256Mi"   # maximum allowed
    cpu: "500m"       # 500 millicores = 0.5 CPU core
```

- **Requests** — what the scheduler uses for pod placement. A pod is scheduled on a node that has at least this much available.
- **Limits** — enforced at runtime. A container exceeding its memory limit is killed (OOMKilled). A container exceeding its CPU limit is throttled (not killed).

CPU is expressed in millicores: `1000m = 1 core`. Memory uses suffixes: `Mi` (mebibyte), `Gi` (gibibyte).

### Resource quality of service

Kubernetes assigns a QoS class to each pod:

| Class | Condition | Eviction priority |
|-------|-----------|-------------------|
| Guaranteed | requests == limits for all containers | Last to be evicted |
| Burstable | requests < limits (or partial) | Middle |
| BestEffort | no requests or limits | First to be evicted |

Set requests == limits for critical workloads to get Guaranteed QoS.

---

## Probes

Probes tell Kubernetes whether a container is healthy. There are three types:

### Liveness probe

Is the container alive? If this fails, restart the container.

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30   # wait 30s before first check (startup time)
  periodSeconds: 10         # check every 10s
  failureThreshold: 3       # restart after 3 consecutive failures
```

### Readiness probe

Is the container ready to receive traffic? If this fails, remove the pod from the Service's endpoints (stop sending traffic to it) — but do NOT restart it.

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
```

Use a different endpoint for readiness than liveness. `/ready` might check database connectivity; `/health` just checks if the process is alive.

### Startup probe

For slow-starting containers. Replaces liveness during startup to avoid premature restarts.

```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8000
  failureThreshold: 30      # allow up to 30 * 10s = 5 minutes to start
  periodSeconds: 10
```

---

## Summary

- StatefulSets for stateful apps: stable identity, ordered start/stop, per-pod storage.
- DaemonSets for node-level agents: one pod per node.
- Jobs for one-off tasks; CronJobs for scheduled tasks.
- ConfigMaps for non-sensitive config; Secrets for sensitive data.
- Always set resource requests and limits — it enables proper scheduling and QoS.
- Liveness probes restart unhealthy containers; readiness probes control traffic.
