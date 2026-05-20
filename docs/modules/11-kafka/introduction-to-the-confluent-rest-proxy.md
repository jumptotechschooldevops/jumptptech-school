---
title: "Introduction to the Confluent REST Proxy"
description: "1. Why Do We Need the REST Proxy?   Kafka works best with Java (JVM-based languages). Kafka..."
published: 2025-11-20
source: "https://dev.to/jumptotech/introduction-to-the-confluent-rest-proxy-1ccl"
tags: []
---

# Introduction to the Confluent REST Proxy






# **1. Why Do We Need the REST Proxy?**

Kafka works best with Java (JVM-based languages).
Kafka has clients for other languages too:

* Node.js
* Go
* Python
* C#
* Rust
* PHP

But these clients **do not always support Avro well**.
Some of them:

* cannot register schemas
* cannot handle binary Avro easily
* do not support schema evolution
* require many libraries

### The solution:

## ✔️ **Confluent REST Proxy**

It allows any application to use **simple HTTP requests** (POST, GET) to send or read Kafka messages **without writing Kafka code**.

Every language can make HTTP requests, so every language can talk to Kafka through the REST Proxy.

---

# **2. Where Does the REST Proxy Fit?**

Here is your normal system:

```
[ Java Producer ] → Kafka Cluster + Schema Registry → [ Java Consumer ]
```

Now we introduce REST Proxy:

```
[ Any Language Producer ] → HTTP → REST Proxy → Kafka → Schema Registry
```

And for consumers:

```
[ Any Language Consumer ] ← HTTP ← REST Proxy ← Kafka
```

The REST Proxy communicates with:

* Kafka brokers
* Schema Registry

It does the “Kafka work” for you.

---

# **3. What Does REST Proxy Do?**

The REST Proxy acts as a **translator**.

It allows you to:

### ✔ Produce messages to Kafka via HTTP POST

### ✔ Consume messages from Kafka via HTTP GET

### ✔ Use Avro, JSON, or raw bytes

### ✔ Automatically register schemas

### ✔ Automatically validate schemas

### ✔ Easily integrate with languages that have poor Kafka libraries

It simplifies everything.

---

# **4. Why REST Proxy Is Useful**

### ✔ Works with any programming language

All languages support HTTP calls.

### ✔ Easy to produce Avro

Even if the language has no Avro serializer.

### ✔ Automatically works with Schema Registry

Schema Registry is fully integrated.

### ✔ Easy debugging

HTTP requests are easier to test than Kafka clients.

---

# **5. What Are the Downsides?**

### ❌ It is slower than direct Kafka clients

Why?

Because:

* HTTP is slower than the Kafka wire protocol
* REST Proxy does extra work
* Messages are serialized and validated through REST Proxy first

**Performance cost:**
**3x–4x slower than normal Kafka clients**

For most use cases this is okay, but high-performance systems should use Kafka clients directly.

### ❌ Requires batching on the application side

The REST Proxy will not batch automatically.
If you want high throughput, your application must batch multiple messages together before sending.

---

# **6. REST Proxy Is Already in Your Docker Setup**

Good news:

If you're using Confluent’s Docker Compose, the REST Proxy is already available at a port like:

```
http://localhost:8082
```

So you can start using it immediately.

---

# **7. What We Will Learn in This Section**

In this REST Proxy module you will learn:

### 🔹 **How REST Proxy works internally**

* Supported endpoints
* Supported API versions
* How messages are formatted

### 🔹 **How to create topics via REST Proxy**

### 🔹 **How to produce messages**

* In binary
* In JSON
* In Avro

### 🔹 **How to consume messages**

* With different formats
* With schemas
* With offsets

### 🔹 **How to deploy and scale the REST Proxy**

* Production tips
* High availability
* Load balancing






## 1. V1 vs V2 – Which REST Proxy API Should We Use?

### 1.1 Background: Old Kafka APIs vs New Kafka APIs

A long time ago, Kafka had:

* an **old producer API**
* an **old consumer API**

These were used in Kafka **before version 0.8**.

* The **old consumer** stored offsets in **Zookeeper**.
* Then Kafka introduced a **new consumer** and **new producer** that store offsets **in Kafka itself**, not Zookeeper.

All modern code and all modern courses (including yours) use the **new producer/consumer APIs**.

---

### 1.2 How REST Proxy fits into this history

The **REST Proxy** has existed for a long time too.

* Originally, it was built on top of the **old** Kafka consumer/producer APIs.
  That version was called **V1** in the REST Proxy.
* Later, the REST Proxy was updated to use the **new** Kafka consumer/producer APIs.
  That new version is called **V2** in the REST Proxy.

So:

* **V1 REST Proxy API** → old Kafka APIs
* **V2 REST Proxy API** → new Kafka APIs (what we use today)

---

### 1.3 Which one should you use?

This part is very simple:

> **Always use V2.**
> Ignore V1.
> If you see `.../v1/...` in examples – that is legacy.

* V1 is old and will eventually disappear.
* V2 has better performance.
* V2 matches everything you already know about Kafka.

So the rule for your students:

> “If the URL says `/v1/` – don’t use it.
> In this course and in real projects, we always use `/v2/` REST Proxy APIs.”

---

## 2. REST Proxy Content-Type Header – How to Build It

When you send an HTTP request to the REST Proxy, you must set a **Content-Type** header that tells the proxy:

* what kind of Kafka data you’re sending (Avro, JSON, binary)
* which API version you’re using (V2)
* how the HTTP body itself is encoded (JSON)

There is a **pattern** for the Content-Type.

Let’s break it into 4 parts.

---

### 2.1 The 4 Parts of the Content-Type

General pattern:

```text
application/vnd.kafka.<embedded-format>.v2+json
```

Let’s understand each piece:

1. `application`
   – normal MIME type prefix.

2. `vnd.kafka`
   – means “Kafka-specific vendor type”.

3. `<embedded-format>`
   – this tells REST Proxy what **Kafka message format** you are using:

   * `json`
   * `binary`
   * `avro`

4. `.v2`
   – REST Proxy API version. We use **v2** only.

5. `+json`
   – this tells REST Proxy that the **HTTP body** is encoded as JSON text.

---

### 2.2 Some concrete examples

#### Example 1: JSON messages

You want to send **JSON messages** to Kafka via V2:

```http
Content-Type: application/vnd.kafka.json.v2+json
```

* Kafka message format: `json`
* REST Proxy API version: `v2`
* HTTP body format: JSON (`+json`)

---

#### Example 2: Avro messages

You want to send **Avro messages** to Kafka via V2:

```http
Content-Type: application/vnd.kafka.avro.v2+json
```

* Kafka message format: `avro`
* REST Proxy version: `v2`
* HTTP body format: JSON (`+json`)

The *payload* is described in JSON, but REST Proxy converts it to **Avro** using Schema Registry.

---

#### Example 3: Binary messages

You want to send **raw binary** data:

```http
Content-Type: application/vnd.kafka.binary.v2+json
```

---

### 2.3 Easy way to remember

Just memorize this template:

```text
application/vnd.kafka.<json|avro|binary>.v2+json
```

And remember:

* Always use `.v2` → because we use V2 API.
* Always end with `+json` → because the HTTP request body is JSON.
* Change only the `<embedded-format>` to: `json`, `avro`, or `binary`.

---

## 3. Quick Summary

* Kafka used to have old APIs; REST Proxy V1 was built on top of those.
* New Kafka APIs → REST Proxy V2 → this is what we use today.
* **Always use V2 REST Proxy endpoints.**
* REST Proxy Content-Type follows a pattern:

  ```text
  application/vnd.kafka.<embedded-format>.v2+json
  ```

  where `<embedded-format>` = `json`, `avro`, or `binary`.










