---
title: "Runbook: Application Down (Packet Tracer / Network-Based App)"
description: "📌 Scenario   User reports: “Application is down (app.local not working)”              🎯..."
published: 2026-04-22
source: "https://dev.to/jumptotech/runbook-application-down-packet-tracer-network-based-app-221b"
tags: []
---

# Runbook: Application Down (Packet Tracer / Network-Based App)



## 📌 Scenario

User reports: **“Application is down (app.local not working)”**

---

## 🎯 Goal

Quickly identify whether the issue is:

* DNS
* Network (IP / routing)
* VLAN / switching
* Server / application

---

## 🔍 Step-by-Step Troubleshooting

### 1. Check DNS Resolution

```bash
ping app.local
```

### Result:

* ❌ Fails → possible DNS issue
* ✅ Works → DNS is OK → go to Step 2

---

### 2. Check IP Connectivity

```bash
ping 192.168.50.10
```

### Result:

* ❌ Fails → network/routing problem
* ✅ Works → network OK → go to Step 3

---

### 3. Verify IP Configuration (Client)

```bash
ipconfig
```

### Check:

* IP address assigned?
* Correct subnet?
* Gateway present?
* DNS server present?

### Common issues:

* No IP → DHCP failure
* Wrong subnet → VLAN issue
* Missing DNS → DHCP misconfig

---

### 4. Check Default Gateway

```bash
ping 192.168.X.1
```

(X = client VLAN)

### Result:

* ❌ Fails → VLAN / switch / trunk issue
* ✅ Works → gateway OK → continue

---

### 5. Check Server Reachability

```bash
ping 192.168.50.10
```

If fails:

* Server down
* VLAN 50 issue
* Routing issue

---

### 6. Check Server Services

On Server:

* DNS → ON
* HTTP → ON

### Test:

Browser:

```plaintext
http://192.168.50.10
```

---

### 7. Check VLAN Configuration

On Switch:

```bash
show vlan brief
```

Verify:

* PC ports in correct VLAN
* Server in VLAN 50

---

### 8. Check Trunk Links

```bash
show interfaces trunk
```

Verify:

* VLANs 10,20,30,50 allowed
* trunk is active

---

### 9. Check Routing (Router)

```bash
show ip interface brief
```

Verify:

* g0/0.10 → 192.168.10.1
* g0/0.20 → 192.168.20.1
* g0/0.30 → 192.168.30.1
* g0/1.50 → 192.168.50.1

---

### 10. Check DHCP Relay

```bash
show run | include helper
```

Verify:

```cisco_ios
ip helper-address 192.168.50.10
```

---

## 🧠 Root Cause Mapping

| Symptom                        | Likely Issue              |
| ------------------------------ | ------------------------- |
| ping app.local fails, IP works | DNS issue                 |
| no IP assigned                 | DHCP issue                |
| gateway unreachable            | VLAN/trunk issue          |
| server unreachable             | routing or VLAN 50 issue  |
| IP works, app fails            | application/service issue |

---

## ⚡ Quick Diagnosis Flow

1. DNS?
2. IP?
3. Gateway?
4. Server?
5. VLAN?
6. Routing?

---

## 💡 SRE Insight

Always troubleshoot **layer by layer**:

1. DNS
2. Network
3. Routing
4. Application

Never jump randomly — follow the chain.


