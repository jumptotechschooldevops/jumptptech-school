---
title: "AZURE NETWORKING + VM LAB"
description: "This document builds:   Resource Group Virtual Network (VNet) Public Subnet Private Subnet NAT..."
published: 2026-03-02
source: "https://dev.to/jumptotech/azure-networking-vm-lab-53gg"
tags: []
---

# AZURE NETWORKING + VM LAB


This document builds:

* Resource Group
* Virtual Network (VNet)
* Public Subnet
* Private Subnet
* NAT Gateway
* Network Security Group (NSG)
* Public VM
* Private VM
* Full connectivity test

---

 

## (AWS-Style Architecture in Azure)

---

# 🎯 LAB OBJECTIVE

  build a production-style cloud network in Microsoft Azure similar to AWS architecture.

By the end of this lab  will understand:

* Azure Resource Groups
* Virtual Network (VNet)
* Subnets
* NAT Gateway
* Network Security Groups
* Public vs Private VMs
* Inbound vs Outbound traffic control
* SSH connectivity
* Internet access from private subnet

---

# 🧠 AWS vs Azure Terminology

| AWS              | Azure                        |
| ---------------- | ---------------------------- |
| VPC              | Virtual Network (VNet)       |
| Subnet           | Subnet                       |
| Security Group   | Network Security Group (NSG) |
| Internet Gateway | Built-in internet routing    |
| NAT Gateway      | NAT Gateway                  |
| Elastic IP       | Public IP                    |
| EC2              | Virtual Machine              |

---

# STEP 1 — Create Resource Group

Resource Group is a logical container for all resources.

### Go to:

portal.azure.com

Search:
Resource groups

Click:

* Create

Fill:

Subscription: Azure subscription
Resource group name: rg-devops-lab
Region: East US

Click Review + Create
Click Create

---

# STEP 2 — Create Virtual Network (VNet)

VNet is equivalent to AWS VPC.

### Go to:

Virtual networks → + Create

Fill:

Resource Group: rg-devops-lab
Name: vnet-devops
Region: East US

Address Space:
10.0.0.0/16

Click Next until Review
Click Create

---

# STEP 3 — Create Subnets

Inside VNet create two subnets.

Go to:
vnet-devops → Subnets → + Subnet

---

## Public Subnet

Name: subnet-web
Starting Address: 10.0.1.0
Size: /24

Click Add

---

## Private Subnet

Name: private-subnet
Starting Address: 10.0.2.0
Size: /24

Click Add

---

Now architecture:

VNet (10.0.0.0/16)

* subnet-web (10.0.1.0/24)
* private-subnet (10.0.2.0/24)

---

# STEP 4 — Create NAT Gateway

Purpose:
Allow private subnet to access internet outbound only.

Search:
NAT Gateway → + Create

Fill:

Name: nat-devops
Region: East US
Resource Group: rg-devops-lab
SKU: Standard

Click Next

Outbound IP → Add Public IP

Create new:
Name: nat-public-ip
Assignment: Static

Click OK

Next → Networking

Virtual Network: vnet-devops
Subnet: private-subnet

Click Review + Create
Click Create

---

Now private subnet has outbound internet access.

---

# STEP 5 — Create Network Security Group (NSG)

Purpose:
Control inbound and outbound traffic.

Search:
Network Security Groups → + Create

Fill:

Name: nsg-public
Resource Group: rg-devops-lab
Region: East US

Click Create

---

# STEP 6 — Add Inbound Rules

Go to:
nsg-public → Inbound security rules → + Add

---

## Rule 1 — SSH

Protocol: TCP
Source: Any
Source Port: *
Destination: Any
Destination Port: 22
Action: Allow
Priority: 100
Name: allow-ssh

Click Add

---

## Rule 2 — HTTP

Protocol: TCP
Source: Any
Destination Port: 80
Action: Allow
Priority: 110
Name: allow-http

Click Add

---

Note:
Lower number = higher priority.

Azure evaluates rules from lowest to highest number.

---

# STEP 7 — Attach NSG to Public Subnet

Go to:
Virtual Networks → vnet-devops → Subnets → subnet-web → Edit

Scroll to:

Network security group

Select:
nsg-public

Click Save

---

Now subnet-web is protected.

---

# STEP 8 — Create Public Virtual Machine

Search:
Virtual machines → + Create → Azure VM

---

## Basics Tab

Name: vm-public
Resource Group: rg-devops-lab
Region: East US
Image: Ubuntu 22.04 LTS
Size: Standard B1s

Authentication:
SSH public key
Username: azureuser
Generate new key pair
Key name: vm-public-key

Inbound ports:
Allow selected ports → SSH

Click Next

---

## Networking Tab

Virtual network: vnet-devops
Subnet: subnet-web
Public IP: Create new

NIC Network Security Group:
None
(We already attached NSG to subnet)

Click Review + Create
Click Create

Download private key file.

---

# STEP 9 — SSH Into Public VM

From Mac terminal:

chmod 400 vm-public-key.pem

ssh -i vm-public-key.pem azureuser@PUBLIC_IP

If successful → SSH works.

---

# STEP 10 — Install Web Server

Inside VM:

sudo apt update
sudo apt install nginx -y

Open browser:
http://PUBLIC_IP

You should see nginx page.

---

# STEP 11 — Create Private VM

Create another VM:

Name: vm-private
Subnet: private-subnet
Public IP: None

Authentication:
SSH key

Create.

---

# STEP 12 — Test NAT Functionality

SSH into public VM first.

From public VM:

ssh azureuser@PRIVATE_IP

Once inside private VM:

sudo apt update

If it downloads packages → NAT is working.

Private VM has internet outbound only.

---

# FINAL ARCHITECTURE

Internet
↓
Public IP
↓
vm-public
↓
subnet-web
↓
NSG

Private side:

vm-private
↓
private-subnet
↓
NAT Gateway
↓
Internet (outbound only)



# WHAT  LEARN

* Cloud networking design
* Subnet segmentation
* Traffic control
* Security layers
* NAT architecture
* SSH connectivity
* Public vs Private workloads
* Azure vs AWS differences


