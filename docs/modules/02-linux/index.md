# Module 02 · Linux

Linux is the operating system that runs the internet. Every web server, container host, Kubernetes node, and cloud VM you will ever work with runs Linux. Being slow or unsure on the command line will slow you down at every step of your DevOps career.

This module covers the Linux skills that come up daily: navigating the filesystem, understanding permissions, managing processes, working with systemd services, and writing shell scripts that actually get used.

## What you will cover

**Lecture 1 — Filesystem & Navigation**
The Linux directory tree, inodes, hard and soft links, permissions (rwx and octal), file ownership, and `find`.

**Lecture 2 — Processes & Services**
What a process is, signals, `ps`, `top`, `htop`, `lsof`, systemd service management.

**Lecture 3 — Shell Scripting**
Variables, conditionals, loops, functions, error handling, and script patterns you will actually use.

**Lab 1 — Navigation & Permissions**
Explore the filesystem, set permissions correctly, manage users and groups.

**Lab 2 — Processes & systemd**
Monitor processes, manage services, write a basic unit file.

**Lab 3 — Scripting**
Write scripts that automate real DevOps tasks.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 50 min |
| Lecture 2 | 45 min |
| Lecture 3 | 60 min |
| Lab 1 | 60 min |
| Lab 2 | 60 min |
| Lab 3 | 90 min |

## Setup

You need a Linux environment. Options:

- A Linux VM (Ubuntu 22.04 LTS recommended) via VirtualBox, VMware, or UTM
- WSL2 on Windows with Ubuntu
- An AWS EC2 instance (t2.micro is free tier)
- Any macOS with Homebrew (`brew install coreutils` for GNU tools)

All examples in this module use Ubuntu 22.04 unless noted.
