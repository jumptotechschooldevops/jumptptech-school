---
title: "linux day #4"
description: "What Is a Process?   A process is an instance of a program in execution.    It can be:   A..."
published: 2025-12-26
source: "https://dev.to/jumptotech/linux-day-4-3jh0"
tags: []
---

# linux day #4






## What Is a Process?

A **process** is an **instance of a program in execution**.

* It can be:

  * A program you start manually (Firefox, Terminal, Bash)
  * A background service (nginx, sshd, cron)
  * A helper process started by another program

Once a program starts running, **it becomes a process**.

---

## Process as an Independent Execution Unit

Each process behaves like it has its **own system**:

* Assigned **CPU time**
* Assigned **memory**
* Its own:

  * Open files
  * Network connections
  * Environment variables

From the **process point of view**:

* It believes it owns the CPU
* It believes it owns memory
  Even though in reality, the **kernel shares resources** between many processes.

---

## Who Manages Processes? → The Kernel

The **kernel** is the **lowest level of the operating system**.

Think of it as a **bridge** between:

* Applications (Firefox, Bash, Ping)
* Hardware (CPU, RAM, Disk, Network)

The kernel decides:

* How much CPU time a process gets
* How much memory it can use
* What happens if it asks for more memory
* Which process runs next

Example (real life):

* On a phone, the kernel may **kill background apps** to free memory.
* On a server, it may **slow down processes** instead.

---

## Key Properties of a Process

Every process has:

| Property              | Meaning                            |
| --------------------- | ---------------------------------- |
| **PID**               | Process ID (unique identifier)     |
| **User**              | Which user owns the process        |
| **State**             | Running, sleeping, stopped, zombie |
| **Memory usage**      | RAM used                           |
| **CPU usage**         | CPU time used                      |
| **Parent PID (PPID)** | Which process started it           |

---

## Process States (High Level)

A process can be:

* **Running** – currently executing
* **Sleeping / Waiting** – waiting for input or resources
* **Stopped** – paused
* **Zombie** – finished execution but not cleaned up

(You will study this in more detail later.)

---

## Process Hierarchy (Parent–Child Relationship)

Linux processes are organized as a **tree**.

* Every process is started by another process
* Except the first system process (`init` / `systemd`)

Example:

* `gnome-shell` → starts → `firefox`
* `firefox` → starts → `web content process`

![Image](https://image1.slideserve.com/3351561/linux-process-tree-l.jpg)

![Image](https://i.sstatic.net/iplOi.png)

![Image](https://www.simplified.guide/_media/linux/process-view-tree/process-tree.png?tok=2dd200\&w=700)

![Image](https://d8it4huxumps7.cloudfront.net/uploads/images/6411b0df9fd00_process_state.jpeg)

---

## Practical Example (GUI – System Monitor)

When you open **Firefox**:

* A Firefox process is created
* It runs under your user
* It gets memory and CPU
* It may start **child processes** (tabs, web content)

In **System Monitor**:

* You can see:

  * PID
  * Memory usage
  * Disk usage
  * User
* Enabling **“Show dependencies”** displays the process tree
* Enabling **“All processes”** shows system-wide processes

This visually proves:

* Processes have parents
* Applications are not a single process

---

## Terminal Example (Shell Inside Shell)

When you:

1. Open Terminal
2. Start `bash`
3. Start another `bash`
4. Run `ping google.com`

You create this hierarchy:

```
terminal-server
 └── bash
     └── bash
         └── ping
```

Each command:

* Becomes its own process
* Has its own PID
* Has a parent process

---

## Why This Matters for DevOps

Understanding processes helps you:

* Debug **high CPU usage**
* Identify **memory leaks**
* Kill **hung processes**
* Understand **containers and Kubernetes**
* Manage **system services**

Every tool you use later (`ps`, `top`, `htop`, `kill`, `systemctl`) builds on this concept.

---

## CLI Without GUI (Next Lecture)

On servers:

* There is **no GUI**
* Everything is done via **command line**



# Listing Processes from the Command Line — `ps`

## Why This Lecture Matters

In real servers and cloud environments:

* There is **no GUI**
* You rely on the **command line** to inspect running processes

The `ps` command is one of the **most fundamental Linux/Unix tools** for:

* Troubleshooting
* Performance analysis
* Process inspection
* Interview questions

---

## What Is `ps`?

`ps` stands for **Process Status**.

* Displays information about **running processes**
* Works on **Linux and macOS**
* Behavior is **slightly different** between platforms (explained later)

---

## Basic Usage (Default Behavior)

### Command

```bash
ps
```

### What it shows

* Only processes running in the **current terminal (TTY)**
* Example output:

  * Your shell (`bash`, `zsh`)
  * The `ps` command itself

### Why?

By default, `ps` follows the **POSIX standard** (on Linux):

* Scope is **only the current terminal session**

---

## Demonstrating Process Hierarchy

### Example: Bash inside Bash

```bash
bash
ps
```

You will see:

* Outer `bash`
* Inner `bash`
* `ps`

This confirms:

* Each shell is a **separate process**
* Processes form a **parent–child hierarchy**

---

## Showing All Processes (All Users & Sessions)

### Command

```bash
ps -e
```

or

```bash
ps -A
```

### Meaning

* `-e` / `-A` → **All processes**
* Includes:

  * Background services
  * GUI applications
  * Other terminals
  * Other users’ processes

### Real Example

* Open Firefox in GUI
* Run:

```bash
ps -e
```

* Firefox and its helper processes appear

---

## Full Format Output (`-f`)

### Command

```bash
ps -ef
```

### Why use it?

Adds **important columns**:

* USER
* PID
* PPID (Parent Process ID)
* Start time
* Full command path

### Example Interpretation

* One main Firefox process
* Multiple child processes
* All child processes share the **same PPID**

This explains:

* Multi-process browsers
* Process trees
* Application internals

---

## Process Hierarchy (Tree View)

### Linux only

```bash
ps -ef --forest
```

### What it shows

* Processes displayed as a **tree**
* Parent → child relationships
* Same structure you see in GUI system monitors

![Image](https://linuxhandbook.com/content/images/2022/11/use---tree-option--1.png)

![Image](https://www.computernetworkingnotes.com/wp-content/uploads/linux-tutorials/images/lt12-09-ps-forest.png)

![Image](https://linuxhandbook.com/content/images/2022/11/pstree-.png)

![Image](https://www.tutorialspoint.com/assets/questions/media/12675/Parent%20and%20Child%20Process.PNG)

This is **extremely useful** on servers without a GUI.

---

## Filtering Specific Processes

### By Process ID

```bash
ps -fp <PID>
```

Example:

```bash
ps -fp 1234
```

Shows **only that process**, not its children.

---

## Finding Child Processes (Using `grep`)

There is no perfect built-in child-only filter with `ps`.

### Practical Solution

```bash
ps -ef | grep firefox
```

This:

* Lists the main process
* Lists all child/helper processes
* Common real-world technique

---

## Paging Long Output (`less`)

### Command

```bash
ps -ef | less
```

Why?

* Scrollable output
* Full command lines visible
* No live updates (static snapshot)

---

## Long Format (`-l`)

### Command

```bash
ps -el
```

Adds even more columns:

* Process state
* Priority
* Scheduling info

### Combine options

```bash
ps -elf
ps -elF
ps -eFl
```

Linux allows **flexible combination** of flags.

---

## Summary of Common Linux `ps` Options

| Command           | Purpose               |                |
| ----------------- | --------------------- | -------------- |
| `ps`              | Current terminal only |                |
| `ps -e`           | All processes         |                |
| `ps -ef`          | Full details          |                |
| `ps -ef --forest` | Process tree          |                |
| `ps -fp PID`      | Single process        |                |
| `ps -ef           | grep name`            | Filter by name |
| `ps -ef           | less`                 | Scroll output  |

---

# `ps` on macOS (Important Differences)

## Why Behavior Is Different

macOS and Linux are **both Unix**, but:

* Linux → **POSIX behavior**
* macOS → **BSD behavior**

This affects default `ps` output.

---

## Default macOS Behavior

### Command

```bash
ps
```

### What it shows on macOS

* Processes from **all terminals**
* But **only for the current user**
* Even if processes are in:

  * Other tabs
  * Other terminal windows

This is **different from Linux**.

---

## Why `ps` Doesn’t Show Itself on macOS

* `ps` runs with **elevated privileges**
* Executed as **root (UID 0)**
* Output filters processes **owned by your user**
* Therefore:

  * `ps` does not list itself

This often confuses beginners.

---

## Full Output on macOS

```bash
ps -f
```

Shows:

* UID (numeric user ID)
* PID
* PPID

You will notice:

* `ps` runs as UID `0` (root)

---

## Linux-Like Output on macOS

To match Linux default behavior:

```bash
ps -T
```

### Meaning

* Show **only processes from current terminal**
* Includes processes run as other users
* Makes output consistent with Linux

---

## Cross-Platform Compatibility (Important Course Note)

The flags shown in this course:

* Work on **Linux**
* Work on **macOS**
* Avoid platform-specific options

Example:

* `--forest` → Linux only
* BSD alternatives exist but differ

Always check:

* OS documentation
* Platform-specific man pages


# `ps` Advanced Usage, Multitasking, and Process Priority (Niceness)

---

## 1. Two Styles of `ps` Parameters

So far, we used **Unix (POSIX) style parameters**:

```bash
ps -ef
ps -e -f
```

These:

* Start with a **dash (`-`)**
* Can be **combined**
* Are portable and predictable

However, `ps` also supports **BSD style parameters**.

---

## 2. BSD Style `ps` Parameters

### Key Differences

* **No dash**
* Switches `ps` into **BSD mode**
* Changes default output behavior
* Some options behave differently than POSIX style

---

### Common BSD Example: `ps aux`

```bash
ps aux
```

This is extremely common in documentation and forums.

| Option | Meaning                                             |
| ------ | --------------------------------------------------- |
| `a`    | Processes of all users                              |
| `u`    | User-oriented output                                |
| `x`    | Include processes without a terminal (GUI, daemons) |

### Result

* Lists **almost all processes**
* Shows **CPU % and MEM %**
* Different default columns than `ps -ef`

---

### BSD vs POSIX Comparison

```bash
ps aux      # BSD style
ps -ef      # POSIX style
```

Key difference:

* `ps aux` → CPU & memory usage
* `ps -ef` → hierarchy, PPID, full command

---

### Important Rule

> **Once you use one BSD-style option, `ps` switches to BSD mode**

Example:

```bash
ps auxf
```

Behaves differently than:

```bash
ps -ef --forest
```

---

### Practical Advice

* `ps aux` → **quick system overview**
* `ps -ef` → **debugging, hierarchy, scripting**
* CPU analysis → use `top` / `htop` (not `ps`)

---

## 3. Why Multitasking Works (Single CPU Example)

Assume:

* **One CPU**
* **One core**
* **No hyper-threading**

How can multiple programs run?

### Answer: **Scheduling**

The OS:

* Rapidly switches between processes
* Each process gets a **time slice**
* Switching happens thousands of times per second

This creates the **illusion of parallel execution**.

---

## 4. Scheduler and Context Switching

Each time the CPU switches from one process to another, it performs a:

### **Context Switch**

* Saves state of current process
* Loads state of next process
* Happens extremely fast

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20250825182631440618/1223.webp)

![Image](https://miro.medium.com/1%2Afn9XIL7FIZwbI7bkR2XQ5g.png)

![Image](https://devblogs.microsoft.com/pix/wp-content/uploads/sites/41/2020/08/pix_new_timing_capture_bold_cswitch.png)

![Image](https://eci.intel.com/docs/2.6/_images/def_scheduling_latency.png)

---

## 5. Observing Context Switches (`/proc`)

Linux exposes process details via:

```bash
/proc/<PID>/status
```

### Example

```bash
cat /proc/49225/status | grep ctxt
```

Output:

* `voluntary_ctxt_switches`
* `nonvoluntary_ctxt_switches`

| Type          | Meaning                      |
| ------------- | ---------------------------- |
| Voluntary     | Process waits (I/O, sleep)   |
| Non-voluntary | Scheduler interrupts process |

---

### Live Monitoring with `watch`

```bash
watch -n 0.5 grep ctxt /proc/49225/status
```

You will see:

* Context switches increasing rapidly
* Especially when the application is active

This **visually proves multitasking**.

---

## 6. Process Priority (Niceness)

Now that we understand scheduling, the next question is:

> Can we influence how much CPU time a process gets?

### Yes — with **niceness**

---

### Niceness Scale

| Niceness | Priority         |
| -------- | ---------------- |
| `-20`    | Highest priority |
| `0`      | Default          |
| `+19`    | Lowest priority  |

Think of it as:

* **More nice** → more polite → yields CPU
* **Less nice** → more aggressive → more CPU

---

### Permissions Rule

* Normal users:

  * Can **increase niceness** (lower priority)
* Root:

  * Can **decrease niceness** (raise priority)

---

## 7. Starting a Process with Priority (`nice`)

### Low priority

```bash
nice -n 19 gedit
```

### Attempt high priority (fails as user)

```bash
nice -n -10 gedit
```

### High priority (allowed with sudo)

```bash
sudo nice -n -10 gedit
```

---

## 8. Changing Priority of Running Process (`renice`)

### Find PID

```bash
ps -ef | grep gedit
```

### Increase niceness (allowed)

```bash
renice 10 -p 68836
```

### Decrease niceness (requires root)

```bash
sudo renice -10 -p 68836
```

---

## 9. Real Proof: CPU Benchmark Test

To **prove** niceness works, we must:

* Fully load the CPU
* Run competing processes

### Install benchmark tool

```bash
sudo apt update
sudo apt install sysbench
```

---

### Single Benchmark

```bash
sysbench cpu --threads=10 run
```

Works normally — no competition.

---

### Competing Benchmarks with Different Priorities

Script (`bench.sh`):

```bash
#!/bin/bash
nice -n 19 sysbench cpu --threads=10 run &
sysbench cpu --threads=10 run &
```

Make executable:

```bash
chmod +x bench.sh
./bench.sh
```

---

### Result

* High-priority process:

  * ~15,000 events/sec
* Low-priority process:

  * ~2,000 events/sec

**Huge difference**, same hardware.

---

## 10. Important Clarification

> Niceness **does NOT make your CPU faster**

It only:

* Changes **resource allocation**
* Matters **only under contention**
* Helps control **fairness**, not performance

---

## 11. When Niceness Matters in Real Life

* Databases vs background jobs
* CI pipelines vs monitoring agents
* Desktop responsiveness
* Batch processing
* Production servers under load



# Finding Process IDs Easily & Introduction to Signals

---

## Why Finding the Process ID (PID) Matters

Many Linux operations require a **PID**, for example:

* Changing priority (`renice`)
* Sending signals (`kill`)
* Debugging or stopping processes

### The Problem with `ps | grep`

Example:

```bash
ps -ef | grep firefox
```

Issues:

* Too much output
* Manual searching
* Easy to pick the **wrong PID**
* Child processes mixed with main process

This is **error-prone and inefficient**, especially in production.

---

## The Solution: `pgrep`

### What Is `pgrep`?

`pgrep` searches **running processes by name** and prints **only their PIDs**.

```bash
pgrep firefox
```

Output:

```
1910
```

That is the **main Firefox process ID**.

---

## Why `pgrep` Returns Only the Main Firefox Process

* `pgrep` matches the **process name**
* Firefox helper processes often have names like:

  * `Web Content`
  * `RDD Process`
* Only the main process is named `firefox`

This makes `pgrep` **clean and reliable**.

---

## Matching Full Command Lines (`-f`)

If you want **all Firefox-related processes**:

```bash
pgrep -f firefox
```

This matches:

* Main Firefox
* Helper processes
* Child processes

---

## Combining `pgrep` with `renice` (Very Important)

### Why This Is Powerful

Shell expansion allows:

* One command to **find PIDs**
* Another command to **act on them**

### Example: Lower Firefox Priority

```bash
renice 19 $(pgrep firefox)
```

What happens:

1. `pgrep firefox` → returns PID(s)
2. Shell substitutes PID(s)
3. `renice` applies niceness

No manual searching.

---

### Applying to All Firefox Processes

```bash
renice 19 $(pgrep -f firefox)
```

This:

* Changes priority of **all Firefox-related processes**
* Useful when apps spawn many subprocesses

⚠️ **Do not use quotes**

```bash
# WRONG
renice 19 "$(pgrep firefox)"
```

This would be treated as **one string**, not multiple PIDs.

---

## Key Takeaway (PID Handling)

| Method           | Good? | Reason              |               |
| ---------------- | ----- | ------------------- | ------------- |
| `ps              | grep` | ❌                   | Manual, noisy |
| `pgrep`          | ✅     | Clean, reliable     |               |
| `pgrep + renice` | ✅✅    | Automation-friendly |               |

---

# Introduction to Signals

---

## What Are Signals?

Signals are **special messages** sent to processes.

They:

* Interrupt normal execution
* Are delivered by the **kernel**
* Are handled at a **safe point** (context switch, I/O, etc.)

From a human perspective:

> Signals feel **instant**

Technically:

> Signals are delivered at a **convenient execution point**

---

## Why Signals Exist

Signals allow:

* Users to stop programs
* Shells to control child processes
* OS to notify processes of errors
* Hardware/CPU events to be handled safely

---

## Common Signal Sources

![Image](https://imgv2-2-f.scribdassets.com/img/document/61266152/original/adc800112f/1706351151?v=1)

![Image](https://wiki.cs.manchester.ac.uk/COMP15212/images/b/bd/Unix_signals.png)

![Image](https://devopedia.org/images/article/197/5091.1562685662.png)

![Image](https://liujunming.top/images/2018/12/73.png)

Signals can come from:

* Terminal
* Shell
* Window manager
* Other processes
* Kernel / CPU

---

## Common Signals (Conceptual)

| Signal     | Meaning                  |
| ---------- | ------------------------ |
| `SIGINT`   | Interrupt (Ctrl+C)       |
| `SIGHUP`   | Hangup (terminal closed) |
| `SIGTERM`  | Graceful termination     |
| `SIGKILL`  | Force kill               |
| `SIGWINCH` | Window size change       |
| `SIGILL`   | Illegal CPU instruction  |

---

## You Have Already Used Signals (Ctrl + C)

### Example: `wget`

```bash
wget bigfile.iso
```

* Terminal is **blocked**
* You cannot type commands

Press:

```
Ctrl + C
```

This sends:

```
SIGINT
```

---

## What Happens When SIGINT Is Sent?

1. Terminal sends `SIGINT`
2. Kernel delivers signal
3. Process **handles the signal**
4. Program exits gracefully (if supported)

Example:

* `wget`:

  * Closes connection
  * Cleans up partial download
  * Exits cleanly

---

## Important Concept: Signal Handling

Programs can:

* Handle signals (clean shutdown)
* Ignore signals
* Override default behavior

If a program **does nothing**:

* Default action applies
* For `SIGINT` → process terminates

---

## Why Signals Are Powerful

Signals allow:

* Async control of processes
* Safe interruption
* Communication without polling
* Clean shutdowns

They are **core to Linux process control**.


# The `kill` Command and Linux Signals (Practical Process Control)

---

## What Is the `kill` Command (Really)?

Despite its name, **`kill` does not kill processes by default**.

What it actually does:

* **Sends a signal** to a process
* The **kernel delivers** that signal
* The **process decides** what to do (except for special signals)

So:

> `kill` = **signal sender**, not a murder weapon

---

## Sending Signals Without the Keyboard

Previously, you used:

```text
Ctrl + C
```

That sends:

```
SIGINT
```

But:

* This only works in the **same terminal**
* You cannot use it from another session

To send signals **from anywhere**, we use `kill`.

---

## Basic `kill` Syntax

```bash
kill -s SIGNAL PID
```

Examples:

```bash
kill -s SIGINT 1234
kill -s SIGTERM 1234
kill -s SIGKILL 1234
```

Short form (also valid):

```bash
kill -SIGINT 1234
```

If **no signal is specified**, `kill` sends:

```
SIGTERM (15)
```

---

## Sending `SIGINT` from Another Terminal

Example workflow:

1. Start a download:

```bash
wget largefile.iso
```

2. In another terminal, find the PID:

```bash
pgrep wget
```

3. Send `SIGINT`:

```bash
kill -s SIGINT $(pgrep wget)
```

Result:

* Same behavior as **Ctrl+C**
* Download exits gracefully
* Clean shutdown

---

## Listing Available Signals

```bash
kill -l
```

* Shows all signals supported by the OS
* Linux and macOS outputs differ slightly
* **You do NOT need to memorize all of them**

Focus on the **important ones**.

---

## The Most Important Signals (You Must Know These)

![Image](https://devopedia.org/images/article/197/5091.1562685662.png)

![Image](https://devopedia.org/images/article/197/5924.1562685604.jpg)

![Image](https://i.sstatic.net/9EQBC.png)

![Image](https://liujunming.top/images/2018/12/73.png)

| Signal    | Meaning                  | Can Be Ignored? |
| --------- | ------------------------ | --------------- |
| `SIGINT`  | Interrupt (Ctrl+C)       | Yes             |
| `SIGTERM` | Graceful termination     | Yes             |
| `SIGKILL` | Force kill               | ❌ No            |
| `SIGHUP`  | Terminal closed / reload | Yes             |
| `SIGSTOP` | Pause process            | ❌ No            |
| `SIGCONT` | Resume process           | Yes             |

---

## `SIGTERM` — Graceful Shutdown (Default)

### Meaning

> “Please terminate when ready.”

Used for:

* Services
* Databases
* Long-running jobs

### Commands

```bash
kill PID
kill -s SIGTERM PID
kill -15 PID
```

### Why It Matters

* Allows cleanup
* Flushes data to disk
* Finishes transactions

**Databases expect SIGTERM.**

---

## `SIGINT` vs `SIGTERM`

| Signal    | Purpose                      |
| --------- | ---------------------------- |
| `SIGINT`  | User interrupt from terminal |
| `SIGTERM` | System-requested shutdown    |

Both:

* Can be handled
* Can be ignored
* Are **polite requests**

---

## `SIGKILL` — Force Termination

### Meaning

> “You are terminated immediately.”

Characteristics:

* Cannot be ignored
* Cannot be handled
* Kernel kills the process directly
* No cleanup
* Possible data corruption

### Commands

```bash
kill -s SIGKILL PID
kill -9 PID
```

### When to Use

* Process is stuck
* Process ignores SIGTERM
* System is at risk

⚠️ **Last resort only**

---

## Why `SIGKILL` Is Dangerous

Example:

* Killing a database with `SIGKILL`
* No data flush
* Possible corruption
* Recovery needed on restart

Always try:

1. `SIGTERM`
2. Wait
3. Only then `SIGKILL`

---

## Real Example: Why Vim Is “Hard to Quit”

* `Ctrl+C` → ignored
* `SIGINT` → handled internally
* Vim expects **`:q` or `:q!`**

But:

```bash
kill -s SIGTERM PID
```

✔️ Works

```bash
kill -9 PID
```

✔️ Always works (but unsafe)

Why terminals break afterward:

* Program didn’t reset terminal state
* Escape sequences not restored
* Solution: **open a new terminal**

---

## `SIGHUP` — Hangup Signal

### Meaning (Typical)

* Terminal closed
* Session ended

### Behavior

* Child processes receive `SIGHUP`
* Usually causes them to exit

### Example

```bash
gedit
# close terminal
```

Result:

* `gedit` exits
* `SIGHUP` delivered automatically

### For Daemons

* Often means: **reload configuration**

---

## `SIGSTOP` — Pause a Process

### Meaning

> Pause execution (not terminate)

Characteristics:

* Cannot be ignored
* Kernel-enforced
* Process freezes completely

### Example

```bash
kill -s SIGSTOP PID
```

Process:

* CPU usage → 0
* Memory stays allocated
* State → **stopped**

---

## `SIGCONT` — Resume a Process

```bash
kill -s SIGCONT PID
```

* Process resumes execution
* Continues exactly where it stopped

---

## Visual Demo with `cmatrix` / `ping`

```bash
cmatrix
```

Pause it:

```bash
kill -s SIGSTOP $(pgrep cmatrix)
```

Resume it:

```bash
kill -s SIGCONT $(pgrep cmatrix)
```

Same idea works with:

```bash
ping google.com
```

---

## Pausing Network Programs (Important Insight)

* `SIGSTOP` freezes the process
* Network connection may stay open
* Remote server may timeout
* Resume behavior depends on server support

Result:

* Sometimes download resumes
* Sometimes restarts
* Sometimes fails

This is **real-world behavior**, not a bug.



# `kill` Built-in vs Executable, `killall`, Process Lifecycle, and `top`

---

## 1. `kill` Exists Twice: Built-in vs Executable

In Bash (and other shells), **many commands exist in two forms**:

1. **Shell built-in**
2. **Standalone executable**

### Check with `type`

```bash
type kill
```

Output:

```
kill is a shell builtin
```

Other examples:

```bash
type cut
# cut is /usr/bin/cut

type echo
# echo is a shell builtin
```

### Why This Matters

* Built-ins are implemented **inside the shell**
* Executables are **separate programs**
* Output and supported options **may differ**

---

## 2. Locating the Executable `kill`

The built-in hides the executable by default.

To find the executable version:

```bash
which kill
```

Examples:

* Linux: `/usr/bin/kill`
* macOS: `/bin/kill`

---

## 3. Comparing Built-in vs Executable `kill`

### Built-in

```bash
kill -l
```

* Shows signal **names and numbers**
* Format depends on shell (bash, zsh)

### Executable

```bash
/bin/kill -l
```

* Different formatting
* Usually fewer details
* Still POSIX-compliant

⚠️ **Important**
If output looks different across systems or shells, this is **normal**, not an error.

---

## 4. `killall` — Send Signals by Process Name

`killall` sends signals **by process name**, not PID.

### Basic Usage

```bash
killall firefox
```

* Sends `SIGTERM` by default
* All `firefox` processes terminate

---

### Sending Specific Signals

#### Linux (preferred)

```bash
killall -s SIGINT firefox
```

#### Portable (Linux + macOS)

```bash
killall -SIGINT firefox
```

⚠️ On macOS:

* `-s` means **“verbose”**, not “signal”
* Always use `-SIGNAL` form

---

## 5. Process Exit and Exit Codes

When a process exits:

* Memory is freed
* CPU is released
* **Process entry remains temporarily**

### Exit Code

In Bash, the parent can read the child’s exit code:

```bash
echo $?
```

* `0` → success
* `1–255` → error

Example:

```bash
ls missingfile
echo $?
# 1
```

---

## 6. Parent Responsibility & Reaping

When a child exits:

1. Kernel sends `SIGCHLD` to parent
2. Parent calls `wait()` / `waitpid()`
3. Exit code is collected
4. Process entry is removed

This is called **process reaping**.

---

## 7. Orphan Processes

If the **parent exits before the child**:

* Child becomes an **orphan**
* Adopted by `init` / `systemd` (PID 1 or user session systemd)

Example:

```bash
nohup firefox &
exit
```

Firefox continues running.

---

## 8. Zombie Processes

A **zombie** is:

* Process has exited
* Parent did NOT collect exit code
* Entry remains in process table

### Characteristics

* No CPU usage
* No memory usage
* Occupies **process table slot**
* State: `Z`

### Viewing Zombies

```bash
ps -el | grep Z
```

Zombies are usually:

* Short-lived
* Cleaned automatically

⚠️ Excessive zombies → **buggy parent process**

---

## 9. Process States (You Must Know These)

### View states

```bash
ps -el
```

| State | Meaning                      |
| ----- | ---------------------------- |
| `R`   | Running                      |
| `S`   | Sleeping (interruptible)     |
| `D`   | Uninterruptible sleep (I/O)  |
| `T`   | Stopped (SIGSTOP / debugger) |
| `Z`   | Zombie                       |

---

### Important Clarifications

* **Running ≠ visible GUI**
* Sleeping processes are normal
* `D` state ignores signals until kernel returns
* `T` can be resumed with `SIGCONT`
* `Z` means exit not yet reaped

---

## 10. Introducing `top` — CLI System Monitor

When servers have **no GUI**, `top` replaces System Monitor.

### Start `top`

```bash
top
```

Quit with:

* `q`
* `Ctrl+C`

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20250724162654411322/top.webp)

![Image](https://s3.us-east-2.wasabisys.com/gridpanekb/how-to-use-the-top-command/top-01.png)

![Image](https://i.sstatic.net/G7Pel.png)

![Image](https://journaldev.nyc3.cdn.digitaloceanspaces.com/2020/04/top-command-load-average.png)

---

## 11. Understanding `top` Header

### Load Average

```
load average: 0.37, 0.21, 0.15
```

Means:

* Last 1 min
* Last 5 min
* Last 15 min

Interpreted as:

> Average number of CPU cores in use

---

### CPU Breakdown

* `us` → user space
* `sy` → kernel space
* `id` → idle
* `wa` → I/O wait

---

### Memory

* **Used**
* **Free**
* **Buffers / Cache** → reclaimable

---

## 12. `top` Requires Privileges

```bash
top
sudo top
```

* Root sees **more processes**
* Reads `/proc/*` fully

---

## 13. `top` Startup Options

```bash
top -u username   # only user processes
top -d 1          # refresh every second
top -i            # hide idle
top -c            # full command
```

Example:

```bash
sudo top -d 1 -i -c
```

---

## 14. Interactive `top` Controls (Very Important)

Inside `top`:

| Key | Action           |
| --- | ---------------- |
| `F` | Field selection  |
| `P` | Sort by CPU      |
| `M` | Sort by memory   |
| `k` | Send signal      |
| `r` | Renice           |
| `z` | Toggle color     |
| `Z` | Configure colors |
| `W` | Save config      |
| `q` | Quit             |

---

### Kill from `top`

1. Press `k`
2. Enter PID
3. Enter signal (default `SIGTERM`)

---

### Renice from `top`

1. Press `r`
2. Enter PID
3. Enter niceness

---

## 15. Saving `top` Configuration

```text
Shift + W
```

* Saves layout
* User-specific
* Root and normal user configs differ

---

## 16. `top` vs `htop`

| Tool   | Availability     |
| ------ | ---------------- |
| `top`  | Always installed |
| `htop` | Optional package |

* `htop` is easier and richer
* `top` is **guaranteed everywhere**



# `htop` — Interactive Process Monitor (Practical Guide)


⚠️ Important:

* `htop` is **not always installed by default**
* Installing it may require **permission** and **repository access**
* If you cannot install additional software, you must use `top`

---

## 1. Installing `htop`

### Ubuntu / Debian

```bash
sudo apt install htop
```

### CentOS / RHEL (EPEL required)

```bash
sudo dnf install htop
```



## 2. Starting `htop`

```bash
htop
```

To see **all processes**, start it with root privileges:

```bash
sudo htop
```

Why?

* `htop` reads process data from `/proc`
* Some entries require root access

![Image](https://codeahoy.com/img/htop.jpg)

![Image](https://www.tecmint.com/wp-content/uploads/2012/08/Htop-Process-View-in-Tree-Format.png)

![Image](https://s3.us-east-2.wasabisys.com/gridpanekb/how-to-use-the-htop-command/htop-07.png)

![Image](https://www.inmotionhosting.com/support/wp-content/uploads/2019/07/htop-terminal-1.png)

---

## 3. Understanding the `htop` Interface

### Top Section (System Overview)

* **CPU cores** (one bar per core)
* **Load average** (1 / 5 / 15 minutes)
* **Uptime**
* **Memory usage**
* **Swap usage**

This gives you an **instant health overview** of the system.

---

### Process List

* Scrollable with **arrow keys**
* Horizontally scrollable to see **full commands**
* Click column headers to **sort**
* Mouse support (if terminal allows it)

---

## 4. Navigating `htop`

### Keyboard Navigation

* ↑ ↓ → ← : move around
* Mouse: select, sort, scroll (if supported)

This alone makes `htop` much easier than `top`.

---

## 5. Changing Process Priority (Niceness)

### Increase niceness (lower priority)

```text
F8
```

### Decrease niceness (higher priority)

```text
F7
```

⚠️ Notes:

* Requires root privileges
* Be careful: selection moves when list refreshes

---

## 6. Sending Signals (Killing Processes)

Press:

```text
F9
```

What happens:

* A **signal selection menu** appears
* No need to remember signal numbers
* Select:

  * `SIGTERM` (default, safe)
  * `SIGKILL` (force, dangerous)
  * Any other signal

Cancel with:

* `Esc`
* “Cancel” option

---

## 7. Tree View (Process Hierarchy)

Toggle tree view:

```text
F5
```

This shows:

* Parent → child relationships
* Who launched whom

Very useful for:

* Debugging
* Understanding service dependencies

Toggle again to return to normal view.

---

## 8. Configuration & Customization (Setup Menu)

Open setup:

```text
F2
```

### What You Can Customize

#### Meters (Top Section)

* Memory style (bar, graph, LED)
* Add/remove meters
* Move meters left/right

Example:

* Add **Clock**
* Add **CPU frequency**
* Add **Temperature** (on physical servers)

---

#### Display Options

* CPU numbering (start at 0 or 1)
* Show/hide kernel threads
* Highlight running processes

---

#### Colors

* Fully customizable color scheme

---

## 9. Saving Configuration

### Quit without saving

```text
Ctrl + C
```

### Quit and save configuration

```text
F10
```

Saved configuration is:

* **User-specific**
* Separate for:

  * normal user
  * root (`sudo htop`)

---

## 10. `htop` vs `top` — When to Use Which

| Tool   | Use When                           |
| ------ | ---------------------------------- |
| `top`  | Minimal systems, no extra packages |
| `htop` | Daily admin work, troubleshooting  |

### Recommendation

> Use **`htop` whenever possible**
> Know **`top` for interviews and restricted environments**


# Bash Job Control — Foreground, Background, Suspend & Resume

## 1. What is a *job* in Bash?

A **job** is a **command line executed by the shell**.

Important distinction:

* A **job** can contain **multiple processes**
* A **process** is a single running program

### Example

```bash
ping google.com | wc -l
```

* `ping` → one process
* `wc` → another process
* Together → **one job**

Bash manages **jobs**, not individual processes.

---

## 2. Foreground Jobs

A **foreground job**:

* Occupies the terminal
* Blocks Bash until it finishes
* Receives keyboard input

### Example

```bash
ping google.com
```

While this runs:

* You cannot type new commands
* `Ctrl+C` sends **SIGINT** and stops it

Only **one foreground job** can exist per shell.

---

## 3. Background Jobs (`&`)

To run a job in the background, append `&`:

```bash
ping -c 10 google.com &
```

What happens:

* Bash immediately returns control
* Job continues running
* Output still appears in the terminal unless redirected

Bash prints:

```text
[1] 12345
```

* `1` → Job ID
* `12345` → PID (usually last process in pipeline)

---

## 4. Background Output & Redirection

### Without redirection (messy)

```bash
ping google.com &
ls
```

Output interleaves → confusing.

### Redirect output to file

```bash
ping google.com > ping.txt &
```

### Discard output completely

```bash
ping google.com > /dev/null &
```

---

## 5. Job Completion Messages

When a background job finishes:

* Bash prints its status **after your next command**

Example:

```bash
ping -c 5 google.com > /dev/null &
echo
```

Then Bash reports:

```text
[1]+  Done  ping -c 5 google.com
```

---

## 6. Background Jobs with Pipelines

```bash
ping -c 100 google.com | wc -l &
```

Notes:

* Multiple processes → one job
* Bash shows only **last PID**
* Both processes run concurrently

---

## 7. Listing Jobs — `jobs`

```bash
jobs
```

Example output:

```text
[1]- Running ping google.com > /dev/null &
[2]+ Running ping bing.com > /dev/null &
```

Symbols:

* `+` → current job (default target)
* `-` → previous job

---

## 8. Bringing Jobs to Foreground — `fg`

### Bring current job

```bash
fg
```

### Bring specific job

```bash
fg %1
```

Once in foreground:

* Receives keyboard input
* `Ctrl+C` works
* Terminal is blocked again

---

## 9. Suspending a Foreground Job (`Ctrl+Z`)

While a job runs in the foreground:

```text
Ctrl + Z
```

What happens:

* Bash sends **SIGTSTP**
* Job is **paused**, not terminated
* Control returns to shell

Check status:

```bash
jobs
```

Example:

```text
[1]+  Stopped ping google.com
```

---

## 10. Resuming Suspended Jobs

### Resume in background

```bash
bg %1
```

### Resume in foreground

```bash
fg %1
```

Internally:

* Bash sends **SIGCONT**
* Program continues execution

---

## 11. Killing Jobs (Job IDs)

To kill a **job**, not a PID:

```bash
kill %1
```

* Sends **SIGTERM**
* Requests graceful shutdown

### Force kill

```bash
kill -SIGKILL %1
```

⚠️ Important:

* `%` indicates **job ID**
* Without `%`, `kill` assumes **PID**

---

## 12. Bash Built-in vs System `kill`

Job control works **only** with Bash’s built-in `kill`.

Correct:

```bash
kill %1
```

Incorrect:

```bash
/bin/kill %1
```

Reason:

* Job IDs exist **only inside Bash**
* External `kill` does not understand `%`

---

## 13. Keyboard Input Rule (Critical)

> **Only foreground jobs receive keyboard input**

This includes:

* Typed characters
* `Ctrl+C`
* `Ctrl+Z`

Background jobs:

* Never receive keyboard input
* Must be brought to foreground first

---

## 14. Controlling Background Output — `stty tostop`

### Problem

* Background jobs print output
* Output clutters terminal

### Solution

Enable automatic stop on output:

```bash
stty tostop
```

Now:

* Any background job that writes output → **stopped**

Check:

```bash
jobs
```

---

## 15. Using `stty tostop` in Practice

```bash
stty tostop
ping google.com &
```

Result:

```text
Stopped ping google.com
```

Bring to foreground:

```bash
fg
```

Suspend again:

```text
Ctrl + Z
```

Resume:

```bash
bg
```

Job immediately stops again on output.

---

## 16. Disable `stty tostop`

```bash
stty -tostop
```

Now background jobs can output freely again.

---

## 17. Mental Model (Very Important)

| Action        | Effect               |
| ------------- | -------------------- |
| `&`           | Start in background  |
| `Ctrl+Z`      | Suspend (pause)      |
| `bg`          | Resume in background |
| `fg`          | Resume in foreground |
| `jobs`        | List jobs            |
| `kill %N`     | Terminate job        |
| `stty tostop` | Stop jobs on output  |



# Waiting for Background Jobs in Bash (`wait`)

## 1. The Problem

You start **multiple background jobs** and want to:

* Wait until **all** of them finish
* Or wait for **one specific job**
* Then **run the next command**

Example use cases:

* Multiple downloads
* Parallel builds
* Long-running scripts

---

## 2. The `wait` Command (Basics)

### Wait for **all** background jobs

```bash
wait
```

* Runs in the **foreground**
* Blocks until **all current background jobs** change state
* Usually means: **they finish**

---

### Wait for a specific **PID**

```bash
wait 12345
```

* Waits only for that process

---

### Wait for a specific **job**

```bash
wait %1
```

* `%` → job ID (Bash job control)

---

### Wait until **any** job finishes

```bash
wait -n
```

* Returns as soon as **one** background job completes

---

## 3. Practical Example — Waiting for Multiple Jobs

Start three background jobs:

```bash
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &
```

Check jobs:

```bash
jobs
```

Now wait:

```bash
wait
```

What happens:

* Bash blocks
* All three pings run in parallel
* `wait` exits only after all three finish

---

## 4. Running Commands *After* All Jobs Finish

Bash executes commands **sequentially**.

Example:

```bash
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &

wait
echo "All jobs finished"
```

Result:

* `echo` runs **only after** all background jobs complete

---

## 5. Using `;` to Chain Commands

```bash
wait; echo "Done"
```

* `;` → always runs next command after previous finishes
* `wait` must complete first

---

## 6. Audible Notification When Jobs Finish (Bell)

You can notify yourself when jobs complete.

### Terminal bell (if supported)

```bash
tput bel
```

* Sends a **bell escape sequence**
* Terminal may:

  * Beep
  * Flash
  * Ignore it (depends on settings)

---

### Example: Notify When All Jobs Finish

```bash
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &
ping -c 5 google.com > /dev/null &

wait
tput bel
echo "All downloads completed"
```

Use case:

* Start jobs
* Walk away
* Get notified when done

⚠️ Note:

* Many modern terminals disable bells by default
* Check terminal settings if it doesn’t work

---

## 7. Why `wait` Is Especially Useful in Scripts

In scripts, `wait` allows:

* **Parallel execution**
* **Controlled synchronization**
* Faster execution than sequential logic

Example:

```bash
task1 &
task2 &
task3 &
wait
cleanup
```

---

# Keeping Jobs Running After Logout — `nohup`

## 8. The Problem

Normally:

* When you **close a terminal** or **log out**
* Bash sends **SIGHUP**
* Child processes terminate

This is bad for:

* Long downloads
* Long scripts
* Remote SSH sessions

---

## 9. The `nohup` Command

`nohup` = **no hangup**

It:

* Disconnects a process from **SIGHUP**
* Keeps it running after logout

---

## 10. Basic `nohup` Usage

```bash
nohup ping -c 100 google.com &
```

What happens:

* Process runs in background
* Survives terminal close
* Output redirected to `nohup.out`

Location of `nohup.out`:

* Current directory (if writable)
* Otherwise: `$HOME/nohup.out`

---

## 11. Verifying It Still Runs

```bash
ps -p <PID>
```

Or from another terminal:

```bash
ps aux | grep ping
```

Even after:

* Closing terminal
* Logging out

---

## 12. Understanding the Three Variants (Very Important)

### 1️⃣ `nohup command`

```bash
nohup ping google.com
```

* Foreground process
* Survives terminal close
* Still receives keyboard signals (Ctrl+C)

---

### 2️⃣ `command &`

```bash
ping google.com &
```

* Background process
* **Dies when terminal closes**
* No keyboard input

---

### 3️⃣ `nohup command &` (Most common)

```bash
nohup ping google.com &
```

* Background
* Survives logout
* No keyboard input
* Ideal for servers

---

## 13. Why `nohup` + `&` Is Usually Used Together

| Feature            | `nohup` | `&` |
| ------------------ | ------- | --- |
| Survives logout    | ✅       | ❌   |
| Runs in background | ❌       | ✅   |
| Keyboard input     | ✅       | ❌   |
| Used in production | ⚠️      | ⚠️  |
| Combined usage     | ✅       | ✅   |

👉 **Production standard**:

```bash
nohup script.sh &
```

---

## 14. What Happens to the Parent Process?

When you close the terminal:

* Bash exits
* Parent process dies
* Kernel reassigns child to **PID 1**

On Linux:

* Parent becomes `systemd` (or `init`)

This is why the process survives.

---

## 15. Killing a `nohup` Process

Since it’s no longer a job:

```bash
kill <PID>
```

Or force:

```bash
kill -9 <PID>
```

---

## 16. Mental Model (Final Summary)

### `wait`

* Synchronization tool
* Blocks until jobs finish
* Essential for scripts

### `nohup`

* Prevents termination on logout
* Handles SIGHUP only
* Usually combined with `&`



# Linux Package Management (Debian / Ubuntu)



## 1. `dpkg` — The Lowest Level Package Manager

### What is `dpkg`?

* **dpkg** = *Debian Package Manager*
* Used by **Debian**, **Ubuntu**, and derivatives
* Works directly with `.deb` files
* **Does NOT resolve dependencies**

`dpkg` only:

* Installs files
* Removes files
* Tracks installed packages

---

### Installing a `.deb` File Manually

```bash
sudo dpkg -i package.deb
```

* `-i` = install
* Requires **root privileges**
* Fails if dependencies are missing

---

### Removing a Package Installed via `dpkg`

```bash
sudo dpkg -r package-name
```

Example:

```bash
sudo dpkg -r neofetch
```

---

## 2. What Is Inside a `.deb` File?

A `.deb` file is an **archive** containing:

### 1️⃣ `data.tar.*`

* Files copied into `/`
* Example paths:

  * `/usr/bin`
  * `/etc`
  * `/usr/share`

### 2️⃣ `control.tar.*`

* Metadata:

  * Package name
  * Version
  * Dependencies
* Lifecycle scripts:

  * `postinst`
  * `prerm`
  * `postrm`

### 3️⃣ `debian-binary`

* Format version (usually `2.0`)

📌 You can inspect `.deb` files using an archive manager.

---

## 3. Why `dpkg` Is Not Enough

Problem:

* You must **manually download** `.deb` files
* Dependencies are **not resolved**
* Easy to break your system

Solution:
➡ **APT**

---

# APT — Advanced Package Tool

APT sits **on top of dpkg** and adds:

* Dependency resolution
* Repository management
* Secure updates
* Automatic upgrades

---

## 4. `apt` vs `apt-get`

| Tool      | Purpose                        |
| --------- | ------------------------------ |
| `apt-get` | Stable scripting interface     |
| `apt`     | User-friendly interactive tool |

**Best practice**

* Scripts → `apt-get`
* Manual usage → `apt`

Both:

* Use the same config files
* Install the same packages

---

## 5. Repository Configuration

APT gets packages from **repositories** defined in:

### Main file

```bash
/etc/apt/sources.list
```

### Additional repositories

```bash
/etc/apt/sources.list.d/*.list
```

---

### Repository Line Structure

Example:

```
deb http://archive.ubuntu.com/ubuntu jammy main restricted
```

Breakdown:

1. `deb` → binary packages
2. URL → repository server
3. `jammy` → Ubuntu version
4. `main restricted` → repository components

---

## 6. Ubuntu Repository Components

| Component    | Description               |
| ------------ | ------------------------- |
| `main`       | Official, free, supported |
| `restricted` | Official, non-free        |
| `universe`   | Community-maintained      |
| `multiverse` | Non-free, unsupported     |

💡 Default configuration is recommended unless you know why you’re changing it.

---

## 7. Updating Package Lists

Before installing or upgrading:

```bash
sudo apt update
```

This:

* Downloads **package indexes**
* Does **not install** anything

---

## 8. Installing Software with APT

Example:

```bash
sudo apt install neofetch
```

APT will:

* Resolve dependencies
* Install required libraries
* Track manual vs dependency installs

---

### Recommended Packages

APT installs **recommended packages by default**.

To disable:

```bash
sudo apt install --no-install-recommends neofetch
```

---

## 9. Keeping the System Up to Date

### Standard Upgrade (Safe)

```bash
sudo apt upgrade
```

* Updates installed packages
* Does **not remove** packages
* Low risk

---

### Full Upgrade / Dist Upgrade (Advanced)

```bash
sudo apt full-upgrade
```

or

```bash
sudo apt-get dist-upgrade
```

* May:

  * Remove packages
  * Replace dependencies
  * Downgrade packages if needed
* **Higher risk**

📌 Use during maintenance windows.

---

## 10. Removing Unused Dependencies

After upgrades, unused libraries remain.

Clean them with:

```bash
sudo apt autoremove
```

Benefits:

* Frees disk space
* Reduces attack surface
* Keeps system clean

---

# Custom (Third-Party) Repositories

## 11. Why Add Third-Party Repositories?

Default repositories may contain:

* Older versions
* LTS-frozen software

Use third-party repos when you need:

* Newer versions
* Vendor-supported builds
* Fast security fixes

---

## 12. Security Model — GPG Keys

When adding a repository:

* You **trust the maintainer**
* Packages are **cryptographically signed**
* APT verifies signatures before installing

⚠️ A trusted repository can:

* Replace system packages
* Override official updates

---

## 13. Repository Entry Types

### Old format (single line)

```
deb http://example.com jammy main
```

### Modern format (preferred)

```
Types: deb
URIs: https://example.com
Suites: jammy
Components: main
Signed-By: /usr/share/keyrings/example.gpg
```

---

# Example: WineHQ Repository

## 14. Why Wine Needs a Third-Party Repo

Ubuntu ships:

* **Older Wine versions**

WineHQ provides:

* Faster updates
* Better Windows compatibility

---

### Steps (Conceptual)

1️⃣ Enable 32-bit architecture
2️⃣ Add WineHQ GPG key
3️⃣ Add WineHQ repository
4️⃣ Update package lists
5️⃣ Install WineHQ

```bash
sudo apt update
sudo apt install winehq-stable
```

---

## 15. Real-World Result

* Ubuntu Wine version: **6.x**
* WineHQ version: **8.x**
* Newer Wine versions:

  * Fix crashes
  * Improve compatibility
  * Reduce graphical glitches

---

## 16. Important Warning (Production Reality)

Adding third-party repositories:

* Affects **entire system**
* Applies to **future upgrades**
* Can override core packages

**Best practice**

* Read install instructions
* Understand what is added
* Remove unused repositories later

---

# Summary — What You Now Understand

### Package Layers

```
APT → dpkg → filesystem
```



# Ubuntu Package Management – PPAs, Verification, Dependencies, Reconfiguration, and Snap


## 1. PPAs (Personal Package Archives)

### What is a PPA?

* **PPA = Personal Package Archive**
* Ubuntu-specific feature (Canonical / Launchpad)
* Allows individuals or teams to publish newer or custom packages
* Mostly **not available on Debian**

PPAs are hosted on:

```
https://launchpad.net
```

---

### Why Use a PPA?

Official Ubuntu repositories often provide:

* Stable versions
* LTS-frozen software

PPAs are useful when you need:

* Newer versions (e.g., PHP, Node.js)
* Faster security fixes
* Vendor-maintained builds

---

## 2. Example: Installing a Newer PHP via PPA

### Default PHP Version

```bash
apt show php
```

Example:

* Ubuntu repo → PHP 8.1
* We want → PHP 8.2+

---

### Finding a PPA

1. Go to **Launchpad**
2. Search for *PHP*
3. Example PPA:

   ```
   ppa:ondrej/php
   ```

Important:

* This is **not an official Canonical repository**
* Maintained by an individual
* Must be explicitly trusted

---

### Adding the PPA

```bash
sudo add-apt-repository ppa:ondrej/php
sudo apt update
```

What happens:

* New `.list` file added to `/etc/apt/sources.list.d/`
* GPG key automatically installed
* Packages now available system-wide

---

### Installing PHP from the PPA

```bash
sudo apt install php
php --version
```

Result:

* PHP 8.2 installed
* Overrides Ubuntu’s default PHP

---

### Removing a PPA Safely

Removing the PPA does **NOT** remove installed packages.

```bash
sudo add-apt-repository --remove ppa:ondrej/php
```

Then:

```bash
sudo apt remove php
sudo apt autoremove
sudo apt install php
```

Result:

* PHP falls back to Ubuntu version (8.1)

⚠️ **Key lesson**
Removing a repository does **not** downgrade or remove packages automatically.

---

## 3. Security Reality of PPAs

* PPAs can replace **any package**
* Affect **future upgrades**
* Trust is delegated to the maintainer

Best practice:

* Minimize PPAs
* Remove when no longer needed
* Prefer LTS versions

---

## 4. Package Verification with `debsums`

### What is `debsums`?

* Verifies installed package files against stored checksums
* Uses MD5 (not cryptographically secure, but useful)
* Detects accidental or unauthorized modifications

Install:

```bash
sudo apt install debsums
```

---

### Common Options

| Option | Meaning                            |
| ------ | ---------------------------------- |
| `-a`   | Check all files (including config) |
| `-s`   | Silent (only show mismatches)      |
| `-l`   | List packages without checksums    |

---

### Verify System Files

```bash
sudo debsums -as
```

Example output:

```
/etc/crontab
```

Meaning:

* File modified since install
* Expected for config files

---

### What `debsums` Does NOT Detect

It **only checks files installed by `.deb` packages**.

Example attack it won’t catch:

```bash
sudo touch /usr/local/bin/apt
sudo chmod +x /usr/local/bin/apt
```

Because:

* New file
* Not owned by any package
* Precedence via `$PATH`

⚠️ **Important**
`debsums` ≠ full system integrity tool

---

### When to Use `debsums`

* New server handover
* Suspected tampering
* Debugging broken packages
* Compliance checks

---

## 5. Dependency Management in APT

### Viewing Dependencies

```bash
apt show bash
```

or

```bash
apt-cache show bash
```

---

### Dependency Types

| Type          | Meaning                       |
| ------------- | ----------------------------- |
| `Pre-Depends` | Must be fully installed first |
| `Depends`     | Required                      |
| `Recommends`  | Usually installed             |
| `Suggests`    | Optional                      |
| `Conflicts`   | Cannot coexist                |
| `Replaces`    | Overwrites files              |

---

## 6. Dependency Conflict Example

### Resolvable Case

```
bash → libc6 >= 2.35
zsh  → libc6 >= 2.36
```

Solution:

* Install libc6 2.36

APT resolves automatically.

---

### Unresolvable Case (Hypothetical)

```
bash → libc6 == 2.35
zsh  → libc6 >= 2.36
```

No solution exists.

---

## 7. Breaking the System (What NOT to Do)

Installing incompatible `.deb` manually:

```bash
sudo dpkg -i --force-all zsh_old.deb
```

Result:

* Broken dependency state
* APT cannot install unrelated packages
* System partially broken

---

## 8. Fixing Dependency Issues

### Automatic Repair

```bash
sudo apt install -f
```

What it does:

* Fixes broken dependencies
* Upgrades or removes conflicting packages
* Keeps manually installed packages

---

### Other Recovery Steps

1. Update first:

```bash
sudo apt update
sudo apt upgrade
```

2. Cleanup:

```bash
sudo apt autoremove
```

3. Remove broken package manually if needed

---

## 9. Best Practices to Avoid Dependency Hell

* Prefer official repositories
* Minimize PPAs
* Avoid random `.deb` files
* Keep system updated
* Use LTS releases
* Delay major upgrades
* Backup before upgrades
* Use containers (Docker) when possible

---

## 10. Reconfiguring Packages with `dpkg-reconfigure`

### Why Reconfigure?

Packages may:

* Ask configuration questions
* Run post-install scripts
* Set system defaults

Example uses:

* Bootloader selection
* Display manager choice
* Locale generation

---

### Reconfigure a Package

```bash
sudo dpkg-reconfigure package-name
```

---

## 11. Example: Locales (Internationalization)

Locales define:

* Date formats
* Number formats
* Currency formats

Example:

```bash
date "+%A"
```

Output:

```
Wednesday
```

---

### Generate New Locales

```bash
sudo dpkg-reconfigure locales
```

Select:

* `de_DE.UTF-8`
* Choose default locale

Result:

```bash
LANG=de_DE.UTF-8 date "+%A"
Mittwoch
```

---

## 12. Snap Packages (Alternative Packaging System)

### Why Snap Exists

APT problems:

* Global dependencies
* Version conflicts
* Distro-specific builds

Snap solves this by:

* Bundling dependencies
* Isolating applications
* Auto-updating packages

---

### Installing a Snap

```bash
sudo snap install gimp
```

---

### Where Snaps Live

* Images stored in:

  ```
  /var/lib/snapd/snaps/
  ```
* Mounted at:

  ```
  /snap/
  ```

Example:

```
/snap/gimp/current/
```

---

### Executables

Symlinks created in:

```
/snap/bin/
```

Accessible via `$PATH`:

```bash
which gimp
```

---

### Advantages of Snap

* No dependency conflicts
* Consistent behavior
* Automatic updates
* Cross-distribution compatibility

---

### Tradeoffs

* Larger disk usage
* Slower startup
* Mostly desktop-focused
* Less common on servers

---

## 13. When to Use Snap vs APT

| Use Case          | Preferred    |
| ----------------- | ------------ |
| Core system tools | APT          |
| Servers           | APT / Docker |
| Desktop apps      | Snap         |
| Rapid updates     | Snap         |
| Stability         | APT          |



## 16. Snap Packages (Alternative Model)

### What Is Snap?

* Universal package format
* Bundles **all dependencies**
* Runs isolated from system libraries
* Auto-updates by default

Common on:

* Ubuntu
* Fedora
* Can be used on CentOS/RHEL

---

### Important Enterprise Warning

Using Snap on **RHEL**:

* Breaks enterprise support
* Snap itself is unsupported
* Applications installed via Snap are unsupported

---

## 17. Why Snap Exists

Traditional Linux packages:

* Share dependencies globally
* Can conflict

Snap approach:

* Each app bundles dependencies
* No conflicts
* Larger disk usage
* Faster vendor updates

Comparable to:

* Windows installers
* macOS app bundles

---

## 18. Installing Snap on CentOS Stream

Requires EPEL.

```bash
sudo dnf install snapd
sudo systemctl enable --now snapd.socket
```

---

## 19. Installing Software via Snap

### Example: Latest Firefox

```bash
sudo snap install firefox
```

First install:

* Takes longer (security profiles)
* Subsequent installs are faster

---

### Running Snap Applications

```bash
snap run firefox
```

Snap Firefox version:

* Much newer than ESR
* Independent of system Firefox

---

## 20. When to Use Snap

Good for:

* Developer workstations
* 최신 browser versions
* Tools needing rapid updates

Avoid for:

* Production servers
* Systems requiring enterprise support
* Security-restricted environments


