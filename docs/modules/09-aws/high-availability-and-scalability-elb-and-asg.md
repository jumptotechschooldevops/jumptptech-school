---
title: "High availability and scalability ELB and ASG"
description: "1. Scalability   Scalability means an application can handle increased load by adapting..."
published: 2025-10-08
source: "https://dev.to/jumptotech/high-availability-and-scalability-elb-and-asg-2k2d"
tags: []
---

# High availability and scalability ELB and ASG


### **1. Scalability**

Scalability means an application can handle **increased load** by adapting resources.

#### **Types of Scalability**

* **Vertical Scalability (Scale Up / Down):**

  * Increase instance size (more CPU, RAM, etc.).
  * Example: Upgrading an EC2 instance from `t2.micro` → `t2.large`.
  * Common for non-distributed systems like **databases (RDS, ElastiCache)**.
  * Limited by hardware capacity.

* **Horizontal Scalability (Scale Out / In):**

  * Add more instances to share the load.
  * Example: Add more EC2 instances behind a **Load Balancer**.
  * Common for distributed systems and web applications.
  * In AWS: use **Auto Scaling Groups**.

---

### **2. High Availability (HA)**

High availability means keeping the system **operational even if one part fails**.

* Achieved by running applications in **multiple Availability Zones (AZs)**.
* Ensures resilience to data center or zone failure.
* Example:

  * EC2 Auto Scaling Group across 2+ AZs.
  * RDS **Multi-AZ** (primary + standby replica).
* Can be:

  * **Active-Passive:** standby server takes over on failure.
  * **Active-Active:** all instances handle traffic simultaneously.

---

### **3. Scalability vs. High Availability**

| Concept               | Purpose                   | AWS Example                 |
| --------------------- | ------------------------- | --------------------------- |
| **Scalability**       | Handle increased load     | Auto Scaling (scale in/out) |
| **High Availability** | Survive component failure | Multi-AZ Deployment         |

---

### **4. Call Center Analogy**

| Concept            | Example                                       |
| ------------------ | --------------------------------------------- |
| Vertical scaling   | One operator becomes faster (junior → senior) |
| Horizontal scaling | Hire more operators                           |
| High availability  | Operators distributed in multiple cities      |








## 🧭 **What Is Load Balancing?**

**Definition:**
Load balancing is the process of **distributing incoming network traffic** across multiple backend servers (EC2 instances) to ensure **no single instance is overloaded**.

In AWS, this is handled by **Elastic Load Balancing (ELB)** — a fully managed service that automatically distributes traffic across targets such as EC2 instances, containers, IP addresses, and Lambda functions.

---

## ⚙️ **How It Works**

* Users connect to a **single endpoint** — the **load balancer’s DNS name**.
* The load balancer forwards each request to one of several **healthy backend instances**.
* Traffic is distributed based on a **routing algorithm** (round-robin, least connections, etc.).
* Health checks continuously monitor backend instances to ensure only **healthy** ones receive traffic.

---

## 🧩 **Why Use a Load Balancer**

| Benefit                        | Description                                           |
| ------------------------------ | ----------------------------------------------------- |
| **Single Access Point**        | Users access your app through one endpoint (DNS).     |
| **Fault Tolerance**            | Automatically removes unhealthy instances.            |
| **Scalability**                | Easily add or remove instances without downtime.      |
| **SSL Termination**            | Manage HTTPS certificates at the load balancer level. |
| **Sticky Sessions (Cookies)**  | Keep users on the same instance if needed.            |
| **Multi-AZ High Availability** | Distribute traffic across Availability Zones.         |
| **Security Segregation**       | Public-facing LB with private backend instances.      |

---

## 🩺 **Health Checks**

Health checks ensure traffic goes only to **healthy targets**.

Example configuration:

```
Protocol: HTTP
Port: 4567
Path: /health
```

If the endpoint returns an **HTTP 200 OK**, the instance is healthy.
If not, it’s marked **unhealthy**, and ELB stops routing traffic to it.

---

## 🧱 **Types of Elastic Load Balancers**

| Type                                | Year | Protocols Supported    | Layer   | Use Case                       |
| ----------------------------------- | ---- | ---------------------- | ------- | ------------------------------ |
| **Classic Load Balancer (CLB)**     | 2009 | HTTP, HTTPS, TCP, SSL  | L4 + L7 | Legacy apps (deprecated)       |
| **Application Load Balancer (ALB)** | 2016 | HTTP, HTTPS, WebSocket | L7      | Modern web apps, microservices |
| **Network Load Balancer (NLB)**     | 2017 | TCP, TLS, UDP          | L4      | High performance, low latency  |
| **Gateway Load Balancer (GWLB)**    | 2020 | IP                     | L3      | Firewalls, security appliances |

✅ **Use ALB or NLB** for most modern AWS applications.

---

## 🔐 **Security Groups Setup**

**1. Load Balancer Security Group**

```text
Inbound:
  Port: 80, 443
  Source: 0.0.0.0/0 (public access)
```

**2. EC2 Instance Security Group**

```text
Inbound:
  Port: 80
  Source: Load Balancer Security Group (not an IP range)
```

This ensures **only the load balancer** can reach the backend instances.

---

## 🔗 **Integrations**

Load balancers work seamlessly with:

* **EC2 Auto Scaling Groups**
* **ECS / EKS containers**
* **AWS Certificate Manager (ACM)**
* **CloudWatch (monitoring)**
* **Route 53 (DNS)**
* **AWS WAF (security)**
* **Global Accelerator (performance)**

---

## 🧠 **Quick Recap**

* Load balancers **distribute traffic** → scalability
* Run across multiple AZs → **high availability**
* Health checks + security groups → **resilience and safety**
* Choose **ALB or NLB** depending on your app layer (HTTP vs TCP/UDP).

---











## 🎯 **Application Load Balancer (ALB)**

**Layer 7 Load Balancer (HTTP/HTTPS)**
→ Operates at the **Application Layer (OSI Layer 7)**.
→ Understands **HTTP headers, URLs, and cookies**, enabling smart routing decisions.

---

### 🔍 **Key Features**

| Feature                            | Description                                                                                                                                                |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Layer 7 (HTTP/HTTPS)**           | Routes based on HTTP methods, headers, hostnames, paths, query strings.                                                                                    |
| **Multiple Applications, One ALB** | One ALB can handle multiple apps or microservices (e.g., `/user`, `/search`).                                                                              |
| **Target Groups**                  | Logical grouping of backend targets (EC2, ECS, Lambda, or IPs).                                                                                            |
| **Advanced Routing**               | - Path-based routing (`/user`, `/search`)  <br> - Host-based routing (`api.example.com`, `admin.example.com`) <br> - Query string or header-based routing. |
| **Redirects**                      | Redirect HTTP → HTTPS automatically.                                                                                                                       |
| **Protocol Support**               | HTTP/1.1, HTTP/2, WebSockets.                                                                                                                              |
| **Port Mapping (ECS)**             | Dynamically route to container ports (used with ECS).                                                                                                      |
| **Fixed DNS Name**                 | AWS assigns a static hostname for each ALB.                                                                                                                |
| **Health Checks**                  | Done per **target group**.                                                                                                                                 |

---

### 🧩 **Target Groups**

A **Target Group** defines where the load balancer sends traffic.

Targets can be:

* **EC2 Instances** (managed manually or via Auto Scaling)
* **ECS Tasks** (containers)
* **Lambda Functions**
* **Private IP Addresses** (for hybrid or on-premises servers)

💡 Health checks are configured **per target group**.
If targets fail health checks, ALB automatically stops sending them traffic.

---

### 🧠 **Routing Example (Microservices)**

```
            ┌──────────────────────────┐
            │   Application Load Balancer│
            └────────────┬─────────────┘
                         │
         ┌───────────────┼────────────────┐
         │                                │
  /user  │                                │  /search
(Target Group 1)                   (Target Group 2)
   EC2: User Service               EC2: Search Service
```

* `/user` → routed to **Target Group 1**
* `/search` → routed to **Target Group 2**
* Both microservices share the **same ALB endpoint**

---

### 🧠 **Routing by Query or Headers**

Example rule:

```
If query string = Platform=Mobile → Target Group 1
If query string = Platform=Desktop → Target Group 2
```

This allows **smart routing** based on request parameters or headers.

---

### 🧾 **X-Forwarded Headers**

When traffic passes through an ALB,
the backend **does not see the original client IP directly**.

AWS adds extra HTTP headers:

| Header              | Description                |
| ------------------- | -------------------------- |
| `X-Forwarded-For`   | Original client IP address |
| `X-Forwarded-Port`  | Port used by client        |
| `X-Forwarded-Proto` | Protocol (HTTP or HTTPS)   |

Backend servers use these headers to log or identify the true client source.

---

### 🔒 **Security Overview**

* ALB is public-facing (port 80/443).
* Backend EC2 instances allow **only traffic from the ALB’s security group**.
* This ensures end users can’t directly access your backend servers.

---

### 🧠 **ALB vs. Classic Load Balancer (CLB)**

| Feature           | Classic LB   | Application LB         |
| ----------------- | ------------ | ---------------------- |
| Layer             | 4 & 7        | 7 only                 |
| Routing           | Basic        | Path/Host/Header-based |
| Multi-App Support | ❌            | ✅                      |
| WebSockets/HTTP/2 | ❌            | ✅                      |
| Container Support | ❌            | ✅                      |
| Cost Efficiency   | Multiple LBs | One ALB for many apps  |

---

### 🧮 **Use Cases**

✅ Microservices architecture
✅ Container workloads (ECS / EKS)
✅ Web applications requiring intelligent routing
✅ Hybrid apps (some on AWS, some on-premises)
✅ HTTPS redirection and centralized SSL management









## ⚙️ **Lab: Launching an Application Load Balancer**

### **Objective**

Create two EC2 instances serving simple web pages and distribute traffic between them using an **Application Load Balancer (ALB)**.

---

## 🪜 **Step 1: Launch Two EC2 Instances**

1. **Go to EC2 → Launch Instances**

2. **Name:**

   * Instance 1 → `My First Instance`
   * Instance 2 → `My Second Instance`

3. **AMI:** Ubuntu

4. **Instance Type:** `t2.micro` (Free-tier)

5. **Key Pair:** *Proceed without key pair* (we’ll use EC2 Instance Connect)

6. **Network Settings:**

   * Select **existing security group** `launch-wizard-1`
   * Ensure inbound rules allow:

     * `HTTP` (port 80) from anywhere
     * `SSH` (port 22) from your IP (optional)

7. **User Data Script:**
   Paste the following script to auto-start a simple web server:

   ```#!/bin/bash
# Update the package index
sudo apt update -y

# Install Nginx (package name must be lowercase)
sudo apt install -y nginx

# Start and enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a simple web page
echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html

   ```

8. **Launch 2 instances** and wait for both to reach `running` and `Status check: 2/2 passed`.

 **Test:**
Copy each instance’s **IPv4 public address** and open it in a browser —
you should see:
`Hello World from ip-xxx-xxx-xxx-xxx.ec2.internal`

---

## 🌐 **Step 2: Create an Application Load Balancer**

1. Go to **EC2 → Load Balancers → Create Load Balancer**
2. Choose **Application Load Balancer (ALB)**.
3. **Name:** `DemoALB`
4. **Scheme:** Internet-facing
   **Address Type:** IPv4
5. **Network Mapping:**

   * Select your **VPC**.
   * Enable **all available Availability Zones**.
6. **Security Group:**

   * Create new one named `demo-sg-load-balancer`
   * Allow **Inbound:**

     * Type: `HTTP`
     * Port: `80`
     * Source: `0.0.0.0/0`
   * Outbound: default (allow all)
7. **Listeners and Routing:**

   * Protocol: `HTTP`
   * Port: `80`
   * Create a **new Target Group** named `demo-tg-alb`

---

## 🎯 **Step 3: Create Target Group**

1. **Target Type:** Instances
2. **Protocol:** HTTP
3. **Port:** 80
4. **Health Check Path:** `/` (default OK)
5. Click **Next** → Select both EC2 instances → **Include as pending** → **Create target group**

✅ Your target group now includes both instances.

---

## 🔄 **Step 4: Attach Target Group to ALB**

* In ALB creation wizard → choose target group `demo-tg-alb`.
* Review and click **Create Load Balancer**.
* Wait for ALB **State: active**.

---

## 🔗 **Step 5: Test the Load Balancer**

1. Copy the **DNS name** of your ALB (e.g., `DemoALB-123456789.us-east-1.elb.amazonaws.com`).
2. Paste it into a browser.

You should see:
`Hello World from ip-xx-xx-xx-xx.ec2.internal`

🔁 **Refresh repeatedly:**
Each refresh alternates between your two EC2 instances — proof of **load balancing**!

---

## 🩺 **Step 6: Verify Health Checks**

1. Go to **Target Groups → demo-tg-alb → Targets tab**
   You should see:

   ```
   i-xxxxx  healthy
   i-yyyyy  healthy
   ```

2. **Stop one instance** → Wait ~30 seconds → Refresh the target group page.
   The stopped instance becomes:

   ```
   i-xxxxx  unused (unhealthy)
   ```

   The ALB automatically stops sending traffic to it.

3. **Restart the instance** → Wait for health status to become **healthy** again → both instances resume receiving traffic.

---

## ✅ **Result**

* One ALB endpoint distributing traffic evenly across two EC2 instances.
* Automatic detection of unhealthy instances.
* Seamless recovery once instances come back online.

---

## 💡 **Key Concepts Learned**

| Concept            | Meaning                                                                |
| ------------------ | ---------------------------------------------------------------------- |
| **Target Group**   | Logical grouping of backend instances                                  |
| **Health Check**   | Regular status probe (`HTTP 200 OK`) to detect healthy targets         |
| **Listener**       | Defines protocol/port and routing rules (e.g., HTTP:80 → Target Group) |
| **DNS Name**       | Single entry point for users                                           |
| **Security Model** | ALB accepts public traffic; EC2 only from ALB SG                       |









## ⚙️ **Advanced Concepts – Application Load Balancer (ALB)**

---

### 🧱 **1. Network Security Enhancement**

#### 🧩 **Current Setup**

* **Load Balancer SG:** `demo-sg-load-balancer` — allows inbound `HTTP (80)` from anywhere.
* **EC2 Instance SG:** `launch-wizard-1` — currently allows inbound `HTTP (80)` from anywhere too.

This means users can **bypass the ALB** and directly access EC2 instances — not ideal for production.

---

#### 🔒 **Goal**

✅ Allow **only** the load balancer to access EC2 instances.
❌ Block direct public access to backend servers.

---

#### 🪜 **Steps to Tighten Security**

1. Go to **EC2 → Security Groups → launch-wizard-1**
2. Click **Edit inbound rules**
3. **Delete** the rule that allows:

   ```
   Type: HTTP
   Source: 0.0.0.0/0
   ```
4. Add a new rule:

   ```
   Type: HTTP
   Source: demo-sg-load-balancer
   ```

   (Select the security group of your ALB)
5. Click **Save rules**

---

#### 🔍 **Result**

* Accessing EC2 instance directly via public IP → ❌ *Connection timed out*
* Accessing via **Load Balancer DNS** → ✅ *Works perfectly!*

This ensures traffic must pass through the ALB, achieving **layered security**.

---

### 🧠 **2. Listener Rules in ALB**

Listeners define **how incoming requests are routed**.
Each listener listens on a port (e.g., 80/443) and processes rules **top-to-bottom by priority**.

---

#### 🧩 **Default Rule**

> “For every request → forward to target group `demo-tg-alb`.”

Now we’ll add **custom rules** to handle specific request paths or headers.

---

### 🪜 **Steps to Add a Custom Rule**

1. Go to your **ALB → Listeners → View/Edit Rules**
2. Add a **New Rule**
   **Name:** `DemoRule`
3. **Add Condition:**

   * Type: `Path`
   * Value: `/error`
4. **Action:**

   * Choose **Fixed Response**
   * Status Code: `404`
   * Content Type: `text/plain`
   * Response Body: `Not found – custom error`
5. **Set Priority:** `5` (lower numbers = higher priority)
6. **Save changes**

Now your rules look like:

| Priority | Condition       | Action                   |
| -------- | --------------- | ------------------------ |
| 5        | Path = `/error` | Fixed Response (404)     |
| Default  | All requests    | Forward to `demo-tg-alb` |

---

### ✅ **Test Your Rule**

1. Copy the **ALB DNS name**, e.g.:

   ```
   http://DemoALB-123456789.us-east-1.elb.amazonaws.com
   ```
2. Visit:

   * `/` → returns *Hello World* (from EC2 target group)
   * `/error` → returns *Not found – custom error*

💡 The `/error` path matched your new **listener rule**, so ALB responded directly with 404 instead of forwarding the request to instances.

---

### 🧩 **3. Rule Priority System**

* ALB processes listener rules **in order of priority (lowest = highest precedence)**.
* Example:

  | Priority | Rule                          |
  | -------- | ----------------------------- |
  | 1        | `/admin` → Admin Target Group |
  | 5        | `/error` → Fixed Response     |
  | Default  | → Main Target Group           |

If multiple rules match, the **rule with the lowest priority number wins**.

---

### 💡 **Key Takeaways**

| Concept                         | Description                                    |
| ------------------------------- | ---------------------------------------------- |
| **SG to SG reference**          | Restricts EC2 access to only the ALB           |
| **Listener Rules**              | Define conditional routing for requests        |
| **Fixed Response**              | Send custom responses without touching backend |
| **Priorities**                  | Determine which rule executes first            |
| **Path/Host/Header conditions** | Enable advanced routing for microservices      |

---

### 🏁 **Summary**

* Secured backend instances (no direct internet access).
* Implemented **custom ALB listener rules** (path-based routing).
* Learned rule **priority and conditional logic**.
* Demonstrated **fixed response** (useful for error pages or maintenance).








## ⚙️ **Network Load Balancer (NLB)**

**Layer 4 Load Balancer** — handles **TCP** and **UDP** traffic.
✅ Designed for **ultra-high performance** and **low latency**.

---

### 🧠 **1. Core Concepts**

| Feature                 | Description                                                   |
| ----------------------- | ------------------------------------------------------------- |
| **Layer**               | Layer 4 – Transport layer (TCP/UDP). Works below HTTP layer.  |
| **Protocols Supported** | TCP, UDP, TLS                                                 |
| **Performance**         | Millions of requests per second with microsecond latency.     |
| **Static IPs**          | One static IP per Availability Zone (can assign Elastic IPs). |
| **High Availability**   | Multi-AZ support with failover.                               |
| **Health Checks**       | Supports TCP, HTTP, or HTTPS-based health checks.             |

---

### 🧩 **2. When to Use NLB**

| Scenario                                  | Why NLB?                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| **High performance needed**               | Can handle millions of requests/sec.                                     |
| **Static IP requirement**                 | Use Elastic IPs for predictable endpoints.                               |
| **Non-HTTP traffic**                      | Supports raw TCP/UDP connections (e.g., SMTP, RDP, DNS, gaming servers). |
| **Hybrid network setup**                  | Can target on-prem servers via private IPs.                              |
| **Load balance HTTP apps with fixed IPs** | Use NLB in front of ALB (NLB → ALB).                                     |

💡 **Exam Tip:**
If the question mentions:

* “Static IPs required”
* “Extreme performance”
* “TCP or UDP traffic”
  → **Answer: Network Load Balancer**

---

### 🏗️ **3. Architecture Overview**

```
            ┌──────────────────────────────┐
            │      Network Load Balancer    │
            └─────────────┬────────────────┘
                          │
            ┌─────────────┴──────────────┐
            │                            │
     Target Group A                Target Group B
     (EC2 Instances)              (Private IPs / On-Prem)
```

* Frontend listener: TCP or UDP port (e.g., 80, 443, 25)
* Backend targets: EC2 instances or private IP addresses
* Health checks: TCP/HTTP/HTTPS
* One static IP per AZ (Elastic IP optional)

---

### 🔗 **4. Target Groups**

**Types of targets NLB can route to:**

* **EC2 Instances** (same VPC)
* **Private IPs** (cross-network or on-prem)
* **Other Load Balancers** (e.g., ALB for HTTP logic)

💡 **Combo Pattern:**
NLB (for static IPs) → ALB (for routing rules).
This combines Layer 4 and Layer 7 benefits.

---

### 🩺 **5. Health Checks**

NLB Target Groups support **3 protocols** for health checks:

| Protocol  | Use Case                                        |
| --------- | ----------------------------------------------- |
| **TCP**   | Simple connectivity check (fast, low overhead). |
| **HTTP**  | Checks for valid HTTP 200 OK response.          |
| **HTTPS** | Secure health checks for encrypted endpoints.   |

If a target fails its health check, NLB **stops sending traffic** until it’s healthy again.

---

### 🔒 **6. Key Differences: ALB vs NLB**

| Feature                | **Application Load Balancer (ALB)** | **Network Load Balancer (NLB)**         |
| ---------------------- | ----------------------------------- | --------------------------------------- |
| **Layer**              | Layer 7 (HTTP/HTTPS)                | Layer 4 (TCP/UDP/TLS)                   |
| **Protocol Awareness** | Understands URLs, headers           | Works with raw packets                  |
| **Static IPs**         | ❌ No                                | ✅ Yes                                   |
| **Performance**        | High                                | Extremely high                          |
| **Use Case**           | Web apps, microservices             | Gaming, databases, IoT, legacy TCP apps |
| **Health Checks**      | HTTP/HTTPS only                     | TCP/HTTP/HTTPS                          |
| **Integration**        | ECS, Lambda                         | Hybrid network, ALB chaining            |

---

### 🧾 **Example Exam Question**

> “Your company must expose a TCP-based financial application that requires static IPs for firewall whitelisting and must handle millions of requests per second.”
> ✅ **Answer:** Network Load Balancer (NLB)

---

### 🧠 **7. Summary**

* **Layer 4 load balancer** for TCP/UDP traffic.
* Supports **static IPs** (Elastic IPs per AZ).
* **High performance + low latency.**
* Can sit **in front of ALB** for combined benefits.
* Health checks: TCP, HTTP, HTTPS.








## ⚙️ **Hands-On: Creating a Network Load Balancer (NLB)**

### 🎯 **Objective**

Create a **Network Load Balancer (Layer 4)** to distribute TCP traffic between two EC2 instances and understand NLB-specific setup, routing, and security.

---

## 🪜 **Step 1: Create the Network Load Balancer**

1. Go to **EC2 → Load Balancers → Create Load Balancer**
2. Select **Network Load Balancer**
3. **Name:** `DemoNLB`
4. **Scheme:** Internet-facing
   **Address type:** IPv4
5. **Network Mapping:**

   * Select your **VPC**
   * Enable **all Availability Zones (AZs)**
   * Each AZ will automatically get **one static IPv4 address**
     → You can replace these with **Elastic IPs** for fixed public IPs.

💡 **Tip:** Each AZ = one static IP → excellent for firewall whitelisting or static endpoint access.

---

## 🧱 **Step 2: Create a Security Group for the NLB**

1. Click **Create security group**

   * **Name:** `demo-sg-nlb`
   * **Description:** Allow HTTP into NLB
2. Add **Inbound Rule:**

   ```
   Type: HTTP
   Port: 80
   Source: 0.0.0.0/0
   ```
3. Keep default outbound rule (allow all).
4. Save and attach `demo-sg-nlb` to the load balancer.

✅ **Purpose:** Controls inbound traffic into the NLB (acts as a front gate).

---

## 🧩 **Step 3: Configure Listener & Target Group**

1. Under **Listeners and Routing:**

   * Protocol: `TCP`
   * Port: `80`
2. **Create Target Group:**

   * **Name:** `demo-tg-nlb`
   * **Target type:** Instances
   * **Protocol:** TCP
   * **Port:** 80
   * **VPC:** Select the same one used above
   * **Health check protocol:** HTTP
     (because your EC2 web servers respond to HTTP)
   * **Advanced health check settings:**

     ```
     Healthy threshold: 2
     Timeout: 2 seconds
     Interval: 5 seconds
     ```
3. **Register targets:**
   Select both EC2 instances → **Include as pending** → **Create Target Group**.

✅ Target group created → ready for backend connections.

---

## 🌐 **Step 4: Finalize NLB Setup**

* Back on NLB creation screen → Refresh Target Group list.
* Choose `demo-tg-nlb` as backend.
* Review configuration → **Create Load Balancer**.
* Wait until **State: active**.

---

## 🧠 **Step 5: Troubleshooting (Unhealthy Targets)**

If targets show as **Unhealthy**, check:

1. Go to **Target Group → Targets tab** → status: *unhealthy*
2. Verify **EC2 security group inbound rules**:

   * It currently allows HTTP only from `demo-sg-alb` (Application LB)
   * You must **also allow traffic from NLB SG**

### ✅ Fix:

1. Go to **EC2 → Security Groups → launch-wizard-1**
2. Edit inbound rules:

   * Add new rule:

     ```
     Type: HTTP
     Source: demo-sg-nlb
     ```
   * (Keep the old “allow from ALB” rule if both are in use)
3. Save rules.

---

## 🔁 **Step 6: Verify Load Balancing**

1. Wait ~30 seconds for **health checks** to pass → status becomes **Healthy**.
2. Copy the **DNS name** of your NLB (e.g., `DemoNLB-123456.us-east-1.elb.amazonaws.com`)
3. Paste in browser → you should see:

   ```
   Hello World from ip-xxx-xxx-xxx-xxx
   ```
4. **Refresh multiple times** — each refresh switches between instance responses.

✅ **Result:**
Traffic alternates between your two EC2 instances — proving **TCP load balancing** works.

---

## 🧹 **Step 7: Clean Up**

To avoid charges:

1. Delete **DemoNLB**
2. Optionally delete:

   * Target group `demo-tg-nlb`
   * Security group `demo-sg-nlb`

---

## 🧩 **Key Takeaways**

| Concept                      | Explanation                                            |
| ---------------------------- | ------------------------------------------------------ |
| **Layer 4 (TCP/UDP)**        | NLB operates below HTTP, ideal for raw network traffic |
| **Static IPs / Elastic IPs** | One per AZ, ideal for firewall rules                   |
| **Health Checks**            | Can use TCP, HTTP, or HTTPS                            |
| **Security**                 | Must explicitly allow NLB SG in backend EC2 SG         |
| **Performance**              | Millions of requests per second, microsecond latency   |
| **Troubleshooting Tip**      | “Unhealthy” targets usually mean blocked inbound rules |

---

### 💡 **Exam + Real-World Insight**

* If a system requires **static IPs** → Use NLB.
* If traffic uses **TCP/UDP** → Use NLB.
* For **HTTP-based routing** → Use ALB.
* For **hybrid setups** → Chain them: **NLB → ALB → EC2**.









## ⚙️ **Gateway Load Balancer (GWLB)**

**Layer 3 Load Balancer (Network Layer – IP)**

---

### 🧠 **1. Concept Overview**

**Purpose:**
The **Gateway Load Balancer (GWLB)** allows you to **deploy, scale, and manage third-party network appliances** such as:

* Firewalls
* Intrusion Detection/Prevention Systems (IDS/IPS)
* Deep Packet Inspection (DPI) tools
* Network traffic analyzers
* Custom packet filters or payload modifiers

✅ It makes **all traffic in your VPC pass through these appliances transparently** before reaching applications.

---

### 🧩 **2. Key Idea: Transparent Traffic Inspection**

**Without GWLB:**
User traffic → Application Load Balancer → EC2 app directly.

**With GWLB:**
User traffic → **Gateway Load Balancer** → **Virtual Appliances (firewalls, IDS)** → GWLB → ALB/Application.

---

### 🌐 **3. How It Works (Flow Diagram)**

```
Users 
  ↓
Gateway Load Balancer (GWLB)
  ↓
Target Group (Virtual Appliances – Firewalls, IDS)
  ↓
GWLB (return path)
  ↓
Application Load Balancer / EC2 Application
```

* GWLB **intercepts all traffic**.
* Routes traffic to your **security appliances** for inspection.
* Appliances **accept** (forward) or **drop** (block) packets.
* If accepted, traffic returns through GWLB to your app.
* For applications, this process is **completely transparent**.

---

### 🧱 **4. Technical Characteristics**

| Feature                     | Description                                                                 |
| --------------------------- | --------------------------------------------------------------------------- |
| **Layer**                   | Layer 3 (Network Layer – IP)                                                |
| **Protocol**                | Uses **GENEVE** protocol (port **6081**) for encapsulation                  |
| **Gateway Function**        | Acts as a transparent network gateway — single ingress & egress point       |
| **Load Balancing Function** | Distributes traffic across appliance targets                                |
| **Target Group Types**      | EC2 instances or private IP addresses                                       |
| **Supported Targets**       | - AWS-hosted EC2 appliances <br> - On-premise devices (via private IPs)     |
| **Routing Integration**     | Automatically updates **VPC route tables** to redirect traffic through GWLB |

---

### 🧰 **5. Use Cases**

| Use Case                          | Example                                                          |
| --------------------------------- | ---------------------------------------------------------------- |
| **Firewalling**                   | All VPC inbound/outbound traffic passes through a firewall fleet |
| **Intrusion Detection (IDS/IPS)** | Detect and block malicious packets before app layer              |
| **Deep Packet Inspection**        | Analyze packet contents for compliance or malware                |
| **Hybrid Security**               | Inspect traffic between AWS and on-prem environments             |

---

### 🧠 **6. Exam Tips (AWS Certified Solutions Architect / SysOps)**

Look for these **keywords** to identify a **Gateway Load Balancer** question:

| Keyword                                              | Points To             |
| ---------------------------------------------------- | --------------------- |
| “GENEVE protocol” or “port 6081”                     | Gateway Load Balancer |
| “Third-party firewall/IDS/DPI appliances”            | Gateway Load Balancer |
| “All traffic must be inspected before reaching apps” | Gateway Load Balancer |
| “Layer 3 load balancing”                             | Gateway Load Balancer |
| “Transparent routing or VPC route modification”      | Gateway Load Balancer |

---

### 🧩 **7. Summary**

| Layer                                         | Protocols             | Purpose                               | Typical Targets         | Example Services                 |
| --------------------------------------------- | --------------------- | ------------------------------------- | ----------------------- | -------------------------------- |
| **Layer 3 – Gateway Load Balancer (GWLB)**    | IP (GENEVE port 6081) | Inspect or filter all network traffic | Firewalls, IDS/IPS, DPI | Palo Alto, Fortinet, Check Point |
| **Layer 4 – Network Load Balancer (NLB)**     | TCP/UDP/TLS           | Raw network traffic distribution      | EC2, private IPs        | Databases, games, IoT            |
| **Layer 7 – Application Load Balancer (ALB)** | HTTP/HTTPS            | Web traffic routing and microservices | EC2, ECS, Lambda        | Web apps, APIs                   |

---

### 🧩 **8. Key Takeaway**

**Gateway Load Balancer = Gateway + Load Balancer**

* **Gateway:** Single ingress/egress for traffic in VPC.
* **Load Balancer:** Distributes traffic among virtual appliances.
* **Use GENEVE protocol (port 6081).**
* **Main use:** Routing all traffic through inspection or firewall systems.

---

### 🧠 **Remember for the Exam**

If you see:

> “Traffic must go through a firewall or IDS before reaching application servers,”
> “GENEVE protocol,”
> “Transparent inspection,”

✅ The answer is **Gateway Load Balancer (GWLB)**.









## 🍪 **Sticky Sessions (Session Affinity) in AWS Load Balancers**

---

### 🧠 **1. Concept Overview**

**Definition:**
Sticky sessions (also called *session affinity*) ensure that **a user is consistently routed to the same backend instance** for all requests during a session.

Without stickiness:
Requests are distributed evenly across all targets (round-robin).

With stickiness:
Each client “sticks” to one backend target — useful for preserving **session data** stored in memory.

---

### 🧩 **2. Why Use Sticky Sessions**

✅ **Use Cases**

* Applications that **store session state locally** on EC2 (not in Redis or DynamoDB).
* Web apps requiring **user login persistence**.
* Shopping carts, dashboards, chat sessions.

❌ **Avoid when**

* You want **perfect load distribution** (stickiness can cause uneven load).
* The app already uses **stateless design or shared storage**.

---

### ⚙️ **3. Supported Load Balancers**

| Load Balancer Type              | Supports Stickiness? | Cookie Name             |
| ------------------------------- | -------------------- | ----------------------- |
| Classic Load Balancer (CLB)     | ✅                    | `AWSELB`                |
| Application Load Balancer (ALB) | ✅                    | `AWSALB` or `AWSALBAPP` |
| Network Load Balancer (NLB)     | ✅ (via source IP)    | No cookie (IP-based)    |

---

### 🧾 **4. How Sticky Sessions Work**

#### Example:

You have **ALB → 2 EC2 instances**

* Client 1 → Instance A
* Client 2 → Instance B

When **stickiness is ON**:

* Client 1’s next request always goes to **Instance A**.
* Client 2’s next request always goes to **Instance B**.

Mechanism:

1. The **load balancer sends a cookie** to the client.
2. The client includes the cookie in each subsequent request.
3. The load balancer uses that cookie to direct traffic to the same target.

If the cookie **expires**, a new instance may be chosen.

---

### 🍪 **5. Cookie Types**

There are **two main stickiness cookie types**:

| Type                         | Who Generates It                   | Description                                                           | Example Name                  |
| ---------------------------- | ---------------------------------- | --------------------------------------------------------------------- | ----------------------------- |
| **Application-Based Cookie** | The **application** (your backend) | Custom cookie defined by your app; you control its name and duration. | `MYCUSTOMCOOKIEAPP`           |
| **Duration-Based Cookie**    | The **Load Balancer**              | Automatically created by ELB with a set expiry time.                  | ALB: `AWSALB` / CLB: `AWSELB` |

---

#### **Application-Based Cookie (Custom)**

* Created by your **app logic**.
* You can specify:

  * Cookie name
  * Duration
  * Attributes
* Must **not** use reserved AWS cookie names:

  ```
  AWSALB, AWSALBAPP, AWSALBTG
  ```

#### **Duration-Based Cookie (Managed)**

* Created by **the Load Balancer**.
* Default lifetime: **1 day**, but configurable from **1 second → 7 days**.
* Cookie expires automatically; user might be rebalanced after expiration.

---

### 🔧 **6. Enabling Sticky Sessions (Hands-On)**

#### **Steps:**

1. Go to **EC2 → Target Groups**
2. Select your Target Group (e.g., `demo-tg-alb`)
3. Click **Actions → Edit Attributes**
4. Scroll to **Stickiness**
5. Turn it **ON**
6. Choose cookie type:

   * Load Balancer–generated (default)
   * Application–based (custom cookie)
7. Set duration (default = 1 day)
8. Save changes.

---

### 🔍 **7. Verifying Stickiness**

1. Open your app in the browser.
2. Enable **Web Developer Tools → Network → Cookies tab.**
3. Make several requests (refresh multiple times).

✅ You’ll notice:

* Responses always come from the **same EC2 instance**.
* Under *Cookies*, a new cookie like `AWSALB` appears with:

  * `Expires:` tomorrow (default 1 day)
  * `Path:` `/`
  * `Value:` session token.

🧪 When the browser includes that cookie in the next request,
the load balancer routes back to the same backend.

---

### ⚖️ **8. Disabling Stickiness**

To revert to normal round-robin load balancing:

1. Go back to the **Target Group attributes.**
2. Turn **Stickiness → Off**.
3. Save changes.

Now each request can hit any backend instance again.

---

### 🧠 **9. Key Points to Remember**

| Concept              | Description                                   |
| -------------------- | --------------------------------------------- |
| **Sticky Sessions**  | Keep the same client bound to the same target |
| **Mechanism**        | Load balancer cookie or app cookie            |
| **Default Duration** | 1 day (configurable 1s–7d)                    |
| **Main Benefit**     | Maintains user session consistency            |
| **Main Risk**        | Uneven load or instance “hot spots”           |
| **Where Configured** | Target group attributes (per ALB or CLB)      |

---

### 🧩 **10. Exam & Real-World Tip**

**Exam trigger words:**

> “User sessions must remain on the same EC2 instance.”
> ✅ Answer: Enable **sticky sessions (session affinity)** on your Load Balancer.

**Real-world tip:**
If you need session persistence but want balanced load, use **shared session storage** (e.g., Redis, ElastiCache, DynamoDB) instead of stickiness.









## ⚖️ **Cross-Zone Load Balancing in AWS**

---

### 🧠 **1. What Is Cross-Zone Load Balancing?**

**Definition:**
Cross-zone load balancing ensures that **each load balancer node in every Availability Zone (AZ)** distributes traffic **evenly across all registered targets (EC2 instances)** in **all AZs**.

Without it, each load balancer node only sends traffic to targets **within its own AZ**.

---

### 📊 **2. Example Scenario**

#### 💡 Setup

* **2 Availability Zones (AZs)**
* **AZ1:** 2 EC2 instances
* **AZ2:** 8 EC2 instances
* Both zones are under the same load balancer.

---

### ✅ **With Cross-Zone Load Balancing (Enabled)**

Each load balancer node sends traffic **evenly across all 10 instances**, regardless of zone.

**Traffic flow example:**

* Client traffic → distributed 50/50 between AZ1 and AZ2 load balancer nodes.
* Each node → evenly distributes requests across **all 10 targets**.

➡️ **Result:**
Every EC2 instance gets **10% of total traffic**, ensuring perfect balance.

---

### ❌ **Without Cross-Zone Load Balancing (Disabled)**

Each load balancer node only sends traffic to **targets in its own AZ**.

**Traffic flow example:**

* Client traffic → split 50/50 between AZ1 and AZ2 load balancer nodes.
* AZ1’s node → distributes traffic to its **2 instances only** → each gets 25%.
* AZ2’s node → distributes traffic to its **8 instances only** → each gets 6.25%.

➡️ **Result:**
AZ1’s instances are overloaded (25% each), while AZ2’s are underutilized.

---

### ⚙️ **3. How It Works (Visual Concept)**

```
       ┌────────────────────┐
       │     Clients        │
       └────────┬───────────┘
                │
   ┌────────────┼───────────────┐
   │        Load Balancer        │
   │ (multiple AZ nodes inside)  │
   └────────────┬───────────────┘
                │
 ┌──────────────┼────────────────────────┐
 │              │                        │
 │         AZ1 (2 instances)         AZ2 (8 instances)
 │      (25% each w/o CZLB)       (6.25% each w/o CZLB)
 │      (10% each w/ CZLB)        (10% each w/ CZLB)
 └────────────────────────────────────────┘
```

---

### 🧩 **4. AWS Load Balancer Default Behaviors**

| Load Balancer Type                  | Default State  | Can Be Changed?             | Inter-AZ Data Charges |
| ----------------------------------- | -------------- | --------------------------- | --------------------- |
| **Application Load Balancer (ALB)** | ✅ **Enabled**  | Yes (at target group level) | ❌ No charge           |
| **Network Load Balancer (NLB)**     | ❌ **Disabled** | Yes                         | 💲 **Charged**        |
| **Gateway Load Balancer (GWLB)**    | ❌ **Disabled** | Yes                         | 💲 **Charged**        |
| **Classic Load Balancer (CLB)**     | ❌ **Disabled** | Yes                         | ❌ No charge           |

---

### 🧱 **5. Configuration Locations**

#### **Application Load Balancer (ALB):**

* **Cross-Zone LB** → Enabled by default.
* Can be overridden **per Target Group**:

  * Inherit from ALB (default)
  * Force **ON** or **OFF**

#### **Network Load Balancer (NLB):**

* **Disabled** by default.
* To enable:

  * Go to **Attributes → Edit**
  * Toggle **Cross-Zone Load Balancing → ON**
  * Warning: “May incur inter-AZ data charges.”

#### **Gateway Load Balancer (GWLB):**

* Same behavior as NLB (off by default, charges apply when enabled).

---

### 💰 **6. Pricing Implications**

| LB Type | Cross-Zone Behavior | Inter-AZ Cost Impact            |
| ------- | ------------------- | ------------------------------- |
| ALB     | Enabled by default  | Free (no inter-AZ charge)       |
| NLB     | Optional            | Charged per GB of cross-AZ data |
| GWLB    | Optional            | Charged per GB of cross-AZ data |
| CLB     | Optional            | Free (legacy, no charge)        |

---

### 🧠 **7. When to Enable / Disable**

✅ **Enable Cross-Zone Load Balancing when:**

* AZs have **unequal numbers of EC2 instances**
* You want **even traffic distribution**
* Cost impact is minimal or acceptable (ALB or low data volume)

❌ **Disable Cross-Zone Load Balancing when:**

* You have **balanced infrastructure** across AZs
* Want to **avoid inter-AZ data charges** (NLB or GWLB)
* Need **strict AZ isolation** for compliance or latency

---

### 🔧 **8. Hands-On Practice**

1. Go to your **Load Balancer → Attributes**
2. Locate **Cross-Zone Load Balancing**
3. Edit:

   * For **ALB:** verify it’s enabled (default)
   * For **NLB/GWLB:** toggle **ON** to enable (charges warning)
4. At **Target Group level**, override ALB cross-zone setting if desired.

---

### 🧾 **9. Key Takeaways**

| Concept                       | Summary                                                      |
| ----------------------------- | ------------------------------------------------------------ |
| **Cross-Zone Load Balancing** | Distributes traffic across all registered targets in all AZs |
| **Without It**                | Each LB node only routes to its own AZ targets               |
| **ALB**                       | Enabled by default, free                                     |
| **NLB & GWLB**                | Disabled by default, extra cost when enabled                 |
| **Use Case**                  | Uneven AZ target distribution or global load spreading       |

---

### 🧠 **10. Exam Tip**

If a question says:

> “You have more EC2 instances in one AZ than another, and want equal traffic distribution.”
> ✅ **Answer:** Enable **Cross-Zone Load Balancing** on your Load Balancer.

If it says:

> “You need static IPs and low latency TCP traffic; avoid cross-AZ data costs.”
> ✅ **Answer:** Use **NLB** and **disable cross-zone balancing**.








## 🔒 **SSL / TLS Certificates in AWS Load Balancing**

---

### 🧠 **1. What Is SSL / TLS?**

| Term                               | Meaning                                      | Status              |
| ---------------------------------- | -------------------------------------------- | ------------------- |
| **SSL (Secure Sockets Layer)**     | Original protocol for encrypting connections | Outdated            |
| **TLS (Transport Layer Security)** | Modern replacement for SSL                   | 🔹 Current standard |

✅ Both ensure **data encryption in transit** between client ↔ server.
This is called **“in-flight encryption.”**

---

### 🧩 **2. Purpose of SSL / TLS in Load Balancing**

**Goal:**
Encrypt all traffic between the **client** and the **load balancer** over **HTTPS**.

**Flow Example:**

```
Client → HTTPS (encrypted) → Load Balancer
       → HTTP (plain, private VPC) → EC2 instances
```

* The **Load Balancer terminates SSL/TLS** — decrypts incoming traffic before forwarding to backend targets.
* This process is called **SSL Termination**.

💡 Backend communication (within the VPC) can be **HTTP** for performance,
or **HTTPS** for end-to-end encryption (optional).

---

### 🧾 **3. Certificates and Management**

* SSL/TLS certificates are digital credentials that:

  * Verify the **identity** of your domain.
  * Enable **encryption** between client and server.
* Certificates are issued by **Certificate Authorities (CAs)** such as:

  * Comodo, DigiCert, GlobalSign, GoDaddy, Let’s Encrypt, etc.
* Certificates **expire periodically** (e.g., 1 year) and must be **renewed**.

---

### 🧰 **4. Managing Certificates in AWS**

AWS provides **AWS Certificate Manager (ACM)** to:

* Automatically **provision**, **store**, and **renew** public certificates.
* Let you **upload** your own private or third-party certificates.

💡 When configuring an **HTTPS listener** on a Load Balancer:

* You must attach at least one **default certificate**.
* You can attach **multiple certificates** (for different domains) if SNI is supported.

---

### 🔐 **5. What Is SNI (Server Name Indication)?**

**Problem (before SNI):**

* Only one SSL certificate per IP address.
* Hosting multiple secure websites on one server required multiple IPs.

**Solution:**

* **SNI (Server Name Indication)** allows clients to tell the server **which hostname** they’re trying to reach during the SSL handshake.
* The server (load balancer) then chooses the correct certificate dynamically.

✅ **Result:** One ALB/NLB can host multiple domains with different SSL certificates.

---

### 🧭 **6. How SNI Works**

```
1️⃣ Client → “I want to connect to www.mycorp.com”
2️⃣ Load Balancer → Looks up www.mycorp.com
3️⃣ Load Balancer → Loads correct certificate
4️⃣ Connection established (TLS encrypted)
```

**AWS Implementation Example:**

| Component    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| **ALB**      | Has 2 certificates → `www.mycorp.com` and `domain1.example.com`  |
| **Client 1** | Requests `www.mycorp.com` → ALB uses certificate for that domain |
| **Client 2** | Requests `domain1.example.com` → ALB uses the other certificate  |
| **Routing**  | ALB forwards each to correct target group                        |

---

### 🌍 **7. SNI Support by AWS Load Balancers**

| Load Balancer Type                  | SNI Support | Certificates Supported                                  |
| ----------------------------------- | ----------- | ------------------------------------------------------- |
| **Classic Load Balancer (CLB)**     | ❌ No        | Only **one** SSL certificate                            |
| **Application Load Balancer (ALB)** | ✅ Yes       | Multiple certificates per listener                      |
| **Network Load Balancer (NLB)**     | ✅ Yes       | Multiple certificates per listener (TLS listeners only) |
| **Gateway Load Balancer (GWLB)**    | ❌ N/A       | Works at Layer 3 (no SSL support)                       |

---

### 🧩 **8. Security Policies**

When you create an HTTPS listener, you can choose a **Security Policy**, which defines:

* Supported **TLS versions** (e.g., TLS 1.2, TLS 1.3)
* Supported **cipher suites**
* Legacy client compatibility (e.g., old browsers or systems)

💡 Modern practice: **Use only TLS 1.2+** for strong encryption.

---

### 💡 **9. Real-World Example**

#### **Architecture:**

```
Client
  ↓ HTTPS (TLS)
Application Load Balancer (SSL termination)
  ↓ HTTP (private)
Target Group (EC2 instances)
```

#### **Benefits:**

* Users get the green padlock (secure site).
* ALB handles certificate management via ACM.
* EC2 servers can stay simple — no local certificates needed.

---

### 🧠 **10. AWS Exam and Interview Tips**

| Scenario                                        | Correct Answer                                       |
| ----------------------------------------------- | ---------------------------------------------------- |
| “Multiple secure websites on one ALB.”          | Use **SNI** with multiple certificates.              |
| “Need automatic certificate renewal.”           | Use **AWS Certificate Manager (ACM)**.               |
| “Encrypt traffic between ALB and targets too.”  | Use **HTTPS target group** or end-to-end encryption. |
| “Legacy system supports only old SSL versions.” | Choose a **custom security policy** on the listener. |
| “One IP per SSL domain required.”               | (Old case) → Classic Load Balancer (no SNI).         |

---

### 🧾 **11. Key Takeaways**

| Concept               | Summary                                      |
| --------------------- | -------------------------------------------- |
| **SSL/TLS**           | Encrypts traffic between client and LB       |
| **SSL Termination**   | Decryption happens at the Load Balancer      |
| **ACM**               | AWS Certificate Manager handles certificates |
| **SNI**               | Enables multiple SSL certs on one LB         |
| **ALB/NLB**           | Support SNI                                  |
| **CLB**               | One certificate only                         |
| **Security Policies** | Define TLS versions and cipher suites        |










## 🔐 **Enabling SSL/TLS on Application and Network Load Balancers**

---

### 🧠 **1. Why Enable SSL/TLS**

* To ensure **encrypted traffic** between **clients and your Load Balancer** (HTTPS).
* Protects data **in transit** and gives users a **secure connection (padlock icon)**.
* Implemented using **port 443 (HTTPS)** and valid **SSL/TLS certificates** from a trusted authority.

---

### 🧩 **2. SSL/TLS on the Application Load Balancer (ALB)**

#### **Steps to Enable HTTPS Listener:**

1. **Go to your ALB** → **Listeners tab**
2. Click **Add listener**
3. **Protocol:** `HTTPS`
   **Port:** `443` (default)
4. **Default Action:**
   → *Forward traffic* to a chosen **Target Group** (e.g., `demo-tg-alb`)

---

#### **5. Configure Security Settings**

**(a) SSL Security Policy**

* Defines which **TLS versions and cipher suites** are supported.
* Use defaults unless you need to support legacy clients.
  Example:

  * `ELBSecurityPolicy-TLS13-1-2-2021-06` (modern)
  * `ELBSecurityPolicy-2016-08` (legacy-compatible)

**(b) SSL/TLS Certificate Source**
You have three options:

| Source                            | Description                                              |
| --------------------------------- | -------------------------------------------------------- |
| **ACM (AWS Certificate Manager)** | Recommended. Automatically renews certificates.          |
| **IAM**                           | Can store certs but not ideal for external domains.      |
| **Import manually**               | Paste private key, certificate body, and chain directly. |

💡 **Best Practice:** Use **ACM-issued certificates** for your domain (e.g., via Route 53 DNS validation).

---

#### **6. Result**

Once the listener is active:

* All client requests via `https://` are **encrypted**.
* ALB terminates the SSL connection at port **443**.
* Backend targets can still receive **HTTP (port 80)** traffic inside the VPC.

---

### 🌐 **3. SSL/TLS on the Network Load Balancer (NLB)**

#### **Steps to Enable TLS Listener:**

1. Open your **NLB** → **Listeners tab**
2. Click **Add listener**
3. **Protocol:** `TLS`
   **Port:** `443` (default)
4. **Default Action:**
   → Forward to a **Target Group** (e.g., `demo-tg-nlb`)

---

#### **5. Configure Security Settings**

**(a) Security Policy**

* Defines TLS versions and cipher suites for negotiation.
  You can choose policies like:

  * `ELBSecurityPolicy-TLS13-1-2-2021-06`
  * `ELBSecurityPolicy-FS-1-2-Res-2020-10`

**(b) Certificate Source**
Same three options:

* **ACM (recommended)**
* **IAM (for internal)**
* **Import manually (if needed)**

**(c) (Optional) ALPN — Application-Layer Protocol Negotiation**

* Used for modern TLS-based protocols (e.g., HTTP/2, gRPC).
* Usually left at default unless you specifically need it.

---

### 🧱 **4. Behind the Scenes**

* **ALB TLS Termination:**
  Decrypts HTTPS → Forwards plaintext HTTP to backend.
* **NLB TLS Termination:**
  Decrypts TCP-level encryption → Forwards decrypted traffic downstream.
* **You can also configure end-to-end encryption** (client → ALB/NLB → EC2 HTTPS).

---

### 🧾 **5. Key Differences Between ALB and NLB SSL Configuration**

| Feature                    | ALB                               | NLB                                   |
| -------------------------- | --------------------------------- | ------------------------------------- |
| **Layer**                  | Layer 7 (Application)             | Layer 4 (Network)                     |
| **Listener Protocol**      | HTTPS                             | TLS                                   |
| **Certificate Management** | ACM / IAM / Import                | ACM / IAM / Import                    |
| **Policy Control**         | SSL/TLS cipher & version policies | TLS cipher & version policies         |
| **Advanced Option**        | Redirect HTTP→HTTPS               | ALPN (App-Layer Protocol Negotiation) |

---

### 🧠 **6. AWS Exam / Real-World Tips**

| Scenario                                                  | Best Practice                               |
| --------------------------------------------------------- | ------------------------------------------- |
| “We need to secure our public web app.”                   | Use **ALB + ACM certificate** on port 443.  |
| “Our backend runs TCP-based apps (e.g., database proxy).” | Use **NLB with TLS listener**.              |
| “We host multiple domains.”                               | Use **SNI with multiple certs** on ALB/NLB. |
| “We want automatic certificate renewals.”                 | Use **AWS Certificate Manager (ACM)**.      |
| “Need strong encryption only.”                            | Choose a **TLS 1.2/1.3 security policy**.   |

---

### 🧩 **7. Quick Visual Summary**

```
          ┌─────────────────────────────┐
          │       Clients (HTTPS)       │
          └────────────┬────────────────┘
                       │ Port 443 (TLS)
             ┌─────────▼────────────┐
             │ Application LB (ALB) │  ← ACM Certificate + TLS Policy
             └─────────┬────────────┘
                       │
              ┌────────▼────────┐
              │ EC2 / ECS Tasks │  ← HTTP or HTTPS Target Group
              └─────────────────┘
```

```
             ┌───────────────────────┐
             │ Network LB (NLB)      │  ← TLS Listener + ACM Certificate
             └────────┬──────────────┘
                      │
               ┌──────▼──────┐
               │ TCP Targets │
               └─────────────┘
```










## 🔁 **Connection Draining / Deregistration Delay**

---

### 🧠 **1. Concept Overview**

**Goal:**
To gracefully remove EC2 instances (targets) from a Load Balancer **without breaking active connections.**

When an instance is:

* **Manually deregistered**,
* **Marked unhealthy**, or
* **Being terminated / replaced** (like in Auto Scaling),

…the load balancer needs to **stop sending new requests** to that instance
but still **allow ongoing requests to finish**.

This is exactly what **Connection Draining (CLB)** or **Deregistration Delay (ALB/NLB)** does.

---

### 🧩 **2. Two Different Names, Same Purpose**

| Load Balancer Type                  | Feature Name         | Default Timeout | Setting Location        |
| ----------------------------------- | -------------------- | --------------- | ----------------------- |
| **Classic Load Balancer (CLB)**     | Connection Draining  | 300 sec (5 min) | ELB attributes          |
| **Application Load Balancer (ALB)** | Deregistration Delay | 300 sec (5 min) | Target Group attributes |
| **Network Load Balancer (NLB)**     | Deregistration Delay | 300 sec (5 min) | Target Group attributes |

---

### 🧾 **3. How It Works**

Let’s imagine 3 EC2 instances behind a Load Balancer:

```
       ┌──────────────────────┐
       │     Load Balancer    │
       └────────┬─────────────┘
                │
 ┌──────────────┼──────────────┐
 │     EC2-1 (draining)       │
 │     EC2-2 (active)         │
 │     EC2-3 (active)         │
 └────────────────────────────┘
```

**When EC2-1 enters draining state:**

1. **Existing connections** (in-flight requests) → continue until they finish.
2. **New connections** → redirected to EC2-2 and EC2-3.
3. After the **draining timeout**, any remaining open connections are **terminated**.

---

### ⚙️ **4. Configuration Settings**

| Parameter                        | Description                                                                  |
| -------------------------------- | ---------------------------------------------------------------------------- |
| **Deregistration Delay Timeout** | Time (in seconds) that Load Balancer waits for in-flight requests to finish. |
| **Range**                        | 1 – 3600 seconds                                                             |
| **Default**                      | 300 seconds (5 minutes)                                                      |
| **Disable**                      | Set to `0` seconds (no delay).                                               |

---

### 🧮 **5. Example Behavior**

| Timeout Value           | Use Case                            | Behavior                                     |
| ----------------------- | ----------------------------------- | -------------------------------------------- |
| `30 seconds`            | Short API calls or static website   | Instance drains quickly                      |
| `300 seconds` (default) | Balanced workload                   | Allows moderate in-flight request completion |
| `600–3600 seconds`      | Long-running uploads, video streams | Gives users time to finish connections       |

---

### 🚦 **6. Real-World Example**

* Your **Auto Scaling Group** triggers a scale-in event.
* One EC2 instance is selected for **termination**.
* Before stopping, the Load Balancer marks it as **“draining.”**
* All new traffic goes to other instances.
* Current users finish their requests → instance shuts down gracefully.

💡 Without connection draining, active users could face:

* Timeout errors
* File upload failures
* Interrupted web sessions

---

### 🧰 **7. How to Configure in AWS Console**

#### **For ALB or NLB:**

1. Go to **EC2 → Target Groups**
2. Select your **Target Group**
3. Choose **Attributes → Edit**
4. Set **Deregistration delay timeout (seconds)**
5. Save changes

#### **For Classic Load Balancer:**

1. Go to **EC2 → Load Balancers**
2. Select **Classic Load Balancer**
3. Go to **Description → Edit Attributes**
4. Enable **Connection Draining**
5. Set timeout (1–3600 sec)

---

### 💡 **8. CLI Configuration Examples**

#### **ALB / NLB (Deregistration Delay):**

```bash
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/demo-tg/abc123 \
  --attributes Key=deregistration_delay.timeout_seconds,Value=120
```

#### **CLB (Connection Draining):**

```bash
aws elb modify-load-balancer-attributes \
  --load-balancer-name demo-clb \
  --load-balancer-attributes \
  "{\"ConnectionDraining\":{\"Enabled\":true,\"Timeout\":300}}"
```

---

### 🧠 **9. Exam and Interview Tips**

| Question                                                            | Answer                                                         |
| ------------------------------------------------------------------- | -------------------------------------------------------------- |
| **What is Connection Draining used for?**                           | Allows in-flight requests to complete before instance removal. |
| **What is it called in ALB/NLB?**                                   | Deregistration Delay.                                          |
| **Default value?**                                                  | 300 seconds (5 minutes).                                       |
| **How to disable it?**                                              | Set timeout = 0.                                               |
| **Where to configure in ALB?**                                      | In Target Group attributes.                                    |
| **Scenario:** “Long file uploads fail during instance termination.” | Increase Deregistration Delay value.                           |

---

### 🧾 **10. Key Takeaways**

| Concept                | Description                                              |
| ---------------------- | -------------------------------------------------------- |
| **Purpose**            | Gracefully remove instances without breaking connections |
| **CLB Term**           | Connection Draining                                      |
| **ALB/NLB Term**       | Deregistration Delay                                     |
| **Default Timeout**    | 300 seconds                                              |
| **Configurable Range** | 1–3600 seconds                                           |
| **Effect**             | Allows existing requests to complete before shutdown     |
| **Disable**            | Set to 0 seconds                                         |









## ⚙️ **Amazon EC2 Auto Scaling Groups (ASG)**

---

### 🧠 **1. What Is an Auto Scaling Group?**

An **Auto Scaling Group (ASG)** automatically **adds (scales out)** or **removes (scales in)** EC2 instances to match the demand on your application.

✅ **Main goals:**

* Maintain the **right number of instances**.
* Automatically **replace unhealthy instances**.
* Optimize **costs** by removing idle capacity.
* Ensure **high availability** by balancing load across AZs.

💡 **Key Idea:**
ASG uses **CloudWatch metrics + scaling policies** to decide *when* to launch or terminate instances.

---

### 🧩 **2. ASG Core Concepts**

| Term                 | Meaning                                                        |
| -------------------- | -------------------------------------------------------------- |
| **Scale Out**        | Add EC2 instances when load increases                          |
| **Scale In**         | Remove EC2 instances when load decreases                       |
| **Minimum Size**     | The smallest number of instances ASG maintains                 |
| **Desired Capacity** | The number of instances ASG *wants* to have (starts with this) |
| **Maximum Size**     | The largest number of instances ASG can launch                 |

---

### 📊 **3. Example Configuration**

| Setting              | Value | Meaning                                  |
| -------------------- | ----- | ---------------------------------------- |
| **Min Size**         | 2     | Always keep at least 2 instances running |
| **Desired Capacity** | 4     | Start with 4 instances                   |
| **Max Size**         | 7     | Never exceed 7 instances                 |

**If load increases:**
→ ASG automatically *launches* up to 7 instances (scale out).

**If load decreases:**
→ ASG automatically *terminates* instances (scale in).

---

### 🔁 **4. How ASG Works with a Load Balancer**

#### **Architecture Flow:**

```
         ┌───────────────────────────┐
         │      Load Balancer        │
         └────────────┬──────────────┘
                      │
      ┌───────────────┼────────────────┐
      │       Auto Scaling Group       │
      └───────────────┬────────────────┘
          ┌───────────┴────────────┐
          │    EC2 Instances       │
          └────────────────────────┘
```

**Behavior:**

* New EC2 instances **automatically register** with the Load Balancer.
* ELB performs **health checks** and sends the status to the ASG.
* If an instance is **unhealthy**, ASG **terminates and replaces it**.
* Traffic is evenly **load balanced** across all healthy instances.

💡 Works perfectly with:

* **Application Load Balancer (ALB)**
* **Network Load Balancer (NLB)**

---

### 🧱 **5. Launch Template (or Launch Configuration)**

ASG uses a **Launch Template** that defines how new EC2 instances are created.

**Launch Template includes:**

* Amazon Machine Image (**AMI**)
* **Instance Type** (e.g., `t3.micro`)
* **User Data** (startup script)
* **EBS volumes**
* **Security Groups**
* **Key Pair (SSH access)**
* **IAM Role** for EC2
* **Network Subnets / VPC**
* Optional **Load Balancer** attachment

💡 *Launch Configurations* are older — **use Launch Templates** for all new setups.

---

### 📈 **6. Integration with CloudWatch**

ASGs rely on **CloudWatch Alarms** to scale dynamically.

**Example Flow:**

```
CloudWatch Metric → Alarm Triggered → ASG Scaling Policy → Adjust Instance Count
```

**Common metrics:**

* Average **CPU Utilization**
* **Network In/Out**
* **Request Count per Target**
* **Custom Application Metrics**

**Scale-Out Policy Example:**

* If `CPU > 70%` for 5 minutes → Add 2 instances

**Scale-In Policy Example:**

* If `CPU < 20%` for 10 minutes → Remove 1 instance

---

### 🧮 **7. Example Scenario**

| Time     | Average CPU | ASG Action | Instance Count |
| -------- | ----------- | ---------- | -------------- |
| 12:00 PM | 20%         | Scale In   | 2              |
| 1:00 PM  | 75%         | Scale Out  | 4              |
| 2:00 PM  | 90%         | Scale Out  | 6              |
| 4:00 PM  | 15%         | Scale In   | 3              |

ASG keeps scaling dynamically to maintain **optimal performance and cost**.

---

### 💰 **8. Cost Model**

Auto Scaling Groups are **free** —
you only pay for:

* **EC2 instances** it launches
* **EBS volumes**
* **Load balancer usage**

---

### 🧠 **9. Exam & Real-World Tips**

| Concept             | What to Remember                                  |
| ------------------- | ------------------------------------------------- |
| **Purpose of ASG**  | Automatically scale EC2 instances based on demand |
| **Scale Out**       | Add instances                                     |
| **Scale In**        | Remove instances                                  |
| **Min/Max/Desired** | Controls group size                               |
| **Launch Template** | Defines instance configuration                    |
| **CloudWatch**      | Triggers scaling policies                         |
| **Health Checks**   | Replace unhealthy instances automatically         |
| **Cost**            | ASG is free — pay for underlying EC2 only         |

---

### 🧩 **10. Quick Recap Diagram**

```
┌────────────────────────────┐
│      CloudWatch Alarm      │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│  Auto Scaling Group (ASG)  │
│   ├─ Min: 2                │
│   ├─ Desired: 4            │
│   └─ Max: 7                │
└──────────────┬─────────────┘
               │
               ▼
       ┌─────────────┐
       │ EC2 Fleet   │  ← Instances automatically added/removed
       └─────────────┘
               │
               ▼
     ┌─────────────────┐
     │ Load Balancer   │  ← Routes traffic to healthy EC2s
     └─────────────────┘
```










## ⚙️ **Auto Scaling Group (ASG) – Hands-On Practice**

---

### 🧩 **1. Pre-Setup: Clean Environment**

* Go to **EC2 → Instances**
* **Terminate** all existing EC2 instances
  → You should have **0 running** before starting.

---

### 🏗️ **2. Step 1 – Create an Auto Scaling Group**

Go to:

```
EC2 → Auto Scaling Groups → Create Auto Scaling Group
```

**Name:** `Demo-ASG`

Since an ASG needs instructions on *how* to launch instances,
we must first create a **Launch Template**.

---

### 🧰 **3. Step 2 – Create a Launch Template**

1. **Name:** `my-demo-template`
2. **Description:** `template for ASG practice`
3. **AMI (Amazon Machine Image):**

   * Choose **Amazon Linux 2 (x86, Free Tier Eligible)**
4. **Instance Type:** `t2.micro`
5. **Key Pair:** `EC2-tutorial` (or your existing key)
6. **Security Group:** `launch-wizard-1` (HTTP + SSH allowed)
7. **Storage:** Default 8 GB gp2 volume
8. **User Data:**
   Paste the web-server startup script you’ve been using:

   ```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   echo "<h1>Hello world from $(hostname -f)</h1>" > /var/www/html/index.html
   ```
9. **Create Template → Done**

✅ You’ve defined how EC2 instances will be launched by the ASG.

---

### 🌐 **4. Step 3 – Configure the Auto Scaling Group**

1. **Select Launch Template:** `my-demo-template`
2. **VPC:** Choose your default or custom VPC
3. **Availability Zones:**
   Select *at least two or three subnets* for multi-AZ distribution.
4. **Load Balancer Integration:**

   * Choose **Attach to an existing target group**
   * Pick your ALB target group (e.g., `demo-tg-alb`)
5. **Health Checks:**

   * Enable both **EC2** and **ELB** health checks
     → ASG will replace any failed instance.
6. **Capacity Settings:**

   ```
   Min capacity: 1
   Desired capacity: 1
   Max capacity: 1
   ```
7. **Scaling Policies:** Skip for now (manual scaling only)
8. **Notifications / Tags:** Optional
9. **Create Auto Scaling Group**

---

### 🚀 **5. Step 4 – Observe Instance Launch**

Go to:

```
Auto Scaling Group → Demo-ASG → Activity History
```

* You’ll see a new activity:
  **“Launching a new EC2 instance”**
* ASG automatically provisions the instance defined by the Launch Template.

Then check under:

```
EC2 → Instances
```

✅ One instance is running.

---

### ⚙️ **6. Step 5 – Load Balancer & Health Check Integration**

* Go to:

  ```
  EC2 → Target Groups → demo-tg-alb → Targets
  ```
* You’ll see your new instance in **initializing** state.
* After the **User Data** completes and health checks pass → **Healthy**.

💡 The instance is now automatically **registered** to your Application Load Balancer (ALB).

---

### 🌍 **7. Step 6 – Test the Web Application**

* Copy the **ALB DNS name** and open it in a browser.
* You should see:

  ```
  Hello world from ip-xx-xx-xx-xx.ec2.internal
  ```

✅ Your instance created by the ASG is fully serving traffic through the ALB.

---

### 📈 **8. Step 7 – Manual Scaling (Scale Out)**

To test **scaling out manually**:

1. Go to:

   ```
   Auto Scaling Group → Demo-ASG → Edit
   ```
2. Change:

   ```
   Desired capacity: 2
   Max capacity: 2
   ```
3. Save changes.

⏳ ASG detects that current count = 1, desired = 2 → launches a new instance.

* Watch **Activity History**:

  * “Launching a new EC2 instance”
* Check **Target Group → Targets**:
  Both instances become **Healthy** after bootstrapping.

✅ ALB now balances traffic between **two EC2 instances**.

You can verify by refreshing the ALB DNS —
you’ll see **different hostnames/IPs** alternating.

---

### 📉 **9. Step 8 – Manual Scaling (Scale In)**

Now test **scaling in**:

1. Edit ASG again:

   ```
   Desired capacity: 1
   ```
2. Save changes.

ASG will:

* Pick one instance to **terminate**
* Deregister it from the Target Group
* Retain one healthy EC2 instance

Check **Activity History**:

```
Terminating EC2 instance to match desired capacity
```

✅ Traffic now routes only to the remaining instance.

---

### 🧠 **10. Key Takeaways**

| Concept                       | Description                                           |
| ----------------------------- | ----------------------------------------------------- |
| **Launch Template**           | Defines how ASG creates EC2 instances                 |
| **Desired Capacity**          | Number of instances to maintain                       |
| **Scaling Out**               | Add instances (handle more load)                      |
| **Scaling In**                | Remove instances (reduce cost)                        |
| **Load Balancer Integration** | ALB automatically distributes traffic & checks health |
| **Health Check**              | ASG replaces failed instances automatically           |
| **Cost**                      | ASG is free; pay for EC2 + Load Balancer only         |

---

### 🧾 **11. Quick Visual Summary**

```
┌───────────────────────────────┐
│      Application Load Balancer│
└──────────────┬────────────────┘
               │
   ┌───────────▼───────────┐
   │  Auto Scaling Group   │
   │  ├ Min = 1            │
   │  ├ Desired = 2         │
   │  └ Max = 2            │
   └───────────┬───────────┘
               │
   ┌───────────▼───────────┐
   │   EC2 Instances       │
   │   (Web servers w/ UserData) │
   └───────────────────────┘
```











## ⚙️ **Auto Scaling Group (ASG) – Scaling Policies Explained**

---

### 🧠 **1. Purpose of Scaling Policies**

Scaling policies tell the **Auto Scaling Group** *when* and *how* to adjust the number of EC2 instances based on metrics, schedules, or predictions.

**Goal:**
Keep your application **stable, cost-efficient, and responsive** to changes in load.

---

## 🚀 **2. Types of Scaling Policies**

---

### **A. Dynamic Scaling**

Automatically adjusts capacity in response to changing demand.

#### **1️⃣ Target Tracking Scaling (most common & simplest)**

* You define a **metric** and a **target value**.
* ASG automatically scales in/out to maintain that target.

**Example:**
Target metric = Average CPU utilization
Target value = 40%

→ ASG keeps average CPU ≈ 40% by adding/removing instances as needed.

**Analogy:** Like a thermostat — you set a temperature (target metric), and it adjusts automatically.

**Typical metrics:**

* `AWS/EC2:CPUUtilization`
* `AWS/ApplicationELB:RequestCountPerTarget`
* `AWS/EC2:NetworkIn` / `NetworkOut`
* Custom CloudWatch metrics

---

#### **2️⃣ Simple / Step Scaling**

* You create **CloudWatch alarms** that trigger **scaling actions**.
* When an alarm threshold is reached, ASG adds or removes instances.

**Example:**

```text
If average CPU > 70% → Add 2 instances
If average CPU < 30% → Remove 1 instance
```

**Step Scaling** enhances this by defining *multiple thresholds:*

| Condition | Action            |
| --------- | ----------------- |
| CPU ≥ 70% | Add 1 instance    |
| CPU ≥ 85% | Add 2 instances   |
| CPU ≤ 20% | Remove 1 instance |

💡 Useful for **gradual adjustments** instead of big jumps.

---

### **B. Scheduled Scaling**

Used when you **know** in advance that load will increase or decrease.

**Example:**

* Every Friday at 5 PM → increase min capacity to 10
* Every Sunday at 2 AM → decrease min capacity to 2

🕓 Useful for **predictable workloads**, like office hours or batch jobs.

---

### **C. Predictive Scaling**

Uses **machine learning** to **analyze historical trends** and automatically **forecast demand**.

* AWS forecasts future traffic based on patterns.
* It pre-provisions instances *ahead of time* to prevent performance drops.

💡 Ideal for **cyclical traffic patterns**, such as:

* E-commerce peaks (weekends, holidays)
* Daily business workloads (9 AM – 5 PM)

---

## 📈 **3. Common Scaling Metrics**

| Metric                     | Description                                  | When to Use                                             |
| -------------------------- | -------------------------------------------- | ------------------------------------------------------- |
| **CPUUtilization**         | Average CPU load across ASG                  | For compute-intensive apps                              |
| **RequestCountPerTarget**  | Requests handled per target (via ALB)        | For web apps / APIs                                     |
| **NetworkIn / NetworkOut** | Data transferred (in bytes)                  | For upload/download-heavy apps                          |
| **Custom Metric**          | Any app-specific metric pushed to CloudWatch | For special workloads (e.g., queue depth, active users) |

---

## 🧮 **4. Cooldown Period (Stabilization Delay)**

After a scaling activity (adding/removing instances), the ASG enters a **cooldown period** — a “quiet time” before the next scaling action.

| Setting              | Description                                             |
| -------------------- | ------------------------------------------------------- |
| **Default Cooldown** | 300 seconds (5 minutes)                                 |
| **Purpose**          | Prevents rapid up/down scaling before metrics stabilize |
| **Disable / Adjust** | You can customize or shorten it if using pre-baked AMIs |

🧠 **How it works:**

* If a scaling action occurs during cooldown → **ignored**.
* If no cooldown in progress → **action executed**.

**Best practice:**
Use **ready-to-use AMIs** (with pre-installed dependencies)
→ new instances become healthy faster → shorter cooldowns → quicker scaling response.

---

## 🧩 **5. Example Scenario**

Let’s say your web app has **3 instances** and CPU jumps to 80%.

| Metric                | Rule              | Action    | Result  |
| --------------------- | ----------------- | --------- | ------- |
| CPU > 70%             | Add 2 instances   | Scale Out | 5 total |
| CPU < 30%             | Remove 1 instance | Scale In  | 4 total |
| CPU stabilizes at 40% | No change         | Stable    | 4 total |

---

## 🔍 **6. Recommended Setup Flow**

1. Enable **Detailed Monitoring** (1-minute metric intervals)
2. Define **metric and target value**
3. Configure **Target Tracking Policy**
4. Adjust **Cooldown Period**
5. Test with **manual scaling** first
6. Gradually **enable predictive/scheduled scaling**

---

## 💡 **7. Exam & Interview Tips**

| Question                                         | Answer                                    |
| ------------------------------------------------ | ----------------------------------------- |
| **What’s the easiest scaling policy to use?**    | Target Tracking Scaling                   |
| **Which scaling type uses CloudWatch alarms?**   | Simple / Step Scaling                     |
| **Which one is based on future load forecasts?** | Predictive Scaling                        |
| **Default cooldown period?**                     | 300 seconds                               |
| **How to reduce cooldown?**                      | Use pre-baked AMIs & shorter warm-up time |
| **What’s the most common scaling metric?**       | Average CPUUtilization                    |
| **How to prepare for predictable spikes?**       | Scheduled Scaling                         |

---

## 🧾 **8. Visual Summary**

```
 ┌──────────────────────────────────────┐
 │           CloudWatch Metrics         │
 │  (CPU, Requests, Network, Custom)    │
 └──────────────────┬───────────────────┘
                    │
                    ▼
      ┌────────────────────────────┐
      │ Auto Scaling Group (ASG)   │
      │ ├ Target Tracking Policy   │
      │ ├ Step/Simple Policy       │
      │ ├ Scheduled Policy         │
      │ └ Predictive Policy        │
      └────────────┬───────────────┘
                   │
                   ▼
       ┌─────────────────────────┐
       │ EC2 Instances Adjusted  │
       └─────────────────────────┘
```









## ⚙️ **Auto Scaling Group (ASG) – Automatic Scaling Hands-On**

---

### 🧠 **Goal**

Set up **automatic scaling** so your ASG can **add or remove EC2 instances automatically** based on CPU utilization (or any other metric).

We’ll practice:

* Scheduled scaling
* Predictive scaling
* Dynamic scaling (with Target Tracking)

---

## 🗓️ **1. Scheduled Scaling**

Schedule capacity changes at specific times.

**Example use cases:**

* You expect heavy traffic during **weekends or marketing events**
* You want to scale down during **off-hours** to save cost

**Steps:**

1. Go to your **ASG → Automatic Scaling → Scheduled actions → Create**
2. Define:

   * **Start time / end time**
   * **Desired, Min, or Max capacity**
3. Example:

   * At **Saturday 8 AM**, increase min capacity to **10**
   * At **Sunday 11 PM**, decrease min capacity to **2**

✅ Used when **load is predictable**.

---

## 🧮 **2. Predictive Scaling**

Uses **machine learning** to automatically forecast load and scale ahead of time.

**How it works:**

* AWS analyzes your app’s **historical metrics** (like CPU or request counts)
* Builds a **forecast** for upcoming load
* Schedules scaling **before** the spike

**Setup:**

* Choose metric (CPU, ALB RequestCountPerTarget, etc.)
* Define a **target value** (e.g., 50% CPU)
* AWS automatically handles the rest

💡 Works best after **at least 24 hours** of steady metrics — typically used for **apps with repeating patterns** (e.g., business hours, daily peaks).

---

## ⚡ **3. Dynamic Scaling (Hands-On)**

Automatically adjusts instance count based on **real-time metrics**.

There are three types:

| Type                              | Description                             | Example                                |
| --------------------------------- | --------------------------------------- | -------------------------------------- |
| **Simple Scaling**                | Uses one CloudWatch alarm               | “If CPU > 70%, add 1 instance”         |
| **Step Scaling**                  | Uses multiple alarm thresholds          | “If CPU > 85%, add 2; if > 70%, add 1” |
| **Target Tracking (Recommended)** | Automatically maintains a target metric | “Keep average CPU = 40%”               |

---

### 🧰 **Step-by-Step: Target Tracking Policy**

1. Go to your **ASG → Automatic Scaling → Add Policy**
2. Choose **Dynamic Scaling Policy**
3. Select **Target Tracking Scaling Policy**
4. Name it `CPU-TargetTracking`
5. Metric: **Average CPU Utilization**
6. Target value: **40%**
7. Leave cooldown at default (300s)
8. **Save**

✅ This automatically creates **two CloudWatch alarms**:

* **AlarmHigh** → Scale Out (when CPU > 40%)
* **AlarmLow** → Scale In (when CPU < 28%)

---

## 🔬 **4. Stress Test to Trigger Scaling**

Now we’ll simulate load to make scaling happen.

### **Step 1 – Connect to EC2 Instance**

Use **EC2 Instance Connect** or your SSH key:

```bash
ssh -i mykey.pem ec2-user@<public-ip>
```

### **Step 2 – Install stress tool**

```bash
sudo yum install -y stress
```

### **Step 3 – Generate CPU load**

```bash
stress -c 4
```

→ Forces CPU utilization close to **100%**.

### **Step 4 – Observe scaling**

Go to:

```
EC2 → Auto Scaling Groups → Demo-ASG → Activity history
```

After a few minutes you’ll see:

```
Launching a new EC2 instance due to target tracking policy
```

Check under:

```
Instance management → Instances
```

✅ New EC2 instances appear (scale-out event)

---

## 📊 **5. CloudWatch Alarms in Action**

Go to:

```
CloudWatch → Alarms
```

You’ll see:

* `AlarmHigh` → State: **In ALARM** (CPU > 40%)
* `AlarmLow` → State: **OK** or **INSUFFICIENT_DATA**

**Details:**

* `AlarmHigh`: triggers scale-out after CPU > 40% for 3 data points (3 min)
* `AlarmLow`: triggers scale-in after CPU < 28% for 15 data points (15 min)

---

## 🔁 **6. Observe Scale-In**

Once you stop stressing the CPU:

* Press `Ctrl + C` to stop stress, or reboot instance:

  ```bash
  sudo reboot
  ```
* CPU utilization drops → alarmLow activates
* ASG automatically terminates extra instances

Check **Activity History:**

```
Terminating EC2 instance to match desired capacity
```

✅ ASG gradually scales back down to the minimum instance count.

---

## 📈 **7. Verification**

| Step               | Action             | Expected Result                 |
| ------------------ | ------------------ | ------------------------------- |
| Stress CPU         | Run `stress -c 4`  | CPU → 100%, triggers scale-out  |
| Stop stress        | Ctrl+C / reboot    | CPU → drops, triggers scale-in  |
| Check CloudWatch   | Two alarms visible | `AlarmHigh` and `AlarmLow`      |
| Check ASG activity | History updated    | Launch/Terminate events visible |

---

## ⚙️ **8. Cleanup**

When finished:

1. Stop stress test (if still running)
2. In **ASG → Automatic Scaling**, delete your **target tracking policy**
3. Optionally, delete the **ASG** and **launch template** to stop all EC2 billing

---

## 🧠 **9. Key Takeaways**

| Concept                 | Summary                                  |
| ----------------------- | ---------------------------------------- |
| **Target Tracking**     | Simplest, recommended scaling method     |
| **Automatic Scaling**   | Adds/removes instances based on metrics  |
| **Scaling Alarms**      | Created automatically by target tracking |
| **Predictive Scaling**  | Uses ML to forecast and pre-scale        |
| **Scheduled Scaling**   | Manual scheduling of capacity changes    |
| **Cooldown Period**     | Default 300s; prevents rapid oscillation |
| **Stress Tool**         | Useful for testing scaling logic         |
| **Detailed Monitoring** | Provides 1-minute metric granularity     |

---

## 🧾 **10. Visual Summary**

```
CloudWatch Metric (CPU) ───► AlarmHigh / AlarmLow
        │
        ▼
  ┌─────────────────────────────┐
  │ Auto Scaling Group (Demo-ASG) │
  │  • Min: 1                    │
  │  • Max: 3                    │
  │  • Target: 40% CPU           │
  └───────────┬─────────────────┘
              │
   ┌──────────▼─────────┐
   │ EC2 Instances Auto │
   │ Added / Removed    │
   └────────────────────┘
```







## 📊 **Lecture: Visualizing ASG Metrics in CloudWatch Dashboard**

---

### 🎯 **Goal**

By the end of this lab, students will:

* Create a **CloudWatch Dashboard**
* Add **ASG metrics** (CPU, instance count, network)
* Observe **scale in/out events in real time**
* Understand how to interpret these graphs for troubleshooting and tuning scaling policies

---

## 🧩 **1. What Is a CloudWatch Dashboard?**

A **CloudWatch Dashboard** is a customizable view that displays your AWS metrics in one screen.

You can:

* Monitor **ASG**, **EC2**, **ELB**, and **CloudWatch Alarms**
* View **CPU spikes**, **instance count changes**, and **traffic load**
* Compare multiple metrics side by side

✅ This is essential for real-world **DevOps monitoring and alerting setups**.

---

## ⚙️ **2. Step-by-Step: Create the Dashboard**

1. Go to **CloudWatch Console**

   ```
   AWS Console → CloudWatch → Dashboards
   ```
2. Click **Create Dashboard**
3. Name it: `ASG-Monitoring-Dashboard`
4. Choose **Line widget** (for graphs)
5. Click **Configure**

---

## 📈 **3. Add Key Metrics to the Dashboard**

Let’s add 4 key widgets that every DevOps engineer should monitor for ASGs.

---

### 🧠 **Widget 1: Average CPU Utilization**

* **Namespace:** `AWS/EC2`
* **Metric:** `CPUUtilization`
* **Statistic:** Average
* **Period:** 1 minute (requires Detailed Monitoring)
* **Filter:** Select your **Auto Scaling Group instances**
* **Label:** “Average CPU Utilization”

✅ This shows how busy your EC2 instances are.

---

### 🧩 **Widget 2: ASG Group Desired, InService, and Pending Instances**

* **Namespace:** `AWS/AutoScaling`
* **Metrics:**

  * `GroupDesiredCapacity`
  * `GroupInServiceInstances`
  * `GroupPendingInstances`
* **Dimensions:** Choose your ASG (`Demo-ASG`)
* **Statistic:** Average
* **Label:** “ASG Capacity Overview”

✅ Shows when scaling events occur (launch/terminate).

---

### 🌐 **Widget 3: NetworkIn / NetworkOut**

* **Namespace:** `AWS/EC2`
* **Metrics:**

  * `NetworkIn`
  * `NetworkOut`
* **Statistic:** Sum
* **Period:** 1 minute
* **Label:** “Network Traffic (bytes)”

✅ Useful for **data-heavy** applications or detecting high traffic peaks.

---

### 🧱 **Widget 4: Application Load Balancer Request Count**

If your ASG is behind an ALB:

* **Namespace:** `AWS/ApplicationELB`
* **Metric:** `RequestCountPerTarget`
* **Statistic:** Sum
* **Dimension:** Choose your Target Group (e.g., `demo-tg-alb`)
* **Label:** “Requests Per Target”

✅ Helps correlate **incoming traffic** with **scaling actions**.

---

### 💡 Optional Widget: CloudWatch Alarms State

* **Widget Type:** “Alarm Status”
* Select alarms created by your Target Tracking Policy:

  * `AlarmHigh`
  * `AlarmLow`
* Label: “Scaling Alarms”

✅ Visually shows which alarm triggered (red = active).

---

## 🎨 **4. Arrange and Save Dashboard**

* Drag widgets to organize logically:

  ```
  ┌──────────────────────────────────────────────┐
  │ Average CPU Utilization (%)                  │
  ├──────────────────────────────────────────────┤
  │ ASG Capacity Overview (Desired vs InService) │
  ├──────────────────────────────────────────────┤
  │ Network Traffic (In/Out Bytes)               │
  ├──────────────────────────────────────────────┤
  │ Requests Per Target (ALB)                    │
  └──────────────────────────────────────────────┘
  ```

* Click **Save Dashboard**

---

## 🔍 **5. Test in Real Time**

To see the dashboard in action:

1. **Run the stress test** again on one instance:

   ```bash
   stress -c 4
   ```
2. Wait 2–3 minutes.
3. Watch:

   * **CPUUtilization** spike upward
   * **AlarmHigh** trigger
   * **ASG Desired / InService Instances** increase
4. Stop stress test with `Ctrl + C`
5. Observe:

   * **CPUUtilization** drops
   * **AlarmLow** triggers
   * **Instances** terminate (scale-in)

✅ You’ll see the entire auto-scaling process visually.

---

## 🧮 **6. Understanding the Dashboard**

| Metric                  | What It Shows             | What To Look For                           |
| ----------------------- | ------------------------- | ------------------------------------------ |
| **CPU Utilization**     | Resource stress level     | Sudden spikes → scaling triggers           |
| **Desired / InService** | Instance count            | Confirms scaling in/out actions            |
| **NetworkIn/Out**       | Load intensity            | High traffic → possible cause of scale-out |
| **Requests per Target** | User load via ALB         | Useful for performance tuning              |
| **Alarm Status**        | Which threshold triggered | Red (scale out), Green (scale in)          |

---

## 🧠 **7. Best Practices**

| Area            | Recommendation                                                  |
| --------------- | --------------------------------------------------------------- |
| **Granularity** | Enable **1-minute detailed monitoring** on ASG                  |
| **Metrics**     | Track both **ASG-level** and **EC2-level** metrics              |
| **Naming**      | Use consistent names (e.g., `demo-asg`, `demo-tg-alb`)          |
| **Alarms**      | Always have one for scale-out and one for scale-in              |
| **Retention**   | Keep dashboard open during load testing                         |
| **Automation**  | Optionally export to JSON for IaC (Terraform or CloudFormation) |

---

## 🧾 **8. Example Dashboard JSON (optional)**

If you want to create via CLI or CloudFormation:

```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 24,
      "height": 6,
      "properties": {
        "metrics": [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "Demo-ASG"]],
        "title": "Average CPU Utilization",
        "period": 60,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 24,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "Demo-ASG"],
          ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "Demo-ASG"]
        ],
        "title": "ASG Capacity Overview"
      }
    }
  ]
}
```

---

## 🎓 **9. Key Takeaways**

| Concept                        | Summary                                                              |
| ------------------------------ | -------------------------------------------------------------------- |
| **CloudWatch Dashboard**       | Custom visualization of ASG performance                              |
| **Dynamic scaling visibility** | Instantly shows scale events & CPU trends                            |
| **Metrics correlation**        | Links alarms, traffic, and scaling patterns                          |
| **Practical DevOps skill**     | Used in every production-grade AWS setup                             |
| **Next Step**                  | Integrate with **SNS** or **Slack alerts** for scaling notifications |









