---
title: "StatefulSet project"
description: "0) Full production architecture (end-to-end)            Data flow +..."
published: 2026-01-18
source: "https://dev.to/jumptotech/statefulset-project-2p09"
tags: []
---

# StatefulSet project


# 0) Full production architecture (end-to-end)

### Data flow + responsibilities 

```
[Users/Clients]
      |
      v
[App/API Pods]  (App team owns code, DB queries, read/write usage)
      |
      |  writes                 reads (optional)
      v                         v
[mysql-primary Service]     [mysql-replicas Service]
      |                         |
      v                         v
  mysql-0 (Primary)         mysql-1..N (Replicas)
      |                         |
  PVC data-mysql-0          PVC data-mysql-1..N
      |
      v
[PV -> Disk via StorageClass/CSI]
      |
      v
[Node / Cloud infra]
```

### The non-negotiable Kubernetes pieces

* **StatefulSet**: stable identity (`mysql-0`, `mysql-1`) + ordered lifecycle + one PVC per pod
* **Headless Service**: stable per-pod DNS (required for replication)
* **PVC/PV**: data survives pod restart (pods are disposable; disks are not)
* **InitContainer**: generates **unique `server-id`** per pod ordinal (prevents replication failure)
* **Services for apps**: control write traffic to primary (and optionally read traffic to replicas)

---

# 1) Team structure + who does what (production reality)

## Platform / SRE team (cluster owners)

**Owns:**

* Kubernetes cluster lifecycle (upgrades, node pools)
* CSI storage driver (EBS CSI / etc), StorageClasses
* Cluster security baseline (PodSecurity, admission policies)

**DevOps depends on them for:**

* “PVC attaches reliably”
* “DNS resolves reliably”
* “Nodes are healthy”

---

## DevOps team (you, the integrator)

**Owns:**

* Workload manifests (StatefulSet, Services, namespaces)
* initContainers, config patterns, labels/selectors correctness
* Secrets integration (ideally External Secrets)
* Observability setup (metrics, logs, dashboards, alerts)
* Runbooks + incident playbooks
* Release process / change management for manifests (GitOps / CI/CD)

**DevOps must pay attention to:**

* Service selectors (misrouting = data loss risk)
* Storage settings (RWO, disk size, expansion policy)
* Rolling updates safety for databases
* Backups/restore plan and testing
* Replication health signals and lag

---

## DBA / Data team (database correctness owners)

**Owns:**

* Replication design, consistency, MySQL settings
* Schema migrations and migration sequencing
* Query performance, indexes, slow queries
* Data retention, compliance rules

**DevOps provides platform; DBA validates correctness.**

---

## Application team (business logic owners)

**Owns:**

* How the application uses DB (read/write separation)
* Connection pooling, retry logic, timeouts
* Migration coordination with DBAs/DevOps
* Data model & query patterns

---

# 2) Lab project skeleton 

Create this folder:

```
mysql-statefulset-primary-replica-lab/
├── README.md
├── k8s/
│   ├── 00-namespace.yaml
│   ├── 01-headless-service.yaml
│   ├── 02-secret.yaml
│   ├── 03-statefulset.yaml
│   ├── 04-service-primary.yaml
│   ├── 05-service-replicas.yaml        # optional (recommended for teaching)
│   └── 06-client-pod.yaml
└── scripts/
    ├── 01-primary-setup.sql
    ├── 02-replica-setup.sql            # contains placeholders; students fill file/pos
    ├── 03-validate.sql
    └── 04-health-check.sh
```

---

# 3) Kubernetes manifests (copy/paste exactly)

## k8s/00-namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: database
```

**Why DevOps cares:** isolation, RBAC, quotas, backup scope.

---

## k8s/01-headless-service.yaml (mandatory)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  namespace: database
spec:
  clusterIP: None              # KEY: headless => per-pod DNS, no load-balancing
  selector:
    app: mysql
  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
```

**Behavior:** creates DNS names like:

* `mysql-0.mysql-headless.database.svc.cluster.local`
* `mysql-1.mysql-headless.database.svc.cluster.local`

**DevOps attention:** if you forget `clusterIP: None`, you lose per-pod identity and replication becomes unreliable.

---

## k8s/02-secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: database
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: root
  REPLICATION_USER: repl
  REPLICATION_PASSWORD: replpass
```

**DevOps attention (production):** don’t store real secrets in Git. Use Vault / AWS Secrets Manager + External Secrets Operator.

---

## k8s/03-statefulset.yaml (final working version you used)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: database
spec:
  serviceName: mysql-headless
  replicas: 2
  selector:
    matchLabels:
      app: mysql

  template:
    metadata:
      labels:
        app: mysql
    spec:
      # initContainer generates per-pod MySQL config from pod ordinal
      initContainers:
        - name: init-mysql-config
          image: busybox:1.36
          command:
            - sh
            - -c
            - |
              set -e
              ORDINAL="${HOSTNAME##*-}"        # mysql-0 => 0, mysql-1 => 1
              SERVER_ID=$((ORDINAL + 1))       # mysql-0 => 1, mysql-1 => 2

              # Create a config file inside a writable volume (emptyDir)
              echo "[mysqld]" > /work/server.cnf
              echo "server-id=${SERVER_ID}" >> /work/server.cnf

              if [ "$ORDINAL" = "0" ]; then
                # Primary: write binlogs for replication
                echo "log-bin=mysql-bin" >> /work/server.cnf
                echo "binlog_format=ROW" >> /work/server.cnf
                echo "binlog-do-db=appdb" >> /work/server.cnf
              else
                # Replicas: enforce read-only
                echo "read-only=ON" >> /work/server.cnf
                echo "super-read-only=ON" >> /work/server.cnf
                echo "relay-log=relay-log" >> /work/server.cnf
              fi

              echo "Generated config for ${HOSTNAME}:"
              cat /work/server.cnf
          volumeMounts:
            - name: mysql-config
              mountPath: /work

      containers:
        - name: mysql
          image: mysql:8.0
          ports:
            - containerPort: 3306
              name: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_ROOT_PASSWORD
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql          # DB data directory (goes to PVC)
            - name: mysql-config
              mountPath: /etc/mysql/conf.d       # MySQL reads *.cnf from here

      volumes:
        - name: mysql-config
          emptyDir: {}                            # writable config volume

  volumeClaimTemplates:
    - metadata:
        name: data
    spec:
      accessModes: ["ReadWriteOnce"]              # critical for block disks like EBS
      resources:
        requests:
          storage: 5Gi
```

**Behavior to teach:**

* StatefulSet creates pods in order: `mysql-0` then `mysql-1`
* Creates PVC per pod: `data-mysql-0`, `data-mysql-1`
* On pod deletion, pod comes back with same name and same PVC

**DevOps attention:**

* `server-id` must be unique (you saw replication fail when it wasn’t)
* Binlog settings must exist on primary
* Read-only must exist on replicas (safety)

---

## k8s/04-service-primary.yaml (write traffic goes here)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-primary
  namespace: database
spec:
  selector:
    statefulset.kubernetes.io/pod-name: mysql-0   # pin writes to mysql-0 only
  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
```

**Behavior:** app connects to `mysql-primary` for writes.

**DevOps attention:** selector mistakes here can send writes to replicas or load balance across pods = dangerous.

---

## k8s/05-service-replicas.yaml (optional, for reads)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-replicas
  namespace: database
spec:
  selector:
    app: mysql
  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
```

 this service includes primary too because of the shared label. For real production, you’d add labels like `role=primary/replica` and select only replicas.

---

## k8s/06-client-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-client
  namespace: database
spec:
  containers:
    - name: client
      image: mysql:8.0
      command: ["sh", "-c", "sleep 3600"]
```

---

# 4) Apply the lab (students do in order)

From inside the project folder:

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-headless-service.yaml
kubectl apply -f k8s/02-secret.yaml
kubectl apply -f k8s/03-statefulset.yaml
kubectl apply -f k8s/04-service-primary.yaml
kubectl apply -f k8s/05-service-replicas.yaml
kubectl apply -f k8s/06-client-pod.yaml
```

Verify:

```bash
kubectl get pods -n database
kubectl get pvc -n database
```

Expected:

* Pods: `mysql-0`, `mysql-1`, `mysql-client`
* PVCs: `data-mysql-0`, `data-mysql-1`

---

# 5) Replication setup scripts (students run)

## scripts/01-primary-setup.sql

```sql
-- Create app database (binlog-do-db references this)
CREATE DATABASE IF NOT EXISTS appdb;

-- MySQL 8 note:
-- caching_sha2_password can require TLS/public key; in labs we switch to mysql_native_password
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;

SHOW MASTER STATUS;
```

Run it:

```bash
kubectl exec -it mysql-0 -n database -- mysql -h 127.0.0.1 -uroot -proot < scripts/01-primary-setup.sql
```

**DevOps attention:** capture `File` and `Position` from output. This is where students must learn “copy the exact values”.

---

## scripts/02-replica-setup.sql (students must fill FILE/POS)

```sql
STOP SLAVE;
RESET SLAVE ALL;

-- Replace MYSQL_BIN_FILE and MYSQL_BIN_POS with values from SHOW MASTER STATUS
CHANGE MASTER TO
  MASTER_HOST='mysql-0.mysql-headless.database.svc.cluster.local',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpass',
  MASTER_LOG_FILE='MYSQL_BIN_FILE',
  MASTER_LOG_POS=MYSQL_BIN_POS;

START SLAVE;
SHOW SLAVE STATUS\G;
```

Run it after editing file/pos:

```bash
kubectl exec -it mysql-1 -n database -- mysql -h 127.0.0.1 -uroot -proot < scripts/02-replica-setup.sql
```

Expected:

* `Slave_IO_Running: Yes`
* `Slave_SQL_Running: Yes`
* `Seconds_Behind_Master: 0`

---

## scripts/03-validate.sql

```sql
USE appdb;
CREATE TABLE IF NOT EXISTS replication_test (
  id INT PRIMARY KEY,
  msg VARCHAR(50)
);

INSERT INTO replication_test VALUES (1, 'written_on_primary');
SELECT * FROM replication_test;
```

Write on primary:

```bash
kubectl exec -it mysql-0 -n database -- mysql -h 127.0.0.1 -uroot -proot < scripts/03-validate.sql
```

Read from replica:

```bash
kubectl exec -it mysql-1 -n database -- mysql -h 127.0.0.1 -uroot -proot -e "USE appdb; SELECT * FROM replication_test;"
```

**Replica write should fail (safety test):**

```bash
kubectl exec -it mysql-1 -n database -- mysql -h 127.0.0.1 -uroot -proot -e "USE appdb; INSERT INTO replication_test VALUES (2,'should_fail');"
```

Expected error:

* `read-only` / `super-read-only` prevents the write

---

## scripts/04-health-check.sh (quick checks without entering mysql>)

```bash
#!/usr/bin/env bash
set -euo pipefail

NS=database

echo "Pods:"
kubectl get pods -n "$NS"

echo
echo "PVCs:"
kubectl get pvc -n "$NS"

echo
echo "Server IDs:"
kubectl exec mysql-0 -n "$NS" -- mysql -h 127.0.0.1 -uroot -proot -e "SHOW VARIABLES LIKE 'server_id';"
kubectl exec mysql-1 -n "$NS" -- mysql -h 127.0.0.1 -uroot -proot -e "SHOW VARIABLES LIKE 'server_id';"

echo
echo "Replication health (mysql-1):"
kubectl exec mysql-1 -n "$NS" -- mysql -h 127.0.0.1 -uroot -proot -e "SHOW SLAVE STATUS\G" | egrep "Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Last_IO_Error"
```

Run:

```bash
bash scripts/04-health-check.sh
```

---

# 6) Behavior demos (what students should observe)

## A) StatefulSet identity

* Delete pod:

  ```bash
  kubectl delete pod mysql-0 -n database
  ```
* It comes back as **mysql-0** (same name).
* Data persists because PVC persists.

## B) PVC lifecycle

* Pods are cattle; PVC is the real “data”
* `data-mysql-0` stays even if `mysql-0` is deleted.

## C) DNS identity (headless)

From mysql-client:

```bash
kubectl exec -it mysql-client -n database -- sh
nslookup mysql-0.mysql-headless
nslookup mysql-1.mysql-headless
```

## D) Common “DevOps mistakes” you already saw

* Using socket connection → fails in containers → use TCP (`-h 127.0.0.1`)
* MySQL 8 auth plugin requiring secure connection → use `mysql_native_password` for labs or configure TLS
* Duplicate `server-id` → replication stops → solve via ordinal-based initContainer

---

# 7) What DevOps must pay attention to (production checklist)

### Networking

* DNS must be reliable (CoreDNS health)
* Headless service must exist and match `serviceName` in StatefulSet
* Services selectors must be correct (misrouting writes is catastrophic)

### Storage

* Correct StorageClass
* RWO vs RWX
* Disk growth plan (volume expansion)
* Backups + restore testing

### Reliability

* Replication lag alerts (`Seconds_Behind_Master`)
* Restart behavior (pod delete test)
* Node failure and volume reattach behavior

### Security

* Secrets management (external secrets, rotation)
* NetworkPolicy (limit who can connect to MySQL)
* TLS for replication/clients in real prod

### Change management

* Schema migrations coordination (app + DBA + DevOps)
* Safe rollouts (avoid unsafe changes to DB config mid-flight)

---

# 8) How teams collaborate on changes (typical workflow)

Example: “We need to scale replicas and add read service”

1. **App team** requests read scaling due to load
2. **DBA** confirms replica strategy & read consistency requirements
3. **DevOps** updates manifests (replica service selectors, scaling rules)
4. **SRE/Platform** verifies storage/network capacity
5. **DevOps + DBA** validate replication health post-change
6. **SRE** monitors incidents/lag after rollout

---

# 9)  “what to create where” 

1. Create folder `mysql-statefulset-primary-replica-lab/`
2. Create `k8s/` and paste each YAML file
3. Create `scripts/` and paste each script/SQL
4. Apply manifests
5. Run primary SQL → copy file/pos
6. Run replica SQL → verify status
7. Run validation tests


