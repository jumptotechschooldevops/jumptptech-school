# Lab 1 · Images & Registries

**Duration:** ~75 minutes  
**Goal:** Pull images, inspect layers, write and optimise Dockerfiles, push to Docker Hub.

**Prerequisites:** Docker installed and running (`docker run hello-world` works).

---

## Part 1 — Exploring images

### 1.1 Pull and inspect images

```bash
# Pull a few images
docker pull python:3.12-slim
docker pull python:3.12-alpine
docker pull nginx:1.25

# Compare sizes
docker images | grep python
```

Note the size difference between `slim` and `alpine`. Alpine uses musl libc instead of glibc — smaller, but some Python packages that include C extensions may not work correctly.

### 1.2 Inspect image layers

```bash
# View layer history for the slim image
docker image history python:3.12-slim

# View layer history for alpine
docker image history python:3.12-alpine
```

Each line is a layer. The `CREATED BY` column shows the Dockerfile instruction that created it.

```bash
# Get a detailed JSON inspection of an image
docker image inspect python:3.12-slim

# Extract specific fields
docker image inspect python:3.12-slim \
    --format '{{.Config.Cmd}}'     # default command

docker image inspect python:3.12-slim \
    --format '{{.Config.Env}}'     # environment variables

docker image inspect python:3.12-slim \
    --format '{{.RootFS.Layers}}' | tr , '\n'   # layer hashes
```

Count how many layers each image has:

```bash
docker image inspect python:3.12-slim --format '{{len .RootFS.Layers}}'
docker image inspect python:3.12-alpine --format '{{len .RootFS.Layers}}'
```

### 1.3 Run and explore inside

```bash
# Start a Python container interactively
docker run -it --rm python:3.12-slim bash

# Inside the container:
whoami
id
cat /etc/os-release
python3 --version
pip --version
df -h
ls /app 2>/dev/null || echo "no /app"
exit
```

---

## Part 2 — Build your first image

Create a simple web application:

```bash
mkdir -p ~/docker-lab/app
cd ~/docker-lab/app
```

### 2.1 Application code

```bash
cat > app.py << 'EOF'
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import platform
import os
import datetime

class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            response = {
                "status": "ok",
                "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
            }
            body = json.dumps(response).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif self.path == "/info":
            response = {
                "python_version": platform.python_version(),
                "hostname": platform.node(),
                "environment": os.environ.get("APP_ENV", "unknown"),
                "uptime_since": datetime.datetime.utcnow().isoformat() + "Z"
            }
            body = json.dumps(response, indent=2).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)

        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")

    def log_message(self, format, *args):
        print(f"[{datetime.datetime.utcnow().isoformat()}] {format % args}", flush=True)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    print(f"Starting server on port {port}", flush=True)
    HTTPServer(("0.0.0.0", port), AppHandler).serve_forever()
EOF
```

### 2.2 First Dockerfile (naive)

```bash
cat > Dockerfile.v1 << 'EOF'
FROM python:3.12
WORKDIR /app
COPY . .
CMD ["python3", "app.py"]
EOF
```

Build it:

```bash
docker build -f Dockerfile.v1 -t myapp:v1 .
docker images myapp
```

Note the size. The full `python:3.12` image is nearly 1GB.

### 2.3 Improved Dockerfile

```bash
cat > Dockerfile.v2 << 'EOF'
FROM python:3.12-slim

# Create non-root user
RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --no-create-home --shell /bin/false appuser

WORKDIR /app

# Copy and install dependencies (would be requirements.txt in a real app)
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=appuser:appgroup app.py .

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" \
    || exit 1

CMD ["python3", "app.py"]
EOF

docker build -f Dockerfile.v2 -t myapp:v2 .
docker images myapp
```

Compare sizes:

```bash
docker images myapp --format "table {{.Tag}}\t{{.Size}}"
```

### 2.4 Add .dockerignore

```bash
cat > .dockerignore << 'EOF'
.git
*.md
Dockerfile*
.dockerignore
__pycache__
*.pyc
.env
.venv
EOF
```

---

## Part 3 — Layer caching

### 3.1 Observe caching in action

```bash
# Build v2 again — should be fully cached
docker build -f Dockerfile.v2 -t myapp:v2 .
# Every step should show "CACHED"

# Modify the app code
echo "# comment" >> app.py

# Rebuild — which layers rebuild?
docker build -f Dockerfile.v2 -t myapp:v2 .
```

Only the `COPY` instruction and everything after it should be re-executed.

### 3.2 Caching with dependencies

Create a more realistic setup:

```bash
mkdir -p ~/docker-lab/flask-app
cd ~/docker-lab/flask-app

cat > requirements.txt << 'EOF'
flask==3.0.3
gunicorn==22.0.0
EOF

cat > app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({"message": "Hello from Flask!", "env": os.environ.get("APP_ENV", "dev")})

@app.route("/health")
def health():
    return jsonify({"status": "ok"})
EOF

# Dockerfile with correct layer order
cat > Dockerfile << 'EOF'
FROM python:3.12-slim

RUN groupadd -g 1001 appgroup && useradd -u 1001 -g appgroup -M appuser

WORKDIR /app

# Dependencies first (changes rarely)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code (changes often)
COPY --chown=appuser:appgroup . .

USER appuser
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
EOF
```

```bash
# First build — installs packages
docker build -t flask-app:v1 .

# Change app code, not requirements
echo "# new comment" >> app.py

# Second build — pip install should be cached
time docker build -t flask-app:v2 .
# Note: requirements step is CACHED, only COPY is rebuilt
```

---

## Part 4 — Multi-stage builds

Build a Go binary with a minimal final image:

```bash
mkdir -p ~/docker-lab/go-app
cd ~/docker-lab/go-app

cat > main.go << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "os"
    "runtime"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{
        "go_version": runtime.Version(),
        "os":         runtime.GOOS,
        "arch":       runtime.GOARCH,
    })
}

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    http.HandleFunc("/health", healthHandler)
    http.HandleFunc("/info", infoHandler)
    fmt.Printf("Listening on :%s\n", port)
    http.ListenAndServe(":"+port, nil)
}
EOF

cat > go.mod << 'EOF'
module github.com/jumptptech/go-app

go 1.22
EOF
```

```bash
cat > Dockerfile << 'EOF'
# Stage 1: build
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod .
# RUN go mod download   # uncomment when you have dependencies
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server .

# Stage 2: minimal runtime
FROM scratch
COPY --from=builder /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
EOF

docker build -t go-app:v1 .
docker images go-app
```

The final image is tiny — just the compiled binary, nothing else.

---

## Part 5 — Push to Docker Hub

### 5.1 Create a Docker Hub account

If you do not have one, create a free account at hub.docker.com.

### 5.2 Tag and push

```bash
# Log in
docker login

# Tag the flask app with your Docker Hub username
docker tag flask-app:v1 YOUR_USERNAME/flask-app:v1
docker tag flask-app:v1 YOUR_USERNAME/flask-app:latest

# Push both tags
docker push YOUR_USERNAME/flask-app:v1
docker push YOUR_USERNAME/flask-app:latest

# Verify
docker search YOUR_USERNAME
```

### 5.3 Pull and run

```bash
# Remove the local image
docker image rm YOUR_USERNAME/flask-app:v1

# Pull from Docker Hub
docker pull YOUR_USERNAME/flask-app:v1

# Run it
docker run -d -p 5000:5000 \
    -e APP_ENV=production \
    --name flask-demo \
    YOUR_USERNAME/flask-app:v1

# Test it
curl http://localhost:5000/
curl http://localhost:5000/health

# Cleanup
docker stop flask-demo && docker rm flask-demo
```

---

## Checkpoint

Verify your work:

```bash
# You should have several images
docker images | grep -E "(myapp|flask-app|go-app)"

# What was the size difference between v1 and v2 of myapp?
# (check your notes from Part 2)

# Can you explain why the go-app image is so small?
```

Run a quick security scan if you have `trivy` installed:

```bash
# Install trivy: https://aquasecurity.github.io/trivy/
trivy image flask-app:v1
```
