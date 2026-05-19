---
title: "LAB: 2 EC2 Servers + Group-Based Deployment"
description: "Objective    Inventory groups Deploy different software to different servers Run playbook..."
published: 2026-02-26
source: "https://dev.to/jumptotech/lab-2-ec2-servers-group-based-deployment-5big"
tags: []
---

# LAB: 2 EC2 Servers + Group-Based Deployment





# Objective



* Inventory groups
* Deploy different software to different servers
* Run playbook against specific group
* Use variables per group
* Understand real-world environment separation

---

# Architecture

![Image](https://miro.medium.com/1%2ABackGXABGa2hArkGDv-OCQ.png)

![Image](https://miro.medium.com/0%2ASr1T30hc8WT269jV)

![Image](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/sql-server-ec2-ha-dr/images/two-node-ag.png)

![Image](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/sql-server-ec2-ha-dr/images/single-node.png)

Control Node (Mac)
↓ SSH
EC2-1 → Web Server
EC2-2 → DB Server

---

# Step 1 — Launch 2 EC2 Instances

Both:

* Ubuntu 22.04
* Port 22 open
* Port 80 open (for web)
* Same key pair

Example IPs:

Web: `3.141.22.178`
DB: `3.141.25.200`

---

# Step 2 — Create Inventory with Groups

Edit `inventory.ini`

```ini
[web]
3.141.22.178 ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/pem/key.pem

[db]
3.141.25.200 ansible_user=ubuntu ansible_ssh_private_key_file=~/Downloads/pem/key.pem
```

Test:

```bash
ansible all -i inventory.ini -m ping
```

Both should return pong.

---

# Step 3 — Create Group-Based Playbook

Create:

```bash
vim multi-server.yml
```

Paste:

```yaml
- name: Configure Web Server
  hosts: web
  become: yes

  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes


- name: Configure Database Server
  hosts: db
  become: yes

  tasks:
    - name: Install mysql
      apt:
        name: mysql-server
        state: present

    - name: Start mysql
      service:
        name: mysql
        state: started
        enabled: yes
```

---

# Step 4 — Run Playbook

```bash
ansible-playbook -i inventory.ini multi-server.yml
```

Students will observe:

* Web server installs nginx only
* DB server installs MySQL only
* Separate execution blocks

---

# Step 5 — Verify

Web server:

```
http://3.141.22.178
```

Should show nginx.

SSH into DB server:

```bash
systemctl status mysql
```

---

# Step 6 — Run Against Specific Group

Only deploy to web:

```bash
ansible-playbook -i inventory.ini multi-server.yml --limit web
```

This teaches targeting.

---

# Step 7 — Add Group Variables (Important)

Create folder:

```bash
mkdir group_vars
```

Create:

```bash
vim group_vars/web.yml
```

```yaml
package_name: nginx
```

Create:

```bash
vim group_vars/db.yml
```

```yaml
package_name: mysql-server
```

Now modify playbook:

```yaml
- name: Install package
  apt:
    name: "{{ package_name }}"
    state: present
```



Group → Variable → Behavior change

This is real DevOps practice.





# Real Industry Connection

In production:

[web] → Auto Scaling Group
[db] → RDS or DB cluster
[monitoring] → Prometheus servers
[workers] → Background processors

Ansible handles configuration layer.



