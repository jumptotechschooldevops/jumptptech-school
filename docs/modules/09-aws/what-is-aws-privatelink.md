---
title: "What is AWS PrivateLink?"
description: "AWS PrivateLink lets you access AWS services or your own services hosted in another VPC privately —..."
published: 2026-05-07
source: "https://dev.to/jumptotech/what-is-aws-privatelink-2mgo"
tags: []
---

# What is AWS PrivateLink?



**AWS PrivateLink** lets you access AWS services or your own services hosted in another VPC *privately* — traffic never leaves the AWS network, never touches the internet, and the two VPCs don't need to be peered or connected via Transit Gateway.

The core idea: instead of exposing a service publicly or opening up full VPC-to-VPC networking, PrivateLink creates a **one-way, private endpoint** — the consumer VPC gets a private IP in its own subnet that tunnels traffic to the provider service. That's it. No route tables to manage, no CIDR conflicts to worry about.**Diagram 1: How PrivateLink works** — the core mechanism is an Interface Endpoint (an ENI in your subnet) that maps to the provider's service via AWS's internal network.The consumer VPC creates an **Interface Endpoint** — just a private IP (ENI) sitting in its own subnet. DNS resolves the service name to that private IP. Traffic flows through AWS's internal backbone to the provider's Network Load Balancer, then to the actual service. The two VPCs never need to peer, share route tables, or even know each other's CIDR ranges.

**Diagram 2: The three ways PrivateLink is used** in practice.---

## The Three Uses of PrivateLink

**1. Accessing AWS-managed services privately.** Services like S3, SQS, ECR, Secrets Manager, KMS, and 100+ others support PrivateLink. Instead of your EC2 or Lambda hitting `s3.amazonaws.com` over the internet, an Interface Endpoint gives it a private IP inside your subnet. For S3 and DynamoDB specifically, there's a simpler free variant called a Gateway Endpoint — same idea, slightly different implementation.

**2. Consuming a partner SaaS service.** Vendors like Datadog, Splunk, Snowflake, and many others publish themselves as PrivateLink Endpoint Services. You create an Interface Endpoint in your VPC pointing to their service name, and your traffic to them never touches the internet. The vendor's VPC and your VPC never peer — they can't see your network at all, only receive the specific calls you make.

**3. Publishing your own internal service.** You place a Network Load Balancer in front of your service, register it as an Endpoint Service, then whitelist which AWS accounts can connect. Other teams or customers create Interface Endpoints in their own VPCs pointing at yours. This is how internal platform teams build shared services — auth, payments, data APIs — without opening full VPC-to-VPC access.

---

## PrivateLink vs the Alternatives

| | PrivateLink | VPC Peering | Transit Gateway |
|---|---|---|---|
| Traffic path | AWS backbone | AWS backbone | AWS backbone |
| CIDR conflicts | No problem | Breaks everything | No problem |
| Access scope | Single service only | Full VPC-to-VPC | All attached VPCs |
| Direction | One-way (consumer → provider) | Bidirectional | Bidirectional |
| Cross-account | Yes | Yes | Yes |
| Cross-region | Yes (via interface EP) | Yes | Yes (TGW peering) |
| Best for | Exposing a specific service privately | Small number of VPCs needing full access | Large-scale hub-and-spoke networking |

The key insight: PrivateLink is surgical. VPC Peering and Transit Gateway open up *networking* — entire VPCs can talk to each other. PrivateLink exposes only *one service* through a single endpoint. If you just want your app to call an internal payments API without routing everything through a shared network, PrivateLink is exactly the right tool.





## What is AWS Transit Gateway?

**Transit Gateway (TGW)** is a central network hub that connects multiple VPCs, on-premises networks, and AWS accounts together — like a cloud router that everything plugs into.

Think of it this way: without Transit Gateway, if you have 5 VPCs that all need to talk to each other, you'd need a mesh of VPC peering connections. With Transit Gateway, every VPC just connects to *one* hub.**Diagram 1: The problem Transit Gateway solves** — without it, VPCs connecting to each other require a full mesh of peering connections that grows unmanageable fast.The key pain point with VPC peering: it is *non-transitive*. If VPC A peers with VPC B, and VPC B peers with VPC C, VPC A still cannot talk to VPC C. You'd need a direct peering for every pair. With 10 VPCs that's 45 connections to manage. Transit Gateway fixes this entirely — everything connects through one hub.

**Diagram 2: What Transit Gateway connects** — it's not just VPC-to-VPC. It acts as the central router for your entire network.---

## Why You Need Transit Gateway

**1. Scale without the mesh chaos.** VPC peering connections grow as N×(N-1)/2 — 4 VPCs need 6 connections, 10 VPCs need 45. TGW keeps it at N connections regardless.

**2. Transitivity.** VPC peering is not transitive — traffic can't hop through an intermediate VPC. TGW routes traffic across all attached networks as a proper router would.

**3. Centralized on-premises connectivity.** Without TGW, each VPC needs its own VPN tunnel to your data center. With TGW, one VPN attachment serves all VPCs attached to the gateway.

**4. Traffic isolation via route tables.** The TGW has its own route tables. You can define that your Dev VPC can only reach other Dev VPCs and a shared-services VPC, while a security VPC sees everything for traffic inspection. This is impossible with VPC peering alone.

**5. Cross-account and cross-region.** TGW works with AWS Resource Access Manager to share the gateway across multiple accounts. TGW peering connects gateways across regions.

---

## TGW vs VPC Peering — When to Use Which

| Scenario | Use |
|---|---|
| 2–3 VPCs that need to talk | VPC Peering (simpler, cheaper) |
| 4+ VPCs, especially growing | Transit Gateway |
| Cross-account, cross-region networking | Transit Gateway |
| On-premises + multiple VPCs | Transit Gateway |
| Need centralized firewall/inspection | Transit Gateway (route all traffic through security VPC) |
| Just two VPCs, same account | VPC Peering |

The core mental model: **VPC Peering is a direct cable between two VPCs. Transit Gateway is a router that every VPC plugs into.** Once you have more than a handful of VPCs, the router approach wins every time.


Great question — this is where a lot of people get confused because all three keep traffic on the AWS backbone. The real difference is *what problem each one solves*.

Here's a decision framework:**The one question that drives the choice:** what scope of access do you need?---

## The Core Mental Model

Think of it in terms of **scope of access**:

**PrivateLink** = expose *one service* to another VPC. The consumer gets a single private IP endpoint — nothing else. They cannot reach any other resource in your VPC. This is surgical, zero-trust access. Use it when two VPCs don't need to talk to each other broadly — they just need one service to be reachable.

**VPC Peering** = full network access between exactly *two VPCs*. Both VPCs can reach any resource in the other (subject to security groups and NACLs). Simple to set up, no cost for the connection itself, but does not scale — every new VPC pair needs its own peering, and it's non-transitive.

**Transit Gateway** = full network access between *many VPCs, accounts, and on-premises networks*, all routed through one hub. More complex and costs money per attachment + data processed, but scales linearly and supports centralized routing policies.

---

## Real-World Scenarios

**Scenario 1 — Startup with 2 VPCs (prod + dev)**
Dev team occasionally needs to pull from a shared database in prod. → Use **VPC Peering**. Two VPCs, simple, done in minutes.

**Scenario 2 — Company with 8 VPCs across 3 AWS accounts**
Networking team needs all VPCs to reach a shared DNS resolver and a centralized logging service, plus a VPN back to the data center. → Use **Transit Gateway**. One VPN connection shared by all, one hub to manage routing.

**Scenario 3 — Platform team building an internal payments API**
Other teams' VPCs need to call the payments API — but the platform team doesn't want those VPCs to have any other access into their network. → Use **PrivateLink**. Expose only the API endpoint. Consumer VPCs get a single private IP, nothing more.

**Scenario 4 — VPC Peering is impossible (overlapping CIDRs)**
Two VPCs both use `10.0.0.0/16` — peering is blocked. But one VPC needs to call a service in the other. → Use **PrivateLink**. CIDR conflicts don't matter since there's no route table overlap.

**Scenario 5 — Lambda in a private VPC needs to write to S3**
Lambda is in a VPC with no internet access. You need to reach S3 without adding a NAT Gateway. → Use **PrivateLink** (Gateway Endpoint for S3 — free). Traffic stays entirely within AWS.

---

## Quick Reference

| | PrivateLink | VPC Peering | Transit Gateway |
|---|---|---|---|
| Access scope | Single service | Whole VPC | Whole network |
| CIDR conflicts | No issue | Breaks it | No issue |
| Scale | Unlimited consumers | Up to ~125 peers | Thousands of VPCs |
| On-premises | No | No | Yes (VPN/DX) |
| Cost | Per endpoint + data | Data transfer only | Per attachment + data |
| Direction | One-way | Bidirectional | Bidirectional |
| Complexity | Low | Very low | Medium-high |

The pattern most large companies end up with: **Transit Gateway as the backbone** for VPC-to-VPC and on-premises connectivity, with **PrivateLink layered on top** for exposing specific internal services securely to teams or customers who shouldn't have broad network access.
