# Lecture 2 · GitHub Actions in Depth

## What GitHub Actions is

GitHub Actions is a CI/CD platform built into GitHub. Workflows are YAML files in `.github/workflows/`. Every push, pull request, schedule, or manual trigger can start a workflow.

The key components:

| Concept | Description |
|---------|-------------|
| **Workflow** | A YAML file — the top-level automation unit |
| **Event** | What triggers the workflow (push, PR, schedule, manual) |
| **Job** | A group of steps that run on the same runner |
| **Step** | A single shell command or action |
| **Action** | Reusable unit of logic (community or custom) |
| **Runner** | The machine that executes jobs (GitHub-hosted or self-hosted) |

---

## Workflow structure

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Run tests
        run: pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4

  build:
    name: Build and push image
    runs-on: ubuntu-latest
    needs: test        # only runs if test succeeds
    if: github.ref == 'refs/heads/main'
    
    permissions:
      contents: read
      packages: write  # needed to push to ghcr.io
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Log in to registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

---

## Events and triggers

```yaml
on:
  # Trigger on push to specific branches
  push:
    branches: [main, release/**]
    paths:
      - "src/**"        # only trigger if files in src/ changed
      - "Dockerfile"

  # Trigger on pull requests
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]

  # Scheduled (cron syntax)
  schedule:
    - cron: "0 6 * * 1-5"   # 6am on weekdays

  # Manual trigger with inputs
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [staging, production]
        required: true
      version:
        type: string
        required: true

  # Triggered by another workflow completing
  workflow_run:
    workflows: [CI]
    types: [completed]
```

---

## Contexts and expressions

Contexts provide information about the workflow run:

```yaml
# github context
${{ github.sha }}              # current commit SHA
${{ github.ref }}              # branch/tag ref
${{ github.ref_name }}         # branch name
${{ github.actor }}            # user who triggered
${{ github.repository }}       # owner/repo
${{ github.event_name }}       # push, pull_request, etc.

# env context
${{ env.MY_VAR }}

# secrets context
${{ secrets.MY_SECRET }}

# Conditional expressions
if: github.ref == 'refs/heads/main'
if: github.event_name == 'push'
if: success() && github.ref == 'refs/heads/main'
if: always()                   # run even if previous steps failed
if: failure()                  # run only if previous steps failed
```

---

## Secrets and environment variables

### Setting secrets

In GitHub: Repository Settings → Secrets and variables → Actions → New repository secret.

For deployment secrets, use **environments** (Settings → Environments). Each environment can have different secrets and protection rules (like required reviewers).

### Using secrets

```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
    run: ./deploy.sh
```

Secrets are masked in logs — their values never appear in workflow output.

### GITHUB_TOKEN

Every workflow automatically gets `secrets.GITHUB_TOKEN` — a temporary token with permissions scoped to the repository. Use it for registry operations, creating releases, commenting on PRs.

```yaml
permissions:
  contents: write    # needed to create releases
  packages: write    # needed to push to ghcr.io
  issues: write      # needed to comment on issues
```

Default permissions are read for everything. Be explicit about what you need.

---

## Caching

Caching reduces build times by storing and reusing dependencies between runs:

```yaml
# Python with pip cache
- uses: actions/setup-python@v5
  with:
    python-version: "3.12"
    cache: pip             # built-in caching

# Explicit cache with custom key
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-

# Node.js
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm

# Docker layer cache
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

Cache keys work like this: if the exact key matches, use the cache. If not, try the restore-keys (prefix matches). Either way, the job runs, but with a warm cache.

---

## Matrix builds

Test across multiple versions or configurations in parallel:

```yaml
jobs:
  test:
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
        os: [ubuntu-latest, macos-latest]
        exclude:
          - os: macos-latest
            python-version: "3.10"  # skip specific combination
        include:
          - os: ubuntu-latest
            python-version: "3.12"
            experimental: true      # add extra matrix variable

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
```

This generates 5 parallel jobs (3×2 minus 1 excluded): each Python version on each OS.

---

## Reusable workflows

Extract common workflow patterns into reusable files:

```yaml
# .github/workflows/reusable-docker.yml
on:
  workflow_call:
    inputs:
      image-name:
        type: string
        required: true
      dockerfile:
        type: string
        default: Dockerfile
    secrets:
      registry-password:
        required: true
    outputs:
      image-tag:
        value: ${{ jobs.build.outputs.tag }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      tag: ${{ steps.meta.outputs.tags }}
    steps:
      # ...
```

```yaml
# .github/workflows/main.yml
jobs:
  build-image:
    uses: ./.github/workflows/reusable-docker.yml
    with:
      image-name: myapp
    secrets:
      registry-password: ${{ secrets.REGISTRY_PASSWORD }}
```

---

## Job dependencies and outputs

```yaml
jobs:
  build:
    outputs:
      image-tag: ${{ steps.tag.outputs.value }}
    steps:
      - name: Generate tag
        id: tag
        run: echo "value=${{ github.sha }}" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.image-tag }}"

  deploy-prod:
    needs: [build, deploy-staging]
    environment: production    # requires manual approval
    steps:
      - run: echo "Deploying to prod"
```

The `environment: production` line triggers GitHub's required reviewers if configured — a workflow that pauses and waits for someone to approve before continuing.

---

## Common patterns

### Only run certain steps on main

```yaml
- name: Push to registry
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: docker push myapp:${{ github.sha }}
```

### Skip CI for documentation changes

```yaml
on:
  push:
    paths-ignore:
      - "docs/**"
      - "*.md"
```

### Notify on failure

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {"text": "Pipeline failed: ${{ github.workflow }} on ${{ github.ref }}"}
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Summary

- Workflows are YAML files in `.github/workflows/`. Jobs run in parallel by default; use `needs:` for ordering.
- Use `GITHUB_TOKEN` for registry operations — no extra secrets needed.
- Cache dependencies by hashing the requirements file — exact cache on the first run, prefix match on subsequent.
- Matrix builds test multiple configurations in parallel. Keep the matrix small enough to finish in 10 minutes.
- Reusable workflows reduce duplication across repositories.
- GitHub Environments with required reviewers implement deployment approval gates.
