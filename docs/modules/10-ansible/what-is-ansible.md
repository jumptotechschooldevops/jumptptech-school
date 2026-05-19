---
title: "What is Ansible?"
description: "Ansible is an open-source automation tool used for:   Configuration management Application..."
published: 2026-02-26
source: "https://dev.to/jumptotech/what-is-ansible-3589"
tags: []
---

# What is Ansible?


![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Ansible_logo.svg/500px-Ansible_logo.svg.png)

![Image](https://www.techtarget.com/rms/onlineImages/it_ops-ansible_yaml_1_mobile.jpg)

![Image](https://miro.medium.com/v2/da%3Atrue/resize%3Afit%3A1200/0%2AsMSfIbPO8mH299to)

![Image](https://us1.discourse-cdn.com/ansible/original/2X/c/cb5aab2229d7c6cfeb73afd42464a27ccc95f518.svg)

**Ansible** is an **open-source automation tool** used for:

* Configuration management
* Application deployment
* Infrastructure provisioning
* Orchestration

It helps DevOps engineers automate tasks on multiple servers at the same time.

---

## Who created it?

* Originally created by **Michael DeHaan**
* Now owned and maintained by **Red Hat**

---

## How Ansible Works (Simple)

Ansible uses:

* **Control Node** → your machine (where Ansible runs)
* **Managed Nodes** → remote servers
* **SSH** → to connect (no agent needed)

Unlike many tools, Ansible is **agentless** — you don’t install anything on target servers.

---

## Core Components

### 1. Inventory

List of servers:

```ini
[web]
192.168.1.10
192.168.1.11
```

---

### 2. Playbook (YAML file)

Automation instructions written in YAML:

```yaml
- hosts: web
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
```

---

### 3. Modules

Prebuilt functions (like plugins):

* apt
* yum
* copy
* file
* service
* user

---

## Why DevOps Engineers Use Ansible

Since you teach DevOps and work heavily with AWS:

You can use Ansible to:

* Configure EC2 instances
* Install Docker automatically
* Deploy applications
* Configure Nginx
* Manage users
* Set up Kubernetes nodes
* Patch servers

Example:

```bash
ansible all -m ping
```

Tests connection to all servers.

---

## Where Ansible Fits in DevOps

| Tool       | Purpose                |
| ---------- | ---------------------- |
| Terraform  | Create infrastructure  |
| Ansible    | Configure servers      |
| Docker     | Containerize apps      |
| Kubernetes | Orchestrate containers |

---

## Simple Real-World Example

Instead of logging into 20 EC2 servers and running:

```bash
sudo apt update
sudo apt install docker -y
```

You run **one playbook**, and Ansible does it everywhere automatically.





Ansible is a **configuration management and automation tool**.

It is used to:

* Configure servers
* Install software
* Deploy applications
* Enforce system state
* Automate operational tasks

In DevOps terms:

Terraform → Creates infrastructure
Ansible → Configures infrastructure

---

# 2️⃣ Why DevOps Engineers Use Ansible

Without Ansible:

* SSH into server
* Install packages manually
* Configure services manually
* Risk human errors
* No repeatability

With Ansible:

* Infrastructure as Code
* Repeatable configuration
* Version controlled
* Scalable automation

---

# 3️⃣ How Ansible Works

## Architecture

![Image](https://miro.medium.com/v2/da%3Atrue/resize%3Afit%3A1200/0%2AsMSfIbPO8mH299to)

![Image](https://miro.medium.com/0%2AUUE-khFeEwuKC_VM)

![Image](https://www.oreilly.com/api/v2/epubs/urn%3Aorm%3Abook%3A9781788299558/files/assets/8a9607f9-4fee-4ac4-8164-17e2d31d1c27.png)

![Image](https://cdn.hashnode.com/res/hashnode/image/upload/v1683908520759/a171f6c9-2e38-4569-94fb-d42e7645d6e3.png)

Ansible is:

* Agentless
* Push-based
* Uses SSH

Components:

Control Node
→ Where Ansible runs (Mac, CI server, etc.)

Managed Nodes
→ Remote servers (EC2, VM, etc.)

Inventory
→ List of servers

Playbook
→ YAML automation file

Modules
→ Built-in automation tasks

---

# 4️⃣ Core Concepts Every DevOps Engineer Must Know

---

## 1. Inventory

Defines groups of servers.

Example:

```ini
[web]
3.141.22.178

[db]
3.141.22.200
```

Why important:
You deploy different configurations to different environments.

---

## 2. Playbooks (YAML)

Playbooks define desired state.

Example:

```yaml
- hosts: web
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
```

DevOps Insight:
This is declarative.
You define state, not commands.

---

## 3. Idempotency (VERY IMPORTANT)

If you run playbook 10 times:

Result = same state.

This is critical for production systems.

DevOps engineers must understand:
Automation must be safe to re-run.

---

## 4. Modules

Examples:

* apt
* yum
* copy
* file
* service
* user
* git
* docker_container

You must know how to read module documentation.

---

## 5. Variables

Used to make playbooks reusable.

Example:

```yaml
vars:
  package_name: nginx
```

Professional DevOps work heavily with variables.

---

## 6. Handlers

Handlers run only when triggered.

Example:

If config file changes → restart service.

This prevents unnecessary restarts.

Production best practice.

---

## 7. Roles (Production Structure)

Instead of one big playbook, companies use:

```
roles/
  nginx/
    tasks/
    handlers/
    vars/
```

Roles = reusable automation components.

Every DevOps engineer should know roles.

---

## 8. Ansible vs Terraform (Important Interview Topic)

Terraform:

* Provisions infrastructure
* Cloud-focused
* Creates EC2, VPC, etc.

Ansible:

* Configures inside the server
* Installs software
* Manages services

They are complementary.

---

# 5️⃣ Real DevOps Use Cases

In real companies, Ansible is used for:

* OS hardening
* Patch management
* Application deployment
* CI/CD automation
* Server configuration
* Kubernetes node setup
* Docker installation
* Log configuration
* Security compliance

---

# 6️⃣ Ansible in CI/CD

Ansible can run inside:

* Jenkins
* GitLab CI
* GitHub Actions

Example flow:

Code push → CI builds Docker image → Ansible deploys to server

This is common in smaller companies without Kubernetes.

---

# 7️⃣ What You Should Know for Interviews

DevOps engineer must understand:

* How inventory works
* How SSH connection works
* What idempotency means
* Difference between ad-hoc and playbook
* How handlers work
* How variables work
* What roles are
* How to troubleshoot connection issues
* How to structure project properly

---

# 8️⃣ Common  Mistakes

* Using shell instead of modules
* Not using handlers
* Hardcoding values
* Not grouping servers
* Ignoring idempotency
* Running playbooks without understanding output

---

# 9️⃣ Ansible Execution Flow

1. Read inventory
2. Connect via SSH
3. Gather facts
4. Execute tasks
5. Trigger handlers if needed
6. Print result summary

---

# 10️⃣ Ansible Output Understanding

Example:

```
ok=3
changed=1
failed=0
```

DevOps must understand:

ok → Already in correct state
changed → System modified
failed → Task failed
















## Lab: Install and Configure Nginx on EC2 Using Ansible

---

## Lab Architecture

![Image](https://www.endpointdev.com/blog/2022/08/ansible-tutorial-with-aws-ec2/ansible01.webp)

![Image](https://miro.medium.com/0%2AUUE-khFeEwuKC_VM)

![Image](https://www.researchgate.net/publication/364137703/figure/fig1/AS%3A11431281180917193%401691759671671/EC2-System-Architecture.jpg)

![Image](https://www.tutorialspoint.com/amazon_web_services/images/architecture.jpg)

**Flow:**

Mac (Control Node)
→ SSH
→ EC2 Instance (Managed Node)
→ Install Nginx automatically

---

# Lab Objective

By the end of this lab, students will:

* Install Ansible
* Create inventory file
* Write first playbook
* Install Nginx on EC2
* Verify deployment in browser

---

# Step 1 – Launch EC2 Instance

In AWS:

* AMI: Ubuntu 22.04
* Instance type: t2.micro
* Security Group:

  * Port 22 (SSH) – Your IP
  * Port 80 (HTTP) – Anywhere
* Attach IAM Role (optional)

Make sure you can SSH:

```bash
ssh -i key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

# Step 2 – Install Ansible (On Your Mac)

```bash
brew install ansible
```

Verify:

```bash
ansible --version
```

---

# Step 3 – Create Project Folder

```bash
mkdir ansible-lab
cd ansible-lab
```

---

# Step 4 – Create Inventory File

Create file: `inventory.ini`

```ini
[web]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/key.pem
```

Test connection:

```bash
ansible web -i inventory.ini -m ping
```

Expected output:

```
SUCCESS
```

If this works → SSH + Ansible are configured correctly.

---

# Step 5 – Create First Playbook

Create file: `install-nginx.yml`

```yaml
- name: Install and start Nginx
  hosts: web
  become: yes

  tasks:
    - name: Update apt
      apt:
        update_cache: yes

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

---

# Step 6 – Run Playbook

```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

Students will see:

* TASK [Update apt]
* TASK [Install nginx]
* TASK [Start nginx]

---

# Step 7 – Verify

Open browser:

```
http://<EC2_PUBLIC_IP>
```

You should see:

**Welcome to Nginx**

---

# Step 8 – Make It More Real (Optional)

Modify playbook to deploy custom HTML page:

Add this task:

```yaml
    - name: Create custom index page
      copy:
        dest: /var/www/html/index.html
        content: |
          <h1>Welcome to JumpToTech DevOps Lab</h1>
```

Run again:

```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

Refresh browser.

---



* Agentless automation
* YAML basics
* Infrastructure configuration
* Idempotency (run playbook twice → no changes)
* SSH automation
* Real DevOps workflow













