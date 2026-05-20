---
title: "KAFKA REAL-TIME MICROSERVICES PROJECT"
description: "Kafka is a real-time event streaming platform.           Think of Kafka like:    A post office for..."
published: 2025-11-18
source: "https://dev.to/jumptotech/kafka-real-time-microservices-project-c70"
tags: []
---

# KAFKA REAL-TIME MICROSERVICES PROJECT



Kafka is a **real-time event streaming platform**.

### Think of Kafka like:

* A **post office** for microservices
* Services send messages → Kafka stores them
* Other services read messages whenever they want

### Kafka is used for:

* Realtime payments
* Fraud detection
* Analytics
* Logs & monitoring
* Order processing (Amazon, Walmart)
* Ride events (Uber)
* Video playback events (Netflix)

Kafka lets **systems talk with each other without calling each other directly**.

This is called **event-driven microservices**.

---

# 🧠 **PART 2 — Kafka Components (simple)**

### 1️⃣ **Producer**

Sends events into Kafka.

### 2️⃣ **Topic**

Kafka folder where messages are stored.
Example: `orders`

### 3️⃣ **Partitions**

Topic is split for speed.
More partitions = more performance.

### 4️⃣ **Consumer**

Reads messages from the topic.

### 5️⃣ **Consumer Group**

Multiple services reading the same topic.

### 6️⃣ **Broker**

Kafka server itself.

### 7️⃣ **Zookeeper**

Keeps Kafka metadata. Required for older Kafka versions.

### 8️⃣ **Kafdrop (UI tool)**

Lets you visualize topics & messages.

---

# 🧠 **PART 3 — Why companies use Kafka**

### ✔ Decouples microservices

Producer doesn’t know consumers.

### ✔ High throughput

Millions of messages per second.

### ✔ Real-time

Processing happens instantly.

### ✔ Reliability

Messages are never lost.

### ✔ Scalability

Add more consumers — works instantly.

---

# 🧠 **PART 4 — Install & Run Kafka Using Docker Compose**

### 🔥 You do NOT install Kafka manually — we use Docker.

### Create project folder

```
mkdir kafkaproject
cd kafkaproject
```

### Create `docker-compose.yaml`

Paste the **working final version**:

```yaml
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    ports:
      - "9092:9092"
      - "29092:29092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,PLAINTEXT_HOST://0.0.0.0:29092
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zookeeper

  kafdrop:
    image: obsidiandynamics/kafdrop
    ports:
      - "9000:9000"
    environment:
      KAFKA_BROKERCONNECT: "kafka:9092"
    depends_on:
      - kafka
```

### Start everything

```
docker-compose up -d
```

### Verify containers

```
docker ps
```

You should see **Kafka, Zookeeper, and Kafdrop** running.

### Open UI:

👉 [http://localhost:9000](http://localhost:9000)

---

# 🧠 **PART 5 — Create a Python Virtual Environment**

Inside `kafkaproject`:

```
python3 -m venv venv
source venv/bin/activate
pip install kafka-python
```

---

# 🧠 **PART 6 — Build Microservices**

Create 4 files:

---

## 1️⃣ **order_producer.py**

```python
import json
import random
import time
from kafka import KafkaProducer

producer = KafkaProducer(
    bootstrap_servers="localhost:29092",
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

products = ["laptop", "mouse", "keyboard", "monitor", "headset"]
cities = ["Chicago", "New York", "Dallas", "San Jose", "Seattle"]

print("🚀 Order Producer Started...")

while True:
    order = {
        "order_id": random.randint(1000, 9999),
        "product": random.choice(products),
        "amount": round(random.uniform(100, 2000), 2),
        "city": random.choice(cities),
    }
    print("➡️ Producing:", order)
    producer.send("orders", order)
    time.sleep(1)
```

Run:

```
python3 order_producer.py
```

Your Kafdrop UI will show messages.

---

## 2️⃣ **payments_service.py**

```python
import json
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    "orders",
    bootstrap_servers="localhost:29092",
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
    enable_auto_commit=True,
)

print("💳 Payments Service Started...")

for msg in consumer:
    order = msg.value
    print(f"[PAYMENTS] Charging customer ${order['amount']} for {order['product']} from {order['city']}")
```

Run:

```
python3 payments_service.py
```

---

## 3️⃣ **fraud_service.py**

```python
import json
from kafka import KafkaConsumer

HIGH_RISK_CITIES = {"Seattle", "Dallas"}
AMOUNT_THRESHOLD = 1500

consumer = KafkaConsumer(
    "orders",
    bootstrap_servers="localhost:29092",
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
)

print("🕵️ Fraud Service Started...")

for msg in consumer:
    order = msg.value

    if order["amount"] > AMOUNT_THRESHOLD or order["city"] in HIGH_RISK_CITIES:
        print(f"🚨 FRAUD ALERT: {order}")
    else:
        print(f"[FRAUD] OK → {order}")
```

Run:

```
python3 fraud_service.py
```

---

## 4️⃣ **analytics_service.py**

```python
import json
from kafka import KafkaConsumer
from collections import defaultdict

consumer = KafkaConsumer(
    "orders",
    bootstrap_servers="localhost:29092",
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
)

sales = defaultdict(int)

print("📊 Analytics Service Started...")

for msg in consumer:
    order = msg.value
    sales[order["product"]] += 1
    print("📈 Live Sales Count:", dict(sales))
```

Run:

```
python3 analytics_service.py
```

---

# 🧠 **PART 7 — What Tools We Used & Why**

| Tool               | Why                            |
| ------------------ | ------------------------------ |
| **Kafka**          | Real-time messaging            |
| **Zookeeper**      | Manages Kafka metadata         |
| **Kafdrop**        | Web UI to see messages         |
| **Docker Compose** | Runs full Kafka cluster easily |
| **Python**         | Build microservices            |
| **Kafka-python**   | Kafka client library           |
| **Virtualenv**     | Clean Python environment       |

This setup is **exactly** what real companies use.

---

# 🧠 **PART 8 — How to Delete Everything & Start Fresh**

```
docker-compose down -v
rm -rf kafkaproject
```


