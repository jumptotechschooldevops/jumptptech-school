---
title: "production-style, fully working MySQL StatefulSet (primary + replicas) with headless + ClusterIP"
description: "0) Folder structure (clean, production-friendly)      mysql-statefulset-prod/  ..."
published: 2026-01-22
source: "https://dev.to/jumptotech/production-style-fully-working-mysql-statefulset-primary-replicas-with-headless-clusterip-1a8o"
tags: []
---

# production-style, fully working MySQL StatefulSet (primary + replicas) with headless + ClusterIP





## 0) Folder structure (clean, production-friendly)

```bash
mysql-statefulset-prod/
  00-namespace.yaml
  01-secrets.yaml
  02-configmap-mysql.yaml
  03-headless-svc.yaml
  04-statefulset.yaml
  05-service-write.yaml
  06-service-read.yaml
  07-pdb.yaml
  08-networkpolicy.yaml
  09-hpa-note.md
  10-verify.sh
```


## 1) Namespace

**00-namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: db
```

Why:

* Isolation (RBAC, policies, quotas).
* Clear ownership for platform vs app teams.

Apply:

```bash
kubectl apply -f 00-namespace.yaml
```

---

## 2) Secrets (no passwords in YAML)

**01-secrets.yaml**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: db
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: "ChangeMeRoot#123"
  MYSQL_REPL_PASSWORD: "ChangeMeRepl#123"
```

Why:

* Credentials shouldn’t live in ConfigMap.
* `stringData` is human-friendly; API stores base64.

Apply:

```bash
kubectl apply -f 01-secrets.yaml
```

---

## 3) ConfigMap: MySQL config + init SQL

**02-configmap-mysql.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: db
data:
  primary.cnf: |
    [mysqld]
    server-id=1
    log-bin=mysql-bin
    binlog_format=ROW
    gtid_mode=ON
    enforce_gtid_consistency=ON
    log_replica_updates=ON

  replica.cnf: |
    [mysqld]
    read_only=ON
    super_read_only=ON
    relay-log=relay-bin
    gtid_mode=ON
    enforce_gtid_consistency=ON

  init.sql: |
    -- create replication user (root only runs this on first init)
    CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY '${MYSQL_REPL_PASSWORD}';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
    FLUSH PRIVILEGES;

    CREATE DATABASE IF NOT EXISTS appdb;
```

Why:

* Primary and replica need different DB settings.
* init SQL runs once on new volume.
* `server-id` must be unique per pod (we’ll set dynamically too).

Apply:

```bash
kubectl apply -f 02-configmap-mysql.yaml
```

---

## 4) Headless Service (mandatory for StatefulSet DNS)

**03-headless-svc.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  namespace: db
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
```

Why (production reason):

* Headless gives stable DNS per pod:

  * `mysql-0.mysql-headless.db.svc.cluster.local`
  * `mysql-1.mysql-headless...`
* Without this, StatefulSet loses its key benefit (stable network identity).
* Services do **not** “store pod IPs”; they select by labels (endpoints are created dynamically).

Apply:

```bash
kubectl apply -f 03-headless-svc.yaml
```

---

## 5) StatefulSet (the core)

**04-statefulset.yaml**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: db
spec:
  serviceName: mysql-headless
  replicas: 3
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
        tier: database
    spec:
      terminationGracePeriodSeconds: 60

      securityContext:
        fsGroup: 999

      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: mysql
              topologyKey: kubernetes.io/hostname

      initContainers:
      - name: init-mysql
        image: mysql:8.0
        command:
          - bash
          - -lc
          - |
            set -e
            ORDINAL=$(hostname | awk -F'-' '{print $NF}')
            if [ "$ORDINAL" = "0" ]; then
              cp /config/primary.cnf /etc/mysql/conf.d/server.cnf
            else
              cp /config/replica.cnf /etc/mysql/conf.d/server.cnf
            fi

            # ensure unique server-id per pod
            echo "" >> /etc/mysql/conf.d/server.cnf
            echo "server-id=$((100 + ORDINAL))" >> /etc/mysql/conf.d/server.cnf
        volumeMounts:
        - name: config
          mountPath: /config
        - name: conf
          mountPath: /etc/mysql/conf.d

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
        - name: MYSQL_REPL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_REPL_PASSWORD
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        - name: initdb
          mountPath: /docker-entrypoint-initdb.d

        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "1"
            memory: "1Gi"

        readinessProbe:
          exec:
            command:
              - bash
              - -lc
              - "mysqladmin ping -uroot -p$MYSQL_ROOT_PASSWORD"
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 6

        livenessProbe:
          exec:
            command:
              - bash
              - -lc
              - "mysqladmin ping -uroot -p$MYSQL_ROOT_PASSWORD"
          initialDelaySeconds: 60
          periodSeconds: 20
          timeoutSeconds: 5
          failureThreshold: 3

      - name: replication-sidecar
        image: mysql:8.0
        command:
          - bash
          - -lc
          - |
            set -e

            ORDINAL=$(hostname | awk -F'-' '{print $NF}')
            if [ "$ORDINAL" = "0" ]; then
              echo "Primary pod: no replica setup needed."
              sleep infinity
            fi

            # wait for mysql to be ready
            until mysqladmin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; do
              echo "waiting for local mysql..."
              sleep 3
            done

            # try to configure replication from mysql-0
            PRIMARY_HOST="mysql-0.mysql-headless.db.svc.cluster.local"

            # If already configured, this is idempotent enough for lab.
            mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
              STOP REPLICA;
              RESET REPLICA ALL;
              CHANGE REPLICATION SOURCE TO
                SOURCE_HOST='${PRIMARY_HOST}',
                SOURCE_USER='repl',
                SOURCE_PASSWORD='${MYSQL_REPL_PASSWORD}',
                SOURCE_AUTO_POSITION=1;
              START REPLICA;
            " || true

            echo "Replica configured (or attempted)."
            sleep infinity
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_REPL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_REPL_PASSWORD

      volumes:
      - name: config
        configMap:
          name: mysql-config
      - name: initdb
        configMap:
          name: mysql-config
          items:
          - key: init.sql
            path: init.sql
      - name: conf
        emptyDir: {}

  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

Why each “production” part matters:

* **PVC per pod**: each MySQL has its own disk (StatefulSet guarantee).
* **Headless + serviceName**: stable DNS identities required for replication.
* **initContainer**: sets primary vs replica config based on ordinal.
* **unique server-id**: required for MySQL replication.
* **probes**: keeps traffic away until DB is ready; restarts stuck DB.
* **resources**: prevents noisy neighbor and OOM surprises.
* **anti-affinity**: spreads pods across nodes when possible.
* **sidecar**: auto-configures replicas to follow mysql-0 (simple approach for lab/demo).

Apply:

```bash
kubectl apply -f 04-statefulset.yaml
```

---

## 6) ClusterIP “write” Service (goes only to primary)

**05-service-write.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-write
  namespace: db
spec:
  type: ClusterIP
  selector:
    app: mysql
    statefulset.kubernetes.io/pod-name: mysql-0
  ports:
  - port: 3306
    targetPort: 3306
```

Why:

* In production you usually want a **stable write endpoint** that never load-balances to replicas.
* This selector targets **only mysql-0**.

Apply:

```bash
kubectl apply -f 05-service-write.yaml
```

---

## 7) ClusterIP “read” Service (load-balances across replicas)

**06-service-read.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  namespace: db
spec:
  type: ClusterIP
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

Important production note:

* This selects **all** pods (including mysql-0).
* If you want “replicas only”, you must label replicas (or use separate selector). For a skeleton, we keep it simple and you can teach both options.

Apply:

```bash
kubectl apply -f 06-service-read.yaml
```

---

## 8) PodDisruptionBudget (avoid losing quorum during maintenance)

**07-pdb.yaml**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: mysql-pdb
  namespace: db
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: mysql
```

Why:

* During node drain/upgrade, Kubernetes won’t evict too many DB pods.

Apply:

```bash
kubectl apply -f 07-pdb.yaml
```

---

## 9) NetworkPolicy (lock down DB)

**08-networkpolicy.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mysql-allow-from-app
  namespace: db
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: app
    ports:
    - protocol: TCP
      port: 3306
```

Why:

* “Default deny” style: only allow traffic from your app namespace.
* DevOps must ensure CNI supports NetworkPolicy.

Apply:

```bash
kubectl apply -f 08-networkpolicy.yaml
```

(If you don’t use networkpolicies in your cluster, skip this file.)

---

## 10) Verification (how to “see everything”)

**10-verify.sh**

```bash
#!/usr/bin/env bash
set -e

kubectl -n db get all
echo "----"
kubectl -n db get pvc
echo "----"
kubectl -n db get pods -o wide
echo "----"
kubectl -n db get svc
echo "----"
kubectl -n db get endpoints mysql-headless
echo "---- DNS check ----"
kubectl -n db run dns-test --rm -it --image=busybox:1.36 --restart=Never -- \
sh -c "nslookup mysql-0.mysql-headless.db.svc.cluster.local && nslookup mysql-headless.db.svc.cluster.local"
```

Run:

```bash
chmod +x 10-verify.sh
./10-verify.sh
```

How to prove write vs read (clean demo):

```bash
# open mysql client pod
kubectl -n db run mysql-client --rm -it --image=mysql:8.0 --restart=Never -- bash

# write to primary service
mysql -h mysql-write -uroot -pChangeMeRoot#123

USE appdb;
CREATE TABLE IF NOT EXISTS test (id INT);
INSERT INTO test VALUES (1),(2);
SELECT @@hostname;   -- shows mysql-0
exit

# read from read service
mysql -h mysql-read -uroot -pChangeMeRoot#123 -e "USE appdb; SELECT * FROM test; SELECT @@hostname;"
# run multiple times: hostname may vary (load balancing)
```

---

## Headless vs ClusterIP in production (simple rule)

* **Headless**: for **stateful identity** and **pod-level DNS** (replication, sharding, membership, stable endpoints).
* **ClusterIP**: for **a stable virtual endpoint** (write endpoint, read endpoint, app traffic, service discovery).

In real prod:

* You almost always use **both** for stateful DB patterns.

---

## Where DevOps must pay attention (production checklist)

1. **Failover reality**

* This skeleton has **mysql-0 as primary** (fixed).
* In real prod you need **automated failover** (e.g., Orchestrator / MHA / InnoDB Cluster / operator).

2. **Backups**

* StatefulSet ≠ backup.
* You need scheduled logical/physical backups + restore tests.

3. **Storage class + IO**

* DB performance is storage-bound. Know the StorageClass, IOPS, volume expansion, encryption.

4. **Rolling updates**

* Updating MySQL image can break replication or cause downtime.
* Control surge/unavailable (StatefulSet behavior differs from Deployments).

5. **Probes and startup**

* If probes are too aggressive, you get CrashLoopBackOff for DB warmup.

6. **Security**

* Secrets rotation, least-privilege, NetworkPolicy, TLS in transit (not included here), audit.

7. **Resource sizing**

* CPU/memory requests must match real workload; OOM on DB is common.

8. **Pod disruption & node drains**

* Without PDB, upgrades drain too many DB pods.


