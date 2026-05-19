---
title: "proxy, firewall and DMZ on packet tracer"
description: "PHASE 1 — CHECK EXISTING ARCHITECTURE FIRST            1. ROUTER0 CHECK COMMANDS   Run on..."
published: 2026-04-27
source: "https://dev.to/jumptotech/proxy-firewall-and-dmz-on-packet-tracer-3b45"
tags: []
---

# proxy, firewall and DMZ on packet tracer


# PHASE 1 — CHECK EXISTING ARCHITECTURE FIRST

## 1. ROUTER0 CHECK COMMANDS

Run on **Router0**.

### Check all router interfaces

```bash
enable
show ip interface brief
```

Expected:

```text
g0/0.10    192.168.10.1    up/up
g0/0.20    192.168.20.1    up/up
g0/0.30    192.168.30.1    up/up
g0/1.50    192.168.50.1    up/up
g0/1.100   200.1.1.1       up/up
```

This shows:

```text
Which VLAN gateway exists on router
Whether interfaces are working
```

---

### Check routing table

```bash
show ip route
```

Expected:

```text
192.168.10.0/24 connected
192.168.20.0/24 connected
192.168.30.0/24 connected
192.168.50.0/24 connected
200.1.1.0/24 connected
```

This shows:

```text
Router knows all VLAN networks
```

---

### Check DHCP pools on router

```bash
show running-config | section dhcp
```

Expected:

```text
VLAN10 pool
VLAN20 pool
VLAN30 pool
```

This shows:

```text
Router or server DHCP settings
```

---

### Check firewall rules

```bash
show access-lists
```

Expected before firewall:

```text
No important ACL or old ACL only
```

This shows:

```text
Existing firewall rules
```

---

### Check where ACL is applied

```bash
show running-config | include access-group
```

Expected before firewall:

```text
empty or old access-group
```

This shows:

```text
Whether firewall is already applied to interface
```

---

### Check router full config

```bash
show running-config
```

This shows everything:

```text
Subinterfaces
DHCP
ACL
NAT
Gateway IPs
```

---

## 2. SWITCH0 CHECK COMMANDS

Switch0 = user computers.

Run on **Switch0**.

### Check VLAN and ports

```bash
enable
show vlan brief
```

Expected from your lab:

```text
VLAN 10 HR       Fa0/1, Fa0/2, Fa0/5
VLAN 20 IT       Fa0/3
VLAN 30 DevOps   Fa0/4
```

This shows:

```text
Which computer port belongs to which VLAN
```

---

### Check trunk port

```bash
show interfaces trunk
```

Expected:

```text
Fa0/24 trunking
Allowed VLANs: 10,20,30,50
```

This shows:

```text
Switch-to-router connection carries VLANs
```

---

### Check MAC address table

```bash
show mac address-table
```

Expected:

```text
MAC addresses learned on PC ports and trunk port
```

This shows:

```text
Which device is connected to which switch port
```

---

### Check switch interfaces

```bash
show ip interface brief
```

Expected:

```text
Fa0/1 up
Fa0/2 up
Fa0/3 up
Fa0/4 up
Fa0/24 up
```

This shows:

```text
Which physical cables are active
```

---

## 3. SWITCH1 CHECK COMMANDS

Switch1 = servers.

Run on **Switch1**.

### Check VLAN and server ports

```bash
enable
show vlan brief
```

Expected:

```text
VLAN 50 SERVERS/PUBLIC   Fa0/1
VLAN 100 PUBLIC          Fa0/2, Fa0/4
```



```text
Fa0/1 = Server0
Fa0/2 = Server2
Fa0/4 = PC4 or future server
Fa0/3 = trunk to router
```

---

### Check trunk

```bash
show interfaces trunk
```

Expected:

```text
Fa0/3 trunking
Allowed VLANs: 50,100
```

---

### Check MAC address table

```bash
show mac address-table
```

Expected:

```text
VLAN 50 MAC on Fa0/1
VLAN 100 MAC on Fa0/2
VLAN 100 MAC on Fa0/4
```

---

### Check interface status

```bash
show ip interface brief
```

Expected:

```text
Fa0/1 up
Fa0/2 up
Fa0/3 up
Fa0/4 up
```

---

## 4. COMPUTER CHECK COMMANDS

On every PC:

```text
Desktop → Command Prompt
```

Run:

```bash
ipconfig
```

Expected:

```text
PC0  = 192.168.10.10 / gateway 192.168.10.1
PC10 = 192.168.10.11 / gateway 192.168.10.1
PC1  = 192.168.10.12 / gateway 192.168.10.1
PC2  = 192.168.20.10 / gateway 192.168.20.1
```

Then test gateway:

```bash
ping 192.168.10.1
```

or for VLAN20:

```bash
ping 192.168.20.1
```

Expected:

```text
Success
```

---

## 5. SERVER CHECKS

### Server0 — DHCP/DNS server

Go to:

```text
Server0 → Desktop → IP Configuration
```

Expected:

```text
IP: 192.168.50.10
Mask: 255.255.255.0
Gateway: 192.168.50.1
DNS: 192.168.50.10
```

Services:

```text
Services → DHCP → ON
Services → DNS → ON
```

---

### Server2 — Public-facing web/proxy server

Expected:

```text
IP: 200.1.1.2
Mask: 255.255.255.0
Gateway: 200.1.1.1
DNS: 192.168.50.10
DHCP Service: OFF
HTTP Service: ON
```

---

# PHASE 2 — IMPLEMENT DMZ + FIREWALL + PROXY

Important:

```text
Right now VLAN100 is only a separate network.
It becomes a DMZ after we apply firewall rules.
```

## Production-style zones

```text
INTERNAL USERS:
VLAN 10,20,30
192.168.10.0/24
192.168.20.0/24
192.168.30.0/24

PRIVATE SERVERS:
VLAN 50
192.168.50.0/24

DMZ / PUBLIC-FACING:
VLAN 100
200.1.1.0/24
```

---

# STEP 1 — FIX SERVER2

On Server2:

```text
Services → DHCP → OFF
Services → HTTP → ON
```

IP config:

```text
IP: 200.1.1.2
Mask: 255.255.255.0
Gateway: 200.1.1.1
DNS: 192.168.50.10
```

---

# STEP 2 — CREATE FIREWALL ON ROUTER

This firewall will do:

```text
Internal users can access web/proxy server
DMZ cannot access internal PCs
DMZ cannot access private servers except database later
Users cannot directly access database later
```

Run on **Router0**:

```bash
enable
conf t

no access-list 100
no access-list 101
no access-list 110

ip access-list extended DMZ_FIREWALL
remark Allow DMZ server to reach private database later
permit tcp host 200.1.1.2 host 192.168.50.20 eq 80

remark Block DMZ from reaching internal user VLANs
deny ip 200.1.1.0 0.0.0.255 192.168.10.0 0.0.0.255
deny ip 200.1.1.0 0.0.0.255 192.168.20.0 0.0.0.255
deny ip 200.1.1.0 0.0.0.255 192.168.30.0 0.0.0.255

remark Block DMZ from reaching private server VLAN except database rule above
deny ip 200.1.1.0 0.0.0.255 192.168.50.0 0.0.0.255

remark Allow remaining traffic for Packet Tracer lab stability
permit ip any any

interface g0/1.100
ip access-group DMZ_FIREWALL in

end
wr
```

---

## What this means

```text
interface g0/1.100 = VLAN100 gateway
ip access-group DMZ_FIREWALL in = check traffic coming FROM DMZ into router
```

So when Server2 tries to go inside:

```text
Server2 → Router → Internal network
```

Router checks firewall.

---

# STEP 3 — INTERNAL USERS FIREWALL

This blocks users from directly accessing database later.

Run on **Router0**:

```bash
enable
conf t

ip access-list extended INTERNAL_USERS
remark Allow users to access DMZ web/proxy server
permit tcp 192.168.0.0 0.0.255.255 host 200.1.1.2 eq 80

remark Allow users to use DNS
permit udp 192.168.0.0 0.0.255.255 host 192.168.50.10 eq 53

remark Block users from accessing private database directly
deny tcp 192.168.0.0 0.0.255.255 host 192.168.50.20 eq 80

remark Allow other traffic for lab testing
permit ip any any

interface g0/0.10
ip access-group INTERNAL_USERS in

interface g0/0.20
ip access-group INTERNAL_USERS in

interface g0/0.30
ip access-group INTERNAL_USERS in

end
wr
```



# 🔥 PHASE 3 — CREATE INTERNET-FACING WEB APP

## Step 1 — Create Website on Server2 (DMZ)

Go to:

```text
Server2 → Services → HTTP → ON
```

Then edit **index.html**

Replace with:

```html
<html>
<head>
<title>Company Portal</title>
</head>

<body>
<h1>Welcome to JumpToTech Company</h1>

<h2>Login</h2>

<form>
Username: <input type="text"><br><br>
Password: <input type="password"><br><br>
<input type="submit" value="Login">
</form>

</body>
</html>
```

---

## Step 2 — TEST WEB SERVER

From any PC (PC0):

```bash
ping 200.1.1.2
```

Expected:

```text
Success
```

Now open browser:

```text
Desktop → Web Browser
http://200.1.1.2
```

✔️ You should see your webpage

---

# 🔥 PHASE 4 — CREATE PRIVATE DATABASE

We simulate database using another server.

---

## Step 1 — Use Server0 or New Server as DB

👉 Better: use **Server0 as DB + DNS**

Assign (already done):

```text
IP: 192.168.50.10
```

---

## Step 2 — Create Database (simulate via HTTP)

Go to:

```text
Server0 → Services → HTTP → ON
```

Edit page:

```html
<html>
<body>

<h1>DATABASE SERVER</h1>

<p>User Data Stored Here</p>

<p>Username: admin</p>
<p>Password: secret123</p>

</body>
</html>
```

---

# 🔥 PHASE 5 — CONNECT WEB → DATABASE

Now simulate backend call:

### On Server2 (Web server)

Update HTML:

```html
<html>
<body>

<h1>Company Portal</h1>

<a href="http://192.168.50.10">Access Database</a>

</body>
</html>
```

---

## Test flow:

From PC:

```text
http://200.1.1.2
→ click link
→ should open 192.168.50.10
```

---

# 🚨 NOW APPLY FIREWALL RESTRICTION (IMPORTANT)

We now enforce production behavior:

## Requirement:

```text
❌ Users cannot access DB directly
✅ Only Web Server can access DB
```

---

## Step — FIX FIREWALL (Router)

Run:

```bash
conf t

no ip access-list extended INTERNAL_USERS

ip access-list extended INTERNAL_USERS

remark Allow users → web server only
permit tcp 192.168.0.0 0.0.255.255 host 200.1.1.2 eq 80

remark Block users → database
deny tcp 192.168.0.0 0.0.255.255 host 192.168.50.10 eq 80

permit ip any any

interface g0/0.10
ip access-group INTERNAL_USERS in

interface g0/0.20
ip access-group INTERNAL_USERS in

interface g0/0.30
ip access-group INTERNAL_USERS in

end
```

---

## Now test:

### From PC:

```text
http://192.168.50.10
```

❌ SHOULD FAIL

---

### From Web Server:

```text
Server2 → Browser
http://192.168.50.10
```

✔️ SHOULD WORK

---

# 🔥 PHASE 6 — ADD PROXY (VERY IMPORTANT)

Now we simulate proxy:

👉 Proxy = control user internet access

---

## Step — Make Server2 act as Proxy

In Packet Tracer (simplified):

Use HTTP filtering idea:

Update firewall:

```bash
conf t

ip access-list extended PROXY_CONTROL

remark Allow only web server access
permit tcp 192.168.0.0 0.0.255.255 host 200.1.1.2 eq 80

remark Block all other internet
deny ip 192.168.0.0 0.0.255.255 any

permit ip any any

interface g0/0.10
ip access-group PROXY_CONTROL in

interface g0/0.20
ip access-group PROXY_CONTROL in

interface g0/0.30
ip access-group PROXY_CONTROL in

end
```

---

## Result:

| Action          | Result |
| --------------- | ------ |
| PC → Web Server | ✅      |
| PC → Internet   | ❌      |
| PC → DB         | ❌      |
| Web → DB        | ✅      |

---

# 🔥 FINAL ARCHITECTURE (PRODUCTION STYLE)

```plaintext
[ USERS VLAN 10/20/30 ]
        ↓
     (Firewall)
        ↓
   [ DMZ - Web Server ]
        ↓
     (Firewall)
        ↓
 [ Private DB VLAN50 ]
```

---

# 🔥 PHASE 7 — SRE TROUBLESHOOTING SCENARIOS



## Scenario 1 — Website not opening

Check:

```bash
ping 200.1.1.2
```

If fails:

```bash
show ip interface brief
show vlan brief
```

---

## Scenario 2 — Page loads but DB not working

Check from Server2:

```bash
ping 192.168.50.10
```

If fails:

```bash
show access-lists
```

---

## Scenario 3 — User cannot access web

Check:

```bash
show access-lists
show run | include access-group
```

---

## Scenario 4 — DNS issue

Check:

```bash
ping 192.168.50.10
```

Then:

```text
Server0 → DNS → ON
```

---

# 🔥 FINAL RESULT

You built:

✔️ VLAN segmentation
✔️ Router-on-a-stick
✔️ DMZ architecture
✔️ Firewall (ACL)
✔️ Proxy control
✔️ Web application
✔️ Database separation
✔️ SRE troubleshooting scenarios


