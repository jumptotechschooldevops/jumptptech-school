# Git Cheatsheet

## Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global pull.rebase true           # rebase instead of merge on pull
```

## Repository

```bash
git init                          # new repo in current directory
git clone <url>                   # clone remote repo
git clone <url> my-dir            # clone into specific directory
git remote -v                     # show remote URLs
git remote add origin <url>       # add a remote
```

## Status & diff

```bash
git status                        # what's changed
git status -s                     # short format
git diff                          # unstaged changes (working dir vs staging)
git diff --staged                 # staged changes (staging vs last commit)
git diff HEAD~1 HEAD              # compare last two commits
git diff main feature             # compare branches
```

## Staging & committing

```bash
git add file.txt                  # stage a file
git add .                         # stage all changes
git add -p                        # interactive hunk staging
git commit -m "message"           # commit staged changes
git commit -am "message"          # stage tracked + commit
git commit --amend                # modify last commit (DON'T if pushed)
```

## Branching

```bash
git branch                        # list local branches
git branch -a                     # list all (including remote-tracking)
git switch -c feature/name        # create and switch
git switch main                   # switch to existing branch
git branch -d feature/name        # delete (must be merged)
git branch -D feature/name        # force delete
git branch -m old-name new-name   # rename
```

## Merging & rebasing

```bash
git merge feature/name            # merge branch into current
git merge --squash feature/name   # squash all commits, then commit
git merge --abort                 # abort in-progress merge

git rebase main                   # rebase current branch onto main
git rebase -i HEAD~3              # interactive rebase last 3 commits
git rebase --abort                # abort rebase
git rebase --continue             # continue after resolving conflict
```

## Remote operations

```bash
git fetch origin                  # download changes (don't merge)
git pull                          # fetch + merge (or rebase if configured)
git pull --rebase origin main     # fetch + rebase
git push -u origin feature/name   # push and set upstream
git push                          # push to upstream branch
git push --tags                   # push all tags
git push -f origin feature/name   # force push (DANGER on shared branches)
```

## History

```bash
git log                           # full history
git log --oneline                 # compact one-line format
git log --oneline --graph --all   # graph view
git log --follow -- file.txt      # history of specific file
git log -p                        # show diffs with each commit
git log --author="Name"           # filter by author
git log --since="2 weeks ago"     # filter by date
git show abc1234                  # show specific commit
git blame file.txt                # who changed each line
```

## Undoing

```bash
git restore --staged file.txt     # unstage (keep working dir change)
git restore file.txt              # discard working dir change (DESTRUCTIVE)
git revert abc1234                # create commit that undoes a commit (safe)
git reset --soft HEAD~1           # undo last commit, keep staged changes
git reset --mixed HEAD~1          # undo last commit, keep unstaged (default)
git reset --hard HEAD~1           # undo last commit, discard changes (DESTRUCTIVE)
```

## Tags

```bash
git tag                           # list tags
git tag v1.0.0                    # lightweight tag
git tag -a v1.0.0 -m "Release"   # annotated tag (preferred)
git push origin v1.0.0            # push a tag
git push origin --tags            # push all tags
git tag -d v1.0.0                 # delete tag locally
```

## Stashing

```bash
git stash                         # stash working dir and staged changes
git stash push -m "description"   # stash with message
git stash list                    # list stashes
git stash pop                     # apply latest stash and remove it
git stash apply stash@{1}         # apply without removing
git stash drop stash@{0}          # remove a stash
git stash clear                   # remove all stashes
```

## Searching

```bash
git grep "pattern"                # search in working directory (tracked files)
git grep "pattern" abc1234        # search in a specific commit
git log -S "function_name"        # find commits that changed a string
git log --all --grep="fix bug"    # search commit messages
```

## Aliases (add to ~/.gitconfig)

```ini
[alias]
    st = status -s
    co = switch
    br = branch
    lg = log --oneline --graph --all
    last = log -1 HEAD
    unstage = restore --staged
    changes = diff --staged
```

## .gitignore patterns

```gitignore
*.log           # all .log files
build/          # directory and contents
!important.log  # exception (don't ignore this one)
**/temp/        # temp/ in any subdirectory
doc/*.txt       # only in doc/, not subdirs
```

## Common workflows

### Feature branch

```bash
git switch main && git pull
git switch -c feature/my-feature
# ... make commits ...
git push -u origin feature/my-feature
# Open PR, get reviewed, merge
git switch main && git pull
git branch -d feature/my-feature
```

### Fix a mistake in the last commit

```bash
# Add the forgotten change
git add forgotten-file.txt
git commit --amend --no-edit     # only if NOT yet pushed
```

### Cherry-pick a commit from another branch

```bash
git cherry-pick abc1234
```
