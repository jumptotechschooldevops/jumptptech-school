# Lecture 1 · Filesystem & Navigation

## The Linux directory tree

Linux has a single directory tree rooted at `/`. Everything — files, devices, network sockets, processes — is a file or a directory somewhere in this tree.

```
/
├── bin      → essential user binaries (ls, cp, mv)
├── boot     → bootloader and kernel files
├── dev      → device files (disks, terminals, null)
├── etc      → system configuration files
├── home     → user home directories (/home/alice, /home/bob)
├── lib      → shared libraries used by /bin and /sbin
├── media    → mount points for removable media
├── mnt      → temporary mount points
├── opt      → optional third-party software
├── proc     → virtual filesystem: process and kernel info
├── root     → home directory for the root user
├── run      → runtime data (PID files, sockets)
├── sbin     → system binaries (used by root: fdisk, iptables)
├── srv      → data served by the system (www, ftp)
├── sys      → virtual filesystem: kernel and device info
├── tmp      → temporary files (cleared on reboot)
├── usr      → user programs and data
│   ├── bin  → most user commands live here
│   ├── lib  → libraries for /usr/bin
│   └── local → locally compiled software
└── var      → variable data (logs, databases, spool)
    ├── log  → system logs
    └── run  → runtime data (older convention)
```

### Key directories for DevOps work

| Path | What you find there |
|------|-------------------|
| `/etc` | Config files: `/etc/nginx/`, `/etc/ssh/sshd_config`, `/etc/hosts` |
| `/var/log` | System logs: `syslog`, `auth.log`, `kern.log` |
| `/proc` | Live process info: `/proc/1/`, `/proc/meminfo`, `/proc/cpuinfo` |
| `/tmp` | Temporary files. Safe to write, wiped on reboot |
| `/usr/local/bin` | Where you install custom tools and scripts |

---

## Navigation

```bash
pwd           # Print working directory
ls            # List files
ls -la        # Long format, show hidden files
ls -lh        # Human-readable sizes
ls -lt        # Sort by modification time (newest first)
ls -lS        # Sort by size (largest first)

cd /etc       # Absolute path — starts from /
cd nginx      # Relative path — relative to current directory
cd ..         # Go up one level
cd ~          # Go to home directory
cd -          # Go to previous directory (very useful)
```

### Glob patterns

```bash
ls *.log          # Files ending in .log
ls app.{py,js}    # app.py or app.js
ls file[123].txt  # file1.txt, file2.txt, file3.txt
ls /var/log/sys*  # Files starting with sys in /var/log
```

---

## Inodes

Every file and directory has an **inode** — a data structure that stores metadata: permissions, owner, size, timestamps, and pointers to the data blocks on disk. The inode does NOT store the filename. Filenames are stored in directory entries that point to inodes.

```bash
ls -i /etc/hosts    # Show inode number
stat /etc/hosts     # Show all inode metadata
```

This distinction matters because of links.

### Hard links

A hard link is another directory entry pointing to the same inode. The file appears in two places but uses no extra disk space (only the inode + data blocks exist once).

```bash
ln original.txt hardlink.txt
ls -li   # Both files have the same inode number
```

Deleting either name does not delete the data — the data is deleted when the link count reaches zero.

### Symbolic (soft) links

A symbolic link is a file that contains a path to another file. It is like a shortcut.

```bash
ln -s /usr/local/bin/python3.12 /usr/local/bin/python
ls -la /usr/local/bin/python  # Shows → target
```

Unlike hard links, symlinks can cross filesystem boundaries and can point to directories. They break if the target is moved or deleted.

---

## File permissions

Every file has three permission sets and three groups:

```
-rw-r--r--  1  alice  staff  2048  May 18 09:00  config.txt
│└┬┘└┬┘└┬┘  │   │      │
│ │  │  │   │   │      group
│ │  │  │   │   owner
│ │  │  │   link count
│ │  │  permissions for others
│ │  permissions for group
│ permissions for owner
file type (- file, d directory, l symlink)
```

Permission characters:
- `r` (4) — read: view file contents or list directory
- `w` (2) — write: modify file or add/remove files in directory
- `x` (1) — execute: run file as program, or enter directory

### Changing permissions

```bash
# Symbolic notation
chmod u+x script.sh          # add execute for owner
chmod g-w sensitive.conf     # remove write for group
chmod o=r public.txt         # set others to read-only
chmod a+r shared.md          # add read for all

# Octal notation
chmod 644 config.txt    # rw-r--r--  (owner rw, group r, others r)
chmod 755 script.sh     # rwxr-xr-x  (owner rwx, group rx, others rx)
chmod 600 private.key   # rw-------  (owner rw only — for SSH keys)
chmod 700 ~/.ssh        # rwx------  (required for SSH to work)
```

Common octal patterns:

| Octal | Symbolic | Use case |
|-------|----------|----------|
| 644 | rw-r--r-- | Web files, config files |
| 755 | rwxr-xr-x | Scripts, executables, directories |
| 600 | rw------- | Private keys, password files |
| 700 | rwx------ | Private directories |
| 777 | rwxrwxrwx | Never use this in production |

### Changing ownership

```bash
chown alice config.txt           # change owner
chown alice:developers config.txt  # change owner and group
chown -R alice:developers /app   # recursive (-R)
chgrp developers config.txt      # change group only
```

### The execute bit on directories

The `x` bit on a directory means "permission to enter the directory". Without it, you cannot `cd` into it or access files inside it, even if you have read permission. Read without execute lets you list filenames but not access them.

---

## Special permissions

### setuid (s on owner execute bit)

When set on an executable, the program runs as the file's owner, not the user who invoked it.

```bash
ls -la /usr/bin/passwd
# -rwsr-xr-x  root  root  ...
```

`passwd` has setuid root. That is why a normal user can change their own password — the program runs as root for the duration of the call.

### Sticky bit (t on others execute bit)

When set on a directory, only the file owner or root can delete files in that directory, even if others have write permission.

```bash
ls -la /tmp
# drwxrwxrwt  ...  /tmp
```

The `t` on `/tmp` means anyone can create files there, but you cannot delete someone else's files.

---

## Finding files

`find` is one of the most useful commands in Linux:

```bash
# Find by name
find /etc -name "*.conf"
find /home -name ".env" -type f

# Find by type
find /var/log -type f -name "*.log"
find /etc -type d -name "nginx"

# Find by size
find /var -size +100M        # larger than 100 MB
find /tmp -size -1k          # smaller than 1 KB

# Find by age
find /var/log -mtime +7      # modified more than 7 days ago
find /tmp -mtime -1          # modified in the last 24 hours

# Find and run a command on each result
find /tmp -name "*.tmp" -exec rm {} \;
find /app -name "*.py" -exec grep -l "import os" {} \;

# Find and show disk usage
find /var/log -name "*.log" -exec du -sh {} \;
```

---

## Summary

- Linux has a single directory tree rooted at `/`. Know the key directories.
- Inodes store metadata. Hard links share inodes; symlinks store paths.
- Permissions are three groups of three bits: owner, group, others × read, write, execute.
- Common octal patterns: 644 for files, 755 for scripts, 600 for secrets.
- `find` is how you locate files by name, type, size, or age. Learn `-exec`.
