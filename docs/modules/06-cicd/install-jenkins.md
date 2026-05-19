---
title: "Install Jenkins"
description: "Jenkins on macOS using Docker — full DevOps setup           This is the BEST +..."
published: 2026-02-05
source: "https://dev.to/jumptotech/install-jenkins-5bme"
tags: []
---

# Install Jenkins

## Jenkins on macOS using **Docker** — full DevOps setup 

![Image](https://www.jenkins.io/doc/book/resources/tutorials/setup-jenkins-01-unlock-jenkins-page.jpg)

![Image](https://i.sstatic.net/EeLNT.png)

![Image](https://toolsqa.com/gallery/Jenkins/2.Jenkins%20build%20jobs%20Creation%20of%20new%20Standalone%20job%20in%20Jenkins.jpg)

![Image](https://wiki.jenkins-ci.org/JENKINS/attachments/41877565/42631391.jpg)

This is the **BEST + industry-standard** way for DevOps engineers.

---

## PHASE 1 — Install prerequisites (once)

### 1. Install Docker Desktop for Mac

Download:

```
https://www.docker.com/products/docker-desktop/
```

After install:

* Open Docker Desktop
* Make sure Docker is **running**
* Verify:

```bash
docker --version
docker ps
```

---

## PHASE 2 — Run Jenkins using Docker (clean & correct)

### 2. Create Jenkins container

Run this **exact command**:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

Why this matters (DevOps mindset):

* `-v jenkins_home` → **persistent data**
* LTS → **stable for production**
* No Java install on Mac needed

Check:

```bash
docker ps
```

---

## PHASE 3 — Unlock & login Jenkins

### 3. Get admin password

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the password.

---

### 4. Open Jenkins UI

Browser:

```
http://localhost:8080
```

Steps:

1. Paste admin password
2. Click **Install suggested plugins**
3. Create admin user
4. Finish setup

You are now **logged in as Jenkins admin**.

---

## PHASE 4 — Jenkins basics every DevOps must know

### Jenkins UI essentials

* **Dashboard** → all pipelines/jobs
* **Manage Jenkins** → configuration
* **Manage Plugins** → DevOps tools
* **Credentials** → secrets management
* **Nodes** → agents/workers

---

## PHASE 5 — First DevOps job (hands-on)

### 5. Create your first job

1. Click **New Item**
2. Name: `devops-demo-job`
3. Type: **Freestyle project**
4. Click **OK**

---

### 6. Add build step

Scroll → **Build** → Add build step → **Execute shell**

Paste:

```bash
echo "Hello DevOps"
date
whoami
```

Save.

---

### 7. Run job

Click **Build Now**

Check:

* **Console Output**
* Job status (blue = success)

This proves:

* Jenkins works
* Linux shell runs inside container

---

## PHASE 6 — Real DevOps workflow (what matters)

### Typical DevOps CI pipeline

```
Git → Jenkins → Build → Test → Artifact → Deploy
```

You will now build toward:

* GitHub / GitLab integration
* Maven / Gradle / Node builds
* Docker image builds
* AWS deployment
* Kubernetes pipelines

---

## PHASE 7 — Must-install plugins (DevOps standard)

Go to:
**Manage Jenkins → Manage Plugins → Available**

Install:

* Git
* Pipeline
* Docker Pipeline
* Credentials Binding
* Blue Ocean
* Maven Integration

Restart Jenkins when asked.

---

## PHASE 8 — Jenkins + Git (real CI)

### Example: clone Git repo

In job config:

* **Source Code Management → Git**
* Repo URL:

```
https://github.com/spring-projects/spring-petclinic.git
```

Build step:

```bash
ls -la
```

Build → see repo files → CI working.

---

## PHASE 9 — Jenkins container access (important)

### Enter Jenkins container

```bash
docker exec -it jenkins bash
```

Inside container:

* Jenkins workspace
* Linux commands
* Java available

Exit:

```bash
exit
```

---

## PHASE 10 — DevOps mindset (very important)

You are NOT “installing Jenkins”.
You are building **automation**.

As a DevOps engineer, Jenkins is used to:

* Enforce CI
* Catch bugs early
* Automate deployments
* Replace manual work
* Integrate tools (Git, Docker, AWS, K8s)










## A) Verify Jenkins is running locally (Mac)

### 1) Confirm process + port

```bash
ps aux | grep jenkins
```

### 2) Open Jenkins in browser

Open:

* `http://127.0.0.1:9090`

If this doesn’t open, Jenkins is not running (stop here and fix Jenkins start).

---

## B) Install ngrok on Mac (2 options)

### Option 1: Homebrew (recommended)

```bash
brew install ngrok/ngrok/ngrok
ngrok version
```

### Option 2: Download from ngrok website

1. Go to ngrok downloads (Mac)
2. Download zip, unzip
3. Move binary:

```bash
sudo mv ~/Downloads/ngrok /usr/local/bin/ngrok
ngrok version
```

---

## C) Connect ngrok to your ngrok account (required)

ngrok requires auth token.

### 1) Login to ngrok dashboard

* Go to your ngrok account → **“Your Authtoken”**

### 2) Copy token and paste this command (exact)

```bash
ngrok config add-authtoken YOUR_TOKEN_HERE
```

Check config:

```bash
cat ~/.config/ngrok/ngrok.yml
```

---

## D) Start ngrok tunnel for Jenkins

### 1) Start tunnel (Jenkins port 9090)

```bash
ngrok http 9090
```

You will see something like:

* Forwarding `https://temple-deontic-ansley.ngrok-free.dev -> http://localhost:9090`
* Web Interface `http://127.0.0.1:4040`

### 2) Copy ONLY this URL

Copy the **https** forwarding URL, example:

* `https://temple-deontic-ansley.ngrok-free.dev`

---

## E) Prepare Jenkins for GitHub webhooks

### 1) Install required plugins (Jenkins UI)

Go to:

* **Manage Jenkins → Plugins → Available**

Install:

* **GitHub**
* **Git**
* **Pipeline**
* **Multibranch Pipeline** (optional, but recommended)
* **GitHub Branch Source** (recommended)

Restart Jenkins if asked.

### 2) Set Jenkins URL (important)

Go to:

* **Manage Jenkins → System**

Find **Jenkins Location → Jenkins URL**
Set it to your ngrok public URL:

* `https://temple-deontic-ansley.ngrok-free.dev`

Save.

Why DevOps does this:

* Jenkins generates correct callback URLs (links in webhook, notifications, etc.)

---

## F) Create GitHub token (DevOps standard, secure)

You should NOT use GitHub password.

### 1) In GitHub

Go:

* **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**

Create token with scopes:

* `repo`
* `admin:repo_hook` (needed to manage webhooks)
* `read:org` (if repo is org)

Copy the token (save it).

### 2) Add token to Jenkins as credential

In Jenkins:

* **Manage Jenkins → Credentials**
* Domain: **(global)**
* **Add Credentials**

  * Kind: **Secret text**
  * Secret: paste GitHub token
  * ID: `github-token`
    Save.

---

## G) Create Jenkins Pipeline job that reads Jenkinsfile from GitHub

### 1) Create job

* Jenkins → **New Item**
* Name: `eks-text` (example)
* Type: **Pipeline**
* OK

### 2) Configure “Pipeline script from SCM”

In job config:

**Pipeline section**

* Definition: **Pipeline script from SCM**
* SCM: **Git**
* Repository URL:

  * `https://github.com/jumptotechschooldevops/cloud-guardrails.git`
* Credentials:

  * choose your GitHub token credential (`github-token`) if Jenkins asks
* Branches to build:

  * `*/main` (or `*/master`)
* Script Path:

  * `01-eks-gatekeeper/Jenkinsfile`

Save.

### 3) Enable webhook trigger

In the same job config:

* **Build Triggers**

  * ✅ Check **GitHub hook trigger for GITScm polling**
    Save.

DevOps reason:

* This tells Jenkins: “Start build when GitHub webhook arrives.”

---

## H) Add GitHub Webhook (this is the KEY part)

Go to your GitHub repo:

* **Repo → Settings → Webhooks → Add webhook**

Fill:

### 1) Payload URL (copy/paste exact)

Use your ngrok URL + Jenkins GitHub endpoint:

```
https://temple-deontic-ansley.ngrok-free.dev/github-webhook/
```

Important:

* Must end with **`/github-webhook/`**

### 2) Content type

* `application/json`

### 3) Which events

* Choose: **Just the push event**
  (That’s enough for auto-build on push.)

### 4) Active

* ✅ Active

Click: **Add webhook**

---

## I) Test (DevOps validation checklist)

### 1) Check webhook delivery

In GitHub webhook page:

* Click the webhook
* Go to **Recent Deliveries**
* You want **Status: 200 OK**

If you see 404/500 → Jenkins didn’t receive it.

### 2) Make a test commit + push

From your repo:

```bash
git pull
echo "webhook test $(date)" >> webhook-test.txt
git add webhook-test.txt
git commit -m "test webhook trigger"
git push
```

Expected:

* GitHub webhook shows **200**
* Jenkins job starts automatically: **“Started by GitHub push …”**

---

## J) If webhook triggers but job doesn’t run (common fixes)

### Fix 1: Wrong webhook URL

Must be:

* `https://YOUR-NGROK-DOMAIN/github-webhook/`

### Fix 2: Jenkins is only listening on 127.0.0.1

That’s OK with ngrok, because ngrok forwards to localhost.

### Fix 3: ngrok is running but Jenkins not reachable

Open in browser:

* `https://YOUR-NGROK-DOMAIN`
  If you don’t see Jenkins login page, ngrok isn’t forwarding to correct port.

### Fix 4: ngrok changes URL

Free ngrok changes domain each time.
If you restart ngrok → you MUST update GitHub webhook payload URL.

---

## K) What DevOps engineers do in real companies

* Use a real public DNS + TLS (not ngrok)
* Put Jenkins behind:

  * Reverse proxy (Nginx)
  * HTTPS cert (Let’s Encrypt)
  * Auth (SSO)
* Lock down webhook security:

  * GitHub “Secret” header validation
  * IP allowlist (GitHub webhook IPs)
* Use Multibranch Pipeline + PR builds












## 1) Confirm Jenkins is running on your Mac

You already confirmed with:

```bash
ps aux | grep jenkins
```

You saw Jenkins running like:

* `jenkins.war`
* listening on `127.0.0.1`
* port like `9090`

So locally Jenkins works.

Open in browser:

* `http://127.0.0.1:9090`

---

## 2) Problem: GitHub cannot reach localhost Jenkins

Because Jenkins was on `127.0.0.1`, GitHub webhook **cannot call it**.

So we used **ngrok** to expose Jenkins.

---

## 3) Start ngrok to expose Jenkins

Run (example if Jenkins on 9090):

```bash
ngrok http 9090
```

ngrok gave you a public URL like:

* `https://temple-deontic-ansley.ngrok-free.dev`

That URL forwards internet traffic → your local Jenkins.

---

## 4) Create a Pipeline job in Jenkins (GitHub Jenkinsfile)

In Jenkins UI:

1. **New Item**
2. Name: for example `eks-text` (your job name)
3. Choose: **Pipeline**
4. Click OK

Then configure:

### Pipeline section

* **Definition:** `Pipeline script from SCM`

* **SCM:** `Git`

* **Repository URL:**
  `https://github.com/jumptotechschooldevops/cloud-guardrails.git`

* **Branches to build:**
  `*/main` (or `*/master` depending on your repo)

* **Script Path:**
  `01-eks-gatekeeper/Jenkinsfile`

Save.

---

## 5) Fix #1 you hit: “Unable to find Jenkinsfile”

Reason: Jenkins was looking in wrong place.

Fix:

* Ensure the **Script Path** matches exactly where Jenkinsfile is.
* You confirmed correct path when Jenkins log showed:

> `Obtained 01-eks-gatekeeper/Jenkinsfile from git ...`

So that part became correct.

---

## 6) Commit Jenkinsfile + required folders to GitHub

Inside your repo you created/edited:

```bash
cd cloud-guardrails/01-eks-gatekeeper
vim Jenkinsfile
tree
```

You had:

* `Jenkinsfile`

* `tests/`

* `policies_backup/` (yaml)
  Later you added the **real conftest policies** folder:

* `policies/` (rego files)

Final working structure:

```
01-eks-gatekeeper/
  Jenkinsfile
  policies/
    deny-hostpath.rego
    deny-privileged.rego
  tests/
    bad-pod.yaml
    good-deployment.yaml
```

Then push:

```bash
git add .
git commit -m "Add Jenkinsfile + policies + tests"
git push
```

---

## 7) Fix #2 you hit: sudo password issue

Your pipeline originally did:

```bash
sudo mv conftest /usr/local/bin
```

Jenkins cannot type sudo password → fails.

Fix:

* Install conftest **without sudo**
* Put it in workspace, mark executable, run from there.

---

## 8) Fix #3 you hit: “cannot execute binary file”

That happened because you downloaded the wrong conftest build for your platform/architecture.

Fix:

* Download correct conftest for the machine running Jenkins.
* You’re running Jenkins on Mac, so use **Darwin** build when running locally.

(When you later ran with correct binary + chmod, that error was gone.)

---

## 9) Fix #4 you hit: “no policies found in [policies_backup]”

Reason:

* `policies_backup/` had YAML constraints, not `.rego` policies.
* conftest requires **OPA Rego policies**.

Fix:

* Create a `policies/` directory with `.rego` files:

Example (you created):

```
policies/
  deny-hostpath.rego
  deny-privileged.rego
```

Then update Jenkinsfile to point to:

* `--policy policies`

---

## 10) Final working Jenkinsfile approach (what made it succeed)

Key things your successful Jenkinsfile did:

1. Run inside repo folder:

   * `dir("01-eks-gatekeeper") { ... }`
2. Install conftest locally (no sudo)
3. Run conftest against:

   * `tests/`
   * using policies from `policies/`

---

## 11) Configure GitHub Webhook to auto-trigger Jenkins on push

In GitHub repo:

1. **Settings → Webhooks → Add webhook**
2. Payload URL:

```
https://temple-deontic-ansley.ngrok-free.dev/github-webhook/
```

Important:

* Must end with `/github-webhook/`

3. Content type: `application/json`
4. Events: **Just the push event**
5. Add webhook

---

## 12) Enable Jenkins trigger for GitHub webhook

In Jenkins job config:

* **Build Triggers**
  ✅ check **GitHub hook trigger for GITScm polling**

Save.

---

## 13) Verify it works

### Test by pushing a commit

Make a small change:

```bash
echo "# test" >> 01-eks-gatekeeper/tests/bad-pod.yaml
git add .
git commit -m "trigger webhook test"
git push
```

Expected result:

* GitHub webhook shows **200 OK**
* Jenkins job starts automatically: “Started by GitHub push…”

---

## 14) What “success” looks like

In Jenkins console output, you should see:

* Repo checked out
* conftest installed (without sudo)
* `conftest test tests --policy policies`
* One of:

  * ✅ Policies passed
  * or ❌ failed (if bad yaml triggers deny)

---

## Important notes (DevOps engineer best practice)

* If ngrok URL changes (free plan does), you must update webhook URL in GitHub.
* For production, don’t use ngrok — use a real public Jenkins endpoint behind TLS.
* Keep Jenkins credentials secure (GitHub tokens, etc.).


