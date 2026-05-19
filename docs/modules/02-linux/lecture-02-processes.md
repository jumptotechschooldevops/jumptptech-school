# Lecture 2 · Processes & Services

## What is a process

A process is a running program. When you run `ls`, the kernel creates a process, loads the `ls` binary, executes it, and destroys the process when it finishes. Every process has:

- A **PID** (process ID) — a unique integer
- A **PPID** (parent process ID) — every process except PID 1 has a parent
- An owner (the user who started it)
- Open file descriptors (stdin, stdout, stderr, and any files or sockets)
- Memory mappings
- A state: running, sleeping, stopped, or zombie

The first process is PID 1 — on modern Linux systems, this is `systemd`. Every other process is a descendant of PID 1.

---

## Viewing processes

### ps

```bash
ps              # Your processes in the current shell
ps aux          # All processes, all users, with details
ps aux | grep nginx    # Filter by name

# BSD-style options (no dash) — most portable
ps aux

# Fields in ps aux output:
# USER    PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root      1   0.0  0.1 168940  9876 ?        Ss   09:00   0:01 /sbin/init
```

`STAT` codes:

| Code | Meaning |
|------|---------|
| `R` | Running |
| `S` | Sleeping (interruptible) |
| `D` | Sleeping (uninterruptible, usually I/O) |
| `T` | Stopped |
| `Z` | Zombie |
| `s` | Session leader |
| `+` | Foreground process group |

### Process tree

```bash
pstree          # Show process hierarchy as a tree
pstree -p       # Include PIDs
pstree -u       # Include usernames
```

### top and htop

```bash
top             # Live process monitor — press q to quit
htop            # Better interactive monitor (install: apt install htop)
```

In `top`:
- `M` — sort by memory
- `P` — sort by CPU
- `k` — kill a process (enter PID)
- `1` — toggle per-CPU view

---

## Signals

Signals are a way to communicate with processes. You send them with `kill` (misleading name — it sends signals, not just kills).

```bash
kill -l         # List all signals

# Most important signals:
# SIGHUP  (1)  — reload config (many daemons handle this)
# SIGINT  (2)  — interrupt (what Ctrl+C sends)
# SIGTERM (15) — polite termination request (default kill signal)
# SIGKILL (9)  — force kill, cannot be caught or ignored

kill <PID>          # Send SIGTERM (give process a chance to clean up)
kill -9 <PID>       # Send SIGKILL (last resort — no cleanup)
kill -HUP <PID>     # Send SIGHUP (often triggers config reload)

killall nginx       # Kill all processes named nginx
pkill -f "python app.py"   # Kill by full command line match
```

Always try `SIGTERM` first. Give the process a few seconds. If it does not stop, then use `SIGKILL`. A SIGKILL does not allow the process to close files cleanly, flush buffers, or release locks.

---

## Foreground and background

```bash
# Run a command in the background
sleep 100 &
# [1] 12345   — job number and PID

# List background jobs
jobs

# Bring job 1 to the foreground
fg %1

# Send foreground job to background
# Press Ctrl+Z to suspend it, then:
bg %1

# Detach completely (process survives shell exit)
nohup long-script.sh > output.log 2>&1 &
```

For long-running processes that need to survive after you log out, use `tmux` or `screen` rather than `nohup`:

```bash
tmux new -s mysession   # create named session
# run your command
# Ctrl+B, D to detach
tmux attach -t mysession  # re-attach later
```

---

## Viewing open files and connections

### lsof

`lsof` lists open files. Since everything in Linux is a file, this includes network connections, sockets, and pipes.

```bash
lsof             # All open files (output is enormous)
lsof -u alice    # Files opened by user alice
lsof -p 1234     # Files opened by PID 1234
lsof /var/log    # Processes with files open in /var/log
lsof -i          # Network connections
lsof -i :80      # Processes listening on port 80
lsof -i tcp:443  # TCP connections on port 443
```

### Checking ports

```bash
# What is listening on port 80?
ss -tlnp | grep :80

# All listening TCP ports
ss -tlnp

# All established TCP connections
ss -tnp state established

# Older equivalent (still common)
netstat -tlnp
```

`ss` flags: `-t` TCP, `-u` UDP, `-l` listening, `-n` numeric, `-p` show process.

---

## systemd

`systemd` is PID 1. It is responsible for:
- Starting and stopping all system services
- Managing service dependencies (start the database before the app)
- Restarting services that crash
- Collecting logs via journald

### Unit files

Every service managed by systemd has a **unit file** — typically in `/etc/systemd/system/` (custom) or `/lib/systemd/system/` (installed by packages).

A minimal unit file:

```ini
[Unit]
Description=My web application
After=network.target

[Service]
Type=simple
User=www
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Managing services

```bash
# Start / stop / restart
systemctl start nginx
systemctl stop nginx
systemctl restart nginx

# Reload config without full restart (if the service supports it)
systemctl reload nginx

# Check status — most useful command
systemctl status nginx

# Enable / disable at boot
systemctl enable nginx    # start automatically on boot
systemctl disable nginx   # do not start at boot

# Check if enabled
systemctl is-enabled nginx
systemctl is-active nginx

# List all units
systemctl list-units
systemctl list-units --type=service
systemctl list-units --state=failed
```

### Reading logs with journald

```bash
# Logs for a specific service
journalctl -u nginx

# Follow live logs (like tail -f)
journalctl -u nginx -f

# Logs since last boot
journalctl -u nginx -b

# Logs since a specific time
journalctl -u nginx --since "2026-05-18 10:00:00"

# Last 100 lines
journalctl -u nginx -n 100

# All logs since last boot
journalctl -b

# Kernel messages (like dmesg)
journalctl -k
```

---

## Resource monitoring

```bash
# Memory usage
free -h             # Human-readable
cat /proc/meminfo   # Raw kernel data

# Disk usage
df -h               # Filesystem usage
du -sh /var/log/*   # Size of each item in /var/log
du -sh * | sort -h  # Sort by size

# CPU info
nproc               # Number of CPU cores
cat /proc/cpuinfo   # Full CPU details
uptime              # Load averages (1m, 5m, 15m)
```

Load average is the number of processes waiting for CPU time (ready to run but not scheduled). A load of 1.0 on a single-core machine means the CPU is fully utilised. On a 4-core machine, a load of 4.0 is 100% utilisation. Above that, processes are queuing.

---

## Summary

- Every process has a PID, PPID, owner, and state. PID 1 is systemd.
- `ps aux` shows all processes. `top`/`htop` are interactive monitors.
- Signals let you communicate with processes. Try SIGTERM before SIGKILL.
- `lsof -i` and `ss -tlnp` show network connections and listening ports.
- systemd manages services via unit files. `systemctl status` is your first stop when something is wrong.
- `journalctl -u <service> -f` streams live logs from any systemd service.
