# Module 01 · Git

Git is the foundation of everything we do in this program. Every pipeline, every deployment, every infrastructure change starts with a commit. If your Git workflow is sloppy, your entire engineering practice will be sloppy.

This module is not a tour of all Git commands. It is a focused look at how professional teams actually use Git — branching models, commit hygiene, conflict resolution, and the pull request workflow that every company with more than one engineer follows.

## What you will cover

**Lecture 1 — Version Control Fundamentals**
How Git stores data, what a commit actually is, the staging area, and why the history graph matters.

**Lecture 2 — Branching & Collaboration**
Feature branches, rebase vs merge, how pull requests work, and the conventions that make team Git sustainable.

**Lab 1 — Git Basics**
Initialise a repo, stage and commit changes, inspect history, undo mistakes.

**Lab 2 — Team Workflow**
Simulate a multi-developer workflow: feature branches, pull requests, merge conflicts, and resolution.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 45 min |
| Lecture 2 | 45 min |
| Lab 1 | 60 min |
| Lab 2 | 90 min |

## Setup required

```bash
# Check Git is installed
git --version   # should be 2.39 or later

# Set your identity (required for commits)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set a default branch name
git config --global init.defaultBranch main
```
