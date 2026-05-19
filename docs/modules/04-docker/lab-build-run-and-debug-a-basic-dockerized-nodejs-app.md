---
title: "Lab: Build, Run, and Debug a Basic Dockerized Node.js App"
description: "0) Prerequisites    Docker Desktop installed and running (whale icon in menu bar) Terminal..."
published: 2026-03-03
source: "https://dev.to/jumptotech/lab-build-run-and-debug-a-basic-dockerized-nodejs-app-1d60"
tags: []
---

# Lab: Build, Run, and Debug a Basic Dockerized Node.js App

## 



# 0) Prerequisites

* Docker Desktop installed and running (whale icon in menu bar)
* Terminal access on Mac

Verify Docker:

```bash
docker --version
```

---

# 1) Create Project Folder

```bash
mkdir docker-basic
cd docker-basic
```

---

# 2) Create Node App

Create `app.js`:

```bash
nano app.js
```

Paste **exactly**:

```js
const http = require("http");

const server = http.createServer((req, res) => {
  res.write("Hello DevOps from Docker!");
  res.end();
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

Save:

* Ctrl + O, Enter
* Ctrl + X

---

# 3) Create `package.json`

```bash
npm init -y
```

Confirm it exists:

```bash
ls -la
```

You should see:

* `app.js`
* `package.json`

---

# 4) Create Dockerfile

Create file named **Dockerfile** (no extension):

```bash
nano Dockerfile
```

Paste:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

Save:

* Ctrl + O, Enter
* Ctrl + X

---

# 5) Validate Files (Important)

Make sure Dockerfile content is NOT inside `app.js`.

```bash
echo "---- app.js ----"
cat app.js

echo "---- Dockerfile ----"
cat Dockerfile
```

---

# 6) Build the Docker Image

```bash
docker build -t my-node-app:latest .
```

Verify image:

```bash
docker images | head
```

You should see `my-node-app:latest`.

---

# 7) Run the Container (with Port Mapping)

```bash
docker rm -f my-node-container 2>/dev/null
docker run -d -p 3000:3000 --name my-node-container my-node-app:latest
```

Verify it’s running:

```bash
docker ps
```

You must see:

* NAME: `my-node-container`
* PORTS: `0.0.0.0:3000->3000/tcp`

---

# 8) Test in Browser

Open:

`http://localhost:3000`

Expected output:

`Hello DevOps from Docker!`

Also test via terminal:

```bash
curl http://localhost:3000
```

---

# 9) Debugging Lab (Real DevOps Troubleshooting)

## 9.1 If `localhost:3000` shows nothing

### Step A: Is container running?

```bash
docker ps
```

If empty → container exited.

### Step B: Show stopped containers

```bash
docker ps -a
```

Look for status like:

* `Exited (1)`

### Step C: Read logs (most important)

```bash
docker logs my-node-container
```

Common errors:

* `SyntaxError: missing ) after argument list`
* `Unexpected identifier` (often means Dockerfile text was pasted into app.js)
* `Cannot find module` or `app.js not found`

---

## 9.2 Fix Common Student Mistakes

### Mistake 1: Running wrong tag (example `:prod`)

If you built `:latest` but run `:prod`:

```bash
docker run my-node-app:prod
```

You’ll get: “Unable to find image…”

Fix: run `:latest`:

```bash
docker run -d -p 3000:3000 --name my-node-container my-node-app:latest
```

Or create prod tag:

```bash
docker tag my-node-app:latest my-node-app:prod
```

---

### Mistake 2: Container exits immediately

Cause: JavaScript error in `app.js`.

Fix: check logs:

```bash
docker logs my-node-container
```

Fix `app.js`, then rebuild and rerun:

```bash
docker rm -f my-node-container
docker build -t my-node-app:latest .
docker run -d -p 3000:3000 --name my-node-container my-node-app:latest
```

---

### Mistake 3: Port 3000 already in use

Check:

```bash
lsof -iTCP:3000 -sTCP:LISTEN
```

Run on another port:

```bash
docker rm -f my-node-container
docker run -d -p 3001:3000 --name my-node-container my-node-app:latest
```

Open:

`http://localhost:3001`

---

# 10) Use `docker exec` (Inspect Inside Container)

Enter container shell:

```bash
docker exec -it my-node-container sh
```

Check files:

```bash
ls -la
pwd
cat app.js
```

Exit:

```bash
exit
```

---

# 11) Cleanup (Stop and Remove Everything)

Stop & remove container:

```bash
docker rm -f my-node-container
```

Remove image:

```bash
docker rmi my-node-app:latest
```


