---
title: "Network basics"
description: "1️⃣ What Is a MAC Address? (Inside Your House Only)           Think of MAC like:   Your..."
published: 2026-02-21
source: "https://dev.to/jumptotech/network-basics-2fpk"
tags: []
---

# Network basics



# 1️⃣ What Is a MAC Address? (Inside Your House Only)

![Image](https://online.visual-paradigm.com/repository/images/4fafa350-af05-4dd9-b6dd-bff99d8166ce.png)

![Image](https://www.pcweenie.com/images/hni/s03p014_connectRouterDiagram.png)

![Image](https://aruljohn.com/blog/pix/mac-address.png)

![Image](https://www.intel.com/content/dam/support/us/en/images/network-and-i-o/ethernet-products/7060-img2.png)

Think of MAC like:

> Your apartment number inside a building.

* Every device has a MAC address.
* It never leaves your house.
* Switch uses MAC addresses.

Example:

Laptop MAC:

```
AA:BB:CC:DD:EE:FF
```

Used only in **local network (LAN)**.

---

# 2️⃣ What Is an IP Address? (Street Address)

![Image](https://a.storyblok.com/f/47007/2400x1904/f25dd5f061/glossary_ipaddress_v01_card-1.png/m/2880x0/filters%3Aquality%2880%29)

![Image](https://www.ipxo.com/app/uploads/2021/09/Private-vs-Public_2-1024x455.png)

![Image](https://www.pragimtech.com/blog/contribute/article_images/1220210107030954/public-ip-address-vs-private-ip-address.jpg)

![Image](https://www.ipxo.com/app/uploads/2021/09/Private-vs-Public-_-featured.png)

Think of IP like:

> Your home street address.

Example:

Private IP (inside home):

```
192.168.1.10
```

Public IP (visible on internet):

```
73.54.20.11
```

---

# 3️⃣ Why Do We Need Private and Public IP?

Simple reason:

If every phone and laptop in the world had public IP —
👉 We would run out.

So we use:

* Private IP → inside home
* Public IP → router uses this for internet

Your router translates using **NAT**.

---

# 4️⃣ What Is a Switch? (Inside the House)

![Image](https://p.turbosquid.com/ts-thumb/XL/xQy3bu/yz/productshot01switchhub3d/jpg/1681347288/1920x1080/fit_q87/a256d00d8da1b7bb828a8c9e0c5da76855052ea7/productshot01switchhub3d.jpg)

![Image](https://conceptdraw.com/How-To-Guide/picture/Network-diagram-System-design.png)

![Image](https://images.openai.com/static-rsc-3/NLEKHaPKQeTIg-Tl_L6vI8SMeNCxMt_JeIKv4SIXg8Gc6c5p0XX3SUKSmXa7DgGnyFhkmqsFSBxaUjUzFYlNxkToCyouhCos5Nk9kIdmGRY?purpose=fullsize\&v=1)

![Image](https://images.openai.com/static-rsc-3/jBSKQ_N6o5eqlfEwWQ4zdEFS_PT4OBwHLGtv8dekHZzjAPYCX-dF-RfsIWJoDiD_WY-VR88Ue-TK1xeBR456YCCNk0FeonqEjoV0sCmpiRE?purpose=fullsize\&v=1)

Switch:

* Connects devices inside same network
* Uses MAC addresses
* Does NOT connect to internet

Example:
Laptop ↔ Printer ↔ Desktop

---

# 5️⃣ What Is a Router? (Door to the Internet)

![Image](https://images.openai.com/static-rsc-3/okPqYUBMLYtW2oXoSH9LNmZvCkNa3NpvzzfTVXuE7w16hTBBWkj18fg---bMtndf1PKovmCKVgJs4KK-08JUZUemY3tcQbT3tIeGrhw_GkU?purpose=fullsize\&v=1)

![Image](https://images.wondershare.com/edrawmax/templates/wireless-network-diagram.png)

![Image](https://www.suncomm.com/uploads/image/20250913/WAN_Port.png)

![Image](https://www.conceptdraw.com/How-To-Guide/picture/Computer-and-networks-Physical-LAN-and-WAN-diagram.png)

Router:

* Connects your home to internet
* Has:

  * Private IP (inside)
  * Public IP (outside)
* Makes decisions where to send traffic

Router = your house door.

---

# 6️⃣ What Happens When You Type google.com?

Now the fun part.

---

# Step 1 — DNS (Find Google’s Address)

![Image](https://blog.dnsimple.com/files/2016/how-dns-works-first-characters.png)

![Image](https://miro.medium.com/0%2AJRojhE3Qh03aza1p.png)

![Image](https://cdn.prod.website-files.com/5babb9f91ab233ff5f53ce10/607d82bf9feb3a827eb7158f_dns101.jpeg)

![Image](https://miro.medium.com/1%2AF12RohSQ_GPrBuc5dS0EWw.jpeg)

You type:

```
google.com
```

Computer asks:

👉 “What is Google’s IP?”

DNS replies:

```
142.250.190.78
```

Now computer knows where Google lives.

---

# Step 2 — Send to Router

![Image](https://cdn.prod.website-files.com/65f854814fd223fc3678ea53/65f854814fd223fc3678fa34_Ethernet-Packet.gif)

![Image](https://media.licdn.com/dms/image/v2/C5612AQGlr3a90RwVnA/article-cover_image-shrink_600_2000/article-cover_image-shrink_600_2000/0/1627983941999?e=2147483647\&t=XabrfFU-BYfctJpQqyQc4efclHLfmrR9jK5MrhONOTI\&v=beta)

![Image](https://creately.com/static/assets/guides/home-network-diagram/basic-network-diagram-example-with-modem-and-router-VSfKzRefoUg.svg)

![Image](https://louwrentius.com/static/images/home-network-traffic.png)

Laptop sees:

Google is NOT inside my home network.

So it sends packet to:

```
Default Gateway (Router)
```

Before sending:
Laptop asks:

> Who is 192.168.1.1?

Router replies with MAC.

---

# Step 3 — NAT Happens

![Image](https://wi.mit.edu/sites/default/files/styles/pt_picture_bottom_caption/public/2021-05/RNA-family-portrait_v2-01.png?itok=ccaNAKCj)

![Image](https://miro.medium.com/0%2A_oHzXT3JYrkKScFE.png)

![Image](https://devopscube.com/content/images/2025/03/nat-high-level-1.png)

![Image](https://www.9tut.com/images/ccna_self_study/NAT/PAT_Basic.jpg)

Router changes:

```
192.168.1.10
→ 73.54.20.11
```

Now packet goes to internet.

---

# Step 4 — The HOPS (Very Important)

![Image](https://beej.us/guide/bgnet0/html/split/mult_routers_net_diagram.png)

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Hop-count-trans.png/500px-Hop-count-trans.png)

![Image](https://blog.paessler.com/hubfs/blog/2018-03/Traceroute_diagram.png)

![Image](https://scaler.com/topics/images/traceroute-Image_1.webp)

Each time packet moves from one router to another =

👉 One HOP

Example:

```
Hop 1 → Home Router
Hop 2 → ISP Router
Hop 3 → Regional Router
Hop 4 → Backbone Router
Hop 5 → Google Router
```

You can see this using:

On Mac/Linux:

```
traceroute google.com
```

On Windows:

```
tracert google.com
```

Each line = one hop.

---

# Step 5 — Google Receives Packet

![Image](https://storage.googleapis.com/gweb-cloudblog-publish/images/1_Jupiter.max-2000x2000.jpg)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fthepracticaldev.s3.amazonaws.com%2Fi%2Fl2dq74v9l2p990ha3sy5.png)

![Image](https://cdn.tutsplus.com/net/authors/jeremymcpeak/http1-request-response.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AOMhE9T_tuC0pUoZyWKWSnQ.png)

Google server receives request.

Google sends response back.

Response follows same path backward.

Router uses NAT table to send back to correct laptop.

Page loads.

---

# Full Beginner Flow (Very Simple)

```
1. Type google.com
2. DNS finds IP
3. Laptop sends to router
4. Router changes private IP to public IP
5. Packet travels through many routers (hops)
6. Google responds
7. Response returns to laptop
8. Page opens
```

---

# Simple Real-Life Analogy

Think like sending a letter:

* MAC → Apartment number
* IP → Street address
* Router → Post office
* DNS → Phonebook
* Hops → Postal centers
* Google → Company office


