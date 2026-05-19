---
title: "packet tracer lab: subletting"
description: "1. What is a subnet?   A subnet, or subnetwork, is a smaller network created from a larger..."
published: 2026-04-14
source: "https://dev.to/jumptotech/packet-tracer-lab-subletting-1k42"
tags: []
---

# packet tracer lab: subletting



# 1. What is a subnet?

A subnet, or subnetwork, is a smaller network created from a larger IP network. Instead of putting every device into one big network, we divide the network into smaller logical groups.

For example, instead of placing all devices in one network like this:

```text
192.168.1.0/24
```

we can separate devices into different networks like this:

```text
192.168.1.0/24
192.168.2.0/24
```

Each of these is a separate subnet.

A subnet is a logical boundary. Devices inside the same subnet can communicate directly. Devices in different subnets cannot communicate directly unless a router or Layer 3 device routes traffic between them.

That is the key idea:

* Same subnet = direct communication
* Different subnet = router required

---

# 2. What does “segregation by subnet” mean?

Segregation means separating devices into different network groups based on purpose, role, department, security level, or location.

For example, a company may separate:

* HR department
* Finance department
* Developers
* Servers
* Guests
* Printers
* Security cameras

Instead of allowing all of them to live in one big flat network, the company creates different subnets.

Example:

```text
192.168.10.0/24  → HR
192.168.20.0/24  → Finance
192.168.30.0/24  → Developers
192.168.40.0/24  → Servers
192.168.50.0/24  → Guest Wi-Fi
```

This is network segregation.

---

# 3. Why do companies separate subnets?

Companies separate subnets because one large network creates many problems.

## Security

If every device is in one subnet, every device is closer to every other device. If one machine is compromised, an attacker can move more easily across the network.

When networks are separated into subnets, companies can control communication between them using routers, ACLs, firewalls, and security policies.

Example:

* Guest Wi-Fi should not access company servers
* Finance should not be reachable by everyone
* Test environment should not freely reach production

## Performance

In one large subnet, broadcast traffic increases. More devices share the same broadcast domain. That can slow down the network.

Subnetting reduces unnecessary broadcast traffic.

## Easier management

It is easier to identify devices and departments when each subnet has a purpose.

Example:

* 192.168.10.x = HR
* 192.168.20.x = Finance
* 192.168.30.x = IT

This makes troubleshooting easier.

## Better control

Companies can decide:

* which subnet can talk to which subnet
* which ports are allowed
* which applications are allowed
* which users are isolated

## Scalability

As a company grows, one big network becomes messy. Subnetting helps the network grow in a clean and organized way.

---

# 4. Real-world company example

Imagine a company has:

* HR users
* Finance users
* Developers
* Application servers
* Database servers
* Guest Wi-Fi

If all devices are in one network, then:

* guests might reach internal systems
* developers may access finance systems directly
* malware can spread more easily
* troubleshooting becomes harder

A better design is:

```text
Subnet 1: 192.168.1.0/24   → Office Users
Subnet 2: 192.168.2.0/24   → Servers
```

Then the router controls traffic between them.

That is the idea you are building in Packet Tracer.

---

# 5. Important subnet terms

## Network address

This identifies the subnet itself.

Example:

```text
192.168.1.0/24
```

`192.168.1.0` is the network address.

## Host address

These are usable device IP addresses inside the subnet.

Example:

```text
192.168.1.1
192.168.1.2
192.168.1.100
```

## Broadcast address

This is the last address in the subnet, used for broadcast traffic.

For `192.168.1.0/24`, broadcast is:

```text
192.168.1.255
```

## Subnet mask

The subnet mask tells us which part of the IP is the network portion and which part is the host portion.

Example:

```text
255.255.255.0
```

This means `/24`.

## Default gateway

This is the router interface IP used to leave the local subnet.

Example:

```text
192.168.1.254
```

If a host wants to reach another subnet, it sends traffic to the default gateway.

---

# 6. Lab objective

In this lab, you will build two separate subnets and observe:

* devices in each subnet
* routing between subnets
* why the router is required
* how segregation improves control
* how ACLs can block one subnet from reaching another

---

# 7. Lab topology

## Subnet 1

```text
Network: 192.168.1.0/24
Gateway: 192.168.1.254
Devices:
PC0 → 192.168.1.1
PC1 → 192.168.1.2
PC2 → 192.168.1.3
```

## Subnet 2

```text
Network: 192.168.2.0/24
Gateway: 192.168.2.254
Devices:
Laptop0 → 192.168.2.1
Laptop1 → 192.168.2.2
Laptop2 → 192.168.2.3
```

## Router interfaces

```text
GigabitEthernet0/0 → 192.168.1.254
GigabitEthernet0/1 → 192.168.2.254
```

---

# 8. Devices needed

Use these in Packet Tracer:

* 1 Router (1941)
* 2 Switches
* 3 PCs
* 3 Laptops
* Copper straight-through cables

---

# 9. Build the topology

## Step 1: Add devices

Place:

* one router in the middle
* one switch for subnet 1
* one switch for subnet 2
* three PCs on the left side
* three laptops on the right side

## Step 2: Cable connections

Connect:

* PC0 to Switch1
* PC1 to Switch1
* PC2 to Switch1
* Switch1 to Router Gig0/0

Connect:

* Laptop0 to Switch2
* Laptop1 to Switch2
* Laptop2 to Switch2
* Switch2 to Router Gig0/1

Use straight-through cables or automatic cable selection.

---

# 10. Configure subnet 1 hosts

On each PC, go to Desktop → IP Configuration.

## PC0

```text
IP Address: 192.168.1.1
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.1.254
```

## PC1

```text
IP Address: 192.168.1.2
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.1.254
```

## PC2

```text
IP Address: 192.168.1.3
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.1.254
```

---

# 11. Configure subnet 2 hosts

## Laptop0

```text
IP Address: 192.168.2.1
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.2.254
```

## Laptop1

```text
IP Address: 192.168.2.2
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.2.254
```

## Laptop2

```text
IP Address: 192.168.2.3
Subnet Mask: 255.255.255.0
Default Gateway: 192.168.2.254
```

---

# 12. Configure the router

Open router CLI and type:

```bash
enable
configure terminal
interface gigabitEthernet0/0
ip address 192.168.1.254 255.255.255.0
no shutdown
exit
interface gigabitEthernet0/1
ip address 192.168.2.254 255.255.255.0
no shutdown
end
```

---

# 13. Verification lab

## Test 1: Same subnet communication

From PC0, ping PC1:

```bash
ping 192.168.1.2
```

This should succeed.

Why? Because both devices are in the same subnet and can communicate directly through the switch.

---

## Test 2: Across subnets

From PC0, ping Laptop0:

```bash
ping 192.168.2.1
```

This should also succeed if the router is configured correctly.

Why? Because the router connects both subnets and forwards traffic between them.

---

# 14. Explain what is happening during the ping

When PC0 tries to reach 192.168.2.1, it checks the destination.

PC0 sees that 192.168.2.1 is not in its own subnet, because PC0 belongs to 192.168.1.0/24.

So PC0 does not send traffic directly to Laptop0. Instead, it sends traffic to its default gateway:

```text
192.168.1.254
```

That is the router interface.

The router receives the packet, checks its routing information, and forwards the packet to the second subnet through interface Gig0/1.

That is why default gateway is so important.

---

# 15. Show the importance of segregation

Now you can explain the design like this:

“In this lab, I created two separate subnets. Devices in subnet 1 use the 192.168.1.0/24 range. Devices in subnet 2 use the 192.168.2.0/24 range. The separation gives us better security, control, and organization. Instead of allowing every device to exist in one flat network, we created logical boundaries. The router provides controlled communication between these boundaries.”

That is a strong explanation.

---

# 16. Security control lab with ACL

Now show why segregation is powerful.

Without segregation, all devices are in one flat network and it is harder to control communication.

With separate subnets, the router can control traffic.

## Goal

Block subnet 1 from reaching subnet 2.

In router CLI:

```bash
enable
configure terminal
access-list 100 deny ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255
access-list 100 permit ip any any
interface gigabitEthernet0/0
ip access-group 100 in
end
```

---

# 17. Test security policy

From PC0:

```bash
ping 192.168.2.1
```

This should fail.

Why? Because the router is now blocking traffic from subnet 1 to subnet 2.

That is the real value of subnet segregation:
it allows traffic control between groups.






# 21. Interview-ready answer

Here is a polished answer:

“A subnet is a logical subdivision of an IP network. It groups devices into smaller broadcast domains. Companies use subnetting to improve security, reduce broadcast traffic, organize departments or services, and control communication between groups. In my lab, I created two subnets, configured router interfaces as gateways for each subnet, verified inter-subnet routing, and then applied an ACL to block one subnet from accessing the other. That demonstrated why segmentation is important in real environments.”

---

# 22. Simple real-life analogy

You can explain it like this:

“A large company building has many departments. If everyone works in one giant open room, it becomes noisy, unorganized, and insecure. Subnetting is like giving each department its own room. The router is like the controlled hallway between rooms. The ACL is like a security guard deciding who can pass.”

That makes the idea very easy to remember.

---

# 23. Short conclusion 

Subnetting is not only about IP addresses. It is about design, control, and security.

When a company creates subnets, it is organizing the network in a smarter way. It separates traffic, reduces unnecessary communication, improves performance, and makes policy enforcement possible. That is why subnetting is so important in enterprise networking, cloud networking, and DevOps environments.


