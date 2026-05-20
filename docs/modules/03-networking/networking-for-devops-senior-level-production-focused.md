---
title: "Networking for DevOps (Senior-Level, Production-Focused)"
description: "🔥 DEVOPS NETWORKING PROJECT            “Service Is UP but NOT Reachable” (AWS EC2 –..."
published: 2025-12-29
source: "https://dev.to/jumptotech/networking-for-devops-senior-level-production-focused-4k5f"
tags: []
---

# Networking for DevOps (Senior-Level, Production-Focused)







# 🔥 DEVOPS NETWORKING PROJECT

## “Service Is UP but NOT Reachable” (AWS EC2 – Ubuntu)

---

## 🎯 PROJECT GOAL 

1. Run a real service on EC2
2. Break network access in real ways
3. Learn **exactly what to check and in what order**
4. Be able to answer the interview question confidently

---

## 🧠 ONE RULE (MEMORIZE)

```
App → Port → Binding → Local Test → Linux Firewall → Routing → Cloud Firewall → DNS
```

---

# STEP 0 — CONNECT TO EC2

```bash
ssh ubuntu@<EC2_PUBLIC_IP>
```

---

# STEP 1 — CREATE A REAL SERVICE (APP LAYER)

```bash
echo "Hello DevOps Networking" > index.html
python3 -m http.server 8080
```

---

### ✅ TEST 1 — IS THE SERVICE RUNNING?

```bash
curl http://localhost:8080
```

**Expected**

```
Hello DevOps Networking
```

**Meaning**

* App is running
* App responds
* NOT a code problem

---

# STEP 2 — CHECK PORT & PROCESS

```bash
ss -tulnp | grep 8080
```

**Expected**

```
tcp LISTEN 0.0.0.0:8080 python3
```

### What you check here

* Port number
* LISTEN state
* Process name

**Meaning**

* Port is open
* No conflict
* Service accepts traffic

---

# STEP 3 — CHECK IP & ROUTING

### CHECK INTERFACES

```bash
ip a
```

Find:

```
inet 172.31.x.x
```

### CHECK ROUTES

```bash
ip r
```

Find:

```
default via 172.31.x.1
```

**Meaning**

* Server has IP
* Server knows how to send traffic

---

# STEP 4 — TEST USING SERVER IP (LOCAL NETWORK)

```bash
curl http://<PRIVATE_IP>:8080
```

**Expected**

```
Hello DevOps Networking
```

**Meaning**

* Linux networking is OK

---

# STEP 5 — CHECK LINUX FIREWALLS

### CHECK UFW

```bash
sudo ufw status
```

Expected:

```
Status: inactive
```

---

### CHECK IPTABLES

```bash
sudo iptables -L -n
```

Expected:

```
policy ACCEPT
```

**Meaning**

* Linux is NOT blocking traffic

---

# STEP 6 — TEST PORT OWNERSHIP (PORT TROUBLESHOOTING)

```bash
lsof -i :8080
```

**Expected**

```
python3
```

**Meaning**

* Correct app owns the port

---

# STEP 7 — TEST FROM OUTSIDE (REAL PROBLEM)

Open in browser:

```
http://<EC2_PUBLIC_IP>:8080
```

**Result**
❌ Page does NOT open

---

# 🚨 WHY IT FAILS (THIS IS THE LESSON)

AWS blocks traffic **before it reaches Linux**.

---

# STEP 8 — FIX CLOUD FIREWALL (AWS SECURITY GROUP)

### In AWS Console → Security Group → Inbound Rules

Add:

| Type | Port | Source               |
| ---- | ---- | -------------------- |
| TCP  | 8080 | Your IP or 0.0.0.0/0 |

Save.

---

# STEP 9 — TEST AGAIN

Open:

```
http://<EC2_PUBLIC_IP>:8080
```

**Expected**

```
Hello DevOps Networking
```

🎉 SUCCESS

---

# STEP 10 — DNS TEST (OPTIONAL BUT IMPORTANT)

### Test IP works

```bash
curl http://<EC2_PUBLIC_IP>:8080
```

### Test domain

```bash
curl http://myapp.example.com:8080
```

### Check DNS

```bash
nslookup myapp.example.com
```

**Meaning**

* DNS maps name → IP

---

# 🔍 ERROR TYPES & WHAT THEY MEAN

| Error                   | Meaning       |
| ----------------------- | ------------- |
| Timeout                 | Firewall / SG |
| Connection refused      | App down      |
| Works on localhost only | Wrong binding |
| Works with IP only      | DNS issue     |

---

# 🎤 INTERVIEW ANSWER (MEMORIZE)

> “I check layer by layer.
> First I verify the service locally.
> Then I check port and binding.
> After that I check Linux firewall and routing.
> If Linux is open, I check cloud firewalls like Security Groups and DNS.”

---

# ✅ WHAT THIS PROJECT COVERS

✔ IP, ports, routing
✔ `ip a`, `ip r`
✔ `ss`, `netstat`
✔ `curl`, `wget`
✔ `ufw`, `iptables`
✔ `lsof -i`
✔ Interview question












