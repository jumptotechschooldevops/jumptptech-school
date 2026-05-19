---
title: "CloudFront and AWS global accelerator"
description: "1. What CloudFront Is     Type: Content Delivery Network (CDN)  Purpose: Improves read..."
published: 2025-10-28
source: "https://dev.to/jumptotech/cloudfront-and-aws-global-accelerator-48fl"
tags: []
---

# CloudFront and AWS global accelerator


### **1. What CloudFront Is**

* **Type:** Content Delivery Network (CDN)
* **Purpose:** Improves **read performance** and reduces **latency** by **caching website content** at AWS **edge locations** around the world.
* **Global Infrastructure:** 200+ **Points of Presence (PoPs)** including **Edge Locations** and **Regional Edge Caches**.

---

### **2. How It Works**

1. **User requests** content (e.g., image, video, or webpage).
2. **Edge location checks cache:**

   * If **content is cached**, it’s delivered immediately (low latency).
   * If **not cached**, CloudFront fetches it from the **origin** (S3, EC2, ALB, or custom HTTP server).
3. The **response** is then **cached** locally for future users.

---

### **3. CloudFront Origins**

* **Amazon S3** → for static files and websites.

  * Secured with **Origin Access Control (OAC)** (replaces the old OAI).
* **HTTP/HTTPS servers** → for dynamic sites or APIs.
* **Load Balancers / EC2 / ECS / EKS** → for private VPC applications.
* **Custom Origins** → any HTTP-based service inside or outside AWS.

---

### **4. Security Features**

* **OAC (Origin Access Control)**: Restricts direct S3 bucket access.
* **AWS Shield Standard**: Built-in DDoS protection.
* **AWS WAF (Web Application Firewall)**: Filters malicious requests.
* **HTTPS / TLS**: End-to-end encryption from viewer → CloudFront → origin.

---

### **5. CloudFront vs S3 Cross-Region Replication**

| Feature  | CloudFront (CDN)                              | S3 Cross-Region Replication                    |
| -------- | --------------------------------------------- | ---------------------------------------------- |
| Purpose  | Cache static/dynamic content for global users | Replicate entire buckets for disaster recovery |
| Reach    | 216+ global edge locations                    | Only the regions you configure                 |
| Latency  | Very low (served from nearest edge)           | Depends on region proximity                    |
| Updates  | Cached, refreshed periodically                | Real-time replication                          |
| Best for | **Static assets, global apps, media**         | **Backups, compliance, DR**                    |

---

### **6. Benefits**

✅ Low latency
✅ Global availability
✅ Scalability
✅ Security (DDoS, WAF)
✅ Cost-effective caching (reduced origin load)







## **1. Step-by-Step Recap**

### **Step 1 — Create an S3 Bucket**

* **Bucket name:** `demo-cloudfront-stephane-v4`
* Default settings (no public access).
* Uploaded:

  * `index.html`
  * `beach.jpg`
  * `coffee.jpg`

👉 **Purpose:** Store static website files (HTML, images, CSS, JS, etc.) privately — not public.

---

### **Step 2 — Test Access from S3**

* **Object URL** (unauthenticated): ❌ *AccessDenied* — because public access is blocked.
* **Open via S3 console**: ✅ Works via **pre-signed URL**, which is temporary and private.

👉 **Takeaway:** Objects remain **private**, which is good practice for security.

---

### **Step 3 — Create a CloudFront Distribution**

* **Type:** Single website or app.
* **Origin type:** Amazon S3.
* **Origin:** Selected the S3 bucket (`demo-cloudfront-stephane-v4`).
* **Origin path:** *(blank)* since files are in the root.
* **Access:** Enabled **Private S3 Bucket Access** → CloudFront creates **Origin Access Control (OAC)** automatically.
* **Distribution domain:** Uses default CloudFront domain (e.g., `d1abcde123.cloudfront.net`).

👉 **Purpose:** Let CloudFront fetch files *privately* from S3 without exposing them publicly.

---

### **Step 4 — CloudFront Configures Security**

CloudFront automatically:

* Creates an **OAC** (Origin Access Control).
* Adds a new **bucket policy** to S3:

  ```json
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "cloudfront.amazonaws.com"
    },
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::demo-cloudfront-stephane-v4/*",
    "Condition": {
      "StringEquals": {
        "AWS:SourceArn": "arn:aws:cloudfront::ACCOUNT_ID:distribution/DISTRIBUTION_ID"
      }
    }
  }
  ```

👉 **Meaning:** Only **this specific CloudFront distribution** can read objects from the S3 bucket.

---

### **Step 5 — Wait for Deployment**

* Status: *Deploying → Deployed* (takes 5–10 minutes typically).
* Once deployed, use the **CloudFront domain name**, e.g.:

  ```
  https://d1abcde123.cloudfront.net/index.html
  https://d1abcde123.cloudfront.net/coffee.jpg
  ```

👉 **Result:** Files load instantly via the **nearest edge location**.

---

## **2. What’s Happening Behind the Scenes**

| Action                        | Description                                               |
| ----------------------------- | --------------------------------------------------------- |
| 1. User requests `coffee.jpg` | Request goes to the nearest **edge location**             |
| 2. CloudFront checks cache    | If not cached, it fetches from the **S3 origin** securely |
| 3. Object cached              | Cached for faster delivery next time                      |
| 4. Second user (same region)  | Served instantly from the **edge cache**, not S3          |
| 5. Private access maintained  | S3 bucket is never exposed publicly                       |

---

## **3. Key Benefits of This Setup**

✅ **Security:** S3 stays private (no public ACLs).
✅ **Speed:** Edge caching reduces latency worldwide.
✅ **Cost optimization:** Reduced S3 GET requests.
✅ **Scalability:** Automatic high availability and DDoS protection.
✅ **Flexibility:** Can later attach WAF, custom domain, SSL certificate (ACM).

---

## **4. Exam & Real-World Tips**

* **OAC (Origin Access Control)** is the **modern** approach.
  Don’t use OAI (Origin Access Identity) — it’s legacy.
* **Viewer Protocol Policy:** Always set to **Redirect HTTP → HTTPS** for production.
* **Cache Behavior:** Default TTL, Max TTL, and Min TTL affect cost and performance.
* **Custom Domain:** Use Route 53 + ACM certificate if you want your own domain.
* **Invalidations:** Used to remove outdated cache objects (`/*` to clear all).








## **1. CloudFront + VPC Origin (Modern & Recommended Method)**

### **Purpose**

Connect CloudFront **securely** to **private applications** hosted inside a **VPC**, such as:

* **Application Load Balancer (ALB)**
* **Network Load Balancer (NLB)**
* **EC2 Instances in private subnets**

All traffic between CloudFront and your backend stays **within AWS’s private network** — never exposed to the public Internet.

---

### **Architecture Overview**

**User → CloudFront (Edge) → VPC Origin → Private ALB/EC2/NLB**

* **Users** connect to the CloudFront distribution (global edge network).
* **CloudFront** uses a **VPC Origin** to reach into your **private VPC**.
* **Private ALB/EC2/NLB** processes requests internally.
* **No public IPs** are required on backend resources.

---

### **How to Configure**

1. **Create your application** in a private subnet (ALB/EC2/NLB).

   * Security groups allow CloudFront to access the target via the VPC origin endpoint.
2. **Go to CloudFront → Create Distribution**

   * **Origin Type:** VPC Origin
   * **Select VPC:** choose your VPC
   * **Origin Endpoint:** your ALB or instance endpoint inside that VPC
3. **Set Access Control:**

   * No public access to ALB or instance.
   * CloudFront handles all traffic via internal networking.
4. **Deploy** the distribution.
   CloudFront automatically creates and manages a **private link** to your VPC.

---

### **Advantages**

✅ **Private communication** — no need for public subnets or internet-facing endpoints.
✅ **Stronger security** — no IP whitelisting or manual security-group edits.
✅ **Simpler maintenance** — CloudFront manages connectivity.
✅ **Lower latency** — stays on AWS’s internal backbone network.
✅ **Compliance-friendly** — avoids public exposure entirely.

---

## **2. Legacy Method (Pre-VPC Origin)**

Before VPC origins, you had to:

* Make your **ALB or EC2 instance public**.
* Obtain the **list of all CloudFront edge IP ranges** (from AWS JSON file).
* Add them manually to your **security groups** to restrict access.

Example:

```bash
# Example security group rule (old way)
Type: HTTP
Source: <CloudFront Edge IP Range>
```

### **Drawbacks**

❌ Tedious and error-prone (IP ranges change over time).
❌ Requires **public exposure** of ALB or EC2.
❌ Security risk if someone modifies security groups.
❌ More maintenance and less automation.

---

## **3. Summary Table**

| Feature     | **VPC Origin (New)**     | **Public Origin (Old)** |
| ----------- | ------------------------ | ----------------------- |
| Exposure    | Private (no Internet)    | Public                  |
| Setup       | Automatic via CloudFront | Manual IP whitelist     |
| Security    | AWS internal network     | Internet-facing         |
| Maintenance | Minimal                  | High                    |
| Best for    | Private ALBs, EC2s, APIs | Legacy or hybrid setups |

---

✅ **Exam Tip:**
If you see a question saying *“Deliver content from private subnets without making ALB public”*,
→ **Answer:** Use **CloudFront with a VPC Origin**.










### **CloudFront Geo Restriction (Geo Blocking)**

**Definition:**
Geo Restriction in CloudFront allows you to **control access** to your content **based on the viewer’s country**.

---

### **How It Works**

* CloudFront determines the user’s **country** using a **third-party Geo-IP database** (based on the requester’s IP address).
* You can then either:

  * ✅ **Allowlist** specific countries → only these can access content.
  * 🚫 **Blocklist** specific countries → all others can access.

---

### **Use Cases**

* **Copyright and licensing compliance** (e.g., streaming restrictions by region)
* **Regulatory or export control** requirements
* **Security** — blocking known high-risk regions

---

### **How to Enable (Console Path)**

1. Open your **CloudFront Distribution**.
2. Go to **Security → Geographic Restrictions**.
3. Click **Edit**.
4. Choose:

   * **Allowlist** → specify countries allowed.
   * **Blocklist** → specify countries denied.
5. **Save changes.**

---

### **Example**

If you choose an **allowlist** for **India** and **United States**,
only viewers from those countries can access your distribution; all others receive an HTTP `403 Forbidden`.

---

✅ **Key Exam Tip:**
Geo Restriction applies **at the CloudFront level**, not at the origin (like S3). It’s enforced **before** requests reach your backend.










### **CloudFront Pricing & Price Classes**

**Concept:**
CloudFront delivers content via **edge locations** all over the world.
Because bandwidth costs differ by region, **data transfer pricing** also varies.

---

### **1. Data Transfer Pricing**

* Each **region or continent** has its own **per-GB cost**.
* Example:

  * 🇺🇸 **US / Canada / Mexico** → ~$0.085 / GB (first 10 TB)
  * 🇮🇳 **India** → ~$0.17 / GB (about twice the price)
* The **more data** you transfer, the **lower** the per-GB cost (volume discount).

---

### **2. Price Classes**

To control costs, you can **limit which edge locations** CloudFront uses:

| **Price Class** | **Edge Coverage**                      | **Cost**         | **Best For**                   |
| --------------- | -------------------------------------- | ---------------- | ------------------------------ |
| **All**         | All global edge locations              | 💲💲💲 (highest) | Best performance, global users |
| **200**         | Most regions (excludes most expensive) | 💲💲             | Balanced cost vs reach         |
| **100**         | Only North America & Europe            | 💲 (lowest)      | Apps targeting US/EU audiences |

---

### **3. Visualization**

🌍 **Price Class 100:** North America + Europe
🌍 **Price Class 200:** Adds Asia, South America, Middle East, Africa
🌍 **Price Class All:** Every AWS edge location worldwide

---

### **4. Exam Tip**

If a question mentions:

* *“Reduce CloudFront cost while maintaining good global coverage”* → **Price Class 200**
* *“App only for US + EU users”* → **Price Class 100**
* *“Worldwide users need best performance”* → **Price Class All**







### **CloudFront Cache Invalidations**

**Purpose:**
When you update content in your **origin** (like S3 or EC2),
CloudFront **edge locations** still serve the *old cached version* until the **TTL expires**.
If you want users to see the **new content immediately**,
you perform a **cache invalidation**.

---

### **How It Works**

1. Each edge location stores cached copies of objects (e.g., `index.html`, `images/*`).
2. When you update your origin (e.g., upload a new HTML or image file), the cached objects remain unchanged until TTL ends.
3. To refresh them instantly, you issue a **CloudFront invalidation** request:

   * For one file: `/index.html`
   * For multiple: `/images/*`
   * For all: `/*`

CloudFront then removes those objects from **every edge cache**, forcing the next request to fetch the latest version from the origin.

---

### **Example**

* You update:

  * `index.html`
  * Several files under `/images/`
* You create an invalidation for:

  ```
  /index.html
  /images/*
  ```
* Result:
  Edge caches delete the old versions.
  Next viewer request = fresh data from origin (S3 or ALB).

---

### **Cost Note**

* **First 1,000 invalidation paths/month** → Free.
* After that → small charge per path.

---

### **Exam Tip**

If a question says:

> “Users still see outdated content after updates to the S3 bucket…”

✅ **Answer:** Perform a **CloudFront invalidation** (don’t make objects public or change TTL).










### **AWS Global Accelerator — Overview**

**Definition:**
AWS **Global Accelerator (GA)** is a **networking service** that improves the **availability and performance** of your global applications by routing user traffic through the **AWS global network** instead of the public internet.

---

### **1. The Problem It Solves**

* Without GA, global users access your app over the **public internet**, causing:

  * High latency (many router hops)
  * Unstable connections
  * Slower failover between regions
* Goal → Enter AWS’s private backbone network **as early as possible**.

---

### **2. How It Works**

* **Uses Anycast IPs** (two static, global IPs).
* User requests go to the **nearest AWS edge location**.
* From there, traffic travels through **AWS’s internal network** to your backend:

  * **ALB**, **NLB**, or **EC2 instance** (public or private).
* **Health checks** monitor endpoints and **automatically fail over** within 1 minute if one region becomes unhealthy.

---

### **3. Key Benefits**

✅ **Static Anycast IPs** (no DNS caching issues)
✅ **Low latency** and **consistent performance**
✅ **Automatic regional failover**
✅ **Works with TCP & UDP** (HTTP and non-HTTP apps)
✅ **DDoS protection** via **AWS Shield**
✅ **Simplified whitelisting** — only two global IPs

---

### **4. Supported Backends (Endpoints)**

* **Elastic IPs**
* **EC2 instances**
* **ALB / NLB** (public or private)

---

### **5. CloudFront vs. Global Accelerator**

| Feature               | **CloudFront**            | **Global Accelerator**                       |
| --------------------- | ------------------------- | -------------------------------------------- |
| **Primary use**       | CDN (cache content)       | Global traffic routing                       |
| **Protocol**          | HTTP / HTTPS              | Any TCP or UDP                               |
| **Content**           | Static & dynamic (cached) | Dynamic only (no caching)                    |
| **Performance boost** | From **edge cache**       | From **AWS global network routing**          |
| **IP type**           | DNS-based                 | 2 static Anycast IPs                         |
| **Best for**          | Websites, media, APIs     | Gaming, IoT, real-time apps, multi-region HA |
| **Failover**          | via DNS TTL               | via health checks (<1 min)                   |

---

### **6. Exam Tip**

If you see:

> “Need global static IPs and lowest-latency routing for TCP/UDP apps”
> ✅ **Answer:** AWS Global Accelerator

If you see:

> “Need to deliver cached static and dynamic web content”
> ✅ **Answer:** Amazon CloudFront











## **AWS Global Accelerator – Hands-On Summary**

### **1. What You Built**

* Two **EC2 instances** running simple web servers:

  * One in **us-east-1 (Virginia)**
  * One in **ap-south-1 (Mumbai)**
* Each returned a region-specific message (e.g., *Hello from US East 1*).
* Then, a **Global Accelerator** was created to route users to the closest healthy endpoint.

---

### **2. Key Configuration Steps**

#### **(a) Create EC2 Instances**

* **AMI:** Amazon Linux 2, `t2.micro`
* **User Data:** simple HTTP server printing region name
* **Security Group:** allow **HTTP (port 80)** from anywhere
* **No key pair** needed (no SSH access required).

#### **(b) Create the Global Accelerator**

* **Listener:**

  * Port 80 / TCP
  * Optional client affinity = *none* or *source IP*
* **Endpoint Groups:**

  * Region 1: us-east-1
  * Region 2: ap-south-1
  * **Traffic dial = 100%** each (equal weight)
  * **Health checks:** HTTP → “/” every 10 s, threshold = 3
* **Endpoints:** add each EC2 instance.

#### **(c) Test**

* Accelerator provides:

  * **2 static Anycast IPs**
  * **1 DNS name** (global)
* From Europe → routed to **us-east-1** (nearest healthy region).
* From Indonesia (via VPN) → routed to **ap-south-1**.

#### **(d) Health Check + Failover Demo**

* Removed HTTP rule from Mumbai instance’s security group → health check = ❌ unhealthy.
* Within ≈ 1 minute, Global Accelerator rerouted all traffic to **us-east-1** automatically.

---

### **3. Cleanup**

* Terminate both EC2 instances.
* **Disable** and then **delete** the Accelerator.
* Verify that billing stops.

---

### **4. Pricing Overview**

| **Cost Component**            | **Rate (approx.)**                       |
| ----------------------------- | ---------------------------------------- |
| Accelerator hourly charge     | $0.025 per hour                          |
| Data transfer (edge → origin) | $0.01 – $0.08 per GB depending on region |

*(Service is billed while enabled, so always delete after labs.)*

---

### **5. Key Takeaways**

✅ **Anycast IPs:** two fixed global addresses.
✅ **Health checks + automatic failover (< 1 min).**
✅ **Traffic routing via AWS backbone**, not the public Internet.
✅ **Supports TCP & UDP**, public or private ALB/NLB/EC2.
✅ **Expensive but enterprise-grade performance.**

---

**Exam tip:**

> *“Global users need lowest-latency access and instant regional failover using static IPs.”*
> → **Answer:** AWS Global Accelerator.



