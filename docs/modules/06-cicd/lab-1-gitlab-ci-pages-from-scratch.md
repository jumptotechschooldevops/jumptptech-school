---
title: "LAB 1 — GitLab CI + Pages From Scratch"
description: "🟢 PART 1 — Register GitLab Account            Step 1   Go to:    https://gitlab.com       ..."
published: 2026-02-20
source: "https://dev.to/jumptotech/lab-1-gitlab-ci-pages-from-scratch-53ok"
tags: []
---

# LAB 1 — GitLab CI + Pages From Scratch








# 🟢 PART 1 — Register GitLab Account

### Step 1

Go to:

```
https://gitlab.com
```

Click **Register**

Use:

* Email
* Username
* Password

Verify email.

---

# 🟢 PART 2 — Create New Project

After login:

Click **New project**

Choose:

👉 **Create blank project**

Fill:

* Project name: `gitlab-lab`
* Visibility: Public (easier for Pages)
* Initialize repository with README (optional)

Click **Create project**

---

# 🟢 PART 3 — Connect Mac to GitLab (SSH Setup)

Open Mac Terminal.

### Step 1 — Generate SSH key

```bash
ssh-keygen -t ed25519 -C "your_email"
```

Press Enter for all prompts.

---

### Step 2 — Copy Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy entire output.

---

### Step 3 — Add SSH Key to GitLab

In GitLab:

Top right → Profile → Preferences → SSH Keys

Click **Add new key**

Paste key → Click **Add key**

---

### Step 4 — Test SSH

```bash
ssh -T git@gitlab.com
```

You should see:

```
Welcome to GitLab, @yourusername!
```

---

# 🟢 PART 4 — Clone Project to Mac

Go to your project page.

Click:

Code → Clone → SSH

Copy URL like:

```
git@gitlab.com:username/gitlab-lab.git
```

Now in terminal:

```bash
git clone git@gitlab.com:username/gitlab-lab.git
cd gitlab-lab
```

Check:

```bash
ls -la
```

You should see `.git` folder.

---

# 🟢 PART 5 — Create First Website

Create public folder:

```bash
mkdir public
```

Create index file:

```bash
cat > public/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>My First GitLab CI Site</title>
</head>
<body>
  <h1>Hello DevOps World 🚀</h1>
</body>
</html>
EOF
```

---

# 🟢 PART 6 — Create GitLab CI File

Create file:

```bash
touch .gitlab-ci.yml
```

Open it:

```bash
nano .gitlab-ci.yml
```

Paste:

```yaml
image: busybox

pages:
  stage: deploy
  script:
    - echo "Deploying to GitLab Pages"
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

Save and exit.

---

# 🟢 PART 7 — Push Code (Trigger Pipeline)

```bash
git add .
git commit -m "Setup GitLab Pages site"
git push origin master
```

(If your branch is main, use main instead.)

---

# 🟢 PART 8 — Watch First CI Job

Go to:

👉 Build → Pipelines

You will see:

Pipeline running → then green.

Click pipeline → see job logs.

This is your first CI job.

---

# 🟢 PART 9 — Open Your Website

After pipeline is green:

Go to:

👉 Deploy → Pages

Open URL:

```
https://username.gitlab.io/gitlab-lab/
```

You will see:

```
Hello DevOps World 🚀
```

---

# 🎯 What You Just Learned

You just completed:

✔ GitLab registration
✔ SSH authentication
✔ Git clone
✔ Git workflow
✔ CI pipeline
✔ Artifacts
✔ Static deployment

This is real DevOps foundation.

---

# 🧠 What DevOps Should Understand

* `.gitlab-ci.yml` controls pipeline
* Branch triggers deployment
* `public/` folder becomes website
* CI/CD is event-driven (push = pipeline)
* SSH is secure authentication


