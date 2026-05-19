---
title: "Project: “Multi-Web Server + Shared Files + Backup Storage”"
description: "Architecture (What we will build)                      +----------------------+             ..."
published: 2025-11-04
source: "https://dev.to/jumptotech/project-multi-web-server-shared-files-backup-storage-4i4p"
tags: []
---

# Project: “Multi-Web Server + Shared Files + Backup Storage”


### **Architecture (What we will build)**

```
                +----------------------+
                |      S3 Bucket       |  ← Static files / backups
                +----------+-----------+
                           |
                           v
+-------------------+    +--------------------+    +-------------------+
|   EC2 #1 (Ubuntu) |----|     EFS Storage    |----|   EC2 #2 (Ubuntu) |
|  /var/www/html -> |    | (Shared directory) |    |  /var/www/html -> |
| Uses EBS for root |    +--------------------+    | Uses EBS for root |
| Nginx website     |                                   Nginx website  |
+-------------------+                                          
         ^                                                           
         |                                                           
         +------- Backup web content → S3 Bucket                      
```

---

# **Concept Mapping (Explain like 6 yrs experience)**

| AWS Storage | When We Use It                                          | Why                                   |
| ----------- | ------------------------------------------------------- | ------------------------------------- |
| **EBS**     | Root disk of the server (OS + application installation) | Like a server’s hard drive            |
| **EFS**     | When **multiple servers need the same data**            | Shared folder NFS → scalable web farm |
| **S3**      | Store **backups, static files, logs, objects**          | Cheap, durable, serverless storage    |

This project **shows each one performing its real role**.

---

# **STEP 1 — Create 2 EC2 Servers (Web Servers)**

* Ubuntu
* t2.micro
* Create a **Security Group**:

  * Allow **SSH 22**
  * Allow **HTTP 80**
  * Allow **NFS 2049** (later for EFS)

Confirm each EC2 has **its own EBS volume** automatically created.

---

# **STEP 2 — Install NGINX on Both Servers**

SSH into both servers:

```bash
sudo apt update
sudo apt install -y nginx nfs-common
sudo systemctl enable nginx --now
```

Test in browser:

```
http://EC2-Public-IP
```

---

# **STEP 3 — Create EFS (Shared Storage)**

1. Go to **EFS**
2. Create file system → Name: `web-shared-efs`
3. Select your VPC
4. After creation → Go to **Network → Security Group** → Add rule:

| Type | Port | Source                  |
| ---- | ---- | ----------------------- |
| NFS  | 2049 | SG of the EC2 instances |

---

# **STEP 4 — Mount EFS On Both EC2 Servers**

On each server:

```bash
sudo mkdir -p /shared
sudo mount -t nfs4 -o nfsvers=4.1 fs-XXXX.efs.<region>.amazonaws.com:/ /shared
```

Verify:

```bash
df -h
```

---

# **STEP 5 — Host Website from Shared Storage**

```bash
sudo rm -rf /var/www/html/*
sudo ln -s /shared /var/www/html
```

Add shared index:

```bash
echo "This is a SHARED website $(hostname)" | sudo tee /shared/index.html
```

Test in browser with both EC2 public IPs:

```
EC2 #1 → shows hostname
EC2 #2 → shows same file, different hostname
```

**This proves EFS = shared website content.**

---

# **STEP 6 — Store Backups in S3**

Create an S3 bucket → `web-backup-bucket-<yourname>`

On **one EC2 server**, upload backup:

```bash
sudo apt install -y awscli
aws configure
aws s3 cp /shared/index.html s3://web-backup-bucket-<yourname>/backup-index.html
```

Check bucket → file appears.

This demonstrates **S3 as backup storage**.

---

# **STEP 7 — Create a Cron Job to Backup Automatically**

```bash
crontab -e
```

Add:

```
0 * * * * aws s3 cp /shared/index.html s3://web-backup-bucket-<yourname>/backup-$(date +\%F-\%H).html
```

Now you taught:
✔ Scheduling
✔ Automation
✔ DevOps daily real tasks

---

# **WHAT THIS PROJECT PROVES (You will say during explanation)**

| Skill Demonstrated | Real DevOps Responsibility                                         |
| ------------------ | ------------------------------------------------------------------ |
| Using EBS          | OS + App persistence                                               |
| Setting up EFS     | **Shared web content across multiple servers** (high availability) |
| Using S3           | Backup & durable storage                                           |
| NFS + SG rules     | Understanding network + permissions                                |
| Cron + AWS CLI     | Automation tasks required in real jobs                             |

This is **production architecture** used in real companies behind load balancers.


