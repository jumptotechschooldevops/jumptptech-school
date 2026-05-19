# Lecture 2 · Branching & Collaboration

## What a branch is

A branch is just a pointer to a commit. That is it. When you create a branch, Git writes a file in `.git/refs/heads/` containing one 40-character hash.

When you commit on a branch, that pointer moves forward to the new commit. The branch does not copy any files. It just points to a different place in the history graph.

`HEAD` is a special pointer that tells Git which branch you are currently on. When you run `git commit`, Git advances the branch that `HEAD` points to.

```
main:    A → B → C
                  ↑ HEAD
```

After `git checkout -b feature`:

```
main:    A → B → C
                  ↑
feature:           (same C, HEAD now on feature)
```

After one commit on feature:

```
main:    A → B → C
                   \
feature:             D  ← HEAD
```

---

## Creating and switching branches

```bash
# Create a branch and switch to it
git checkout -b feature/user-auth

# Modern equivalent (Git 2.23+)
git switch -c feature/user-auth

# List all branches
git branch -a   # -a includes remote-tracking branches

# Switch to an existing branch
git switch main

# Delete a branch (only if merged)
git branch -d feature/user-auth

# Force-delete (even if not merged)
git branch -D feature/user-auth
```

### Branch naming conventions

Teams adopt consistent naming schemes so branches are easy to understand at a glance:

```
feature/short-description       # new functionality
fix/what-is-being-fixed         # bug fix
chore/dependency-updates        # maintenance, no user-facing change
docs/update-readme              # documentation only
hotfix/critical-payment-bug     # urgent fix that goes straight to main
```

The prefix tells reviewers what kind of change to expect before they even open the pull request.

---

## Merging

Once you have finished work on a branch, you bring it back into the main branch through a merge.

```bash
git switch main
git merge feature/user-auth
```

Git finds the common ancestor of both branches and combines the changes.

### Fast-forward merge

If `main` has not moved since you branched off it, Git can just advance `main`'s pointer to the tip of your branch. No new commit is created. The history stays linear.

```
Before:
main:    A → B → C
                   \
feature:             D → E

After fast-forward:
main:    A → B → C → D → E
```

### Three-way merge

If `main` has new commits since you branched, Git needs to create a **merge commit** that has two parents.

```
Before:
main:    A → B → C → F
                   \
feature:             D → E

After merge:
main:    A → B → C → F → M
                   \     /
feature:             D → E
```

Merge commit `M` contains the combined changes from both sides.

---

## Rebase

Rebase is an alternative to merge. Instead of creating a merge commit, it replays your commits on top of the target branch, creating new commits with new hashes.

```bash
git switch feature/user-auth
git rebase main
```

```
Before:
main:    A → B → C → F
                   \
feature:             D → E

After rebase:
main:    A → B → C → F
                       \
feature:                D' → E'  (new commits, new hashes)
```

The result looks like you branched off `F` all along. The history is linear and easier to read.

### When to use each

| Situation | Use |
|-----------|-----|
| Sharing work with a team on a long-lived branch | Merge |
| Bringing a local feature branch up to date with main | Rebase |
| Clean linear history on your personal branch before PR | Rebase |
| Already pushed and others have pulled your branch | Merge (rebase rewrites history) |

!!! danger "The golden rule of rebase"
    Never rebase commits that have been pushed to a shared remote branch. Rebase rewrites history. If someone else has based their work on your old commits, their history and yours will diverge and merging becomes painful.

---

## Merge conflicts

Conflicts happen when two branches change the same part of the same file differently. Git cannot decide which version to keep, so it stops and asks you.

```
<<<<<<< HEAD
return "Hello, world"
=======
return "Hi there"
>>>>>>> feature/greeting-update
```

To resolve:

1. Edit the file to contain what it should actually say (remove the conflict markers)
2. Stage the resolved file: `git add src/greet.py`
3. Complete the merge: `git commit`

```bash
# See which files have conflicts
git status

# Open all conflicted files in your editor at once
git diff --name-only --diff-filter=U | xargs code
```

Keeping commits focused (single logical change, as discussed in Lecture 1) dramatically reduces conflicts. The smaller and more targeted your changes, the less likely they are to collide with someone else's work.

---

## Remotes and the push/pull workflow

A **remote** is a copy of your repository stored somewhere else — usually GitHub, GitLab, or Bitbucket.

```bash
# See configured remotes
git remote -v

# Add a remote (automatically done when you clone)
git remote add origin https://github.com/org/repo.git

# Push your branch to the remote
git push -u origin feature/user-auth
# -u sets the upstream, so future pushes can just be: git push

# Fetch changes from the remote without merging
git fetch origin

# Pull = fetch + merge (or fetch + rebase with --rebase)
git pull origin main
git pull --rebase origin main
```

---

## Pull requests

A pull request (PR) is not a Git concept — it is a collaboration feature added by GitHub and similar platforms. It is a formal request to merge one branch into another, with a built-in review interface.

The typical workflow:

1. Branch off `main`: `git switch -c feature/my-thing`
2. Make commits
3. Push to remote: `git push -u origin feature/my-thing`
4. Open a pull request on GitHub (main ← feature/my-thing)
5. Teammates review: comment on specific lines, request changes, approve
6. Address review feedback with additional commits
7. Merge (or squash-merge) the PR
8. Delete the feature branch

### What a good PR looks like

- **Small** — less than 400 lines changed is a reasonable target. Reviewers skip large PRs.
- **One thing** — a PR that adds authentication AND refactors the database layer AND updates dependencies is three PRs pretending to be one.
- **Described** — the PR description explains *why* the change is being made. The diff already shows *what* changed.
- **Tests included** — if the change adds behaviour, it adds tests.

### Squash vs merge vs rebase merge

GitHub offers three ways to close a PR:

| Strategy | What it does | Best for |
|----------|-------------|----------|
| Create a merge commit | Preserves all commits, adds a merge commit | Long-lived branches with meaningful commit history |
| Squash and merge | Combines all PR commits into one | Feature branches with "WIP", "fixup", "address review" commits |
| Rebase and merge | Replays PR commits on main, no merge commit | PRs where every commit is meaningful and clean |

Most teams pick one and stick with it. Squash-and-merge is the most common because it keeps the main branch history clean while allowing messy in-progress commits on feature branches.

---

## Summary

- A branch is just a pointer to a commit — it costs almost nothing to create.
- Fast-forward merge keeps history linear; three-way merge creates a merge commit.
- Rebase replays commits on a new base — use it to clean up local history before sharing.
- Never rebase pushed commits that others have pulled.
- Good pull requests are small, focused, and described. Reviewers read small PRs.
