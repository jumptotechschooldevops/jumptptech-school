---
title: "OSI model"
description: "🌍 How the Internet Works (and Who Controls It)            1. No one person or company..."
published: 2025-10-15
source: "https://dev.to/jumptotech/osi-model-4ia"
tags: []
---

# OSI model


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xy385dfcnsxegul0xhdg.png)



## 🌍 How the Internet Works (and Who Controls It)

### 1. **No one person or company “owns” the internet.**

The internet is a **global network of networks** — millions of private, public, and government networks connected together.
But some **organizations coordinate and standardize** how everything works so all devices and software speak the same “language.”

---

## 🧭 Key Organizations that Control and Standardize It

| Organization                            | Full Name                                                       | Role                                                                                              |
| --------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **ISO**                                 | International Organization for Standardization                  | Created the **OSI model** itself to define how network communication should work.                 |
| **IEEE**                                | Institute of Electrical and Electronics Engineers               | Controls **Layer 1 & 2 standards** — Ethernet (802.3), Wi-Fi (802.11), Bluetooth, etc.            |
| **IETF**                                | Internet Engineering Task Force                                 | Creates and updates **internet protocols** like TCP, IP, HTTP, DNS — the “rules” of the internet. |
| **ICANN**                               | Internet Corporation for Assigned Names and Numbers             | Manages **domain names and IP addresses** (like `www.google.com → 142.250.190.46`).               |
| **IANA**                                | Internet Assigned Numbers Authority (part of ICANN)             | Assigns **port numbers, IP ranges, and protocol numbers** so they don’t conflict.                 |
| **W3C**                                 | World Wide Web Consortium                                       | Develops **web standards** — HTML, CSS, and HTTP behavior for browsers.                           |
| **Regional Internet Registries (RIRs)** | ARIN (North America), RIPE (Europe), APNIC (Asia-Pacific), etc. | Distribute and manage **IP addresses** in different world regions.                                |

So, **ISO** defines the *layers*,
**IEEE** builds the *hardware standards*,
**IETF/ICANN/IANA** make sure all *data travels and resolves correctly*,
and **W3C** ensures web apps *display correctly in browsers*.

---

## ⚙️ How It All Works Together on the Internet

Let’s trace what happens when you open **[https://www.youtube.com](https://www.youtube.com)**:

1. **Browser (Application Layer)**
   Sends a request to find “[www.youtube.com”](http://www.youtube.com”).

2. **DNS (Domain Name System)**
   Managed globally by **ICANN/IANA** — converts domain name → IP address.

3. **Routing (Network Layer)**
   Routers (following **IETF** standards) forward your data across multiple networks using **BGP (Border Gateway Protocol)**.

4. **Transport Layer**
   Uses **TCP port 443** (HTTPS). These ports are assigned by **IANA** so all systems agree which service runs where.

5. **Data Link & Physical Layers**
   Your Wi-Fi router (using **IEEE 802.11**) transmits signals, then fiber cables (also IEEE 802.3 Ethernet) carry them to your ISP.

6. **ISP → Internet Backbone → Google Servers**
   Your data crosses through many autonomous systems (ASNs) connected globally using **IETF-defined protocols**.

7. **Server Response**
   Google’s server sends back encrypted data via **TLS/SSL** → decrypted by your browser → shown on your screen.

---

## 🧩 Summary – How It’s All Connected

| Layer                       | Example Technology             | Who Sets the Rules |
| --------------------------- | ------------------------------ | ------------------ |
| **7–5 Application–Session** | HTTP, HTTPS, DNS, SMTP         | IETF, W3C          |
| **4 Transport**             | TCP, UDP, Port Numbers         | IETF, IANA         |
| **3 Network**               | IP, BGP, ICMP                  | IETF, ICANN, RIRs  |
| **2 Data Link**             | Ethernet, Wi-Fi, MAC addresses | IEEE               |
| **1 Physical**              | Cables, radio, fiber           | IEEE               |






### 🧠 Step-by-Step Simplified OSI Flow

1. **Application Layer:**
   You type your message or perform an action in an app (like WhatsApp, email, or a browser).
   → This is the layer you directly *interact* with as a user.

2. **Presentation Layer:**
   Your message is **translated** into a format suitable for sending and often **encrypted** (secured).
   → Think of it as converting and locking your message.

3. **Session Layer:**
   It **keeps your session alive** while you’re connected — for example, during your chat or video call.
   → It opens, maintains, and closes the “conversation channel.”

4. **Transport Layer:**
   When you hit **send**, this layer decides how to transport your data:

   * **TCP** – reliable (for web pages, emails).
   * **UDP** – fast but less reliable (for videos, gaming).
     → It also makes sure packets arrive in order.

5. **Network Layer:**
   Finds the **best path** for your data to reach the destination using **IP addresses**.
   → Like a GPS for your data packets.

6. **Data Link Layer:**
   Works inside your **local network** (like your Wi-Fi).
   It uses **MAC addresses** to make sure the data goes to the correct device through your router or switch.
   → Like matching a house number on the right street.

7. **Physical Layer:**
   Converts your data into **electrical signals, light, or radio waves** that actually travel through cables or air.
   → The real movement of bits (1s and 0s).





![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ewbdi0071o8nv40gmhg1.png)




## 🏠 OSI Model Like Sending a Letter

We’ll match **each OSI layer** with a **real-world mail step**, plus the **protocols, ports, and controllers** in the network world.

---

### **Layer 7 – Application**

**💬 Real-world:** You write the letter — your actual message.
**📦 Purpose:** This is where *apps* talk to the network.
**🧩 Protocols:** HTTP, HTTPS, SMTP, FTP, DNS, SSH, Telnet, SNMP
**📫 Port Numbers:**

* HTTP → 80
* HTTPS → 443
* SMTP → 25
* DNS → 53
* SSH → 22
* FTP → 20/21
  **⚙️ Who Controls:** The **software application** (e.g., browser, email app, Jenkins, or curl).
  **🔗 Connection:** It hands your request to the **Presentation Layer** for formatting or encryption.

---

### **Layer 6 – Presentation**

**💬 Real-world:** You translate your letter into another language or encrypt it before sending.
**📦 Purpose:** Converts, compresses, and encrypts data.
**🧩 Protocols:** SSL/TLS, ASCII, JPEG, MPEG, JSON, XML
**⚙️ Who Controls:** The **operating system libraries** (OpenSSL, GnuTLS) and app frameworks.
**🔗 Connection:** Feeds ready-to-send data to the **Session Layer**.

---

### **Layer 5 – Session**

**💬 Real-world:** You start a phone call or meeting to coordinate how long you’ll exchange letters.
**📦 Purpose:** Establishes and maintains communication sessions between two systems.
**🧩 Protocols:** NetBIOS, RPC, PPTP, SIP, NFS session handling
**⚙️ Who Controls:** The **OS or network software** (e.g., managing TCP socket sessions).
**🔗 Connection:** Works with **Transport Layer** to ensure an open, valid connection.

---

### **Layer 4 – Transport**

**💬 Real-world:** The postal service decides *how* to deliver (standard mail or express).
**📦 Purpose:** Handles reliable or fast delivery of data.
**🧩 Protocols:** TCP (reliable), UDP (fast, connectionless)
**📫 Port Numbers:**

* TCP → HTTP (80), HTTPS (443), SSH (22), SMTP (25)
* UDP → DNS (53), DHCP (67/68), NTP (123)
  **⚙️ Who Controls:** The **operating system kernel** (Windows TCP/IP stack, Linux networking stack).
  **🔗 Connection:** Gives each app a **port number** to send and receive data streams.

---

### **Layer 3 – Network**

**💬 Real-world:** The postal system figures out *which route* to take (city, state, country).
**📦 Purpose:** Routes data between networks.
**🧩 Protocols:** IP, ICMP, ARP, RIP, OSPF, BGP
**⚙️ Who Controls:** Routers and Layer 3 firewalls.
**🔗 Connection:** Sends packets (with source and destination **IP addresses**) to the next network.

---

### **Layer 2 – Data Link**

**💬 Real-world:** The delivery truck moves letters from your street to the local post office.
**📦 Purpose:** Moves data *within* your local area (Wi-Fi or Ethernet).
**🧩 Protocols:** Ethernet, ARP, PPP, VLAN (802.1Q)
**⚙️ Who Controls:** **Switches and NIC cards** (Network Interface Cards).
**🔗 Connection:** Uses **MAC addresses** to deliver frames to the right local device.

---

### **Layer 1 – Physical**

**💬 Real-world:** The roads, mailboxes, and postmen who *physically move* your letter.
**📦 Purpose:** Transmits bits (1s and 0s) as signals — electrical, light, or radio waves.
**🧩 Examples:** Ethernet cables, fiber optics, Wi-Fi, Bluetooth, 4G/5G
**⚙️ Who Controls:** Hardware manufacturers and drivers.
**🔗 Connection:** Sends raw signals to another device’s physical port.

---

## 🔌 How It All Connects (Simplified Flow)

When you send a web request:

```
Your browser (App Layer)
↓
Encrypts via TLS (Presentation)
↓
Maintains session (Session)
↓
Chooses TCP port 443 (Transport)
↓
Uses your IP to route (Network)
↓
Encapsulates with MAC address (Data Link)
↓
Sends over Wi-Fi or cable (Physical)
```

Each layer **adds its own header** to the packet (encapsulation),
and the receiver **removes them** one by one (decapsulation).

---

## 🧭 Who Controls What

| Layer             | Controlled By        | Example                        |
| ----------------- | -------------------- | ------------------------------ |
| 7–5 (App–Session) | Software & protocols | Browser, email app, API client |
| 4 (Transport)     | Operating system     | TCP/UDP sockets                |
| 3 (Network)       | Routers & OS         | IP routing tables              |
| 2 (Data Link)     | Switches, NIC        | MAC tables, ARP cache          |
| 1 (Physical)      | Hardware             | Cables, antennas, fiber        |





## 💬 Simple OSI Model Explanation

| #     | Layer Name       | What It Does                                           | Real-Life Example                                                      |
| ----- | ---------------- | ------------------------------------------------------ | ---------------------------------------------------------------------- |
| **7** | **Application**  | This is what you actually use — your app.              | You type a message in WhatsApp or open a website.                      |
| **6** | **Presentation** | Makes data readable and secure.                        | Your message gets *encrypted* so no one can spy on it.                 |
| **5** | **Session**      | Keeps the connection alive while you chat.             | The app keeps your chat open with your friend.                         |
| **4** | **Transport**    | Delivers your message correctly and in order.          | If one message fails, it resends it. (TCP/UDP)                         |
| **3** | **Network**      | Finds the best route to send it.                       | Like Google Maps finding the fastest road for your data. (IP address)  |
| **2** | **Data Link**    | Sends the message inside your local area (home Wi-Fi). | Uses your device’s **MAC address** to reach the right laptop or phone. |
| **1** | **Physical**     | The actual wires or signals carrying your data.        | Wi-Fi waves, fiber cables, or your phone’s 4G/5G signal.               |

---

## 💡 In One Sentence:

When you **send a message**,

* The **Application** creates it,
* **Presentation** secures it,
* **Session** keeps the chat open,
* **Transport** guarantees delivery,
* **Network** finds the route,
* **Data Link** delivers it locally,
* **Physical** carries it through wires or air.





![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/s89ml9m5u1xwk5j4zlkq.png)



## 🌐 OSI Model Overview

The **OSI (Open Systems Interconnection)** model standardizes how network communication happens between devices.
It divides data transmission into **7 layers**, each responsible for specific tasks — from sending electrical signals to displaying web pages.

---

## 🧩 The Seven Layers (Simplified with DevOps Focus)

| Layer | Name             | Key Function                                                                          | DevOps Perspective                                                                                                                                                        |
| ----- | ---------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1** | **Physical**     | Sends raw bits over cables, fiber, or radio signals.                                  | When setting up servers (on-prem or cloud), DevOps ensures proper networking hardware or virtual network interfaces (ENIs, VPCs).                                         |
| **2** | **Data Link**    | Organizes bits into *frames*; uses **MAC addresses** for local delivery.              | When configuring **EC2 security groups, VPC subnets, or Docker bridge networks**, you indirectly work with this layer.                                                    |
| **3** | **Network**      | Routes *packets* across networks using **IP addresses**.                              | DevOps configures **VPCs, subnets, CIDR blocks, and route tables** — all belong here. Tools like `ping`, `traceroute`, and `ip route` operate at this layer.              |
| **4** | **Transport**    | Ensures reliable delivery with **TCP** or fast, connectionless transfer with **UDP**. | Understanding ports (HTTP-80, HTTPS-443) and load balancers (ALB/NLB) is critical. Monitoring latency or dropped packets (e.g., `netstat`, `ss`, `curl -v`) happens here. |
| **5** | **Session**      | Manages and maintains communication sessions between applications.                    | In APIs, SSH, or web sockets, DevOps ensures stable sessions using reverse proxies (Nginx) or session persistence in load balancers.                                      |
| **6** | **Presentation** | Translates, encrypts, or compresses data (e.g., SSL/TLS, JSON, JPEG).                 | SSL certificates, HTTPS termination, and data encoding in pipelines (base64, gzip) relate to this layer.                                                                  |
| **7** | **Application**  | Provides services directly to users (HTTP, FTP, SMTP, DNS).                           | DevOps deploys and monitors applications at this layer—web servers (Nginx, Apache), DNS setups, CI/CD delivery of app code.                                               |

---

## 🧠 Practical Example — Visiting YouTube

1. **Application:** Browser uses **HTTP/HTTPS** to request the YouTube page.
2. **Presentation:** Data encrypted via **TLS**.
3. **Session:** Connection maintained between your browser and YouTube servers.
4. **Transport:** **TCP** ensures reliable delivery of video data.
5. **Network:** **IP routing** directs packets globally.
6. **Data Link:** Frames delivered via **MAC addresses** in your LAN or Wi-Fi.
7. **Physical:** Data turned into **electrical or radio signals** over Ethernet or Wi-Fi.

---

## 🧰 Why OSI Matters for DevOps

* **Troubleshooting:** Knowing which layer fails helps isolate issues — e.g., DNS (Layer 7) vs. routing (Layer 3).
* **Infrastructure setup:** VPCs, subnets, and gateways map to layers 2–3.
* **Security:** Firewalls, SSL certificates, and IAM policies relate to Layers 3–7.
* **Monitoring:** Tools like Wireshark, `tcpdump`, `netstat`, and Prometheus metrics target different OSI layers.





