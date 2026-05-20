---
title: "MySQL commands"
description: "MySQL is an open source relational database management system (RDBMS) that’s used to store and manage..."
published: 2025-10-24
source: "https://dev.to/jumptotech/mysql-commands-g53"
tags: []
---

# MySQL commands

MySQL is an open source relational database management system (RDBMS) that’s used to store and manage data. Its reliability, performance, scalability, and ease of use make MySQL a popular choice for developers. In fact, you’ll find it at the heart of demanding, high-traffic applications such as Facebook, Netflix, Uber, Airbnb, Shopify, and Booking.com.
What Is MySQL?
MySQL is the world’s most popular open source database management system. Databases are the essential data repositories for all software applications. For example, whenever someone conducts a web search, logs into an account, or completes a transaction, a database stores the information so it can be accessed in the future. MySQL excels at this task.

SQL, which stands for Structured Query Language, is a programming language that’s used to retrieve, update, delete, and otherwise manipulate data in relational databases. MySQL is officially pronounced “My ess-cue-el,” but “my sequel” is a common variation. As the name suggests, MySQL is a SQL-based relational database designed to store and manage structured data. In recent years, however, Oracle added additional support, including for the popular JSON data type.

Key Takeaways

In 2024, MySQL retains its mantle as the world’s most popular open source database.
As a relational database system, MySQL stores data in rows and columns defined by schemas.
MySQL derives part of its name from the SQL language, which is used for managing and querying data in databases.
MySQL offers full ACID transactions and can handle a high volume of concurrent connections.
MySQL Explained
MySQL is an open source RDBMS that uses SQL to create and manage databases. As a relational database, MySQL stores data in tables of rows and columns organized into schemas. A schema defines how data is organized and stored and describes the relationship among various tables. With this format, developers can easily store, retrieve, and analyze many data types, including simple text, numbers, dates, times, and, more recently, JSON and vectors.

Because MySQL is open source, it includes numerous features developed in close cooperation with a community of users over almost 30 years. Two capabilities that developers rely on are MySQL’s support for ACID transactions and MySQL’s ability to scale. ACID stands for “atomicity, consistency, isolation, and durability,” the four properties that ensure database transactions are processed dependably and accurately. With ACID transactions, MySQL can guarantee that all data modifications are made in a consistent and reliable way, even in the event of a system failure. MySQL can be scaled out to support very large databases, and it can handle a high volume of concurrent connections.

MySQL’s performance, ease of use, and low cost combined with its ability to reliably scale as a business grows have made it the world’s most popular open source database.

MySQL: Distinguishing It from SQL
The acronym “SQL” stands for Structured Query Language, a type of programming language that’s used for manipulating data in a database. MySQL uses the SQL language to manage and query data in databases and, hence, uses the acronym as part of its name. If you’ve got data stored in a MySQL RDBMS, then you can write simple SQL prompts to add, search, analyze, and retrieve data.

Understanding MySQL: Features and Popularity
MySQL’s ability to efficiently store and analyze vast quantities of data means it can help with tasks as varied as informing complex business decisions and finding a local restaurant for a date night. Here’s a look at the top functionality that makes MySQL so pervasive in today’s tech landscape.

A Comprehensive Relational Database System
MySQL is known as a flexible, easy-to-use database management system. You’ll find it used by lone developers grabbing an open source database for a small project all the way up to the world’s most visited websites and applications. MySQL has been evolving to keep up with demand for nearly 30 years and offers ACID transactions that ensure data modifications are made in a consistent way—even when supporting a high volume of concurrent connections.

The Open Source Advantage of MySQL
MySQL is open source, which means anyone can download MySQL software from the internet and use it without cost. Organizations can also change its source code to suit their needs. MySQL software uses the GNU General Public License (GPL), which is a common set of rules for defining what may or may not be done with or to the software in various situations. If an organization feels uncomfortable with the GNU GPL or wishes to embed MySQL code into a commercial application, it can buy a commercially licensed version. See the MySQL Legal Policies page for more information about licensing.

Why Developers Prefer MySQL’s Performance and Flexibility
MySQL is known for being easy to set up and use, yet reliable and scalable enough for organizations with very large data sets and vast numbers of users. MySQL’s native replication architecture enables organizations such as Facebook to scale applications to support billions of users.

Other key factors in MySQL’s popularity include abundant learning resources and the software’s vibrant global community.

How Does MySQL Work?
Each software application needs a repository to store data so the information can be accessed, updated, and analyzed in the future. A relational database such as MySQL stores data in separate tables rather than putting all the data in one big storeroom. The database structure is organized into files optimized so data can be accessed quickly. This logical data model, with objects such as data tables, views, rows, and columns, offers developers and database administrators a flexible programming environment. They can set up rules governing the relationships between different data fields, such as one to one, one to many, unique, required, or optional, and add “pointers” among different tables. The system enforces these rules so that, with a well-designed database, an application never sees data that’s inconsistent, duplicated, orphaned, or out of date.

MySQL Database is a client/server system that consists of a multithreaded SQL server that supports different back ends, several client programs and libraries, a choice of administrative tools, and a wide variety of application programming interfaces (APIs). MySQL is available as an embedded multithreaded library that developers can link into applications to get a smaller, faster, easier-to-manage standalone product.

SQL is the most common standardized programming language used to access databases. Depending on the programming environment, a developer might enter SQL directly—for example, to generate reports. It’s also possible to embed SQL statements into code written in another programming language or use a language-specific API that hides the SQL syntax.

Why Is MySQL Important?
MySQL is important because of its ubiquitousness and the fundamental role of databases as the amount of data both grows exponentially and fuels AI. MySQL underpins a vast array of websites and applications and helps businesses worldwide organize, analyze, and protect their data.

Other factors also help maintain MySQL’s enduring popularity.

Open source with strong community support

During MySQL’s nearly three decades as the leading open source RDBMS, a vibrant global community has grown up around it. That’s important because the community provides a wealth of expertise and resources, such as tutorials, tips in forums, and more. By testing the software in multiple use case scenarios, the community also has helped discover and fix bugs, making MySQL highly reliable.

The open source community’s knowledge sharing, problem-solving, and continuous innovation keep MySQL users at the forefront of technological advancements.

High performance and reliability

MySQL is at home in many different environments, including individual developer projects and mission-critical applications that demand unwavering stability. The open source RDBMS can handle high volumes of data and concurrent connections and provide uninterrupted operations under demanding circumstances. This is partly due to MySQL’s robust replication and failover mechanisms, which help minimize the risk of data loss.

Ease of use and compatibility

MySQL is often praised for being easy to use and for offering broad compatibility with technology platforms and programming languages, including Java, Python, PHP, and JavaScript. MySQL also supports replication from one release to the next, so an application running MySQL 5.7 can easily replicate to MySQL 8.0.

In addition, MySQL offers flexibility in developing both traditional SQL and NoSQL schema-free database applications. This means developers can mix and match relational data and JSON documents in the same database and application.

Cost-effectiveness and scalability

Because MySQL is open source, it’s freely available to use at no cost, beyond the on-premises hardware it runs on and training on how to use it. For the latter, a global community of MySQL users provide cost-effective access to learning resources and troubleshooting expertise. Oracle also offers a wide range of training courses.

When it’s time to scale out, MySQL supports multithreading to handle large amounts of data efficiently. Automated failover features help reduce the potential costs of unplanned downtime.

Benefits of MySQL
MySQL is fast, reliable, scalable, and easy to use. It was originally developed to handle large databases quickly and has been used in highly demanding production environments for many years. MySQL offers a rich and useful set of functions, and it’s under constant development by Oracle, so it keeps up with new technological and business demands. MySQL’s connectivity, speed, and security make it highly suited for accessing databases on the internet.

MySQL’s key benefits include the following:

Ease of use. Developers can install MySQL in minutes, and the database is easy to manage.
Reliability. MySQL is one of the most mature and widely used databases. It has been tested in a wide variety of scenarios for nearly 30 years, including by many of the world’s largest companies. Organizations depend on MySQL to run business-critical applications because of its reliability.
Scalability. MySQL scales to meet the demands of the most accessed applications. MySQL’s native replication architecture enables organizations, including Facebook, Netflix, and Uber, to scale applications to support tens of millions of users or more.
Performance. MySQL is a proven high performance, zero-administration database system and comes in a range of editions to meet nearly any demand. Cloud-based HeatWave MySQL provides unmatched performance and price-performance, according to industry benchmarks including TPC-H, TPC-DS, and CH-benCHmark.
High availability. MySQL delivers a complete set of native, fully integrated replication technologies for high availability and disaster recovery. For business-critical applications and service level agreement commitments, customers can achieve recovery point objective zero (zero data loss) and recovery time objective zero seconds (automatic failover).
Security. Data security entails both data protection and compliance with industry and government regulations, including the European Union General Data Protection Regulation, the Payment Card Industry Data Security Standard, the Health Insurance Portability and Accountability Act, and the Defense Information Systems Agency’s Security Technical Implementation Guides. MySQL Enterprise Edition provides advanced security features, including authentication/authorization, transparent data encryption, auditing, data masking, and a database firewall.
Flexibility. The MySQL Document Store gives users maximum flexibility in developing traditional SQL and NoSQL schema-free database applications. Developers can mix and match relational data and JSON documents in the same database and application.
What Is HeatWave MySQL?
HeatWave is an in-memory query accelerator for MySQL Database. HeatWave MySQL is the only MySQL cloud database service that offers such acceleration and that combines transactions with real-time analytics, eliminating the complexity, latency, cost, and risk of extract, transform, and load (ETL) duplication.

As a result, users can see orders-of-magnitude increases in MySQL performance for analytics and mixed workloads. In addition, HeatWave AutoML lets developers and data analysts build, train, deploy, and explain the outputs of machine learning models within HeatWave MySQL in a fully automated way. They can also benefit from integrated and automated generative AI using HeatWave GenAI.
MySQL Use Cases
MySQL use cases include managing customer and product data for ecommerce websites, helping content management systems serve web content, securely tracking transactions and financial data, and powering social networking sites by storing user profiles and interactions.

MySQL’s ability to handle large data sets and complex queries makes it a key technology across industries and use cases, including the following:

Ecommerce. Many of the world’s largest ecommerce applications—including Uber and Booking.com—run their transactional systems on MySQL. It’s a popular choice for managing user profiles, credentials, user content, and financial data, including payments, along with fraud detection.
Social platforms. Facebook, X (formerly Twitter), and LinkedIn are among the world’s largest social networks, and they all rely on MySQL.
Content management. Unlike single-purpose document databases, MySQL enables both SQL and NoSQL with a single database. The MySQL Document Store enables CRUD operations and harnesses the power of SQL to query data from JSON documents for reporting and analytics.
SaaS and ISVs. More than 2,000 ISVs, OEMs, and VARs, including Ericsson and IBM, rely on MySQL as the embedded database to make their applications, hardware, and appliances more competitive; bring products to market faster; and lower their cost of goods sold. MySQL is also the database behind popular SaaS applications, such as Zendesk. Other popular applications using MySQL include apps for online gaming, digital marketing, retail point-of-sale systems, and Internet of Things monitoring systems.
On-premises applications with MySQL Enterprise Edition. MySQL Enterprise Edition includes the most comprehensive set of advanced features along with management tools and technical support, enabling organizations to achieve the highest levels of MySQL scalability, security, reliability, and uptime. It reduces the risk, cost, and complexity in developing, deploying, and managing business-critical MySQL applications. It provides security features, including MySQL Enterprise Backup, Monitor, Firewall, Audit, Transparent Data Encryption, and Authentication, to help customers protect data and achieve regulatory and industry compliance.
MySQL is the world’s most popular open source database and is second among all databases, behind only Oracle Database, for a reason. It’s reliable and fast, with performance that thousands of websites and applications depend on. It can handle a large amount of data and queries without slowing down. It boasts a large and enthusiastic open source community. All that plus low cost and ease of use make MySQL a top choice for many developers and businesses.

# 🏗️ 1️⃣ DDL – Data Definition Language

(Used to create and modify databases, tables, and structures.)

---

### **1. SHOW DATABASES**

**➡️ Purpose:** Lists all databases on your MySQL server.
**💡 When to use:** When you want to see which databases exist before creating or using one.
**🧠 How to use:**

```sql
SHOW DATABASES;
```

**📤 Output:**
A list of all databases (e.g., `information_schema`, `mysql`, `performance_schema`, `school`).

---

### **2. CREATE DATABASE**

**➡️ Purpose:** Creates a new database.
**💡 When to use:** Before creating tables, you must first create a database to store them.
**🧠 How to use:**

```sql
CREATE DATABASE school;
```

**📤 Output:**
Query OK message — `Query OK, 1 row affected (0.00 sec)`
Now `school` will appear in the `SHOW DATABASES;` list.

---

### **3. USE DATABASE**

**➡️ Purpose:** Selects a specific database to work with.
**💡 When to use:** Before creating or querying tables — you must tell MySQL which database you want to use.
**🧠 How to use:**

```sql
USE school;
```

**📤 Output:**
`Database changed` — means you’re now working inside the `school` database.

---

### **4. SHOW TABLES**

**➡️ Purpose:** Displays all tables inside the selected database.
**💡 When to use:** After selecting a database, check what tables it already has.
**🧠 How to use:**

```sql
SHOW TABLES;
```

**📤 Output:**
A list of table names (e.g., `students`, `courses`, etc.)

---

### **5. CREATE TABLE**

**➡️ Purpose:** Creates a new table inside a database.
**💡 When to use:** To define the structure for storing data (columns, data types, and keys).
**🧠 How to use:**

```sql
CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  age INT,
  city VARCHAR(50)
);
```

**📤 Output:**
`Query OK, 0 rows affected` — table created successfully.

---

### **6. ALTER TABLE**

**➡️ Purpose:** Changes an existing table (add, delete, or modify columns).
**💡 When to use:** When your table needs structure changes (like adding a new field).
**🧠 How to use:**

```sql
ALTER TABLE students ADD email VARCHAR(100);
```

**📤 Output:**
`Query OK, 0 rows affected` — column added successfully.

---

### **7. RENAME TABLE**

**➡️ Purpose:** Changes a table name.
**💡 When to use:** When you want to give a table a more meaningful name.
**🧠 How to use:**

```sql
RENAME TABLE students TO learners;
```

**📤 Output:**
`Query OK, 0 rows affected` — table renamed successfully.

---

### **8. DROP TABLE**

**➡️ Purpose:** Deletes a table permanently.
**💡 When to use:** If you no longer need the table or want to recreate it from scratch.
**🧠 How to use:**

```sql
DROP TABLE learners;
```

**📤 Output:**
`Query OK, 0 rows affected` — table deleted (data lost permanently).

---

### **9. TRUNCATE TABLE**

**➡️ Purpose:** Removes all rows from a table but keeps its structure.
**💡 When to use:** When you want to clear data quickly without deleting the table.
**🧠 How to use:**

```sql
TRUNCATE TABLE students;
```

**📤 Output:**
`Query OK, 0 rows affected` — all data removed, but table remains.

---

### **10. DROP DATABASE**

**➡️ Purpose:** Deletes an entire database (including all its tables).
**💡 When to use:** When a database is no longer needed.
**🧠 How to use:**

```sql
DROP DATABASE school;
```

**📤 Output:**
`Query OK, 0 rows affected` — database removed permanently.

---

# 🧩 2️⃣ DML – Data Manipulation Language

(Used to add, update, or delete data inside tables.)

---

### **1. INSERT INTO**

**➡️ Purpose:** Adds new records (rows) into a table.
**💡 When to use:** After creating a table, to start adding data.
**🧠 How to use:**

```sql
INSERT INTO students (name, age, city)
VALUES ('John', 15, 'Chicago');
```

**📤 Output:**
`Query OK, 1 row affected` — confirms the new row is added.

---

### **2. UPDATE**

**➡️ Purpose:** Changes existing data in a table.
**💡 When to use:** When you want to correct or modify data.
**🧠 How to use:**

```sql
UPDATE students
SET city = 'New York'
WHERE name = 'John';
```

**📤 Output:**
`Query OK, 1 row affected` — data updated successfully.

---

### **3. DELETE**

**➡️ Purpose:** Removes specific rows from a table.
**💡 When to use:** When you need to remove incorrect or outdated data.
**🧠 How to use:**

```sql
DELETE FROM students
WHERE name = 'John';
```

**📤 Output:**
`Query OK, 1 row affected` — record deleted successfully.

---

### **4. REPLACE**

**➡️ Purpose:** Inserts a new row or replaces one with the same primary key.
**💡 When to use:** When you want to insert but avoid duplicates based on a key.
**🧠 How to use:**

```sql
REPLACE INTO students (id, name, age, city)
VALUES (1, 'John', 16, 'Boston');
```

**📤 Output:**
`Query OK, 2 rows affected` — old record deleted, new one inserted.

---

### **5. INSERT INTO SELECT**

**➡️ Purpose:** Copies data from one table into another.
**💡 When to use:** When backing up or duplicating data.
**🧠 How to use:**

```sql
INSERT INTO backup_students (name, age, city)
SELECT name, age, city FROM students;
```

**📤 Output:**
`Query OK, X rows affected` — number depends on how many rows copied.

---

# 🔍 3️⃣ DQL – Data Query Language

(Used to query and view data.)

---

### **1. SELECT**

**➡️ Purpose:** Retrieves data from tables.
**💡 When to use:** To display table data for review, reports, or debugging.
**🧠 How to use:**

```sql
SELECT * FROM students;
```

**📤 Output:**
Displays all rows and columns from `students`.

---

### **2. WHERE**

**➡️ Purpose:** Filters data based on conditions.
**💡 When to use:** To get only the data that meets certain criteria.
**🧠 How to use:**

```sql
SELECT * FROM students WHERE city = 'Chicago';
```

**📤 Output:**
Shows only students from Chicago.

---

### **3. ORDER BY**

**➡️ Purpose:** Sorts query results.
**💡 When to use:** When you want data arranged alphabetically or numerically.
**🧠 How to use:**

```sql
SELECT * FROM students ORDER BY age DESC;
```

**📤 Output:**
Displays students from oldest to youngest.

---

### **4. GROUP BY**

**➡️ Purpose:** Groups data by column values for summary.
**💡 When to use:** When using aggregate functions like COUNT, SUM, AVG.
**🧠 How to use:**

```sql
SELECT city, COUNT(*) AS total_students
FROM students
GROUP BY city;
```

**📤 Output:**
Shows number of students in each city.

---

### **5. HAVING**

**➡️ Purpose:** Filters grouped results (like WHERE but for GROUP BY).
**💡 When to use:** When you want to show only groups meeting a condition.
**🧠 How to use:**

```sql
SELECT city, COUNT(*) AS total_students
FROM students
GROUP BY city
HAVING COUNT(*) > 2;
```

**📤 Output:**
Shows cities that have more than 2 students.

---

### **6. JOIN (INNER JOIN)**

**➡️ Purpose:** Combines related data from multiple tables.
**💡 When to use:** When you need data from more than one table linked by a key.
**🧠 How to use:**

```sql
CREATE TABLE courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_name VARCHAR(50)
);

CREATE TABLE enrollments (
  student_id INT,
  course_id INT
);

SELECT students.name, courses.course_name
FROM students
JOIN enrollments ON students.id = enrollments.student_id
JOIN courses ON enrollments.course_id = courses.id;
```

**📤 Output:**
Shows each student’s name with their enrolled course.

---

### **7. DISTINCT**

**➡️ Purpose:** Removes duplicate rows.
**💡 When to use:** When you want unique values only.
**🧠 How to use:**

```sql
SELECT DISTINCT city FROM students;
```

**📤 Output:**
List of each unique city (no duplicates).

---

### **8. LIMIT**

**➡️ Purpose:** Restricts how many rows are displayed.
**💡 When to use:** To preview data or limit output.
**🧠 How to use:**

```sql
SELECT * FROM students LIMIT 3;
```

**📤 Output:**
Shows only the first 3 rows.

---

### **9. BETWEEN**

**➡️ Purpose:** Selects values within a range.
**💡 When to use:** For numeric or date ranges.
**🧠 How to use:**

```sql
SELECT * FROM students WHERE age BETWEEN 10 AND 15;
```

**📤 Output:**
Displays students aged between 10 and 15.

---

### **10. LIKE**

**➡️ Purpose:** Searches for patterns in text.
**💡 When to use:** For partial matches (e.g., names starting with “J”).
**🧠 How to use:**

```sql
SELECT * FROM students WHERE name LIKE 'J%';
```

**📤 Output:**
Shows all students whose name starts with “J”.



