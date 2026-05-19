# Module 04 · Docker

Containers changed how software is deployed. Before containers, you shipped code and hoped the production environment matched your development environment. With containers, you ship the environment along with the code.

Docker is the tool that made containers accessible. Understanding Docker — not just `docker run`, but images, layers, the build process, networking, and Compose — is essential for every module that follows.

## What you will cover

**Lecture 1 — Containers & Images**
What containers actually are, how images work with layers, the Docker daemon, pulling images, running and managing containers.

**Lecture 2 — Writing Dockerfiles**
The instructions that build images, layer caching, multi-stage builds, and security hardening practices.

**Lecture 3 — Docker Compose**
Defining and running multi-container applications, networking between services, volumes, and environment configuration.

**Lab 1 — Images & Registries**
Pull images, inspect their layers, build your own, push to Docker Hub.

**Lab 2 — Multi-service App with Compose**
Build and run a realistic web application with a frontend, API, and database using Docker Compose.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 45 min |
| Lecture 2 | 60 min |
| Lecture 3 | 45 min |
| Lab 1 | 75 min |
| Lab 2 | 90 min |

## Setup

```bash
# Install Docker Engine
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER  # add yourself to the docker group
newgrp docker                   # reload group membership

# Verify
docker version
docker run hello-world
```
