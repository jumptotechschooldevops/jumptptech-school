---
title: "IP addresses"
description: "What is an IP Address?  An IP Address (Internet Protocol Address) is a unique numerical label..."
published: 2025-10-07
source: "https://dev.to/jumptotech/ip-addresses-18de"
tags: []
---

# IP addresses

What is an IP Address?

An IP Address (Internet Protocol Address) is a unique numerical label assigned to each device connected to a computer network that uses the Internet Protocol for communication. It serves two main purposes:

Identifying a device on the network.
Locating the device to enable communication with other devices over a network like the Internet.

Components of an IP Address
Network Portion: Identifies the network to which the device belongs.
Host Portion: Identifies the individual device on the network.
Subnet Mask (for IPv4): Defines which part of the IP is network and which part is host.
Example: IP 192.168.1.10 with subnet mask 255.255.255.0
Network ID: 192.168.1.0
Host ID: 10


Types of IP Address
IP addresses can be classified in several ways based on their structure, purpose, and the type of network they are used in. Here's a breakdown of the different classifications of IP addresses:


Types of IP Address
1. Based on Addressing Scope (IPv4 vs. IPv6)
1.1 Public IP Addresses
A Public IP address is assigned to every device that directly accesses the internet. This address is unique across the entire internet. Uniqueness & Accessibility are its key characteristics & are assigned by Internet Service Providers. When you connect to the internet through an Xfinity, your device or router receives a public IP address. These addresses can be static or dynamic.

Private-_-Public-Address
Public v/s Private IP Address
Example Use: If you host a website on your own server at home, your ISP must assign a public IP address to your server so users around the world can access your site.

1.2 Private IP Addresses
Private IP addresses are used within private networks and are not routable on the internet. This means that devices with private IP addresses cannot directly communicate with devices on the internet without a translating mechanism like a router performing Network Address Translation (NAT). These are only required to be unique within their own network & are used for communication between devices within the same network

Defined ranges for IPv4: 10.0.0.0 to 10.255.255.255, 172.16.0.0 to 172.31.255.255, 192.168.0.0 to 192.168.255.255
Defined ranges for IPv6: Addresses starting with FD or FC
Example Use: In a typical home network, the router assigns private IP addresses to each device (like smartphones, laptops, smart TVs) from the reserved ranges. These devices use their private IPs to communicate with each other and with the router. The router uses NAT to allow these devices to access the internet using its public IP address.


2. Based on IP Version
2.1 IPv4
This is the most common form of IP Address. It consists of four sets of numbers(octets) separated by dots. This format can support over 4 billion unique addresses. Each octet represents eight bits, or a byte, and can take a value from 0 to 255. This range is derived from the possible combinations of eight bits (28 = 256 combinations).


IPv4 Address Format
Example of IPv4 Address: 
192.168.1.1
192.168.1.1

192 is the first octet
168 is the second octet
1 is the third octet
1 is the fourth octet
Note: Each part of the IP address can indicate various aspects of the network configuration, from the network itself to the specific device within that network.

2.2 IPv6:
IPv6 addresses were created to deal with the shortage of IPv4 addresses. They use 128 bits instead of 32, offering a vastly greater number of possible addresses. These addresses are expressed as eight groups of four hexadecimal digits, each group representing 16 bits. The groups are separated by colons.


### **IPv6 Address Format**

**Example:**

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

---

### **Explanation:**

| Component                | Meaning                                                                                   |
| ------------------------ | ----------------------------------------------------------------------------------------- |
| **128 bits total**       | IPv6 addresses are 128 bits long (compared to IPv4’s 32 bits).                            |
| **8 groups**             | The address is divided into **8 groups** separated by colons (`:`).                       |
| **16 bits per group**    | Each group (like `2001`, `0db8`, `85a3`, etc.) represents 16 bits (4 hexadecimal digits). |
| **Hexadecimal notation** | Each group uses numbers `0–9` and letters `a–f` to represent binary values.               |

---

### **Simplification Rules**

IPv6 allows you to **shorten** addresses:

1. **Remove leading zeros** in any group:

   ```
   2001:db8:85a3:0:0:8a2e:370:7334
   ```

2. **Replace consecutive groups of zeros** with `::` (but only once in an address):

   ```
   2001:db8:85a3::8a2e:370:7334
   ```

---

### **Types of IPv6 Addresses**

| Type               | Example       | Description                                 |
| ------------------ | ------------- | ------------------------------------------- |
| **Global Unicast** | `2001:db8::1` | Public address used on the internet.        |
| **Link-Local**     | `fe80::1`     | Used within a local network segment.        |
| **Loopback**       | `::1`         | Equivalent to `127.0.0.1` in IPv4.          |
| **Multicast**      | `ff00::`      | Used to send data to multiple destinations. |

---



3. Based on Assignment
3.1 Static IP Addresses
Static IP Addresses are permanently assigned to a device, typically important for servers or devices that need a constant address.
Reliable for network services that require regular access such as websites, remote management.
3.2 Dynamic IP Addresses:
Temporarily assigned from a pool of available addresses by the Dynamic Host Configuration Protocol (DHCP).
Cost-effective and efficient for providers, perfect for consumer devices that do not require permanent addresses.
4. Based on Function
4.1. Unicast Address
In unicast, data is sent from one sender to one specific receiver identified by a unique IP address. It is the most common type of communication used in networks. Its Purpose is One-to-one communication.

Example: Sending an email or loading a webpage - your computer directly communicates with a specific server.
Use Case: Regular web browsing, file transfers (FTP), email (SMTP), etc.
4. 2. Broadcast Address
In broadcast, a message is sent from one device to all devices in the same network segment. Every device in the network receives and processes the broadcast message. Its Purpose is One-to-all communication within a network.

Example: An ARP (Address Resolution Protocol) request uses broadcasting to find a device’s MAC address on the local network.
Use Case: Network discovery, DHCP requests, ARP queries
Difference-Between-Unicast-Multicast-and-Broadcast
Unicast v/s Multicast v/s Broadcast
Note: Broadcast communication is supported in IPv4, but not in IPv6 (IPv6 replaces it with multicast).

4. 3. Multicast Address
In multicast, data is sent from one source to multiple selected receivers that are part of a multicast group. Only devices that have joined the group will receive the data, making it more efficient than broadcasting. Its Purpose is One-to-many (selected group) communication.



### **Multicast Address Overview**

| Feature                | Description                                                                    |
| ---------------------- | ------------------------------------------------------------------------------ |
| **Purpose**            | Used to send packets from one sender to **multiple receivers** simultaneously. |
| **Use Cases**          | IPTV, live streaming, video conferencing, online gaming, stock updates, etc.   |
| **Communication Type** | *One-to-many* (unlike unicast which is one-to-one).                            |

---

### **IPv4 Multicast**

| Property           | Value                                                                             |
| ------------------ | --------------------------------------------------------------------------------- |
| **Range**          | `224.0.0.0` → `239.255.255.255`                                                   |
| **Prefix**         | `224.0.0.0/4` (means first 4 bits are `1110`)                                     |
| **Example**        | `239.1.1.1`                                                                       |
| **Reserved Range** | `224.0.0.0 – 224.0.0.255` (used for local network protocols like routing updates) |

**Example Use Case:**
A company sends a live video stream to hundreds of employees on the same network using **224.1.1.1**.
All users subscribed to that multicast group receive the same stream efficiently.

---

### **IPv6 Multicast**

| Property               | Value                                                    |
| ---------------------- | -------------------------------------------------------- |
| **Prefix**             | `FF00::/8`                                               |
| **Format**             | `FFxx::` (the next bits after FF define scope and flags) |
| **Example**            | `FF02::1` (all nodes on the local link)                  |
| **Communication Type** | One-to-many                                              |

**Example Use Case:**
A live university lecture is streamed to students connected across IPv6 networks using a multicast group such as **FF15::1**.

---

### **Summary Table**

| Protocol | Multicast Range / Prefix      | Example     | Use Case                     |
| -------- | ----------------------------- | ----------- | ---------------------------- |
| **IPv4** | `224.0.0.0 – 239.255.255.255` | `239.1.1.1` | IPTV, Zoom, Teams            |
| **IPv6** | `FF00::/8`                    | `FF02::1`   | Live streaming, conferencing |



4.4. Anycast Address
In anycast, data is sent from one sender to the nearest receiver (in terms of network distance) among a group of devices sharing the same IP address. Routers determine the closest destination dynamically. Its Purpose is One-to-nearest communication (based on routing distance).

Anycast
Anycast
Example: Content Delivery Networks (CDNs) use anycast to route user requests to the nearest data center.
Use Case: DNS servers, CDN routing, load balancing
Note: Anycast is primarily used in IPv6, but it can also be implemented in IPv4.

Classes of IPv4 Address
There are around 4.3 billion IPv4 addresses and managing all those addresses without any classification is next to impossible. For easier management and assignment IP addresses are organized in numeric order and divided into the following 5 classes:

IP Class	Address Range	Maximum number of networks
Class A	1-126	126 (27-2)
Class B	128-191	16384
Class C	192-223	2097152
Class D	224-239	Reserve for multitasking
Class E	240-254	Reserved for Research and development
Class A (1.0.0.0 to 127.255.255.255): Used for very large networks (like multinational companies). Supports up to 16 million hosts per network.
Class B (128.0.0.0 to 191.255.255.255): Used for medium-sized networks, such as large organizations. Supports up to 65,000 hosts per network.
Class C (192.0.0.0 to 223.255.255.255): Used for smaller networks, like small businesses or home networks. Supports up to 254 hosts per network.
Class D (224.0.0.0 to 239.255.255.255): Reserved for multicast groups (used to send data to multiple devices at once). Not used for traditional devices or networks.
Class E (240.0.0.0 to 255.255.255.255): Reserved for experimental purposes and future use.
Special IP Addresses
There are also some special-purpose IP addresses that don't follow the usual structure:

Loopback Address: The loopback address 
127.0.0.1
127.0.0.1 is used to test network connectivity within the same device (i.e., sending data to yourself). Often called "localhost."
Broadcast Address: The broadcast address allows data to be sent to all devices in a network. For a typical network with the IP range 
192.168.1.0
/
24
192.168.1.0/24, the broadcast address would be 
192.168.1.255
192.168.1.255.
Multicast Address: Used to send data to a group of devices (multicast). For example, 
233.0.0.1
233.0.0.1 is a multicast address.
How Do IP Addresses Work?
An IP address (Internet Protocol address) serves as a unique identifier for every device connected to a network, enabling communication and data exchange across local and global networks. The Internet Protocol governs how data is packaged, addressed, transmitted, routed, and received.

1. Unique Identification
Every device-such as a computer, smartphone, or server-connected to a network is assigned an IP address.
This address acts like a digital home address, allowing the device to be uniquely identified within the network.
Without an IP address, a device cannot send or receive data on the network.
2. Communication Protocol
The Internet Protocol (IP) defines how data is transmitted between devices. When data is sent over a network, it is divided into smaller units called packets. Each packet contains:

The source IP address (the sender’s device)
The destination IP address (the receiver’s device)
Note: Routers and switches use these addresses to ensure that each packet reaches its correct destination.

3. Data Routing
When a device sends data to another device on the internet, the following steps occur:

The data is divided into packets.
Each packet includes the IP address of its destination.
Routers examine the destination IP on each packet and determine the best route to forward it.
Routers communicate with each other to update routing tables and maintain the most efficient paths for data transmission.
Note: This process ensures that packets may take different routes but ultimately arrive at the correct destination, where they are reassembled.

4. LAN and WAN Communication
Local Area Network (LAN): Within a local network, IP addresses can be assigned statically (manually) or dynamically using DHCP (Dynamic Host Configuration Protocol). Devices within the same LAN can communicate directly using private IP addresses.
Wide Area Network (WAN): When communicating across different networks, data travels through multiple routers over the internet. Each router independently decides the next hop based on the destination IP address to ensure optimal routing.
5. Network Address Translation (NAT)
NAT (Network Address Translation) allows multiple devices in a private network to share a single public IP address when accessing the internet.
Inside the local network, devices use private IPs (e.g., 192.168.x.x).
The router translates these private IPs into a public IP for outbound communication.
Note: NAT helps conserve the limited number of public IPs and provides an additional security layer by hiding internal network structures from the outside world.

Real World Scenario: Sending an Email from New York to Tokyo
Let's explore how IP addresses work through a real-world example that involves sending an email from one person to another across the globe:

Step 1: Assigning IP Addresses
Alice in New York has a laptop with a private IP, e.g., 192.168.1.5, assigned by her home router.
Bob in Tokyo has a computer with a private IP, e.g., 192.168.2.4, assigned by his office router
Step 2: Connecting to the Internet
Both routers have public IP addresses provided by their ISPs (Internet Service Providers).
These public IPs are used for all communications over the internet.
Step 3: Sending the Email
Alice composes an email and clicks "Send."
Her email client (e.g., Gmail or Outlook) converts the email into data packets that contain: Source IP -> Alice’s public IP (her router’s address) & Destination IP -> Bob’s mail server’s public IP
Step 4: Routing the Packets
The packets move from Alice’s laptop to her router.
The router detects that the destination IP is external and forwards the packets to Alice’s ISP.
The ISP’s routers analyze the destination IP and determine the optimal route.
Packets travel across several intermediate routers -perhaps through data centers in North America, Europe, and Asia -before reaching Japan.
Step 5: Reaching Bob
The packets arrive at Bob’s email server’s ISP in Tokyo.
The server’s router forwards them to Bob’s email server.
The server reassembles the packets into the original email message.
Step 6: Email Retrieval
Bob’s computer requests the email from the server using his local IP.
The server sends the email to Bob’s device, completing the communication.
Note: This illustrates the fundamental role of IP addresses and the complex network of routers involved in even the simplest internet activities like sending an email. Each part of the process depends on the IP address to ensure that data finds its way correctly from sender to receiver, no matter where they are in the world.

How to Look Up IP Addresses?
1. In Windows
Open the Command Prompt.
Type ipconfig and press Enter.
Look for your IP under your network connection.
2. On Mac
Open System Preferences > Network.
Select your active connection.
You’ll see your IP address in the connection details.
3. On iPhone
Go to Settings > Wi-Fi.
Tap the (i) icon next to your network.
Find your IP under "IP Address."
IP Address Security Threats
IP addresses are essential for connecting devices on the internet, but they also come with various security risks. Understanding these threats can help you protect your network and personal information more effectively. Some common IP address security threats are:

IP Spoofing: Attackers fake a trusted IP address to bypass security and gain unauthorized access.
DDoS Attacks: Multiple infected systems flood a target with traffic, causing slowdowns or crashes.
Man-in-the-Middle (MitM): Hackers intercept or alter data between two parties to steal sensitive information.
Port Scanning: Attackers scan for open ports to find vulnerabilities and exploit system weaknesses.
Note: Protecting against these threats requires strong network security, monitoring, and regular system updates.

How to Protect and Hide Your IP Address
Use a VPN (Virtual Private Network): A VPN hides your real IP address by routing your internet traffic through a secure VPN server. This masks your identity, encrypts your data, and prevents websites or attackers from tracking your location or online activities.
Use a Proxy Server: A proxy server acts as an intermediary between your device and the internet. When you send a request, it goes through the proxy, which substitutes its own IP address for yours, helping to conceal your real identity.
Use the Tor Browser: The Tor network routes your data through multiple volunteer-run servers (nodes), encrypting it at every layer. This makes it extremely difficult for anyone to trace your IP address or monitor your browsing activity.
Enable a Firewall: A firewall monitors and filters incoming and outgoing network traffic. It blocks suspicious or unauthorized connections, reducing the risk of hackers targeting your device via your IP address.





## 🌐 1. IP Address Basics

### **IPv4**

* Format: `x.x.x.x` (four numbers separated by dots)
* Range per block: 0–255
  Example: `192.168.10.5`
* Total available addresses: about **4.3 billion** (but some are reserved).

### **IPv6**

* Format: eight groups of hexadecimal numbers separated by colons (`:`)
  Example: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
* Provides **an almost unlimited number of addresses**, mainly used for **IoT** and modern large-scale networking.

In AWS, we primarily use **IPv4**.

---

## 🏠 2. Private IP Addresses

### **Definition:**

Private IPs are used **inside a company or AWS VPC** — they are **not reachable from the Internet**.

### **Private IP ranges (RFC 1918):**

| Range                         | CIDR Notation  | Example         |
| ----------------------------- | -------------- | --------------- |
| 10.0.0.0 – 10.255.255.255     | 10.0.0.0/8     | `10.0.1.15`     |
| 172.16.0.0 – 172.31.255.255   | 172.16.0.0/12  | `172.20.10.5`   |
| 192.168.0.0 – 192.168.255.255 | 192.168.0.0/16 | `192.168.1.100` |

### **Key Facts:**

* Used within **VPCs or office networks**.
* **Cannot** be accessed directly from the Internet.
* Two companies can have the same private IPs with no conflict.
* AWS assigns a **private IP by default** to every EC2 instance.

---

## 🌍 3. Public IP Addresses

### **Definition:**

Public IPs are **unique across the entire Internet** and allow your instance to be reachable globally.

### **Key Facts:**

* Used for web servers, APIs, or any Internet-facing resource.
* Assigned automatically by AWS **if your subnet is public**.
* Changes when you **stop/start your EC2 instance** (unless you use an Elastic IP).
* Mapped to your private IP via the **Internet Gateway (IGW)**.

---

## ⚙️ 4. Elastic IP (EIP)

### **Definition:**

A **permanent public IPv4 address** that you **own and control** in your AWS account.

### **When to Use:**

* You need a **fixed IP** for whitelisting (e.g., firewall, corporate VPNs).
* You want to **move an IP** quickly between instances for fault tolerance.

### **Key Facts:**

* AWS limits you to **5 Elastic IPs per region**.
* Each EIP can be attached to **only one instance** at a time.
* You are **charged** if the EIP is **allocated but not attached** to a running instance.
* Best practice: use **DNS (Route 53)** instead of static EIPs whenever possible.

---

## 🔁 5. How Private and Public IPs Work Together

| Scenario                              | IP Type          | Example       | Accessible From          |
| ------------------------------------- | ---------------- | ------------- | ------------------------ |
| Internal communication within AWS VPC | Private          | 10.0.1.10     | Same VPC/Subnet          |
| Internet access for EC2               | Public           | 54.200.123.11 | Anywhere                 |
| Fixed external IP                     | Elastic IP       | 3.88.41.200   | Anywhere                 |
| NAT Gateway access                    | Private → Public | via NAT       | Internet (outbound only) |

---

## 🧠 6. Hands-On in AWS

### **Step 1: Launch an EC2 Instance**

* Use Amazon Linux or Ubuntu.
* Note its **private** and **public** IPv4 addresses in the console.

### **Step 2: Connect via SSH**

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

### **Step 3: View Network Info**

```bash
ip addr show eth0
```

You’ll see:

* `inet 10.x.x.x` → private IP
* `inet 172.x.x.x` or `192.168.x.x` → private IP (depending on VPC range)

### **Step 4: Stop/Start Instance**

* Observe that **the public IP changes** after restart.

### **Step 5: Allocate an Elastic IP**

1. Go to **EC2 → Elastic IPs → Allocate**.
2. **Associate** it with your instance.
3. **Test SSH again** using the Elastic IP.

---

## 🚀 7. Best Practices

✅ Use **DNS names** via Route 53 instead of relying on IPs.
✅ Avoid Elastic IPs unless you need fixed whitelisting.
✅ Keep **private IPs** for internal communication between instances.
✅ For Internet-bound private instances, use **NAT Gateway** instead of assigning public IPs.











# 🧠 **Lecture: Public vs Private IPs and Elastic IPs (AWS Hands-On)**

## 🎯 **Goal**

Understand:

* Why we need Public IPs to connect to AWS EC2 from the Internet
* Why Private IPs cannot be used from outside the AWS VPC
* How Elastic IPs preserve the same public address even after restarting an instance
* The pricing and cleanup considerations for IPs

---

## 🌐 **1. Key Concepts Recap**

| Type                 | Accessible From                   | Changes on Stop/Start | Example        | Cost                                   |
| -------------------- | --------------------------------- | --------------------- | -------------- | -------------------------------------- |
| **Private IPv4**     | Only inside VPC / Private Network | ❌ No                  | `10.0.0.12`    | Free                                   |
| **Public IPv4**      | Internet                          | ✅ Yes                 | `54.200.18.45` | ~$3.50/mo (after free tier)            |
| **Elastic IP (EIP)** | Internet                          | ❌ No                  | `3.89.11.22`   | ~$3.50/mo if attached; charged if idle |

---

## 💻 **2. Hands-On: Observe IP Behavior**

### **Step 1 — Launch an EC2 Instance**

1. Go to **AWS Console → EC2 → Launch Instance**
2. Choose **Amazon Linux 2** (or Ubuntu)
3. Leave the default **VPC + subnet** (with Auto-assign Public IP = enabled)
4. Create a **key pair** if not done yet.
5. Launch the instance and wait for “running” state.

---

### **Step 2 — View Private and Public IPs**

* In the EC2 dashboard:

  * **Private IPv4:** used inside AWS
  * **Public IPv4:** used to connect via Internet

---

### **Step 3 — SSH into Your Instance**

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

✅ You’re connected — because the public IP is Internet-accessible.

---

### **Step 4 — Try Connecting Using the Private IP**

```bash
ssh -i your-key.pem ec2-user@<private-ip>
```

❌ It will **not work**, because:

* Private IPs belong to AWS internal network.
* You are outside that network unless you have a **VPN** or **Direct Connect**.

---

### **Step 5 — Observe Public IP Change After Stop/Start**

1. Copy and save your instance’s **current public IP**.
2. **Stop** the instance (Actions → Instance State → Stop).
3. **Start** it again.
4. Check the **new public IP** — it’s different.

👉 Your **private IP stays the same**, but the **public IP changes** every time you stop/start.

---

## ⚡ **3. Assign an Elastic IP**

### **Step 1 — Allocate Elastic IP**

1. Go to **EC2 → Elastic IPs → Allocate Elastic IP**
2. Choose “Amazon’s pool of IPv4 addresses” → Allocate
3. You now “own” a static IP address

---

### **Step 2 — Associate Elastic IP**

1. In Elastic IPs panel → select your new IP → Actions → Associate Elastic IP
2. Choose:

   * **Instance:** select your running EC2
   * **Private IP:** your instance’s private IP
3. Click **Associate**

✅ Now your instance has a **fixed public IP** (Elastic IP).

---

### **Step 3 — Test Elastic IP**

SSH into the instance using the new Elastic IP:

```bash
ssh -i your-key.pem ec2-user@<elastic-ip>
```

✅ Works.

Now stop and start the instance again.

Check again — **the Elastic IP remains the same!**

---

### **Step 4 — Clean Up**

When finished:

1. Go to **Elastic IPs → Actions → Disassociate Elastic IP**
2. Then **Release Elastic IP**
3. Terminate the EC2 instance

💡 This prevents extra charges (since idle EIPs cost ~$0.005/hour).

---

## 💲 **4. Pricing Summary**

| Type        | Charged When                      | Cost Estimate |
| ----------- | --------------------------------- | ------------- |
| Public IPv4 | Always (used or unused)           | ~$0.005/hr    |
| Elastic IP  | If **allocated but not attached** | ~$0.005/hr    |
| Private IP  | Free                              | $0            |

🧾 Free Tier gives 750 hours/month of free IPv4 usage, so if you run 1 instance for the month, you’re safe.

---

## 🚀 **5. Best Practice Tips**

* Use **Elastic IP** only when necessary (static whitelisting, legacy systems).
* Prefer **DNS (Route 53)** instead of relying on static IPs.
* For scalable designs, use a **Load Balancer** — no public IP needed on EC2s.
* Always **release unused EIPs** to save money.











# ⚙️ **Lecture: AWS EC2 Placement Groups**

## 🎯 **Goal**

Understand **how AWS places EC2 instances physically** in its data centers — and how **placement groups** can help you optimize for:

* **Low latency**
* **High throughput**
* **High availability**
* **Fault isolation**

---

## 🧩 **1. What Are Placement Groups?**

Placement Groups let you **control how EC2 instances are physically distributed** across AWS hardware (racks and Availability Zones).

AWS doesn’t let you directly choose hardware,
but placement groups let you express *intent* — for example:

> “Keep my servers close together for faster communication,”
> or
> “Spread them out so they don’t fail together.”

---

## 🧱 **2. Three Placement Group Strategies**

| Type          | Placement Goal                                   | Use Case                                              | Risk                     | Limit                     |
| ------------- | ------------------------------------------------ | ----------------------------------------------------- | ------------------------ | ------------------------- |
| **Cluster**   | Place instances close together in one AZ         | High performance computing (HPC), analytics           | High (single AZ failure) | No limit                  |
| **Spread**    | Place instances on distinct hardware             | Critical apps that must avoid single hardware failure | Low                      | 7 instances per AZ        |
| **Partition** | Group instances into isolated racks (partitions) | Big Data clusters (Hadoop, Cassandra, Kafka)          | Medium                   | Up to 7 partitions per AZ |

---

## 🚀 **3. Cluster Placement Group**

### **Concept**

* All EC2 instances are placed **close together** (same rack or same AZ).
* Designed for **high-speed communication** and **low latency**.

### **Benefits**

✅ 10 Gbps+ inter-instance network bandwidth
✅ Lowest latency possible
✅ Ideal for HPC, deep learning, real-time gaming, or tightly coupled workloads

### **Drawbacks**

⚠️ If the AZ fails → all instances fail
⚠️ Only works within a **single AZ**

### **Use Case Examples**

* High-performance computing (HPC)
* Distributed simulation workloads
* Real-time financial modeling
* GPU compute clusters

### **Visual**

```
Cluster Placement Group (1 AZ)
-------------------------------
| AZ us-east-1a               |
| [EC2-1][EC2-2][EC2-3]       | <-- Same rack (10 Gbps)
-------------------------------
```

---

## 🛡️ **4. Spread Placement Group**

### **Concept**

* EC2 instances are **spread across multiple racks and AZs**.
* Each instance sits on **separate hardware** — no two share the same rack.

### **Benefits**

✅ Best for fault tolerance
✅ Reduces simultaneous failure risk
✅ Can span multiple AZs in the same region

### **Drawbacks**

⚠️ Limited to **7 instances per AZ**
⚠️ Slightly higher latency (since hardware is spread out)

### **Use Case Examples**

* Critical web servers
* Multi-AZ application controllers
* Small, resilient systems that must stay up

### **Visual**

```
Spread Placement Group (multi-AZ)
----------------------------------------
| us-east-1a | us-east-1b | us-east-1c |
| [EC2-1]    | [EC2-2]    | [EC2-3]    | <-- Each on different rack
----------------------------------------
```

---

## 🗂️ **5. Partition Placement Group**

### **Concept**

* Designed for **large distributed systems**.
* EC2 instances are grouped into **partitions**, each isolated from the others by hardware racks.

### **Key Features**

* Up to **7 partitions per AZ**
* Each partition = independent set of racks
* Instances in the same partition share hardware; across partitions, they don’t.

### **Benefits**

✅ Fault isolation between partitions
✅ Scale to **hundreds of EC2 instances**
✅ Perfect for **partition-aware** workloads

### **Drawbacks**

⚠️ Slightly more complex setup
⚠️ Applications must understand data partitioning

### **Use Case Examples**

* Hadoop / HDFS
* Apache Cassandra
* Apache Kafka
* Spark clusters
* Big data storage layers

### **Visual**

```
Partition Placement Group (multi-AZ)
-------------------------------------------------
| us-east-1a         | us-east-1b               |
| [Partition-1]      | [Partition-3]            |
| [EC2-1][EC2-2][EC2-3] | [EC2-7][EC2-8][EC2-9]  |
| [Partition-2]                              |
| [EC2-4][EC2-5][EC2-6]                      |
-------------------------------------------------
```

---

## 🔧 **6. Hands-On: Create Placement Groups**

### **Step 1 — Create the Group**

In AWS Console → **EC2 → Placement Groups → Create Placement Group**

Choose:

* **Name:** my-cluster-group
* **Strategy:** Cluster / Spread / Partition
* For **Partition**, specify number of partitions (e.g., 3)

---

### **Step 2 — Launch EC2 into the Group**

1. Launch EC2 instance → **Advanced details → Placement group**
2. Select **existing group** or **create new one**
3. Choose AZ consistent with group type:

   * Cluster: one AZ
   * Spread: can span AZs
   * Partition: same region

---

### **Step 3 — View Placement Info**

In EC2 → Select Instance → **Description tab**
Check:

* *Placement group name*
* *Partition number (if applicable)*

You can also query it from inside the instance:

```bash
curl http://169.254.169.254/latest/meta-data/placement/group-name
```

and for partition info:

```bash
curl http://169.254.169.254/latest/meta-data/placement/partition-number
```

---

## 💡 **7. Comparison Summary**

| Feature              | Cluster          | Spread              | Partition        |
| -------------------- | ---------------- | ------------------- | ---------------- |
| Network Performance  | ⭐⭐⭐⭐             | ⭐⭐                  | ⭐⭐⭐              |
| Fault Tolerance      | ⭐                | ⭐⭐⭐⭐                | ⭐⭐⭐              |
| AZ Scope             | 1 AZ only        | Multi-AZ            | Multi-AZ         |
| Max Instances per AZ | Unlimited        | 7                   | Hundreds         |
| Use Case             | HPC, low latency | Critical small apps | Big Data, Hadoop |
| Failure Isolation    | Low              | Very High           | Partition-level  |

---

## ✅ **8. Best Practices**

* Choose **Cluster** for performance-sensitive tasks.
* Choose **Spread** for critical, small-scale HA systems.
* Choose **Partition** for large distributed data workloads.
* Always align your placement strategy with your **application’s architecture**.














# ⚙️ **Hands-On Lab: Creating and Using EC2 Placement Groups**

## 🎯 **Goal**

Learn how to:

* Create **Cluster**, **Spread**, and **Partition** placement groups
* Launch EC2 instances into them
* Understand how placement strategy affects performance and fault tolerance

---

## 🧭 **Step 1 — Open Placement Groups in AWS Console**

1. Go to **AWS Management Console → EC2**
2. In the **left sidebar**, scroll down to **Network & Security**
3. Click **Placement Groups**

---

## 🧩 **Step 2 — Create Three Placement Groups**

### **A. Cluster Placement Group**

* Click **Create placement group**
* **Name:** `my-high-performance-group`
* **Strategy:** `Cluster`
* **Description:** (optional) “High-speed low-latency placement group for compute-intensive workloads.”
* Click **Create group**

🟢 Result → You now have a group designed for **high-performance computing** within a single Availability Zone.

---

### **B. Spread Placement Group**

* Click **Create placement group**
* **Name:** `my-critical-group`
* **Strategy:** `Spread`
* **Spread level:** `Rack` (default)

  > 💡 “Host” option is only for **AWS Outposts** — ignore for now.
* Click **Create group**

🟢 Result → You now have a **fault-tolerant group**, spreading instances across multiple racks (and AZs).

---

### **C. Partition Placement Group**

* Click **Create placement group**
* **Name:** `my-distributed-group`
* **Strategy:** `Partition`
* **Number of partitions per AZ:** `4` (you can choose between 1–7)
* Click **Create group**

🟢 Result → You now have a **partitioned group**, perfect for large distributed data systems (Hadoop, Kafka, Cassandra, etc.).

---

## 🚀 **Step 3 — Launch an EC2 Instance into a Placement Group**

1. Click **Launch instance**
2. Choose **Amazon Linux 2** or **Ubuntu**
3. Choose instance type: e.g. `t2.micro` or `m5.large`
4. Select a **key pair**
5. Under **Network settings** → leave defaults (VPC and subnet)
6. Scroll to the **bottom** → expand **Advanced details**
7. Find **Placement group name**
8. Select one:

   * `my-high-performance-group`
   * `my-critical-group`
   * `my-distributed-group`
9. Click **Launch instance**

🧠 Note:
Each EC2 instance can belong to **only one placement group**.

---

## 🔍 **Step 4 — Verify Placement Group Assignment**

After your instance is running:

1. Go to **EC2 → Instances**
2. Select your instance → **Description tab**
3. Find:

   * **Placement group name**
   * **Placement strategy**
   * (For partition groups) → **Partition number**

You can also check this **inside the instance**:

```bash
# Find the placement group name
curl http://169.254.169.254/latest/meta-data/placement/group-name

# If using a partition group
curl http://169.254.169.254/latest/meta-data/placement/partition-number
```

---

## 🧼 **Step 5 — Clean Up**

After testing, to avoid charges:

1. **Terminate** EC2 instances
2. Go to **Placement Groups**
3. Select each → **Actions → Delete**

---

## 🧠 **Summary**

| Group Name                  | Strategy  | Use Case                 | Key Feature                  |
| --------------------------- | --------- | ------------------------ | ---------------------------- |
| `my-high-performance-group` | Cluster   | HPC, analytics           | Low latency, high throughput |
| `my-critical-group`         | Spread    | Web apps, control nodes  | Fault-tolerant (7 per AZ)    |
| `my-distributed-group`      | Partition | Hadoop, Kafka, Cassandra | Scalable, partition-aware    |











-

# ⚙️ **Lecture: Elastic Network Interfaces (ENI)**

---

## 🎯 **Goal**

Understand what **Elastic Network Interfaces (ENIs)** are, how they work, and why they’re used in **networking, failover, and multi-IP** architectures within AWS.

---

## 🧠 **1. What Is an ENI?**

An **Elastic Network Interface (ENI)** is a **virtual network card** inside your **VPC**.

It provides:

* Network connectivity (private/public IPs)
* Security group association
* MAC address and DNS hostname
* Elastic or static IP assignment

Every EC2 instance **must have at least one ENI** — called the **primary network interface (eth0)**.
You can optionally attach **secondary ENIs (eth1, eth2, …)**.

---

## 🧩 **2. ENI = Virtual Network Adapter**

Think of ENIs like physical network cards in a server — but virtual and managed by AWS.

### **Example Architecture**

```
Availability Zone: us-east-1a
----------------------------------
EC2 Instance A
   └── eth0 → ENI-Primary (10.0.1.10)
   └── eth1 → ENI-Secondary (10.0.1.20)

EC2 Instance B
   └── eth0 → ENI-Primary (10.0.2.10)
```

Each **ENI**:

* Belongs to a **Subnet**
* Is tied to a **single AZ**
* Can be **moved between instances** (within same AZ)

---

## 🧾 **3. ENI Attributes**

| Attribute                     | Description                                           |
| ----------------------------- | ----------------------------------------------------- |
| **Primary private IPv4**      | Automatically assigned on creation                    |
| **Secondary private IPv4(s)** | Optional extra IPs (can be used for apps or failover) |
| **Elastic IP (optional)**     | Can be mapped to any private IP                       |
| **Security Groups**           | One or more security groups can be attached           |
| **MAC Address**               | Fixed hardware-like identifier                        |
| **Subnet + AZ**               | Determines network reachability                       |
| **Attachment state**          | Attached / Detached / Attaching / Detaching           |

---

## 🔁 **4. ENI Use Cases**

| Scenario                        | Description                                                                |
| ------------------------------- | -------------------------------------------------------------------------- |
| **Primary ENI (eth0)**          | Always attached at instance launch                                         |
| **Secondary ENI (eth1, eth2)**  | Can be attached later manually or via automation                           |
| **Failover**                    | Move ENI (and its IP) to another instance if one fails                     |
| **Multi-Network Configuration** | EC2 connected to multiple subnets (via different ENIs)                     |
| **High Availability Services**  | Seamless IP transfer between standby instances                             |
| **Security Isolation**          | Use separate ENIs for private and public traffic                           |
| **BYO Network Firewall**        | Attach an ENI to custom firewall appliances (e.g., Palo Alto, Check Point) |

---

## ⚠️ **5. Important Notes**

* ENIs are **tied to a single AZ**.
  You can’t move them across AZs.
* Each ENI can be attached to **only one instance at a time**.
* You can attach or detach ENIs **while instances are running**.
* When detached, the ENI retains:

  * Its **private IPs**
  * **Security groups**
  * **Elastic IP associations**

---

## 🧪 **6. Hands-On: Creating and Attaching ENIs**

### **Step 1 — Create an ENI**

1. Go to **EC2 → Network & Security → Network Interfaces**
2. Click **Create network interface**
3. Configure:

   * **Name:** `my-secondary-eni`
   * **Subnet:** choose same AZ as your EC2 instance
   * **Private IPv4:** leave default (auto-assign)
   * **Security groups:** choose existing one (e.g., default)
4. Click **Create network interface**

---

### **Step 2 — Attach ENI to EC2 Instance**

1. Go to **Network Interfaces → select `my-secondary-eni`**
2. Click **Actions → Attach**
3. Choose the target EC2 instance
4. Click **Attach**

✅ Now your instance has a **second network interface (eth1)**.

---

### **Step 3 — Verify from Inside the Instance**

SSH into the instance:

```bash
ip addr show
```

You should see:

* `eth0` (primary interface)
* `eth1` (secondary ENI)

---

### **Step 4 — Move ENI Between Instances**

1. **Detach** ENI from Instance A (Actions → Detach)
2. **Attach** it to Instance B (must be in the same AZ)
3. Check on Instance B:

   ```bash
   ip addr show
   ```

   You’ll see the same **private IP** move with the ENI.

✅ This demonstrates **failover** — IP moves to another instance instantly.

---

### **Step 5 — Clean Up**

1. Detach ENI from any instances
2. Delete it from **Network Interfaces**

---

## 🧩 **7. CLI Reference**

Create ENI:

```bash
aws ec2 create-network-interface \
  --subnet-id subnet-123abc \
  --groups sg-123abc \
  --description "My secondary ENI"
```

Attach ENI:

```bash
aws ec2 attach-network-interface \
  --network-interface-id eni-0abc1234 \
  --instance-id i-0abc1234 \
  --device-index 1
```

Detach ENI:

```bash
aws ec2 detach-network-interface --attachment-id eni-attach-0abc1234
```

Delete ENI:

```bash
aws ec2 delete-network-interface --network-interface-id eni-0abc1234
```

---

## ✅ **8. Summary**

| Feature                   | Description                                      |
| ------------------------- | ------------------------------------------------ |
| **Purpose**               | Virtual network card for EC2 & VPC resources     |
| **Default ENI**           | Primary (eth0) created automatically             |
| **Secondary ENIs**        | Added manually for HA or multi-networking        |
| **AZ-bound**              | Cannot move between AZs                          |
| **Failover Ready**        | IP moves instantly with ENI                      |
| **CLI + Console Support** | Fully managed via AWS API, Console, or Terraform |












# ⚙️ **Hands-On Lab: Practicing Elastic Network Interfaces (ENI)**

---

## 🎯 **Goal**

Learn how to:

* View ENIs automatically created with EC2 instances
* Create and attach your own ENI manually
* Move an ENI between instances for **network failover**
* Understand ENI persistence and deletion behavior

---

## 🧱 **1. Launch Two EC2 Instances**

1. Go to **EC2 → Launch Instances**
2. Choose **Amazon Linux 2 AMI**
3. Instance type → `t2.micro`
4. Key pair → choose any (for this demo)
5. **Network Settings**:

   * Use **default VPC**
   * Subnet: any (e.g., `us-east-2a`)
   * Security group: select existing one (e.g., `launch-wizard-1`)
6. Launch **two instances**

🟢 **Expected result:**
Two EC2 instances running in the same Availability Zone.

---

## 🌐 **2. View Network Interfaces for Each Instance**

1. Select an instance → **Networking tab**
2. Scroll down to **Network interfaces**

You’ll see:

* **Interface ID** (e.g., `eni-0abc12345`)
* **Private IPv4**
* **Public IPv4**
* **Private DNS name**

🟢 Each EC2 instance has **one ENI (eth0)** automatically created.
This is the **primary ENI** responsible for instance connectivity.

---

## 🧭 **3. Locate ENIs in the Console**

1. On the left panel → **Network & Security → Network Interfaces**
2. You’ll see **two ENIs**, one for each EC2 instance.

   * Status: **In-use**
   * Each linked to a different **Instance ID**

🧠 **Observation:**
When you launch an EC2, AWS automatically creates and attaches an ENI to it.

---

## 🔧 **4. Create a New (Manual) ENI**

1. Click **Create network interface**
2. Set:

   * **Description:** `demo-eni`
   * **Subnet:** same AZ as your instances (e.g., `us-east-2a`)
   * **Private IPv4:** select “Auto-assign”
   * **Security Group:** choose your default or `launch-wizard-1`
3. Click **Create network interface**

🟢 **Result:**
You now have a new ENI named `demo-eni` in **Available** state (not attached to any instance).

---

## 🔗 **5. Attach the ENI to an Instance**

1. Select `demo-eni` → **Actions → Attach**
2. Choose your **first EC2 instance**
3. Click **Attach**

🟢 **Result:**
The ENI status changes to **In-use**.
Your instance now has **two interfaces**:

* `eth0` (primary, with public and private IP)
* `eth1` (secondary, private IP from demo ENI)

---

## 💻 **6. Verify from the Instance**

SSH into the instance:

```bash
ip addr show
```

You’ll see:

```
eth0: 10.0.1.100
eth1: 10.0.1.150  <-- demo-eni
```

✅ This confirms your secondary ENI is attached.

---

## 🔁 **7. Move the ENI Between Instances (Failover Demo)**

1. Go back to **Network Interfaces**
2. Select `demo-eni` → **Actions → Detach**
3. Confirm → use **Force Detach** if needed
4. Wait until status becomes **Available**
5. **Attach** it to your **second EC2 instance**
6. Refresh both instances’ Networking tabs

🧠 **Observation:**

* The first instance now has only **one ENI**
* The second instance now has **two ENIs**
* The **private IPv4** moved with the ENI!

🎯 **Why this matters:**
This demonstrates **instant failover** — the same private IP can move between instances, useful for HA systems or active/passive setups.

---

## 🧹 **8. Terminate Instances and Observe ENI Behavior**

1. Terminate both EC2 instances
2. Go back to **Network Interfaces**

🧠 **Observation:**

* The **two automatically created ENIs** (eth0 of each instance) are **deleted** automatically.
* Your manually created `demo-eni` remains.

💡 **Reason:**
Manually created ENIs are independent resources — they persist even after the instance they were attached to is deleted.

---

## ✅ **9. Clean Up**

If you want to remove it:

* Select `demo-eni` → **Actions → Delete**

🟢 **Cost note:**
ENIs **do not incur charges** unless attached to a running EC2.

---

## 🧠 **Summary**

| Concept                        | Description                                             |
| ------------------------------ | ------------------------------------------------------- |
| **Primary ENI (eth0)**         | Created automatically with instance                     |
| **Secondary ENI (eth1, etc.)** | Created manually for additional IPs or failover         |
| **AZ-bound**                   | ENIs cannot move across Availability Zones              |
| **Failover use case**          | Move ENI between instances for instant recovery         |
| **Persistence**                | Manually created ENIs remain after instance termination |














# ⚙️ **Lecture: EC2 Hibernate**

---

## 🎯 **Goal**

Understand what **EC2 Hibernate** does, how it differs from **Stop** and **Terminate**, and when to use it for faster instance startup and state preservation.

---

## 🧠 **1. Background: Stop vs Terminate vs Hibernate**

| Action        | What Happens                                | RAM         | EBS (Disk)                                                   | Boot Time   | Typical Use                                       |
| ------------- | ------------------------------------------- | ----------- | ------------------------------------------------------------ | ----------- | ------------------------------------------------- |
| **Stop**      | Shuts down the OS; preserves EBS volume     | ❌ Lost      | ✅ Preserved                                                  | Normal      | Pause instance (no charges for compute)           |
| **Terminate** | Deletes instance (and possibly root volume) | ❌ Lost      | ⚠️ Optional (if “Delete on Termination” is true → destroyed) | N/A         | Delete instance permanently                       |
| **Hibernate** | Saves RAM contents to EBS; resumes later    | ✅ Preserved | ✅ Preserved                                                  | ⚡ Very fast | Resume applications instantly from previous state |

---

## 🧩 **2. What EC2 Hibernate Does Internally**

1. Instance is in **running** state with data in RAM.
2. When **Hibernate** is triggered:

   * AWS **dumps the RAM contents** to the **root EBS volume**.
   * The instance goes into **stopping → stopped** state.
3. On restart:

   * The RAM contents are **reloaded** from the EBS volume.
   * The instance resumes **exactly where it left off**.

✅ **Result:** Processes, cache, sessions, and in-memory data are all preserved.

---

## ⚙️ **3. Technical Requirements for EC2 Hibernate**

| Requirement                | Description                                                                            |
| -------------------------- | -------------------------------------------------------------------------------------- |
| **Root Volume Type**       | Must be an **EBS volume**                                                              |
| **Encryption**             | The **root EBS volume must be encrypted**                                              |
| **Available Space**        | Root volume must be **large enough** to store RAM contents                             |
| **RAM Limit**              | Supported up to ~150 GB RAM                                                            |
| **Instance Type**          | Supported on most modern families (no bare-metal)                                      |
| **Operating Systems**      | Works on Amazon Linux, Ubuntu, RHEL, CentOS, Windows                                   |
| **Max Hibernate Duration** | Up to 60 days                                                                          |
| **Billing**                | You are charged for the **EBS storage** only (no EC2 compute charges while hibernated) |

---

## 🚀 **4. Advantages of EC2 Hibernate**

✅ **Fast boot time** — instance resumes from memory snapshot
✅ **Preserves in-memory data** (caches, sessions, temporary computation state)
✅ **No re-initialization** — OS and applications start immediately
✅ **Great for long-running workloads** that need quick restarts

---

## ⚠️ **5. Limitations**

* **Cannot hibernate bare-metal** instances.
* **Root volume must be encrypted.**
* **RAM dump consumes EBS space.**
* Not ideal for **stateless applications** (better to just stop/start).
* Hibernate duration: **up to 60 days** only.

---

## 💡 **6. Typical Use Cases**

| Use Case                                 | Why Hibernate Helps                               |
| ---------------------------------------- | ------------------------------------------------- |
| **Long-running simulations**             | Resume computation without restarting processes   |
| **In-memory caches (Redis, Memcached)**  | Avoid cache rebuild after restart                 |
| **Dev/Test Environments**                | Quickly resume preconfigured environments         |
| **Data analysis or ML training**         | Keep Python/R models or datasets loaded in memory |
| **App servers with large startup delay** | Fast recovery without reloading all dependencies  |

---

## 🧪 **7. Hands-On: Enable and Test Hibernate**

### **Step 1 — Create Key Pair & Security Group**

If you don’t already have one:

* Create a **key pair** (for SSH access)
* Create a **security group** allowing SSH (port 22)

---

### **Step 2 — Launch a New EC2 Instance**

1. Go to **EC2 → Launch Instance**
2. Name: `hibernate-demo`
3. Choose **Amazon Linux 2 AMI**
4. Choose an instance type (e.g., `t3.micro`)
5. Key pair: your existing one
6. Under **Advanced Details → Stop - Hibernate behavior:**

   * Select **Enable hibernation as an instance behavior**
7. Click **Launch instance**

🟢 **Important:**
Hibernate option is only visible when:

* AMI supports it
* Instance type + root volume are compatible
* Root volume encryption is enabled

---

### **Step 3 — Connect and Simulate Data in Memory**

SSH into your instance:

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

Create a sample in-memory process:

```bash
python3 -c "data = 'x'*100000000; input('Data loaded in memory. Press Enter to exit...')"
```

Now, without exiting, go back to AWS Console.

---

### **Step 4 — Hibernate the Instance**

1. Go to **EC2 → Instances**
2. Select `hibernate-demo`
3. Click **Instance state → Hibernate instance**
4. Confirm → the instance will enter **Stopping → Stopped** state.

🧠 **Behind the scenes:**
RAM contents are written to the root EBS volume.

---

### **Step 5 — Start the Instance Again**

1. Select the same instance → **Instance state → Start**
2. Watch as it transitions to **Running**.

✅ **Expected Result:**

* Boot time is **much faster** than a full start.
* In-memory processes resume exactly where you left off.
* If you used the Python script, your prompt reappears instantly.

---

### **Step 6 — Clean Up**

Terminate the instance when done:

* Go to **EC2 → Instances → Select → Terminate**

---

## 📊 **8. Behavior Comparison Recap**

| Behavior       | Stop         | Hibernate    | Terminate   |
| -------------- | ------------ | ------------ | ----------- |
| Retains RAM?   | ❌            | ✅            | ❌           |
| Keeps EBS?     | ✅            | ✅            | ⚠️ Optional |
| Boot Speed     | Normal       | Very Fast    | N/A         |
| Cost While Off | Storage only | Storage only | None        |
| Duration Limit | Unlimited    | 60 days      | N/A         |

---

## ✅ **9. Summary**

| Key Point         | Description                                         |
| ----------------- | --------------------------------------------------- |
| **EC2 Hibernate** | Freezes your instance — saves memory (RAM) to disk  |
| **Root EBS**      | Must be encrypted and large enough                  |
| **Startup Time**  | Extremely fast — resumes from saved state           |
| **Use Case**      | Long-running, memory-heavy, or slow-start workloads |
| **Max Duration**  | Up to 60 days                                       |












# ⚙️ **Hands-On Lab: Practicing EC2 Hibernate**

---

## 🎯 **Goal**

Learn how to:

* Enable **EC2 Hibernate** when launching an instance
* Configure encryption and storage correctly
* Verify hibernation behavior using the `uptime` command

---

## 🧩 **1. Launch an EC2 Instance with Hibernate Enabled**

### **Step 1 — Launch Instance**

1. Go to **EC2 → Launch Instances**
2. Choose **Amazon Linux 2 AMI**
3. Instance type: `t2.micro`
4. Select your **key pair**
5. In **Network settings**, select an existing **security group** (e.g., `launch-wizard-1`)

---

### **Step 2 — Configure Storage and Encryption**

1. Scroll to **Storage (EBS Volume)**

   * Default size: 8 GB
   * That’s enough for `t2.micro` (which has **1 GB RAM**)
2. Click **Advanced → Encryption**

   * ✅ Check **Encrypt this volume**
   * Choose **AWS managed key (aws/ebs)**

🧠 **Why:**

* Hibernate writes the contents of **RAM** to your **root EBS volume**.
* The volume must be **encrypted** and **large enough** to store all memory data.

---

### **Step 3 — Enable Hibernate**

1. Scroll down to **Stop - Hibernate behavior**
2. ✅ Select **Enable hibernation as an instance behavior**
3. Review your configuration
4. Click **Launch instance**

🟢 **Result:**
Instance is now configured to **hibernate** instead of performing a full stop when requested.

---

## 🔍 **2. Verify Hibernation Behavior**

### **Step 1 — Connect to Instance**

Use EC2 Instance Connect:

* Select your instance → **Connect → EC2 Instance Connect → Connect**

---

### **Step 2 — Check Initial Uptime**

Run:

```bash
uptime
```

You’ll see something like:

```
 00:34:12 up 0 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Wait about a minute:

```bash
uptime
```

Now it should show:

```
 00:35:14 up 1 min,  1 user,  load average: 0.00, 0.00, 0.00
```

🧠 **Meaning:**
`uptime` shows how long the system has been running since its last restart.

---

## 💤 **3. Hibernate the Instance**

### **Step 1 — Hibernate**

1. In the EC2 console → select your instance
2. Click **Instance state → Hibernate instance**
3. Confirm

AWS will:

* Save all data in **RAM** to your **root EBS volume**
* Transition the instance to **Stopping → Stopped**

---

### **Step 2 — Start the Instance Again**

1. Select your instance → **Instance state → Start instance**
2. Wait for the **running** state

🧠 **Behind the scenes:**
When starting, AWS **restores the RAM contents** from the EBS snapshot — the OS never reboots from scratch.

---

## ⚡ **4. Verify Hibernate Worked**

### **Step 1 — Reconnect**

Open EC2 Instance Connect again.

### **Step 2 — Check Uptime**

```bash
uptime
```

Expected output:

```
 00:39:45 up 3 min,  1 user,  load average: 0.00, 0.00, 0.00
```

✅ The uptime did **not reset to 0**, proving that:

* The system was **not restarted**, only **resumed** from hibernation.
* RAM state and OS session were preserved.

---

## 🧹 **5. Clean Up**

1. When done testing, select your instance
2. Click **Instance state → Terminate instance**

---

## 🧠 **Key Takeaways**

| Concept                | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| **Hibernate**          | Saves the instance’s RAM state to its root EBS volume        |
| **EBS Requirements**   | Must be **encrypted** and large enough to store RAM contents |
| **Benefit**            | Faster startup — resumes from frozen OS state                |
| **Command to Verify**  | `uptime` (shows continuity after hibernation)                |
| **Supported Duration** | Up to **60 days** in hibernation                             |
| **Cost**               | Only EBS storage charges (no compute cost while hibernated)  |

---



