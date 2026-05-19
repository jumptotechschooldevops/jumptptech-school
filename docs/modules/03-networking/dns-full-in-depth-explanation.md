---
title: "DNS — full in-depth explanation"
description: "When we say DNS, we mean Domain Name System.  At the simplest level, DNS is the system that helps..."
published: 2026-04-22
source: "https://dev.to/jumptotech/dns-full-in-depth-explanation-m2c"
tags: []
---

# DNS — full in-depth explanation



 

When we say **DNS**, we mean **Domain Name System**.

At the simplest level, DNS is the system that helps computers find each other by name.

Humans prefer names. Computers communicate using IP addresses. DNS is the bridge between those two worlds.

For example, a human wants to type:

`google.com`

But the network does not really work with the word `google.com`. The network needs an IP address, something like:

`142.250.x.x`

So DNS translates the human-friendly name into the machine-usable IP address.

That is the first and most important idea.

---

# Why DNS exists

Imagine a world without DNS.

Every website, every application, every database, every API, every internal server would have to be accessed by IP address only.

Instead of saying:

* app.company.com
* db.company.com
* api.company.com

you would need to remember:

* 10.1.2.15
* 10.1.2.20
* 10.1.2.30

That becomes a disaster very quickly.

People do not remember IP addresses well. Also, IP addresses can change. A server may move to another machine, a cloud instance may be recreated, a load balancer may be replaced, an application may be migrated. If users had to remember the IP, every change would break everyone.

DNS solves that.

With DNS, the name stays the same and the IP behind it can change.

That means DNS gives us:

* easier access
* flexibility
* abstraction
* scalability
* easier maintenance

This is why DNS is not just a convenience. It is a core part of modern infrastructure.

---

# The main idea behind DNS

DNS is often described as “the phonebook of the internet,” and that analogy is helpful, but let’s make it more practical.

Suppose you want to call a person. You look up their name in your contacts, and your phone finds the number. You don’t memorize every phone number.

DNS does the same thing for systems.

A user types a name. The computer asks DNS, “What IP address belongs to this name?” DNS replies with the answer. Then the computer connects to that IP.

So DNS is really a **directory system**.

But it is not just one single server. It is a whole distributed system with hierarchy, delegation, caching, and many record types.

---

# What happens when a user types a name

Let’s say a user opens a browser and types:

`app.company.com`

A lot happens behind the scenes.

First, the computer needs to find the IP address for that name. It checks whether it already knows the answer. Maybe it is in local cache. Maybe the OS remembers it. Maybe the browser remembers it.

If the answer is not already cached, the computer asks a DNS server. Usually this DNS server is one the machine learned from DHCP or one configured manually.

That DNS server will either already know the answer, or it will go find the answer through the DNS hierarchy.

Once the IP is found, the browser can send traffic to that IP.

This means the application flow often starts with DNS.

Before HTTP, before SSH, before API calls, often DNS happens first.

That is why when DNS breaks, users often say, “The app is down,” even though the app server itself may be healthy. The problem is that the client cannot find it.

---

# DNS is not just for websites

people often think DNS is only for websites on the internet, but that is too narrow.

DNS is used for:

* websites
* internal company applications
* APIs
* databases
* email systems
* Active Directory
* Kubernetes service discovery
* cloud load balancers
* monitoring endpoints
* SSH targets
* VPN services
* many service-to-service communications

In real infrastructure, DNS is everywhere.

For example:

* a developer may connect to `git.company.com`
* an app may call `api.internal.company.local`
* a database may be known as `db.prod.internal`
* Kubernetes may resolve `service.namespace.svc.cluster.local`

So if you want to become professional DevOps engineers or SREs, they must understand that DNS is not “just a web thing.” It is foundational service discovery.

---

# DNS in  Packet Tracer lab

In Packet Tracer, DNS is simplified, but the concept is still correct.

You have a server. On that server, you can turn on DNS service. Then you manually create records like:

* `app.local -> 192.168.50.10`
* `server.local -> 192.168.50.10`

When a client PC learns that DNS server’s IP through DHCP, it can ask the server to resolve those names.

So Packet Tracer helps  see the basic idea:

1. client gets DNS server address
2. DNS server has records
3. client asks for name resolution
4. DNS server replies with IP
5. client uses IP to connect

That is a simplified but accurate  model.

---

# Why DHCP and DNS are connected

This is very important.

DNS and DHCP are different services, but in real networks they work together closely.

DHCP assigns network settings automatically to clients. Those settings usually include:

* IP address
* subnet mask
* default gateway
* DNS server

That means DHCP tells the client not only what its own IP is, but also where to send DNS queries.

So DHCP helps clients find DNS.

If DHCP is broken, many clients may not know which DNS server to use.

If DNS is broken, clients may have IP connectivity but still fail to reach services by name.

That is why in troubleshooting, SREs often separate the problem:

* Is this a DHCP issue?
* Is this a DNS issue?
* Is this a routing issue?
* Is this an application issue?

---

# DNS is a distributed system

DNS is not one giant central database with every answer in one place.

It is distributed.

That means responsibility is divided.

For example:

* root servers know where top-level domains are handled
* top-level domain servers know where `company.com` is handled
* authoritative DNS servers for `company.com` know the actual records for that domain

This structure makes DNS scalable and global.

If one single server had to store every domain in the world, it would not work. So DNS is hierarchical and delegated.

That is one of the reasons it is called a “system,” not just a table.

---

# Public DNS vs private DNS

you should understand that DNS exists in two major worlds.

The first is **public DNS**.

This is what the internet uses. Public DNS answers for names like:

* google.com
* amazon.com
* openai.com

These are meant to be reachable publicly.

The second is **private or internal DNS**.

Companies use internal DNS for systems that should not be exposed publicly, such as:

* app.internal.company.local
* db.prod.local
* jenkins.corp.internal

These are used only inside the company network or VPN-connected environment.

This distinction is very important because in real life many production systems are not accessed by public names. They are internal.

 DNS is not only “internet website naming.” It is also internal infrastructure naming.

---

# DNS records — what they are and why they exist

 **DNS records.**

A DNS record is an entry in DNS that stores some kind of information about a name.

Not all DNS questions are the same.

Sometimes you want to know:
“What IP belongs to this name?”

Sometimes you want to know:
“What mail server handles this domain?”

Sometimes you want to know:
“Which DNS servers are authoritative for this domain?”

That is why there are different record types.

Each record type exists for a specific purpose.

---

# A record

The **A record** is the most common and most important record students should understand first.

An A record maps a hostname to an IPv4 address.

For example:

`app.company.com -> 192.168.50.10`

When someone asks DNS for `app.company.com`, the DNS server can reply with the IPv4 address.

Why does this record exist?

Because applications and users usually reference services by name, while the network needs the IPv4 address to actually send traffic.

This is the core record for most web apps, internal services, APIs, and many server names.

If you teach only one DNS record first, teach the A record.

In Packet Tracer, this is the record students will understand most easily because they can create a name and point it directly to the server IP.

---

# AAAA record

The AAAA record does the same job as an A record, but for IPv6 instead of IPv4.

For example:

`app.company.com -> 2001:db8::10`

Why does it exist?

Because IPv6 addresses are different from IPv4, and DNS needs a record type that can return IPv6 addresses.

In many beginner labs, students do not use IPv6 much, so AAAA records may feel less important at first. But professionally, students should know that if A means name to IPv4, AAAA means name to IPv6.

The reason the record exists is simple: modern networks increasingly use IPv6, and DNS must support that.

---

# CNAME record

The **CNAME** record stands for canonical name. It is an alias record.

Instead of pointing a name directly to an IP, it points one name to another name.

For example:

`www.company.com -> app.company.com`

Then `app.company.com` might have an A record pointing to the actual IP.

Why would we do this?

Because sometimes multiple names should refer to the same destination, and we do not want to manage multiple IP mappings manually.

Suppose you have:

* `app.company.com`
* `www.company.com`
* `portal.company.com`

If all of them ultimately should point to the same service, using aliases can simplify management.

If the real target changes, you update the main record, not every alias separately.

So CNAME exists for flexibility and easier maintenance.

people often confuse CNAME with A records. The easiest way to explain it is:

* A record: name points directly to IP
* CNAME: name points to another name

---

# MX record

The **MX record** is for mail exchange. It tells the world which mail server handles email for a domain.

For example, if someone sends email to:

`user@company.com`

the sending system needs to know which mail server is responsible for `company.com`.

The MX record provides that information.

Why does this record exist?

Because email delivery is a special service and needs to know where to send mail. Websites, APIs, and mail systems are not all the same, so DNS needs record types that support specific services.

you do not need to become email experts immediately, but they should know that DNS is also involved in mail routing.

---

# NS record

The **NS record** stands for nameserver record.

It tells which DNS servers are authoritative for a domain or zone.

Why does this matter?

Because DNS is distributed and delegated. When the world needs to know who is responsible for the DNS records of `company.com`, NS records help indicate that.

This is part of how DNS hierarchy works.

Without NS records, the DNS system would not know where responsibility has been delegated.

 NS records are less about applications connecting to services and more about DNS infrastructure itself knowing who is in charge of a zone.

---

# TXT record

The **TXT record** stores text data.

At first this sounds strange. Why would DNS need text?

Because many modern systems use DNS as a place to publish verification, ownership, or policy information.

TXT records are commonly used for:

* domain ownership verification
* email security policies like SPF, DKIM, and DMARC
* service integrations
* cloud platform validation

Why does this record exist?

Because DNS is a trusted and widely available distributed system, so it became a natural place to publish configuration-like text that other systems can check.

you should know TXT records are very common in cloud and SaaS integrations.

For example, when you connect a custom domain to a cloud service, the provider may ask you to add a TXT record to prove that you own the domain.

This is very real-world and highly relevant for DevOps.

---

# PTR record

The **PTR record** is used for reverse DNS.

Normally DNS means:
name -> IP

Reverse DNS means:
IP -> name

Why would that matter?

Sometimes systems want to check what hostname is associated with an IP address. This is often used in logging, troubleshooting, email systems, and some security-related checks.

So PTR exists because sometimes we need the reverse lookup direction.

This is not usually the first record students use in Packet Tracer, but they should know it exists and understand that DNS can work in both directions.

---

# SRV record

The **SRV record** is for service discovery.

Instead of simply mapping a name to an IP, it can help describe where a service is located, often including host and port-related service information.

Why does this matter?

Because not every service is just “a machine at an IP.” Some environments need a more structured way to find specific services.

SRV records are used in systems like:

* Active Directory
* SIP/VoIP
* some distributed applications

This record is more advanced, but good students should know that DNS is not just for simple name-to-IP translation. DNS can also help clients discover services.

---

# Why there are so many DNS record types

 “Why not just use one record for everything?”

Because DNS is not only for one purpose.

Networks need to solve different problems:

* finding an IP for a service
* finding a mail server
* finding who manages the zone
* storing verification text
* discovering service endpoints
* handling aliases
* supporting IPv6

One record type cannot do all of that cleanly.

So DNS uses specialized record types to support different real needs.

That is why learning records is not memorizing random letters. Each record exists because a different operational problem had to be solved.

---

# DNS zones

A **zone** is a portion of the DNS namespace managed together.

The easiest way to explain it is that a zone is like a container of DNS records for a domain or subdomain.

For example, the zone `company.com` may contain records such as:

* `app.company.com`
* `db.company.com`
* `mail.company.com`

Why do zones exist?

Because DNS management needs boundaries. Someone must be responsible for a group of records. Zones help organize authority and management.

In real life, DNS administrators manage zones. In cloud platforms, hosted zones in Route 53 are an example of this concept.

So a zone is not just a random group. It is an administrative boundary.

---

# Authoritative DNS vs recursive DNS

This is a very important distinction.

An **authoritative DNS server** is the source of truth for a domain or zone. It holds the actual records.

A **recursive resolver** is the server a client usually asks for help. If it does not know the answer, it goes and finds it by asking other DNS servers.

Why are these roles separated?

Because clients should not have to walk the entire DNS hierarchy themselves. Recursive resolvers do that work and often cache answers.

That makes client lookups faster and simpler.

you do not have to master every DNS internals detail on day one, but they should know:

* authoritative = owns the records
* recursive = helps clients find answers

This distinction becomes very important in real troubleshooting.

---

# Caching in DNS

DNS uses caching heavily.

When a DNS answer is found, it is often stored for a period of time so it does not need to be looked up again immediately.

Why is caching important?

Because DNS is used constantly. Without caching, every request would need to travel through more infrastructure, causing extra delay and extra load.

Caching improves:

* speed
* efficiency
* scalability

But caching also creates troubleshooting challenges.

For example, if you update a DNS record but a client still sees the old IP, that may be because the old answer is cached.

This is one of the most practical professional lessons about DNS: changes are not always visible everywhere immediately.

That is why TTL matters.

---

# TTL

TTL means **time to live**.

It tells how long a DNS answer may be cached before it should be considered expired and refreshed.

Why does TTL exist?

Because caching needs rules. DNS cannot cache forever if records might change, but it also should not refetch everything constantly.

So TTL balances freshness and performance.

A low TTL means changes can be picked up more quickly, but it increases lookup traffic.

A high TTL reduces lookup load but causes changes to take longer to propagate in practice.

This matters a lot in production. If you move a service to a new IP and the old record is cached everywhere for a long time, users may continue reaching the old destination until caches expire.

That is why SREs and DevOps engineers often think carefully about TTL during cutovers and migrations.

---

# Why DNS failure feels like application failure

This is one of the best lessons .

Suppose the app server is healthy. The web service is running. The database is fine. But DNS is broken.

Users cannot resolve the app name. What do they say?

“The app is down.”

From the user’s perspective, the app is unavailable. They do not care whether the root cause is DNS, routing, or HTTP.

Users report symptoms. Engineers identify root cause.

DNS failures often look like application outages.

That is why your runbook approach is excellent:
first separate whether the issue is name resolution or connectivity.

For example:

* `ping app.local` fails
* `ping 192.168.50.10` works

This strongly suggests DNS is the problem, not the network path to the server.

That is a very valuable troubleshooting pattern.

---

# DNS in real companies

In real life, DNS is not usually just one simple server like in Packet Tracer.

Companies often have:

* internal DNS infrastructure
* public DNS infrastructure
* redundant resolvers
* integration with DHCP
* monitoring and alerting
* policies around changes and TTL
* zone management and delegation

Some environments use:

* Active Directory DNS
* BIND on Linux
* Infoblox
* Route 53
* Cloudflare DNS
* Azure DNS
* Google Cloud DNS

The principles remain the same even if the tooling changes.

 emphasize that Packet Tracer teaches the concept, while enterprise tools implement the same ideas at larger scale.

---

# DNS and DevOps

you aiming for DevOps should know DNS is involved in many daily tasks.

Examples:

When deploying a new application, they may need to create or update:

* `app.company.com`

When putting a load balancer in front of a service, the DNS name may point to the load balancer.

When moving from one environment to another, DNS may be changed to redirect traffic.

When using Kubernetes, services rely on internal DNS naming.

When configuring email-related systems, DNS records like MX and TXT become important.

When using custom domains in cloud services, ownership verification often depends on TXT records.

So DNS is not just a networking chapter. It is part of operations, release engineering, cloud setup, security, and application availability.

---

# DNS and SRE

For SRE, DNS matters because it is a dependency.

A healthy application depends on many things:

* DNS
* routing
* gateway
* firewall rules
* load balancer
* server health
* application process
* storage
* certificates

DNS is often near the beginning of that dependency chain.

If service discovery fails, higher layers often fail too.

SREs need to understand not only how DNS works, but how DNS failure presents in symptoms, how caching affects rollouts, and how to distinguish DNS issues from app or network issues.

That is why DNS is deeply relevant to incident response.






