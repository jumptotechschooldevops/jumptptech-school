---
title: "Docker"
description: "1. What is Docker? (Very Simple)   Before Docker: Application depends on OS, packages,..."
published: 2025-11-11
source: "https://dev.to/jumptotech/docker-225l"
devto_id: 3014303
---

# Docker




# **1. What is Docker? (Very Simple)**

Before Docker:
Application depends on OS, packages, libraries → “it works on my machine” problem.

Docker solves it by packaging:

```
App Code + Dependencies + Runtime = IMAGE
```

Then you run **containers** from that image.

| Term           | Meaning                        | Analogy     |
| -------------- | ------------------------------ | ----------- |
| **Image**      | Read-only blueprint            | Template    |
| **Container**  | Running instance of that image | Real object |
| **Dockerfile** | Instructions to build an image | Recipe      |

---

# **2. Docker Architecture**

```
+--------------------+
|    Docker Client   |  -> docker commands
+--------------------+
          |
+--------------------+
|   Docker Engine    |  (daemon)
+--------------------+
          |
+--------------------+
| Images | Containers |
+--------------------+
```

---

# **3. Basic Docker Commands**

### Check Docker version:

```bash
docker --version
```

### See running containers:

```bash
docker ps
```

### See all containers (including stopped):

```bash
docker ps -a
```

### See images stored locally:

```bash
docker images
```

---

# **4. Run Your First Container**

```bash
docker run -it ubuntu bash
```

Means:

* `-it` → interactive terminal
* `ubuntu` → official image
* `bash` → open shell

Exit:

```bash
exit
```

---

# **5. Run a Web App (Nginx)**

```bash
docker run -d -p 8080:80 nginx
```

* `-d` → run in background
* `-p 8080:80` → expose port

Open browser:

```
http://localhost:8080
```

---

# **6. Stop & Remove Containers**

Stop:

```bash
docker stop <container_id>
```

Remove:

```bash
docker rm <container_id>
```

Remove unused:

```bash
docker system prune -a -f
```

---

# **7. Create Your Own Docker Image**

### Step 1: Create `app.py`

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Docker!"

app.run(host="0.0.0.0", port=5000)
```

### Step 2: Create `requirements.txt`

```
flask
```

### Step 3: Create `Dockerfile`

```Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

### Step 4: Build the image

```bash
docker build -t myflaskapp .
```

### Step 5: Run container

```bash
docker run -p 5000:5000 myflaskapp
```

Open:

```
http://localhost:5000
```

✅ **You just built your own containerized application**

---

# **8. Docker Volumes (Persistent Data)**

Without volumes, container data disappears when container stops.

### Create a named volume:

```bash
docker volume create data1
```

### Run container with persistent storage:

```bash
docker run -d -p 3307:3306 -e MYSQL_ROOT_PASSWORD=pass -v data1:/var/lib/mysql mysql
```

Now database data is **permanent**.

---

# **9. Docker Networks (Connect Multiple Containers)**

```bash
docker network create mynet
```

Backend:

```bash
docker run -d --network=mynet --name=db postgres
```

Frontend:

```bash
docker run -d --network=mynet --name=web nginx
```

They can now talk to each other using **container name**.

---

# **10. Docker Compose (Run Multi-Container App)**

Create `docker-compose.yml`:

```yaml
version: "3.8"
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  redis:
    image: redis
```

Run:

```bash
docker compose up -d
docker compose ps
docker compose down
```

---

# **11. Production Best Practices (Very Important for Interview)**

| Best Practice                                | Reason                          |
| -------------------------------------------- | ------------------------------- |
| Use **small base images** (`alpine`, `slim`) | Reduces size, improves security |
| Do not run as **root**                       | Security                        |
| Set resource limits in Kubernetes / Compose  | Stability                       |
| Use `.dockerignore`                          | Prevent unnecessary files       |
| Use multi-stage builds                       | Reduce final image size         |

---

# **12. Real DevOps Interview Answer**

> “Docker allows us to package applications with dependencies into container images that run consistently across environments. We write Dockerfiles to build images and run containers using Docker Engine. Using volumes ensures persistent storage, and custom networks allow multi-service communication. In production we use Docker with Kubernetes, OPA Gatekeeper for policy enforcement, and CI/CD pipelines for image delivery.”


