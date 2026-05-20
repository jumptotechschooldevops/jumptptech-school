---
title: "LAB: Deploy Nginx with Variables, Templates & Handlers"
description: "🎯 Objective    Use common modules (apt, template, service) Understand variables See variable..."
published: 2026-02-27
source: "https://dev.to/jumptotech/lab-deploy-nginx-with-variables-templates-handlers-454n"
tags: []
---

# LAB: Deploy Nginx with Variables, Templates & Handlers



# 
## 🎯 Objective



* Use common modules (`apt`, `template`, `service`)
* Understand variables
* See variable precedence in action
* Use Jinja2 template
* Trigger handler on config change
* Observe idempotency

---

# 🏗 Architecture

![Image](https://miro.medium.com/v2/da%3Atrue/resize%3Afit%3A1200/0%2AsMSfIbPO8mH299to)

![Image](https://miro.medium.com/0%2AUUE-khFeEwuKC_VM)

![Image](https://miro.medium.com/1%2ARNqdUIDLAcKlwz9bWhXYjA.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AxFRFI3zc_J8D45cr)

Flow:

Mac (Control Node)
→ SSH
→ 2 Ubuntu EC2 Instances
→ Install & Configure Nginx

---

# 🔹 Step 1 – Launch 2 EC2 Instances

AMI: Ubuntu 22.04
Instance type: t2.micro
Security Group:

* Port 22 (SSH)
* Port 80 (HTTP)

---

# 🔹 Step 2 – Install Ansible (Control Node)

```bash
brew install ansible
```

Verify:

```bash
ansible --version
```

---

# 🔹 Step 3 – Create Inventory

`inventory.ini`

```ini
[web]
node1 ansible_host=3.x.x.x
node2 ansible_host=18.x.x.x

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/Downloads/key.pem
```

Test:

```bash
ansible web -i inventory.ini -m ping
```

---

# 🔹 Step 4 – Create Project Structure

```bash
ansible-nginx-lab/
│
├── inventory.ini
├── deploy.yml
├── group_vars/
│   └── web.yml
└── templates/
    └── nginx.conf.j2
```

---

# 🔹 Step 5 – Variables (Group Level)

`group_vars/web.yml`

```yaml
app_port: 80
server_name: jumptotech.local
welcome_message: "Welcome to JumpToTech DevOps Lab"
```

---

# 🔹 Step 6 – Create Template (Jinja2)

`templates/nginx.conf.j2`

```server {
    listen {{ app_port }};
    server_name {{ server_name }};

    location / {
        default_type text/plain;
        return 200 "{{ welcome_message }}\n";
    }
}
```

Students now see:
👉 Variables being injected dynamically.

---

# 🔹 Step 7 – Create Playbook

`deploy.yml`

```yaml
- name: Deploy Nginx with Template
  hosts: web
  become: yes

  vars:
    server_name: override.local   # Playbook variable (higher precedence)

  tasks:

    - name: Install nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Deploy nginx config from template
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/default
      notify: Restart nginx

    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

---

# 🔹 Step 8 – Run Playbook

```bash
ansible-playbook -i inventory.ini deploy.yml
```

Open browser:

```
http://<EC2-IP>
```

You should see:

```
Welcome to JumpToTech DevOps Lab
```

---

# 🔥 What Students Just Learned

## ✅ Modules

* apt
* template
* service

## ✅ Variables

* group_vars
* playbook vars

## ✅ Variable Precedence

We defined:

In group_vars:

```yaml
server_name: jumptotech.local
```

In playbook:

```yaml
vars:
  server_name: override.local
```

Result?

Playbook variable wins.

To prove precedence:

Run with extra variable:

```bash
ansible-playbook -i inventory.ini deploy.yml -e "server_name=prod.local"
```

Extra vars override everything.

Precedence (simplified):

lowest → highest

1. role defaults
2. group_vars
3. play vars
4. extra vars (-e)

---

## ✅ Template

Jinja2 variable rendering

---

## ✅ Handler

Handler only runs if template changes.

Test it:

Run playbook again without changes:

You’ll see:

```
ok=3 changed=0
```

Handler will NOT run.

Now change welcome_message in group_vars and rerun.

Handler triggers.


