#!/usr/bin/env bash
# sync-devto.sh — Pull new dev.to articles into the MkDocs site

set -euo pipefail

export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       dev.to → MkDocs Sync Script        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── dependency check ──────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Error: python3 is required but not found.${NC}"; exit 1
fi
if ! command -v curl &>/dev/null; then
    echo -e "${RED}Error: curl is required but not found.${NC}"; exit 1
fi

echo -e "${CYAN}Working directory:${NC} $SCRIPT_DIR"
echo ""

# ── hand off to Python ────────────────────────────────────────────────────────
python3 - << 'PYTHON_EOF'
import os, sys, json, re, urllib.request, urllib.error
from datetime import datetime, timezone
from pathlib import Path

# ── constants ─────────────────────────────────────────────────────────────────
SCRIPT_DIR  = Path(os.environ["SCRIPT_DIR"])
DOCS_DIR    = SCRIPT_DIR / "docs" / "modules"
MKDOCS_YML  = SCRIPT_DIR / "mkdocs.yml"
API_BASE    = "https://dev.to/api"
USERNAME    = "jumptotech"

# Module keyword rules — first match wins.
# Keywords are matched case-insensitively against the article title.
MODULE_RULES = [
    ("08-monitoring",  ["prometheus", "grafana", "monitoring", "alertmanager",
                        " sre ", "slo", "sla", "sli", "observability"]),
    ("07-terraform",   ["terraform", "terragrunt", "opentofu"]),
    ("05-kubernetes",  ["kubernetes", "k8s", "helm", "argocd", "gitops",
                        "kubectl", "statefulset", "ingress controller"]),
    ("04-docker",      ["docker", "dockerfile", "containeriz", "compose"]),
    ("06-cicd",        ["jenkins", "gitlab", "github action", "ci/cd", "cicd",
                        "pipeline", "newman", "postman", " ci "]),
    ("02-linux",       ["linux", " bash ", "shell script", "ubuntu", "systemd",
                        "cron", "chmod", "grep", "awk"]),
    ("03-networking",  ["networking", " dns ", "subnet", "subnetting", "vlan",
                        "firewall", " nat ", " dhcp ", "osi model", "tcp/ip",
                        " ip address", "packet tracer", "wireshark", "protocol"]),
    ("09-aws",         [" aws ", "amazon web", "ec2 ", " s3 ", " iam ", " rds ",
                        "lambda", "cloudfront", "route 53", " vpc ", " alb ",
                        " elb ", " asg ", " ecs ", "dynamodb", "aurora",
                        "elasticache", "cloudwatch", " sqs ", " sns ", "eks"]),
    ("10-ansible",     ["ansible", "playbook"]),
    ("11-kafka",       ["kafka", "confluent", "ksqldb", "schema registry"]),
    ("12-azure",       ["azure", "microsoft azure"]),
    ("01-git",         [r"\bgit\b", "github", "gitflow", "version control",
                        "branching strategy", "git rebase", "git merge"]),
]

# Nav section labels that appear in mkdocs.yml
MODULE_NAV_LABEL = {
    "01-git":        "01 · Git",
    "02-linux":      "02 · Linux",
    "03-networking": "03 · Networking",
    "04-docker":     "04 · Docker",
    "05-kubernetes": "05 · Kubernetes",
    "06-cicd":       "06 · CI/CD",
    "07-terraform":  "07 · Terraform",
    "08-monitoring": "08 · Monitoring",
    "09-aws":        "09 · AWS (SAA-C04)",
    "10-ansible":    "10 · Ansible",
    "11-kafka":      "11 · Kafka",
    "12-azure":      "12 · Azure",
}

# ── helpers ───────────────────────────────────────────────────────────────────

def fetch_json(url):
    """HTTP GET → parsed JSON. Raises on network/HTTP errors."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "sync-devto/1.0"})
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        print(f"  HTTP {e.code} fetching {url}")
        raise
    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        raise


def slug_to_filename(devto_slug):
    """
    Strip the trailing dev.to hash suffix (e.g. '-a3b', '-39oc') from a slug.
    The hash always contains at least one digit and is 3–5 chars long.
    """
    cleaned = re.sub(r'-[a-z0-9]{3,5}$',
                     lambda m: '' if re.search(r'\d', m.group()) else m.group(),
                     devto_slug)
    return cleaned + ".md"


def categorize(title):
    """Return the module folder name (e.g. '08-monitoring') or None."""
    title_lower = " " + title.lower() + " "
    for module, keywords in MODULE_RULES:
        for kw in keywords:
            # keywords starting with \b use regex; others use plain substring
            if kw.startswith(r'\b') or kw.endswith(r'\b'):
                if re.search(kw, title_lower, re.IGNORECASE):
                    return module
            else:
                if kw.lower() in title_lower:
                    return module
    return None


def collect_known_sources():
    """
    Scan every .md in docs/modules/** for 'source:' and 'devto_id:' frontmatter.
    Returns (set_of_source_urls, set_of_devto_ids).
    """
    source_urls = set()
    devto_ids   = set()
    for md in DOCS_DIR.rglob("*.md"):
        try:
            text = md.read_text(encoding="utf-8", errors="ignore")
            # Only inspect the frontmatter block
            if text.startswith("---"):
                block_end = text.find("---", 3)
                frontmatter = text[:block_end] if block_end != -1 else text[:500]
            else:
                frontmatter = text[:500]
            m = re.search(r'^source:\s*["\']?(https?://[^\s"\']+)', frontmatter, re.M)
            if m:
                source_urls.add(m.group(1).rstrip('/'))
            m2 = re.search(r'^devto_id:\s*(\d+)', frontmatter, re.M)
            if m2:
                devto_ids.add(int(m2.group(1)))
        except Exception:
            pass
    return source_urls, devto_ids


def unique_filepath(folder, filename):
    """Return a Path that does not yet exist, appending -2, -3 … if needed."""
    base = Path(filename).stem
    ext  = Path(filename).suffix
    candidate = folder / filename
    n = 2
    while candidate.exists():
        candidate = folder / f"{base}-{n}{ext}"
        n += 1
    return candidate


def write_article(article_data, module_folder):
    """
    Save one article as a markdown file inside DOCS_DIR/module_folder/.
    Returns (Path, title) or raises on error.
    """
    folder   = DOCS_DIR / module_folder
    folder.mkdir(parents=True, exist_ok=True)

    title    = article_data.get("title", "Untitled")
    slug     = article_data.get("slug", "article")
    body     = article_data.get("body_markdown", "")
    pub_at   = article_data.get("published_at", "")
    url      = article_data.get("url", "")
    desc     = article_data.get("description", "")
    art_id   = article_data.get("id", 0)

    # Parse date
    try:
        pub_date = datetime.fromisoformat(pub_at.replace("Z", "+00:00")).strftime("%Y-%m-%d")
    except Exception:
        pub_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Sanitise title for YAML — escape internal double-quotes
    safe_title = title.replace('"', '\\"')
    safe_desc  = desc.replace('"', '\\"').replace('\n', ' ')[:200]

    filename = slug_to_filename(slug)
    filepath = unique_filepath(folder, filename)

    content = f'---\ntitle: "{safe_title}"\ndescription: "{safe_desc}"\npublished: {pub_date}\nsource: "{url}"\ndevto_id: {art_id}\n---\n\n# {title}\n\n{body}\n'

    filepath.write_text(content, encoding="utf-8")
    return filepath, title


def update_mkdocs_nav(module_folder, article_title, rel_path):
    """
    Append one article entry to the correct Articles: section in mkdocs.yml.
    Returns True if the nav was updated, False if the path was already present.
    """
    module_id  = module_folder                          # e.g. "08-monitoring"
    nav_label  = MODULE_NAV_LABEL.get(module_id, "")
    if not nav_label:
        return False

    lines = MKDOCS_YML.read_text(encoding="utf-8").splitlines(keepends=True)

    # Guard: skip if already in nav
    if any(rel_path in line for line in lines):
        return False

    # 1. Find the nav section for this module
    section_idx = None
    for i, line in enumerate(lines):
        if nav_label in line and line.strip().startswith('- '):
            section_idx = i
            break
    if section_idx is None:
        print(f"  WARNING: nav section '{nav_label}' not found in mkdocs.yml")
        return False

    # 2. Find "- Articles:" within this section
    articles_idx = None
    for i in range(section_idx + 1, len(lines)):
        stripped = lines[i].strip()
        # A new top-level nav item means we've left this section
        if i > section_idx and re.match(r'^\s{2}- "', lines[i]) and i != section_idx:
            break
        if stripped == "- Articles:":
            articles_idx = i
            break

    if articles_idx is None:
        print(f"  WARNING: 'Articles:' not found under '{nav_label}'")
        return False

    # 3. Find the last article line inside this Articles: block (indent == 10)
    insert_after = articles_idx
    for i in range(articles_idx + 1, len(lines)):
        line = lines[i]
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(' '))
        if indent >= 10:
            insert_after = i
        else:
            break   # exited the Articles block

    # 4. Escape title for YAML and insert
    safe_title = article_title.replace('"', '\\"')
    new_line   = f'          - "{safe_title}": {rel_path}\n'
    lines.insert(insert_after + 1, new_line)

    MKDOCS_YML.write_text("".join(lines), encoding="utf-8")
    return True


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    print("Fetching article list from dev.to …")
    try:
        articles = fetch_json(f"{API_BASE}/articles?username={USERNAME}&per_page=1000")
    except Exception:
        print("Failed to fetch articles. Check your internet connection.")
        sys.exit(1)

    print(f"  Found {len(articles)} articles on dev.to")
    print("")

    print("Scanning existing docs for already-saved articles …")
    known_urls, known_ids = collect_known_sources()
    print(f"  {len(known_urls)} unique source URLs already saved")
    print(f"  {len(known_ids)}  articles tracked by devto_id")
    print("")

    # Determine which articles are new
    new_articles = []
    for art in articles:
        art_id  = art.get("id", 0)
        art_url = art.get("url", "").rstrip("/")
        if art_id in known_ids:
            continue
        if art_url in known_urls:
            continue
        new_articles.append(art)

    if not new_articles:
        print("Everything is up to date. No new articles found.")
        return

    print(f"Found {len(new_articles)} new article(s) to sync:")
    for a in new_articles:
        print(f"  • [{a['id']}] {a['title']}")
    print("")

    added_by_module = {}
    skipped = []

    for art in new_articles:
        art_id = art["id"]
        title  = art["title"]
        print(f"Processing: {title}")

        # Categorize
        module_id = categorize(title)
        if not module_id:
            print(f"  ⚠  Could not categorize — skipping (no keyword match)")
            skipped.append(title)
            continue

        print(f"  → module: {module_id}")

        # Fetch full article body
        try:
            full = fetch_json(f"{API_BASE}/articles/{art_id}")
        except Exception:
            print(f"  ✗ Failed to fetch article body — skipping")
            skipped.append(title)
            continue

        # Save file
        try:
            filepath, saved_title = write_article(full, module_id)
        except Exception as e:
            print(f"  ✗ Failed to write file: {e} — skipping")
            skipped.append(title)
            continue

        # Relative path for mkdocs nav (relative to docs/)
        rel_path = "modules/" + module_id + "/" + filepath.name

        # Update mkdocs.yml
        nav_updated = update_mkdocs_nav(module_id, saved_title, rel_path)

        status = "✓" if nav_updated else "✓ (file saved; nav path already present)"
        print(f"  {status} Saved → {rel_path}")

        added_by_module.setdefault(module_id, []).append(saved_title)

    # ── summary ───────────────────────────────────────────────────────────────
    print("")
    print("=" * 60)
    print("SYNC COMPLETE")
    print("=" * 60)

    total_added = sum(len(v) for v in added_by_module.values())
    print(f"New articles added : {total_added}")
    print(f"Skipped            : {len(skipped)}")
    print("")

    if added_by_module:
        print("Articles by module:")
        for mod, titles in sorted(added_by_module.items()):
            label = MODULE_NAV_LABEL.get(mod, mod)
            print(f"  {label} ({len(titles)}):")
            for t in titles:
                print(f"    • {t}")
        print("")

    if skipped:
        print("Skipped (no keyword match or fetch error):")
        for t in skipped:
            print(f"  • {t}")
        print("")
        print("Tip: re-run after adding keywords for the above titles,")
        print("     or manually move them to the correct module folder.")


main()
PYTHON_EOF

echo ""
echo -e "${GREEN}Done.${NC}"
