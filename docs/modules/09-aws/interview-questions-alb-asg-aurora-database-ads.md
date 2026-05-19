---
title: "interview questions: alb, asg, aurora, database, ads"
description: "1️⃣ IP Address            What is IP?   IP (Internet Protocol) address is a unique..."
published: 2026-02-17
source: "https://dev.to/jumptotech/interview-questions-alb-asg-aurora-database-ads-3g16"
tags: []
---

# interview questions: alb, asg, aurora, database, ads





# 1️⃣ IP Address

### What is IP?

IP (Internet Protocol) address is a unique identifier assigned to a device on a network.

Example:

* `192.168.1.10` (Private)
* `18.221.32.84` (Public)

### Types:

* **IPv4** – 32-bit (most common)
* **IPv6** – 128-bit

### Interview Q&A

**Q: What is the difference between public and private IP?**
A: Public IP is reachable over the internet. Private IP is used inside internal networks (VPC, office LAN).

**Q: Can two servers have same IP?**
A: Not in the same network. It causes IP conflict.

---

# 2️⃣ Port

### What is a Port?

Port is a logical communication endpoint on a machine.

Examples:

* 80 → HTTP
* 443 → HTTPS
* 22 → SSH
* 3306 → MySQL

### Interview Q&A

**Q: What is the difference between IP and port?**
A: IP identifies the machine. Port identifies the application on that machine.

---

# 3️⃣ Protocol

A protocol is a set of rules for communication.

Examples:

* HTTP
* HTTPS
* FTP
* TCP
* UDP

**Q: What is TCP vs UDP?**
A: TCP is reliable (connection-based). UDP is faster but connectionless.

---

# 4️⃣ Internet

The Internet is a global network of interconnected networks using TCP/IP protocol suite.

---

# 5️⃣ Virtual Machine (VM)

A Virtual Machine is a software-based computer that runs on a physical machine.

Examples:

* AWS EC2
* VMware
* VirtualBox

In AWS:
EC2 = virtual server.

**Q: Difference between VM and container?**
A: VM has full OS. Container shares host OS kernel.

---

# 6️⃣ SSD vs HDD

## HDD (Hard Disk Drive)

![Image](https://images.openai.com/static-rsc-3/lQZWhqlMluGR96C53miTu-aJDCEBjX4LbE9IMDDuNaUBaMXASh__seq-jKhhFcOLkQl08vlsWVEJCKuf_VyQ9g3KEMvJyO7fJo7c29M_L8I?purpose=fullsize\&v=1)

![Image](https://images.openai.com/static-rsc-3/8250YPWCCZ-lS-G_66DlskUNDL0PlWdOG1gv_ACGsAvZi3JcKItTc4WYjAcc8_KkdQ8K3kXesNg7bL6L-HFWYxyL0np2YmWJTtNbvWG0-BI?purpose=fullsize\&v=1)

![Image](https://images.openai.com/static-rsc-3/t1cTzyQXuOQRtLlis5Yi1zsxPovl1KZHA8MKjpQtyvArRgx0sS5_GJuGLlAs9AwKJyloMVht3FDXcuK9tEPzmllNBO7f86ZYVo6gNC7KlpM?purpose=fullsize\&v=1)

* Mechanical
* Slower
* Cheaper
* Moving parts

## SSD (Solid State Drive)

![Image](https://images.openai.com/static-rsc-3/ddYbtiiyojDmEiTThfB7e7gLqCZOg8SyvC5qbnRTSuW-S6wW4rdV5-VEgS3hPfkCNPtbCoAvW_TqVsCr5uVmmbbKYIogkR344U42ShdMlRg?purpose=fullsize\&v=1)

![Image](https://images.openai.com/static-rsc-3/Brv3VP_lThLQ0-K1Ipe3HsaKf5iOYk8dJu5Eaux88gA1skEAEL0naB7kUzlz6zOUBGNND78H59M-ZFC6Xtm1uB_5wS2clW9DQZ_HdqbzsyM?purpose=fullsize\&v=1)

![Image](https://d6okerqgsqwys.cloudfront.net/cdn/gen/1204219/1_hewlett-packard-hp-_n09761-001_ntJrPc_800x800.jpg)

* No moving parts
* Much faster
* More expensive
* Used in cloud

**Q: Why SSD is better for databases?**
A: Faster IOPS and lower latency.

---

# 7️⃣ Types of Disks (Cloud / AWS Example)

* **EBS** – Block storage
* **EFS** – File storage
* **S3** – Object storage

Disk Types:

* Magnetic
* SSD
* NVMe
* Network Attached

---

# 8️⃣ Temporary IP

Also called:

* Dynamic IP
* Ephemeral IP

In AWS:

* Public IP changes when EC2 stops/starts
* Elastic IP stays fixed

---

# 9️⃣ DNS (Domain Name System)

DNS converts domain names into IP addresses.

Example:
google.com → 142.250.190.78

**Q: Why do we need DNS?**
A: Humans remember names, not IP addresses.

---

# 🔟 DHCP (Dynamic Host Configuration Protocol)

Automatically assigns:

* IP
* Gateway
* DNS

Used in:

* Home routers
* Corporate networks

---

# 1️⃣1️⃣ SSH (Secure Shell)

Port: 22
Used to securely connect to servers.

Example:

```bash
ssh ubuntu@18.221.32.84
```

**Q: Is SSH encrypted?**
A: Yes.

---

# 1️⃣2️⃣ TLS / SSL

TLS = Transport Layer Security
SSL = Old version

Used in:

* HTTPS
* Secure communication

**Q: Difference between HTTP and HTTPS?**
A: HTTPS uses TLS encryption.

---

# 1️⃣3️⃣ HTTP

HyperText Transfer Protocol

* Stateless
* Port 80

Methods:

* GET
* POST
* PUT
* DELETE

---

# 1️⃣4️⃣ OSI Model (Very Important Interview Question)

7 Layers:

1. Physical
2. Data Link
3. Network
4. Transport
5. Session
6. Presentation
7. Application

### Easy Memory Trick:

All People Seem To Need Data Processing

### Important Layers for DevOps:

* Layer 3 → IP
* Layer 4 → TCP/UDP
* Layer 7 → HTTP

**Q: At which layer does TCP work?**
A: Transport layer (Layer 4)

**Q: At which layer does IP work?**
A: Network layer (Layer 3)

---

# 🔥 Advanced DevOps Interview Questions

**1. What happens when you type google.com in browser?**
Answer:

* DNS lookup
* TCP handshake
* TLS handshake
* HTTP request
* Server response

**2. Explain 3-way TCP handshake**
SYN → SYN-ACK → ACK

**3. What is latency?**
Time taken for packet to travel.

**4. What is bandwidth?**
Amount of data that can be transferred.

**5. What is NAT?**
Network Address Translation converts private IP to public IP.

---

# 🎯 Real DevOps Scenario Question

**Q: Application not reachable. How do you troubleshoot?**

Answer steps:

1. Check DNS
2. Check security group
3. Check port open (`ss -tulnp`)
4. Check firewall
5. Check application logs
6. Check load balancer








# ✅ PART 1 — ALB (Application Load Balancer)

---

## 🔹 1. What is ALB?

**Answer:**
ALB (Application Load Balancer) distributes incoming HTTP/HTTPS traffic across multiple targets such as EC2 instances, containers, or IP addresses.
It works at **Layer 7 (Application Layer)** and supports advanced routing like path-based and host-based routing.

---

## 🔹 2. Difference between ALB and NLB?

| ALB                     | NLB                                   |
| ----------------------- | ------------------------------------- |
| Layer 7                 | Layer 4                               |
| HTTP/HTTPS              | TCP/UDP                               |
| Path-based routing      | No advanced routing                   |
| Web apps, microservices | High-performance, low latency systems |

---

## 🔹 3. What is a Target Group?

A logical group of instances or IPs where ALB sends traffic.
Health checks are configured at the target group level.

---

## 🔹 4. What is a Listener?

A process that checks for connection requests on a specific port (80, 443) and forwards traffic to target groups.

---

## 🔹 5. What is Path-Based Routing?

Routing based on URL path:

```
example.com/api → API servers
example.com/app → App servers
```

Very common in microservices architecture.

---

## 🔹 6. What is Host-Based Routing?

Routing based on hostname:

```
api.example.com → API service
app.example.com → Frontend
```

---

## 🔹 7. How does ALB perform health checks?

ALB sends periodic HTTP requests to a configured path like:

```
/health
```

If instance fails multiple checks → marked unhealthy → traffic stops.

---

## 🔹 8. What is Cross-Zone Load Balancing?

ALB distributes traffic evenly across instances in multiple Availability Zones.

Improves high availability.

---

## 🔹 9. What is Sticky Session?

Also called session affinity.

ALB forwards requests from the same client to the same instance using cookies.

Used for stateful apps.

---

## 🔹 10. What is Deregistration Delay?

When instance is removed, ALB waits (default 300 sec) before fully stopping traffic.

Prevents connection drops.

---

## 🔹 11. Why ALB returns 502?

* Application crashed
* Wrong port in target group
* Container not listening
* Security group issue

---

## 🔹 12. Why ALB returns 503?

* No healthy targets
* All instances unhealthy
* Target group empty

---

## 🔹 13. Why ALB returns 504?

* Backend timeout
* Application too slow
* Long-running query

---

## 🔹 14. How do you secure ALB?

* Attach Security Group
* Use HTTPS (ACM certificate)
* Enable WAF
* Restrict inbound traffic
* Enable access logs

---

## 🔹 15. How does ALB integrate with EKS?

* Kubernetes Ingress Controller creates ALB
* ALB routes traffic to pods via NodePort or IP targets
* Used for microservices

---

# ✅ PART 2 — ASG (Auto Scaling Group)

---

## 🔹 1. What is ASG?

ASG automatically adjusts number of EC2 instances based on load.

Ensures:

* High availability
* Fault tolerance
* Cost optimization

---

## 🔹 2. What is Launch Template?

Blueprint for EC2 instances:

* AMI
* Instance type
* Security group
* Key pair
* User data

---

## 🔹 3. What is Desired Capacity?

Number of instances ASG tries to maintain.

---

## 🔹 4. What are Min and Max size?

Minimum and maximum number of instances allowed.

Example:

```
Min: 2
Desired: 3
Max: 6
```

---

## 🔹 5. What is Scaling Policy?

Defines when to scale:

* Target tracking (CPU 70%)
* Step scaling
* Scheduled scaling

---

## 🔹 6. What metric is commonly used?

* CPUUtilization
* NetworkIn/Out
* RequestCount (via ALB)
* Custom CloudWatch metrics

---

## 🔹 7. What happens if instance becomes unhealthy?

ASG terminates it and launches a new one automatically.

---

## 🔹 8. What is Cooldown Period?

Time ASG waits after scaling event before scaling again.

Prevents rapid scaling.

---

## 🔹 9. What is lifecycle hook?

Pauses instance during launch/terminate to run custom scripts.

Used for:

* Logging
* Configuration
* Data draining

---

## 🔹 10. How ASG works with ALB?

* ASG attaches to target group
* ALB sends traffic
* If load increases → ASG launches new instance
* ALB automatically registers it

---

# ✅ PART 3 — RDS (Relational Database Service)

---

## 🔹 1. What is RDS?

Managed database service in AWS.

Supports:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server
* Aurora

---

## 🔹 2. Why use RDS instead of EC2 database?

RDS provides:

* Automatic backups
* Patching
* Monitoring
* Multi-AZ
* Failover
* Snapshots

Less operational overhead.

---

## 🔹 3. What is Multi-AZ?

RDS creates standby replica in another AZ.

If primary fails → automatic failover.

---

## 🔹 4. What is Read Replica?

Read-only copy of database.

Used to:

* Improve read performance
* Offload reporting queries

---

## 🔹 5. Difference between Multi-AZ and Read Replica?

| Multi-AZ           | Read Replica     |
| ------------------ | ---------------- |
| For HA             | For performance  |
| Automatic failover | Manual promotion |
| Synchronous        | Asynchronous     |

---

## 🔹 6. What are RDS backups?

* Automated backups (retention 1–35 days)
* Manual snapshots

---

## 🔹 7. What is RDS endpoint?

DNS address used to connect to database.

Example:

```
database-1.cchwko406tle.us-east-1.rds.amazonaws.com
```

---

## 🔹 8. How do you secure RDS?

* Place in private subnet
* Security group restrict port 3306
* Enable encryption (KMS)
* Store password in Secrets Manager

---

## 🔹 9. What causes RDS high latency?

* Slow queries
* Missing indexes
* High connections
* CPU spike
* Disk IOPS limit

---

## 🔹 10. How to troubleshoot RDS connection timeout?

* Check security group
* Check subnet routing
* Check NACL
* Check if public access enabled
* Check port

---

# ✅ PART 4 — Aurora

---

## 🔹 1. What is Aurora?

AWS high-performance relational database compatible with MySQL and PostgreSQL.

---

## 🔹 2. Why Aurora is faster?

* Distributed storage
* 6 copies across 3 AZs
* Auto scaling storage
* Optimized engine

---

## 🔹 3. Difference between RDS MySQL and Aurora?

| RDS MySQL              | Aurora             |
| ---------------------- | ------------------ |
| Traditional engine     | Cloud-native       |
| Storage manual scaling | Auto-scaling       |
| Slower replication     | Faster replication |

---

## 🔹 4. What is Aurora cluster?

Consists of:

* 1 writer instance
* Multiple reader instances
* Shared distributed storage

---

## 🔹 5. What is Aurora endpoint types?

* Cluster endpoint (writer)
* Reader endpoint
* Custom endpoint

---

## 🔹 6. What is Aurora Serverless?

On-demand auto-scaling database.

Scales automatically based on load.

---

# ✅ PART 5 — Advanced Scenario Questions

---

## 🔹 Scenario 1

Application crashes when scaling.

What do you check?

* Health check path
* User data script
* Instance logs
* CPU spike
* Memory usage

---

## 🔹 Scenario 2

High database CPU.

What do you check?

* Slow query log
* Index usage
* Connection count
* Long transactions

---

## 🔹 Scenario 3

ALB healthy but users can’t access.

Check:

* Security groups
* Route table
* Internet Gateway
* DNS

---

## 🔹 Scenario 4

ASG not scaling.

Check:

* CloudWatch alarm
* Scaling policy
* Metric threshold
* Launch template validity


