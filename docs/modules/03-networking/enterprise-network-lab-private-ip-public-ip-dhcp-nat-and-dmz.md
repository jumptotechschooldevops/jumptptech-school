---
title: "Enterprise Network Lab: Private IP, Public IP, DHCP, NAT, and DMZ"
description: "1. Lab goal   In this lab, you will understand how a real production network is..."
published: 2026-04-23
source: "https://dev.to/jumptotech/enterprise-network-lab-private-ip-public-ip-dhcp-nat-and-dmz-38ki"
tags: []
---

# Enterprise Network Lab: Private IP, Public IP, DHCP, NAT, and DMZ




# 1. Lab goal

In this lab, you will understand how a real production network is designed.

* why internal users get **private IP addresses**
* why internet-facing systems use **public IP addresses**
* why companies do **not** give public IPs to all users
* how **DHCP** automatically gives IP addresses
* how the **router** routes traffic between networks
* how **NAT** translates private IP to public IP
* what a **DMZ** is
* why private systems must be protected
* how public and private systems communicate safely

---

A company network is usually divided into zones.

### Private zone

This is where internal users and internal systems live.

Examples:

* employee laptops
* internal databases
* internal application servers
* HR systems
* finance systems

These systems usually use **private IP addresses** like:

* `10.0.0.0/8`
* `172.16.0.0/12`
* `192.168.0.0/16`

---

### Public zone

This is the side that must be reachable from outside, from the internet.

Examples:

* website front-end
* reverse proxy
* public web server
* load balancer

These systems use or are reached through **public IP addresses**.

---

### DMZ zone

DMZ means **Demilitarized Zone**.

This is a separate network between the internet and the private internal network.

The DMZ contains systems that need to communicate with the outside world, but should **not be placed directly inside the internal private network**.

Examples:

* public web server
* DNS server
* mail gateway
* reverse proxy
* jump host / bastion host

---

# 3. Real production explanation

A company does not normally ask DHCP to randomly give some users private IP and some users public IP.

That is not how production works.

### In real production:

* **DHCP gives private IPs** to internal users
* **ISP gives public IPs** to the company edge device
* **Router or firewall uses NAT**
* public-facing systems are usually placed in **DMZ**
* sensitive systems stay in **private network**

---

# 4. Where public IP comes from in production

Public IP does **not** come from your internal DHCP for normal employee PCs.

It usually comes from:

* ISP
* telecom provider
* cloud provider

Examples:

* office internet connection from Comcast, AT&T, Verizon, etc.
* AWS public IP / Elastic IP
* Azure public IP
* GCP public IP

So:

> The company receives public connectivity from ISP or cloud provider.
> Internal clients use private IP.
> Edge devices translate traffic between the private network and the public network.

---

# 5. Your current topology and what each device does

Based on  Packet Tracer setup:

### Switch0 on the left

This is your **user access switch**.

Devices connected here:

* PCs in VLAN 10
* PCs in VLAN 20
* PCs in VLAN 30

This switch connects employee devices to the network.

---

### Router0 in the middle

This is your **Layer 3 device**.

This device performs:

* routing between VLANs
* default gateway functions
* DHCP relay with `ip helper-address`
* NAT translation
* connection between inside and outside

> The switch connects devices inside a LAN.
> The router connects different networks together.

---

### Switch1 on the right

This is your **server-side switch**.

You can use this side as:

* server network
* DMZ
* internet simulation side

---

### DHCP server

This is your central DHCP server.

It can stay on the server side.
You do **not** need to move it to Switch0.

Why?

Because the router already uses `ip helper-address`, which forwards DHCP requests across networks.

That is actually very realistic.

---

# 6. Production-style architecture 

### Left side = private internal users

* VLAN 10 = HR
* VLAN 20 = IT
* VLAN 30 = DevOps

### Right side = servers / DMZ / outside simulation

* DHCP server
* DNS server if needed
* one extra “internet simulation” server

### Router = edge and internal gateway

* routes between VLANs
* forwards DHCP requests
* performs NAT
* separates inside and outside

---

# 7. IP addressing plan

We will use this addressing.

## Private internal networks

### VLAN 10

* Network: `192.168.10.0/24`
* Gateway: `192.168.10.1`

### VLAN 20

* Network: `192.168.20.0/24`
* Gateway: `192.168.20.1`

### VLAN 30

* Network: `192.168.30.0/24`
* Gateway: `192.168.30.1`

### Server network / internal server VLAN

* Network: `192.168.50.0/24`
* Gateway: `192.168.50.1`

DHCP server:

* `192.168.50.10`

---

## Public simulation network

We will add one extra outside/public simulation network.

### Public side

* Network: `200.1.1.0/24`
* Router outside interface: `200.1.1.1`
* Public simulation server: `200.1.1.2`

Important:

This is **not real internet**, but it simulates public internet behavior.

---

# 8. Why we use private IP

We use private IP because:

* public IPv4 is limited
* internal devices do not need to be exposed directly to the internet
* private networks are safer
* companies may have thousands of internal devices
* NAT allows many internal devices to share one or a few public IPs

Example:

A company may have:

* 2000 laptops
* 500 printers
* 100 servers

It would be wasteful and dangerous to give public IP to all of them.

So they use private IP internally.

---

# 9. Why we use public IP

Public IP is needed for communication over the internet.

Examples:

* public website
* internet-facing API
* VPN endpoint
* public load balancer
* company firewall outside interface

Public IP is globally reachable.

That is why it must be controlled carefully.

---

# 10. Why we need DMZ

This is one of the most important security concepts.

DMZ is used so that public-facing systems do not sit directly inside the internal private network.

For example:

A public website should not be on the same protected network as:

* HR system
* payroll
* database with customer records
* internal admin systems

Instead:

* public web server goes into DMZ
* internal database stays private
* firewall rules allow only required communication

---

# 11. What data stays private and what can stay public

## Data that stays private

Usually:

* databases
* employee information
* payroll
* internal admin panels
* source code systems
* internal monitoring
* financial data
* internal file shares

These systems should normally never be directly internet-facing.

---

## Data or services that may be public

Usually:

* public website
* public API gateway
* reverse proxy
* public DNS
* public landing page
* public load balancer

Even these are often protected behind:

* firewalls
* WAF
* reverse proxies
* access controls

---

# 12. How public systems communicate with private systems

Important production pattern:

A public service in the DMZ often talks to an internal service in the private zone.

Example:

```text
User on internet
   ↓
Public IP / Load balancer
   ↓
Web server in DMZ
   ↓
Application server in private zone
   ↓
Database in private zone
```

This design protects sensitive systems.

The database is never exposed directly to the internet.

---

# 13. Step-by-step lab

Now we build the lab.

---

# Step 1: Keep DHCP server where it is

Do not move it.

Why:

* central DHCP is normal
* router already relays requests
* this simulates production better

You already have `ip helper-address 192.168.50.10` configured.
That is correct.

---

# Step 2: Confirm router subinterfaces

On the router, you already created subinterfaces.
These are used for inter-VLAN routing.

That means the router will be the gateway for each VLAN.

Use this model:

```bash
conf t

interface g0/0
no shutdown

interface g0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0
ip helper-address 192.168.50.10
ip nat inside

interface g0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0
ip helper-address 192.168.50.10
ip nat inside

interface g0/0.30
encapsulation dot1Q 30
ip address 192.168.30.1 255.255.255.0
ip helper-address 192.168.50.10
ip nat inside

interface g0/0.50
encapsulation dot1Q 50
ip address 192.168.50.1 255.255.255.0
ip nat inside
```

---

## Why we do this

* `g0/0` is the physical router interface connected to the switch
* `.10`, `.20`, `.30`, `.50` are subinterfaces, one per VLAN
* each subinterface has a gateway IP
* devices in each VLAN use that IP as default gateway
* `ip helper-address` forwards DHCP broadcast to the DHCP server
* `ip nat inside` marks these as internal/private networks

---

# Step 3: Configure the switch trunk on Switch0

The switch port connecting to router must be trunk.

Example on Switch0:

```bash
conf t
interface fa0/1
switchport mode trunk
switchport trunk allowed vlan 10,20,30,50
no shutdown
```

Use the actual port that goes to the router.

---

## Why trunk is needed

Explain:

A trunk carries traffic for multiple VLANs over one cable.

Without trunk:

* VLAN 10 traffic cannot be separated from VLAN 20
* router-on-a-stick design will not work

---

# Step 4: Configure access ports on Switch0

Assign user ports to correct VLANs.

Example:

```bash
conf t

vlan 10
name HR

vlan 20
name IT

vlan 30
name DEVOPS

vlan 50
name SERVERS
```

Assign ports:

```bash
interface fa0/2
switchport mode access
switchport access vlan 10

interface fa0/3
switchport mode access
switchport access vlan 10

interface fa0/4
switchport mode access
switchport access vlan 20

interface fa0/5
switchport mode access
switchport access vlan 30
```

Adjust ports based on where your PCs are connected.

---

## Why we do this

Explain:

Each user belongs to a network segment.

VLANs separate departments:

* better security
* better management
* smaller broadcast domains
* easier troubleshooting

---

# Step 5: Configure server-side switch

On the right side, the switch connecting the DHCP server and other servers can be used as server/DMZ zone.

If router connects with a normal access port into VLAN 50, configure the switch port accordingly.

If you want server network as VLAN 50 on Switch1, make sure those devices are in that network.

For basic lab simplicity, use it as the `192.168.50.0/24` network for servers.

---

# Step 6: Configure DHCP server

On the DHCP server, set its own static IP first.

### DHCP Server static IP

* IP: `192.168.50.10`
* Mask: `255.255.255.0`
* Gateway: `192.168.50.1`

Then configure DHCP pools on the server.

---

## DHCP Pool for VLAN 10

* Pool Name: VLAN10
* Default Gateway: `192.168.10.1`
* DNS Server: `192.168.50.10` or another DNS if you use one
* Start IP: `192.168.10.10`
* Subnet Mask: `255.255.255.0`

---

## DHCP Pool for VLAN 20

* Pool Name: VLAN20
* Default Gateway: `192.168.20.1`
* DNS Server: `192.168.50.10`
* Start IP: `192.168.20.10`
* Subnet Mask: `255.255.255.0`

---

## DHCP Pool for VLAN 30

* Pool Name: VLAN30
* Default Gateway: `192.168.30.1`
* DNS Server: `192.168.50.10`
* Start IP: `192.168.30.10`
* Subnet Mask: `255.255.255.0`

---

## Why we do this

Explain:

DHCP automatically assigns:

* IP address
* subnet mask
* default gateway
* DNS server

That means users do not have to configure IP manually.

This is how real office environments work.

---

# Step 7: Test DHCP on user PCs

On each PC:

* Desktop
* IP Configuration
* choose DHCP

The PC should receive:

* a private IP in the correct VLAN
* correct gateway
* correct subnet mask

---





* PC in VLAN 10 gets `192.168.10.x`
* PC in VLAN 20 gets `192.168.20.x`
* PC in VLAN 30 gets `192.168.30.x`

This proves:

* VLANs are working
* DHCP relay is working
* router gateway is correct

---

# Step 8: Add public simulation server

Yes, now add one more server on the right side.

This is your **internet simulation server**.

Set it manually, not by DHCP.

### Public simulation server

* IP: `200.1.1.2`
* Mask: `255.255.255.0`
* Gateway: `200.1.1.1`

---

## Why we add this server

Explain:

We need a device that represents the outside world.

This lets students test:

* private IP inside
* public IP outside
* NAT translation in the router

Without this server, students cannot clearly see how internal traffic becomes public-facing.

---

# Step 9: Configure router outside interface

Choose the router interface connected toward this public simulation side.

Example:

```bash
conf t
interface g0/1
ip address 200.1.1.1 255.255.255.0
ip nat outside
no shutdown
```

---

## Why we do this

Explain:

This interface represents the company’s public-facing edge.

In real production, this would connect to:

* ISP
* internet edge
* cloud public subnet
* external router/firewall

---

# Step 10: Configure NAT

Now configure NAT on the router.

```bash
access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface g0/1 overload
```

---

## Why we do this

Explain every line.

### `access-list 1 permit 192.168.0.0 0.0.255.255`

This says:
All private internal networks that start with `192.168` are allowed to be translated.

### `ip nat inside source list 1 interface g0/1 overload`

This says:
Take inside private traffic matching ACL 1 and translate it to the IP of the outside interface `g0/1`.

`overload` means many private devices can share one public IP.

This is also called PAT.

---

# Step 11: Test internal communication first

Before testing internet/public simulation, test internal communication.

From a user PC:

```bash
ping 192.168.50.10
```

This should ping the DHCP server.

---

## Why this matters

It proves:

* private routing works
* router is routing correctly
* VLANs can reach server network
* no NAT is needed for private-to-private traffic

---

# Step 12: Test public simulation

From a user PC:

```bash
ping 200.1.1.2
```

This should go:

* from private user
* to router
* router translates source IP
* packet reaches public simulation server

---

# Step 13: Verify NAT translations

On the router:

```bash
show ip nat translations
```

You should see something like:

```text
Inside local    192.168.10.10
Inside global   200.1.1.1
Outside local   200.1.1.2
Outside global  200.1.1.2
```

---



### Inside local

The real private IP of the user machine inside the company.

### Inside global

The public IP that the outside network sees.

So if PC is `192.168.10.10`, the outside sees it as `200.1.1.1`.

That is NAT.

---

# 14. Production security explanation

Now explain why this is safer.

If user PCs had public IP directly:

* attackers could scan them
* they would be exposed
* malware and attacks would be easier
* every internal machine would be internet-visible

Instead, companies protect internal users by:

* using private IP
* using NAT
* placing public systems in DMZ
* using firewalls
* using ACLs and segmentation

---

# 15. DMZ example using your lab

In your lab, the right side can be explained as DMZ/server side.

You can say:

* DHCP server in your lab is internal server-side
* the extra public simulation server represents an outside-facing or public-side service
* in a more advanced version, we can place web server in DMZ and keep database private

### Real production example

* public web server in DMZ
* app server in private network
* database in private network

Flow:

```text
Internet user
→ public IP
→ DMZ web server
→ private app server
→ private database
```

---

# 16. What device does what

This is very important .

## Switch

The switch:

* connects local devices
* forwards frames in same LAN/VLAN
* separates VLANs
* does not do internet translation

## Router

The router:

* routes between VLANs/subnets
* acts as default gateway
* forwards DHCP requests with helper-address
* performs NAT
* connects inside and outside networks

## DHCP server

The DHCP server:

* hands out private IP addresses
* provides gateway and DNS settings

## Public simulation server

This server:

* represents external/public destination
* helps us test NAT

---

# 17. CIDR explanation using your lab

Use this part during class.

### `192.168.10.0/24`

Means:

* network = `192.168.10.0`
* mask = `255.255.255.0`
* usable hosts = `192.168.10.1` to `192.168.10.254`
* broadcast = `192.168.10.255`

### `200.1.1.0/24`

Means:

* public simulation network
* router outside IP = `200.1.1.1`
* public simulation server = `200.1.1.2`

---

# 18. Common mistakes



### If DHCP fails

* wrong helper-address
* DHCP server wrong IP
* PC not in correct VLAN
* trunk port missing
* switch port assigned to wrong VLAN

### If routing fails

* wrong gateway
* wrong router subinterface
* encapsulation dot1Q missing
* router physical interface shut down

### If NAT fails

* forgot `ip nat inside`
* forgot `ip nat outside`
* wrong ACL
* wrong outside interface
* public server wrong gateway



> In production, employee machines usually receive private IP addresses from DHCP.
> These addresses are used only inside the company network.
> The company connects to ISP or a cloud provider to get public IP connectivity.
> The router or firewall sits at the edge and uses NAT to translate private internal traffic into public traffic.
> Public-facing systems are often placed in a DMZ so they are separated from the sensitive internal network.
> Important data like databases, payroll, and internal admin systems remain private.
> Public systems like websites can communicate inward only through controlled paths.

---

# 20.  tasks



### Task 1

Set all PCs to DHCP and verify they receive correct private IPs.

### Task 2

Ping default gateway from each PC.

### Task 3

Ping DHCP server `192.168.50.10`.

### Task 4

Add public simulation server `200.1.1.2`.

### Task 5

Configure NAT on router.

### Task 6

Ping public simulation server from a private PC.

### Task 7

Run:

```bash
show ip nat translations
```

### Task 8

Explain the difference between:

* inside local
* inside global



# 22. Exact router NAT commands in one block

Here is the clean NAT part only:

```bash
conf t
interface g0/0.10
ip nat inside
exit

interface g0/0.20
ip nat inside
exit

interface g0/0.30
ip nat inside
exit

interface g0/0.50
ip nat inside
exit

interface g0/1
ip address 200.1.1.1 255.255.255.0
ip nat outside
no shutdown
exit

access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface g0/1 overload
end
write memory
```

---

# 23. Exact server settings for the public simulation server

On the extra server:

* IP: `200.1.1.2`
* Mask: `255.255.255.0`
* Gateway: `200.1.1.1`

Set it manually.

Do not use DHCP for that one.


