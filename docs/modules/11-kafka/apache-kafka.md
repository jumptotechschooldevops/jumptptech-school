---
title: "Understanding Kafka Architecture, Schema Registry, ksqlDB, PostgreSQL, Couchbase, and Microservices"
description: "Modern companies (Uber, Lyft, Airbnb, Amazon) need:   real-time data historical data fast..."
published: 2025-11-21
source: "https://dev.to/jumptotech/apache-kafka-1mi3"
tags: []
---

# Understanding Kafka Architecture, Schema Registry, ksqlDB, PostgreSQL, Couchbase, and Microservices






Modern companies (Uber, Lyft, Airbnb, Amazon) need:

* real-time data
* historical data
* fast decisions
* scalable architecture

No single database solves everything.
No single service can handle high traffic.

So companies combine:

✔ Kafka (real-time messages)
✔ PostgreSQL (historical/transaction data)
✔ Couchbase (high-speed document storage)
✔ Microservices (fraud, payment, analytics)
✔ Schema Registry (data rules)
✔ ksqlDB (real-time SQL on Kafka)

Your project demonstrates exactly this.

---

# 🔥 2. Kafka Basics (Beginner Explanation)

Before touching complex things, students must understand the basic building blocks.

## ✔ Producer

Sends data to Kafka.

```
Human-readable data → Producer App → Kafka
```

## ✔ Consumer

Reads data from Kafka.

```
Kafka → Consumer App → processing
```

## ✔ Broker

A Kafka server.

## ✔ Topic

A named stream, like a folder.
Examples:

```
orders
payments
fraud-alerts
```

## ✔ Partition

A topic is split into pieces so work can be parallel.

```
Topic: orders
P0 | P1 | P2 | P3
```

## ✔ Offset

Line number inside a partition.

```
P0:
 offset 0
 offset 1
 offset 2
```

## ✔ Consumer Group

Multiple consumers share work.

---

# 🔥 3. Serialization and Deserialization (Very Simple)

Kafka stores **bytes**, not objects.

* Serialization: object → bytes
* Deserialization: bytes → object

JSON serializer/deserializer:

✔ easy to understand
✔ no schema registry needed
✔ slow & big messages

Avro serializer/deserializer:

✔ compact
✔ faster
✔ works with Schema Registry
✔ required in large companies

---

# 🔥 4. Schema Registry — What It REALLY Does

Your students always get confused here.

### ❌ Schema Registry does NOT:

* read data
* serialize data
* talk to Kafka
* transform data
* send data

### ✔ Schema Registry DOES:

* stores the **schema**
* enforces **rules**
* provides **schema IDs** to producers/consumers
* checks compatibility during schema evolution

It is a **schema database**, nothing more.

### Why we did NOT need it in the project?

Because we used JSON:

```python
json.dumps(order)
```

Both producer and consumer understand JSON → no schema registry needed.

Schema Registry is only required if:

✔ Avro
✔ Protobuf
✔ JSON Schema

is used.

---

# 🔥 5. Why did we include Schema Registry in docker-compose?

Because:

* ksqlDB requires Schema Registry **if** VALUE_FORMAT=Avro
* Kafka Connect uses Schema Registry **if Avro converters enabled**
* It is part of the Confluent platform
* It prepares you for real-world projects

But in **your project**, we used **JSON everywhere**, so Schema Registry was not used by your microservices.

Only ksqlDB and Kafka Connect referenced it.

---

# 🔥 6. Where ksqlDB Fits (The Students MUST Understand This!)

### ksqlDB is a **special consumer** + **special producer**.

It reads data from Kafka streams:

```
Kafka → ksqlDB (reads JSON orders)
```

Then it writes new streams/tables back to Kafka:

```
ksqlDB → order-analytics topic
```

### It does NOT store data permanently.

It creates:

* streams
* tables
* materialized views
* aggregations
* windows

This is **real-time SQL** on Kafka.

---

# 🔥 7. Why PostgreSQL Is In The Project

Students must understand:

Kafka is **real-time only**.
Kafka is not a database.

Kafka does not store:

* long-term historical data
* customer identity
* profile information
* payment history
* fraud history

Postgres does.

**PostgreSQL = historical or OLTP database.**

In your project:

* Postgres simulates a legacy Oracle DB
* Kafka Connect JDBC Source reads old customer/order history
* It pushes that historical data into Kafka for real-time processing

Because your microservices need BOTH:

### ✔ Old data (history) → from Postgres

### ✔ New events → from Kafka

This is exactly what Uber, Lyft, Amazon, Walmart, Netflix do.

---

# 🔥 8. Why Does Kafka “read” PostgreSQL?

Kafka does NOT read Postgres directly.
Kafka Connect does.

**Why?**

To unify:

* legacy old data
* new real-time data

Into one stream for:

* fraud detection
* payment validation
* analytics
* personalization
* machine learning

### Final goal:

**Your microservice can compare OLD behavior with NEW events.**

Example:

* Postgres: old 100 rides history
* Kafka: new ride request
* Fraud service: compares old behavior vs new request

---

# 🔥 9. Why Couchbase?

Couchbase is used for:

* fast document storage
* analytics
* dashboards
* near real-time views

Kafka → Couchbase Sink Connector writes:

```
order-analytics → Couchbase bucket
```

This powers dashboards like:

* orders per country
* fraud events
* payment status
* customer activity

---

# 🔥 10. Connecting Everything (Beautiful Diagram for Students)

```
     HUMAN REQUEST (New Ride)
               |
               v
          Producer
    (generates JSON order)
               |
               v
-------------------------------------
|            KAFKA                 |
| Topic: orders                    |
| Partitions: P0, P1, P2           |
-------------------------------------
               |
               v
     Fraud Service (reads Kafka)
               |
               v
     Payment Service (reads Kafka)
               |
               v
  Analytics Service (reads Kafka)
               |
               v
   Couchbase (stores real-time data)

-------------------------------------
|   Legacy Ride History (Old Data)  |
|        PostgreSQL Database        |
-------------------------------------
               |
               v
     Kafka Connect (JDBC Source)
               |
               v
   Kafka Topic: legacy_orders
               |
               v
       ksqlDB (joins old+new)
               |
               v
   order-analytics topic
               |
               v
      Couchbase Dashboard
```

---



### ✔ Kafka handles NEW events

Ride requests from users in real time.

### ✔ PostgreSQL stores OLD events

Customer’s past ride history.

### ✔ Kafka Connect JDBC Source

Moves old DB data → Kafka for real-time use.

### ✔ ksqlDB

Processes streams, aggregates, and writes new topics.

### ✔ Couchbase

Stores analytics and dashboard data.

### ✔ Microservices (fraud, payment, analytics)

Consume the streams and act on them.

### ✔ Serialization

We used JSON, so we did NOT need Avro or Schema Registry.

### ✔ Schema Registry

Is useful only when using Avro or Protobuf.


