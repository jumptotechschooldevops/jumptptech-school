---
title: "Create an Azure VM and connect with SSH (Mac)"
description: "Part A — Create the VM in Azure Portal    Azure Portal    Go to portal.azure.com  Search:..."
published: 2026-03-04
source: "https://dev.to/jumptotech/create-an-azure-vm-and-connect-with-ssh-mac-4ic4"
tags: []
---

# Create an Azure VM and connect with SSH (Mac)



### Part A — Create the VM in Azure Portal

1. **Azure Portal**

* Go to **portal.azure.com**
* Search: **Virtual machines**
* Click **Create** → **Azure virtual machine**

2. **Basics tab**

* **Subscription**: choose your subscription
* **Resource group**: **Create new** (example: `rg-devops-lab`)
* **Virtual machine name**: `vm-lab-1`
* **Region**: pick one (example: **East US**)
* **Availability options**: leave default (or “No infrastructure redundancy required” for simplest)
* **Image**: **Ubuntu Server 24.04 LTS**
* **Size**: pick something small (example: `Standard_B1s` or `Standard_B2s` if available)

3. **Administrator account (SSH)**

* **Authentication type**: **SSH public key**
* **Username**: `azureuser`
* **SSH public key source**:

  * Choose **Generate new key pair** (recommended if you don’t have one)
* **Key pair name**: `vm-lab-1_key`

4. **Inbound ports**

* Select **Allow selected ports**
* Choose **SSH (22)**

5. Click **Review + create**

* If validation passes, click **Create**
* Azure will prompt to **Download private key** → download the `.pem` file

  * Save it safely (usually in `~/Downloads`)

---

### Part B — Get the Public IP

6. After deployment:

* Go to **Virtual machines** → open your VM
* Copy **Public IP address** (example: `20.x.x.x`)

---

### Part C — SSH from Mac Terminal

7. Open **Terminal** and go to where the key is (example Downloads):

```bash
cd ~/Downloads
ls
```

8. Fix permissions on the key (required):

```bash
chmod 400 vm-lab-1_key.pem
```

9. Connect with SSH:

```bash
ssh -i vm-lab-1_key.pem azureuser@<PUBLIC_IP>
```

Example:

```bash
ssh -i vm-lab-1_key.pem azureuser@20.83.170.33
```

10. First-time prompt:

* Type `yes` and press Enter

You should land in:

```bash
azureuser@vm-lab-1:~$
```

---

## Common problems (quick fixes)

### 1) `Permission denied (publickey)`

You forgot `-i` or used the wrong key:

```bash
ssh -i correct_key.pem azureuser@<PUBLIC_IP>
```

### 2) `UNPROTECTED PRIVATE KEY FILE`

Permissions are too open:

```bash
chmod 400 *.pem
```

### 3) SSH times out / hangs

Port 22 blocked:

* Azure Portal → VM → **Networking**
* Ensure **Inbound rule** allows **TCP 22**
* If you restricted Source to your IP, verify your current public IP


