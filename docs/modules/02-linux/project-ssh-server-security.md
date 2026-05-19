---
title: "Project: SSH & Server Security"
description: "you will learn   Why DevOps uses SSH daily SSH keys (id_ed25519, authorized_keys) and..."
published: 2025-12-30
source: "https://dev.to/jumptotech/project-ssh-server-security-3lo2"
tags: []
---

# Project: SSH & Server Security

you will learn

* Why DevOps uses SSH daily
* SSH keys (`id_ed25519`, `authorized_keys`) and permissions
* Secure SSH hardening (`sshd_config`)
* File transfer with `scp` and `rsync`
* Firewall rules (UFW)
* Fail2ban basics (auto-ban attackers)
* SELinux awareness (what to know, even on Ubuntu)

---

# 0) Lab story (real company scenario)

You are a DevOps engineer. You manage Linux servers that run apps and CI/CD agents.
Your job is to:

1. Access servers safely (no passwords)
2. Deploy files/configs
3. Reduce attack surface
4. Detect and stop brute-force attempts
5. Explain it clearly in interviews

---

# 1) Lab prerequisites

### you machine(Mac or windows terminal or cli) machine

* Mac/Windows/Linux terminal
* SSH client (already installed on Mac/Linux)

### Server(ec2 ubuntu, console)

* 1 Ubuntu EC2 instance (public IP)
* Security group allows **port 22** from student IP (or temporarily from anywhere for lab)

---

# 2) Part A — Connect once using AWS Console (bootstrap access)

### Why this exists

Sometimes you don’t have a key file, or you need emergency access. AWS “Connect” gives initial access so you can set up proper keys.

**Action**

* AWS Console → EC2 → instance → **Connect** → connect

---

# 3) Part B — Create your own SSH key on the laptop

### Why DevOps needs this

* Passwords can be brute-forced
* Keys are stronger and standard in companies
* Keys are required for automation (Ansible, CI runners, GitHub Actions self-hosted runners, etc.)

**On your laptop:**

```bash
ssh-keygen -t ed25519 -C "devops-lab" -f ~/.ssh/devops_lab_ed25519
```

What to explain:

* `devops_lab_ed25519` = private key (never share)
* `devops_lab_ed25519.pub` = public key (safe to share)

Show:

```bash
ls -l ~/.ssh/devops_lab_ed25519*
cat ~/.ssh/devops_lab_ed25519.pub
```

---

# 4) Part C — Install public key on server (`authorized_keys`)

### Why this matters

SSH only allows users whose **public keys** are inside:
`~/.ssh/authorized_keys`

**On server (AWS Connect session):**

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

Paste the `.pub` line (one line), save.

Fix permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```



* `~/.ssh` must be `700`
* `authorized_keys` must be `600`
  If too open, SSH refuses keys.

Verify:

```bash
ls -ld ~/.ssh
ls -l ~/.ssh/authorized_keys
```

---

# 5) Part D — Test SSH from laptop (real DevOps access)

### Why DevOps cares

This is how you:

* run production commands
* deploy
* troubleshoot outages
* access Kubernetes nodes / bastions

**On your laptop:**

```bash
ssh -i ~/.ssh/devops_lab_ed25519 ubuntu@<PUBLIC_IP>
```

Add shortcut config (recommended):

```bash
nano ~/.ssh/config
```

Add:

```text
Host devops-lab
  HostName <PUBLIC_IP>
  User ubuntu
  IdentityFile ~/.ssh/devops_lab_ed25519
  IdentitiesOnly yes
```

Now:

```bash
ssh devops-lab
```

---

# 6) Part E — DevOps transfers: `scp` vs `rsync`

### Why DevOps needs this

* Deploy configs, scripts, artifacts
* Sync logs for investigation
* Copy backups between servers

## 6.1 Create test files locally

```bash
mkdir -p ~/ssh-lab-files
echo "version1" > ~/ssh-lab-files/app.conf
dd if=/dev/zero of=~/ssh-lab-files/big.bin bs=1M count=20
```

## 6.2 Copy with SCP

```bash
scp -r ~/ssh-lab-files devops-lab:/home/ubuntu/
```

## 6.3 Sync with RSYNC (better for updates)

Install rsync on server if needed:

```bash
ssh devops-lab "sudo apt-get update && sudo apt-get install -y rsync"
```

Run rsync:

```bash
rsync -avz --progress ~/ssh-lab-files/ devops-lab:/home/ubuntu/ssh-lab-files/
```

Change one file and rsync again:

```bash
echo "version2" >> ~/ssh-lab-files/app.conf
rsync -avz --progress ~/ssh-lab-files/ devops-lab:/home/ubuntu/ssh-lab-files/
```

Explain:

* `scp` copies everything again
* `rsync` sends only changes (fast, standard)

---

# 7) Part F — SSH hardening (production settings)

### Why DevOps does this

Stop:

* password brute force
* root login attacks
* unauthorized accounts

**On server:**
Backup:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Edit:

```bash
sudo nano /etc/ssh/sshd_config
```

Set/ensure:

```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AllowUsers ubuntu
```

Validate and restart:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

Critical teaching point:

* Always keep one session open
* Test in a new terminal:

```bash
ssh devops-lab
```

---

# 8) Part G — Firewall rules (UFW)

### Why DevOps needs firewall

Even if app is running, firewall can block it.
We open only required ports.

**On server:**

```bash
sudo apt-get install -y ufw
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

Demo: run a web server on 8080

```bash
python3 -m http.server 8080
```

In another SSH session:

```bash
sudo ufw allow 8080/tcp
sudo ufw status
```

Now students test in browser:
`http://<PUBLIC_IP>:8080`

Cleanup:

```bash
sudo ufw delete allow 8080/tcp
sudo ufw status
```

---

# 9) Part H — Fail2ban basics (auto-ban attackers)

### Why DevOps uses it

SSH gets attacked constantly. Fail2ban blocks IPs that fail login too many times.

Install:

```bash
sudo apt-get install -y fail2ban
```

Create local config:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Find `[sshd]` and set:

```text
[sshd]
enabled = true
maxretry = 5
findtime = 10m
bantime = 1h
```

Restart + check:

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

Show logs:

```bash
sudo tail -n 50 /var/log/fail2ban.log
```

Unban example:

```bash
sudo fail2ban-client set sshd unbanip <IP>
```

---

# 10) Part I — SELinux awareness (what DevOps must know)

### Key message 

Ubuntu usually uses AppArmor, but enterprises often use RHEL/Rocky with SELinux.

What to know (commands and mindset):

* SELinux blocks actions even if Linux permissions look correct
* Don’t “chmod 777” to fix SELinux problems

Must-know commands (on SELinux systems):

```bash
getenforce
sestatus
ls -Z
ps -eZ
```

Interview line:

* “If permissions look fine but access is denied, I check SELinux mode and contexts.”

---

# 11)  checklist (what  must demonstrate)



* Create key, explain private vs public
* Add key to `authorized_keys`
* Fix permissions correctly
* SSH from laptop successfully
* Use `scp` and `rsync` and explain difference
* Harden SSH config and restart safely
* Enable UFW and open/close ports
* Enable Fail2ban and check bans/logs
* Explain SELinux at high level

---

# 12) DevOps interview Q&A (short, simple)

**Q: Why do DevOps need SSH?**
A: To securely manage Linux servers: deploy, troubleshoot, edit configs, check logs, restart services.

**Q: Why keys, not passwords?**
A: Keys are stronger, not brute-forced easily, and work for automation.

**Q: What is `authorized_keys`?**
A: It’s the allow-list of public keys that can log in to that user.

**Q: Why do permissions matter?**
A: SSH refuses to use keys if `.ssh` or `authorized_keys` are too open.

**Q: scp vs rsync?**
A: `scp` copies everything. `rsync` syncs only changes and is best for deployments.

**Q: What does Fail2ban do?**
A: Watches logs and bans IPs that fail authentication too many times.


