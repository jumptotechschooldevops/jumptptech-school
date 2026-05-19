---
title: "Subnetting explained"
description: "🔹 What Is Subnetting?   Subnetting is the process of dividing one large network into smaller..."
published: 2025-10-15
source: "https://dev.to/jumptotech/subnetting-explained-25i9"
tags: []
---

# Subnetting explained




### 🔹 What Is Subnetting?

Subnetting is the process of dividing one large network into smaller logical networks (subnets).

**Goals of Subnetting:**

* Reduce **network congestion**
* Improve **performance and security**
* Simplify **management and troubleshooting**

**Example from video:**
The main network: `192.168.4.0/24`
We need **3 subnets** for:

1. Office
2. Front desk
3. Public Wi-Fi

---

## 🧮 **Subnetting Table**

Sunny introduces a **three-row table** that makes subnetting visual and fast.

| **Subnets (Row 1)**     | 1   | 2   | 4   | 8   | 16  | 32  | 64  | 128 | 256 |
| ----------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Hosts (Row 2)**       | 256 | 128 | 64  | 32  | 16  | 8   | 4   | 2   | 1   |
| **Subnet Mask (Row 3)** | /24 | /25 | /26 | /27 | /28 | /29 | /30 | /31 | /32 |

**Observation:**

* Each subnet count **doubles**.
* Each host count **halves**.
* The subnet mask **increases** by 1 bit each step.

👉 **Memorize this table** — it’s reusable for all subnetting questions.

---

## 💡 **Example Calculation:**

Given:

* Network: `192.168.4.0/24`
* Need 3 subnets

### Step 1️⃣: Find Closest Subnet Number

From Sunny’s table → nearest ≥ 3 is **4 subnets** → `/26`

| Info             | Value                |
| ---------------- | -------------------- |
| Subnets          | 4                    |
| Hosts per subnet | 64 total → 62 usable |
| New mask         | /26                  |

---

## 🧱 **Step 2️⃣: Create Subnets**

We add **64** to the last octet (because 256 ÷ 4 = 64).

| Subnet # | Network ID    | Broadcast ID  | Host Range                    | Usable Hosts |
| -------- | ------------- | ------------- | ----------------------------- | ------------ |
| 1        | 192.168.4.0   | 192.168.4.63  | 192.168.4.1 – 192.168.4.62    | 62           |
| 2        | 192.168.4.64  | 192.168.4.127 | 192.168.4.65 – 192.168.4.126  | 62           |
| 3        | 192.168.4.128 | 192.168.4.191 | 192.168.4.129 – 192.168.4.190 | 62           |
| 4        | 192.168.4.192 | 192.168.4.255 | 192.168.4.193 – 192.168.4.254 | 62           |

Sunny mentions you can **use any 3** of these 4 subnets and **waste 1** (common in real networks).

---

## 📘 **Formulas Used**

| Purpose                    | Formula                  | Example        |
| -------------------------- | ------------------------ | -------------- |
| Total addresses per subnet | 2^n                      | n = 8 → 256    |
| Usable hosts               | 2^n - 2                  | 256 - 2 = 254  |
| Subnet increment           | 256 - last octet of mask | 256 - 192 = 64 |

---

## 🧩 **Key Terms Recap**

| Term             | Meaning                                     |
| ---------------- | ------------------------------------------- |
| **Network ID**   | Identifies the subnet                       |
| **Host ID**      | Identifies the device                       |
| **Broadcast ID** | Used to send to all hosts in the subnet     |
| **Subnet Mask**  | Defines the division between network & host |

---

## 🧠 **Tips**

* Always focus on **the last octet** (since the first 3 often stay the same).
* The **broadcast ID = next network ID − 1**.
* Practice until you can calculate subnets in your head.
* Use the **Sunny Table** as a quick visual map.

---

## 🛠 **How to Use in DevOps Context**

| DevOps Use Case        | Relevance of Subnetting                                               |
| ---------------------- | --------------------------------------------------------------------- |
| **AWS VPC**            | Each subnet (/24, /26, etc.) defines network zones for EC2, NAT, RDS. |
| **Security Isolation** | Private subnet for databases, public subnet for web servers.          |
| **Scaling**            | Add more subnets for new environments (dev, test, prod).              |
| **Performance**        | Smaller subnets reduce broadcast traffic.                             |

---

## 🎓 **Practice Exercise**

**Task:**
Given `10.0.0.0/24`, divide into 8 subnets.
Find:

* New subnet mask
* Network IDs
* Broadcast IDs
* Usable host range per subnet







