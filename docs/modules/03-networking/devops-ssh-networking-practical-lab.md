---
title: "DEVOPS SSH & NETWORKING PRACTICAL LAB"
description: "🧩 MODULE 1 — NETWORK FOUNDATION (WHY SSH WORKS)               🔹 Lecture Topics..."
published: 2025-12-28
source: "https://dev.to/jumptotech/devops-ssh-networking-practical-lab-51ap"
tags: []
---

# DEVOPS SSH & NETWORKING PRACTICAL LAB







## 🧩 MODULE 1 — NETWORK FOUNDATION (WHY SSH WORKS)

---

## 🔹 Lecture Topics Covered

* TCP vs UDP
* Port scanning (Nmap)
* NAT & Port Forwarding
* Home vs Cloud networking
* Why SSH ports matter

---

## 🧪 LAB 1 — Understanding Ports & Services (Nmap)

### 🎯 Goal

Understand **what ports are**, **why SSH uses ports**, and **how attackers find servers**.

---

### 🧠 Concept (Beginner Explanation)

A **port** is like a **door** on a server.
SSH uses **port 22** by default.

Attackers scan the internet to find **open doors**.

---

### 🧪 Exercise

1. Install nmap:

```bash
sudo apt install nmap -y
```

2. Scan localhost:

```bash
nmap localhost
```

3. Scan SSH explicitly:

```bash
nmap -p 22 localhost
```

4. Run SYN scan (root required):

```bash
sudo nmap -sS localhost
```

---

### 🧠 What You Learn

* What “open”, “closed”, “filtered” mean
* Why **SSH port scanning is dangerous**
* Why changing SSH port reduces noise

---

### 🧑‍💼 DevOps Real-World Use

> Before exposing a server, DevOps engineers **scan their own infrastructure** to ensure only expected ports are open.

---

## 🧪 LAB 2 — NAT & Port Forwarding (Mental Model)

### 🎯 Goal

Understand **why SSH sometimes works locally but not from outside**.

---

### 🧠 Concept

* Home router = NAT
* Internal IP ≠ Internet IP
* SSH from outside requires **port forwarding**

---

### 🧪 Exercise (Observation)

1. Find local IP:

```bash
ip a
```

2. Find gateway:

```bash
ip route
```

3. Understand:

* Why cloud servers don’t need port forwarding
* Why home servers do

---

### 🧠 What You Learn

* Why cloud networking feels “easier”
* Why DevOps prefers cloud infra
* Why NAT breaks inbound SSH

---

## 🧩 MODULE 2 — SSH FUNDAMENTALS

---

## 🔹 Lecture Topics Covered

* What SSH is
* Client vs Server
* Use cases
* VM networking models

---

## 🧪 LAB 3 — Install & Start SSH Server

### 🎯 Goal

Turn a machine into a **real server**.

---

### 🧠 Concept

SSH server = **remote control service**

---

### 🧪 Exercise

Ubuntu:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl status ssh
```

CentOS:

```bash
sudo dnf install openssh-server -y
sudo systemctl enable sshd --now
```

---

### 🧠 What You Learn

* Difference between client & server
* How servers accept connections
* How system services work

---

### 🧑‍💼 DevOps Reality

> Every cloud VM you manage relies on SSH.

---

## 🧪 LAB 4 — SSH Connection Basics

### 🎯 Goal

Log into a server remotely.

---

### 🧪 Exercise

```bash
ssh user@server-ip
```

Test:

```bash
whoami
hostname
pwd
```

---

### 🧠 What You Learn

* You are controlling a remote machine
* Commands run **on the server**, not locally

---

## 🧩 MODULE 3 — SSH SECURITY HARDENING (CORE DEVOPS SKILL)

---

## 🔹 Lecture Topics Covered

* Change SSH port
* Disable root login
* Whitelist users
* Logs & monitoring

---

## 🧪 LAB 5 — Change SSH Port (22 → 2222)

### 🎯 Goal

Reduce attack surface.

---

### 🧪 Exercise

```bash
sudo nano /etc/ssh/sshd_config
```

Change:

```ini
Port 2222
```

Test:

```bash
sudo sshd -t
sudo systemctl restart sshd
```

Connect:

```bash
ssh -p 2222 user@server
```

---

### 🧠 What You Learn

* How SSH configuration works
* Why services must be restarted
* How easy it is to break access

---

### 🧑‍💼 DevOps Reality

> Every production SSH server **does this**.

---

## 🧪 LAB 6 — Disable Root Login

### 🎯 Goal

Prevent instant full compromise.

---

### 🧪 Exercise

```ini
PermitRootLogin no
```

Restart SSH.

Test:

```bash
ssh root@server
```

---

### 🧠 What You Learn

* Principle of least privilege
* Why attackers target root

---

## 🧪 LAB 7 — AllowUsers Whitelisting

### 🎯 Goal

Explicitly control access.

---

### 🧪 Exercise

```ini
AllowUsers devuser
```

Test login failure for others.

---

### 🧠 What You Learn

* SSH as access control layer
* How DevOps enforces policy

---

## 🧩 MODULE 4 — DO NOT LOCK YOURSELF OUT

---

## 🔹 Lecture Topics Covered

* Multiple SSH sessions
* Safe changes
* Recovery mindset

---

## 🧪 LAB 8 — Two-Session Safety Practice

### 🎯 Goal

Never brick a production server.

---

### 🧪 Exercise

1. Open **two SSH terminals**
2. Stop SSH:

```bash
sudo systemctl stop sshd
```

3. Observe:

* Session A works
* Session B fails

4. Restore:

```bash
sudo systemctl start sshd
```

---

### 🧠 What You Learn

* Why existing connections survive
* How DevOps recovers mistakes

---

## 🧩 MODULE 5 — SSH KEYS (ENTERPRISE AUTH)

---

## 🔹 Lecture Topics Covered

* Public/private keys
* ssh-keygen
* ssh-copy-id
* authorized_keys

---

## 🧪 LAB 9 — SSH Key Authentication

### 🎯 Goal

Replace passwords with cryptography.

---

### 🧪 Exercise

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -p 2222 user@server
ssh -p 2222 user@server
```

---

### 🧠 What You Learn

* Cryptographic trust
* Why keys are stronger than passwords
* Foundation for automation

---

## 🧩 MODULE 6 — DISABLE PASSWORD LOGIN

---

## 🔹 Lecture Topics Covered

* PasswordAuthentication no
* sudo separation
* Recovery planning

---

## 🧪 LAB 10 — Enforce Key-Only SSH

### 🎯 Goal

Eliminate brute-force attacks.

---

### 🧪 Exercise

```ini
PasswordAuthentication no
```

Restart SSH.

Test:

```bash
ssh user@server
```

From another user → should fail.

---

### 🧠 What You Learn

* Zero-trust login
* Production hardening standard

---

## 🧩 MODULE 7 — KEEP SSH ALIVE

---

## 🔹 Lecture Topics Covered

* SSH keepalive
* Client config
* Long-running sessions

---

## 🧪 LAB 11 — Prevent Connection Drops

### 🎯 Goal

Survive long deployments.

---

### 🧪 Exercise

```bash
nano ~/.ssh/config
```

```ini
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

---

### 🧠 What You Learn

* Client vs server responsibility
* Why SSH drops connections

---

## 🧩 MODULE 8 — FINGERPRINTS & MITM PROTECTION

---

## 🔹 Lecture Topics Covered

* Fingerprints
* known_hosts
* MITM attacks

---

## 🧪 LAB 12 — Fingerprint Verification

### 🎯 Goal

Detect impostor servers.

---

### 🧪 Exercise

Client:

```bash
cat ~/.ssh/known_hosts
```

Server:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Compare hashes.

---

### 🧠 What You Learn

* Why fingerprints exist
* How SSH prevents MITM

---

## 🧩 MODULE 9 — FILE TRANSFER (SFTP / SCP)

---

## 🔹 Lecture Topics Covered

* SCP
* SFTP
* GUI tools (Cyberduck)

---

## 🧪 LAB 13 — SCP & SFTP

### 🎯 Goal

Move data securely.

---

```bash
scp -P 2222 file.txt user@server:/home/user/
scp -P 2222 user@server:/home/user/file.txt .
```

GUI:

* Connect via SFTP
* Drag & drop files

---

### 🧠 What You Learn

* Why FTP is insecure
* Secure automation transfers

---

## 🧩 MODULE 10 — SCREEN (PRODUCTION SURVIVAL TOOL)

---

## 🔹 Lecture Topics Covered

* screen
* detach/attach
* collaboration

---

## 🧪 LAB 14 — Screen Mastery

### 🎯 Goal

Survive disconnects & collaborate.

---

```bash
screen
Ctrl+A Ctrl+D
screen -x
exit
```

---

### 🧠 What You Learn

* Persistent sessions
* Remote teamwork

---

## 🏁 FINAL CAPSTONE PROJECT

### 🎯 Scenario

> You are the only DevOps engineer managing a production server.

You must:

1. Harden SSH
2. Use key auth only
3. Prevent lockout
4. Enable file transfer
5. Keep sessions alive
6. Share terminal with teammate

---

## 🎓 OUTCOME

After completing this:

* Student **can manage real servers**
* Student **understands SSH deeply**
* Student **thinks like a DevOps engineer**
* Student **can pass interviews**

---

If you want, next I can:

* Convert this into **PDF course manual**
* Create **graded homework**
* Add **interview questions**
* Add **cloud (AWS EC2) version**
* Add **GitHub lab repo**

Just tell me what you want next.


> **Audience:** Absolute beginners
> **Outcome:** Production-ready DevOps engineer mindset
> **Environment:** Ubuntu / CentOS / Cloud / VM
> **Style:** Real-world, mistakes included, recovery included

---

## 🧩 MODULE 1 — NETWORK FOUNDATION (WHY SSH WORKS)

---

## 🔹 Lecture Topics Covered

* TCP vs UDP
* Port scanning (Nmap)
* NAT & Port Forwarding
* Home vs Cloud networking
* Why SSH ports matter

---

## 🧪 LAB 1 — Understanding Ports & Services (Nmap)

### 🎯 Goal

Understand **what ports are**, **why SSH uses ports**, and **how attackers find servers**.

---

### 🧠 Concept (Beginner Explanation)

A **port** is like a **door** on a server.
SSH uses **port 22** by default.

Attackers scan the internet to find **open doors**.

---

### 🧪 Exercise

1. Install nmap:

```bash
sudo apt install nmap -y
```

2. Scan localhost:

```bash
nmap localhost
```

3. Scan SSH explicitly:

```bash
nmap -p 22 localhost
```

4. Run SYN scan (root required):

```bash
sudo nmap -sS localhost
```

---

### 🧠 What You Learn

* What “open”, “closed”, “filtered” mean
* Why **SSH port scanning is dangerous**
* Why changing SSH port reduces noise

---

### 🧑‍💼 DevOps Real-World Use

> Before exposing a server, DevOps engineers **scan their own infrastructure** to ensure only expected ports are open.

---

## 🧪 LAB 2 — NAT & Port Forwarding (Mental Model)

### 🎯 Goal

Understand **why SSH sometimes works locally but not from outside**.

---

### 🧠 Concept

* Home router = NAT
* Internal IP ≠ Internet IP
* SSH from outside requires **port forwarding**

---

### 🧪 Exercise (Observation)

1. Find local IP:

```bash
ip a
```

2. Find gateway:

```bash
ip route
```

3. Understand:

* Why cloud servers don’t need port forwarding
* Why home servers do

---

### 🧠 What You Learn

* Why cloud networking feels “easier”
* Why DevOps prefers cloud infra
* Why NAT breaks inbound SSH

---

## 🧩 MODULE 2 — SSH FUNDAMENTALS

---

## 🔹 Lecture Topics Covered

* What SSH is
* Client vs Server
* Use cases
* VM networking models

---

## 🧪 LAB 3 — Install & Start SSH Server

### 🎯 Goal

Turn a machine into a **real server**.

---

### 🧠 Concept

SSH server = **remote control service**

---

### 🧪 Exercise

Ubuntu:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl status ssh
```

CentOS:

```bash
sudo dnf install openssh-server -y
sudo systemctl enable sshd --now
```

---

### 🧠 What You Learn

* Difference between client & server
* How servers accept connections
* How system services work

---

### 🧑‍💼 DevOps Reality

> Every cloud VM you manage relies on SSH.

---

## 🧪 LAB 4 — SSH Connection Basics

### 🎯 Goal

Log into a server remotely.

---

### 🧪 Exercise

```bash
ssh user@server-ip
```

Test:

```bash
whoami
hostname
pwd
```

---

### 🧠 What You Learn

* You are controlling a remote machine
* Commands run **on the server**, not locally

---

## 🧩 MODULE 3 — SSH SECURITY HARDENING (CORE DEVOPS SKILL)

---

## 🔹 Lecture Topics Covered

* Change SSH port
* Disable root login
* Whitelist users
* Logs & monitoring

---

## 🧪 LAB 5 — Change SSH Port (22 → 2222)

### 🎯 Goal

Reduce attack surface.

---

### 🧪 Exercise

```bash
sudo nano /etc/ssh/sshd_config
```

Change:

```ini
Port 2222
```

Test:

```bash
sudo sshd -t
sudo systemctl restart sshd
```

Connect:

```bash
ssh -p 2222 user@server
```

---

### 🧠 What You Learn

* How SSH configuration works
* Why services must be restarted
* How easy it is to break access

---

### 🧑‍💼 DevOps Reality

> Every production SSH server **does this**.

---

## 🧪 LAB 6 — Disable Root Login

### 🎯 Goal

Prevent instant full compromise.

---

### 🧪 Exercise

```ini
PermitRootLogin no
```

Restart SSH.

Test:

```bash
ssh root@server
```

---

### 🧠 What You Learn

* Principle of least privilege
* Why attackers target root

---

## 🧪 LAB 7 — AllowUsers Whitelisting

### 🎯 Goal

Explicitly control access.

---

### 🧪 Exercise

```ini
AllowUsers devuser
```

Test login failure for others.

---

### 🧠 What You Learn

* SSH as access control layer
* How DevOps enforces policy

---

## 🧩 MODULE 4 — DO NOT LOCK YOURSELF OUT

---

## 🔹 Lecture Topics Covered

* Multiple SSH sessions
* Safe changes
* Recovery mindset

---

## 🧪 LAB 8 — Two-Session Safety Practice

### 🎯 Goal

Never brick a production server.

---

### 🧪 Exercise

1. Open **two SSH terminals**
2. Stop SSH:

```bash
sudo systemctl stop sshd
```

3. Observe:

* Session A works
* Session B fails

4. Restore:

```bash
sudo systemctl start sshd
```

---

### 🧠 What You Learn

* Why existing connections survive
* How DevOps recovers mistakes

---

## 🧩 MODULE 5 — SSH KEYS (ENTERPRISE AUTH)

---

## 🔹 Lecture Topics Covered

* Public/private keys
* ssh-keygen
* ssh-copy-id
* authorized_keys

---

## 🧪 LAB 9 — SSH Key Authentication

### 🎯 Goal

Replace passwords with cryptography.

---

### 🧪 Exercise

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -p 2222 user@server
ssh -p 2222 user@server
```

---

### 🧠 What You Learn

* Cryptographic trust
* Why keys are stronger than passwords
* Foundation for automation

---

## 🧩 MODULE 6 — DISABLE PASSWORD LOGIN

---

## 🔹 Lecture Topics Covered

* PasswordAuthentication no
* sudo separation
* Recovery planning

---

## 🧪 LAB 10 — Enforce Key-Only SSH

### 🎯 Goal

Eliminate brute-force attacks.

---

### 🧪 Exercise

```ini
PasswordAuthentication no
```

Restart SSH.

Test:

```bash
ssh user@server
```

From another user → should fail.

---

### 🧠 What You Learn

* Zero-trust login
* Production hardening standard

---

## 🧩 MODULE 7 — KEEP SSH ALIVE

---

## 🔹 Lecture Topics Covered

* SSH keepalive
* Client config
* Long-running sessions

---

## 🧪 LAB 11 — Prevent Connection Drops

### 🎯 Goal

Survive long deployments.

---

### 🧪 Exercise

```bash
nano ~/.ssh/config
```

```ini
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

---

### 🧠 What You Learn

* Client vs server responsibility
* Why SSH drops connections

---

## 🧩 MODULE 8 — FINGERPRINTS & MITM PROTECTION

---

## 🔹 Lecture Topics Covered

* Fingerprints
* known_hosts
* MITM attacks

---

## 🧪 LAB 12 — Fingerprint Verification

### 🎯 Goal

Detect impostor servers.

---

### 🧪 Exercise

Client:

```bash
cat ~/.ssh/known_hosts
```

Server:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Compare hashes.

---

### 🧠 What You Learn

* Why fingerprints exist
* How SSH prevents MITM

---

## 🧩 MODULE 9 — FILE TRANSFER (SFTP / SCP)

---

## 🔹 Lecture Topics Covered

* SCP
* SFTP
* GUI tools (Cyberduck)

---

## 🧪 LAB 13 — SCP & SFTP

### 🎯 Goal

Move data securely.

---

```bash
scp -P 2222 file.txt user@server:/home/user/
scp -P 2222 user@server:/home/user/file.txt .
```

GUI:

* Connect via SFTP
* Drag & drop files

---

### 🧠 What You Learn

* Why FTP is insecure
* Secure automation transfers

---

## 🧩 MODULE 10 — SCREEN (PRODUCTION SURVIVAL TOOL)

---

## 🔹 Lecture Topics Covered

* screen
* detach/attach
* collaboration

---

## 🧪 LAB 14 — Screen Mastery

### 🎯 Goal

Survive disconnects & collaborate.

---

```bash
screen
Ctrl+A Ctrl+D
screen -x
exit
```

---

### 🧠 What You Learn

* Persistent sessions
* Remote teamwork

---

## 🏁 FINAL CAPSTONE PROJECT

### 🎯 Scenario

> You are the only DevOps engineer managing a production server.

You must:

1. Harden SSH
2. Use key auth only
3. Prevent lockout
4. Enable file transfer
5. Keep sessions alive
6. Share terminal with teammate

---

## 🎓 OUTCOME

After completing this:

* Student **can manage real servers**
* Student **understands SSH deeply**
* Student **thinks like a DevOps engineer**
* Student **can pass interviews**


