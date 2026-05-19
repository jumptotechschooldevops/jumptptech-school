---
title: "linux day #1"
description: "1. What is an Operating System (OS)?   An operating system is system software..."
published: 2025-12-24
source: "https://dev.to/jumptotech/linux-day-1-2745"
tags: []
---

# linux day #1


## 1. What is an Operating System (OS)?

An **operating system** is system software that:

* Manages **computer hardware** (CPU, memory, disk, network)
* Provides **services** for applications
* Allows users and programs to interact with the computer

### Examples:

* Windows
* macOS
* Linux

**Without an operating system, applications cannot run.**

---

## 2. What is Unix?

**Unix** is a powerful operating system that was created in the late 1960s.

Key characteristics of Unix:

* **Multi-user**
  Multiple users can use the system at the same time, each with different permissions.

* **Multitasking**
  Multiple programs can run simultaneously.

* **Stable and secure**
  This is why Unix became very popular in servers and enterprise systems.

Originally:

* Unix was **proprietary** (closed source)
* Different companies created their own Unix versions (Solaris, AIX, HP-UX)

---

## 3. What does “multi-user” really mean?

A simple example:

* When Windows asks:
  *“Do you want to allow this app to make changes to your device?”*
* That is a **multi-user permission model**

Unix and Linux were designed around this concept **from the beginning**, which makes them ideal for servers and security-focused systems.

---

## 4. What is a Kernel?

The **kernel** is the **core part** of an operating system.

It is responsible for:

* CPU scheduling
* Memory management
* Disk access
* Network communication
* Talking directly to hardware

Think of it like this:

> **Applications → Operating System → Kernel → Hardware**

Without the kernel, the OS cannot function.

---

## 5. What is Linux?

**Linux is a kernel.**
Not a full operating system by itself.

Linux kernel responsibilities:

* Manages hardware
* Handles system calls
* Controls memory, CPU, and devices

The Linux kernel is:

* **Open source**
* Free to use and modify
* Widely used in servers, cloud, security, and embedded systems

---

## 6. What does “Unix-like” mean?

Linux is described as **Unix-like** because:

* It behaves like Unix
* It follows Unix design principles
* It uses similar commands (`ls`, `cp`, `chmod`, `ps`, etc.)
* But it is **not original Unix**

Linux was created as a **free replacement** for Unix.

---

## 7. What is GNU?

**GNU** stands for:

> **GNU is Not Unix**

The GNU Project started in **1983** with the goal of creating:

* A **free**
* **Open-source**
* Unix-compatible operating system

GNU created:

* Compilers (`gcc`)
* Shells (`bash`)
* Core utilities (`ls`, `cat`, `grep`, `chmod`, etc.)

But GNU **did not have a kernel**.

---

## 8. How GNU and Linux work together

Here is the key idea:

* **Linux** → provides the **kernel**
* **GNU** → provides the **tools and utilities**

Together they form a complete operating system:

> **GNU + Linux = a full Unix-like operating system**

Technically, this is called **GNU/Linux**.

---

## 9. Why do we usually just say “Linux”?

In practice:

* Saying **“GNU/Linux”** is technically correct
* Saying **“Linux”** is common and accepted

So when people say:

* “Linux server”
* “Linux OS”
* “Linux system”

They usually mean **GNU/Linux**.

---

## 10. Linux in real life

Linux is everywhere:

* **Servers & Cloud** (AWS, Azure, GCP)
* **Cybersecurity tools**
* **DevOps environments**
* **Microcomputers** (Raspberry Pi)
* **IoT devices**
* **Android smartphones** (Android runs on the Linux kernel)

Even:

* **macOS and iOS** are based on **Unix principles** (BSD/Unix foundation)

---

## 11. Simple summary (interview-friendly)

You can answer like this:

> Linux is an open-source kernel used to build Unix-like operating systems.
> GNU provides the tools and utilities, and together they form GNU/Linux.
> Linux is widely used in servers, cloud computing, cybersecurity, and embedded systems because it is stable, secure, and flexible.











# Linux Distributions Explained

## 1. What is a Linux Distribution?

A **Linux distribution (distro)** is a **complete operating system** built on top of:

* **Linux kernel** (core)
* **GNU tools and utilities**
* Additional software selected for a specific purpose

In short:

> **GNU + Linux kernel + extra software = Linux distribution**

Examples of extra software:

* Package managers
* Desktop environments
* Web servers
* Security tools
* System utilities

That is why Linux distributions exist — **to serve different user needs**.

---

## 2. Why are there many Linux distributions?

Different users need different things:

* Beginners → user-friendly systems
* Servers → stability and security
* Enterprises → long-term support
* Developers → modern packages
* Security professionals → hardened systems

Because Linux is open source:

* Anyone can create a distribution
* Many distributions share common tools
* Differences are usually in **defaults, configuration, and support model**

---

## 3. Free vs Paid Linux Distributions

Most Linux distributions are **free**.

Some are **commercial** (paid), but this is allowed by open-source licenses as long as:

* Source code is available
* Users can inspect and modify it

Paid distributions usually offer:

* Enterprise support
* Security guarantees
* Long-term maintenance


### 1. Ubuntu

* Based on the **Debian family**
* Designed to be **user-friendly**
* Very popular for:

  * Beginners
  * Developers
  * Cloud environments
* Excellent documentation and community support

### 2. CentOS Stream

* Part of the **Red Hat family**
* Free to use
* Closely related to **Red Hat Enterprise Linux (RHEL)**
* Ideal for:

  * Enterprise-style environments
  * Learning Red Hat ecosystems
  * Professional and production-like setups





## 9. Ways to Run Linux on Your Computer

There are multiple options:

### Option 1: Install Linux as the main OS

* Replace Windows or macOS
* Linux becomes your primary system

### Option 2: Dual Boot

* Install Linux alongside Windows
* Choose OS at boot time













# Installing Ubuntu  in VirtualBox



you will learn:

* How to install **Ubuntu Linux** in VirtualBox
* How to install **CentOS Stream** in VirtualBox
* How to configure VirtualBox so the virtual machine is **comfortable to use**
* How to enable:

  * Copy & paste
  * Shared folders
  * Better mouse and screen behavior
* How to **pause, resume, and shut down** virtual machines correctly



# PART 1 — Installing Ubuntu in VirtualBox

## 1. Download Ubuntu Desktop (LTS)

1. Go to **ubuntu.com**
2. Click **Download → Ubuntu Desktop**
3. Download the **latest LTS version**

   * LTS = Long Term Support
   * Supported for several years
   * More stable for learning and courses

> Ubuntu releases versions every 6 months, but LTS releases every 2 years.

## 2. Create a New Ubuntu Virtual Machine

1. Open **VirtualBox**
2. Click **New**
3. Name the VM: `Ubuntu-LTS`
4. Select the downloaded **Ubuntu ISO**
5. **IMPORTANT:**
   ✅ Check **“Skip unattended installation”**
   (If you cannot check it, that’s fine — continue anyway)

Why:

* Automatic installs often break:

  * Language settings
  * Terminal
  * `sudo` permissions

---

## 3. Allocate Resources

Recommended (minimum → better):

* **RAM:**

  * Minimum: 512 MB
  * Recommended: 2 GB
* **CPU:**

  * Minimum: 1 core
  * Recommended: 2–4 cores
* **Disk:**

  * Recommended: **100 GB**
  * Disk grows only when used

Click **Next → Finish**

---

## 4. Install Ubuntu

1. Start the VM
2. Select **Try or Install Ubuntu**
3. Click **Install Ubuntu**
4. **Keyboard layout**

   * Choose carefully (very important)
5. Select:

   * **Normal installation**
   * ✅ Install updates
   * ✅ Install third-party software
6. Choose **Erase disk and install Ubuntu**

   * This affects only the virtual disk
7. Set:

   * Name
   * Computer name
   * Username
   * Password (keep it simple)
   * Optional: Auto-login
8. Click **Install**
9. Wait ~10 minutes
10. Click **Restart**

Ubuntu is now installed.

---

## 5. Basic Ubuntu First Boot

* Skip welcome tour if shown
* If you see a **battery icon instead of power icon**, this is normal
* Ubuntu is now ready, but **not fully optimized yet**

---

## 6. Install VirtualBox Guest Additions (Ubuntu)

Guest Additions improve:

* Mouse behavior
* Screen resizing
* Clipboard sharing
* Shared folders

### Step 1: Update System

Open **Terminal** and run:

```bash
sudo apt update
sudo apt full-upgrade -y
```

Restart if kernel updates were installed.

---

### Step 2: Install Required Tools

```bash
sudo apt install -y build-essential linux-headers-generic dkms
```

Why:

* Guest Additions drivers are **compiled from source**
* These tools allow compilation and kernel integration

---

### Step 3: Install Guest Additions

1. In VirtualBox menu:

   * **Devices → Insert Guest Additions CD Image**
2. Open Terminal
3. Run (drag the file into terminal):

```bash
sudo /media/*/VBoxLinuxAdditions.run
```

4. Confirm installation
5. Restart the VM

---

## 7. Enable Convenience Features (Ubuntu)

### Clipboard

* **Devices → Clipboard → Bidirectional**

### Shared Folders

1. **Devices → Shared Folders → Settings**
2. Add a folder (e.g., Desktop)
3. Enable:

   * Auto-mount
   * Make permanent
   * Read & Write
4. Access via:

   * Files → Other Locations

Now you can exchange files between **Windows/macOS ↔ Ubuntu**.

---

## 8. Pausing and Shutting Down Ubuntu

* Close VM window:

  * **Save Machine State** → pause
  * **Power off** → shutdown
* Saved state resumes instantly later



Creating and Using Snapshots

## Why Snapshots Matter

Snapshots allow you to:

* Go back in time
* Undo mistakes
* Recover broken systems
* Avoid reinstalling Linux

You should **always create a snapshot after setup**.

---

## 1. Create a Snapshot

1. Power off or keep VM running
2. VirtualBox → **Snapshots**
3. Click **Take Snapshot**
4. Name it:
   `After Clean Install`
5. Click **OK**

---

## 2. Restore a Snapshot

If something breaks:

1. Power off VM
2. Open **Snapshots**
3. Select snapshot
4. Click **Restore**
5. ❌ Do NOT take another snapshot
6. Start VM

Your system is restored to a working state.

---

## Important Safety Note

Snapshots **do not protect**:

* Files deleted from **shared folders**
* Files deleted from your **Windows host**

Best practice:

* Use shared folders carefully
* Prefer **read-only** shared folders if unsure






















\

# Installing Ubuntu on Apple Silicon Macs (M1 / M2 / M3)



This lecture is **only for Mac users** who:

* Do **NOT** have an Intel Mac
* Have a Mac with an **Apple processor**:

  * M1
  * M2
  * M3 (and newer)

If you have an **Intel Mac**, you should **not** follow this lecture.
You can use **VirtualBox** instead.

---

## Why We Cannot Use VirtualBox on Apple Silicon

Apple Silicon Macs use the **ARM CPU architecture**, while VirtualBox is mainly optimized for **x86 (Intel/AMD)** processors.

Because of this:

* VirtualBox support on Apple Silicon is **limited**
* Performance is poor or features don’t work correctly

So we need a different solution.

---

## What Is UTM?

**UTM** is a virtualization tool made specifically for macOS.

It supports two modes:

1. **Apple Virtualization** (fast – recommended)
2. **QEMU Emulation** (slow – not recommended)

In this course, we will use:

> ✅ **Apple Virtualization**

This requires:

* Guest operating system compiled for **ARM**
* Host and guest CPU architecture must match

That is why we must download **Ubuntu for ARM (arm64)**.

---

## CPU Architecture (Simple Explanation)

### x86 / x86_64 / AMD64

* Used by Intel and AMD
* Common on:

  * Windows PCs
  * Older Macs
* All names mean the **same architecture**

### ARM (arm64 / aarch64)

* Used by:

  * Apple Silicon Macs
  * Smartphones
  * Many cloud servers
* Very energy efficient
* Different “language” than x86 CPUs

> A processor can only execute instructions written for its architecture.

That’s why:

* x86 Linux cannot run directly on ARM
* ARM Linux **must** be used on Apple Silicon

---

## Why We Use Apple Virtualization (Not Emulation)

### Apple Virtualization

* Uses macOS native virtualization
* Very fast
* Low overhead
* Requires ARM Linux (which we use)

### QEMU Emulation

* Emulates a full CPU
* Extremely slow
* Not needed for this course

> ❌ Do NOT use QEMU unless absolutely necessary

---

# PART 1 — Download Ubuntu for ARM (LTS)

## Important Requirements

* Must be **Ubuntu Desktop**
* Must be **ARM64**
* Must be **LTS (Long Term Support)**

⚠️ **Do NOT download:**

* Ubuntu Server
* x86 / AMD64 ISO

---

## How to Find the Correct ISO

The ARM desktop ISO is not always visible on the main Ubuntu page.

### Option 1: Direct Search

Search for:

```
Ubuntu Desktop Live Jammy ARM64
```

### Option 2: Ubuntu Release Page

Look for:

* **Desktop**
* **arm64**
* **ISO**

Example (Jammy = 22.04 LTS):

```
ubuntu-22.04.x-desktop-arm64.iso
```

Download the **Desktop ISO**, not Server.

---

# PART 2 — Install UTM on macOS

## Download UTM

Go to:

```
https://mac.getutm.app
```

You have two options:

* **Mac App Store** (paid – supports developers)
* **Direct download** (free – open source)



> ✅ Direct download is perfectly fine

---

## Install UTM

1. Download the **DMG**
2. Open it
3. Drag **UTM** into **Applications**
4. Open UTM

UTM is now installed.

---

# PART 3 — Create Ubuntu Virtual Machine in UTM

## Step 1: Create New VM

1. Open **UTM**
2. Click **Create**
3. Choose **Virtualize**
4. Choose **Linux**
5. Choose **Apple Virtualization**
   ⚠️ This is critical

---

## Step 2: Select Ubuntu ARM ISO

1. Click **Boot ISO Image**
2. Browse to your downloaded:

   ```
   ubuntu-*-desktop-arm64.iso
   ```
3. Click **Continue**

---

## Step 3: Allocate Resources

Recommended settings:

* **Memory:** 2–4 GB
* **CPU cores:** 2–4
* **Storage:** 64–100 GB

Shared directories:

* Leave empty for now (we’ll configure later)

Click **Continue**

---

## Step 4: Save and Start VM

* Name the VM (e.g. `Ubuntu-Desktop`)
* Click **Save**
* Click **Play**

---

# PART 4 — Install Ubuntu Inside UTM

## Boot Screen

* Select **Try or Install Ubuntu**
* Press **Enter**

⚠️ You may see **boot warnings or errors**
These are normal on ARM → **ignore them**

---

## Ubuntu Installer Steps

1. Click **Install Ubuntu**
2. Language: English
3. **Keyboard layout**

   * Choose carefully
   * If you’re not using US keyboard → change it
   * Mac users should select **Macintosh layout**
4. Select:

   * Normal installation
   * Install updates
   * Install third-party software
5. Choose **Erase disk and install Ubuntu**

   * This affects only the virtual disk
6. Set:

   * Name
   * Username
   * Password (simple is fine)
   * Enable **automatic login** (recommended)
   * Set computer name (optional)

Click **Install**

---

## Installation Time

* Usually 3–5 minutes
* Progress bar may restart → this is normal
* Wait until completion

---

## Restart

* Click **Restart Now**
* Ubuntu boots into your new system

---

# PART 5 — First Boot on Apple Silicon

After login:

* Skip welcome screens if desired
* Internet should already work
* Copy & paste **text** usually works
* Keyboard shortcuts may use **Ctrl** instead of **Cmd**

---

## Display Resolution (Important)

UTM does **not auto-resize** the display.

Fix manually:

1. Open **Settings**
2. Go to **Display**
3. Choose higher resolution if needed

---

## Current Limitations (Normal)

* No automatic screen resize
* Drag & drop may not work
* This is expected behavior in UTM

---

# Why This Setup Works Well

* Native Apple virtualization
* ARM-optimized Linux
* Fast performance
* Stable for learning
* No CPU emulation overhead


















# Configuring Ubuntu  on macOS Using UTM (Apple Silicon)


This  is for **Mac users with Apple Silicon (M1 / M2 / M3)** who are running:

* **Ubuntu** in UTM


At this point, your Linux system already works.
We only need to **finish configuration**, mainly:

* Access files from macOS
* Make shared folders permanent
* Improve usability
* Create a safe backup (clone)


UTM supports shared folders, but they need **manual setup inside Linux**.

---

# PART 1 — Adding a Shared Folder in UTM (Ubuntu)

## Step 1: Add Shared Directory in UTM

1. Open **UTM**
2. Select your virtual machine
3. Click **Settings** (slider icon)
4. Go to **Sharing / Directory Sharing**
5. Add a folder from macOS
   👉 **Recommended:** create a dedicated folder like:

   ```
   ~/utm-shared
   ```
6. Confirm

⚠️ The folder may **not appear immediately** inside Linux.
This is normal.

---

## Step 2: Create a Mount Directory Inside Linux

Open **Terminal** in Ubuntu or CentOS and run:

```bash
sudo mkdir -p /mnt/shared
```

* This folder will hold all shared directories
* You can name it anything, but `/mnt/shared` is a clean convention

---

## Step 3: Mount the Shared Folder Manually

UTM uses **virtiofs** for directory sharing.

Run:

```bash
sudo mount -t virtiofs share /mnt/shared
```

Important notes:

* `share` is **always** called `share`
  (it does NOT depend on your folder name)
* `/mnt/shared` must exist

---

## Step 4: Verify Access

1. Open **Files**
2. Go to:

   ```
   Computer → /mnt/shared
   ```
3. You should see your macOS shared folder

Test it:

* Create a file in Linux → appears on macOS
* Rename a file → reflected on macOS
* Delete a file → deleted on macOS

✅ File sharing works

---

# PART 2 — Make Shared Folder Persistent (Auto-Mount)

## Why This Is Needed

After reboot:

* Shared folders disappear
* You would need to re-run the mount command

To avoid this, we update **`/etc/fstab`**.

---

## Step 1: Edit `/etc/fstab`

Open the file with admin privileges:

```bash
sudo nano /etc/fstab
```

(Add `nano` if prompted — it’s usually installed)

---

## Step 2: Add This Line at the Bottom

```
share   /mnt/shared   virtiofs   rw,nofail   0   0
```

Explanation (high level, no deep theory yet):

* `share` → virtiofs shared source
* `/mnt/shared` → mount location
* `virtiofs` → filesystem type
* `rw,nofail` → read/write, don’t fail boot
* `0 0` → standard settings

---

## Step 3: Save and Exit

In `nano`:

* `CTRL + O` → save
* `Enter`
* `CTRL + X` → exit

---

## Step 4: Reboot and Test

```bash
sudo reboot
```

After reboot:

* Open **Files**
* Go to `/mnt/shared`
* Folder should be available **automatically**

✅ Permanent shared folder enabled

---

## Safety Recommendation (Important)

⚠️ **Do NOT share your entire home directory**

Best practice:

* Share **one dedicated folder only**
* Assume everything inside can be deleted accidentally
* Never share:

  * Documents
  * Desktop
  * Home directory
  * System folders

This keeps your macOS safe even if you run dangerous commands.

---

# PART 3 — Clipboard Behavior (macOS ↔ Linux)

Clipboard works automatically in UTM:

* Copy in Linux → paste in macOS
* Copy in macOS → paste in Linux

⚠️ Keyboard shortcuts:

* **Linux:** `Ctrl + C`, `Ctrl + V`
* **macOS:** `Cmd + V`

This difference is normal.

---

# PART 4 — Display Settings (Highly Recommended)

## Adjust Resolution & Scaling

Especially useful on MacBooks.

1. Open **Settings**
2. Go to **Displays**
3. Choose:

   * Higher resolution
   * Optional scaling
4. Click **Apply**

This improves:

* Sharpness
* Readability
* Comfort during long sessions

---

# PART 5 — Cloning the Virtual Machine (Your Safety Net)

## Why Cloning Is Important

If you:

* Break the system
* Delete critical files
* Misconfigure Linux
* Want to experiment freely

A **clone** lets you recover instantly.

---

## How to Clone in UTM

1. Shut down the VM
2. Right-click the VM
3. Select **Clone**
4. Confirm

Now you have:

* Original (clean)
* Clone (experiment freely)

⚠️ Note:

* Shared folders may need to be re-selected in UTM settings
* `/etc/fstab` changes remain intact













# First Steps in the Terminal (Bash Basics)

## 1. Opening the Terminal


### On Ubuntu

1. Click **Show Applications**
2. Search for **Terminal**
3. Click to open it

> The terminal may look different on Ubuntu .
> This is **normal**.
> The behavior is the same.

---

## 2. What Is the Terminal?

The terminal is a **text-based interface** to your computer.

Instead of clicking buttons:

* You **type commands**
* Press **Enter**
* The system executes them

If you type something invalid (like random text), Linux will respond with an error.

Example:

```bash
hello world
```

Output:

```text
command not found
```

This simply means:

> Linux tried to find a program called `hello` and could not find it.

---

## 3. Your First Command: `echo`

The `echo` command prints text to the terminal.

### Basic Example

```bash
echo 'bash is amazing!'
```

Output:

```text
bash is amazing!
```

### Important Notes (for now)

* Use **single quotes** exactly as shown
* Quotes in Bash work **differently** than in other programming languages
* We will explain this later in the **expansions chapter**

For now:

> **Type it exactly as shown**

---

## 4. Understanding a Bash Command

This command:

```bash
echo 'bash is amazing!'
```

Breaks down into:

* **Command:** `echo`
* **Argument:** `'bash is amazing!'`

General structure:

```text
command [options] [arguments]
```

Everything together is called a **Bash command**.

---

## 5. Line Break Behavior in `echo`

By default, `echo` prints a **line break** at the end.

### Example

```bash
echo 'hello'
```

Cursor moves to the next line.

---

### Disable Line Break: `-n`

```bash
echo -n 'hello'
```

Now the cursor stays on the **same line**.

This is normal behavior.

---

## 6. Command History & Editing

You **do not need to retype commands**.

### Useful Keys

* **Arrow Up** → previous command
* **Arrow Down** → next command
* **Arrow Left / Right** → move cursor
* Edit the command
* Press **Enter** to run again

This is extremely important for productivity.

---

## 7. Clearing the Terminal

To clear the screen:

```bash
clear
```

This does **not** delete anything.
It only clears the visible output.

---

## 8. Escape Sequences (`-e` option)

The `-e` option enables **escape sequences** like `\n`.

### Without `-e`

```bash
echo 'bash\namazing'
```

Output:

```text
bash\namazing
```

---

### With `-e`

```bash
echo -e 'bash\namazing'
```

Output:

```text
bash
amazing
```

`\n` becomes a **real line break**.

---

## 9. Combining Options

Options can usually be combined.

### These are equivalent:

```bash
echo -e -n 'bash\namazing'
```

```bash
echo -en 'bash\namazing'
```

Result:

* `-e` → enables `\n`
* `-n` → disables final line break

---

## 10. Why This Matters

This may look simple, but these ideas are **fundamental**:

* Commands
* Options
* Arguments
* Output
* Line breaks

Later you will:

* Write output to files
* Chain commands
* Build scripts
* Automate tasks

Everything starts here.

---

## 11. Confirm You Are Using Bash

Some systems use different shells by default.

Run:

```bash
echo "${BASH_VERSION}"
```

If you see a version number (for example `5.1.x`):

> ✅ You are using Bash

If nothing prints:

> ❌ You are NOT in Bash

---

## 12. Starting Bash Manually (If Needed)

If Bash is not active:

```bash
bash
```

Press **Enter**.

Now run again:

```bash
echo "${BASH_VERSION}"
```

---

### Important Rule

Each terminal window or tab is **independent**.

If your system does **not** start Bash automatically:

* You must run `bash` **every time you open a new terminal**

Later in the course, we will change the default shell if needed.

---

## 13. Terminal Appearance (Optional)

You can customize the terminal:

1. Right-click → **Preferences**
2. Change:

   * Font size
   * Colors
   * Theme

This **does not affect commands**.
Choose what is comfortable.

















# Navigating the File System in the Shell

## 1. The Working Directory

Whenever you open a terminal, you are **always inside a directory**.

This directory is called the **working directory**.

* Commands run **from this directory**
* Programs can access files **relative to this directory**

To find out **where you are**, we use the `pwd` command.

---

## 2. `pwd` — Print Working Directory

`pwd` stands for **print working directory**.

### Example

```bash
pwd
```

Example output:

```text
/home/yourusername
```

This means:

* You are currently in the folder `/home/yourusername`
* This is your **home directory**

### Notes

* On Linux, there are **no drive letters** like `C:` or `D:`
* Everything starts from a single root directory: `/`
* Other systems may look different:

  * Linux: `/home/username`
  * macOS: `/Users/username`

---

## 3. The Home Directory (`~`)

Often, the terminal shows a `~` symbol.

Example prompt:

```text
~ $
```

This means:

* `~` is a shortcut for **your home directory**
* It is equivalent to `/home/yourusername`

⚠️ This depends on terminal configuration.
If you don’t see it, **that’s fine** — `pwd` always works.

---

## 4. Changing Directories with `cd`

To move between directories, we use:

```bash
cd
```

`cd` stands for **change directory**.

---

### Example 1: Move into a Folder

```bash
cd Desktop
```

Now check:

```bash
pwd
```

Output:

```text
/home/yourusername/Desktop
```

You are now inside the `Desktop` folder.

---

### Tab Autocomplete (Very Important)

You don’t need to type full names.

Example:

```bash
cd Des<TAB>
```

The shell completes:

```bash
cd Desktop
```

This:

* Saves time
* Prevents typing mistakes

Use **Tab constantly**.

---

## 5. Absolute Paths vs Relative Paths

### Absolute Path

* Starts from `/`
* Always the same, no matter where you are

Example:

```bash
cd /home/yourusername/Desktop
```

---

### Relative Path

* Depends on your current directory

If you are already in `/home/yourusername`:

```bash
cd Desktop
```

Both commands lead to the same place.

---

## 6. Moving Up the Directory Tree

### One Level Up

```bash
cd ..
```

`..` means **parent directory**.

Example:

* From `/home/yourusername/Desktop`
* `cd ..` → `/home/yourusername`

---

### Two Levels Up

```bash
cd ../..
```

Example:

* From `/home/yourusername/Desktop`
* `cd ../..` → `/home`

---

## 7. Going Back to Home

There are **two easy ways**:

### Option 1: Use `~`

```bash
cd ~
```

### Option 2: Just `cd`

```bash
cd
```

Both take you to your home directory.

---

## 8. Combining Paths

You can combine shortcuts and paths.

Example:

```bash
cd ~/Desktop
```

This means:

* Go to home directory
* Then into `Desktop`

Very common and very useful.

---

## 9. Listing Files with `ls`

To see what’s inside a directory, we use:

```bash
ls
```

This lists the contents of the **current working directory**.

---

### Example

```bash
ls
```

Output:

```text
Desktop  Documents  Downloads  Pictures
```

These are folders inside your home directory.

---

## 10. Showing Hidden Files: `-a`

Hidden files in Linux:

* Start with a `.` (dot)
* Example: `.bashrc`, `.config`

To show **all files**, including hidden ones:

```bash
ls -a
```

You will now see:

* `.`
* `..`
* Files starting with `.`

### Meaning

* `.` → current directory
* `..` → parent directory

---

## 11. Sorting Output

### Sort by Modification Time: `-t`

```bash
ls -t
```

Newest files appear first.

---

### Reverse Order: `-r`

```bash
ls -r
```

---

### Combine Options

```bash
ls -tr
```

Options with **single letters** can be combined.

---

## 12. Long Options (`--`)

Some options use **full words**, not single letters.

Example:

```bash
ls --color=never
```

This disables colored output.

### Important Rule

* Single-letter options → can be combined (`-tr`)
* Long options → **cannot** be combined
  They must be written separately with `--`

---

## 13. Listing Another Directory Without Entering It

You can list a directory **without changing into it**.

Example:

```bash
ls /
```

This lists the contents of the **root directory**, even if your working directory is still your home directory.

Your location does **not change**:

```bash
pwd
```

Still shows:

```text
/home/yourusername
```

This pattern is very important and applies to many commands.

---

## 14. Key Concepts to Remember

* `pwd` → where you are
* `cd` → move around
* `ls` → see contents
* Working directory matters
* Commands use:

  * Command
  * Options
  * Arguments (like paths)












# Absolute Paths vs Relative Paths (Very Important)

Because we will work a lot with **files and paths**, this lecture is dedicated entirely to understanding:

* **Absolute paths**
* **Relative paths**
* Why mistakes here cause many Linux problems

---

## 1. Executing Multiple Commands Together

You already know that you can run commands one by one.

You can also run **multiple commands in one line** using `&&`.

### Example

```bash
cd .. && cd Desktop && ls
```

What happens here:

1. Go one directory up
2. Go into `Desktop`
3. List the contents of `Desktop`

If the folder is empty, `ls` prints nothing — this is normal.

---

### Another Example

```bash
cd / && cd home && ls
```

This:

1. Moves to the root directory `/`
2. Moves into `home`
3. Lists its contents

---

### Important Warning About Auto-Completion

⚠️ **Be careful when combining commands**

Tab-completion (`TAB`) always works based on your **current working directory**, **not future ones**.

Example:

```bash
cd / && cd Des<TAB>
```

This fails because:

* While typing, you are still in your original directory
* After execution, your directory changes
* Tab completion cannot predict future directories

**Best practice:**

* Use single commands when navigating interactively
* Use combined commands only when paths are fully known

---

## 2. What Is an Absolute Path?

An **absolute path**:

* Always starts with `/`
* Describes the **full path from the root**
* Works **no matter where you are**

### Example

```bash
/home/username/Desktop
```

This path:

* Always points to the same folder
* Works from anywhere in the system

---

### Special Case: `~` (Home Shortcut)

You may see paths like:

```bash
~/Desktop
```

Even though it does not start with `/`, it is treated as **absolute** because:

* Bash rewrites `~` internally
* `~` becomes `/home/username`

So these two are equivalent:

```bash
cd ~/Desktop
cd /home/username/Desktop
```

---

## 3. What Is a Relative Path?

A **relative path**:

* Does **not** start with `/`
* Is resolved relative to your **current working directory**

### Example

```bash
cd Desktop
```

This means:

> Go into `Desktop` **from where I am now**

---

### Using `..` (Parent Directory)

```bash
cd ..
```

* Moves **one level up**

```bash
cd ../Documents
```

* Go one level up
* Then enter `Documents`

---

## 4. Why Relative Paths Can Break

Imagine you previously ran:

```bash
cd ../Documents
```

This worked because:

* You were in your home directory

Now imagine you moved somewhere else:

```bash
cd /
```

Then you press **arrow up** and re-run:

```bash
cd ../Documents
```

❌ This fails because:

* You are now in `/`
* `/../Documents` does not exist

---

### Absolute Path Always Works

```bash
cd /home/username/Documents
```

This works **from anywhere**.

---

## 5. Key Difference (Very Important)

| Absolute Path           | Relative Path                |
| ----------------------- | ---------------------------- |
| Starts with `/`         | Starts without `/`           |
| Independent of location | Depends on current directory |
| Safer in scripts        | Risky if directory changes   |
| Predictable             | Context-dependent            |

---

## 6. Getting Help in Linux

When you don’t know how a command works, Linux gives you **multiple help options**.

---

## 7. `--help` Option

Many commands support:

```bash
command --help
```

### Example

```bash
ls --help
```

This prints:

* Available options
* Usage syntax
* Short explanations

⚠️ Not all commands support `-h` or `--help`, but many do.

---

## 8. Manual Pages (`man`)

The most important help system in Linux is `man`.

### Example

```bash
man ls
```

This opens the **manual page** for `ls`.

Navigation:

* Arrow keys → scroll
* `q` → quit

---

## 9. Ubuntu: Installing `man` Pages (If Missing)

On **Ubuntu Desktop**, manuals may not be installed by default.

If `man ls` shows an error, do this:

### Step 1: Enable manuals

```bash
sudo unminimize
```

Answer **Y** to all prompts.

---

### Step 2: Install man pages

```bash
sudo apt install man-db
```

---

### Step 3: Reboot (recommended)

```bash
sudo reboot
```

After reboot:

```bash
man ls
```

Now works correctly.

---

## 10. If Built-In Help Is Not Enough

You can also:

* Search official documentation online
* Use Stack Overflow
* Use Linux forums or Reddit
* Ask questions in the course Q&A section

When searching online:

* Include your **distribution** (Ubuntu / CentOS)
* Include the **exact error message**






