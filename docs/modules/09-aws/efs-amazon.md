---
title: "EFS Amazon"
description: "🌩️ What Is AWS Storage?   Think of AWS storage like online hard drives that you rent from..."
published: 2025-10-14
source: "https://dev.to/jumptotech/efs-amazon-i0c"
tags: []
---

# EFS Amazon




## 🌩️ What Is AWS Storage?

Think of **AWS storage** like **online hard drives** that you rent from Amazon’s data centers.
Just like your computer has a **C: drive**, AWS gives you many different types of **cloud drives**, each made for a specific purpose.

AWS stores your data safely in big, secure buildings called **data centers**, all around the world.

---

## 🧱 3 Main Types of AWS Storage

There are **three main ways** to store data in AWS — just like in real life, you use different places for different things.

| Type               | What It Feels Like                | Example Use                             | AWS Service                     |
| ------------------ | --------------------------------- | --------------------------------------- | ------------------------------- |
| **Object storage** | Like Google Drive or Dropbox      | Store pictures, videos, backups         | **S3 (Simple Storage Service)** |
| **Block storage**  | Like your computer’s hard disk    | Run operating systems or databases      | **EBS (Elastic Block Store)**   |
| **File storage**   | Like a shared folder in an office | Multiple computers share the same files | **EFS (Elastic File System)**   |

Let’s understand each one.

---

## ☁️ 1. Amazon S3 (Simple Storage Service)

### What it is:

Imagine a huge **online folder** where you can put any kind of file — photos, videos, text, etc.
This folder is called a **bucket** in AWS.

You don’t need to manage a server; AWS does it for you.

### What you can do:

* Create a **bucket** (your folder)
* Upload or download files
* Make files **public or private**
* Set **rules** to automatically move old files to cheaper storage (like Glacier)
* Store **unlimited data**

### Simple example:

You can upload a picture to S3, get a link, and share it with someone — just like sharing a file from Google Drive.

---

## 💾 2. Amazon EBS (Elastic Block Store)

### What it is:

This is like the **hard drive** inside your computer.

When you create a **virtual computer (EC2 instance)** in AWS, it needs a disk to save data — that’s where EBS comes in.

Each EBS volume can be connected to **one EC2 instance** at a time.

### What you can do:

* Attach it to an EC2 instance (like plugging a USB drive)
* Store your system files and databases
* Take **snapshots** (backups) of your disk
* Restore data if something goes wrong

### Simple example:

If your EC2 instance is your computer, then EBS is your **C: drive**.

---

## 📂 3. Amazon EFS (Elastic File System)

### What it is:

Think of this like a **shared network folder** that many computers can use at the same time.

EFS automatically grows and shrinks as you add or remove files.
It’s used when multiple EC2 instances need to **share the same data**.

### What you can do:

* Create one EFS
* Mount it (connect) to many EC2 instances
* Store and share files in real time
* Data is stored in **multiple availability zones**, so it’s safe

### Simple example:

In an office, if 5 people open and edit the same document stored in a shared folder — that’s how EFS works.

---

## 🧊 4. Amazon Glacier (Archival Storage)

### What it is:

Glacier is used to **store old data you don’t use often**, but want to keep safe — like backups or old records.

It’s **very cheap**, but if you want to get your files back, it takes a few hours.

### Simple example:

Think of Glacier like putting old photo albums in your attic — safe, cheap, but not quickly accessible.

---

## 🗺️ 5. Where Is Your Data Stored?

AWS divides the world into **regions** (like cities) and **availability zones (AZs)** (like buildings).
When you create storage, you pick a **region**, for example:

* `us-east-1` → Virginia, USA
* `us-west-2` → Oregon, USA

Your data is saved **in multiple buildings (AZs)** so that if one fails, your data is still safe.

---

## 💰 6. How You Pay for AWS Storage

You pay only for what you use:

* **S3**: by amount of data + number of requests
* **EBS**: by size of disk (GB per month)
* **EFS**: by storage amount and usage time
* **Glacier**: by how much you store + how often you retrieve

---

## 🧠 7. What You Need to Know First (Base Knowledge)

Before learning AWS storage, you should understand:

1. What is a **server** (EC2)
2. What is a **region and availability zone**
3. What is a **VPC** (virtual network in AWS)
4. How to **log in to AWS Console**
5. How to use the **AWS Management Console** (the web interface)

Once you know these, AWS storage will make sense.

---

## 🪜 8. Easiest Learning Path

| Step | What to Learn | What to Do                                                     |
| ---- | ------------- | -------------------------------------------------------------- |
| 1    | Learn S3      | Create a bucket, upload files, make one public                 |
| 2    | Learn EBS     | Create EC2 → add an extra EBS volume → see how it stores files |
| 3    | Learn EFS     | Create file system → mount on 2 EC2s → see both share files    |
| 4    | Learn Glacier | Move S3 files to Glacier for cheap long-term storage           |



### **What is NFS (Network File System)?**

**NFS** stands for **Network File System**.
It’s a way for **computers to share files over a network** — like how you share a folder on Google Drive, but for computers on the same network.

---

### **Example:**

Imagine you have:

* One **main computer (server)** that stores files.
* Several **other computers (clients)** that want to use those files.

With **NFS**, the clients can “mount” (connect to) the shared folder from the server and use it **as if it were on their own computer** — open, edit, save, etc.

---

### **Why NFS is useful**

* Everyone sees the **same files** in real time.
* Great for **teams or systems** that need to share data (like multiple EC2 servers in AWS).
* Saves space — no need to copy the same file to every machine.

---

### **Simple analogy**

Think of **NFS** like a **shared drive in an office**:

* The **server** is the file cabinet.
* The **clients** are the employees’ computers.
* Everyone can open and work on the same files stored in that cabinet.







### **1. What EFS Is**

* **EFS (Elastic File System)** is a **managed Network File System (NFS)**.
* It allows **multiple EC2 instances** (even across multiple Availability Zones) to **share the same data**.
* It behaves like a **shared folder** in the cloud, accessible from multiple Linux servers.




![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/drp5suo3cig6fns14br1.png)




---

### **2. Key Features**

| Feature                 | Description                                                                    |
| ----------------------- | ------------------------------------------------------------------------------ |
| **Fully managed**       | AWS takes care of setup, scaling, and maintenance.                             |
| **Scalable**            | Automatically grows and shrinks as you add/remove files.                       |
| **Highly available**    | Spans multiple AZs for fault tolerance.                                        |
| **Expensive**           | Costs roughly **3× more than GP2 EBS**, but you pay **only for what you use**. |
| **Supports Linux only** | Uses the **NFSv4.1 protocol** (not supported on Windows).                      |

---

### **3. Performance and Throughput Modes**

| Mode                | When to Use                                                                  | Notes                   |
| ------------------- | ---------------------------------------------------------------------------- | ----------------------- |
| **General Purpose** | Low-latency workloads like web apps, CMS, or home directories                | Default                 |
| **Max I/O**         | High-latency but high-throughput workloads like big data or media processing | For parallel operations |

**Throughput Options:**

* **Bursting** – Throughput increases with storage size.
* **Provisioned** – Manually set throughput independent of storage.
* **Elastic** – Automatically scales based on workload (best for unpredictable loads).

---

### **4. Storage Classes and Lifecycle Management**

| Storage Tier                   | Description                              | Use Case                 |
| ------------------------------ | ---------------------------------------- | ------------------------ |
| **EFS Standard**               | For frequently accessed files            | Default                  |
| **EFS Infrequent Access (IA)** | Lower cost for rarely accessed files     | Backup or less-used data |
| **EFS Archive**                | Very low cost for long-term cold storage | Archival data            |

**Lifecycle Policies** automatically move files between tiers:

* Example: Move from **Standard → IA** after 60 days of no access.

---

### **5. Availability and Durability**

| Option                      | Zones     | Use Case                                   |
| --------------------------- | --------- | ------------------------------------------ |
| **EFS Regional (Standard)** | Multi-AZ  | Production systems needing high durability |
| **EFS One Zone**            | Single AZ | Development or cost-sensitive workloads    |

---

### **6. Common Use Cases**

* WordPress shared uploads directory
* CMS and content repositories
* Web servers sharing same static assets
* Data science and analytics workloads
* Shared configuration files for microservices

---

### **7. Exam Tips**

* EFS is **NFS-based** → cannot be accessed with SMB or CIFS (Windows).
* **Cannot SSH** into EFS — it’s a managed file system, not a server.
* **Mount targets** must be allowed in **Security Groups** (NFS port **2049**).
* **Encryption** at rest uses **AWS KMS**.
* **Automatically scales** in size and throughput.






\

## **1. Create the EFS File System**

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p4g18z2q9njynttm9scm.png)



### **Basic Setup**

* Go to **Amazon EFS → Create file system**
* Choose **Customize** (instead of “Quick Create”) to see all options.
* Leave the **name** blank or optional.
* Choose the **default VPC**.

---

## **2. File System Type**

| Option                     | Description                                                 | Use Case             |
| -------------------------- | ----------------------------------------------------------- | -------------------- |
| **Regional (recommended)** | Spans multiple AZs for **high availability and durability** | **Production**       |
| **One Zone**               | Stored in a single AZ, cheaper, less durable                | **Development/Test** |

---

## **3. Backup and Lifecycle**

* **Automatic backups:** Keep **enabled** (recommended).
* **Lifecycle management:** Move data automatically between tiers:

  * After **30 days** → move to **Infrequent Access (IA)**
  * After **90 days** → move to **Archive**
  * When accessed again → move back to **Standard**

This helps **reduce costs** for rarely accessed data.

---

## **4. Encryption and Performance Settings**

* **Encryption:** Enable (default, uses KMS).
* **Throughput modes:**

| Mode            | Description                               | Notes                                      |
| --------------- | ----------------------------------------- | ------------------------------------------ |
| **Bursting**    | Throughput scales with size.              | Default mode.                              |
| **Elastic**     | Automatically adjusts throughput up/down. | Best for **unpredictable workloads**.      |
| **Provisioned** | Manually set throughput (e.g. 100 MB/s).  | For **consistent, predictable** workloads. |

**Recommended:** Elastic throughput + General Purpose performance.

---

## **5. Network Access**

* Choose **default VPC**.
* Automatically creates **mount targets** in 3 AZs (for Regional).
* Create a **security group** (e.g. `sg-efs-demo`) with **no inbound rules** yet.

Then assign that group to the EFS.

**Port:** NFS (2049)

---

## **6. Launch EC2 Instances**

* Create **two EC2 instances** (Instance A & B):

  * Use **Amazon Linux 2**
  * Instance type: **t2.micro**
  * Disable key pair (use **EC2 Instance Connect**)
  * Place Instance A in **AZ-a**, Instance B in **AZ-b**

---

## **7. Attach EFS to EC2**

Now, directly in the **EC2 launch wizard**:

* Scroll to **File Systems**
* Add your **EFS file system**
* Mount point: `/mnt/efs/fs1`
* The console **automatically creates** and configures:

  * Mount scripts
  * Correct **security groups** (`efs-sg-1`, `efs-sg-2`)
  * NFS rules (port 2049)

No manual user-data script needed anymore.

---

## **8. Test EFS Sharing Between Instances**

### **On Instance A**

```bash
sudo su
echo "hello world" > /mnt/efs/fs1/hello.txt
cat /mnt/efs/fs1/hello.txt
```

Output:

```
hello world
```

### **On Instance B**

```bash
ls /mnt/efs/fs1/
cat /mnt/efs/fs1/hello.txt
```

Output:

```
hello world
```

✅ Both instances see the **same file** — this confirms EFS is a **shared NFS storage**.

---

## **9. Cleanup**

* Terminate EC2 instances.
* Delete EFS file system.
* Delete extra auto-created security groups (e.g., `efs-sg-1`, `efs-sg-2`).

---

## **Key Takeaways for Students**

* EFS = **shared, managed NFS storage** for multiple EC2s.
* Use **Elastic throughput + Regional type** in production.
* Accessible via **port 2049 (NFS)**.
* **Pay per GB used** — no need to pre-provision capacity.
* **Mount once → shared across all instances**.







## **1. Amazon EBS (Elastic Block Store)**

### **What it is:**

* A **block-level storage** device that attaches to a **single EC2 instance**.
* Behaves like a **hard drive** for your EC2 instance.

### **Key Points:**

| Feature           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| **Attachment**    | One instance at a time (except io1/io2 Multi-Attach) |
| **AZ Scope**      | Tied to one **Availability Zone**                    |
| **Migration**     | Use **snapshots** to move data between AZs           |
| **Performance**   | Depends on volume type (gp2/gp3/io1/io2)             |
| **Backup Impact** | Backups use I/O → may affect performance             |
| **Cost**          | Pay for **provisioned capacity** (size + IOPS)       |
| **OS Support**    | Works with **Linux and Windows**                     |

### **When to use:**

* Databases
* OS boot volumes
* Applications that need **low latency block storage**

---

## **2. Amazon EFS (Elastic File System)**

### **What it is:**

* A **network file system (NFS)** that multiple EC2 instances can share at the same time.

### **Key Points:**

| Feature           | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| **Attachment**    | Multiple instances **across AZs**                          |
| **AZ Scope**      | **Regional** (spans multiple AZs)                          |
| **Protocol**      | Uses **NFS** (Linux only)                                  |
| **Scaling**       | Automatically scales with file size                        |
| **Cost**          | Pay per **GB used**, 3× more expensive than EBS            |
| **Storage Tiers** | Standard, Infrequent Access (IA), Archive                  |
| **Encryption**    | Supported with KMS                                         |
| **Performance**   | Choose **Elastic**, **Bursting**, or **Provisioned** modes |

### **When to use:**

* Shared content for web servers (e.g., WordPress uploads)
* CMS or data sharing between EC2 instances
* Applications needing **shared access + scalability**

---

## **3. Instance Store**

### **What it is:**

* **Physical storage** attached directly to the EC2 host.
* **Temporary** — data is lost when instance stops or terminates.

### **Key Points:**

| Feature        | Description                                  |
| -------------- | -------------------------------------------- |
| **Speed**      | Very fast (physically attached)              |
| **Durability** | Data lost if instance stops or fails         |
| **Cost**       | Included in EC2 price                        |
| **Use Case**   | Temporary data (e.g., caching, buffer files) |

### **When to use:**

* High-speed temporary storage
* Caches or scratch data
* Non-persistent workloads

---

## **4. Quick Comparison Table**

| Feature       | **EBS**         | **EFS**             | **Instance Store** |
| ------------- | --------------- | ------------------- | ------------------ |
| Type          | Block storage   | Network file system | Local storage      |
| Shared Access | ❌ Single EC2    | ✅ Multiple EC2      | ❌ No               |
| AZ Scope      | One AZ          | Multi-AZ            | One AZ             |
| Persistence   | ✅ Persistent    | ✅ Persistent        | ❌ Temporary        |
| Backup        | Snapshots       | Lifecycle tiers     | None               |
| OS Support    | Linux & Windows | Linux only          | Linux & Windows    |
| Cost          | Moderate        | Higher              | Free (included)    |











