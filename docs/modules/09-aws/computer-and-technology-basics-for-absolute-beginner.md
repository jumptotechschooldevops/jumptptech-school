---
title: "Computer and Technology Basics for absolute beginner"
description: "🧩 1. “What Is a Computer?” → Hardware vs Software Diagram   Lecture Summary:   Computer =..."
published: 2025-10-15
source: "https://dev.to/jumptotech/computer-and-technology-basics-for-absolute-beginner-4coc"
tags: []
---

# Computer and Technology Basics for absolute beginner



## 🧩 1. “What Is a Computer?” → Hardware vs Software Diagram

**Lecture Summary:**

* Computer = electronic device that processes data.
* Hardware = physical parts.
* Software = instructions that tell hardware what to do.
* Types: desktops, laptops, servers, and smart devices.

**Connected Diagram:**

```
+----------------------+
|     SOFTWARE         |
|  (OS + Applications) |
+----------------------+
|     HARDWARE         |
| (CPU, RAM, Storage)  |
+----------------------+
```

**DevOps Connection:**

* In cloud servers (EC2, Azure VM), you select both hardware (CPU, RAM, Storage) and software (Ubuntu, Amazon Linux, etc.).
* As a DevOps engineer, you control both layers — for example, **automating software setup on hardware with Ansible or Terraform**.

---

## 🖥️ 2. “Buttons and Ports” → External Hardware Diagram

**Lecture Summary:**

* Power button, USB ports, HDMI, audio jacks, Ethernet ports.
* These allow connecting devices and networks.

**Connected Diagram:**

```
+-------------------------------------+
| USB | HDMI | Ethernet | Audio | Power |
+-------------------------------------+
```

**DevOps Connection:**

* Understanding ports = understanding **networking**.
  Example: Port 22 (SSH), Port 80 (HTTP), Port 443 (HTTPS).
* Physical Ethernet = like a **VPC connection** in AWS.

---

## ⚙️ 3. “Basic Parts of a Computer” → Internal Hardware Diagram

**Lecture Summary:**

* Case, monitor, keyboard, mouse, screen.
* Laptops combine these into one device.

**Connected Diagram:**

```
+--------------------+
|   MONITOR (Display)|
|   KEYBOARD / MOUSE |
|   COMPUTER CASE    |
|   POWER CABLE      |
+--------------------+
```

**DevOps Connection:**

* These are what you use locally for coding, automation, and testing.
* In cloud computing, you won’t physically see these — you use **terminals and dashboards** to control virtual computers.

---

## 🧩 4. “Inside a Computer” → Motherboard Diagram

**Lecture Summary:**

* Motherboard = central circuit board.
* CPU = brain.
* RAM = short-term memory.
* Hard Drive / SSD = long-term memory.
* Power Supply = sends power to components.
* Expansion slots = extra capabilities.

**Connected Diagram:**

```
+-------------------------------------------------+
| CPU  | RAM  | STORAGE  | GPU | POWER SUPPLY     |
| (Brain)(Memory)(Disk)  (Graphics)(Electricity)  |
+-------------------------------------------------+
```

**DevOps Connection:**

* In AWS, Azure, or GCP, you configure all of this virtually:

  * **CPU & Memory** → EC2 instance type
  * **Storage** → EBS volume or S3 bucket
  * **Motherboard/Network** → VPC and subnets
* When deploying apps, you **allocate compute, memory, and storage** just like a real machine.

---

## 💻 5. “Laptops vs Desktops”

**Lecture Summary:**

* Laptops are portable; desktops are powerful and customizable.
* Laptops have built-in batteries; desktops use power cables.

**Connected Diagram:**

```
[Desktop] -> More Power, Customizable
[Laptop] -> Portable, Built-in Components
```

**DevOps Connection:**

* Same tradeoff in DevOps:

  * **Local machine** = laptop
  * **Cloud environment** = remote “desktop” with more resources.
* You use both — local for code/testing, cloud for deployment.

---

## 🧠 6. “Operating Systems” → Software Layer Diagram

**Lecture Summary:**

* OS controls communication between user and hardware.
* Examples: Windows, macOS, Linux, Android.

**Connected Diagram:**

```
+---------------------------+
| Applications (Browser, IDE)|
+---------------------------+
| Operating System (Linux)   |
+---------------------------+
| Hardware (CPU, RAM, Disk)  |
+---------------------------+
```

**DevOps Connection:**

* Most DevOps servers run **Linux OS**.
* You’ll use the **terminal**, **commands**, and **permissions** to control the OS.
* OS automation = core skill (Ansible, Bash scripting, etc.).

---

## 🌐 7. “Connecting to the Internet” → Networking Diagram

**Lecture Summary:**

* Ethernet, Wi-Fi, broadband, fiber.
* Modem + Router connect you to the web.

**Connected Diagram:**

```
[Computer] <--Ethernet/Wi-Fi--> [Router] <---> [Internet]
```

**DevOps Connection:**

* Same principle as connecting a **VPC to the internet gateway** in AWS.
* You’ll manage connections using public/private subnets, firewalls, and routing.

---

## ☁️ 8. “What Is the Cloud?” → Cloud Architecture Diagram

**Lecture Summary:**

* Cloud = storing data and apps on internet servers.
* Examples: Google Drive, Dropbox, iDrive.

**Connected Diagram:**

```
[Your Laptop] ---> [Internet] ---> [Cloud Server]
```

**DevOps Connection:**

* This is **the foundation of DevOps**.
* You deploy code, databases, and apps to **cloud servers** (AWS EC2, EKS, Azure VMs).
* You also manage **CI/CD pipelines** that push software to the cloud.

---

## 🧹 9. “Cleaning and Maintenance”

**Lecture Summary:**

* Keep computer dust-free; clean keyboard and fans.
* Avoid overheating.

**DevOps Connection:**

* In DevOps, this is **system maintenance**:

  * Cleaning log files
  * Deleting old containers/images
  * Monitoring CPU temperature and usage

---

## 🔐 10. “Protecting Your Computer” → Security Stack Diagram

**Lecture Summary:**

* Use antivirus, backups, OS updates, and cloud backups.

**Connected Diagram:**

```
+--------------------------+
| User Data (Files, Code)  |
+--------------------------+
| Security Layer (Antivirus, Encryption) |
+--------------------------+
| Cloud Backup             |
+--------------------------+
```

**DevOps Connection:**

* Similar to **DevSecOps** — protect cloud systems using:

  * IAM Roles
  * Security Groups
  * Encryption (KMS, SSL/TLS)
  * Regular backups (S3, EBS snapshots)

---

## 🪑 11. “Creating a Safe Workspace”

**Lecture Summary:**

* Ergonomics: monitor height, chair, breaks, posture.

**DevOps Connection:**

* Encourages healthy long-term work habits.
* DevOps work often involves long terminal sessions — ergonomics = productivity.

---

## 🌎 12. “Internet Safety, Spam, Tracking”

**Lecture Summary:**

* Beware phishing, spam, and tracking cookies.
* Check HTTPS padlock icon.

**Connected Diagram:**

```
[User] ---> [Secure Website (HTTPS)] ---> [Internet]
```

**DevOps Connection:**

* Web security knowledge = essential for CI/CD testing, SSL configuration, and protecting infrastructure.
* When you set up HTTPS on a load balancer or Kubernetes Ingress, it’s the same concept.

---

## 💡 13. “Windows & macOS Basics” → GUI Diagram

**Lecture Summary:**

* Learn desktop, start menu, dock, file explorer, finder.

**Connected Diagram:**

```
+--------------------------------+
| Graphical Interface (Icons, Menus) |
+--------------------------------+
| File System (Folders, Files)      |
+--------------------------------+
| OS Kernel + Hardware             |
+--------------------------------+
```

**DevOps Connection:**

* GUI for beginners → later replaced by CLI tools (bash, zsh).
* File navigation (Finder, File Explorer) → equivalent to using Linux commands (`ls`, `cd`, `pwd`).

---

## 🌐 14. “Browser Basics” → Application Layer Diagram

**Lecture Summary:**

* Browser = tool to access websites.
* Tabs, bookmarks, history, back/forward.

**Connected Diagram:**

```
+--------------------------+
| Web Browser (Chrome)     |
|  -> Uses Internet        |
|  -> Displays Web Apps    |
+--------------------------+
```

**DevOps Connection:**

* Browsers are used to access Jenkins dashboards, AWS Console, Grafana, and Argo CD UI.
* Understanding browser structure helps debug web apps and APIs.

---

## ✅ 15. Summary Diagram for Students

```
USER (You)
    ↓
APPLICATIONS (VS Code, Docker Desktop)
    ↓
OPERATING SYSTEM (Linux, macOS, Windows)
    ↓
HARDWARE (CPU, RAM, Storage)
    ↓
NETWORK (Router, Internet, Cloud)
    ↓
CLOUD SERVERS (AWS, Azure, GCP)
```






---

## 🧩 2. Section Breakdown for DevOps Beginners

| **Component**                | **Simple Explanation**                                         | **DevOps Relevance (Why You Should Care)**                                                                                    |
| ---------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **CPU (Processor)**          | The “brain” of the computer that runs instructions.            | In cloud (AWS EC2, Azure VMs), you choose CPU types (t2.micro, m5.large etc.) — more cores = faster builds & deployments.     |
| **Motherboard**              | A large board that connects all other parts.                   | In physical servers (on-prem DevOps), all components attach here; in cloud, the VPC network is like a digital motherboard.    |
| **Chipset & Bus**            | The communication center between CPU, RAM, storage, and ports. | Equivalent to how Kubernetes or Terraform connect resources — data flow and resource coordination.                            |
| **VRM (Voltage Regulator)**  | Lowers power from the supply to safe levels for CPU.           | Teaches you why monitoring power and CPU temperature matters in data centers.                                                 |
| **CPU Cooler**               | Moves heat away from CPU using air or liquid.                  | In DevOps monitoring tools (Prometheus, Grafana), CPU temperature and load alerts are crucial.                                |
| **Power Supply (PSU)**       | Converts wall power into DC power for the computer.            | Equivalent to cloud infrastructure power planning and availability zones.                                                     |
| **GPU (Graphics Processor)** | Handles visual and parallel computing tasks.                   | Used in DevOps for machine-learning servers, AI pipelines, and render jobs that need GPUs on AWS (EKS or EC2 p2/p3).          |
| **RAM (Temporary Memory)**   | Fast memory that stores data the CPU is using right now.       | Impacts build and deployment speed in CI/CD pipelines (Jenkins, GitHub Actions).                                              |
| **SSD (Solid State Drive)**  | Permanent fast storage with no moving parts.                   | Used for container images and CI/CD workspaces — fast I/O means faster pipelines.                                             |
| **HDD (Hard Disk Drive)**    | Magnetic disks that store lots of data cheaply but slower.     | Used for backups and log storage (ELK, S3 Glacier analogy in cloud).                                                          |
| **Mouse & Keyboard**         | Input devices to interact with computer.                       | DevOps engineers often work headless (SSH terminal), but you should know how peripherals connect via USB for troubleshooting. |

---

## 🧠 3. Quiz for Absolute Beginners (DevOps Context)

### **A. Multiple Choice**

1. Which part executes the commands you type in a terminal?
   a) RAM b) GPU c) CPU ✅ d) HDD

2. Which component is like the “central hub” that connects CPU, RAM, and storage?
   a) Motherboard ✅ b) GPU c) Power Supply d) SSD

3. What makes SSDs faster than HDDs?
   a) They use liquid cooling b) They have no moving parts ✅ c) They store data magnetically d) They are cheaper

4. In DevOps, choosing an EC2 instance with more CPU cores helps because ___.
   a) It uses less power b) It can run more containers faster ✅ c) It needs no cooling d) It has bigger screen

5. Why is RAM important in a Jenkins pipeline?
   a) It stores the OS permanently b) It helps run multiple builds at once ✅ c) It controls the fans d) It cools the CPU

---

### **B. True / False**

1. The GPU is only used for gaming. ❌
2. The CPU needs a cooler because it gets hot while processing. ✅
3. The power supply converts AC to DC power for the computer. ✅
4. HDDs are faster than SSDs. ❌
5. RAM is temporary and data is lost when power is off. ✅

---

### **C. Short Answer (1–2 sentences each)**

1. **Why do DevOps engineers care about CPU and RAM sizes when creating cloud instances?**
   → They affect how fast applications build, deploy, and run in the pipeline.

2. **What is the purpose of cooling systems in data centers or servers?**
   → To prevent hardware damage and downtime by keeping CPUs and GPUs from overheating.

3. **Why do we use SSD storage for containers or databases?**
   → Because SSDs have high speed and low latency, making applications and pipelines faster.

4. **If you were to monitor a server, which hardware metrics would you track?**
   → CPU usage, memory (RAM), disk I/O, temperature, and power supply status.


