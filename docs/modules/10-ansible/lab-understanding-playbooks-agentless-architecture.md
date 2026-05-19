---
title: "LAB: Understanding Playbooks & Agentless Architecture"
description: "Objective    Prove Ansible is agentless Understand playbook structure See fact..."
published: 2026-02-26
source: "https://dev.to/jumptotech/lab-understanding-playbooks-agentless-architecture-41ih"
tags: []
---

# LAB: Understanding Playbooks & Agentless Architecture



# 

## Objective



* Prove Ansible is agentless
* Understand playbook structure
* See fact gathering
* Observe idempotency
* Understand execution order

---

# Architecture

![Image](https://miro.medium.com/v2/da%3Atrue/resize%3Afit%3A1200/0%2AsMSfIbPO8mH299to)

![Image](https://miro.medium.com/0%2ASr1T30hc8WT269jV)

![Image](https://www.researchgate.net/publication/368672298/figure/fig10/AS%3A11431281125130708%401678217014022/Flow-diagram-of-the-Ansible-playbook-for-disk-and-link-measurement-collections-and.png)

![Image](https://repository-images.githubusercontent.com/108265239/f489cc00-88aa-11e9-9967-8a4f0dbcb0d1)

Mac (Control Node)
↓ SSH
EC2 Ubuntu (Managed Node)

No agent installed on EC2.

---

# Step 1 — Prove It Is Agentless

SSH into EC2:

```bash
ssh -i ~/Downloads/pem/key.pem ubuntu@3.141.22.178
```

Now check:

```bash
ps aux | grep ansible
```

You will see:

Nothing running.

Ask students:

“If Ansible works, where is the agent?”

Answer:
There is none.

Ansible connects via SSH, executes modules remotely, and exits.

Exit EC2.

---

# Step 2 — Create Playbook to See Execution Flow

Create:

```bash
vim playbook-demo.yml
```

Paste:

```yaml
- name: Playbook Behavior Demo
  hosts: web
  become: yes

  tasks:

    - name: Show hostname
      command: hostname

    - name: Create test file
      file:
        path: /tmp/ansible-test.txt
        state: touch

    - name: Write content into file
      copy:
        dest: /tmp/ansible-test.txt
        content: "Hello from Ansible"

    - name: Install htop
      apt:
        name: htop
        state: present
```

---

# Step 3 — Run Playbook

```bash
ansible-playbook -i inventory.ini playbook-demo.yml
```

Students observe:

1. Gathering Facts
2. Tasks executed in order
3. changed vs ok

---

# Step 4 — Run It Again

Run again:

```bash
ansible-playbook -i inventory.ini playbook-demo.yml
```

Now students see:

* hostname → ok
* file → ok
* copy → ok
* htop → ok
* changed = 0

Ask them:

“Did Ansible re-install htop?”

Answer:
No. Because state was already correct.

This is idempotency.

---

# Step 5 — Disable Fact Gathering

Now modify playbook:

Add:

```yaml
gather_facts: no
```

Like this:

```yaml
- name: Playbook Behavior Demo
  hosts: web
  become: yes
  gather_facts: no
```

Run again.

Students will see:
No "Gathering Facts" step.

Explain:

Ansible automatically collects system info using setup module.

---

# Step 6 — Observe SSH Activity

Run with verbose mode:

```bash
ansible-playbook -i inventory.ini playbook-demo.yml -vvv
```

Students will see:

* SSH connection
* Module transfer
* Execution
* Cleanup

Explain:

Ansible copies module temporarily → executes → removes it.

That proves:

Agentless + push-based.

---

# Step 7 — Break Something Intentionally

SSH into EC2:

```bash
sudo rm /tmp/ansible-test.txt
```

Run playbook again.

Now students see:

changed=1

Explain:

Ansible detected missing state and corrected it.


