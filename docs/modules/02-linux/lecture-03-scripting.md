# Lecture 3 · Shell Scripting

## Why scripting matters

A shell script is a file containing a sequence of commands. Anything you can type in the terminal you can put in a script. The moment you find yourself doing the same sequence of commands more than twice, that is a script waiting to be written.

This is not a scripting tutorial for developers who want a programming hobby. It is a survival guide for DevOps work. We cover bash because bash is everywhere — it is the default shell on almost every Linux system and available on macOS.

---

## The basics

### Shebang

The first line of every script:

```bash
#!/bin/bash
```

This tells the kernel which interpreter to use when running the file. Without it, the script might run under the wrong shell or fail entirely.

Use `#!/usr/bin/env bash` if you want portability — it finds bash in `PATH` rather than hardcoding the location.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

`set -euo pipefail` is a best-practice header:
- `-e` — exit immediately if any command fails
- `-u` — treat unset variables as errors
- `-o pipefail` — if any command in a pipeline fails, the pipeline fails

Without these, a script can silently continue after an error and produce incorrect results with no obvious indication that anything went wrong.

### Variables

```bash
# Assignment — NO spaces around =
name="Alice"
count=42
message="Hello, $name"

# Referencing
echo $name
echo "$name"       # always quote variables
echo "${name}s"    # braces when adjacent to text

# Command substitution
today=$(date +%Y-%m-%d)
file_count=$(ls /var/log | wc -l)

# Arithmetic
x=5
y=3
result=$((x + y))    # 8
echo $((x * y))      # 15
echo $((x / y))      # 1 (integer division)
```

**Always double-quote variable expansions.** Unquoted variables are split on whitespace and glob-expanded, which causes subtle bugs:

```bash
filename="my file.txt"
rm $filename      # tries to remove "my" and "file.txt" — WRONG
rm "$filename"    # removes "my file.txt" — correct
```

### Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

# $0 = script name
# $1, $2, ... = positional arguments
# $# = number of arguments
# $@ = all arguments as separate words

echo "Script: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Count: $#"
```

Validate arguments at the start:

```bash
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <source> <destination>" >&2
    exit 1
fi
```

Writing errors to stderr with `>&2` is important — it keeps error messages separate from actual output, which matters when you pipe scripts together.

---

## Conditionals

```bash
# if / elif / else
if [[ condition ]]; then
    commands
elif [[ other_condition ]]; then
    commands
else
    commands
fi
```

### String comparisons

```bash
[[ "$a" == "$b" ]]    # equal
[[ "$a" != "$b" ]]    # not equal
[[ -z "$a" ]]         # empty string
[[ -n "$a" ]]         # non-empty string
[[ "$a" =~ ^[0-9]+$ ]] # regex match
```

### Numeric comparisons

```bash
[[ $a -eq $b ]]   # equal
[[ $a -ne $b ]]   # not equal
[[ $a -lt $b ]]   # less than
[[ $a -gt $b ]]   # greater than
[[ $a -le $b ]]   # less than or equal
[[ $a -ge $b ]]   # greater than or equal
```

### File tests

```bash
[[ -f "$path" ]]   # is a regular file
[[ -d "$path" ]]   # is a directory
[[ -e "$path" ]]   # exists (file or directory)
[[ -r "$path" ]]   # readable
[[ -w "$path" ]]   # writable
[[ -x "$path" ]]   # executable
[[ -s "$path" ]]   # file exists and is non-empty
```

### Case statement

```bash
case "$environment" in
    production|prod)
        replicas=5
        ;;
    staging)
        replicas=2
        ;;
    development|dev)
        replicas=1
        ;;
    *)
        echo "Unknown environment: $environment" >&2
        exit 1
        ;;
esac
```

---

## Loops

### for loop

```bash
# Loop over a list
for server in web01 web02 web03; do
    echo "Checking $server..."
    ssh "$server" uptime
done

# Loop over files
for f in /var/log/*.log; do
    echo "Processing: $f"
done

# C-style loop
for ((i = 0; i < 10; i++)); do
    echo "Iteration $i"
done

# Loop over command output
for line in $(cat servers.txt); do
    ping -c 1 "$line"
done

# Better pattern for files with spaces — read line by line
while IFS= read -r line; do
    echo "Host: $line"
done < servers.txt
```

### while loop

```bash
# Wait until a service is ready
max_attempts=30
attempt=0

while ! curl -sf http://localhost:8080/health; do
    attempt=$((attempt + 1))
    if [[ $attempt -ge $max_attempts ]]; then
        echo "Service did not start after $max_attempts attempts" >&2
        exit 1
    fi
    echo "Waiting... ($attempt/$max_attempts)"
    sleep 2
done

echo "Service is ready"
```

---

## Functions

```bash
#!/usr/bin/env bash
set -euo pipefail

log() {
    local level="$1"
    local message="$2"
    echo "[$(date +%H:%M:%S)] [$level] $message"
}

check_dependency() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log ERROR "Required command not found: $cmd"
        return 1
    fi
}

main() {
    log INFO "Starting deployment"

    check_dependency docker
    check_dependency kubectl

    log INFO "All dependencies found"
    # ... rest of script
}

main "$@"
```

Good scripting practices shown above:
- Functions are defined before they are called
- Local variables with `local` — do not pollute the global scope
- A `main()` function that is called at the end with `"$@"` (passes all script arguments)
- Consistent logging function

---

## Error handling

```bash
# Exit on error (from set -e), but catch specific failures
if ! cp "$src" "$dst"; then
    log ERROR "Failed to copy $src to $dst"
    exit 1
fi

# Trap to run cleanup on exit
cleanup() {
    local exit_code=$?
    rm -f "$tmpfile"
    if [[ $exit_code -ne 0 ]]; then
        log ERROR "Script failed with exit code $exit_code"
    fi
}
trap cleanup EXIT

# Create temp files safely
tmpfile=$(mktemp)
```

The `trap` command runs a function when the script exits — for any reason, including errors and signals. This is how you ensure cleanup happens even if the script crashes.

---

## Common script patterns

### Backup a file before modifying it

```bash
backup_file() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    echo "Backup created: $backup"
}
```

### Parse flags

```bash
verbose=false
dry_run=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose) verbose=true; shift ;;
        -n|--dry-run) dry_run=true; shift ;;
        -h|--help)
            echo "Usage: $0 [-v] [-n] <target>"
            exit 0
            ;;
        -*)
            echo "Unknown flag: $1" >&2
            exit 1
            ;;
        *) break ;;
    esac
done
```

### Retry with backoff

```bash
retry() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local attempt=0

    until "$@"; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge $max_attempts ]]; then
            echo "Command failed after $max_attempts attempts: $*" >&2
            return 1
        fi
        echo "Attempt $attempt failed. Retrying in ${delay}s..."
        sleep "$delay"
        delay=$((delay * 2))   # exponential backoff
    done
}

# Usage:
retry 5 2 curl -sf https://api.example.com/health
```

---

## Testing scripts

```bash
# Test mode: echo commands instead of running them
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] $*"
else
    "$@"
fi

# ShellCheck — static analysis for shell scripts
# Install: apt install shellcheck / brew install shellcheck
shellcheck deploy.sh
```

ShellCheck catches common bugs before you run the script. Run it as part of your CI pipeline.

---

## Summary

- Start every script with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Always double-quote variable expansions: `"$var"`.
- Write errors to stderr with `>&2`.
- Use `trap cleanup EXIT` for reliable cleanup.
- Write a `main()` function and call it with `main "$@"`.
- Run `shellcheck` on every script before committing.
