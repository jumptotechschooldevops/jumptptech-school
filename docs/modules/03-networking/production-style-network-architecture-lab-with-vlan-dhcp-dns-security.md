---
title: "Production-Style Network Architecture Lab with VLAN, DHCP, DNS & Security"
description: "Employees (VLANs) → Switch → Router → Server Network        Enter fullscreen mode            Exit..."
published: 2026-04-21
source: "https://dev.to/jumptotech/production-style-network-architecture-lab-with-vlan-dhcp-dns-security-6ih"
tags: []
---

# Production-Style Network Architecture Lab with VLAN, DHCP, DNS & Security




```plaintext
Employees (VLANs) → Switch → Router → Server Network
```

* Left side = employees (HR, IT, DevOps)
* Right side = servers (DNS, Web, etc.)
* Router = connects everything
* Switch = organizes devices


# 1️⃣ VLAN — WHY WE CREATE IT

👉 Problem:
If all PCs are in one network → everyone sees everyone → messy + insecure

👉 Solution:
We created VLANs:

| VLAN | Meaning |
| ---- | ------- |
| 10   | HR      |
| 20   | IT      |
| 30   | DevOps  |

👉 What happens internally:

* Switch separates traffic using **MAC addresses**
* Devices in VLAN 10 **cannot talk** to VLAN 20 by default

👉 Key concept:

> VLAN = logical separation inside the same switch

---

# 2️⃣ ACCESS PORTS — HOW PCs CONNECT

Each PC is connected like:

```cisco_ios
interface fa0/x
switchport mode access
switchport access vlan X
```

👉 Meaning:

* That port belongs to ONE VLAN
* PC inherits VLAN automatically

---

# 3️⃣ TRUNK — WHY WE NEEDED IT

👉 Problem:
We have **multiple VLANs**, but only **one cable to router**

👉 Solution:
Trunk port

```cisco_ios
switchport mode trunk
```

👉 What trunk does:

* Carries **multiple VLANs in one cable**
* Adds **VLAN tag (802.1Q)**






> One cable, but labeled traffic:

* VLAN 10 packet → tagged 10
* VLAN 20 packet → tagged 20

---

# 4️⃣ ROUTER — WHY WE NEEDED IT

👉 Problem:
VLANs cannot talk to each other

👉 Solution:
Router

---

# 5️⃣ SUBINTERFACES — HOW ROUTER UNDERSTANDS VLANS

You created:

```plaintext
g0/0.10 → VLAN 10
g0/0.20 → VLAN 20
g0/0.30 → VLAN 30
```

Each has:

```cisco_ios
encapsulation dot1Q X
ip address 192.168.X.1
```

👉 What this does:

* Router receives tagged traffic
* Understands VLAN ID
* Routes between VLANs

👉 Key concept:

> Router = Layer 3 (IP based routing)

---

# 6️⃣ DEFAULT GATEWAY — WHY IT MATTERS

Each PC has:

```plaintext
Default Gateway = Router IP
```

Example:

| VLAN | Gateway      |
| ---- | ------------ |
| 10   | 192.168.10.1 |
| 20   | 192.168.20.1 |

👉 Meaning:

> “If I don’t know where to go → send to router”

---

# 7️⃣ SECOND NETWORK (RIGHT SIDE)

You added:

```plaintext
Router → Switch1 → PCs
```

👉 This simulates:

* Datacenter
* Servers
* Another office

---

# 8️⃣ DHCP — AUTOMATION (REAL SRE FEATURE)

Instead of manual IP:

```cisco_ios
ip dhcp pool VLAN10
```

👉 What DHCP does:

* Automatically gives:

  * IP address
  * Subnet mask
  * Gateway
  * DNS

👉 Real-world:

> No company manually configures thousands of PCs

---

# 9️⃣ DNS — NAME SYSTEM

You configured:

```plaintext
company.local → 192.168.50.10
```

👉 Meaning:

Instead of:

```plaintext
http://192.168.50.10
```

Users type:

```plaintext
http://company.local
```

👉 Real-world:

> Humans use names, computers use IP

---

# 🔟 WEB SERVER — APPLICATION LAYER

You enabled HTTP:

👉 Now network serves content

This is important:

> Networking is useless without applications

---

# 1️⃣1️⃣ SSH — REMOTE ADMINISTRATION

You configured:

```ssh
ssh admin@router
```

👉 Why:

* No physical access needed
* Secure (encrypted)

👉 Real SRE task:

> Managing servers remotely

---

# 1️⃣2️⃣ ACL — SECURITY (VERY IMPORTANT)

You created:

```plaintext
deny HR → Server
permit everything else
```

👉 Meaning:

| Traffic     | Result    |
| ----------- | --------- |
| HR → Server | ❌ BLOCKED |
| IT → Server | ✅ ALLOWED |

👉 Key concept:

> ACL = firewall rule

---

# 🧠 HOW EVERYTHING WORKS TOGETHER

Let’s trace one packet:

---

### Example: HR PC → Web Server

1. PC sends request → switch
2. Switch sees VLAN 10 → sends via trunk
3. Router receives tagged VLAN 10
4. Router checks ACL
5. If allowed → forwards to server network
6. Server responds
7. Router sends back to correct VLAN
8. Switch delivers to PC

---

# 🔥 WHAT YOU BUILT (IMPORTANT FOR INTERVIEW)

You built:

* Network segmentation (VLAN)
* Routing (Inter-VLAN)
* Traffic aggregation (Trunk)
* IP management (DHCP)
* Name resolution (DNS)
* Remote access (SSH)
* Security (ACL)

---

# 🎯 HOW TO SAY THIS IN INTERVIEW

Short version:

> “I built a segmented enterprise network using VLANs, configured trunking and router-on-a-stick for inter-VLAN routing, implemented DHCP and DNS services, enabled SSH for secure management, and applied ACLs to enforce security policies.”












  implement:

1. VLANs (left side)
2. Inter-VLAN routing (router)
3. Routing to second network (right side)
4. DHCP (automatic IP)
5. DNS (name resolution)
6. SSH (remote admin)
7. ACL (security)




> “Left side = company employees
> Right side = server network / datacenter
> Router = brain connecting everything”

---

# 🧩 STEP 1 — DESIGN IP PLAN

## LEFT SIDE (Switch0 VLANs)

| VLAN | Network         | Purpose |
| ---- | --------------- | ------- |
| 10   | 192.168.10.0/24 | HR      |
| 20   | 192.168.20.0/24 | IT      |
| 30   | 192.168.30.0/24 | DevOps  |

---

## RIGHT SIDE (Switch1 = Server Network)

| Network         | Purpose |
| --------------- | ------- |
| 192.168.50.0/24 | Servers |

---

## ROUTER INTERFACES

| Interface | IP           |
| --------- | ------------ |
| G0/0.10   | 192.168.10.1 |
| G0/0.20   | 192.168.20.1 |
| G0/0.30   | 192.168.30.1 |
| G0/1      | 192.168.50.1 |

---

# 🔧 STEP 2 — CONFIGURE LEFT SWITCH 

Just verify:

```bash
show vlan brief
show interfaces trunk
```

Make sure:

* PCs in correct VLANs
* trunk is on **Fa0/24**

---

# 🌉 STEP 3 — ROUTER CONFIG (VERY IMPORTANT)

```bash
enable
conf t

interface g0/0
no shutdown

interface g0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0

interface g0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0

interface g0/0.30
encapsulation dot1Q 30
ip address 192.168.30.1 255.255.255.0

interface g0/1
ip address 192.168.50.1 255.255.255.0
no shutdown

end
```

👉 This connects:

* VLANs → Router
* Router → Right switch

---

# 🔌 STEP 4 — RIGHT SWITCH (Switch1)

No VLAN needed (keep simple for now)

Just ensure:

* All ports active
* PCs connected

---

# 🖥️ STEP 5 — CONFIGURE SERVER (VERY IMPORTANT)

Choose **one PC on right side → make it SERVER**

Example (PC3):

```text
IP: 192.168.50.10
Mask: 255.255.255.0
Gateway: 192.168.50.1
DNS: 192.168.50.10
```

---

# 📦 STEP 6 — DHCP (REAL SRE FEATURE)

👉 On router:

```bash
conf t

ip dhcp pool VLAN10
network 192.168.10.0 255.255.255.0
default-router 192.168.10.1
dns-server 192.168.50.10

ip dhcp pool VLAN20
network 192.168.20.0 255.255.255.0
default-router 192.168.20.1

ip dhcp pool VLAN30
network 192.168.30.0 255.255.255.0
default-router 192.168.30.1

end
```

👉 Now set PCs to DHCP

---

# 🌍 STEP 7 — DNS (ON SERVER)

Go to PC3 → Services → DNS

Add:

```plaintext
company.local → 192.168.50.10
```

---

# 🌐 STEP 8 — WEB SERVER

On PC3:

* Turn ON HTTP
* Add message:

```plaintext
Welcome to Company Network
```

---

# 🧪 STEP 9 — TEST (VERY IMPORTANT)

From ANY VLAN PC:

```bash
ping 192.168.50.10
```

Then:

Browser:

```plaintext
http://company.local
```

---

# 🔐 STEP 10 — SSH (REAL SRE TASK)

Router:

```bash
conf t
hostname R1
ip domain-name company.local
username admin secret Cisco123
crypto key generate rsa
1024

line vty 0 4
login local
transport input ssh
end
```

---

# 🔐 TEST SSH

From PC:

```bash
ssh -l admin 192.168.10.1
```

---

# 🔥 STEP 11 — SECURITY (ACL)

Block HR → Server:

```bash
conf t

access-list 100 deny ip 192.168.10.0 0.0.0.255 192.168.50.0 0.0.0.255
access-list 100 permit ip any any

interface g0/0.10
ip access-group 100 in

end
```

---

# 🧪 TEST AGAIN

| Test             | Result |
| ---------------- | ------ |
| HR → Server ping | ❌      |
| IT → Server ping | ✅      |
| DevOps → Server  | ✅      |

---

# 🧠 WHAT YOU JUST BUILT 

You now have:

* Segmented network (VLAN)
* Routing (Router)
* Central services (Server)
* Automation (DHCP)
* Name system (DNS)
* Secure access (SSH)
* Security policy (ACL)

---

# 🔥 THIS IS REAL SRE LEVEL



> “This is exactly how companies work. When something breaks, you don’t know if it’s DHCP, DNS, routing, or firewall. Your job is to find it.”



