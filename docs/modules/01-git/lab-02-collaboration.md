# Lab 2 · Team Workflow

**Duration:** ~90 minutes  
**Goal:** Practice the full pull request workflow, handle merge conflicts, and understand how branching strategies work in real teams.

**Prerequisites:** Lab 1 complete. A GitHub account.

---

## Setup

### Create a GitHub repository

1. Go to github.com → New repository
2. Name: `devops-notes`
3. Visibility: Public (or Private)
4. Do NOT initialise with README (you already have one locally)
5. Click Create

### Push your local repo

```bash
cd devops-notes   # from Lab 1

git remote add origin https://github.com/YOUR_USERNAME/devops-notes.git
git push -u origin main
```

Refresh GitHub — you should see your commits.

---

## Part 1 — Feature branch workflow

### 1.1 Create a feature branch

```bash
git switch -c feature/docker-notes
```

Add content on this branch:

```bash
mkdir -p notes/docker

cat > notes/docker/concepts.md << 'EOF'
# Docker Concepts

## What is a container?
A container is a lightweight, isolated process that shares the host OS kernel
but has its own filesystem, network, and process space.

## Images vs Containers
- An **image** is a read-only template (like a class)
- A **container** is a running instance of an image (like an object)

## Key commands
| Command | What it does |
|---------|-------------|
| `docker pull nginx` | Download the nginx image |
| `docker run -p 80:80 nginx` | Run nginx, map port 80 |
| `docker ps` | List running containers |
| `docker stop <id>` | Stop a container |
| `docker rm <id>` | Remove a container |
| `docker images` | List local images |
EOF

git add notes/docker/concepts.md
git commit -m "Add Docker concepts notes"
```

Add more content:

```bash
cat > notes/docker/dockerfile.md << 'EOF'
# Writing Dockerfiles

A Dockerfile is a set of instructions for building an image.

## Basic structure
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
```

## Best practices
- Use specific image tags, not `latest`
- Copy requirements first, then code (layer caching)
- Run as a non-root user
- Use .dockerignore to exclude unnecessary files
EOF

git add notes/docker/dockerfile.md
git commit -m "Add Dockerfile writing guide"
```

### 1.2 Push the branch and open a PR

```bash
git push -u origin feature/docker-notes
```

GitHub will print a URL to open a pull request. Open it, or go to your repo on GitHub and click "Compare & pull request".

PR description:

```
## What
Adds notes for the Docker module covering container concepts and Dockerfile basics.

## Why
Students need reference material for Module 04 lab work.

## Checklist
- [x] Concepts page covers images vs containers
- [x] Dockerfile page has a working example
- [x] Best practices listed
```

For now, approve and merge the PR yourself (in a real team, a teammate would review it). Use **Squash and merge**.

### 1.3 Update local main

```bash
git switch main
git pull origin main

git log --oneline
# You should see the squashed commit from the PR
```

Delete the local feature branch (it was merged):

```bash
git branch -d feature/docker-notes
```

---

## Part 2 — Simulating a merge conflict

This part simulates what happens when two developers edit the same file. You will create the conflict yourself by working on two branches simultaneously.

### 2.1 Branch 1 — Update README module list

```bash
git switch -c feature/update-readme-docker
```

Edit `README.md` to mark Docker as in progress:

```bash
# Open README.md and change:
# - [ ] Docker
# to:
# - [x] Docker

sed -i '' 's/- \[ \] Docker/- [x] Docker/' README.md
# On Linux: sed -i 's/- \[ \] Docker/- [x] Docker/' README.md

git add README.md
git commit -m "Mark Docker module as complete in README"
```

### 2.2 Branch 2 — A different README change

```bash
git switch main
git switch -c feature/add-readme-intro
```

Add an introduction section to README.md that will conflict:

Open `README.md` in your editor and change the top of the file. The current content starts with `# DevOps Notes`. Replace the first few lines with:

```markdown
# DevOps Notes

> Personal notes from the JumptpTech School DevOps programme.
> Started May 2026.

This repository tracks my progress through 8 modules of hands-on DevOps training.

## Modules
- [ ] Git
- [ ] Linux
...
```

```bash
git add README.md
git commit -m "Add introductory paragraph to README"
git push -u origin feature/add-readme-intro
```

### 2.3 Merge the first branch

```bash
git switch main
git merge feature/update-readme-docker
git push origin main
```

### 2.4 Merge the second branch — conflict!

```bash
git merge feature/add-readme-intro
```

You will see:

```
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts then commit the result.
```

### 2.5 Resolve the conflict

```bash
cat README.md   # look at the conflict markers
```

The file will have sections like:

```
<<<<<<< HEAD
# DevOps Notes

A collection of notes from the JumptpTech DevOps course.

## Modules
- [x] Docker
=======
# DevOps Notes

> Personal notes from the JumptpTech School DevOps programme.
> Started May 2026.

This repository tracks my progress through 8 modules of hands-on DevOps training.

## Modules
- [ ] Docker
>>>>>>> feature/add-readme-intro
```

Edit `README.md` to produce the final version that incorporates both changes:

```markdown
# DevOps Notes

> Personal notes from the JumptpTech School DevOps programme.
> Started May 2026.

This repository tracks my progress through 8 modules of hands-on DevOps training.

## Modules
- [x] Git
- [x] Docker
- [ ] Linux
...
```

After editing, complete the merge:

```bash
git add README.md
git merge --continue   # or: git commit
```

```bash
git log --oneline --graph --all
```

You will see the merge commit with two parent pointers.

Push the resolved merge:

```bash
git push origin main
```

---

## Part 3 — Rebase workflow

Rebase produces a cleaner history than merge. Here you will use it to update a feature branch before opening a PR.

### 3.1 Create a feature branch

```bash
git switch -c feature/kubernetes-notes
mkdir -p notes/kubernetes

cat > notes/kubernetes/overview.md << 'EOF'
# Kubernetes Overview

Kubernetes (k8s) is a container orchestration platform. It manages:
- Scheduling containers across a cluster of machines
- Self-healing (restarting failed containers)
- Scaling (adding or removing replicas)
- Service discovery and load balancing
EOF

git add .
git commit -m "Add Kubernetes overview notes"
```

### 3.2 Someone else updates main

Simulate another commit landing on main while you were working:

```bash
git switch main
echo "Updated 2026-05-18" >> notes/linux/basics.md
git add notes/linux/basics.md
git commit -m "Update linux notes with date"
git push origin main
```

### 3.3 Rebase your branch on updated main

```bash
git switch feature/kubernetes-notes

# Fetch the latest main
git fetch origin

# Rebase your work on top of the updated main
git rebase origin/main
```

Git replays your commits on top of the latest `main`. If there are no conflicts, it succeeds silently.

```bash
git log --oneline --graph
```

Your branch now appears as if you branched from the latest commit on main, even though you started earlier.

### 3.4 Push and open a PR

```bash
git push -u origin feature/kubernetes-notes
```

Open a PR on GitHub. Notice the history is clean — no merge commits, just your feature commits on top of the current main.

Merge the PR (squash or rebase merge are both fine here).

---

## Part 4 — Tags and releases

Tags mark specific points in history — typically software releases.

```bash
git switch main
git pull origin main

# Create a lightweight tag
git tag v0.1

# Create an annotated tag (preferred for releases)
git tag -a v0.1.0 -m "First tagged version of DevOps notes"

# List tags
git tag

# Show tag details
git show v0.1.0

# Push tags to remote (not pushed by default)
git push origin --tags
```

Check GitHub — you will see the tag in the Releases/Tags section.

---

## Checkpoint

At the end of this lab you should have:

- [ ] A GitHub remote with your `devops-notes` repo
- [ ] At least 3 merged pull requests in the repo's history
- [ ] Successfully resolved a merge conflict
- [ ] Used `git rebase` to update a branch before merging
- [ ] At least one annotated tag pushed to GitHub

```bash
git log --oneline --graph --all | head -20
```

---

## Common mistakes to watch for

**Accidentally committing on main**

If you notice you made commits directly on `main` instead of a branch:

```bash
# Create a branch that includes those commits
git switch -c feature/oops-committed-here

# Reset main to where it should be
git switch main
git reset --hard origin/main

# Your commits are safe on the feature branch
git switch feature/oops-committed-here
```

**Pushed changes that need to be undone**

Never force-push to `main`. Use `git revert`:

```bash
git revert <bad-commit-hash>
git push origin main
```

This adds a commit that undoes the bad one. The history still shows both — which is good for transparency.
