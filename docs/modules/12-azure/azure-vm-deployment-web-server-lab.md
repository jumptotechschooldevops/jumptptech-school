---
title: "Azure VM Deployment & Web Server Lab"
description: "Objective   Deploy an Ubuntu Virtual Machine in Azure, resolve quota issues, connect via..."
published: 2026-03-03
source: "https://dev.to/jumptotech/azure-vm-deployment-web-server-lab-ae7"
tags: []
---

# Azure VM Deployment & Web Server Lab



 

## Objective

Deploy an Ubuntu Virtual Machine in Azure, resolve quota issues, connect via SSH, install Nginx, and access the server from a browser.

---

# Part 1 – Resolve Azure Quota Issues

## Problem Encountered

While creating a VM in East US region:

* B-series VM sizes were unavailable
* Error: Insufficient quota – family limit
* Availability zone conflicts

## Root Cause

New Azure subscriptions often:

* Do not enable B-series by default
* Have limited regional vCPU quotas
* Restrict burstable VM families

## Solution

Instead of waiting for quota approval:

* Switched to Standard D2s_v3
* Used Availability Zone 3
* Confirmed regional quota available

This is real-world cloud troubleshooting.

---

# Part 2 – Create Azure Virtual Machine

## Steps

1. Go to Azure Portal
2. Virtual Machines → Create
3. Configure Basics:

### Required Settings

* Subscription: Azure subscription 1
* Resource Group: devops-azure-lab
* VM Name: vm-new-lab
* Region: East US
* Availability Zone: Zone 3
* Image: Ubuntu Server 24.04 LTS
* Size: Standard D2s_v3
* Authentication Type: SSH public key
* Username: azureuser

---

## Networking

* Public IP: Enabled
* NSG: Default (auto-created)
* Open ports: 22 (SSH)

---

## Deployment Result

VM successfully deployed with:

* Public IP: 135.222.41.117
* Status: Running
* OS: Ubuntu 24.04
* Zone: 3

---

# Part 3 – Connect to VM via SSH

From Mac terminal:

```bash
ssh azureuser@135.222.41.117
```

If using a private key:

```bash
chmod 400 key.pem
ssh -i key.pem azureuser@135.222.41.117
```

First-time connection shows:

The authenticity of host can't be established
Type: yes

Login successful.

---

# Part 4 – Verify Server Environment

Inside VM:

```bash
whoami
hostname
lsb_release -a
free -h
df -h
```

Confirms:

* User
* OS version
* Memory
* Disk

---

# Part 5 – Update System

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Part 6 – Install Web Server (Nginx)

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

Verify:

```bash
sudo systemctl status nginx
```

Must show:

active (running)

---

# Part 7 – Open Port 80 in Azure

Azure Portal:

VM → Networking → Inbound rules → Add

Rule:

* Source: Any
* Protocol: TCP
* Port: 80
* Action: Allow

Save.

---

# Part 8 – Access in Browser

Open browser:

```
http://135.222.41.117
```

Expected result:

Welcome to nginx!

---

# Part 9 – Replace Default Web Page

Inside VM:

```bash
cd /var/www/html
sudo rm index.nginx-debian.html
sudo wget https://raw.githubusercontent.com/mdn/beginner-html-site/gh-pages/index.html
```

Refresh browser:

```
http://135.222.41.117
```

Custom page loads.

---

# Architecture Overview

User Browser
↓
Public IP (Azure)
↓
Network Security Group (Firewall)
↓
Virtual Machine (Ubuntu)
↓
Nginx Web Server
↓
HTML Content

---

# What Students Learned

Cloud Infrastructure:

* VM provisioning
* Public IP assignment
* NSG firewall configuration
* Availability Zones

Troubleshooting:

* vCPU quota limits
* VM family restrictions
* Availability zone mismatch
* SSH key authentication errors

Linux Administration:

* Package updates
* Service management
* Systemctl usage
* Web server deployment

Networking:

* Port exposure
* Public internet access
* Security group configuration

---

# Real-World Skills Demonstrated

* Azure quota troubleshooting
* Infrastructure deployment
* Secure SSH access
* Web server installation
* Firewall configuration
* Cloud networking validation

This is real DevOps work.


