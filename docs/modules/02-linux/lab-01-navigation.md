# Lab 1 · Navigation & Permissions

**Duration:** ~60 minutes  
**Goal:** Get confident navigating the Linux filesystem, reading and setting permissions, managing users and groups.

---

## Part 1 — Exploring the filesystem

### 1.1 System information

```bash
# Who are you and where are you?
whoami
id
pwd
hostname

# What Linux version?
uname -a
cat /etc/os-release
```

Write down your UID and GID — you will need them shortly.

### 1.2 Navigate key directories

Explore each of these locations. For each one, look at the contents and understand what lives there:

```bash
ls -la /
ls -la /etc | head -30
ls -la /var/log
ls -la /proc | head -20
ls -la /dev | head -20
```

**Questions to answer:**

1. How many files are in `/etc` that end in `.conf`?
   ```bash
   ls /etc/*.conf | wc -l
   ```

2. What is the most recently modified file in `/var/log`?
   ```bash
   ls -lt /var/log | head -5
   ```

3. What is in `/proc/version`?
   ```bash
   cat /proc/version
   ```

4. Find out how much memory your system has:
   ```bash
   cat /proc/meminfo | grep MemTotal
   ```

### 1.3 The find command

```bash
# Find all .conf files under /etc
find /etc -name "*.conf" -type f

# Count them
find /etc -name "*.conf" -type f | wc -l

# Find files modified in the last hour
find /var/log -mmin -60 -type f

# Find files larger than 1MB in /var/log
find /var/log -size +1M -type f -exec ls -lh {} \;

# Find directories with world-write permission (potential security issue)
find /etc -perm -o+w -type f 2>/dev/null
```

---

## Part 2 — Working with permissions

### 2.1 Create a test environment

```bash
mkdir -p ~/permissions-lab
cd ~/permissions-lab

# Create some test files
touch public.txt secret.key script.sh directory-test/
mkdir directory-test
echo "public content" > public.txt
echo "SECRET_KEY=abc123" > secret.key
echo '#!/bin/bash\necho "Hello from script"' > script.sh
```

### 2.2 Read permissions

```bash
ls -la ~/permissions-lab/
```

Note the permissions on each file. They will likely all be `644` for files and `755` for the directory. Why? Because of the **umask**.

```bash
umask
```

The umask subtracts permissions from the default (666 for files, 777 for dirs). A umask of `022` means: remove write from group and others. So files get `644`, directories get `755`.

### 2.3 Set correct permissions

Apply appropriate permissions for each file's purpose:

```bash
# Public file — everyone can read
chmod 644 public.txt
ls -la public.txt
# -rw-r--r--

# Secret file — only owner can read/write, no one else
chmod 600 secret.key
ls -la secret.key
# -rw-------

# Script — owner can execute, others can read and execute
chmod 755 script.sh
ls -la script.sh
# -rwxr-xr-x

# Try to run the script
./script.sh
```

### 2.4 Directory permissions explained

```bash
# Restrictive directory — only owner can enter and list
chmod 700 directory-test
ls -la directory-test   # you can still see it listed here (parent dir permission)
cd directory-test       # you can enter (you're the owner)
cd ..

# Now switch to another user to test
# (If you don't have another user, skip to 2.5 and create one first)
```

### 2.5 Create a test user and group

```bash
# These commands require sudo
sudo groupadd devteam

sudo useradd -m -s /bin/bash -G devteam testuser
sudo passwd testuser   # set a password

# Verify
id testuser
cat /etc/passwd | grep testuser
cat /etc/group | grep devteam
```

### 2.6 Test ownership and access

```bash
# Create a file owned by root:devteam with group permissions
sudo touch /tmp/devteam-config.txt
sudo chown root:devteam /tmp/devteam-config.txt
sudo chmod 660 /tmp/devteam-config.txt
ls -la /tmp/devteam-config.txt
# -rw-rw---- root devteam

# Can testuser (who is in devteam) read it?
sudo -u testuser cat /tmp/devteam-config.txt    # no content, but should succeed
sudo -u testuser bash -c "echo test > /tmp/devteam-config.txt"  # should succeed

# Can a non-group user read it?
# Create another user not in devteam
sudo useradd -m outsider
sudo -u outsider cat /tmp/devteam-config.txt   # should fail: Permission denied
```

---

## Part 3 — Working with links

### 3.1 Hard links

```bash
cd ~/permissions-lab

echo "Original content" > original.txt
ls -li original.txt     # note the inode number

# Create a hard link
ln original.txt hardlink.txt
ls -li original.txt hardlink.txt   # same inode number!

# Modify through either name
echo "Modified" >> hardlink.txt
cat original.txt   # change visible through original name

# Check link count
stat original.txt | grep Links
# Links: 2

# Delete one name — the other still works
rm hardlink.txt
ls -li original.txt
stat original.txt | grep Links
# Links: 1   (data still there, just one name now)
```

### 3.2 Symbolic links

```bash
# Create a symlink
ln -s /etc/hosts hosts-link
ls -la hosts-link   # shows: hosts-link -> /etc/hosts

# Follow the link
cat hosts-link   # reads /etc/hosts

# See where it points
readlink hosts-link
readlink -f hosts-link   # absolute canonical path

# Create a broken symlink (target doesn't exist)
ln -s /nonexistent broken-link
ls -la broken-link   # listed, but in red on most terminals
cat broken-link      # No such file or directory

# Practical use: versioned binaries
sudo ln -s /usr/bin/python3.12 /usr/local/bin/python
python --version
```

---

## Part 4 — Finding and fixing problems

### 4.1 Find world-writable files

World-writable files (writable by anyone) are a security concern:

```bash
# Create one intentionally
echo "test" > ~/permissions-lab/bad-permissions.txt
chmod 777 ~/permissions-lab/bad-permissions.txt

# Find world-writable files in your home directory
find ~ -perm -o+w -type f 2>/dev/null

# Fix all of them
find ~ -perm -o+w -type f 2>/dev/null -exec chmod o-w {} \;

# Verify
find ~ -perm -o+w -type f 2>/dev/null   # should be empty
```

### 4.2 Find files with no owner (orphaned inodes)

```bash
# Find files not owned by any user
find /tmp -nouser 2>/dev/null
find /tmp -nogroup 2>/dev/null
```

These appear when a user is deleted without removing their files. The inode keeps the UID, but the UID no longer maps to a username.

### 4.3 Find and clean up large old log files

```bash
# Find log files larger than 10MB
sudo find /var/log -name "*.log" -size +10M -type f

# Find old log files (older than 30 days)
sudo find /var/log -name "*.log" -mtime +30 -type f

# See total disk usage in /var/log
sudo du -sh /var/log

# In production, log rotation (logrotate) handles this automatically
# Check the logrotate config:
cat /etc/logrotate.conf
ls /etc/logrotate.d/
```

---

## Checkpoint

Before finishing, verify you can answer these questions:

1. What command shows a file's inode number?
2. What octal permission means "owner can read/write, nobody else"?
3. What does the sticky bit on `/tmp` do?
4. How do you find all `.env` files recursively under `/home`?
5. What is the difference between `chown` and `chmod`?

```bash
# Quick permission reference test
stat -c "%a %n" ~/permissions-lab/*
```

---

## Cleanup

```bash
# Remove test users if you created them
sudo userdel -r testuser
sudo userdel -r outsider
sudo groupdel devteam

# Remove lab files
rm -rf ~/permissions-lab
```
