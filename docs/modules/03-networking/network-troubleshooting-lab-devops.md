---
title: "NETWORK TROUBLESHOOTING LAB (DevOps)"
description: "📘 PART 1 — HOW DEVOPS THINKS   When something “doesn’t work,” DevOps engineers follow a..."
published: 2026-04-13
source: "https://dev.to/jumptotech/network-troubleshooting-lab-devops-1df2"
tags: []
---

# NETWORK TROUBLESHOOTING LAB (DevOps)




# 📘 PART 1 — HOW DEVOPS THINKS

When something “doesn’t work,” DevOps engineers follow a logical flow:

1. Do I have network connectivity?
2. Does DNS resolve correctly?
3. Is the server reachable?
4. Is the port open?
5. Is the application running?

We always troubleshoot **layer by layer**, not randomly.

---

# 🧪 PART 2 — CORE NETWORK COMMANDS

---

## 1. Check Your IP Address

```bash
ip a
```

### 🔍 How to read:

* `inet 192.168.x.x` → your machine’s IP
* `127.0.0.1` → localhost
* `eth0`, `ens33` → network interfaces

### ✅ When to use:

* No internet
* Checking if machine has an IP

---

## 2. Check Connectivity (Ping)

```bash
ping google.com
```

### 🔍 How to read:

* `64 bytes from ...` → connection is working
* `time=20ms` → latency
* `Request timeout` → no connection

### ✅ When to use:

* Server not responding
* Check internet access

---

## 3. Trace Network Path

```bash
traceroute google.com
```

### 🔍 How to read:

* Each line = one hop
* `* * *` → failure at that point

### ✅ When to use:

* Ping works but app doesn’t
* Identify where connection breaks

---

## 4. DNS Check

```bash
nslookup google.com
```

### 🔍 How to read:

* `Address:` → resolved IP
* Error → DNS issue

### ✅ When to use:

* Domain not working
* Suspected DNS problem

---

## 5. Advanced DNS Tool

```bash
dig google.com
```

### 🔍 How to read:

* `ANSWER SECTION` → IP
* `status: NOERROR` → success

### ✅ When to use:

* Deep DNS troubleshooting

---

## 6. Test HTTP/HTTPS

```bash
curl http://example.com
```

### 🔍 Better version:

```bash
curl -I http://example.com
```

### 🔍 How to read:

* `200 OK` → success
* `404` → not found
* `500` → server error
* `Connection refused` → service down

### ✅ When to use:

* API testing
* Website issues

---

## 7. Check Open Ports

```bash
netstat -tulnp
```

### 🔍 How to read:

* `LISTEN` → port is open
* `:80`, `:443` → ports
* Process name → service

---

## 8. Modern Alternative

```bash
ss -tulnp
```

### ✅ When to use:

* Same as netstat (preferred today)

---

## 9. Check Which Process Uses a Port

```bash
lsof -i :3000
```

### 🔍 Output shows:

* Process name
* PID
* Port

---

## 10. Test Port Connectivity

### Option 1 — Telnet

```bash
telnet google.com 80
```

### Option 2 — Netcat (recommended)

```bash
nc -zv google.com 80
```

### 🔍 How to read:

* `succeeded` → port open
* `failed` → port closed

---

## 11. Check Routing

```bash
ip route
```

### 🔍 How to read:

* `default via` → gateway (internet path)

---

## 12. Simple DNS Tool

```bash
host google.com
```

---

## 13. Download Test

```bash
wget http://example.com
```

---

# 🧪 PART 3 — HANDS-ON LAB

---

## 🔥 Task 1 — Check Network Connectivity

```bash
ping 8.8.8.8
```

👉 If this fails → network issue

---

## 🔥 Task 2 — Check DNS

```bash
nslookup google.com
```

👉 If this fails → DNS problem

---

## 🔥 Task 3 — Check Website Response

```bash
curl -I https://google.com
```

👉 Find the status code

---

## 🔥 Task 4 — Check Port Availability

```bash
nc -zv google.com 443
```

---

## 🔥 Task 5 — Check Local Service

Run your app:

```bash
node app.js
```

Then check:

```bash
ss -tulnp | grep 3000
```

---

## 🔥 Task 6 — Find Process Using Port

```bash
lsof -i :3000
```

---

# 🧪 PART 4 — REAL DEVOPS SCENARIO

## ❗ Problem:

“Application is not accessible”

## ✅ Step-by-step troubleshooting:

### 1. Check internet

```bash
ping 8.8.8.8
```

### 2. Check DNS

```bash
nslookup myapp.com
```

### 3. Check server

```bash
ping myapp.com
```

### 4. Check port

```bash
nc -zv myapp.com 443
```

### 5. Check HTTP

```bash
curl -I https://myapp.com
```

---

# 🧠 PART 5 — IMPORTANT INTERVIEW KNOWLEDGE

You MUST understand:

* `ping` → connectivity
* `nslookup/dig` → DNS
* `curl` → HTTP
* `ss/netstat` → ports
* `nc` → port testing
* `traceroute` → path


