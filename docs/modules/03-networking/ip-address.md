---
title: "IP address"
description: "🧠 What Is an IP Address?     Definition: A unique numerical label assigned to every device..."
published: 2025-10-15
source: "https://dev.to/jumptotech/ip-address-2523"
tags: []
---

# IP address


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2fjgh761l5wbpgm1bhik.png)



## 🧠 What Is an IP Address?

* **Definition:** A unique numerical label assigned to every device on a network using the Internet Protocol.
* **Purpose:**

  1. **Identification** – tells who the device is.
  2. **Location** – tells where it is on the network.
* **Analogy:** Like your **home address**—ensures the message (data) reaches the correct destination.

---

## 🌍 Two Main Versions of IP

| Feature         | IPv4                                | IPv6                                            |
| --------------- | ----------------------------------- | ----------------------------------------------- |
| Bit Length      | 32-bit                              | 128-bit                                         |
| Format          | 192.168.0.1                         | 2001:0db8:85a3:0000:0000:8a2e:0370:7334         |
| Total Addresses | ~4.3 billion                        | 2¹²⁸ (virtually unlimited)                      |
| Written As      | Decimal (4 octets)                  | Hexadecimal (8 hextets)                         |
| Why IPv6?       | IPv4 ran out of available addresses | Solves shortage, adds better security & routing |

---

## 🧩 Structure of IPs

* **IPv4:** Four *octets* separated by dots → e.g. `192.168.1.5`

  * Each octet = 8 bits = value between 0–255.
* **IPv6:** Eight *hextets* separated by colons → e.g. `2001:db8::1`

  * Each hextet = 16 bits = value between `0000–FFFF`.

---

## 🏠 Public vs Private IPs

| Type        | Example                      | Used For                               | Accessible From Internet? |
| ----------- | ---------------------------- | -------------------------------------- | ------------------------- |
| **Private** | 192.168.x.x, 10.x.x.x        | Inside local networks (home, office)   | ❌ No                      |
| **Public**  | 54.167.118.5 (AWS EC2, etc.) | For internet access, websites, servers | ✅ Yes                     |

> **Check yours:**
>
> * Private: `ipconfig` (Windows) / `ifconfig` (Linux/Mac)
> * Public: visit [whatismyip.com](https://whatismyip.com)

---

## 🔄 Network Address Translation (NAT)

**Purpose:**
Translates **private IPs** → **public IPs** so multiple devices share one public address.

**How it works:**

1. Your device (192.168.1.10) sends a request to Google.
2. NAT router replaces it with your public IP (like 73.101.22.5).
3. Response from Google returns → NAT routes it back to 192.168.1.10.

**Benefits:**

* Saves public IP space.
* Hides internal network → adds security.

---

## 🔢 Static vs Dynamic IPs

| Type        | Assigned By | Changes? | Typical Use            |
| ----------- | ----------- | -------- | ---------------------- |
| **Static**  | Manually    | No       | Servers, DNS, websites |
| **Dynamic** | DHCP        | Yes      | Home/office devices    |

> In AWS: Elastic IPs = static IPs.
> Regular EC2 public IP = dynamic (changes on reboot).

---

## 💡 DevOps Connection

| DevOps Context                               | Role of IP                                                                    |
| -------------------------------------------- | ----------------------------------------------------------------------------- |
| **AWS EC2**                                  | Public IP identifies your instance; private IP used for internal VPC traffic. |
| **Load Balancers / NAT Gateway**             | Manage traffic between private and public subnets.                            |
| **CI/CD Servers (Jenkins, GitHub Webhooks)** | Require static IPs or DNS mapping for stability.                              |
| **Monitoring / SSH / Networking**            | IP helps identify nodes, agents, pods, and network traffic.                   |


