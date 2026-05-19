# Lab 3 · Shell Scripting

**Duration:** ~90 minutes  
**Goal:** Write practical shell scripts that solve real DevOps problems. No toy examples.

---

## Setup

```bash
mkdir -p ~/scripting-lab
cd ~/scripting-lab
```

Install ShellCheck for static analysis:

```bash
sudo apt install -y shellcheck   # Ubuntu/Debian
# brew install shellcheck         # macOS
```

---

## Script 1 — System health report

Write a script that produces a concise health report of the local system. Something you would run on a server and paste into a ticket.

### Create the script

```bash
cat > health-report.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

# Produce a brief system health report

SEPARATOR="$(printf '=%.0s' {1..60})"

section() {
    echo ""
    echo "$SEPARATOR"
    echo "  $1"
    echo "$SEPARATOR"
}

section "SYSTEM"
echo "Hostname:   $(hostname -f)"
echo "OS:         $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "Kernel:     $(uname -r)"
echo "Uptime:     $(uptime -p)"
echo "Date:       $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

section "CPU"
echo "Cores:      $(nproc)"
echo "Load (1m):  $(awk '{print $1}' /proc/loadavg)"
echo "Load (5m):  $(awk '{print $2}' /proc/loadavg)"
echo "Load (15m): $(awk '{print $3}' /proc/loadavg)"

section "MEMORY"
free -h | awk '
    /^Mem:/ {printf "Total:      %s\nUsed:       %s\nFree:       %s\nAvailable:  %s\n", $2, $3, $4, $7}
    /^Swap:/ {printf "Swap Used:  %s / %s\n", $3, $2}
'

section "DISK"
df -h --output=source,size,used,avail,pcent,target | grep -v tmpfs | column -t

section "TOP PROCESSES (by CPU)"
ps aux --sort=-%cpu | head -6 | awk '{printf "%-10s %5s %5s %s\n", $1, $3, $4, $11}'

section "LISTENING PORTS"
ss -tlnp | awk 'NR>1 {print $4, $6}' | column -t

section "RECENT FAILED SERVICES"
systemctl list-units --state=failed --no-legend 2>/dev/null | head -10 \
    || echo "No failed units"

echo ""
SCRIPT

chmod +x health-report.sh
```

### Run and verify

```bash
./health-report.sh
shellcheck health-report.sh
```

Fix any ShellCheck warnings before moving on.

---

## Script 2 — Log file analyser

Write a script that takes a log file path and reports the most common errors, warning counts, and unusual patterns.

```bash
cat > analyse-logs.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

LOGFILE="${1:-}"
LINES="${2:-1000}"

usage() {
    echo "Usage: $0 <logfile> [lines]" >&2
    echo "  logfile  Path to the log file to analyse" >&2
    echo "  lines    Number of recent lines to analyse (default: 1000)" >&2
    exit 1
}

if [[ -z "$LOGFILE" ]]; then
    usage
fi

if [[ ! -f "$LOGFILE" ]]; then
    echo "ERROR: File not found: $LOGFILE" >&2
    exit 1
fi

if [[ ! -r "$LOGFILE" ]]; then
    echo "ERROR: Cannot read file: $LOGFILE" >&2
    exit 1
fi

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Get the last N lines
tail -n "$LINES" "$LOGFILE" > "$TMPFILE"

total_lines=$(wc -l < "$TMPFILE")
error_count=$(grep -ciE '\b(error|err|fatal|critical|crit)\b' "$TMPFILE" || true)
warn_count=$(grep -ciE '\b(warn|warning)\b' "$TMPFILE" || true)
info_count=$(grep -ciE '\binfo\b' "$TMPFILE" || true)

echo "=== Log Analysis: $LOGFILE ==="
echo "Lines analysed: $total_lines (last $LINES)"
echo ""
echo "Level counts:"
echo "  ERROR/FATAL : $error_count"
echo "  WARNING     : $warn_count"
echo "  INFO        : $info_count"
echo ""

echo "Top 10 most frequent errors:"
grep -iE '\b(error|fatal|critical)\b' "$TMPFILE" 2>/dev/null \
    | sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9:.-]*//g' \
    | sed 's/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/IP/g' \
    | sort | uniq -c | sort -rn | head -10 \
    | awk '{$1=$1; printf "  %4d | %s\n", $1, substr($0, index($0,$2))}' \
    || echo "  (no errors found)"

echo ""
echo "Activity by hour (last 24h):"
grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}' "$TMPFILE" 2>/dev/null \
    | cut -d: -f1 | sort | uniq -c \
    | awk '{printf "  %s:00 — %4d entries\n", $2, $1}' \
    | tail -24 \
    || echo "  (no timestamps found)"
SCRIPT

chmod +x analyse-logs.sh
```

### Test it

```bash
# Generate a sample log file
cat > /tmp/sample.log << 'EOF'
2026-05-18T09:00:01 INFO  Server started on port 8080
2026-05-18T09:01:15 INFO  Request: GET /api/users 200 45ms
2026-05-18T09:01:22 ERROR Connection to database timed out after 30s
2026-05-18T09:01:22 ERROR Retrying database connection (1/3)
2026-05-18T09:01:27 ERROR Retrying database connection (2/3)
2026-05-18T09:01:32 INFO  Database connection established
2026-05-18T09:05:00 WARN  Memory usage above 80%: 82%
2026-05-18T09:10:00 ERROR Connection to database timed out after 30s
2026-05-18T09:10:00 ERROR Retrying database connection (1/3)
2026-05-18T10:00:00 INFO  Scheduled job started: cleanup
2026-05-18T10:00:15 INFO  Scheduled job finished: cleanup (deleted 142 records)
2026-05-18T10:30:00 WARN  Certificate expires in 14 days
EOF

./analyse-logs.sh /tmp/sample.log

# Also run on a real log
./analyse-logs.sh /var/log/syslog 500
```

```bash
shellcheck analyse-logs.sh
```

---

## Script 3 — Service check and auto-restart

Write a script that checks if a list of services are running and restarts any that have stopped. This is the kind of script that lives in a cron job on systems where you do not have proper orchestration.

```bash
cat > service-watchdog.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

# Services to monitor — customise this list
SERVICES=(nginx ssh cron)
LOG="/var/log/service-watchdog.log"

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG"
}

check_and_restart() {
    local service="$1"

    if systemctl is-active --quiet "$service"; then
        log INFO "$service is running"
    else
        log WARN "$service is NOT running — attempting restart"

        if sudo systemctl start "$service" 2>&1 | tee -a "$LOG"; then
            log INFO "$service restarted successfully"
        else
            log ERROR "Failed to restart $service"
            # In a real setup: send alert here
            # curl -X POST "$PAGERDUTY_URL" -d "{\"service\": \"$service\"}"
        fi
    fi
}

main() {
    log INFO "=== Watchdog check started ==="

    for service in "${SERVICES[@]}"; do
        if systemctl list-units --type=service | grep -q "^  ${service}.service"; then
            check_and_restart "$service"
        else
            log WARN "Service unit not found: $service"
        fi
    done

    log INFO "=== Watchdog check complete ==="
}

main
SCRIPT

chmod +x service-watchdog.sh

# Test it (requires sudo for restarting services)
./service-watchdog.sh

shellcheck service-watchdog.sh
```

---

## Script 4 — Deployment helper

Write a script that mimics a simple deployment: backs up the current version, copies new files, restarts the service, and rolls back if the service fails to start.

```bash
cat > deploy.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/labserver}"
SERVICE_NAME="${SERVICE_NAME:-labserver}"
BACKUP_DIR="/var/backups/labserver"
MAX_BACKUPS=5

log() {
    echo "[$(date +%H:%M:%S)] $*"
}

error() {
    echo "[$(date +%H:%M:%S)] ERROR: $*" >&2
}

backup_current() {
    if [[ ! -d "$DEPLOY_DIR" ]]; then
        log "No existing deployment to back up"
        return 0
    fi

    local backup_name
    backup_name="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$DEPLOY_DIR" "$backup_name"
    log "Backed up to: $backup_name"

    # Prune old backups — keep only MAX_BACKUPS
    local count
    count=$(ls "$BACKUP_DIR" | wc -l)
    if [[ $count -gt $MAX_BACKUPS ]]; then
        ls -t "$BACKUP_DIR" | tail -n +$((MAX_BACKUPS + 1)) | while read -r old; do
            log "Removing old backup: $old"
            rm -rf "$BACKUP_DIR/$old"
        done
    fi
}

deploy_files() {
    local source_dir="$1"
    log "Deploying from: $source_dir"
    sudo cp -r "$source_dir/." "$DEPLOY_DIR/"
    sudo chown -R nobody:nogroup "$DEPLOY_DIR"
    log "Files deployed"
}

restart_service() {
    log "Restarting $SERVICE_NAME..."
    sudo systemctl restart "$SERVICE_NAME"
    sleep 3
}

check_health() {
    local port="${1:-9090}"
    local attempts=10
    local wait=2

    for ((i = 1; i <= attempts; i++)); do
        if curl -sf "http://localhost:$port/health" > /dev/null 2>&1; then
            log "Health check passed"
            return 0
        fi
        log "Health check failed ($i/$attempts). Waiting ${wait}s..."
        sleep "$wait"
    done

    error "Health check failed after $attempts attempts"
    return 1
}

rollback() {
    local latest_backup
    latest_backup=$(ls -t "$BACKUP_DIR" | head -1)

    if [[ -z "$latest_backup" ]]; then
        error "No backup available for rollback"
        return 1
    fi

    log "Rolling back to: $latest_backup"
    sudo cp -r "$BACKUP_DIR/$latest_backup/." "$DEPLOY_DIR/"
    sudo systemctl restart "$SERVICE_NAME"
    sleep 3

    if check_health; then
        log "Rollback successful"
    else
        error "Rollback health check also failed — manual intervention required"
        return 1
    fi
}

main() {
    local source_dir="${1:-}"

    if [[ -z "$source_dir" ]]; then
        echo "Usage: $0 <source_directory>" >&2
        exit 1
    fi

    if [[ ! -d "$source_dir" ]]; then
        error "Source directory not found: $source_dir"
        exit 1
    fi

    log "=== Starting deployment ==="
    backup_current
    deploy_files "$source_dir"
    restart_service

    if check_health; then
        log "=== Deployment successful ==="
    else
        error "Deployment health check failed — rolling back"
        rollback
        exit 1
    fi
}

main "$@"
SCRIPT

chmod +x deploy.sh
shellcheck deploy.sh
```

Test a simulated deployment (requires the labserver from Lab 2):

```bash
# Create a "new version" to deploy
mkdir -p /tmp/new-version
cp /opt/labserver/server.py /tmp/new-version/
echo "# version 2" >> /tmp/new-version/server.py

# Deploy it
sudo DEPLOY_DIR=/opt/labserver SERVICE_NAME=labserver ./deploy.sh /tmp/new-version
```

---

## Script 5 — Disk usage alert

```bash
cat > disk-alert.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${THRESHOLD:-80}"  # alert if any filesystem is over 80% full

send_alert() {
    local mount="$1"
    local usage="$2"
    # Replace this with a real notification (Slack webhook, email, PagerDuty)
    echo "ALERT: Filesystem $mount is at ${usage}% (threshold: ${THRESHOLD}%)"
}

while IFS= read -r line; do
    # Parse df output: filesystem size used avail use% mountpoint
    usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')

    if [[ "$usage" -ge "$THRESHOLD" ]]; then
        send_alert "$mount" "$usage"
    fi
done < <(df -h --output=source,size,used,avail,pcent,target | tail -n +2 | grep -v tmpfs)

echo "Disk check complete (threshold: ${THRESHOLD}%)"
SCRIPT

chmod +x disk-alert.sh
THRESHOLD=1 ./disk-alert.sh   # use threshold=1 so everything triggers
shellcheck disk-alert.sh
```

---

## Checkpoint

You should have written 5 scripts with no ShellCheck warnings. Run the final check:

```bash
shellcheck health-report.sh analyse-logs.sh service-watchdog.sh deploy.sh disk-alert.sh
```

**Review questions:**

1. Why does `set -euo pipefail` matter? What does each option do?
2. What is the purpose of `trap 'rm -f "$TMPFILE"' EXIT`?
3. In the deploy script, why do we check health after restarting rather than just checking if the service is active?
4. What does `"${var:-default}"` do?
5. Why is `while IFS= read -r line` better than `for line in $(cat file)`?

---

## Bonus — Add to cron

Put the disk alert script in cron to run every 15 minutes:

```bash
# Edit crontab
crontab -e

# Add this line:
# */15 * * * * THRESHOLD=85 /home/youruser/scripting-lab/disk-alert.sh >> /var/log/disk-alert.log 2>&1
```

Cron format: `minute hour day month weekday command`
- `*/15` — every 15 minutes
- `*` — any value for that field
