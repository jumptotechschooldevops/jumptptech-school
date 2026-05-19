---
title: "linux day #6"
description: "Full Ubuntu Version Upgrade (Release Upgrade)            1. What Is a “Full Software..."
published: 2025-12-28
source: "https://dev.to/jumptotech/linux-day-6-35ol"
tags: []
---

# linux day #6



# Full Ubuntu Version Upgrade (Release Upgrade)

## 1. What Is a “Full Software Upgrade”?

So far, we have used commands like:

* `apt update`
* `apt upgrade`
* `apt dist-upgrade`
* `apt full-upgrade`

These commands **upgrade packages only**, but they **do NOT upgrade the Ubuntu OS version itself**.

Ubuntu releases a **new OS version every 6 months**.
A **release upgrade** means upgrading from one Ubuntu version to another (for example: **22.04 → 22.10 → 23.04**).

---

## 2. Important Difference: Package Upgrade vs Release Upgrade

| Type                 | What it upgrades        | Ubuntu version changes? |
| -------------------- | ----------------------- | ----------------------- |
| `apt upgrade`        | Installed packages      | ❌ No                    |
| `apt dist-upgrade`   | Packages + dependencies | ❌ No                    |
| `do-release-upgrade` | Entire OS version       | ✅ Yes                   |

---

## 3. Critical Things to Check *Before* Upgrading

A release upgrade is **risky**, especially on servers. Before upgrading, always check the following.

### 3.1 Full Backup (Mandatory)

* Always have a **verified backup**
* Backup must be accessible **even if the system fails to boot**
* For cloud servers: snapshot + off-server backup

If the system becomes unbootable, the backup is your only recovery.

---

### 3.2 Disk Space

You need **several GB of free space**.

Check disk usage:

```bash
df -h
```

Example:

* 20% used
* 80% free → safe for upgrade

---

### 3.3 Time for Troubleshooting

* Expect problems in ~20% of upgrades
* Always plan **several hours** for fixing issues
* Never upgrade a critical system without downtime window

---

### 3.4 Wait After Release (Best Practice)

* Wait **1–2 weeks after a new Ubuntu release**
* Early bugs get fixed quickly
* Ubuntu may even **delay server upgrades** until a stable point release

---

### 3.5 Third-Party Repositories

* Check if **all external repos support the new Ubuntu version**
* Unsupported repos cause:

  * dependency conflicts
  * broken packages
  * failed upgrades

This is a **major risk factor**.

---

### 3.6 Bootable Recovery Media (Desktop Systems)

* Prepare a **bootable Ubuntu USB**
* Make sure BIOS allows USB boot
* Know disk encryption passwords

This allows you to recover data if the OS fails.

---

## 4. LTS vs Non-LTS (Very Important)

Check your current version:

```bash
lsb_release -a
```

Example:

```
Ubuntu 22.04 LTS
```

### What does LTS mean?

* **Long Term Support**
* 5 years of security updates
* Recommended for:

  * servers
  * production systems

### Non-LTS versions:

* Supported for **9 months only**
* Require frequent upgrades
* Not recommended for servers

⚠️ **Upgrading from LTS → non-LTS means losing long-term support**

---

## 5. When Should You Upgrade?

| System Type              | Recommendation |
| ------------------------ | -------------- |
| Production server        | Stay on LTS    |
| Business-critical system | Stay on LTS    |
| Workstation / testing    | Optional       |
| Learning / demo          | Fine           |

**Always ask:**

> “What problem does this upgrade solve for me?”

---

## 6. Upgrade Preparation Steps

### Step 1: Fully Update Current System

```bash
sudo apt update
sudo apt full-upgrade
```

This ensures:

* latest bug fixes
* clean dependency state

---

### Step 2: Reboot (If Kernel Updated)

```bash
sudo reboot
```

Ensures new kernel is active.

---

### Step 3: Install Upgrade Tool

```bash
sudo apt install update-manager-core
```

This provides:

* `do-release-upgrade`

---

## 7. Running the Release Upgrade

### Step 1: Start Upgrade

```bash
sudo do-release-upgrade
```

If no new LTS is available, you may see:

```
No new release found
```

---

### Step 2: Allow Non-LTS Upgrades (If Needed)

Edit:

```bash
sudo nano /etc/update-manager/release-upgrades
```

Change:

```ini
Prompt=lts
```

to:

```ini
Prompt=normal
```

Save and exit.

---

### Step 3: Run Upgrade Again

```bash
sudo do-release-upgrade
```

Ubuntu will:

* check system
* detect SSH connection
* warn about risks
* download ~1–2 GB
* ask configuration questions

---

## 8. During the Upgrade

### Configuration Prompts

Examples:

* Keyboard layout
* Console character set

Default choices are usually safe.

---

### Obsolete Packages

You may be asked:

```
Remove obsolete packages?
```

* Usually safe
* Review list if system is critical

---

### Configuration File Conflicts

Example:

```
Configuration file '/etc/crontab' has been modified
```

Options:

* Install maintainer version
* Keep your version
* View differences

Use `D` to inspect differences before deciding.

---

## 9. Kernel Errors (High Risk)

Kernel issues are **critical** because:

* kernel loads first at boot
* failure = system won’t start

Causes:

* unusual CPU architecture (ARM)
* custom kernels
* incompatible drivers

---

## 10. Final Reboot

```bash
sudo reboot
```

After reboot:

```bash
lsb_release -a
```

If successful, version is upgraded.

---

## 11. Real-World Outcome (Important Lesson)

In this case:

* Kernel upgrade failed
* System became **unbootable**

This is **realistic and valuable**:

* Upgrades can fail
* Backups matter
* Recovery skills are required












# Troubleshooting an Unbootable Ubuntu System (Real Incident Walkthrough)

## 1. Why This Failure Is a Good Thing

This is actually a **perfect real-world example**.

In real DevOps work:

* Systems **do break**
* Upgrades **do fail**
* You rarely get a clean, predictable error

This is far more valuable than a “happy-path” demo.

---

## 2. Initial Situation: System Does Not Boot

Symptoms:

* System powers on
* Boot messages appear
* Kernel starts loading
* System **hangs and never completes boot**

This tells us:

* Hardware is OK
* Bootloader likely works
* Failure happens **during kernel boot**

---

## 3. First Rule of Incident Response: Stay Calm

Before touching anything:

* Accept the system is down
* Inform stakeholders if needed
* Stop rushing
* Think logically

Stress causes bad decisions.
Calm fixes systems.

---

## 4. Isolating the Failure: Bootloader vs Kernel

### Observations:

* Bootloader menu appears
* “Booting Linux kernel” message appears
* No userspace logs appear

Conclusion:
👉 **Kernel is failing**, not the bootloader.

---

## 5. Best-Case Scenario: GRUB Menu Available

Because GRUB was enabled earlier, we could:

1. Open **Advanced options for Ubuntu**
2. Select an **older kernel**
3. Boot successfully

Result:

* System boots
* Login works
* Problem is confirmed: **new kernel is broken**

This immediately isolates the issue.

---

## 6. Worst-Case Scenario: GRUB Menu NOT Available

If GRUB was hidden (default on many systems):

* You cannot select older kernels
* System appears completely dead

### Solution:

👉 Boot from a **Live Linux system**

---

## 7. Booting from a Live Linux System

### What is a Live System?

* Linux runs from USB/DVD
* No changes written to disk
* Full access to tools and terminal

### Options:

* Physical machine → USB or DVD
* Virtual machine → attach ISO
* Cloud server → provider “rescue mode”

---

## 8. Choosing the Correct Live Image

Important rules:

* Desktop images usually include live mode
* Server images often install immediately
* Architecture **must match your CPU**

### Special case (ARM systems):

* ARM64 images are harder to find
* Daily builds may be required
* Older live images may work better

---

## 9. Booting the Live System

Steps:

1. Attach ISO
2. Set boot order (USB/DVD first)
3. Restart system
4. Choose **“Try Ubuntu”**

If errors appear:

* Wait a few minutes
* Many hardware warnings are harmless

---

## 10. First Priority: Data Access & Backup

Once live system is running:

* Your installed system disk is mounted automatically
* You can browse:

  * `/home`
  * `/var/www`
  * `/var/lib/mysql`
  * application data

👉 **Even if repair fails, your data is safe**

This alone is a major win.

---

## 11. Verifying File System Health

Before touching boot components, rule out disk corruption.

### Read-only check (recommended):

```bash
sudo fsck /dev/sda2
```

Result:

* No errors → filesystem is healthy
* Problem is **not disk-related**

---

## 12. Accessing the Installed System via `chroot`

We need to work **inside** the broken system.

### Step 1: Open terminal inside mounted system

Right-click → *Open in Terminal*

### Step 2: Change root

```bash
sudo chroot .
```

What this does:

* Does **not boot** the system
* Redirects `/` to the installed OS
* Commands now act as if system were running

This is critical for recovery.

---

## 13. Why Things Still Don’t Work Yet

Inside `chroot`, commands like:

```bash
update-grub
```

may fail with:

```
No such device
```

Why?

* `/dev`, `/proc`, `/sys` are kernel-managed
* They are missing inside chroot

---

## 14. Fixing Missing System Mounts (Critical Step)

We must bind system directories from the live kernel.

### Bind mounts:

```bash
sudo mount --bind /dev /dev
sudo mount --bind /proc /proc
sudo mount --bind /sys /sys
```

Now the installed system can:

* See disks
* Detect kernels
* Update bootloader properly

---

## 15. Rebuilding GRUB

Now run:

```bash
update-grub
```

This time:

* Kernel entries are detected
* Boot menu is regenerated correctly

---

## 16. Making the Working Kernel the Default

### Step 1: Inspect GRUB menu entries

```bash
cat /boot/grub/grub.cfg
```

Find the **exact menu entry** of the working kernel.

---

### Step 2: Set default kernel

Edit:

```bash
nano /etc/default/grub
```

Set:

```bash
GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 5.19.x"
```

(Exact text must match `grub.cfg`)

---

### Step 3: Apply changes

```bash
update-grub
```

---

## 17. Reboot and Verify

Exit chroot:

```bash
exit
```

Restart system:

```bash
reboot
```

Result:

* GRUB automatically selects working kernel
* System boots normally
* Login successful

---

## 18. Important Follow-Up (Next Lecture)

We are **not done yet**.

Next steps:

* Prevent working kernel from being removed
* Remove broken kernel safely
* Lock kernel packages
* Avoid repeat failure

👉 This is **mandatory in production**













# Stabilizing the System After Recovery (Kernel Safety & Cleanup)

Our system is **booting again**, but recovery is **not finished yet**.

A recovered system is still fragile unless we **prevent the same failure from happening again**.

---

## 1. The Risk After Recovery

Right now:

* The system boots **only because an older kernel exists**
* If that kernel is removed → system becomes unbootable again

Common danger:

```bash
sudo apt autoremove
```

This command may **silently remove old kernels** if they are marked as auto-installed.

We must **protect the working kernel**.

---

## 2. Identify the Active (Working) Kernel

Check the running kernel:

```bash
uname -r
```

Example:

```
5.19.0-xx-generic
```

Kernel files live in:

```bash
/boot
```

Important files:

* `vmlinuz-<version>` → kernel
* `initrd.img-<version>` → initial RAM disk

These files **must not disappear**.

---

## 3. Find Which Package Owns the Kernel File

Linux package manager knows which package created each file.

Check kernel ownership:

```bash
dpkg -S /boot/vmlinuz-5.19.0-xx-generic
```

Output example:

```
linux-image-5.19.0-xx-generic: /boot/vmlinuz-5.19.0-xx-generic
```

This tells us:
👉 **The kernel comes from this package**

---

## 4. Mark the Working Kernel as Manually Installed

This is the **most important protection step**.

```bash
sudo apt install linux-image-5.19.0-xx-generic
```

Why this works:

* Even if already installed, APT marks it as **manually installed**
* `autoremove` will **never delete it**

APT logic:

* Auto-installed → removable
* Manually installed → protected

---

## 5. Why `initrd.img` Does Not Have a Package

You may notice:

```bash
dpkg -S /boot/initrd.img-5.19.0-xx-generic
```

returns nothing.

That is normal.

Reason:

* `initrd.img` is **generated dynamically**
* Created by post-install scripts of the kernel package

Verify:

```bash
sudo dpkg-reconfigure linux-image-5.19.0-xx-generic
```

You will see:

* initramfs regeneration

As long as the kernel package stays installed → initrd stays too.

---

## 6. Removing the Broken Kernel (Optional but Recommended)

If a newer kernel **breaks boot**, remove it.

### Step 1: Identify broken kernel package

```bash
dpkg -S /boot/vmlinuz-6.x.x-generic
```

### Step 2: Remove dependent headers first

```bash
sudo apt remove linux-headers-generic
```

### Step 3: Remove the broken kernel

```bash
sudo apt remove linux-image-6.x.x-generic
```

Why headers first?

* Meta-packages depend on latest kernel
* Removing headers breaks that dependency safely

⚠️ **Do this only if you are sure the kernel is broken**

---

## 7. Why `linux-headers-generic` Exists

This package:

* Does **not contain code**
* Always depends on the **latest kernel**

Installing it later:

```bash
sudo apt install linux-headers-generic
```

Will:

* Pull the newest kernel again

Since the newest kernel caused failure:
👉 **Do not reinstall it yet**

---

## 8. Reboot and Verify Stability

Always test after kernel changes.

Reboot:

```bash
sudo reboot
```

Test:

* Default boot entry
* Advanced options → working kernel

If both work:
✅ System is stable again

---

## 9. Optional Cleanup: Reset GRUB Default

Now that broken kernel is gone:

* First GRUB entry boots correctly
* You may reset default behavior if desired

This is optional and not urgent.

---

## 10. Operational Best Practices (Real DevOps Advice)

### A. Practice Recovery on Purpose

Create test failures:

* Delete a boot file
* Break GRUB config
* Recover via live system

Practice makes **incident response fast**.

---

### B. Servers Without Physical Access

In real servers:

* Use provider rescue mode
* SSH into recovery system
* Use `chroot` only (no GUI)

Same logic — just CLI only.

---

### C. Always Back Up Before Fixing

Even during rescue:

* Copy `/home`
* Copy `/var`
* Copy application data

Never trust recovery until data is safe.

---

## 11. Common Causes of Boot Failures

| Category   | Examples                   |
| ---------- | -------------------------- |
| Kernel     | incompatible kernel update |
| Bootloader | broken GRUB config         |
| Filesystem | disk corruption            |
| Packages   | broken third-party drivers |
| Hardware   | disk failure, overheating  |
| Security   | firewall blocks SSH        |
| Mounts     | `/etc/fstab` errors        |

Not all require live systems — **boot failures do**.









# Cron Jobs in Linux — Concepts, Configuration, and Real Usage

## 1. Heads-Up: There Is More Than One Cron Implementation

Before working with cron, you need to know one important thing:

👉 **Cron is not one single program**.

Historically, multiple cron implementations evolved independently.
They all **look similar**, but they may differ slightly in:

* features
* defaults
* supported syntax
* email behavior

The **concepts are the same**, but details may vary.

---

## 2. What Is Cron?

### Cron Daemon

* Cron is a **background service (daemon)**
* It wakes up **every minute**
* Checks whether any scheduled jobs must run
* Executes commands at predefined times

The name comes from **Chronos**, the Greek word for time.

---

## 3. Where Cron Jobs Are Stored

Cron reads multiple locations.

### 3.1 User-Specific Cron Jobs (Most Common)

Stored internally in:

```
/var/spool/cron/crontabs/
```

* One file per user
* **Never edit these files directly**
* Permissions are intentionally restrictive

Correct way to manage them:

```bash
crontab -e
```

---

### 3.2 System-Wide Cron Jobs

Stored in:

```
/etc/crontab
```

Characteristics:

* Editable directly
* Must be owned by `root`
* Must not be writable by group or others

Used mainly for **system-level tasks**.

---

### 3.3 `/etc/cron.d` (Debian / Ubuntu)

* Directory containing cron job files
* Often used by **third-party software**
* You normally **do not place your own jobs here**
* Cron loads every file in this directory

This is Debian/Ubuntu-specific behavior.

---

## 4. Editing a User Crontab

### Open your crontab:

```bash
crontab -e
```

* First time: you may be asked which editor to use
* Editor choice is stored

### Temporarily choose an editor:

```bash
EDITOR=vim crontab -e
```

or

```bash
EDITOR=nano crontab -e
```

---

### View your crontab:

```bash
crontab -l
```

This is the **only safe way** to read it without root access.

---

## 5. Why You Should Never Edit Cron Files Directly

Even your own crontab:

```
/var/spool/cron/crontabs/<username>
```

* Has strict permissions
* Editing directly may:

  * break cron
  * corrupt format
  * change ownership

👉 Always use `crontab -e`

---

## 6. Crontab File Structure

A crontab has **two parts**:

1. Optional environment variables
2. One or more cron job definitions

---

## 7. Environment Variables in Crontab

These apply **only to cron jobs**, not your shell.

Common ones:

```cron
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Why this matters:

* Cron uses a **minimal PATH**
* Many commands fail without a full PATH
* Default shell may not be Bash

⚠️ Not all cron implementations support this
(works on Ubuntu/Debian)

---

## 8. Cron Job Syntax (Core Knowledge)

### General Format:

```
MINUTE HOUR DAY MONTH DAY_OF_WEEK COMMAND
```

| Field       | Range            |
| ----------- | ---------------- |
| Minute      | 0–59             |
| Hour        | 0–23             |
| Day         | 1–31             |
| Month       | 1–12             |
| Day of week | 0–7 (Sun=0 or 7) |

---

### Example: Every day at 03:05

```cron
5 3 * * * command
```

---

## 9. Wildcards (`*`)

`*` means **all possible values**.

Example: every minute

```cron
* * * * * command
```

---

## 10. Redirecting Output (Very Important)

Cron runs **without a terminal**.

If you don’t redirect output:

* Output may be emailed
* Or silently discarded
* Or logged elsewhere

Example:

```cron
* * * * * ping -c 1 google.com >> ~/ping.log
```

* `>>` appends
* Prevents overwriting

---

## 11. Testing a Cron Job

After saving your crontab:

* Wait one minute
* Check output file

```bash
cat ~/ping.log
```

If output appears → cron works.

---

## 12. Limiting Execution Frequency

### Every hour at minute 0

```cron
0 * * * * command
```

---

### Every 5 minutes

```cron
*/5 * * * * command
```

Runs at:

```
00, 05, 10, 15, 20, ...
```

---

### Specific minutes

```cron
0,15,30,45 * * * * command
```

---

### Hour range (08:00–20:00)

```cron
0 8-20 * * * command
```

Both ends included.

---

### Every 2 hours

```cron
0 */2 * * * command
```

⚠️ This runs **every minute during matching hours** if minute is `*`.

Correct way:

```cron
0 */2 * * * command
```

---

### Every 2 hours starting at 01:00

```cron
0 1-23/2 * * * command
```

---

## 13. Day of Week Filtering

Day of week acts as a **filter**.

Example: every Monday at midnight

```cron
0 0 * * 1 command
```

Values:

* 0 or 7 = Sunday
* 1 = Monday
* 6 = Saturday

---

## 14. Combining Fields Carefully (Common Pitfall)

This:

```cron
* */2 * * * command
```

Means:

* Every minute
* During every second hour

Result:

* Runs 60 times per active hour
* Silent for the next hour

Often **not what you want**.

---

## 15. Practical Example

```cron
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

0 * * * * ping -c 1 google.com >> ~/ping_hourly.log
```

Runs:

* Once per hour
* Clean output
* Predictable behavior

---

## 16. Cron Implementations You Should Know

### 16.1 Vixie Cron

* Default on Ubuntu/Debian
* Package name: `cron`
* Most common reference behavior

---

### 16.2 Anacron

* Handles **missed jobs**
* Runs jobs after system was offline
* Used for:

  * daily
  * weekly
  * monthly tasks

Ubuntu:

* Separate package

CentOS:

* Integrated

---

### 16.3 Cronie (CentOS / RHEL / Fedora)

* Fork of Vixie Cron
* Includes Anacron
* Same syntax
* Slightly different defaults

---

## 17. Why This Matters in Real Life

Cron is used for:

* backups
* log rotation
* monitoring
* cleanup tasks
* report generation
* automation glue

Understanding:

* timing
* output
* environment
* implementation differences

is **mandatory for DevOps and SysAdmins**.














# Cron Output, Email Notifications, and `flock` (Ubuntu)

> **Important**
> This lecture is **Ubuntu-specific**.
> CentOS behaves differently and is covered in the **next lecture**.

---

## 1. What Happens If We Do NOT Redirect Cron Output?

So far, we always redirected output:

```bash
>> file.log
```

But what if:

* we **don’t redirect stdout**, or
* the command writes to **stderr**, or
* the command fails?

### Answer:

👉 **Cron tries to send the output by email** to the job’s owner.

---

## 2. Default Cron Mail Behavior on Ubuntu

* Output is emailed to the **local user**
* Email delivery requires a **Mail Transfer Agent (MTA)**
* Ubuntu does **not install one by default**

So initially:

* cron **tries** to send mail
* mail **fails silently**
* output is discarded

---

## 3. Demonstration: Cron Job With Output (No Redirect)

Edit crontab:

```bash
crontab -e
```

Add:

```cron
* * * * * ping google.com
```

This runs **every minute** and produces output.

Wait one minute.

---

## 4. Checking Cron Logs (systemd)

On Ubuntu, cron logs are handled by **systemd**.

Follow cron logs:

```bash
journalctl -u cron -f
```

You will see:

```
CRON: No mail transfer agent installed, discarding output
```

So:

* cron executed the job
* output existed
* but email delivery failed

---

## 5. Installing Mail Support on Ubuntu

Cron does **not send mail itself**.
It delegates email delivery to an MTA.

### Install mail support:

```bash
sudo apt install mailutils
```

This installs:

* `mail` command
* **Postfix** (mail transfer agent)

---

## 6. Postfix Configuration (Initial)

During install, choose:

```
General type of mail configuration: Local only
```

This means:

* Mail is delivered **only to local users**
* No internet delivery yet

Finish installation.

---

## 7. Where Local Cron Emails Are Stored

Local emails are stored as plain text files:

```bash
/var/mail/<username>
```

Example:

```bash
sudo cat /var/mail/youruser
```

You will see:

* email headers
* cron output body
* one email per execution

👉 This is **not internet email**
👉 This is **local system mail**

---

## 8. Sending Cron Output to an External Email Address

Cron supports the `MAILTO` variable.

Edit crontab:

```bash
crontab -e
```

Add at the top:

```cron
MAILTO=you@example.com
```

Now cron will attempt to send output **externally**.

---

## 9. Why External Email Initially Fails

Even with `MAILTO`, emails may not arrive because:

* Postfix is set to **local only**
* External delivery is disabled

---

## 10. Reconfiguring Postfix for Internet Mail

Reconfigure postfix:

```bash
sudo dpkg-reconfigure postfix
```

Choose:

```
Internet Site
```

Accept defaults for:

* system mail name
* mailbox size
* delivery method

This allows:

* outbound email
* internet mail delivery

---

## 11. Why Emails Go to Spam (This Is Normal)

Your VM:

* has no valid domain
* no SPF / DKIM
* unknown sender reputation

Result:

* Gmail usually **accepts** the mail
* but places it in **Spam**

This is expected.

For production servers:

* proper DNS
* proper mail relay
* trusted domain

---

## 12. How to Stop Cron Email Spam

### Option 1: Redirect output

```cron
* * * * * command >> file.log 2>&1
```

### Option 2: Send output to `/dev/null`

```cron
* * * * * command > /dev/null 2>&1
```

### Option 3: Comment out job

```cron
# * * * * * command
```

---

## 13. Why `flock` Is Important (Real Production Problem)

Cron **does not prevent overlap**.

If a job runs every minute:

* previous run may still be active
* next run starts anyway
* leads to:

  * database overload
  * duplicate jobs
  * race conditions

---

## 14. What `flock` Does

`flock`:

* locks a file
* only **one process** can hold the lock
* others wait or exit

This allows **mutual exclusion**.

---

## 15. Simple `flock` Example

Terminal 1:

```bash
flock /tmp/test.lock ping google.com
```

Terminal 2:

```bash
flock /tmp/test.lock ping google.com
```

Result:

* second command **waits**
* runs only after first finishes

---

## 16. Non-Blocking `flock` (Cron-Safe)

Use:

```bash
flock -n /tmp/test.lock -c "command"
```

Behavior:

* if lock exists → exit immediately
* no overlap
* cron sees **success exit code**

---

## 17. Why Exit Code Matters

Cron logic:

* exit `0` = success
* exit `!=0` = error → email

Using:

```bash
flock -n file -c "cmd" || true
```

Ensures:

* cron sees success
* no spam
* no duplicate execution

---

## 18. Real Production Cron Example

```cron
0 */2 * * * /usr/bin/flock -n /tmp/app.lock \
/usr/bin/php /var/www/app/artisan schedule:run
```

What this does:

* runs every 2 hours
* prevents overlap
* skips execution if still running
* safe for databases

---

## 19. Why Full Paths Are Used

Cron has a **minimal PATH**.

Best practice:

* always use **absolute paths**

Find executable path:

```bash
which flock
which php
```

---

## 20. Why This Matters in Real Systems

Without `flock`:

* multiple cron runs overlap
* jobs collide
* data corruption happens

With `flock`:

* single execution guaranteed
* predictable behavior
* safe automation













# System-Wide Cron Jobs and Anacron (Ubuntu)

> **Important**
>
> * This lecture is **Ubuntu-specific**
> * CentOS / RHEL handle Anacron differently (covered separately)
> * Concepts are shared, implementations differ

---

## 1. User Cron Jobs vs System-Wide Cron Jobs

So far, we worked with **user cron jobs**:

```bash
crontab -e
```

Key points:

* Affects **only the current user**
* Stored internally in `/var/spool/cron/crontabs/`
* Managed **only** via `crontab` command

Even this:

```bash
sudo crontab -e
```

still creates a **user cron job** — this time for the **root user**.

---

## 2. System-Wide Cron Jobs (`/etc/crontab`)

Ubuntu also supports **system-wide cron jobs**.

### Location

```bash
/etc/crontab
```

### Key differences

* Regular text file
* Edited **directly** (no `crontab -e`)
* Owned by `root`
* Writable **only** by `root`
* Ignored if permissions are unsafe

---

## 3. Why System-Wide Cron Is Safe

Security model:

* If someone can write `/etc/crontab`, they already have root
* Root can already do anything
* Cron ignores the file if permissions are wrong

So this is **not a security risk**.

---

## 4. System-Wide Cron Syntax

Unlike user crontabs, **one extra field exists**.

### Format

```
MIN HOUR DAY MONTH DOW USER COMMAND
```

Example:

```cron
* * * * * alice echo "----" >> /home/alice/test.txt
```

This means:

* Runs every minute
* Executed **as user `alice`**
* Writes to Alice’s home directory

---

## 5. Example: System-Wide Cron Job

Edit the file:

```bash
sudo nano /etc/crontab
```

Add:

```cron
* * * * * alice cd /home/alice && echo "----" >> test.txt
```

After one minute:

```bash
ls /home/alice
```

Result:

* `test.txt` exists
* File owned by `alice`
* Command executed with Alice’s permissions

---

## 6. When to Use System-Wide Cron

### Use **user crontab** when:

* Job is personal
* No root privileges needed
* User manages their own tasks

### Use **system-wide cron** when:

* Job must run as a **specific service user**
* Example users:

  * `www-data`
  * `postgres`
  * `mysql`
* You don’t want to log in as that user

Example:

```cron
*/5 * * * * www-data php /var/www/app/artisan cleanup
```

---

## 7. Introducing Anacron (Why Cron Is Not Enough)

Regular cron jobs:

* Run **only if the system is running**
* Miss execution if the system is off
* Ignore battery state

Anacron solves this.

---

## 8. What Is Anacron?

Anacron:

* Executes jobs **eventually**
* Designed for:

  * laptops
  * desktops
  * non-24/7 systems
* Handles:

  * missed executions
  * delayed execution after reboot
  * power-state awareness

Typical use cases:

* log cleanup
* cache cleanup
* maintenance tasks

---

## 9. When to Use Anacron

Use **Anacron** when:

* Exact execution time does not matter
* Task must run **at least once**
* Delay is acceptable

Use **cron** when:

* Exact timing matters
* Task must run **on schedule**
* Servers are always online

---

## 10. Anacron Job Directories (Ubuntu)

Ubuntu integrates Anacron via folders:

```bash
/etc/cron.daily/
/etc/cron.weekly/
/etc/cron.monthly/
```

How it works:

* Place an **executable file** in the folder
* Anacron executes it automatically

---

## 11. Filename Restrictions (Important)

Allowed characters only:

* letters (A–Z, a–z)
* digits (0–9)
* underscore `_`
* dash `-`

Invalid filenames are **ignored**.

---

## 12. Example: Daily Anacron Job

List daily jobs:

```bash
ls /etc/cron.daily
```

Example:

```bash
/etc/cron.daily/apache2
```

Open it:

```bash
sudo nano /etc/cron.daily/apache2
```

You’ll see a shell script:

* executed once per day
* used for maintenance

---

## 13. How Anacron Is Configured

Configuration file:

```bash
/etc/anacrontab
```

---

## 14. Anacrontab Syntax

Format:

```
PERIOD DELAY JOB-ID COMMAND
```

Example:

```text
1   5   cron.daily   run-parts /etc/cron.daily
```

Meaning:

* Period: every 1 day
* Delay: wait 5 minutes after boot
* ID: unique identifier
* Command: execute all scripts in folder

---

## 15. Default Ubuntu Anacron Jobs

```text
1   5    cron.daily
7   10   cron.weekly
@monthly 15 cron.monthly
```

This enables:

* `/etc/cron.daily`
* `/etc/cron.weekly`
* `/etc/cron.monthly`

---

## 16. Why `/etc/cron.hourly` Exists

Check `/etc/crontab`:

```cron
17 * * * * root cd / && run-parts --report /etc/cron.hourly
```

This is:

* **normal cron**, not Anacron
* runs hourly
* no power-state awareness

If the system is down → job is skipped.

---

## 17. Fallback Logic in `/etc/crontab`

You may see lines like:

```cron
25 6 * * * root test -x /usr/sbin/anacron || run-parts /etc/cron.daily
```

Meaning:

* If Anacron exists → do nothing
* If Anacron is missing → fallback to cron

This guarantees:

* daily jobs still run
* even without Anacron

---

## 18. Battery-Aware Execution (How It Works)

Check Anacron’s systemd unit:

```bash
systemctl cat anacron.service
```

You will see:

```ini
ConditionACPower=true
```

Meaning:

* Anacron runs **only when plugged in**

---

## 19. Overriding Battery Behavior (Optional)

To override:

```bash
sudo systemctl edit anacron.service
```

Add:

```ini
[Unit]
ConditionACPower=
```

Now:

* Anacron runs even on battery

---

## 20. Best Practices for Cron & Anacron

### Scheduling

* Avoid peak traffic hours
* Distribute heavy jobs
* Be timezone-aware

---

### Logging & Monitoring

* Always log output
* Review logs regularly
* Monitor after updates

---

### Security

* Run jobs with **least privilege**
* Avoid root unless required
* Secure scripts and dependencies
* Never store secrets in crontab

---

### Permissions

* Cron-created files inherit user ownership
* Match cron user with application user
* Avoid permission mismatches

---

### Testing

* Test commands manually
* Use absolute paths
* Verify PATH differences
* Monitor first executions

---

## 21. Cron Implementation Differences

Be aware:

* Ubuntu / Debian → Vixie cron
* CentOS / RHEL → Cronie
* Features differ slightly
* Environment variables may not work everywhere

When in doubt:

* use shell scripts
* use absolute paths
* avoid assumptions

---

## 22. Final Takeaways

* User cron ≠ system cron
* `/etc/crontab` allows per-user execution
* Anacron handles missed jobs
* Ubuntu integrates Anacron via cron folders
* Power state matters on laptops
* Cron needs planning, logging, and discipline












## What Is the Internet? (Big Picture)

![Image](https://cs.lmu.edu/~ray/images/internets.png)

![Image](https://networkencyclopedia.com/wp-content/uploads/2019/10/packet-switching.png)

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Hop-count-trans.png/500px-Hop-count-trans.png)

### Definition

The **Internet is a network of networks**.

* It is made of **interconnected nodes** (computers, routers, servers)
* These nodes form a **mesh**, not a single direct line
* Any node can communicate with almost any other node
* No dedicated end-to-end connection is required

This design makes the Internet:

* **Scalable**
* **Fault-tolerant**
* **Efficient**

---

## Why the Internet Works Without Dedicated Connections

Imagine:

* You are in Europe
* You connect to a server in Australia

You do **not** have a physical cable to Australia.

Instead:

* Data is split into **small packets**
* Each packet is routed independently
* Routers choose the best available path **at that moment**
* If a link is congested or broken, traffic is rerouted automatically

This is called **packet switching**.

Important consequences:

* Packets may take **different paths**
* Paths can change dynamically
* Packet order is not guaranteed (higher layers fix this)

---

## Visualization: How Data Reaches Google

![Image](https://lazyadmin.nl/wp-content/uploads/2020/07/home-network-modem-router-2.jpg)

![Image](https://i.sstatic.net/26uLp.png)

![Image](https://media.licdn.com/dms/image/v2/D4D12AQFsL1w54DIKVw/article-inline_image-shrink_400_744/article-inline_image-shrink_400_744/0/1681481573810?e=2147483647\&t=dJNNtCDm8PsSdtL6WpWmHNNcnbJhAcM1s3OgQj23rms\&v=beta)

### Example Flow

1. **Your computer**
2. **Home router**
3. **ISP router**
4. **Multiple intermediate routers (hops)**
5. **Destination server (e.g., Google)**

Each router:

* Looks only at the destination address
* Forwards the packet to the next best hop
* Does not know the full path

Routers are often called **hops** because packets “hop” through them.

---

## What Must Exist for Internet Communication to Work

To send data to `google.com`, several things must happen:

1. **Name resolution**

   * Convert `google.com` → IP address
   * This is done by **DNS**

2. **Local delivery**

   * Your computer must send data to the **local router**
   * Happens inside your local network

3. **Inter-network routing**

   * Data must cross multiple networks
   * Handled by the **IP protocol**

4. **Reliability**

   * Lost packets must be detected and retransmitted
   * Done by **TCP**

5. **Application communication**

   * Web, SSH, email, etc.
   * Done by protocols like **HTTP, HTTPS, SSH**

This layered approach is **intentional**.

---

## Working Bottom-Up (How This Chapter Is Structured)

We will study networking **from the ground up**:

1. How data is placed on the wire or Wi-Fi
2. How packets move inside a local network
3. How packets move between networks (Internet)
4. How reliability is guaranteed
5. How applications use the network

This matches how real networking works.

---

## Tool 1: The `ip` Command (Linux Networking)

### What Is `ip`?

The `ip` command is the **modern Linux networking tool**.

It replaces:

* `ifconfig`
* `route`
* `netstat`

It is:

* More powerful
* More accurate
* Actively maintained

---

### Showing Network Interfaces

```bash
ip address show
```

Output shows:

* Network interfaces
* IP addresses
* Interface state
* MAC addresses

Example interfaces:

* `lo` → loopback (localhost)
* `eth0`, `ens33`, `wlp0s20f3` → physical or virtual NICs

---

### Legacy Tool (Still Exists)

```bash
ifconfig -a
```

* Older
* Still available on some systems
* Internally uses older kernel interfaces

**In this course, we use `ip`**.

---

## macOS Users: Using `ip` via Homebrew

macOS does not ship with `ip`.

Options:

* Use `ifconfig` (native)
* Install an `ip` wrapper

### Install via Homebrew

```bash
brew install iproute2mac
```

After installation:

```bash
ip address show
```

Notes:

* Output may differ slightly
* Not all features are supported
* Good enough for learning

---

## Tool 2: Wireshark (Traffic Analysis)

![Image](https://www.wireshark.org/docs/wsug_html_chunked/images/ws-main.png)

![Image](https://www.wireshark.org/docs/wsug_html_chunked/images/ws-packet-selected.png)

![Image](https://talesoftechnology.github.io/assets/img/favicons/Wireshark10.png)

### What Is Wireshark?

Wireshark is a **graphical packet analyzer**.

It allows you to:

* Capture live network traffic
* Inspect packets layer by layer
* Visualize real network behavior

This is critical for **understanding**, not just memorizing.

---

## ⚠️ Legal & Ethical Warning (Very Important)

Wireshark can:

* Capture **private data**
* Capture **MAC addresses**
* Capture **credentials (if unencrypted)**

Rules:

* Capture **only traffic you own or are allowed to analyze**
* Laws vary by country
* In some regions, MAC addresses are personal data

This lecture is for:

* Learning
* Teaching
* Ethical debugging

**This is not legal advice.**

---

## Installing Wireshark (Ubuntu)

```bash
sudo apt install wireshark
```

Start Wireshark with required privileges:

```bash
sudo wireshark
```

---

## Capturing Traffic

Steps:

1. Select network interface
2. Start capture
3. Generate traffic (open a website)
4. Stop capture
5. Analyze packets

Example:

* Open `google.com`
* Stop capture
* Filter by protocol:

  ```
  http
  ```

Note:

* Modern sites use **HTTPS**
* Payload is encrypted
* Metadata is still visible

---

## Why Wireshark Matters

Wireshark shows:

* Frames
* Packets
* Headers
* Protocol layers

Right now this looks overwhelming — that’s expected.

By the end of this chapter:

* Every section will make sense
* Every field will have meaning

---

## Introducing the OSI Model

![Image](https://insights.profitap.com/hs-fs/hubfs/The%207%20Layers%20of%20OSI.png?name=The+7+Layers+of+OSI.png\&width=560)

![Image](https://cdn.educba.com/academy/wp-content/uploads/2019/07/OSI-Model-vs-TCPIP-Model.png)

### What Is the OSI Model?

The **OSI (Open Systems Interconnection) model** is a conceptual framework.

Purpose:

* Standardize network communication
* Enable interoperability
* Provide a shared troubleshooting language

Developed:

* Concept in the 1970s
* Formalized in the 1980s

---

## Why the OSI Model Exists

Before standards:

* Vendors used incompatible protocols
* Networks could not interoperate

Today:

* Any phone works on any Wi-Fi
* Any laptop works on any router
* Any OS can talk to any server

That did **not** happen by accident.

---

## The 7 OSI Layers (Bottom → Top)

| Layer | Name         | Purpose                         |
| ----- | ------------ | ------------------------------- |
| 1     | Physical     | Bits on wire (cables, signals)  |
| 2     | Data Link    | Local delivery (MAC, Ethernet)  |
| 3     | Network      | Routing between networks (IP)   |
| 4     | Transport    | Reliability, ordering (TCP/UDP) |
| 5     | Session      | Session management              |
| 6     | Presentation | Encryption, compression         |
| 7     | Application  | HTTP, SSH, FTP, SMTP            |

---

## Key Layer Intuition

* **Layer 1**: Is the cable plugged in?
* **Layer 2**: Can I talk to my router?
* **Layer 3**: Can packets reach the destination?
* **Layer 4**: Are packets reliable?
* **Layer 7**: Does the application work?

This is how **real troubleshooting** is done.

---

## Why the OSI Model Is Useful for You

### 1. Modularity

Each layer can evolve independently.

Example:

* TCP improvements do not break Ethernet
* HTTPS encryption does not affect routing

---

### 2. Interoperability

Devices from different vendors work together.

---

### 3. Troubleshooting Framework

You can say:

* “Layer 1 issue” → cable
* “Layer 3 issue” → routing
* “Layer 7 issue” → application

This saves **hours** in production.








# OSI Layer 1 – The Physical Layer

![Image](https://cdn.shopify.com/s/files/1/0613/4041/8306/files/LO-Connection_of_networks_through_Router.png?v=1659944198)

![Image](https://m.media-amazon.com/images/I/61dLDc%2B9v%2BL.jpg)

![Image](https://img.lightwaveonline.com/files/base/ebm/lw/image/2023/10/REN9524.6531716cc9920.png?auto=format%2Ccompress\&cache=0.21871496713765093\&fit=max\&h=590\&w=1050)

## What Is the Physical Layer?

The **physical layer (Layer 1)** is the foundation of networking.

It is responsible for **physically transmitting bits** from one device to another.

This includes:

* Ethernet cables (copper)
* Fiber-optic cables
* Wi-Fi radio signals
* Electrical voltages and light pulses

At this layer, there is **no concept of IP addresses, packets, or routing**—only raw bits.

---

## Responsibilities of Layer 1

Layer 1 handles:

* **Physical media**

  * Copper, fiber, wireless
* **Signal transmission**

  * Electrical voltage
  * Light pulses
  * Radio waves
* **Bit encoding**

  * Converting 0s and 1s into signals
* **Timing & synchronization**
* **Collision avoidance (basic mechanisms)**
* **Basic error detection**

  * e.g., parity bits

Important detail:

* Signals are encoded so the **average voltage is zero**
* This prevents electrical potential buildup between devices

---

## Examples of Physical Layer Failures

Common Layer 1 problems:

* Cable unplugged
* Broken cable
* Power missing
* Faulty network card
* Electromagnetic interference
* Hardware malfunction

If Layer 1 fails, **nothing above it can work**.

---

## Layer 1 Hardware Examples

* Ethernet cables
* Fiber cables
* Wi-Fi antennas
* Physical splitters (old Ethernet hubs)
* Network Interface Cards (NICs)

> Old Ethernet splitters literally connected wires together.
> All devices shared the same electrical medium.

---

## Influencing Layer 1 via Software

You cannot unplug a cable with software.

But you **can**:

* Enable or disable a network interface

This effectively shuts down Layer 1 from the OS perspective.

---

## Enabling / Disabling a Network Interface (Linux)

### Step 1: Identify interfaces

```bash
ip addr show
```

Example interface names:

* `enp0s5` (modern, predictable)
* `eth0` (older style)
* `wlan0` (Wi-Fi)

Modern names are stable and tied to hardware location.

---

### Step 2: Disable interface

```bash
sudo ip link set dev enp0s5 down
```

Result:

* Interface exists
* State becomes **DOWN**
* No traffic flows

⚠️ **Warning**
If this interface is your SSH connection → you will disconnect immediately.

---

### Step 3: Enable interface

```bash
sudo ip link set dev enp0s5 up
```

Connectivity returns.

---

## Real Example: Remote Device Risk

On systems like:

* Raspberry Pi
* Remote servers
* Cloud VMs

If you disable:

* `wlan0` (Wi-Fi)
* `eth0` (Ethernet)

Your remote session will drop.

Recovery requires:

* Reboot
* Physical access
* Console access

This is a **classic Layer 1 outage**.

---

# OSI Layer 2 – The Data Link Layer

![Image](https://study-ccna.com/wp-content/uploads/2020/04/how_switch_forwards_unicast_frames.jpg)

![Image](https://i2.wp.com/www.conceptdraw.com/How-To-Guide/picture/network-wiring.png?strip=all)

![Image](https://securitytronix.com/wp-content/uploads/2021/08/bridge-diagram.jpg)

## What Is Layer 2?

The **Data Link Layer (Layer 2)** handles **local communication** inside one network.

Key responsibilities:

* Frame delivery
* MAC addressing
* Error detection (local)
* Collision reduction
* Traffic isolation

Layer 2 does **not** route between networks.

---

## Typical Layer 2 Hardware

* **Switch**
* **Bridge**
* **Wireless Access Point (WAP)**

> Note:
>
> * A **switch** is hardware
> * A **bridge** is usually software
> * Functionally, they are similar

---

## Switch vs Wireless Router (Important Distinction)

* **Switch / Access Point**

  * Layer 2 only
  * No routing
* **Router**

  * Layer 3 (and above)
  * Connects different networks

A Wi-Fi **access point** is essentially:

> A Layer-2 switch with radio antennas

---

## Why We Need Switches

### Old Method: Shared Wire (Hub / Splitter)

* All devices share one cable
* Every frame reaches every device
* Devices discard frames not meant for them
* Collisions occur if multiple devices talk

Works for:

* Few machines

Fails for:

* Many machines
* High traffic

---

## How a Switch Solves This

A **switch learns MAC addresses**.

* Each device has its own cable
* Switch remembers:

  * MAC → port mapping
* Frames are forwarded **only where needed**

Example:

* PC A sends frame to PC B
* Switch forwards frame only to PC B’s port
* Other ports remain silent

---

## Parallel Communication with a Switch

With a switch:

* Multiple devices can transmit **simultaneously**
* No shared collision domain
* Massive performance improvement

This is why switches replaced hubs.

---

## Transparency of a Switch (Very Important)

From the computer’s perspective:

* It does **not know** a switch exists
* It behaves as if:

  * It is directly connected to other devices

The switch is **completely transparent**.

This fact is critical when later learning about:

* Routers
* Network segmentation
* Subnets

---

## What Layer 2 Can and Cannot Do

### Can do:

* Send frames inside the same network
* Reduce collisions
* Isolate traffic

### Cannot do:

* Route between networks
* Reach the Internet
* Understand IP addresses

That is Layer 3.

---

## Layer 1 vs Layer 2 Summary

| Layer   | Purpose               | Example      |
| ------- | --------------------- | ------------ |
| Layer 1 | Physical transmission | Cable, Wi-Fi |
| Layer 2 | Local delivery        | Switch, MAC  |





# OSI Layer 3 – The Network Layer (IP, Routing, Subnets)

![Image](https://networkwalks.com/wp-content/uploads/2020/10/osi-model-network-layer-3_2.png)

![Image](https://www.tcpipguide.com/free/diagrams/ipencap.png)

![Image](https://o.quizlet.com/RBZ4NaRP8CW1YBV1z59ezg_b.png)

## Why Do We Need the Network Layer?

On **Layer 2 (Data Link)**, we learned:

* Frames are sent **from one network card to another**
* Communication is limited to the **local network**
* Switches are transparent
* MAC addresses are **local only**

➡️ **Problem**
If two computers are **not in the same network**, Layer 2 is not enough.

That is why we need **Layer 3 – the Network Layer**.

---

## What Changes on Layer 3?

| Layer   | Unit   | Address Type | Scope              |
| ------- | ------ | ------------ | ------------------ |
| Layer 2 | Frame  | MAC address  | Local network only |
| Layer 3 | Packet | IP address   | Across networks    |

### Key idea

* **Frames cannot be routed**
* **Packets can be routed**

Routing = forwarding data **between networks**

---

## Packet Encapsulation (Very Important Concept)

When sending data:

1. Application creates data
2. Layer 3 wraps it into an **IP packet**
3. Layer 2 wraps the packet into an **Ethernet frame**
4. Frame is sent on the wire

At every router:

* Frame is removed
* Packet is inspected
* Packet is wrapped into a **new frame**
* Sent to the next hop

This happens extremely fast in hardware.

---

## What Is a Network?

A **network** is a group of interconnected devices that can communicate.

### Important network types

* **LAN (Local Area Network)**
  Home, office, data center
* **WAN (Wide Area Network)**
  Internet, country, continent

➡️ The **Internet is a WAN made of many LANs**

---

## Routers and Gateways

![Image](https://i.pinimg.com/736x/96/69/ff/9669ffec3f7cbc1b5ce4df463b8bd82a.jpg)

![Image](https://lazyadmin.nl/wp-content/uploads/2020/07/home-network-modem-router.jpg)

![Image](https://www.homenethowto.com/wp-content/uploads/default-gateway.jpg)

A **router**:

* Connects networks
* Operates on Layer 3
* Forwards packets

A **default gateway**:

* The router your computer sends packets to
* Used when destination is **outside your local network**

---

## Inspecting Network Configuration (Linux)

### Show IP address

```bash
ip addr show
```

You will see:

* Interface name
* IP address
* Subnet mask (CIDR notation)

Example:

```
192.168.1.23/24
```

---

### Show routing table

```bash
ip route show
```

Example:

```
default via 192.168.1.1 dev enp0s5
```

Meaning:

* Anything not local → send to **192.168.1.1**
* That IP is your **router / gateway**

---

## Local vs Internet Traffic (Wireshark Proof)

![Image](https://wiki.wireshark.org/uploads/__moin_import__/attachments/Internet_Control_Message_Protocol/ICMP.JPG)

![Image](https://www.alphr.com/wp-content/uploads/2023/04/Wireshark-How-to-Find-MAC-Address-20.jpg)

### Case 1: Ping Google (Internet)

* IP packet destination = Google IP
* Ethernet frame destination = **router MAC**
* Router forwards packet

### Case 2: Ping local machine

* IP packet destination = local IP
* Ethernet frame destination = **target MAC**
* Router not involved (acts only as switch if Wi-Fi)

➡️ Same IP protocol
➡️ Different **Layer-2 destination**

---

## Why Frames Are Addressed Differently

| Destination       | Ethernet Frame Goes To |
| ----------------- | ---------------------- |
| Same network      | Target device MAC      |
| Different network | Router MAC             |

This decision is made using the **subnet mask**.

---

# Subnets – Networks Inside Networks

![Image](https://content.instructables.com/ORIG/FSH/FNEF/HS18G38O/FSHFNEFHS18G38O.jpg?frame=1)

![Image](https://cdn.networkacademy.io/sites/default/files/2023-03/function-subnet-mask.svg)

![Image](https://i0.wp.com/learntomato.flashrouters.com/wp-content/uploads/subnet-subnetwork.jpg?resize=464%2C621\&ssl=1)

## What Is a Subnet?

A **subnet** is a logical subdivision of a network.

Used to:

* Reduce broadcast traffic
* Improve performance
* Scale large networks
* Control routing

---

## The Problem Subnets Solve

Your computer must answer:

> Is the destination IP **local** or **remote**?

If local → send frame directly
If remote → send frame to gateway

---

## Subnet Mask (Core Concept)

Example:

```
IP address:     192.168.1.10
Subnet mask:    255.255.255.0
CIDR:           /24
```

Subnet mask:

* Defines **network part**
* Defines **host part**

---

## Binary AND Logic (Conceptual)

* Subnet mask has:

  * 1 = network bits
  * 0 = host bits

Logical AND:

* Keep bits where mask = 1
* Zero out bits where mask = 0

If:

```
(network part of source)
==
(network part of destination)
```

➡️ Same subnet

Otherwise ➡️ send to gateway

Computers do this instantly in hardware.

---

## CIDR Notation (Short Form)

Instead of:

```
255.255.255.0
```

We write:

```
/24
```

Why?

* 24 bits = 1
* Remaining bits = 0

Examples:

| CIDR | Hosts (usable)     |
| ---- | ------------------ |
| /24  | 254                |
| /23  | 510                |
| /22  | 1022               |
| /30  | 2 (point-to-point) |

---

## Reserved Addresses in a Subnet

For `/24`:

* `.0` → network address
* `.255` → broadcast address
* `.1 – .254` → usable hosts

---

## Inspecting Subnet Mask on Linux

```bash
ip addr show
```

Example output:

```
inet 192.168.1.23/24
```

This tells you:

* Your IP
* Your subnet size
* How routing decisions are made

---

## Key Mental Model (Very Important)

* **IP packet** → logical destination
* **Ethernet frame** → physical next hop
* **Subnet mask** → decision maker
* **Router** → network boundary











# How Does a Computer Know Where to Send a Frame?

### (ARP, IP ↔ MAC Resolution, Routes, DHCP)

![Image](https://marvel-b1-cdn.bc0a.com/f00000000310757/www.fortinet.com/content/dam/fortinet/images/cyberglossary/what-is-arp.jpg)

![Image](https://www.ciscopress.com/content/images/chap7_9780136633662/elementLinks/07fig11_alt.jpg)

![Image](https://support.mangocomm.com/docs/wlan-user-guide-v2/_images/eth_encap_ap.png)

## The Core Question

> We know **IP packets** contain destination IPs
> We know **Ethernet frames** need destination MACs
>
> ❓ **How does the system know which MAC address to use?**

That is the job of **ARP**.

---

## Packet vs Frame (Quick Reminder)

| Layer   | Unit   | Address Used |
| ------- | ------ | ------------ |
| Layer 3 | Packet | IP address   |
| Layer 2 | Frame  | MAC address  |

To send **any IP packet**, the system must:

1. Decide **where the packet should go**
2. Resolve **which MAC address** to send the frame to

---

## ARP – Address Resolution Protocol

**ARP answers one question only:**

> “Which MAC address owns this IP address?”

ARP works **only inside the local network**.

---

## What Happens When You Ping a Local Machine

![Image](https://media.licdn.com/dms/image/v2/C4D12AQGQyyXYgQRmVw/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1587614475476?e=2147483647\&t=qiwUAdkgNIDWZ4JO660Z-BEq5ewFlmzp0tAQ_Ng-Vp8\&v=beta)

![Image](https://i.sstatic.net/B4Cfi.png)

![Image](https://www.networkacademy.io/sites/default/files/2020-09/how-arp-works.png)

### Step-by-step

1. You run:

   ```bash
   ping 192.168.1.50
   ```
2. System checks subnet mask
   → Destination is **local**
3. System does **ARP request (broadcast)**:

   ```
   Who has 192.168.1.50?
   ```
4. All devices receive it
5. Only the owner replies:

   ```
   192.168.1.50 is at AA:BB:CC:DD:EE:FF
   ```
6. MAC address is cached
7. Ethernet frame is sent **directly** to that MAC

---

## What Happens When You Ping the Internet

![Image](https://networkbachelor.com/wp-content/uploads/2019/05/Network-Diagram-1024x576.jpg)

![Image](https://www.homenethowto.com/wp-content/uploads/arp-unknown-mac-1.jpg)

![Image](https://info.pivitglobal.com/hs-fs/hubfs/1%20%2816%29.png?name=1+%2816%29.png\&width=1920)

### Step-by-step

1. You run:

   ```bash
   ping google.com
   ```
2. DNS resolves IP (e.g. `142.250.x.x`)
3. Subnet mask check
   → Destination is **NOT local**
4. System needs **gateway MAC**
5. ARP request:

   ```
   Who has 192.168.1.1?
   ```
6. Router replies with its MAC
7. Ethernet frame destination = **router MAC**
8. Router forwards packet

➡️ **IP destination stays Google**
➡️ **MAC destination is router**

---

## Why ARP Is Always Happening

ARP traffic is normal and frequent:

* Devices announce themselves
* Devices verify IP conflicts
* Routers refresh mappings

In Wireshark:

```
ARP Who has 192.168.1.X?
ARP 192.168.1.X is at …
```

This is **normal network noise**, not a problem.

---

## Changing IP Addresses Manually (Linux)

### Show current IPs

```bash
ip addr show
```

---

### Add a secondary IP

```bash
sudo ip addr add 192.168.1.232/24 dev enp0s5
```

Now the interface has **two IPs**.

✔️ Other devices in the same subnet can reach it
❌ Devices outside the subnet will not

---

### Remove the IP

```bash
sudo ip addr del 192.168.1.232/24 dev enp0s5
```

---

## Why Adding “Any IP” Doesn’t Work

You *can* add:

```
8.8.8.8/24
```

But:

* Other machines see it as **Internet IP**
* Frames go to the **router**
* Router does NOT send traffic back to your PC

➡️ IP must **match subnet logic**, not just syntax.

---

## Routing Table – How the OS Decides Paths

![Image](https://thermalcircle.de/lib/exe/fetch.php?media=linux%3Arouting_simple_01.png)

![Image](https://www.computernetworkingnotes.com/wp-content/uploads/ccna-study-guide/images/csg116-01-show-ip-route-output.png)

![Image](https://www.baeldung.com/wp-content/uploads/sites/4/2021/10/routingtable_entry2.drawio.svg)

### Show routes

```bash
ip route show
```

Typical output:

```
192.168.1.0/24 dev enp0s5
default via 192.168.1.1 dev enp0s5
```

Meaning:

* Local network → direct
* Everything else → router

---

### Ask the OS how it would reach an IP

```bash
ip route get 8.8.8.8
```

or

```bash
ip route get 192.168.1.50
```

You will see:

* Interface used
* Gateway (if any)

---

## Manually Adding Routes (Advanced)

### Example: Send traffic to wrong gateway

```bash
sudo ip route add 9.9.9.9/32 via 192.168.1.100 dev enp0s5
```

Result:

* Packet sent to wrong device
* Device does not forward
* Traffic fails

Remove it:

```bash
sudo ip route del 9.9.9.9/32
```

---

## Why Manual Routes Matter (Corporate Networks)

![Image](https://beej.us/guide/bgnet0/html/split/mult_routers_net_diagram.png)

![Image](https://i.sstatic.net/NZGjI.png)

![Image](https://www.gliffy.com/sites/default/files/inline-images/enterprise-network-diagram.png)

Example:

* Subnet A: `192.168.1.0/24`
* Subnet B: `192.168.2.0/24`
* Router in between

Without route:

* Subnet A cannot reach Subnet B

With route:

```bash
sudo ip route add 192.168.2.0/24 via 192.168.1.5 dev enp0s5
```

Now traffic flows.

---

# DHCP – How Devices Get IPs Automatically

![Image](https://www.vsolcn.com/wp-content/uploads/2025/04/dhcp-address-application-process.webp)

![Image](https://i.sstatic.net/XKsfr.jpg)

![Image](https://www.101labs.net/wp-content/uploads/2023/03/4.jpg)

## What Is DHCP?

**Dynamic Host Configuration Protocol**

Automatically assigns:

* IP address
* Subnet mask
* Gateway
* DNS servers
* Lease time

Usually runs on the **router**.

---

## DHCP 4-Step Process (DORA)

1. **Discover** (broadcast)
2. **Offer**
3. **Request**
4. **Acknowledge**

All initial messages are **broadcast**.

---

## Seeing DHCP in Wireshark

Filter:

```
dhcp
```

You’ll see:

* Client MAC
* Offered IP
* Lease duration
* Gateway
* DNS servers

This is your **entire network configuration** being delivered.

---

## Debugging DHCP (systemd-networkd)

### View logs

```bash
journalctl -u systemd-networkd
```

Look for:

* DHCP lease acquired
* DHCP lease lost
* Link up/down events

If:

* Cable is plugged
* Wi-Fi is connected
* But no IP

➡️ It’s **almost always DHCP**

---

## Final Mental Model (Very Important)

**To send data:**

1. Subnet mask decides:

   * Local → direct MAC
   * Remote → gateway MAC
2. ARP resolves MAC
3. Ethernet frame is built
4. Router forwards if needed
5. Routing table controls decisions
6. DHCP provides configuration











# NetworkManager vs systemd-networkd (DHCP Logs)

![Image](https://arachnoid.com/linux/NetworkManager/images/block_diagram.gif)

![Image](https://media.licdn.com/dms/image/v2/D4D12AQFv_uXOdDu06g/article-inline_image-shrink_1000_1488/B4DZXymOseG8AQ-/0/1743531863864?e=2147483647\&t=2mfys72jFb2R7E5QUSb0tv_Hl5vXvH-1EEHp9RLwxD8\&v=beta)

![Image](https://www.debugpoint.com/wp-content/uploads/2020/12/journalctl-NetworkManager-service.jpg)

## Why Different Linux Systems Use Different Network Tools

Not all Linux distributions manage networking the same way.

* **Ubuntu Server** → usually uses **systemd-networkd**


Both tools:

* Configure interfaces
* Run a DHCP client
* Assign IP addresses
* Manage routes

They just do it **differently**.

---

## Why NetworkManager Exists

NetworkManager is a **more integrated solution**.

It supports:

* DHCP
* DNS integration
* Wi-Fi
* VPNs
* Mobile connections

With systemd:

* Networking is split across **multiple components**

  * `systemd-networkd`
  * `systemd-resolved`
  * others

➡️ **Recommendation**
Use the default tool provided by your distribution unless you have a strong reason to change it.

---

## Inspecting DHCP Logs with NetworkManager

On systems using NetworkManager (e.g. CentOS):

```bash
sudo journalctl -u NetworkManager --boot
```

What you’ll see:

* Service startup
* Interface detection
* DHCP requests
* DHCP lease assignment
* Lease renewals

---

## Understanding the Logs

Key events you’ll notice:

* Interface appears
* DHCP client starts
* IP address is assigned
* Subnet mask, gateway, DNS received
* Lease renewals every few minutes

### Lease Renewal Explained

DHCP leases expire unless renewed.

The client periodically tells the router:

> “I’m still here. Please keep my IP.”

This prevents:

* IP conflicts
* Stale reservations

---

## Key Takeaway

Regardless of tool:

* **A DHCP client must exist**
* It must talk to a **DHCP server**
* Logs tell you **why networking works or fails**

If:

* Cable is connected
* Wi-Fi is up
* But no IP

➡️ **Check DHCP logs first**

---

# Ping – The ICMP Diagnostic Tool

![Image](https://www.10-strike.com/network-monitor/help/images/icmp.png)

![Image](https://wiki.wireshark.org/uploads/__moin_import__/attachments/Internet_Control_Message_Protocol/ICMP.JPG)

![Image](https://www.researchgate.net/publication/316727741/figure/fig5/AS%3A614213521268736%401523451323001/CMP-packet-structure.png)

## What Is Ping?

`ping` is a **Layer-3 diagnostic tool**.

It uses **ICMP (Internet Control Message Protocol)**.

### What ping does:

1. Sends **ICMP Echo Request**
2. Waits for **ICMP Echo Reply**
3. Measures **round-trip time**

---

## Important Warning About Ping

If ping fails, it does **NOT always mean**:

* The host is down

It may mean:

* ICMP blocked by firewall
* ICMP disabled on destination
* ICMP filtered in between

Ping tests **reachability**, not availability.

---

## Seeing Ping in Wireshark

Filter:

```
icmp
```

You will see:

* Echo request
* Echo reply
* Sequence numbers
* Identifiers

Round-trip time (RTT):

* Gives latency estimate
* Wi-Fi fluctuates more than Ethernet

---

## When Ping Is Useful

Ping helps answer:

* Can I reach the host?
* Is the network slow?
* Is there packet loss?

Ping does **not**:

* Test application health
* Guarantee connectivity beyond ICMP

---

# Traceroute – Tracing the Path

![Image](https://www.lumen.com/content/dam/lumen/help/network/traceroute/traceroute-one.png)

![Image](https://i.sstatic.net/PQuPD.png)

![Image](https://i.sstatic.net/IawRC.png)

## What Traceroute Does

Traceroute shows:

* Each router (hop) between source and destination
* Latency per hop
* Where delays appear

Command:

```bash
traceroute google.com
```

Output:

* Hop number
* Router IP or hostname
* Three RTT measurements

---

## Why Three Measurements?

Network latency fluctuates.

Traceroute sends **multiple probes** to:

* Detect instability
* Avoid false conclusions

---

## Interpreting Traceroute Output

Typical observations:

* First hop = your gateway
* ISP routers next
* Backbone routers later
* Destination last

`* * *` means:

* Router didn’t reply
* ICMP blocked
* Still forwarding traffic

---

## Long-Distance Latency Example

When tracing overseas destinations:

* Sudden jump (e.g. 30 ms → 250 ms)
* Caused by:

  * Physical distance
  * Speed of light
  * Undersea fiber cables

This is why:

* Global services deploy servers near users

---

# How Traceroute Actually Works (TTL Explained)

![Image](https://packetpushers.net/wp-content/uploads/2019/05/IPv4-Headers-Standard-TTL-Highlighted-1024x431.png)

![Image](https://www.firewall.cx/images/stories/icmp-time-exceeded-2.gif)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20220424152026/ttl1.png)

## The TTL Field

Every IP packet has:

```
TTL – Time To Live
```

Purpose:

* Prevent infinite routing loops

---

## Traceroute Algorithm (Simplified)

1. Send packet with **TTL = 1**
2. First router:

   * Decrements TTL → 0
   * Drops packet
   * Sends **ICMP Time Exceeded**
3. Record router IP
4. Increase TTL to 2
5. Repeat until destination reached

➡️ Each step discovers **one hop**

---

## Why ICMP Appears in Captures

When a router replies:

* It embeds the **original IP packet**
* Inside an ICMP message
* Inside a new IP packet
* Inside a new Ethernet frame

That’s why Wireshark still matches filters.

---

## Why Traceroute Isn’t a Single Packet

Each hop is:

* A **separate probe**
* Sent independently

Traceroute assumes:

* Routing path remains stable

---

# Real-World Insight: Traceroute Reveals Topology

Traceroute can show:

* Multiple routers in your home network
* ISP router + your own router
* Hidden subnets

Example:

* ISP router (mandatory)
* Personal router behind it
* Double NAT
* Multiple internal subnets

Traceroute exposes this.

---

## Final Layer-3 Summary

You now understand:

* DHCP (automatic configuration)
* ARP (IP → MAC resolution)
* Routing tables
* Default gateways
* Ping (ICMP reachability)
* Traceroute (path discovery)
* TTL mechanics
* Multi-subnet routing

At this point, you have **solid Layer-3 knowledge**, exactly what:

* DevOps engineers
* Cloud engineers
* SREs

**must understand deeply**.











# Transport Layer (Layer 4) — Why We Need It

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230623142335/Transport-layer-660.jpg)

![Image](https://cdn-images-1.medium.com/max/1600/1%2Ani8U_s0qOxilaf61HXeN2w.jpeg)

![Image](https://www.manageengine.com/network-monitoring/images/packet-loss.png)

So far, Layer 3 (IP) solved **routing across networks**.
But IP alone has serious limitations:

### Problems at Layer 3

* Packets can be **lost**
* Packets can be **dropped** (very common)
* Packets can arrive **out of order**
* No retransmission
* No flow control
* No congestion control

Routers **intentionally drop packets** when overloaded — this is normal and expected.

➡️ **Layer 4 exists to handle these problems**

---

# UDP vs TCP — Two Different Philosophies

![Image](https://www.colocationamerica.com/wp-content/uploads/2018/12/udp-tcp.jpg)

![Image](https://sp-ao.shortpixel.ai/client/to_webp%2Cq_glossy%2Cret_img%2Cw_700%2Ch_417/https%3A//www.wowza.com/wp-content/uploads/Graphic-UDP-Vs-TCP-Diagram_1150x685-700x417.png)

![Image](https://assets.extrahop.com/images/infographics/TCP-RTO-Retransmission-Timeout-Diagram.jpg)

## UDP — “Send and Forget”

**UDP (User Datagram Protocol)**:

* No retransmission
* No ordering
* No congestion control
* No connection setup

### Why Use UDP?

Because **sometimes retransmission is worse than packet loss**.

**Examples:**

* Video calls
* Live streaming
* Online gaming
* DNS
* NTP (time sync)

If a video frame arrives late → it’s already useless
➡️ Better to **drop it** and move on

Applications using UDP usually:

* Send extra data
* Use error correction
* Handle loss themselves

---

## TCP — Reliable Data Stream

**TCP (Transmission Control Protocol)** provides:

* Reliable delivery
* Ordered data
* Retransmission
* Flow control
* Congestion control

Applications see TCP as a **continuous stream**, not packets.

### What TCP Manages for You

* Lost packets → retransmitted
* Out-of-order packets → reordered
* Receiver overload → sender slows down
* Network congestion → speed reduced automatically

➡️ Applications don’t need to care about packet loss.

---

# TCP Internals (High-Level, Practical View)

![Image](https://networklessons.com/wp-content/uploads/2015/07/tcp-header.png)

![Image](https://static.wixstatic.com/media/a2409e_aef337e8e53946f383f37bad39fe1028~mv2.jpg/v1/fill/w_566%2Ch_480%2Cal_c%2Clg_1%2Cq_80/a2409e_aef337e8e53946f383f37bad39fe1028~mv2.jpg)

![Image](https://www.researchgate.net/publication/288250636/figure/fig1/AS%3A549837323149313%401508102841451/Flow-chart-of-TCP-congestion-control.png)

Each TCP segment contains:

* Source port
* Destination port
* Sequence number
* Acknowledgment number
* Flags (SYN, ACK, FIN, RST)
* Checksum
* Payload (data)

### Sequence Numbers

Used to:

* Order packets
* Detect missing data
* Acknowledge received bytes

TCP does **not** count packets — it counts **bytes**.

---

# TCP Three-Way Handshake (Connection Setup)

![Image](https://afteracademy.com/images/what-is-a-tcp-3-way-handshake-process-three-way-handshaking-terminating-connection-6ea4a4c72d165361.jpg)

![Image](https://user-content.gitlab-static.net/d1f2cbdbc064b2cfa0acc4fe483cd8fd4fac931c/687474703a2f2f746370697067756964652e636f6d2f667265652f6469616772616d732f7463706f70656e337761792e706e67)

![Image](https://www.ionos.com/digitalguide/fileadmin/DigitalGuide/Schaubilder/EN-tcp.png)

Before data transfer, TCP builds a connection:

### Step 1 — SYN

Client → Server

* SYN flag set
* Initial Sequence Number (ISN)

### Step 2 — SYN-ACK

Server → Client

* SYN + ACK flags
* Server’s ISN
* Acknowledges client’s ISN

### Step 3 — ACK

Client → Server

* ACK flag
* Acknowledges server’s ISN

➡️ **Connection is now established**

After this:

* Data can flow both ways
* Every byte is acknowledged

---

# Seeing the Handshake in Wireshark

When using tools like `wget` or a browser:

* You will see:

  * SYN
  * SYN-ACK
  * ACK
* Followed by normal data packets

This knowledge is critical for:

* Debugging
* Firewall troubleshooting
* Port scanning (next topic)

---

# Ports — How Applications Are Identified

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20241218113402039961/TCP-vs-UDP-3.png)

![Image](https://study-ccna.com/wp-content/uploads/2016/03/how_ports_work.jpg)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20220522144232/portnumbers.png)

Ports are **Layer 4 identifiers**.

* Range: `0 – 65535`
* TCP and UDP have **separate port spaces**

A connection is uniquely identified by:

```
Source IP + Source Port + Destination IP + Destination Port
```

---

## Port Categories

### 1. Well-Known Ports (0–1023)

Require root privileges.

Examples:

* 80 → HTTP
* 443 → HTTPS
* 22 → SSH
* 21 → FTP
* 25 → SMTP

---

### 2. Registered Ports (1024–49151)

Assigned to common services.

Examples:

* 3306 → MySQL
* 5432 → PostgreSQL
* 5900 → VNC

---

### 3. Dynamic / Ephemeral Ports (49152–65535)

Used by clients:

* Randomly chosen
* Temporary
* No special privileges required

---

## Source Port vs Destination Port

Example:

* Client opens **random high port** (e.g. 46062)
* Server listens on **well-known port** (e.g. 80)

Server response:

* Source port = 80
* Destination port = 46062

This allows **thousands of simultaneous connections**.

---

# Common TCP and UDP Ports (Overview)

![Image](https://www.stationx.net/wp-content/uploads/2022/12/Well-Known-Ports-Unencrypted-vs-Encrypted-Graphic-by-author.png)

![Image](https://www.itperfection.com/wp-content/uploads/2020/06/ITPerfection-TCP-ports-UDP-ports.jpg)

![Image](https://dev.mysql.com/doc/mysql-port-reference/en/img/mysql-ports-diagram.png)

### Common TCP Ports

* 80 → HTTP
* 443 → HTTPS
* 22 → SSH
* 21 → FTP
* 25 → SMTP
* 110 → POP3
* 143 → IMAP

### Common UDP Ports

* 53 → DNS
* 67 / 68 → DHCP
* 123 → NTP
* 161 / 162 → SNMP
* 69 → TFTP
* 5004 / 5005 → RTP (audio/video)

**Why UDP here?**

* Low latency
* No retransmission delays

---

# Port Scanning — Understanding Nmap

![Image](https://www.hackercoolmagazine.com/wp-content/uploads/2024/06/Port-scanning_results_0.jpg)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20220715123349/synscanning1.png)

![Image](https://www.researchgate.net/publication/220841654/figure/fig11/AS%3A305566615392282%401449864166949/Nmap-scanning-of-the-firewall-in-destination-port-mode.png)

## What Is Port Scanning?

Port scanning tries to:

* Connect to many ports
* Observe responses
* Determine which services are reachable

### Possible Responses

* **SYN-ACK** → Port open
* **RST** → Port closed
* **No response** → Port filtered (firewall)

---

## Legal & Ethical Warning (Important)

* Port scanning is a **reconnaissance technique**
* Often used by attackers
* Also used by **defenders**

⚠️ **Only scan systems you own or are authorized to scan**

Laws vary by country — **never assume legality**

---

# Nmap Basics

Install:

```bash
sudo apt install nmap
# or
sudo dnf install nmap
```

Basic scan:

```bash
sudo nmap localhost
```

Scans:

* Top 1000 TCP ports

---

## Scan Specific Ports

```bash
sudo nmap -p 22,80,443 192.168.1.10
```

## Scan All Ports

```bash
sudo nmap -p- 192.168.1.10
```

---

## Scan a Network Range

```bash
sudo nmap 192.168.1.1-100
```

Useful for:

* Inventory
* Firewall validation
* Security hardening

---

# Practical Security Use Case

Port scanning helps you:

* Detect unnecessary services
* Close unused ports
* Reduce attack surface

Example:

* MySQL open on all interfaces
* Not needed externally
* Disable service or firewall it

```bash
sudo systemctl stop mysql
sudo systemctl disable mysql
```

Re-scan:

```bash
sudo nmap localhost
```

➡️ **Security improved**

---

# Why This Matters for DevOps & Cloud

You now understand:

* TCP vs UDP tradeoffs
* Ports & services
* Connection establishment
* How attackers discover services
* How defenders harden systems

This knowledge is **mandatory** for:

* Firewalls
* Kubernetes networking
* Load balancers
* Cloud security groups
* Incident response










# Advanced Nmap Scan Types — Why Scan Type Matters

![Image](https://nmap.org/book/images/ereet/Ereet_Packet_Trace_Syn_Closed.png)

![Image](https://www.techtarget.com/rms/onlineImages/networking-tcp_port_scanning_mobile.png)

![Image](https://network-insight.net/wp-content/uploads/2014/10/rsz_udp_port_numer.png)

Not all port scans behave the same way.
**Scan type directly affects:**

* Speed
* Detectability
* Logging on the target
* Legal and operational risk

This is why an Nmap introduction is incomplete **without scan types**.

---

## 1. TCP SYN Scan (`-sS`) — *Stealth Scan*

### What It Does

* Sends **SYN** packet only
* Waits for response
* **Does NOT complete the handshake**

### Responses

| Response | Meaning                  |
| -------- | ------------------------ |
| SYN-ACK  | Port open                |
| RST      | Port closed              |
| No reply | Port filtered (firewall) |

### Why It’s Fast

* Only **one packet** per port
* No full TCP connection
* Minimal resource usage

### Requirements

* **Root privileges** (raw sockets)

```bash
sudo nmap -sS localhost
```

### Logging Behavior

* Often **not logged**
* No established connection
* Lower detection probability

➡️ **Default and preferred scan if available**

---

## 2. TCP Connect Scan (`-sT`) — *Full Connection Scan*

![Image](https://afteracademy.com/images/what-is-a-tcp-3-way-handshake-process-three-way-handshaking-establishing-connection-6a724e77ba96e241.jpg)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/TCP-connection-1.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20220704165316/connectss.jpg)

### When Is It Used?

* When SYN scan is **not possible**

  * No root access
  * IPv6 scanning
  * Restricted environments

### What It Does

* Performs **full TCP handshake**

  * SYN → SYN-ACK → ACK
* Uses OS networking stack

```bash
nmap -sT localhost
```

### Downsides

* Slower (extra packets)
* Uses OS resources
* **Almost always logged**
* Can trigger alerts or IDS
* May stress poorly written services

➡️ **High visibility scan — use carefully**

---

## 3. UDP Scan (`-sU`) — *Slow but Necessary*

![Image](https://network-insight.net/wp-content/uploads/2014/10/rsz_udp_port_numer.png)

![Image](https://www.stationx.net/wp-content/uploads/2023/11/Nmap-UDP-Scan.png)

![Image](https://erg.abdn.ac.uk/users/gorry/course/images/ports.gif)

### Why UDP Is Hard to Scan

* No handshake
* No ACKs
* Packet loss is normal

### How Nmap Interprets Responses

| Response   | Meaning          |
| ---------- | ---------------- |
| UDP reply  | Port open        |
| ICMP error | Port closed      |
| No reply   | Open or filtered |

```bash
sudo nmap -sU localhost
```

### Important Notes

* **Extremely slow**
* Requires retries
* Often inconclusive

But still critical because:

* DNS
* DHCP
* NTP
* SNMP
* RTP

➡️ **TCP scans alone are not enough**

---

## Why Nmap Matters for Firewalls

Nmap answers:

* *What services are exposed?*
* *Which ports must be blocked?*
* *Did my firewall work?*

Security hardening workflow:

1. Scan
2. Identify unnecessary services
3. Stop or firewall them
4. Re-scan to verify

---

# Network Address Translation (NAT)

![Image](https://www.ipxo.com/app/uploads/2021/11/Network-Address-Translation.jpg)

![Image](https://www.researchgate.net/publication/320322146/figure/fig1/AS%3A548239512018944%401507721893582/Typical-configuration-of-a-home-network-using-NAT.png)

![Image](https://study-ccna.com/wp-content/uploads/2018/08/pat_explanation.jpg)

## Why NAT Exists

* IPv4 address shortage
* Many internal devices → **one public IP**

### Internal IPs (Private)

* `192.168.0.0/16`
* `10.0.0.0/8`
* `172.16.0.0/12`

Not routable on the Internet.

---

## How NAT Works (Outbound)

1. Internal device sends packet
2. Router:

   * Rewrites **source IP**
   * Often rewrites **source port**
3. Router remembers mapping
4. Reply arrives
5. Router reverses translation

➡️ Router maintains a **NAT table**

---

## Why Inbound Traffic Fails by Default

Incoming traffic:

* Router has **no idea** where to send it
* Packet is dropped

➡️ NAT works **outbound only**

---

## Port Forwarding — Allowing Inbound Access

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/NAPT-en.svg/1200px-NAPT-en.svg.png)

![Image](https://www.howtogeek.com/wp-content/uploads/2011/06/dlink.png)

![Image](https://learn.microsoft.com/en-us/azure/load-balancer/media/tutorial-load-balancer-port-forwarding-portal/load-balancer-port-forwarding-resources.png)

Example:

* External: `:80`
* Internal: `192.168.1.50:8080`

Router rewrites:

* Destination IP
* Destination port

---

## DHCP Reservation — Critical Step

Problem:

* Internal IPs change

Solution:

* Bind **MAC → IP**
* Prevent forwarding breakage

Always reserve IPs for:

* Servers
* NAS
* Home labs

---

## Dynamic Public IP Problem

Most ISPs:

* Assign **dynamic IPs**
* Change periodically

Solution:

* **Dynamic DNS (DDNS)**

Router updates DNS record automatically:

```
myhome.ddns-provider.com → current public IP
```

⚠️ **Not production-grade**

* DNS propagation delays
* ISP NAT (CGNAT) may block inbound access entirely

---

# OSI Layer 5 — Session Layer

![Image](https://open4tech.com/wp-content/uploads/2019/09/session-layer.png)

![Image](https://www.infosectrain.com/wp-content/uploads/2023/09/Key-Components-of-Session-Management.jpg)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/0%2AUPkTIFKC33n7673d.jpg)

## Purpose

* Establish
* Maintain
* Terminate sessions

Adds:

* State
* Authentication
* Session tracking

---

## Examples

* Network File Systems
* Remote Procedure Calls (RPC)
* Session-aware protocols

Modern reality:

* Often implemented **inside applications**
* Layers 5–7 are frequently merged

---

# OSI Layer 6 — Presentation Layer

![Image](https://cf-assets.www.cloudflare.com/slt3lc6tev37/19L86neKKT8srUkOSe4rf7/ff4c91c94a1790651df7b48433913f59/osi_model_presentation_layer_6.png)

![Image](https://cheapsslweb.com/resources/wp-content/uploads/2022/12/encoding-vs-encryption-diference.webp)

![Image](https://cf-assets.www.cloudflare.com/slt3lc6tev37/3wZIhjRIjfVSmCbVqkBKzb/4a7aa34324108c725dc25fc9e7c4ea4a/tls-ssl-handshake.png)

## Responsibilities

* Data format
* Encoding
* Encryption
* Compression

---

## Common Functions

### Encoding

* ASCII
* UTF-8 / Unicode

### Encryption

* SSL / TLS
* HTTPS

### Compression

* gzip
* deflate
* brotli

---

## MIME — Real Example

Emails require:

* Character encoding
* Attachments
* HTML + plain text
* Metadata

MIME defines:

* **How data is represented**
* Not how it’s transported

➡️ Transport (SMTP) ≠ Representation (MIME)

---

# Modern Reality of OSI Layers

Important truth:

* OSI is a **conceptual model**
* Real protocols blur boundaries

Example:

* HTTP/3 (QUIC)

  * Uses UDP
  * Implements encryption
  * Handles congestion control
  * Manages sessions internally

➡️ One protocol can span **multiple OSI layers**

---

# Final Takeaways

You now understand:

* Why scan type matters in Nmap
* SYN vs Connect vs UDP scans
* NAT behavior and limitations
* Port forwarding & DHCP reservations
* Why inbound traffic fails by default
* How higher OSI layers overlap in reality

This knowledge is **essential** for:

* Firewall configuration
* Cloud networking
* Kubernetes ingress
* Security audits
* Incident response









# OSI Layer 7 — Application Layer

![Image](https://cf-assets.www.cloudflare.com/slt3lc6tev37/2rcDKpr4WLqoyAZ7GDKkyJ/7cab96402de7ac5465b86e617da3da4e/osi_model_application_layer_7.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20250127103912860245/1.webp)

![Image](https://i.sstatic.net/ysG0q.jpg)

The **application layer (Layer 7)** consists of **protocols used by applications**, not the applications themselves.

### Important distinction

* **Firefox / Chrome / Outlook** → applications (software)
* **HTTP, HTTPS, IMAP, SSH** → application-layer protocols

Example:

* Firefox uses **HTTPS**
* Thunderbird uses **IMAP**
* Terminal uses **SSH**

According to the OSI model, **the protocol is Layer 7**, not the program you click.

---

## Common Layer 7 Protocols

| Protocol     | Purpose                     |
| ------------ | --------------------------- |
| HTTP / HTTPS | Web access                  |
| IMAP         | Access emails on server     |
| POP3         | Download emails             |
| SMTP         | Send emails                 |
| SSH          | Remote shell, file transfer |
| FTP / SFTP   | File transfer               |
| DNS          | Name resolution             |
| Custom APIs  | REST, gRPC, proprietary     |

Layer 7 protocols **depend on all lower layers**:

* Reliable transport (TCP/UDP)
* Routing (IP)
* Switching (Ethernet)
* Physical transmission (bits)

---

# DNS — Domain Name System (Layer 7)

![Image](https://www.tcpipguide.com/free/diagrams/dnsresolution.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20220713172800/RecursiveDNS1.png)

![Image](https://substackcdn.com/image/fetch/%24s_%21P_Ol%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ff0a1bb2c-a1bc-40ce-abde-6fb9d2a66ce8_1600x570.png)

DNS is an **application-layer protocol** that converts **human-readable names into IP addresses**.

Example:

```
google.com → 142.250.x.x
```

---

## Why DNS Exists

Humans remember names better than IP addresses.
Computers require IP addresses to communicate.

DNS bridges that gap.

---

## DNS Resolution Flow (Step by Step)

### 1. Browser Cache

The browser checks:

* “Have I resolved this domain recently?”

If yes → use cached IP.

---

### 2. Operating System Cache

If browser cache misses:

* Browser asks the OS
* OS checks its DNS cache

If found → return IP.

---

### 3. DNS Resolver (ISP or Custom)

If OS cache misses:

* OS queries a **DNS resolver**
* Usually provided by ISP or configured manually (e.g. 8.8.8.8)

Resolvers also **cache results** heavily.

---

## Full Recursive Resolution (If Not Cached)

![Image](https://learn.microsoft.com/en-us/windows-server/identity/media/reviewing-dns-concepts/1c044845-b104-4262-a7af-474ba3558a85.gif)

![Image](https://www.researchgate.net/publication/342547942/figure/fig1/AS%3A907969327800320%401593488165786/llustration-of-DNS-resolution-over-recursive-root-TLD-and-authoritative-name-server.png)

![Image](https://cdn.umbrella.marketops.umbrella.com/wp-content/uploads/2020/06/16092413/What-is-the-difference-between-Authoritative-and-Recursive-DNS-Nameservers_Cisco-Umbrella-blog_DNS-server-diagram.jpg)

### 4. Root Name Servers

* Resolver queries **one of 13 root servers (A–M)**
* Root servers do **not** know google.com
* They know **who manages `.com`**

Response:

```
Ask the .com TLD servers
```

---

### 5. TLD Name Servers (.com)

* Resolver queries `.com` TLD servers
* TLD servers respond:

```
Ask Google’s authoritative name servers
```

---

### 6. Authoritative Name Servers

* Resolver queries `ns1.google.com`
* Gets final DNS records:

```
google.com → IP addresses
```

---

### 7. Response Propagation

* Resolver → OS
* OS → Browser
* Browser connects to IP

✅ DNS resolution complete.

---

# Common DNS Record Types

![Image](https://assets.bytebytego.com/diagrams/0175-dns-record-types-you-should-know.png)

![Image](https://www.whizlabs.com/blog/wp-content/uploads/sites/2/2018/12/dns-records-summary.png)

![Image](https://assets.gcore.pro/site-media/uploads-staging/dns_records_explained_1_686969a9dc.png)

| Record    | Purpose                           |
| --------- | --------------------------------- |
| **A**     | Domain → IPv4                     |
| **AAAA**  | Domain → IPv6                     |
| **CNAME** | Alias to another domain           |
| **MX**    | Mail servers                      |
| **NS**    | Authoritative name servers        |
| **TXT**   | Verification, SPF, DKIM, metadata |

---

## Viewing DNS Records

```bash
host -a google.com
```

Example output:

* IPv4 + IPv6 addresses
* Name servers
* MX records
* TXT verification records

### Why IPs Change?

* **Load balancing**
* **High availability**
* Different users → different servers

---

# Manual DNS Resolution (Bonus — Deep Understanding)

![Image](https://www.cyberciti.biz/media/new/faq/2012/01/Linux-and-Unix-dig-Command-Examples.png)

![Image](https://substackcdn.com/image/fetch/%24s_%21P_Ol%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ff0a1bb2c-a1bc-40ce-abde-6fb9d2a66ce8_1600x570.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20200517230023/To-query-domain-A-record.png)

Using `dig` shows **exactly what DNS is doing**.

---

## Step 1 — Query Root Server

```bash
dig @a.root-servers.net com NS
```

Returns:

* List of `.com` TLD servers

---

## Step 2 — Query TLD Server

```bash
dig @a.gtld-servers.net google.com NS
```

Returns:

* Google’s authoritative name servers

---

## Step 3 — Query Authoritative Server

```bash
dig @ns1.google.com google.com A
```

Returns:

* Final IP addresses

This demonstrates **DNS hierarchy and delegation** clearly.

---

# DNS Security Problems

DNS was designed **before modern security threats**.

### Common Risks

* DNS spoofing
* Cache poisoning
* Man-in-the-middle
* ISP or government manipulation

---

## Why HTTPS Matters

![Image](https://data.embeddedcomputing.com/uploads/articles/wp/12592/5f356bc3aa75a-Picture1.png)

![Image](https://docs.apigee.com/static/images/ht-validate-cert-chain-image1.png)

![Image](https://www.indusface.com/wp-content/uploads/2024/10/DNS-Spoofing-.png)

Even if DNS is spoofed:

* HTTPS verifies server identity
* Invalid certificate → browser warning

This **mitigates DNS attacks**, though it does not fix DNS itself.

---

## DNSSEC (Mention Only)

* Cryptographic DNS signatures
* Protects integrity of DNS data
* Complex, not universally deployed

---

# `/etc/hosts` — Manual DNS Override

![Image](https://linux-audit.com/is-your-etc-hosts-file-healthy/images/etc-nsswitch-conf.png)

![Image](https://phoenixnap.com/kb/wp-content/uploads/2023/11/edit-etc-hosts-in-linux-add-ip-address-pnap.jpg)

![Image](https://www.partitionwizard.com/images/uploads/articles/2022/07/windows-11-hosts-file/windows-11-hosts-file-thumbnail.png)

File:

```
/etc/hosts
```

Format:

```
IP_ADDRESS   hostname
```

Example:

```
127.0.0.1   myproject.local
```

---

## Why Use `/etc/hosts`

* Local development
* Testing
* Offline resolution
* Temporary overrides

⚠️ **Overrides DNS entirely**

---

## Example

```bash
sudo nano /etc/hosts
```

Add:

```
127.0.0.1   myproject.local
```

Test:

```bash
ping myproject.local
```

---

## Overriding Public Domains (Not Recommended)

```bash
127.0.0.1 google.com
```

Result:

* Browser connects to localhost
* HTTPS fails (certificate mismatch)

Useful only for **testing or demos**.

---

# DNS Cache Issues & Fixes

Sometimes `/etc/hosts` changes **don’t apply immediately**.

Reason:

* Local DNS caching

---

## Identify Local DNS Resolver

```bash
sudo lsof -i :53
```

Common:

* `systemd-resolved`
* `dnsmasq`

---

## Flush DNS Cache (systemd)

```bash
sudo resolvectl flush-caches
```

Verify:

```bash
resolvectl statistics
```

---

## Restart dnsmasq (if used)

```bash
sudo systemctl restart dnsmasq
```

---

# Final Takeaways

You now understand:

* OSI Layer 7 vs real applications
* DNS resolution hierarchy
* DNS record types
* Manual DNS resolution with `dig`
* DNS security weaknesses
* HTTPS mitigation
* `/etc/hosts` overrides
* DNS cache flushing

This knowledge is **critical** for:

* DevOps debugging
* Kubernetes services
* Load balancers
* Cloud networking
* Incident response











# Hostnames in a Local Network

![Image](https://stevessmarthomeguide.com/wp-content/uploads/name-resolution-home-networks1.jpg)

![Image](https://i.sstatic.net/WOC1y.jpg)

![Image](https://kmpic.asus.com/images/2022/10/12/f03f5370-3a61-4d87-ad9e-64e30ef04b2c.png)

A **hostname** is a human-readable name assigned to a computer on a network.

### Why hostnames exist

* Easier identification of devices (e.g. *ubuntu*, *raspberrypi*)
* Used during **DHCP negotiation**
* Displayed on routers (device lists)
* Allows hostname-based access inside local networks

---

## Viewing the Hostname (Linux)

```bash
hostname
```

Example output:

```
ubuntu
```

Some shells show it automatically in the prompt, but this is configurable.

---

## Using Hostnames in a Local Network

From another machine:

```bash
ping ubuntu
ping ubuntu.local
```

If hostname resolution is configured correctly, the hostname resolves to an IP.

---

# Changing the Hostname (Linux)

### Step 1 — Edit `/etc/hostname`

```bash
sudo nano /etc/hostname
```

Example:

```
vm-ubuntu
```

---

### Step 2 — Reboot (required)

```bash
sudo reboot
```

After reboot:

```bash
hostname
```

Output:

```
vm-ubuntu
```

---

## Why `/etc/hosts` Must Also Be Updated

![Image](https://linux-audit.com/is-your-etc-hosts-file-healthy/images/etc-nsswitch-conf.png)

![Image](https://assets.techrepublic.com/uploads/2022/04/hostsb-770x494.jpg)

![Image](https://coding-boot-camp.github.io/full-stack/static/00f3d6b443a8e0fb8bbddc141504a189/c1b63/hosts-file-windows.png)

The hostname **should resolve locally** to the loopback interface.

Edit:

```bash
sudo nano /etc/hosts
```

Correct example:

```
127.0.1.1   vm-ubuntu
127.0.0.1   localhost
```

### Why `127.0.1.1`?

* Used by Debian/Ubuntu for hostname binding
* Avoids conflicts with `localhost`
* Still loopback (local machine)

Best practice: **always update `/etc/hosts` after hostname change**

---

# `.local` Hostnames and mDNS

![Image](https://www.researchgate.net/publication/345017736/figure/fig5/AS%3A953311133982722%401604298494369/multicast-DNS-Architecture-DNS-Domain-Name-System.png)

![Image](https://opengraph.githubassets.com/88991d28f7776dd7537e9b8f9049c98f7a80845fce0072b1e61591a6e52e0de7/agnat/node_mdns)

![Image](https://upload.wikimedia.org/wikipedia/commons/7/7b/Avahi-logo.svg)

### What is `.local`?

`.local` is a **reserved domain for multicast DNS (mDNS)**.

It ensures:

* No internet DNS lookup
* Local-network only resolution
* Future-proof against new public TLDs

---

## Why `.local` Is Required

❌ Bad:

```
server.london
```

✔ Good:

```
server.london.local
```

`.local` guarantees the name **never escapes your LAN**.

---

# How mDNS Works (Conceptually)

1. Device sends a **multicast query**:

   ```
   Who is raspberrypi.local?
   ```
2. All devices receive it
3. The correct host replies:

   ```
   I am raspberrypi.local → 192.168.1.29
   ```

No central DNS server required.

---

## mDNS Implementations

| OS      | Implementation     |
| ------- | ------------------ |
| macOS   | Bonjour / Zeroconf |
| Linux   | Avahi              |
| Windows | Partial support    |
| Routers | Often integrated   |

---

## Linux Requirements (Important)

On some distributions (e.g. **CentOS**):

```bash
sudo dnf install nss-mdns
sudo reboot
```

Without this:

* Others can resolve your host
* Your system cannot resolve others

---

# Capturing mDNS Traffic (Wireshark)

![Image](https://www.researchgate.net/publication/271466428/figure/fig2/AS%3A295152800288772%401447381319276/Screenshot-of-an-mDNS-response-packet-as-seen-in-Wireshark-from-a-successful-service.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AV4-r1-VH7jLgjpVO20zJLQ.png)

![Image](https://service.shure.com/servlet/rtaImage?eid=ka08W000000SJwx\&feoid=00N1I00000Gbkqm\&refid=0EM8W000006QFOI)

### Filter:

```
mdns
```

You will see:

* Multicast IPv6 packets
* Query + response messages
* Host announcing its IP

---

## Best Practice for Local Networking

✔ Always use:

```
hostname.local
```

✔ Or use static IPs if stability is critical

✔ Avoid bare hostnames without `.local`

---

# HTTP — How the Web Actually Works

![Image](https://www.researchgate.net/publication/369358390/figure/fig1/AS%3A11431281127810255%401679180216268/HTTP-request-and-response-flow.png)

![Image](https://media.licdn.com/dms/image/v2/C5612AQEypLYzlwPegA/article-cover_image-shrink_600_2000/article-cover_image-shrink_600_2000/0/1629980412670?e=2147483647\&t=_0rCtHnzTwYJUuxeKRh4xL6VLxbHTluK8iQ1cow8zr4\&v=beta)

![Image](https://i.sstatic.net/1dolH.png)

### HTTP basics

* Runs on **TCP**
* Text-based protocol
* Request → Response model

---

## Inspecting HTTP in Browser

1. Right-click → **Inspect**
2. Open **Network tab**
3. Reload page
4. Click request → **Headers**

Example request:

```
GET / HTTP/1.1
Host: www.google.com
User-Agent: Firefox
Accept: text/html
```

---

## HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Encoding: br
```

Then:

* HTML
* CSS
* JS
* Images (separate requests)

---

# Manual HTTP Using Telnet

![Image](https://moocat.me/words/guides/how-to-use-telnet-to-send-a-get-and-head-http-request/tph3.PNG)

![Image](https://tmgblog.richardhicks.com/wp-content/uploads/2009/08/telnet_http_03.jpg?w=584)

![Image](https://i.sstatic.net/I4URS.png)

### Open TCP connection

```bash
telnet www.google.com 80
```

### Send HTTP request

```
GET / HTTP/1.1
Host: www.google.com
```

(blank line required)

### Result

* Server replies with headers + HTML
* Pure text over TCP

---

## Why This Matters for DevOps

* Test server behavior
* Debug load balancers
* Validate HTTP compliance
* Fuzz malformed requests safely

Example malformed request:

```
HELLO WORLD HTTP/9.9
```

Expected result:

```
400 Bad Request
```

A good server **never crashes**.

---

# IPv4 vs IPv6 (Practical View)

![Image](https://www.networkacademy.io/sites/default/files/inline-images/comparing-ipv4-and-ipv6-headers.png)

![Image](https://upload.wikimedia.org/wikipedia/commons/7/70/Ipv6_address_leading_zeros.svg)

![Image](https://www.researchgate.net/publication/295789701/figure/fig2/AS%3A332568235921409%401456301854503/Dual-Stack-IPv6-protocol.png)

## IPv4

* 32-bit
* ~4.3 billion addresses
* NAT required
* Still dominant

Example:

```
192.168.1.10
```

---

## IPv6

* 128-bit
* 3.4 × 10³⁸ addresses
* No NAT required
* Hierarchical routing
* Better scalability

Example:

```
2001:db8::1
```

---

## IPv6 Address Shortening

Full:

```
2001:0db8:0000:0000:0000:0000:0000:0001
```

Shortened:

```
2001:db8::1
```

Rules:

* Remove leading zeros
* `::` only once

---

## Why IPv6 Is Better

✔ No NAT
✔ Easier routing
✔ Every device gets public IP
✔ Firewalls replace NAT for security

---

## Why IPv4 Still Matters

* Many ISPs still IPv4-only
* Legacy systems
* IPv6 transition is slow

---

# Dual Stack Is the Correct Strategy

✔ IPv4 + IPv6 enabled
✔ Servers reachable on IPv4
✔ IPv6 preferred internally
✔ Fallback always works

---

## DevOps Recommendation

| Scenario          | Recommendation   |
| ----------------- | ---------------- |
| Internal networks | Dual stack       |
| Public servers    | IPv4 mandatory   |
| Future-proofing   | Add IPv6         |
| Debugging         | Test both stacks |

---

## Wireshark IPv6 View

You’ll see:

* Longer IP headers
* ICMPv6
* mDNS heavily uses IPv6

IPv6 ≠ exotic — it’s already active.

---

# Key Takeaways

✔ Hostnames simplify local networking
✔ Always update `/etc/hosts`
✔ Use `.local` for LAN resolution
✔ mDNS uses multicast (not DNS)
✔ HTTP is plain text over TCP
✔ Telnet is a powerful debug tool
✔ IPv6 removes NAT limitations
✔ IPv4 still required today











# SSH — Secure Shell (Concepts & Real Usage)

![Image](https://miro.medium.com/0%2AtgrMTzwM0nO7DDjQ.png)

![Image](https://www.hostinger.com/tutorials/wp-content/uploads/sites/2/2017/07/asymmetric-encryption.webp)

![Image](https://doimages.nyc3.cdn.digitaloceanspaces.com/008ArticleImages/ssh-console-digitalocean.png)

## What is SSH?

**SSH (Secure Shell)** is a cryptographic network protocol used to securely access and manage remote systems over a network.

SSH provides:

* **Confidentiality** (encryption)
* **Integrity** (tamper detection)
* **Authentication** (verifying identities)

SSH is one of the **most important tools** for Linux, DevOps, Cloud, and Security engineers.

---

## Common SSH Use Cases

1. **Remote shell access**

   * Execute commands on a remote server
   * Administer systems without physical access

2. **Secure file transfer**

   * `scp` (Secure Copy)
   * `sftp` (SSH File Transfer Protocol)

3. **Tunneling / Port forwarding**

   * Securely forward other protocols through SSH

> In this course, we focus on **shell access, file transfer, and security basics**.

---

## SSH Architecture

![Image](https://www.ssh.com/hubfs/Imported_Blog_Media/SSH_simplified_protocol_diagram-2.png)

![Image](https://www.scaler.com/topics/images/linux-sshd-thumbnail.webp)

SSH always consists of **two components**:

### 1. SSH Server (`sshd`)

* Runs on the **remote machine**
* Listens for incoming connections
* Usually installed on servers

### 2. SSH Client (`ssh`)

* Runs on **your local machine**
* Used to connect to the SSH server
* Preinstalled on Linux, macOS, Windows

---

## Real-World Context

* Cloud servers **do not have monitors**
* You never “log in physically”
* SSH is **the primary control channel**

Everything you practice here applies directly to:

* AWS EC2
* Azure VMs
* Google Cloud
* Data center servers
* Raspberry Pi devices

---

# Network Setup Options for SSH Practice

You need **two machines that can reach each other**.

## Method 1 — Host → Virtual Machine (Recommended)

![Image](https://www.researchgate.net/profile/Maraehau-Salmon/publication/361825906/figure/fig8/AS%3A1175364869079048%401657240230239/VirtualBox-Bridged-network-21.png)

![Image](https://linuxiac.com/wp-content/uploads/2025/08/virtualbox-ssh-04.jpg)

* VM uses **Bridged Adapter**
* VM becomes a real device on your LAN
* Host connects directly to VM via SSH

**Pros**

* Simple
* Realistic
* Easy debugging

**Cons**

* May be blocked on corporate networks

---

## Method 2 — VM → VM (Always Works)

![Image](https://www.nakivo.com/blog/wp-content/uploads/2019/07/VirtualBox-network-modes-%E2%80%93-how-the-NAT-mode-works.png)

![Image](https://techbeatly.com/images/tb-uploads/2019/07/VirtualBox-network-modes-how-the-NAT-mode-works.png)

* Two VMs inside a **NAT Network**
* VMs can reach each other
* No dependency on host or corporate LAN rules

**Pros**

* Works everywhere
* Fully isolated

**Cons**

* Slightly less realistic than bridged mode

---

## VirtualBox NAT Network Setup (Reliable)

Key steps:

1. Power off VM
2. Clone VM
3. **Generate new MAC addresses**
4. Create **NAT Network**
5. Attach both VMs to that network
6. Boot both machines
7. Verify connectivity

### Verify IP addresses

```bash
ip addr show
```

### Verify connectivity

```bash
ping <other_vm_ip>
ping ubuntu.local
```

If ping works → SSH will work.

---

# Bridged Networking (Host → VM)

![Image](https://i.sstatic.net/HZOJ8.jpg)

![Image](https://linuxhint.com/wp-content/uploads/2021/05/word-image-732.png)

### What Bridged Mode Does

* VM shares physical NIC (Ethernet/Wi-Fi)
* VM gets **real IP from your router**
* Appears as a separate device on LAN

### After enabling bridged mode

```bash
ip addr show
```

You should see:

```
192.168.x.x
```

### Test from host

```powershell
ping 192.168.x.x
ping ubuntu.local
```

---

# Installing SSH Server (Ubuntu)

![Image](https://www.cyberciti.biz/media/new/faq/2018/08/How-to-login-to-power9-system-with-openbmc-client.png)

![Image](https://www.simplified.guide/_media/ssh/restart-service/sshd-status.png?tok=b58489\&w=700)

On the **machine you want to control**:

```bash
sudo apt update
sudo apt install openssh-server
```

Verify service:

```bash
systemctl status ssh
```

SSH server starts automatically.

---

# Connecting with SSH

## Basic Syntax

```bash
ssh username@host
```

Examples:

```bash
ssh user@192.168.1.40
ssh user@ubuntu.local
ssh user@example.com
```

If username is omitted:

```bash
ssh host
```

SSH uses your **local username** by default.

---

## First Connection Warning (Fingerprint)

You may see:

```
The authenticity of host cannot be established.
```

This is **normal**.

Type:

```
yes
```

This stores the server’s **host key fingerprint**.

We will cover this **security mechanism in detail later**.

---

## Successful SSH Session

Once connected:

* Your terminal controls the **remote machine**
* Commands behave exactly like local shell
* `exit` closes the connection

---

# SSH Security: Essential Practices

![Image](https://miro.medium.com/1%2AjHu1SshZKDRRgCE4nnqAGg.png)

![Image](https://us.norton.com/content/dam/blogs/images/norton/am/in-post-01-guest-networks-simplified.png)

SSH is encrypted, but **exposure still matters**.

## 1. Use Strong Passwords

* Long
* Unique
* Mixed characters
* Avoid dictionary words

Bad:

```
sanfrancisco
```

Good:

```
A9$eP7!xQm
```

---

## 2. Protect Active Sessions

* Never leave SSH sessions unattended
* Lock screen or disconnect
* Anyone with your open terminal **has server access**

---

## 3. Change Default SSH Port

### Why?

* Port **22** is scanned constantly
* Automated bots attempt brute force logins
* Log files become noisy
* Changing ports reduces noise (not absolute security)

---

## Change SSH Port (Ubuntu)

Edit config:

```bash
sudo nano /etc/ssh/sshd_config
```

Change:

```text
Port 22
```

To:

```text
Port 2222
```

Save file.

---

## Validate & Restart SSH

Always validate before restart:

```bash
sudo sshd -t
```

If no output → config is valid.

Restart service:

```bash
sudo systemctl restart ssh
```

Existing sessions remain active.

---

## Connect Using New Port

```bash
ssh -p 2222 user@host
```

Example:

```bash
ssh -p 2222 user@192.168.1.40
```

---

## Important Port Warning

Some networks block uncommon ports:

* Coffee shops
* Corporate Wi-Fi
* Public hotspots

**Solutions**

* Choose another port
* Use VPN
* Use SSH over port 443 if required

---

# SSH Logs & Monitoring

![Image](https://linuxhandbook.com/content/images/2024/11/ssh-logs-real-time.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240719102537/1.webp)

### Ubuntu / Debian

```bash
/var/log/auth.log
```

### CentOS / RHEL

```bash
/var/log/secure
```

View SSH activity:

```bash
grep sshd /var/log/auth.log
```

You will see:

* Successful logins
* Failed password attempts
* Source IPs
* Target usernames

Changing the SSH port makes **real attacks visible**, not buried in noise.

---

# Why This Matters in Production

SSH is:

* Your **primary control channel**
* Your **highest-risk exposed service**
* The **first target of attackers**

Understanding SSH deeply is **non-negotiable** for:

* DevOps
* Cloud Engineers
* SRE
* Security Engineers










# Restrict SSH Access to Specific Users

![Image](https://ostechnix.com/wp-content/uploads/2017/01/Edit-ssh-configuration-file-to-allow-ssh-access-to-particular-user.png.webp)

![Image](https://media2.dev.to/dynamic/image/width%3D1280%2Cheight%3D720%2Cfit%3Dcover%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fqaj8s76jh0dvgs4b1jza.png)

By default:

> **All local users with passwords can SSH**

This is **not ideal**.

---

## Allow Only Specific Users

In `sshd_config`:

```text
AllowUsers yannis
```

Multiple users:

```text
AllowUsers yannis deploy admin
```

Validate & restart:

```bash
sudo sshd -t
sudo systemctl restart sshd
```

---

## ⚠️ Lockout Warning (Very Important)

If you mistype the username:

* SSH will reject **everyone**
* If this is a remote server → **you are locked out**

---

# How to Avoid Locking Yourself Out (CRITICAL)

![Image](https://areeblog.com/wp-content/uploads/2025/09/SSH-and-Terminal.jpg)

![Image](https://substackcdn.com/image/fetch/%24s_%21doAK%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F1d1185b1-5e07-4adb-909f-63b003849b4a_1542x1466.heic)

### Golden Rule

**Always keep one SSH session open.**

Why?

* SSH sessions are **independent processes**
* Existing sessions survive SSH restarts

---

## Safe Workflow

1. Open **Terminal A**
2. Connect via SSH
3. Make SSH changes
4. Test from **Terminal B**
5. If broken → fix using Terminal A
6. Only close Terminal A when confirmed

---

### Example: SSH stopped

```bash
sudo systemctl stop sshd
```

* Existing session → still alive
* New connections → rejected

You can fix it:

```bash
sudo systemctl start sshd
```

This **prevents rescue-mode recovery**.

---

# SSH Key Authentication (Passwordless & Secure)

![Image](https://www.sectigo.com/uploads/images/SSH-Authentication.png)

![Image](https://www.manageengine.com/key-manager/images/ssh-key-based-authentication.png)

Passwords are:

* Guessable
* Brute-forceable
* Inconvenient for automation

SSH keys solve all of this.

---

## How SSH Keys Work (Concept)

* **Private key** → stays on your machine
* **Public key** → copied to server
* Server verifies identity **without passwords**
* Private key is never transmitted

---

## Generate SSH Key (Client Machine)

```bash
ssh-keygen -t rsa -b 4096
```

Press **Enter** for defaults.

Files created:

```text
~/.ssh/id_rsa       (PRIVATE – never share)
~/.ssh/id_rsa.pub   (PUBLIC – safe to share)
```

---

## Copy Public Key to Server

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2222 user@server
```

Enter your password **once**.

---

## Login Without Password

```bash
ssh -p 2222 user@server
```

✔ No password
✔ Secure
✔ Perfect for automation

---

## Server-Side Key Storage

Location:

```bash
~/.ssh/authorized_keys
```

Permissions:

```text
~/.ssh            → 700
authorized_keys   → 600
```

Each line = one allowed public key
Comments help identify owners.

---

# Why SSH Keys Are Essential

* Impossible to brute-force
* Required for CI/CD
* Required for automation
* Required for production security

SSH keys are **not optional** in real environments.












# Disable Password Authentication for SSH (Key-Only Login)

![Image](https://www.manageengine.com/key-manager/images/ssh-key-based-authentication.png)

![Image](https://discover.strongdm.com/hubfs/ssh-passwordless-tutorial.jpeg)

## Why Disable Password Authentication?

Now that **public/private key authentication** is configured, allowing password login is unnecessary and risky.

### Security Benefits

1. **Massive attack-surface reduction**

   * Passwords can be brute-forced
   * SSH keys are thousands of characters long
   * Practically impossible to guess

2. **Two-layer security**

   * SSH key → login
   * Password → `sudo` (privilege escalation)

3. **Even if SSH access is compromised**

   * Attacker still needs the **user password**
   * Root login is already disabled
   * Privilege escalation is blocked

---

## How Authentication Works After This Change

### Login

* Uses **private key**
* No password accepted

### System changes

```bash
sudo <command>
```

* Still requires **user password**

This means:

> SSH key ≠ root access

---

## Verify Key-Based Login Works (Before Disabling Passwords)

From your client:

```bash
ssh -p 2222 user@server
```

You should log in **without a password prompt**.

⚠️ **If this does not work, STOP. Do not continue.**

---

## Disable Password Authentication

Edit SSH server configuration:

```bash
sudo nano /etc/ssh/sshd_config
```

Set:

```text
PasswordAuthentication no
```

(Optional but recommended)

```text
PermitEmptyPasswords no
```

---

## Validate & Apply Configuration

```bash
sudo sshd -t
```

No output = configuration is valid

Restart SSH:

```bash
sudo systemctl restart sshd
```

---

## Test Enforcement (Important)

Switch to a user **without SSH keys** (or another local user):

```bash
ssh -p 2222 user@server
```

Expected result:

```text
Permission denied (publickey).
```

✔ Password login is now **fully disabled**
✔ Only authorized SSH keys can log in

---

## Critical Warnings (Very Important)

### 1. Other Users Will Be Locked Out

If teammates still use passwords:

* They **must** add SSH keys
* Otherwise access is lost

---

### 2. Losing Your Private Key = Lost Access

If your laptop is:

* Lost
* Damaged
* Encrypted drive wiped

You **cannot log in**.

### Best Practice

* Create **at least two SSH keys**
* Store on **different devices**
* Add both public keys to `authorized_keys`

---

### 3. If Private Key Is Leaked

If someone gets your **private key**:

* ALL servers using that key are compromised
* You must:

  1. Remove public key from all servers
  2. Generate a new key pair
  3. Re-deploy keys everywhere

---

# Prevent SSH Connection Drops (Keep-Alive)

![Image](https://i.sstatic.net/iJtA5.png)

![Image](https://substackcdn.com/image/fetch/f_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fed998b2e-fbc8-4c3c-b339-eca5abd85ce3_1289x1536.gif)

## The Problem

SSH connections may drop if:

* No activity for a long time
* NAT, firewall, or router times out
* You take a break (lunch, meeting, coffee)

This is annoying and dangerous:

* Lost working directory
* Lost environment state
* Possible lockout during SSH changes

---

## The Solution: Keep-Alive Packets

SSH can send **empty packets** periodically to keep the connection alive.

Best practice:

> Configure this on the **client**, not the server.

---

## Configure SSH Keep-Alive (Client Side)

Edit user SSH config:

```bash
nano ~/.ssh/config
```

Add:

```text
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### Meaning

* Every **60 seconds** → send keep-alive packet
* Allow **3 missed responses**
* Prevents idle disconnects

---

## Secure the Config File

```bash
chmod 600 ~/.ssh/config
```

---

## Result

* SSH sessions stay alive for hours
* No random disconnects
* Safe during breaks
* Extremely useful during server maintenance

As long as:

* Internet does not drop completely
* Laptop stays powered

Your SSH session remains active.

---

## Why This Matters in Production

These features prevent:

* Locking yourself out
* Losing work mid-operation
* SSH disconnects during critical changes

This is **mandatory knowledge** for:

* DevOps Engineers
* Cloud Engineers
* SREs
* Linux Administrators









# SSH Fingerprints: Why They Are Critical for Security

![Image](https://learningnetwork.cisco.com/sfc/servlet.shepherd/version/renditionDownload?contentId=05T3i00000AC7tq\&operationContext=CHATTER\&page=0\&rendition=THUMB720BY480\&versionId=0683i000001ri9T)

![Image](https://www.memcyco.com/wp-content/uploads/2023/09/Hoe-man-in-the-middle-attack-works.png)

## What Is an SSH Fingerprint?

* Every SSH server generates **host keys** when `sshd` is installed
* A **fingerprint** is a cryptographic hash of that host key
* It uniquely identifies **that exact server**

When you connect **for the first time**, SSH asks:

> *“Are you sure you want to continue connecting?”*

Once accepted, the fingerprint is saved locally.

---

## Where Fingerprints Are Stored (Client Side)

```bash
~/.ssh/known_hosts
```

This file maps:

```
hostname → fingerprint
```

From that moment on:

* SSH **expects the fingerprint to remain the same**
* Any change triggers a **security warning**

---

## Why Fingerprint Warnings Must NEVER Be Ignored

### Fingerprint Change = Red Flag

If SSH says:

```
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

Possible causes:

1. DNS now resolves to a **different server**
2. Server was **reinstalled**
3. **Man-in-the-middle attack**

---

## What Is a Man-in-the-Middle (MITM) Attack?

![Image](https://www.thesslstore.com/blog/wp-content/uploads/2018/11/man-in-the-middle-attack.png)

![Image](https://www.keytos.io/blog/img/man-in-the-middle-attack.jpg)

Instead of connecting directly:

```
You → Attacker → Real Server
```

The attacker:

* Creates their own SSH host key
* Forwards traffic to the real server
* Can **read passwords or commands**

SSH fingerprints are what **detect this attack**.

---

## Why Encryption Alone Is Not Enough

SSH traffic **is encrypted**, but:

* Encryption only protects the **transport**
* If the endpoint is wrong, encryption does not help

**Fingerprint verification proves the server identity.**

---

## How to Manually Verify an SSH Fingerprint (Best Practice)

### Step 1: Get the fingerprint from the server (trusted access)

On the server:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

(Or RSA if used)

### Step 2: Compare with client warning

SSH shows:

```
SHA256:QOG...ELkww
```

Both must **match exactly**.

Only then should you type:

```text
yes
```

---

## Important Reality Check

If SSH is your **only access**:

* First connection always requires **one trust decision**
* Best practice: trust **once**, verify manually, then never ignore warnings again

After first trust:

* Any future warning = **stop and investigate**

---

# SFTP: Secure File Transfer Over SSH

![Image](https://phoenixnap.com/kb/wp-content/uploads/2021/11/how-does-sftp-work-01-sftp.png)

![Image](https://cdn.softwaretestinghelp.com/wp-content/qa/uploads/2020/05/scp2.jpg)

## What Is SFTP?

* SSH File Transfer Protocol
* Built **on top of SSH**
* Fully encrypted
* Uses same authentication (password or SSH key)

SSH includes:

* Shell access
* SFTP access

(Some servers allow **SFTP only**, no shell)

---

## GUI Access via SFTP (Linux)

In file manager:

```
sftp://user@hostname
```

* Supports SSH keys automatically
* Shows fingerprint warning on first connection
* Permissions enforced by Linux users

---

## CLI File Transfer Using SCP

### Copy file from server → local

```bash
scp user@server:/home/user/file.txt .
```

### Copy directory recursively

```bash
scp -r user@server:/home/user/folder .
```

### Copy local → server

```bash
scp file.txt user@server:/home/user/
```

### Specify SSH port

```bash
scp -P 2222 file.txt user@server:/home/user/
```

⚠️ SCP uses **uppercase `-P`**
⚠️ SSH uses **lowercase `-p`**

---

## Using Cyberduck (Mac & Windows)

![Image](https://chemicloud.com/kb/wp-content/uploads/2021/02/3-1-783x486.jpg)

![Image](https://www.sfc.itc.keio.ac.jp/media/png/0/2016_08_03_cyberduck_en_3.png)

Cyberduck supports:

* SFTP
* SSH key authentication
* Drag & drop
* Permission management

Steps:

1. Select **SFTP**
2. Enter host, port, username
3. Choose SSH private key (recommended)
4. Verify fingerprint
5. Connect

---

# `screen`: Shared & Persistent Terminal Sessions

![Image](https://www.admin-magazine.com/var/ezflow_site/storage/images/media/images/f03-ttyshare/196998-1-eng-US/F03-ttyshare_reference.png)

![Image](https://omniti.com/i/terminal_multiplexing_before_and_after.png)

## What Is `screen`?

* Terminal multiplexer
* Creates a **virtual terminal**
* Multiple users can attach to the same session
* Session survives SSH disconnects

---

## Why DevOps Engineers Use `screen`

* Collaborative debugging
* Long-running processes
* Server maintenance
* Pair troubleshooting over SSH

---

## Install `screen`

```bash
# Ubuntu
sudo apt install screen

# CentOS
sudo dnf install screen
```

---

## Basic `screen` Workflow

### Start a session

```bash
screen
```

### Detach (leave it running)

```text
Ctrl + A, then Ctrl + D
```

### List sessions

```bash
screen -ls
```

### Reattach

```bash
screen -x <session-id>
```

---

## Sharing a Terminal with a Colleague

1. You start `screen`
2. Colleague SSHs into same server
3. Colleague runs:

```bash
screen -x
```

Now:

* Both see the same terminal
* Both can type
* Ideal for live collaboration

---

## Exit vs Detach (Important)

| Action          | Effect                 |
| --------------- | ---------------------- |
| `exit`          | Terminates the session |
| `Ctrl+A Ctrl+D` | Detaches safely        |

To fully stop screen:

```bash
exit
exit
```

(Exit shell → exit screen)

---

## Why `screen` Belongs in Your Toolbox

* No external software
* Works over SSH
* Extremely reliable
* Used in real production environments

---

# Summary

### SSH Security

* Fingerprints protect against MITM
* Never ignore fingerprint warnings
* Verify once, trust forever

### File Transfer

* SFTP = secure, encrypted, simple
* SCP for CLI automation
* GUI tools supported

### Collaboration

* `screen` enables shared terminals
* Safe, fast, SSH-native

This completes a **professional, real-world SSH workflow** used daily by DevOps engineers.

