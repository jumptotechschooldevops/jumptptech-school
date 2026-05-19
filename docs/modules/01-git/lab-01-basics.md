# Lab 1 · Git Basics

**Duration:** ~60 minutes  
**Goal:** Get comfortable with the core Git workflow — init, stage, commit, inspect, and undo.

---

## Part 1 — Set up and first commit

### 1.1 Configure Git

If you have not already done this, run:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.editor "code --wait"  # or nano, vim, etc.
```

Verify your config:

```bash
git config --global --list
```

### 1.2 Create a project

```bash
mkdir devops-notes
cd devops-notes
git init
```

You should see: `Initialized empty Git repository in .../devops-notes/.git/`

```bash
# Check the status of the empty repo
git status
```

Expected output:
```
On branch main

No commits yet

nothing to commit (create/copy files and start tracking)
```

### 1.3 Create your first file

```bash
cat > README.md << 'EOF'
# DevOps Notes

A collection of notes from the JumptpTech DevOps course.

## Modules
- [ ] Git
- [ ] Linux
- [ ] Networking
- [ ] Docker
- [ ] Kubernetes
- [ ] CI/CD
- [ ] Terraform
- [ ] Monitoring
EOF
```

Check status again:

```bash
git status
```

You will see `README.md` listed as an untracked file. Git sees it but is not tracking it yet.

### 1.4 Stage and commit

```bash
git add README.md
git status   # now shows "Changes to be committed"
git commit -m "Initial commit: add README"
```

Look at the history:

```bash
git log
git log --oneline
```

---

## Part 2 — The staging area

This part demonstrates why the staging area exists and how to use it properly.

### 2.1 Create multiple files

```bash
mkdir -p notes/git notes/linux

cat > notes/git/commits.md << 'EOF'
# Git Commits

A commit is a snapshot of your project at a point in time.

## Good commit messages
- Subject line under 50 characters
- Describe WHAT changed and WHY
- Use imperative mood: "Add", "Fix", "Remove"
EOF

cat > notes/git/branches.md << 'EOF'
# Git Branches

A branch is a pointer to a commit.

## Commands
- git switch -c feature/name  — create and switch
- git switch main             — switch to main
- git branch -d feature/name  — delete branch
EOF

cat > notes/linux/basics.md << 'EOF'
# Linux Basics

Notes for the Linux module.
EOF
```

### 2.2 Stage selectively

You have three new files. Commit the git notes separately from the linux notes:

```bash
# Only stage the git notes
git add notes/git/

git status
# Should show notes/git/* staged, notes/linux/* untracked

git commit -m "Add git commit and branch notes"

# Now stage and commit the linux notes
git add notes/linux/basics.md
git commit -m "Add linux basics placeholder"
```

Check your history:

```bash
git log --oneline
```

You should see three commits.

### 2.3 Stage part of a file

Add two unrelated changes to the same file, then commit them separately:

```bash
cat >> notes/git/commits.md << 'EOF'

## Undoing commits
- git revert <hash> — safe, creates a new commit
- git reset — rewrites history, use carefully
EOF

cat >> notes/git/commits.md << 'EOF'

## Viewing history
- git log --oneline
- git log --graph --all
- git show <hash>
EOF
```

Now use interactive staging to commit these as separate changes:

```bash
git add -p notes/git/commits.md
```

Git will show you each "hunk" and ask what to do:

- `y` — stage this hunk
- `n` — skip this hunk
- `s` — split hunk into smaller pieces
- `q` — quit

Stage only the "Undoing commits" section, then commit it. Then stage and commit the "Viewing history" section.

```bash
git log --oneline
# Should now show 5 commits
```

---

## Part 3 — Inspecting history

### 3.1 Show a specific commit

```bash
# Get the hash of your second commit from git log --oneline
git show <hash>
```

This shows the commit metadata and the diff — what changed in that commit.

### 3.2 Compare commits and working directory

```bash
# Add a change but do NOT stage it
echo "## Tips" >> notes/git/branches.md
echo "- Always branch from main, not from another feature branch" >> notes/git/branches.md

# Compare working directory to staging area
git diff

# Compare staging area to last commit
git diff --staged

# Compare two commits
git diff HEAD~2 HEAD
```

`HEAD~2` means "two commits before HEAD". `HEAD~1` or `HEAD^` means the parent of HEAD.

### 3.3 Find when a line was added

```bash
git log -p notes/git/commits.md
```

`-p` shows the patch (diff) for each commit that touched that file. Use it to understand the history of a specific file.

---

## Part 4 — Undoing things

### 4.1 Unstage a file

```bash
# Stage the change from 3.2
git add notes/git/branches.md

git status  # shows staged

# Unstage it without losing the change
git restore --staged notes/git/branches.md

git status  # back to unstaged
```

The file in your working directory is unchanged — you just removed it from the staging area.

### 4.2 Discard a working directory change

```bash
# Discard the unsaved change (WARNING: cannot be recovered)
git restore notes/git/branches.md

git status  # clean
git diff    # no output
```

`git restore <file>` without `--staged` throws away your working directory changes. There is no undo. Use it intentionally.

### 4.3 Amend a commit

```bash
# Create a commit with a typo in the message
echo "extra line" >> notes/linux/basics.md
git add notes/linux/basics.md
git commit -m "Fix linux noets"   # oops

# Amend to fix the message (and optionally add more staged changes)
git commit --amend -m "Fix linux notes"

git log --oneline  # new message, same position in history
```

!!! warning
    Only amend commits that you have **not pushed** to a remote. Amending rewrites the commit (creates a new hash), which causes problems if others have already pulled the original.

### 4.4 Revert a commit

```bash
# Get the hash of a commit you want to undo
git log --oneline

# Revert it — creates a new commit that undoes the changes
git revert <hash>
# This opens your editor for a commit message — save and close

git log --oneline  # see the revert commit
```

Revert is safe because it adds to history rather than rewriting it.

---

## Part 5 — Ignoring files

### 5.1 Create a .gitignore

```bash
cat > .gitignore << 'EOF'
# Build output
*.pyc
__pycache__/
dist/
build/

# Editor files
.vscode/
.idea/
*.swp

# OS files
.DS_Store
Thumbs.db

# Secrets — NEVER commit these
.env
*.key
EOF

# Create some files that should be ignored
touch .DS_Store
mkdir -p __pycache__
touch __pycache__/module.cpython-311.pyc
```

```bash
git status
```

The `.gitignore` file should appear as untracked, but `.DS_Store` and the `__pycache__` files should not be listed at all.

```bash
git add .gitignore
git commit -m "Add .gitignore"
```

### 5.2 Check what is ignored

```bash
git check-ignore -v .DS_Store
git check-ignore -v __pycache__/module.cpython-311.pyc
```

This tells you exactly which `.gitignore` rule is catching each file — useful for debugging gitignore rules.

---

## Checkpoint

Run `git log --oneline` and confirm you have at least 8–10 commits. Your working directory should be clean (`git status` shows nothing to commit).

**Expected commits (roughly):**

```
abc1234 Add .gitignore
def5678 Revert "..."
...
9f8e7d6 Add git commit and branch notes
a1b2c3d Initial commit: add README
```

If something looks wrong, check `git log -p` to trace through what happened.

---

## Challenge exercises

If you finish early:

1. Use `git stash` to temporarily set aside uncommitted work, switch branches, then bring it back with `git stash pop`
2. Use `git log --author="Your Name" --since="1 hour ago"` to filter history
3. Use `git bisect` to find which commit introduced a bug: manually add `echo "BUG" >> notes/linux/basics.md` in one commit, then use bisect to find it
