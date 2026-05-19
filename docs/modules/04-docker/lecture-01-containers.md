# Lecture 1 · Containers & Images

## What a container is

A container is not a virtual machine. A VM virtualises hardware — it has its own kernel, its own memory management, its own device drivers. Starting a VM means booting an OS, which takes seconds to minutes.

A container shares the host kernel. It is a process (or group of processes) running on the host, isolated from other processes using two Linux kernel features:

- **Namespaces** — give each container its own view of the system: its own process tree, network interfaces, filesystem mount points, user IDs, and hostname.
- **cgroups** (control groups) — limit and account for CPU, memory, disk I/O, and network usage.

A container starts in milliseconds because there is no OS to boot. It uses much less memory because it does not have a separate kernel.

### What isolation means in practice

Inside a container:
- `ps aux` shows only the processes in the container, not the host's processes
- `ip addr` shows only the container's network interfaces
- The filesystem appears to start at `/`, but it is actually a different set of files than the host
- `whoami` might say `root`, but this is a non-privileged root by default

Outside on the host:
- The container's process is visible with `ps` (just with a different PID)
- You can see the container's network traffic
- You can access its files through `/proc/<pid>/root`

---

## Docker architecture

```
┌────────────────────────────────────────┐
│ Docker CLI (docker)                    │
│  docker run, docker build, docker ps   │
└──────────────────┬─────────────────────┘
                   │ REST API (Unix socket)
┌──────────────────▼─────────────────────┐
│ Docker Daemon (dockerd)                │
│  Manages images, containers, networks  │
└──────────────────┬─────────────────────┘
                   │
┌──────────────────▼─────────────────────┐
│ containerd                             │
│  Low-level container runtime           │
└──────────────────┬─────────────────────┘
                   │
┌──────────────────▼─────────────────────┐
│ runc                                   │
│  Creates containers using cgroups      │
│  and namespaces                        │
└────────────────────────────────────────┘
```

When you run `docker run nginx`, the CLI sends a request to the Docker daemon over a Unix socket at `/var/run/docker.sock`. The daemon pulls the image if needed, calls containerd, which calls runc, which creates the container.

---

## Images and layers

A Docker image is a read-only template. Every image is made of **layers** stacked on top of each other. Each instruction in a Dockerfile creates a new layer.

```
nginx image (stacked layers):
┌──────────────────────────────────┐
│ Layer 4: nginx config            │
├──────────────────────────────────┤
│ Layer 3: nginx binary            │
├──────────────────────────────────┤
│ Layer 2: libc, openssl           │
├──────────────────────────────────┤
│ Layer 1: Debian base OS          │
└──────────────────────────────────┘
```

Each layer is content-addressed by its SHA256 hash. If two images share a layer, Docker stores it only once. This is why pulling a second image that shares layers with an existing one is fast — only the new layers are downloaded.

When a container runs, Docker adds a **read-write layer** on top of the image layers. All changes made inside the container (files created, logs written, config modified) go into this writable layer. The image itself is never modified. When the container is stopped and removed, this writable layer is discarded.

This is why you should not store persistent data inside containers — it disappears when the container is removed.

---

## Working with images

```bash
# Pull an image
docker pull nginx:1.25
docker pull python:3.12-slim

# List local images
docker images
docker image ls

# Inspect an image
docker image inspect nginx:1.25

# See the layers
docker image history nginx:1.25

# Remove an image
docker image rm nginx:1.25

# Remove all unused images
docker image prune

# Search Docker Hub
docker search python
```

Image names follow the format: `[registry/][namespace/]name[:tag]`

- `nginx` → `docker.io/library/nginx:latest`
- `python:3.12-slim` → `docker.io/library/python:3.12-slim`
- `ghcr.io/org/app:v1.2.3` → GitHub Container Registry

**Never use `:latest` in production.** `latest` is just a tag like any other — it can change without warning. Pin to a specific version so you control when you update.

---

## Running containers

```bash
# Run a container (pulls image if not local)
docker run nginx

# Run in the background (detached)
docker run -d nginx

# Run with a name
docker run -d --name webserver nginx

# Map host port to container port
docker run -d -p 8080:80 nginx
# Now http://localhost:8080 hits nginx inside the container

# Pass environment variables
docker run -d \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypass \
  -e POSTGRES_DB=mydb \
  postgres:16

# Mount a volume
docker run -d \
  -v /host/path:/container/path \
  nginx

# Mount a volume (named volume — Docker manages it)
docker run -d \
  -v mydata:/var/lib/postgresql/data \
  postgres:16

# Run interactively (shell in container)
docker run -it ubuntu:22.04 bash
docker run -it --rm python:3.12 python3
# --rm removes the container when you exit

# Set resource limits
docker run -d \
  --memory="512m" \
  --cpus="0.5" \
  nginx
```

### The lifecycle of a container

```
pulled image → created → running → stopped → removed
                                            ↑ or paused
```

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container (sends SIGTERM, waits, then SIGKILL)
docker stop webserver

# Start a stopped container
docker start webserver

# Restart
docker restart webserver

# Remove a container
docker rm webserver

# Remove a running container (force)
docker rm -f webserver

# Remove all stopped containers
docker container prune
```

---

## Interacting with running containers

```bash
# Execute a command in a running container
docker exec webserver ls /etc/nginx

# Get a shell in a running container
docker exec -it webserver bash

# View container logs
docker logs webserver
docker logs -f webserver    # follow (like tail -f)
docker logs --tail 100 webserver

# Inspect container details
docker inspect webserver

# Get specific fields from inspect
docker inspect webserver --format '{{.State.Status}}'
docker inspect webserver --format '{{.NetworkSettings.IPAddress}}'

# Copy files between host and container
docker cp webserver:/etc/nginx/nginx.conf ./nginx.conf
docker cp ./custom.conf webserver:/etc/nginx/conf.d/

# See resource usage
docker stats
docker stats webserver
```

---

## Networking

Docker creates a default bridge network. Containers on the same bridge network can communicate using their IP addresses. Named networks allow communication by container name:

```bash
# Create a custom network
docker network create myapp

# Run containers on the network
docker run -d --name db --network myapp postgres:16
docker run -d --name app --network myapp -e DB_HOST=db myapp-image

# The 'app' container can reach 'db' by hostname 'db'
# because Docker handles DNS for named networks

# List networks
docker network ls

# Inspect a network
docker network inspect myapp

# Connect an existing container to a network
docker network connect myapp webserver
```

---

## Summary

- A container is an isolated process using Linux namespaces and cgroups — not a VM.
- An image is layers of read-only files. Containers add a writable layer at runtime.
- Never store persistent data inside a container — use volumes.
- Never use `:latest` in production — pin to a specific image version.
- Named Docker networks let containers communicate by hostname.
