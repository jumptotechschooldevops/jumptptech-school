---
title: "Jenkins Runs Commands For Me"
description: "Before Jenkins:   Engineer runs commands manually Forgets steps Makes mistakes Cannot repeat..."
published: 2026-02-06
source: "https://dev.to/jumptotech/jenkins-runs-commands-for-me-1e68"
tags: []
---

# Jenkins Runs Commands For Me








Before Jenkins:

* Engineer runs commands manually
* Forgets steps
* Makes mistakes
* Cannot repeat reliably

With Jenkins:

* Commands are written **once**
* Jenkins runs them **the same way every time**
* Anyone can click **Build Now**

---

## 🛠 Task Rules (IMPORTANT)

* ❌ No copy–paste
* ✅ Students **type each line**
* ✅ After each line, explain **why it exists**

---

## 🧩 Step 1: Create Freestyle Job

1. Open Jenkins:
   `http://localhost:9090`

2. Click **New Item**

3. Job name:

```
devops-first-script
```

4. Select **Freestyle project**
5. Click **OK**

---

## 🧩 Step 2: Add Shell Build Step

* Scroll to **Build**
* Click **Add build step**
* Choose **Execute shell**

---

## ✍️ Step 3:  Write This Script (Line by Line)

### Line 1

```bash
echo "Hello from Jenkins"
```

### Why?

* `echo` prints text
* Proves Jenkins can **execute commands**
* First validation Jenkins is working

---

### Line 2

```bash
whoami
```

### Why?

* Shows **which user** Jenkins runs as
* Important for permissions (DevOps reality)
* Explains why some commands fail later

---

### Line 3

```bash
pwd
```

### Why?

* Shows **where Jenkins runs**
* Introduces the concept of **workspace**
* Jenkins does NOT run in your home folder

---

### Line 4

```bash
ls
```

### Why?

* Lists files in workspace
* Shows workspace starts **empty**
* Important before cloning repos later

---

### Line 5

```bash
echo "This file was created by Jenkins" > jenkins.txt
```

### Why?

* Jenkins creates files just like a human
* Demonstrates automation creates artifacts
* `>` redirects output into a file

---

### Line 6

```bash
cat jenkins.txt
```

### Why?

* Confirms file exists
* Verifies Jenkins work visually
* Basic troubleshooting skill

---

### Line 7

```bash
echo "Script completed successfully"
```

### Why?

* Clear log message
* Professional habit in CI/CD
* Helps debugging later

---

## ▶️ Step 4: Run the Job

* Click **Save**
* Click **Build Now**
* Open **Console Output**

---

## ✅ What  Should See

* Text printed
* Username
* Jenkins workspace path
* File created
* File content displayed

---

## 🧠 DevOps Concepts They Just Learned

| Concept       | Meaning                  |
| ------------- | ------------------------ |
| Jenkins job   | Automation task          |
| Workspace     | Safe execution directory |
| Shell step    | Real Linux commands      |
| Logs          | Debugging source         |
| Repeatability | Same result every time   |

---

MANDATORY



```bash
exit 1
```

### Ask them:

> “What do you think will happen?”

Then run again.

---

## ❌ Result

* Build turns **RED**
* Jenkins stops
* No further steps run

### Why?

* `exit 1` = failure
* Jenkins trusts exit codes
* This is how bad code blocks deployments

---



> “Jenkins is stupid but honest.
> If a command fails, Jenkins stops everything.”

That’s **real DevOps**.


