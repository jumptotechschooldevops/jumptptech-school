---
title: "ROUTE 53"
description: "🌐 What is DNS?   DNS (Domain Name System) translates domain names (like www.google.com) into..."
published: 2025-10-27
source: "https://dev.to/jumptotech/route-53-3d6p"
tags: []
---

# ROUTE 53



### 🌐 What is DNS?

**DNS (Domain Name System)** translates **domain names** (like `www.google.com`) into **IP addresses** that computers use to communicate (like `142.250.190.14`).

---

### 🧩 DNS Components

| Term                       | Description                                | Example                            |
| -------------------------- | ------------------------------------------ | ---------------------------------- |
| **Domain Registrar**       | Company where you register your domain.    | Route 53, GoDaddy                  |
| **DNS Record**             | Defines how domain names map to resources. | A, AAAA, CNAME, NS                 |
| **Zone File**              | File that contains DNS records.            | Maps hostnames to IPs              |
| **Name Server**            | Server that resolves DNS queries.          | `ns-123.awsdns-45.net`             |
| **TLD (Top-Level Domain)** | The extension part of a domain.            | `.com`, `.org`, `.us`              |
| **Second-Level Domain**    | The main part before TLD.                  | `google.com`                       |
| **Subdomain**              | Child of a domain.                         | `www.google.com`, `api.google.com` |
| **FQDN**                   | Fully Qualified Domain Name.               | `api.www.example.com.`             |

---

### ⚙️ How DNS Resolution Works

1. **Browser request:** User enters `example.com`.
2. **Local DNS Server:** Checks its cache. If unknown →
3. **Root DNS Server:** Directs to `.com` nameserver.
4. **TLD (.com) Server:** Points to the `example.com` nameserver.
5. **Authoritative DNS Server:** Returns IP (e.g., `9.10.11.12`).
6. **Browser caches the answer** and connects to the web server.

---

### 💡 Key Idea

DNS is **hierarchical** and **distributed**, enabling the entire Internet to work seamlessly by **mapping names → IP addresses** efficiently.



 Amazon Route 53 — AWS DNS Service

### 🔹 What is Route 53?

**Amazon Route 53** is a **highly available, scalable, and fully managed** **authoritative DNS** service.

* **Authoritative** means you (the customer) **own and manage DNS records** — you control which IP addresses or resources your domains point to.
* It acts as both:

  * a **DNS service**, and
  * a **Domain Registrar** (you can buy and register domains directly in Route 53).

---

### 💡 Example

You have an **EC2 instance** with a **public IP**: `54.22.33.44`,
and you want users to reach it via `example.com`.

In Route 53:

1. You create a **Hosted Zone** for `example.com`.
2. You create an **A record** mapping:

   ```
   example.com → 54.22.33.44
   ```
3. When a client types `example.com`, Route 53 returns that IP.

---

### ⚙️ Route 53 DNS Record Components

Each DNS record contains:

| Component              | Description                         | Example                               |
| ---------------------- | ----------------------------------- | ------------------------------------- |
| **Name**               | Domain/Subdomain                    | `example.com`, `www.example.com`      |
| **Type**               | Record type                         | `A`, `AAAA`, `CNAME`, `NS`            |
| **Value**              | Target IP or hostname               | `54.22.33.44`, `elb.amazonaws.com`    |
| **TTL (Time-to-Live)** | How long resolvers cache the record | `300 seconds`                         |
| **Routing Policy**     | How Route 53 responds to queries    | Simple, Weighted, Latency-based, etc. |

---

### 📘 Common DNS Record Types in Route 53

| Record Type                | Description                                     | Example                         |
| -------------------------- | ----------------------------------------------- | ------------------------------- |
| **A (Address)**            | Maps a hostname → IPv4 address                  | `example.com → 1.2.3.4`         |
| **AAAA (Quad-A)**          | Maps a hostname → IPv6 address                  | `example.com → 2001:db8::1`     |
| **CNAME (Canonical Name)** | Maps one hostname → another hostname            | `www.example.com → example.com` |
| **NS (Name Server)**       | Identifies the name servers for the hosted zone | `ns-123.awsdns-45.net`          |

> ⚠️ **CNAME Restriction:**
> You *cannot* create a CNAME at the **root domain** (`example.com`), only for **subdomains** like `www.example.com`.

---

### 🧱 Hosted Zones

A **Hosted Zone** is a **container** for all DNS records for a domain.

#### Two Types:

| Type                    | Description                       | Use Case                         |
| ----------------------- | --------------------------------- | -------------------------------- |
| **Public Hosted Zone**  | Accessible from the Internet      | `myapp.com`, `api.myapp.com`     |
| **Private Hosted Zone** | Resolvable *only* within your VPC | `webapp.internal`, `db.internal` |

---

### 🌍 Public vs Private Example

**Public Hosted Zone**

* Client: browser on the Internet
* Domain: `example.com`
* Response: Route 53 returns public IP (`54.22.33.44`)
* Access: anyone can resolve it

**Private Hosted Zone**

* Domain: `database.example.internal`
* Resolved only **inside your VPC**
* Response: private IP (`10.0.0.10`)
* Access: internal EC2 instances only

---

### 💰 Pricing Overview

| Feature             | Cost                    |
| ------------------- | ----------------------- |
| Hosted Zone         | ~$0.50 per month        |
| Domain Registration | starts at ~$12 per year |

---

### 🧠 Why the name “Route 53”?

Because **DNS traditionally runs on port 53**, hence the name.

---

### Summary

* Route 53 = AWS’s **authoritative DNS** + **domain registrar**
* Supports **A, AAAA, CNAME, NS** records (and advanced ones)
* Uses **hosted zones** to group DNS records
* Offers both **public** and **private** zones
* Backed by **100% availability SLA**




 Registering a Domain in Amazon Route 53


### 🔹 Step 1: Open the Route 53 Console

1. In the AWS Management Console, open **Route 53**.
2. On the left-hand menu, select **Register Domains**.
3. If prompted, switch to the **new console experience** — this is the one AWS is moving forward with.

---

### 🔹 Step 2: Search for an Available Domain

1. In the **Domain name** search box, type a name you’d like (e.g., `mydevopsbootcamp.com`).
2. Route 53 checks whether the domain is available.

   * If it’s taken → choose another name.
   * If available → you’ll see a price (e.g., `$13 USD per year`).
3. Select the domain and click **Add to cart / Proceed to checkout**.

---

### 🔹 Step 3: Configure Domain Registration

* **Duration:** choose 1 year (extend later if needed).
* **Auto-renew:**

  * **ON** if you plan to keep the domain long-term.
  * **OFF** if you just need it temporarily (for this course).
* **Privacy Protection:** **Enable it** – hides your real name, address, and phone number in WHOIS data.

Click **Next**.

---

### 🔹 Step 4: Contact Information

Fill in or confirm:

* **Registrant contact** (you, the owner)
* **Administrative contact**
* **Technical contact**
  You can reuse the same information for all three.

---

### 🔹 Step 5: Review and Purchase

* Review all details carefully.
* Accept the **Terms and Conditions**.
* Click **Purchase / Submit**.

> ⚠️ Important: This will immediately charge your AWS account (~ $12–$15 USD per year).

The registration process may take a few minutes to a few hours.

---

### 🔹 Step 6: Verify Your Domain and Hosted Zone

Once registration completes:

1. Go back to **Route 53 → Hosted zones**.
2. You’ll now see your new domain (e.g., `mydevopsbootcamp.com`).
3. Open it — you’ll notice **two default DNS records**:

| Record Type                  | Purpose                                                       | Example                                        |
| ---------------------------- | ------------------------------------------------------------- | ---------------------------------------------- |
| **NS (Name Server)**         | Points to AWS Route 53 name servers used for DNS queries      | `ns-123.awsdns-45.com`, `ns-987.awsdns-10.org` |
| **SOA (Start of Authority)** | Stores basic info about the zone (owner, refresh times, etc.) | Created automatically                          |

> ✅ These records tell the internet that **Route 53** is now the *authoritative* DNS for your domain.

---

### 🧩 Step 7: What’s Next

Now that your **domain** and **hosted zone** exist, you can start creating **custom DNS records**:

* `A` record → maps domain to EC2 public IP
* `CNAME` → points a subdomain to another host
* `MX` → for email
* and more.

Creating Your First DNS Record in Amazon Route 53


### 🔹 Step 1: Open Your Hosted Zone

1. In the AWS Console, open **Route 53 → Hosted zones**.
2. Click on your hosted zone (for example, `stephanetheteacher.com`).
3. You’ll see your default `NS` and `SOA` records.
4. Now, click **“Create record.”**

---

### 🔹 Step 2: Create a Simple A Record

Fill out the record form:

| Field                  | Example            | Description                           |
| ---------------------- | ------------------ | ------------------------------------- |
| **Record name**        | `test`             | Creates `test.stephanetheteacher.com` |
| **Record type**        | `A – IPv4 address` | Maps domain → IPv4 address            |
| **Value**              | `11.22.33.44`      | Example IP (not real)                 |
| **TTL (Time to Live)** | `300` seconds      | How long resolvers cache this record  |
| **Routing policy**     | *Simple*           | Default policy for basic routing      |

Click **Create record**.

✅ Record created!
This tells Route 53 that `test.stephanetheteacher.com → 11.22.33.44`.

---

### 🔹 Step 3: Test the Record from the Command Line

Although the IP isn’t real, we can still confirm that the DNS lookup works.

#### Option A – Use AWS CloudShell

1. Open the **AWS Management Console**.
2. Click the **CloudShell** icon (top menu bar).
3. Wait until the terminal window is ready.

Now install DNS utilities (only needed once):

```bash
sudo yum install -y bind-utils
```

Clear the screen:

```bash
clear
```

#### Option B – Use Your Local Machine

* **Windows:** use `nslookup`
* **Mac/Linux:** use `dig`

---

### 🔹 Step 4: Run the Lookup

#### Using nslookup

```bash
nslookup test.stephanetheteacher.com
```

Expected output:

```
Name: test.stephanetheteacher.com
Address: 11.22.33.44
```

#### Using dig

```bash
dig test.stephanetheteacher.com
```

You’ll see:

```
;; ANSWER SECTION:
test.stephanetheteacher.com. 300 IN A 11.22.33.44
```

✅ This confirms that Route 53 is **responding** and returning the A record value.

---

### 🔹 Step 5: What Did We Learn?

* Route 53 is now **authoritative** for our domain.
* We successfully added and resolved an A record.
* Even though no web server exists at that IP, DNS resolution still works.
* We verified it using both **nslookup** and **dig** commands.

---






 Preparing EC2 Instances and a Load Balancer for Route 53 Integration

### 🎯 Goal

Before using Route 53 to route global traffic, you’ll:

* Launch **three EC2 instances in different AWS regions**
* Deploy a simple **“Hello World” web page**
* Create an **Application Load Balancer (ALB)** to front the instances

---

### 🧱 Step 1 – Launch Three EC2 Instances

You’ll create one instance per region to simulate multi-region deployments.

| Region                         | Example AZ      | Instance Type | Notes                          |
| ------------------------------ | --------------- | ------------- | ------------------------------ |
| **EU Central 1 (Frankfurt)**   | eu-central-1b   | t2.micro      | Will host the ALB              |
| **US East 1 (N. Virginia)**    | us-east-1a      | t2.micro      | For latency-based routing demo |
| **AP Southeast 1 (Singapore)** | ap-southeast-1b | t2.micro      | For Asia traffic demo          |

#### Instance Settings

* **AMI:** Amazon Linux 2 (64-bit x86)
* **Key Pair:** None (required only if SSH is needed)
* **Security Group:** Allow ports 22 (SSH) and 80 (HTTP) from anywhere
* **User Data:** Bootstrap web server

Example User Data script:

```#!/bin/bash
yum update -y
amazon-linux-extras install -y nginx1
systemctl start nginx
systemctl enable nginx
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<h1>Hello World from EC2 in $AZ (using Nginx)</h1>" > /usr/share/nginx/html/index.html

```

✅ **Result:**
Each instance serves a page like “Hello World from AZ eu-central-1b”.

---

### 🌎 Step 2 – Verify Instances

1. Copy each instance’s **public IP**.
2. Open it in a browser:

   ```
   http://<public-ip>
   ```
3. Confirm you see the message with the correct availability zone.

Keep a record of each IP and region for the next step.

---

### ⚙️ Step 3 – Create an Application Load Balancer (ALB)

We’ll use the Frankfurt region for the load balancer.

1. In EC2 → **Load Balancers** → **Create Load Balancer** → **Application Load Balancer**
2. **Name:** `DemoRoute53ALB`
3. **Scheme:** Internet-facing  • **IP Version:** IPv4
4. **Subnets:** Select at least 2-3 subnets in different AZs
5. **Security Group:** Use the same SG that allows HTTP (Port 80)
6. **Listeners:** HTTP → Forward to Target Group

#### Create Target Group

* **Name:** `demo-tg-route53`
* **Target Type:** Instances
* Register your Frankfurt EC2 instance
* Health Check: HTTP on `/`
* Create Target Group and attach it to the ALB

Click **Create Load Balancer**.

Wait for the state to be “Active”.

---

### 🔍 Step 4 – Test the ALB

1. Copy the ALB **DNS name** (e.g., `DemoRoute53ALB-123456789.eu-central-1.elb.amazonaws.com`).
2. Open it in a browser:

   ```
   http://DemoRoute53ALB-123456789.eu-central-1.elb.amazonaws.com
   ```
3. You should see:

   ```
   Hello World from AZ eu-central-1b
   ```

✅ The ALB is now serving traffic to your EC2 instance.

---

### 📋 Summary

| Component                     | Purpose                                                 |
| ----------------------------- | ------------------------------------------------------- |
| **3 EC2 Instances**           | Serve simple “Hello World” pages from different regions |
| **Application Load Balancer** | Distribute traffic to targets in Frankfurt              |
| **Security Groups**           | Allow HTTP/SSH access                                   |
| **Bootstrap User Data**       | Automates web server setup                              |
| **Verification**              | Confirm HTTP access and AZ display                      |







 Understanding TTL (Time To Live) in Route 53

### 🎯 Objective

Learn what **TTL (Time To Live)** means in DNS, how caching affects record updates, and how to test it practically in Route 53.

---

### 🔹 What is TTL?

**TTL (Time To Live)** defines how long a **DNS resolver or client** should **cache a DNS record** before querying Route 53 again.

When you query:

```
myapp.example.com
```

the DNS resolver replies with:

* Record type: `A`
* IP address: `54.22.33.44`
* **TTL:** 300 seconds

That means the client should **cache** this response for 300 seconds.

---

### 🔹 Why TTL Matters

| TTL Value                      | Effect                                                                                        | Example                                               |
| ------------------------------ | --------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| **High TTL (e.g., 24 hours)**  | Fewer DNS lookups → Lower cost, faster response — but slower propagation when record changes. | Cached results stay valid longer, even if IP changes. |
| **Low TTL (e.g., 60 seconds)** | More DNS lookups → Slightly higher cost — but updates propagate faster.                       | Useful during migrations or testing.                  |

---

### 🧠 Real-World Strategy

When planning DNS changes:

1. **Reduce TTL** (e.g., from 24h → 1min) 24 hours before making the change.
2. Make your **DNS update**.
3. **Increase TTL** back after all clients have cached the new IP.

This ensures a smooth transition without downtime.

---

### ⚙️ Hands-On Example

#### Step 1 – Create a DNS Record

In your hosted zone:

* **Name:** `demo.stephanetheteacher.com`
* **Type:** `A`
* **Value:** `Public IP of EU Central (Frankfurt) instance`
* **TTL:** `2 minutes (120 seconds)`

✅ Create the record.

---

#### Step 2 – Verify with Browser and CLI

* In Chrome: visit

  ```
  http://demo.stephanetheteacher.com
  ```

  → Displays *Hello from eu-central-1b*

* In CloudShell:

  ```bash
  nslookup demo.stephanetheteacher.com
  dig demo.stephanetheteacher.com
  ```

  Output shows TTL (e.g., `115` seconds left).

Each second the TTL counts down until it expires.

---

#### Step 3 – Update Record While Cached

Edit the record:

* New **IP:** public IP of AP-Southeast-1 instance (Singapore)

Run again:

```bash
dig demo.stephanetheteacher.com
```

✅ You’ll still see the old IP (Frankfurt) until the TTL expires (cached result).

---

#### Step 4 – Wait for TTL Expiration

After ~120 seconds:

* Refresh Chrome → Now shows *Hello from ap-southeast-1b*
* `dig` output shows:

  ```
  ;; ANSWER SECTION:
  demo.stephanetheteacher.com. 120 IN A <new IP>
  ```

This proves that **DNS caching obeys TTL**.

---

### 🧩 Key Takeaways

* TTL defines how long a record is cached by clients/resolvers.
* Higher TTL = fewer DNS queries, slower propagation.
* Lower TTL = faster record updates, more DNS queries.
* TTL doesn’t apply to **Alias records** (special AWS feature).
* Always plan TTL adjustments **before** DNS changes.





Perfect — this section is your **CNAME vs Alias Record** lecture, and it’s one of the most important topics in understanding how **Route 53 integrates with AWS services** like ALB, CloudFront, and S3 Websites.

Here’s a **clean, structured, instructor-ready version** of your explanation — ideal for slides, teaching scripts, or written course material.

---

## 🧭 Lecture 7 – CNAME vs Alias Records in Amazon Route 53

### 🎯 Objective

Understand the **difference between CNAME and Alias records**, when to use each, and how to configure them correctly in AWS Route 53.

---

### 🔹 Why We Need CNAMEs and Aliases

Many AWS resources — like **Application Load Balancers**, **CloudFront distributions**, or **S3 static websites** — expose a **public DNS hostname** such as:

```
demo-alb-123456789.eu-central-1.elb.amazonaws.com
```

Instead of sharing this long AWS DNS name, we can map it to our **own domain**:

```
myapp.mydomain.com
```

There are **two ways** to achieve this mapping:

* Using a **CNAME record**
* Using an **Alias record (AWS-specific)**

---

### ⚙️ Option 1 – CNAME Record

**Definition:**
A CNAME (Canonical Name) record maps **one hostname → another hostname**.

**Example:**

```
app.mydomain.com → demo-alb-123456789.eu-central-1.elb.amazonaws.com
```

#### ✅ Characteristics:

* Works for **subdomains only** (e.g., `www.mydomain.com`, `api.mydomain.com`)
* **Cannot** be used at the **root (apex)** of a domain (`mydomain.com`)
* Standard **DNS record** type (not AWS-specific)
* You can set a custom **TTL**

#### ❌ Limitations:

If you try to create a **CNAME at the domain apex**, Route 53 shows:

```
Bad request: CNAME is not permitted at apex of this zone.
```

---

### ⚙️ Option 2 – Alias Record (AWS Extension)

**Definition:**
An **Alias record** is an **AWS-specific extension** of DNS.
It acts like a CNAME but is **integrated with AWS resources**.

**Example:**

```
myalias.mydomain.com (Alias A record) → Application Load Balancer
```

#### ✅ Characteristics:

| Feature                           | Alias Record                      |
| --------------------------------- | --------------------------------- |
| Works at domain **apex**          | ✅ Yes                             |
| Works for **subdomains**          | ✅ Yes                             |
| Target can be an **AWS resource** | ✅ Yes                             |
| **TTL**                           | Managed automatically by Route 53 |
| **Free**                          | ✅ No charge for Alias queries     |
| **Health checks**                 | ✅ Integrated automatically        |
| **Type**                          | A (IPv4) or AAAA (IPv6)           |

---

### 🧩 Common Alias Targets

You can create Alias records that point to:

| AWS Service                              | Example Use                         |
| ---------------------------------------- | ----------------------------------- |
| **Elastic Load Balancers (ALB/NLB/CLB)** | `app.mydomain.com` → ALB            |
| **CloudFront Distributions**             | `cdn.mydomain.com` → CloudFront     |
| **API Gateway Custom Domain**            | `api.mydomain.com` → API Gateway    |
| **Elastic Beanstalk Environments**       | `app.mydomain.com` → Beanstalk app  |
| **S3 Websites (static site hosting)**    | `mydomain.com` → S3 bucket endpoint |
| **VPC Interface Endpoints**              | Private service connections         |
| **Global Accelerator**                   | Low-latency global endpoints        |
| **Another Route 53 record (same zone)**  | Nested routing setups               |

> ⚠️ You **cannot** create an Alias that points to an **EC2 instance DNS name**.

---

### 🧠 Key Difference Summary

| Feature                      | **CNAME**                            | **Alias**                         |
| ---------------------------- | ------------------------------------ | --------------------------------- |
| Works for root domain (apex) | ❌ No                                 | ✅ Yes                             |
| Works for subdomains         | ✅ Yes                                | ✅ Yes                             |
| Can point to AWS resources   | ✅ Yes (indirectly)                   | ✅ Yes (directly)                  |
| Custom TTL                   | ✅ Yes                                | ❌ Managed by AWS                  |
| DNS Standard                 | ✅ Yes                                | ❌ AWS-specific                    |
| Query Cost                   | Paid per lookup                      | ✅ Free                            |
| Health check integration     | ❌ No                                 | ✅ Yes                             |
| Use Case                     | Non-AWS targets (e.g., GitHub Pages) | AWS targets (ALB, S3, CloudFront) |

---

### 💻 Hands-On Example

#### 1️⃣ Create a CNAME Record

* **Name:** `myapp.stephanetheteacher.com`
* **Type:** `CNAME`
* **Value:** `demo-alb-123456789.eu-central-1.elb.amazonaws.com`

✅ Works perfectly for **subdomains**.
When you open the browser:

```
http://myapp.stephanetheteacher.com
```

You’ll see:
**“Hello World from eu-central-1c”**

---

#### 2️⃣ Create an Alias Record

* **Name:** `myalias.stephanetheteacher.com`
* **Type:** `A (Alias)`
* **Alias target:**

  * **Region:** `eu-central-1`
  * **Load Balancer:** `DemoRoute53ALB`
* **Evaluate target health:** Yes
* **Create record**

✅ Access:

```
http://myalias.stephanetheteacher.com
```

Shows:
**“Hello World from eu-central-1c”**

💡 Alias queries are **free** and **auto-update** if ALB IPs change.

---

#### 3️⃣ CNAME at the Root Domain (Fails)

* Try creating:

  ```
  stephanetheteacher.com → demo-alb-123456789.eu-central-1.elb.amazonaws.com
  ```

  ❌ Error: “CNAME is not permitted at apex of this zone.”

---

#### 4️⃣ Alias at the Root Domain (Works)

* Create:

  * **Name:** *(leave blank)* → represents `stephanetheteacher.com`
  * **Type:** `A (Alias)`
  * **Alias target:** `DemoRoute53ALB`
  * **Region:** `eu-central-1`

✅ Works perfectly:

```
http://stephanetheteacher.com
```

Displays:
**“Hello World from eu-central-1b”**

---

### ✅ Summary

| Feature                  | **CNAME**      | **Alias**                                 |
| ------------------------ | -------------- | ----------------------------------------- |
| Root domain allowed      | ❌              | ✅                                         |
| TTL configurable         | ✅              | ❌ Auto-managed                            |
| AWS resource integration | Limited        | Full                                      |
| Cost                     | Paid per query | ✅ Free                                    |
| Use Case                 | External hosts | AWS resources (ALB, S3, CloudFront, etc.) |






Routing Policies in Amazon Route 53


### 🔹 What is a Routing Policy?

A **routing policy** determines **how Route 53 responds** to DNS queries.
It does **not** perform real network routing — it only **tells the client which endpoint (IP or hostname) to contact**.

Once the client receives the answer, **it connects directly** to that endpoint (for example, to an EC2 instance or an ALB).

---

### ⚙️ Available Routing Policies in Route 53

| Routing Policy        | Purpose                                                               |
| --------------------- | --------------------------------------------------------------------- |
| **Simple**            | Default. Maps a domain to one or multiple records randomly.           |
| **Weighted**          | Distributes traffic based on assigned weights.                        |
| **Failover**          | Sends traffic to a backup resource if the primary fails.              |
| **Latency-based**     | Routes clients to the region with lowest latency.                     |
| **Geolocation**       | Routes based on the user’s geographic location.                       |
| **Multivalue Answer** | Returns multiple healthy IP addresses for simple load balancing.      |
| **Geoproximity**      | Routes based on proximity and bias (requires AWS Global Accelerator). |

---

## 🧩 Simple Routing Policy

### 🔹 Definition

The **Simple Routing Policy** is the **most basic** one.
It allows you to map a hostname to:

* **One** resource → a single IP or Alias target, or
* **Multiple resources** → several IP addresses returned in one response.

The client chooses **randomly** which IP to use when multiple addresses are returned.

---

### 🧠 Key Concepts

| Feature           | Description                                            |
| ----------------- | ------------------------------------------------------ |
| **Use case**      | Map a domain to a single endpoint (e.g., EC2, ALB).    |
| **Health checks** | Not supported for Simple Routing.                      |
| **Alias support** | Can point to one AWS resource (e.g., ALB, S3 Website). |
| **TTL**           | Defines how long clients cache the record.             |

---

### 🧱 Hands-On Demo – Simple Routing Policy

#### 1️⃣ Create a Record

* **Name:** `simple.stephanetheteacher.com`
* **Type:** A record (IPv4)
* **Value:** Public IP of your `ap-southeast-1` instance
* **TTL:** 20 seconds
* **Routing policy:** Simple

✅ Click **Create record**.

---

#### 2️⃣ Verify the Record

Open your browser:

```
http://simple.stephanetheteacher.com
```

You should see:

```
Hello World from ap-southeast-1b
```

From AWS CloudShell:

```bash
sudo yum install -y bind-utils   # install dig/nslookup
dig simple.stephanetheteacher.com
```

Output:

```
;; ANSWER SECTION:
simple.stephanetheteacher.com. 20 IN A 13.210.xxx.xxx
```

---

#### 3️⃣ Add Multiple IP Addresses

Edit the record → add a second IP:

* `ap-southeast-1` instance IP
* `us-east-1` instance IP

Save the record.

---

#### 4️⃣ Observe DNS Responses

Run:

```bash
dig simple.stephanetheteacher.com
```

Now you’ll see **two A records**:

```
;; ANSWER SECTION:
simple.stephanetheteacher.com. 20 IN A 13.210.xxx.xxx
simple.stephanetheteacher.com. 20 IN A 3.81.xxx.xxx
```

Each time the client makes a new DNS lookup, it may randomly select one IP.
Browser refresh may alternate between regions:

* “Hello World from ap-southeast-1b”
* “Hello World from us-east-1a”

✅ This confirms **Simple Routing** works and DNS resolves randomly when multiple records are returned.

---

### 📘 Summary

| Property      | Simple Routing Policy                            |
| ------------- | ------------------------------------------------ |
| DNS function  | Maps domain → one or more IP addresses           |
| Routing logic | Random client-side selection                     |
| Health checks | Not supported                                    |
| TTL           | Configurable                                     |
| Alias support | Yes (for single AWS resource)                    |
| Use case      | Simple apps or testing multi-region connectivity |







 Weighted Routing Policy in Amazon Route 53


### 🔹 What Is Weighted Routing?

Weighted routing allows you to **split traffic across multiple resources** (e.g., EC2 instances or regions) based on **weights** you define.

It’s handled **at the DNS level** — Route 53 doesn’t route network traffic itself.
Instead, it decides **which IP or endpoint to return** to the client for each DNS query.

---

### ⚙️ How It Works

1. You create **multiple records with the same name and type** (e.g., all `A` records for `weighted.example.com`).
2. Each record is assigned a **weight** (a relative number, not necessarily adding up to 100).
3. When Route 53 receives DNS queries, it responds proportionally:

   * Record A → weight 70 → ≈ 70 % of queries
   * Record B → weight 20 → ≈ 20 % of queries
   * Record C → weight 10 → ≈ 10 % of queries

> 💡 The percentage of traffic ≈
> weight of record ÷ sum of all weights × 100 %

---

### 🧩 Common Use Cases

| Scenario                             | Description                                               |
| ------------------------------------ | --------------------------------------------------------- |
| **Gradual deployment / A/B testing** | Send a small % of users to a new app version.             |
| **Multi-region balancing**           | Route more queries to specific regions.                   |
| **Traffic migration**                | Shift traffic progressively from one instance to another. |
| **Maintenance / zero weight**        | Temporarily stop sending queries to a resource.           |

If you set a record’s **weight = 0**, no queries go to that record (useful for quick cut-overs).

---

### 🧱 Hands-On Demo – Weighted Routing Policy

#### 1️⃣ Create Records

In Route 53 → Hosted zone → “Create record”.

| Setting            | Example                           |
| ------------------ | --------------------------------- |
| **Name**           | `weighted.stephanetheteacher.com` |
| **Type**           | A (IPv4)                          |
| **Routing Policy** | Weighted                          |
| **TTL**            | 3 seconds (for demo only)         |

Now add three records with the same name but different IPs and weights:

| Region                     | IP Address       | Weight | Record ID   |
| -------------------------- | ---------------- | ------ | ----------- |
| AP Southeast 1 (Singapore) | `13.xxx.xxx.xxx` | 10     | `Southeast` |
| US East 1 (N. Virginia)    | `3.xxx.xxx.xxx`  | 70     | `USEast`    |
| EU Central 1 (Frankfurt)   | `18.xxx.xxx.xxx` | 20     | `EU`        |

✅ Click **Create records**.

---

#### 2️⃣ Verify in the Console

You’ll now see three separate records under the same name, each with its own weight and value.

---

#### 3️⃣ Test with Browser and CLI

**Browser:**
Open

```
http://weighted.stephanetheteacher.com
```

You’ll usually see
**“Hello World from us-east-1a”** (70 % weight).

**CloudShell / Terminal:**

```bash
dig weighted.stephanetheteacher.com
```

Sample output:

```
;; ANSWER SECTION:
weighted.stephanetheteacher.com. 3 IN A 3.85.xxx.xxx
```

TTL = 3 seconds → cache expires quickly so you can test rotation.

Run `dig` multiple times → occasionally you’ll see:

* IP from US East 1 (≈ 70 %)
* IP from EU Central 1 (≈ 20 %)
* IP from AP Southeast 1 (≈ 10 %)

---

### 🧠 Key Characteristics

| Feature                  | Description                                    |
| ------------------------ | ---------------------------------------------- |
| **DNS Name / Type**      | Must match across all records                  |
| **Weights**              | Relative values (do not need to sum to 100)    |
| **Traffic Distribution** | Proportional to weight                         |
| **Health Checks**        | Optional – Route 53 can skip unhealthy records |
| **TTL**                  | Controls cache refresh rate                    |
| **Zero Weight**          | Record still exists but gets 0 % traffic       |
| **Equal Weights**        | All records treated equally                    |

---

### 🧮 Formula

```
Traffic % to record = (weight of record ÷ total weights) × 100
```

---

### 📘 Summary

| Property          | Weighted Routing Policy                           |
| ----------------- | ------------------------------------------------- |
| **Purpose**       | Control what % of DNS queries go to each target   |
| **DNS Behavior**  | Route 53 chooses based on weights                 |
| **Health Checks** | Optional                                          |
| **TTL**           | Configurable                                      |
| **Use Case**      | A/B testing, gradual rollout, region distribution |
| **Zero Weight**   | Removes traffic without deleting record           |




 Latency-Based Routing Policy in Amazon Route 53



### 🔹 What Is Latency-Based Routing?

* LBR tells Route 53 to **evaluate latency** between a user’s DNS resolver and AWS regions where your application is hosted.
* The DNS response returned corresponds to **the region with the lowest latency** for that user.
* This is purely **DNS-level decision making** — the traffic does **not** pass through Route 53.

---

### 🧠 How It Works

1. You deploy identical applications in **multiple AWS regions**
   (for example: `us-east-1`, `eu-central-1`, `ap-southeast-1`).
2. Users send DNS queries (for example: `latency.example.com`).
3. Route 53 checks its internal latency measurements and returns the IP address corresponding to the **region with the lowest latency** to that user.
4. The client connects directly to that endpoint.

---

### 🌍 Example Scenario

| User Location | Closest Region     | Response                     |
| ------------- | ------------------ | ---------------------------- |
| Germany       | **eu-central-1**   | “Hello World from Frankfurt” |
| Canada        | **us-east-1**      | “Hello World from Virginia”  |
| Hong Kong     | **ap-southeast-1** | “Hello World from Singapore” |

Thus, each user automatically reaches the nearest regional deployment.

---

### 💡 Why Use Latency-Based Routing?

| Benefit                        | Explanation                                 |
| ------------------------------ | ------------------------------------------- |
| **Better performance**         | Users connect to the lowest-latency region. |
| **Automatic region selection** | No manual geolocation setup required.       |
| **Global coverage**            | Works seamlessly across AWS regions.        |
| **Health-check integration**   | Automatically avoids unhealthy regions.     |

---

### ⚙️ Hands-On Demo – Latency-Based Routing

#### 1️⃣ Create Three Records

Open Route 53 → your hosted zone → **Create record**.

| Setting            | Example                          |
| ------------------ | -------------------------------- |
| **Name**           | `latency.stephanetheteacher.com` |
| **Type**           | A (IPv4)                         |
| **Routing Policy** | Latency                          |
| **TTL**            | Default (300 seconds)            |

Now create **three records** (same name and type), one per region:

| Region                         | IP Address    | Record ID        | Note                     |
| ------------------------------ | ------------- | ---------------- | ------------------------ |
| **AP Southeast 1 (Singapore)** | `13.xx.xx.xx` | `ap-southeast-1` | Asia deployment          |
| **US East 1 (N. Virginia)**    | `3.xx.xx.xx`  | `us-east-1`      | North America deployment |
| **EU Central 1 (Frankfurt)**   | `18.xx.xx.xx` | `eu-central-1`   | Europe deployment        |

✅ Click **Create records**.

---

#### 2️⃣ Verify Your Records

You should now see three separate A records with the same name, each tagged to a specific region.

---

#### 3️⃣ Test Latency Behavior

##### From Europe (eu-central-1)

Browser:

```
http://latency.stephanetheteacher.com
```

Response → **Hello World from eu-central-1c**

CloudShell (dig command):

```bash
dig latency.stephanetheteacher.com
```

Output:

```
;; ANSWER SECTION:
latency.stephanetheteacher.com. 300 IN A 18.xxx.xxx.xxx
```

✅ Returned IP belongs to **Frankfurt**.

---

##### From Canada (VPN)

Switch VPN → Canada.
Refresh browser → response now shows
**Hello World from us-east-1a**
because latency to the US East region is lower.

> When switching location, your device clears cached DNS entries (TTL expired), forcing a new query and new regional selection.

---

##### From Hong Kong (VPN)

Switch VPN → Hong Kong.
Refresh page →
**Hello World from ap-southeast-1b**

Each region receives queries from users closest to it in terms of latency.

---

### 🧩 Key Characteristics

| Property          | Description                                       |
| ----------------- | ------------------------------------------------- |
| **Purpose**       | Direct users to the region with lowest latency    |
| **Name & Type**   | Must be identical across records                  |
| **Region Field**  | Required for each record                          |
| **Health Checks** | Optional; skip unhealthy endpoints                |
| **TTL**           | Controls how often new latency decisions occur    |
| **Alias Support** | Works with AWS resources (ALB, CloudFront, etc.)  |
| **Use Case**      | Multi-region apps needing optimal user experience |

---

### 📘 Summary

| Feature                         | Latency-Based Routing         |
| ------------------------------- | ----------------------------- |
| **Decision Basis**              | AWS latency measurements      |
| **Best For**                    | Global applications           |
| **AWS-Specific**                | Yes                           |
| **Supports Alias**              | ✅ Yes                         |
| **Combines With Health Checks** | ✅ Yes                         |
| **DNS Query Behavior**          | Users get nearest region’s IP |









 Health Checks in Amazon Route 53


### 🔹 What Are Health Checks?

A **Route 53 health check** is a monitoring mechanism that continuously checks whether a target (like a web server, load balancer, or application endpoint) is **healthy and reachable**.

Health checks help Route 53 automatically **remove unhealthy resources** from DNS responses so that users are only directed to **healthy endpoints**.

---

### ⚙️ Use Case Example

Imagine you have:

* Two **public load balancers** (ALBs) — one in `us-east-1`, another in `eu-west-1`
* Each ALB serves the same web application in different regions

You want Route 53 to:

* Send users to the **closest** region (using Latency-Based Routing)
* But if one region goes down, automatically redirect users to the **healthy region**

✅ Solution: Create **Route 53 health checks** for both load balancers and **associate** them with your DNS records.

---

### 🩺 Types of Route 53 Health Checks

| Type                              | Purpose                                                                      | Example Use Case                           |
| --------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------ |
| **Endpoint Health Check**         | Monitors the health of a public endpoint (ALB, EC2, API, etc.)               | Web servers, ALBs, static websites         |
| **Calculated Health Check**       | Combines multiple health checks into one parent check (logical AND, OR, NOT) | Aggregate EC2 or ALB health                |
| **CloudWatch Alarm Health Check** | Uses a CloudWatch Alarm to infer health (for private resources)              | Private EC2 instances or internal services |

---

### 🌐 1️⃣ Endpoint Health Checks

#### 🔹 How It Works

* AWS has ~15 **global health checkers** distributed worldwide.
* Each one sends requests to your **public endpoint** (HTTP, HTTPS, or TCP).
* Route 53 marks your endpoint **healthy** if enough checkers receive a success code (2xx or 3xx).

#### 🔹 Configuration Options

| Option                  | Description                                                               |
| ----------------------- | ------------------------------------------------------------------------- |
| **Protocol**            | HTTP, HTTPS, or TCP                                                       |
| **Check Interval**      | Every 30s (standard) or 10s (fast, higher cost)                           |
| **Healthy Threshold**   | # of consecutive successes before “healthy”                               |
| **Unhealthy Threshold** | # of consecutive failures before “unhealthy”                              |
| **Success Codes**       | 2xx or 3xx HTTP codes                                                     |
| **String Matching**     | Optionally search for a specific text in the first 5120 bytes of response |
| **CloudWatch Metrics**  | Each health check publishes data to CloudWatch                            |

#### 🔹 Network Requirement

The target endpoint **must allow inbound traffic** from AWS health checker IPs.
You can download the list of these IP ranges from the AWS documentation page:

> [https://ip-ranges.amazonaws.com/ip-ranges.json](https://ip-ranges.amazonaws.com/ip-ranges.json)

---

### 🧩 2️⃣ Calculated Health Checks

Used to combine the results of multiple health checks.

#### 🔹 How It Works

* You define **child health checks** for individual endpoints.
* Then you create a **parent (calculated)** health check that evaluates the children using Boolean logic.

#### 🔹 Example

* 3 EC2 instances → 3 child health checks
* Parent health check uses:

  * **AND** → all must be healthy
  * **OR** → at least one must be healthy
  * **NOT** → invert condition

You can monitor **up to 256 child health checks**.

#### 💡 Use Case

During maintenance, you can remove one resource from health without failing the entire group by adjusting child conditions.

---

### 🔒 3️⃣ Health Checks for Private Resources (via CloudWatch)

Because Route 53’s health checkers are **external (public)**, they **cannot access private VPC endpoints**.
To monitor private services:

#### ✅ Solution

Use a **CloudWatch Alarm–based Health Check**:

1. Create a **CloudWatch Metric** that tracks the internal resource (e.g., EC2 CPUUtilization or a custom heartbeat metric).
2. Create a **CloudWatch Alarm** that triggers when the metric indicates failure.
3. Create a **Route 53 health check** that monitors this alarm.
4. Associate the health check with your DNS record.

Now Route 53 can treat a **private resource** as healthy/unhealthy based on your **CloudWatch data**.

---

### 🧠 Key Details & Best Practices

| Feature                    | Description                                                         |
| -------------------------- | ------------------------------------------------------------------- |
| **Global Checker Network** | ~15 AWS global endpoints performing independent checks              |
| **Healthy Threshold**      | Default = 3 (three consecutive passes)                              |
| **Unhealthy Threshold**    | Default = 3 (three consecutive fails)                               |
| **Fast Health Checks**     | Every 10 seconds (higher cost)                                      |
| **Health Check Cost**      | ~$0.50/month + optional fast check cost                             |
| **Integration**            | Works with all routing policies (Weighted, Latency, Failover, etc.) |
| **Failover Logic**         | Automatically removes unhealthy endpoints from DNS responses        |

---

### 💻 Example Workflow

1. Create 2 health checks:

   * `ALB-USEast-1-Health`
   * `ALB-EUWest-1-Health`
2. Associate each health check with its Route 53 record.
3. Configure **Latency-Based Routing**.
4. When the EU region fails, Route 53 automatically returns only the US endpoint IP.

✅ Clients seamlessly reroute to the healthy region.

---

### 📘 Summary

| Concept                | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| **Purpose**            | Monitor health of endpoints and control DNS failover |
| **Protocols**          | HTTP, HTTPS, TCP                                     |
| **Check Frequency**    | 30s (standard) or 10s (fast)                         |
| **Health Evaluation**  | 2xx/3xx or text-based search                         |
| **Private Monitoring** | Use CloudWatch Alarm integration                     |
| **Combining Checks**   | Use Calculated Health Checks                         |
| **Integration**        | Works with all Routing Policies                      |





 Creating and Testing Health Checks in Amazon Route 53


### 🔹 Step 1: Navigate to Health Checks

In the AWS Console:

1. Open **Route 53**
2. On the left-hand menu, click **Health checks**
3. Click **Create health check**

---

### ⚙️ Step 2: Create a Public Endpoint Health Check

We’ll create **three health checks**, one for each EC2 instance running in:

* `us-east-1`
* `ap-southeast-1`
* `eu-central-1`

#### 🧱 Example 1 – US East (N. Virginia)

* **Name:** `US-East-1-Health`
* **Type:** Endpoint
* **IP address:** Paste your EC2 instance’s public IPv4
* **Port:** `80`
* **Path:** `/`
  (this checks the root web page — in real setups, `/health` is often used)

##### Advanced Configuration:

| Setting                  | Value / Description                   |
| ------------------------ | ------------------------------------- |
| **Check Interval**       | 30 seconds (standard)                 |
| **Failure Threshold**    | 3 consecutive failed checks           |
| **String Matching**      | No (skip for this demo)               |
| **Latency Graphs**       | Optional (enabled by default)         |
| **Invert Health Status** | No                                    |
| **Regions for Checkers** | Use recommended (AWS global checkers) |
| **Notifications**        | Disabled for now (no SNS alarm)       |

✅ Click **Create health check**

---

#### 🧱 Example 2 – AP Southeast (Singapore)

* **Name:** `AP-Southeast-1-Health`
* **IP address:** Public IP of your Singapore instance
* **Port:** `80`
* **Path:** `/`
  ✅ Click **Create health check**

---

#### 🧱 Example 3 – EU Central (Frankfurt)

* **Name:** `EU-Central-1-Health`
* **IP address:** Public IP of Frankfurt instance
* **Port:** `80`
  ✅ Click **Create health check**

---

### 🔍 Step 3: Simulate a Failure

We’ll make one instance **unreachable** to trigger an unhealthy check.

1. Go to your **Singapore EC2 instance**
2. Open its **Security Group**
3. Edit inbound rules → **delete the HTTP (port 80)** rule
4. Wait 1–2 minutes for Route 53 checkers to report status.

✅ Expected Result:

* **US-East-1** → Healthy
* **EU-Central-1** → Healthy
* **AP-Southeast-1** → ❌ Unhealthy

---

### 🔎 Step 4: Verify Health Check Status

In Route 53 → Health Checks dashboard:

* Each health check shows **Last checked**, **Status**, and **Average latency**
* Click the **unhealthy check** → **View last failed check**
  Example error:

  ```
  Connection timed out
  The request may be blocked by a firewall.
  ```

  ✅ This matches our simulated security group block.

---

### 🧩 Step 5: Create a Calculated Health Check

A **Calculated Health Check** lets you combine multiple health checks using logical conditions (AND / OR / NOT).

#### Example Configuration:

* **Name:** `All-Regions-Calculated-Health`
* **Type:** Calculated
* **Monitored health checks:**

  * `US-East-1-Health`
  * `EU-Central-1-Health`
  * `AP-Southeast-1-Health`
* **Rule:** “Healthy if **all** selected health checks are healthy”

✅ Create the calculated health check

Result:

* Since one child (Singapore) is unhealthy, the calculated check will also report **Unhealthy**

---

### 🔒 Step 6: CloudWatch Alarm-Based Health Check (For Private Resources)

Use this type when your resource is **inside a private subnet** (not accessible to Route 53’s public checkers).

#### Configuration Overview:

1. **In CloudWatch:**

   * Create a metric (e.g., EC2 CPUUtilization or a custom `/health` metric)
   * Create an **Alarm** that triggers when the instance is unhealthy
     e.g., “Alarm when `StatusCheckFailed` = 1”
2. **In Route 53:**

   * Create a **health check**
   * Type: *Monitor a CloudWatch Alarm*
   * Select the region and alarm name

✅ Now, when the CloudWatch Alarm goes into **ALARM** state, Route 53 marks the health check as **Unhealthy**.

> 💡 This is how you monitor **private EC2 instances** or **internal applications**.

---

### 🧠 Step 7: Review and Insights

| Health Check Type    | Description                                              | Example Use                |
| -------------------- | -------------------------------------------------------- | -------------------------- |
| **Endpoint**         | Directly probes a public IP or domain                    | ALB, EC2, API endpoint     |
| **Calculated**       | Combines multiple child health checks (AND/OR/NOT logic) | Aggregate service health   |
| **CloudWatch Alarm** | Uses a CloudWatch metric to infer health                 | Private EC2, VPC resources |

---

### ✅ Results Recap

* Three endpoint health checks created
* One intentionally made **unhealthy** (Singapore)
* Calculated health check shows **Unhealthy**
* Diagnostic info confirms connection timeout
* Setup ready for **Failover or Latency routing** using these checks

---

### 📘 Summary

| Concept                    | Key Takeaway                               |
| -------------------------- | ------------------------------------------ |
| **Health Checks**          | Verify endpoint reachability automatically |
| **Global Checkers**        | 15 AWS regions performing HTTP/TCP probes  |
| **Failure Simulation**     | Use security group rules to block access   |
| **Calculated Checks**      | Combine logic for multi-endpoint health    |
| **CloudWatch Integration** | Enables private resource monitoring        |
| **DNS Integration**        | Works with all routing policies            |





Failover Routing Policy in Amazon Route 53



### 🔹 What Is Failover Routing?

Failover Routing lets Route 53 detect when your **primary endpoint** is unavailable (via health checks) and seamlessly route traffic to a **secondary endpoint** until the primary recovers.

#### 🔸 How It Works

1. Each record (primary & secondary) points to a different endpoint.
2. The **primary record** is associated with a health check.
3. When the health check fails, Route 53 automatically returns the **secondary record’s** value in DNS responses.
4. Once the primary is healthy again, Route 53 routes traffic back.

---

### ⚙️ Step-by-Step Configuration

#### 1️⃣ Create the Primary Record

| Setting            | Value                             |
| ------------------ | --------------------------------- |
| **Name**           | `failover.stephanetheteacher.com` |
| **Type**           | A record                          |
| **Value**          | EC2 instance IP in `eu-central-1` |
| **TTL**            | 60 seconds                        |
| **Routing Policy** | Failover                          |
| **Failover Type**  | Primary                           |
| **Health Check**   | Attach `EU-Central-1-Health`      |
| **Record ID**      | `EU`                              |

✅ Click **Create record**

---

#### 2️⃣ Create the Secondary Record

| Setting            | Value                                         |
| ------------------ | --------------------------------------------- |
| **Name**           | `failover.stephanetheteacher.com` (same name) |
| **Type**           | A record                                      |
| **Value**          | EC2 instance IP in `us-east-1`                |
| **TTL**            | 60 seconds                                    |
| **Routing Policy** | Failover                                      |
| **Failover Type**  | Secondary                                     |
| **Health Check**   | Optional                                      |
| **Record ID**      | `US`                                          |

✅ Click **Create record**

---

### 🧠 At This Point

* Two records exist for the same name:

  * Primary → EU instance (with health check)
  * Secondary → US instance
* Both are healthy, so traffic goes to **Primary (EU)**.

---

### 🧪 Step 3 – Simulate a Failure

To test failover:

1. Go to the **EU instance’s security group**.
2. Edit inbound rules → **delete the HTTP (80)** rule.
3. Wait 1–2 minutes for Route 53 health checks to detect the failure.

✅ Result:
`EU-Central-1-Health` → **Unhealthy**

---

### 🔍 Step 4 – Observe the Failover

1. Visit `http://failover.stephanetheteacher.com`
2. Originally → “Hello World from EU-Central-1c”
3. After failure → **“Hello World from US-East-1a”**

✅ DNS now returns the secondary record’s IP.
✅ Failover happens automatically and seamlessly.

---

### 🛠 Step 5 – Recovery

To restore the primary endpoint:

1. Add back the HTTP rule in the EU security group.
2. Health check becomes **Healthy** again.
3. Route 53 automatically **fails back** to the primary.

---

### 🧩 Key Concepts

| Term                   | Meaning                                  |
| ---------------------- | ---------------------------------------- |
| **Primary Record**     | Main endpoint used when healthy          |
| **Secondary Record**   | Backup endpoint used when primary fails  |
| **Health Check**       | Determines endpoint status               |
| **TTL**                | Time before clients refresh DNS response |
| **Automatic Failback** | Traffic returns to primary when healthy  |

---

### 🧠 Best Practices

* Always associate a health check with the **primary record**.
* Set a short TTL (e.g., 60 s) for faster switching.
* Use **HTTP/HTTPS checks** instead of TCP for application-level validation.
* Combine Failover with **Latency-based Routing** for multi-region HA + performance.
* Monitor health checks via **CloudWatch Metrics and Alarms**.

---

### 📘 Summary

| Feature                | Failover Routing Policy                 |
| ---------------------- | --------------------------------------- |
| **Purpose**            | High availability and disaster recovery |
| **Records**            | Primary + Secondary                     |
| **Decision Basis**     | Health check status                     |
| **Failover Direction** | Automatic                               |
| **Integration**        | All record types (A, Alias A, etc.)     |
| **TTL Impact**         | Determines DNS switch speed             |












Geolocation Routing Policy in Amazon Route 53


### 🔹 What Is Geolocation Routing?

Geolocation Routing answers DNS queries according to the **geographic origin** of the requester’s IP address.

Unlike Latency-Based Routing (which picks the *fastest* region), Geolocation Routing makes deterministic decisions:

* You decide *where* each region’s traffic should go.
* Route 53 matches the user’s location to the most specific rule (State > Country > Continent > Default).

---

### ⚙️ Key Use Cases

* 🌍 **Website localization:** Serve different languages or content by country.
* 🎬 **Content restrictions:** Comply with regional licensing or legal limits.
* ☁️ **Regional load balancing:** Direct users to their nearest legal or operational region.
* 🧠 **Marketing analysis:** Measure traffic by country or continent.

---

### 🧩 How It Works

1. Client sends a DNS query for your domain (e.g., `geo.example.com`).
2. Route 53 looks at the IP address of the requesting resolver to determine its geographic origin.
3. It selects the most specific matching rule:
    - If match = State  → use that record.
    - Else if match = Country  → use that record.
    - Else if match = Continent  → use that record.
    - Else → use the **Default record**.

You can associate each record with a health check for automatic failover inside a region.

---

### 🧱 Step-by-Step Configuration (Lab Example)

#### 1️⃣ Create the Asia Record

| Setting            | Value                                      |
| :----------------- | :----------------------------------------- |
| **Record Name**    | `geo.stephanetheteacher.com`               |
| **Type**           | A                                          |
| **Value**          | Public IP of `ap-southeast-1` EC2 instance |
| **Routing Policy** | Geolocation                                |
| **Location**       | Continent → Asia                           |
| **Record ID**      | `Asia`                                     |
| **Health Check**   | Optional                                   |

---

#### 2️⃣ Create the U.S. Record

| Setting            | Value                             |
| :----------------- | :-------------------------------- |
| **Record Name**    | `geo.stephanetheteacher.com`      |
| **Type**           | A                                 |
| **Value**          | Public IP of `us-east-1` instance |
| **Routing Policy** | Geolocation                       |
| **Location**       | Country → United States           |
| **Record ID**      | `US`                              |

---

#### 3️⃣ Create the Default Record

| Setting            | Value                                |
| :----------------- | :----------------------------------- |
| **Record Name**    | `geo.stephanetheteacher.com`         |
| **Type**           | A                                    |
| **Value**          | Public IP of `eu-central-1` instance |
| **Routing Policy** | Geolocation                          |
| **Location**       | Default                              |
| **Record ID**      | `Default-EU`                         |

✅ Click **Create records** — three entries now exist for the same domain with different geo rules.

---

### 🧪 Testing the Setup

1. From your current (non-U.S./Asia) location, open `geo.stephanetheteacher.com` → response from **EU (Central 1)** (default).
2. Switch VPN to **India (Asia)** → response from **AP Southeast 1**.
    - If you see a timeout, check the security group for port 80 rules.
3. Switch VPN to **United States** → response from **US East 1**.
4. Switch VPN to **Mexico** (not configured) → response returns to **EU Central 1** (default record).

✅ Each region’s traffic flows exactly to its assigned endpoint.

---

### 🧠 Behavior Summary

| Location                       | Returned Endpoint      |
| :----------------------------- | :--------------------- |
| Asia (India, Singapore, Japan) | ap-southeast-1         |
| United States                  | us-east-1              |
| Everywhere Else                | eu-central-1 (default) |

---

### 💡 Key Details

| Feature            | Description                                               |
| :----------------- | :-------------------------------------------------------- |
| **Granularity**    | Continent → Country → State (U.S. only)                   |
| **Default Record** | Used if no location match exists                          |
| **Health Checks**  | Optional per region                                       |
| **Use Cases**      | Localization, regulatory control, regional load balancing |
| **Limitation**     | Cannot target specific cities or ISP IPs                  |

---

### 🧠 Pro-Tips

* Always create a **Default** record to avoid unresolved queries.
* Combine with **weighted routing** inside each region for fine-grained control.
* If you serve content to U.S. states with different policies (e.g., California vs Texas), use the “State” option.
* Use **health checks** on regional records for geo failover.

---

### 📘 Summary

| Concept        | Key Point                                  |
| :------------- | :----------------------------------------- |
| Routing Basis  | User geographic location                   |
| Priority Order | State > Country > Continent > Default      |
| Integration    | Works with A and Alias A records           |
| Fallback       | Default record handles unmatched locations |
| Best Use Case  | Regional content and regulatory control    |







 Geoproximity Routing Policy in Amazon Route 53



### 🔹 What Is Geoproximity Routing?

Geoproximity Routing helps you route traffic to the **closest resource** (region or data center) but lets you **manually expand or shrink** the geographic influence of each resource using a configurable **bias**.

You can therefore:

* Send *more* traffic to a region by **increasing** its bias (positive number).
* Send *less* traffic by **decreasing** its bias (negative number).

---

### ⚙️ When To Use It

Use **Geoproximity Routing** when you need to:

* Gradually **shift load between regions** (e.g., U.S. East → U.S. West migration).
* **Control traffic flow** during maintenance or regional scaling.
* Direct users to the **nearest region** with the option to *override* automatic distance-based routing.
* Integrate **on-premises data centers** into AWS routing logic.

---

### 🧩 Key Concept – Bias Value

| Bias Value  | Effect                 | Example Behavior                               |
| ----------- | ---------------------- | ---------------------------------------------- |
| **0**       | Neutral (default)      | Users go to the geographically closest region. |
| **+ Value** | Expands region’s reach | Attracts more users → larger influence area.   |
| **– Value** | Shrinks region’s reach | Fewer users routed there.                      |

---

### 🌍 How It Works

You can assign each record to:

* An **AWS Region**, or
* A **Custom location** (latitude + longitude) for **on-prem or external resources**.

Then, Route 53 calculates which region each query should reach, based on:

1. The user’s location, and
2. Each region’s bias setting.

> ⚠️ To use Geoproximity Routing, you must enable **Route 53 Traffic Flow**,
> which provides a visual map and policy editor.

---

### 🧠 Visual Example

#### **Scenario 1 – No Bias (Neutral)**

* Regions: `us-west-1` and `us-east-1`
* Both bias = 0

🟦 Users on the West → us-west-1
🟨 Users on the East → us-east-1
A straight vertical line divides the U.S. down the middle.

---

#### **Scenario 2 – Positive Bias on US-East-1**

* `us-west-1`: bias = 0
* `us-east-1`: bias = + 50

👉 Result: The dividing line shifts westward.
Now, some users who were previously sent to `us-west-1` are redirected to `us-east-1`.

You have effectively **expanded us-east-1’s influence** — more traffic flows there.

---

#### **Scenario 3 – Negative Bias on US-East-1**

* `us-west-1`: bias = 0
* `us-east-1`: bias = – 50

👉 Result: The dividing line shifts eastward.
**us-east-1’s influence shrinks**, so more users are sent to `us-west-1`.

---

### 🧮 Practical Example (Lab Concept)

Imagine two resources:

* **Region A:** `us-east-1` (ALB)
* **Region B:** `us-west-1` (ALB)

You can:

* Assign bias = + 30 to `us-east-1` → Shift 30% more traffic there.
* Assign bias = – 30 to `us-west-1` → Shift traffic away from the West.
  All this is done at the DNS level without touching the load balancers or applications.

---

### 💡 Key Benefits

| Benefit                          | Description                                                            |
| -------------------------------- | ---------------------------------------------------------------------- |
| **Smooth migration**             | Gradually move users to a new region without downtime.                 |
| **Controlled load distribution** | Adjust traffic without changing app infrastructure.                    |
| **On-prem integration**          | Combine AWS and non-AWS locations using latitude/longitude.            |
| **Visualization**                | Traffic Flow console lets you see and drag region boundaries on a map. |

---

### ⚠️ Important Notes

* Requires **Route 53 Traffic Flow** (not available in the simple record UI).
* Each geoproximity rule can be paired with a **health check** for automatic failover.
* Only **one bias setting per region or custom location**.
* **Bias values range** roughly from –99 to +99.
* Higher bias = larger influence area → more traffic.

---

### 📘 Summary

| Concept                     | Description                                         |
| :-------------------------- | :-------------------------------------------------- |
| **Routing Basis**           | Distance + bias adjustment                          |
| **Configuration Tool**      | Route 53 Traffic Flow                               |
| **AWS Resources Supported** | Regions (ALBs, EC2s, CloudFront)                    |
| **Custom Resources**        | Latitude/Longitude for on-prem sites                |
| **Bias Effect**             | Positive → expand reach  /  Negative → reduce reach |
| **Use Case**                | Smooth regional shift and geo-based load control    |









 IP-Based Routing Policy in Amazon Route 53

### 🎯 Objective

Understand how to route DNS traffic based on the **source IP address of the client**, using **CIDR-based rules** to deliver responses optimized for performance, cost, or network topology.

---

### 🔹 What Is IP-Based Routing?

**IP-Based Routing** lets Route 53 decide which DNS record to return depending on the **client’s IP range (CIDR)**.

You pre-define IP ranges that represent known users, networks, or ISPs, and Route 53 maps each range to a specific resource or region.

This approach gives you precise, network-level control of traffic distribution.

---

### ⚙️ Typical Use Cases

| Scenario                     | Example Benefit                                                           |
| ---------------------------- | ------------------------------------------------------------------------- |
| **Performance optimization** | Direct customers from a specific ISP to the closest AWS region.           |
| **Cost reduction**           | Route corporate VPN users to a private endpoint to avoid internet egress. |
| **Compliance control**       | Ensure partner or government IP ranges reach only authorized endpoints.   |
| **B2B integration**          | Separate traffic from internal networks and external clients.             |

---

### 🧱 How It Works

1. Define one or more **CIDR blocks** that represent client IPs.
2. Associate each CIDR block with a target record value (IP or AWS resource).
3. When a DNS query arrives, Route 53 checks the source IP of the resolver:

   * If it matches a defined CIDR block → returns the corresponding record.
   * If no match → uses the **default** record.

---

### 🧩 Example Scenario

You manage two EC2 instances:

| EC2 Instance   | Public IP | Region       |
| -------------- | --------- | ------------ |
| **Instance A** | `1.2.3.4` | US-East-1    |
| **Instance B** | `5.6.7.8` | EU-Central-1 |

Define two client locations:

| Location Name  | CIDR Block       | Target IP (Record Value) |
| -------------- | ---------------- | ------------------------ |
| **Location 1** | `203.0.113.0/24` | `1.2.3.4`                |
| **Location 2** | `200.0.114.0/24` | `5.6.7.8`                |

**Result:**

* A client whose IP belongs to `203.0.113.0/24` receives the DNS answer → `1.2.3.4`.
* A client in `200.0.114.0/24` receives → `5.6.7.8`.

Each user automatically reaches the endpoint intended for their network.

---

### 🧠 Key Concepts

| Concept                      | Description                                                |
| ---------------------------- | ---------------------------------------------------------- |
| **CIDR block**               | Defines a range of client IP addresses.                    |
| **Match priority**           | Longest prefix match ( /32 > /24 > /16  ).                 |
| **Default record**           | Used if no CIDR rule matches.                              |
| **Supported record types**   | A / AAAA / Alias A records.                                |
| **Health check support**     | Optional, per record.                                      |
| **Traffic flow requirement** | Managed through **Route 53 Traffic Flow** (visual editor). |

---

### 💡 Benefits

* 🔹 Fine-grained control over traffic distribution.
* 🔹 Supports hybrid AWS + on-prem environments.
* 🔹 Works with health checks and failover.
* 🔹 Ideal for performance, cost, and policy optimization.

---

### ⚠️ Considerations

* Requires **Traffic Flow** to define CIDR rules visually.
* Too many CIDR ranges increase management complexity.
* Works at the DNS level only (no application-layer inspection).
* Always define a **default record** to handle unmatched queries.

---

### 📘 Summary

| Feature             | Description                               |
| ------------------- | ----------------------------------------- |
| **Routing Basis**   | Client IP (CIDR block match)              |
| **Tool Required**   | Route 53 Traffic Flow                     |
| **Health Checks**   | Supported                                 |
| **Fallback Record** | Default record (optional but recommended) |
| **Best Use Case**   | ISP / partner network-specific routing    |











Multi-Value Answer Routing Policy in Amazon Route 53



### 🔹 What Is Multi-Value Answer Routing?

Multi-Value Answer Routing allows Route 53 to respond to DNS queries with **up to eight healthy records** (A or AAAA).

Each record can have an **associated Health Check**, and only the **healthy** ones are returned.
This gives you simple, cost-effective **client-side load distribution**—although it’s **not a replacement** for an Application Load Balancer (ALB).

> 💡 Think of it as DNS-level load balancing rather than traffic-level balancing.

---

### ⚙️ Use Cases

| Scenario                   | Example                                                                       |
| -------------------------- | ----------------------------------------------------------------------------- |
| 🌐 Simple web applications | Distribute requests between several EC2 instances without ALB.                |
| 💰 Low-cost redundancy     | Return multiple healthy IPs to ensure users reach a working endpoint.         |
| 🧠 Failover light          | Combine with health checks so unhealthy endpoints are excluded automatically. |

---

### 🧩 How It Works

1. Create multiple A (or AAAA) records with the **same domain name**.
2. Associate each record with its own **Health Check**.
3. Route 53 returns up to eight healthy records per query.
4. The **client** (browser, resolver, or app) chooses one endpoint at random and connects to it.

---

### 🧱 Key Difference from Simple Routing

| Feature               | Simple Routing      | Multi-Value Answer Routing       |
| --------------------- | ------------------- | -------------------------------- |
| Health Check Support  | 🚫 No               | ✅ Yes                            |
| # of Records Returned | All values (always) | Up to 8 healthy values only      |
| Purpose               | Static resolution   | Basic client-side load balancing |
| Failover              | Manual              | Automatic (based on health)      |

---

### 🧪 Hands-On Demo (Example)

#### Step 1 – Create Three Records

| Record Name                    | Value (IP)                    | Region         | Policy      | Health Check            | Record ID |
| ------------------------------ | ----------------------------- | -------------- | ----------- | ----------------------- | --------- |
| `multi.stephanetheteacher.com` | IP of US-East-1 instance      | US-East-1      | Multi-Value | `US-East-1-Health`      | `US`      |
| `multi.stephanetheteacher.com` | IP of AP-Southeast-1 instance | AP-Southeast-1 | Multi-Value | `AP-Southeast-1-Health` | `Asia`    |
| `multi.stephanetheteacher.com` | IP of EU-Central-1 instance   | EU-Central-1   | Multi-Value | `EU-Central-1-Health`   | `EU`      |

TTL = 60 seconds for each.

✅ Click **Create records**.

---

#### Step 2 – Test the Response

From AWS CloudShell or your terminal:

```bash
dig multi.stephanetheteacher.com
```

Output:

```
;; ANSWER SECTION:
multi.stephanetheteacher.com. 60 IN A 3.91.45.XX
multi.stephanetheteacher.com. 60 IN A 18.142.XX.XX
multi.stephanetheteacher.com. 60 IN A 35.156.XX.XX
```

➡ Three healthy IPs returned because all health checks are passing.

---

#### Step 3 – Simulate a Failure

1. Edit the EU-Central-1 health check.

2. Enable **Invert health status** (to force it to appear unhealthy).

3. Wait a minute and run:

   ```bash
   dig multi.stephanetheteacher.com
   ```

   ✅ Now only two records are returned (the unhealthy one is excluded).

4. Revert the change to restore normal behavior.

---

### 🧠 Key Points

| Feature                  | Details                                     |
| ------------------------ | ------------------------------------------- |
| Max records returned     | 8 healthy values per query                  |
| Supported types          | A, AAAA, Alias A                            |
| Health Check integration | ✅ Recommended                               |
| TTL                      | Defines how long clients cache the results  |
| Failover logic           | Client chooses only healthy IPs             |
| Traffic balancing        | Client-side (round robin or resolver-based) |

---

### ⚠️ Limitations

* Not a replacement for **Elastic Load Balancer (ALB)** or **NLB**.
* No session stickiness or weighted distribution.
* Depends on client-side selection and DNS resolver behavior.

---

### 💡 Best Practices

* Combine Multi-Value records with health checks for maximum availability.
* Keep TTL short (≤ 60 seconds) to reduce stale cache impact.
* For production grade load balancing → use ALB or NLB with Route 53 alias.

---

### 📘 Summary

| Concept                        | Description                                  |
| ------------------------------ | -------------------------------------------- |
| Routing Basis                  | DNS returns multiple healthy records         |
| Max Returned Values            | 8                                            |
| Health Check Integration       | Yes                                          |
| Failover Capability            | Yes (client-side)                            |
| AWS Service Used For           | Lightweight redundancy / DNS-level balancing |
| Production Replacement For ALB | 🚫 No                                        |







Excellent — this final section transitions perfectly into the **real-world setup** of Route 53: connecting registrars and DNS services.
Here’s your **clear, instructor-ready version** for bootcamp delivery or slide presentation:

---

## 🌐 Lecture 18 – Domain Registrar vs DNS Service (Route 53 Integration)

### 🎯 Objective

Understand the **difference** between a **Domain Registrar** and a **DNS Service**, and learn how to connect an external registrar (like GoDaddy or Google Domains) with **Amazon Route 53** to manage DNS records.

---

### 🔹 1️⃣ What is a Domain Registrar?

A **Domain Registrar** is a company authorized to **sell and register domain names**.
Examples:

* Amazon Registrar (via Route 53)
* GoDaddy
* Google Domains
* Namecheap

When you purchase a domain, the registrar:

* Registers your domain in the **ICANN registry**
* Charges **annual renewal fees**
* Usually provides a **basic DNS service**

💡 You can register a domain anywhere — it’s independent of your DNS host.

---

### 🔹 2️⃣ What is a DNS Service Provider?

A **DNS Service** (like Amazon Route 53) manages **DNS records** that control how users reach your resources:

| DNS Record Type | Purpose                          | Example                         |
| --------------- | -------------------------------- | ------------------------------- |
| **A**           | Points a name to an IPv4 address | `app.example.com → 192.0.2.5`   |
| **AAAA**        | IPv6 address                     | `api.example.com → 2001:db8::1` |
| **CNAME**       | Alias to another name            | `www.example.com → example.com` |
| **MX**          | Mail routing                     | Email servers                   |
| **TXT**         | Verification, SPF, DKIM records  | Used by Gmail, AWS, etc.        |

A DNS service translates human-readable names into IP addresses so clients can find your servers.

---

### 🔹 3️⃣ Using Different Registrars and DNS Services

You can mix and match:

| Scenario                        | Example Setup                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Registrar and DNS both AWS**  | Buy domain and hosted zone in Route 53 → fully managed in AWS                                     |
| **Registrar GoDaddy, DNS AWS**  | Buy domain on GoDaddy → create public hosted zone in Route 53 → point GoDaddy to AWS name servers |
| **Registrar AWS, DNS external** | Buy domain in Route 53 → use GoDaddy or Cloudflare to manage records                              |

This flexibility lets you keep DNS in AWS even if your domain is elsewhere.

---

### 🧩 4️⃣ Example – Use GoDaddy with Amazon Route 53

#### Step 1 – Register Domain on GoDaddy

Buy `example.com` from GoDaddy.
By default, it uses GoDaddy’s DNS servers.

#### Step 2 – Create a Public Hosted Zone in Route 53

In the AWS Console → **Route 53 → Hosted Zones → Create Hosted Zone**

* Domain Name: `example.com`
* Type: **Public Hosted Zone**

#### Step 3 – Get Route 53 Name Servers

Inside the Hosted Zone, you’ll see four NS (Name Server) records, for example:

```
ns-1023.awsdns-20.org
ns-580.awsdns-09.net
ns-2008.awsdns-58.co.uk
ns-144.awsdns-17.com
```

#### Step 4 – Update Name Servers on GoDaddy

* Log in to GoDaddy → Manage Domain `example.com`
* Find **Name Servers** section → Choose **Custom Name Servers**
* Enter the four AWS Route 53 servers from Step 3
* Save Changes ✅

After propagation (usually within minutes to a few hours),
GoDaddy will delegate all DNS queries to AWS Route 53.

---

### ⚙️ 5️⃣ What Happens After Delegation

1️⃣ A user types `example.com` in a browser.
2️⃣ GoDaddy is contacted as the registrar and replies with the Route 53 Name Servers.
3️⃣ DNS resolvers then query Route 53 for records (A, CNAME, etc.).
4️⃣ Route 53 returns the correct IP based on your routing policies (weighted, latency, etc.).

---

### 💡 6️⃣ Key Takeaways

| Concept                  | Explanation                                                        |
| ------------------------ | ------------------------------------------------------------------ |
| **Domain Registrar**     | Sells and registers domain names (e.g., GoDaddy, Amazon Registrar) |
| **DNS Service Provider** | Hosts DNS records and routes traffic (e.g., Route 53)              |
| **Delegation**           | Registrar points to your DNS service’s name servers                |
| **Hosted Zone**          | AWS container for your DNS records                                 |
| **NS Records**           | Define which name servers control a domain                         |

---

### ⚠️ Notes & Tips

* It can take up to 48 hours for DNS propagation after updating name servers.
* Always create both **A** and **CNAME** records in Route 53 before delegation to avoid downtime.
* If you move DNS away from AWS, delete the hosted zone to avoid unnecessary charges.

---

### 📘 Summary

| Role                 | Example                                           | Managed By                  |
| -------------------- | ------------------------------------------------- | --------------------------- |
| **Domain Registrar** | GoDaddy, Google Domains, AWS Registrar            | Purchases domain            |
| **DNS Service**      | Route 53, Cloudflare, GoDaddy DNS                 | Hosts DNS records           |
| **Connection**       | Update registrar’s NS to DNS service name servers | Links domain → DNS provider |







 Domain Registrar vs DNS Service (Route 53 Integration)



### 🔹 1️⃣ What is a Domain Registrar?

A **Domain Registrar** is a company authorized to **sell and register domain names**.
Examples:

* Amazon Registrar (via Route 53)
* GoDaddy
* Google Domains
* Namecheap

When you purchase a domain, the registrar:

* Registers your domain in the **ICANN registry**
* Charges **annual renewal fees**
* Usually provides a **basic DNS service**

💡 You can register a domain anywhere — it’s independent of your DNS host.

---

### 🔹 2️⃣ What is a DNS Service Provider?

A **DNS Service** (like Amazon Route 53) manages **DNS records** that control how users reach your resources:

| DNS Record Type | Purpose                          | Example                         |
| --------------- | -------------------------------- | ------------------------------- |
| **A**           | Points a name to an IPv4 address | `app.example.com → 192.0.2.5`   |
| **AAAA**        | IPv6 address                     | `api.example.com → 2001:db8::1` |
| **CNAME**       | Alias to another name            | `www.example.com → example.com` |
| **MX**          | Mail routing                     | Email servers                   |
| **TXT**         | Verification, SPF, DKIM records  | Used by Gmail, AWS, etc.        |

A DNS service translates human-readable names into IP addresses so clients can find your servers.

---

### 🔹 3️⃣ Using Different Registrars and DNS Services

You can mix and match:

| Scenario                        | Example Setup                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Registrar and DNS both AWS**  | Buy domain and hosted zone in Route 53 → fully managed in AWS                                     |
| **Registrar GoDaddy, DNS AWS**  | Buy domain on GoDaddy → create public hosted zone in Route 53 → point GoDaddy to AWS name servers |
| **Registrar AWS, DNS external** | Buy domain in Route 53 → use GoDaddy or Cloudflare to manage records                              |

This flexibility lets you keep DNS in AWS even if your domain is elsewhere.

---

### 🧩 4️⃣ Example – Use GoDaddy with Amazon Route 53

#### Step 1 – Register Domain on GoDaddy

Buy `example.com` from GoDaddy.
By default, it uses GoDaddy’s DNS servers.

#### Step 2 – Create a Public Hosted Zone in Route 53

In the AWS Console → **Route 53 → Hosted Zones → Create Hosted Zone**

* Domain Name: `example.com`
* Type: **Public Hosted Zone**

#### Step 3 – Get Route 53 Name Servers

Inside the Hosted Zone, you’ll see four NS (Name Server) records, for example:

```
ns-1023.awsdns-20.org
ns-580.awsdns-09.net
ns-2008.awsdns-58.co.uk
ns-144.awsdns-17.com
```

#### Step 4 – Update Name Servers on GoDaddy

* Log in to GoDaddy → Manage Domain `example.com`
* Find **Name Servers** section → Choose **Custom Name Servers**
* Enter the four AWS Route 53 servers from Step 3
* Save Changes ✅

After propagation (usually within minutes to a few hours),
GoDaddy will delegate all DNS queries to AWS Route 53.

---

### ⚙️ 5️⃣ What Happens After Delegation

1️⃣ A user types `example.com` in a browser.
2️⃣ GoDaddy is contacted as the registrar and replies with the Route 53 Name Servers.
3️⃣ DNS resolvers then query Route 53 for records (A, CNAME, etc.).
4️⃣ Route 53 returns the correct IP based on your routing policies (weighted, latency, etc.).

---

### 💡 6️⃣ Key Takeaways

| Concept                  | Explanation                                                        |
| ------------------------ | ------------------------------------------------------------------ |
| **Domain Registrar**     | Sells and registers domain names (e.g., GoDaddy, Amazon Registrar) |
| **DNS Service Provider** | Hosts DNS records and routes traffic (e.g., Route 53)              |
| **Delegation**           | Registrar points to your DNS service’s name servers                |
| **Hosted Zone**          | AWS container for your DNS records                                 |
| **NS Records**           | Define which name servers control a domain                         |

---

### ⚠️ Notes & Tips

* It can take up to 48 hours for DNS propagation after updating name servers.
* Always create both **A** and **CNAME** records in Route 53 before delegation to avoid downtime.
* If you move DNS away from AWS, delete the hosted zone to avoid unnecessary charges.

---

### 📘 Summary

| Role                 | Example                                           | Managed By                  |
| -------------------- | ------------------------------------------------- | --------------------------- |
| **Domain Registrar** | GoDaddy, Google Domains, AWS Registrar            | Purchases domain            |
| **DNS Service**      | Route 53, Cloudflare, GoDaddy DNS                 | Hosts DNS records           |
| **Connection**       | Update registrar’s NS to DNS service name servers | Links domain → DNS provider |








 Amazon Route 53 Resolver (Hybrid DNS)



### 🔹 1️⃣ What Is the Route 53 Resolver?

The **Route 53 Resolver** is the **built-in DNS service** that automatically works in every VPC.

It allows:

* EC2 instances to **resolve domain names** inside AWS (e.g. private hosted zones).
* Access to **public domains** (via the AWS-provided DNS at `169.254.169.253`).

By default, it handles:

| Type                | Example                        | Scope                |
| ------------------- | ------------------------------ | -------------------- |
| **Private DNS**     | `app.internal.company.local`   | Private hosted zones |
| **Public DNS**      | `www.amazon.com`               | Internet             |
| **EC2 Local Names** | `ip-172-31-10-24.ec2.internal` | Local VPC            |

So, the resolver natively answers all DNS queries **within AWS** — no extra setup required.

---

### 🔹 2️⃣ Why Do We Need Resolver Endpoints?

In **hybrid cloud** environments, you often have resources **on-premises** and **in AWS**.
You might need:

* On-prem servers to resolve **AWS private domains**, or
* AWS EC2 instances to resolve **on-prem DNS names**.

To make that happen, we use **Route 53 Resolver Endpoints**.

---

### 🔸 3️⃣ Types of Resolver Endpoints

#### 🟢 **Inbound Endpoint**

* Allows **on-premises DNS resolvers → AWS**.
* Receives DNS queries from your data center or corporate network and forwards them to Route 53 inside AWS.
* Use case: Your on-prem servers need to resolve AWS private domain names.

##### Example Flow:

```
On-prem Server → On-prem DNS Resolver → VPN/Direct Connect → Inbound Endpoint → Route 53 Private Zone
```

✅ **Result:** On-prem systems can resolve AWS-internal DNS (e.g., `db.private.aws.local`).

---

#### 🔵 **Outbound Endpoint**

* Allows **AWS → on-premises DNS**.
* Your EC2 instances in AWS can forward queries for external or on-prem domains to your on-prem DNS servers.

##### Example Flow:

```
EC2 Instance → Route 53 Resolver → Outbound Endpoint → On-prem DNS Resolver
```

✅ **Result:** AWS resources can resolve on-premises domain names (e.g., `fileserver.corp.local`).

---

### 🧩 4️⃣ Architecture Diagram (Conceptual)

```
         ┌───────────────────────────────┐
         │       On-Prem Network         │
         │ ┌───────────────┐             │
         │ │ DNS Resolver  │◀────────────┼───┐
         │ └───────────────┘             │   │
         └───────────────────────────────┘   │
                                              │
     VPN / Direct Connect (Private Link)      │
                                              ▼
 ┌───────────────────────────────┐      ┌──────────────────────────┐
 │          AWS Cloud            │      │ Route 53 Resolver        │
 │ ┌──────────────┐              │      │  (Built-in VPC DNS)      │
 │ │ Inbound EP   │◀─────────────┘      └──────────────────────────┘
 │ │ Outbound EP  │──────────────▶
 │ └──────────────┘
 │ EC2 Instances (Private Zone) │
 └───────────────────────────────┘
```

---

### ⚙️ 5️⃣ Requirements for Hybrid DNS Setup

1. **Network connectivity** between AWS and on-prem (VPN or Direct Connect).
2. **Route 53 Resolver Endpoints** created in your VPC:

   * **Inbound** for on-prem → AWS.
   * **Outbound** for AWS → on-prem.
3. **Security groups and ACLs** must allow UDP/TCP port **53**.
4. Correct **forwarding rules** configured on each side.

---

### 🧠 6️⃣ Typical Use Cases

| Use Case                      | Direction                                 | Endpoint Used          |
| ----------------------------- | ----------------------------------------- | ---------------------- |
| On-prem → AWS private DNS     | On-prem → AWS                             | **Inbound**            |
| AWS → On-prem DNS             | AWS → On-prem                             | **Outbound**           |
| Full bidirectional hybrid DNS | Both ways                                 | **Inbound + Outbound** |
| Split-horizon DNS             | Resolve internal vs. external differently | Both ways              |

---

### 🧰 7️⃣ Key Components in Route 53 Resolver

| Component             | Description                                                |
| --------------------- | ---------------------------------------------------------- |
| **Inbound Endpoint**  | Receives DNS queries from on-premises DNS servers          |
| **Outbound Endpoint** | Forwards AWS DNS queries to external resolvers             |
| **Rules**             | Define which domains should be forwarded to which resolver |
| **VPC Association**   | Determines which VPCs can use a given endpoint             |

---

### ⚠️ 8️⃣ Notes and Best Practices

* Always deploy endpoints in **at least two subnets** (for high availability).
* Use **security groups** to restrict access to trusted DNS servers.
* Route 53 Resolver pricing is based on **endpoint hours** and **query volume**.
* Forwarding rules can be shared using **AWS Resource Access Manager (RAM)**.

---

### 📘 Summary

| Feature               | Description                                      |
| --------------------- | ------------------------------------------------ |
| **Default Resolver**  | Handles AWS public + private DNS inside VPCs     |
| **Inbound Endpoint**  | Lets on-prem systems resolve AWS private names   |
| **Outbound Endpoint** | Lets AWS resources resolve on-prem/private names |
| **Connectivity**      | Requires VPN or Direct Connect                   |
| **Protocols**         | UDP/TCP on port 53                               |
| **Availability**      | Multi-AZ recommended                             |






