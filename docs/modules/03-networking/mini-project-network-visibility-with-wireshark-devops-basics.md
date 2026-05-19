---
title: "Mini Project: Network Visibility with Wireshark (DevOps Basics)"
description: "🎯 Project Goal   This project teaches how the network really works, which is essential for..."
published: 2025-12-28
source: "https://dev.to/jumptotech/mini-project-network-visibility-with-wireshark-devops-basics-39co"
tags: []
---

# Mini Project: Network Visibility with Wireshark (DevOps Basics)



## 🎯 Project Goal 


This project teaches **how the network really works**, which is essential for DevOps.

---



By the end of this project, you will understand:

* What Wireshark is
* How to capture traffic
* Difference between **MAC address** and **IP address**
* What **TLS Client Hello** is
* Why DevOps engineers use Wireshark (sometimes)



## 🧩 Project Structure

1. Install Wireshark
2. Fix permissions
3. Capture live traffic
4. Identify HTTPS traffic
5. Inspect TLS Client Hello
6. Explain MAC vs IP behavior
7. Answer DevOps questions

---

# STEP 1 — Download Wireshark

### Official website (IMPORTANT)

[https://www.wireshark.org/download.html](https://www.wireshark.org/download.html)

### Installation

* **macOS**: Download `.dmg`
* During install:

  * ✅ Install **ChmodBPF**
  * ✅ Allow permissions

💡 Explain:

> ChmodBPF allows Wireshark to capture packets safely without root.

---

# STEP 2 — Start Wireshark

1. Open Wireshark
2. Choose interface:

   * **Wi-Fi (en0)** (most students)
3. Click **Start**

---

# STEP 3 — Generate Network Traffic

Ask students to:

* Open browser
* Visit:

```
https://google.com
```

Tell them:

> Wireshark only shows traffic that actually happens.

---

# STEP 4 — Filter TLS Traffic

In the **Display Filter bar**, enter:

```
tls
```

### What students should see

* TLS packets
* “Application Data”
* Encrypted communication

Explain:

> HTTPS traffic is encrypted. Wireshark shows metadata, not passwords.

---

# STEP 5 — Find TLS Client Hello

Apply this filter:

```
tls.handshake.type == 1
```



# STEP 6 — Inspect MAC and IP Addresses

Click one packet and expand:

* **Ethernet II**
* **Internet Protocol**

Explain:

* Source MAC = router
* Destination MAC = laptop
* IP addresses stay end-to-end
* MAC addresses change at every router


> MAC is local, IP is global.

---

# STEP 7 — Stop Capture

Click the **red square** to stop capture.






## ✅ Project Success Criteria


* Capture packets
* Filter TLS traffic
* Identify Client Hello
* Explain MAC vs IP
* Explain why TLS hides data

---

## 📌 DevOps Mapping (Explain to Students)

| Concept    | DevOps Use          |
| ---------- | ------------------- |
| TLS        | Secure APIs         |
| IP routing | Cloud networking    |
| MAC        | VPC / ENI internals |
| Wireshark  | Deep debugging      |

---



> “Wireshark helps us understand how applications communicate over the network, even when data is encrypted.”


