---
title: "Why We Need Schema Registry in Kafka"
description: "1. The Big Picture: Who is Who?   Think of your system like this:    Kafka → the messaging..."
published: 2025-11-20
source: "https://dev.to/jumptotech/why-we-need-schema-registry-in-kafka-3gek"
tags: []
---

# Why We Need Schema Registry in Kafka



## 1. The Big Picture: Who is Who?

Think of your system like this:

* **Kafka** → the messaging backbone (stores and streams bytes).
* **Avro** → the data format (how we structure and type those bytes).
* **Schema Registry** → the brain for Avro schemas (stores and validates schemas).
* **Confluent Platform / Confluent Cloud** → the ecosystem that provides:

  * Kafka brokers
  * Schema Registry
  * REST Proxy
  * Kafka Connect
  * Control Center UI
  * Extra tooling

So the connection is:

> **Producers and consumers send Avro messages into Kafka,
> but they rely on Schema Registry to agree on the schema.
> All of this typically runs inside Confluent Platform or Confluent Cloud.**

---

## 2. Architecture: How They Talk to Each Other

Imagine this diagram in your head:

```text
         +------------------------+
         |   Schema Registry      |
         | (stores Avro schemas)  |
         +-----------+------------+
                     ^
                     |
   +-----------------+-----------------+
   |                                   |
+--+---------+                   +-----+---------+
| Producer   |                   |   Consumer    |
| (Avro)     |                   |   (Avro)      |
+--+---------+                   +------+--------+
   |                                       ^
   | KafkaAvroSerializer                   | KafkaAvroDeserializer
   |                                       |
   v                                       |
+--+---------------------------------------+--+
|                Kafka Cluster               |
|             (topics = bytes)               |
+--------------------------------------------+
```

Key ideas:

* Producer and consumer both talk to:

  * **Kafka** (for data)
  * **Schema Registry** (for schemas)
* Kafka only stores and moves **bytes**.
* Schema Registry knows:

  * which schema ID belongs to which schema
  * which version is compatible
  * which subject (topic-value / topic-key) uses which schema

---

## 3. Data Flow: End-to-End Story

Let’s walk through one message.

### Step 1: Producer starts

Producer has:

* Avro schema (e.g., `OrderCreated`)
* Data object (e.g., `{order_id: 1, amount: 55.0, ...}`)

### Step 2: Producer talks to Schema Registry

1. Producer checks if this schema is already registered for the subject:

   * e.g., `orders-value`
2. If schema is new:

   * Producer registers it via Schema Registry REST API.
   * Schema Registry assigns a `schema_id` (integer).
3. If schema exists:

   * Schema Registry returns existing `schema_id`.

### Step 3: Producer serializes data with Avro

The Avro serializer creates a payload like:

```binary
[ magic_byte = 0 ][ schema_id ][ avro_serialized_payload ]
```

* `magic_byte` is always 0 (used to identify Confluent wire format)
* `schema_id` is 4 bytes (int)
* `avro_serialized_payload` is the compact binary representation of the data

Producer then sends this byte array to **Kafka** on topic `orders`.

### Step 4: Kafka just stores bytes

Kafka:

* writes bytes to the `orders` topic
* replicates them
* manages offsets
* does not interpret the Avro data at all

### Step 5: Consumer reads from Kafka

1. Consumer receives the same bytes:

   * `magic_byte + schema_id + payload`
2. KafkaAvroDeserializer:

   * Reads `schema_id`
   * Calls Schema Registry: "Give me schema for ID = X"
   * Uses that schema to decode the binary payload
3. Consumer code finally sees a typed object:

   * e.g., in Java: a `GenericRecord` or a specific class
   * in Python: dict-like structure

That’s the **connection**: Avro + Kafka + Schema Registry.

---

## 4. Configuration: How They Connect in Code

I’ll show a generic **Java-style** configuration – concept is the same for all languages.

### Producer config

```properties
bootstrap.servers=localhost:9092

key.serializer=org.apache.kafka.common.serialization.StringSerializer
value.serializer=io.confluent.kafka.serializers.KafkaAvroSerializer

schema.registry.url=http://localhost:8081
```

Here is the connection:

* `bootstrap.servers` → connects to Kafka
* `KafkaAvroSerializer` → tells producer to use Avro + Schema Registry
* `schema.registry.url` → tells serializer where to find schema registry

### Consumer config

```properties
bootstrap.servers=localhost:9092
group.id=order-analytics-group

key.deserializer=org.apache.kafka.common.serialization.StringDeserializer
value.deserializer=io.confluent.kafka.serializers.KafkaAvroDeserializer

schema.registry.url=http://localhost:8081
specific.avro.reader=true
```

Connections:

* KafkaAvroDeserializer talks to:

  * Kafka (to get bytes)
  * Schema Registry (to get schema from schema_id)

---

## 5. How Confluent Platform Ties It All Together

In a typical **docker-compose** for Confluent, you’ll have services like:

* `zookeeper` (older setups)
* `kafka` (broker)
* `schema-registry`
* `connect` (Kafka Connect)
* `control-center`
* `kafkarest` or `rest-proxy` (optional)
* your `producer` / `consumer` containers

Minimal idea:

```yaml
services:
  kafka:
    image: confluentinc/cp-kafka:...
    ports:
      - "9092:9092"

  schema-registry:
    image: confluentinc/cp-schema-registry:...
    ports:
      - "8081:8081"
    environment:
      SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: PLAINTEXT://kafka:9092
      SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081
```

Notice the connection here:

* Schema Registry needs to talk to Kafka too (it stores its metadata in Kafka internal topics).
* Your apps connect to:

  * `kafka:9092`
  * `schema-registry:8081`

---

## 6. Where DevOps Fits In (Your Role)

As a DevOps engineer, you care about:

1. **Provisioning** this stack

   * Docker Compose
   * Kubernetes (Helm charts)
   * Confluent Cloud (managed)

2. **Configuration**

   * Kafka bootstrap servers
   * Schema Registry URLs
   * Security (SASL, TLS, API keys)
   * Compatibility levels (backward / full)

3. **Observability**

   * Monitor Kafka brokers
   * Monitor Schema Registry
   * Watch for serialization/deserialization errors
   * Track schema evolution

4. **Governance**

   * Enforce schema compatibility in CI/CD
   * Block breaking schema changes
   * Version schemas in Git

So, **“connection master”** for DevOps means:

> You understand how to wire:
> configs → Avro SerDe → Schema Registry → Kafka → Confluent ecosystem
> and how to keep everything stable when schemas evolve.







## **1. Why this topic matters**

Apache Kafka is one of the best platforms for real-time data streaming.
But **Kafka has one big limitation**:

> **Kafka does NOT understand your data.**
> Kafka only sees **bytes**.

Because of this, Kafka cannot verify whether your data is correct, valid, or even complete.

This becomes a big issue when your systems grow.

---

# **2. How Kafka handles data (the real truth)**

### **Producer → Kafka → Consumer**

You may think Kafka understands your messages.
But in reality:

* Producer sends **0s and 1s** (raw bytes)
* Kafka stores those bytes
* Kafka forwards those bytes to consumers
* Kafka NEVER checks:

  * data type
  * missing fields
  * renamed fields
  * JSON vs string
  * valid vs invalid data

Kafka is **purely transport**.
It does **zero validation**.

### **This is why Kafka is extremely fast (zero-copy)**

Kafka never parses your message. It doesn’t inspect it.
It literally takes bytes from producer buffers and hands them directly to consumer buffers.

This is called **zero-copy architecture**, and it is a major reason Kafka is high-performance.

---

# **3. The big problem (Why companies fail)**

Imagine you have:

* Order Service (Producer)
* Fraud Service / Analytics Service (Consumers)

If the producer suddenly sends:

* a renamed field
* a deleted field
* a different JSON structure
* wrong datatype
* wrong format

Then ALL consumers will break **immediately**.

This has happened in real companies:

* Uber
* Netflix
* PayPal

When producers change message formats, **downstream systems crash**.

This destroys real-time pipelines.

---

# **4. What do we need to fix this?**

We need:

### ✅ A **schema**

A rule that says:

* what fields exist
* what types they are
* what is required
* what is optional

### ✅ A **Schema Registry**

A service that producers/consumers check before sending/reading data.

### **Goals:**

1. Ensure data sent to Kafka is valid
2. Allow safe evolution of schemas
3. Prevent breaking consumers

---

# **5. Why can’t Kafka validate messages itself?**

You may ask:

> “Why can’t Kafka just read the data and validate it?”

Because if Kafka started parsing every message:

* it would consume CPU
* it would load data into memory
* it would slow down drastically
* it would break the zero-copy design
* Kafka throughput would collapse

Kafka was intentionally designed to **never inspect your data**.

So schema validation must be done **outside Kafka**, not inside.

---

# **6. Solution: Confluent Schema Registry**

Confluent created a service called:

### **Schema Registry**

It is a **separate component** where:

* Producers register their schema
* Consumers read schemas
* Schema Registry checks data correctness
* Schema Registry prevents incompatible schema changes

Schema Registry works with a data format called:

### **Apache Avro**

Avro supports:

* **schemas**
* **schema evolution**
* **compact, fast binary encoding**

---

# **7. How the system works (simplified)**

### **Producer workflow**

1. Producer loads schema (Avro)
2. Sends schema ID to Schema Registry
3. Schema Registry approves or rejects
4. If approved → Producer sends message to Kafka

### **Consumer workflow**

1. Consumer receives message
2. Reads schema ID
3. Fetches schema from Schema Registry
4. Decodes message safely

This ensures:

* No more breaking changes
* No more corrupted data
* No more incompatible formats

---

# **8. Why Schema Registry is critical**

Without Schema Registry:

* You can break 20 microservices with one wrong JSON field
* You can break fraud detection
* You can break real-time analytics
* You will have silent data corruption

With Schema Registry:

* You enforce data contracts
* You protect downstream consumers
* You version schemas safely
* You evolve data formats over time

---

# **9. Summary**

Kafka is fast because:

* It does **not read data**
* It does **not validate**
* It treats everything as **raw bytes**

But this creates a major risk.

**Schema Registry + Avro** solve this problem by:

* Validating data
* Controlling schema evolution
* Ensuring backward/forward compatibility
* Making producers and consumers safe
* Supporting large real-time pipelines







Below is a **clean, structured, professional lecture** rewritten from your transcript — **perfect for teaching absolute beginners** and for your DevOps/Kafka course.
This follows the same content as the video but rewritten clearly, logically, and with good explanations.

---

# **Lecture: Introduction to Apache Avro — Why Avro Exists and How It Evolved**

## **1. Why are we learning Avro?**

Before using Confluent Schema Registry, we need a **data format** that:

* supports schemas
* supports schema evolution
* is efficient and compact
* is great for streaming (Kafka)

That data format is **Apache Avro**.

But to understand why Avro matters, we need to understand how data formats evolved.

---

# **2. Evolution of Data Formats (CSV → SQL → JSON → Avro)**

## **2.1 CSV (Comma Separated Values)**

### **Example**

```
John, Doe, 25, true
Mary, Poppins, 60
```

### **Advantages**

* Easy to create
* Easy to read
* Very lightweight

### **Problems with CSV**

1. **No types**

   * Column 3 is “25” for John and “60” for Mary
   * Is it a number or a string? CSV doesn’t know.

2. **Missing data**

   * Mary has fewer columns
   * No error, no validation

3. **Ambiguity**

   * If a name contains a comma → parsing breaks
   * Column names may or may not exist

4. **Difficult for automation**

   * Every system must guess the type

CSV is simple but extremely unreliable.

---

## **2.2 Relational Tables (SQL Databases)**

Now we add **types**.

### **Example**

```sql
CREATE TABLE distributors (
    did   INTEGER,
    name  VARCHAR(40)
);
```

### **Advantages**

* Strong data types
* Schema is enforced
* Invalid data is rejected
* Columns have names → not just position-based

### **Problems**

1. **Data must be flat**

   * Tables cannot easily store nested or flexible structures.

2. **Tied to a database system**

   * Schema representation differs by vendor
   * Hard to share across languages, networks, or services
   * Requires a database driver

SQL solves typing issues but lacks flexibility and portability for streaming systems.

---

## **2.3 JSON (JavaScript Object Notation)**

JSON changed everything.

### **Example**

```json
{
  "id": 1,
  "name": "example",
  "image": {
    "url": "image.png",
    "width": 200,
    "height": 200
  }
}
```

### **Advantages**

* Supports nested structures
* Extremely flexible
* Every language can parse JSON
* Easy to share over a network
* Human-readable

### **Problems**

1. **No schema enforcement**

   * A string can become a number
   * A field can be removed or renamed
   * Consumers can break

2. **Large message size**

   * Keys ("height", "width") repeat for every record
   * Wasteful for high-volume streaming

3. **No type guarantee**

   * You must trust the producer
   * No validation built-in

JSON is flexible but unsafe for large-scale systems and streaming workloads.

---

# **3. Apache Avro — The Solution**

Avro solves all problems of CSV, SQL, and JSON.

### **Avro = JSON schema + compact binary data**

An Avro record has two parts:

1. **Schema (written in JSON)**
2. **Serialized binary payload**

### **Example of an Avro Schema**

```json
{
  "type": "record",
  "name": "User",
  "fields": [
    { "name": "username", "type": "string" },
    { "name": "age", "type": "int" }
  ]
}
```

---

# **4. Advantages of Avro**

## **4.1 Fully typed data**

The schema specifies types:

* string
* int
* float
* boolean
* arrays
* maps
* nested records
* unions

No guessing.

---

## **4.2 Compact binary format**

Only the data is sent — not repeated field names.

This makes Avro faster and much smaller than JSON.

---

## **4.3 Schema travels with data**

Data is **self-describing**.

A consumer reading a message can fetch the schema from Schema Registry and understand the message.

---

## **4.4 Language-neutral**

Because the schema is JSON and the payload is binary, data can be read in:

* Python
* Java
* Go
* Node.js
* C#
* Scala
* Rust

---

## **4.5 Schema evolution**

This is the #1 reason Kafka uses Avro.

Avro supports safe evolution:

* add fields
* remove fields
* rename fields
* change defaults

All with **backward** and **forward** compatibility rules.

This prevents breaking consumers.

---

# **5. Disadvantages of Avro**

1. **Not human-readable**

   * You need Avro tools to inspect the binary data.

2. **Some languages have limited Avro support**

   * Java is best supported
   * Others may require libraries

But these are small tradeoffs for the benefits.

---

# **6. Why Avro is used in Kafka and Confluent Schema Registry**

A key reason:

> **Confluent Schema Registry officially supports Avro.**

Also:

* Avro is optimized for streaming
* Avro is fast
* Avro is efficient for millions of messages
* Avro allows message-by-message schema compatibility
* Avro is widely used in Hadoop/Spark ecosystem

This makes it the right choice for Kafka pipelines.

---

# **7. Avro vs Protobuf vs Thrift vs Parquet**

Students often ask:
“What about Protobuf? What about Thrift? What about Parquet?”

Short answer:

* **Parquet & ORC** → columnar storage (not for streaming)
* **Protobuf & Thrift** → good, but Schema Registry support is limited
* **Avro** → best for Kafka streaming + official Schema Registry support

For streaming pipelines, **Avro is ideal**.

You don’t need to stress about performance.
Even large systems (millions of msgs/sec) use Avro without issues.

---

# **Summary**

### **Why Avro?**

Because in streaming systems:

* data must be typed
* schema must be versioned
* messages must be lightweight
* schema must be shared
* changes must not break consumers

Avro gives:

* strict typing
* schema evolution
* compact binary size
* multi-language support
* safe compatibility
* perfect integration with Schema Registry


 Understanding Avro Schemas 


Now that you understand **why Avro exists** and **why we use it in Kafka**, the next step is to learn:

* what an **Avro schema** actually looks like
* what every Avro schema **must contain**
* how schemas define **typed data**
* how schemas control **structure, rules, and evolution**

This lecture is **the real foundation** of mastering Avro.

---

# **1. What is an Avro Schema?**

An **Avro schema** is a JSON document that describes the structure of your data.

It defines:

* the **fields** in your message
* the **data types** of those fields
* the **default values**
* the **rules for compatibility**
* optional **documentation**

This schema is what makes Avro:

* typed
* safe
* evolvable
* efficient

**Without a schema, Avro does not exist.**

---

# **2. The Three Parts of an Avro Schema**

Every Avro schema for a record has **three required elements**:

### **1. type**

Defines what this schema represents.
Most Kafka messages use `"record"`.

### **2. name**

A unique name for the record (like a class name in Java).

### **3. fields**

A list of fields, their names, and their types.

---

## **Example: A simple Avro schema**

```json
{
  "type": "record",
  "name": "User",
  "namespace": "com.mycompany",
  "fields": [
    { "name": "username", "type": "string" },
    { "name": "age", "type": "int" }
  ]
}
```

Let’s break this down.

---

# **3. Schema Elements Explained**

## **3.1 type**

Must be `"record"` for structured data.

Other types exist (like enum, array, etc.) but we will cover them later.

---

## **3.2 name**

Name of the record.

* Equivalent to a class name
* Must be unique within the namespace
* Used by some naming strategies in Schema Registry

---

## **3.3 namespace**

Optional but recommended.

Helps avoid name collisions.

Example:

```
com.mycompany.serviceA
com.mycompany.serviceB
```

Just like Java packages.

---

## **3.4 fields**

This is where the structure is defined.

Each field must have:

* `"name"`
* `"type"`

Example:

```json
{ "name": "username", "type": "string" }
```

---

# **4. Supported Field Types**

Avro supports many types, but here are the basics (covered in this lecture):

### **Primitive types**

* string
* int
* long
* float
* double
* boolean
* bytes
* null

### **Complex types** (later lectures)

* record
* array
* map
* enum
* union
* fixed
* logical types (date, timestamp, uuid…)

In this lecture we focus on primitive types only.

---

# **5. Example: A Real-World Avro Schema**

Let’s take a real Kafka message example:

### JSON version

```json
{
  "order_id": 1001,
  "customer": "John Doe",
  "amount": 49.99,
  "is_vip": false
}
```

### Avro version

```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.mycompany.orders",
  "fields": [
    { "name": "order_id", "type": "int" },
    { "name": "customer", "type": "string" },
    { "name": "amount", "type": "double" },
    { "name": "is_vip", "type": "boolean" }
  ]
}
```

Notice the difference:

* JSON → flexible, no rules
* Avro → strict, typed, validated

This protects your downstream consumers.

---

# **6. Adding Documentation (Highly Recommended)**

Avro allows you to document fields.

### Example:

```json
{
  "name": "order_id",
  "type": "int",
  "doc": "Unique ID of the order"
}
```

This is perfect for large teams and microservices.

---

# **7. Default Values (Critical for Schema Evolution)**

Default values are NOT optional — they are essential for compatibility.

### Example:

```json
{
  "name": "currency",
  "type": "string",
  "default": "USD"
}
```

Why does this matter?

If a field is added later and consumers expect older messages:

* they can use the default value
* the message remains valid
* no consumer breaks

This is the basis of **backward compatibility** (future lecture).

---

# **8. Putting It All Together — Updated Schema**

```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.mycompany.orders",
  "doc": "Schema for an order creation event in our system",
  "fields": [
    {
      "name": "order_id",
      "type": "int",
      "doc": "Unique ID of the order"
    },
    {
      "name": "customer",
      "type": "string",
      "doc": "Full name of the customer"
    },
    {
      "name": "amount",
      "type": "double",
      "doc": "Total dollar amount of the order"
    },
    {
      "name": "is_vip",
      "type": "boolean",
      "doc": "Whether this customer has VIP status",
      "default": false
    }
  ]
}
```

This is a **professional** Avro schema used in real enterprise Kafka pipelines.









# **1. What is the Schema Registry?**

The **Confluent Schema Registry** is a separate service (not part of Apache Kafka itself) that stores:

* all schemas used by producers
* all schemas used by consumers
* every version of each schema
* compatibility rules for safe evolution

It acts as the **central authority** for schemas in your entire Kafka ecosystem.

### Why wasn’t this included in Apache Kafka?

Because:

* Schema handling is complex
* Different companies use different formats
* Kafka itself only deals with bytes

So Confluent (the company behind Kafka) created Schema Registry as a **separate open-source product**.

Many people call it “Kafka Schema Registry,” but technically it is a Confluent component.

---

# **2. Why Do We Need Schema Registry?**

You need Schema Registry for three important reasons:

### **Reason 1: Store and retrieve schemas**

Producers and consumers must agree on:

* field names
* field types
* schema versions

Without Schema Registry, this agreement breaks down.

---

### **Reason 2: Enforce compatibility**

Schema Registry ensures that schema evolution does **not** break:

* existing consumers
* future consumers
* applications that read older messages

It manages compatibility settings such as:

* **backward**
* **forward**
* **full**
* **none**

These rules prevent entire pipelines from breaking.

---

### **Reason 3: Reduce payload size**

Avro messages sent to Kafka only contain:

* a small **schema ID**
* the **binary-encoded payload**

The heavy JSON schema itself is stored once in the registry.

This makes messages lightweight and extremely fast.

---

# **3. How Schema Registry Interacts With Kafka**

Here’s how the architecture looks:

```
 Producer  →  Schema Registry  →  Kafka  
 Consumer  →  Schema Registry  →  Kafka
```

### Producer steps:

1. Send schema to Schema Registry (only first time)
2. Schema Registry returns a schema ID
3. Producer sends:

   * schema ID
   * Avro binary payload
     to Kafka

### Consumer steps:

1. Read schema ID from Kafka message
2. Fetch schema from Schema Registry
3. Decode Avro payload safely

Both producer and consumer talk to **Kafka AND Schema Registry**.

---

# **4. What Operations Can Schema Registry Perform?**

Schema Registry supports:

### **1. Add Schema**

A new message type is introduced.

### **2. Retrieve Schema**

Consumers fetch schemas based on schema ID or subject name.

### **3. Update Schema (Schema Evolution)**

Add fields, remove fields, or modify types — following compatibility rules.

### **4. Delete Schema**

Remove old versions or entire subjects.

All of this is done through a REST API (we will cover the REST API in a separate lecture).

---

# **5. Schema Registry UI (Hands-On Overview)**

When you open the Schema Registry UI in Confluent Control Center (or via tools like `kafk-ui`), you will see:

* Zero schemas (if starting fresh)
* List of topics
* Number of brokers
* Global compatibility settings

You can navigate into **Schema Registry** and immediately:

* view existing schemas
* register new schemas
* evolve (update) schemas
* delete schemas

---

# **6. Global Compatibility Setting**

Schema Registry has a **global compatibility level**, usually set to:

* **Backward** (default)
* **Forward**
* **Full**

### Best practice:

Set it to **FULL** for the entire registry.

This ensures:

* older consumers can still read new messages
* newer consumers can still read old messages

It protects the entire ecosystem.

Each schema (subject) can override this global setting.

---

# **7. Registering Your First Schema (UI Example)**

When creating a schema in the UI:

### Step 1 — Click “New Schema”

### Step 2 — Subject Naming

If your topic is:

```
customer-test
```

Then:

* value schema → `customer-test-value`
* key schema → `customer-test-key`

For now we create:

```
customer-test-value
```

### Step 3 — Fill in Schema Details

Example:

```json
{
  "type": "record",
  "name": "CustomerTest",
  "namespace": "example",
  "doc": "This is a test schema from the Schema Registry",
  "fields": [
    { "name": "first_name", "type": "string" },
    { "name": "age", "type": "int" },
    { "name": "height", "type": "float" }
  ]
}
```

### Step 4 — Validate → Create

Schema becomes **Version 1**.

You can see:

* fields
* documentation
* compatibility rules
* version history

---

# **8. Schema Evolution Example**

Now let’s modify the schema.

We add:

```json
{
  "name": "last_name",
  "type": "string",
  "default": "unknown",
  "doc": "Person's last name. Unknown if not provided."
}
```

Click:

* Validate
* Evolve Schema

Now the schema becomes **Version 2**.

Compatibility is maintained because:

* We added a new field
* We provided a default value

These are allowed under **full** compatibility.

You can now switch between:

* Version 1
* Version 2

And view a complete history.

---

# **9. Key Schemas**

If you wanted a schema for keys:

```
customer-test-key
```

You define a schema for the key (for example, customer ID).

We typically keep keys simple:

* string
* int
* long

Full record keys are rare but supported.

---

# **10. Why This Matters**

Now you finally see how Avro schemas are:

* created
* stored
* versioned
* evolved
* validated

This ties together everything you learned so far:

* Avro types
* Schema structure
* Evolution rules
* Compatibility rules

The Schema Registry is the **heart** of Kafka data governance.







 **Avro Console Producer & Avro Console Consumer**

*(Continuing your Schema Registry + Avro section)*

Now that you understand Avro and the Schema Registry, it’s time to learn how to **produce** and **consume Avro messages manually** using the Confluent CLI tools:

* **kafka-avro-console-producer**
* **kafka-avro-console-consumer**

These tools allow you to:

* quickly test schemas
* push Avro messages to Kafka
* validate schema correctness
* experiment with schema evolution
* troubleshoot Schema Registry issues

These tools are ideal for learning and debugging.

---

# **1. Where These Tools Come From**

These commands are included in:

* Confluent Platform binaries (installed locally), or
* The Confluent CLI container (via Docker), or
* Confluent Cloud CLI (managed)

In this example, we use Docker because it is simple and does not require installation.

---

# **2. Start the Avro CLI Environment**

Run this Docker command (from Confluent Platform image):

```bash
docker run -it --net=host confluentinc/cp-schema-registry:latest bash
```

This opens a shell **inside a container** that contains:

* kafka-avro-console-producer
* kafka-avro-console-consumer
* schema registry tools

This gives us the full environment needed to test Avro.

---

# **3. First Tool: Kafka Avro Console Producer**

This tool sends messages to Kafka **in Avro format**.

Here is the command template:

```bash
kafka-avro-console-producer \
  --broker-list localhost:9092 \
  --topic test-avro \
  --property schema.registry.url=http://localhost:8081 \
  --property value.schema='{"type":"record","name":"MyRecord","fields":[{"name":"f1","type":"string"}]}'
```

Let’s break it down:

* `--broker-list`: how to reach Kafka
* `--topic`: where to send messages
* `schema.registry.url`: where Schema Registry is running
* `value.schema`: the Avro schema you want to register + use

The schema is defined inline:

```json
{
  "type": "record",
  "name": "MyRecord",
  "fields": [
    { "name": "f1", "type": "string" }
  ]
}
```

After you run the command, you enter **interactive mode**:

```
{"f1": "value1"}
{"f1": "value2"}
{"f1": "value3"}
```

Pressing **Enter** sends each message to Kafka.

---

# **4. Checking the Results in Schema Registry UI**

Open your browser:

```
http://127.0.0.1:3030
```

You will now see:

* A **new subject**: `test-avro-value`
* Schema **Version 1**
* Field `f1` of type string

Check the topic itself:

* Topic name: `test-avro`
* Messages:

  * `{ "f1": "value1" }`
  * `{ "f1": "value2" }`
  * `{ "f1": "value3" }`

Kafka UI will also show:

* **Encoding:** Avro
* **Schema version:** V1

---

# **5. Triggering Validation Errors (Important!)**

Avro rejects invalid data **before it reaches Kafka**.

### ❌ Example 1 — Wrong field name

Input:

```
{"f2": "hello"}
```

Output error:

```
Expected field not found: f1
```

Because `f2` is not defined in the Avro schema.

---

### ❌ Example 2 — Wrong type

Input:

```
{"f1": 123}
```

Output:

```
AvroTypeException: Expected string. Got int.
```

Because the schema expects a string.

This is exactly why Avro + Schema Registry protects pipelines.

---

# **6. Kafka Avro Console Consumer**

Now you want to read the data:

```bash
kafka-avro-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic test-avro \
  --from-beginning \
  --property schema.registry.url=http://localhost:8081
```

You will see:

```
{"f1":"value1"}
{"f1":"value2"}
{"f1":"value3"}
```

The consumer:

* reads bytes from Kafka
* sees the schema ID inside the message
* fetches schema from Schema Registry
* deserializes the data
* prints JSON

Even though the data is stored in Avro binary format, the console prints JSON for readability.

---

# **7. Schema Evolution Test**

Let’s evolve the schema.

We add a new field:

```json
{"name":"f2","type":"int","default":0}
```

Here is the producer command for V2 schema:

```bash
kafka-avro-console-producer \
  --broker-list localhost:9092 \
  --topic test-avro \
  --property schema.registry.url=http://localhost:8081 \
  --property value.schema='{
    "type":"record",
    "name":"MyRecord",
    "fields":[
      {"name":"f1","type":"string"},
      {"name":"f2","type":"int","default":0}
    ]
  }'
```

Send a new message:

```
{"f1": "evolution", "f2": 1}
```

Now Schema Registry:

* Validates the schema evolution
* Registers it as **Version 2**
* Ensures backward compatibility

Kafka UI now shows:

```
{"f1":"value1"}
{"f1":"value2"}
{"f1":"value3"}
{"f1":"evolution","f2":1}
```

This proves Avro + Schema Registry compatibility enforcement works.

---

# **8. Trying a Breaking Change (Error 409)**

Let’s try to destroy the schema…

Define a new schema with **only an integer**:

```json
{"type":"int"}
```

Send:

```
1
```

Output:

```
Error registering schema:
Incompatible with earlier schema
HTTP error 409
```

This is Schema Registry protecting your system.

You **cannot** break existing consumers.




#  What Else a DevOps Engineer Must Know About Schema Registry**

You already learned:

* What Schema Registry is
* How Avro interacts with Schema Registry
* How to use console producer/consumer
* How schema evolution works

Now we will learn **only the missing pieces**, but explained in the simplest way.

---

# **1. What is a “Subject” in Schema Registry?**

When Schema Registry stores a schema, it saves it under a **subject name**.

Think of a subject like a **folder** that holds:

* version 1
* version 2
* version 3

Example:

```
orders-value
```

This is where Schema Registry stores **all versions** of the **value schema** for the topic `orders`.

You always have two possible subjects:

```
topic-name-key
topic-name-value
```

That’s it.

---

# **2. What is Compatibility? (SUPER SIMPLE)**

Compatibility decides whether Schema Registry allows a new version of a schema.

There are only 3 ideas you must understand:

### ✔ Backward compatibility (MOST COMMON)

Old messages → can still be read by new consumers.

You add a new field with a default:

```
"last_name": "unknown"
```

OK ✔ Schema Registry allows it.

---

### ✔ Forward compatibility

New messages → can be read by old consumers.

Rarely used by most teams.

---

### ✔ Full compatibility

Both backward + forward.

This is the **safest** and what many companies choose.

---

# **3. What is Schema Evolution? (Simplified)**

Schema evolution means:

> “You can change your schema later, as long as the change is safe.”

Examples of SAFE changes:

* Adding a new field with default value
* Adding documentation
* Renaming namespace

Examples of UNSAFE changes:

* Removing a field
* Changing type (string → int)
* Adding a field **without** a default

Schema Registry **stops you** from breaking production.

---

# **4. How Schema Registry Stores Schemas (Super Simple)**

Schema Registry does NOT use:

* MySQL
* MongoDB
* Files

It stores everything **inside Kafka** in a hidden topic called:

```
_schemas
```

Think of it as Schema Registry’s “database”.

That’s all.

---

# **5. Why DevOps Should Care About Schema Registry?**

As a DevOps engineer, your job is to ensure:

### ✔ Schema Registry is running

(port 8081)

### ✔ Apps can connect to it

(producer & consumer)

### ✔ Schema changes don’t break existing systems

(compatibility rules)

### ✔ There are no errors like:

* “schema is incompatible”
* “schema not found”
* “error registering schema”

### ✔ Schema Registry has backup (Kafka replication)

So you don’t lose schemas.

---

# **6. Schema Registry Errors Explained Simply**

These are the only errors you will really see:

### ❌ Error 409 – Incompatible schema

You made a breaking change.
Add a default → try again.

---

### ❌ Schema not found

App is using old schema ID.
Probably wrong topic or wrong schema.

---

### ❌ Cannot connect to Schema Registry

Port 8081 blocked, or service down.

---

### ❌ Wrong type error

Schema says “string”, but you send a number.

---

That's it.

All errors fall into these simple buckets.

---

# **7. Naming Strategy (Super Simple Explanation)**

You don’t need all strategies.
Only one is used 95% of the time:

### ✔ Default strategy (TopicNameStrategy)

This creates subjects as:

```
my-topic-key
my-topic-value
```

IGNORE the others unless you do something advanced.


