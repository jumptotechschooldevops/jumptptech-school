---
title: "3-Tier Lab (Web + App + DB)"
description: "Target Architecture     ALB (public) → routes HTTP to Web tier (Nginx)   Web tier (EC2 ASG)..."
published: 2026-02-26
source: "https://dev.to/jumptotech/3-tier-lab-web-app-db-27ef"
tags: []
---

# 3-Tier Lab (Web + App + DB)


## Target Architecture 

* **ALB (public)** → routes HTTP to **Web tier (Nginx)**
* **Web tier (EC2 ASG)** → reverse proxies to **App tier**
* **App tier (EC2 ASG)** → runs a simple Node.js API (or Python Flask)
* **DB tier (RDS MySQL/Postgres)** → app connects privately
* **Ansible** configures EC2 instances (web/app)
* **Terraform** provisions AWS resources
* **GitLab CI** runs Terraform + Ansible automatically on push


1. Launch **3 EC2** (or 2 EC2 + RDS):

   * `web-1` (public subnet, port 80 open from ALB only)
   * `app-1` (private subnet, port 3000 from web SG only)
   * `db` (RDS in private subnet, port 3306/5432 from app SG only)

2. Validate connectivity:

   * `web → app` works (curl app private IP)
   * `app → db` works (connect using client)

### Minimal app idea

A tiny API endpoint:

* `GET /health` returns OK
* `GET /` returns “Hello from app”

---

# B) Add Load Balancer + Auto Deploy App

## 1) ALB in front of Web

* Create **ALB** (public subnets)
* Target group → **web ASG** (port 80)

## 2) Web reverse proxies to App

Nginx config (Ansible-managed) proxies `/api` to app target group.

Example Nginx snippet (concept):

```nginx
location /api/ {
  proxy_pass http://APP_INTERNAL_DNS_OR_LB:3000/;
}
```

## 3) Auto deploy app (Ansible)

Ansible deploys:

* Node.js runtime
* app code (git clone or artifact download)
* systemd service
* starts/restarts app

Students “feel” automation because they push code, run playbook, and traffic updates.

---

# C) Production-Style Ansible Roles Structure

Teach them this structure early (this is what companies expect):

```
ansible/
  inventories/
    dev/
      hosts.ini
    prod/
      hosts.ini
  group_vars/
    web.yml
    app.yml
  roles/
    common/
      tasks/main.yml
    web/
      tasks/main.yml
      templates/nginx.conf.j2
      handlers/main.yml
    app/
      tasks/main.yml
      templates/app.service.j2
      handlers/main.yml
  site.yml
```

## `site.yml` (top-level playbook)

```yaml
- hosts: web
  become: yes
  roles:
    - common
    - web

- hosts: app
  become: yes
  roles:
    - common
    - app
```



# D) Terraform + Ansible Combined Lab (Real DevOps pattern)

## Pattern used in many teams

* Terraform creates infrastructure
* Terraform outputs inventory info (IPs/DNS)
* Ansible configures software

### Terraform outputs example (concept)

* `web_public_ips`
* `app_private_ips`
* `alb_dns_name`

Then generate Ansible inventory from outputs.

**Simple approach (beginner-friendly):**

1. `terraform output -json > tfoutput.json`
2. small script converts it to `hosts.ini`

Example inventory template result:

```ini
[web]
<web_ip_1>
<web_ip_2>

[app]
<app_ip_1>
<app_ip_2>
```


**infra and config are separate, but connected.**

---

# E) GitLab CI/CD Deployment Using GitLab (Terraform + Ansible)

## Repo approach 

One repo with:

* `/terraform`
* `/ansible`
* `.gitlab-ci.yml`

Pipeline stages:

1. **validate** (fmt/validate)
2. **plan**
3. **apply** (manual in prod)
4. **configure** (run ansible)

### Example `.gitlab-ci.yml` (minimal concept)

```yaml
stages: [validate, plan, apply, configure]

validate:
  stage: validate
  script:
    - cd terraform
    - terraform fmt -check
    - terraform validate

plan:
  stage: plan
  script:
    - cd terraform
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - terraform/tfplan

apply:
  stage: apply
  when: manual
  script:
    - cd terraform
    - terraform apply -auto-approve tfplan

configure:
  stage: configure
  script:
    - cd terraform
    - terraform output -json > ../ansible/tfoutput.json
    - cd ../ansible
    - ./gen_inventory.sh tfoutput.json > inventories/prod/hosts.ini
    - ansible-playbook -i inventories/prod/hosts.ini site.yml
```



* Why **apply** is manual in prod
* CI/CD runs config automatically after infra is ready


