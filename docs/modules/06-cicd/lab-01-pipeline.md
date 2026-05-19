# Lab 1 · Build & Test Pipeline

**Duration:** ~90 minutes  
**Goal:** Create a GitHub repository with a Python Flask application and a complete CI pipeline that lints, tests, builds, and pushes a Docker image.

---

## Setup

### Create the repository

1. Create a new public GitHub repository named `devops-ci-lab`
2. Clone it locally:

```bash
git clone https://github.com/YOUR_USERNAME/devops-ci-lab.git
cd devops-ci-lab
```

---

## Part 1 — Application code

### 1.1 Flask application

```bash
mkdir -p src tests
```

```bash
cat > src/__init__.py << 'EOF'
EOF

cat > src/app.py << 'EOF'
from flask import Flask, jsonify, request
from datetime import datetime
import os

app = Flask(__name__)
VERSION = os.environ.get("APP_VERSION", "dev")

todos = []
next_id = 1


@app.route("/health")
def health():
    return jsonify({"status": "ok", "version": VERSION, "time": datetime.utcnow().isoformat()})


@app.route("/todos", methods=["GET"])
def list_todos():
    return jsonify({"todos": todos, "count": len(todos)})


@app.route("/todos", methods=["POST"])
def create_todo():
    global next_id
    data = request.get_json()
    if not data or not data.get("title"):
        return jsonify({"error": "title is required"}), 400
    todo = {"id": next_id, "title": data["title"], "done": False}
    todos.append(todo)
    next_id += 1
    return jsonify(todo), 201


@app.route("/todos/<int:todo_id>", methods=["PATCH"])
def update_todo(todo_id):
    todo = next((t for t in todos if t["id"] == todo_id), None)
    if not todo:
        return jsonify({"error": "not found"}), 404
    data = request.get_json()
    if "done" in data:
        todo["done"] = bool(data["done"])
    if "title" in data:
        todo["title"] = data["title"]
    return jsonify(todo)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
EOF
```

### 1.2 Tests

```bash
cat > tests/__init__.py << 'EOF'
EOF

cat > tests/test_app.py << 'EOF'
import json
import pytest
from src.app import app, todos


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        todos.clear()
        yield client


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "ok"
    assert "version" in data


def test_list_todos_empty(client):
    resp = client.get("/todos")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["todos"] == []
    assert data["count"] == 0


def test_create_todo(client):
    resp = client.post("/todos",
                       data=json.dumps({"title": "Buy groceries"}),
                       content_type="application/json")
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["title"] == "Buy groceries"
    assert data["done"] is False
    assert "id" in data


def test_create_todo_missing_title(client):
    resp = client.post("/todos",
                       data=json.dumps({}),
                       content_type="application/json")
    assert resp.status_code == 400


def test_list_todos_after_creation(client):
    client.post("/todos",
                data=json.dumps({"title": "First"}),
                content_type="application/json")
    client.post("/todos",
                data=json.dumps({"title": "Second"}),
                content_type="application/json")
    resp = client.get("/todos")
    data = resp.get_json()
    assert data["count"] == 2


def test_update_todo(client):
    create_resp = client.post("/todos",
                              data=json.dumps({"title": "Test"}),
                              content_type="application/json")
    todo_id = create_resp.get_json()["id"]

    resp = client.patch(f"/todos/{todo_id}",
                        data=json.dumps({"done": True}),
                        content_type="application/json")
    assert resp.status_code == 200
    assert resp.get_json()["done"] is True


def test_update_todo_not_found(client):
    resp = client.patch("/todos/9999",
                        data=json.dumps({"done": True}),
                        content_type="application/json")
    assert resp.status_code == 404
EOF
```

### 1.3 Dependencies

```bash
cat > requirements.txt << 'EOF'
flask==3.0.3
gunicorn==22.0.0
EOF

cat > requirements-dev.txt << 'EOF'
-r requirements.txt
pytest==8.2.2
pytest-cov==5.0.0
flake8==7.0.0
black==24.4.2
EOF
```

### 1.4 Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM python:3.12-slim

RUN groupadd -g 1001 appgroup && useradd -u 1001 -g appgroup -M appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appgroup src/ ./src/

USER appuser
EXPOSE 5000

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "src.app:app"]
EOF

cat > .dockerignore << 'EOF'
.git
.github
.venv
__pycache__
*.pyc
tests/
*.md
.flake8
.coveragerc
Dockerfile*
EOF
```

### 1.5 Linting configuration

```bash
cat > .flake8 << 'EOF'
[flake8]
max-line-length = 100
exclude = .git, __pycache__, .venv
per-file-ignores =
    tests/*: F401
EOF
```

### 1.6 Test it locally

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt

# Lint
flake8 src/ tests/
black --check src/ tests/

# Test
pytest tests/ -v --cov=src --cov-report=term-missing

# Build
docker build -t devops-ci-lab:local .
docker run -p 5000:5000 -d devops-ci-lab:local
curl http://localhost:5000/health
docker stop $(docker ps -q --filter ancestor=devops-ci-lab:local)
```

---

## Part 2 — GitHub Actions workflow

```bash
mkdir -p .github/workflows
```

```bash
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ github.repository_owner }}/devops-ci-lab

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip

      - name: Install dependencies
        run: pip install -r requirements-dev.txt

      - name: Run flake8
        run: flake8 src/ tests/

      - name: Check formatting with black
        run: black --check src/ tests/

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
        run: pip install -r requirements-dev.txt

      - name: Run tests with coverage
        run: |
          pytest tests/ -v \
            --cov=src \
            --cov-report=xml \
            --cov-report=term-missing \
            --junitxml=test-results.xml

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: test-results.xml

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage.xml

  build:
    name: Build and push image
    runs-on: ubuntu-latest
    needs: [lint, test]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}

      - name: Print image info
        run: |
          echo "Image tags: ${{ steps.meta.outputs.tags }}"
          echo "Image digest: ${{ steps.build.outputs.digest }}"
EOF
```

---

## Part 3 — Configure secrets

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `DOCKERHUB_USERNAME` — your Docker Hub username
   - `DOCKERHUB_TOKEN` — a Docker Hub access token (Account Settings → Security → New access token)

---

## Part 4 — Trigger the pipeline

```bash
git add -A
git commit -m "Add Flask todo app with CI pipeline"
git push origin main
```

Open the Actions tab on GitHub. Watch the pipeline run.

### Verify each stage

1. **Lint** — should pass if code follows flake8 and black rules
2. **Test** — all 7 tests should pass with >90% coverage
3. **Build** — image should be pushed to Docker Hub

### Check the built image

```bash
docker pull YOUR_USERNAME/devops-ci-lab:latest
docker run -p 5000:5000 YOUR_USERNAME/devops-ci-lab:latest
curl http://localhost:5000/health
```

---

## Part 5 — Test the pipeline catches failures

### 5.1 Break a test

```bash
git checkout -b feature/break-test

# Modify health endpoint to return wrong status
sed -i 's/return jsonify({"status": "ok"/return jsonify({"status": "broken"/' src/app.py

git add src/app.py
git commit -m "Break health endpoint (test)"
git push -u origin feature/break-test
```

Open a pull request. The test job should fail, and the build job should not run.

```bash
# Fix it
git revert HEAD
git push origin feature/break-test
```

The pipeline should go green again. Merge the PR (with the revert).

### 5.2 Add a failing lint check

```bash
git checkout main
git checkout -b feature/lint-test

# Add a line that violates flake8 (too long)
echo "x = 'this is a very very very very very very very very very very very very very very very very long string'" >> src/app.py

git add src/app.py
git commit -m "Add overly long line (lint test)"
git push -u origin feature/lint-test
```

The lint job should fail. No tests run, no build.

Revert and merge.

---

## Checkpoint

Your pipeline should:

- [x] Trigger on every push to main and every PR targeting main
- [x] Lint Python code with flake8 and check formatting with black
- [x] Run 7 tests with coverage reporting
- [x] Upload test results as build artifacts
- [x] Build and push a Docker image tagged with the git SHA (only on main)
- [x] Block deployment (build) if lint or tests fail

Check that `docker.io/YOUR_USERNAME/devops-ci-lab:sha-xxxxxx` exists in Docker Hub.
