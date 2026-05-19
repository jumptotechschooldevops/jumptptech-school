# Lecture 2 · Writing Dockerfiles

## What a Dockerfile is

A Dockerfile is a text file containing instructions for building a Docker image. Each instruction creates a layer. Docker builds images by executing instructions top to bottom, caching layers that have not changed.

The most important thing to understand is **layer caching** and how to optimise for it. This determines both build times and image sizes.

---

## Dockerfile instructions

### FROM

Every Dockerfile starts with `FROM`. It sets the base image.

```dockerfile
FROM python:3.12-slim
FROM node:20-alpine
FROM ubuntu:22.04
FROM scratch        # empty base — for statically compiled binaries
```

Choose base images deliberately:

| Tag | Size | Use when |
|-----|------|----------|
| `python:3.12` | ~900MB | You need the full Python toolchain |
| `python:3.12-slim` | ~120MB | Most production Python apps |
| `python:3.12-alpine` | ~55MB | Minimal size, but Alpine libc differs from glibc |
| `python:3.12-bookworm` | ~1.4GB | Maximum compatibility |

The smaller the image, the smaller the attack surface and the faster it pulls.

### WORKDIR

Sets the working directory for subsequent instructions. Creates it if it does not exist.

```dockerfile
WORKDIR /app
```

Always use `WORKDIR` instead of `RUN cd /app`. Without it, instructions run from `/` which is confusing and error-prone.

### COPY and ADD

```dockerfile
# Copy specific files
COPY requirements.txt .
COPY src/ ./src/

# Copy with a different destination name
COPY config/production.yml ./config/app.yml

# ADD additionally supports URLs and tar extraction — avoid unless needed
ADD https://example.com/file.tar.gz /tmp/   # pulls a URL
ADD archive.tar.gz /app/                     # extracts automatically
```

Prefer `COPY` over `ADD` for clarity. `ADD` has surprising behaviour.

### RUN

Executes a command during the build:

```dockerfile
# Shell form (runs in /bin/sh -c)
RUN apt-get update && apt-get install -y curl

# Exec form (no shell, faster, safer)
RUN ["pip", "install", "-r", "requirements.txt"]
```

**Always combine related `apt-get` commands** into a single `RUN` instruction:

```dockerfile
# BAD — three layers, and apt cache is kept
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git

# GOOD — one layer, cache cleaned up
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       git \
    && rm -rf /var/lib/apt/lists/*
```

`--no-install-recommends` avoids pulling in optional packages. `rm -rf /var/lib/apt/lists/*` removes the package lists after installation, shrinking the image by 50–100MB.

### ENV

Sets environment variables available at build time and runtime:

```dockerfile
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1
```

### ARG

Like `ENV` but only available during the build, not at runtime:

```dockerfile
ARG APP_VERSION=1.0.0
RUN echo "Building version $APP_VERSION"
```

Pass at build time: `docker build --build-arg APP_VERSION=2.0.0 .`

### EXPOSE

Documents which port the container listens on. Does NOT actually open the port:

```dockerfile
EXPOSE 8000
```

You still need `-p 8000:8000` when running the container. `EXPOSE` is documentation.

### USER

Run as a non-root user:

```dockerfile
RUN useradd --no-create-home --system --uid 1001 appuser
USER appuser
```

Running as root inside a container is a significant security risk. If someone exploits your app, they get root inside the container — and container escapes happen.

### CMD and ENTRYPOINT

These define what runs when the container starts:

```dockerfile
# CMD — can be overridden by 'docker run ... <command>'
CMD ["python3", "-m", "uvicorn", "app:app", "--host", "0.0.0.0"]

# ENTRYPOINT — the command that always runs; CMD becomes default arguments
ENTRYPOINT ["python3", "-m", "uvicorn"]
CMD ["app:app", "--host", "0.0.0.0", "--port", "8000"]
```

Use exec form (JSON array) for both — it avoids a shell wrapper, which means signals go directly to your process.

---

## Layer caching

Docker caches each layer. When you rebuild, it only re-executes instructions where something has changed. Everything after the changed instruction is also re-executed.

This means instruction order matters enormously:

```dockerfile
# BAD — any code change invalidates the pip install layer
FROM python:3.12-slim
WORKDIR /app
COPY . .                            # all source code
RUN pip install -r requirements.txt # runs every time

# GOOD — dependencies only reinstall when requirements.txt changes
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .              # just requirements first
RUN pip install -r requirements.txt  # cached unless requirements change
COPY . .                             # source code copied last
```

The rule: copy files that change infrequently before files that change frequently. For most apps:

1. System packages
2. Language dependencies (requirements.txt, package.json, go.mod)
3. Application code

---

## Multi-stage builds

Multi-stage builds solve the problem of build dependencies polluting production images:

```dockerfile
# Stage 1: build the application
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build     # produces /app/dist

# Stage 2: run the application (much smaller image)
FROM nginx:1.25-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

The final image contains only nginx and your built files. Node.js, npm, and all the build tools are left behind in the builder stage.

For a compiled Go application:

```dockerfile
# Stage 1: compile
FROM golang:1.22 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# Stage 2: minimal runtime
FROM scratch
COPY --from=builder /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

The final image is just your binary and nothing else.

---

## .dockerignore

Like `.gitignore`, `.dockerignore` tells Docker which files to exclude from the build context. Without it, `docker build` sends everything in the directory to the daemon:

```dockerignore
.git
.github
*.md
.env
.env.*
node_modules
__pycache__
*.pyc
.venv
dist
build
*.test
*.spec.ts
Dockerfile*
docker-compose*.yml
```

A `.dockerignore` file is not optional — a project without one sends hundreds of MB of unnecessary data and can accidentally include secrets.

---

## A complete example

A production-ready Python FastAPI application:

```dockerfile
FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

FROM base AS deps
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

FROM base AS final

# Create non-root user
RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --no-create-home appuser

# Copy installed packages from deps stage
COPY --from=deps /install /usr/local

# Copy application code
COPY --chown=appuser:appgroup src/ ./src/

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["python3", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

The `HEALTHCHECK` instruction tells Docker (and container orchestrators) how to verify the container is healthy. A container that passes the health check is considered ready to receive traffic.

---

## Summary

- Instructions in a Dockerfile create image layers. Layers are cached — order matters.
- Copy `requirements.txt` before copying source code to cache dependency installation.
- Use multi-stage builds to keep production images small and clean.
- Always set `USER` to a non-root user before `CMD`.
- Always use a `.dockerignore` file to avoid sending secrets and unnecessary files.
- Use exec form (`["cmd", "arg"]`) for `ENTRYPOINT` and `CMD` so signals work correctly.
