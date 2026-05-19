---
title: "Kafka"
description: "Apache Kafka is an open-source distributed event-streaming platform.  Let’s break this into simple..."
published: 2025-11-18
source: "https://dev.to/jumptotech/kafka-c7h"
tags: []
---

# Kafka




Apache Kafka is an **open-source distributed event-streaming platform**.

Let’s break this into simple words:

### **Event Streaming**

This refers to two activities:

1. **Producing events** (sending continuous data/messages)
2. **Consuming events** (reading and processing the data continuously)

Example:
Imagine PayTM (payment app). Every time a user:

* Pays someone
* Books a ticket
* Recharges mobile

An **event** is created.
Millions of users create **millions of events per second**.

All these events are **streamed to Kafka** in real-time.

Then, another application (consumer) reads these events from Kafka. For example:

* Check if a user exceeded daily transaction limits
* Detect fraud
* Send notifications

So, event streaming = **continuous sending + continuous processing**.

---

## **2. Why is Kafka called distributed?**

“Distributed” means Kafka runs on **multiple servers** across different regions.
Kafka clusters usually have:

* Multiple **brokers** (servers)
* Multiple machines
* Replicas of data

Why?

* To avoid downtime
* To balance load
* To improve scalability

If one server fails, another one continues serving requests.

---

## **3. Where does Kafka come from?**

* Kafka was originally developed at **LinkedIn**.
* Open-sourced in **2011**.
* Now part of **Apache Software Foundation**.

---

## **4. Why do we need Kafka? (The Letterbox Example)**

### **Without Kafka (Problem)**

Application A wants to send data to Application B.

But:

* What if Application B is offline?
* What if network is slow?
* What if Application B crashes?

Data will be lost.

This is just like:
A postman bringing a parcel when you are NOT home → parcel lost.

---

### **With Kafka (Solution)**

Kafka becomes a **letterbox** between A and B.

Application A → (sends data) → **Kafka**
Application B → (reads data later) → **Kafka**

Even if B is offline, messages stay safe in Kafka until B reads them.

Kafka guarantees that:

* No data is lost
* Data is stored safely
* Producer and consumer do NOT need to be online at same time
* System is decoupled
* Scaling becomes easy

---

## **5. Why Kafka is important for microservices?**

Imagine 4 applications want to send data to 5 other services.

### **Without Kafka**

Each service must connect directly to all other services.

This creates:

* Too many connections
* Too many protocols
* Difficult to manage schemas
* Failure of one service affects all
* 20+ connections for only 9 services

It becomes a **nightmare** to maintain.

---

### **With Kafka**

All services send and read messages from Kafka.

Only **one connection per service**:

```
Apps → Kafka → Other Apps
```

Benefits:

* Fewer connections
* Scalability
* Loose coupling
* Easy to onboard new services
* No dependency between producer and consumer

---

## **6. How Kafka works (High-level Overview)**

Kafka uses the **Pub/Sub model**:

### **3 components:**

1. **Publisher / Producer**

   * Sends messages to Kafka

2. **Broker / Messaging System**

   * Stores and manages messages
   * This is Kafka itself

3. **Subscriber / Consumer**

   * Reads messages from Kafka

Kafka acts like an **inbox** storing messages until consumers are ready to process them.

Producers and Consumers are independent:

* Producer doesn't care who consumes
* Consumer doesn't care who produces

This is the foundation of:

* Event-driven applications
* Real-time analytics
* Microservice communication
* Fraud detection
* Logging pipelines

---

# **Short Summary (Interview-Friendly)**

**Apache Kafka is a distributed event-streaming platform used to build real-time data pipelines and streaming applications. It allows producers to send continuous streams of events and consumers to read them reliably. Kafka acts as a durable, scalable, fault-tolerant messaging system, decoupling systems and preventing data loss.**






Apache Kafka Architecture & Components 

Understanding Kafka architecture means understanding **how messages flow from producers → Kafka brokers → consumers**, and how Kafka scales using **topics, partitions, offsets, consumer groups, and ZooKeeper/KRaft**.

Let’s go step-by-step.

---

# **1. Producer, Consumer, and Broker**

## **Producer**

* The **producer** is the application that **sends (publishes)** messages to Kafka.
* It does NOT send messages directly to consumers.
* It only sends data to **Kafka broker(s)**.

Example:
PayTM or Uber app sending:

* payment event
* booking event
* ride event

Producers generate unlimited, continuous streams of events.

---

## **Consumer**

* The **consumer** is the application that **reads (subscribes)** to messages from Kafka.
* It only reads from Kafka, not from other applications.

Example:
A PayTM fraud detection service consumes messages to check:

* how many transactions per user
* suspicious activity
* limit exceeded etc.

---

## **Broker (Kafka Server)**

* The **broker** is the Kafka server that stores messages.
* It receives messages from producers.
* It allows consumers to read them later.
* Broker is the **middle-man** between producer and consumer.

A single Kafka cluster can have **one or many brokers**.

---

# **2. Kafka Cluster**

A **cluster** = group of Kafka brokers working together.

Why do we need a cluster?

* To handle high volume of messages
* To spread load
* To avoid downtime if one broker fails
* To scale horizontally

Example:

```
Producer → Broker1  
Producer → Broker2  
Producer → Broker3  
```

If Broker1 fails → Broker2 and Broker3 automatically continue.

Kafka = distributed, fault-tolerant, highly scalable.

---

# **3. Topic — The “Category” of Messages**

Kafka stores messages in **topics**.

A topic is like a **folder** or **database table** where related messages are stored.

Example topics:

* `payments`
* `ticket-booking`
* `mobile-recharge`
* `orders`
* `rides`

### Why topics?

Without topics, consumers must ask:

> “Give me all payment messages… No, not these ones… No, not those types…”

That becomes chaotic.

Topics solve this by grouping messages of the same type.

### How topics work:

Producer sends:

```
(payment event) → "payments" topic
(ticket event) → "booking" topic
(recharge event) → "recharge" topic
```

Consumers simply subscribe:

* Consumer1 → “payments”
* Consumer2 → “ticket-booking”
* Consumer3 → “recharge”

This removes confusion and back-and-forth requests.

**Topics are the foundation of Kafka data organization.**

---

# **4. Partitions — Kafka Scalability Engine**

A topic may receive **millions** of messages per second.

One machine cannot handle that.

Solution: **Partition the topic.**

### **Partition = part of a topic stored on different brokers**

Example:

Topic: `payments`
Partitions:

```
Partition 0 → Broker1  
Partition 1 → Broker2  
Partition 2 → Broker3
```

Kafka distributes messages across partitions using **round-robin** (unless a key is provided).

### Benefits:

✔ Stores more data
✔ Handles high throughput
✔ Enables parallel reading by consumers
✔ Increases fault tolerance

Partitioning is one of Kafka’s biggest strengths.

---

# **5. Offset — Message Position in a Partition**

Every message inside a partition gets a **unique, increasing number** called **offset**.

Example:

```
Partition 0:
Offset 0 → Msg A
Offset 1 → Msg B
Offset 2 → Msg C
```

### Why offset is important?

Consumers use offset to know:

* which messages they already consumed
* where to continue after restart

Example:
Consumer reads offsets 0,1,2,3
Consumer crashes
When it comes back → it continues from offset 4.

Offset ensures **no message is lost** and **no message is read twice** unless you want to.

---

# **6. Consumer Group — Scaling Consumers Horizontally**

If one consumer reads ALL partitions alone — it becomes slow.

Solution:
Use **multiple consumers grouped together**.

Example:
Topic has 3 partitions:

* Partition 0
* Partition 1
* Partition 2

Create a consumer group: `payment-consumers`

Inside the group:

* Consumer1
* Consumer2
* Consumer3

Then:

```
Consumer1 → Partition 0  
Consumer2 → Partition 1  
Consumer3 → Partition 2
```

All partitions are processed **in parallel**, giving:
✔ Faster processing
✔ Higher throughput
✔ Load distribution

### Important Group Rules:

* **Partitions ≥ Consumers** → all consumers work
* **Consumers > Partitions** → extra consumers remain idle
* If a consumer fails → Kafka rebalance assigns the partition to another consumer

This balancing is called **consumer rebalancing**.

---

# **7. ZooKeeper — Kafka’s Manager (Old Architecture)**

Traditionally, Kafka used **ZooKeeper** for:

* metadata
* cluster coordination
* tracking brokers
* managing topics
* storing offsets (older versions)
* election of controller node

You can think of ZooKeeper as the **administrator** that watches the Kafka cluster.

### Note (modern Kafka):

Kafka now uses **KRaft (Kafka Raft)** mode to replace ZooKeeper.

Confluent and Kafka community are moving toward **ZooKeeper-less Kafka**.

---

# **Full Architecture Flow (Simple View)**

```
Producer → Topic → Partitions → Broker → Consumer Group → Consumers
```

---

# **Final Short Interview Summary**

Use this in interviews:

> Apache Kafka architecture consists of producers that publish messages, brokers that store them in topics, and consumers that consume them. Each topic is divided into partitions for scalability and parallelism. Messages inside partitions have sequential offsets for tracking consumption. Consumers work together inside consumer groups to share the load. Kafka clusters consist of multiple brokers for high availability. ZooKeeper (or KRaft in newer versions) handles metadata, coordination, and broker management.









# **1. Kafka Distributions — What Options Exist?**

Before installing Kafka, it’s important to understand the **three different types of Kafka distributions** you will find in real-world DevOps environments.

---

## **A. Apache Kafka (Open Source)**

* Free, official Kafka maintained by Apache.
* Downloadable from the official Apache portal.
* You manage everything:

  * scaling
  * upgrades
  * monitoring
  * Zookeeper
  * scripts
* Most companies still run this version in production with their own infra teams.

Use this option if:

* You want to learn Kafka deeply
* You want full control of cluster and configs
* You’re not using Confluent’s ecosystem

---

## **B. Confluent Platform (Commercial Distribution)**

Confluent provides:

* More tools
* More utilities
* GUI
* Schema Registry
* REST Proxy
* Kafka Connect
* KSQL DB
* Monitoring tools

They also provide:

### **✔ Confluent Enterprise (Paid)**

For companies, includes advanced monitoring and enterprise features.

### **✔ Confluent Community Edition (FREE)**

Perfect for developers and students.

Use this if:

* You want schema registry, connectors, REST proxy
* You plan to practice enterprise-level Kafka features

---

## **C. Managed Kafka Services (Cloud)**

These services are hosted and managed by cloud providers:

* **Amazon MSK (Managed Streaming for Kafka)**
* **Confluent Cloud**
* **Azure HDInsight Kafka**
* **Redpanda Cloud (Kafka compatible)**

Advantages:

* No server setup
* No Zookeeper management
* Automatic scaling
* Highly reliable

Suitable for:

* Cloud-native applications
* Large-scale enterprise solutions

---

# **2. Install Apache Kafka (Open Source Version)**

### **Step 1 — Download Kafka**

Go to:

```
https://kafka.apache.org/downloads
```

Select the latest stable release:
**Kafka 3.x — Scala version 2.13 or 3.0**

Click **Binary downloads** → download the `.tgz` file (about 100 MB).

---

### **Step 2 — Extract the Folder**

Unzip/Extract:

You will see folders:

```
bin/  
config/  
libs/  
LICENSE  
README  
```

---

### **Step 3 — Understand Folder Structure**

#### **bin/**

Contains scripts to run Kafka:

| Script                      | Purpose                       |
| --------------------------- | ----------------------------- |
| `zookeeper-server-start.sh` | Start Zookeeper               |
| `kafka-server-start.sh`     | Start Kafka broker            |
| `kafka-topics.sh`           | Create / list / delete topics |
| `kafka-console-producer.sh` | Produce messages              |
| `kafka-console-consumer.sh` | Consume messages              |

There are `.sh` versions for **Mac/Linux** and `.bat` versions for **Windows**.

---

#### **config/**

Contains configuration files:

| File                   | Purpose                    |
| ---------------------- | -------------------------- |
| `server.properties`    | Kafka broker configuration |
| `zookeeper.properties` | Zookeeper configuration    |
| `producer.properties`  | Producer configs           |
| `consumer.properties`  | Consumer configs           |

You will use these later when modifying Kafka settings.

---

# **3. Install Confluent Platform (Community Edition – FREE)**

### **Step 1 — Open Confluent Website**

Go to:

```
https://www.confluent.io/get-started/
```

Click:
**Get Started Free → Download Software → Confluent Community Edition**

---

### **Step 2 — Extract the Package**

You’ll see folder structure:

```
bin/
etc/
share/
lib/
```

---

### **Step 3 — Understand Differences from Apache Kafka**

Confluent adds extra tools like:

* Schema Registry
* Kafka REST Proxy
* KSQL DB
* Kafka Connect
* Control Center (enterprise only)

Inside **etc/kafka/** you will find:

* `server.properties`
* `schema-registry.properties`
* `connect-distributed.properties`
* `ksql-server.properties`

This is why Confluent is preferred for:

* Real production streaming platforms
* ETL pipelines
* Schema-based applications

---

# **4. Install Kafka Offset Explorer (Kafka Tool)**

This is a GUI application that helps you:

* Browse topics
* View partitions
* Inspect offsets
* Monitor consumers
* View messages

### **Step 1 — Download Kafka Tool**

Search on Google:

```
Kafka Offset Explorer Download
```

Or go to:

```
https://www.kafkatool.com/
```

---

### **Step 2 — Install**

Choose your OS:

* macOS (DMG)
* Windows (.exe)
* Linux (AppImage)

Double-click → install → open.

Now you can visually explore Kafka clusters.

---

# **5. Final Software Summary**

| Software                  | Purpose                               |
| ------------------------- | ------------------------------------- |
| **Apache Kafka**          | Pure open-source Kafka                |
| **Confluent Platform**    | Enhanced Kafka with tools             |
| **Kafka Offset Explorer** | GUI for monitoring topics & consumers |











# **1. Pre-requisite**

You must complete:

✔ Kafka Architecture
✔ Kafka Components (Topic, Partition, Offset, Broker, Consumer Group, Zookeeper)

---

# **2. Kafka Workflow Overview**

The CLI workflow looks like this:

```
Start Zookeeper → Start Kafka Server → Create Topic → Define Partitions →
Start Producer → Start Consumer → Send Messages → Observe Offsets/Partitions
```

Kafka **never** allows producer and consumer to talk directly.
They always communicate **through Topics within Kafka broker**.

---

# **3. Start Your Kafka Ecosystem (Open Source Apache Kafka)**

You must start:

1. **Zookeeper**
2. **Kafka Broker**

Both exist inside the `bin/` folder of Kafka installation.

---

## **Step 1 — Start Zookeeper**

**Command:**

```bash
bin/zookeeper-server-start.sh config/zookeeper.properties
```

**Default Zookeeper port:** `2181`

Kafka CLI output will show:

```
binding to port 0.0.0.0/2181
```

Good — Zookeeper is running.

---

## **Step 2 — Start Kafka Broker**

**Command:**

```bash
bin/kafka-server-start.sh config/server.properties
```

**Default Kafka port:** `9092`

You will see output:

```
[KafkaServer id=0] started on port 9092
```

Kafka broker is successfully running.

---

# **4. Create a Topic (with Partitions & Replication Factor)**

A topic is required so producers and consumers have a communication channel.

### **Command:**

```bash
bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create \
  --topic javatechy-topic \
  --partitions 3 \
  --replication-factor 1
```

Explanation:

* `--bootstrap-server localhost:9092` = Kafka broker address
* `--partitions 3` = topic will have 3 partitions
* `--replication-factor 1` = only 1 copy (because we have only 1 broker)

---

## **List Topics**

```bash
bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
```

You will see:

```
javatechy-topic
javatechy-topic1
```

---

## **Describe Topic (View Partition Info)**

```bash
bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe \
  --topic javatechy-topic
```

Output:

* Partitions: 0, 1, 2
* Replication Factor: 1
* Leader for each partition
* ISR (In-Sync Replicas)

---

# **5. Start Producer & Consumer CLI**

Now we will test the **real Pub/Sub workflow**.

---

## **A. Start Consumer (to listen messages)**

**Command:**

```bash
bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic javatechy-topic \
  --from-beginning
```

This keeps listening for new messages.

---

## **B. Start Producer (to send messages)**

**Command:**

```bash
bin/kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic javatechy-topic
```

Now whatever you type, goes to topic → consumer reads it.

Example:
Producer:

```
hello
welcome
test message
```

Consumer receives:

```
hello
welcome
test message
```

Pub/Sub works perfectly.

---

# **6. Visualize Messages in Kafka Offset Explorer**

Kafka Offset Explorer (GUI tool) helps monitor:

* Topics
* Partitions
* Offsets
* Partition load distribution
* Consumer lag

### Steps:

1. Open Offset Explorer
2. Add a new Kafka connection

   * Name: `JT-Cluster`
   * Host: `localhost`
   * Port: `2181` (Zookeeper)
3. Connect
4. Expand → Topics → javatechy-topic
5. Open **Data** tab

   * View messages
   * Watch offsets increase
   * See which partition got which message

This helps visually understand how Kafka works internally.

---

# **7. Bulk Message Ingestion (CSV File)**

Kafka producer can send an entire CSV file as messages.

Example file: `users.csv` (1000 rows)

### **Command:**

```bash
bin/kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic javatechy-topic < /path/to/users.csv
```

This sends **each line of CSV as an individual Kafka message**.

---

## **Verify Bulk Data Distribution**

In Offset Explorer:

* Open topic → partitions → data
* Observe load balancing
* Mostly messages may go to:

  * Partition 0
  * Partition 1
  * Partition 2

Based on Kafka internal logic
(`round-robin` unless key provided)

Example distribution:

* Partition 0 → 1546 messages
* Partition 1 → 461 messages
* Partition 2 → 0 messages

Kafka decides partition assignment automatically.

---

# **8. Repeat Everything Using Confluent Community Edition**

Now start Kafka using Confluent folder.

**First stop old Kafka:**

* Stop producer
* Stop consumer
* Stop Kafka broker
* Stop Zookeeper

### Confluent folder structure:

```
bin/
etc/kafka/
```

---

## **Start Zookeeper (Confluent)**

```bash
bin/zookeeper-server-start etc/kafka/zookeeper.properties
```

---

## **Start Kafka Broker (Confluent)**

```bash
bin/kafka-server-start etc/kafka/server.properties
```

---

## **Create Topic (Confluent)**

(Same command, only paths changed)

```bash
bin/kafka-topics \
  --bootstrap-server localhost:9092 \
  --create \
  --topic new-topic1 \
  --partitions 3 \
  --replication-factor 1
```

---

## **Produce Messages (Confluent)**

```bash
bin/kafka-console-producer \
  --broker-list localhost:9092 \
  --topic new-topic1
```

---

## **Consume Messages (Confluent)**

```bash
bin/kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic new-topic1 \
  --from-beginning
```

---

## **Send Bulk CSV Again**

```bash
bin/kafka-console-producer \
  --broker-list localhost:9092 \
  --topic new-topic1 < ./users.csv
```

Check partitions → messages distributed across partition 0, 1, 2.


