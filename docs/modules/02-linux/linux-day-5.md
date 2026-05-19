---
title: "linux day #5"
description: "Linux Boot Process &amp; Bootloader (GRUB2)                       1. What happens when a..."
published: 2025-12-28
source: "https://dev.to/jumptotech/linux-day-5-31op"
tags: []
---

# linux day #5



## Linux Boot Process & Bootloader (GRUB2)

![Image](https://assets.bytebytego.com/diagrams/0213-linux-boot-process-explained.png)

![Image](https://i.sstatic.net/QIzyq.png)

![Image](https://static0.howtogeekimages.com/wordpress/wp-content/uploads/2014/09/gnu-grub2-boot-loader-menu.png?dpr=1.5\&fit=crop\&q=50\&w=640)

![Image](https://static.thegeekstuff.com/wp-content/uploads/2011/02/linux-boot-process.png)

---

## 1. What happens when a computer starts?

When you power on a computer, the startup process happens in **strict stages**:

### Step 1: BIOS or UEFI (Firmware)

* The **BIOS** (older systems) or **UEFI** (modern systems) initializes hardware:

  * CPU
  * RAM
  * Disk controllers
* It **does NOT load Linux directly**
* Its job is to **find and start a bootloader**

---

## 2. What is a Bootloader?

A **bootloader** is the **first software** that runs after BIOS/UEFI.

### Main responsibility:

* Load the **Linux kernel** into memory
* Hand over control to the kernel

### On Linux, the most common bootloader is:

* **GRUB2 (Grand Unified Bootloader v2)**

---

## 3. What can GRUB2 do?

GRUB2 is more than just a kernel loader.

It can:

* Boot **different kernel versions**
* Boot into **recovery mode**
* Support **dual-boot systems** (Linux + Windows)
* Load **another bootloader** (for example, Windows Boot Manager)

> The bootloader runs only for a **very short time**, unless a menu is shown.

---

## 4. Why doesn’t GRUB always show up?

This depends on:

* Linux distribution (Ubuntu, CentOS, etc.)
* System configuration
* Whether dual-boot is enabled

### Typical behavior:

* **Ubuntu**: GRUB menu often hidden or shown for milliseconds
* **CentOS**: GRUB menu often visible by default
* **Dual-boot systems**: GRUB must appear so the OS can be selected

---

## 5. Where is GRUB configured?

### Editable configuration file:

```
/etc/default/grub
```

This file is:

* A **bash-style configuration file**
* Safe to edit

### Actual GRUB configuration (DO NOT EDIT):

```
/boot/grub/grub.cfg
(or /boot/grub2/grub.cfg on CentOS)
```

⚠️ **Never edit `grub.cfg` manually**

* It is auto-generated
* Kernel updates will overwrite it

---

## 6. How GRUB configuration works

### Correct workflow:

1. Edit `/etc/default/grub`
2. Regenerate GRUB config
3. GRUB detects kernels automatically

---

## 7. Updating GRUB (Ubuntu vs CentOS)

### Ubuntu (Debian-based):

```bash
sudo update-grub
```



## 8. Enabling the GRUB menu (Ubuntu example)

Edit the file:

```bash
sudo nano /etc/default/grub
```

### Key settings:

```bash
#GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=5
```

Meaning:

* Commenting `GRUB_TIMEOUT_STYLE=hidden` allows menu display
* `GRUB_TIMEOUT=5` gives you 5 seconds to choose

Then apply changes:

```bash
sudo update-grub
```

---

## 9. What happens after update-grub?

* GRUB scans:

  * Installed kernels
  * Recovery options
* Regenerates:

  ```
  /boot/grub/grub.cfg
  ```

This file:

* Is **read by the bootloader**
* Is **not a bash script**
* Should never be edited manually

---

## 10. GRUB menu options explained

When GRUB is visible, you can:

* Boot the **default kernel**
* Boot an **older kernel**
* Boot into **recovery mode**

### Why older kernels matter:

* New kernel may have:

  * Driver issues
  * Hardware incompatibility
* Older kernel allows system recovery

---

## 11. Recovery mode (Security implications)

Recovery mode allows:

* Root shell access
* **No password required**

This is powerful — and dangerous.

---

## 12. Hardening the boot process (Production systems)

To secure a Linux system:

* Hide GRUB menu
* Set GRUB password
* Lock BIOS/UEFI with password
* Disable booting from:

  * USB
  * External drives

### Trade-off:

* More security
* Harder recovery if kernel breaks

---

## 13. Full boot flow summary

```
Power On
  ↓
BIOS / UEFI
  ↓
GRUB2 Bootloader
  ↓
Linux Kernel
  ↓
Init system (systemd)
  ↓
Userspace services
```







## The Linux Kernel — What It Really Does

![Image](https://www.scaler.com/topics/images/fundamental-architecture-of-linux.webp)

![Image](https://www.researchgate.net/publication/245022829/figure/fig1/AS%3A298303410458625%401448132483777/Linux-User-and-Kernel-space.png)

![Image](https://cdn.prod.website-files.com/681e366f54a6e3ce87159ca4/6877c8000c649c78e209c5a1_image002.png)

![Image](https://www.researchgate.net/publication/277248477/figure/fig1/AS%3A774804445605893%401561739183918/nteraction-of-Linux-kernel-modules-with-their-environment.png)

---

## 1. What is the Kernel?

The **kernel** is the **core of the operating system**.

It:

* Runs all the time
* Has direct access to hardware
* Controls everything else

User programs **never talk to hardware directly** — they always go through the kernel.

---

## 2. Core Responsibilities of the Kernel

### 2.1 Process Management

The kernel:

* Creates processes
* Schedules CPU time
* Decides **which process runs when**
* Enables **inter-process communication (IPC)**

Example:

* Your browser, terminal, and background services are all competing for CPU
* The kernel schedules them fairly

---

### 2.2 Memory Management

The kernel manages:

* **Physical memory (RAM)**
* **Virtual memory**
* **Swap space** (disk used as memory)

Responsibilities:

* Assign memory to programs
* Prevent programs from accessing each other’s memory
* Free memory when programs exit

Without the kernel:

* Programs would overwrite each other
* System would crash constantly

---

### 2.3 File System Management

The kernel:

* Implements file system drivers (ext4, xfs, btrfs, etc.)
* Handles file operations:

  * open
  * read
  * write
  * close

You say:

```
cat file.txt
```

The kernel:

* Talks to the disk
* Knows where blocks are stored
* Returns data safely

---

### 2.4 Networking Stack

The kernel provides:

* TCP/IP
* UDP
* Ethernet
* Firewall (netfilter / iptables / nftables)

Applications **do not implement networking themselves**.

When a program opens a socket:

* The kernel handles packets
* Routing
* Network drivers

---

## 3. Hardware Abstraction Layer (HAL)

### Key idea:

**Programs should not care about hardware differences**

The kernel:

* Abstracts CPUs, disks, NICs, GPUs
* Makes the same program run on:

  * Laptop
  * Server
  * VM
  * Cloud instance

This is why Linux scales from:

* Embedded devices → supercomputers

---

## 4. Where is the Kernel Stored?

The kernel is a file stored on disk.

Typical location:

```
/boot/
```

Example kernel file:

```
vmlinuz-<version>
```

Characteristics:

* Compressed (the `z` in vmlinuz)
* ~15 MB in size
* Multiple versions kept for safety

Older kernels remain installed so you can:

* Boot an older version if the latest fails

---

## 5. Kernel Modules (Very Important)

### What is a Kernel Module?

A **kernel module** is:

* Code loaded **into the running kernel**
* Extends kernel functionality
* Loaded **at runtime**

Think of it as:

> “A plugin for the kernel”

---

### Why Kernel Modules Exist

Advantages:

* Kernel stays small
* Features can be added on demand
* Hardware support without recompiling kernel

---

### Common Kernel Module Examples

* GPU drivers (NVIDIA)
* Wi-Fi drivers
* RAID drivers
* Filesystems (ZFS)
* VirtualBox Guest Additions
* VFIO (GPU passthrough for VMs)

---

### Listing Loaded Kernel Modules

Command:

```bash
lsmod
```

Shows:

* Loaded modules
* Dependencies
* Memory usage

---

## 6. Why Kernel Modules Matter in Real Life

In production:

* Some hardware requires **custom or proprietary modules**
* Kernel updates may break those modules

This causes:

* System failures
* Downtime
* Stressful recovery

---

## 7. Kernel Updates & Version Locking

### When should you lock a kernel?

Only when:

* You depend on custom kernel modules
* Hardware drivers are version-specific

---

### Ubuntu — Lock Kernel Version

Kernel package example:

```
linux-generic
```

Lock it:

```bash
sudo apt-mark hold linux-generic
```

Unlock it:

```bash
sudo apt-mark unhold linux-generic
```

---

### CentOS / RHEL — Lock Kernel Version

Install version lock plugin:

```bash
sudo dnf install dnf-command(versionlock)
```

Lock kernel:

```bash
sudo dnf versionlock kernel
```

This prevents kernel upgrades.

---

## 8. User Space vs Kernel Space

This is a **fundamental concept**.

### Hardware (Bottom Layer)

* CPU
* RAM
* Disk
* Network

### Kernel Space

* Linux kernel
* Device drivers
* Memory manager
* Scheduler

### User Space

* Libraries (glibc)
* systemd
* Desktop environment
* Applications (Firefox, Docker, Bash)

---

## 9. System Calls — The Bridge

Applications cannot:

* Access hardware directly
* Read disk blocks directly

Instead they use **system calls**.

Examples:

* open()
* read()
* write()
* close()

Flow:

```
User Program
 → System Call
   → Kernel Mode
     → Hardware
   ← Kernel
 ← User Program
```

This design provides:

* Security
* Stability
* Isolation

---

## 10. Why This Matters for DevOps

You don’t need to memorize everything.

But you **must understand**:

* Kernel vs user space
* Why kernel modules can break upgrades
* Why kernel updates can be risky in prod
* Why hardware issues often involve kernel drivers

This knowledge helps you:

* Troubleshoot faster
* Communicate with senior engineers
* Avoid dangerous updates

---

## 11. Summary

The kernel:

* Is the core of Linux
* Manages CPU, memory, files, networking
* Abstracts hardware
* Runs silently in the background
* Can be extended using kernel modules

You use it **every second**, even if you never see it.







## From Kernel to Running Applications — Introducing systemd

![Image](https://assets.bytebytego.com/diagrams/0213-linux-boot-process-explained.png)

![Image](https://opensource.com/sites/default/files/uploads/systemd-architecture.png)

![Image](https://insujang.github.io/assets/images/181126/systemd_boot.png)

---

## 1. What happens after the kernel starts?

So far, we have seen:

1. **BIOS / UEFI** initializes hardware
2. **Bootloader (GRUB)** loads the kernel
3. **Kernel** initializes hardware and core subsystems

Now the question is:

👉 **How do applications start?**
👉 **How do we get a login screen, network, services, background jobs?**

This is where **systemd** comes in.

---

## 2. What is systemd?

**systemd is the main process that manages the operating system.**

Key points:

* It runs **above the kernel**
* It does **not** talk to hardware directly
* It uses the kernel to manage processes and services

Once the kernel is ready, it starts **one main process**.

That process is:

* **PID 1**
* On modern Linux systems: **systemd**

---

## 3. systemd is PID 1

We can verify this:

```bash
ps 1
```

You’ll see:

* Process ID: **1**
* Command name: often shown as `init`

Why `init`?

Historically:

* Older Linux systems used **SysV init**
* systemd replaced it
* For compatibility, `/sbin/init` is now a **symbolic link** to systemd

You can confirm this:

```bash
ls -l /sbin/init
```

You’ll see it points to systemd.

So even if it says `init`, **systemd is running**.

---

## 4. What does systemd do?

systemd:

* Starts all required services
* Controls service order and dependencies
* Manages system state
* Keeps services running
* Restarts failed services

Examples of things started by systemd:

* Network services
* Time synchronization
* Disk mounting
* Login manager
* Web servers
* Background tasks

In short:

👉 **If systemd stops, the system is unusable**

---

## 5. systemd is not just one tool

This is very important.

**systemd is a large ecosystem**, not a single binary.

Besides PID 1, there are many systemd-related processes running:

Examples:

* Time synchronization
* Logging
* Network management
* Device handling

You can see this with:

```bash
ps -ef | grep systemd
```

So systemd consists of:

* A **core manager (PID 1)**
* Many **supporting tools and daemons**

---

## 6. What will we focus on?

Because systemd is huge, we will **not** cover everything.

We will focus on:

* The **main systemd process**
* How it starts and manages services
* How it controls background jobs



## 7. Why systemd matters (real problems)


### Problem 1: Auto-start services

Example:

* You have a web server
* You want it to start **automatically at boot**

How does Linux do this?

---

### Problem 2: Run custom commands at boot

Example:

* Run a script
* Write something to a log file
* Initialize an application

Without user login.

---

### Problem 3: Run background jobs repeatedly

Example:

* Transcoding videos
* Cleaning files
* Health checks

Runs:

* Every few minutes
* Even when nobody is logged in

Traditionally, this was done using **cron**.

---

## 8. systemd vs cron (high level)

systemd can:

* Replace many cron use cases
* Run scheduled tasks
* Handle dependencies
* Restart failed jobs
* Log output automatically

We’ll look at this later as a **bonus topic**.

---

## 9. Why DevOps engineers must know systemd

In real environments:

* Servers boot without a GUI
* Everything runs in background
* Services must be reliable
* Logs must be inspectable
* Failures must be recoverable

systemd is:

* Everywhere (cloud, VMs, containers hosts)
* Central to Linux operations
* Frequently asked in interviews








## General Structure of systemd

![Image](https://opensource.com/sites/default/files/uploads/systemd-architecture.png)

![Image](https://seb.jambor.dev/posts/systemd-by-example-part-2-dependencies/shutdown.png)

![Image](https://www.computernetworkingnotes.com/wp-content/uploads/linux-tutorials/images/rsg32-02-display-sshd-serivce-unit-file.png)

![Image](https://assets.bytebytego.com/diagrams/0213-linux-boot-process-explained.png)

---

## 1. systemd Operating Modes

systemd supports **multiple modes**, but the two important ones are:

### 1.1 System Mode (Main focus of this course)

* Manages the **entire operating system**
* Handles:

  * Boot process
  * Service startup
  * Dependency resolution
* This is what runs as **PID 1**

This is the mode responsible for:

* Networking
* Login screen
* Graphical interface
* Background services
* Servers (web, database, etc.)

---

### 1.2 User Mode

* Runs **per user**
* Starts when a user logs in
* Manages:

  * User-specific background services
  * User timers
  * Per-user tasks

Important note:

* **System mode and user mode can run at the same time**
* In this course, we focus on **system mode**
* You should still be aware user mode exists

---

## 2. What systemd Does During Boot

After the kernel finishes initializing:

systemd:

1. Reads **unit files**
2. Builds a **dependency graph**
3. Determines:

   * What must start first
   * What can start in parallel
4. Brings the system to a **target state**

Example dependencies:

* Network must start before GUI
* Time sync before certain services
* Drivers before display manager

systemd does **execution dependency management**, not install-time dependency management.

---

## 3. systemd Building Blocks — Units

### 3.1 What is a Unit?

A **unit** is the **basic building block** in systemd.

* Everything systemd manages is a unit
* Units can:

  * Depend on other units
  * Require or want other units
  * Be ordered before or after other units

systemd resolves these dependencies automatically.

---

### 3.2 Common Unit Types

 **three unit types**:

| Unit Type | Purpose                                 |
| --------- | --------------------------------------- |
| service   | Runs processes (daemons, scripts, apps) |
| target    | Groups units and defines system state   |
| timer     | Runs tasks on a schedule                |

Other unit types exist :

* mount (mount filesystems)
* socket (network/socket activation)
* device (hardware)

---

## 4. Service Units

A **service unit** represents something that runs.

Examples:

* Web server
* Background script
* Graphical login manager
* Long-running daemon

A service can be:

* Started
* Stopped
* Restarted
* Reloaded
* Enabled / disabled at boot

Important:

* **Every service is a unit**
* Identified by `.service` file extension

---

## 5. Where systemd Unit Files Are Stored

systemd loads unit files from **multiple directories**.

### 5.1 Distribution / Package Units

```
/lib/systemd/system/
(or /usr/lib/systemd/system/)
```

* Provided by OS or package maintainers
* Should **never be edited**
* Safe to replace during updates

---

### 5.2 Runtime Units

```
/run/systemd/system/
```

* Temporary
* Lost on reboot
* Used internally at runtime
* Usually not touched manually

---

### 5.3 Administrator Units (Most Important)

```
/etc/systemd/system/
```

* Used for:

  * Custom services
  * Overrides
  * Admin configuration
* **Overrides files in /lib**
* Persistent across updates

This is where **you** work as an admin.

---

## 6. How systemd Finds Unit Paths

You can inspect unit search paths with:

```bash
systemd-analyze unit-paths
```

This shows:

* All directories systemd checks
* Order of precedence

---

## 7. Exploring Installed Units

Example:

```bash
cd /lib/systemd/system
ls
```

You will see:

* Many `.service` files
* Many other unit types

Each file defines **one unit**.

---

## 8. Example: Inspecting a Service Unit

Example service:

```bash
wpa_supplicant.service
```

To view it:

```bash
systemctl cat wpa_supplicant.service
```

Why use `systemctl cat` instead of `cat`?

* Merges:

  * Base unit
  * Overrides
  * Drop-in files
* Shows **effective configuration**

This matters because:

* systemd units can be composed from multiple files
* Manual `cat` may be misleading

---

## 9. What a Unit File Is

A unit file is:

* Plain text
* Declarative
* Defines:

  * Dependencies
  * Execution commands
  * Conditions
  * Environment

You don’t need to understand syntax yet.
We will cover this step by step later.

---

## 10. Why This Structure Matters

This design allows:

* Parallel startup
* Reliable dependency handling
* Clean overrides
* Safe OS updates
* Admin customization without breaking packages

This is why systemd scales well from:

* Laptops
* Servers
* Cloud instances










## Managing Services (Units) with systemd

![Image](https://miro.medium.com/1%2AOD9MOvg4XlBFYezYqwUSMA.png)

![Image](https://i.sstatic.net/mXDtZ.jpg)

![Image](https://lcom.static.linuxfound.org/sites/lcom/files/default-page.png)

![Image](https://docs.rockylinux.org/10/books/admin_guide/images/16-init-compare.jpg)

---


## 2. Installing a Service (Apache Web Server)

On Ubuntu, we install Apache using APT:

```bash
sudo apt install apache2
```

Key observations:

* Apache installs successfully
* During installation, it **registers itself with systemd**
* The service is **started automatically**

On other distributions:

* The package may be called `httpd`
* The concept is the same

---

## 3. Verifying the Service Is Running

### Using a Web Browser

You can open:

```
http://localhost
```

You will see:

* The default Apache welcome page
* Confirmation that the web server is running

---

### Using the Terminal (CLI Browser)

Install a terminal-based browser:

```bash
sudo apt install links
```

Open the site:

```bash
links http://localhost
```

This confirms:

* The service is running
* The server responds to requests

Exit the browser:

```
q
```

---

## 4. Finding the systemd Unit Name

systemd manages services as **units**.

To list active units:

```bash
systemctl list-units
```

This output can be long, so filter it:

```bash
systemctl list-units | grep apache
```

You will find:

```
apache2.service
```

This is the **unit name** .

---

## 5. Checking Service Status

Use:

```bash
systemctl status apache2.service
```

This shows:

* Whether the service is active
* Since when it has been running
* Main process ID (PID)
* Child processes (cgroup)
* Recent log messages

To exit:

```
q
```

---

## 6. Understanding What systemctl Shows

The status output includes:

* **Active state** (active / inactive / failed)
* **Main PID**
* **CGroup** (all child processes managed together)
* **Logs from startup**

This is powerful because:

* systemd tracks **all subprocesses**
* Stopping the service stops everything cleanly

---

## 7. Controlling a Service

systemd allows us to control services using `systemctl`.

### Common Commands

```bash
sudo systemctl start apache2.service
sudo systemctl stop apache2.service
sudo systemctl restart apache2.service
sudo systemctl reload apache2.service
```

Explanation:

* **start** – start the service
* **stop** – stop the service
* **restart** – stop and start again
* **reload** – ask the service to reload its own configuration

⚠️ `reload` does **not** reload systemd unit files
It only reloads the application’s config (if supported)

---

## 8. Stopping the Apache Service

```bash
sudo systemctl stop apache2.service
```

Check status:

```bash
systemctl status apache2.service
```

You will see:

* `inactive (dead)`

Test access:

```bash
links http://localhost
```

Result:

* Connection refused
* Service is not running

---

## 9. Starting the Apache Service Again

```bash
sudo systemctl start apache2.service
```

Test again:

```bash
links http://localhost
```

Result:

* Website is accessible again

---

## 10. Short Unit Names (Convenience)

For **service units**, you can omit `.service`.

These are equivalent:

```bash
systemctl status apache2
systemctl status apache2.service
```

Important:

* This only works when the unit type is unambiguous
* For other unit types (target, timer), the suffix matters

---

## 11. Important Behavior: Auto-Start on Boot

Even if you stop the service:

```bash
sudo systemctl stop apache2
```

After a **reboot**, Apache will start again automatically.

This is **not a bug**.

Reason:

* The service is **enabled**
* It is attached to a boot target

To control this behavior, we must understand **targets**.




## Control Groups (cgroups) — Concept and Practical Usage

![Image](https://access.redhat.com/webassets/avalon/d/Red_Hat_Enterprise_Linux-6-Resource_Management_Guide-en-US/images/67e2c07808671294692acde9baf0b452/RMG-rule4.png)

![Image](https://www.scylladb.com/wp-content/uploads/systemd-and-cgroups-1062x1100.png)

![Image](https://lcom.static.linuxfound.org/sites/lcom/files/fig01_coredumpctl_list.png)

![Image](https://labs.iximiuz.com/content/files/tutorials/controlling-process-resources-with-cgroups/__static__/cgroup-v2-rev2.png)

---

## 1. What is a cgroup?

A **cgroup (control group)** is a feature provided by the **Linux kernel**.

Purpose:

* Group processes together
* Control and measure their resource usage
* Enforce limits across **process trees**, not just single processes

Important:

* This lecture gives **only an overview**
* cgroups can do much more than shown here

---

## 2. Why cgroups exist

Without cgroups:

* Each process is managed individually
* Child processes can escape resource limits

With cgroups:

* Processes are bundled together
* Child processes automatically inherit limits
* Groups form a **hierarchy**

This enables:

* Fair CPU scheduling
* Memory limits
* Resource accounting
* Process freezing
* Clean service management

---

## 3. systemd and cgroups

systemd **heavily relies on cgroups**.

Key idea:

* systemd places every process into a cgroup
* Services, users, and sessions all live inside cgroups
* cgroups form a tree structure

This allows systemd to:

* Track services reliably
* Kill all child processes cleanly
* Enforce limits on entire services

---

## 4. Why cgroups are better than per-process limits

### Example: Web server

A web server may spawn:

* Worker processes
* PHP processes
* Helper processes

If you limit only the parent process:

* Child processes are unaffected

With cgroups:

* The **entire web server tree** is limited
* No process can escape the limit

---

### Example: Firefox

Firefox spawns:

* Main process
* Rendering processes
* Extension processes

With a cgroup:

* All Firefox processes share the same limits
* Memory and CPU are enforced globally

---

## 5. cgroups are already in use

You don’t need to enable cgroups — they already exist.

Every process on your system:

* Is part of a cgroup
* Is part of a cgroup hierarchy

You’ve been using them all along.

---

## 6. Inspecting cgroups (basic view)

### Using systemctl status

```bash
systemctl status
```

This shows:

* The main system cgroup
* system.slice
* user.slice
* Service-specific cgroups
* Nested hierarchy

Important clarification:

* A **service is not a process**
* A service *manages* one or more processes
* Those processes live inside the service’s cgroup

---

## 7. Understanding slices

A **slice** is a special systemd-managed cgroup.

Examples:

* `system.slice` → system services
* `user.slice` → user sessions
* `user-1000.slice` → user with UID 1000

Slices:

* Can contain services
* Can contain other slices
* Can enforce limits

---

## 8. Monitoring cgroups in real time

Use:

```bash
systemd-cgtop
```

This shows:

* CPU usage per cgroup
* Memory usage per cgroup
* Hierarchical resource usage

Exit with:

```text
q
```

---

### Showing deeper hierarchy

By default, only a few levels are shown.

To show more:

```bash
systemd-cgtop --depth=5
```

You will see:

* User slices
* Session slices
* Individual application cgroups
* Even terminal sessions

This gives **clear visibility** into system resource usage.

---

## 9. Why this matters in production

cgroups are critical for:

* Multi-service servers
* Docker containers
* Kubernetes pods
* Shared infrastructure
* Preventing resource starvation

This is one of the foundations of:

* Containers
* Cloud platforms
* Modern Linux servers

---

## 10. Practical Example — Limiting Firefox Memory

Goal:

> Run Firefox with a **hard memory limit**

This is **only a demo** to visualize cgroups.

---

## 11. Creating a user-level slice

We create a **systemd user slice**.

Location:

```bash
~/.config/systemd/user/
```

Create directories:

```bash
mkdir -p ~/.config/systemd/user
```

Create slice file:

```bash
nano ~/.config/systemd/user/browser.slice
```

Example configuration:

```ini
[Slice]
MemoryMax=250M
```

Save and exit.

---

## 12. Reload systemd user configuration

After modifying unit files:

```bash
systemctl --user daemon-reload
```

Without this:

* Changes won’t apply
* Old limits remain active

---

## 13. Finding the real Firefox executable

Important:

* On Ubuntu, Firefox is installed via **Snap**
* `/usr/bin/firefox` is often a **wrapper script**
* Wrapper scripts may reset cgroup placement

### Find real executable

Start Firefox normally, then:

```bash
ps -ef | grep firefox
```

Look for the **actual binary**, for example:

```text
/snap/firefox/2670/usr/lib/firefox/firefox
```

This is the path you must use.

---

## 14. Running Firefox inside the cgroup

Use `systemd-run`:

```bash
systemd-run --user --slice=browser.slice /snap/firefox/2670/usr/lib/firefox/firefox
```

Result:

* A temporary unit is created
* Firefox runs inside `browser.slice`
* Memory limit is enforced

---

## 15. Observing the effect

Symptoms:

* Firefox becomes slow
* Tabs struggle to load
* Memory usage stays capped

Check with:

* System Monitor
* `systemd-cgtop`

All Firefox processes together:

* Cannot exceed the configured memory limit

---

## 16. Key lessons from this example

* cgroups apply to **process trees**
* systemd slices make cgroups easy to manage
* Wrapper scripts (Snap) can bypass limits
* You must target the **real executable**
* Limits apply instantly and strictly

---

## 17. Scope warning (important)

This example shows **only a small part** of what cgroups can do.

They can also:

* Limit CPU
* Control IO
* Shape network usage
* Apply limits to services
* Integrate with containers

For real use cases:

* Further research is required
* Configuration depends on workload

---

## 18. Summary

* cgroups are a **Linux kernel feature**
* systemd uses cgroups everywhere
* They provide hierarchy, limits, and visibility
* systemd slices are managed cgroups
* Resource control applies to entire process groups
* This is the foundation of modern Linux resource management









## systemd Targets — Boot Modes and Service Enablement

![Image](https://insujang.github.io/assets/images/181126/systemd_boot.png)

![Image](https://www.systutorials.com/wp/files/2015/12/Systemd-components.png)

![Image](https://seb.jambor.dev/posts/systemd-by-example-part-2-dependencies/shutdown.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2Ap-7YlK167dRLcBS3GiPkOA.png)

---

## 1. What is a systemd Target?

A **target** is a special type of **systemd unit**.

You can think of a target as:

* A **goal**
* A **boot mode**
* A **logical grouping of units**

A target does **not run code itself**.
Instead, it:

* Pulls in other units (services, mounts, sockets, etc.)
* Represents a **system state**

---

## 2. Examples of Targets

Typical goals represented by targets:

* Boot with a **graphical user interface**
* Boot with **command line only**
* Shutdown
* Reboot
* Emergency / rescue mode

Targets replace the old **SysV runlevels**.

---

## 3. Checking the Default Target

The **default target** is what the system boots into.

Check it with:

```bash
systemctl get-default
```

Example output:

```text
graphical.target
```

This means:

* System boots into GUI
* Graphical services are started

---

## 4. Inspecting a Target Unit File

Targets are defined by unit files, just like services.

Example:

```bash
systemctl cat graphical.target
```

You will see:

* Dependencies
* Required targets
* Wanted units

Important detail:

* `graphical.target` **requires** `multi-user.target`
* Targets build **on top of each other**

---

## 5. Important Targets to Know

### graphical.target

* Full desktop system
* GUI, network, services
* Typical laptop / desktop mode

### multi-user.target

* No GUI
* Network enabled
* Services running
* Typical server mode

---

## 6. Switching Targets at Runtime (isolate)

You can switch targets **without rebooting** using `isolate`.

Example:

```bash
sudo systemctl isolate multi-user.target
```

Result:

* GUI stops
* System switches to terminal login

⚠️ Warning:

* This will **close graphical sessions**
* Do not do this with unsaved work

---

To return to GUI:

```bash
sudo systemctl isolate graphical.target
```

---

## 7. Listing Available Targets

To list all targets:

```bash
systemctl list-units --type=target --all
```

You will see:

* graphical.target
* multi-user.target
* network.target
* shutdown.target
* many internal targets

Not all targets are meant for manual use.

---

## 8. Changing the Default Target

You can permanently change what the system boots into.

Example: set server-style boot

```bash
sudo systemctl set-default multi-user.target
```

After reboot:

* No GUI
* Terminal login only

To restore GUI boot:

```bash
sudo systemctl set-default graphical.target
```

You can also switch immediately:

```bash
sudo systemctl isolate graphical.target
```

---

## 9. How Services Start Automatically

Now we answer an important question:

👉 **Why did Apache start automatically after installation?**

Because the service was **enabled**.

---

## 10. Enabling a Service

Enable a service:

```bash
sudo systemctl enable apache2.service
```

Enable **and start immediately**:

```bash
sudo systemctl enable --now apache2.service
```

What this means:

* Service starts when its target is reached
* Usually at boot

---

## 11. Understanding Why Apache Starts

Inspect the service file:

```bash
systemctl cat apache2.service
```

Look for:

```ini
[Install]
WantedBy=multi-user.target
```

Meaning:

* When `multi-user.target` is reached
* Apache should be started

Since:

* `graphical.target` depends on `multi-user.target`

Apache starts in **both CLI and GUI boots**.

---

## 12. Disabling a Service

Disable future auto-start:

```bash
sudo systemctl disable apache2.service
```

Important:

* This does **not stop** the service
* It only affects **future boots**

To stop it now:

```bash
sudo systemctl stop apache2.service
```

---

## 13. Verifying After Reboot

After disabling and rebooting:

```bash
systemctl status apache2.service
```

Result:

* Inactive
* Not started automatically

---

## 14. What systemd Does Behind the Scenes

When you enable a service, systemd:

1. Reads the unit file
2. Looks at `WantedBy=`
3. Creates a **symbolic link**

Location example:

```text
/etc/systemd/system/multi-user.target.wants/
```

Inside this directory:

* Symlinks to enabled services
* Not copies of files

Example:

```text
apache2.service → /lib/systemd/system/apache2.service
```

---

## 15. Important Rule (Very Important)

⚠️ **Never manage symlinks manually**

Do NOT:

* Create links yourself
* Delete files manually

Always use:

```bash
systemctl enable
systemctl disable
```

This ensures:

* Correct dependency handling
* Clean configuration
* Safe updates

---

## 16. Big Picture Summary

* **Targets** define system states
* **Default target** defines boot mode
* Services are started because they are **enabled**
* Enabling links services to targets
* Disabling prevents auto-start
* `systemctl` manages everything safely











## systemd Unit Files — Structure, Syntax, and Editing

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AnEu3F3JJwk6PyhQTXPOIKQ.png)

![Image](https://www.computernetworkingnotes.com/wp-content/uploads/linux-tutorials/images/rsg32-02-display-sshd-serivce-unit-file.png)

![Image](https://docs.rockylinux.org/10/books/admin_guide/images/16-init-compare.jpg)

![Image](https://file.labex.io/namespace/55ae3196-3a30-4415-8951-c05df8a2cb17/linux/linux-systemctl-daemon-reload/assets/20250303-14-50-18-s8CZGtYi.png)

---

## 1. What is a systemd Unit File?

A **unit file** is a plain text configuration file that tells systemd:

* **What** a unit is
* **How** it should behave
* **When** it should start

Unit files are used for:

* Services
* Targets
* Timers
* Slices
* Mounts
* Sockets

---

## 2. General Structure of a Unit File

A unit file is divided into **sections**.

### 2.1 `[Unit]` — General Configuration

* Present in **all unit types**
* Defines:

  * Description
  * Dependencies
  * Ordering

---

### 2.2 `[Service]` — Service Behavior

* **Only for `.service` units**
* Defines:

  * How the service starts
  * How it stops
  * Restart behavior
  * User, environment, commands

---

### 2.3 `[Install]` — Enablement Rules

* Used when enabling/disabling a unit
* Defines:

  * Which targets the unit should attach to

---

## 3. Inspecting Real Unit Files

### Example: Apache service

```bash
systemctl cat apache2.service
```

You will see:

* `[Unit]`
* `[Service]`
* `[Install]`

---

### Example: Graphical target

```bash
systemctl cat graphical.target
```

You will see:

* Only `[Unit]`
* Because targets do not execute processes

---

## 4. The `[Unit]` Section (Most Important Concepts)

### Common Options

#### `Description=`

* Short explanation of what the unit does

#### `Documentation=`

* Links to manuals or documentation

---

### Dependency vs Ordering (Very Important)

#### `Requires=`

* **Hard dependency**
* If required unit fails → this unit fails

Example:

```ini
Requires=network.target
```

---

#### `Wants=`

* **Soft dependency**
* Unit still starts even if dependency fails

Example:

```ini
Wants=network.target
```

---

#### `After=`

* **Ordering only**
* No dependency implied

Example:

```ini
After=network.target
```

Meaning:

> “If network.target starts, start me after it.”

---

#### `Before=`

* Opposite of `After=`
* Ordering only

---

### Key Rule

* **Requires / Wants** = dependency
* **After / Before** = order only

---

## 5. `[Unit]` Section Examples

### Apache service

```ini
[Unit]
Description=The Apache HTTP Server
After=network.target
```

Apache:

* Does **not require** network
* But starts **after** network if available

---

### Graphical target

```ini
[Unit]
Description=Graphical Interface
Requires=multi-user.target
Wants=display-manager.service
After=multi-user.target
AllowIsolate=yes
```

Meaning:

* Must reach `multi-user.target`
* Tries to start display manager
* Can be isolated using `systemctl isolate`

---

## 6. The `[Service]` Section



---

### 6.1 `Type=`

Defines startup behavior.

Common values:

#### `simple` (default)

* Process runs in foreground
* systemd tracks the process directly

#### `forking`

* Process starts, then forks to background
* Common for older daemons (Apache)

#### `oneshot`

* Runs once and exits
* Used for setup or cleanup scripts

---

### 6.2 `ExecStart=`

Command used to start the service.

Important:

* **Not a shell**
* No pipes (`|`)
* No redirects (`>`)
* No Bash expansions

Example:

```ini
ExecStart=/usr/sbin/apachectl start
```

---

### 6.3 `ExecStop=`

Command used to stop the service (optional).

If omitted:

* systemd sends signals automatically

---

### 6.4 `ExecReload=`

Command used when running:

```bash
systemctl reload <service>
```

Example:

```ini
ExecReload=/usr/sbin/apachectl graceful
```

---

### 6.5 `Restart=`

Defines restart policy.

Common values:

* `no`
* `on-failure`
* `always`

Example:

```ini
Restart=on-failure
```

---

### 6.6 Signals and Cleanup

When stopping a service:

1. `ExecStop` (if defined)
2. `SIGTERM` to main process
3. `SIGKILL` if still running
4. All child processes are killed (via cgroups)

---

### 6.7 Additional Options

* `User=`
* `Group=`
* `Environment=`
* Resource limits
* Security options

---

## 7. The `[Install]` Section



### Most Important Option

#### `WantedBy=`

Defines which targets this unit should attach to when enabled.

Example:

```ini
[Install]
WantedBy=multi-user.target
```

Meaning:

* Service starts when `multi-user.target` is reached

---

## 8. How `enable` Works Internally

When you run:

```bash
sudo systemctl enable apache2.service
```

systemd:

* Reads `[Install]`
* Creates symlinks under:

```text
/etc/systemd/system/multi-user.target.wants/
```

Never manage these symlinks manually.

---

## 9. Editing Unit Files — Method 1 (Manual Copy)

### Step 1: Copy unit file

```bash
sudo cp /lib/systemd/system/apache2.service /etc/systemd/system/
```

Why?

* Files in `/lib` may be overwritten by updates
* `/etc` takes precedence

---

### Step 2: Reload systemd

```bash
sudo systemctl daemon-reload
```

This:

* Reloads unit files
* Does **not** restart services

---

### Step 3: Restart service (if needed)

```bash
sudo systemctl restart apache2.service
```

---

## 10. Important Caveat — `[Install]` Changes

If you change:

```ini
[Install]
WantedBy=graphical.target
```

You must:

```bash
sudo systemctl disable apache2.service
sudo systemctl enable apache2.service
```

Why?

* `daemon-reload` does **not** update enablement links

---

## 11. Reverting Custom Changes

To revert to distro defaults:

```bash
sudo rm /etc/systemd/system/apache2.service
sudo systemctl daemon-reload
```

systemd will fall back to:

```text
/lib/systemd/system/apache2.service
```

---

## 12. Summary

* Unit files have **three main sections**
* `[Unit]` = description, dependencies, order
* `[Service]` = how the service runs
* `[Install]` = enable/disable behavior
* Always edit units in `/etc`
* Always run `daemon-reload`
* Re-enable services if `[Install]` changes










## Editing systemd Units Safely with `systemctl edit`

![Image](https://www.baeldung.com/wp-content/uploads/sites/2/2023/08/systemctl-editor-ready-for-preparing-the-drop-in-file.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AtQYgooZumBNAgL125o5ILg.png)

![Image](https://user-images.githubusercontent.com/10233106/63906084-9b13e200-ca40-11e9-94ea-4fdc0356cc8d.png)

---

## 1. Why `systemctl edit` Exists



```
/etc/systemd/system/
```

That works, but it has drawbacks:

* You must maintain the **entire unit file**
* Distribution updates may improve the original unit
* Your copied file may become outdated

### `systemctl edit` solves this

Instead of copying the full unit, it lets you:

* Override **only the parts you need**
* Keep the rest managed by the OS
* Stay compatible with future updates

---

## 2. How `systemctl edit` Works

When you run:

```bash
sudo systemctl edit apache2.service
```

systemd:

* Creates a **drop-in directory**
* Stores overrides in:

```
/etc/systemd/system/apache2.service.d/override.conf
```

Load order:

1. Original unit (`/lib/systemd/system`)
2. Drop-in overrides (`.d/*.conf`)
3. All settings are **merged**

---

## 3. Example: Change Apache to Start Only in GUI Mode

### Original behavior

Apache contains:

```ini
[Install]
WantedBy=multi-user.target
```

This means:

* Apache starts in **CLI and GUI boots**

---

### Step 1: Edit with drop-in

```bash
sudo systemctl edit apache2.service
```

Add **only what you want to change**:

```ini
[Install]
WantedBy=graphical.target
```

Save and exit.

---

## 4. Important Detail: Drop-ins EXTEND, They Don’t Replace

After enabling again:

```bash
sudo systemctl disable apache2.service
sudo systemctl enable apache2.service
```

You may notice:

* Apache is enabled for **both targets**

Why?

* Original `WantedBy=multi-user.target` still exists
* Your override **adds**, it doesn’t remove

---

## 5. How to Remove an Existing Setting in a Drop-in

To **clear** a value, assign it an empty value first.

Correct override:

```ini
[Install]
WantedBy=
WantedBy=graphical.target
```

Now:

* Original target is removed
* Only graphical.target remains

Re-enable:

```bash
sudo systemctl disable apache2.service
sudo systemctl enable apache2.service
```

✔ Correct behavior achieved

---

## 6. Why This Is the Best Practice

Advantages of `systemctl edit`:

* Minimal configuration
* Safe upgrades
* Clear intent
* No file duplication
* Reversible

This is the **recommended production approach**.

---

# Creating Your Own systemd Service (From Scratch)

![Image](https://www.maketecheasier.com/assets/uploads/2025/01/create-systemd-service-linux-01-sample-systemd-service-unit-file-ssh.jpg)

![Image](https://www.redhat.com/rhdc/managed-files/styles/default_800/private/sysadmin/2022-04/oneshot.png.webp?itok=ySyyOEbX)

![Image](https://stevenrombauts.be/images/posts/2019-01-14-run-multiple-instances-of-the-same-systemd-unit.png)

![Image](https://seb.jambor.dev/posts/systemd-by-example-part-2-dependencies/shutdown.png)

---

## 7. Goal of This Example

We will create a **custom systemd service** that:

* Runs at boot
* Logs the current time
* Pings a server
* Writes output to a log file

This shows:

* Real service creation
* Dependencies
* Ordering
* Logging
* One-shot execution

---

## 8. Commands We Will Use

### Date (safe for systemd)

```bash
date +%T
```

⚠️ In systemd:

* `%` is a placeholder
* To pass a literal `%`, use `%%`

So inside a unit:

```ini
date +%%T
```

---

### Ping (must terminate)

```bash
ping -c 4 google.com
```

No shell features used → **safe for systemd**

---

## 9. Creating the Service File

Create the service using:

```bash
sudo systemctl edit --force --full my-network-log.service
```

This creates a **new full unit file**.

---

## 10. Complete Service File

```ini
[Unit]
Description=Log time and ping network on boot
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
StandardOutput=append:/var/log/ping.txt
ExecStart=/bin/date +%%T
ExecStart=/bin/ping -c 4 google.com

[Install]
WantedBy=multi-user.target
```

---

## 11. Explanation (Important)

### `[Unit]`

* `network-online.target` ensures network is **actually usable**
* `After=` ensures correct **execution order**

### `[Service]`

* `oneshot` → run once and exit
* Multiple `ExecStart=` → run sequentially
* Output appended to log file

### `[Install]`

* Runs at every boot (CLI + GUI)


## 14. Why Network Targets Matter (Subtle but Critical)

### `network.target`

* Network **starting**
* Interfaces may not be ready

### `network-online.target`

* Network **usable**
* IP assigned
* Routing available

### Correct combination

```ini
Requires=network-online.target
After=network-online.target
```

This ensures:

* Service waits
* No race conditions
* Reliable behavior

---

## 15. Why systemd Is Powerful

This logic would be **very hard** with old init systems.

systemd provides:

* Dependency graph
* Ordering guarantees
* Automatic retries
* Clean logs
* Robust boot behavior

This is why systemd dominates modern Linux.

---

## 16. Summary

You learned how to:

* Safely override units with `systemctl edit`
* Remove inherited settings correctly
* Create a service from scratch
* Handle network readiness
* Write boot-time automation
* Avoid SELinux pitfalls
* Use systemd the **right way**








# systemd Timers — Delayed & Scheduled Tasks

## What is a systemd timer?

A **timer** is a systemd unit that:

* Triggers **another unit** (usually a `.service`)
* Runs it **later**, **once**, or **repeatedly**
* Replaces most cron use cases
* Is dependency-aware and boot-aware

Timers **do not do work themselves** — they only **start services**.

---

## Rule #1 (Very Important)

> **A timer always triggers a service.**

That means:

* You **disable the service**
* You **enable the timer**
* The timer starts the service at the right time

---

# Part 1 — Delayed Execution After Boot (`OnActiveSec`)

### Goal

Run our previously created service:

```
my-network-log.service
```

**one minute after boot** (or five minutes in real use).

---

## Step 1 — Disable the Service

We do **not** want the service to start immediately on boot.

```bash
sudo systemctl disable my-network-log.service
```

This removes the boot symlink.

---

## Step 2 — Create the Timer Unit

The timer **must have the same base name** as the service:

```
my-network-log.timer
```

Create it:

```bash
sudo systemctl edit --force --full my-network-log.timer
```

---

## Step 3 — Timer File (Delayed Execution)

Example (1 minute delay):

```ini
[Unit]
Description=Run network logging service one minute after boot

[Timer]
OnActiveSec=1min
Unit=my-network-log.service

[Install]
WantedBy=timers.target
```

### Explanation

* **OnActiveSec=1min**

  * Timer fires **1 minute after activation**
* **Unit=**

  * Explicitly states which service to start
  * Optional if names match, but recommended
* **timers.target**

  * This is the systemd target that manages timers

---

## Step 4 — Start the Timer Manually (Testing)

```bash
sudo systemctl start my-network-log.timer
```

To watch the output:

```bash
tail -f /var/log/ping.txt
```

After ~1 minute:

* Date is logged
* Ping runs
* Output appears

---

## Timer Accuracy (Important Concept)

systemd timers are **not real-time precise by default**.

Why?

* CPU wakes up **once per minute** by default
* Saves power (especially laptops)

So:

* `1min` might be **1 min + a few seconds**

---

## Optional — Increase Timer Accuracy

Add this to `[Timer]`:

```ini
AccuracySec=1s
```

⚠️ Trade-off:

* Higher accuracy
* Slightly more CPU wakeups

---

## Step 5 — Enable Timer at Boot

```bash
sudo systemctl enable my-network-log.timer
```

Now:

* Timer starts automatically on boot
* Service runs after delay

---

## Inspect Active Timers

```bash
systemctl list-timers
```

This shows:

* NEXT run
* LAST run
* Which service is triggered

To see all timers (including inactive):

```bash
systemctl list-timers --all
```

---

# Part 2 — Repeated Timers with Calendar Events (`OnCalendar`)

Now we move beyond delays.

## What is `OnCalendar`?

`OnCalendar` lets you define **time-based schedules**, like:

* Every hour
* Every 15 minutes
* Every day at 02:00
* Weekdays only
* Monthly jobs

This is **cron replacement** — but smarter.

---

## Understanding systemd Calendar Format

Use this tool:

```bash
systemd-analyze timestamp
```

This prints the **exact time format** systemd understands.

---

## Analyze Calendar Expressions

Use:

```bash
systemd-analyze calendar 'EXPRESSION'
```

### Example — Every 15 minutes

```bash
systemd-analyze calendar '*-*-* *:0/15:00'
```

Meaning:

* Every year
* Every month
* Every day
* Every hour
* At minutes **00, 15, 30, 45**
* At second 00

systemd will show:

* Normalized format
* Next execution time

---

## Shortcuts You Can Use

| Shortcut   | Meaning               |
| ---------- | --------------------- |
| `hourly`   | Every hour            |
| `daily`    | Every day at midnight |
| `weekly`   | Weekly                |
| `minutely` | Every minute          |

Example:

```bash
systemd-analyze calendar hourly
```

---

## Update the Timer to Use `OnCalendar`

Edit the timer:

```bash
sudo systemctl edit --full my-network-log.timer
```

Replace `[Timer]` section:

```ini
[Timer]
OnCalendar=*-*-* *:0/15:00
AccuracySec=1s
Unit=my-network-log.service
```

Save and exit.

---

## Critical Step — Restart the Timer

⚠️ **Timers do NOT reload automatically after edits**

You must restart:

```bash
sudo systemctl restart my-network-log.timer
```

Now check:

```bash
systemctl list-timers
```

You should see:

* Next execution time
* Countdown to next run

---

## Verify Execution

Follow the log file:

```bash
tail -f /var/log/ping.txt
```

Every 15 minutes:

* Timestamp logged
* Ping output appended

---

## Why systemd Timers Are Better Than cron

| cron                   | systemd timers             |
| ---------------------- | -------------------------- |
| No dependency handling | Full dependency graph      |
| No boot awareness      | Boot-aware                 |
| No retry logic         | Retry on failure           |
| No logs by default     | Integrated logging         |
| Hard to debug          | Inspectable with systemctl |

---

## Key Rules to Remember

1. **Timers trigger services**
2. **Disable the service, enable the timer**
3. **Restart timers after edits**
4. **Use `network-online.target` for network work**
5. **Use `systemctl list-timers` to debug**












# systemd Logging — `journald` and `journalctl`

## 1. What is `journald`?

`journald` (systemd-journal) is **part of the systemd suite**, but it is **not** the main systemd process (`PID 1`).

* `systemd` → manages services, boot, targets, cgroups
* `journald` → **collects and stores logs**

It runs as a **separate daemon** and handles **system-wide logging**.

---

## 2. Why Logging Exists

Logging allows us to:

* Record **events and state changes**
* Troubleshoot problems
* Perform analysis and auditing
* Understand *what happened* and *when*

Logs always include:

* A **timestamp**
* The **source** of the message
* The **message content**

---

## 3. What `journald` Is Meant For (and What It Is Not)

### Good use cases

* Service start / stop failures
* Crashes
* System warnings
* Kernel messages
* Dependency or boot issues

### Not ideal for

* High-volume application access logs
  (e.g. Apache access logs, Nginx access logs)

Those are still better written to **application-specific log files**.

---

## 4. journald vs Traditional syslog

`journald` largely **replaces traditional syslog**.

Key differences:

### Binary logs

* Logs are stored in **binary format**
* More efficient storage
* Faster indexing and filtering
* Requires `journalctl` to read

### Centralized logging

* Kernel logs
* Boot logs
* Service logs
* Application logs (if supported)

All in **one place**.

---

## 5. Automatic Rotation and Retention

`journald` automatically:

* Rotates logs
* Limits disk usage
* Deletes old logs

Examples of policies:

* Keep only last **5 GB**
* Rotate after **50 MB**
* Auto-cleanup — no manual logrotate needed

---

## 6. Boot-Time Logging (Major Advantage)

Even **before journald starts**:

* Kernel writes messages to a temporary buffer
* When journald starts, it **imports those messages**

This means:

* You can inspect **early boot failures**
* No logs are lost during startup

---

## 7. Reading Logs with `journalctl`

`journalctl` is the **reader** for journald logs.

### Show all logs

```bash
journalctl
```

* Oldest logs first
* Uses a pager (`less`)
* Navigate with arrow keys
* Quit with `q`

---

## 8. Show Logs for Current Boot Only

```bash
journalctl -b
```

Why this matters:

* Systems may have logs from **months ago**
* Focus only on the **current boot session**

---

## 9. Kernel Logs During Boot

When using:

```bash
journalctl -b
```

You will see:

* Kernel messages
* Hardware detection
* Early system initialization
* Then systemd logs

All in one timeline.

---

## 10. Listing Previous Boots

```bash
journalctl --list-boots
```

Example output:

```
-2  1f23...  Tue Apr 16
-1  9a12...  Wed Apr 17
 0  a8bc...  Thu Apr 18
```

* `0` → current boot
* `-1`, `-2` → previous boots
* UUID is a **stable boot identifier**

---

## 11. Viewing Logs from a Specific Boot

```bash
journalctl -b -1
```

Or using the boot ID:

```bash
journalctl -b a8bc...
```

Very useful for:

* Investigating crashes after reboot
* Comparing boots

---

## 12. Filtering Logs by Unit (Service)

```bash
journalctl -u apache2.service
```

Or (extension optional):

```bash
journalctl -u apache2
```

This shows:

* Only logs produced by that service
* Across all boots (unless combined with `-b`)

---

### Example: Custom Service Logs

```bash
journalctl -u my-network-log
```

You’ll see:

* Failures
* Command output
* Exit statuses

---

## 13. Filtering by Time Range

### Since a date

```bash
journalctl --since "2023-04-18"
```

### Between two dates

```bash
journalctl --since "2023-04-18" --until "2023-04-21"
```

Extremely useful when:

* Logs are large
* You know *when* the issue happened

---

## 14. Reverse Order (Newest First)

```bash
journalctl -r
```

Helpful if you only care about **latest events**.

---

## 15. Follow Logs in Real Time

```bash
journalctl -f
```

Equivalent to:

```bash
tail -f
```

Often combined with filters:

```bash
journalctl -u apache2 -f
```

Great for:

* Debugging service startup
* Watching crashes live

Exit with:

```text
Ctrl + C
```

---

## 16. Writing Custom Log Entries

You can write messages **directly into the journal** using `systemd-cat`.

### Simple example

```bash
echo "journal is amazing" | systemd-cat
```

Now check:

```bash
journalctl -n 5
```

You will see:

```
Unknown journal is amazing
```

---

## 17. Using Identifiers (Tags)

You can assign an identifier:

```bash
echo "journal is amazing" | systemd-cat -t my-app
```

Now filter by identifier:

```bash
journalctl -t my-app
```

Important notes:

* Identifier is **not a unit name**
* It’s a **tag**, useful for custom scripts

---

## 18. When to Use `systemd-cat`

Good for:

* Custom scripts
* One-shot services
* Lightweight application logging
* Centralized system events

Not ideal for:

* High-frequency application logs

---

## 19. Summary — What You Should Remember

* `journald` stores logs (binary)
* `journalctl` reads logs
* Logs are centralized
* Boot logs are preserved
* Powerful filtering:

  * by boot
  * by service
  * by time
  * by identifier
* You can write logs yourself using `systemd-cat`

---

## 20. Big Picture (DevOps Perspective)

`journalctl` is essential for:

* Debugging failed services
* Understanding boot issues
* Monitoring system behavior
* Investigating production incidents

If you work with **systemd**, you **must** know journald.









## Structure of a Storage Device (HDD, SSD, USB)

block storage devices, such as:

* Hard Disk Drives (HDD)
* Solid State Drives (SSD)
* USB flash drives
* SD cards



* Optical disks (CD/DVD)
* Tape storage
* Cloud storage (S3, GCS, etc.)


## How Data Is Stored on a Disk

At the lowest level, a storage device stores **bits (0 and 1)** in a **continuous sequence**.

To make this usable, we must define **how the disk is divided** and **where data can live**.
This is done using a **partition table**.

---

## What Is a Partition Table?

A **partition table** defines how a disk is divided into **independent areas (partitions)**.

### Why partitions are needed

Example: Dual-boot system

* Linux needs its own area
* Windows needs its own area
* Each OS must not overwrite the other

Even if a disk has **only one partition**, a partition table is still required.

---

## Partition Table Types

### 1. MBR (Master Boot Record)

**Older partitioning scheme**

Limitations:

* Maximum **4 primary partitions**
* Maximum disk size ~ **2 TB**

Today, MBR is considered **legacy** and rarely used.

---

### 2. GPT (GUID Partition Table)

**Modern standard**

Advantages:

* Supports **up to 128 partitions**
* Supports **very large disks** (far beyond 2 TB)
* Required for modern systems (UEFI)

GPT is the **recommended and default choice** today.

---

## Visualizing Partitions with GParted

![Image](https://gparted.org/screens/gparted-main-window.png)

![Image](https://upload.wikimedia.org/wikipedia/commons/0/07/GUID_Partition_Table_Scheme.svg)

![Image](https://linux.die.net/sag/hd-layout.png)

![Image](https://www.diskpart.com/screenshot/en/others/windows-10/comparison-mbr-and-gpt.png)

### Installing GParted

On Ubuntu:

```bash
sudo apt install gparted
```

On CentOS:

```bash
sudo yum install gparted
```

### Why root access is required

Partition changes are **destructive operations**.
One wrong click can erase a disk.

---

## Typical Ubuntu Disk Layout

Example disk: `/dev/sda`

Common partitions:

1. **Boot partition** (~1 GB)

   * Contains bootloader and kernel files
2. **Root partition**

   * Contains the Linux operating system (`/`)

You may also see:

* Small unallocated space (e.g., 1 MB)
* This is normal and harmless





## File Systems (Preview)

Each partition must be formatted with a **file system**, such as:

* ext4 (Linux default)
* FAT32
* NTFS

File systems define:

* How files are stored
* How metadata is tracked
* Performance and reliability



## Disk Size Units – Why Sizes Look “Wrong”

You may notice:

* Creating **50,000 MiB**
* Disk shows **~48.8 GiB**

This is **not an error**.

---

## Storage Measurement Units

### Binary Units (Computer-friendly)

Used internally by operating systems:

| Unit  | Size        |
| ----- | ----------- |
| 1 KiB | 1024 bytes  |
| 1 MiB | 1024² bytes |
| 1 GiB | 1024³ bytes |

---

### Decimal Units (Human-friendly)

Used by manufacturers:

| Unit | Size        |
| ---- | ----------- |
| 1 KB | 1000 bytes  |
| 1 MB | 1000² bytes |
| 1 GB | 1000³ bytes |

---

## Why the Difference Matters

As sizes grow, the difference increases:

| Unit | Difference |
| ---- | ---------- |
| KB   | ~2.4%      |
| MB   | ~4.9%      |
| GB   | ~7.4%      |

This explains why:

* Disk vendors advertise **500 GB**
* OS reports **~465 GiB**

---

## Why It’s Confusing in Practice

Historically:

* Memory (RAM) used **binary units**
* Storage vendors used **decimal units**

Operating systems sometimes:

* Label **GiB as GB**
* Mix terminology inconsistently

Result:

* “1 GB” may mean **different things depending on context**

---

## Key Takeaways (Interview-Ready)

* Disks require **partition tables** before use
* **GPT** is modern and preferred over MBR
* Ubuntu typically uses **simple partitions**
* CentOS often uses **LVM**
* File systems live **inside partitions**
* Disk size differences come from **binary vs decimal units**
* This is **normal behavior**, not a bug









## Working With a New Drive in Linux (Virtual Machines)


If we were running Linux on a **physical machine**, we would need to:

* Buy a new HDD or SSD
* Open the computer
* Physically connect the drive

Because we are running Linux inside a **virtual machine**, we can simulate this **without buying hardware**.

A virtual machine allows us to:

* Create a new virtual disk
* Attach it to the VM
* Treat it exactly like a real hard drive inside Linux

From Linux’s perspective, there is **no difference** between a real disk and a virtual one.

---

## Important Rule: Power Off the VM First

Before adding a new disk:

* The virtual machine **must be fully powered off**
* **Paused is NOT enough**
* **Saved state is NOT enough**

If the VM is paused:

1. Start the VM
2. Perform a **normal shutdown**
3. Only then change hardware settings

This prevents disk corruption and configuration issues.

---

## Adding a New Drive in VirtualBox

![Image](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/images/vm-settings-harddisk.png)

![Image](https://sysprobs.com/wp-content/uploads/2010/05/add_sata_controller.png)

![Image](https://www.simplified.guide/_media/virtualbox/disk-add/virtualbox-vm-settings-storage.png?tok=fa686a\&w=700)

![Image](https://documentation.help/VirtualBox/vm-settings-harddisk.png)

### Step 1: Open VM Settings

* Select the virtual machine
* Click **Settings**
* Go to **Storage**

### Step 2: Understand the Storage Controller

* You will see a **SATA controller**
* One disk is already attached (your OS disk)

Think of this like a real motherboard:

* One SATA controller
* Multiple SATA ports
* Multiple drives connected to the same controller

We do **not** need a new controller.

---

### Step 3: Create a New Virtual Disk

* Select the **SATA controller**
* Click **Add Hard Disk**
* Choose **Create new disk**
* Leave default disk location
* Set size to **64 GB** (or smaller if needed)

Important:

* **Do NOT preallocate full size**

  * Otherwise it will immediately consume 64 GB on your host
  * Dynamic allocation is safer and recommended

If disk space is limited:

* You may use **12 GB**
* Just remember to scale partition sizes later

Click **Finish** → **Choose** → **OK**

---

### Result

Your VM now has:

* Disk 1: OS disk (e.g. 25 GB)
* Disk 2: New empty disk (e.g. 64 GB)

This is equivalent to physically plugging in a second hard drive.

---

## Notes for Other Virtualization Software

The steps are conceptually identical in:

* VMware
* Parallels
* Hyper-V

Key rules are always the same:

* VM must be **powered off**
* Add a **new hard disk**
* Attach it to the same VM

Only the UI layout differs.

---

## What Is a File System?

A **partition** usually has a **file system**.

Unallocated space:

* Has **no file system**
* Cannot store files

A **file system** is responsible for:

* Organizing files and directories
* Managing free and used space
* Handling permissions and ownership
* Storing metadata (timestamps, size, owner)
* Maintaining data integrity
* Recovering after crashes or power loss
* SSD wear-leveling and trim support

Without a file system, a partition is unusable.

---

## Common Linux File Systems

### ext (Extended File System Family)

* **ext2** – obsolete
* **ext3** – journaling, older
* **ext4** – modern default (recommended)

Why ext4:

* Excellent stability
* Fast recovery after crashes
* Supports large files and disks
* Default on Ubuntu and many servers

👉 **Use ext4 for most Linux systems**

---

### XFS

* High performance
* Excellent for large files
* Common in enterprise environments
* Often used with CentOS/RHEL

We will use **ext4 and XFS** in this course.

---

### ZFS (Advanced)

* Designed for very large storage
* Built-in snapshots
* Strong data integrity guarantees
* Parallel I/O optimized

Not beginner-friendly. Not used in this course.

---

### btrfs

* Copy-on-write
* Easy snapshots
* Built-in software RAID
* No LVM required

Powerful, but complex. Mentioned for awareness only.

---

## Non-Linux File Systems (Awareness Only)

### Windows

* **FAT32** – max file size ~4 GB
* **NTFS** – main Windows file system
* **ReFS** – NTFS successor (enterprise)

### Cross-platform

* **exFAT** – USB drives, SD cards

### Apple

* **APFS** – macOS & iOS, encryption support

This course focuses on **Linux file systems only**.

---

## Creating a Partition with GParted

![Image](https://www.diskpart.com/screenshot/en/others/others/gparted-create-new-partition-style.png)

![Image](https://i.sstatic.net/ivolF.png)

![Image](https://devconnected.com/wp-content/uploads/2019/10/gparted-new.png)

![Image](https://i.sstatic.net/KoS4O.png)

### Step 1: Select the Correct Disk

In GParted:

* `/dev/sda` → OS disk (DO NOT TOUCH)
* `/dev/sdb` → New empty disk (USE THIS)

Always double-check before modifying disks.

---

### Step 2: Create a Partition Table

* Menu → **Device → Create Partition Table**
* Select **GPT**
* Apply

Now the disk is initialized.

---

### Step 3: Create a New Partition

* Select **unallocated space**
* Click **New**
* Size: `50000 MiB` (~50 GB)
* Name: `backups`
* File system: (formatting comes later)

Click **Add** → **Apply**

---

### Result

* One partition (~50 GB)
* Remaining space unallocated
* Disk successfully divided into usable parts









## Managing Partitions from the Command Line with `parted`


In real production environments, **GUI tools are often unavailable**, especially on:

* Cloud servers
* Bare-metal servers
* Rescue or recovery environments

That’s why learning **`parted`** is essential.

> ⚠️ `parted` is powerful and dangerous
> A single wrong command can destroy your system.

---

## Starting `parted`

We need elevated privileges:

```bash
sudo parted
```

If you are logged in as `root`, `sudo` is not required.

When started, `parted` opens its **own interactive shell** (not bash).

---

## Basic `parted` Commands

Inside the `parted` shell:

```bash
help
```

Common commands:

* `print` → show partition table
* `print devices` → list disks
* `select /dev/sdb` → switch disk
* `mklabel gpt` → create partition table
* `mkpart` → create partition
* `name` → name partition
* `quit` → exit

---

## Viewing Existing Partitions

```bash
print
```

Example output:

* Current device: `/dev/sda`
* Partition table: GPT
* Partitions:

  * FAT32 (boot)
  * ext4 (root)

⚠️ **Never modify `/dev/sda`** if it contains your OS.

---

## Switching to the New Disk

We want to work on the **second disk**:

```bash
select /dev/sdb
```

Verify:

```bash
print
```

---

## Wiping the Disk (Creating a New Partition Table)

This deletes **everything** on the disk:

```bash
mklabel gpt
```

Confirm with `Yes`.

Now the disk has **no partitions**.

---

## Creating a Partition (Correctly Aligned)

### ❌ Bad (misaligned – not recommended)

```bash
mkpart primary ext4 0 50000
```

This causes performance warnings.

---

### ✅ Correct (sector-aligned)

```bash
mkpart primary ext4 2048s 50000MB
```

Why `2048s`?

* Aligns partition to physical disk sectors
* Improves performance
* Standard best practice

You may also use percentages:

```bash
mkpart primary ext4 0% 70%
```

---

## Naming the Partition

```bash
name 1 backups
```

Verify:

```bash
print
```

---

## Using `parted` Non-Interactively

Instead of entering the `parted` shell:

```bash
sudo parted /dev/sdb print
```

Syntax:

```bash
sudo parted <device> <command>
```

Useful for scripts—but **extra dangerous**.

---

## Creating the File System (VERY IMPORTANT)

So far, we only **declared** the filesystem type.
Now we must **actually create it**.

```bash
sudo mkfs.ext4 /dev/sdb1
```

Confirm with `y`.

What this does:

* Writes ext4 structures
* Creates journal
* Initializes metadata

This is similar to “formatting” a disk in Windows.

---

## Why ext4 Uses Space Immediately

After formatting, you may notice:

* ~400–500 MB used

This includes:

* Journal
* Metadata
* Inode tables

This is **normal and expected**.

---

## From Partition to Volume (Important Concept)

### Partition

* Physical region on a disk

### Volume

* A **usable storage unit**
* Must have:

  * A filesystem
  * Be mounted

A volume can be:

* A partition
* An LVM logical volume
* A network disk
* A virtual disk

---

## What Is Mounting?

![Image](https://en.opensuse.org/images/7/78/Montage2-en.png)

![Image](https://i.sstatic.net/V5IBb.png)

![Image](https://hcc.unl.edu/docs/images/anvil-volumes/3-mkpart.png)

![Image](https://i.sstatic.net/xEFuf.png)

Mounting means:

> Attaching a volume’s filesystem into the Linux directory tree

Linux has **one directory tree**, starting at `/`.

Mounting makes storage accessible.

---

## Common Mount Locations

| Location | Purpose                             |
| -------- | ----------------------------------- |
| `/media` | Auto-mounted removable drives (GUI) |
| `/mnt`   | Manual / temporary mounts           |
| `/`      | Root filesystem                     |

---

## Automatic Mount via Desktop (GUI)

Once `gparted` is closed:

* Open File Manager
* Click **Other Locations**
* Select the new disk

Ubuntu mounts it automatically under:

```bash
/media/<username>/<UUID>
```

---

## Permission Problem (Very Common)

By default:

* Mounted volumes are owned by `root`
* Regular users cannot write

Check permissions:

```bash
ls -ld /media/<username>/<UUID>
```

---

## Fixing Permissions (Simple Method)

Allow full access (lab-friendly):

```bash
sudo chmod 777 /media/<username>/<UUID>
```

Now you can:

```bash
touch test.txt
mkdir data
```

⚠️ **Not recommended for production**, but fine for learning.

---

## Manual Mounting (CLI – Production Style)

### Step 1: Create mount point

```bash
sudo mkdir /mnt/backups
```

### Step 2: Mount the volume

```bash
sudo mount /dev/sdb1 /mnt/backups
```

### Step 3: Verify

```bash
df -h
mount | grep sdb
```

Now `/mnt/backups` is your volume.

---

## Key Differences: `/media` vs `/mnt`

| `/media`              | `/mnt`         |
| --------------------- | -------------- |
| GUI auto-mount        | Manual mount   |
| User-focused          | Admin-focused  |
| Shows in file browser | Usually hidden |

---

## Summary (Interview-Ready)

* `parted` manages partitions from CLI
* Always verify device names (`sda` vs `sdb`)
* Use **GPT** partition tables
* Align partitions (`2048s`)
* `mkfs.ext4` creates the actual filesystem
* A **volume = filesystem + mount**
* Mounting connects storage into `/`
* Permissions must be fixed manually
* `/media` = desktop mounts
* `/mnt` = admin mounts









## Manual Mounting of Drives in Linux


Manual mounting gives us **full control** over:

* Where a volume appears in the filesystem
* How it behaves (read-only, executable, secure, etc.)

### Why manual mounting matters

Examples:

* Database data on a **fast NVMe SSD**
* Logs on a **separate disk**
* Backups mounted **read-only**
* External disks mounted **securely**

On servers:

* There is usually **no GUI**
* Nothing is auto-mounted
* Everything must be done via CLI

---

## Device Names in Linux

Linux exposes storage devices as **files under `/dev`**.

Typical naming:

* `/dev/sda` → first disk
* `/dev/sdb` → second disk
* `/dev/sdb1` → first partition on second disk

Even though they look like files, these are **block device interfaces** provided by the kernel.

---

## Safely Identifying Drives (Recommended Tool)

Instead of using `parted`, which can destroy data, use:

```bash
lsblk -f
```

This shows:

* Disks and partitions
* Filesystem type
* UUID
* Mount point

Example interpretation:

* `sdb`

  * `sdb1` → ext4 → not mounted
  * `sdb2` → exfat → not mounted

This is the **safest way** to identify devices before mounting.

---

## What Is Mounting?

![Image](https://en.opensuse.org/images/7/78/Montage2-en.png)

![Image](https://i.sstatic.net/V5IBb.png)

![Image](https://hcc.unl.edu/docs/images/anvil-volumes/3-mkpart.png)

![Image](https://docs.oracle.com/en-us/iaas/Content/File/Images/subdirectorymount.png)

Mounting means:

> Attaching a filesystem to a directory inside Linux’s single directory tree (`/`)

Linux does **not** use drive letters.
Everything appears as part of one tree.

---

## Standard Mount Locations

| Path     | Purpose                         |
| -------- | ------------------------------- |
| `/media` | GUI auto-mounts (USB, SD cards) |
| `/mnt`   | Manual / admin mounts           |
| `/`      | Root filesystem                 |

Manually mounted volumes **do not appear in the file browser** if mounted under `/mnt`.

---

## Creating a Mount Point

A mount point must exist **before mounting**.

Example:

```bash
sudo mkdir /mnt/backups
```

---

## Manually Mounting a Volume

```bash
sudo mount /dev/sdb1 /mnt/backups
```

If the filesystem is supported, Linux auto-detects it.

Verify:

```bash
mount | grep sdb
df -h
```

Now `/mnt/backups` represents the contents of the disk.

---

## Unmounting a Volume

You can unmount using:

* Device name **or**
* Mount point

```bash
sudo umount /mnt/backups
```

### “Target is busy” error

This happens if:

* You are currently inside the directory
* A process is using the filesystem

Fix:

```bash
cd /
sudo umount /mnt/backups
```

Avoid forcing unmounts unless absolutely necessary.

---

## Mount Options (`-o`)

Mount options control **security, performance, and behavior**.

Syntax:

```bash
sudo mount -o option1,option2 /dev/sdb1 /mnt/backups
```

---

## Common and Important Mount Options

### `ro` – Read-only

```bash
-o ro
```

* Prevents all writes
* Even root cannot write

Useful for:

* Backups
* Forensics
* Recovery systems

---

### `rw` – Read/write (default)

---

### `noexec`

```bash
-o noexec
```

* Prevents executing binaries from the mounted filesystem
* Common for external or untrusted storage

⚠️ Important caveat:

* `./script.sh` → blocked
* `bash script.sh` → **still works**

Why?

* The executable is `bash`, not the script

---

### `nosuid`

```bash
-o nosuid
```

* Disables SUID/SGID bits
* Prevents privilege escalation
* **Strong security recommendation**

Use this when mounting:

* External drives
* User-supplied disks

---

### `noatime`

```bash
-o noatime
```

* Disables access-time updates
* Reduces disk writes
* Improves performance

Common on:

* SSDs
* Databases
* Logs

---

## Example: Secure Read-Only Mount

```bash
sudo mount -o ro,noexec,nosuid,noatime /dev/sdb1 /mnt/backups
```

Result:

* Files visible
* No writes allowed
* No execution
* No privilege escalation

---

## Filesystems Without Permissions (exFAT Example)

Some filesystems **do not support Linux permissions**, including:

* exFAT
* FAT32
* NTFS (partially)

### Problem

After mounting:

* Files owned by `root`
* Normal users cannot write

---

## Fixing Ownership at Mount Time (exFAT)

Get your user and group IDs:

```bash
id
```

Example:

* UID: `1001`
* GID: `1001`

Mount with ownership override:

```bash
sudo mount -o uid=1001,gid=1001 /dev/sdb2 /mnt/partition2
```

Now files appear owned by your user.

---

## Permission Mask (`umask`)

Because exFAT has **no permissions**, Linux simulates them.

Syntax:

```bash
-o umask=027
```

Meaning:

```
0777 - 027 = 0750
```

Result:

* Owner: read/write/execute
* Group: read/execute
* Others: no access

Example:

```bash
sudo mount -o uid=1001,gid=1001,umask=027 /dev/sdb2 /mnt/partition2
```

---

## Why `chmod` Does Not Work on exFAT

```bash
chmod 700 file.txt
```

❌ No effect
Reason:

* Filesystem does not store permissions
* Permissions are simulated globally at mount time

---

## Demonstrating `noexec`

1. Create executable:

```bash
chmod +x script.sh
```

2. Normal mount:

```bash
./script.sh   # works
```

3. Mount with `noexec`:

```bash
sudo mount -o noexec /dev/sdb1 /mnt/backups
```

```bash
./script.sh   # permission denied
bash script.sh # still works
```



## Persistent Mounts with `/etc/fstab`

So far, we have manually mounted drives using the `mount` command.
However, there is a major limitation:

> ❌ **All manual mounts are lost after a reboot**

On servers, this is unacceptable.

Linux solves this using a configuration file called:

```
/etc/fstab
```

---

## What Is `/etc/fstab`?

![Image](https://geek-university.com/wp-content/images/linux/etc_fstab_file1.jpg)

![Image](https://i.sstatic.net/hxldt.png)

![Image](https://www.linuxjournal.com/sites/default/files/inline-images/BGKI-process.jpg)

![Image](https://www.computernetworkingnotes.com/wp-content/uploads/linux-tutorials/images/lt93-12-fstab-file-sixth.png)

`/etc/fstab` (filesystem table) defines:

* Which filesystems exist
* Where they should be mounted
* How they should be mounted
* When they should be checked

At boot time, the system reads `/etc/fstab` and mounts everything automatically.

---

## `/etc/fstab` File Format

Each line represents **one filesystem**:

```
<device> <mount_point> <fs_type> <options> <dump> <fsck_order>
```

### Field Breakdown

1. **Device identifier**

   * UUID (recommended)
   * `/dev/sdXn` (not recommended)
   * Labels

2. **Mount point**

   * Must exist (e.g. `/mnt/backups`)

3. **Filesystem type**

   * `ext4`, `vfat`, `xfs`, `exfat`, `swap`, etc.

4. **Mount options**

   * `defaults`, `ro`, `noexec`, `nosuid`, `noatime`, etc.

5. **Dump**

   * Legacy backup tool
   * Almost always `0`

6. **fsck order**

   * `1` → root filesystem
   * `2` → other filesystems
   * `0` → no check

---

## Why UUIDs Are Preferred

Example:

```bash
/dev/sda2
```

This name **can change** if:

* Drives are reordered
* Hardware changes
* USB / SATA order changes

UUIDs are **stable and unique**.

Get UUIDs safely:

```bash
lsblk -f
```

---

## Viewing the Current `/etc/fstab`

```bash
cat /etc/fstab
```

Typical entries you’ll see:

* Root filesystem (`/`)
* EFI boot partition (`/boot/efi`)
* Swap file or partition

These are created during installation.

---

## Common Default Mount Options

When you use:

```
defaults
```

It expands to:

* `rw`
* `suid`
* `dev`
* `exec`
* `auto`
* `nouser`
* `async`

Meaning:

* Read/write enabled
* SUID allowed
* Device files allowed
* Executables allowed
* Auto-mount at boot
* Only root can mount/unmount
* Async I/O for performance

---

## Adding a Persistent Mount (Example)

### Goal

Mount an ext4 backup disk permanently at:

```
/mnt/backups
```

### Step 1: Ensure mount point exists

```bash
sudo mkdir -p /mnt/backups
```

---

### Step 2: Get the UUID

```bash
lsblk -f
```

Copy the UUID of `/dev/sdb1`.

---

### Step 3: Edit `/etc/fstab`

```bash
sudo nano /etc/fstab
```

Add:

```
UUID=xxxx-xxxx-xxxx-xxxx  /mnt/backups  ext4  defaults,nosuid,noexec  0  2
```

Explanation:

* `nosuid` → prevents privilege escalation
* `noexec` → prevents executing binaries from this disk
* `2` → checked after root filesystem

---

### Step 4: Apply Without Rebooting

```bash
sudo mount -a
```

If there are **no errors**, the configuration is valid.

Verify:

```bash
df -h
mount | grep backups
```

---

## ⚠️ Critical Safety Rule

> ❗ **A broken `/etc/fstab` can prevent your system from booting**

Always:

1. Edit carefully
2. Run `mount -a`
3. Fix errors immediately

---

## Special Case: Network Filesystems (Concept Preview)

Not all filesystems are local.

Examples:

* FTP
* SFTP
* NFS
* SMB
* S3 (via FUSE)

These are often mounted using **FUSE** (Filesystem in Userspace).

---

## What Is FUSE?

FUSE allows:

* Filesystems implemented in **user space**
* Kernel forwards filesystem calls to user processes

Used for:

* FTP mounts
* S3 buckets
* SSHFS
* Cloud storage

---

## Mounting an FTP Server (Conceptual Example)

⚠️ **Ubuntu-only demo**
(The required tool is not in CentOS repos.)

### Required packages

```bash
sudo apt install fuse curlftpfs
```

---

### FTP Security Warning

FTP by default:

* ❌ Unencrypted
* ❌ Credentials sent in plain text

Prefer:

* **FTPS (FTP over TLS)**
* **SFTP (SSH-based)** ← recommended in real life

---

### Mounting an FTP Server

```bash
sudo mkdir /mnt/ftp
```

```bash
sudo curlftpfs -o ssl,user=USER:PASSWORD ftp.example.com /mnt/ftp
```

Now:

* `/mnt/ftp` behaves like a directory
* Files are remote
* Operations are slower
* Network-dependent

---

## Unmounting a FUSE Filesystem

Do **not** use `umount`.

Use:

```bash
fusermount -u /mnt/ftp
```

---

## Important FTP Caveats

* Network failures can break scripts
* Latency is higher
* Permissions are limited
* Root-only by default
* Credentials visible in command line

These issues must be addressed in production.













## Allowing Non-Root Access & Hiding Credentials (FUSE / FTP)



## Allowing All Users to Access a FUSE Mount

By default:

* Only the user who mounts a FUSE filesystem can access it
* Because we used `sudo`, that user was `root`

### Solution: `allow_other`

We add the following mount option:

```
allow_other
```

This allows **all users** to access the mounted filesystem.

> ⚠️ Important:
> `allow_other` must be enabled explicitly in FUSE mounts.

---

### Correct Mount Example

```bash
sudo curlftpfs -o ssl,allow_other ftp.example.com /mnt/ftp
```

If you see an error like:

```
unknown option allow_others
```

It’s a typo.
The correct option is **`allow_other`** (no `s`).

---

### Result

* Normal users can now:

  * Read files
  * Write files
  * Copy data
* Scripts no longer need to run as root

This is **critical for backup automation**.

---

### Unmounting a FUSE Filesystem

FUSE filesystems must be unmounted using:

```bash
fusermount -u /mnt/ftp
```

Not `umount`.

---

## Hiding FTP Credentials (Security Best Practice)

Putting credentials directly in commands or `/etc/fstab` is **unsafe** because:

* Command history can leak passwords
* `/etc/fstab` is readable by all users

### Solution: `.netrc`

`curlftpfs` uses **curl**, which supports a credentials file:

```
.netrc
```

This file stores login credentials securely.

---

## Creating the `.netrc` File (Root User)

Because mounting via `/etc/fstab` runs as root, credentials must be stored in:

```
/root/.netrc
```

### Important Note About `~`

This does **NOT** work:

```bash
sudo nano ~/.netrc
```

Why?

* `~` expands **before sudo**
* It points to your user’s home, not root’s

Always use the **full path**.

---

### Create the File

```bash
sudo nano /root/.netrc
```

Add:

```
machine ftp.example.com
login ftpuser
password ftppassword
```

Save and exit.

---

### Secure the File

```bash
sudo chmod 600 /root/.netrc
```

Only root can read it.

---

### Test Mount (No Credentials on CLI)

```bash
sudo curlftpfs -o ssl,allow_other ftp.example.com /mnt/ftp
```

✅ Mounted
✅ No password visible
✅ All users can access

---

## Automatically Mounting FTP via `/etc/fstab`

Now we are ready for **persistent mounting**.

---

## How FTP Works in `/etc/fstab`

FTP filesystems are **not kernel filesystems**.
They use **FUSE (Filesystem in Userspace)**.

That’s why:

* Filesystem type = `fuse`
* Device = `curlftpfs#server`

---

### `/etc/fstab` Entry Format (FTP via FUSE)

```
curlftpfs#ftp.example.com  /mnt/ftp  fuse  noauto,allow_other,ssl,x-systemd.automount  0  0
```

---

## Why These Options Matter

| Option                | Purpose               |
| --------------------- | --------------------- |
| `noauto`              | Do not mount at boot  |
| `x-systemd.automount` | Mount on first access |
| `allow_other`         | Allow non-root users  |
| `ssl`                 | Encrypted connection  |
| `0 0`                 | No dump, no fsck      |

### Why `noauto` + `x-systemd.automount`?

* Network may not be ready during boot
* Prevents boot delays or failures
* Mount occurs **only when accessed**

This is **best practice for network filesystems**.

---

## Applying the Configuration

After editing `/etc/fstab`:

```bash
sudo reboot
```

After reboot:

```bash
cd /mnt/ftp
```

➡️ Mount is triggered automatically
➡️ FTP server appears as a local directory

---

## Access from GUI & CLI

The mounted FTP directory:

* Appears under `/mnt`
* Works in file managers
* Supports drag & drop
* Works with scripts

From the system’s perspective:

> It’s just a directory

---

## What FUSE Enables (Big Picture)

![Image](https://www.researchgate.net/publication/221084248/figure/fig2/AS%3A667773634101255%401536221049456/FUSE-Architecture-Courtesy-of-15.png)

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/FUSE_structure.svg/330px-FUSE_structure.svg.png)

![Image](https://miro.medium.com/1%2AklgrZZBK1NPontwl1amTiA.png)

FUSE allows:

* Filesystems without kernel support
* Network-based storage
* Cloud storage mounts

Examples:

* FTP (curlftpfs)
* SFTP (sshfs)
* Amazon S3
* Google Cloud Storage

---

## Real-World Warning (Important)

FTP (even FTPS):

* Slower than local disks
* Network-dependent
* Not ideal for databases
* OK for backups, sync jobs, archives

In production:

* Prefer **SFTP / SSHFS**
* Prefer **NFS** for LAN
* Prefer **object storage APIs** for cloud

---

## Disk Health Monitoring with SMART

Now that we understand filesystems and volumes, let’s talk about **hardware failure prevention**.

Disks **do not last forever**.

---

## What Is SMART?

SMART = **Self-Monitoring, Analysis and Reporting Technology**

It allows disks to:

* Self-report errors
* Track wear
* Predict failure

SMART detects:

* Read/write errors
* Bad sectors
* Temperature issues
* SSD wear level

---

## Installing SMART Tools

```bash
sudo apt install smartmontools
```

---

## Checking Disk Health

```bash
sudo smartctl -a /dev/sda
```

Look for:

```
SMART overall-health self-assessment test result: PASSED
```

If it says **PASSED**, the disk is healthy.

---

## Important SMART Notes

* SMART checks **hardware only**
* It does **not** detect filesystem corruption
* Virtual disks often **do not support SMART**

That’s normal in VMs.

---

## Example SMART Metrics (Physical Disks)

| Attribute             | Meaning              |
| --------------------- | -------------------- |
| Reallocated_Sector_Ct | Bad sectors replaced |
| Power_On_Hours        | Disk lifetime        |
| Temperature_Celsius   | Disk temperature     |
| Wear_Leveling_Count   | SSD wear             |

SSD example:

* 99% health → normal
* Rapid drop → replace disk soon

---

## SMART in DevOps & Production

In real systems:

* SMART is monitored automatically
* Alerts are generated before failure
* Disks are replaced **before data loss**











# File System Checking & Recovery (fsck) — Linux Deep Dive

## Why File System Checks Matter

File system checks are **not needed when everything works**.
They become critical when something goes wrong:

### Common Causes of File System Errors

1. **Unexpected power loss**

   * System shuts down while writing data
   * Journaling helps, but corruption is still possible
2. **Kernel or filesystem driver bugs**
3. **Failing hardware**

   * Bad sectors
   * Silent data corruption
4. **Improper unmount**

   * Forced reboot
   * Kernel panic
5. **Manual disk-level operations**

   * `dd`
   * Partition edits
   * Disk cloning mistakes

Modern filesystems (like ext4) are much more resilient than 10–20 years ago, but **corruption still happens**.

---

## Critical Limitation of fsck (Very Important)

> **You cannot safely run fsck on a mounted filesystem**

For **ext4**:

* The filesystem **must be unmounted**
* Otherwise, you risk **permanent data loss**

This creates a problem for:

* Production servers
* 24/7 systems

### Real-World Reality

* fsck causes **downtime**
* You must choose between:

  * Availability
  * Data integrity

Typical solutions:

* Maintenance windows
* Redundant systems (cloud, HA)
* Live migration + offline repair

---

## Manual File System Check (Unmounted Volume)

### Step 1: Unmount the filesystem

```bash
sudo umount /dev/sdb1
```

### Step 2: Run filesystem check

```bash
sudo fsck /dev/sdb1
```

If the filesystem is ext4, this internally calls:

```bash
fsck.ext4
```

### Typical Output (Healthy Filesystem)

```
clean, 12345/65536 files, 67890/262144 blocks
```

If errors are found, fsck will prompt for fixes.

---

## Checking the Root Filesystem (Special Case)

You **cannot unmount `/`** while the system is running.

### Option 1: Force fsck on next boot (GRUB)

At the GRUB menu:

1. Press `e` to edit boot entry
2. Find the Linux kernel line
3. Add:

```
fsck.mode=force
```

4. Boot with `F10`

This forces a filesystem check **during boot**.

---

### Viewing fsck Results After Boot

```bash
journalctl -b | grep fsck
```

Or simply:

```bash
journalctl -b
```

(fsck output appears early in boot logs)

---

## Alternative Recovery Method (Last Resort)

If:

* System does not boot
* GRUB is inaccessible
* Root filesystem is badly corrupted

### Use a Live Linux Environment

* Boot from USB
* Mount disks manually
* Run `fsck` from outside the system

This method is also used during **full system recovery**.

---

## Automatic File System Checks (fsck Scheduling)

Linux supports **automatic checks**, but Ubuntu disables most of them by default.

### When Ubuntu Runs fsck Automatically

* Only when the filesystem is marked **dirty**
* Usually after:

  * Power loss
  * Improper shutdown

---

## Disabling Automatic Checks (fstab)

In `/etc/fstab`, the **last column** controls fsck behavior:

```
UUID=xxxx  /  ext4  defaults  0  1
```

### fsck column values

| Value | Meaning              |
| ----- | -------------------- |
| `0`   | Never check          |
| `1`   | Root filesystem      |
| `2`   | Non-root filesystems |

### Example: Disable fsck completely

```
UUID=xxxx  /data  ext4  defaults  0  0
```

⚠️ **This prioritizes availability over data integrity**

---

## Enabling Routine Automatic Checks (tune2fs)

### View current fsck settings

```bash
sudo tune2fs -l /dev/sda2 | grep -i check
```

Typical output:

```
Last checked: ...
Check interval: none
```

### View mount-based check settings

```bash
sudo tune2fs -l /dev/sda2 | grep -i mount
```

```
Maximum mount count: -1
```

`-1` = never check

---

### Enable fsck Every 30 Mounts

```bash
sudo tune2fs -c 30 /dev/sda2
```

Verify:

```bash
sudo tune2fs -l /dev/sda2 | grep -i mount
```

---

### Enable Time-Based fsck (Every 6 Months)

```bash
sudo tune2fs -i 6m /dev/sda2
```

This triggers fsck on next boot **after 6 months**.

---

## Important Production Warning

Automatic fsck means:

* Boot may take **minutes**
* Server is **unavailable**
* Users may think the system is “stuck”

### Best Use Cases

* Desktop systems
* Lab machines
* Non-critical servers

### Avoid on:

* High-availability production systems
* Latency-sensitive workloads

---

# Recovering a Broken File System (Danger Zone)

⚠️ **This section is dangerous**

* One wrong command = permanent data loss
* Do NOT practice on real systems
* Virtual machines only

---

## Simulating File System Damage (dd)

We intentionally corrupt the filesystem **at disk level**.

### Unmount the filesystem first

```bash
sudo umount /mnt/backups
```

---

### Destroy filesystem metadata (example)

```bash
sudo dd if=/dev/urandom of=/dev/sdb1 bs=1M count=10
```

What this does:

* Overwrites the **first 10 MB**
* Destroys superblock & directory structure
* Instant corruption

This is **irreversible**.

---

## Symptoms of a Broken Filesystem

* Cannot mount
* `bad superblock`
* UUID missing
* Mount fails from `/etc/fstab`

---

## Repairing the Filesystem

```bash
sudo fsck /dev/sdb1
```

When prompted:

* Press `a` → **fix all errors**

fsck will:

* Rebuild metadata
* Reattach recoverable files
* Move orphaned files to `lost+found`

---

## After Repair: What Happens to Data?

* Directory structure may be lost
* Files may survive
* Recovered files appear in:

```
lost+found/
```

Access requires root privileges.

Example:

```bash
sudo ls /mnt/backups/lost+found
```

Recovered files:

* Renamed to numbers
* No original filenames
* No directory hierarchy

---

## Reality of Data Recovery

fsck:

* **Does not guarantee full recovery**
* Saves what it can
* Loses what it must

This is why:

* Backups matter
* Redundancy matters
* Monitoring matters










# Resizing File Systems in Linux (Shrink & Grow)

Resizing storage is a **two-layer operation**:

1. **Partition** (disk layout)
2. **Filesystem** (data structure inside the partition)

👉 **You must resize them in the correct order**, or you will corrupt the filesystem.

---

## 1. First Rule: Not All File Systems Can Be Resized

Before doing anything, confirm that the filesystem **supports resizing**.

### Common Filesystem Capabilities

| Filesystem | Shrink | Grow | Online Resize |
| ---------- | ------ | ---- | ------------- |
| ext4       | ✅      | ✅    | Grow only     |
| ext3       | ✅      | ✅    | Limited       |
| ext2       | ✅      | ✅    | Limited       |
| XFS        | ❌      | ✅    | Grow only     |
| exFAT      | ❌      | ❌    | Not supported |
| FAT32      | ❌      | ❌    | Not supported |

⚠️ **exFAT / FAT32 cannot be resized safely on Linux**
You must:

* Backup data
* Recreate filesystem
* Restore data

---

## Scenario Overview

We have:

* `/dev/sdb1` → ext4
* `/dev/sdb2` → ext4 (we will shrink)
* Free space → create a new partition

---

# PART A — Shrinking a Filesystem (Most Dangerous Operation)

Shrinking is **always riskier** than growing.

### Required Order (Must Be Followed)

1. Unmount filesystem
2. Check filesystem (`fsck`)
3. Shrink filesystem
4. Shrink partition

---

## Step 1: Unmount the Filesystem

```bash
sudo umount /dev/sdb2
```

You **cannot shrink a mounted filesystem**.

---

## Step 2: Check Filesystem Integrity (Mandatory)

```bash
sudo fsck /dev/sdb2
```

If errors exist, resizing may fail or corrupt data.

---

## Step 3: Shrink the Filesystem (resize2fs)

Example: shrink to **10 GiB**

```bash
sudo resize2fs /dev/sdb2 10G
```

Important:

* `resize2fs` works on **filesystem**, not partition
* Data at the end of the filesystem must be moved → may take time

---

## Step 4: Shrink the Partition (parted)

Now the **partition** is still larger than the filesystem.

```bash
sudo parted /dev/sdb
```

Inside `parted`:

```text
unit GiB
print
resizepart 2 10.5GiB
```

Why **10.5 GiB** and not exactly `10`?

* Filesystem size uses **GiB**
* Rounding errors can make the partition **smaller than the filesystem**
* Always leave buffer space

Exit:

```text
quit
```

---

## Verification

```bash
sudo mount /dev/sdb2 /mnt/test
df -h /mnt/test
```

If mount works → shrink succeeded.

---

# PART B — Creating a New Partition in Freed Space

```bash
sudo parted /dev/sdb
```

```text
mkpart primary ext4 10.5GiB 15GiB
quit
```

Create filesystem:

```bash
sudo mkfs.ext4 /dev/sdb3
```

Mount and test:

```bash
sudo mkdir -p /mnt/data
sudo mount /dev/sdb3 /mnt/data
touch /mnt/data/testfile
```

---

# PART C — Growing a Filesystem (Safe Operation)

Growing is safer and often possible **online**.

### Required Order (Opposite of Shrinking)

1. Grow partition
2. Grow filesystem

---

## Step 1: Grow the Partition (Online)

Filesystem may remain mounted.

```bash
sudo parted /dev/sdb
```

```text
unit GiB
resizepart 3 100%
quit
```

---

## Step 2: Grow the Filesystem

For ext4, size auto-detects:

```bash
sudo resize2fs /dev/sdb3
```

This works **even while mounted**.

---

## Verification

```bash
df -h /mnt/data
```

Filesystem now uses full partition size.

---

# Why Order Matters (Critical Concept)

### ❌ Wrong Order (Causes Corruption)

* Shrink partition first
* Filesystem larger than partition
* Result: **unmountable filesystem**

### ✅ Correct Order

| Operation | Filesystem | Partition |
| --------- | ---------- | --------- |
| Shrink    | First      | Second    |
| Grow      | Second     | First     |

Memorize this — **interview favorite**.

---

# Production Safety Rules

1. **Never resize without backups**
2. **Never shrink mounted filesystems**
3. **Always run fsck before shrinking**
4. **Use GiB units to avoid rounding errors**
5. **Leave buffer space when shrinking**
6. **Avoid resizing root filesystem live**
7. **Prefer LVM for flexible resizing**









