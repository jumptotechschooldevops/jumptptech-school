---
title: "AWS introduction"
description: "🧾 AWS Billing, Budget, and Cost Management – Step-by-Step            1. Access the Billing..."
published: 2025-10-06
source: "https://dev.to/jumptotech/aws-introduction-17h6"
tags: []
---

# AWS introduction


## 🧾 **AWS Billing, Budget, and Cost Management – Step-by-Step**

### 1. Access the Billing Console

* In the **AWS Management Console**, click your account name (top right).
* Choose **Billing and Cost Management**.

> ⚠️ If you see “Access Denied” — you are using an **IAM user**.
> Only the **root account** can enable billing access for IAM users.

---

### 2. Enable Billing Access for IAM Users

* Sign in as the **root account owner**.
* Go to **Account → IAM user and role access to billing information**.
* Turn **ON** “Activate IAM access.”

Now IAM users with admin permissions can view billing.

---

### 3. View Billing Data

* Go back to **Billing → Bills**.
* You can now see:

  * **Month-to-date costs**
  * **Forecasted cost**
  * **Charges by service** (e.g., EC2, S3, etc.)
* Click on a month → scroll to **Charges by Service** to identify what costs money (e.g., NAT Gateway, EBS, etc.).

---

### 4. Check the **Free Tier**

* Go to **Billing → Free Tier**.
* Shows:

  * **Usage vs Free Tier limit**
  * **Forecasted overages**
* If usage turns **red**, you’re about to be charged — stop or delete resources.

---

### 5. Create a Budget

* Go to **Billing → Budgets → Create budget**.
* Choose **“Use a template (simplified)”**.

#### **Option A: Zero Spend Budget**

* Template: **Zero spend**
* Name: `My Zero Spend Budget`
* Alert email: your address (e.g., `yourname@example.com`)
* Sends alert as soon as you spend **$0.01**.

#### **Option B: Monthly Cost Budget**

* Template: **Monthly cost budget**
* Limit: e.g., `$10`
* Add alert recipients.
* Alerts at:

  * 85% of actual spend
  * 100% of actual spend
  * 100% of forecasted spend

---

### ✅ **Result**

You’ll get an email warning if:

* You spend **1 cent** (zero spend budget), or
* Your forecasted/actual spend hits your **limit**.

This ensures students **don’t overspend** during AWS labs.







# ☁️ **Amazon EC2 – Elastic Compute Cloud**

## 1. What is EC2?

* **EC2** = **Elastic Compute Cloud**
* It’s AWS’s main **Infrastructure as a Service (IaaS)** offering.
* Lets you **rent virtual machines (VMs)** — called **EC2 Instances** — on demand.
* Foundation of AWS: most AWS services depend on EC2 behind the scenes.

---

## 2. Key EC2 Components

| Component                       | Description                                                                           |
| ------------------------------- | ------------------------------------------------------------------------------------- |
| **EC2 Instance**                | The virtual server you rent from AWS.                                                 |
| **EBS Volume**                  | Elastic Block Storage – a network-attached disk for your instance.                    |
| **Elastic Load Balancer (ELB)** | Distributes incoming traffic across multiple instances.                               |
| **Auto Scaling Group (ASG)**    | Automatically increases or decreases the number of running instances based on demand. |
| **Security Group**              | Acts as a firewall — controls inbound/outbound traffic to the instance.               |
| **Elastic IP**                  | A static public IP address you can attach to your instance.                           |
| **User Data**                   | Script that runs *once* when the instance boots — used for automation/setup tasks.    |

---

## 3. Choosing EC2 Instance Settings

When launching an EC2 instance, you choose:

| Option               | Examples / Details                                                                                           |
| -------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Operating System** | Linux (most popular), Windows, or macOS.                                                                     |
| **Compute (vCPUs)**  | Choose instance type (e.g., `t2.micro`, `t3.medium`) based on performance.                                   |
| **Memory (RAM)**     | Depends on workload size (web server vs. database).                                                          |
| **Storage**          | - **EBS**: network-attached, persistent storage. <br> - **Instance Store**: local hardware disk (temporary). |
| **Network**          | Select subnet, VPC, and network interface (speed, public IP, etc.).                                          |
| **Firewall Rules**   | Configure **Security Groups** — open only necessary ports (e.g., 22 for SSH, 80 for HTTP).                   |

---

## 4. Bootstrapping with **User Data**

**Bootstrapping** = running setup commands automatically when the instance launches.

✅ Common tasks in **User Data**:

* Update packages (`yum update -y` or `apt update -y`)
* Install software (e.g., Nginx, Apache, Python)
* Download configuration files
* Start services automatically

🧠 Notes:

* Runs **only once** at first boot.
* Executed as **root user** (no need for `sudo`).
* Makes EC2 setup **automated and repeatable**.

Example:

```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Hello from EC2</h1>" > /usr/share/nginx/html/index.html
```

---

## 5. Why EC2 Matters

* Core building block of the AWS ecosystem.
* Lets you **quickly deploy servers on demand**.
* Forms the base for many other services (ECS, EKS, Beanstalk, etc.).
* Teaches the foundation of **cloud computing**: scalability, pay-as-you-go, and automation.





# 🚀 **Launching Your First EC2 Instance (Amazon Linux)**

## 1. What You’ll Do

You will:

* Launch your **first EC2 instance** (a virtual server).
* Use **User Data** to automatically install a web server.
* Access the website through a browser.
* Learn to **start**, **stop**, and **terminate** the instance.

---

## 2. Launch an Instance

### **Step 1: Open EC2 Console**

* Go to **AWS Management Console → EC2 → Instances**
* Click **Launch Instances**

---

### **Step 2: Name and Tags**

* Name: `My First Instance`
* (Tag Key = `Name`, Value = `My First Instance`)

---

### **Step 3: Choose an AMI (Amazon Machine Image)**

* Go to **Quick Start → Amazon Linux 2 AMI (64-bit x86)**
* ✅ Free Tier eligible

This defines the **operating system** for your EC2 instance.

---

### **Step 4: Choose Instance Type**

* Choose **t2.micro** (Free Tier eligible)
* 1 vCPU, 1 GB RAM
* Perfect for small practice servers

---

### **Step 5: Create or Choose Key Pair**

You’ll need a key to connect via SSH later.

* Name: `EC2Tutorial`
* Type: `RSA`
* Format:

  * **.pem** → for Mac, Linux, or Windows 10+
  * **.ppk** → for older Windows (PuTTY)
* Download and save it safely — AWS **will not let you download again!**

---

### **Step 6: Configure Network Settings**

* Leave defaults (public IP assigned automatically).
* Create a **Security Group** (default name: `launch-wizard-1`).
* Add inbound rules:

  * **SSH (port 22)** → Source: Anywhere
  * **HTTP (port 80)** → Source: Anywhere
    (This allows browser access.)

---

### **Step 7: Configure Storage**

* Default: 8 GB **gp2** EBS volume
* You get up to **30 GB** free under Free Tier.
* Option “Delete on Termination” = **Yes** (keeps cleanup simple).

---

### **Step 8: Add User Data Script**

Scroll to **Advanced details → User data**
Paste this script:

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
```

This will:

* Update the system
* Install Apache web server
* Enable it at boot
* Create a simple “Hello World” web page

---

### **Step 9: Launch**

* Review → Launch instance
* Go to **View all instances**
* Wait until **Instance State = running** (takes ~10–15 seconds)

---

## 3. Access the Website

* Copy your **Public IPv4 address**
* In your browser, enter:

  ```
  http://<Public-IP>
  ```
* (⚠️ Use `http`, *not* `https`.)
* You’ll see:
  **Hello World from 172.x.x.x** — where the number is the private IP.

---

## 4. Manage the Instance

| Action                 | What It Does            | Note                                |
| ---------------------- | ----------------------- | ----------------------------------- |
| **Stop Instance**      | Shuts down the server   | You’re **not billed** while stopped |
| **Start Instance**     | Restarts it later       | ⚠️ May get a **new public IP**      |
| **Terminate Instance** | Deletes server + volume | Irreversible — removes data         |

> 🧠 The private IP stays the same, but the **public IP changes** after every stop/start cycle unless you assign an **Elastic IP**.

---

## 5. Key Takeaways

* You can launch a web server **in minutes** without owning hardware.
* **User Data** automates setup during boot.
* Learn to stop/terminate to **avoid charges**.
* EC2 is the **core of cloud computing** — flexible, fast, pay-as-you-go.




# ⚙️ **Amazon EC2 Instance Types**

## 1. Why EC2 Instance Types Exist

AWS offers **different EC2 instance types** to match **different workloads** —
from lightweight web servers to machine learning and databases.

Each type has:

* Different **CPU, RAM, and network** capabilities
* Different **optimization** (compute, memory, storage, or networking)
* Different **pricing**

---

## 2. EC2 Instance Naming Convention

Example: **m5.2xlarge**

| Part        | Meaning                 | Example                              |
| ----------- | ----------------------- | ------------------------------------ |
| **m**       | Instance class / family | `m` = general purpose                |
| **5**       | Generation              | `5` = newer than `4`, older than `6` |
| **2xlarge** | Size                    | Larger = more vCPUs & memory         |

So `m5.2xlarge` means:
➡️ General-purpose instance, generation 5, with 2xlarge size (moderate CPU and memory).

---

## 3. EC2 Instance Families (Main Categories)

| Type                         | Family Prefix | Description                          | Example Use Cases                                      |
| ---------------------------- | ------------- | ------------------------------------ | ------------------------------------------------------ |
| 🧩 **General Purpose**       | `t`, `m`, `a` | Balanced CPU, memory, and networking | Web servers, code repos, dev/test environments         |
| ⚡ **Compute Optimized**      | `c`           | High CPU performance                 | Batch processing, media encoding, gaming, ML inference |
| 🧠 **Memory Optimized**      | `r`, `x`, `z` | High RAM for in-memory processing    | Databases, caching (Redis), analytics, BI              |
| 💾 **Storage Optimized**     | `i`, `d`, `h` | High local disk throughput           | Big data, OLTP, NoSQL, data warehousing                |
| 🎮 **Accelerated Computing** | `p`, `g`, `f` | GPUs or FPGAs                        | AI/ML training, deep learning, rendering, HPC          |

---

## 4. Common Instance Examples

| Instance      | vCPU | Memory (GB) | Optimized For                |
| ------------- | ---- | ----------- | ---------------------------- |
| `t2.micro`    | 1    | 1           | General-purpose, free tier   |
| `m5.large`    | 2    | 8           | Balanced web/app server      |
| `c5.4xlarge`  | 16   | 32          | Compute-intensive tasks      |
| `r5.16xlarge` | 64   | 512         | Memory-heavy databases       |
| `i3.8xlarge`  | 32   | 244         | Storage-optimized, high IOPS |

---

## 5. Helpful Reference Websites

### 🔗 **AWS Official Instance Types Page**

[https://aws.amazon.com/ec2/instance-types](https://aws.amazon.com/ec2/instance-types)
→ Lists all current instance families, pricing, and features.

### 🔗 **EC2Instances.info**

[https://ec2instances.info](https://ec2instances.info)
→ Excellent for:

* Comparing CPU, memory, storage, and cost
* Searching & filtering instance families
* Quickly checking **On-Demand** and **Reserved** pricing

---

## 6. Key Takeaways

✅ **Understand the prefixes:**

* `t` → test & dev (burstable)
* `m` → general-purpose
* `c` → compute-heavy
* `r` → memory-heavy
* `i` → storage-heavy
* `p/g` → GPU-based

✅ **Choose instance type by workload:**

* Web apps → `t2.micro`, `m5.large`
* Databases → `r5.xlarge`
* Machine learning → `p3`, `g4`
* Data warehousing → `i3`, `d2`

✅ **Use the AWS Free Tier:**

* `t2.micro` or `t3.micro` = Free for 12 months (750 hours/month)









# 🔒 **Security Groups in Amazon EC2 (Firewalls)**

## 1. What Are Security Groups?

* **Security Groups (SGs)** are **virtual firewalls** that control traffic **into and out of** your EC2 instances.
* They define **network access rules** based on:

  * **Ports** (e.g., 22 for SSH, 80 for HTTP)
  * **Protocols** (TCP, UDP, etc.)
  * **Source/Destination** (IP ranges or other security groups)

> 🧠 Think of a security group as a “protective shield” that decides **who can talk to your server** and on **which ports**.

---

## 2. Basic Behavior

| Direction    | Default Behavior                     | Purpose                                                              |
| ------------ | ------------------------------------ | -------------------------------------------------------------------- |
| **Inbound**  | ❌ All traffic **blocked** by default | Protects the instance from unwanted access                           |
| **Outbound** | ✅ All traffic **allowed** by default | Lets the instance connect to the internet (updates, downloads, etc.) |

* SGs contain **only ALLOW rules** (no explicit “deny”).
* If traffic is not explicitly allowed → it’s **implicitly denied**.

---

## 3. How Security Groups Work

### Example:

You (your computer) are on the **public internet**, trying to connect to an **EC2 instance**.

* The EC2 instance has a **Security Group** attached.
* That SG checks its **inbound rules**:

  * If your IP and port (e.g., 22 or 80) match → traffic **allowed**
  * If not → traffic **blocked**

### Two traffic directions:

* **Inbound rules** → from the **outside** → into EC2
* **Outbound rules** → from **EC2** → out to the internet

---

## 4. Security Group Rules Format

| Field                  | Description             | Example                      |
| ---------------------- | ----------------------- | ---------------------------- |
| **Type**               | What kind of connection | SSH, HTTP, HTTPS             |
| **Protocol**           | Usually TCP             | TCP                          |
| **Port Range**         | Communication port      | 22, 80, 443                  |
| **Source/Destination** | IP or Security Group    | `0.0.0.0/0` (all) or your IP |

### Example Rule:

| Type | Protocol | Port | Source                   |
| ---- | -------- | ---- | ------------------------ |
| SSH  | TCP      | 22   | Your IP (`203.x.x.x/32`) |
| HTTP | TCP      | 80   | `0.0.0.0/0`              |

---

## 5. Key Characteristics

✅ You can attach:

* **One SG → multiple instances**
* **One instance → multiple SGs**

✅ SGs are:

* **Region-specific**
* **VPC-specific**

✅ SGs live **outside the instance** (so blocked traffic never reaches it).

✅ If your app **times out**, it’s probably an SG issue.
If you get **connection refused**, SG worked but the app isn’t running.

---

## 6. Best Practices

* Create a **dedicated SG for SSH (port 22)** and restrict it to **your IP only**.
  Example: `MySSH-SG` → Inbound rule: SSH (22) → Source: your IP.
* Create **separate SGs** for each application/service (e.g., web, database).
* Regularly review inbound rules — remove unused ones.

---

## 7. Referencing Other Security Groups

Security groups can **reference other security groups** instead of IPs.

### Why use it?

When instances must communicate **internally** (e.g., web server → database),
you don’t have to manage IP addresses.

**Example:**

* SG-Web → allows inbound HTTP (80) from `0.0.0.0/0`
* SG-DB → allows inbound MySQL (3306) **from SG-Web**

➡️ Any instance with SG-Web can talk to instances with SG-DB over port 3306.

This is common with **load balancers** and **multi-tier apps**.

---

## 8. Common Ports to Remember

| Port     | Protocol | Purpose                         |
| -------- | -------- | ------------------------------- |
| **22**   | SSH      | Linux remote login              |
| **21**   | FTP      | File Transfer Protocol          |
| **22**   | SFTP     | Secure File Transfer (uses SSH) |
| **80**   | HTTP     | Unsecured web traffic           |
| **443**  | HTTPS    | Secured web traffic             |
| **3389** | RDP      | Remote Desktop (Windows)        |

---

## 9. Quick Recap

✅ **Inbound** = Blocked by default
✅ **Outbound** = Allowed by default
✅ **Security Groups = ALLOW rules only**
✅ **Region + VPC bound**
✅ **Timeout → SG issue**, **Connection Refused → App issue**

---




# 🔐 **Hands-On: Working with Security Groups in EC2**

---

## 1. Where to Find Security Groups

* In the **EC2 Console**, select your instance → click **Security** tab.
* You’ll see:

  * **Inbound rules**
  * **Outbound rules**
  * Linked **Security Group(s)**

For a full view:
👉 Left menu → **Network & Security → Security Groups**

---

## 2. Default Security Groups

You’ll typically see:

1. **Default security group** (created automatically per VPC)
2. **Launch-wizard-1** (created during your first EC2 launch)

Each SG has:

* A **unique ID** (e.g., `sg-0a12b3c4d5e6f`)
* **Inbound rules** → traffic *into* your instance
* **Outbound rules** → traffic *out of* your instance

---

## 3. Viewing and Editing Inbound Rules

Example: **Launch-wizard-1**

| Type | Protocol | Port | Source    | Purpose                |
| ---- | -------- | ---- | --------- | ---------------------- |
| SSH  | TCP      | 22   | 0.0.0.0/0 | Remote terminal access |
| HTTP | TCP      | 80   | 0.0.0.0/0 | Web server access      |

* These rules allowed us to:

  * **SSH** into the instance (port 22)
  * **Access the web page** (`http://<Public-IP>`) on port 80

---

## 4. Testing Firewall Behavior

### 🔸 Case 1 – Remove the HTTP rule

* Delete the inbound rule for port **80**.
* Save changes.
* Try reloading your website → ❌ **Timeout**

> 🧠 **Timeout = Security Group issue**
>
> * Your request never reached the EC2 instance.
> * Fix: check inbound rules.

---

### 🔸 Case 2 – Add the HTTP rule back

* Add inbound rule:

  * **Type:** HTTP
  * **Port:** 80
  * **Source:** Anywhere (`0.0.0.0/0`)
* Save rules → ✅ Refresh your page → Works again!

> The **port 80** rule allows public HTTP access to your web server.

---

## 5. Adding New Rules

You can:

* Choose any **port or port range** (e.g., 443 for HTTPS).
* Pick from the **dropdown list** (common protocols).
* Specify **source**:

  * `Anywhere` (`0.0.0.0/0`) → open to everyone
  * `My IP` → restrict access to your own machine
  * **Custom CIDR**, **security group**, or **prefix list** → for advanced setups

⚠️ **Note:** If your IP changes (e.g., new Wi-Fi or VPN), you’ll lose access if rule is “My IP”.

---

## 6. Outbound Rules

Default outbound rule:

| Type        | Protocol | Port | Destination |
| ----------- | -------- | ---- | ----------- |
| All traffic | All      | All  | 0.0.0.0/0   |

→ This allows your instance to **download updates, connect to APIs, or reach the internet** freely.

---

## 7. Multiple Security Groups and Instances

* **One EC2 instance** can have **multiple SGs** attached.
* **One SG** can be attached to **multiple EC2 instances**.
* Combined rules are **additive** — all allowed traffic from each SG is permitted.

---

## 8. Quick Diagnostic Tip

| Symptom               | Meaning                         | Fix                      |
| --------------------- | ------------------------------- | ------------------------ |
| ❌ Timeout             | Blocked by SG (no inbound rule) | Add correct inbound rule |
| ⚠️ Connection Refused | App/service not running on port | Start service inside EC2 |

---

## ✅ Summary

* SGs control **inbound and outbound** traffic.
* They’re **stateful** — return traffic is automatically allowed.
* **Timeouts = SG misconfiguration**, not instance failure.
* Use **least privilege** → only open required ports.
* One SG = many instances; one instance = many SGs.








# 🧩 **Connecting to Your EC2 Instance**

---

## 1. Why We Need It

After launching an EC2 instance, the next step is to **connect inside the server** —
to install software, check logs, or perform maintenance.

To do this securely, AWS provides several **connection methods**, depending on your computer’s **operating system**.

---

## 2. The SSH Protocol

### 🔐 **What is SSH?**

**SSH (Secure Shell)** is a protocol that allows secure, encrypted remote access to Linux servers.

It lets you:

* Run commands directly on your EC2 instance.
* Manage software, configurations, and troubleshooting.
* Transfer files securely (via SFTP or SCP).

---

## 3. Methods by Operating System

| Platform                     | Recommended Method        | Tool                                             | Notes                                          |
| ---------------------------- | ------------------------- | ------------------------------------------------ | ---------------------------------------------- |
| **Mac / Linux**              | SSH command-line          | Built-in terminal                                | Use `ssh -i your-key.pem ec2-user@<Public-IP>` |
| **Windows 10 / 11**          | SSH (built-in PowerShell) | Use `ssh` command                                | Works the same as on Mac/Linux                 |
| **Windows 7 / 8 (or older)** | PuTTY                     | Separate application                             | Convert `.pem` → `.ppk` file first             |
| **Any OS (browser-based)**   | EC2 Instance Connect      | AWS Console → “Connect” → “EC2 Instance Connect” | Easiest, no software setup                     |

---

## 4. 🧠 **EC2 Instance Connect (Recommended for Beginners)**

### ✅ Advantages:

* Works on **Mac, Linux, Windows** — any browser.
* No setup, no key conversion, no CLI required.
* Uses your **AWS credentials** securely.
* Best for quick testing and short sessions.

### ⚠️ Limitation:

* Currently supports **Amazon Linux 2** and **Ubuntu** instances only.
* Not ideal for automation or long-term maintenance.

---

## 5. ⚙️ **When to Use SSH**

* For **advanced work**, scripting, or automation.
* When using custom Linux distributions.
* When setting up multiple servers with consistent access.

### Example SSH Command (Mac/Linux/Win10+)

```bash
ssh -i ~/Downloads/ec2tutorial.pem ec2-user@<Public-IP>
```

> Replace `<Public-IP>` with your instance’s address.
> Ensure port 22 is open in your **Security Group**.

---

## 6. Common SSH Connection Issues

| Problem                          | Likely Cause                        | Fix                                                               |
| -------------------------------- | ----------------------------------- | ----------------------------------------------------------------- |
| ❌ Timeout                        | Security Group missing port 22 rule | Add inbound rule for SSH (port 22, your IP)                       |
| ⚠️ Permission denied (publickey) | Wrong key or wrong user name        | Use correct `.pem` and correct user (`ec2-user` for Amazon Linux) |
| ⛔️ Connection refused            | Instance not running or booting     | Wait for “Running” state                                          |
| 🌐 Wrong IP                      | Instance stopped/restarted          | Use new Public IP or attach an Elastic IP                         |

---

## 7. 💡 Instructor Tips

* **Only one method** needs to work (SSH or EC2 Instance Connect).
* Don’t stress if SSH fails — you’ll still progress fine with **EC2 Instance Connect**.
* Keep your `.pem` key safe — AWS doesn’t allow redownloads.
* Always check **Security Group** rules before troubleshooting deeper.

---

## 8. 🧭 Next Steps

1. Identify your OS.
2. Use the right connection method:

   * Mac/Linux → SSH
   * Windows 10+ → PowerShell SSH
   * Windows 7/8 → PuTTY
   * Any OS → EC2 Instance Connect
3. Connect and explore your EC2 server.

---











# 💻 **Connecting to EC2 with SSH (Mac or Linux)**

---

## 1. 🎯 Goal

Use **SSH (Secure Shell)** to remotely access your EC2 instance from your local terminal.
Once connected, you’ll be able to:

* Run Linux commands directly on the EC2 machine
* Verify network connectivity
* Manage and troubleshoot your cloud server

---

## 2. 🧱 How SSH Works

### Diagram:

```
Your Laptop (SSH Client)
   ↓ Port 22 (SSH)
Internet
   ↓
EC2 Instance (Amazon Linux 2)
Security Group → allows Port 22 inbound
```

### Explanation:

* SSH uses **Port 22** to securely connect to the server.
* The **Security Group** must allow inbound access on **Port 22**.
* The connection authenticates using your **private key (.pem)**.

---

## 3. 🧩 Preparation Steps

1. Locate your downloaded key file (e.g. `EC2Tutorial.pem`).

   * Rename it to remove spaces → ✅ `EC2Tutorial.pem`
2. Move it to a safe folder (e.g. `~/aws-course/`).
3. In AWS Console:

   * Go to **EC2 → Instances**
   * Copy your **Public IPv4 Address**
   * Check **Security Group** → must allow:

     ```
     Type: SSH | Protocol: TCP | Port: 22 | Source: 0.0.0.0/0
     ```

---

## 4. 🖥️ Navigate to the Key File

Open your terminal:

```bash
cd ~/aws-course
ls
```

You should see:

```
EC2Tutorial.pem
```

If not:

* Use `pwd` to see where you are.
* Use `cd ..` to go up a directory until you find your folder.

---

## 5. 🔑 Set Proper Permissions

Your key file must not be publicly viewable:

```bash
chmod 400 EC2Tutorial.pem
```

This means: **only you can read the file**.

---

## 6. 🌐 Connect via SSH

Run:

```bash
ssh -i EC2Tutorial.pem ec2-user@<Public-IP>
```

### Example:

```bash
ssh -i EC2Tutorial.pem ec2-user@54.165.90.11
```

* `-i` → specify your private key file
* `ec2-user` → default username for **Amazon Linux 2**
* `<Public-IP>` → your EC2’s public IPv4 address

If prompted with:

```
Are you sure you want to continue connecting (yes/no)?
```

→ type **yes**.

---

## 7. ✅ You’re In!

If successful, your prompt changes:

```
[ec2-user@ip-172-31-45-20 ~]$
```

You’re now **inside your EC2 instance**.

---

## 8. 🧪 Try Basic Commands

```bash
whoami         # shows current user (ec2-user)
hostname       # displays machine name
ping google.com
```

Press **Ctrl + C** to stop the ping.

---

## 9. 🚪 Exit the SSH Session

To disconnect:

```bash
exit
```

or press **Ctrl + D**.

---

## 10. ⚠️ Important Notes

* If you **stop and start** your instance → the **Public IP changes**.
  Update your SSH command accordingly.
* Keep your `.pem` file secure — **you cannot re-download it** from AWS.
* If you see **"Permission denied"**, check:

  * File permissions (`chmod 400`)
  * Username (`ec2-user`)
  * Correct IP address
  * Port 22 open in security group

---

## 🧠 Summary

| Step | Command                                       | Purpose                |
| ---- | --------------------------------------------- | ---------------------- |
| 1    | `chmod 400 EC2Tutorial.pem`                   | Secure key permissions |
| 2    | `ssh -i EC2Tutorial.pem ec2-user@<Public-IP>` | Connect to instance    |
| 3    | `whoami` / `ping google.com`                  | Test access            |
| 4    | `exit`                                        | Disconnect safely      |









# 💻 **Connecting to EC2 Using SSH on Windows (PuTTY Method)**

---

## 1. 🎯 **Goal**

Learn how to connect (SSH) from a **Windows computer** to an **Amazon Linux 2 EC2 instance** using **PuTTY**.

SSH lets you:

* Control your EC2 instance **remotely** from Windows.
* Run commands directly on your cloud server.
* Troubleshoot or configure your Linux machine securely.

---

## 2. 🌍 **How It Works**

```
Your Windows PC (PuTTY)
   ↓ Port 22 (SSH)
Internet
   ↓
EC2 Instance (Amazon Linux 2)
Security Group → allows Port 22 inbound
```

✅ SSH (Secure Shell) runs over **Port 22**
✅ The EC2 **Security Group** must allow:

```
Type: SSH
Protocol: TCP
Port: 22
Source: 0.0.0.0/0
```

---

## 3. 🧩 **Prerequisites**

1. You already launched an **EC2 instance (Amazon Linux 2)**.
2. You downloaded your **key pair file** (e.g., `EC2Tutorial.pem`).
3. You are using **Windows 7, 8, or older** (PuTTY required).

   > For Windows 10+, you can use **PowerShell SSH** instead.

---

## 4. 🧰 **Install PuTTY Tools**

Go to [https://www.putty.org/](https://www.putty.org/)
Download and install:

* **PuTTY** (main SSH app)
* **PuTTYgen** (key converter tool)

During setup → click **Next → Install → Finish** ✅

---

## 5. 🔑 **Convert Your .PEM Key to .PPK**

PuTTY requires `.ppk` format for private keys.

### Steps:

1. Open **PuTTYgen**.
2. Click **Load**.
3. Navigate to your `.pem` file (e.g., `EC2Tutorial.pem`).

   * If it’s not visible → choose **All Files (*.*)** at the bottom right.
4. Select the file → click **Open**.
5. You’ll see:
   `"Successfully imported foreign key"`
6. Click **Save private key** → choose a name like `EC2Tutorial.ppk`.
7. When asked about a passphrase → click **Yes** (no passphrase needed).
8. Save it (e.g., on your Desktop).

✅ You now have both:

```
EC2Tutorial.pem  (AWS original)
EC2Tutorial.ppk  (PuTTY-compatible)
```

---

## 6. ⚙️ **Configure PuTTY to Connect**

1. Open **PuTTY**.

2. In **Host Name (or IP address)**, enter:

   ```
   ec2-user@<Public-IP>
   ```

   Example:

   ```
   ec2-user@54.167.123.45
   ```

3. Port: **22**
   Connection type: **SSH**

4. In the **Category** list → expand **SSH** → click **Auth**.

5. Under “Private key file for authentication” → click **Browse**.

6. Select your `.ppk` file (e.g., `EC2Tutorial.ppk`).

7. Go back to **Session** (top of the list).

8. Under “Saved Sessions,” name it something like:

   ```
   EC2-Instance
   ```

   Then click **Save**.

✅ This stores your connection and key configuration.

---

## 7. 🔌 **Connect to EC2**

1. Select your saved session (`EC2-Instance`).
2. Click **Open**.
3. A security alert appears:

   > “The server’s host key is not cached in the registry.”
   > → Click **Yes** (to trust it).
4. You’ll see:

   ```
   login as:
   ```

   Type:

   ```
   ec2-user
   ```
5. ✅ You’re in your EC2 instance!

---

## 8. 🧪 **Test Commands**

Inside PuTTY, try:

```bash
whoami          # shows current user
hostname        # shows machine name
ping google.com # tests internet connectivity
```

To stop the ping → **Ctrl + C**.

---

## 9. 🚪 **Exit and Reconnect**

* To leave the session:

  ```bash
  exit
  ```
* Next time:

  * Open **PuTTY**
  * Load your saved session (`EC2-Instance`)
  * Click **Open**
  * You’ll be logged in instantly — no need to reconfigure.

---

## 10. ⚠️ **Common Troubleshooting**

| Problem                          | Likely Cause                       | Fix                                     |
| -------------------------------- | ---------------------------------- | --------------------------------------- |
| ❌ Timeout                        | Missing SSH rule in Security Group | Add inbound rule for port 22            |
| ⚠️ No auth methods available     | Didn’t attach the `.ppk` key       | Re-add the private key under SSH → Auth |
| ⛔️ Permission denied (publickey) | Wrong username                     | Use `ec2-user` (not root)               |
| 🌐 Connection refused            | Instance not running or wrong IP   | Start instance and use new Public IP    |

---

## 🧠 **Key Takeaways**

* **PuTTY** is the SSH tool for Windows 7/8.
* Always convert `.pem` → `.ppk` using **PuTTYgen**.
* Use `ec2-user` as the default login for Amazon Linux 2.
* Always check port 22 is open in your **Security Group**.
* Save your session — it saves time for future logins.












# 💻 **Connecting to EC2 Using SSH on Windows 10 (PowerShell)**

---

## 1. 🎯 **Goal**

Learn to connect (SSH) from a **Windows 10 or later** machine directly to your **EC2 instance** — without PuTTY — using **PowerShell** or **Command Prompt**.

---

## 2. 🔐 **What Is SSH?**

**SSH (Secure Shell)** lets you:

* Remotely control your EC2 Linux server through a command line.
* Run, install, or troubleshoot applications securely.
* Avoid using any GUI — all actions happen via text commands.

---

## 3. 🌍 **How It Works**

```
Your Windows 10 PC (PowerShell SSH)
   ↓ Port 22 (SSH)
Internet
   ↓
EC2 Instance (Amazon Linux 2)
Security Group → allows Port 22 inbound
```

✅ **Port 22** must be open in the **Security Group**:

```
Type: SSH | Protocol: TCP | Port Range: 22 | Source: 0.0.0.0/0
```

---

## 4. 🧩 **Check If SSH Is Available**

Open **PowerShell** or **Command Prompt** and type:

```bash
ssh
```

* If you see command help (e.g. usage options) → SSH is installed. ✅
* If not → install the Windows “OpenSSH Client” feature or use **PuTTY** (see previous lecture).

---

## 5. 📁 **Locate Your Key File**

Your key file is the `.pem` file you downloaded from AWS (e.g. `EC2Tutorial.pem`).

Steps:

1. Place it somewhere simple — e.g. `Desktop` or `C:\Users\<YourName>\aws-course`
2. In PowerShell:

   ```bash
   cd .\Desktop
   ls
   ```

   You should see your `.pem` file listed.

---

## 6. ⚙️ **Connect Using SSH**

The command format is:

```bash
ssh -i "EC2Tutorial.pem" ec2-user@<Public-IP>
```

Example:

```bash
ssh -i "EC2Tutorial.pem" ec2-user@3.94.152.11
```

Explanation:

| Part           | Meaning                                      |
| -------------- | -------------------------------------------- |
| `-i`           | Path to your private key (.pem file)         |
| `ec2-user`     | Default Linux username for Amazon Linux 2    |
| `@<Public-IP>` | The public IPv4 address of your EC2 instance |

---

## 7. ⚠️ **First-Time Connection**

You’ll see:

```
The authenticity of host ... can't be established.
Are you sure you want to continue connecting (yes/no)?
```

→ Type **yes**
✅ You are now inside your EC2 instance!

---

## 8. 🧰 **If You Get Permission Errors**

Windows sometimes restricts `.pem` file permissions, causing:

```
Permissions for 'EC2Tutorial.pem' are too open.
```

### Fixing Permissions:

1. Right-click your `.pem` file → **Properties**
2. Go to **Security** tab → **Advanced**
3. Make sure:

   * **Owner** = your Windows user account
   * Click **Change** if needed → type your username → **Check Names → OK**
4. Click **Disable inheritance** → select **Remove all inherited permissions**
5. Click **Add → Select a principal**

   * Type your username → **Check Names → OK**
   * Give yourself **Full control**
6. Apply and close all dialogs.

✅ Now only you (the owner) have access to the key — SSH will work without warnings.

---

## 9. 🧪 **Verify Connection**

Once connected, try:

```bash
whoami          # shows the current user
hostname        # shows the EC2 machine name
ping google.com # tests internet connectivity
```

Press **Ctrl + C** to stop the ping.

---

## 10. 🚪 **Exit the Session**

To disconnect:

```bash
exit
```

or press **Ctrl + D**.

---

## 11. 🧠 **Key Tips**

| Action                   | Command/Note                                  |
| ------------------------ | --------------------------------------------- |
| Check SSH installed      | `ssh` in PowerShell or CMD                    |
| Navigate to key location | `cd .\Desktop`                                |
| Connect                  | `ssh -i EC2Tutorial.pem ec2-user@<Public-IP>` |
| Fix permissions          | Change file owner + disable inheritance       |
| Exit                     | `exit` or **Ctrl + D**                        |
| Public IP changes        | If you stop/start EC2 → use new IP address    |

---

## ✅ **Summary**

* Windows 10+ has **built-in SSH** — no need for PuTTY.
* Use your **.pem key** from AWS to authenticate.
* Adjust file permissions if Windows blocks access.
* Always ensure **port 22** is open in your Security Group.














# 🌐 **Connecting to EC2 Using EC2 Instance Connect (Browser-Based SSH)**

---

## 1. 🎯 **Goal**

Learn to connect to your **Amazon EC2 instance** directly from the AWS Console —
without needing any `.pem` key, PuTTY, or terminal setup.

This method works on **Windows, Mac, and Linux** using only a web browser.

---

## 2. ⚙️ **What Is EC2 Instance Connect?**

**EC2 Instance Connect** is a **browser-based SSH client** built into AWS.

It:

* Lets you open a secure terminal session in your browser.
* Uses a **temporary SSH key** (uploaded automatically by AWS).
* Requires **no manual key management**.
* Works with **Amazon Linux 2** and **Ubuntu** instances.

---

## 3. 🧱 **How It Works**

```
Browser (AWS Console)
   ↓ HTTPS (Port 443)
AWS EC2 Instance Connect Service
   ↓ Temporary SSH key (Port 22)
EC2 Instance (Amazon Linux 2)
Security Group → must allow inbound port 22
```

✅ Behind the scenes, it still uses SSH —
so **port 22** must be open in your Security Group.

---

## 4. 🚀 **Step-by-Step: Connecting**

1. Go to **EC2 Console → Instances**
2. Select your instance (e.g. `My First Instance`)
3. Click **Connect** (top right)
4. Choose **EC2 Instance Connect (browser-based SSH)**
5. Confirm details:

   * **Instance ID**: prefilled
   * **Public IPv4 address**: visible
   * **Username**: `ec2-user` (default for Amazon Linux 2)
6. Click **Connect**

✅ Within seconds, a **new browser tab opens** — you are now inside your EC2 instance terminal!

---

## 5. 🧪 **Try Some Commands**

In the browser terminal:

```bash
whoami          # shows 'ec2-user'
hostname        # shows internal hostname
ping google.com # test connectivity
```

Press **Ctrl + C** to stop the ping.

---

## 6. 🔒 **Troubleshooting EC2 Instance Connect**

### ❌ Connection Error:

> “There was a problem connecting to your instance”

✅ **Fix: Ensure Port 22 Is Open**

1. Go to **EC2 → Security Groups**
2. Select the group attached to your instance.
3. Click **Edit inbound rules**
4. Add:

   ```
   Type: SSH | Protocol: TCP | Port Range: 22 | Source: 0.0.0.0/0
   ```
5. (Optional) Add IPv6 rule if needed:

   ```
   Type: SSH | Protocol: TCP | Port Range: 22 | Source: ::/0
   ```
6. Save changes → try connecting again.

---

## 7. 🧠 **Key Points to Remember**

* EC2 Instance Connect is **quickest** for beginners — no setup, no key downloads.
* It still relies on **SSH port 22** — inbound rules must allow access.
* It uses **temporary credentials** valid only for the session.
* If you remove the SSH rule → connection fails immediately.
* Works best for **short admin sessions or training labs**.

---

## 8. ✅ **Summary**

| Feature        | EC2 Instance Connect                  |
| -------------- | ------------------------------------- |
| Setup required | None (browser only)                   |
| SSH key needed | Temporary key handled by AWS          |
| Port required  | 22 (SSH)                              |
| Supported OS   | Amazon Linux 2, Ubuntu                |
| Security       | Uses HTTPS + ephemeral SSH key        |
| Best for       | Quick access, demos, and student labs |












# 🔐 **Using IAM Roles with EC2 Instances**

---

## 1. 🎯 **Goal**

Learn how to securely give your EC2 instance permission to access AWS services using **IAM Roles** —
**without** storing Access Keys or running `aws configure`.

---

## 2. 💡 **Why IAM Roles?**

In AWS, EC2 instances often need to access other services (like S3, DynamoDB, or IAM).
You could use AWS credentials (`Access Key` + `Secret Key`) — but that’s **unsafe**.

### ❌ Bad Practice:

Running:

```bash
aws configure
```

and entering your personal IAM user credentials exposes them to anyone with instance access.
They could retrieve keys and use them elsewhere — a major security risk.

### ✅ Correct Practice:

Use an **IAM Role** attached to the EC2 instance.
AWS automatically injects **temporary credentials** through the instance metadata service.

---

## 3. ⚙️ **How It Works**

```
EC2 Instance
   ↕
IAM Role attached
   ↕
AWS automatically provides temporary credentials
   ↕
Access to AWS services (like IAM, S3, DynamoDB)
```

✔ No keys stored
✔ Rotates automatically
✔ Least privilege by policy

---

## 4. 🧪 **Hands-On: Attach an IAM Role to EC2**

### Step 1: Connect to EC2

Use **EC2 Instance Connect** or SSH — both open a terminal inside your EC2.

In the shell, verify connection:

```bash
whoami
ping google.com
```

Then clear the screen:

```bash
clear
```

---

### Step 2: Test AWS CLI Access

Try:

```bash
aws iam list-users
```

You’ll see:

```
Unable to locate credentials. You can configure credentials by running "aws configure".
```

This confirms your instance currently has **no permissions**.

---

### Step 3: Create an IAM Role (if not already)

In AWS Console → **IAM → Roles → Create role**

1. **Trusted entity:** AWS Service
2. **Use case:** EC2
3. **Attach permissions policy:**

   * Choose `IAMReadOnlyAccess` (for demo)
4. **Name:** `DemoRoleForEC2`
5. **Create role**

---

### Step 4: Attach Role to Instance

In AWS Console:

1. Go to **EC2 → Instances**
2. Select your instance → **Actions → Security → Modify IAM Role**
3. From the dropdown, choose **DemoRoleForEC2**
4. Click **Save**

Now go to the **Security tab** of your instance —
you’ll see:

```
IAM Role: DemoRoleForEC2
```

---

### Step 5: Test Again

Back in the terminal:

```bash
aws iam list-users
```

✅ You now get a proper IAM response:

```json
{
  "Users": [
    {
      "UserName": "AdminUser",
      "Arn": "arn:aws:iam::123456789012:user/AdminUser",
      ...
    }
  ]
}
```

---

### Step 6: Remove and Re-Test

Detach the policy from your IAM role (in IAM console → Role → Permissions → Detach policy).

Then rerun:

```bash
aws iam list-users
```

❌ Now you get:

```
An error occurred (AccessDenied) when calling the ListUsers operation: User is not authorized to perform iam:ListUsers
```

✅ This proves that permissions are directly controlled by the IAM Role.

---

## 5. 🔁 **How the Role Credentials Work**

You can check the temporary credentials with:

```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

This returns your IAM role name and a short-lived credential set.
AWS automatically rotates these keys for you.

---

## 6. 🧠 **Key Takeaways**

| Concept                   | Explanation                                            |
| ------------------------- | ------------------------------------------------------ |
| IAM Role                  | Securely grants permissions to EC2 without credentials |
| Policy                    | Defines *what actions* EC2 can perform                 |
| AWS CLI                   | Automatically uses temporary role credentials          |
| Never use `aws configure` | Don’t hardcode keys on EC2                             |
| IAMReadOnlyAccess         | Safe policy to view IAM data                           |
| Metadata service          | Provides auto-rotated credentials to EC2               |

---

## ✅ **Summary**

* **Never use static IAM keys** inside EC2.
* Always attach an **IAM Role** to the instance.
* The role defines what AWS actions the instance can perform.
* IAM credentials are automatically provided and rotated by AWS.
* Use `aws cli` commands directly — no configuration needed.










# 💰 **EC2 Instance Purchasing Options**

---

## 1. 🎯 **Goal**

Understand how AWS offers different **pricing models** for EC2 —
each optimized for cost, flexibility, or stability — depending on workload type.

---

## 2. ⚙️ **Overview**

AWS gives you **six main purchasing options** for EC2 instances:

| Type                            | Duration      | Best For                                    | Discount (vs On-Demand) | Reliability |
| ------------------------------- | ------------- | ------------------------------------------- | ----------------------- | ----------- |
| **On-Demand**                   | Pay-as-you-go | Short, unpredictable workloads              | –                       | ⭐⭐⭐⭐⭐       |
| **Reserved Instances (RI)**     | 1 or 3 years  | Predictable, long-term workloads            | Up to 72%               | ⭐⭐⭐⭐⭐       |
| **Savings Plans**               | 1 or 3 years  | Long-term spend commitment (flexible usage) | Up to 72%               | ⭐⭐⭐⭐⭐       |
| **Spot Instances**              | Variable      | Short, flexible, fault-tolerant tasks       | Up to 90%               | ⭐⭐          |
| **Dedicated Hosts / Instances** | Long-term     | Compliance, licensing, or isolation needs   | – / Up to 70%           | ⭐⭐⭐⭐⭐       |
| **Capacity Reservations**       | Flexible      | Reserved AZ capacity without discount       | 0%                      | ⭐⭐⭐⭐        |

---

## 3. 🧩 **1️⃣ On-Demand Instances**

* Pay **per second** (Linux/Windows) or **per hour** (other OS).
* No upfront cost, no commitment.
* Highest flexibility, **highest price**.
* Perfect for:

  * Testing, proof of concept, dev environments.
  * Unpredictable workloads.

💡 **Example:**

> “Run when you want, stop when you want — like renting a car by the hour.”

---

## 4. 💡 **2️⃣ Reserved Instances (RI)**

* Commit for **1 or 3 years**.
* Save **up to 72%** compared to On-Demand.
* Fixed attributes: **instance type, region, tenancy, OS**.
* Payment options:

  * No upfront
  * Partial upfront
  * All upfront (max discount)
* Two types:

  * **Standard RI** → fixed configuration
  * **Convertible RI** → change family, OS, or size (discount ~66%)
* Can **buy/sell on AWS RI Marketplace**.

✅ **Use for:**
Steady workloads like databases, web servers, or ERP systems.

---

## 5. 💸 **3️⃣ Savings Plans**

* Modern alternative to RI.
* Commit to **spend a fixed $/hour** (e.g., $10/hour for 3 years).
* AWS automatically applies discount to matching compute usage.
* Flexibility:

  * Any instance size in same family.
  * Switch between Linux ↔ Windows.
  * Works with EC2, Fargate, Lambda.

✅ **Use for:**
Dynamic environments where workload changes but total spend is predictable.

💡 **Analogy:**

> “You commit to spending $300 per month at a hotel — you can change rooms anytime.”

---

## 6. ⚡ **4️⃣ Spot Instances**

* Up to **90% cheaper** than On-Demand.
* AWS reclaims instances anytime with a **2-minute warning**.
* Ideal for workloads tolerant to interruptions:

  * Batch jobs, rendering, data analysis, CI/CD runners, machine learning training.
* Not suited for:

  * Databases or critical systems.

💡 **Analogy:**

> “Like last-minute hotel deals — super cheap, but you might get kicked out anytime.”

---

## 7. 🏠 **5️⃣ Dedicated Hosts & Dedicated Instances**

### **Dedicated Host**

* Physical server **fully reserved** for your account.
* Visibility into **underlying sockets, cores, VMs**.
* Use for:

  * **Bring Your Own License (BYOL)** software (Oracle, SQL Server, etc.).
  * **Compliance or regulatory** isolation needs.
* Billed **per host**, can be reserved 1 or 3 years.

### **Dedicated Instance**

* Runs on hardware **dedicated to you**, but AWS manages placement.
* You don’t see or control the physical server.
* Slightly cheaper than Dedicated Host.

💡 **Difference:**

| Feature                  | Dedicated Instance | Dedicated Host |
| ------------------------ | ------------------ | -------------- |
| Control over placement   | ❌                  | ✅              |
| Hardware visibility      | ❌                  | ✅              |
| Licensing (BYOL) support | ❌                  | ✅              |
| Cost                     | Lower              | Higher         |

---

## 8. 🧱 **6️⃣ Capacity Reservations**

* Reserve capacity in a specific **Availability Zone (AZ)**.
* No discount — billed at On-Demand rate.
* Guarantees instance availability even during high demand.
* Can be canceled anytime.

✅ **Use for:**

* Mission-critical workloads that must always launch.
* Short-term events or DR (disaster recovery) readiness.

💡 **Analogy:**

> “You book a hotel room but pay even if you don’t stay — you’re guaranteed it’s there.”

---

## 9. 🧮 **Cost & Use Case Comparison**

| Option               | Duration | Commitment       | Discount  | Suitable For                   | Risk of Interruption |
| -------------------- | -------- | ---------------- | --------- | ------------------------------ | -------------------- |
| On-Demand            | None     | None             | –         | Short, unpredictable workloads | ❌                    |
| Reserved Instance    | 1–3 yrs  | Fixed            | Up to 72% | Steady usage                   | ❌                    |
| Savings Plan         | 1–3 yrs  | Spend commitment | Up to 72% | Flexible long-term             | ❌                    |
| Spot Instance        | None     | Variable         | Up to 90% | Short, interruptible           | ✅                    |
| Dedicated Host       | 1–3 yrs  | Fixed            | –         | Compliance, BYOL               | ❌                    |
| Capacity Reservation | Any      | None             | 0%        | Guaranteed capacity            | ❌                    |

---

## 10. 🏨 **Hotel Analogy (Easiest to Remember)**

| Option                   | Analogy                     | Description                                  |
| ------------------------ | --------------------------- | -------------------------------------------- |
| **On-Demand**            | Walk-in guest               | Pay full price, come and go anytime          |
| **Reserved Instance**    | Long-term resident          | Pay less for committing to stay longer       |
| **Savings Plan**         | Monthly membership          | Spend fixed $ each month, flexible room type |
| **Spot Instance**        | Last-minute deal            | Cheap, but may lose your room anytime        |
| **Dedicated Host**       | Rent the whole hotel        | Full control, private property               |
| **Capacity Reservation** | Reserve a room just in case | Pay even if you don’t use it                 |

---

## 11. 🧠 **Exam & Interview Tips**

* ❗**On-Demand** → short, unpredictable, no commitment.
* 💡**Reserved Instance** → predictable workloads (DBs, web apps).
* 💰**Savings Plan** → flexible workloads, commit to spend.
* ⚙️**Spot** → batch, ML, non-critical compute.
* 🧾**Dedicated Host** → compliance or BYOL licensing.
* 🧩**Capacity Reservation** → guaranteed AZ availability.

---

## ✅ **Summary**

| Feature              | Optimized For          | Example            |
| -------------------- | ---------------------- | ------------------ |
| On-Demand            | Flexibility            | Dev/test, startups |
| Reserved             | Predictability         | Databases          |
| Savings Plan         | Spending control       | Constant EC2 usage |
| Spot                 | Cost savings           | Batch, analytics   |
| Dedicated Host       | Compliance & licenses  | Oracle workloads   |
| Capacity Reservation | Availability guarantee | Disaster recovery  |












# ⚡ **Deep Dive: EC2 Spot Instances**

---

## 1. 🎯 **Goal**

Learn how **EC2 Spot Instances** work, how to use them safely, and how AWS manages interruptions, pricing, and automation for massive cost savings.

---

## 2. 💰 **Why Spot Instances?**

* **Up to 90% cheaper** than On-Demand.
* You use **unused EC2 capacity** that AWS sells at a discount.
* You must be prepared for **interruptions**.

✅ Ideal for:

* Batch jobs
* CI/CD runners
* Data analytics
* ML training
* Image/video processing
* Container clusters (ECS, EKS)

❌ Not ideal for:

* Databases
* Stateful apps
* Long-lived sessions
* Mission-critical production workloads

---

## 3. ⚙️ **How Spot Pricing Works**

### 🔸 Step 1 — You define:

```text
Max Spot Price = the most you’re willing to pay/hour
```

### 🔸 Step 2 — AWS publishes:

```text
Current Spot Price (varies by instance type & AZ)
```

### 🔸 Step 3 — If:

| Condition              | Result                                     |
| ---------------------- | ------------------------------------------ |
| Spot price ≤ Max price | ✅ Instance runs                            |
| Spot price > Max price | ⚠️ Instance interrupted (2-minute warning) |

---

## 4. ⏰ **Two-Minute Interruption Notice**

When AWS reclaims your instance, you get a **2-minute warning**.
You can:

1. **Stop the instance** → retain EBS data; restart later.
2. **Terminate the instance** → lose ephemeral data; cheaper.

💡 Choose based on workload type:

* *Stop* → stateful compute
* *Terminate* → stateless batch jobs

---

## 5. 🧱 **Spot Blocks (Fixed-Duration Instances)**

* Lock a spot instance for **1–6 hours**.
* AWS *guarantees* no interruption during that period (except in rare capacity loss).
* Cost is higher than standard Spot, but still cheaper than On-Demand.

✅ Best for predictable short jobs (e.g., nightly builds, simulations).

---

## 6. 📈 **Spot Price Behavior**

* Prices fluctuate by **Availability Zone** and **instance family**.
* Reflect **supply and demand** — not user bidding anymore (AWS sets the price).
* Typically **stable**, but may spike if capacity tightens.

💡 **Example:**
`m4.large` On-Demand: $0.10/hr
Spot average: ~$0.04/hr → **60%+ savings**

---

## 7. 🧩 **Spot Requests**

A **Spot Request** defines:

* Number of instances
* Max price
* AMI, instance type, subnet
* Duration (valid from/until)
* Request type → **One-Time** or **Persistent**

### 🔹 One-Time Request

* Launches once → fulfilled → ends automatically.
* Good for single batch jobs.

### 🔹 Persistent Request

* Stays open until canceled.
* If an instance is terminated due to price/capacity,
  AWS automatically relaunches new ones when conditions improve.

---

## 8. ❌ **How to Cancel Spot Requests Properly**

⚠️ **Order matters:**

1. **Cancel the Spot Request**
   → Prevents AWS from launching replacements.
2. **Terminate the Spot Instances**
   → Frees resources you’re billed for.

If you terminate first (without canceling),
the Spot Request sees “0 instances running” and relaunches them again.

✅ Exam Tip → Always **cancel request first**, then **terminate instances**.

---

## 9. 🚀 **Spot Fleets**

A **Spot Fleet** = group of Spot + (optional) On-Demand instances that AWS manages to meet a **target capacity** at **lowest possible cost**.

### 📦 What You Define

* Target capacity (e.g., 100 vCPUs or 10 instances)
* Multiple launch pools:

  * Different instance types
  * Different AZs
  * Different OSs
* Allocation strategy (below)

### ⚙️ **Allocation Strategies**

| Strategy                     | Description                                | Best For                             |
| ---------------------------- | ------------------------------------------ | ------------------------------------ |
| **Lowest-Price**             | Chooses the cheapest pool                  | Cost-optimized short workloads       |
| **Diversified**              | Spreads across multiple pools              | Availability-focused, long workloads |
| **Capacity-Optimized**       | Chooses pools with best capacity           | Large-scale, reliable compute        |
| **Price-Capacity-Optimized** | Balances lowest price + available capacity | 🔹 Best for most real workloads      |

✅ AWS automatically replaces lost instances to maintain capacity.

---

## 10. 🔄 **Spot Fleet vs Simple Spot Request**

| Feature                 | Spot Request | Spot Fleet                     |
| ----------------------- | ------------ | ------------------------------ |
| Single instance type    | ✅            | ❌                              |
| Multiple instance types | ❌            | ✅                              |
| Across multiple AZs     | ❌            | ✅                              |
| Includes On-Demand      | ❌            | ✅                              |
| Auto-optimization       | ❌            | ✅                              |
| Best for                | Simple job   | Cost-optimized scaling cluster |

💡 **Think of Spot Fleet** as an *intelligent manager* that keeps your compute capacity running at the lowest possible cost.

---

## 11. 💡 **Practical Examples**

| Use Case                | Best Approach                         |
| ----------------------- | ------------------------------------- |
| Hadoop/Spark batch jobs | Spot Fleet (diversified)              |
| CI/CD pipelines         | Spot Block (1–6 hrs)                  |
| ML model training       | Spot Fleet (price-capacity-optimized) |
| Web servers with ASG    | Combine On-Demand + Spot mix          |
| Databases               | Never use Spot                        |

---

## 12. 🧠 **Exam & Interview Tips**

* Spot = **cheapest** but **interruptible**.
* **2-minute warning** before termination.
* **Spot Block** = 1–6 hr fixed duration.
* **Cancel request → then terminate instances**.
* **Spot Fleet** optimizes across types, AZs, and prices.
* **Price-Capacity-Optimized** = best modern default.
* Don’t use Spot for **critical or stateful** systems.

---

## ✅ **Summary**

| Feature              | Description                   |
| -------------------- | ----------------------------- |
| Max discount         | Up to 90%                     |
| Billing unit         | Per second                    |
| Interruption notice  | 2 minutes                     |
| Typical use cases    | Batch, analytics, CI/CD       |
| Don’t use for        | Databases, critical workloads |
| Key services         | Spot Request, Spot Fleet      |
| Recommended strategy | Price-Capacity-Optimized      |













# 🚀 **All the Ways to Launch EC2 Instances**

---

## 1. 🎯 **Goal**

Understand every method AWS offers to **launch EC2 instances**, from **Spot Requests** to **Dedicated Hosts**, and when each is appropriate for cost, flexibility, or compliance.

---

## 2. ⚡ **Option 1 — Spot Requests**

### 💰 *Save up to 90% on compute costs!*

A **Spot Request** asks AWS for spare EC2 capacity at discounted pricing.

### 🧭 Steps in the Console

1. In the **EC2 Dashboard**, go to **Spot Requests**.
2. Click **Pricing history** → view past 3 months for any instance type (e.g., `c4.large`).

   * Black bar = On-Demand price.
   * Colored lines = Spot prices per AZ.
   * Typically 60–70% cheaper and quite stable.

### 🧱 Create a Spot Request

Click **Request Spot Instances** → You can either:

* Use a **Launch Template**, or
* **Manually configure** launch settings:

  * AMI (e.g., Amazon Linux 2)
  * Key pair
  * VPC/subnet
  * Security group

---

### ⚙️ **Request Details**

| Setting                        | Description                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Max Price**                  | Max hourly rate you’re willing to pay. If AWS’s Spot price rises above this, the instance is stopped or terminated. |
| **Valid From / Valid Until**   | Defines the active time window of your request.                                                                     |
| **Terminate when expired**     | Decide whether to stop instances when request expires.                                                              |
| **Load Balancer/Target Group** | (Optional) attach to ELB/ALB target group.                                                                          |

---

### 📊 **Target Capacity**

* Define how many instances or vCPUs you want.
* Choose to **maintain capacity** — AWS will automatically re-launch if any are lost.
* Interruption behavior: `terminate`, `stop`, or `hibernate`.

---

### 🌐 **Networking**

* Choose **VPC**, **subnet**, and **Availability Zone (AZ)**.
* Pick **instance types** manually (e.g., `c3.large`, `c4.large`) or define attribute filters:

  * Min/max vCPUs
  * Min/max memory
  * Architecture, virtualization type, etc.

💡 *The broader your filters → the more flexibility → the cheaper AWS can provide capacity.*

---

### 🧮 **Allocation Strategy**

| Strategy                     | Description                         | Use Case                     |
| ---------------------------- | ----------------------------------- | ---------------------------- |
| **Lowest Price**             | Choose pools with lowest Spot price | Short workloads, max savings |
| **Capacity Optimized**       | Prefer pools with highest capacity  | Large workloads              |
| **Diversified**              | Spread across multiple pools        | High availability            |
| **Price-Capacity Optimized** | Mix of cost + reliability           | ✅ Recommended for most users |

You can also maintain a **diverse pool** of instance types for resilience.

---

### 🧾 **Example**

> Target capacity: 10 instances
> Estimated fleet cost: $0.156/hr
> Savings: ~73% vs On-Demand

---

## 3. ⚡ **Option 2 — Launching Spot Instances Directly**

Instead of Spot Fleet, you can launch directly from:
**EC2 → Instances → Launch Instance → Advanced details → Request Spot Instances**

### You’ll see options:

* **Request type:** `one-time` (default) or `persistent`
* **Max price:** default = On-Demand price (can customize)
* **Interruption behavior:** `stop`, `terminate`, `hibernate`
* **Request validity:** specify start & end time

💡 *The “block duration” (1–6 hour Spot blocks) feature was deprecated after Dec 2022.*

---

## 4. 💸 **Option 3 — Reserved Instances (RI)**

Buy capacity in advance for **1 or 3 years**.

### Console Flow:

1. EC2 → **Reserved Instances**
2. Search instance type (e.g., `c5.large`)
3. Choose:

   * Term: 12 or 36 months
   * Type: Standard or Convertible
   * Payment: All Upfront / Partial / No Upfront
4. Add to Cart → View Cart → (⚠ don’t actually purchase unless needed!)

💡 **Convertible RIs** let you change instance family/OS.
**Standard RIs** are locked but cheaper.

⚠️ **Note:** RIs are slowly being replaced by **Savings Plans**.

---

## 5. 💡 **Option 4 — Savings Plans**

A **modern alternative to RIs**, committing to spend a fixed **$ per hour** over 1–3 years.

### Features

* Flexible across:

  * Instance size
  * OS
  * Region
  * Tenancy (default, dedicated, host)
* Applies to EC2, Fargate, and Lambda usage.
* Same savings as RIs (up to 72%).

✅ **Recommended** for most long-term, steady workloads.

---

## 6. 🏠 **Option 5 — Dedicated Hosts**

Get a **physical EC2 server** fully reserved for your account.

### Use Cases

* Compliance or regulatory isolation.
* BYOL (Bring Your Own License) software (Oracle, SQL Server).
* Control instance placement and underlying hardware.

### Launch Steps

1. EC2 → **Dedicated Hosts** → **Allocate Dedicated Host**
2. Select:

   * Instance family (e.g., `c5`)
   * Availability Zone
3. Click **Allocate**

⚠️ Cost is much higher — typically for enterprise or compliance workloads.

---

## 7. 🧱 **Option 6 — Capacity Reservations**

Guarantee EC2 capacity in a specific **Availability Zone (AZ)** — even if you’re not running anything yet.

### Features

* Pay **On-Demand price** (no discount).
* Reserve exact instance type & count.
* Duration: open-ended or fixed end time.
* Cancelling stops future billing, but you’re charged while reserved.

✅ Useful for:

* Disaster recovery (DR)
* Mission-critical systems
* Short-term but guaranteed compute bursts

### Example:

Reserve `4 × m5.2xlarge` in `eu-central-1a`
→ You pay even if not used, but AWS guarantees capacity exists.

---

## 8. 🧠 **Comparison Summary**

| Option                   | Pricing   | Commitment | Flexibility | Use Case                        |
| ------------------------ | --------- | ---------- | ----------- | ------------------------------- |
| **On-Demand**            | High      | None       | Very high   | Unpredictable workloads         |
| **Spot**                 | Lowest    | None       | Moderate    | Batch, analytics, non-critical  |
| **Reserved**             | Low       | 1–3 yrs    | Fixed       | Databases, web servers          |
| **Savings Plan**         | Low       | 1–3 yrs    | High        | Steady spend, variable workload |
| **Dedicated Host**       | Very high | Optional   | Low         | Licensing, compliance           |
| **Capacity Reservation** | On-Demand | None       | Moderate    | Guaranteed AZ capacity          |

---

## 9. 💡 **Exam Tips**

* **Spot Instance:** Interrupted → 2-min warning.
* **Spot Fleet:** Combines pools for lowest cost.
* **Reserved Instance:** Locked to type + region.
* **Convertible RI:** Can change instance family.
* **Savings Plan:** Commit to spend $, flexible.
* **Dedicated Host:** Physical isolation.
* **Capacity Reservation:** Pay to reserve compute in an AZ.
* **Spot Block:** Deprecated after Dec 2022.

---

## ✅ **Summary**

AWS provides **six different launch paths** for EC2:

1. Spot Request / Fleet (lowest cost)
2. Regular Launch → request Spot Instance
3. Reserved Instance
4. Savings Plan
5. Dedicated Host
6. Capacity Reservation

Each one balances **price, predictability, and flexibility** differently.


