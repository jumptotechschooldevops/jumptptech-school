---
title: "CloudFront & Global Accelerator"
description: "Part 1 — CloudFront (CDN) Lab: S3 Website + CloudFront            What learn    Put a..."
published: 2026-02-19
source: "https://dev.to/jumptotech/cloudfront-global-accelerator-1jfp"
tags: []
---

# CloudFront & Global Accelerator



# Part 1 — CloudFront (CDN) Lab: S3 Website + CloudFront

## What learn

* Put a website behind a CDN
* Improve speed worldwide (cache at edge)
* Secure S3 (no public bucket)

## Why DevOps uses CloudFront

DevOps uses CloudFront when:

* You need **fast global delivery** (images, HTML, JS, downloads)
* You want **TLS/HTTPS** easily
* You want **DDoS protection** (with AWS Shield/WAF)
* You want **private origin** (S3 not public)
* You want **stable domain + caching**

Who uses it:

* **Platform/DevOps/SRE**: creates distribution, caching, security headers, WAF, logging
* **App team**: sets cache rules for paths (/api no-cache, /static cache)
* **Security**: WAF rules, TLS, access logs
* **Network/Infra**: DNS + routing (Route 53), certificates

---

## Step A — Create S3 bucket and upload website

### 1) Create bucket

1. AWS Console → search **S3**
2. Click **Create bucket**
3. Bucket name: `my-student-site-<unique-number>`
4. Region: pick your region (any)
5. **Block Public Access**: keep **ON** (recommended)
6. Click **Create bucket**

### 2) Upload a simple site

1. Open the bucket
2. Click **Upload**
3. Upload `index.html` (create one locally)

Example `index.html` content (simple):

```html
<html>
  <body>
    <h1>Hello from CloudFront</h1>
    <p>Version 1</p>
  </body>
</html>
```

4. Click **Upload**

---

## Step B — Create CloudFront Distribution (private S3 using OAC)

### 1) Start CloudFront creation

1. AWS Console → search **CloudFront**
2. Click **Create distribution**

### 2) Origin settings

1. **Origin domain** → select your S3 bucket from dropdown
2. **Origin access** → choose **Origin access control settings (recommended)**
3. Click **Create new OAC**

   * Name: `oac-student-site`
   * Signing behavior: **Sign requests**
   * Click **Create**

### 3) Default cache behavior

Set these:

1. **Viewer protocol policy** → **Redirect HTTP to HTTPS**
2. **Allowed HTTP methods** → **GET, HEAD**
3. **Cache policy** → **CachingOptimized** (default is fine)

### 4) Settings

1. **Default root object** → type: `index.html`

### 5) Create

Click **Create distribution**

CloudFront will deploy (usually a few minutes).

---

## Step C — Add S3 bucket policy (Required)

After you create the distribution, CloudFront will show a message like:
**“Update bucket policy to allow CloudFront access”**

1. On the CloudFront page, find **S3 bucket policy** section
2. Click **Copy policy**
3. Go to **S3 → your bucket → Permissions**
4. Scroll to **Bucket policy** → click **Edit**
5. Paste the policy
6. Click **Save changes**

---

## Step D — Test CloudFront

1. CloudFront → Distributions → open your distribution
2. Copy **Distribution domain name** (example: `dxxxx.cloudfront.net`)
3. Open in browser:

   * `https://dxxxx.cloudfront.net`

If you see your HTML page, success.

---

## CloudFront Troubleshooting 

### Problem 1: “Access Denied”

Common cause: S3 policy/OAC missing

* Check: S3 bucket policy exists
* Check: CloudFront origin uses OAC (not public)

### Problem 2: Old content still shows (cache)

CloudFront caches. To update:

1. CloudFront → your distribution
2. Go to **Invalidations**
3. Create invalidation:

   * Object path: `/*`
4. Create invalidation
   Then refresh.

### Problem 3: 403/404

* 404: your file path wrong or default root object missing
* 403: permission issue (OAC/bucket policy)

### Logs (for real DevOps)

* CloudFront → enable **Standard logs** to S3
* Use logs to see request status codes, paths, IPs, user agents

---

# Part 2 — Global Accelerator Lab: ALB + Global Accelerator

## What  learn

* Get **two static anycast IPs**
* Faster, more stable routing over AWS backbone
* Multi-region failover (advanced)

## Why DevOps uses Global Accelerator

DevOps uses it when:

* You need **static IP addresses** (some companies require allowlisting)
* You need **fast global entry point** for TCP/UDP apps
* You need **multi-region active/standby** failover
* You need better performance than “public internet routing”

Who uses it:

* **Network/Platform/DevOps/SRE**: accelerator, listeners, endpoint groups, health checks
* **Security**: IP allowlists, network policies
* **App team**: confirms the app is healthy and ports are correct

---

## Requirements for this demo

You need an endpoint like:

* **ALB** (recommended) OR
* EC2 instance with a public app

 use an **ALB** in front of a simple app.

If you already have an ALB DNS name, you can continue.

---

## Step A — Create Global Accelerator

### 1) Open Global Accelerator

1. AWS Console → search **Global Accelerator**
2. Click **Create accelerator**
3. Name: `student-ga`
4. IP address type: **IPv4**
5. Click **Next**

### 2) Add Listener

1. Listener name: `web-listener`
2. Protocol: **TCP**
3. Port: **80**

   * (Use 443 if HTTPS is ready)
4. Click **Next**

### 3) Add Endpoint Group

1. Region: choose the region where your ALB exists (example: **us-east-2**)
2. Traffic dial: **100**
3. Health check:

   * Protocol: **TCP**
   * Port: **80**
4. Click **Next**

### 4) Add Endpoint

1. Endpoint type: **Application Load Balancer**
2. Select your ALB from dropdown
3. Weight: **128** (default ok)
4. Click **Next**
5. Click **Create accelerator**

---

## Step B — Test Global Accelerator

After creation, you will see:

* **2 static IPs** (important)

Test in browser:

* `http://<static-ip-1>`
* `http://<static-ip-2>`

If your ALB serves a page, it should open.

---

## Global Accelerator Troubleshooting (Beginner checklist)

### Problem 1: Site doesn’t open (timeout)

Common causes:

* ALB listener not on port 80
* Security group doesn’t allow inbound on the ALB
* Target group unhealthy

Check:

1. EC2 → **Load Balancers** → select ALB
2. **Listeners** tab:

   * must have `HTTP : 80`
3. **Target Groups**:

   * targets must be **Healthy**

### Problem 2: GA says endpoint unhealthy

* Health check failing
* Your app is not responding
* Wrong port

Fix:

* Ensure your app responds on the exact port
* If app is HTTPS only, use listener 443 and health check HTTPS

### Problem 3: Works on ALB DNS but not on GA IP

* Usually port mismatch (GA 80 but ALB listens 443)
* Or health check mismatch

---

# CloudFront vs Global Accelerator 

CloudFront:

* Best for **web content + caching**
* Usually **HTTP/HTTPS**
* Speeds up by caching at edge

Global Accelerator:

* Best for **static IP + fast routing**
* Works at **TCP/UDP**
* No caching

---

# “At what moment do we add these in real projects?”

Typical DevOps timeline:

1. App runs on EKS/EC2 and works inside region
2. Add ALB / Ingress
3. When product is public:

   * Add **CloudFront** for web + caching + security
4. When enterprise requirements come:

   * Add **Global Accelerator** for static IP / global reliability
5. Add monitoring + logging:

   * CloudWatch, ALB logs, CloudFront logs, WAF logs

---

# Who checks what in a real company?

**DevOps / Platform**

* creates CloudFront/GA
* sets caching, TLS, origins
* sets logging and alarms
* works with DNS (Route 53)
* does rollouts and invalidations

**Network team**

* approves ports, firewall rules
* IP allowlist requirements (Global Accelerator is common here)
* routing requirements

**Security team**

* WAF rules, bot protection
* TLS policy
* access logs, compliance

**Application team**

* app health endpoints (`/health`)
* correct headers for caching
* correct base paths

**Support / NOC**

* watches dashboards
* handles incidents and escalates to DevOps/app teams

---

# Homework (Simple):

1. Update `index.html` to “Version 2”
2. Upload to S3
3. See that CloudFront still shows old version
4. Create invalidation `/*`
5. Confirm Version 2 appears


