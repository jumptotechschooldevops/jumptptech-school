# Lab 2 · Processes & systemd

**Duration:** ~60 minutes  
**Goal:** Monitor running processes, manage signals, control systemd services, and write a unit file.

---

## Part 1 — Exploring processes

### 1.1 The process tree

```bash
# View all processes in a tree
pstree -p

# How many processes are running?
ps aux | wc -l

# Who is PID 1?
ps -p 1 -o comm=
cat /proc/1/cmdline | tr '\0' ' '
```

### 1.2 Finding specific processes

```bash
# Find the process for your current shell
echo $$   # prints the PID of the current shell
ps -p $$

# Find all bash processes
pgrep bash
pgrep -a bash   # include full command

# Find your current shell's parent (the terminal emulator or sshd)
ps -p $PPID
```

### 1.3 What resources is a process using?

```bash
# Get PID of something interesting
nginx_pid=$(pgrep nginx | head -1)
# If nginx is not installed: sudo apt install nginx -y

echo "nginx PID: $nginx_pid"

# Open files
lsof -p $nginx_pid | head -20

# Memory map
pmap $nginx_pid | tail -5

# From /proc
cat /proc/$nginx_pid/status | grep -E "Name|Pid|VmRSS|Threads"
ls /proc/$nginx_pid/fd | wc -l   # number of open file descriptors
```

---

## Part 2 — Signals

### 2.1 Start a long-running process

```bash
# Start a sleep process in the background
sleep 300 &
sleep_pid=$!
echo "sleep PID: $sleep_pid"

# Verify it is running
ps -p $sleep_pid
```

### 2.2 Send signals

```bash
# Send SIGSTOP — pause the process (like pressing pause)
kill -STOP $sleep_pid
ps -p $sleep_pid   # STAT will show T (stopped)

# Send SIGCONT — resume
kill -CONT $sleep_pid
ps -p $sleep_pid   # STAT back to S

# Send SIGTERM — polite termination
kill $sleep_pid   # SIGTERM is the default
ps -p $sleep_pid  # process is gone
```

### 2.3 Signals in the terminal

```bash
# Start a continuous process
ping localhost &
ping_pid=$!

# Ctrl+C sends SIGINT — kill it politely from the terminal
# (if running in foreground, just press Ctrl+C)
kill -INT $ping_pid

# Now start something that ignores SIGTERM
cat <<'EOF' > /tmp/stubborn.sh
#!/bin/bash
trap 'echo "Got SIGTERM, ignoring it..."' TERM
echo "Running. PID: $$"
while true; do sleep 1; done
EOF
chmod +x /tmp/stubborn.sh

/tmp/stubborn.sh &
stubborn_pid=$!
sleep 1

kill $stubborn_pid        # SIGTERM — it ignores
sleep 1
kill -9 $stubborn_pid     # SIGKILL — cannot be ignored
ps -p $stubborn_pid 2>&1  # should show "no process"
```

### 2.4 Finding and killing by name

```bash
# Start multiple sleep processes
sleep 1000 &
sleep 1000 &
sleep 1000 &

# Find them
pgrep sleep
ps aux | grep sleep

# Kill all of them
pkill sleep
ps aux | grep sleep   # gone
```

---

## Part 3 — systemd services

Make sure nginx is installed for this part:

```bash
sudo apt update && sudo apt install -y nginx
```

### 3.1 Inspect an existing service

```bash
# Check status
systemctl status nginx

# What does the unit file look like?
systemctl cat nginx

# What are its dependencies?
systemctl list-dependencies nginx

# What comes after nginx in startup order?
systemctl list-dependencies nginx --after
```

### 3.2 Start, stop, restart

```bash
# Stop nginx
sudo systemctl stop nginx
systemctl status nginx   # should show "inactive (dead)"

# Start it
sudo systemctl start nginx
systemctl status nginx   # should show "active (running)"

# Check it actually serves HTTP
curl -s http://localhost | grep -o "<title>.*</title>"

# Restart
sudo systemctl restart nginx
# vs.
sudo systemctl reload nginx   # reload config without dropping connections
```

### 3.3 Enable/disable at boot

```bash
# Check if enabled
systemctl is-enabled nginx

# Enable (create symlink in /etc/systemd/system/multi-user.target.wants/)
sudo systemctl enable nginx
ls -la /etc/systemd/system/multi-user.target.wants/nginx.service

# Disable
sudo systemctl disable nginx
ls /etc/systemd/system/multi-user.target.wants/nginx.service 2>&1  # gone
```

### 3.4 Reading logs

```bash
# Last 20 lines
journalctl -u nginx -n 20

# Live stream
sudo journalctl -u nginx -f &
journal_pid=$!

# Cause a log entry
sudo systemctl reload nginx

# Stop the live stream
kill $journal_pid

# Filter by time
journalctl -u nginx --since "1 minute ago"

# Full logs since last boot
journalctl -u nginx -b
```

---

## Part 4 — Write your own unit file

You will create a simple Python HTTP server and run it as a systemd service.

### 4.1 Create the application

```bash
sudo mkdir -p /opt/labserver
sudo tee /opt/labserver/server.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import datetime

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = json.dumps({
                "status": "ok",
                "pid": os.getpid(),
                "time": datetime.datetime.utcnow().isoformat()
            }).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")

    def log_message(self, format, *args):
        print(format % args, flush=True)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 9090))
    server = HTTPServer(("0.0.0.0", port), HealthHandler)
    print(f"Listening on port {port}")
    server.serve_forever()
EOF

sudo chmod 755 /opt/labserver/server.py

# Test it manually first
python3 /opt/labserver/server.py &
server_pid=$!
sleep 1
curl http://localhost:9090/health
kill $server_pid
```

### 4.2 Create the unit file

```bash
sudo tee /etc/systemd/system/labserver.service << 'EOF'
[Unit]
Description=JumptpTech Lab HTTP Server
Documentation=https://jumptptech.school/modules/02-linux/
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
WorkingDirectory=/opt/labserver
ExecStart=/usr/bin/python3 /opt/labserver/server.py
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=PORT=9090

# Security hardening
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/tmp

[Install]
WantedBy=multi-user.target
EOF
```

### 4.3 Enable and start the service

```bash
# Reload systemd to pick up the new file
sudo systemctl daemon-reload

# Check the unit file is valid
systemctl cat labserver

# Enable and start
sudo systemctl enable labserver
sudo systemctl start labserver

# Verify
systemctl status labserver
curl http://localhost:9090/health | python3 -m json.tool
```

You should see output like:
```json
{
    "status": "ok",
    "pid": 12345,
    "time": "2026-05-18T10:00:00"
}
```

### 4.4 Test failure recovery

```bash
# Find the PID of the server process
server_pid=$(systemctl show labserver -p MainPID --value)
echo "Server PID: $server_pid"

# Kill it abruptly (simulating a crash)
sudo kill -9 $server_pid

# Watch systemd restart it
sleep 6
systemctl status labserver   # should show restarted

new_pid=$(systemctl show labserver -p MainPID --value)
echo "New server PID: $new_pid"   # different from before

# Check the journal for the restart event
journalctl -u labserver --since "1 minute ago"
```

### 4.5 Read service logs

```bash
# Stream live logs in another terminal (or background)
journalctl -u labserver -f &
journal_pid=$!

# Generate some requests
for i in $(seq 1 5); do
    curl -s http://localhost:9090/health > /dev/null
done

sleep 1
kill $journal_pid
```

---

## Cleanup

```bash
sudo systemctl stop labserver
sudo systemctl disable labserver
sudo rm /etc/systemd/system/labserver.service
sudo systemctl daemon-reload
sudo rm -rf /opt/labserver
```

---

## Challenge

Extend the unit file with a `[Timer]` to run a script every 5 minutes. systemd timers are a modern alternative to cron:

```ini
# /etc/systemd/system/health-check.service
[Unit]
Description=Health check script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/health-check.sh

# /etc/systemd/system/health-check.timer
[Unit]
Description=Run health check every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=health-check.service

[Install]
WantedBy=timers.target
```

Activate it with `systemctl enable --now health-check.timer` and monitor with `systemctl list-timers`.
