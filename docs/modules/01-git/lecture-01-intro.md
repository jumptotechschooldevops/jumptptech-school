# Lecture 1 · Version Control Fundamentals

## Why version control exists

Before version control, people shared code by emailing zip files and naming them `project_final_v2_REALLY_FINAL.zip`. This works fine until two people edit the same file on the same day. Then someone's work disappears, and nobody can figure out who changed what or when.

Version control solves three problems:

1. **History** — you can see every change ever made, who made it, and why
2. **Collaboration** — multiple people can work on the same codebase simultaneously without overwriting each other
3. **Recovery** — if something breaks, you can go back to a state where it worked

Git is a distributed version control system. "Distributed" means every developer has a complete copy of the repository, including the full history. You do not need a network connection to commit, branch, or inspect history. You only need a network to push to or pull from a remote.

---

## How Git stores data

Most version control systems store files and then record what changed between versions (deltas). Git does not do this.

Git stores **snapshots**. Every time you commit, Git takes a picture of every tracked file at that moment and stores a reference to that snapshot. If a file has not changed since the last commit, Git does not store it again — it just stores a link to the previous identical file. This makes Git fast and makes the history graph meaningful.

Every object Git stores is identified by a SHA-1 hash of its contents. A commit hash like `a3f8c91` is not just a label — it is derived from the commit's content. If anything in that commit changes (the message, the files, the parent), the hash changes. This is how Git guarantees integrity.

### The three areas

Understanding these three areas is the single most important concept in Git:

```
Working directory  →  Staging area (index)  →  Repository (.git)
```

- **Working directory** — the actual files on your disk. When you edit a file, the change is here.
- **Staging area** — a preparation zone. You add changes here before committing. This lets you commit only part of your working directory changes.
- **Repository** — the `.git` folder. Every commit, branch, and tag lives here.

The workflow is always the same:

1. Edit files in your working directory
2. Stage the changes you want to include in the next commit (`git add`)
3. Commit the staged changes with a message (`git commit`)

---

## Commits

A commit is a snapshot plus metadata:

- The snapshot of every tracked file at that point in time
- Your name and email
- A timestamp
- The commit message you wrote
- The hash of the parent commit (or two parent hashes for a merge commit)

The parent reference is what creates the history graph. Each commit points back to its parent, creating a chain that you can follow all the way to the very first commit.

### What makes a good commit

A commit should represent a single logical change. Not "a morning's work". Not "fix everything". One change, explained clearly.

The subject line (first line of the message) should complete the sentence: "If applied, this commit will..."

```
# Good
Add retry logic to the payment API client
Fix null pointer exception in user session handler
Update Dockerfile to use non-root user

# Bad
fix
WIP
stuff
asdfasdf
fixed the thing from yesterday
```

The subject line should be 50 characters or fewer. If you need to explain *why* you made the change, add a blank line after the subject and then write a body paragraph.

---

## Essential commands

### Starting a repository

```bash
# Create a new repo in the current directory
git init

# Clone an existing repo
git clone https://github.com/org/repo.git

# Clone into a specific directory
git clone https://github.com/org/repo.git my-project
```

### Checking status

```bash
# See what is staged, unstaged, and untracked
git status

# Short format — useful once you know the symbols
git status -s
```

Output symbols in short format:

- `M` — modified
- `A` — added (staged)
- `?` — untracked
- Left column = staging area, right column = working directory

### Staging changes

```bash
# Stage a specific file
git add README.md

# Stage all changes in the current directory
git add .

# Stage only part of a file (interactive hunk selection)
git add -p README.md
```

`git add -p` is one of the most useful Git commands for maintaining clean commits. It shows you each changed section (hunk) and asks whether to stage it. This lets you split work-in-progress changes into multiple logical commits.

### Committing

```bash
# Commit staged changes with a message
git commit -m "Add retry logic to payment API client"

# Open your editor to write a longer message
git commit

# Stage all tracked modified files and commit in one step
# (does NOT add untracked files)
git commit -am "Fix typo in error message"
```

### Inspecting history

```bash
# Show commit history
git log

# Compact one-line format
git log --oneline

# Graph view showing branches
git log --oneline --graph --all

# Show what changed in a specific commit
git show a3f8c91

# Show history for a specific file
git log --follow -- src/app.py
```

### Undoing things

```bash
# Unstage a file (keep the working directory change)
git restore --staged README.md

# Discard working directory changes to a file (DESTRUCTIVE)
git restore README.md

# Amend the most recent commit (message or staged files)
# Only do this before pushing — it rewrites history
git commit --amend

# Create a new commit that reverses a previous commit (safe)
git revert a3f8c91
```

!!! warning "git reset"
    `git reset` is powerful and can rewrite history or discard uncommitted work permanently. Until you understand what it does, stick to `git restore` and `git revert`.

---

## .gitignore

Not every file in your working directory should be tracked. Build artifacts, dependency directories, and files containing secrets should never go into version control.

A `.gitignore` file tells Git which files to ignore:

```gitignore
# Python
__pycache__/
*.pyc
.venv/

# Node
node_modules/
dist/

# Environment files (NEVER commit these)
.env
.env.local
*.env

# Editor
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
```

Put `.gitignore` in the root of your repository and commit it. GitHub provides language-specific `.gitignore` templates when you create a new repo — use them.

---

## Summary

- Git stores snapshots, not deltas. Every commit has a SHA-1 hash derived from its content.
- The three areas are: working directory, staging area, repository.
- Stage intentionally using `git add -p` to keep commits focused.
- Commits should represent a single logical change, described clearly.
- Never commit secrets, build artifacts, or dependency directories.
