---
title: "linux day #2"
description: "Linux User Management and Sudo – Foundations            User Types in Linux   In Linux,..."
published: 2025-12-24
source: "https://dev.to/jumptotech/linux-day-2-402j"
tags: []
---

# linux day #2


# Linux User Management and Sudo – Foundations

## User Types in Linux

In Linux, users are generally divided into **three main categories**.

Understanding these categories is very important because **permissions, security, and system management** depend on them.

---

## 1. System Accounts

System accounts are used by the operating system itself.

* They run **background services and processes**
* Examples: web servers, databases, system daemons
* They usually **do not have a home directory**
* They are **not meant for human login**



## 2. Regular Users

Regular users are normal human users of the system.

* Each regular user has a **home directory** (for example: `/home/username`)
* They can:

  * Create files
  * Edit files
  * Browse their own directories
* They **cannot**:

  * Perform administrative tasks
  * Access other users’ files
  * Change system configuration

During Ubuntu installation, the user you create is a **regular user** by default.

---

## 3. Super User (Root)

The **super user**, also called **root**, has **unrestricted access** to the system.

The root user can:

* Access all files, including other users’ home directories
* Add or remove users
* Install or remove software
* Change system configuration
* Perform any administrative task

There are **no restrictions** for the root user.

Because of this power, direct root usage is **dangerous** and is avoided in real environments.

---

## Regular User in Practice

When you log in as a regular user, you can:

* Browse files
* Create and edit files
* Use applications

However, you **cannot perform system administration tasks**.

For example:

* Opening **Settings → Users**
* Trying to add or modify users

You will see that:

* You cannot add users
* You cannot change settings

This is expected behavior for a regular user.

---

## Why We Need Temporary Privileges

In real systems, we often need to:

* Install software
* Update the system
* Manage users
* Change system configuration

We do **not** want to log in as root all the time.

Instead, Linux provides a safe mechanism called **sudo**.

---

## What Is `sudo`?

`sudo` stands for **“superuser do”**.

It allows a regular user to **temporarily gain elevated (root) privileges**.

Key points:

* Privileges apply **only to that command**
* You use **your own user password**, not the root password
* The command runs as root

---

## Example: Accessing Root’s Home Directory

The root user’s home directory is:

```
/root
```

A regular user **cannot** access this directory.

If you try:

```
ls /root
```

You will get:

```
Permission denied
```

But with `sudo`:

```
sudo ls /root
```

* You are prompted for **your password**
* The command executes with root privileges
* Access is granted

---

## Important Notes About `sudo`

* Not all users have `sudo` access
* During installation, you may need to enable:

  * “Make this user an administrator”
* If `sudo` does not work:

  * You will see a permission error
  * This can be fixed (no reinstall needed)
  * We will troubleshoot this in the next lecture

For now, assume `sudo` is working.

---

## Creating Another User (Example)

Using administrative privileges, you can create new users.

When creating a **standard user**:

* The user gets:

  * A home directory
* The user does **not** get:

  * `sudo` privileges by default

Each user’s home directory is private and protected.

---

## Accessing Other Users’ Home Directories

As a regular user:

```
cd /home/otheruser
```

Result:

```
Permission denied
```

With `sudo`:

```
sudo ls /home/otheruser
```

Now access is allowed.

This clearly shows how powerful `sudo` is.

---

## ⚠️ WARNING: Be Extremely Careful with `sudo`

`sudo` gives you **root power**.

If you run a dangerous command, Linux **will not stop you**.

For example (DO NOT RUN):

```
sudo rm -rf /etc
```

* This deletes critical system files
* The system will break
* The OS may fail to boot

In virtual machines, this is recoverable.
In real production systems, this can cause **serious outages**.

---

## Key Takeaways

* Linux has **system users, regular users, and root**
* Regular users are restricted by default
* Root has unlimited power
* `sudo` allows **temporary privilege escalation**
* `sudo` must be used **carefully and intentionally**

This foundation is critical for:

* Package management
* System updates
* DevOps and production environments

In the **next lecture**, we will focus fully on:

* How `sudo` works internally
* How to configure it safely
* How to troubleshoot `sudo` issues













# What to Do If `sudo` Does Not Work

## Important Clarification

Even if a regular user can use `sudo`, **that user is still not the super user (root)**.

* `sudo` only allows **temporary privilege escalation**
* You always enter **your own user password**
* You do **not** become root permanently

---

## Why `sudo` Might Not Work

If `sudo` does not work, it usually means:

* Your regular user was **not granted administrative privileges during installation**
* This is common on some systems (especially CentOS)

In this case:

* `sudo` commands will fail
* Administrative actions will request the **root password**, not your user password

---

## How to Recognize the Problem (GUI Example)

When opening **Settings → Users**:

* Clicking **Unlock** may ask for:

  * **Administrator password**
  * Not your regular user password

If the system asks for the **root password**, your user:

* Does **not** have `sudo` privileges
* Is a standard regular user only

If `sudo` were enabled:

* It would ask for **your own user password**

---

## Solution 1: Create a New Administrator User (Recommended)

Instead of modifying the existing user, the simplest and safest approach is:

1. Log in using the **root account** (or authenticate with root password)
2. Create a **new user**
3. Set the account type to **Administrator**
4. Assign a strong password

⚠️ Note:

* Some systems enforce **strict password policies**
* Simple passwords may be rejected
* This is normal and expected

Once created:

* This new user will have `sudo` privileges
* A home directory will be created automatically

---

## Switching to the New Admin User

1. Log out of the current session
2. Log in as the **new administrator user**
3. Open a terminal

Now test:

```bash
sudo ls /root
```

* The system asks for **your user password**
* Access is granted
* `sudo` is working correctly

---

## Verifying Permissions

As a regular user:

```bash
ls /home/otheruser
```

Result:

```
Permission denied
```

With `sudo`:

```bash
sudo ls /home/otheruser
```

Access is granted.

This confirms:

* User isolation is enforced
* `sudo` allows controlled privilege escalation

---

## Optional: Fix the Original User

Once logged in as an administrator:

* Go back to **Settings → Users**
* Unlock using your **admin user password**
* Change the original user’s role to **Administrator**

After logging out and back in:

* The original user will also have `sudo` access

---

## Summary: Fixing `sudo` Issues

If `sudo` does not work:

* Your user lacks administrative privileges
* Create a new **administrator user**
* Log in with that user
* Optionally upgrade the original user later

This works on:

* Ubuntu
* CentOS
* Most Linux distributions

---

# Introduction to Package Management (Concept)

Now that we understand **permissions and `sudo`**, we can talk about **package management**.

---

## What Is Package Management?

Package management is a system that allows you to:

* Install software
* Update software
* Remove software
* Keep the system secure and consistent

Almost all Linux distributions include a package manager.

This is one of Linux’s **biggest strengths**.

---

## Why Package Management Is Important

* Centralized software updates
* No need for individual app updaters
* System stays consistent and secure

For example:

* Firefox and Chrome usually **do not update themselves**
* Updates are handled by the OS package manager

---

## How Package Management Works

1. The system connects to **central repositories**
2. Repositories provide:

   * Available packages
   * Versions
   * Dependencies
3. The package manager:

   * Downloads a package list
   * Resolves dependencies automatically
   * Installs everything required

This process is:

* Automatic
* Reliable
* Widely used in production systems

---

## Distribution Differences

* Ubuntu and CentOS use **different tools**
* The **concept is the same**
* The **commands differ**

That’s why:

* Ubuntu package management
* CentOS package management
  are covered in **separate lectures**

---

# Package Management on Ubuntu (APT Basics)

## Why `sudo` Is Required

When running:

```bash
apt update
```

You may see:

```
Permission denied
```

Reason:

* APT needs access to system files

Solution:

```bash
sudo apt update
```

This updates the **package list**, not the software itself.

---

## Updating Installed Software

### Small Upgrade (Safe)

```bash
sudo apt upgrade
```

* Upgrades installed packages
* Installs **required dependencies**
* Does **not remove packages**

This is the safest upgrade option.

---

### Full Upgrade (Advanced)

```bash
sudo apt full-upgrade
```

(or)

```bash
sudo apt dist-upgrade
```

* Upgrades packages
* May **remove unused dependencies**
* May remove old packages

⚠️ Use only if you:

* Have time to troubleshoot
* Understand potential risks

---

## Installing Software

Example:

```bash
sudo apt install cowsay
```

* Installs the package
* Automatically resolves dependencies

Using the program:

```bash
cowsay Hello from Ubuntu
```

---

## Removing Software

```bash
sudo apt remove cowsay
```

* Removes the package
* Leaves unused dependencies behind

---

## Cleaning Unused Packages (Troubleshooting)

```bash
sudo apt autoremove
```

* Removes unused dependencies
* Often fixes upgrade issues
* Safe to run when needed

---

## APT vs APT-GET (Important Note)

Both work with the same system:

* `apt` → newer, user-friendly
* `apt-get` → older, script-friendly

Key difference:

* `apt upgrade` → installs dependencies
* `apt-get upgrade` → does **not** install new dependencies

You may see both used in this course.

---

## Key Takeaways

* `sudo` is required for system changes
* Package managers keep systems secure
* Ubuntu uses APT
* Always update before installing software
* Prefer `apt upgrade` for daily maintenance
* Use `full-upgrade` carefully

















`





#  Package Management and Bash




 you will learn:

* How to **create directories and files** in Bash
* How to **copy, move, and rename files**
  (renaming is done using the same command as moving)
* How to **delete files and directories**
* Why Bash can be **dangerous** if used incorrectly
* How to **protect yourself from accidental data loss**

You will also solve **real-world problems**, such as:

* Extracting all photos from a complex folder structure
  (for example, from an SD card)
* Finding and extracting specific PDF files from nested directories



# Package Management on macOS: Homebrew

Unlike Linux, macOS does **not** include a built-in system-wide package manager.

To install software from the command line, we use **Homebrew**.

Homebrew describes itself as:

> “The missing package manager for macOS”

This description is very accurate, especially if you work a lot in the terminal.

---

## Installing Homebrew

To install Homebrew:

1. Open a browser
2. Go to the Homebrew website
3. Copy the installation command shown there

The command:

* Uses Apple’s built-in Bash
* Downloads a script
* Executes it to install Homebrew

⚠️ **Security note**
Running a script downloaded from the internet always carries some risk.
In this case, we trust Homebrew because it is widely used and well-maintained.

---

## Running the Installer

1. Open **Terminal** on macOS
2. Paste the install command
3. Press Enter
4. Enter your password if prompted
5. Follow the on-screen instructions

Once the installation finishes, Homebrew is ready to use.

---

# Using Homebrew

### Updating Package Definitions

```bash
brew update
```

This updates Homebrew’s package list.

Unlike Linux:

* Homebrew usually **does not require sudo**
* It installs software in user-controlled directories

---

### Installing Software

To install a package:

```bash
brew install <package-name>
```

Example:

```bash
brew install bash
```

This installs a modern version of Bash (version 5.x).

---

### Upgrading Installed Software

To upgrade all installed packages:

```bash
brew upgrade
```

---

# Installing and Using Bash 5 on macOS

After installing Bash with Homebrew, a **new Bash version** is available on your system.

---

## Launching the New Bash

In most cases, you can simply run:

```bash
bash
```

Then verify the version:

```bash
echo $BASH_VERSION
```

If the version starts with **5**, you are good to go.

---

## If Bash Is Still Version 3

On some systems, `bash` may still start Apple’s old Bash (version 3).

In that case, start Homebrew’s Bash explicitly:

```bash
/opt/homebrew/bin/bash
```

(Apple Silicon Macs)

or use tab completion to locate the correct path.

This will **always** launch Bash 5.x.

---

## Apple Bash Still Exists

Nothing is removed.

You can still launch Apple’s original Bash with:

```bash
/bin/bash
```

This keeps the system safe and compatible.

---

# Important Differences on macOS

Although Bash works very similarly, there are some differences to be aware of.

### Home Directory Path

On macOS:

```text
/Users/yourname
```

On Linux:

```text
/home/yourname
```

---

### Folder Names and Language

Even if your macOS language is not English:

* Finder may show translated names (e.g. “Dokumente”)
* The **actual folder name** on disk is still:

  ```text
  Documents
  ```

This is important when navigating in the terminal.

---

# Safety Warning for macOS Users

When using Bash **directly on macOS**:

* You are working on your **real system**
* A single wrong command (for example `rm -rf`) can delete real files

That is why:

* A **virtual machine is still recommended**
* Especially for beginners

However:

* For Bash basics
* For scripting practice

You can safely do **a large portion of the course** directly on macOS if you are careful.














# File Management Basics in Bash

## `touch`, `mkdir`, `mv`, and `cp`



* `touch` – create files and update timestamps
* `mkdir` – create directories
* `mv` – move and rename files
* `cp` – copy files and directories

These commands are used **every day** in real Linux and DevOps environments.

---

## 1. Creating Files with `touch`

The `touch` command is typically used to **create empty files**.
It can also create **multiple files at once**.

### Creating a Single File

Assume we are already inside an empty directory:

```bash
touch invite.txt
```

Now list the contents:

```bash
ls
```

You will see:

```
invite.txt
```

---

### Creating Multiple Files at Once

```bash
touch anna.txt max.txt eva.txt
```

List again:

```bash
ls
```

All files are created in one command.

---

### Why Is It Called `touch`?

The main purpose of `touch` is **not just file creation**.

What it actually does:

* If the file **exists** → updates its timestamp
* If the file **does not exist** → creates an empty file with the current timestamp

---

### Viewing File Timestamps

Use the `-l` flag with `ls`:

```bash
ls -l
```

This shows:

* Permissions
* Owner
* Size
* **Last modified timestamp**

Now touch an existing file again:

```bash
touch invite.txt
ls -l
```

You will see that the **timestamp has changed**.

---

## 2. Creating Directories with `mkdir`

The `mkdir` command is used to create **directories (folders)**.

### Example

```bash
mkdir ready
```

List contents:

```bash
ls
```

You now have:

* Files
* One directory (`ready`)

---

### Showing Colors (Optional)

On most systems:

```bash
ls --color=auto
```

* Directories appear in a different color
* Files remain a normal color

This helps visually distinguish files and folders.

---

## 3. Moving Files with `mv`

The `mv` command is used to:

* Move files
* Rename files
* Move and rename at the same time

---

### Moving a File into a Folder

```bash
mv anna.txt ready/
```

Confirm without changing directories:

```bash
ls ready
```

The file is now inside the `ready` folder.

---

### Renaming a File

```bash
mv max.txt maximilian.txt
```

List contents:

```bash
ls
```

The file has been renamed.

---

### Move and Rename at the Same Time

```bash
mv maximilian.txt ready/max.txt
```

This:

* Moves the file into `ready`
* Renames it back to `max.txt`

Check:

```bash
ls ready
```

---

## 4. Copying Files with `cp`

The `cp` command creates a **copy** of a file.

---

### Copying a File

```bash
cp laura.txt laura_copy.txt
```

Now both files exist.

---

### Copy and Rename in One Step

```bash
cp laura.txt ready/lauren.txt
```

This:

* Copies the file
* Renames it during the copy

---

### Copying Multiple Files into a Folder

```bash
cp eva.txt ready/
```

---

## 5. Copying Directories (Recursive Copy)

To copy a **directory**, you must use the `-R` flag.

`-R` means **recursive** (copy everything inside).

---

### Example: Create a Backup

```bash
cp ready ready_backup
```

This will **fail**, because `ready` is a directory.

Correct command:

```bash
cp -R ready ready_backup
```

Now you have:

* `ready`
* `ready_backup`

Both contain the same files.

---

### Best Practice: Avoid Spaces in Names

Instead of:

```
Ready Backup
```

Use:

```
ready_backup
```

Why?

* Spaces require quotes
* Commands become harder to type
* Underscores are safer and standard practice

---

## Summary of Commands

| Command | Purpose                                |
| ------- | -------------------------------------- |
| `touch` | Create empty files / update timestamps |
| `mkdir` | Create directories                     |
| `mv`    | Move or rename files                   |
| `cp`    | Copy files                             |
| `cp -R` | Copy directories recursively           |


















# Deleting Files and Directories in Bash

## `rm` and `rmdir`


⚠️ **Important warning**:
Deleting files in Bash is **permanent**.
There is **no recycle bin**, no undo, and usually **no confirmation**.

Because of this, these commands are some of the **most dangerous** Bash commands.

---

## 1. Deleting Files with `rm`

To delete a file, we use the `rm` command.

### Delete a Single File

```bash
rm invite.txt
```

The file is deleted immediately.

---

### Delete Multiple Files at Once

```bash
rm anna.txt max.txt
```

Both files are removed with one command.

---

## ⚠️ Why `rm` Is Dangerous

When you delete a file using `rm`:

* The file is **gone permanently**
* It does **not** go to Trash / Bin
* You cannot restore it

### Example (Real Risk)

If you delete a presentation file:

```bash
rm presentation.pptx
```

And then open your Trash:

* The file is **not there**
* It is permanently deleted

This is why you must **always double-check** before pressing Enter.

---

## 2. Deleting Directories with `rm -r`

By default, `rm` **cannot delete directories**.

If you try:

```bash
rm ready_backup
```

You will get an error saying it is a directory.

This is intentional — deleting directories is even more dangerous.

---

### Recursive Delete (`-r`)

To delete a directory, you must explicitly allow it:

```bash
rm -r ready_backup
```

* `-r` means **recursive**
* Deletes the directory and **everything inside it**
* Works for empty and non-empty directories

After this command, the folder is **completely gone**.

---

## 3. Why Extra Protection Exists

Deleting one file is bad.
Deleting a **whole directory tree** by accident can be catastrophic.

That is why:

* `rm` refuses to delete directories by default
* You must explicitly add `-r`

This extra step protects you from accidental data loss.

---

## 4. Safer Alternative: `rmdir`

The `rmdir` command means **remove directory**.

Key behavior:

* It **only deletes empty directories**
* It will **fail** if the directory contains files

### Example

```bash
rmdir ready
```

If the directory is **not empty**, you will see:

```
Directory not empty
```

Nothing is deleted.

---

## Why `rmdir` Is Safer

If you accidentally run `rmdir` on a directory with files:

* Nothing happens
* Your data is safe

This makes `rmdir` a **much safer choice** when possible.

---

## 5. Hidden Files and `rmdir`

Be careful: **hidden files count as files**.

### Example

Create a directory and a hidden file:

```bash
mkdir images
touch images/.thumbs.db
```

List normally:

```bash
ls images
```

It looks empty.

But list all files:

```bash
ls -a images
```

You will see:

* `.thumbs.db` (hidden file)

Now try:

```bash
rmdir images
```

It will fail because the directory is **not empty**.

---

### Special Entries Explained

When using `ls -a`, you may see:

* `.` → current directory
* `..` → parent directory

These are **not real files**.
Only `.thumbs.db` is a real file in this example.

---

## 6. Correct and Safe Cleanup Process

To safely delete the directory:

```bash
rm images/.thumbs.db
rmdir images
```

This approach is:

* Explicit
* Safer
* Less error-prone than `rm -r`

---

## Summary of Deletion Commands

| Command          | Purpose                       | Safety            |
| ---------------- | ----------------------------- | ----------------- |
| `rm file`        | Delete file                   | ⚠️ Dangerous      |
| `rm file1 file2` | Delete multiple files         | ⚠️ Dangerous      |
| `rm -r dir`      | Delete directory and contents | 🚨 Very dangerous |
| `rmdir dir`      | Delete empty directory        | ✅ Safer           |

---

## Key Takeaways

* `rm` permanently deletes files
* There is **no undo**
* `rm -r` is extremely dangerous
* Prefer `rmdir` whenever possible
* Always double-check paths before pressing Enter

















# File Management – Exercise Solution



## Step 1: Navigate to the Desktop

First, we check our current working directory:

```bash
pwd
```

On macOS, the home directory looks like:

```text
/Users/yourname
```

Now navigate to the Desktop:

```bash
cd Desktop
```

You can also use **Tab completion** to avoid typing everything manually.

Verify:

```bash
pwd
```

You should now be on your Desktop.

---

## Step 2: Create and Enter `temp_website`

Create a new directory:

```bash
mkdir temp_website
```

Move into it:

```bash
cd temp_website
```

Confirm:

```bash
pwd
```

---

## Step 3: Create Initial Files

Create three files:

```bash
touch index.html style.css script.js
```

Verify:

```bash
ls
```

You should see all three files.

---

## Step 4: Create `styles` Directory and Move `style.css`

Create the directory:

```bash
mkdir styles
```

Move the file:

```bash
mv style.css styles/
```

Verify:

```bash
ls
ls styles
```

---

## Step 5: Create `scripts` Directory

Still inside `temp_website`, create:

```bash
mkdir scripts
```

---

## Step 6: Move and Rename `script.js`

Move `script.js` into `scripts` and rename it to `index.js` at the same time:

```bash
mv script.js scripts/index.js
```

Verify:

```bash
ls scripts
```

---

## Step 7: Create `pages/page1.html`

Create a new directory:

```bash
mkdir pages
```

Create the file inside it (without changing directories):

```bash
touch pages/page1.html
```

---

## Step 8: Copy to `page2.html` and `page3.html`

Copy using paths:

```bash
cp pages/page1.html pages/page2.html
```

Change into the directory and copy again:

```bash
cd pages
cp page1.html page3.html
```

Now go back:

```bash
cd ..
```

---

## Step 9: Move `page2.html` One Level Up

Move the file from `pages` into the current directory:

```bash
mv pages/page2.html .
```

The dot (`.`) means **current directory**.

---

## Step 10: Delete Unneeded Files

Delete:

* `index.html`
* `pages/page1.html`
* `pages/page3.html`

```bash
rm index.html pages/page1.html pages/page3.html
```

---

## Step 11: Rename `page2.html` to `index.html`

```bash
mv page2.html index.html
```

---

## Step 12: Remove Empty `pages` Directory

Because `pages` is now empty, use:

```bash
rmdir pages
```

---

## Step 13: Delete the Entire Project Directory

First, leave the directory:

```bash
cd ..
```

Now delete everything recursively:

```bash
rm -r temp_website
```

The project is now completely removed.

---

## Exercise Summary

This exercise was a **play-along**, but it is extremely important because these commands are used constantly:

* `cd`
* `pwd`
* `touch`
* `mkdir`
* `mv`
* `cp`
* `rm`
* `rmdir`

Practicing them builds muscle memory that you will rely on later.

---

# Introduction to Globbing (Filename Expansion)

We are now ready to talk about **Globbing**, also called **filename expansion**.

This is one of the reasons why Bash is:

* Very compact
* Extremely powerful

---

## What Is Globbing?

Globbing is a process where **Bash rewrites your command before it is executed**.

It:

* Recognizes **wildcard characters**
* Matches file patterns
* Expands them into real file names

This happens **before** the command runs.

---

## Example Without Globbing

Imagine a folder containing:

```text
image1.jpeg
image2.jpeg
image3.jpeg
movie.mp4
info.txt
```

To move images manually:

```bash
mv image1.jpeg image2.jpeg image3.jpeg images/
```

This works, but it is inefficient.

---

## Using the `*` Wildcard

The `*` (asterisk) means:

> Match zero or more characters

Move all JPEG files at once:

```bash
mv *.jpeg images/
```

Bash expands this internally to:

```bash
mv image1.jpeg image2.jpeg image3.jpeg images/
```

You didn’t type that — **Bash did it for you**.

---

## Why This Is Powerful

* Works with 3 files or 300 files
* Reduces errors
* Saves time
* Makes scripts scalable

---

## Globbing Works with Any Command

Globbing is a **shell feature**, not a `mv` feature.

Example:

```bash
echo *.jpeg
```

Bash expands the wildcard and prints the file names.

The command itself has no idea globbing happened.

---

## What Happens If Globbing Finds Nothing?

If no files match:

```bash
mv *.jpeg images/
```

Bash passes `*.jpeg` as a literal string.

Result:

* `mv` fails
* File does not exist

This behavior is specific to Bash and differs in other shells like Zsh.

---

## Disabling Globbing with Quotes

Wildcards are **not expanded** inside quotes.

```bash
echo "*.jpeg"
```

Output:

```text
*.jpeg
```

No expansion occurs.

---

## Creating Files with Wildcard Characters

If you want a literal filename like:

```text
*.jpeg
```

Use quotes:

```bash
touch "*.jpeg"
```

Now it is a real file name.

---

## Working with Such Files

Always disable globbing:

```bash
mv "*.jpeg" new.jpeg
```

This treats it as a literal filename.

---

## Globbing ≠ Regular Expressions

Important clarification:

* Globbing is **not** regex
* Syntax is different
* Use cases are different
























# Globbing – Additional Wildcards


* `*` (asterisk) → matches **zero or more characters**



* `?` (question mark)
* `[ ]` (character ranges)
* `**` (globstar – recursive matching)

---

## 1. The Question Mark `?`

The question mark matches **exactly one single character**.

### Comparison

| Wildcard | Matches                 |
| -------- | ----------------------- |
| `*`      | Zero or more characters |
| `?`      | Exactly one character   |

---

### Example

Assume we have these files:

```text
IMG_6677.mkv
IMG_6677.srt
```

To match both files:

```bash
echo IMG_?677.*
```

Explanation:

* `IMG_` → fixed prefix
* `?` → matches exactly one character
* `677` → fixed digits
* `.*` → any extension

Both files are matched.

---

### Why `?` Is Useful

If filenames differ by **only one character**, `?` allows you to match them without matching too much.

---

## 2. Character Ranges `[ ]`

Square brackets allow you to match **exactly one character from a defined range**.

### Examples

| Pattern | Meaning              |
| ------- | -------------------- |
| `[0-9]` | One digit            |
| `[a-z]` | One lowercase letter |
| `[A-Z]` | One uppercase letter |

---

### Example with Images

Assume we have files like:

```text
IMG_6001.jpeg
IMG_6123.jpeg
IMG_7450.jpeg
```

To match only images starting with `IMG_6` and followed by **three digits**:

```bash
echo images/IMG_6[0-9][0-9][0-9].*
```

Explanation:

* `IMG_6` → fixed prefix
* `[0-9][0-9][0-9]` → exactly three digits
* `.*` → any extension

This matches files starting with `IMG_6xxx`.

---

### Important Limitation

Normal globbing **does not support repetition counts** like `{3}`.

So this does **not** work in standard globbing:

```text
[0-9]{3}
```

You must repeat the range manually.

---

### Practical Note

In real life, most people simply use:

```bash
IMG_6*
```

The asterisk is often **simpler and more practical**.

---

## 3. The Double Asterisk `**` (Globstar)

The double asterisk matches:

* Zero or more characters
* **Including directory separators (`/`)**

This allows **recursive matching**.

---

### Requirements

* Bash **4.0 or higher**
* `globstar` must be enabled:

```bash
shopt -s globstar
```

---

### Example: Find All JPEG Files Recursively

```bash
echo **/*.jpeg
```

Explanation:

* `**/` → any directory depth
* `*.jpeg` → all JPEG files

This finds JPEG files in:

* Current directory
* Subdirectories
* Nested folders

---

### Why the Slash Matters

This is correct:

```bash
**/*.jpeg
```

This is wrong:

```bash
**.jpeg
```

Without the slash, Bash would look for a file literally named `something.jpeg` inside a folder.

---

### Combining Globstar with Commands

Example: Copy all JPEG and MOV files into the current directory:

```bash
cp **/*.jpeg **/*.mov .
```

* Both patterns are expanded
* Last argument (`.`) is the destination

---

## 4. Why Globbing Is So Powerful

One command can:

* Traverse directories
* Match hundreds of files
* Replace complex manual work

This is why Bash is:

* Compact
* Extremely powerful
* Widely used in automation

---

# ⚠️ Be Careful with Globbing

Globbing is powerful — **and dangerous** if used incorrectly.

---

## The Core Problem

Bash does **not distinguish** between:

* Filenames
* Command parameters

Everything is just **arguments**.

---

### Dangerous Scenario

A file can legally be named:

```text
-rf
```

Now imagine this command:

```bash
rm *
```

Bash expands `*` to:

```bash
rm -rf documents important.txt
```

Now:

* `-r` → recursive
* `-f` → force
* Confirmation is bypassed
* Entire directories may be deleted

This can cause **massive data loss**.

---

## Demonstration

Files and folders:

```text
important.txt
letter.txt
documents/
documents/presentation.txt
```

Now create a dangerous filename safely:

```bash
touch ./-rf
```

The `./` ensures it is treated as a filename.

---

### Expansion Example

```bash
echo *
```

Expands to:

```text
-rf documents important.txt letter.txt
```

Now if used with `rm`, behavior changes drastically.

---

## ✅ Best Practice: Always Use `./*`

Instead of:

```bash
rm *
```

Use:

```bash
rm ./*
```

Why this is safer:

* `./-rf` is now clearly a filename
* It cannot be interpreted as a parameter
* Commands behave predictably

---

### Example

```bash
rm ./*
```

* Files are deleted
* Directories are **not deleted** unless `-r` is explicitly provided

This dramatically reduces risk.

---

## Key Safety Rule

> **Always prefix wildcards with `./` when working in the current directory.**

This one habit prevents many real-world accidents.

---

## Summary: Globbing Safety

* Globbing happens **before command execution**
* Filenames can become parameters
* `*` can expand into dangerous arguments
* `./*` forces filenames, not options
* Power requires responsibility

---

# Globbing Exercise

## Scenario

You work for a company and must urgently provide documents for **January and February**.

Requirements:

* Extract **Excel and PDF files**
* From **multiple departments**
* Across **nested folder structures**

---

## Folder Structure (Provided as ZIP)

* Departments (e.g. `sales`, `purchasing`)
* Monthly folders:

  * `01_January`
  * `02_February`
* Files:

  * `.xlsx`
  * `.pdf`
  * Other irrelevant files

---

## Your Goal

Use **globbing** to:

* Select only January and February
* Select only PDF and Excel files
* Work across all departments
* Copy results into one destination

---

## Helpful Tips

### Character Ranges

```text
[0-2]
```

Matches:

* `0`
* `1`
* `2`

Useful for months.

---

### Combining Patterns

You can use multiple glob patterns in one command:

```bash
cp pattern1 pattern2 destination/
```

Both patterns expand before execution.

---

### Practical Advice

* Extract the ZIP
* Navigate to the root folder
* Try solving it **yourself first**
* Observe how compact Bash solutions can be














# Globbing Exercise – Sample Solution



## Viewing the Directory Structure

First,  listed the directory structure in my terminal using the `tree` command:

```bash
tree
```

This command displays the folder structure in a tree-like format.

⚠️ **Note**:
You may need to install `tree` first, depending on your system.
This output is similar to what you saw earlier in the file browser.

---

## Understanding the Task

We need to:

* Go through **multiple department folders** (for example, `purchasing` and `sales`)
* Enter **January and February** only
* Collect:

  * **Excel files (`.xlsx`)**
  * **PDF files (`.pdf`)**
* Copy them into a single destination folder

The folders cannot be reliably selected by name, but they **can be selected by number**:

* January → `01`
* February → `02`

This is perfect for globbing.

---

## Matching January and February

To match January and February folders, we use:

```text
0[1-2]*
```

Explanation:

* `0` → folders starting with `0`
* `[1-2]` → match `1` or `2`
* `*` → match the rest of the folder name

---

## Previewing Excel Files (Safe Check)

Before copying anything, we preview the result using `echo`:

```bash
echo */0[1-2]*/**/*.xlsx
```

This shows all Excel files from:

* Any department
* January and February only

Always preview first when using globbing.

---

## Creating the Destination Folder

Create a folder to collect the files:

```bash
mkdir export
```

---

## Copying Excel Files

Now copy all matching Excel files into the `export` folder:

```bash
cp */0[1-2]*/**/*.xlsx export/
```

Verify:

```bash
ls export
```

---

## Copying PDF Files

Repeat the process for PDF files:

```bash
cp */0[1-2]*/**/*.pdf export/
```

Now the `export` folder contains:

* All Excel files
* All PDF files
* From January and February
* From all departments

---

## Combining Multiple Patterns in One Command

You can also combine multiple patterns in a single `cp` command:

```bash
cp */0[1-2]*/**/*.xlsx */0[1-2]*/**/*.pdf export/
```

Both patterns are expanded before execution, and the **last argument** is the destination directory.

---

## Even Shorter (Advanced – Preview Only)

Later in the course, you will learn expansions that allow this:

```bash
cp */0[1-2]*/**/*.{xlsx,pdf} export/
```

This is shorter, but it relies on advanced Bash expansions, which we will cover later.

---

## Why This Matters

What would be very difficult and error-prone in a graphical interface becomes a **one-liner in Bash**.

This is why Bash is:

* Extremely powerful
* Highly efficient
* Widely used in automation and DevOps

---

## Summary of the Solution

* We used **globbing**, not `find`
* We selected folders by **number ranges**
* We matched multiple file types
* We copied everything with **one or two commands**

This was the intended solution to the exercise.

---

# Bonus Lecture: The `find` Command

This is a **bonus lecture**.

That means:

* Not required for the rest of the course
* Very useful to know
* Highly recommended to watch

---

## What Is `find`?

`find` is a standalone program used to **search files and directories** based on many criteria.

Basic syntax:

```bash
find <path>
```

Example (current directory):

```bash
find .
```

This lists:

* All files
* All folders
* Including hidden system files

---

## Stopping a Long `find` Command

If you accidentally run `find` on a very large directory (like `/`):

* It may take a long time
* Press **Ctrl + C** to stop it

---

## Filtering by Type

### Find Files Only

```bash
find . -type f
```

### Find Directories Only

```bash
find . -type d
```

---

## Filtering by Modification Time

Find files modified in the last 7 days:

```bash
find . -type f -mtime -7
```

* `-mtime` → modification time
* `-7` → last 7 days

---

## Filtering by File Size

Find files larger than 1 MB:

```bash
find . -type f -size +1M
```

This can be useful for:

* Cleanup
* Disk usage analysis

---

## ⚠️ `find` Can Modify Files

`find` is powerful and **can be dangerous**.

Example: delete empty files:

```bash
find . -type f -empty -delete
```

This permanently deletes files.

Always be careful when combining `find` with actions like `-delete`.

---

## Getting Help for `find`

Quick help:

```bash
find --help
```

Full documentation:

```bash
man find
```

Use `q` to exit the manual.

The `find` command has **many options**, far more than we covered here.

---

## Key Takeaways

* Globbing is great for **pattern-based selection**
* `find` is better for **complex filtering**
* `find` can search by:

  * Type
  * Time
  * Size
* `find` can also **modify or delete files**
* Always preview before destructive actions













# Reading Files from the Command Line



## 1. Reading Files with `cat`

The simplest way to read a file is with the **`cat`** command.

> ⚠️ Note: The correct command is **`cat`**, not `cut`.
> `cut` is a different tool used for column-based text processing.

### Basic usage

```bash
cat bash.txt
```

This prints the entire contents of the file directly to the terminal.

### Using globbing with `cat`

Because `cat` accepts multiple file names, you can use globbing:

```bash
cat *.txt
```

This prints **all matching files** in order.

---

## ⚠️ Warning: Do NOT `cat` Binary Files

If you accidentally run `cat` on a binary file (for example, a JPEG):

```bash
cat image.jpg
```

You may see:

* Garbled output
* Broken terminal behavior
* Cursor issues or strange characters

Some terminals interpret binary control characters, which can **corrupt your terminal session**.

✅ **If this happens**:
Close the terminal and open a new one.

---

## 2. Why `cat` Is Not Enough for Large Files

Imagine a very large text file, such as:

```bash
Romeo.txt   # Romeo and Juliet (public domain)
```

This file contains **over 5,500 lines**.

If you run:

```bash
cat Romeo.txt
```

Problems occur:

* The terminal buffer is limited
* You cannot scroll back far enough
* The beginning of the file is lost

So we need better tools.

---

## 3. Viewing Parts of Files with `head` and `tail`

### `head` – show the beginning of a file

```bash
head Romeo.txt
```

By default, this shows the **first 10 lines**.

To specify the number of lines:

```bash
head -n 20 Romeo.txt
```

---

### `tail` – show the end of a file

```bash
tail Romeo.txt
```

This shows the **last 10 lines**.

Useful for:

* Logs
* Recent entries
* End-of-file summaries

---

## 4. Reading Large Files Properly with `less`

The best tool for reading large text files is **`less`**.

```bash
less Romeo.txt
```

### Why `less` is better

* Loads files efficiently
* Does not overflow the terminal buffer
* Allows interactive navigation

---

### Navigation inside `less`

| Key        | Action              |
| ---------- | ------------------- |
| Arrow keys | Move line by line   |
| `F`        | Page forward        |
| `B`        | Page backward       |
| `q`        | Quit                |
| `=`        | Show file position  |
| `50%`      | Jump to 50% of file |

---

### Searching inside `less`

* Forward search:

  ```text
  /word
  ```
* Backward search:

  ```text
  ?word
  ```

Example:

```text
/food
```

This jumps to the next occurrence of “food”.

---

### Show line numbers

```bash
less -N Romeo.txt
```

This displays **line numbers**, which is very useful for orientation.

---

## 5. Counting Lines, Words, and Bytes with `wc`

The **word count** program is `wc`.

```bash
wc Romeo.txt
```

Output format:

```
lines  words  bytes  filename
```

---

### Common `wc` options

| Option | Meaning     |
| ------ | ----------- |
| `-l`   | Count lines |
| `-w`   | Count words |
| `-c`   | Count bytes |

Example (line count only):

```bash
wc -l Romeo.txt
```

This is often used to decide:

* Is the file too large for `cat`?
* Should I use `less` instead?

---

## 6. Checking File Size with `du` (Disk Usage)

The `du` command shows how much disk space a file or directory uses.

### File size only

```bash
du Romeo.txt
```

---

### Summary only (recommended)

```bash
du -s Romeo.txt
```

---

## ⚠️ macOS vs Linux Disk Size Difference

* **macOS**

  * Default block size: **512 bytes**
* **Linux**

  * Default block size: **1024 bytes (1 KB)**

This makes macOS output confusing.

### Fix: Human-readable output

```bash
du -sh Romeo.txt
```

This works consistently across systems.

---

## 7. Editing Files from the Command Line

Bash itself does **not** include a text editor.
You must use an external program.

---

## Recommended Editor: `nano`

We use **Nano** because:

* Very easy to learn
* Minimal keyboard shortcuts
* Installed by default on many systems

Related editors:

* `pico` → older version
* `nano` → modern rewrite
* `vim` → powerful but steep learning curve (not used here)

---

## Installing Nano

### macOS (Homebrew)

```bash
brew install nano
```

### Ubuntu / WSL

```bash
sudo apt update
sudo apt install nano
```

---

## Editing a File with Nano

```bash
nano bash.txt
```

If the file does not exist, Nano will create it when you save.

---

### Basic Nano Controls

| Shortcut   | Action               |
| ---------- | -------------------- |
| `Ctrl + O` | Save file            |
| `Enter`    | Confirm filename     |
| `Ctrl + X` | Exit                 |
| Arrow keys | Move cursor          |
| `Ctrl + C` | Show cursor position |
| `/`        | Search               |

Nano shows shortcuts at the bottom of the screen.

---

## Why Use Nano Instead of VS Code?

Nano is essential when:

* Working on **remote servers**
* Connected via **SSH**
* No graphical interface available

Example:

* Editing server config files
* Quick fixes on production systems
* Emergency changes

For **large projects**, a GUI editor (like VS Code) is still preferred.
















# Exercise: Analyzing a Real-World Log File (Shell-Only)


The file you receive is **synthetically generated** for privacy reasons, but:

* The **format**
* The **structure**
* The **content patterns**

are all very close to what you would see in production systems.

---

## Your Tasks

After downloading the log file, answer the following **three questions**:

### 1. What kind of log file is this?

* What system or application could have generated it?
* What kind of information is being logged?

### 2. What is the file size?

* Use the **shell only**
* Do **not** check the browser or file explorer
* Determine the size in:

  * KB / MB / GB (as appropriate)

### 3. How many lines does the log file contain?

* Again, use **shell commands only**

---

## Important Rules

* ❌ Do **not** open the file in a GUI editor
* ❌ Do **not** rely on file explorer metadata
* ✅ Use **shell tools only**
* ✅ Pretend this file lives on a **remote server** accessed via SSH

This is exactly how log analysis works in real DevOps / Linux environments.

---

## Hints

* The file is **small enough** to be analyzed locally
  (to keep download sizes reasonable)
* In real production systems, log files can be:

  * Hundreds of MB
  * Several GB
* Avoid dumping the entire file to the terminal
* Use tools that allow **controlled inspection**

---

# Sample Solution

Let’s now walk through **one correct way** to solve the exercise.

---

## Step 1: Inspect the Beginning of the File

Use `head` to preview the first few lines:

```bash
head -n 4 access.log
```

What we observe:

* Each line is long (wrapped visually)
* Contains:

  * IP addresses (IPv4 and IPv6)
  * Dates and timestamps
  * HTTP methods (GET)
  * Paths
  * HTTP versions
  * Status codes

---

## Step 2: Inspect the End of the File

Use `tail`:

```bash
tail access.log
```

Or more context:

```bash
tail -n 40 access.log
```

Observations:

* Same structure throughout
* Status codes like:

  * `200` (OK)
  * `302` (Redirect)
  * `404` (Not Found)
* URLs
* Browser information (User-Agent strings)

---

## Step 3: Identify the Log Type

From the structure we can identify:

* Client IP address
* Timestamp with timezone
* HTTP request method and path
* HTTP version
* Response status code
* Referrer
* User-Agent string

👉 **Conclusion**
This is a **web server access log**, specifically in the
**Apache Combined Log Format**.

You did **not** need to know the exact name for the quiz — recognizing it as a **web server log** is enough.

---

## Step 4: Count the Number of Lines

Use `wc` (word count):

```bash
wc -l access.log
```

Output:

```
10000 access.log
```

✔ The file contains **10,000 log entries**.

---

## Step 5: Determine the File Size (Shell Only)

Use `du` (disk usage).

### macOS (recommended)

```bash
du -h access.log
```

Output (example):

```
3.0M access.log
```

✔ File size is approximately **3 MB**.

> On macOS, always use `-h` because default block sizes are confusing.

### Linux (Ubuntu)

```bash
du -h access.log
```

Linux already reports in kilobytes by default, so the output is usually clearer.

---

## Why This Approach Matters

You analyzed the file by:

* Viewing **only small parts**
* Avoiding terminal overflow
* Using efficient, safe commands

This scales to:

* Very large log files
* Remote servers
* Production environments

Dumping an entire log file with `cat` would be:

* Inefficient
* Potentially dangerous
* Completely unrealistic in real systems

---

## Final Answers Summary

| Question   | Answer                |
| ---------- | --------------------- |
| Log type   | Web server access log |
| Line count | 10,000 lines          |
| File size  | ~3 MB                 |














#  Streams in Bash







## Writing Command Output to a File

Let’s start with a simple problem:

> We have a command that produces output.
> How can we save that output into a file?

### The Wrong Way (Manual Copy)

One possible (but bad) approach would be:

1. Run a command
2. Select the output with your mouse
3. Copy it
4. Paste it into a text file
5. Save the file

This approach:

* Depends on your terminal and OS
* Breaks with large output
* Is slow and error-prone
* Does not work on remote servers

So this is **not the correct solution**.

---

## Redirecting Output with `>`

Bash provides a built-in way to redirect output using the **greater-than operator (`>`)**.

### Basic Syntax

```bash
command > file.txt
```

What this does:

* Takes the output of `command`
* Writes it into `file.txt`
* If the file does not exist → it is created
* If the file exists → it is **overwritten**

### Example

```bash
echo "Hello Bash" > output.txt
```

Now check the file:

```bash
cat output.txt
```

Output:

```
Hello Bash
```

Notice:

* Nothing was printed to the terminal
* The output was written directly to the file

---

### Overwriting Behavior

If we run another command:

```bash
ls > output.txt
```

Now the file contains the output of `ls`, and the previous content is gone.

This is important:

> `>` **always overwrites** the file.

---

## Appending Output with `>>`

Sometimes we don’t want to overwrite a file.
Instead, we want to **append** new output to the end.

For this, we use the **double greater-than operator (`>>`)**.

### Basic Syntax

```bash
command >> file.txt
```

What this does:

* Creates the file if it does not exist
* Appends output if the file already exists

### Example

```bash
echo "----" >> output.txt
echo "Another line" >> output.txt
```

Check the file:

```bash
cat output.txt
```

You will now see multiple lines added to the file instead of overwritten.

---

### Appending Command Output

You can append output from any command:

```bash
du -h image.jpg >> output.txt
```

The result of the `du` command is now added to `output.txt`.

---

## Important Observation: Errors Are Not Redirected

Let’s look at an example:

```bash
du does_not_exist.txt >> output.txt
```

What happens?

* The error message appears **in the terminal**
* Nothing new is added to `output.txt`

Why?

Because **not all output is the same**.

---

## Why Errors Behave Differently

Bash uses **separate streams**:

* **Standard Output (stdout)** – normal command output
* **Standard Error (stderr)** – error messages

When you use:

```bash
command > file.txt
```

or

```bash
command >> file.txt
```

You are **only redirecting standard output**, not errors.

That’s why:

* Successful output goes into the file
* Errors still appear on the screen

This behavior is **by design** and extremely important.

---

## Why This Matters

Understanding this allows you to:

* Save only successful output
* Capture only errors
* Discard noisy output
* Debug scripts more effectively
* Write professional-grade Bash commands

This is exactly how real Unix systems are designed to work.
















# Understanding Standard Streams in Bash

To understand why Bash behaved the way it did when we redirected output, we need to understand **standard streams**.

Every Unix/Linux program communicates with the outside world using **three default streams**.

---

## The Three Standard Streams

### 1. Standard Input (stdin) — **File Descriptor 0**

* Name: **STDIN**
* Purpose: Input to a program
* Default source: **Keyboard**

If a program reads input (for example `cat` without a file), it reads from stdin.

---

### 2. Standard Output (stdout) — **File Descriptor 1**

* Name: **STDOUT**
* Purpose: Normal program output
* Default destination: **Terminal**

Anything a program prints when everything works correctly goes to stdout.

---

### 3. Standard Error (stderr) — **File Descriptor 2**

* Name: **STDERR**
* Purpose: Error messages
* Default destination: **Terminal**

Errors are sent to stderr so they can be handled separately from normal output.

---

## Why Errors Didn’t Go Into Your File

When you run:

```bash
command > output.txt
```

You are **only redirecting stdout (fd 1)**.

* stdout → file
* stderr → terminal (unchanged)

That’s why error messages still appeared on the screen.

---

## Explicit Stream Redirection

Redirection operators can be written in a **short form** or a **verbose form**.

### These two commands are identical:

```bash
command > output.txt
1> output.txt
```

Because:

* `1` = stdout
* stdout is the default redirection target

---

## Redirecting stderr

To redirect **errors**, use file descriptor **2**.

```bash
command 2> error.txt
```

Now:

* stdout → terminal
* stderr → error.txt

---

## Redirecting stdout and stderr Separately

Example using `du` (which produces both output and errors):

```bash
du file_exists.txt file_missing.txt 1> output.txt 2> error.txt
```

Result:

* `output.txt` → file size info
* `error.txt` → error message

Nothing appears on the terminal.

---

## Appending Instead of Overwriting

Use `>>` to append:

```bash
du file_exists.txt file_missing.txt 1>> output.txt 2>> error.txt
```

---

## Discarding Errors with `/dev/null`

Sometimes errors are irrelevant and should be ignored.

Unix provides a **special device**:

```text
/dev/null
```

Anything written to `/dev/null` is **discarded permanently**.

### Ignore all errors:

```bash
command 2> /dev/null
```

### Ignore normal output but keep errors:

```bash
command 1> /dev/null
```

---

## Why Ignoring Errors Matters

Later in Bash scripting:

* Errors can break pipelines
* Errors can pollute command output
* Scripts may fail unexpectedly

Suppressing stderr allows scripts to continue cleanly.

---

## Redirecting stderr to stdout

Sometimes you want **both outputs together**.

Instead of writing:

```bash
command > out.txt 2> out.txt
```

You can redirect stderr **into stdout**:

```bash
command > out.txt 2>&1
```

Meaning:

* `2>` → redirect stderr
* `&1` → send it to wherever stdout is currently going

---

## Why This Is Important (Pipelines)

Bash pipes (`|`) only work with **stdout**.

If stderr is not redirected to stdout:

* It **cannot** be piped
* It breaks data processing

This makes `2>&1` essential for advanced Bash usage.

---

## Example

```bash
du existing.txt missing.txt > out.txt 2>&1
```

Both normal output and errors end up in `out.txt`.

---

## Why Output Order May Change

You may notice:

Terminal output order:

```
file size
error message
```

File output order:

```
error message
file size
```

### This is due to buffering:

| Stream | Buffering                                    |
| ------ | -------------------------------------------- |
| stdout | **Buffered** (file-buffered when redirected) |
| stderr | **Unbuffered**                               |

What happens:

1. stdout waits in a buffer
2. stderr is written immediately
3. buffer flushes when program exits

This is a **performance optimization**, not a bug.

---

## Key Takeaways

* Bash uses **three streams**
* `>` redirects stdout
* `2>` redirects stderr
* `/dev/null` discards output
* `2>&1` merges stderr into stdout
* Buffering can change output order
* Correct ordering of redirections **matters**


















# Why the Order of Redirections Is Extremely Important

Let’s compare these two commands:

### ✅ Correct (works as expected)

```bash
command > out.txt 2>&1
```

### ❌ Incorrect (does NOT work the same)

```bash
command 2>&1 > out.txt
```

At first glance, they look almost identical.
But they behave **very differently**.

---

## Key Rule to Remember

👉 **Redirections are processed from left to right**
👉 Bash creates **mappings**, not sequential execution

---

## Case 1: Correct Order

```bash
command > out.txt 2>&1
```

### Step-by-step mapping

1. `> out.txt`

   * Redirects **stdout (1)** to `out.txt`

2. `2>&1`

   * Redirects **stderr (2)** to **where stdout is currently pointing**
   * At this moment, stdout → `out.txt`

### Final result

| Stream | Destination |
| ------ | ----------- |
| stdout | out.txt     |
| stderr | out.txt     |

✔ **Both outputs go into the file**

---

## Case 2: Wrong Order

```bash
command 2>&1 > out.txt
```

### Step-by-step mapping

1. `2>&1`

   * Redirects stderr to **current stdout**
   * At this moment, stdout → terminal

2. `> out.txt`

   * Redirects **stdout only** to file
   * stderr is already mapped and does **not change**

### Final result

| Stream | Destination |
| ------ | ----------- |
| stdout | out.txt     |
| stderr | terminal    |

❌ **Errors still appear on screen**

---

## Why This Happens (Mental Model)

Redirection is **not**:

> “Do this, then do that”

It is:

> “Create stream mappings in order, then run the command”

Once stderr is mapped, **later redirections do not affect it**.

---

## Visual Summary

### Correct

```text
stdout ──▶ out.txt
stderr ──▶ stdout ──▶ out.txt
```

### Wrong

```text
stderr ──▶ terminal
stdout ──▶ out.txt
```

---

## Golden Rule (Interview-Safe)

> **If you want stderr to follow stdout, `2>&1` must come last**

✔ Always write:

```bash
command > file 2>&1
```

❌ Never:

```bash
command 2>&1 > file
```

---

# Understanding stdin (Standard Input)

So far, we worked with:

* `stdout` (1)
* `stderr` (2)

Now let’s look at:

### stdin — File Descriptor **0**

---

## Programs That Read stdin

Many Unix programs accept input **without a file argument**.

Example:

```bash
wc -l
```

This waits for input from **stdin (keyboard)**.

### Example

```bash
wc -l
hello
world
^D
```

Output:

```text
2
```

* You typed 2 lines
* `Ctrl+D` ends stdin

---

## stdin Redirection Using `<`

We can feed a file into stdin:

```bash
wc -l < file.txt
```

### What happens

1. Bash reads `file.txt`
2. Sends its contents to stdin
3. `wc` reads stdin
4. Outputs line count

✔ Same result as:

```bash
wc -l file.txt
```

---

## stdin With `cat`

```bash
cat
```

Waits for stdin and echoes it back.

```bash
cat < file.txt
```

Reads file via stdin instead of filename.

---

## Why stdin Matters (Big Picture)

Right now this may feel unnecessary — and that’s okay.

👉 **stdin becomes critical when we use pipes (`|`)**, because:

* Pipes pass **stdout of one command** into **stdin of another**
* stderr does NOT pipe unless redirected

That’s why everything you learned here is foundational.

---

## Summary: Streams Mastered

| Stream | FD | Purpose       |
| ------ | -- | ------------- |
| stdin  | 0  | Input         |
| stdout | 1  | Normal output |
| stderr | 2  | Errors        |

### Redirection Essentials

```bash
>    stdout overwrite
>>   stdout append
2>   stderr overwrite
2>>  stderr append
<    stdin
2>&1 stderr → stdout
```

### Critical Rule

> **Redirection order matters**
















# Why Pipes Are Important in Bash

Before learning *how* pipes work, we need to understand **why we need them**.

Let’s start with a very simple task:

## Problem

**How do we count the number of files in a directory?**

---

## ❌ Inefficient (Old Way – No Pipes)

Without pipes, you might think like this:

1. List files with `ls`
2. Redirect output into a temporary file
3. Count lines using `wc`
4. Delete the temporary file

### Example

```bash
ls > output.txt
wc -l output.txt
rm output.txt
```

### Problems with this approach

* ❌ Creates unnecessary temporary files
* ❌ Output file affects directory contents
* ❌ More commands than needed
* ❌ Error-prone and inefficient

---

## Hidden Problem: Output File Affects Results

When you do:

```bash
ls > output.txt
```

What happens internally?

1. `output.txt` is created **first**
2. Then `ls` runs
3. `ls` now sees **output.txt** as part of the directory
4. So it gets included in the listing

### Result

Instead of 3 files, you now see **4**:

* 3 original files
* `output.txt` (created before `ls` runs)

So your count is already wrong unless you subtract manually.

This is **not reliable**.

---

## ✅ The Pipe Solution (Correct Way)

Instead of writing output to a file, we can **send output directly to another program**.

That’s exactly what **pipes** are for.

---

## What Is a Pipe?

The pipe operator is:

```bash
|
```

### Meaning:

> Take the **stdout** of the left command
> and send it as **stdin** to the right command

---

## Counting Files Using a Pipe

### One-line solution

```bash
ls | wc -l
```

### What happens step by step:

1. `ls`

   * Lists files
   * Sends output to **stdout**

2. `|` (pipe)

   * Takes stdout of `ls`
   * Feeds it into stdin

3. `wc -l`

   * Reads from stdin
   * Counts lines

✔ No temporary files
✔ No side effects
✔ Fast and clean

---

## Why Pipes Are Powerful

Pipes allow you to:

* Combine small programs into powerful workflows
* Avoid intermediate files
* Process large outputs efficiently
* Work safely on remote servers
* Build production-grade shell commands

This follows the **Unix philosophy**:

> *“Do one thing well, and combine tools together.”*

---

## Pipes vs Redirection (Important Difference)

| Feature | Redirection (`>`) | Pipe (`|`) |
|------|-----------------|-----------|
| Writes to file | Yes | No |
| Connects programs | No | Yes |
| Temporary files | Required | Not needed |
| Real-time processing | No | Yes |

---

## What Pipes Enable Later

Once you understand pipes, you can:

* Filter logs
* Extract patterns
* Count errors
* Search text
* Chain 5–10 commands together
* Build real DevOps one-liners

Example preview:

```bash
cat access.log | grep 404 | wc -l
```



---

## Key Takeaways

* Temporary files are inefficient and risky
* Pipes connect programs directly
* Pipes work with **stdout → stdin**
* Pipes are essential for real-world Bash usage
* One pipe can replace multiple commands and files

















# Using Pipes in Bash 

## What Is a Pipe?

A **pipe (`|`)** connects two commands together.

* The **stdout** of the first command becomes the **stdin** of the second command.
* This allows us to **chain commands** and build powerful workflows.
* Everything happens **in memory**, without temporary files.

### General Syntax

```bash
command1 | command2 | command3
```

Each command:

* Reads from **stdin**
* Writes to **stdout**
* Pipes forward to the next command

---

## Example: Counting Files in a Directory

```bash
ls | wc -l
```

### How This Works

1. `ls` lists files → stdout
2. `|` sends stdout to stdin
3. `wc -l` counts lines → prints result

Result:

* One clean command
* No temporary files
* No side effects

---

## Pipes and Output Formatting

When `ls` outputs directly to a terminal:

* It may format output in columns

When `ls` is piped:

* Each file appears on **its own line**

That’s why `wc -l` works correctly here.

---

## Using Pipes to Inspect Output

```bash
ls | cat
```

This may look pointless, but it demonstrates:

* `ls` → stdout
* `cat` → reads stdin → prints output

This confirms:

> Pipes move **stdout → stdin**

---

# Combining Pipes with Redirection

## Filtering Errors Only

Example command:

```bash
du file_exists.txt missing.txt
```

Produces:

* stdout → size of existing file
* stderr → error for missing file

### Keep Only Errors

```bash
du file_exists.txt missing.txt 1>/dev/null
```

Now:

* stdout is discarded
* stderr remains

---

### Send Errors into a Pipe

To pipe **errors**, they must first be redirected to stdout:

```bash
du file_exists.txt missing.txt 2>&1 1>/dev/null | wc -l
```

### Step-by-step:

1. `2>&1` → stderr → stdout
2. `1>/dev/null` → discard original stdout
3. Pipe remaining output into `wc -l`

Result:

* Counts number of error lines

This pattern is **extremely common in production scripts**.

---

# The `tee` Command

## What Does `tee` Do?

`tee`:

* Reads from **stdin**
* Writes to **stdout**
* Writes to **file at the same time**

Think of it like a **T-junction** in a pipe.

---

## Basic Example

```bash
echo "Hello world" | tee hello.txt
```

Result:

* Output shown in terminal
* Output saved in `hello.txt`

---

## Append Instead of Overwrite

```bash
echo "Another line" | tee -a hello.txt
```

* `-a` = append mode

---

## `tee` in a Pipe Chain

```bash
echo "Hello world" | tee hello.txt | wc -c
```

### What Happens

1. `echo` → produces text
2. `tee`:

   * writes to `hello.txt`
   * forwards output
3. `wc -c` counts characters

Result:

* File keeps full content
* Pipeline continues processing

This is extremely useful when **debugging complex pipelines**.

---

# Real-World Example: Logging Ping Output

### Ping normally:

```bash
ping google.com
```

* Output → stdout
* Errors → stderr

---

### Capture EVERYTHING (stdout + stderr)

```bash
ping google.com 2>&1 | tee ping.log
```

### Why this is powerful:

* All output is visible live
* All output is saved to file
* Works even when errors occur
* Perfect for troubleshooting and documentation

Press `Ctrl + C` to stop ping.

---

## Common DevOps Use Cases for `tee`

* Capture logs while watching them live
* Debug broken pipelines
* Save intermediate pipeline results
* Provide evidence for support tickets
* Monitor long-running commands

---

# Key Takeaways

* Pipes connect commands via **stdout → stdin**
* Redirection controls **where output goes**
* `tee` lets you **see output and save it**
* Order of redirects matters
* Pipes are essential for real-world Bash usage



















# Common Text Processing Tools in Bash


## 1. The `sort` Command

### What `sort` Does

`sort`:

* Sorts lines of text
* Works on **files** or **stdin**
* Outputs the result to **stdout**
* **Does not modify the original file**

By default, sorting is **alphabetical (lexicographical)**.

---

### Basic Usage

```bash
sort users.txt
```

This:

* Reads `users.txt`
* Sorts lines alphabetically
* Prints result to the terminal

---

### Using `sort` with Pipes

```bash
cat users.txt | sort
```

This works the same, but:

* Is less efficient
* Useful when input comes from another command

---

### Common `sort` Options

#### Reverse Order

```bash
sort -r users.txt
```

#### Numeric Sorting

```bash
sort -n numbers.txt
```

Use `-n` when lines **start with numbers**, otherwise `sort` treats them as text.

#### Sort by Column (Field)

```bash
sort -k 2 users.txt
```

* Sorts by the **second column**
* Columns are separated by whitespace by default

Example:

```
John Smith
Alice Brown
```

Sorted by **last name**, not first name.

#### Check If File Is Already Sorted

```bash
sort -c users.txt
```

* No output → file is sorted
* Error → file is not sorted

---

## 2. The `uniq` Command

### What `uniq` Does

`uniq`:

* Removes **duplicate adjacent lines**
* Works on **sorted input**
* Does **not** remove duplicates unless they are **next to each other**

This is extremely important.

---

### Incorrect Usage (Very Common Mistake)

```bash
uniq users.txt
```

This **will NOT remove all duplicates** unless the file is already sorted.

---

### Correct Usage (Classic Pattern)

```bash
sort users.txt | uniq
```

This:

1. Sorts the file
2. Groups duplicates together
3. Removes duplicate lines

---

### Shortcut: `sort -u`

```bash
sort -u users.txt
```

This:

* Sorts
* Removes duplicates
* In **one command**

Preferred in most cases.

---

### Find Only Duplicate Lines

```bash
sort users.txt | uniq -d
```

* Shows **only duplicated entries**
* Very useful for:

  * Detecting duplicate users
  * Finding repeated log entries

---

## 3. Filtering Streams with `grep`

### What `grep` Does

`grep`:

* Searches for a **pattern**
* Outputs **only matching lines**
* Works on **files** or **stdin**
* Filters **line by line**

---

### Basic Usage (Exact Match)

```bash
grep -F "Alice" users.txt
```

* `-F` = fixed string
* No regular expressions
* Safer and faster for beginners

---

### Why Use `-F`?

By default, `grep` uses **regular expressions**.
For now, we **disable regex** to avoid complexity.

You will learn regex later in the course.

---

### Using `grep` with Pipes

```bash
ls | grep -F ".txt"
```

This:

* Lists files
* Filters only `.txt` files

---

### Example: Filtering Network Information

```bash
ip addr show | grep -F "inet"
```

This:

* Prints only lines containing IP addresses

Further filtering:

```bash
ip addr show | grep -F "inet" | grep -F "192.168"
```

Each `grep`:

* Narrows the result further
* Keeps commands simple and readable

---

## ⚠️ Important Warning: `grep` and Binary Files

**Do NOT use `grep` on binary files** (images, archives, executables).

Reasons:

1. False matches (random byte sequences)
2. Extremely slow performance
3. Terminal corruption (non-printable characters)
4. Not designed for binary data

`grep` is for **text files only**.

---

## Summary

### `sort`

* Orders text
* Supports numeric, reverse, column-based sorting

### `uniq`

* Removes duplicates
* Requires sorted input
* `sort -u` is the preferred shortcut

### `grep`

* Filters lines by pattern
* Works with pipes
* Essential for logs and system output














# Working with Strings in Bash 

I
This is extremely important because:

* Most real-world shell work is **text processing**
* Logs, configs, command outputs → all strings
* Pipes allow us to transform data step-by-step


1. `tr` – character-level translation and deletion
2. `rev` – reverse strings
3. `cut` – extract parts of strings
4. `sed` – word-level and pattern-based editing

---

## 1. Character-Level Replacement with `tr`

### What is `tr`?

`tr` stands for **translate**.

It:

* Works on **stdin**
* Replaces or deletes **characters**
* Works strictly on a **character level**, not words

---

### Basic Replacement

```bash
echo bash | tr b d
```

Output:

```
dash
```

Here:

* `b` → `d`
* Every occurrence is replaced

---

### Multiple Character Replacement

```bash
echo bash | tr ba dc
```

Mapping:

* `b` → `d`
* `a` → `c`

Output:

```
dcsh
```

Important:

* `tr` does **not** replace strings
* It replaces **character by character**

---

### Character Ranges

`tr` supports **ranges**, such as `a-z` or `A-Z`.

Convert lowercase → uppercase:

```bash
echo awesome | tr a-z A-Z
```

Output:

```
AWESOME
```

This range expansion is a **feature of `tr`**, not Bash.

---

### Unequal Ranges

If ranges have different lengths:

```bash
echo alphabet | tr a-z X
```

* All letters become `X`
* Last character is reused

---

### Deleting Characters with `-d`

```bash
echo "Bash is amazing" | tr -d ' '
```

Output:

```
Bashisamazing
```

This deletes **all spaces**.

---

### When `tr` Is Useful

* Case conversion
* Removing characters
* Simple character cleanup
* Fast and lightweight

---

## 2. Reversing Strings with `rev`

### What `rev` Does

`rev` reverses **all characters in each line**.

Example:

```bash
echo "Was it a cat I saw?" | rev
```

Output:

```
?was I tac a ti saW
```

Useful for:

* Palindrome checks
* Simple transformations
* Debugging text flows

---

## 3. Extracting Data with `cut`

`cut` is **extremely important** in Bash pipelines.

It allows us to extract:

* Bytes
* Characters
* Fields (columns)

Only **one mode at a time** can be used.

---

### Cutting by Bytes (`-b`)

```bash
uptime | cut -b 1-10
```

Cuts the **first 10 bytes** of output.

⚠️ Bytes ≠ characters
Some characters use **multiple bytes**.

---

### Cutting by Characters (`-c`)

```bash
echo "😄hello" | cut -c 1-2
```

Correctly handles multibyte characters.

Key difference:

* `-b` can break characters
* `-c` is character-aware

---

### Cutting by Fields (`-f`) – Most Important

By default, fields are **tab-separated**.

To change delimiter, use `-d`.

Example:

```bash
uptime | cut -d ' ' -f 1
```

* `-d ' '` → space delimiter
* `-f 1` → first field

---

### Multiple Fields

```bash
uptime | cut -d ' ' -f 1,3
```

Or ranges:

```bash
uptime | cut -d ' ' -f 3-
```

---

### Important Note on Whitespace

Multiple spaces = empty fields.

Different systems (Linux vs macOS) may produce:

* Leading spaces
* Different field positions

Always **inspect the output first**.

---

## 4. Word-Level Editing with `sed`

### What is `sed`?

`sed` = **stream editor**

It:

* Edits text streams
* Works on stdin or files
* Uses its own command language

Most common use case: **string replacement**

---

### Basic Substitute Command

```bash
echo "hello world" | sed 's/world/bash/'
```

Output:

```
hello bash
```

---

### Replace All Occurrences (`g` flag)

```bash
echo "hello world world" | sed 's/world/bash/g'
```

Output:

```
hello bash bash
```

---

### Syntax Breakdown

```
s / pattern / replacement / flags
```

* `s` → substitute
* `pattern` → what to find
* `replacement` → what to insert
* `g` → global (all matches)

---

### Why `sed` Is Powerful

* Works on **words and patterns**
* Supports **regular expressions**
* Can delete, insert, modify lines
* Essential for scripts and automation

---

### Platform Differences (Important)

* macOS → BSD `sed`
* Linux → GNU `sed`

Simple replacements work the same
Complex scripts may differ slightly

Always test on target OS in production.

---

## Summary

### Tool Comparison

| Tool  | Purpose                     | Level               |
| ----- | --------------------------- | ------------------- |
| `tr`  | Replace / delete characters | Character           |
| `rev` | Reverse strings             | Character           |
| `cut` | Extract parts               | Byte / Char / Field |
| `sed` | Edit text                   | Word / Pattern      |




















# Exercise Solution: Analyzing Web Server Logs with Pipes

## Goal Recap

We were asked to analyze a web server access log (`access.log`) and answer two questions:

1. **How many ZIP file downloads happened in total?**
2. **How many unique ZIP files were downloaded?**

We will solve this using **Bash pipes**, without fully parsing the log format.

This is intentional:

> Bash is best used to get **fast, practical insights**, not perfect parsing.

---

## Step 1: Understand the Log Structure

Each line in `access.log` looks roughly like this:

```
IP - - [date] "GET /downloads/file.zip HTTP/1.1" 200 referrer "User-Agent"
```

Important observations:

* Each request is **one line**
* ZIP files appear as `*.zip`
* ZIP filenames appear **inside the request path**
* User agent and referrer fields contain spaces → hard to parse cleanly
* We **do not** attempt perfect column parsing

---

## Step 2: Find All ZIP File Downloads

We first filter **only lines that contain `.zip`**.

```bash
grep -F ".zip" access.log
```

Why `-F`?

* Disables regular expressions
* Treats `.zip` as a literal string
* Faster and safer for logs

At this point:

* Each remaining line represents **one ZIP download request**

---

## Step 3: Count Total ZIP Downloads (Question 1)

Now we simply count how many matching lines exist:

```bash
grep -F ".zip" access.log | wc -l
```

### Explanation:

* `grep -F ".zip"` → keep only ZIP downloads
* `wc -l` → count number of lines

### Result:

```
4061
```

✅ **Answer 1:**
**4061 ZIP file downloads in total**

This includes:

* Repeated downloads of the same file
* Different users
* Different browsers

---

## Step 4: Extract the ZIP File Path

Now we want to find **how many different ZIP files** were downloaded.

We must extract the **requested file path**.

In the Apache *combined log format*, the request path appears as the **7th space-separated field**:

```bash
grep -F ".zip" access.log | cut -d ' ' -f 7
```

Why this works:

* Although the log contains quoted strings
* The request path itself does **not contain spaces**
* The 7th field reliably contains `/path/to/file.zip`

At this point, output looks like:

```
/downloads/app-v1.zip
/downloads/app-v2.zip
/downloads/toolkit.zip
...
```

---

## Step 5: Find Unique ZIP Files

To remove duplicates:

1. Sort the list
2. Remove duplicates
3. Count the result

```bash
grep -F ".zip" access.log \
| cut -d ' ' -f 7 \
| sort \
| uniq
```

This produces a clean list of **unique ZIP files**.

---

## Step 6: Count Unique ZIP Files (Question 2)

Now count the number of unique files:

```bash
grep -F ".zip" access.log \
| cut -d ' ' -f 7 \
| sort \
| uniq \
| wc -l
```

### Result:

```
27
```

✅ **Answer 2:**
**27 unique ZIP files were downloaded**

---

## Final Answers

| Question            | Answer   |
| ------------------- | -------- |
| Total ZIP downloads | **4061** |
| Unique ZIP files    | **27**   |

---

## Why This Bash Solution Is Powerful

* No temporary files
* No scripting language required
* One-line commands
* Extremely fast even on large logs
* Perfect for **incident response**, **debugging**, and **exploration**

Equivalent Python solution would take:

* File parsing
* Regex
* Loops
* More complexity

Bash gives us **99% accuracy with 1% effort**, which is exactly what we want in real-world DevOps work.














# : The Shell Environment


## What Is the Shell Environment?

The shell environment can be thought of as a **collection of settings** that define how commands and programs run.

It includes things such as:

* Environment variables
* Aliases
* Configuration files
* Runtime context for programs

Together, these elements define the **context** in which your programs are executed.

In other words, the shell environment influences:

* How commands are found and executed
* Which programs are available
* How programs behave at runtime

---


## Why the PATH Variable Is Important

The `PATH` variable defines **where the shell looks for executable programs**.

This explains common situations such as:

* You install a program, but the command is “not found”
* A program works only when you use its full path
* A different version of a program is executed than expected

Understanding `PATH` is essential for:

* Troubleshooting command execution issues
* Installing and using tools correctly
* Working efficiently in real Linux and DevOps environments

---




### Common (Practical) Definition

In everyday usage, especially in Linux and DevOps, the term **shell** usually means:

> The **command-line interface** (CLI)

This is the text-based interface where we:

* Type commands
* Execute programs
* Manage systems without a graphical interface










# Environment Variables in Bash



## What Are Environment Variables?

Environment variables are used to store **configuration information and settings**.

They influence:

* The shell itself
* The behavior of programs started from the shell

Environment variables are provided by the **operating system** and are inherited by child processes.

By convention:

* Environment variables are written in **UPPERCASE**
* This is only a convention — uppercase letters do not technically make a variable an environment variable

---

## Environment Variables vs Bash Variables (Important Distinction)

There are **two types of variables** in Bash:

### 1. Environment variables

* Provided by the operating system
* Available to child processes
* Typically written in **UPPERCASE**
* Example: `PATH`, `HOME`, `USER`

### 2. Bash (shell) variables

* Exist only inside the shell
* Not automatically inherited by child processes
* Usually written in lowercase or mixed case

We will cover **Bash variables later**, when we start writing shell scripts.
For now, we focus only on **environment variables**.

---

## Listing Environment Variables

To list all environment variables, use:

```bash
env
```

This prints all environment variables currently available in your shell.

You will see variables such as:

* `USER` – current username
* `HOME` – home directory
* `PWD` – current working directory
* `SHELL` – the shell being used
* `PATH` – executable search paths

---

## Accessing an Environment Variable

To access the value of a variable, use:

```bash
echo "${VARIABLE_NAME}"
```

### Example:

```bash
echo "${PWD}"
```

This prints the current working directory.

---

## Why Use `$` and `{}`?

* `$` tells Bash that we want to access a variable
* `{}` clearly define the variable name boundaries

### Recommended syntax:

```bash
echo "${PATH}"
```

### This also works:

```bash
echo $PATH
```

But **using curly braces is safer**.

---

## Why Curly Braces Matter

Consider this example:

```bash
echo "${PATH}_extra"
```

This works as expected.

But without braces:

```bash
echo $PATH_extra
```

Bash will look for a variable named `PATH_extra`, which probably does not exist.

**Best practice:** always use `${}` when expanding variables.

---

## Why Use Double Quotes?

Double quotes prevent Bash from performing **unwanted word splitting and glob expansion**.

Without quotes:

* Special characters could be interpreted
* Output may be modified unexpectedly

### Best practice:

```bash
echo "${PATH}"
```

Avoid:

```bash
echo $PATH
```

We will go deeper into this in the **Shell Expansions** chapter.

---

## Important Environment Variables

### 1. `HOME`

Stores the current user’s home directory.

Examples:

* Linux user: `/home/username`
* Root user: `/root`
* macOS user: `/Users/username`

```bash
echo "${HOME}"
```

This value does **not** change when you change directories.

---

### 2. `PWD`

Stores the current working directory.

```bash
echo "${PWD}"
```

This is equivalent to the `pwd` command.

---

### 3. `OLDPWD`

Stores the previous working directory.

```bash
echo "${OLDPWD}"
```

You can return to it with:

```bash
cd "${OLDPWD}"
```

---

### 4. `USER`

Stores the **Unix username** (not the display name).

```bash
echo "${USER}"
```

Important:

* Unix usernames are lowercase and contain no spaces
* Changing the display name does **not** change the Unix username

---

## Creating an Environment Variable

Use the `export` command:

```bash
export VARIABLE_NAME='value'
```

### Example:

```bash
export CITY='New York'
```

Verify it:

```bash
env | grep CITY
```

---

## Naming Convention (Important)

Environment variables **should always be uppercase**:

✔️ `CITY`
❌ `city`

Bash allows lowercase variables, but using them for environment variables is **bad practice** and can cause confusion.

---

## Overwriting an Environment Variable

You can overwrite an existing variable simply by assigning a new value:

```bash
CITY='NEW YORK'
```

This updates the variable immediately.

⚠️ **No spaces allowed around `=`**

Correct:

```bash
CITY='NEW YORK'
```

Incorrect:

```bash
CITY = 'NEW YORK'
```

Whitespace **changes the meaning** in Bash.

---

## Removing an Environment Variable

Use the `unset` command:

```bash
unset VARIABLE_NAME
```

Example:

```bash
unset city
```

This removes the variable from the environment.

---

## The PATH Environment Variable (Very Important)

`PATH` is one of the most critical environment variables.

It contains a **colon-separated list of directories** that Bash searches for executable programs.

Example:

```bash
echo "${PATH}"
```

Output looks like:

```text
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

---

## How PATH Works

When you run a command like:

```bash
cat test.txt
```

Bash:

1. Looks in the first directory in `PATH`
2. If not found, checks the next directory
3. Continues until it finds an executable named `cat`
4. Executes the first match

Order **matters**.

---

## Executing a Program with Full Path

You can bypass `PATH` by using the full path:

```bash
/bin/cat test.txt
```

This works even if `PATH` is misconfigured.

If the file does not exist:

```bash
/usr/bin/cat test.txt
```

You will get:

```text
No such file or directory
```

---

## Platform Differences (Linux vs macOS)

Executable locations may differ:

* Linux: `/usr/bin/cut`
* macOS: `/bin/cut`

Always verify with:

```bash
which cut
```

---

## Why PATH Matters So Much

Understanding `PATH` explains:

* “command not found” errors
* Why the wrong program version runs
* Why newly installed tools don’t work
* How virtual environments and toolchains work
















#  Why Different Paths Exist (Filesystem & PATH Deep Dive)



## Filesystem Hierarchy Standard (FHS)

Linux and Unix systems follow a standard called the **Filesystem Hierarchy Standard (FHS)**.

It defines:

* **Where files should live**
* **Which directories are essential**
* **Which files must be available during system recovery**


## Single-User Mode (Why Some Paths Must Always Exist)

Linux supports **single-user mode**, a minimal boot mode used for:

* Repairing broken systems
* Fixing misconfigurations
* Recovering from failures

In single-user mode:

* Not all filesystems are mounted
* Only **essential commands** must be available

This is the historical reason **why different binary directories exist**.

---

## Why Do We Have Different Binary Directories?

### `/bin`

* **Essential binaries**
* Must always be available
* Required to boot and repair the system
* Examples: `cat`, `ls`, `cp`, `mv`, `sh`

---

### `/sbin`

* **Essential system binaries**
* Usually executed by `root`
* Used for system administration
* Examples: disk tools, networking tools, boot tools

---

### `/usr/bin`

* **Non-essential user binaries**
* Available to all users
* Historically could be on another disk or network mount
* Most normal commands live here today

---

### `/usr/sbin`

* **Non-essential system binaries**
* Usually executed by `root`
* System administration tools that are not required for recovery

---

### `/usr/local/bin`

* **Non-essential binaries specific to this machine**
* Installed manually or by local package managers
* Should not be shared with other systems

---

### `/usr/local/sbin`

* Same as `/usr/local/bin`, but:
* Typically used for root-level administration tools

---

## Why This Separation Exists

Historically:

* Disks were small
* `/bin` and `/sbin` lived on the root disk
* `/usr` could be mounted later or over the network

Even today:

* This separation helps recovery
* Maintains compatibility
* Keeps system design predictable

---

## Modern Linux: `/usr` Merge

Many modern distributions use **/usr merge**:

* `/bin` → symlink to `/usr/bin`
* `/sbin` → symlink to `/usr/sbin`

This is why:

```bash
/bin/cat
/usr/bin/cat
```

Both work and point to the same executable.

This improves consistency while preserving compatibility.

---

## PATH in Practice

Your `PATH` contains multiple directories:

```bash
echo "${PATH}"
```

Bash searches them **from left to right**.

When you run:

```bash
cat test.txt
```

Bash:

1. Checks each directory in `PATH`
2. Finds the first executable named `cat`
3. Executes it

---

## Running Programs With Full Paths

Instead of relying on `PATH`, you can run a program directly:

```bash
/bin/cat test.txt
```

If the file does not exist:

```bash
/usr/bin/cat test.txt
# No such file or directory
```

---

## Platform Differences (Linux vs macOS)

macOS:

* System directories are **read-only**
* Apple protects `/bin`, `/usr/bin`, `/sbin`
* Third-party tools live in:

  * `/opt/homebrew/bin` (Apple Silicon)
  * `/usr/local/bin` (Intel Macs)

Linux:

* Tools install directly into system paths
* Fewer restrictions

This is why macOS `PATH` is usually **longer**.

---

## Modifying PATH (Temporary)

You can extend `PATH`:

```bash
PATH="${PATH}:/new/directory"
```

Best practice:

* Append user paths **at the end**
* Keep system directories first

---

## Creating Your Own Commands

### Step 1: Create a personal bin directory

```bash
mkdir -p ~/bin
```

### Step 2: Add it to PATH

```bash
PATH="${PATH}:${HOME}/bin"
```

*(Temporary — resets when shell closes)*

---

## Step 3: Create an executable file

```bash
cd ~/bin
touch custom_program
chmod +x custom_program
```

Now you can run it:

```bash
custom_program
```

---

## Creating a Real Program (Python Example)

### Create executable file

```bash
nano hello_world
```

Add content:

```python
#!/usr/bin/env python3
print("Hello world from Python")
```

Make executable:

```bash
chmod +x hello_world
```

Run from anywhere:

```bash
hello_world
```

---

## What Is the Shebang?

```bash
#!/usr/bin/env python3
```

* Must be **first line**
* Tells the OS how to execute the file
* Uses `env` to find `python3` in `PATH`
* Makes scripts portable across systems

---

## Finding Executables

Use:

```bash
which cat
```

Example output:

```bash
/bin/cat
```

This helps debug:

* `command not found`
* Wrong program version
* PATH order issues

---

## PATH Order Matters (Very Important)

Example problem:

* System Python vs Anaconda Python
* Wrong version runs
* Libraries missing
* GPU support not available

Fix:

* Put desired path **earlier** in PATH

---

## PATH Best Practices

✔ Keep system directories first
✔ Add user paths at the end
✔ Avoid duplicate entries
✔ Regularly clean unused paths
✔ Be careful — PATH affects the whole system

---

## Environment Variables Are OS-Level

Environment variables:

* Are provided by the operating system
* Are inherited by child processes
* Are **not** a Bash-only feature

This is why:

* Bash
* Python
* AWS Lambda
* Docker
* Kubernetes

All use **the same concept**.

---

## Environment Variables in Python

### Accessing all variables

```python
import os
print(os.environ)
```

---

### Accessing a single variable

```python
import os
print(os.environ["LOGIN_CONFIG"])
```

---

### Environment Variables Are Copied

When a program starts:

* It receives a **copy** of the environment
* Changes inside the program do **not** affect the parent shell

---

### Example: Temporary override

```bash
LOGIN_CONFIG="localhost:3306" python3 env.py
```

* Only applies to this command
* Shell variable remains unchanged

---

## Why This Matters (Cloud & DevOps)

Cloud platforms (AWS Lambda, ECS, Kubernetes):

* Pass configuration via environment variables
* No hard-coded secrets
* Same code, different environments

Local:

```bash
DB_HOST=localhost
```

Cloud:

```bash
DB_HOST=prod-db.aws.internal
```

**Same application, different behavior.**




















# The `SHELL` Environment Variable (Important Clarification)


## What `SHELL` Actually Means

The `SHELL` environment variable:

* Stores the **path to the user’s default login shell**
* **Does NOT** represent the currently running shell
* Is inherited like any other environment variable

This means:

> Even if you start another shell manually (for example, `bash` inside `zsh`), the value of `SHELL` does **not change**.

---

## Example: Why `SHELL` Is Misleading

```bash
echo "${SHELL}"
```

Output:

```text
/bin/zsh
```

This tells us:

* The operating system’s **default login shell** is `zsh`

Now start a new shell:

```bash
bash
```

Check again:

```bash
echo "${SHELL}"
```

Still:

```text
/bin/zsh
```

Even though you are **now inside bash**, `SHELL` still points to your **login shell**, not the active one.

---

## How to Check the Current Shell (Correct Way)

To check the **currently running shell**, use:

```bash
echo "$0"
```

Or:

```bash
ps -p $$
```

These reflect the active process, not the default login shell.

---

## Changing the Default Login Shell

To change the default shell your OS starts at login, use `chsh`:

```bash
chsh -s /bin/bash
```

Important rules:

* The shell must be listed in `/etc/shells`
* The change may require logging out and logging back in

Check available shells:

```bash
cat /etc/shells
```

---

## Terminal Apps May Override the Default Shell

Some terminal emulators **ignore `chsh`**.

Example:

* macOS Terminal.app respects `chsh`
* Other terminals (e.g., Hyper, VS Code terminal) may always start a specific shell

This behavior depends on the terminal application, not Bash or the OS.

---

## Summary of the `SHELL` Variable

| Fact                     | Meaning             |
| ------------------------ | ------------------- |
| `SHELL`                  | Default login shell |
| Not updated dynamically  | True                |
| Shows current shell      | False               |
| Controlled by OS         | Yes                 |
| Affected by terminal app | Yes                 |

---

# Bash Startup Files (Why So Many?)

Bash has **multiple startup files** because it can start in different modes.

Understanding this is critical for:

* Persistent environment variables
* PATH configuration
* Aliases
* Shell behavior

---

## Bash Startup Modes (Core Concept)

### 1. Interactive Login Shell

* You log in first
* Example:

  * SSH into a server
  * TTY (Ctrl + Alt + F1 on Linux)

### 2. Interactive Non-Login Shell

* Already logged in
* Example:

  * Terminal window in a GUI
  * Running `bash` inside another shell

### 3. Non-Interactive Non-Login Shell

* Executes a script
* Example:

  ```bash
  ./script.sh
  ```

(There is a rare 4th case: non-interactive login shell — usually ignored.)

---

## Which Files Bash Reads (Simplified)

### Interactive **Login** Shell

Reads:

1. `/etc/profile`
2. First existing of:

   * `~/.bash_profile`
   * `~/.bash_login`
   * `~/.profile`

---

### Interactive **Non-Login** Shell

Reads:

* `~/.bashrc`

---

### Non-Interactive Shell

Reads:

* File pointed to by `$BASH_ENV` (if set)

---

## Practical Reality (Modern Best Practice)

Most systems today configure:

```bash
~/.profile  → sources ~/.bashrc
```

This means:

* You only need to edit **`.bashrc`**
* It works for **both login and non-login shells**

This is why modern Linux and macOS setups feel simpler than the theory suggests.

---

## Editing `.bashrc` (Your Main Configuration File)

Open it:

```bash
nano ~/.bashrc
```

This file:

* Contains Bash code
* Runs every time a new interactive shell starts
* Is the correct place for:

  * PATH changes
  * Aliases
  * Environment variables
  * Shell options

---

## Example: Persistent Environment Variable

Add to `~/.bashrc`:

```bash
export TOP_SECRET_TOKEN='top-secret'
```

Important:

* No spaces around `=`
* Use single quotes unless expansion is required

After saving:

* The variable appears **only in new shells**

Reload manually without restarting:

```bash
source ~/.bashrc
```

---

## Making PATH Changes Persistent

Temporary change (lost on restart):

```bash
PATH="${PATH}:${HOME}/bin"
```

Persistent change (add to `.bashrc`):

```bash
export PATH="${PATH}:${HOME}/bin"
```

Now:

* Custom executables in `~/bin` work everywhere
* Survive terminal restarts and reboots

---

# Aliases (Command Shortcuts)

Aliases allow you to:

* Shorten long commands
* Enhance existing commands
* Improve productivity

---

## Creating an Alias

```bash
alias gohome='cd ~'
```

Use it:

```bash
gohome
```

---

## Listing Aliases

```bash
alias
```

---

## Aliases Are Session-Scoped

Aliases:

* Exist only in the current shell
* Disappear in new shells

To make them persistent, add them to `~/.bashrc`.

---

## Example: Useful Aliases

```bash
alias ll='ls --color=auto'
alias gs='git status'
alias gc='git checkout'
```

Aliases:

* Can accept arguments
* Expand before command execution
* Do not recursively expand themselves

---

# Shell Options with `set`

The `set` command configures **shell behavior**.

Syntax:

* Enable: `set -<option>`
* Disable: `set +<option>`

---

## Most Important Option: `set -x` (Debug Mode)

```bash
set -x
```

Effect:

* Prints every command **after expansion**
* Shows aliases, PATH resolution, variable expansion

Example output:

```text
+ ls --color=auto
```

This is invaluable for:

* Debugging scripts
* Understanding alias expansion
* Learning shell internals

Disable:

```bash
set +x
```

---

## Example: Seeing Expansions

```bash
set -x
cd ~/Desktop
```

You will see:

```text
+ cd /home/user/Desktop
```

This shows how `~` expands.

---

## Other `set` Options (Advanced)

Example:

```bash
set -t
```

Meaning:

* Exit shell after executing one command

Rarely used, but useful for special automation cases.

---

## Why `set -x` Matters (DevOps Perspective)

* Reveals what Bash **actually executes**
* Critical for debugging CI/CD scripts
* Helps trace alias, PATH, and expansion issues


















# Configuring the Shell with `shopt` (Shell Options)



## What Is `shopt`?

* `shopt` is a **Bash built-in command**
* It configures **Bash-specific features**
* These options are **not inherited from older shells**
* They only exist in **Bash**

This is why `shopt` exists **in addition to** `set`.

---

## `set` vs `shopt` (Very Important Distinction)

### `set`

* Controls **POSIX / historical shell behavior**
* Options exist for compatibility
* Often inherited by subshells
* Example: `set -x`, `set -e`

### `shopt`

* Controls **Bash-only behavior**
* Modern features
* More ergonomic / interactive features
* Example: `autocd`, `cdspell`

👉 **Rule of thumb**

* `set` → shell-level behavior
* `shopt` → Bash-specific features

---

## Enabling and Disabling `shopt` Options

### Enable an option

```bash
shopt -s option_name
```

### Disable an option

```bash
shopt -u option_name
```

---

## Example 1: `autocd`

### What `autocd` Does

Allows you to change directories **without typing `cd`**.

---

### Default Behavior (autocd OFF)

```bash
Desktop
bash: Desktop: command not found
```

You must use:

```bash
cd Desktop
```

---

### Enable `autocd`

```bash
shopt -s autocd
```

Now you can simply type:

```bash
Desktop
```

And Bash automatically changes into that directory.

---

### Is This Useful?

**Pros**

* Faster navigation
* Less typing

**Cons**

* Ambiguous behavior
* Harder to distinguish between:

  * commands
  * directory names

👉 Personal preference
Many professionals **do not enable `autocd`**.

---

## Example 2: `cdspell`

### What `cdspell` Does

Automatically corrects **minor spelling mistakes** in directory names when using `cd`.

---

### Enable `cdspell`

```bash
shopt -s cdspell
```

Example:

```bash
cd Desktpo
```

Bash corrects it automatically to:

```bash
cd Desktop
```

---

### Disable `cdspell`

```bash
shopt -u cdspell
```

Now:

```bash
cd Desktpo
bash: cd: Desktpo: No such file or directory
```

---

### Should You Use `cdspell`?

**Pros**

* Forgives typos

**Cons**

* Can hide mistakes
* Unexpected directory changes

👉 Many engineers **prefer strict behavior** and keep this disabled.

---

## Viewing Available `shopt` Options

List all options:

```bash
shopt
```

Or see detailed documentation:

```bash
man bash
```

Search for **Shell Builtin Commands → shopt**

---

## Other `shopt` Options (Preview)

Some examples you’ll encounter later:

* `checkjobs` – behavior of background jobs
* `globstar` – enables `**` recursive globbing
* `nullglob` – empty globs expand to nothing
* `extglob` – extended pattern matching

These are **especially useful in Bash scripting**, which is covered later in the course.

---

## Why We Didn’t Cover More Options Yet

Many `shopt` options affect:

* expansions
* globbing
* scripting logic
* background jobs

Those topics come later.

Once you complete the course, **revisiting `shopt` will make much more sense**.

---

## Key Takeaways

* `shopt` configures **Bash-specific behavior**
* `set` configures **shell-level behavior**
* Enable with `shopt -s`
* Disable with `shopt -u`
* Common interactive options:

  * `autocd`
  * `cdspell`
* Use sparingly — preferences differ

---

## Final Summary

| Command    | Purpose                             |
| ---------- | ----------------------------------- |
| `set`      | POSIX / shell compatibility options |
| `shopt`    | Bash-specific features              |
| `shopt -s` | Enable option                       |
| `shopt -u` | Disable option                      |

Together, **`set` and `shopt` give you full control over Bash behavior**.


