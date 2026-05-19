---
title: "Linux Globbing — FULL Exercise Set"
description: "0️⃣ Setup (Run Once)   Create a safe practice directory.    mkdir ~/globbing-lab cd..."
published: 2025-12-26
source: "https://dev.to/jumptotech/linux-globbing-full-exercise-set-38ap"
tags: []
---

# Linux Globbing — FULL Exercise Set



## 0️⃣ Setup (Run Once)

Create a safe practice directory.

```bash
mkdir ~/globbing-lab
cd ~/globbing-lab
touch file1.txt file2.txt file10.txt fileA.txt fileB.log fileC.log
touch app.log app1.log app2.log error.log
mkdir dir1 dir2 dirA
```

---

## 1️⃣ `*` — Match ANY number of characters

### Concept

Matches **zero or more characters**

### Exercises

```bash
ls *
ls *.txt
ls *.log
ls file*
ls app*
```

### Expected understanding

* `*` expands **before** command runs
* Matches filenames, not file content

---

## 2️⃣ `?` — Match EXACTLY ONE character

### Concept

Matches **one and only one** character

### Exercises

```bash
ls file?.txt
ls app?.log
ls dir?
```

### Try and think

```bash
ls file??.txt
```

Why does `file10.txt` match?

---

## 3️⃣ `[abc]` — Match ONE character from a set

### Concept

Matches **any ONE** character inside brackets

### Exercises

```bash
ls file[12].txt
ls file[A-Z].txt
ls dir[12]
```

### Practical DevOps usage

```bash
rm app[12].log
```

Deletes `app1.log` and `app2.log`

---

## 4️⃣ `[a-z]` — Match a RANGE

### Concept

Alphabetical or numeric range

### Exercises

```bash
ls file[a-z].txt
ls file[0-9].txt
ls dir[a-z]
```

---

## 5️⃣ `[!abc]` — NEGATION (NOT match)

### Concept

Matches anything **NOT** in brackets

### Exercises

```bash
ls file[!1].txt
ls file[!0-9].txt
ls *.log
ls [!a]*.log
```

---

## 6️⃣ `{}` — Brace Expansion (NOT globbing, but related)

⚠️ Happens **before globbing**

### Exercises

```bash
touch {dev,stage,prod}.env
ls *.env
```

Multiple patterns at once:

```bash
ls file{1,2}.txt
```

---

## 7️⃣ Combine Globs (Real-world patterns)

### Exercises

```bash
ls file[0-9]*.txt
ls app?.log
ls *[A-Z].*
```

---

## 8️⃣ Recursive Globbing `**` (Advanced)

### Enable first

```bash
shopt -s globstar
```

### Create nested structure

```bash
mkdir -p logs/2024/app
touch logs/2024/app/app.log
```

### Exercise

```bash
ls **/*.log
```

---

## 9️⃣ Hidden Files (`.*`)

### Create hidden files

```bash
touch .env .gitignore .bashrc
```

### Exercises

```bash
ls .*
ls -a
```

⚠️ `*` does NOT match hidden files by default

---

## 🔟 Globbing with Commands (Critical DevOps Skill)

### Copy

```bash
cp *.log /tmp/
```

### Delete safely

```bash
rm -i file*.txt
```

### Count files

```bash
ls *.log | wc -l
```

---

## 1️⃣1️⃣ Quoting DISABLES Globbing (Important)

### Exercise

```bash
echo *.log
echo "*.log"
```

Explain:

* Quotes prevent shell expansion

---

## 1️⃣2️⃣ When GLOB DOES NOT MATCH

### Try

```bash
ls nomatch*
```

### Enable safer behavior

```bash
shopt -s nullglob
ls nomatch*
```

---

## 1️⃣3️⃣ Exam / Interview Questions (Very Common)

### Q1

What is the difference between `*` and `?`?

### Q2

Why does `rm *.log` sometimes delete too much?

### Q3

Why doesn’t `ls *` show `.env`?

### Q4

Difference between `{}` and `[]`?

---

## 1️⃣4️⃣ Mini Lab (Assignment)

1. Delete all `.log` files **except** `error.log`
2. List only files ending with numbers
3. Copy only `file1.txt` and `file2.txt` using ONE command
4. List everything except `.txt` files

---

## 1️⃣5️⃣ Real DevOps Usage Examples

```bash
kubectl logs pod-* 
aws s3 rm s3://bucket/logs/2024/*
scp app*.jar server:/opt/apps/
```

---

## ✅ Summary Table

| Pattern  | Meaning        |
| -------- | -------------- |
| `*`      | Any characters |
| `?`      | One character  |
| `[abc]`  | One from set   |
| `[a-z]`  | Range          |
| `[!abc]` | Not in set     |
| `{a,b}`  | Expansion      |
| `**`     | Recursive      |
| `.*`     | Hidden files   |









# `find` Command — `?` Meaning & Exercises (Ubuntu)

## 1️⃣ What does `?` mean in `find`?

👉 **`?` is a wildcard that matches EXACTLY ONE character**
It is used inside `-name` or `-iname`.

Important:

* `?` is evaluated by **find**, not by the shell
* It matches **one character only**

---

## 2️⃣ Setup (Run Once)

```bash
mkdir ~/find-lab
cd ~/find-lab
touch file1.txt file2.txt file10.txt fileA.txt fileB.log
mkdir dir1 dir2 dir10
```

---

## 3️⃣ Basic `find` with `?`

### Find files with ONE character after `file`

```bash
find . -name "file?.txt"
```

✔ Matches:

* `file1.txt`
* `file2.txt`
* `fileA.txt`

❌ Does NOT match:

* `file10.txt` (because `10` = two characters)

---

## 4️⃣ Compare `?` vs `*` (Very Important)

### Using `?`

```bash
find . -name "file?.txt"
```

### Using `*`

```bash
find . -name "file*.txt"
```

Difference:

* `?` → exactly **1** character
* `*` → **any number** of characters

---

## 5️⃣ `?` with directories

```bash
find . -type d -name "dir?"
```

✔ Matches:

* `dir1`
* `dir2`

❌ Does NOT match:

* `dir10`

---

## 6️⃣ Multiple `?` characters

```bash
find . -name "file??.txt"
```

✔ Matches:

* `file10.txt`

Explanation:

* `??` = exactly **two characters**

---

## 7️⃣ Case-Insensitive search (`-iname`)

```bash
find . -iname "file?.txt"
```

Matches:

* `fileA.txt`
* `filea.txt` (if exists)

---

## 8️⃣ Real DevOps-style exercises

### 1️⃣ Find log files with one-digit version

```bash
find /var/log -name "app?.log"
```

---

### 2️⃣ Delete files carefully using `?`

```bash
find . -name "file?.txt" -delete
```

⚠ Deletes only:

* `file1.txt`
* `file2.txt`
* `fileA.txt`

---

### 3️⃣ Count files matching `?`

```bash
find . -name "file?.txt" | wc -l
```

---

### 4️⃣ Combine `?` with type

```bash
find . -type f -name "file?.*"
```

---

## 9️⃣ Common Mistake (Interview Question)

❌ WRONG:

```bash
find . -name file?.txt
```

✔ CORRECT:

```bash
find . -name "file?.txt"
```

Why?

* Without quotes, shell may expand `?` before `find` runs

---

## 🔟 Interview Questions

**Q1:** Difference between `?` in `ls` and `find`?
**Answer:**

* `ls` → shell expands
* `find` → find evaluates pattern

**Q2:** Why does `file10.txt` not match `file?.txt`?
**Answer:**
Because `?` matches exactly one character

---

## ✅ Summary

| Pattern | Meaning                  |
| ------- | ------------------------ |
| `?`     | Exactly one character    |
| `??`    | Exactly two characters   |
| `*`     | Any number of characters |








# `head` and `tail` Commands — Full Explanation + Exercises

## 1️⃣ What is `head`?

👉 `head` shows the **first lines** of a file.

### Default behavior

```bash
head file.txt
```

✔ Shows **first 10 lines**

---

## 2️⃣ What is `tail`?

👉 `tail` shows the **last lines** of a file.

### Default behavior

```bash
tail file.txt
```

✔ Shows **last 10 lines**

---

## 3️⃣ Setup (Run Once)

```bash
mkdir ~/head-tail-lab
cd ~/head-tail-lab
seq 1 50 > numbers.txt
```

This file has **50 lines**.

---

## 4️⃣ `head` Exercises

### Show first 5 lines

```bash
head -n 5 numbers.txt
```

### Show first 1 line

```bash
head -n 1 numbers.txt
```

### Shortcut

```bash
head -5 numbers.txt
```

---

## 5️⃣ `tail` Exercises

### Show last 5 lines

```bash
tail -n 5 numbers.txt
```

### Show last line only

```bash
tail -n 1 numbers.txt
```

---

## 6️⃣ `tail -f` (VERY IMPORTANT for DevOps)

👉 Follow a file in real time

### Terminal 1

```bash
tail -f numbers.txt
```

### Terminal 2

```bash
echo "new log line" >> numbers.txt
```

You will see output **instantly**.

Used for:

* Logs
* Kubernetes
* Application debugging

---

## 7️⃣ `tail -n +NUMBER` (Start from line)

```bash
tail -n +10 numbers.txt
```

✔ Shows from **line 10 till end**

---

## 8️⃣ Combine `head` and `tail`

### Get line 10 only

```bash
head -n 10 numbers.txt | tail -n 1
```

### Get lines 10–15

```bash
head -n 15 numbers.txt | tail -n 6
```

---

## 9️⃣ Real DevOps Log Examples

### View last 50 lines of syslog

```bash
tail -n 50 /var/log/syslog
```

### Follow Docker logs

```bash
docker logs -f container_name
```

### Follow Kubernetes pod logs

```bash
kubectl logs -f pod-name
```

---

## 🔟 Common Interview Questions

### Q1

What is difference between `tail` and `tail -f`?

**Answer:**

* `tail` → static output
* `tail -f` → live streaming

---

### Q2

How to get only the first line of a file?

```bash
head -n 1 file.txt
```

---

### Q3

How to get last line only?

```bash
tail -n 1 file.txt
```

---

## 1️⃣1️⃣ Mini Lab (Homework)

1. Create a file with 100 lines
2. Print first 20 lines
3. Print last 15 lines
4. Show line number 50
5. Follow file while adding new lines

---

## ✅ Summary Table

| Command      | Purpose           |
| ------------ | ----------------- |
| `head`       | First lines       |
| `head -n N`  | First N lines     |
| `tail`       | Last lines        |
| `tail -n N`  | Last N lines      |
| `tail -f`    | Follow live logs  |
| `tail -n +N` | Start from line N |








# `wc` (Word Count) — Full Explanation + Exercises

## 1️⃣ What is `wc`?

👉 `wc` = **word count**
Used to count:

* lines
* words
* characters / bytes

---

## 2️⃣ `wc` Output Explained

```bash
wc file.txt
```

Output format:

```text
LINES  WORDS  BYTES  filename
```

Example:

```text
50  50  141  file.txt
```

---

## 3️⃣ Setup (Run Once)

```bash
mkdir ~/wc-lab
cd ~/wc-lab
seq 1 20 > numbers.txt
echo "hello linux devops world" > text.txt
```

---

## 4️⃣ `wc -l` — Line Count (Most Used)

```bash
wc -l numbers.txt
```

✔ Counts number of lines

---

## 5️⃣ `wc -w` — Word Count

```bash
wc -w text.txt
```

Counts words separated by spaces

---

## 6️⃣ `wc -c` — Byte Count

```bash
wc -c text.txt
```

Counts bytes (includes newline)

---

## 7️⃣ `wc -m` — Character Count

```bash
wc -m text.txt
```

Better for multi-byte characters (UTF-8)

---

## 8️⃣ Using `wc` with Pipes (Very Important)

### Count files

```bash
ls | wc -l
```

### Count log lines

```bash
tail -n 100 /var/log/syslog | wc -l
```

### Count matching lines

```bash
grep error /var/log/syslog | wc -l
```

---

## 9️⃣ Real DevOps Use Cases

### 1️⃣ Count running pods

```bash
kubectl get pods | wc -l
```

### 2️⃣ Count files in directory

```bash
find . -type f | wc -l
```

### 3️⃣ Count users

```bash
cat /etc/passwd | wc -l
```

---

## 🔟 Common Mistakes

❌ Thinking `lc` exists
✔ Correct is:

```bash
wc -l
```

❌ Forgetting pipes

```bash
ls wc -l   # wrong
ls | wc -l # correct
```

---

## 1️⃣1️⃣ Mini Lab (Homework)

1. Count lines in `/etc/passwd`
2. Count words in a file you create
3. Count number of `.log` files
4. Count how many users have `/bin/bash`
5. Count errors in syslog

---

## 1️⃣2️⃣ Interview Questions

**Q1:** Difference between `wc -c` and `wc -m`
**Answer:**

* `-c` → bytes
* `-m` → characters

**Q2:** How to count output lines of a command?
**Answer:**
Use pipe:

```bash
command | wc -l
```

---

## ✅ Summary Table

| Option  | Meaning             |
| ------- | ------------------- |
| `wc`    | Lines, words, bytes |
| `wc -l` | Line count          |
| `wc -w` | Word count          |
| `wc -c` | Byte count          |
| `wc -m` | Character count     |










# File Size Determination — Exercises (Ubuntu)

## 1️⃣ Setup (Run Once)

```bash
mkdir ~/file-size-lab
cd ~/file-size-lab
echo "hello world" > small.txt
seq 1 1000 > numbers.txt
dd if=/dev/zero of=bigfile.bin bs=1M count=5
mkdir logs
cp numbers.txt logs/
```

---

## 2️⃣ `ls -lh` — Human-readable size (Most common)

### Exercise

```bash
ls -lh
```

✔ Shows file sizes in:

* B
* KB
* MB
* GB

### Questions

* Which file is the largest?
* What size is `bigfile.bin`?

---

## 3️⃣ `du -h` — Disk usage (Real storage used)

### Exercise

```bash
du -h
```

### File only

```bash
du -h small.txt
```

### Directory size

```bash
du -h logs/
```

### Summary only

```bash
du -sh logs/
```

✔ `du` = how much disk space is actually used

---

## 4️⃣ `stat` — Exact size in bytes (Interview favorite)

### Exercise

```bash
stat numbers.txt
```

Look for:

```text
Size: 3893
```

✔ Most accurate size info

---

## 5️⃣ `wc -c` — Size in bytes (Content-based)

### Exercise

```bash
wc -c small.txt
```

✔ Counts bytes including newline

Compare with:

```bash
stat small.txt
```

---

## 6️⃣ Compare Commands (Important Concept)

| Command  | What it shows  |
| -------- | -------------- |
| `ls -lh` | Display size   |
| `du -h`  | Disk usage     |
| `stat`   | Exact metadata |
| `wc -c`  | Content size   |

---

## 7️⃣ Find Files Bigger Than X Size

### Bigger than 1MB

```bash
find . -type f -size +1M
```

### Smaller than 1KB

```bash
find . -type f -size -1k
```

---

## 8️⃣ Sort Files by Size

### Largest first

```bash
ls -lhS
```

### Smallest first

```bash
ls -lhrS
```

---

## 9️⃣ Real DevOps Exercises

### 1️⃣ Find large log files

```bash
find /var/log -type f -size +100M
```

### 2️⃣ Check directory disk usage

```bash
du -sh /var/log
```

### 3️⃣ Monitor growing file

```bash
watch -n 1 ls -lh bigfile.bin
```

---

## 🔟 Common Mistakes (Interview)

❌ Using `ls` to check disk usage
✔ Use `du` for actual disk usage

❌ Confusing bytes vs blocks
✔ `stat` is the source of truth

---

## 1️⃣1️⃣ Mini Lab (Homework)

1. Create a file of **10MB**
2. Show its size using **4 different commands**
3. Find files larger than **1MB**
4. Sort files by size
5. Check disk usage of a directory

---

## 1️⃣2️⃣ Interview Questions

**Q1:** Difference between `ls -lh` and `du -h`?
**Answer:**

* `ls` → file size
* `du` → disk blocks used

**Q2:** Which command gives exact size in bytes?
**Answer:**
`stat`

---

## ✅ Summary Cheat Sheet

```bash
ls -lh file
du -sh file_or_dir
stat file
wc -c file
find . -size +10M
```








# Output Redirection Exercises — `>` and `>>`

## 1️⃣ What are `>` and `>>`?

| Operator | Meaning                                |
| -------- | -------------------------------------- |
| `>`      | Redirect output and **overwrite** file |
| `>>`     | Redirect output and **append** to file |

---

## 2️⃣ Setup (Run Once)

```bash
mkdir ~/redirect-lab
cd ~/redirect-lab
```

---

## 3️⃣ `>` — Overwrite Redirection

### Exercise 1

```bash
echo "Hello DevOps" > output.txt
cat output.txt
```

✔ File created

---

### Exercise 2 (Overwrite)

```bash
echo "Linux is powerful" > output.txt
cat output.txt
```

❗ Previous content is **deleted**

---

## 4️⃣ `>>` — Append Redirection

### Exercise 3

```bash
echo "Line 1" >> output.txt
echo "Line 2" >> output.txt
cat output.txt
```

✔ Content is **added**, not replaced

---

## 5️⃣ Real Difference Test (Very Important)

```bash
echo "START" > test.txt
echo "APPEND" >> test.txt
echo "OVERWRITE" > test.txt
cat test.txt
```

Expected result:

```text
OVERWRITE
```

---

## 6️⃣ Redirect Command Output

### Save `ls` output

```bash
ls > files.txt
```

### Append more output

```bash
ls /etc >> files.txt
```

---

## 7️⃣ Redirect Errors (stderr)

### Error without redirect

```bash
ls not_exist
```

### Redirect error

```bash
ls not_exist 2> error.txt
```

### Append error

```bash
ls not_exist 2>> error.txt
```

---

## 8️⃣ Redirect Both Output and Error

```bash
ls /etc not_exist > all.txt 2>&1
```

---

## 9️⃣ Discard Output (Production Trick)

```bash
ls not_exist > /dev/null
ls not_exist 2> /dev/null
ls not_exist > /dev/null 2>&1
```

---

## 🔟 Combine with `wc`, `tail`, `grep`

### Count lines and save

```bash
ls /etc | wc -l > count.txt
```

### Append logs

```bash
date >> app.log
```

---

## 1️⃣1️⃣ Real DevOps Examples

### Log rotation simulation

```bash
echo "$(date) App started" >> app.log
```

### Save command result in script

```bash
df -h > disk_report.txt
```

---

## 1️⃣2️⃣ Common Mistakes (Interview)

❌ Using `>` instead of `>>` → data loss
❌ Forgetting `2>` for errors
❌ Overwriting log files accidentally

---

## 1️⃣3️⃣ Mini Lab (Homework)

1. Create `report.txt` using `>`
2. Append 5 lines using `>>`
3. Save `ls /etc` output
4. Save errors separately
5. Discard output using `/dev/null`

---

## 1️⃣4️⃣ Interview Questions

**Q1:** Difference between `>` and `>>`
**Answer:**

* `>` overwrites
* `>>` appends

**Q2:** How to redirect error only?
**Answer:**

```bash
2>
```

---

## ✅ Summary Cheat Sheet

```bash
command > file
command >> file
command 2> error.txt
command > all.txt 2>&1
command > /dev/null
```







# `tee` Command — Exercises & Explanation

## 1️⃣ What is `tee`?

👉 `tee` **reads from standard input** and **writes to**:

* the **screen**
* and **one or more files** at the same time

Think of it as a **splitter**.

```
command | tee file.txt
```

---

## 2️⃣ Setup (Run Once)

```bash
mkdir ~/tee-lab
cd ~/tee-lab
```

---

## 3️⃣ Basic `tee` Exercise

### Write output to screen AND file

```bash
echo "Hello DevOps" | tee output.txt
```

Check:

```bash
cat output.txt
```

---

## 4️⃣ `tee -a` (Append Mode)

### Overwrite vs append

```bash
echo "Line 1" | tee output.txt
echo "Line 2" | tee -a output.txt
```

✔ `-a` = append
❌ Without `-a` = overwrite

---

## 5️⃣ `tee` vs `>` (Important Difference)

### Using `>`

```bash
ls > files.txt
```

❌ No output on screen

### Using `tee`

```bash
ls | tee files.txt
```

✔ Output shown AND saved

---

## 6️⃣ Multiple Files with `tee`

```bash
echo "Shared log line" | tee file1.log file2.log
```

---

## 7️⃣ `tee` in Pipelines

### Count and save

```bash
ls | tee list.txt | wc -l
```

### Analyze logs

```bash
grep error /var/log/syslog | tee errors.txt | wc -l
```

---

## 8️⃣ `sudo` + `tee` (VERY IMPORTANT)

### Problem

```bash
sudo echo "text" > /root/test.txt   # fails
```

### Solution

```bash
echo "text" | sudo tee /root/test.txt
```

### Append with sudo

```bash
echo "more text" | sudo tee -a /root/test.txt
```

---

## 9️⃣ Real DevOps Use Cases

### Save disk report

```bash
df -h | tee disk_report.txt
```

### Capture install logs

```bash
sudo apt update | tee update.log
```

### Kubernetes debugging

```bash
kubectl logs pod-name | tee pod.log
```

---

## 🔟 Common Mistakes

❌ Forgetting `-a` → overwrites logs
❌ Using `>` with sudo
❌ Thinking `tee` replaces pipes

---

## 1️⃣1️⃣ Mini Lab (Homework)

1. Save `ls` output and still see it
2. Append 5 lines to a log file
3. Write output to two files
4. Save error logs and count them
5. Write to a protected file using sudo

---

## 1️⃣2️⃣ Interview Questions

**Q1:** Why use `tee` instead of `>`?
**Answer:**
To **see output and save it** at the same time.

**Q2:** Why does `sudo echo text > file` fail?
**Answer:**
Redirection happens **before sudo**.

---

## ✅ Summary Cheat Sheet

```bash
command | tee file.txt
command | tee -a file.txt
command | tee file1 file2
command | sudo tee /path/file
```









# `uniq` and `grep` — Exercises & Explanation

## 1️⃣ What is `grep`?

👉 `grep` **searches for patterns** in text.

Basic syntax:

```bash
grep PATTERN file
```

---

## 2️⃣ What is `uniq`?

👉 `uniq` **removes or analyzes duplicate lines**
⚠️ Important: **`uniq` works only on adjacent lines** → usually needs `sort` first.

---

## 3️⃣ Setup (Run Once)

```bash
mkdir ~/grep-uniq-lab
cd ~/grep-uniq-lab

cat <<EOF > logs.txt
error disk full
info service started
warning cpu high
error disk full
error network down
info service started
EOF
```

---

## 4️⃣ `grep` — Basic Exercises

### Find lines containing `error`

```bash
grep error logs.txt
```

---

### Case-insensitive search

```bash
grep -i ERROR logs.txt
```

---

### Show line numbers

```bash
grep -n error logs.txt
```

---

### Count matching lines

```bash
grep -c error logs.txt
```

---

### Search multiple patterns

```bash
grep -E "error|warning" logs.txt
```

---

## 5️⃣ `grep` — Inverted Match (`-v`)

### Show lines WITHOUT `info`

```bash
grep -v info logs.txt
```

Used a lot in log filtering.

---

## 6️⃣ `grep` with Pipes (Real Usage)

### Find errors in last 100 log lines

```bash
tail -n 100 /var/log/syslog | grep error
```

### Count errors

```bash
grep error logs.txt | wc -l
```

---

## 7️⃣ `uniq` — Basic (Important Rule)

### ❌ Wrong (no effect)

```bash
uniq logs.txt
```

Why?
👉 Duplicates are **not adjacent**

---

## 8️⃣ `sort` + `uniq` (Correct Way)

### Remove duplicates

```bash
sort logs.txt | uniq
```

---

### Count duplicate lines

```bash
sort logs.txt | uniq -c
```

Output example:

```text
2 error disk full
2 info service started
1 warning cpu high
```

---

## 9️⃣ `uniq` Options (Very Important)

### Show only duplicates

```bash
sort logs.txt | uniq -d
```

### Show only unique (non-duplicate)

```bash
sort logs.txt | uniq -u
```

---

## 🔟 Combine `grep` + `uniq`

### Unique error messages

```bash
grep error logs.txt | sort | uniq
```

---

### Count unique errors

```bash
grep error logs.txt | sort | uniq -c
```

---

## 1️⃣1️⃣ Real DevOps Examples

### Count unique IPs

```bash
grep "GET" access.log | awk '{print $1}' | sort | uniq -c
```

### Unique Kubernetes errors

```bash
kubectl logs pod-name | grep error | sort | uniq -c
```

---

## 1️⃣2️⃣ Common Mistakes (Interview)

❌ Using `uniq` without `sort`
❌ Forgetting `-i` for case-insensitive search
❌ Using `grep` instead of `grep -v`

---

## 1️⃣3️⃣ Mini Lab (Homework)

1. Find all `error` lines
2. Count how many times each error appears
3. Show unique log messages
4. Exclude `info` messages
5. Find warnings OR errors

---

## 1️⃣4️⃣ Interview Questions

**Q1:** Why doesn’t `uniq` remove all duplicates?
**Answer:**
Because it works only on **adjacent lines**

---

**Q2:** Difference between `grep error` and `grep -v error`?
**Answer:**

* `grep error` → matches
* `grep -v error` → excludes

---

## ✅ Summary Cheat Sheet

```bash
grep pattern file
grep -i pattern file
grep -v pattern file
grep -c pattern file

sort file | uniq
sort file | uniq -c
sort file | uniq -d
```








# `PATH` Environment Variable — Explanation & Exercises

## 1️⃣ What is `PATH`?

👉 `PATH` is a **colon-separated list of directories**.
When you type a command, Linux searches these directories **in order**.

Example:

```bash
echo $PATH
```

Output looks like:

```text
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

---

## 2️⃣ Why `PATH` Matters (Real Meaning)

When you run:

```bash
ls
```

Linux actually checks:

```
/usr/local/sbin/ls
/usr/local/bin/ls
/usr/sbin/ls
/usr/bin/ls   ✅ found here
```

---

## 3️⃣ Setup (Run Once)

```bash
mkdir -p ~/path-lab/bin
cd ~/path-lab/bin
```

Create a custom command:

```bash
echo -e '#!/bin/bash\necho "Hello from custom command"' > hello
chmod +x hello
```

---

## 4️⃣ Command NOT in PATH

Try running:

```bash
hello
```

❌ Command not found

Run with full path:

```bash
~/path-lab/bin/hello
```

✔ Works

---

## 5️⃣ Temporarily Add to `PATH`

```bash
export PATH=$PATH:$HOME/path-lab/bin
```

Now run:

```bash
hello
```

✔ Works without full path

⚠️ This change lasts **only for this terminal session**

---

## 6️⃣ Check Where Command Comes From

```bash
which ls
```

```bash
which hello
```

Shows **exact path** of the command being used.

---

## 7️⃣ Order of PATH (VERY IMPORTANT)

Create another command:

```bash
echo -e '#!/bin/bash\necho "Fake ls command"' > ls
chmod +x ls
```

Run:

```bash
ls
```

Why didn’t it run your fake one?

👉 Because your directory is **after** `/usr/bin`

---

## 8️⃣ Put Directory FIRST in PATH (Danger Demo)

```bash
export PATH=$HOME/path-lab/bin:$PATH
```

Now:

```bash
ls
```

⚠️ Your fake `ls` runs!

👉 **Security risk** — interview favorite

---

## 9️⃣ Permanent PATH Change (User Only)

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
export PATH=$PATH:$HOME/path-lab/bin
```

Reload:

```bash
source ~/.bashrc
```

---

## 🔟 System-wide PATH (Admins)

```bash
/etc/profile
/etc/environment
```

⚠️ Requires sudo
⚠️ Affects all users

---

## 1️⃣1️⃣ PATH with Scripts (DevOps Use)

Script without path:

```bash
#!/bin/bash
aws s3 ls
```

If AWS CLI not in PATH → script fails

Fix:

```bash
which aws
```

Or use full path:

```bash
/usr/bin/aws s3 ls
```

---

## 1️⃣2️⃣ Common Mistakes (Interview)

❌ Overwriting PATH:

```bash
export PATH=/my/bin   # WRONG
```

✔ Correct:

```bash
export PATH=$PATH:/my/bin
```

❌ Putting `.` in PATH (security risk)

---

## 1️⃣3️⃣ Mini Lab (Homework)

1. Print your PATH
2. Create a custom command
3. Run it using full path
4. Add directory to PATH
5. Make change permanent
6. Explain PATH order

---

## 1️⃣4️⃣ Interview Questions

**Q1:** What is PATH?
**Answer:**
A list of directories where shell looks for commands

**Q2:** Why is PATH order important?
**Answer:**
First match wins → security impact

**Q3:** Difference between temporary and permanent PATH?
**Answer:**

* Temporary → `export`
* Permanent → `.bashrc`

---

## ✅ Summary Cheat Sheet

```bash
echo $PATH
export PATH=$PATH:/new/path
which command
source ~/.bashrc
```







# Bash Variables & Environment Variables

## Full Exercise Set for DevOps Engineers

---

## 1️⃣ Bash Variable (Local Variable)

### What it is

* Exists **only in current shell**
* NOT available to child processes

### Exercise

```bash
NAME="devops"
echo $NAME
```

❌ Space is not allowed:

```bash
NAME = devops   # wrong
```

---

## 2️⃣ Variable Scope Test (Very Important)

```bash
MYVAR="local"
bash
echo $MYVAR
```

❌ Output is empty
👉 Local variables do **not** pass to child shells

Exit:

```bash
exit
```

---

## 3️⃣ Environment Variable (`export`)

### What it is

* Available to **child processes**
* Used heavily in DevOps tools

### Exercise

```bash
export ENV="production"
echo $ENV
```

Test in child shell:

```bash
bash
echo $ENV
exit
```

✔ Works

---

## 4️⃣ Difference: Bash vs Env Variable

| Type                 | Child shell |
| -------------------- | ----------- |
| Local variable       | ❌ No        |
| Environment variable | ✅ Yes       |

---

## 5️⃣ List Variables

### All shell variables

```bash
set
```

### Only environment variables

```bash
env
```

or

```bash
printenv
```

---

## 6️⃣ Unset Variables

```bash
TEMP=123
unset TEMP
echo $TEMP
```

✔ Empty output

---

## 7️⃣ Read-only Variables

```bash
readonly VERSION="1.0"
VERSION="2.0"
```

❌ Permission denied

---

## 8️⃣ Command Substitution (VERY IMPORTANT)

### Store command output in variable

```bash
DATE=$(date)
echo $DATE
```

Old style (still seen):

```bash
DATE=`date`
```

---

## 9️⃣ Variable Expansion Types

### Default value

```bash
echo ${APP:-nginx}
```

### Assign default

```bash
echo ${APP:=nginx}
```

### Error if unset

```bash
echo ${APP:?APP is not set}
```

---

## 🔟 Positional Variables (Scripts)

Create script:

```bash
nano args.sh
```

```bash
#!/bin/bash
echo "Script: $0"
echo "First: $1"
echo "Second: $2"
echo "All: $@"
```

Run:

```bash
chmod +x args.sh
./args.sh dev prod
```

---

## 1️⃣1️⃣ Special Variables (INTERVIEW FAVORITE)

| Variable | Meaning             |
| -------- | ------------------- |
| `$0`     | Script name         |
| `$1..$9` | Arguments           |
| `$#`     | Number of args      |
| `$@`     | All args            |
| `$?`     | Exit code           |
| `$$`     | PID                 |
| `$!`     | Last background PID |

### Exercise

```bash
ls
echo $?
```

---

## 1️⃣2️⃣ Global Environment Files (DevOps MUST KNOW)

| File               | Scope             |
| ------------------ | ----------------- |
| `~/.bashrc`        | User, interactive |
| `~/.profile`       | Login shell       |
| `/etc/environment` | System-wide       |
| `/etc/profile`     | System-wide       |

---

## 1️⃣3️⃣ Permanent Environment Variable

### User-level

```bash
echo 'export APP_ENV=prod' >> ~/.bashrc
source ~/.bashrc
```

---

## 1️⃣4️⃣ Environment Variables in Scripts

```bash
#!/bin/bash
echo "Deploying to $APP_ENV"
```

Run:

```bash
APP_ENV=stage ./script.sh
```

---

## 1️⃣5️⃣ Inline Environment Variable (VERY COMMON)

```bash
DB_HOST=localhost DB_PORT=5432 ./app.sh
```

✔ Variable exists **only for this command**

---

## 1️⃣6️⃣ `.env` File (Real DevOps Pattern)

Create:

```bash
nano .env
```

```bash
DB_USER=admin
DB_PASS=secret
```

Load:

```bash
export $(cat .env | xargs)
```

Use:

```bash
echo $DB_USER
```

---

## 1️⃣7️⃣ PATH Variable (Critical)

```bash
echo $PATH
export PATH=$PATH:/custom/bin
```

⚠ Never overwrite PATH

---

## 1️⃣8️⃣ DevOps Tool Examples

### Docker

```bash
export DOCKER_BUILDKIT=1
```

### Kubernetes

```bash
export KUBECONFIG=~/.kube/config
```

### AWS

```bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy
export AWS_DEFAULT_REGION=us-east-1
```

---

## 1️⃣9️⃣ Security Best Practices (IMPORTANT)

❌ Never hardcode secrets:

```bash
DB_PASS=admin123
```

✔ Use env vars or secret managers

✔ `.env` → add to `.gitignore`

---

## 2️⃣0️⃣ Mini DevOps Lab (Homework)

1. Create local variable and test scope
2. Export env variable and test child shell
3. Create script using positional parameters
4. Use `$?` to check command success
5. Load variables from `.env`
6. Set permanent env variable
7. Use inline env variable

---

## 2️⃣1️⃣ Interview Questions (REAL)

**Q:** Difference between `set` and `env`
**A:**

* `set` → shell variables
* `env` → environment variables

**Q:** Why use env vars in DevOps?
**A:**
For configuration, secrets, portability

**Q:** How do you pass env vars to Docker/K8s?
**A:**
Environment variables or secret managers

---

## ✅ Final Cheat Sheet

```bash
VAR=value
export VAR=value
unset VAR
readonly VAR=value
VAR=$(command)
echo $?
env
set
```


