# JumptpTech DevOps School

Hands-on DevOps curriculum — from Git to Kubernetes and beyond.
Built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and sourced from the [dev.to/jumptotech](https://dev.to/jumptotech) blog.

---

## Quick start

```bash
# Install dependencies (first time only)
pip install mkdocs-material mkdocs-minify-plugin

# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

---

## Syncing new articles from dev.to

`sync-devto.sh` pulls any article published on [dev.to/jumptotech](https://dev.to/jumptotech) that is not yet saved locally, categorizes it into the correct module folder, saves it as a Markdown file, and updates `mkdocs.yml` automatically.

### Usage

```bash
./sync-devto.sh
```

No arguments needed. The script requires `curl` and `python3` (both available on macOS/Linux by default).

### What it does, step by step

1. **Fetches** all articles via `GET https://dev.to/api/articles?username=jumptotech&per_page=1000`
2. **Scans** every `.md` file under `docs/modules/` for a `source:` frontmatter URL to build a list of already-saved articles
3. **Identifies** new articles (any whose dev.to URL is not yet present locally)
4. **Fetches** the full Markdown body for each new article via `GET https://dev.to/api/articles/{id}`
5. **Categorizes** each article into a module folder based on keywords found in the title:

   | Keywords in title | Module |
   |---|---|
   | prometheus, grafana, monitoring, SRE, SLO, SLA, observability | `08-monitoring` |
   | terraform | `07-terraform` |
   | kubernetes, k8s, helm, argocd, gitops, kubectl, statefulset | `05-kubernetes` |
   | docker, dockerfile, compose | `04-docker` |
   | jenkins, gitlab, github action, ci/cd, pipeline, newman, postman | `06-cicd` |
   | linux, bash, shell script, ubuntu, systemd | `02-linux` |
   | networking, dns, subnet, vlan, firewall, nat, dhcp, tcp/ip | `03-networking` |
   | aws, ec2, s3, iam, rds, lambda, cloudfront, vpc, alb, eks, … | `09-aws` |
   | ansible, playbook | `10-ansible` |
   | kafka, confluent | `11-kafka` |
   | azure, microsoft azure | `12-azure` |
   | git, github, gitflow, version control | `01-git` |

   Rules are checked in order; the first match wins.

6. **Saves** each article as `docs/modules/<module>/<slug>.md` with YAML frontmatter:
   ```yaml
   ---
   title: "Article title"
   description: "Short description"
   published: 2026-05-20
   source: "https://dev.to/jumptotech/..."
   devto_id: 1234567
   ---
   ```
7. **Updates** `mkdocs.yml` — appends the new article to the `Articles:` section of the matching module in the nav
8. **Prints** a summary of what was added and where

### Example output

```
╔══════════════════════════════════════════╗
║       dev.to → MkDocs Sync Script        ║
╚══════════════════════════════════════════╝

Fetching article list from dev.to …
  Found 312 articles on dev.to

Scanning existing docs for already-saved articles …
  296 unique source URLs already saved

Found 16 new article(s) to sync:
  • [3701234] How to set up Grafana Loki
  ...

Processing: How to set up Grafana Loki
  → module: 08-monitoring
  ✓ Saved → modules/08-monitoring/how-to-set-up-grafana-loki.md

============================================================
SYNC COMPLETE
============================================================
New articles added : 16
Skipped            : 0

Articles by module:
  08 · Monitoring (3):
    • How to set up Grafana Loki
    ...
```

### Handling unmatched articles

If an article title contains no recognized keywords, the script prints a warning and skips that article. To handle it manually:

1. Copy the article from dev.to as a `.md` file into the correct `docs/modules/<module>/` folder
2. Add a `source: "https://dev.to/jumptotech/..."` frontmatter line so future runs skip it
3. Add an entry to `mkdocs.yml` under the matching module's `Articles:` section

### Scheduling automatic syncs

To run the sync automatically every time you start work:

```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
alias school-sync="cd ~/jumptptech-school && ./sync-devto.sh"
```

Or set up a cron job to run nightly:

```bash
# Run at 02:00 every day
0 2 * * * cd /path/to/jumptptech-school && ./sync-devto.sh >> sync.log 2>&1
```

---

## Project structure

```
jumptptech-school/
├── docs/
│   ├── index.md               Home page
│   ├── modules/
│   │   ├── 01-git/
│   │   ├── 02-linux/
│   │   ├── 03-networking/
│   │   ├── 04-docker/
│   │   ├── 05-kubernetes/
│   │   ├── 06-cicd/
│   │   ├── 07-terraform/
│   │   ├── 08-monitoring/
│   │   ├── 09-aws/
│   │   ├── 10-ansible/
│   │   ├── 11-kafka/
│   │   └── 12-azure/
│   └── cheatsheets/
├── mkdocs.yml                 Site configuration & nav
├── sync-devto.sh              Dev.to sync script
└── README.md                  This file
```
