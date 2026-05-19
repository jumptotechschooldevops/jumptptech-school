---
title: "LAB: Subnetting with Router (2 Networks)"
description: "🧠 PART 1 — WHAT YOU BUILT    LEFT side → Switch + PCs → Subnet 1  RIGHT side → Switch + PCs..."
published: 2026-04-17
source: "https://dev.to/jumptotech/lab-subnetting-with-router-2-networks-1kde"
tags: []
---

# LAB: Subnetting with Router (2 Networks)





# 🧠 PART 1 — WHAT YOU BUILT 


* LEFT side → Switch + PCs → **Subnet 1**
* RIGHT side → Switch + PCs → **Subnet 2**
* Middle → Router → connects them

👉 This is **real-world design**

---

# 🧠 PART 2 — WHY SUBNETTING IS IMPORTANT

### ❌ Without subnetting (one big network)

* Too many devices
* Broadcast storms
* Slow network
* No security separation

---

### ✅ With subnetting

You create **smaller networks (subnets)**:

| Benefit      | Explanation               |
| ------------ | ------------------------- |
| Performance  | Less broadcast traffic    |
| Security     | Can control access        |
| Organization | HR, IT, Finance separated |
| Scalability  | Easy to grow              |

---

👉 Example (your lab):

* Subnet 1 = Office A
* Subnet 2 = Office B
* Router = gate between them

---

# 🧠 PART 3 — SUBNET DESIGN (VERY IMPORTANT)

We define:

### Subnet 1 (LEFT)

```plaintext
Network: 192.168.1.0/24
Gateway: 192.168.1.1
```

### Subnet 2 (RIGHT)

```plaintext
Network: 192.168.2.0/24
Gateway: 192.168.2.1
```

---

### 💡 Explain `/24`

2^8 = 256

* 8 bits for hosts
* 256 IP addresses total
* 254 usable

---

# 🧠 PART 4 — CONFIGURATION (STEP-BY-STEP)

## 🔹 1. Configure Router

Open Router CLI:

```cisco_ios
enable
configure terminal

interface g0/0
ip address 192.168.1.1 255.255.255.0
no shutdown

interface g0/1
ip address 192.168.2.1 255.255.255.0
no shutdown
```

---

## 🔹 2. Configure PCs (VERY IMPORTANT)

### LEFT PCs

| PC  | IP           | Gateway     |
| --- | ------------ | ----------- |
| PC0 | 192.168.1.10 | 192.168.1.1 |
| PC1 | 192.168.1.11 | 192.168.1.1 |
| PC2 | 192.168.1.12 | 192.168.1.1 |

---

### RIGHT PCs

| PC  | IP           | Gateway     |
| --- | ------------ | ----------- |
| PC3 | 192.168.2.10 | 192.168.2.1 |
| PC4 | 192.168.2.11 | 192.168.2.1 |
| PC5 | 192.168.2.12 | 192.168.2.1 |

---

# 🧠 PART 5 — HOW IT WORKS (CRITICAL)

## 🔁 Same Subnet Communication

Example:

```plaintext
PC0 → PC1
```

✔ Goes through **switch only**
❌ Router NOT used

---

## 🌍 Different Subnet Communication

Example:

```plaintext
PC0 → PC3
```

Steps:

1. PC0 sees → destination is different subnet
2. Sends packet to **default gateway (router)**
3. Router checks routing table
4. Router forwards to subnet 2
5. PC3 receives

---

👉 THIS is the key concept:

> Router = device that connects different networks

---

# 🧠 PART 6 — TESTING

## 🔹 Test same subnet

From PC0:

```console
ping 192.168.1.11
```

✔ Should work

---

## 🔹 Test different subnet

```console
ping 192.168.2.10
```

✔ Should work **only if router configured correctly**

---

# 🧠 PART 7 — WHAT HAPPENS IF NO ROUTER?



👉 “What if router is removed?”

Answer:

* PC0 cannot reach PC3
* Because different networks need routing

---

# 🧠 PART 8 — INTERVIEW LEVEL EXPLANATION

You can say:

> Subnetting divides a large network into smaller logical networks to improve performance, security, and manageability. Devices within the same subnet communicate directly via Layer 2, while communication between subnets requires a Layer 3 device like a router.

---

# 🧪 BONUS TASK
1. Change subnet mask to `/25`
2. Create **4 subnets**
3. Assign new IPs
4. Test connectivity




# 🧠 WHAT IS BROADCASTING?

> **Broadcast = one device sends data to ALL devices in the network**

---

## 🔁 Example

```text
PC1 → ALL PCs in same network
```

---

## 📦 Real case (VERY IMPORTANT)

When PC1 doesn’t know MAC address:

It sends:

> “Who has 192.168.1.20?”

👉 This is **ARP broadcast**

---

## 🔹 What happens

* Switch receives frame
* Sends it to **ALL ports (same VLAN only)**

---

## 💡 Key rule

> Broadcast stays inside the same subnet / VLAN

---

## 🔥 In your lab

* VLAN 10 → broadcast stays inside VLAN 10
* VLAN 20 → separate broadcast domain

---

---

# 🧠 WHAT IS MULTICASTING?

> **Multicast = one device sends data to a specific GROUP of devices**

---

## 🔁 Example

```text
Server → Only interested clients
```

---

## 📦 Real examples

* Video streaming
* Online classes
* Stock market feeds

---

👉 Not everyone receives it — only subscribers

---

## 🔹 IP Range for Multicast

```text
224.0.0.0 – 239.255.255.255
```

---

---

# 🧠 WHAT IS UNICAST (IMPORTANT TOO)

> **Unicast = one-to-one communication**

---

## 🔁 Example

```text
PC1 → PC2
```

✔ Most common
✔ Used in ping, web traffic, SSH

---

---

# ⚖️ DIFFERENCE (VERY CLEAR)

| Type      | Meaning   | Example     |
| --------- | --------- | ----------- |
| Unicast   | 1 → 1     | PC → Server |
| Broadcast | 1 → ALL   | ARP request |
| Multicast | 1 → Group | Streaming   |

---

---

# 🧠 SIMPLE ANALOGY

* Unicast → Phone call
* Broadcast → Shouting in a room
* Multicast → Talking to a group in a meeting

---

---

# 🔥 WHY BROADCAST IS IMPORTANT (AND DANGEROUS)

## ✅ Needed for:

* ARP
* DHCP discovery

---

## ❌ Problem:

Too many broadcasts =

👉 Network slowdown
👉 CPU overload
👉 “Broadcast storm”

---

---

# 🧠 HOW VLAN HELPS

👉 VLAN reduces broadcast

Instead of:

```text
1 big network → 1000 devices receive broadcast
```

You get:

```text
VLAN 10 → 100 devices
VLAN 20 → 100 devices
```

✔ Faster
✔ Cleaner

---

---

# 🧠 HOW ROUTER HANDLES IT

👉 Router **does NOT forward broadcast**

---

Example:

* PC in VLAN10 sends broadcast
  ❌ Router blocks it
  ✔ VLAN20 never receives it

---

---

# 🧠 MULTICAST IN REAL NETWORKS

Used when:

* You don’t want broadcast (too heavy)
* You don’t want multiple unicast (too expensive)

---

Example:

Instead of:

```text
Server → 100 users (100 separate streams)
```

Multicast:

```text
Server → 1 stream → group receives
```

✔ Efficient

---

---

# 🔥 INTERVIEW ANSWER (SHORT)

> Broadcast is one-to-all communication within a subnet or VLAN and is used for operations like ARP. Multicast is one-to-many communication where data is sent only to a specific group of devices. Unlike broadcast, multicast is more efficient because it avoids sending data to unnecessary devices.


### In your Packet Tracer:

* ARP request = broadcast
* Ping = unicast
* VLAN = controls broadcast domain



# 🔥 FINAL LINE (MEMORIZE)

> Broadcast sends data to all devices in a network, multicast sends data to a selected group, and unicast sends data to a single device.





# 🧠 PART 1 — HOW COMMUNICATION REALLY WORKS 

---

## 🔹 1. SAME NETWORK (NO VLAN)

Example:

```plaintext
PC1 (192.168.1.10) → PC2 (192.168.1.20)
```

### What happens step-by-step:

1. PC1 checks:

   * “Is 192.168.1.20 in my network?”
     ✔ YES

2. PC1 sends ARP:

   > “Who has 192.168.1.20?”

3. Switch:

   * Broadcasts to all ports

4. PC2 replies with MAC

5. Switch learns:

   * MAC → Port mapping (MAC table)

6. Data flows directly

---

👉 Key:

* Uses **MAC address**
* Switch works at **Layer 2**
* Router NOT used

---

# 🧠 2. DIFFERENT NETWORK (SUBNET)

Example:

```plaintext
PC1 (192.168.1.10) → PC3 (192.168.2.10)
```

---

### What happens:

1. PC1 checks:
   ❌ “Different network”

2. PC1 sends packet to:

```plaintext
Default Gateway (Router)
```

3. Router:

   * Removes Layer 2 frame
   * Checks IP (Layer 3)
   * Decides where to send

4. Router forwards to subnet 2

---

👉 Key:

* Uses **IP address**
* Router is required

---

# 🧠 3. VLAN (WHY SWITCH BLOCKS)

Example:

* PC1 → VLAN 10
* PC2 → VLAN 20

---

### What happens:

1. PC1 sends ARP
2. Switch checks VLAN
3. ❌ Does NOT forward to VLAN 20

---

👉 VLAN = **separate broadcast domain**

---

# 🧠 FINAL RULE (MEMORIZE)

👉 Same VLAN → Switch
👉 Different VLAN → Router

---

# 🚀 PART 2 — FULL LAB (USING YOUR TOPOLOGY)

---

# 🎯 Goal

You will:

* Create VLANs
* Assign ports
* Configure trunk
* Configure router (inter-VLAN routing)
* Enable DHCP
* Add ACL security
* Test everything

---

# 🧪 STEP 1 — VERIFY TOPOLOGY

You already have:

* PCs ✔
* Switch ✔
* Router ✔

Make sure:

* PCs connected to switch
* Switch connected to router

---

# 🧪 STEP 2 — SWITCH CONFIGURATION

Click Switch → CLI:

---

## 🔹 Enter config mode

```bash
enable
configure terminal
```

---

## 🔹 Create VLANs

```bash
vlan 10
name HR

vlan 20
name IT
```

---

## 🔹 Assign Ports

Example (adjust to your ports):

```bash
interface fa0/1
switchport mode access
switchport access vlan 10

interface fa0/2
switchport mode access
switchport access vlan 10

interface fa0/3
switchport mode access
switchport access vlan 20

interface fa0/4
switchport mode access
switchport access vlan 20
```

---

## 🔹 Configure Trunk (IMPORTANT)

Port connected to router:

```bash
interface fa0/24
switchport mode trunk
```

---

# 🧪 STEP 3 — ROUTER CONFIGURATION

Click Router → CLI:

---

## 🔹 Enter config

```bash
enable
configure terminal
```

---

## 🔹 Router-on-a-Stick

```bash
interface g0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0

interface g0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0

interface g0/0
no shutdown
```

---

👉 This allows router to handle VLANs

---

# 🧪 STEP 4 — DHCP CONFIG

```bash
ip dhcp pool HR
network 192.168.10.0 255.255.255.0
default-router 192.168.10.1

ip dhcp pool IT
network 192.168.20.0 255.255.255.0
default-router 192.168.20.1
```

---

## 🔹 On PCs

* Click PC
* Desktop → IP Configuration
* Select DHCP

---

# 🧪 STEP 5 — ACL (SECURITY)

## 🎯 Block HR → IT

```bash
access-list 100 deny ip 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255
access-list 100 permit ip any any
```

---

## 🔹 Apply ACL

```bash
interface g0/0.10
ip access-group 100 in
```

---

# 🧪 STEP 6 — TESTING

---

## ✅ SAME VLAN

From VLAN10 PC:

```bash
ping 192.168.10.X
```

✔ Should work

---

## ❌ BLOCKED

From VLAN10:

```bash
ping 192.168.20.X
```

❌ Should fail

---

## ✅ ALLOWED

From VLAN20:

```bash
ping 192.168.10.X
```

✔ Should work

---

# 🧠 PART 3 — WHAT STUDENTS MUST UNDERSTAND

---

## 🔹 Switch Role

* Forwards based on MAC
* Works inside VLAN only

---

## 🔹 VLAN Role

* Separates Layer 2 traffic
* Creates isolated networks

---

## 🔹 Subnet Role

* Defines IP structure
* Enables routing

---

## 🔹 Router Role

* Connects networks
* Routes packets

---

## 🔹 DHCP Role

* Assigns IP automatically

---

## 🔹 ACL Role

* Controls traffic (security)

---

# 🔥 FINAL INTERVIEW ANSWER

> Devices in the same VLAN communicate directly using Layer 2 switching. When devices are in different VLANs or subnets, communication requires a Layer 3 device such as a router. VLANs provide logical segmentation, subnetting provides IP structure, and routing enables communication between networks.


