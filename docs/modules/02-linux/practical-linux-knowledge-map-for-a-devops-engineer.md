---
title: "practical Linux knowledge map for a DevOps engineer"
description: "1. Linux Basics (Must-Know)   You use this every day   File system structure: /, /etc, /var,..."
published: 2025-12-29
source: "https://dev.to/jumptotech/practical-linux-knowledge-map-for-a-devops-engineer-1kmo"
tags: []
---

# practical Linux knowledge map for a DevOps engineer



## 1. Linux Basics (Must-Know)

**You use this every day**

* File system structure: `/`, `/etc`, `/var`, `/opt`, `/home`, `/tmp`
* Absolute vs relative paths
* Basic commands:

  * `ls`, `cd`, `pwd`, `cp`, `mv`, `rm`, `mkdir`, `touch`
  * `cat`, `less`, `head`, `tail`
* File permissions:

  * `chmod`, `chown`
  * Read/write/execute (`rwx`)
* Users & groups:

  * `useradd`, `userdel`, `groupadd`
  * `/etc/passwd`, `/etc/group`
  * `sudo`, `/etc/sudoers`

**Interview focus:**
“How do you restrict access to files?”
“How do you give sudo access safely?”

---

## 2. Process & Resource Management

**How Linux runs applications**

* Processes:

  * `ps`, `top`, `htop`
  * `kill`, `kill -9`
* System load & resources:

  * CPU, memory, swap
  * `free -m`, `uptime`, `vmstat`
* Background & foreground:

  * `&`, `jobs`, `bg`, `fg`, `nohup`

**Real-world usage:**
Killing stuck services, finding memory leaks, CPU spikes.

---

## 3. Networking (Very Important for DevOps)

* Network basics:

  * IP, ports, DNS, routing
* Commands:

  * `ip a`, `ip r`
  * `ss`, `netstat`
  * `ping`, `traceroute`
  * `curl`, `wget`
* Firewalls:

  * `ufw`, `iptables`
* Port troubleshooting:

  * `lsof -i :8080`

**Interview focus:**
“Service is up but not reachable — what do you check?”

---

## 4. Disk & Storage

**Used heavily in cloud**

* Disk commands:

  * `lsblk`, `df -h`, `du -sh`
* Mounting:

  * `mount`, `umount`
  * `/etc/fstab`
* Partitions:

  * `fdisk`, `parted`
* Filesystems:

  * `ext4`, `xfs`
* LVM (important):

  * `pvcreate`, `vgcreate`, `lvcreate`
  * Resize volumes safely

**AWS relevance:**
EBS volumes, resizing disks without downtime.

---

## 5. Logs & Troubleshooting

**One of the most critical DevOps skills**

* Log locations:

  * `/var/log/syslog`
  * `/var/log/messages`
  * `/var/log/auth.log`
* `journalctl`:

  * `journalctl -u nginx`
  * `journalctl --since today`
* Application logs vs system logs

**Interview focus:**
“How do you debug a failed service?”

---

## 6. Services & Systemd

**How applications start**

* Service management:

  * `systemctl start|stop|restart`
  * `systemctl status`
  * `systemctl enable`
* Service files:

  * `/etc/systemd/system/*.service`
* Startup behavior

**Real-world:**
Restarting apps, debugging startup failures.

---

## 7. Package Management

* Ubuntu/Debian:

  * `apt`, `apt-get`
* RedHat/CentOS:

  * `yum`, `dnf`
* Install, update, remove packages
* Repositories

---

## 8. Shell & Bash (Core DevOps Skill)

**Automation starts here**

* Bash basics:

  * Variables, environment variables
  * `$PATH`
* Redirection & pipes:

  * `>`, `>>`, `<`, `|`
* Text processing:

  * `grep`, `awk`, `sed`, `cut`, `sort`, `uniq`, `wc`
* Scripts:

  * `if`, `for`, `while`
  * Functions
* Cron jobs:

  * `crontab -e`

**Interview focus:**
“How do you automate repetitive tasks?”

---

## 9. SSH & Security

* SSH:

  * `ssh`, `scp`, `rsync`
  * SSH keys (`id_rsa`, `authorized_keys`)
* Permissions & security basics
* Firewall rules
* Fail2ban basics
* SELinux (basic awareness)

---

## 10. Containers & Linux

**Docker and Kubernetes depend on Linux**

* Namespaces & cgroups (concept)
* File permissions inside containers
* Volume mounts
* Networking inside containers

---

## 11. Monitoring & Performance

* Tools:

  * `top`, `htop`, `iotop`
  * `sar`, `dstat`
* Disk I/O vs CPU vs Memory issues

---

## What Companies Expect (Summary)

A DevOps engineer **must be able to**:

* SSH into servers
* Debug issues using logs
* Manage services
* Handle disks and networking
* Write Bash scripts
* Secure access
* Support Docker/Kubernetes workloads

---

## DevOps Interview Reality

You are **not expected to be a Linux kernel developer**, but you **are expected to**:

* Fix broken servers
* Debug production issues
* Automate tasks
* Understand what Linux is doing under the hood


