---
title: "Docker"
description: "*Why Do We Need Docker? *   In one of my previous projects, we had to set up a complete..."
published: 2025-11-10
source: "https://dev.to/jumptotech/docker-mg4"
tags: []
---

# Docker


## **Why Do We Need Docker? **

In one of my previous projects, we had to set up a complete application that used:

* **NodeJS** as the web server
* **MongoDB** as the database
* **Redis** as the caching/messaging system

Each part of the application needed different software, dependencies, versions, and configurations. This caused many problems:

### **Problems We Faced**

1. **OS Compatibility Issues**
   Some versions of MongoDB worked on certain operating systems, while Redis or NodeJS needed something else.

2. **Dependency Conflicts**
   One service needed one version of a library, and another service needed a different version. They could not run together easily.

3. **Frequent Upgrades & Changes**
   When we changed one service, we had to carefully check that everything still worked together. This took a lot of time.

4. **Developer Onboarding Was Hard**
   A new developer had to:

   * Install the correct OS
   * Install the exact software versions
   * Follow long setup instructions
     If anything was different → the application would break.

5. **Different Environments**
   Someone on Ubuntu, someone on Mac, someone on Windows — the app worked differently in every machine.
   So we could not guarantee the application would behave the same everywhere.

This whole problem is known as:

### **The “Matrix from Hell”**

Managing compatibility between:

* OS
* Libraries
* Versions
* Tools
* Dependencies

And doing it again every time something changes.

---

## **How Docker Solved This**

With Docker:

* Each service runs inside its **own container**
* Each container has **its own libraries and dependencies**
* But all containers **share the same OS kernel**

So:

* No conflicts
* No OS version problems
* No manual setup
* Just one command to start everything:

```
docker run ...
```

A developer only needs **Docker installed**, nothing else.

---

## **What Is a Container?**

A container is:

* An **isolated environment**
* Runs its own processes
* Has its own libraries and settings
* But it **shares the host OS kernel**

### **Important Point**

Containers are **not virtual machines**.

---

## **Operating System Basics (For Understanding Docker)**

Every OS has two main parts:

| Part                    | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| **Kernel**              | Talks to the hardware (same across Linux distros) |
| **User Space Software** | UI, drivers, tools, libraries (this differs)      |

Ubuntu, Fedora, CentOS → **all share the Linux kernel**, but their user software differs.

### **What Docker Shares**

Docker containers **share the kernel** of the host machine.

So:

* If host OS = Linux → containers must also be Linux-based.
* You **cannot** run Windows containers on Linux directly.

When you run Linux containers on Windows:

* Windows actually runs a **hidden Linux VM** under the hood.

---

## **Containers vs Virtual Machines**

| Feature        | Virtual Machine | Docker Container |
| -------------- | --------------- | ---------------- |
| OS             | Full OS per VM  | Shares host OS   |
| Size           | GBs             | MBs              |
| Startup Time   | Minutes         | Seconds          |
| Isolation      | Very strong     | Medium           |
| Resource Usage | Heavy           | Light            |

**Important:**
It is **not** VMs vs Containers.
We **use both together** in real companies.

Example:

* One big VM may run **hundreds** of containers.

---

## **Images vs Containers**

| Term          | Meaning                                 |
| ------------- | --------------------------------------- |
| **Image**     | A package/template (like a VM template) |
| **Container** | A running instance based on an image    |

We can start multiple containers from one image.

---

## **Docker in DevOps**

Earlier:

* Developers wrote code
* Ops had to set it up manually → many errors

Now:

* Dev + Ops create a **Dockerfile** together
* Dockerfile → builds the **image**
* The same image works everywhere (dev, test, prod)

This makes software:

* **Portable**
* **Consistent**
* **Easy to ship**
* **Easy to scale**

---

## **Conclusion**

Docker solves:

* Compatibility problems
* Dependency conflicts
* Slow onboarding
* “Works on my machine” issues

It allows you to:

* Package your app **once**
* Run it **anywhere**








Docker comes in **two editions**:

| Edition                            | Description                                                                                                                    | Cost                |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------- |
| **Docker Community Edition (CE)**  | Free and open-source. Used for learning, personal projects, and most development work.                                         | **Free**            |
| **Docker Enterprise Edition (EE)** | Includes **official support**, **security features**, **image and policy management**, and **enterprise orchestration tools**. | **Paid / Licensed** |

For learning and real DevOps practice, **Docker Community Edition (CE)** is more than enough.

---

## **Where You Can Install Docker**

Docker CE can be installed on:

* **Linux** (Ubuntu, CentOS, Debian, etc.)
* **Mac** (using Docker Desktop)
* **Windows** (using Docker Desktop)
* **Cloud platforms** (AWS, Azure, GCP virtual machines)

---

## **Installation Options**

### **If You Are on Linux**

You can directly install Docker CE using package manager:

```
apt   (Ubuntu / Debian)
yum  (RHEL / CentOS / Amazon Linux)
```

This is what we will do in the demo.

---

### **If You Are on Mac or Windows**

You have **two choices**:

#### **Option 1 (Recommended for Learning):**

Install a **Linux Virtual Machine (VM)** using:

* VirtualBox
* VMware
* Hyper-V
* Parallels (Mac)

Then install Docker **inside the Linux VM**.
This gives you the same environment as a real production server.

#### **Option 2 (Faster Setup):**

Install **Docker Desktop** (native application):

| OS      | Download                                                                                         |
| ------- | ------------------------------------------------------------------------------------------------ |
| Mac     | [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) |
| Windows | [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) |

Docker Desktop creates a lightweight Linux environment internally so that containers can run.

---

## **Before We Continue**

If your machine is:

| OS                 | What To Do                                                               |
| ------------------ | ------------------------------------------------------------------------ |
| **Linux**          | Continue with the upcoming demo.                                         |
| **Mac or Windows** | Install Docker Desktop or create a Linux VM. Then come back to the demo. |








## **Demo: Installing and Getting Started with Docker on Linux (Ubuntu)**

### **Step 1: Choose a Supported System**

First, make sure you are working on a machine that supports Docker:

* Physical machine, laptop, or virtual machine.
* Running a **64-bit Linux OS** (in this demo, we use **Ubuntu**).

You can check your Ubuntu version with:

```bash
cat /etc/os-release
```

---

### **Step 2: Go to Docker Documentation**

Open your browser and go to:

```
https://docs.docker.com
```

Click **Get Docker**, which leads to the **Docker Engine Community Edition** installation page.

From the left menu:

1. Select **Linux**
2. Select **Ubuntu**

---

### **Step 3: Uninstall Any Older Docker Versions**

Before installation, ensure no old Docker packages exist:

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

If nothing is present, it will simply return with no changes.

---

### **Step 4: Install Docker (Using the Convenience Script)**

There are two ways to install Docker:

* **Manual repository setup**
* **Automated script (easier)**

We will use the automated method.

Run:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```

Then execute the script:

```bash
sudo sh get-docker.sh
```

This will:

* Add Docker repository
* Install Docker Engine
* Configure dependencies
* Start Docker service

Wait a few minutes for installation to complete.

---

### **Step 5: Verify Installation**

Check the installed Docker version:

```bash
docker --version
```

Example output:

```
Docker version 19.03.1, build abcdef01
```

---

### **Step 6: Run Your First Container**

Go to Docker Hub:

```
https://hub.docker.com
```

Search for **whalesay** (a fun test image).

Or simply run:

```bash
sudo docker run docker/whalesay cowsay "Hello World"
```

Docker will:

1. Pull the `docker/whalesay` image from Docker Hub (if not already present)
2. Create a container
3. Run it, printing a whale saying “Hello World”

Output example:

```
_______________
< Hello World >
---------------
       \     
        \
         <°)))><
```

Congratulations — Docker is working successfully.







https://docs.docker.com/install/linux/docker-ce/ubuntu/










## **Basic Docker Commands — Explanation**

### **1. Run a Container**

```
docker run <image-name>
```

Example:

```
docker run nginx
```

* If the image is **not on your system**, Docker will **download** it from **Docker Hub**.
* If the image **already exists**, it will just start the container.

---

### **2. List Containers**

| Command        | Meaning                                                    |
| -------------- | ---------------------------------------------------------- |
| `docker ps`    | Show **only running** containers                           |
| `docker ps -a` | Show **all containers**, including **stopped/exited** ones |

Each container has:

* A **Container ID**
* An **Image** name
* A **Status**
* A **Random auto-generated name** (e.g., `silly_sammet`)

---

### **3. Stop a Running Container**

```
docker stop <container-id or container-name>
```

Example:

```
docker stop silly_sammet
```

After stopping, the container will show in:

```
docker ps -a
```

with status **Exited**.

---

### **4. Remove a Stopped Container**

```
docker rm <container-id or name>
```

This **deletes** the container completely.

Verify:

```
docker ps -a
```

---

### **5. List Images**

```
docker images
```

Shows:

* Image name
* Tag
* Size

Example images:

```
nginx
redis
ubuntu
alpine
```

---

### **6. Remove an Image**

```
docker rmi <image-name>
```

**Important:**
You can **only delete an image** if **no container is using it**.
Stop and remove containers first.

---

### **7. Pull an Image (Download Only, Do Not Run)**

```
docker pull ubuntu
```

This **downloads** the image, but does **not create a container**.

---

## **Why Some Containers Exit Immediately**

Example:

```
docker run ubuntu
```

This container exits right away. Why?

* Containers run **a single process**.
* Ubuntu image has **no application running**, so it **stops immediately**.

To keep it running, run a command:

```
docker run ubuntu sleep 5
```

This runs `sleep 5` inside the container → it runs for **5 seconds**, then exits.

---

### **8. Execute a Command in a Running Container**

```
docker exec <container-name> <command>
```

Example:

```
docker exec sleepy_container cat /etc/hosts
```

This lets you **run commands inside** an existing running container.

---

## **9. Run Containers in Foreground vs Background**

### **Foreground (Attached Mode)** — default

```
docker run kodekloud/simple-webapp
```

You **see the output** and your terminal is **busy** until the container stops.

Press:

```
CTRL + C
```

→ Stops the container.

### **Background (Detached Mode)** — recommended for services

```
docker run -d kodekloud/simple-webapp
```

* Container runs **in the background**.
* You get your terminal back.

Check running containers:

```
docker ps
```

Attach back to it:

```
docker attach <container-id>
```

You only need the **first few characters** of the container ID.

---

## **Summary Table**

| Action                       | Command Example                     |
| ---------------------------- | ----------------------------------- |
| Run a container              | `docker run nginx`                  |
| Run container in background  | `docker run -d nginx`               |
| List containers              | `docker ps`                         |
| List all containers          | `docker ps -a`                      |
| Stop container               | `docker stop <name>`                |
| Remove container             | `docker rm <name>`                  |
| List images                  | `docker images`                     |
| Remove image                 | `docker rmi <image>`                |
| Pull image only              | `docker pull ubuntu`                |
| Run command inside container | `docker exec <name> cat /etc/hosts` |











### **1. Running Containers**

We use:

```
docker run <image-name>
```

Example: Run a **CentOS** container:

```
docker run centos
```

* If the image is **not available locally**, Docker will **download it from Docker Hub**.
* If the image **is already downloaded**, it will be used directly.

### **Docker Hub**

Official images can be pulled simply by using their name:

```
docker run ubuntu
docker run nginx
```

For **your own images** stored under your account:

```
docker run <username>/<image-name>
```

Example:

```
docker run mmsumshad/ansible-playable
```

---

### **2. Why CentOS Exited Immediately?**

Containers **only live while a process is running** inside them.
CentOS has **no default process**, so it exits right away.

To keep it alive, run a command such as `bash` and attach to the container:

```
docker run -it centos bash
```

* `-i` = interactive
* `-t` = allocate a terminal

You are now **inside the container**.

Check OS version:

```
cat /etc/*release*
```

Exit the container:

```
exit
```

---

### **3. Running Containers in Background**

Run a container and keep it alive with `sleep`, in **detached** mode:

```
docker run -d centos sleep 20
```

* This starts the container
* Runs `sleep 20`
* Container stays alive for 20 seconds, then exits

---

### **4. Listing Containers**

| Command        | Description                                 |
| -------------- | ------------------------------------------- |
| `docker ps`    | Shows **only running** containers           |
| `docker ps -a` | Shows **all** containers (running + exited) |

Example:

```
docker ps
docker ps -a
```

---

### **5. Stopping a Running Container**

```
docker stop <container-id or name>
```

Example:

```
docker stop serene_pasteur
```

---

### **6. Removing Containers**

Remove **stopped** containers:

```
docker rm <container-id or name>
```

You can remove **multiple containers** at once:

```
docker rm 345 e0a 773
```

---

### **7. Listing Images**

```
docker images
```

This shows:

* Image name
* Tag
* Size

Example output might include:

```
ubuntu
centos
busybox
hello-world
```

---

### **8. Removing Images**

```
docker rmi <image-name>
```

**Important:** You must **remove containers first** before deleting their image.

Example:

```
docker rm <container>
docker rmi centos
```

---

### **9. Pull an Image (Download Only)**

```
docker pull ubuntu
```

This **downloads the image**, but does **not** run a container.

---

### **10. Execute Commands in a Running Container**

```
docker exec <container-id> <command>
```

Example: View OS release file:

```
docker exec <container-id> cat /etc/*release*
```

This runs the command **inside the running container**.

---

## **Summary of Commands**

| Action                       | Command                          |
| ---------------------------- | -------------------------------- |
| Run a container              | `docker run ubuntu`              |
| Run container in background  | `docker run -d ubuntu sleep 100` |
| Attach shell                 | `docker run -it ubuntu bash`     |
| List running containers      | `docker ps`                      |
| List all containers          | `docker ps -a`                   |
| Stop container               | `docker stop <id>`               |
| Remove container             | `docker rm <id>`                 |
| List images                  | `docker images`                  |
| Remove image                 | `docker rmi <image>`             |
| Pull image only              | `docker pull ubuntu`             |
| Run command inside container | `docker exec <id> <command>`     |








## **More `docker run` Options**

We already know how to run a container, for example:

```
docker run redis
```

This runs the **latest** version of the Redis image.

---

### **1. Image Tags (Versions)**

Every Docker image can have **multiple versions**, called **tags**.

Example:

```
docker run redis:4.0
```

This runs **Redis version 4.0**, instead of the latest.

If you don’t specify a tag:

```
docker run redis
```

Docker automatically uses the:

```
:latest
```

tag.

---

### **Where do we find available tags?**

Go to:

```
https://hub.docker.com
```

Search for:

```
redis
```

You will see a list of tags/versions in the description.

Example Tag Table:

| Tag    | Meaning                                       |
| ------ | --------------------------------------------- |
| latest | The newest version defined by the maintainers |
| 5.0.5  | Specific Redis version                        |
| 4.0    | Older Redis release                           |

---

### **2. Interactive and Terminal Options (`-i` and `-t`)**

Consider a program that asks for your name:

```
Enter your name:
```

If we run it inside Docker normally:

```
docker run myapp
```

You **cannot type input** because containers run **non-interactively** by default.

To allow typing input, we use:

```
-i   → keep STDIN open (interactive mode)
```

Example:

```
docker run -i myapp
```

But this still **does not show a proper terminal prompt**.

To fix that, we add:

```
-t   → allocate a pseudo-terminal (TTY)
```

So the correct way is:

```
docker run -it myapp
```

This allows:

* Input to be typed
* Prompt/output to display correctly

---

### **Summary of `-i` and `-t`**

| Option | Meaning           | Purpose                                             |
| ------ | ----------------- | --------------------------------------------------- |
| `-i`   | Interactive STDIN | Allows you to type input                            |
| `-t`   | Allocate TTY      | Displays a proper terminal prompt                   |
| `-it`  | Both combined     | The standard way to open a shell inside a container |

Common example:

```
docker run -it ubuntu bash
```

This opens a shell **inside** an Ubuntu container.

---

### **3. Port Mapping (Next Topic)**

Many applications inside containers run on **internal ports** (e.g., web servers).

We need **port mapping** to access them from our host machine.

Command format:

```
docker run -p <host-port>:<container-port> <image>
```

Example (we will explain this in detail next):

```
docker run -p 8080:80 nginx
```

---

## **Quick Recap**

| Task                            | Command Example               |
| ------------------------------- | ----------------------------- |
| Run latest Redis                | `docker run redis`            |
| Run Redis version 4.0           | `docker run redis:4.0`        |
| Run container interactively     | `docker run -it ubuntu bash`  |
| Allow input in a CLI program    | `docker run -it myapp`        |
| Map host port to container port | `docker run -p 8080:80 nginx` |










