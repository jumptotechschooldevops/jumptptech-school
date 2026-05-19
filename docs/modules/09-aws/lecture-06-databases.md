# Lecture 6 · Databases — RDS, Aurora, ElastiCache & DynamoDB

AWS offers managed database services for relational, in-memory, and NoSQL workloads. Managed means AWS handles provisioning, patching, backups, and failover — you focus on schema design and queries.

---

## RDS (Relational Database Service)

RDS runs managed relational databases. Supported engines:

- PostgreSQL
- MySQL
- MariaDB
- Oracle
- Microsoft SQL Server
- IBM Db2

You cannot SSH into an RDS instance or access the underlying OS — AWS manages it.

### Multi-AZ

Multi-AZ creates a **synchronous standby replica** in a different AZ. It is for availability, not performance — you cannot read from the standby.

```
Primary DB (us-east-1a)
    ↕ synchronous replication
Standby DB (us-east-1b)   ← no reads here
```

During failover (primary fails), RDS automatically updates the DNS endpoint to point to the standby. Failover takes 60–120 seconds. Your connection will drop briefly; use connection retry logic in your application.

```bash
aws rds create-db-instance \
  --db-instance-identifier my-postgres \
  --db-instance-class db.t3.medium \
  --engine postgres \
  --master-username admin \
  --master-user-password "$(aws secretsmanager get-random-password --output text)" \
  --allocated-storage 20 \
  --multi-az \
  --backup-retention-period 7 \
  --storage-encrypted
```

### Read Replicas

Read replicas use **asynchronous replication** and are used for offloading read traffic, not for failover.

- Up to 15 read replicas per primary
- Replicas can be in different regions (cross-region read replica)
- Replicas can be promoted to standalone instances (for migrations or DR)
- You must point your application to the replica endpoint — replication is not transparent

```
Primary DB ──async──► Read Replica 1 (same region)
          └──async──► Read Replica 2 (eu-west-1)
```

### Backups

- **Automated backups**: daily full backup + transaction logs. Retained for 1–35 days. Point-in-time recovery to any second within the retention window.
- **Snapshots**: manual, retained until deleted. Survive DB deletion (unless you choose not to).

Restore creates a new DB instance — it does not restore in-place.

### RDS Proxy

RDS Proxy sits between your application and RDS, pooling and sharing database connections. Reduces connection overhead for workloads with many short-lived connections (Lambda functions, serverless).

---

## Aurora

Aurora is AWS's cloud-native relational database engine, compatible with PostgreSQL and MySQL. It is not a managed RDS engine — it's a redesigned storage system.

### Architecture

Aurora separates compute (instances) from storage. The storage layer:
- 6 copies of data across 3 AZs automatically
- Self-healing: continuously scans for errors and repairs
- Grows automatically in 10 GB increments, up to 128 TB

```
Writer instance (us-east-1a)
Reader instance 1 (us-east-1b)   ── all share the same
Reader instance 2 (us-east-1c)      storage layer
```

### Endpoints

- **Cluster endpoint** — always points to the writer instance
- **Reader endpoint** — load-balances reads across all reader instances
- **Instance endpoints** — direct connection to specific instance

### Aurora vs RDS PostgreSQL

| | RDS PostgreSQL | Aurora PostgreSQL |
|--|--------------|-----------------|
| Storage | Single AZ (Multi-AZ is separate instance) | 6 copies, 3 AZs automatically |
| Read replicas | Up to 15 | Up to 15 (lower replication lag) |
| Failover | 60–120 seconds | ~30 seconds |
| Cost | Lower | ~20% more than RDS |
| Max storage | 64 TB | 128 TB |
| Replication lag | Up to minutes | Typically milliseconds |

### Aurora Serverless v2

Aurora Serverless v2 scales ACUs (Aurora Capacity Units) automatically within a configured min/max range — fractions of a second response time to traffic changes. 

```bash
aws rds create-db-cluster \
  --db-cluster-identifier my-serverless \
  --engine aurora-postgresql \
  --engine-version 15.4 \
  --serverless-v2-scaling-configuration MinCapacity=0.5,MaxCapacity=128 \
  --enable-http-endpoint  # Data API for HTTP-based SQL queries
```

Use Serverless v2 for: variable workloads, dev/test environments, SaaS with per-tenant databases.

### Aurora Global Database

Replicates an Aurora cluster to up to 5 secondary regions with < 1 second replication lag. Used for global reads and cross-region DR. Failover to a secondary region is manual but takes < 1 minute.

---

## ElastiCache

ElastiCache provides managed in-memory caching. Two engines:

### Redis

- Data structures: strings, hashes, lists, sets, sorted sets, bitmaps, streams
- Persistence: RDB snapshots + AOF (append-only file)
- Replication: primary + up to 5 read replicas
- Cluster mode: shard data across multiple nodes (millions of ops/second)
- Pub/sub messaging
- Lua scripting, transactions

### Memcached

- Simple key-value only
- Multi-threaded (better CPU utilisation on multi-core)
- No persistence, no replication
- Auto-discovery of nodes

### When to use which

| Requirement | Use |
|-------------|-----|
| Session store | Redis |
| Real-time leaderboards (sorted sets) | Redis |
| Pub/sub | Redis |
| Complex data types | Redis |
| Maximum throughput, simple cache | Memcached |
| Multi-threaded scaling | Memcached |

### Caching patterns

**Lazy loading (cache-aside)**:
1. Application checks cache
2. Cache miss → fetch from DB, store in cache, return
3. Cache hit → return immediately

Stale data possible. Populate cache only with data actually requested.

**Write-through**:
1. Application writes to DB
2. Also writes to cache at the same time

Cache always has fresh data. Cache may hold data never read (wasteful).

**TTL**: Always set a Time-To-Live on cached items to prevent stale data accumulating indefinitely.

---

## DynamoDB

DynamoDB is a fully managed, serverless, key-value and document database. It delivers single-digit millisecond performance at any scale with no capacity planning.

### Data model

Every table requires a **primary key**:

- **Simple primary key**: just a Partition Key (hash key)
- **Composite primary key**: Partition Key + Sort Key (range key)

| Attribute | Type | Role |
|-----------|------|------|
| UserId (PK) | String | Partition key — determines which partition stores the item |
| Timestamp (SK) | String | Sort key — items with same PK are sorted by this |
| Email | String | Non-key attribute |

Items in a partition are stored and retrieved together. Choose a partition key with high cardinality to distribute data evenly across partitions. A bad partition key (e.g., `status` with only 3 values) creates hot partitions that throttle.

### Capacity modes

**On-demand**: Pay per request. DynamoDB instantly accommodates any traffic level. Best for unpredictable workloads.

**Provisioned**: Specify Read Capacity Units (RCU) and Write Capacity Units (WCU). More cost-effective for predictable traffic. Enable auto-scaling to adjust capacity automatically.

- 1 RCU = 1 strongly consistent read of up to 4 KB per second (or 2 eventually consistent reads)
- 1 WCU = 1 write of up to 1 KB per second

### Read consistency

- **Eventually consistent**: default, cheapest, may return stale data for a fraction of a second after a write
- **Strongly consistent**: always returns the latest data, costs 2x, not available for global tables

### Global Secondary Indexes (GSI)

Let you query on non-primary-key attributes. A GSI has its own partition key and optional sort key.

```
Table: Orders
  PK: OrderId
  SK: CustomerId
  
GSI: CustomerOrders
  PK: CustomerId
  SK: OrderDate
  → Query all orders by a customer, sorted by date
```

You can have up to 20 GSIs per table. GSIs have their own throughput settings.

### Local Secondary Indexes (LSI)

Same partition key as the table but a different sort key. Must be created at table creation time. Maximum 5 per table.

### DynamoDB Streams

Captures a time-ordered log of all changes (insert, update, delete) to a table. Items stay in the stream for 24 hours. Commonly used to:

- Trigger Lambda functions on data changes
- Replicate data to other systems
- Implement event sourcing

### DynamoDB Accelerator (DAX)

In-memory cache for DynamoDB with microsecond read latency. API-compatible — you point your application at the DAX cluster instead of DynamoDB. No code changes beyond the endpoint.

Use DAX when you need sub-millisecond reads for hot items (popular product pages, leaderboards).

### DynamoDB Global Tables

Multi-region, active-active replication. You write to any region and changes propagate to all other regions within seconds. Last-writer-wins conflict resolution.

Use for: low-latency global access, cross-region DR without manual failover.

---

## Choosing the right database

| Use case | Service |
|---------|---------|
| Relational data, complex queries, ACID | RDS (PostgreSQL recommended) |
| Relational, high performance, enterprise features | Aurora |
| Key-value, session storage, high-throughput, unlimited scale | DynamoDB |
| In-memory cache, real-time leaderboards | ElastiCache (Redis) |
| Simple cache, multi-threaded | ElastiCache (Memcached) |
| Data warehouse, analytical queries (OLAP) | Redshift |
| Graph data | Neptune |
| Time-series | Timestream |

!!! tip "Exam tip"
    Multi-AZ = high availability (failover). Read Replicas = scalability (read throughput). They serve different purposes. A common wrong answer is "use a read replica for DR" — you'd use Multi-AZ for that.

!!! tip "Exam tip"
    Aurora has storage that replicates across 3 AZs automatically — this is distinct from Multi-AZ in RDS. With Aurora, even a "single-AZ" cluster has resilient storage; Multi-AZ in Aurora means having read replicas in multiple AZs for compute-layer HA.

!!! tip "Exam tip"
    DynamoDB on-demand vs provisioned: if the question mentions unpredictable traffic spikes, on-demand. If the question mentions "cost-optimisation for steady-state traffic," provisioned with auto-scaling.
