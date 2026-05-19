---
title: "Networking Foundations for Cloud Engineers"
description: "VPC, Subnets, Internet Gateway, Route Tables, NAT               1. Why Do We Need a Virtual..."
published: 2026-03-01
source: "https://dev.to/jumptotech/networking-foundations-for-cloud-engineers-i1o"
tags: []
---

# Networking Foundations for Cloud Engineers





## VPC, Subnets, Internet Gateway, Route Tables, NAT



---

# 1. Why Do We Need a Virtual Network?

In traditional on-premises data centers, companies build:

* Physical routers
* Switches
* Firewalls
* Cables
* Network segmentation

In cloud, we don’t manage cables.
But we still need:

* IP ranges
* Network isolation
* Controlled internet access
* Private communication between servers

This is why cloud providers give us a **virtual network**.

In AWS, this is called:

Virtual Private Cloud (VPC)

In Azure, this is called:

Virtual Network (VNet)

They solve the same problem.

---

# 2. What Is a VPC? (AWS Concept)

![Image](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/integrate-third-party-services/images/p2_vpc-peering.png)

![Image](https://docs.aws.amazon.com/images/vpc/latest/userguide/images/vpc-example-private-subnets.png)

![Image](https://d2908q01vomqb2.cloudfront.net/da4b9237bacccdf19c0760cab7aec4a8359010b0/2020/03/19/Slide1.png)

![Image](https://docs.aws.amazon.com/images/vpc/latest/userguide/images/outpost-intra-vpc-connection.png)

A VPC (Virtual Private Cloud) is a logically isolated virtual network inside AWS.

Think of it as:

“Your own private data center inside AWS.”

When you create a VPC, you define:

* An IP address range (CIDR block)
* Subnets
* Routing rules
* Internet connectivity
* Security rules

Example:

You create a VPC with:

10.0.0.0/16

That means your network can contain:

65,536 private IP addresses.

No other AWS customer can use your internal IP space.

It is isolated.

---

# 3. Subnets — Dividing the Network

A VPC is large.
You divide it into smaller networks called **subnets**.

Example:

VPC: 10.0.0.0/16

You create:

Public subnet: 10.0.1.0/24
Private subnet: 10.0.2.0/24

Each /24 subnet contains 256 IP addresses.

Why divide?

Because in real architecture:

* Web servers must be reachable from internet
* Databases must NOT be reachable from internet

So we separate workloads.

---

## Public Subnet

A subnet becomes “public” when:

Its route table sends internet traffic (0.0.0.0/0) to an Internet Gateway.

Public subnet is used for:

* Web servers
* Bastion hosts
* Load balancers

---

## Private Subnet

A subnet is private when:

It does NOT have route to Internet Gateway.

Used for:

* Databases
* Internal services
* Backend APIs

Private subnet improves security.

---

# 4. Internet Gateway (AWS)

Internet Gateway (IGW) is a component attached to a VPC.

It allows:

Traffic between VPC and the public internet.

But just attaching IGW is not enough.

You must update route table to use it.

Without route configuration, internet does not work.

---

# 5. Route Tables — The Traffic Map

A route table determines:

Where traffic goes.

It contains rules like:

Destination → Target

Example:

0.0.0.0/0 → Internet Gateway

This means:

“All traffic to internet goes through IGW.”

Each subnet must be associated with a route table.

You can have:

* Public route table
* Private route table

Example:

Public route table:
0.0.0.0/0 → IGW

Private route table:
0.0.0.0/0 → NAT Gateway

This determines internet behavior.

---

# 6. NAT Gateway — Outbound Internet for Private Subnet

NAT stands for:

Network Address Translation.

Problem:

Private subnet servers need internet access to:

* Download updates
* Install packages
* Access APIs

But we do NOT want inbound internet traffic to them.

Solution:

NAT Gateway.

NAT allows:

Private servers → Internet (outbound only)

But blocks:

Internet → Private servers (inbound)

How it works:

Private server sends traffic to NAT.
NAT sends traffic to internet.
Internet responds to NAT.
NAT sends response back to private server.

Internet never sees private server directly.

This is extremely important for secure architecture.

---

# 7. Full AWS Architecture Example

Internet
↓
Internet Gateway
↓
Public Subnet (Web Server)
↓
Private Subnet (App / DB)
↓
NAT Gateway (for outbound access)

This is standard 2-tier or 3-tier architecture.

Every serious AWS production system uses this pattern.

---

# 8. Now Let’s Translate to Azure

Azure networking works differently in implementation, but conceptually similar.

In Azure:

VPC = VNet (Virtual Network)

Subnet = Subnet

Internet Gateway = No separate object

Route Table = User Defined Route (UDR)

NAT Gateway = Azure NAT Gateway

Security Group = Network Security Group (NSG)

---

# 9. Key Differences Between AWS and Azure Networking

## Difference 1: No Internet Gateway Object in Azure

In AWS:
You must attach IGW.

In Azure:
If a VM has Public IP assigned,
it can access internet automatically.

There is no separate IGW resource.

Internet routing is built-in.

---

## Difference 2: Public vs Private Definition

In AWS:
Public subnet = route to IGW

In Azure:
Public subnet = VM with Public IP

This is a conceptual shift.

---

## Difference 3: Routing

In AWS:
You must configure route tables explicitly.

In Azure:
Default system routes already exist.

You only create custom route tables (UDR) when needed.

---

## Difference 4: NAT Gateway

In AWS:
NAT Gateway is placed in public subnet.

In Azure:
NAT Gateway attaches directly to subnet.

Much simpler.

---

# 10. Azure Equivalent Architecture

Internet
↓
Public IP
↓
Public Subnet (Web VM)
↓
Private Subnet (App VM)
↓
Azure NAT Gateway

Very similar logically.

---

# 11. Why This Architecture Is Important for DevOps

As a DevOps engineer, you must understand:

* Network segmentation
* Security boundaries
* Controlled internet access
* Traffic flow
* Least privilege networking

Networking is foundation of:

* Kubernetes clusters
* Load balancers
* Microservices
* Hybrid cloud
* VPN / ExpressRoute

If you do not understand routing and NAT, you cannot troubleshoot production issues.

---

# 12. Mental Model Summary

VPC/VNet = Your virtual data center
Subnet = Floor inside data center
Route Table = Traffic rulebook
Internet Gateway = Door to internet
NAT = Security guard allowing outbound only

If you understand these five pieces deeply, you understand cloud networking fundamentals.




