---
title: "SUBNET MASK (STRUCTURED + WITH CODE EXAMPLES), how a computer communicates in a network"
description: "How a computer communicates locally and remotely, what information is required, and what networking..."
published: 2026-04-16
source: "https://dev.to/jumptotech/subnet-mask-structured-with-code-examples-50lj"
tags: []
---

# SUBNET MASK (STRUCTURED + WITH CODE EXAMPLES), how a computer communicates in a network






 How a computer communicates locally and remotely, what information is required, and what networking devices are involved in these processes.

First, let us understand what information a computer must have in order to function properly in a TCP/IP network.

Every computer needs four key pieces of information:

* MAC address
* IP address
* Subnet mask
* Default gateway

The MAC address is the physical address of the device. It is a 48-bit hexadecimal number and uniquely identifies a network interface on the local network.

The IP address is the logical address used to identify the device on a network. This is what allows devices to communicate across networks.

The subnet mask is used to determine whether another device is in the same network or a different network. This is one of the most important concepts in networking.

The default gateway is the IP address of the router that is responsible for forwarding traffic outside the local network.

Now the question is: when does a computer use each of these?

To understand this, let us look at a scenario.

We have one computer, which we will call Computer A. Computer A wants to communicate with two other devices:

* Computer B (inside the same network)
* Computer C (outside the network, possibly on the internet)

The first thing Computer A does is use the subnet mask.

The subnet mask helps Computer A answer a very important question:

Is the destination in the same network or a different network?

If the answer is yes, meaning the destination is in the same network, then the communication is local.

If the answer is no, meaning the destination is in a different network, then the communication is remote.

Let us first look at local communication.

When Computer A determines that Computer B is in the same network, it does not use the router. Instead, it communicates directly through a switch.

However, to communicate, Computer A needs the MAC address of Computer B.

So the process is as follows:

First, Computer A sends an ARP request. ARP stands for Address Resolution Protocol. It is used to find the MAC address of a device using its IP address.

The ARP request is basically asking:

“Who has this IP address?”

Then Computer B responds with its MAC address.

After that, Computer A uses this MAC address to create a frame and sends data directly to Computer B.

This communication happens through a switch, which is a Layer 2 device.

In this situation, the default gateway is not used at all.

Now let us look at remote communication.

When Computer A determines that Computer C is not in the same network, it cannot send data directly.

Instead, it must send the data to the default gateway.

The default gateway is a router, which is a Layer 3 device.

The process is similar at the beginning.

Computer A uses ARP again, but this time it is not asking for Computer C’s MAC address.

Instead, it asks:

“What is the MAC address of my default gateway?”

The router replies with its MAC address.

Now Computer A sends the packet to the router.

The router then takes that packet and forwards it toward the destination network, eventually reaching Computer C.

So the key difference is:

In local communication, MAC addresses are used and the switch handles the communication.

In remote communication, IP addresses are used and the router handles the communication.

The subnet mask plays a critical role because it determines whether the communication is local or remote.

The default gateway is only used when the destination is outside the local network.

ARP is used in both cases to resolve IP addresses into MAC addresses.

Let us summarize everything.

A computer first uses the subnet mask to determine whether the destination is local or remote.

If the destination is local, the computer uses ARP to find the MAC address of the destination and sends the data through a switch.

If the destination is remote, the computer uses ARP to find the MAC address of the default gateway, sends the data to the router, and the router forwards the packet to the destination.

This is how communication works in a TCP/IP network.

---

# 💻 COMMANDS (ONLY CODE)

## Check IP configuration

```bash
ipconfig /all
```

---

## Test local communication

```bash
ping 192.168.1.2
```

---

## Test remote communication

```bash
ping 192.168.2.1
```

---

## Check ARP table

```bash
arp -a
```

---

## Router configuration (interfaces)

```bash
enable
configure terminal

interface gigabitEthernet0/0
ip address 192.168.1.254 255.255.255.0
no shutdown

interface gigabitEthernet0/1
ip address 192.168.2.254 255.255.255.0
no shutdown

end
```

---

## Verify router interfaces

```bash
show ip interface brief
```



A computer uses the subnet mask to determine whether communication is local or remote. For local communication, it uses ARP to resolve MAC addresses and communicates through a switch. For remote communication, it sends traffic to the default gateway, and the router forwards the packet using IP routing.




# 2. What is an IP Address?

An IP address is an identifier for a computer or device on a network. Every device has to have an IP address for communication purposes.

And to be specific, I'm talking about an IPv4 address.

An IPv4 address is a 32-bit numeric address, written as four numbers, separated by periods. Each group of numbers that are separated by periods is called an octet. The number range in each octet is from 0 - 255.

---

# 3. Network and Host Parts

An IP address consists of two parts. The first part is the network address and the second part is the host address.

The network address or network ID is a number that's assigned to a network. So every network will have a unique address.

The host address or host ID is what's assigned to hosts within that network such as computers, servers, tablets, routers, and so on. So every host will have a unique host address.

---

# 4. Subnet Mask

Now the way to tell which portion of the IP address is the network or the host, is where the subnet mask comes in.

A subnet mask is a number that resembles an IP address. And it reveals how many bits in the IP address are used for the network by masking the network portion of the IP address.

---

# 5. Binary (How Computers Understand)

Now in the world of computers and networks, IP addresses and subnet masks in this decimal format here are meaningless. And this is because computers and networks don't read them in this format and that's because they only understand numbers in a binary format, which are 1s and 0s. And these are called bits.

So the binary number for this IP address is this number here. And the binary number for this subnet mask is this number. And these are the numbers that computers and networks only understand.

---

# 6. How to Convert to Binary

So the next question is, how do we get these binary numbers from this IP address and this subnet mask?

So here we have an 8 bit octet chart. The bits in each octet are represented by a number. So starting from the right, the first bit has a value of 1 and then the number doubles with each step. So there's 2 then 4, 8, and so on, all the way up to 128.

Each bit in the octet can be either a 1 or a 0. If the number is a 1 then the number that it represents counts. If the number is a 0 then the number that it represents does not count.

So by manipulating the 1s and 0s in the octet you can come up with a number range from 0 - 255.

---

# 7. Example: Binary Conversion

So for example, the first octet in this IP address is 192.

```plaintext
128 + 64 = 192

192 = 11000000
```

---

Next octet is 168:

```plaintext
128 + 32 + 8 = 168

168 = 10101000
```

---

Next octet is 1:

```plaintext
1 = 00000001
```

---

Last octet is 0:

```plaintext
0 = 00000000
```

---

Final binary IP:

```plaintext
192.168.1.0 = 11000000.10101000.00000001.00000000
```

---

# 8. Subnet Mask in Binary

Now the subnet mask binary conversion is exactly the same way.

So in this subnet mask the first 3 octets are 255. So if we were to look at this subnet mask in binary form, the first 3 octets would be all 1s because when you count all the numbers in an octet it will equal 255.

```plaintext
255 = 11111111
0   = 00000000

255.255.255.0 =
11111111.11111111.11111111.00000000
```

---

# 9. How Subnet Mask Defines Network and Host

So here we have our IP address and subnet mask in binary form lined up together.

So the way to tell which portion of this IP address is the network part, is when the subnet mask binary digit is a 1 it will indicate the position of the IP address that defines the network.

So we'll cross out all the digits in the IP address that line up with the 1s in the subnet mask.

So the 1s in the subnet mask indicate the network address and the 0s indicate the host addresses.

---

# 10. Example: Network vs Host

```plaintext
IP:   192.168.1.10
Mask: 255.255.255.0

Network: 192.168.1
Host:                10
```

---

# 11. Advanced Mask Example (224)

Now what if the subnet mask was 224?

```plaintext
224 = 11100000
```

So:

```plaintext
Mask: 255.255.224.0

11111111.11111111.11100000.00000000
```

This means:

* first 2 octets + part of 3rd = network
* rest = host

---

# 12. Why Network + Host Exists

Now the reason for this is manageability. It's for breaking down a large network into smaller networks or subnetworks, which is known as subnetting.

---

# 13. Problem Without Subnetting

If all computers are in one network:

* broadcast goes to everyone
* network becomes slow
* hard to manage

---

# 14. Routers

Networks are broken down and physically separated by using routers.

Broadcasts do not go past routers.

---

# 15. Subnetting

Subnetting is done by changing the subnet mask by borrowing some of the bits that were designated for hosts.

---

# 16. Borrowing Bits (IMPORTANT)

Original:

```plaintext
/24 → 255.255.255.0
Hosts = 254
Subnets = 1
```

---

Borrow 1 bit:

```plaintext
/25 → 255.255.255.128

Subnets = 2
Hosts per subnet = 126
```

---

Borrow 2 bits:

```plaintext
/26 → 255.255.255.192

Subnets = 4
Hosts = 62
```

---

Borrow 3 bits:

```plaintext
/27 → 255.255.255.224

Subnets = 8
Hosts = 30
```

---

Borrow 4 bits:

```plaintext
/28 → 255.255.255.240

Subnets = 16
Hosts = 14
```

---

Borrow 5 bits:

```plaintext
/29 → 255.255.255.248

Subnets = 32
Hosts = 6
```

---

Borrow 6 bits:

```plaintext
/30 → 255.255.255.252

Subnets = 64
Hosts = 2
```

---

Borrow 7 bits:

```plaintext
/31 → 255.255.255.254

Subnets = 128
Hosts = 0 usable
```

---

# 17. Important Rule

The more bits the network portion borrows from the host portion:

* number of subnets doubles
* number of hosts halves

---

# 18. Example: Business Case

We need 3 networks.

```plaintext
We borrow 2 bits → /26

255.255.255.192
```

This gives:

```plaintext
4 subnets (enough for 3)
```

---

# 19. Subnet Ranges Example

```plaintext
Step = 256 - 192 = 64

Subnets:
0
64
128
192
```

---

Ranges:

```plaintext
0–63
64–127
128–191
192–255
```

---

# 20. CIDR

CIDR = slash notation

```plaintext
/24 = 255.255.255.0
/25 = 255.255.255.128
/26 = 255.255.255.192
```

---

# 21. Final Summary

* IP = identifier
* Bits = 0 and 1
* Subnet mask = divides network and host
* 1 = network, 0 = host
* Subnetting = splitting networks
* Borrow bits → more networks, fewer hosts


