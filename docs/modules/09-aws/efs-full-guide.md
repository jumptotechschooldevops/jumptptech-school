---
title: "AWS fundamentals: RDS+Aurora+ElastiCache"
description: "1. What is RDS?   RDS = Relational Database Service — a managed SQL database service by..."
published: 2025-10-09
source: "https://dev.to/jumptotech/efs-full-guide-1ae3"
tags: []
---

# AWS fundamentals: RDS+Aurora+ElastiCache



### **1. What is RDS?**

RDS = **Relational Database Service** — a **managed SQL database service** by AWS.
It allows you to create, operate, and scale relational databases without managing the underlying OS or hardware.

---

### **2. Supported Database Engines**

* **PostgreSQL**
* **MySQL**
* **MariaDB**
* **Oracle**
* **Microsoft SQL Server**
* **IBM DB2**
* **Amazon Aurora** (AWS’s own high-performance database engine)

---

### **3. Why Use RDS Instead of EC2-hosted Database**

| Feature               | RDS                               | EC2-hosted Database |
| --------------------- | --------------------------------- | ------------------- |
| Setup                 | Automated provisioning            | Manual setup        |
| OS & Patch Management | Managed by AWS                    | You manage it       |
| Backups               | Automatic + Point-in-Time Restore | Manual              |
| Monitoring            | CloudWatch integration            | Custom setup needed |
| Scaling               | Vertical & Horizontal             | Manual intervention |
| Maintenance           | Automatic windows                 | Manual              |
| SSH Access            | ❌ Not allowed                     | ✅ You manage it     |

---

### **4. Key RDS Features**

* **Automated provisioning**
* **Automated backups** with **Point-in-Time Restore**
* **Read replicas** for read scaling
* **Multi-AZ deployments** for high availability
* **Maintenance windows** for scheduled upgrades
* **CloudWatch monitoring** for performance metrics
* **Storage Auto Scaling** (see below)

---

### **5. Storage Auto Scaling**

* Automatically increases storage when running low on space.
* Triggers when:

  * Free storage < 10%
  * Low storage persists for > 5 minutes
  * At least 6 hours since last resize
* Requires you to set a **maximum storage threshold**.
* Works for **all RDS engines**.
* Great for **unpredictable workloads**.

---

### **6. Exam Tip**

You **cannot SSH** into an RDS instance — AWS fully manages the OS layer.


## 🧠 What “You cannot SSH into an RDS instance” means

When you create a **regular EC2 instance**, you’re creating a **virtual machine** that runs an **operating system (like Amazon Linux or Ubuntu)**.
You can connect to that OS using:

```bash
ssh ec2-user@<EC2-public-IP>
```

You get full control — you can install packages, configure services, edit files, etc.

---

### 🔒 But RDS is **different**:

When you create an **RDS instance**, AWS does **not** give you access to the **operating system layer**.
You **cannot SSH** or log into it like an EC2 server.

Why?
Because **AWS manages that OS for you.**

So:

* You **cannot** do:

  ```bash
  ssh ec2-user@database-1.co1kwukgimqf.us-east-1.rds.amazonaws.com
  ```

  It will fail.

* You **can** do:

  ```bash
  mysql -h database-1.co1kwukgimqf.us-east-1.rds.amazonaws.com -P 3306 -u admin -p
  ```

  That’s how you connect — through the **MySQL protocol**, not SSH.

---

## 🧱 How to Think About It

| Layer              | EC2                                   | RDS                          |
| ------------------ | ------------------------------------- | ---------------------------- |
| Operating System   | You manage (can SSH)                  | AWS manages (no SSH)         |
| Database Engine    | You install (MySQL, PostgreSQL, etc.) | AWS installs and maintains   |
| Backups / Patching | You handle                            | AWS automates                |
| Access             | SSH + Application                     | MySQL/PostgreSQL client only |

So, when AWS says “You cannot SSH into an RDS instance,” it means:

> RDS gives you access to the **database layer only**, not the **underlying server OS**.

---

## 💡 Analogy

Think of RDS as **a managed restaurant kitchen**:

* You can order any dish (run SQL queries),
* But you cannot go inside the kitchen (no OS access),
* AWS chefs handle cooking, cleaning, and upgrades.

---

## 🧩 DevOps Example

If you need to:

* Change the MySQL configuration → you use **Parameter Groups** in AWS.
* See system metrics → you use **CloudWatch**.
* Install tools → ❌ not possible on RDS (you’d use EC2).

If you really need OS-level control (for custom scripts or agents), then you’d:

* Create **MySQL on EC2**, not RDS.

---

## 📘 Exam Tip Summary

| Question                          | Key Idea                                                         |
| --------------------------------- | ---------------------------------------------------------------- |
| Can you SSH into an RDS instance? | ❌ No                                                             |
| How do you connect?               | ✅ Using the DB engine client (e.g., MySQL Workbench, psql, etc.) |
| Who manages OS updates?           | ✅ AWS                                                            |
| How do you change DB parameters?  | ✅ Through Parameter Groups                                       |
| If you need OS-level control?     | ✅ Use EC2-hosted database instead                                |






## **RDS Read Replicas vs Multi-AZ Deployments**

### **1. Read Replicas**

**Purpose:** Improve **read performance** and scalability.

#### ✅ **Key Facts**

* Used for **read scaling**, **not high availability**.
* Replication type: **Asynchronous** (eventually consistent).
* Up to **15 read replicas** per database.
* Can be **in same AZ**, **cross-AZ**, or **cross-region**.
* Can be **promoted** to a standalone database (for DR or migration).
* **Only SELECT statements** allowed (no INSERT, UPDATE, DELETE).
* **Cross-AZ replication is free**; **cross-region replication** incurs network costs.

#### 🧩 **Use Case Example**

* Your **production app** writes to the main RDS instance.
* A **reporting or analytics app** reads from the replica, so reporting load doesn’t affect production performance.

---

### **2. Multi-AZ Deployment**

**Purpose:** Improve **availability** and **disaster recovery** (DR).

#### ✅ **Key Facts**

* Used for **high availability**, **not read scaling**.
* Replication type: **Synchronous** (fully consistent).
* Creates a **standby instance** in another AZ (within same region).
* **Automatic failover** happens if the primary instance or AZ fails.
* Application connects through **one DNS endpoint** — AWS handles the failover behind the scenes.
* The standby **cannot be read from or written to** unless promoted during failover.
* You can **enable Multi-AZ** anytime with **zero downtime** via **Modify → Enable Multi-AZ**.

#### ⚙️ **Behind the Scenes**

When you enable Multi-AZ:

1. AWS takes an automatic **snapshot** of your primary database.
2. Restores that snapshot in a **different AZ** as a standby.
3. Sets up **synchronous replication** between them.
4. Keeps both databases in sync for automatic failover.

---

### **3. Combined Feature**

You can have:

* A **Read Replica** that is **Multi-AZ** (read scaling + HA).
* This is a **common exam scenario** — make sure to remember it.

---

### **4. Quick Comparison Table**

| Feature           | **Read Replica**                      | **Multi-AZ**                       |
| ----------------- | ------------------------------------- | ---------------------------------- |
| Purpose           | Read scalability                      | High availability / DR             |
| Replication       | **Asynchronous**                      | **Synchronous**                    |
| Consistency       | **Eventually consistent**             | **Strongly consistent**            |
| Use Case          | Reporting, analytics, read-heavy apps | Failover protection                |
| # of Copies       | Up to 15 replicas                     | 1 standby                          |
| Cross-Region      | ✅ Supported                           | ❌ Not supported (same region only) |
| Auto Failover     | ❌ No                                  | ✅ Yes                              |
| Read Access       | ✅ Yes                                 | ❌ No                               |
| Write Access      | ❌ No                                  | ✅ (primary only)                   |
| Cost for Cross-AZ | Free                                  | Standard Multi-AZ pricing          |
| Enablement        | Manual (create replica)               | Modify → Enable Multi-AZ           |










# 🌩️ AWS RDS + MySQL Workbench 
---

## 🎯 Lecture Objective

By the end of this lecture, you will:

* Create, configure, and connect to an **Amazon RDS MySQL** instance.
* Understand **why DevOps teams use RDS** instead of local databases.
* Manage and query data using **MySQL Workbench**.
* Practice **30 essential SQL commands** every engineer should know.
* Learn to monitor, secure, and clean up your RDS instance.

---

## 🧠 Why AWS RDS?

RDS is a **managed relational database service**.
You don’t install MySQL manually — AWS handles:

* Backups
* Patching
* High availability
* Storage scaling
* Security

💡 You just connect to it from your client (MySQL Workbench) or applications (EC2, Lambda, etc.).

---

## 🏗️ Part 1 — Create the RDS Instance

### Step 1 – Open RDS Console

* In AWS Console → Search **RDS**
* Click **Databases → Create database**

### Step 2 – Choose Engine

* **Creation method:** Standard create
* **Engine type:** MySQL
* **Version:** MySQL 8.0 (latest)

### Step 3 – Choose Template

* Select **Free tier**
  *(if you choose Production, manually keep db.t3.micro + gp2 to stay free)*

### Step 4 – Settings

| Field           | Value         |
| --------------- | ------------- |
| DB Identifier   | `database-1`  |
| Master username | `admin`       |
| Master password | your password |
| DB name         | `mydb`        |

### Step 5 – Instance Configuration

* Class: **db.t3.micro**
* vCPU: 2
* RAM: 1 GB

### Step 6 – Storage

* Type: **gp2 (SSD)**
* Size: 20 GiB
* Enable **Storage Autoscaling** → Max 1000 GiB

### Step 7 – Connectivity

* **VPC:** Default
* **Public access:** ✅ Yes (for testing)
* **VPC Security Group:** Create new → `demo-mysql-sg`
* **Port:** 3306

After creation:

* Open **EC2 → Security Groups → demo-mysql-sg**
* Add **Inbound rule:**

  * Type = MySQL/Aurora
  * Port = 3306
  * Source = My IP

### Step 8 – Authentication

* **Password authentication**
  (leave IAM and Kerberos disabled for now)

### Step 9 – Monitoring & Backups

* Backups: Enable → Retention = 7 days
* Enhanced Monitoring: Disabled (free tier)
* Performance Insights: Disabled (free tier)

### Step 10 – Deletion Protection

✅ Enable for now (to avoid accidental delete)

Then click **Create database**.

⏳ Wait 3–5 minutes until **Status = Available**

---

## 🛰️ Part 2 — Retrieve Connection Details

In RDS → your DB → **Connectivity & Security**

Copy:

```
Endpoint: database-1.co1kwukgimqf.us-east-1.rds.amazonaws.com
Port: 3306
Username: admin
Database: mydb
```

---

## 💻 Part 3 — Install and Open MySQL Workbench on Mac

```bash
brew install --cask mysqlworkbench
open /Applications/MySQLWorkbench.app
```

---

## 🔌 Part 4 — Connect to RDS from Workbench

1. Click **“+”** next to *MySQL Connections*
2. Fill in:

   * **Connection Name:** AWS RDS
   * **Hostname:** `database-1.co1kwukgimqf.us-east-1.rds.amazonaws.com`
   * **Port:** 3306
   * **Username:** `admin`
   * **Password:** Store in Keychain (your RDS password)
3. Click **Test Connection** → ✅ Success
4. Click **OK → Open**

Now you’re inside your **cloud database**.

---

## 🧭 Part 5 — Verify Your Connection

In the SQL editor window:

```sql
SELECT NOW();
SHOW DATABASES();
```

Expected output:

```
information_schema
mysql
performance_schema
sys
mydb
```

---

## 🎓 Part 6 — Work Inside `mydb`

```sql
USE mydb;
```

---

# 🧩 Part 7 — 30 Essential SQL Commands for DevOps Engineers

### 🟢 A. Database Basics

```sql
SHOW DATABASES;
CREATE DATABASE devopsdemo;
USE devopsdemo;
DROP DATABASE devopsdemo;
```

### 🟢 B. Create Tables

```sql
CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  role VARCHAR(50),
  salary DECIMAL(10,2)
);
SHOW TABLES;
DESCRIBE employees;
```

### 🟢 C. Insert Data

```sql
INSERT INTO employees (name, role, salary)
VALUES ('Aisalkyn', 'DevOps Engineer', 120000),
       ('Medina', 'Cloud Engineer', 110000),
       ('Ramil', 'QA Automation', 95000);
```

### 🟢 D. Read Data

```sql
SELECT * FROM employees;
SELECT name, salary FROM employees;
SELECT * FROM employees WHERE salary > 100000;
```

### 🟢 E. Update and Delete

```sql
UPDATE employees SET salary = 125000 WHERE name='Aisalkyn';
DELETE FROM employees WHERE name='Ramil';
```

### 🟢 F. Constraints and Keys

```sql
ALTER TABLE employees ADD UNIQUE (name);
ALTER TABLE employees ADD COLUMN dept VARCHAR(30);
```

### 🟢 G. Sorting & Filtering

```sql
SELECT * FROM employees ORDER BY salary DESC;
SELECT * FROM employees WHERE role='Cloud Engineer' AND salary > 100000;
```

### 🟢 H. Aggregations

```sql
SELECT COUNT(*) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MAX(salary), MIN(salary) FROM employees;
```

### 🟢 I. Joins

```sql
CREATE TABLE departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(50)
);
INSERT INTO departments (dept_name) VALUES ('DevOps'), ('QA'), ('Cloud');
ALTER TABLE employees ADD COLUMN dept_id INT;
UPDATE employees SET dept_id = 1 WHERE role='DevOps Engineer';
UPDATE employees SET dept_id = 3 WHERE role='Cloud Engineer';

SELECT e.name, e.role, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

### 🟢 J. Administration & Security

```sql
CREATE USER 'student'@'%' IDENTIFIED BY 'password123';
GRANT SELECT, INSERT ON mydb.* TO 'student'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'student'@'%';
```

### 🟢 K. Backup & Restore (Basic)

```sql
-- From Workbench menu: Server → Data Export → select database → Export to SQL file
-- To import: Server → Data Import → select file → Start Import
```

---

# ⚙️ Part 8 — Monitor and Troubleshoot in AWS

### 1️⃣ View Connections and Metrics

* RDS → **Monitoring tab** → check:

  * CPU Utilization
  * DB Connections
  * Free Storage
  * Queries per second

### 2️⃣ View Logs

* **RDS → Logs & Events tab** → download `error/mysql log`

### 3️⃣ Modify Instance Class (Scaling)

* RDS → database-1 → **Modify**
* Change from `db.t3.micro` → `db.t3.small`
* Apply immediately or during maintenance window.

### 4️⃣ Disable Deletion Protection when needed

RDS → Modify → scroll down → **Disable Deletion Protection**
Apply changes → Then Actions → **Delete** to clean up demo.

---

# 🧠 Part 9 — Why RDS + Workbench Together Are Essential

| Component                | Role                                                           |
| ------------------------ | -------------------------------------------------------------- |
| **RDS**                  | Cloud-hosted, secure, scalable MySQL engine                    |
| **MySQL Workbench**      | Local GUI client for queries, schema design, and admin tasks   |
| **DevOps Benefit**       | CI/CD pipelines can deploy apps that talk to RDS automatically |
| **Security Integration** | Use IAM roles + Secrets Manager for passwordless access        |
| **Monitoring**           | CloudWatch metrics and alarms for database performance         |

---

# 💡 Part 10 — DevOps Real-World Extensions

1. Connect an **EC2 instance** in the same VPC to RDS using private endpoint.
2. Store DB credentials in **AWS Secrets Manager**.
3. Automate creation with **Terraform**:

   ```hcl
   resource "aws_db_instance" "mydb" {
     identifier        = "database-1"
     engine            = "mysql"
     instance_class    = "db.t3.micro"
     username          = "admin"
     password          = "yourpassword"
     allocated_storage = 20
     publicly_accessible = true
   }
   ```
4. Integrate RDS health alerts into **CloudWatch Alarms** → Slack/Email.

---

# 🧹 Cleanup (End of Lab)

1. Go to RDS → Databases → `database-1`
2. Disable Deletion Protection
3. Actions → Delete
4. Uncheck “Create final snapshot” → type `delete me` → Confirm

---

# 🧾 Summary Cheat Sheet

| Task            | Command                                       |
| --------------- | --------------------------------------------- |
| List databases  | `SHOW DATABASES;`                             |
| Use database    | `USE mydb;`                                   |
| Show tables     | `SHOW TABLES;`                                |
| Describe table  | `DESCRIBE employees;`                         |
| Add column      | `ALTER TABLE employees ADD dept VARCHAR(20);` |
| Drop table      | `DROP TABLE employees;`                       |
| Count records   | `SELECT COUNT(*) FROM employees;`             |
| User privileges | `SHOW GRANTS FOR 'admin'@'%';`                |
| Current DB      | `SELECT DATABASE();`                          |
| Exit CLI        | `EXIT;`                                       |

---

✅ **Congratulations!**
You’ve:

* Created a real AWS RDS MySQL database.
* Connected it securely from your Mac via MySQL Workbench.
* Practiced 30+ SQL commands used daily by DevOps and Cloud Engineers.
* Learned how to monitor, scale, and delete your DB like a pro.


