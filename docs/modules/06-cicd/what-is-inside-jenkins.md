---
title: "what is inside Jenkins"
description: "🔹 LEFT SIDE MENU               ➕ New Item            What:   Create new job.          ..."
published: 2026-02-12
source: "https://dev.to/jumptotech/what-is-inside-jenkins-2f1p"
tags: []
---

# what is inside Jenkins


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/bla5ognjlcyftjim39q9.png)




# 🔹 LEFT SIDE MENU

---

## ➕ New Item

### What:

Create new job.

### Types you can create:

* Freestyle project
* Pipeline
* Multibranch Pipeline
* Folder
* Organization Folder

### When to use:

DevOps:

* Creates Pipeline jobs
* Creates folder structure (prod/dev)
* Creates multibranch for GitHub repos

---

## Build History

### What:

Shows all builds across all jobs.

### When used:

• Debug past failures
• Audit who deployed
• Rollback investigation

Production:
Very important for audit tracking.

---

## Project Relationship

### What:

Shows upstream/downstream job relationships.

Example:
Job A → triggers → Job B

Used in:

* Microservice pipelines
* Deployment chains

---

## Check File Fingerprint

### What:

Tracks artifact usage.

Example:
Which build produced this artifact?

Used in:

* Artifact traceability
* Compliance
* Large enterprises

---

# 🔹 BUILD QUEUE

Shows builds waiting to run.

If busy:
→ Means agents are overloaded.

DevOps uses this to:

* Add more agents
* Debug stuck jobs

---

# 🔹 BUILD EXECUTOR STATUS

This is VERY important.

Shows:

### Built-In Node (0/2)

Means:

* 0 running
* 2 executors available

Executors = parallel job slots.

---

### linux (offline)

Agent is disconnected.

DevOps must:

* Fix SSH
* Restart agent
* Check logs

---

### mac-agent (0/1)

1 executor, currently idle.

---

### node-mac1 (0/1)

Idle Mac agent.

---

# 🔹 CENTER TABLE (MAIN JOB LIST)

Columns:

| S | W | Name | Last Success | Last Failure | Last Duration | Coverage |

Let’s break everything.

---

# 🔹 COLUMN: S

### S = Status

Icons meaning:

🟢 Green check → Last build successful
🔴 Red X → Last build failed
🔵 Blue circle → Never built
☀️ Sun icon → Pipeline job
☁️ Cloud icon → Multibranch job

When DevOps looks:
First thing → check S column.

Red = investigate.

---

# 🔹 COLUMN: W

### W = Weather

Indicates build stability trend.

☀️ Sunny → Stable
⛅ Partly cloudy → Some failures
🌧 Rain → Many failures
☁️ Cloud → New job

Used to:
See overall health trend quickly.

Interview favorite topic.

---

# 🔹 COLUMN: Name

Clickable job name.

Click opens:

* Console output
* Configure
* Build history
* Replay
* Pipeline view

---

# 🔹 COLUMN: Last Success

Example:
`2 days 22 hr #8`

Means:

* Last successful build was build #8
* Ran 2 days ago

Used to:
Check deployment freshness.

---

# 🔹 COLUMN: Last Failure

Shows:
Last failed build number.

If recent:
Needs investigation.

---

# 🔹 COLUMN: Last Duration

How long build took.

Used to:

* Detect performance issues
* Identify slow builds
* Capacity planning

If build suddenly jumps from 2 min → 20 min → investigate.

---

# 🔹 COLUMN: Coverage

If test coverage plugin installed.

Shows:
Code coverage percentage.

Used in:
Quality gates.

---

# 🔹 RIGHT SIDE PLAY BUTTON ▶️

Manual build trigger.

Used when:

* Testing pipeline
* Re-running after fix
* Emergency deployment

---

# 🔹 JOB TYPES (Based on Icons)

Looking at your screenshot:

---

### basic-pipeline ☀️

Sun icon → Pipeline job.

---

### devops-beginner-lab ☁️

Cloud icon → Multibranch pipeline.

Usually connected to GitHub repo.

---

### eks-text 🔴

Red status → failed last build.

DevOps should:
Click → Console Output → Debug.

---

### netflix1 🔵

Blue circle → never built.

---

# 🔹 ICONS AT BOTTOM: S M L

This changes icon size:

* S = Small
* M = Medium
* L = Large

Only UI preference.

---

# 🔥 HOW DEVOPS USES THIS PAGE DAILY

Morning routine:

1. Open Jenkins dashboard
2. Look at S column
3. Check for red builds
4. Check Build Queue
5. Check agent status
6. Monitor trends (W column)
7. Check build duration spikes

---

# 🔥 WHAT INTERVIEWERS EXPECT YOU TO SAY

If asked:
“What do you monitor on Jenkins dashboard?”

Answer:

• Build health
• Agent availability
• Queue size
• Build duration trends
• Success/failure rates
• Deployment recency
• Code coverage

That shows senior understanding.

---

# 🔥 WHEN TO USE EACH SECTION

| Section              | When Used             |
| -------------------- | --------------------- |
| New Item             | Creating new pipeline |
| Build History        | Debugging failures    |
| Project Relationship | Multi-job chaining    |
| Build Queue          | Capacity issue        |
| Executor Status      | Agent problem         |
| S column             | Quick health check    |
| W column             | Stability trend       |
| Last Duration        | Performance issue     |
| Play button          | Manual trigger        |

---

# 🔥 Production-Level Behavior

If:

* Queue growing → scale agents
* Agent offline → fix SSH or Kubernetes
* Frequent failures → review pipeline logic
* Long duration → optimize build
* No recent success → deployment stale










![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/thjxxg9hzm85uczx9c9x.png)






 This is **Manage Jenkins** page — this is the *brain control panel* of Jenkins.

As a DevOps engineer (especially with 6+ years), you must clearly understand what each section does.



# 🔹 SYSTEM CONFIGURATION

---

## 1️⃣ System

### What it is:

Global Jenkins configuration page.

### Why we use it:

To configure core Jenkins behavior.

### What you find inside:

* Jenkins URL
* Number of executors
* Environment variables
* Email configuration (SMTP)
* GitHub server settings
* Global properties
* Quiet period
* Build discarders
* Global pipeline libraries (important!)
* Slack configuration

### In Production:

DevOps uses this to:

* Configure Jenkins URL (behind ALB or NGINX)
* Setup email notifications
* Set global environment variables
* Set up shared libraries
* Configure webhook integrations

---

## 2️⃣ Tools

### What it is:

Defines tool installations Jenkins can use.

### Why:

So pipelines can use tools consistently.

### What inside:

* JDK
* Git
* Maven
* Gradle
* Docker
* NodeJS
* Terraform (if plugin installed)

You can:

* Auto-install tools
* Define tool versions
* Set paths

### Production usage:

DevOps ensures:

* Correct Java version
* Specific Maven version
* Git version compatibility
* Docker CLI availability

Prevents “works locally but fails in Jenkins”.

---

## 3️⃣ Plugins

### What it is:

Jenkins extension marketplace.

### Why:

Jenkins core is minimal. Plugins add power.

### What you manage:

* Install plugins
* Update plugins
* Disable plugins
* Remove plugins

Common Production Plugins:

* Pipeline
* Git
* GitHub
* Docker Pipeline
* Kubernetes
* AWS
* Blue Ocean
* Credentials Binding
* Slack
* SonarQube
* Artifactory
* Role-based authorization

### Production:

DevOps:

* Carefully upgrades plugins
* Tests in staging
* Avoids breaking production
* Monitors plugin vulnerabilities

---

## 4️⃣ Nodes

### What it is:

Manage Jenkins agents (workers).

### Why:

Jenkins master should NOT run heavy builds.

### Inside:

* Built-in node (master)
* Add new agent
* Label agents
* Configure executors
* Monitor disk / memory

### Production:

DevOps:

* Uses EC2 agents
* Uses Kubernetes dynamic agents
* Uses Docker agents
* Labels agents (linux, docker, prod, test)

Important interview topic.

---

## 5️⃣ Clouds

### What it is:

Dynamic agent provisioning.

### Why:

Auto-create build agents when needed.

### Examples:

* Kubernetes cloud
* AWS EC2 cloud
* Azure cloud

### Production:

DevOps:

* Configure Kubernetes plugin
* Jenkins creates pod per build
* Auto scales
* No idle servers

This is modern setup.

---

## 6️⃣ Appearance

### What it is:

UI customization.

### Why:

Better UX.

### Inside:

* Themes
* Blue Ocean UI
* System message
* Layout

Production:
Not critical, but sometimes used for branding.

---

# 🔹 SECURITY SECTION

---

## 7️⃣ Security

### What it is:

Authentication & authorization config.

### Why:

Without security Jenkins is dangerous.

### Inside:

* Enable security
* LDAP integration
* GitHub OAuth
* SAML
* Matrix-based security
* Role-based access
* CSRF protection

### Production:

DevOps MUST:

* Enable authentication
* Use RBAC
* Restrict admin rights
* Disable anonymous access
* Enable CSRF

Critical for audits.

---

## 8️⃣ Credentials

### What it is:

Secrets storage.

### Why:

Never hardcode secrets in Jenkinsfile.

### Types:

* Username/password
* SSH keys
* Secret text
* AWS credentials
* Certificates

### Scope:

* Global
* Folder
* System

### Production:

DevOps stores:

* GitHub tokens
* DockerHub creds
* AWS IAM creds
* ECR login
* Kubernetes tokens

Used with:

```
withCredentials {}
```

---

## 9️⃣ Credential Providers

### What it is:

Integration with external secret systems.

### Examples:

* HashiCorp Vault
* AWS Secrets Manager
* Azure Key Vault

Production:
Used in secure enterprise setups.

---

# 🔹 STATUS INFORMATION

---

## 🔟 System Information

### What it is:

Jenkins runtime details.

### What inside:

* Java version
* OS info
* Memory usage
* Environment variables
* Installed plugins list

Production:
Used for troubleshooting.

---

## 1️⃣1️⃣ System Log

### What it is:

Jenkins logs viewer.

### Why:

Debug failures.

Shows:

* Plugin errors
* Security issues
* Thread issues
* Disk warnings

Production:
DevOps checks here when:

* Jenkins won’t start
* Plugin crashes
* Builds fail unexpectedly

---

## 1️⃣2️⃣ Load Statistics

### What it is:

Shows executor load.

### Why:

Monitor capacity.

Production:
Used to:

* Decide scaling agents
* Identify bottlenecks
* Justify infrastructure changes

---

## 1️⃣3️⃣ About Jenkins

### Shows:

* Version
* License
* Core version

Production:
Used before:

* Upgrading
* Plugin compatibility checks

---

# 🔹 TROUBLESHOOTING

Depends on plugins installed.

---

# 🔥 How DevOps Uses This Page in Real Life

In real production:

DevOps responsibilities:

1. Install Jenkins
2. Configure security
3. Add agents
4. Install plugins
5. Configure tools
6. Configure shared libraries
7. Store credentials
8. Enable backups
9. Monitor disk space
10. Upgrade safely

Developers mostly:

* Write Jenkinsfile
* Trigger builds
* Check logs

DevOps:
Owns the entire "Manage Jenkins" page.

---

# 🎯 Interview Tip

If interviewer asks:
“What does a DevOps engineer manage in Jenkins?”

You say:

• Global configuration
• Security & RBAC
• Agent scaling
• Plugin lifecycle
• Credentials management
• Backup & upgrade strategy
• Performance monitoring

That is senior-level answer.















 **Manage Jenkins → System** page (the most important global configuration page).


# 🔹 GENERAL

---

## Home directory

Default: `/var/lib/jenkins`

### What:

Where Jenkins stores:

* Jobs
* Build history
* Logs
* Plugins
* Credentials (encrypted)
* Workspace

### Why important:

If you lose this → you lose Jenkins.

### Production:

DevOps:

* Backs this up
* Mounts it to EBS/EFS
* Monitors disk usage
* Migrates this during server move

---

## System Message

### What:

Banner shown on top of Jenkins UI.

### Why:

Used for announcements.

### Production:

Used for:

* “Maintenance at 10PM”
* “Upgrade scheduled”
* “Do not run heavy builds”

---

## Computer Retention Check Interval

### What:

How often Jenkins checks if agents should be disconnected.

### Production:

Important when using:

* Dynamic EC2 agents
* Kubernetes agents

---

## Quiet Period

### What:

Delay before starting build after trigger.

Example: 5 seconds.

### Why:

Avoid triggering multiple builds from rapid commits.

### Production:

Often set to 0 or 5 seconds.

---

## SCM Checkout Retry Count

### What:

How many times to retry Git checkout if it fails.

### Why:

Network glitches happen.

### Production:

Set to 2–3 to avoid random failures.

---

## Restrict Project Naming

### What:

Controls allowed characters in job names.

### Production:

Prevents bad naming conventions.

---

# 🔹 JENKINS LOCATION

---

## Jenkins URL

### What:

Public URL of Jenkins.

Example:

```
https://jenkins.company.com
```

### Why:

Required for:

* Webhooks
* Email links
* GitHub integration

### Production:

Must be correct if behind:

* ALB
* NGINX
* Reverse proxy

---

## System Admin Email

### What:

Admin email used for system notifications.

### Production:

Used for:

* Failure alerts
* System warnings

---

## Resource Root URL

### What:

Serve static resources from CDN.

### Production:

Used in large enterprise setups.

---

# 🔹 GLOBAL PROPERTIES

---

## Environment Variables

### What:

Global variables available in all jobs.

Example:

```
ENV=prod
REGION=us-east-1
```

### Production:

Used for:

* Global configs
* Shared settings
* Proxy config

---

## Disable deferred wipeout

Advanced disk cleanup option.

Used rarely.

---

# 🔹 DISK SPACE MONITORING

Threshold warnings if disk low.

### Production:

Critical to prevent:

* Build failures
* Jenkins crash

---

# 🔹 TOOL LOCATIONS

Overrides default tool paths.

Production:
Used when:

* Tools installed manually
* Custom Docker setups

---

# 🔹 PIPELINE SPEED / DURABILITY

### Options:

* Maximum durability
* Performance optimized

### What:

Controls how pipeline data is saved.

### Production:

If critical builds → use MAX durability
If performance priority → use performance mode

---

# 🔹 USAGE STATISTICS

Anonymous telemetry.

Production:
Usually disabled in enterprise.

---

# 🔹 HTTP PROXY

### What:

Proxy configuration.

### Production:

Required in corporate networks.

---

# 🔹 GLOBAL BUILD TIMEOUT

### What:

Stop builds after time limit.

### Production:

Prevents:

* Stuck builds
* Infinite loops

---

# 🔹 BUILD DISCARDERS

### What:

Auto delete old builds.

Example:
Keep last 10 builds.

### Production:

Prevents disk overflow.

Very important.

---

# 🔹 GITHUB SECTION

---

## GitHub Servers

### What:

Configure GitHub API access.

Used for:

* Webhooks
* Commit status
* PR builds

### Production:

Uses:

* Personal access token
* GitHub App
* Enterprise GitHub

---

## GitHub API rate limiting

Avoid hitting GitHub limits.

Production:
Important for large teams.

---

# 🔹 GLOBAL PIPELINE LIBRARIES

---

## Trusted Pipeline Libraries

### What:

Shared reusable pipeline code.

### Why:

Centralize logic.

Example:

* Docker build function
* ECR push function
* Terraform deploy function

### Production:

DevOps creates:

```
vars/dockerBuild.groovy
```

Used by all teams.

Trusted = can use advanced Groovy.

---

## Untrusted Libraries

Sandboxed version.

More secure.

---

# 🔹 GIT PLUGIN

---

## Global user.name / user.email

Sets Git identity for Jenkins.

### Production:

Used when:

* Jenkins pushes tags
* Auto version bump
* GitOps commits

---

# 🔹 SHELL

---

## Shell executable

Default:

```
/bin/sh
```

Production:
Change to:

```
/bin/bash
```

if needed.

---

# 🔹 EMAIL CONFIGURATION

---

## SMTP Server

Configure mail server.

Example:

```
smtp.gmail.com
```

### Production:

Used for:

* Build failure alerts
* Release notifications

---

## Default recipients

Global email recipients.

---

## Extended Email Notification

Advanced email plugin.

Allows:

* HTML email
* Custom templates
* Attach logs
* Conditional sending

Used heavily in production.

---

# 🔹 TIMESTAMPER

Adds timestamps to console logs.

Production:
Always enabled.

Makes debugging easier.

---

# 🔹 FINGERPRINTS

Tracks artifact usage across jobs.

Used in:

* Large artifact pipelines
* Traceability

---

# 🔹 ADMINISTRATIVE MONITORS

Warnings shown to admins.

Production:
Never disable unless necessary.

---

# 🔹 NOTIFICATION URL

Webhook for external system.

Used for:

* Slack
* Monitoring systems

---

# 🔹 GIT PERFORMANCE OPTIONS

Advanced Git plugin tuning.

Used rarely unless performance issues.

---

# 🔹 BUILD TIMEOUT PLUGIN

Allows per-build timeout.

Production:
Prevents runaway builds.

---

# 🔹 THROTTLING

Limit concurrent builds.

Used to:

* Protect resources
* Avoid overload

---

# 🔥 REAL PRODUCTION PRIORITIES

As DevOps, you MUST configure:

1. Jenkins URL
2. Security
3. Credentials
4. Build discarder
5. SMTP
6. Global library
7. Disk monitoring
8. GitHub integration
9. Pipeline durability
10. Backup strategy

Everything else depends on company size.

---

# 🎯 Interview Answer (Senior Level)

If asked:
“What do you configure in Manage Jenkins → System?”

You say:

* Global environment configuration
* SCM retry & quiet period tuning
* Agent retention policies
* Disk monitoring
* Build retention
* GitHub API integration
* Global shared libraries
* Email & notification systems
* Proxy configuration
* Security & credentials
* Pipeline durability strategy

That is a strong senior DevOps answer.













# 1️⃣ What Happens When You Click a Job

When you click a job (example: `basic-pipeline`), Jenkins opens the **Job Page**.

Inside you will see:

Left Menu:

* Status
* Build Now
* Replay (if pipeline)
* Configure
* Delete
* Pipeline Syntax
* Branches (if multibranch)

Center:

* Build history (#1, #2, #3…)
* Stage View (for pipeline)
* Last build summary

---

# 2️⃣ Full Breakdown of a Pipeline Job Page

Let’s break it section by section.

---

## 🔹 A) Build History (Left Side)

You see builds like:

```
#8
#7
#6
```

Color meaning:

* 🟢 Blue/Green = Success
* 🔴 Red = Failed
* 🟡 Yellow = Unstable
* 🔵 Grey = Aborted

When you click a build → you enter Build Details page.

---

## 🔹 B) Stage View (Very Important)

If it's a Declarative Pipeline:

You see stages like:

| Checkout | Build | Test | Deploy |

Each stage shows:

* Success / Fail
* Duration
* Parallel stages if any

Used for:

* Quick failure identification
* Bottleneck detection

DevOps uses this daily.

---

## 🔹 C) Pipeline Syntax

This helps generate:

* `withCredentials`
* `checkout`
* `archiveArtifacts`
* `input`
* `build`
* etc.

Very helpful for beginners.

---

## 🔹 D) Configure

Opens job configuration page.

Here you configure:

* Git repo
* Branch
* Triggers (GitHub webhook)
* Parameters
* Build triggers
* Pipeline script (if inline)

Production:
DevOps locks this down.
Developers only edit Jenkinsfile in Git.

---

# 3️⃣ Console Output Debugging (Most Important Skill)

When you click a build → click **Console Output**

This shows step-by-step execution.

Example:

```
Cloning repository...
Building Docker image...
Pushing to ECR...
kubectl apply...
```

---

## 🔍 How DevOps Debugs

Step 1: Scroll to bottom
Step 2: Look for:

```
ERROR:
Exception:
script returned exit code 1
```

Step 3: Scroll slightly above error.

Common Errors:

❌ Git authentication failed
❌ Docker not installed
❌ kubectl not found
❌ Permission denied
❌ AWS credentials missing

---

### Interview Tip

If asked:
“How do you debug Jenkins pipeline?”

Answer:

1. Check console output
2. Identify failing stage
3. Verify credentials
4. Re-run locally if needed
5. Check agent environment

Strong answer.

---

# 4️⃣ Replay vs Rebuild

---

## 🔹 Replay (Pipeline Only)

Replay allows you to:

Edit Jenkinsfile directly in Jenkins UI
Re-run build without committing to Git

Used for:

* Quick testing
* Debugging pipeline logic

⚠️ Production:
Usually restricted to admins.

---

## 🔹 Rebuild

Rebuild simply:
Runs same build again.

No code modification.

Used when:

* Network failure
* Temporary issue
* External service glitch

---

### Difference

| Replay         | Rebuild          |
| -------------- | ---------------- |
| Edit pipeline  | No editing       |
| Temporary test | Exact same rerun |
| Pipeline only  | Any job          |

---

# 5️⃣ Multibranch Pipeline – Deep Explanation

This is modern Jenkins setup.

Instead of 1 job per branch,
Jenkins auto-creates jobs per branch.

Example repo:

```
main
dev
feature/login
feature/payment
```

Multibranch automatically creates:

* main job
* dev job
* feature/login job
* feature/payment job

---

## How It Works

1. Connect Jenkins to GitHub repo
2. Jenkins scans repo
3. Finds branches
4. Looks for Jenkinsfile in each branch
5. Creates job per branch

---

## Why It’s Powerful

* PR builds automatically
* Branch isolation
* Cleaner structure
* CI per feature branch

Production standard.

---

## DevOps Setup

* Use GitHub App or token
* Enable webhook
* Configure branch sources
* Configure scan interval

---

## Interview Answer

“What is Multibranch pipeline?”

Answer:

Automatically creates and manages pipeline jobs for each branch in a repository, allowing independent CI/CD per branch and PR.

---

# 6️⃣ Blue Ocean View

Blue Ocean = Modern Jenkins UI plugin.

Better visualization.

---

## What It Shows

Instead of classic stage view, it shows:

Graphical pipeline flow:

Start → Checkout → Build → Test → Deploy

With:

* Clear stage logs
* Visual failure highlight
* Parallel branch visualization

---

## Why Use It

* Cleaner UI
* Easier debugging
* Better for demos
* Great for beginners

---

## When Used in Production

Some companies:

* Use it for developers
* But DevOps often uses classic view for deep logs


# 🔥 Real Production Flow

Developer pushes code →
GitHub webhook →
Jenkins receives trigger →
Multibranch identifies branch →
Pipeline runs →
Build Docker →
Push to ECR →
Deploy to EKS →
Update GitHub commit status →
Send Slack notification

All visible inside job page.




