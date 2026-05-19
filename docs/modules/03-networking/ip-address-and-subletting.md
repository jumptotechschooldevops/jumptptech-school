---
title: "IP address and subletting"
description: "🧠 PART 1 — What is an IP Address?   An IP address is a unique identifier for a device in a..."
published: 2026-04-15
source: "https://dev.to/jumptotech/ip-address-and-subletting-44cb"
tags: []
---

# IP address and subletting


# 🧠 PART 1 — What is an IP Address?

An IP address is a unique identifier for a device in a network.

Example:

```text
192.168.1.10
```

Every IP has **2 parts**:

```text
[ NETWORK PART ] [ HOST PART ]
```

---

# 🔍 PART 2 — Network vs Host (MOST IMPORTANT)

Example:

```text
IP: 192.168.1.10
Mask: 255.255.255.0 (/24)
```

👉 This means:

```text
Network: 192.168.1
Host: .10
```

---

## 🧠 Rule

Subnet mask decides the split.

---

# 📊 PART 3 — Subnet Mask Explained (Power Concept)

Example:

```text
255.255.255.0
```

Binary:

```text
11111111.11111111.11111111.00000000
```

👉 Count 1s:

```text
24 bits → NETWORK
8 bits → HOST
```

---

# 🔥 POWER RULE (THIS IS YOUR “POWER 8”)

👉 Number of hosts =

```text
2^(host bits) - 2
```

---

## Example:

For /24:

```text
Host bits = 8

2^8 = 256
256 - 2 = 254 usable IPs
```

---

## 💡 WHY -2?

Because:

* 1 = Network address
* 1 = Broadcast address

---

# 📊 QUICK TABLE (VERY IMPORTANT FOR TEACHING)

| Subnet | Host Bits | Total IPs | Usable |
| ------ | --------- | --------- | ------ |
| /24    | 8         | 256       | 254    |
| /25    | 7         | 128       | 126    |
| /26    | 6         | 64        | 62     |
| /27    | 5         | 32        | 30     |
| /28    | 4         | 16        | 14     |

---

# 🧠 PART 4 — What is Subnetting?

Subnetting = dividing one network into smaller networks.

Example:

```text
192.168.1.0/24
```

Split into 2:

```text
192.168.1.0/25
192.168.1.128/25
```

---

# 🔥 PART 5 — HOW SPLITTING WORKS

## Example: /24 → /25

```text
Borrow 1 bit
```

So:

```text
2^1 = 2 subnets
```

---

## Result:

| Subnet           | Range   |
| ---------------- | ------- |
| 192.168.1.0/25   | 1–126   |
| 192.168.1.128/25 | 129–254 |

---

# 🧪 PART 6 — LAB (VERY IMPORTANT)

## 🎯 Goal:

Understand:

* network vs host
* subnetting
* IP allocation

---

# 🔧 LAB SETUP

## Use ONE network:

```text
192.168.1.0/24
```

---

# STEP 1 — Split into 2 subnets

```text
Subnet mask → /25
```

Now you have:

### Subnet 1:

```text
Network: 192.168.1.0
Range: 192.168.1.1 – 192.168.1.126
Gateway: 192.168.1.126 or .1
```

### Subnet 2:

```text
Network: 192.168.1.128
Range: 192.168.1.129 – 192.168.1.254
Gateway: 192.168.1.254 or .129
```

---

# STEP 2 — Build in Packet Tracer

### Devices:

* 1 Router
* 2 Switches
* 4 PCs (2 per subnet)

---

# STEP 3 — Assign IPs

## Subnet 1:

```text
PC1 → 192.168.1.10
PC2 → 192.168.1.20
Gateway → 192.168.1.1
Mask → 255.255.255.128
```

---

## Subnet 2:

```text
PC3 → 192.168.1.130
PC4 → 192.168.1.140
Gateway → 192.168.1.129
Mask → 255.255.255.128
```

---

# STEP 4 — Configure Router

```bash
enable
configure terminal

interface g0/0
ip address 192.168.1.1 255.255.255.128
no shutdown

interface g0/1
ip address 192.168.1.129 255.255.255.128
no shutdown
end
```

---

# STEP 5 — TEST

## Same subnet:

```bash
ping 192.168.1.20
```

✔ works

---

## Different subnet:

```bash
ping 192.168.1.130
```

✔ works via router

---

# 🧠 PART 7 — EXPLAIN LIKE A PRO

👉 You can say:

“An IP address is divided into network and host portions based on the subnet mask. Subnetting allows us to split a large network into smaller networks. For example, a /24 network can be divided into two /25 subnets by borrowing one bit. Each subnet has its own range of usable IP addresses. This improves organization, scalability, and security.”

---

# 🔥 BONUS — VISUAL EXPLANATION (VERY POWERFUL)

Think:

```text
/24 = one big apartment building
/25 = two floors
/26 = four floors
```

Each split:

```text
2^n networks
```



