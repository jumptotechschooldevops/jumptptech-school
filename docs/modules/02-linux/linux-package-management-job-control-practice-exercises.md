---
title: "Linux Package Management & Job Control – Practice Exercises"
description: "PART 1 — Bash Jobs &amp; Process Control               Exercise 1 — Job vs Process..."
published: 2025-12-26
source: "https://dev.to/jumptotech/linux-package-management-job-control-practice-exercises-18fa"
tags: []
---

# Linux Package Management & Job Control – Practice Exercises



## PART 1 — Bash Jobs & Process Control

---

### **Exercise 1 — Job vs Process (Foreground job)**

**Goal**
Understand what a *job* is vs a *process* and why pipelines are one job.

**Task**

```bash
ping -c 5 google.com | wc -l
```

**Observe**

* Two processes (`ping`, `wc`)
* One job (single command)

**Why it matters**

* Bash job control operates on **jobs**, not individual processes
* Important for debugging pipelines

---

### **Exercise 2 — Foreground Job Blocking the Shell**

**Task**

```bash
ping google.com
```

Try typing another command.

**Observe**

* Shell is blocked
* Keyboard input goes to the job

Stop it:

```bash
Ctrl + C
```

**Production relevance**

* Long-running commands can block automation scripts

---

### **Exercise 3 — Background Job (`&`)**

**Task**

```bash
ping -c 10 google.com &
```

**Observe**

* Shell returns immediately
* Output still appears

Check job list:

```bash
jobs
```

**Why it matters**

* Background execution without output control can clutter logs

---

### **Exercise 4 — Redirect Background Output**

**Task**

```bash
ping -c 10 google.com > ping.log &
```

**Observe**

* No terminal noise
* Output captured safely

**Production relevance**

* Standard practice for background jobs

---

### **Exercise 5 — Using `/dev/null`**

**Task**

```bash
ping google.com > /dev/null &
```

**Observe**

* Output discarded completely

**Why**

* Useful for health checks, keep-alive scripts

---

### **Exercise 6 — Job Listing**

**Task**

```bash
jobs
```

Start multiple jobs:

```bash
ping google.com > /dev/null &
ping bing.com > /dev/null &
```

**Observe**

* Job IDs (`[1]`, `[2]`)

---

### **Exercise 7 — Bringing Job to Foreground (`fg`)**

**Task**

```bash
fg %1
```

Stop it:

```bash
Ctrl + C
```

**Key rule**

* Only **foreground jobs** receive keyboard signals

---

### **Exercise 8 — Suspending a Job (`Ctrl + Z`)**

**Task**

```bash
ping google.com
Ctrl + Z
jobs
```

**Observe**

* Job state: *Stopped*

---

### **Exercise 9 — Resume Job in Background (`bg`)**

**Task**

```bash
bg %1
jobs
```

**Observe**

* Job runs again
* Still no keyboard input

---

### **Exercise 10 — Killing a Job**

**Task**

```bash
kill %1
```

Force kill:

```bash
kill -9 %1
```

**Production relevance**

* Safely terminating runaway jobs

---

### **Exercise 11 — `wait` Command**

**Task**

```bash
ping -c 5 google.com > /dev/null &
ping -c 5 bing.com > /dev/null &
wait
echo "All jobs finished"
```

**Observe**

* `echo` runs only after jobs finish

**Why**

* Parallel execution control in scripts

---

### **Exercise 12 — `wait -n` (any job finishes)**

**Task**

```bash
ping -c 10 google.com > /dev/null &
ping -c 3 bing.com > /dev/null &
wait -n
echo "One job finished"
```

---

### **Exercise 13 — Notification with Terminal Bell**

**Task**

```bash
ping -c 5 google.com > /dev/null &
wait
tput bel
echo "Download complete"
```

**Why**

* Useful in long manual tasks

---

### **Exercise 14 — `nohup` Survival After Logout**

**Task**

```bash
nohup ping -c 30 google.com > nohup.out &
exit
```

Login again:

```bash
ps aux | grep ping
```

**Observe**

* Job survives logout

**Production relevance**

* Remote server operations

---

### **Exercise 15 — Parent Process Change (Re-parenting)**

**Task**

```bash
ps -o pid,ppid,cmd -p <PID>
```

**Observe**

* Parent changes to PID 1 after logout

---

## PART 2 — RPM (Low-Level Package Management)

---

### **Exercise 16 — Inspect RPM Without Installing**

**Task**

```bash
rpm -qpl zsh*.rpm
```

**Observe**

* Files installed by package

---

### **Exercise 17 — Manual RPM Install**

**Task**

```bash
sudo rpm -i zsh*.rpm
```

**Observe**

* No dependency resolution

---

### **Exercise 18 — RPM Removal**

**Task**

```bash
sudo rpm -e zsh
```

**Why**

* Understand why RPM alone is dangerous in production

---

## PART 3 — DNF Core Usage

---

### **Exercise 19 — Search Packages**

**Task**

```bash
dnf search links
```

---

### **Exercise 20 — Install with Dependencies**

**Task**

```bash
sudo dnf install links
```

---

### **Exercise 21 — Remove Package**

**Task**

```bash
sudo dnf remove links
```

---

### **Exercise 22 — Repository Awareness**

**Task**

```bash
dnf info neofetch
```

**Observe**

* Which repository provides it

---

## PART 4 — Repositories (BaseOS, AppStream, EPEL, CRB)

---

### **Exercise 23 — List Repositories**

**Task**

```bash
dnf repolist
```

---

### **Exercise 24 — Enable CRB**

**Task**

```bash
sudo dnf config-manager --set-enabled crb
```

---

### **Exercise 25 — Enable EPEL**

**Task**

```bash
sudo dnf install epel-release
```

Install:

```bash
sudo dnf install htop
```

---

## PART 5 — Dependency Analysis

---

### **Exercise 26 — What a Package Provides**

**Task**

```bash
dnf repoquery --provides bash
```

---

### **Exercise 27 — What a Package Requires**

**Task**

```bash
dnf repoquery --requires bash
```

---

### **Exercise 28 — Who Requires a Package**

**Task**

```bash
dnf repoquery --whatrequires bash
```

---

### **Exercise 29 — Weak Dependencies (Recommends)**

**Task**

```bash
dnf repoquery --recommends gimp
```

---

### **Exercise 30 — Install Without Weak Dependencies**

**Task**

```bash
sudo dnf install gimp --setopt=install_weak_deps=False
```

---

### **Exercise 31 — Backward Weak Dependencies (Supplements)**

**Task**

```bash
dnf repoquery --what-supplements langpacks-de
```

---

## PART 6 — Dependency Removal Dangers

---

### **Exercise 32 — Dependency Auto-Removal Problem**

**Task**

```bash
sudo dnf install python3-matplotlib
python3 -c "import numpy"
sudo dnf remove python3-matplotlib
python3 -c "import numpy"
```

**Observe**

* App breaks

---

### **Exercise 33 — Fix Using `dnf mark install`**

**Task**

```bash
sudo dnf install python3-numpy
sudo dnf mark install python3-numpy
sudo dnf remove python3-matplotlib
```

---

## PART 7 — Updates, Downgrades, Version Locking

---

### **Exercise 34 — System Upgrade**

**Task**

```bash
sudo dnf upgrade
```

---

### **Exercise 35 — Downgrade a Package**

**Task**

```bash
dnf list python3 --showduplicates
sudo dnf downgrade python3-<version>
```

---

### **Exercise 36 — Temporary Upgrade Exclusion**

**Task**

```bash
sudo dnf upgrade --exclude=python3*
```

---

## PART 8 — Automatic Updates

---

### **Exercise 37 — Enable Automatic Updates**

**Task**

```bash
sudo dnf install dnf-automatic
sudo systemctl enable --now dnf-automatic.timer
```

---

### **Exercise 38 — Configure Security-Only Updates**

Edit:

```bash
sudo vi /etc/dnf/automatic.conf
```

Set:

```
upgrade_type=security
apply_updates=yes
```

---

## PART 9 — DNF Modules

---

### **Exercise 39 — List Modules**

**Task**

```bash
dnf module list
```

---

### **Exercise 40 — Enable NodeJS Stream**

**Task**

```bash
sudo dnf module enable nodejs:18
sudo dnf upgrade
node --version
```

---

### **Exercise 41 — Install Module Profile**

**Task**

```bash
sudo dnf module install nodejs:18/development
```

---

### **Exercise 42 — Remove Module Profile**

**Task**

```bash
sudo dnf module remove nodejs:18/development
```

---

### **Exercise 43 — Disable & Reset Module**

**Task**

```bash
sudo dnf module disable nodejs
sudo dnf module reset nodejs
```

---

## PART 10 — Dependency Conflict Debugging

---

### **Exercise 44 — Broken RPM Install**

**Task**

```bash
sudo dnf install https://example.com/foreign.rpm
```

**Analyze**

* Missing dependencies
* Use:

```bash
dnf repoquery --whatprovides <library>
```

---

## PART 11 — Snap Packages

---

### **Exercise 45 — Install Snap**

**Task**

```bash
sudo dnf install snapd
sudo systemctl enable --now snapd.socket
```

---

### **Exercise 46 — Install Firefox via Snap**

**Task**

```bash
sudo snap install firefox
snap run firefox
```

---

### **Exercise 47 — Compare Versions**

**Task**

```bash
firefox --version
snap run firefox --version
```

**Observe**

* Snap version is newer


