---
title: "Solution architect associate level"
description: "Amazon EBS (Elastic Block Store)            🧩 What It Is     EBS stands for Elastic Block..."
published: 2025-10-08
source: "https://dev.to/jumptotech/solution-architect-associate-level-135i"
tags: []
---

# Solution architect associate level


## **Amazon EBS (Elastic Block Store)**

### 🧩 **What It Is**

* **EBS** stands for **Elastic Block Store** — it’s like a **network hard drive** for your **EC2 instance**.
* You can **store data** on it and **keep it safe even after the instance is stopped or terminated**.

---

### 💽 **Key Features**

1. **Persistent Storage**

   * Data remains even if the EC2 instance stops or is deleted.
   * You can detach an EBS volume from one instance and attach it to another.

2. **Bound to an Availability Zone (AZ)**

   * When you create an EBS volume in `us-east-1a`, it **cannot** be attached to an instance in `us-east-1b`.
   * You can move data to another AZ **only by creating a snapshot** and then restoring it in another zone.

3. **Network-Based Drive**

   * It’s not physically attached; EC2 connects to it **through the network**.
   * That can add a little **latency**, but it’s flexible and easy to manage.

4. **Provisioning**

   * You must specify:

     * **Size** (in GB)
     * **Performance (IOPS)** — Input/Output Operations Per Second
   * You’re billed for the size and performance you request.

---

### 🧠 **Think of It Like**

A **network USB stick**:

* You can plug it into one computer (EC2 instance),
* Unplug it, and plug it into another.
* You can even have multiple USBs (EBS volumes) connected to one machine.

---

### 🗂️ **Delete on Termination**

When you create an EC2 instance:

* The **root EBS volume** (where the OS is installed) has **“Delete on Termination” enabled** by default.

  * So when the instance is terminated, that EBS is deleted too.
* **Additional volumes** are **not deleted by default** (so your data stays safe).

✅ You can **change this behavior**:

* **Enable** it → delete the volume when the instance is deleted.
* **Disable** it → keep the volume even after the instance is gone.

**Example use case:**
You disable “delete on termination” if you want to **keep logs or databases** after deleting the instance.

---

### 🏗️ **Example Setup**

```
us-east-1a
 ├── EC2 instance #1
 │     ├── EBS Volume A (root, delete on termination = true)
 │     └── EBS Volume B (data, delete on termination = false)
 └── EC2 instance #2
       └── EBS Volume C (root)
```

* Each instance can have multiple EBS volumes.
* Each EBS volume can only be attached to **one instance at a time**.









## **Hands-On: Exploring and Managing EBS Volumes in AWS**

### 🧩 **1. Check Existing Volumes on an Instance**

1. Go to the **EC2 Console → Instances**.
2. Click on your **running instance**.
3. Open the **Storage tab**.

   * You’ll see:

     * **Root device** (usually 8 GB)
     * **Block device** showing the attached EBS volume
4. Click on the **Volume ID** to open it in the **EBS → Volumes** section.

**Result:**
You’ll see your current volume (8 GB, “in use”) attached to your EC2 instance.

---

### 💽 **2. Create and Attach a Second Volume**

1. In the **left menu**, choose **Volumes → Create volume**.
2. Select:

   * **Volume type:** `gp2`
   * **Size:** `2 GB`
   * **Availability Zone (AZ):** must match your instance’s AZ
     (Check your instance’s AZ under the **Networking** tab — e.g. `eu-west-1b`)
3. Click **Create volume**.

After creation:

* Status = “Available” (not yet attached)

4. Select the volume → **Actions → Attach volume**.
5. Choose your EC2 instance → **Attach**.

**Result:**
Your instance now has **two EBS volumes** (one 8 GB root + one 2 GB extra).

---

### ⚙️ **3. Verify Attachment**

* Return to your **instance → Storage tab**.
* You’ll now see **two block devices**:

  * 8 GB (root)
  * 2 GB (new volume)

To use the new one, you would **format and mount** it from Linux,
but that’s advanced (out of scope for beginners).

---

### 🗺️ **4. Demonstrate AZ Limitation**

1. Create another volume (again `gp2`, 2 GB).
2. **Choose a *different* Availability Zone** (e.g., `eu-west-1a` instead of `eu-west-1b`).

Now try to **attach** this new volume to your instance.

**Result:**
You **cannot attach** it, because:

> EBS volumes are tied to a specific Availability Zone.

This is a critical exam and real-world point — volumes and instances must be in the same AZ.

---

### 🧹 **5. Delete a Volume**

If a volume is not needed:

1. Select it in **Volumes**.
2. Click **Actions → Delete volume**.
3. Confirm deletion.

It will disappear immediately — showing AWS’s flexibility and speed.

---

### 🔄 **6. Understanding "Delete on Termination"**

When you launch an instance, each storage device has a **Delete on Termination** setting.

* **Root volume:** “Yes” by default → deleted when instance terminates.
* **Additional volumes:** “No” by default → remain after termination.

You can check this under:

* **Instance → Storage → Block devices → scroll right** to the “Delete on Termination” column.

If you terminate the instance:

* Root (8 GB) volume → deleted.
* Attached data (2 GB) volume → remains available.

**Use Case:**
Keep “Delete on Termination = No” if you want to **preserve logs or databases** after instance deletion.

---

### ✅ **Final Verification**

After instance termination:

* Go to **EC2 → Volumes**.
* Refresh.
* The **root 8 GB volume disappears**.
* The **2 GB volume remains**, showing it survived the termination.

---

### 💡 **Summary**

| Action                        | Result                          |
| ----------------------------- | ------------------------------- |
| Create instance               | 8 GB root volume auto-attached  |
| Add new volume (same AZ)      | Attach successfully             |
| Add new volume (different AZ) | Cannot attach                   |
| Terminate instance            | Root deleted, attached one kept |
| Delete volume manually        | Removed instantly               |











## **Amazon EBS Snapshots**

### 💡 **What Is an EBS Snapshot?**

An **EBS Snapshot** is a **backup (point-in-time copy)** of your **EBS Volume**.
It allows you to **save the current state** of your volume data — so you can **restore** it later if needed.

* Think of it like taking a **photo** of your EBS volume at a moment in time.
* You can **create a new EBS volume** from that photo anytime.

---

### 🧩 **1. How It Works**

| Concept                      | Description                                                                                                                                                                                          |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **No Detachment Required**   | You can take a snapshot while the volume is **still attached** to an EC2 instance. (However, for consistent data like databases, it’s recommended to stop the instance or unmount the volume first.) |
| **Cross-AZ or Cross-Region** | Snapshots can be **copied across Availability Zones or Regions**, allowing you to restore EBS volumes anywhere.                                                                                      |
| **Use Case**                 | Move or duplicate a volume from one AZ to another using snapshots.                                                                                                                                   |

**Example:**

```
EBS Volume → Snapshot → Restore in another AZ
us-east-1a          copy → us-east-1b
```

This is how you “move” or “replicate” an EBS volume to another zone or region.

---

### 📦 **2. Key Features of EBS Snapshots**

#### **(a) Snapshot Archive**

* Lets you **move snapshots into a cheaper storage tier** (up to **75% cost savings**).
* Restoring from the archive takes **24–72 hours**.
* Ideal for **long-term backups** that you rarely need to access.

**Think of it like:** moving old photos to cold storage — cheaper, but slower to retrieve.

---

#### **(b) Recycle Bin for Snapshots**

* If you **accidentally delete** a snapshot, it goes to the **Recycle Bin** instead of disappearing immediately.
* You can **recover deleted snapshots** from there.
* Retention period can be set between **1 day and 1 year**.

**Use case:** protect against accidental deletions or human error.

---

#### **(c) Fast Snapshot Restore (FSR)**

* Makes the snapshot **instantly usable** (no initial latency).
* AWS usually initializes snapshots gradually; with FSR, initialization happens immediately.
* Great for **large or critical volumes** that must be restored fast.
* **Warning:** It’s **expensive** — only use it when needed.

**Example use case:** restoring a 1 TB database snapshot for immediate production use.

---

### ⚙️ **3. Typical Workflow**

| Step | Action                                              |
| ---- | --------------------------------------------------- |
| 1    | Create snapshot of an existing EBS volume           |
| 2    | (Optional) Copy it to another Region or AZ          |
| 3    | (Optional) Move to Archive tier for cheaper storage |
| 4    | (Optional) Enable Fast Snapshot Restore             |
| 5    | Restore snapshot into a new EBS volume when needed  |

---

### 🧠 **Quick Summary**

| Feature                   | Purpose                      | Cost        | Restore Time |
| ------------------------- | ---------------------------- | ----------- | ------------ |
| **Standard Snapshot**     | Normal backup                | Normal      | Instant      |
| **Snapshot Archive**      | Cheaper, long-term storage   | 75% cheaper | 24–72 hours  |
| **Recycle Bin**           | Protects deleted snapshots   | None        | N/A          |
| **Fast Snapshot Restore** | Instant recovery, no latency | Expensive   | Instant      |











## **Hands-On: Working with EBS Snapshots in AWS**

### 🧩 **1. Take a Snapshot from an Existing EBS Volume**

1. Go to **EC2 → Volumes**.
2. Select the **2 GB GP2 volume** you created earlier.
3. Choose **Actions → Create snapshot**.
4. Add a description (e.g. `DemoSnapshot`) and click **Create snapshot**.
5. On the left menu, open **Snapshots**.

   * You’ll see the new snapshot with **Status: Completed (100%)** once ready.

✅ **Result:** You’ve successfully created a point-in-time backup of your volume.

---

### 🌍 **2. Copy the Snapshot to Another AWS Region**

This is useful for **disaster recovery** or **multi-region backups**.

1. Select your snapshot → **Actions → Copy snapshot**.
2. Choose any **destination region** (e.g. `us-east-1`, `us-west-2`, etc.).
3. Click **Copy snapshot**.

✅ The snapshot will now be replicated in the new region — a key step in **cross-region backup** strategies.

---

### 💽 **3. Create a New Volume from the Snapshot**

You can restore the snapshot into a **new EBS volume** — even in a different AZ.

1. In the **Snapshots** view → select the snapshot.
2. Click **Actions → Create volume from snapshot**.
3. Configure:

   * **Volume type:** `gp2`
   * **Size:** 2 GB
   * **Availability Zone:** choose a different one (e.g. `eu-west-1b` if the original was `eu-west-1a`)
   * **Encryption:** optional
4. Click **Create volume**.

Then go to **EC2 → Volumes**, and you’ll see:

* The **original 2 GB volume** (source)
* The **new 2 GB volume**, **restored from a snapshot**, in another AZ.

✅ This demonstrates how snapshots allow you to **move data between AZs**.

---

### 🗑️ **4. Protect Snapshots with the Recycle Bin**

The **Recycle Bin** prevents accidental snapshot deletion.

1. Go to **Recycle Bin → Create retention rule**.
2. Name it `DemoRetentionRule`.
3. Select **EBS Snapshots**.
4. Apply to **All resources**.
5. Set **Retention period** to `1 day`.
6. Leave **Rule Lock** unchecked (so you can edit/delete later).
7. Click **Create retention rule**.

✅ Now any deleted snapshots will first move to the Recycle Bin instead of being permanently removed.

---

### 🏷️ **5. Move a Snapshot to the Archive Tier**

1. Go to **EC2 → Snapshots**.
2. Select the snapshot → **Actions → Modify tier / Archive snapshot**.
3. Confirm archiving.

💰 **Benefits:**

* Up to **75 % cheaper** storage.
* **Restore time:** 24–72 hours.
  Use this for long-term, rarely-needed backups.

---

### ♻️ **6. Test Deletion and Recovery**

1. In **EC2 → Snapshots**, select the snapshot and click **Delete snapshot**.

   * It disappears from the list.
2. Go to **Recycle Bin → Resources** → refresh.

   * Your snapshot appears there.
3. Select it → **Actions → Recover resources**.
4. Return to **EC2 → Snapshots** — it’s back!

✅ This proves the Recycle Bin works as expected — you can safely recover deleted snapshots.

---

### 🧠 **Summary Table**

| Feature                         | Purpose               | Key Benefit            | Notes                       |
| ------------------------------- | --------------------- | ---------------------- | --------------------------- |
| **Create Snapshot**             | Backup EBS volume     | Point-in-time restore  | Can be done while attached  |
| **Copy Snapshot**               | Move across Regions   | Disaster recovery      | Secure multi-region storage |
| **Create Volume from Snapshot** | Restore or clone data | Cross-AZ movement      | Useful for scaling          |
| **Recycle Bin**                 | Protect snapshots     | Recover from deletion  | Retention: 1 day–1 year     |
| **Archive Tier**                | Long-term, low-cost   | Save 75 % storage cost | Restore: 24–72 hours        |









## **Amazon Machine Image (AMI)**

### 🧩 **What Is an AMI?**

**AMI** stands for **Amazon Machine Image** — it’s the **template** used to launch an **EC2 instance**.

Think of it as a **“golden image”** that contains:

* The **operating system** (Linux, Windows, etc.)
* **Software and packages** (e.g., Nginx, Docker, Python)
* **System configuration** (users, network settings, scripts)
* **Monitoring and security agents** (e.g., CloudWatch Agent)

Every EC2 instance starts from an AMI — either one provided by AWS or one you create yourself.

---

### ⚙️ **1. Types of AMIs**

| Type                           | Description                                              | Example                                            |
| ------------------------------ | -------------------------------------------------------- | -------------------------------------------------- |
| **Public AMIs (AWS-provided)** | Default, ready-to-use AMIs provided by AWS               | `Amazon Linux 2`, `Ubuntu`, `Windows Server`       |
| **Custom AMIs (User-created)** | You create these yourself after customizing an instance  | Your own preinstalled web app, tools, users, etc.  |
| **Marketplace AMIs**           | Created and sold by third parties on the AWS Marketplace | Bitnami, Fortinet, Jenkins, or commercial software |

✅ **Note:** You can even sell your own AMIs on the AWS Marketplace if you package software or configurations that others need.

---

### 🚀 **2. Why Use a Custom AMI?**

| Benefit                           | Explanation                                                                                    |
| --------------------------------- | ---------------------------------------------------------------------------------------------- |
| **Faster Boot and Configuration** | The software you pre-installed is already there — no need to reconfigure every new instance.   |
| **Consistency**                   | Every new instance is identical — same setup, same packages, same tools.                       |
| **Scaling and Automation**        | Perfect for Auto Scaling Groups — new instances can launch instantly using your pre-built AMI. |
| **Disaster Recovery**             | Rebuild your system anywhere, anytime, using the saved AMI.                                    |

---

### 🧱 **3. How an AMI Is Created (The Process)**

**Step 1:** Launch an EC2 instance (e.g., in `us-east-1a`)
**Step 2:** Customize it — install software, configure settings, test it
**Step 3:** **Stop** the instance (to ensure file system consistency)
**Step 4:** Choose **Actions → Create Image (AMI)**
**Step 5:** AWS automatically creates:

* A **Custom AMI**
* A set of **EBS Snapshots** behind the scenes
  (These snapshots store the actual data that make up your AMI.)

**Step 6:** You can now:

* Launch new EC2 instances **from this AMI**
* Copy this AMI to **other regions** for global use

---

### 🌍 **4. Cross-Region or Cross-AZ Usage**

Once created, your AMI belongs to a **specific region** (e.g., `us-east-1`).

If you want to use it elsewhere:

* You can **copy the AMI** to another region (e.g., `us-west-2`).
* Then, **launch instances** from it in that new region or AZ.

**Example:**

```
Launch EC2 in us-east-1a → Create custom AMI → Copy AMI → Launch EC2 in us-east-1b
```

✅ This is how companies **replicate server setups** across multiple regions for **high availability** or **disaster recovery**.

---

### 🧠 **Key Points to Remember**

| Concept                 | Description                                              |
| ----------------------- | -------------------------------------------------------- |
| AMI = EC2 template      | Defines what your instance contains and how it runs      |
| Backed by EBS Snapshots | Snapshots store the root volume data                     |
| Region-specific         | Must be copied to use in other regions                   |
| Useful for scaling      | Auto Scaling Groups depend on AMIs                       |
| Can be shared or sold   | You can make AMIs public or sell them on AWS Marketplace |

---

### 🖼️ **Simple Analogy**

> An **AMI** is like a **blueprint** for a house.
> You can build (launch) as many identical houses (instances) as you want from that same design.
> And if you move to another city (region), you can copy the blueprint and build there too.












## **Hands-On: Creating and Using an AMI (Amazon Machine Image)**

### 🧩 **Goal**

You’ll create an EC2 instance, install Apache (HTTPD), then **save it as an AMI** so that new instances can launch instantly **without re-installing** anything.

---

### ⚙️ **1. Launch a Base EC2 Instance**

1. Go to **EC2 → Launch instance**.
2. Name it something like **`AMI-Demo`**.
3. **Choose AMI:** `Amazon Linux 2`.
4. **Instance type:** `t2.micro`.
5. **Key pair:** select any (e.g., `easy2-draw`).
6. **Network settings:**

   * Choose an existing **security group** (e.g., `launch-wizard-1`)
   * Make sure **HTTP (port 80)** is allowed.
7. **Storage:** leave defaults.
8. **Advanced details → User data:**

Paste **the first four lines** of your previous HTTPD setup script (installing Apache) — but **omit the last line** that creates the index.html file.

Example:

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
```

9. Click **Launch instance**.

---

### ⏱️ **2. Wait for Initialization**

* The instance will begin running, but **user data scripts take 1–2 minutes** to complete.
* Even if the instance status says **“Running”**, wait until the web server is installed.
* After a few minutes, open the **Public IPv4 address** in your browser using `http://` (not `https`).

✅ You should see the **default Apache test page**.

---

### 💾 **3. Create a Custom AMI**

Once your instance is ready:

1. Right-click (or select) the instance → **Image and templates → Create image**.
2. Name it **`demo-image`**.
3. Leave the default settings and click **Create image**.

Then go to the left menu → **AMIs**.

* You’ll see your new AMI listed with **Status: pending**.
* Wait until it changes to **available**.

✅ You now have your own **custom AMI** that contains:

* Amazon Linux 2
* Apache pre-installed and configured to start automatically

---

### 🚀 **4. Launch a New Instance from Your Custom AMI**

1. In the **AMIs** page, select your AMI (`demo-image`).
2. Click **Launch instance from AMI**.
3. Configure the instance as before:

   * Instance type: `t2.micro`
   * Key pair: any
   * Security group: `launch-wizard-1`
4. **Advanced details → User data:**

Now paste only the lines that **create the webpage**, since HTTPD is already installed.

Example:

```bash
#!/bin/bash
echo "Hello World from AMI" > /var/www/html/index.html
systemctl restart httpd
```

5. Launch the instance.

---

### ⚡ **5. Test the AMI Speed**

* Wait for the instance to show **“Running”**.
* Copy its **Public IP** and open it in your browser:
  `http://<Public-IP>`

✅ You should see:
**“Hello World from AMI”**

Notice how this instance started **much faster** — because:

> Apache was already pre-installed inside the AMI.

---

### 🧠 **6. Why This Is Powerful**

| Advantage           | Explanation                                                           |
| ------------------- | --------------------------------------------------------------------- |
| **Faster Boot**     | No need to reinstall packages; everything is pre-baked.               |
| **Consistency**     | Every instance is identical — great for scaling.                      |
| **Automation**      | Ideal for Auto Scaling Groups, CI/CD pipelines, or disaster recovery. |
| **Custom Software** | Include your own monitoring tools, security agents, or company apps.  |

---

### 🧹 **7. Clean Up**

When you’re done:

* Terminate both EC2 instances.
* Keep the AMI for future labs (optional).

---

### 🖼️ **Process Summary Diagram**

```
Step 1: Launch EC2 → Install Apache (via user data)
Step 2: Test instance
Step 3: Create AMI → "demo-image"
Step 4: Launch new EC2 from demo-image
Step 5: Add custom index.html
Result: Fast boot, Apache already configured ✅
```








## **Amazon EC2 Instance Store (Ephemeral Storage)**

### 🧩 **What It Is**

* An **EC2 Instance Store** is a **temporary, high-performance storage** that is **physically attached** to the host server running your EC2 instance.
* Unlike **EBS (Elastic Block Store)**, which is **network-attached**, the **Instance Store** is **directly connected** to the underlying hardware — giving it **much higher I/O performance**.

---

### ⚙️ **1. How It Works**

When you launch certain EC2 instance types (like `i3`, `d2`, or `m5d`), they come with **Instance Store volumes** pre-attached.

These disks:

* Are **located on the same physical server** as your EC2 instance.
* Are **faster** than network storage (EBS) because data doesn’t travel over the network.
* Are **temporary (ephemeral)** — meaning **data is lost** if:

  * The instance is **stopped**, **terminated**, or
  * The **underlying hardware fails**.

---

### ⚡ **2. Key Characteristics**

| Feature                   | EC2 Instance Store                             | EBS Volume                                |
| ------------------------- | ---------------------------------------------- | ----------------------------------------- |
| **Type**                  | Physical (local) disk                          | Network-attached drive                    |
| **Performance**           | Extremely high IOPS (up to millions)           | High but lower (e.g. 32,000 IOPS for gp2) |
| **Persistence**           | Data lost when instance stops/terminates       | Data persists until deleted               |
| **Use Case**              | Temporary data, caching, buffer, scratch space | Databases, logs, long-term files          |
| **Backup Responsibility** | User must handle manually                      | AWS handles durability and replication    |
| **Attachment**            | Only at instance launch                        | Can attach/detach anytime                 |
| **Availability**          | Only supported by certain instance types       | Supported by almost all                   |

---

### 🔥 **3. Performance Advantage**

* Instance Store can reach **millions of IOPS**:

  * Example: `i3` instances → up to **3.3 million read IOPS** and **1.4 million write IOPS**.
* Compare that with **EBS gp2**, which provides around **32,000 IOPS**.

✅ So if you see “**extremely high performance local storage**” in an exam question —
think **EC2 Instance Store**.

---

### 🧠 **4. Important Notes**

* **Ephemeral nature:**
  If the instance stops or hardware fails → data **disappears permanently**.
  You must **backup or replicate data** to persistent storage (e.g., EBS or S3).

* **Cannot attach after launch:**
  Instance Store volumes are **predefined by instance type** and **cannot be added** later.

* **Use cases:**

  * **Cache / Buffer storage** (e.g., Redis temp data)
  * **Scratch space** for intermediate calculations
  * **Temporary logs** or staging data
  * **High-performance workloads** that don’t require durability

---

### 🧱 **5. Real-World Example**

Imagine you’re processing large amounts of temporary video data:

* You launch an **i3.large** instance (includes NVMe-based Instance Store).
* You store intermediate files locally for fast processing.
* Once done, you move final outputs to **S3** or **EBS** for persistence.
* When you stop or terminate the instance — the local data is gone.

---

### 🧩 **6. Summary**

| Feature                    | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| **Definition**             | Local, high-speed disk physically attached to the EC2 host |
| **Durability**             | Data lost on stop/terminate                                |
| **Speed**                  | Very high (millions of IOPS)                               |
| **Use Case**               | Temporary, transient workloads                             |
| **Backup Needed?**         | Yes — user responsibility                                  |
| **Persistent Alternative** | EBS Volume                                                 |

---

### 💡 **Simple Analogy**

> EBS is like a **USB drive plugged over a network** — slower but persistent.
> Instance Store is like a **built-in SSD inside the computer** — lightning fast but erased when power goes off.








## **Amazon EBS Volume Types**

### 🧩 **Overview**

Amazon EBS (Elastic Block Store) offers **6 volume types**, grouped into **SSD (Solid State Drive)** and **HDD (Hard Disk Drive)** families — each optimized for a specific use case.

| Category                    | Volume Type                  | Description                                              |
| --------------------------- | ---------------------------- | -------------------------------------------------------- |
| **SSD (Performance-based)** | `gp2`, `gp3`                 | General Purpose — balance price and performance          |
|                             | `io1`, `io2` (Block Express) | Provisioned IOPS — mission-critical, consistent high I/O |
| **HDD (Throughput-based)**  | `st1`                        | Throughput Optimized — frequent, large data workloads    |
|                             | `sc1`                        | Cold HDD — infrequent access, lowest cost                |

---

### ⚙️ **1. General Purpose SSDs (gp2 & gp3)**

#### **gp2 – older generation**

* Balances **cost** and **performance**.
* **IOPS are tied to volume size**:

  * Baseline of **3 IOPS per GB**
  * Up to **16,000 IOPS max**
* Can **burst up to 3,000 IOPS** for short periods.
* **Use cases:**

  * Boot volumes
  * Development and testing
  * Web servers
  * Virtual desktops

✅ *Example:*
A 100 GB `gp2` volume = `100 × 3 = 300 IOPS`.

To reach **16,000 IOPS**, volume must be **~5,334 GB**.

---

#### **gp3 – newer generation**

* Successor to gp2 — **cheaper and more flexible**.
* Provides **baseline 3,000 IOPS** and **125 MB/s throughput**, regardless of size.
* You can **independently** increase:

  * **IOPS** → up to **16,000**
  * **Throughput** → up to **1,000 MB/s**
* **Use cases:**

  * Same as gp2 but for modern workloads (default choice today)

✅ *Key difference:*
`gp3` allows tuning performance **independent of volume size** — perfect for cost optimization.

---

### ⚡ **2. Provisioned IOPS SSDs (io1 & io2 Block Express)**

Designed for **mission-critical**, **low-latency**, and **high-throughput** workloads.

#### **io1**

* Size: **4 GB – 16 TB**
* Provision up to **64,000 IOPS** on Nitro-based instances
* Can **set IOPS separately** from storage size
* **Supports Multi-Attach** (attach one EBS volume to multiple EC2 instances)
* **Use cases:**

  * Production databases (e.g., Oracle, MySQL, PostgreSQL)
  * High-transaction systems

---

#### **io2 / io2 Block Express**

* Next-generation version of io1 with **better durability and higher performance**.
* Size: up to **64 TB**
* Latency: **sub-millisecond**
* IOPS: up to **256,000**
* **IOPS-to-GB ratio**: up to **1,000:1**
* **99.999% durability**

**Use cases:**

* Enterprise databases
* Financial or healthcare systems needing consistent high I/O

✅ *Note:*
If you see “critical database workload” or “>16,000 IOPS needed” → choose **io1** or **io2**.

---

### 💽 **3. HDD Volumes (st1 & sc1)**

These are **magnetic disks** optimized for **throughput (MB/s)**, not IOPS.

#### **st1 – Throughput Optimized HDD**

* Size: up to **16 TB**
* Max throughput: **500 MB/s**
* Max IOPS: **500**
* **Cannot be boot volumes**
* **Use cases:**

  * Big data analytics
  * Data warehouses
  * Log processing
  * Streaming workloads

---

#### **sc1 – Cold HDD**

* Size: up to **16 TB**
* Max throughput: **250 MB/s**
* Max IOPS: **250**
* **Lowest cost** option
* **Use cases:**

  * Archival data
  * Backups or rarely accessed datasets

✅ *Exam tip:*
If the question says “lowest cost” + “infrequently accessed data,” pick **sc1**.

---

### 🧠 **4. Boot Volume Rules**

Only the following **can be used as boot/root volumes:**

* `gp2`
* `gp3`
* `io1`
* `io2`

❌ `st1` and `sc1` cannot be used as boot volumes.

---

### 🧾 **5. Key Metrics**

| Metric                               | Meaning                                                                   |
| ------------------------------------ | ------------------------------------------------------------------------- |
| **IOPS (I/O Operations per Second)** | Measures how many read/write operations per second the volume can handle. |
| **Throughput (MB/s)**                | Measures data transfer speed.                                             |
| **Latency**                          | Time delay between request and response.                                  |

---

### 🧩 **6. Summary Table**

| Type                    | Category | Boot? | Max Size | Max IOPS | Max Throughput | Best For                          |
| ----------------------- | -------- | ----- | -------- | -------- | -------------- | --------------------------------- |
| **gp3**                 | SSD      | ✅     | 16 TB    | 16 000   | 1 000 MB/s     | General purpose, cost-efficient   |
| **gp2**                 | SSD      | ✅     | 16 TB    | 16 000   | 250 MB/s       | Older general purpose             |
| **io1**                 | SSD      | ✅     | 16 TB    | 64 000   | 1 000 MB/s     | Databases needing consistent IOPS |
| **io2 (Block Express)** | SSD      | ✅     | 64 TB    | 256 000  | 4 000 MB/s     | Mission-critical, sub-ms latency  |
| **st1**                 | HDD      | ❌     | 16 TB    | 500      | 500 MB/s       | Big data, frequent access         |
| **sc1**                 | HDD      | ❌     | 16 TB    | 250      | 250 MB/s       | Cold storage, infrequent access   |

---

### 💡 **7. Exam Tip Summary**

| Scenario                            | Best Volume Type                |
| ----------------------------------- | ------------------------------- |
| Boot volume, web server, dev/test   | **gp3**                         |
| Database needing steady performance | **io1** or **io2**              |
| High throughput, frequent access    | **st1**                         |
| Archival, rarely accessed data      | **sc1**                         |
| Over 32 000 IOPS required           | **io1/io2 with Nitro instance** |
| Need low cost + SSD speed           | **gp3**                         |

---

### 🖼️ **Simple Analogy**

> Think of EBS like car tires:
>
> * `gp3` = all-purpose tires (balanced, reliable)
> * `io1/io2` = racing tires (maximum performance)
> * `st1` = heavy-duty truck tires (for big loads)
> * `sc1` = spare tire (cheapest, only for emergencies)










## **EBS Multi-Attach**

### 🧩 **What It Is**

**EBS Multi-Attach** allows you to **attach a single EBS volume to multiple EC2 instances simultaneously** — **within the same Availability Zone (AZ)**.

* All attached instances can **read and write** to the same volume **at the same time**.
* This feature is available **only for `io1` and `io2` (Provisioned IOPS SSD)** volume types.

---

### ⚙️ **1. Key Characteristics**

| Feature                     | Description                                             |
| --------------------------- | ------------------------------------------------------- |
| **Supported Volume Types**  | `io1` and `io2` only                                    |
| **Availability Zone Scope** | Works **only within the same AZ**                       |
| **Max Number of Instances** | Up to **16 EC2 instances** can attach the same volume   |
| **Access Type**             | Each instance gets **full read/write access**           |
| **Performance**             | High throughput, low latency (since `io1/io2` are used) |

---

### 💡 **2. Why Use Multi-Attach**

Use Multi-Attach when multiple servers need to **access the same shared storage simultaneously**, **without creating copies** of the data.

**Typical use cases:**

* **Clustered Linux applications** (e.g., Oracle RAC, Teradata)
* **High-availability (HA) clusters**
* **Applications managing concurrent writes** at the software level
* **Distributed caching or compute grids** that require shared block storage

---

### 🚫 **3. Limitations**

1. **Single AZ only:**
   You cannot attach the same EBS volume across multiple Availability Zones.

2. **Cluster-aware file system required:**

   * Normal file systems (like **ext4**, **XFS**) will **corrupt data** if multiple servers write at once.
   * You must use **cluster-aware file systems**, e.g.:

     * **OCFS2** (Oracle Cluster File System)
     * **GFS2** (Red Hat Global File System)
     * **IBM GPFS**
   * These are designed to handle **synchronized access** and **metadata locking**.

3. **Root volumes not supported:**
   Multi-Attach volumes can only be **data volumes**, not **boot/root volumes**.

4. **No cross-region or cross-AZ attachment:**
   Each Multi-Attach configuration exists **inside a single AZ**.

---

### 🧱 **4. How It Works (Conceptually)**

**Example setup:**

```
us-east-1a
 ├── EC2 instance A
 ├── EC2 instance B
 ├── EC2 instance C
 └── io2 volume (Multi-Attach enabled)
```

* All three EC2 instances share and access the same io2 volume simultaneously.
* Each instance sees the same data blocks.
* Application logic or the cluster file system ensures synchronization.

---

### 🧠 **5. Exam Tips**

| Question Type                                                           | Correct Answer / Concept                     |
| ----------------------------------------------------------------------- | -------------------------------------------- |
| “Attach one EBS volume to multiple EC2 instances for high availability” | Use **io1/io2 Multi-Attach**                 |
| “Share EBS volume across AZs”                                           | ❌ Not possible (use S3, EFS, or FSx instead) |
| “How many instances can share one volume?”                              | **Up to 16**                                 |
| “Which file system is needed?”                                          | **Cluster-aware (OCFS2, GFS2, etc.)**        |
| “Which types support Multi-Attach?”                                     | **io1 and io2 only**                         |

---

### ⚙️ **6. Comparison Summary**

| Feature                           | gp2/gp3                           | io1/io2 (Multi-Attach Enabled) |
| --------------------------------- | --------------------------------- | ------------------------------ |
| **Attach to multiple instances?** | ❌ No                              | ✅ Yes                          |
| **AZ restriction**                | N/A                               | Same AZ only                   |
| **Use case**                      | Regular single-instance workloads | Clustered, HA applications     |
| **File system**                   | ext4/XFS                          | Cluster-aware (OCFS2, GFS2)    |
| **Performance**                   | Good                              | Very high                      |

---

### 💡 **Quick Analogy**

> Think of Multi-Attach like **multiple chefs sharing one kitchen** —
> they can all cook (read/write), but only if they follow a system (cluster-aware file system)
> so they don’t bump into each other and spoil the recipe (data corruption).






## **EBS Encryption**

### 🧩 **What It Does**

When you create an **encrypted EBS volume**, AWS automatically encrypts:

1. **Data at rest** – stored inside the volume
2. **Data in transit** – moving between the EC2 instance and the EBS volume
3. **Snapshots** – created from that encrypted volume
4. **New volumes** – restored from encrypted snapshots

Everything connected to an encrypted volume remains encrypted — end to end.

Encryption and decryption happen **transparently** (you don’t need to change your application or OS).

---

### 🔐 **1. Encryption Mechanism**

| Concept                | Details                                            |
| ---------------------- | -------------------------------------------------- |
| **Algorithm**          | AES-256 encryption                                 |
| **Key Management**     | AWS **KMS (Key Management Service)**               |
| **Latency Impact**     | Almost **none** (handled by hardware acceleration) |
| **Default Encryption** | Can be enabled account-wide for all new volumes    |

✅ *Best practice:* Always enable EBS encryption — it’s free, secure, and fast.

---

### ⚙️ **2. Creating an Encrypted EBS Volume**

When launching or creating a volume:

1. Go to **EC2 → Volumes → Create volume**
2. Check **“Encrypt this volume”**
3. Choose a **KMS key** (default or customer-managed)
4. Click **Create volume**

Your new volume will display:

```
State: available
Encryption: encrypted
```

---

### 🔁 **3. How to Encrypt an Existing (Unencrypted) EBS Volume**

You **cannot directly encrypt** an existing unencrypted EBS volume.
Instead, you must go through **snapshots**.

#### **Step-by-step process**

1. **Create a snapshot** of your unencrypted volume.

   * Result → *Snapshot is also unencrypted.*

2. **Copy the snapshot**, and during the copy:

   * Enable **Encryption**
   * Select a **KMS key**
   * Keep the same region or copy to another region

3. Once the **encrypted snapshot** is ready,
   **Create a new EBS volume** from it.

4. The **new volume** is now **encrypted**.
   You can attach it to your original EC2 instance.

✅ You’ve successfully converted an unencrypted volume into an encrypted one!

---

### 🧩 **4. Shortcut Option**

Instead of creating a copy, AWS also allows **on-the-fly encryption** when creating a volume directly from an unencrypted snapshot.

**Steps:**

* Go to your unencrypted snapshot → **Actions → Create volume from snapshot**
* In the creation dialog:

  * Enable **Encryption**
  * Choose a **KMS key**
* Click **Create volume**

Now the new volume is encrypted automatically — a quicker path to secure existing data.

---

### 🧠 **5. Exam + Practical Notes**

| Concept                      | Remember                                                       |
| ---------------------------- | -------------------------------------------------------------- |
| Encryption is **automatic**  | All linked snapshots and future volumes inherit encryption     |
| **KMS keys** are used        | Either AWS-managed or customer-managed                         |
| **Cross-region copies**      | Encryption can be applied during copy                          |
| **Cannot remove encryption** | Once encrypted, a volume or snapshot **cannot be unencrypted** |
| **Performance**              | Minimal impact — fully hardware-accelerated                    |
| **Billing**                  | No extra cost for encryption; only normal EBS usage costs      |

---

### 💡 **6. Example Workflow Summary**

```
Unencrypted Volume
   ↓ (Create Snapshot)
Unencrypted Snapshot
   ↓ (Copy with encryption enabled)
Encrypted Snapshot
   ↓ (Create Volume)
Encrypted Volume
   ↓
Attach to EC2 Instance ✅
```

---

### 🧹 **7. Cleanup (Best Practice)**

After testing:

* Delete snapshots (`Actions → Delete snapshot`)
* Delete volumes (`Actions → Delete volume`)

This keeps your AWS storage costs low.

---

### 🔒 **8. Quick Analogy**

> Think of EBS encryption like having **a safe inside a secure truck**:
>
> * The data (safe contents) is encrypted at rest
> * The truck (EC2 connection) encrypts data while moving
> * Every copy or duplicate safe (snapshot or volume) is also automatically locked
> * And you hold the **key (KMS)** that controls access.










## **Amazon EFS (Elastic File System)**

### 🧩 **What It Is**

**EFS (Elastic File System)** is a **fully managed Network File System (NFS)** that allows **multiple EC2 instances** to share the same data **simultaneously**, even across **multiple Availability Zones**.

* It’s **highly available**, **scalable**, and **managed by AWS**.
* It behaves like a **shared drive** for your Linux servers.
* **You pay only for what you use** — no need to pre-provision storage.

---

### ⚙️ **1. Core Characteristics**

| Feature                       | Description                                                 |
| ----------------------------- | ----------------------------------------------------------- |
| **Type**                      | Managed NFS (Network File System)                           |
| **Access**                    | Mountable on **many EC2 instances**, across multiple AZs    |
| **OS Compatibility**          | **Linux only** (not compatible with Windows)                |
| **Protocol**                  | NFSv4.1                                                     |
| **Encryption**                | Supported at rest and in transit (via **KMS**)              |
| **Scaling**                   | Automatic — grows and shrinks as files are added or removed |
| **Payment**                   | **Pay-per-use** (per GB stored per month)                   |
| **Durability & Availability** | Multi-AZ replication for Standard class                     |

---

### 🌐 **2. Architecture Overview**

```
               ┌──────────────┐
us-east-1a →   │  EC2 Instance│
               └──────┬───────┘
                      │
us-east-1b →   ┌──────┴───────┐
               │  Amazon EFS  │  ←  Shared file system (NFS)
us-east-1c →   └──────┬───────┘
                      │
               ┌──────┴───────┐
               │  EC2 Instance│
               └──────────────┘
```

All instances can read/write to the same files at once — ideal for **shared applications**.

---

### 💡 **3. Use Cases**

* **Web content storage** (e.g., WordPress shared uploads)
* **Content management systems (CMS)**
* **Big data and analytics**
* **Application data sharing** between multiple servers
* **Media processing workflows**

---

### 💰 **4. Cost & Performance**

* EFS is **~3× more expensive than EBS gp2**, but offers **scalability and multi-instance access**.
* You **don’t provision capacity** — AWS handles growth automatically.

---

### ⚙️ **5. Performance Modes**

| Mode                          | Description                                           | Use Case                              |
| ----------------------------- | ----------------------------------------------------- | ------------------------------------- |
| **General Purpose (default)** | Low latency, best for typical use                     | Web servers, CMS                      |
| **Max I/O**                   | Higher latency but scales to thousands of connections | Big data, media processing, analytics |

---

### ⚡ **6. Throughput Modes**

| Mode                   | Description                                              | Example Use Case                 |
| ---------------------- | -------------------------------------------------------- | -------------------------------- |
| **Bursting (default)** | Throughput scales with file system size; includes bursts | Most workloads                   |
| **Provisioned**        | Set a fixed throughput (independent of storage size)     | Consistent, heavy workloads      |
| **Elastic**            | Automatically scales up/down based on workload           | Unpredictable or spiky workloads |

**Example:**

* 1 TB = 50 MB/s base + bursts to 100 MB/s
* Elastic mode can scale up to **3 GB/s read** and **1 GB/s write**

---

### 🗂️ **7. Storage Classes & Lifecycle Management**

EFS supports **storage tiers** to optimize cost automatically.

| Storage Tier                       | Description                                            | Use Case                  |
| ---------------------------------- | ------------------------------------------------------ | ------------------------- |
| **EFS Standard**                   | Default, for frequently accessed data                  | Production, shared apps   |
| **EFS Infrequent Access (EFS-IA)** | Lower storage cost, retrieval fee applies              | Files not accessed often  |
| **EFS Archive**                    | For rarely accessed files (e.g., once or twice a year) | Long-term storage         |
| **EFS One Zone**                   | Stored in a single AZ (lower availability)             | Dev/test environments     |
| **EFS One Zone-IA**                | One-AZ + infrequent access                             | Low-cost development data |

You can configure **lifecycle policies**:

> e.g., move files from **Standard → IA** after 60 days of no access.

✅ This can reduce costs by **up to 90 %**.

---

### 🔐 **8. Security & Encryption**

* **Encryption at rest:** Managed by **AWS KMS (AES-256)**
* **Encryption in transit:** Using TLS between EC2 and EFS
* **Access control:**

  * **Security groups** (control network access)
  * **POSIX file permissions** (UID/GID, chmod)

---

### 🧠 **9. Quick Comparison with Other AWS Storage**

| Feature      | **EBS**                | **EFS**                | **S3**             |
| ------------ | ---------------------- | ---------------------- | ------------------ |
| **Type**     | Block storage          | File storage           | Object storage     |
| **Access**   | One instance at a time | Many instances         | Any via API        |
| **Protocol** | Block (attached disk)  | NFS                    | REST/HTTPS         |
| **Scaling**  | Manual (resize)        | Automatic              | Automatic          |
| **Use Case** | Databases, OS          | Shared files, web apps | Backups, data lake |
| **Pricing**  | Per GB provisioned     | Per GB used            | Per GB used        |

---

### 🧩 **10. Summary Table**

| Category             | Option                             | Description                       |
| -------------------- | ---------------------------------- | --------------------------------- |
| **Performance Mode** | General Purpose / Max I/O          | Balance latency vs. throughput    |
| **Throughput Mode**  | Bursting / Provisioned / Elastic   | Control how EFS scales throughput |
| **Storage Class**    | Standard / IA / Archive / One Zone | Optimize cost and redundancy      |
| **File System Type** | NFSv4                              | Linux only                        |
| **Encryption**       | At rest & in transit               | Uses KMS AES-256                  |
| **Scalability**      | Auto, petabyte-scale               | Thousands of connections          |

---

### 🧩 **11. Exam Tip Summary**

| Question Mentions                     | Correct Answer              |
| ------------------------------------- | --------------------------- |
| “Shared file system across AZs”       | **EFS**                     |
| “Linux only, NFS protocol”            | **EFS**                     |
| “Auto-scaling storage”                | **EFS**                     |
| “Need cheaper infrequent access tier” | **EFS-IA**                  |
| “Single AZ, dev environment”          | **EFS One Zone**            |
| “POSIX permissions”                   | **EFS**                     |
| “Compare cost with gp2”               | **EFS ≈ 3× more expensive** |











## **Hands-On: Amazon EFS (Elastic File System)**

### 🧩 **Goal**

Set up an **EFS file system**, connect it to **two EC2 instances** across different Availability Zones, and verify that both can **share files simultaneously**.

---

## **Step 1 — Create an EFS File System**

1. **Open** the AWS Console → **EFS** → **Create file system**.
2. You can simply click **Create**, but to explore options, choose **Customize**.

### Key Options

| Setting                  | Explanation                                                                                                                              |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **File System Type**     | - **Regional** (multi-AZ, high availability — *recommended for production*)<br>- **One Zone** (single AZ, cheaper — *for dev/test only*) |
| **Automatic Backups**    | Enable it (recommended)                                                                                                                  |
| **Lifecycle Management** | Move files automatically between tiers (Standard → IA → Archive)                                                                         |
| **Encryption**           | Leave enabled (uses **KMS AES-256**)                                                                                                     |

### Lifecycle Example

| Condition                     | Action                        |
| ----------------------------- | ----------------------------- |
| File not accessed for 30 days | Move to **Infrequent Access** |
| File not accessed for 90 days | Move to **Archive**           |
| File accessed again           | Move back to **Standard**     |

---

## **Step 2 — Configure Performance and Throughput**

### **Throughput Modes**

| Mode                   | Description                                        | Use Case                             |
| ---------------------- | -------------------------------------------------- | ------------------------------------ |
| **Bursting (default)** | Scales with storage size                           | Most general workloads               |
| **Elastic**            | Automatically adjusts throughput based on workload | **Recommended** — no tuning required |
| **Provisioned**        | You manually set desired throughput                | Predictable, high-traffic workloads  |

### **Performance Modes**

| Mode                | Description                                   | Best For            |
| ------------------- | --------------------------------------------- | ------------------- |
| **General Purpose** | Low latency                                   | Web servers, CMS    |
| **Max I/O**         | Higher latency but higher parallel throughput | Big data, analytics |

✅ Recommended setting:
**Throughput Mode:** Elastic
**Performance Mode:** General Purpose

---

## **Step 3 — Configure Network Access**

1. **Select VPC:** Choose your default VPC.

2. **Mount Targets:** Automatically created across available AZs.

3. **Create Security Group:**

   * Name: `sg-efs-demo`
   * Description: `EFS Demo SG`
   * Initially no inbound rules (AWS will handle these later).

4. Refresh the EFS setup page, select your **EFS security group**, and click **Next → Create**.

✅ The file system will now show status **Available**.
You’ll see a small usage (e.g., 6 KB), but costs remain zero until you actually store data.

---

## **Step 4 — Launch EC2 Instances**

You’ll create **two instances** in **different Availability Zones** (to test EFS cross-AZ access).

### **Instance A**

1. EC2 → **Launch instance**
2. **Name:** `Instance-A`
3. **AMI:** Amazon Linux 2
4. **Type:** `t2.micro`
5. **Key pair:** None (use EC2 Instance Connect)
6. **Subnet:** `eu-west-1a`
7. **Storage:** Default 8 GB gp2
8. **File System:**

   * Click **Add file system → EFS**
   * Select your created EFS
   * Mount point: `/mnt/efs/fs1`
   * AWS will automatically create required **security groups** and **user-data scripts** for mounting.

Click **Launch Instance** ✅

---

### **Instance B**

Repeat the steps above with:

* **Name:** `Instance-B`
* **Subnet:** `eu-west-1b`
* Select the same **EFS file system**.

---

## **Step 5 — Verify Network Configuration**

After both instances are **Running**:

* In the **EFS console → Network tab**, notice:

  * Auto-created SGs like `efs-sg-1` and `efs-sg-2`
  * Each allows **NFS (port 2049)** inbound access
  * Each is linked to the corresponding EC2 instance SG.

AWS automatically handled all the NFS networking for you!

---

## **Step 6 — Test EFS Mounting**

1. Connect to both instances using **EC2 Instance Connect**.

2. On **Instance A**, verify the mount:

   ```bash
   ls /mnt/efs/fs1/
   ```

   Should list an empty directory.

3. Create a file:

   ```bash
   sudo su
   echo "hello world" > /mnt/efs/fs1/hello.txt
   cat /mnt/efs/fs1/hello.txt
   ```

   Output:

   ```
   hello world
   ```

4. On **Instance B**, run:

   ```bash
   ls /mnt/efs/fs1/
   cat /mnt/efs/fs1/hello.txt
   ```

   Output:

   ```
   hello world
   ```

✅ **Both instances see the same file in real-time** — confirming shared storage.

---

## **Step 7 — Clean Up**

1. Terminate both EC2 instances.
2. In **EFS**, select and **delete** your file system.
3. Delete the **auto-created security groups** (`efs-sg-1`, `efs-sg-2`, etc.) to avoid clutter.

---

## **✅ Summary**

| Feature               | Description                                     |
| --------------------- | ----------------------------------------------- |
| **Type**              | Managed, scalable **Network File System (NFS)** |
| **Multi-AZ Access**   | Yes (Regional type)                             |
| **Auto-Scaling**      | Grows/shrinks automatically                     |
| **Encryption**        | At rest and in transit (via KMS)                |
| **Performance Modes** | General Purpose / Max I/O                       |
| **Throughput Modes**  | Bursting / Elastic / Provisioned                |
| **Storage Tiers**     | Standard / IA / Archive / One Zone              |
| **Protocol**          | NFSv4.1                                         |
| **OS**                | Linux only                                      |
| **Pricing**           | Pay-per-use, 3× cost of EBS gp2                 |

---

### 💡 **What You Learned**

* How to create an **EFS file system**
* How to enable **lifecycle management and encryption**
* How to **auto-mount EFS** to EC2 instances
* How to **verify shared storage access across AZs**








## **EBS vs. EFS vs. Instance Store**

### 🧩 **1. Overview**

| Storage Type                  | Description                                                               | Key Use Case                                   |
| ----------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------- |
| **EBS (Elastic Block Store)** | Block-level storage attached to a single EC2 instance (like a hard drive) | Boot volumes, databases, app data              |
| **EFS (Elastic File System)** | Network File System (NFS) that can be shared across many EC2 instances    | Shared data, web apps, CMS (WordPress)         |
| **Instance Store**            | Physical disk directly attached to the host machine                       | Temporary cache, scratch space, ephemeral data |

---

## **2. Detailed Comparison**

| Feature                     | **EBS**                                                                            | **EFS**                                   | **Instance Store**                     |
| --------------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------- | -------------------------------------- |
| **Type**                    | Block storage                                                                      | File storage (NFS)                        | Local ephemeral storage                |
| **Attachment**              | One instance at a time *(except io1/io2 Multi-Attach)*                             | Many instances across multiple AZs        | Only to one EC2 (physically bound)     |
| **Availability Zone Scope** | Locked to one AZ                                                                   | Accessible across multiple AZs (Regional) | Same host only                         |
| **Persistence**             | Data persists after instance stop/terminate (unless delete-on-termination enabled) | Data persists even if EC2s stop           | Data lost when instance stops or fails |
| **Protocol**                | Block device                                                                       | NFSv4.1                                   | Direct disk access                     |
| **Performance**             | High IOPS (SSD or HDD options)                                                     | High throughput, scalable                 | Extremely high (direct hardware)       |
| **Scalability**             | Fixed size (must provision storage)                                                | Auto-scales to petabytes                  | Fixed per instance type                |
| **Pricing**                 | Pay for **provisioned capacity**                                                   | Pay for **storage used** (per GB)         | Included with instance cost            |
| **OS Compatibility**        | Linux & Windows                                                                    | **Linux only**                            | Linux & Windows                        |
| **Use Case Examples**       | Databases, boot disks, logs                                                        | Web servers, CMS, shared content          | Caches, temporary data processing      |
| **Encryption**              | Supported via KMS                                                                  | Supported via KMS                         | Not supported                          |
| **Backup**                  | Snapshots (EBS Snapshots)                                                          | AWS Backup integration                    | Manual (user responsibility)           |

---

## **3. EBS (Elastic Block Store) Key Notes**

* Attached to **one EC2** in a **single AZ**
* Can migrate to another AZ by:

  1. Taking a **snapshot**
  2. **Restoring** the snapshot in a different AZ
* **IOPS scaling:**

  * `gp2`: IOPS increases with size (3 IOPS/GB)
  * `gp3`, `io1`, `io2`: IOPS and throughput can be set **independently**
* **Multi-Attach:** available only for `io1`/`io2` — up to **16 instances in same AZ**
* **Root volumes** deleted by default upon instance termination (configurable)
* Backups use I/O — avoid during high-traffic times

✅ **Best for:** Boot volumes, databases, app storage needing high performance and durability

---

## **4. EFS (Elastic File System) Key Notes**

* Managed **NFS (Network File System)** service
* Can be mounted by **hundreds of EC2 instances**
* Works **across multiple Availability Zones** (Regional)
* Automatically **scales** to petabytes — no need to pre-size
* **Pay-per-use** pricing model
* **Higher cost** than EBS (≈ 3×), but **shared and scalable**
* Supports **storage tiers**:

  * **Standard** (frequent access)
  * **Infrequent Access (IA)** and **Archive** (for cost savings)
* **Lifecycle policies** move files between tiers automatically

✅ **Best for:** Shared Linux workloads — e.g. WordPress, content sharing, CMS, home directories, analytics

---

## **5. Instance Store Key Notes**

* **Local physical disks** attached to the host EC2 server
* Offers **very high IOPS and throughput**
* **Data lost** when instance stops, terminates, or hardware fails
* **No persistence or snapshot support**
* Used for **temporary data**, caches, or buffers
* **Included** in instance pricing (no separate cost)

✅ **Best for:** Temporary or fast scratch data — not for permanent storage

---

## **6. Practical Example**

| Scenario                             | Recommended Storage |
| ------------------------------------ | ------------------- |
| Web server with persistent logs      | **EBS (gp3)**       |
| WordPress cluster shared across AZs  | **EFS**             |
| Database needing consistent IOPS     | **EBS io1/io2**     |
| Temporary processing (e.g., caching) | **Instance Store**  |
| Big data or media streaming          | **EFS (Max I/O)**   |
| Boot volume for EC2                  | **EBS**             |

---

## **7. Key Takeaways for Exams**

| Question Mentions                           | Correct Answer     |
| ------------------------------------------- | ------------------ |
| “Attach to only one EC2 instance”           | **EBS**            |
| “Mount on multiple EC2s across AZs”         | **EFS**            |
| “Temporary storage, lost on stop/terminate” | **Instance Store** |
| “Auto-scaling storage, NFS, Linux only”     | **EFS**            |
| “Block-level storage for databases”         | **EBS**            |
| “Need Multi-AZ shared storage”              | **EFS**            |
| “Physically attached storage”               | **Instance Store** |

---

### 💡 **Analogy**

> * **EBS** = your personal SSD drive — fast, reliable, one user at a time.
> * **EFS** = a shared network drive — multiple users access together.
> * **Instance Store** = temporary workspace on a computer — gone when powered off.










## **🧹 AWS Clean-Up After the EBS & EFS Labs**

### **1. Delete the EFS File System**

1. Go to **EFS Console → File systems**.
2. Select your file system → **Actions → Delete file system**.
3. Copy the **File System ID** (for example, `fs-0abcd1234efgh5678`) and paste it into the confirmation box.
4. Click **Delete** ✅

   > Wait a few seconds — status will change to *Deleting* and then *Deleted*.

---

### **2. Terminate EC2 Instances**

1. Go to **EC2 Console → Instances**.
2. Select all running or stopped instances from this lab.
3. **Instance state → Terminate instance**.
4. Confirm termination.

   > When done, state changes from *Shutting down* → *Terminated*.

---

### **3. Delete Unused Volumes**

1. Navigate to **EC2 Console → Volumes (under Elastic Block Store)**.
2. Look for any volumes with **State = available** (these are detached).
3. Select them → **Actions → Delete volume** → Confirm.

   > This removes any leftover EBS storage that could otherwise incur charges.

---

### **4. Delete Snapshots**

1. In **EC2 Console → Snapshots**, select any snapshots you created during practice.
2. **Actions → Delete snapshot** → Confirm deletion.

   > Snapshots persist in S3 behind the scenes, so deleting them stops storage billing.

---

### **5. Delete Extra Security Groups**

1. Go to **EC2 Console → Security Groups**.
2. Select and delete unnecessary groups created during this section (for example, `efs-sg-1`, `efs-sg-2`, or `sg-efs-demo`).
3. Keep the **default security group** for your VPC — do *not* delete it.
4. If deletion fails:

   * Ensure all EC2 instances using that SG are **terminated**.
   * Retry deletion after a few minutes.

---

### **6. (Optional) Check Load Balancers or Other Resources**

If you created or tested any **Elastic Load Balancer** or **Target Groups**, delete them as well:

* EC2 Console → **Load Balancers → Actions → Delete**
* Confirm deletion

---

### **7. Verify Everything Is Gone**

* **Instances tab** → No running/stopped instances.
* **Volumes tab** → Empty.
* **Snapshots tab** → Empty.
* **EFS console** → No file systems.
* **Security groups tab** → Only default groups remain.
* **Billing console (optional)** → Monitor “Zero cost” for EC2, EBS, EFS.

---

✅ **Result:**
Your AWS environment is now completely clean — no file systems, no instances, no volumes, and no leftover snapshots.
You’re ready to start fresh in the **next section** without accumulating charges.









