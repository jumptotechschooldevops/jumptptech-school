---
title: "database"
description: "🧠 What is a Database   A database is an organized collection of data stored so it can be..."
published: 2025-10-22
source: "https://dev.to/jumptotech/database-3k9"
tags: []
---

# database



## 🧠 **What is a Database**

A **database** is an **organized collection of data** stored so it can be **easily accessed, managed, and updated** by software or users.

Think of it like a **digital filing system** — instead of paper folders, you have **tables** and **rows**.

---

### **Example**

Let’s say you build a website for a school:

* The **database** stores students, teachers, and grades.
* The **web app** sends queries like:

  ```sql
  SELECT name, grade FROM students WHERE id = 1;
  ```
* The **database engine (like MySQL)** processes this query and returns results.

---

### **Main Types of Databases**

| Type                       | Description                            | Examples                              |
| -------------------------- | -------------------------------------- | ------------------------------------- |
| **Relational (SQL)**       | Data stored in tables (rows & columns) | MySQL, PostgreSQL, Oracle, SQL Server |
| **Non-Relational (NoSQL)** | Flexible document or key-value storage | MongoDB, DynamoDB, Redis              |
| **Cloud Databases**        | Managed by cloud providers             | AWS RDS, Google Cloud SQL, Azure SQL  |

---

## ⚙️ **What DevOps Engineers Need to Learn About Databases**

As a **DevOps engineer**, you don’t build databases — you **manage, deploy, automate, and monitor** them.

Here’s the DevOps-focused path to learning databases 👇

---

### **1️⃣ Understand SQL Fundamentals**

You must know:

* How data is structured in tables
* How to query and filter data

  ```sql
  SELECT * FROM users WHERE status = 'active';
  ```
* CRUD operations (Create, Read, Update, Delete)
* JOINS, GROUP BY, ORDER BY, COUNT, SUM, etc.

👉 **Purpose:** So you can test applications, troubleshoot errors, or verify deployment data.

---

### **2️⃣ Learn Database Engines**

Learn to install and work with:

* **MySQL** (most common)
* **PostgreSQL**
* **MongoDB** (NoSQL)

👉 **Practice:**

* Create a database on your local machine
* Connect via CLI or Workbench
* Run queries and back up data

---

### **3️⃣ Learn Cloud Database Services**

As DevOps, you’ll often manage **databases in the cloud**:

* **AWS RDS** → relational DB (MySQL/PostgreSQL/Oracle)
* **AWS DynamoDB** → NoSQL
* **Azure SQL**, **GCP Cloud SQL**

👉 **Practice:**

* Create an RDS instance on AWS
* Connect via terminal using:

  ```bash
  mysql -h <endpoint> -u admin -p
  ```
* Modify, back up, and restore databases

---

### **4️⃣ Automate Database Tasks**

You’ll automate:

* Database creation (Terraform or CloudFormation)
* Schema updates (Liquibase, Flyway)
* Backups and restores (AWS CLI scripts)
* User management and permissions (SQL scripts or Ansible)

👉 Example (Terraform for RDS):

```hcl
resource "aws_db_instance" "mydb" {
  engine = "mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  name = "devopsdb"
  username = "admin"
  password = "StrongPass123!"
}
```

---

### **5️⃣ Secure Databases**

Learn:

* IAM roles and policies for RDS
* Network rules (VPC, subnet, security groups)
* Encrypt data (KMS)
* Secrets management (AWS Secrets Manager)

---

### **6️⃣ Monitor and Troubleshoot**

* Check logs in **CloudWatch**
* Use **Performance Insights**
* Set up alarms for DB CPU, connections, and storage
* Automate alerts in Slack or email

---

### **7️⃣ Backup and Disaster Recovery**

Understand:

* RDS snapshots (automatic & manual)
* Restoring from backup
* Multi-AZ (high availability)
* Read replicas (load distribution)

---

### **8️⃣ Integration in CI/CD**

* Use Jenkins or GitHub Actions to deploy apps connected to RDS.
* Run DB migrations before app deploys.
* Use Docker containers with MySQL for test environments.

---

## 🚀 **Summary for DevOps Database Path**

| Stage          | What to Learn              | Tools                |
| -------------- | -------------------------- | -------------------- |
| **Basics**     | SQL, tables, queries       | MySQL CLI, Workbench |
| **Cloud**      | AWS RDS, DynamoDB          | AWS Console, CLI     |
| **Automation** | Infrastructure as Code     | Terraform, Ansible   |
| **Security**   | Access control, encryption | IAM, KMS             |
| **Monitoring** | Performance metrics        | CloudWatch, Grafana  |
| **CI/CD**      | Migrations & test DBs      | Jenkins, Docker      |






In SQL, all commands are grouped into **five categories**:

---

## 🧠 **1️⃣ DDL — Data Definition Language**

**Purpose:** defines and changes the structure of the database (tables, columns, etc.)

| Command      | Meaning                                  | Example                                             |
| ------------ | ---------------------------------------- | --------------------------------------------------- |
| **CREATE**   | Create database or table                 | `CREATE TABLE students (id INT, name VARCHAR(50));` |
| **ALTER**    | Modify a table (add/remove columns)      | `ALTER TABLE students ADD grade VARCHAR(10);`       |
| **DROP**     | Delete table or database                 | `DROP TABLE students;`                              |
| **TRUNCATE** | Remove all rows but keep table structure | `TRUNCATE TABLE students;`                          |

🧩 **Remember:** DDL = changes the structure.

---

## 🧮 **2️⃣ DML — Data Manipulation Language**

**Purpose:** used to work with the data inside tables (insert, change, delete rows).

| Command    | Meaning              | Example                                                 |
| ---------- | -------------------- | ------------------------------------------------------- |
| **INSERT** | Add new rows         | `INSERT INTO students VALUES (1, 'Aisalkyn', 17, 'A');` |
| **UPDATE** | Change existing data | `UPDATE students SET grade='B' WHERE name='Aisalkyn';`  |
| **DELETE** | Remove specific rows | `DELETE FROM students WHERE id=1;`                      |

🧩 **Remember:** DML = changes the data (not structure).

---

## 🔍 **3️⃣ DQL — Data Query Language**

**Purpose:** used to **query or read data** from tables.

| Command    | Meaning       | Example                                             |
| ---------- | ------------- | --------------------------------------------------- |
| **SELECT** | Retrieve data | `SELECT name, grade FROM students WHERE grade='A';` |

🧩 **Remember:** DQL = only reads data, doesn’t change anything.

---

## 🔒 **4️⃣ DCL — Data Control Language**

**Purpose:** controls access and permissions.

| Command    | Meaning           | Example                                               |
| ---------- | ----------------- | ----------------------------------------------------- |
| **GRANT**  | Give permission   | `GRANT SELECT ON school.* TO 'user1'@'localhost';`    |
| **REVOKE** | Remove permission | `REVOKE SELECT ON school.* FROM 'user1'@'localhost';` |

🧩 **Remember:** DCL = who can do what.

---

## 🔁 **5️⃣ TCL — Transaction Control Language**

**Purpose:** manages transactions (groups of SQL operations).

| Command               | Meaning                | Example              |
| --------------------- | ---------------------- | -------------------- |
| **START TRANSACTION** | Begin a transaction    | `START TRANSACTION;` |
| **COMMIT**            | Save changes           | `COMMIT;`            |
| **ROLLBACK**          | Undo changes           | `ROLLBACK;`          |
| **SAVEPOINT**         | Create a restore point | `SAVEPOINT point1;`  |

🧩 **Remember:** TCL = save or undo DML actions.

---

## 🎯 **Quick Summary Table**

| Category | Full Form                    | Used For            | Common Commands               |
| -------- | ---------------------------- | ------------------- | ----------------------------- |
| **DDL**  | Data Definition Language     | Define structure    | CREATE, ALTER, DROP, TRUNCATE |
| **DML**  | Data Manipulation Language   | Change data         | INSERT, UPDATE, DELETE        |
| **DQL**  | Data Query Language          | Retrieve data       | SELECT                        |
| **DCL**  | Data Control Language        | Manage permissions  | GRANT, REVOKE                 |
| **TCL**  | Transaction Control Language | Manage transactions | COMMIT, ROLLBACK, SAVEPOINT   |


