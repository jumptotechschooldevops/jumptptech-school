---
title: "Ansible"
description: "3. What Is Ansible?   Ansible is an IT automation engine that simplifies:    Provisioning –..."
published: 2025-10-17
source: "https://dev.to/jumptotech/ansible-234i"
tags: []
---

# Ansible




## **3. What Is Ansible?**

**Ansible** is an **IT automation engine** that simplifies:

* **Provisioning** – creating infrastructure automatically.
* **Configuration management** – setting up software and systems.
* **Application deployment** – installing and updating applications.
* **Patch management** – applying updates.
* **Orchestration** – coordinating multiple systems or services.

You can automate almost **any repetitive IT operation** as long as Ansible can connect to the target via:

* SSH (Linux)
* WinRM (Windows)
* API (Cloud or network devices)

---

## **4. Why Use Ansible?**

### 1. **Simplicity**

* Uses human-readable YAML syntax.
* Playbooks can be easily understood and shared between teams.

### 2. **Powerful**

* Can manage servers, applications, networks, storage, virtualization, and cloud.

### 3. **Agentless**

* No agent installation needed on target hosts.
* Communicates through SSH, WinRM, or APIs.

---

## **5. How Ansible Works**

Ansible operates using **two main components**:

### **A. Control Node**

* The system where Ansible is installed and commands are executed.
* Contains your **project files**, **inventory**, and **playbooks**.

### **B. Managed Nodes**

* The target systems you want to configure or manage.
* Listed in your **inventory file** (can be static or dynamic).

---

## **6. Key Components**

### **Inventory**

* A list of all target nodes (servers).
* Can be grouped (e.g., `[webservers]`, `[dbservers]`).
* You can have separate inventories for `dev`, `staging`, and `prod`.

### **Playbook**

* A YAML file containing **one or more plays**.
* A play defines **what tasks** should run on **which hosts**.

### **Tasks**

* The smallest unit of work.
* Each task uses a **module** to perform an operation.

### **Modules**

* Reusable pieces of code that Ansible runs on your behalf.
* Examples: `yum`, `apt`, `user`, `copy`, `service`, etc.
* You **don’t need to write your own modules** — there are thousands available in the **Ansible community collections**.

---

## **7. Ansible Tower / AWX**

* **Ansible Tower (by Red Hat)** and **AWX (open source)** are web-based enterprise frameworks.
* They help manage, schedule, and secure Ansible automation.
* Not covered in this beginner series, but mentioned for awareness.

---

## **8. Common Use Cases**

You can use Ansible for:

* **Provisioning:** EC2, VM, storage, network creation.
* **Configuration management:** OS setup, packages, users.
* **App deployment:** Deploy web apps or microservices.
* **Continuous Delivery:** Integration with CI/CD pipelines.
* **Security & compliance:** Enforce consistent configurations.
* **Orchestration:** Manage workflows across systems.






## **2. Lab Setup Overview**

To learn Ansible effectively, you need:

* **1 Control Node** — where Ansible is installed.
* **1 or more Managed Nodes** — where Ansible executes commands.

You can build this setup:

* On your **local computer** using **VirtualBox** and multiple VMs, or
* In **cloud environments** (AWS, Azure, GCP), or
* On **on-premise servers** if available.

> For beginners, VirtualBox is enough to simulate real-world automation.

---

## **3. Control Node Requirements**

### **Definition**

A **Control Node** is the machine where you:

* Install the Ansible package.
* Store **project files**, **inventories**, and **playbooks**.
* Run automation commands.

### **Requirements**

| Requirement              | Description                                                                                                            |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| **Operating System**     | Must be **Linux or Unix-based** (e.g., Ubuntu, CentOS, Red Hat). Windows control nodes are **not supported natively**. |
| **Python**               | Python **2.6+** (or 3.x) must be installed. Ansible is written in Python and depends on it.                            |
| **Hardware**             | No special hardware needed for labs; in production, size the server based on workload and number of hosts.             |
| **Control over Targets** | The control node connects via **SSH** (for Linux) or **WinRM** (for Windows).                                          |

> Note: You **can** use a Linux control node to manage **Windows servers** through WinRM.

---

## **4. Managed Nodes Requirements**

### **Definition**

Managed nodes (or hosts) are the systems that Ansible configures and manages.
They are defined in the **inventory file** (either static or dynamic).

### **Requirements by OS Type**

#### **A. Linux Managed Nodes**

| Requirement      | Description                                                             |
| ---------------- | ----------------------------------------------------------------------- |
| **Python**       | Version **2.4+** is required for most modules.                          |
| **JSON library** | The `simplejson` package must be installed if Python < 2.5.             |
| **SELinux**      | If enabled, it must be configured properly to allow Ansible operations. |
| **Connectivity** | SSH must be enabled and reachable from the control node.                |

#### **B. Windows Managed Nodes**

| Requirement        | Description                                      |
| ------------------ | ------------------------------------------------ |
| **PowerShell**     | Version **3.0 or higher**.                       |
| **.NET Framework** | Version **4.0 or later** installed.              |
| **WinRM Listener** | Must be created and activated for communication. |
| **Connectivity**   | Control node connects via **WinRM**, not SSH.    |

---

## **5. Summary**

| Component                | Requirements                        | Notes                                   |
| ------------------------ | ----------------------------------- | --------------------------------------- |
| **Control Node**         | Linux OS, Python ≥ 2.6              | Can manage both Linux and Windows nodes |
| **Linux Managed Node**   | Python ≥ 2.4, SSH access            | Uses Ansible modules written in Python  |
| **Windows Managed Node** | PowerShell ≥ 3.0, .NET ≥ 4.0, WinRM | Requires Windows-specific modules       |








This approach allows you to:

* Simulate a **multi-node environment** (e.g., 1 control node + multiple managed nodes).
* Quickly rebuild your lab when needed — just one command.
* Work entirely on your **local machine**, without requiring cloud resources.

---

## **2. Why Use VirtualBox and Vagrant**

| Tool           | Purpose                                                        | Benefits                                                               |
| -------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **VirtualBox** | Virtualization software for creating and managing VMs locally. | Free, lightweight, cross-platform (Mac, Linux, Windows).               |
| **Vagrant**    | Automation tool for managing VM lifecycle.                     | Simplifies VM creation and configuration using a single `Vagrantfile`. |

**Advantages:**

* No dependency on AWS, Azure, or GCP.
* Can be run entirely on a laptop or desktop.
* Quick to spin up and destroy environments.
* Works identically on Mac, Windows, and Linux.

> **Note:** If you already have servers (e.g., in AWS or a data center), you can skip this setup and use those — just make sure to configure them before using Ansible.

---

## **3. Step 1: Install VirtualBox**

### **Installation Steps**

1. Download **VirtualBox** from [https://www.virtualbox.org](https://www.virtualbox.org).
2. Follow the installation wizard:

   * Accept default settings.
   * Complete installation.
3. After installation:

   * Launch VirtualBox from Applications or Start Menu.
   * You’ll see an empty VM list initially.

> The instructor used a **MacBook**, but steps are the same for **Windows** and **Linux**.

---

## **4. Step 2: Install Vagrant**

### **Installation Methods**

* **macOS:**

  ```bash
  brew install vagrant
  ```
* **Windows/Linux:**
  Download the package from [https://www.vagrantup.com/downloads](https://www.vagrantup.com/downloads) and install manually.

### **Verify Installation**

Run the following command to confirm:

```bash
vagrant -v
```

Example output:

```
Vagrant 2.4.1
```

At this point, you should have:

* ✅ VirtualBox installed
* ✅ Vagrant installed
* 🖥️ No virtual machines yet created

---

## **5. Step 3: Test Vagrant + VirtualBox Integration**

We’ll test whether everything works correctly by creating a **demo VM**.

### **Create a Working Directory**

```bash
mkdir demo-lab
cd demo-lab
```

### **Initialize a Vagrant Environment**

```bash
vagrant init centos/8
```

This command:

* Creates a default **`Vagrantfile`** inside your directory.
* Defines the base image (CentOS 8 in this case).

You can open the file to review its configuration.

---

## **6. Step 4: Launch the Virtual Machine**

Run:

```bash
vagrant up
```

What happens:

* Vagrant automatically uses **VirtualBox** as the provider.
* It downloads the CentOS 8 image if not already cached.
* It creates and boots up a new VM.

You can check the VM in VirtualBox:

* You’ll see a new running machine (headless by default).
* If you want to see its window, click **Show** in VirtualBox.

---

## **7. Step 5: Connect to the VM**

Once running, connect via SSH:

```bash
vagrant ssh
```

Inside the VM, test with:

```bash
hostname
uptime
```

If these commands work, your environment is ready!

---

## **8. Step 6: Manage the VM**

Common commands:

| Command           | Description                       |
| ----------------- | --------------------------------- |
| `vagrant up`      | Start and create VMs.             |
| `vagrant halt`    | Stop VMs gracefully.              |
| `vagrant destroy` | Delete all VMs and reset the lab. |
| `vagrant ssh`     | Connect to the VM shell.          |
| `vagrant status`  | Check the status of all VMs.      |

---

## **9. Summary**

| Tool              | Function                | Verification                                 |
| ----------------- | ----------------------- | -------------------------------------------- |
| VirtualBox        | Virtualization platform | Launch GUI and confirm it’s running          |
| Vagrant           | VM automation tool      | Run `vagrant -v`                             |
| CentOS/Ubuntu VMs | Practice nodes          | Create using `vagrant init` and `vagrant up` |

After completing this setup, your system is ready to **create a full Ansible lab** in the next lesson.










# ** Building an Immutable Ansible Lab (Hands-On Setup)**



## **2. What Is an Immutable Lab?**

An **immutable lab** means:

* You can **recreate the environment anytime** with the same configuration.
* You don’t keep any manual configurations or files inside the VMs.
* All your scripts and playbooks are stored in **Git** (e.g., GitHub, GitLab, Bitbucket).
* If something breaks, simply run `vagrant destroy` and `vagrant up` to rebuild everything from scratch.

> The goal is to focus on **learning Ansible**, not fixing lab setups.

---

## **3. Tools Used**

| Tool           | Purpose                                               |
| -------------- | ----------------------------------------------------- |
| **VirtualBox** | Virtualization platform to host multiple VMs locally. |
| **Vagrant**    | Automates VM provisioning and configuration.          |
| **Git**        | Stores playbooks, Vagrantfiles, and configurations.   |

---

## **4. Lab Components**

The lab will automatically create:

* **1 Control Node** – where Ansible is installed (the “Ansible Engine”).
* **2 Managed Nodes** – servers that Ansible manages.

> You can modify the number of managed nodes in the `Vagrantfile`.

---

## **5. Step 1: Clone the Git Repository**

The instructor provides a Git repo that contains preconfigured **Vagrantfiles** for different use cases.

Example:

```bash
git clone https://github.com/<author>/vagrant-demos.git
```

Navigate into the Ansible lab folder:

```bash
cd vagrant-demos/ansible-lab
```

Inside, you’ll find:

* A **`Vagrantfile`**
* Sample **playbooks** and **provisioning scripts**

---

## **6. Step 2: Edit the Vagrantfile**

Open and modify the file:

```bash
vim Vagrantfile
```

Look for the section that defines the number of managed nodes:

```ruby
ANSIBLE_NODES = 0
```

Change it to:

```ruby
ANSIBLE_NODES = 2
```

This will create:

* `ansible-engine` (control node)
* `ansible-node1`
* `ansible-node2`

---

## **7. Step 3: Create the Lab**

Run:

```bash
vagrant up
```

This command:

* Creates the control and managed nodes.
* Automatically configures **IP addresses**, **hostnames**, **CPU/memory**, and **SSH access**.
* Provisions each VM using built-in scripts.

---

## **8. Step 4: Behind the Scenes**

The **Vagrantfile** handles:

* Automatic network configuration.
* Resource allocation (CPU, memory).
* Initial provisioning commands:

  * Installs **Ansible** on the control node.
  * Enables **password authentication**.
  * Restarts SSH service.
  * Copies a sample **inventory file**.
  * Installs common tools like `git`.

Example provisioning snippet:

```bash
sudo yum install -y git
sudo systemctl enable sshd --now
```

---

## **9. Step 5: Verify the Setup**

After provisioning completes, check VM status:

```bash
vagrant status
```

Example output:

```
ansible-engine     running (virtualbox)
ansible-node1      running (virtualbox)
ansible-node2      running (virtualbox)
```

---

## **10. Step 6: Access the Control Node**

Log in via SSH:

```bash
vagrant ssh ansible-engine
```

Check that Ansible is installed:

```bash
ansible --version
```

Expected output:

```
ansible [core 2.x.x]
```

> ✅ You now have a working Ansible environment with preinstalled Ansible and connected managed nodes.

---

## **11. Step 7: Manage the Lab**

| Command                 | Description                                      |
| ----------------------- | ------------------------------------------------ |
| `vagrant halt`          | Stops all virtual machines but keeps them saved. |
| `vagrant up`            | Starts or recreates all machines.                |
| `vagrant destroy -f`    | Destroys all VMs completely.                     |
| `vagrant ssh <vm_name>` | Connects to a specific VM shell.                 |

Example:

```bash
vagrant halt
vagrant status
```

Output:

```
all machines are powered off
```

---

## **12. Advantages of This Setup**

* **Reproducible:** Same environment each time you rebuild.
* **Portable:** Works on any OS supporting VirtualBox + Vagrant.
* **Resettable:** If you break something, simply rebuild in minutes.
* **Version-controlled:** All configurations stored in Git.
* **Multi-node ready:** Ideal for Ansible, Kubernetes, or CI/CD practice.









# ** Creating an Ansible Lab on AWS Cloud (Free Tier)**



## **2. Why Use AWS for Ansible Labs**

* AWS Free Tier provides enough credits for hands-on Ansible practice.
* Cloud setup lets you access your lab **remotely from any device**.
* You’ll gain additional experience with **cloud infrastructure**, which complements DevOps learning.

> You can use **AWS**, **GCP**, or **Azure**, but this tutorial focuses on AWS.

---

## **3. Step 1: Create an AWS Free Tier Account**

1. Go to [https://aws.amazon.com/free](https://aws.amazon.com/free)
2. Sign up using:

   * Email, password, username
   * Credit/debit card (for verification only — no charges if within Free Tier limits)
3. Log in to **AWS Management Console**.
4. Go to the **EC2 service** — the Elastic Compute Cloud.

---

## **4. Step 2: Launch EC2 Instances**

We’ll create **three instances**:

* 1 × **Ansible Engine** (Control Node)
* 2 × **Managed Nodes**

### **Steps:**

1. Open **EC2 → Instances → Launch Instance**.
2. Choose:

   * **Amazon Linux 2 AMI** (Free Tier eligible)
   * **t2.micro** instance type (Free Tier)
3. Leave default VPC and subnet.
4. (Optional) Add tags:

   * `Name: ansible-engine`, `ansible-node1`, `ansible-node2`
5. **Security Group** → Create new:

   * Allow:

     * SSH (port 22)
     * HTTP (port 80)
     * ICMP (ping)
     * HTTPS (port 443, optional)
6. **Key Pair:**

   * Create new key pair (e.g., `ansible-lab-demo.pem`)
   * Download and store securely (`~/.ssh/ansible-lab-demo.pem`)

Click **Launch Instance**.

---

## **5. Step 3: Rename Instances**

After launch, go to your EC2 dashboard → Rename:

* `ansible-engine`
* `ansible-node1`
* `ansible-node2`

This helps you identify them easily.

---

## **6. Step 4: Connect to Instances via SSH**

### **On Mac/Linux Terminal:**

```bash
chmod 600 ~/.ssh/ansible-lab-demo.pem
ssh -i ~/.ssh/ansible-lab-demo.pem ec2-user@<public-ip>
```

> Replace `<public-ip>` with each instance’s public IP address.

---

## **7. Step 5: Configure Managed Nodes (node1, node2)**

On each node:

```bash
# Set hostname
sudo hostnamectl set-hostname ansible-node1

# Create user for Ansible
sudo useradd devops
sudo passwd devops

# Enable password authentication
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Give sudo access (no password)
echo "devops ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/devops
```

Repeat for **ansible-node2**.

---

## **8. Step 6: Configure Control Node (ansible-engine)**

### **Set Hostname**

```bash
sudo hostnamectl set-hostname ansible-engine
```

### **Install Python and Ansible**

```bash
sudo amazon-linux-extras install epel -y
sudo yum install ansible -y
ansible --version
```

Expected output:

```
ansible 2.9.x
python 2.7.x
```

---

## **9. Step 7: Configure Inventory and Ansible Settings**

### **Create Working Directory**

```bash
mkdir ~/ansible-demo && cd ~/ansible-demo
```

### **Create Configuration File**

```bash
vim ansible.cfg
```

```ini
[defaults]
inventory = ./inventory
remote_user = devops
```

### **Create Inventory File**

```bash
vim inventory
```

Example:

```ini
[engine]
ansible-engine ansible_connection=local

[nodes]
node1 ansible_host=<private-ip-node1>
node2 ansible_host=<private-ip-node2>
```

> Use **private IPs** because they don’t change when you stop/start instances.

---

## **10. Step 8: Set Up SSH Key-Based Access**

On the **Ansible Engine**:

```bash
ssh-keygen
ssh-copy-id devops@node1
ssh-copy-id devops@node2
```

Now verify:

```bash
ssh devops@node1
ssh devops@node2
```

→ Both should connect **without a password**.

---

## **11. Step 9: Test Ansible Connectivity**

```bash
ansible all --list-hosts
ansible nodes -m ping
```

Expected:

```
node1 | SUCCESS => pong
node2 | SUCCESS => pong
```

Test a command:

```bash
ansible nodes -m shell -a "hostnamectl"
```

Output:

```
node1 | SUCCESS | rc=0 >>
ansible-node1
node2 | SUCCESS | rc=0 >>
ansible-node2
```

✅ Your Ansible Lab is fully functional.

---

## **12. Step 10: Managing AWS Lab Instances**

To **stop instances** (avoid charges):

* In EC2 console: **Actions → Instance State → Stop**

To **restart later:**

* Use **Start**
* Note: Public IPs will change each time you start the instance.

To **delete permanently:**

* Use **Terminate**

---

## **13. Step 11: Terraform Alternative**

All these manual steps can be automated using **Terraform**:

* `terraform apply` will:

  * Create 3 EC2 instances
  * Configure networking and SSH
  * Install Ansible automatically
* Recommended once you are comfortable with AWS basics.

---

## **14. Summary**

| Component     | Purpose              | Key Tool/Command        |
| ------------- | -------------------- | ----------------------- |
| Control Node  | Runs Ansible engine  | `yum install ansible`   |
| Managed Nodes | Target servers       | `useradd devops`        |
| SSH Setup     | Secure connection    | `ssh-copy-id`           |
| Inventory     | List of targets      | `inventory` file        |
| Test          | Verify setup         | `ansible nodes -m ping` |
| Manage        | Stop/start/terminate | AWS Console             |

---

## **15. Key Takeaways**

* AWS Free Tier is perfect for practicing Ansible in the cloud.
* Use **private IPs** inside the inventory to avoid IP changes.
* Always **stop** instances after each session.
* Push all playbooks and configurations to **GitHub** for reusability.
* Once confident, switch to **Terraform** for IaC automation.















# ** Create an Ansible Lab in AWS Using Terraform**


## **2. Why Use Terraform**

Terraform lets you:

* **Automate infrastructure provisioning** (EC2, Security Groups, Key Pairs, etc.).
* Maintain a **repeatable**, version-controlled lab setup.
* Save time — no need to click through the AWS console.
* Keep your lab **immutable** — rebuild from scratch anytime.

---

## **3. Prerequisites**

| Requirement                    | Description                                                                                          |
| ------------------------------ | ---------------------------------------------------------------------------------------------------- |
| **AWS Free Tier Account**      | Use `t2.micro` instances (free for ~720 hours/month).                                                |
| **Terraform Installed**        | Install from [https://developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform). |
| **AWS CLI or IAM Credentials** | Access key & secret key configured on your machine.                                                  |
| **Basic AWS Knowledge**        | IAM, EC2, Security Groups.                                                                           |

---

## **4. Step 1: Create an IAM User for Terraform**

1. In **AWS Console → IAM → Users → Create User**

   * Name: `demo-user`
   * Enable **Programmatic Access**
   * Attach **AdministratorAccess** policy (for demo simplicity)
2. Skip tags → Create user.
3. Copy:

   * **Access key ID**
   * **Secret access key**
     (⚠️ This is the only time AWS will show it.)

---

## **5. Step 2: Configure AWS Credentials on Your Machine**

### **Linux/Mac**

Create AWS config files manually:

```bash
mkdir ~/.aws
vim ~/.aws/credentials
```

**Example:**

```
[default]
aws_access_key_id = <YOUR_ACCESS_KEY>
aws_secret_access_key = <YOUR_SECRET_KEY>
```

Then create `~/.aws/config`:

```
[default]
region = us-east-1
output = json
```

Now Terraform can connect to your AWS account automatically.

---

## **6. Step 3: Terraform Project Structure**

Create a working directory:

```bash
mkdir aws-ansible-lab && cd aws-ansible-lab
```

### **Files:**

```
main.tf
variables.tf
outputs.tf
engine-config.yml
```

---

## **7. Step 4: main.tf Overview**

This is the heart of the setup. It defines:

* **AWS provider** credentials
* **Key pair creation**
* **Security group** (SSH, HTTP, ICMP)
* **3 EC2 instances:**

  * `ansible-engine`
  * `ansible-node1`
  * `ansible-node2`
* **Provisioners** that:

  * Install Ansible on the engine
  * Configure SSH keys
  * Generate inventory and ansible.cfg automatically

### **Simplified Structure**

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "ansible_key" {
  key_name   = "ansible-lab-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ansible_sg" {
  name = "ansible_lab_sg"
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_engine" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ansible_key.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  tags = { Name = "ansible-engine" }

  provisioner "file" {
    source      = "engine-config.yml"
    destination = "/home/ec2-user/engine-config.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y ansible",
      "sudo hostnamectl set-hostname ansible-engine"
    ]
  }
}

resource "aws_instance" "ansible_nodes" {
  count = 2
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ansible_key.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  tags = { Name = "ansible-node-${count.index + 1}" }
}
```

---

## **8. Step 5: Variables and Outputs**

### **variables.tf**

```hcl
variable "ami" {
  default = "ami-0c02fb55956c7d316" # Amazon Linux 2
}
```

### **outputs.tf**

```hcl
output "engine_public_ip" {
  value = aws_instance.ansible_engine.public_ip
}
output "node_private_ips" {
  value = aws_instance.ansible_nodes[*].private_ip
}
```

---

## **9. Step 6: Initialize and Apply Terraform**

```bash
terraform init
terraform plan
terraform apply
```

Type **`yes`** when prompted.

Terraform will:

* Create 1 control node and 2 managed nodes.
* Install Ansible automatically.
* Configure the inventory and `ansible.cfg`.
* Generate SSH keys for `devops` user.
* Copy configuration files into `/home/ec2-user/`.

---

## **10. Step 7: Verify the Lab**

### **Connect to Control Node**

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<engine-public-ip>
```

### **Check Files**

```bash
ls
cat inventory
cat ansible.cfg
```

Expected inventory sample:

```
[engine]
ansible-engine ansible_connection=local

[nodes]
node1 ansible_host=10.0.1.10
node2 ansible_host=10.0.1.11
```

### **Test Connectivity**

```bash
ansible all -m ping
```

Expected result:

```
node1 | SUCCESS => pong
node2 | SUCCESS => pong
```

✅ Your AWS Ansible lab is now live.

---

## **11. Step 8: Managing Playbooks**

Best practice:

* Clone your **GitHub repo** into `/home/ec2-user/`:

  ```bash
  git clone https://github.com/<your-repo>/ansible-playbooks.git
  ```
* Edit playbooks, test, and push back to GitHub.
* Do not store work locally — lab is **immutable**.

---

## **12. Step 9: Destroying the Lab**

When done, **destroy all resources** to stay within free tier:

```bash
terraform destroy
```

Terraform will:

* Terminate EC2 instances.
* Delete security groups, volumes, and keys.

Always confirm destruction:

```
Apply complete! Resources: 3 destroyed.
```

---

## **13. Key Benefits**

| Feature         | Manual Setup     | Terraform Setup       |
| --------------- | ---------------- | --------------------- |
| Speed           | 30–45 minutes    | 3–5 minutes           |
| Repeatability   | Error-prone      | Consistent every time |
| Rebuild         | Manual           | `terraform apply`     |
| Cleanup         | Manual deletions | `terraform destroy`   |
| Version Control | Limited          | Full Git integration  |

---

## **14. Key Takeaways**

* **Terraform + AWS = perfect combo** for immutable Ansible labs.
* **Focus on learning Ansible**, not creating infrastructure.
* **Always stop/destroy** resources after practice to avoid charges.
* Store **playbooks in GitHub**; labs are temporary.
* Once familiar, you can expand Terraform to create:

  * Multi-region setups
  * VPC networks
  * Jenkins/ArgoCD labs

---

## **15. Example Workflow Summary**

| Command               | Purpose                      |
| --------------------- | ---------------------------- |
| `terraform init`      | Initialize Terraform modules |
| `terraform plan`      | Preview what will be created |
| `terraform apply`     | Create Ansible lab on AWS    |
| `terraform destroy`   | Clean up the lab             |
| `ansible -m ping all` | Test node connectivity       |












# ** Installing Ansible Manually on CentOS (Control Node Setup)**

---

## **1. Overview**

This lesson explains how to **manually install and configure Ansible** on a **CentOS virtual machine** when you are **not using the automated Vagrant or Terraform-based lab setup**.

The goal is to prepare a **control node** (Ansible engine) manually for practice and playbook execution.

---

## **2. Prerequisites**

* A **CentOS** or **RHEL-based VM** (can be local, Vagrant, or cloud-based).
* **Root** or **sudo** access.
* Internet connectivity to install packages.

---

## **3. Step 1: Verify Python Installation**

Ansible requires Python (either v2 or v3).
Check if Python is already installed:

```bash
sudo yum list installed python
```

If Python 3 is missing, install it:

```bash
sudo yum install python3 -y
```

Verify the version:

```bash
python3 --version
```

Example output:

```
Python 3.9.x
```

---

## **4. Step 2: Enable EPEL Repository**

EPEL (Extra Packages for Enterprise Linux) provides additional packages not included in the default CentOS repo.

Install it:

```bash
sudo yum install epel-release -y
```

---

## **5. Step 3: Install Ansible**

Once EPEL is enabled:

```bash
sudo yum install ansible -y
```

Ansible will be downloaded and installed from the EPEL repository.

---

## **6. Step 4: Verify Installation**

Check the version to confirm successful installation:

```bash
ansible --version
```

Expected output:

```
ansible [version number]
python version = 3.x
```

---

## **7. Notes and Alternatives**

* For **Ubuntu/Debian**, use:

  ```bash
  sudo apt update
  sudo apt install ansible -y
  ```
* For **manual lab setups**, this step is required.
* If using the **Vagrant** or **Terraform** lab setups from earlier videos, Ansible is **installed automatically**, so you can skip this manual step.

---

## **8. Summary**

| Step | Command                            | Purpose                     |
| ---- | ---------------------------------- | --------------------------- |
| 1    | `sudo yum list installed python`   | Check Python installation   |
| 2    | `sudo yum install python3 -y`      | Install Python 3            |
| 3    | `sudo yum install epel-release -y` | Enable EPEL repository      |
| 4    | `sudo yum install ansible -y`      | Install Ansible             |
| 5    | `ansible --version`                | Verify Ansible installation |

---

## **9. Outcome**

✅ Your **Ansible control node** is now ready.
From here, you can:

* Configure managed nodes (inventory, SSH keys)
* Create and test Ansible playbooks








Here’s a **structured, easy-to-teach summary** of that video — ideal for your **Ansible Bootcamp slides or GitHub lab notes**:

---

# **Lecture 8: Ansible Configuration File — Locations and Precedence**

---

## **1. Overview**

Ansible relies heavily on a central configuration file — `ansible.cfg`.
This file defines **how Ansible behaves**, such as inventory path, remote user, privilege escalation, and connection options.

You can have **multiple configuration files** in different locations, but Ansible always follows a **specific order of precedence** when deciding which one to use.

---

## **2. Configuration File Locations (in order of priority)**

| Priority        | Location                                           | Description                                                              |
| --------------- | -------------------------------------------------- | ------------------------------------------------------------------------ |
| **1️⃣ Highest** | **Environment Variable** `ANSIBLE_CONFIG`          | If this variable is set, Ansible uses the config file path defined here. |
| **2️⃣**         | **Current Directory** `./ansible.cfg`              | If found in your project folder, this takes priority.                    |
| **3️⃣**         | **User’s Home Directory** `~/.ansible.cfg`         | Used if no project-level file exists.                                    |
| **4️⃣ Lowest**  | **System-wide Default** `/etc/ansible/ansible.cfg` | Global configuration applied if no other file is found.                  |

> **Summary:**
> `Environment > Project Folder > Home Directory > /etc/ansible/`

---

## **3. Key Sections in ansible.cfg**

### **[defaults]**

Defines global options:

```ini
[defaults]
inventory = ./inventory
remote_user = devops
ask_pass = false
```

* **inventory** → path to hosts file
* **remote_user** → default user for SSH connection
* **ask_pass** → whether to prompt for SSH password (set `false` if using SSH keys)

---

### **[privilege_escalation]**

Used when tasks require elevated privileges:

```ini
[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
```

* **become** → enable privilege escalation
* **become_method** → typically `sudo` (can also be `su`, `pbrun`, etc.)
* **become_user** → target user after privilege escalation
* **become_ask_pass** → prompt for sudo password if required

---

## **4. Checking Which Configuration File Is Active**

Run:

```bash
ansible --version
```

Output example:

```
ansible [core 2.16.2]
  config file = /home/ec2-user/ansible.cfg
```

This line shows which configuration file Ansible is currently using.

---

## **5. Demonstration Recap**

* If `ansible.cfg` exists in the **current directory**, Ansible will use it.
* If you **move it** away, Ansible will fall back to the **next available location**.
* Best practice:

  * Keep a **project-specific ansible.cfg** inside your playbook directory.
  * Customize inventory paths, connection options, and users here.

---

## **6. Best Practices**

✅ Always have one `ansible.cfg` per project folder.
✅ Define inventory, user, and privilege options clearly.
✅ Avoid editing the global `/etc/ansible/ansible.cfg` unless you manage system-wide setups.
✅ Use environment variables only for temporary overrides.

---

## **7. Example Project Structure**

```
project/
├── ansible.cfg
├── inventory
├── playbook.yml
└── roles/
```

---

## **8. Summary**

| Concept                | Key Idea                                     |
| ---------------------- | -------------------------------------------- |
| **Configuration File** | Controls Ansible behavior                    |
| **Precedence Order**   | ENV → Current Dir → Home → /etc/ansible      |
| **Privileges**         | `become` for sudo/su/root execution          |
| **Verification**       | Use `ansible --version` to see active config |
| **Best Practice**      | Keep project-specific configs                |









# ** Understanding Ansible Inventory**

---

## **1. What is an Inventory?**

An **Ansible inventory** is a simple **text file** that defines **which hosts** Ansible should manage and **how they are grouped**.

* It tells Ansible **where to connect**.
* It can be written in **INI** or **YAML** format.
* The **default location** is:

  ```
  /etc/ansible/hosts
  ```

You can override it by:

* Defining another file in `ansible.cfg`
* Or specifying it directly with:

  ```bash
  ansible -i myinventory all -m ping
  ```

---

## **2. Creating a Basic Inventory**

Let’s create a project directory and our first inventory file.

```bash
mkdir inventory-demo
cd inventory-demo
vim myinventory
```

**Example:**

```ini
[localhost]
127.0.0.1

[webservers]
serverA
serverB
serverC

[databases]
db1
db2
db3
```

✅ **Explanation:**

* `[groupname]` defines a **host group**.
* Each host can be listed by **name** or **IP address**.
* You can have multiple groups like `webservers`, `databases`, etc.

---

## **3. Checking the Inventory**

Use Ansible’s built-in command to check hosts from your inventory:

```bash
ansible all -i myinventory --list-hosts
```

Output:

```
  hosts (7):
    127.0.0.1
    serverA
    serverB
    serverC
    db1
    db2
    db3
```

You can list hosts of a specific group:

```bash
ansible webservers -i myinventory --list-hosts
```

---

## **4. Creating Parent/Child Groups**

You can **group groups** together to organize larger environments.

**Example:**

```ini
[webservers]
serverA
serverB

[databases]
db1
db2

[servers:children]
webservers
databases
```

Now when you run:

```bash
ansible servers -i myinventory --list-hosts
```

you’ll see all hosts from both `webservers` and `databases`.

---

## **5. Using Patterns to Match Hosts**

You can use **wildcards or patterns** to target hosts dynamically.

**Examples:**

```bash
ansible db* -i myinventory --list-hosts       # All starting with "db"
ansible serverA -i myinventory --list-hosts   # Specific host
ansible local* -i myinventory --list-hosts    # All starting with "local"
```

---

## **6. Host Range Patterns**

To simplify large environments, use range or sequence patterns.

**Example:**

```ini
[manyservers]
db[a:f].example.com
192.168.0.[10:20]
```

When listed, Ansible expands:

```
dba.example.com
dbb.example.com
dbc.example.com
...
192.168.0.10 → 192.168.0.20
```

✅ This saves time and avoids manually adding each entry.

---

## **7. Static vs Dynamic Inventory**

| Type                  | Description                                          | Example                               |
| --------------------- | ---------------------------------------------------- | ------------------------------------- |
| **Static Inventory**  | Defined manually in text files (`.ini` or `.yml`)    | `/etc/ansible/hosts` or `myinventory` |
| **Dynamic Inventory** | Populated automatically using a **script or plugin** | AWS, Azure, Docker, OpenShift, VMware |

**Static Example:**

```ini
[webservers]
server1
server2
```

**Dynamic Example:**

* Use a script (e.g. `aws_ec2.yaml`, `docker.py`, `gcp_compute.yml`)
* Ansible queries cloud APIs to fetch current host data.

> Example dynamic inventory sources available on GitHub:
>
> * `aws_ec2.yml` (AWS)
> * `azure_rm.yml` (Azure)
> * `openstack.py`
> * `docker.py`
> * `k8s.yaml`

---

## **8. Setting Inventory in ansible.cfg**

Instead of typing `-i` every time, specify the inventory file in your configuration.

Create or edit `ansible.cfg`:

```ini
[defaults]
inventory = ./myinventory
```

Now you can run commands without `-i`:

```bash
ansible all --list-hosts
```

---

## **9. Summary of Key Commands**

| Command                                   | Description                                  |
| ----------------------------------------- | -------------------------------------------- |
| `ansible all --list-hosts`                | Lists all hosts                              |
| `ansible groupname --list-hosts`          | Lists specific group                         |
| `ansible -i myinventory all -m ping`      | Tests connectivity using specified inventory |
| `ansible-inventory --graph`               | Displays inventory as a hierarchy            |
| `ansible-inventory -i myinventory --list` | Shows full inventory details in JSON         |

---

## **10. Key Takeaways**

✅ Inventory is the **starting point** for every Ansible task.
✅ Always keep inventories **organized by groups and environments**.
✅ Use **patterns and ranges** for scalability.
✅ For cloud or container environments, prefer **dynamic inventories**.
✅ Define inventory path in **ansible.cfg** for convenience.











# ** Ansible Ad-Hoc Commands**

---

## **1. Overview**

**Ad-Hoc commands** are **one-line Ansible commands** used to perform **quick tasks** across one or more managed nodes **without writing a playbook**.
They’re perfect for **testing modules, troubleshooting, or verifying connectivity**.

**Syntax:**

```bash
ansible <host-pattern> -m <module> -a "<arguments>"
```

---

## **2. Preparing for Ad-Hoc Commands**

### **Lab Setup**

* One **Ansible control node** and at least **two managed nodes**.
* Configure passwordless SSH access (below).

### **SSH Key Authentication Setup**

1. **Generate a new key pair**

   ```bash
   ssh-keygen
   ```

   *(Press Enter for defaults; no passphrase needed.)*

2. **Copy the public key to each managed node**

   ```bash
   ssh-copy-id node1
   ssh-copy-id node2
   ```

3. **Verify access**

   ```bash
   ssh node1
   ssh node2
   ```

   ✅ You should be logged in without a password prompt.

> ⚠️ Do not overwrite existing SSH keys; use unique names if other keys exist.

---

## **3. Create Project for Ad-Hoc Demo**

```bash
mkdir ad-hoc-demo
cd ad-hoc-demo
```

**ansible.cfg**

```ini
[defaults]
inventory = ./inventory
remote_user = vagrant
```

**inventory**

```ini
[nodes]
node1
node2
```

Check:

```bash
ansible all --list-hosts
```

---

## **4. Common Ad-Hoc Commands**

### **1️⃣ Test Connectivity**

```bash
ansible all -m ping
```

* This is not a network ping; it logs into each host and returns `pong`.

---

### **2️⃣ Run Shell Commands**

```bash
ansible all -m shell -a "uptime"
ansible all -m shell -a "hostname"
ansible all -m shell -a "date"
```

---

### **3️⃣ Install Packages**

Install HTTPD on node1:

```bash
ansible node1 -b -m yum -a "name=httpd state=present"
```

Remove HTTPD:

```bash
ansible node1 -b -m yum -a "name=httpd state=absent"
```

> `-b` (or `--become`) runs commands with sudo privileges.
> Use `--become-user <username>` if you need a different privileged user.

---

### **4️⃣ Check Execution User**

```bash
ansible node1 -m shell -a "id"
ansible node1 -b -m shell -a "id"
```

* Without `-b` → runs as `vagrant`
* With `-b` → runs as `root`

---

### **5️⃣ Copy Files to Nodes**

Copy a message into `/etc/motd`:

```bash
ansible all -b -m copy -a "content='This is configured by Ansible' dest=/etc/motd mode=0755"
```

Verify on the nodes:

```bash
ansible all -m shell -a "cat /etc/motd"
```

---

## **5. Privilege Escalation Options**

| Option                         | Purpose                  |
| ------------------------------ | ------------------------ |
| `-b` / `--become`              | Run as sudo              |
| `--become-user USER`           | Switch to specific user  |
| `--ask-become-pass`            | Prompt for sudo password |
| `become=true` (in ansible.cfg) | Apply sudo globally      |

---

## **6. Practical Examples**

| Goal                | Command                                                            |
| ------------------- | ------------------------------------------------------------------ |
| Check system uptime | `ansible all -m shell -a "uptime"`                                 |
| Restart service     | `ansible webservers -b -m service -a "name=httpd state=restarted"` |
| Check disk usage    | `ansible all -m shell -a "df -h"`                                  |
| Add a user          | `ansible all -b -m user -a "name=devops state=present"`            |

---

## **7. Best Practices**

✅ Use ad-hoc commands for quick tasks, not for production automation.
✅ For repeatable tasks, create **playbooks**.
✅ Always verify SSH connectivity first (`ansible all -m ping`).
✅ Avoid storing passwords in inventory files.
✅ Use `--check` and `--diff` for safe dry-runs.

---

## **8. Summary Table**

| Concept         | Command Example                                            | Purpose              |
| --------------- | ---------------------------------------------------------- | -------------------- |
| Ping            | `ansible all -m ping`                                      | Verify connection    |
| Run command     | `ansible all -m shell -a "uptime"`                         | Quick shell check    |
| Install package | `ansible node1 -b -m yum -a "name=httpd state=present"`    | Manage packages      |
| Copy file       | `ansible all -b -m copy -a "content='...' dest=/etc/motd"` | Push configuration   |
| Privilege       | `-b`, `--become-user`                                      | Run as sudo /root    |
| Check hosts     | `ansible all --list-hosts`                                 | List target machines |














## **1. What is a Playbook?**

An **Ansible Playbook** is a **YAML file** that defines a **set of tasks (plays)** to be executed on target hosts from your **inventory**.
It is used for **automation, configuration management, and orchestration**.

### **Playbook Structure**

* **Playbook:** The entire `.yml` file
* **Play:** A section of tasks targeting specific hosts
* **Task:** A single action using a module
* **Module:** The actual code performing the task (e.g., `yum`, `service`, `copy`)

---

## **2. YAML Syntax Rules**

| Rule              | Description                          |
| ----------------- | ------------------------------------ |
| Starts with `---` | Indicates beginning of YAML document |
| Indentation       | Use **spaces only** (never tabs)     |
| Key-value pairs   | `key: value`                         |
| Lists             | Use `-` for each item                |
| Comments          | Start with `#`                       |

✅ **Tip:** Configure your `vim` or VS Code editor to auto-indent YAML files properly.

---

## **3. Basic Playbook Setup**

Create directory and configuration:

```bash
mkdir playbook-demo
cd playbook-demo
cp ../ad-hoc-demo/ansible.cfg .
```

Now create your first playbook:

```bash
vim site.yml
```

---

## **4. First Playbook – Installing HTTPD and FirewallD**

```yaml
---
- name: Install and configure HTTPD
  hosts: nodes
  become: yes

  tasks:
    - name: Install httpd and firewalld
      yum:
        name:
          - httpd
          - firewalld
        state: latest
```

Run the playbook:

```bash
ansible-playbook site.yml
```

Verify:

```bash
sudo systemctl status httpd
sudo systemctl status firewalld
```

---

## **5. Start and Enable Services**

Extend your playbook:

```yaml
    - name: Enable and start httpd
      service:
        name: httpd
        state: started
        enabled: true

    - name: Enable and start firewalld
      service:
        name: firewalld
        state: started
        enabled: true
```

Run again — Ansible is **idempotent**, so re-running doesn’t reinstall if already configured.

---

## **6. Configure Firewall for HTTP**

Add a new task:

```yaml
    - name: Open firewall port for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
```

---

## **7. Deploy Web Page Content**

Add another task:

```yaml
    - name: Copy HTML content
      copy:
        content: |
          <h1>Welcome to our website!</h1>
          <p>This page was deployed using Ansible.</p>
        dest: /var/www/html/index.html
```

Verify in browser:

```
http://node1
http://node2
```

---

## **8. Add a Second Play – Verify Website**

```yaml
- name: Test and verify web servers
  hosts: localhost
  become: no

  tasks:
    - name: Connect to the web server
      uri:
        url: http://node1
        status_code: 200
```

✅ The `uri` module checks if your web server responds successfully.

If you use a wrong host like `node3`, the task will fail with:

```
status_code: -1 (connection failed)
```

---

## **9. Final Playbook (Complete Example)**

```yaml
---
- name: Install and configure Apache web server
  hosts: nodes
  become: yes

  tasks:
    - name: Install httpd and firewalld
      yum:
        name:
          - httpd
          - firewalld
        state: latest

    - name: Enable and start httpd
      service:
        name: httpd
        state: started
        enabled: true

    - name: Enable and start firewalld
      service:
        name: firewalld
        state: started
        enabled: true

    - name: Open firewall port for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

    - name: Copy HTML content
      copy:
        content: |
          <h1>Welcome to JumpToTech Web Server</h1>
          <p>Deployed automatically using Ansible Playbook.</p>
        dest: /var/www/html/index.html

- name: Verify web server availability
  hosts: localhost
  become: no

  tasks:
    - name: Test web response
      uri:
        url: http://node1
        status_code: 200
```

---

## **10. Key Concepts Recap**

| Concept                    | Description                                  |
| -------------------------- | -------------------------------------------- |
| **Playbook**               | YAML file defining automation logic          |
| **Play**                   | Group of tasks for specific hosts            |
| **Task**                   | Action (e.g., install, copy, enable service) |
| **Module**                 | The actual code that performs actions        |
| **Idempotence**            | Safe re-runs without duplication             |
| **Handlers (next lesson)** | Triggered on change (e.g., restart service)  |

---

## **11. Best Practices**

✅ Use descriptive `name:` for every play and task.
✅ Group related tasks logically.
✅ Validate playbook with:

```bash
ansible-playbook site.yml --syntax-check
```

✅ Keep one playbook per major purpose (e.g., web, DB, security).
✅ Test in a lab before applying to production.













Here’s a **detailed, structured explanation** of that video — *“Ansible Privilege Escalation and Remote User”* — rewritten as a **teaching lecture (Lecture 12)** for your DevOps Bootcamp course.

---

# **Lecture 12 – Ansible Privilege Escalation and Remote User Configuration**

---

## **1. What is Privilege Escalation in Ansible?**

**Privilege escalation** allows Ansible to perform **administrative (root)** tasks — such as installing packages, managing services, or editing system files — even when connecting as a **non-root user** (like `vagrant` or `devops`).

It’s equivalent to running commands with:

```bash
sudo <command>
```

---

## **2. Why We Need Privilege Escalation**

Many Ansible modules require **root access**, for example:

* Installing/removing software packages (`yum`, `apt`)
* Starting or enabling system services (`service`)
* Copying files to `/etc` or `/usr` directories

Without privilege escalation, these operations will fail.

---

## **3. Enabling Privilege Escalation**

You can enable it in **three places**:

| Location                                | Example              | Effect                         |
| --------------------------------------- | -------------------- | ------------------------------ |
| **Playbook level**                      | `become: yes`        | Applies to all tasks in a play |
| **Task level**                          | Inside a single task | Applies only to that task      |
| **Configuration level (`ansible.cfg`)** | Global setting       | Applies to all playbooks       |

---

## **4. Default Configuration Parameters**

Inside `/etc/ansible/ansible.cfg` or your project’s `ansible.cfg`, you can set:

```ini
[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False
```

**Explanation:**

* `become=True`: Enables privilege escalation
* `become_method=sudo`: Default method (can also be `su`, `pbrun`, etc.)
* `become_user=root`: Target user after escalation
* `become_ask_pass=False`: Don’t ask password (requires passwordless sudo)

---

## **5. Testing Privilege Escalation**

### Example 1 – Without Privilege Escalation

```bash
ansible nodes -m yum -a "name=httpd state=absent"
```

Output:

```
FAILED! This command has to be run under the root user
```

### Example 2 – With Privilege Escalation

```bash
ansible nodes -b -m yum -a "name=httpd state=absent"
```

(`-b` or `--become` enables sudo)

✅ **Result:** Package successfully removed.

---

## **6. Adding a Remote User**

You can specify a remote user manually or in configuration:

### **Manual (CLI)**

```bash
ansible nodes -u devops -m shell -a "whoami"
```

If the user requires a password:

```bash
ansible nodes -u devops -k -m shell -a "whoami"
```

(`-k` = ask for SSH password)

---

## **7. Setting a Default Remote User**

In `ansible.cfg`:

```ini
remote_user=devops
ask_pass=True
```

Now you don’t need to specify `-u devops` or `-k` each time.

In **production**, passwords are not used — instead, use **SSH key authentication**.

---

## **8. SSH Key Authentication for a New User**

### On Control Node:

```bash
ssh-copy-id devops@node1
ssh-copy-id devops@node2
```

This copies the public key, so you no longer need to enter passwords.

Then set:

```ini
remote_user=devops
ask_pass=False
```

---

## **9. Configuring Sudo Access for the Remote User**

If you get this error:

```
Missing sudo password
```

It means the user cannot execute sudo commands.

To fix:

### Step 1: Add the user

```bash
sudo useradd devops
sudo passwd devops
```

### Step 2: Grant passwordless sudo

```bash
sudo visudo -f /etc/sudoers.d/devops
```

Add:

```
devops ALL=(ALL) NOPASSWD:ALL
```

Now test:

```bash
su - devops
sudo -i
```

✅ Should not ask for a password.

---

## **10. Verifying with Ansible**

Run:

```bash
ansible nodes -m shell -a "id"
```

Output:

```
uid=1001(devops) gid=1001(devops) groups=1001(devops),0(root)
```

Then with privilege escalation:

```bash
ansible nodes -b -m shell -a "whoami"
```

Output:

```
root
```

✅ Privilege escalation works successfully.

---

## **11. Using `become` Inside Playbooks**

Example: only one task needs root access

```yaml
- name: Example play
  hosts: nodes
  tasks:
    - name: Create a directory as normal user
      file:
        path: /tmp/devops
        state: directory

    - name: Install HTTPD as root
      become: true
      yum:
        name: httpd
        state: present
```

---

## **12. Using Privilege Escalation in Inventory File**

You can set privilege escalation per host:

```ini
[nodes]
node1 ansible_host=192.168.56.101 ansible_user=devops ansible_become=yes ansible_become_method=sudo ansible_become_user=root
```

---

## **13. Supported `become` Methods**

| Method  | Description                           |
| ------- | ------------------------------------- |
| `sudo`  | Most common (default)                 |
| `su`    | Switch user (requires password)       |
| `pbrun` | Used in enterprise privileged systems |
| `runas` | Used on Windows                       |
| `doas`  | Alternative lightweight sudo          |

You can set in config:

```ini
become_method=su
```

---

## **14. Summary**

| Concept           | Key Point                        |
| ----------------- | -------------------------------- |
| `become`          | Enables privilege escalation     |
| `remote_user`     | Default SSH user for Ansible     |
| `ask_pass`        | Prompts for password if needed   |
| `become_user`     | Target user (root by default)    |
| `ssh-copy-id`     | Sets up key-based authentication |
| `/etc/sudoers.d/` | Grants passwordless sudo access  |

---

## **15. Quick Reference Commands**

| Purpose                    | Command                                                 |
| -------------------------- | ------------------------------------------------------- |
| Run as sudo                | `ansible nodes -b -m yum -a "name=httpd state=present"` |
| Use custom user            | `ansible nodes -u devops -m shell -a "whoami"`          |
| Ask for password           | `ansible nodes -k -m shell -a "whoami"`                 |
| Check privilege escalation | `ansible nodes -b -m shell -a "whoami"`                 |

---

## **16. Best Practices**

✅ Always grant **least privilege** access.
✅ Use **SSH key-based authentication** instead of passwords.
✅ Manage sudo privileges via `/etc/sudoers.d/`.
✅ Avoid enabling `become: yes` globally unless necessary.
✅ Store credentials securely (e.g., **Ansible Vault or Tower credentials**).












# ** Configuring `vim` for Editing YAML (Ansible & Kubernetes)**

---

## **1. Why Configure `vim` for YAML?**

Ansible playbooks and Kubernetes manifests use **YAML format**, which is **very sensitive** to:

* Indentation
* Spaces
* Tabs
* Alignment

Using incorrect spacing or tab characters can **break playbooks** or cause **syntax errors**.

By default, `vim` doesn’t handle YAML indentation well.
Therefore, we configure `.vimrc` to make editing YAML easier and error-free.

---

## **2. Visual Editors vs CLI Editing**

You can use **VS Code**, **Sublime**, or **Atom** for YAML editing on desktops, but in real-world DevOps environments (servers, remote EC2s, etc.), you often work directly in the **CLI** using `vim` or `nano`.

So, you must know how to:

* Edit YAML safely inside `vim`
* Auto-indent correctly
* Avoid tabs and formatting issues

---

## **3. The Problem**

When you edit YAML in `vim` and press **Tab**, it inserts a **tab character**, not spaces.
Ansible expects **spaces only** — tabs will cause an **indentation error**.

Example of invalid YAML:

```yaml
- name: Install httpd
<TAB>yum:
<TAB><TAB>name: httpd
```

✅ Correct YAML uses spaces:

```yaml
- name: Install httpd
  yum:
    name: httpd
```

---

## **4. The Fix — Configure `.vimrc`**

You can create or edit the `.vimrc` file in your home directory:

```bash
vim ~/.vimrc
```

Add these lines:

```vim
" --- YAML and Ansible Editing Setup ---
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set number
set filetype=yaml
syntax on
```

### Explanation:

| Setting         | Description                                |
| --------------- | ------------------------------------------ |
| `autoindent`    | Continue same indentation as previous line |
| `smartindent`   | Automatically indent new lines logically   |
| `expandtab`     | Converts tabs into spaces                  |
| `tabstop=2`     | Each tab equals 2 spaces                   |
| `shiftwidth=2`  | Indent width when using `>>` or `<<`       |
| `softtabstop=2` | Number of spaces per Tab key               |
| `number`        | Show line numbers                          |
| `filetype=yaml` | Enable YAML syntax highlighting            |
| `syntax on`     | Color-codes keywords and indentation       |

---

## **5. Test Your Configuration**

Create a test YAML file:

```bash
vim test.yml
```

Inside, type:

```yaml
---
- name: Test playbook
  hosts: all
  tasks:
    - name: Check date
      command: date
```

When pressing **Tab**, it should automatically create **2 spaces** (not an actual tab).
Indentation should follow the previous level automatically.

---

## **6. Demonstration Behavior**

Before configuration:

* Pressing `Tab` inserts a real tab → ❌ YAML error
* Indentation resets to column 0 → frustrating

After configuration:

* Pressing `Tab` = 2 spaces ✅
* Indentation aligns automatically
* Syntax highlighting shows structure clearly

---

## **7. Bonus: `.vimrc` with Auto-YAML Detection**

You can automate YAML formatting by adding this conditional rule:

```vim
autocmd FileType yaml setlocal ts=2 sw=2 expandtab autoindent
```

This ensures any `.yml` or `.yaml` file will always use 2-space indentation automatically.

---

## **8. Optional Enhancements**

If you often edit Ansible files:

```vim
autocmd FileType yaml setlocal ai sw=2 ts=2 et
autocmd FileType yaml setlocal syntax=yaml
autocmd BufNewFile,BufRead *.yml,*.yaml setlocal tabstop=2 shiftwidth=2 expandtab
```

If you edit Kubernetes manifests frequently, this configuration works perfectly too.

---

## **9. Summary**

| Goal                          | Solution                             |
| ----------------------------- | ------------------------------------ |
| Avoid YAML indentation errors | Use `expandtab` and 2-space settings |
| Auto-align new lines          | Use `autoindent` and `smartindent`   |
| Easier reading                | Use `syntax on` and `set number`     |
| Permanent setup               | Save settings in `~/.vimrc`          |

---

## **10. Practice Task**

1. SSH into your Ansible control node
2. Run:

   ```bash
   vim ~/.vimrc
   ```
3. Add the full configuration above
4. Create and edit a test playbook
5. Verify:

   * Tabs become spaces
   * Indentation is consistent
   * Syntax highlighting is active









# **Configuring `vim` for YAML (Ansible & Kubernetes)**

---

## **1. Why YAML Formatting Matters**

Ansible and Kubernetes both use **YAML** files for configuration — these files are *extremely sensitive* to indentation and spacing.
If your indentation is wrong, or if you use **tabs** instead of **spaces**, your playbooks or manifests will **fail to execute**.

Examples:

❌ **Invalid YAML (contains a tab)**

```yaml
- name: Install Apache
<TAB>yum:
<TAB><TAB>name: httpd
```

✅ **Valid YAML (uses spaces)**

```yaml
- name: Install Apache
  yum:
    name: httpd
```

**Key point:** YAML uses spaces — never tabs.

---

## **2. Why We Configure `vim`**

While tools like **VS Code**, **Sublime**, or **Atom** can handle YAML formatting automatically, in real-world DevOps work:

* You often log into **Linux control nodes or EC2 servers**
* You must edit playbooks directly in the terminal
* Only **CLI editors** like `vim` or `nano` are available

So, it’s essential to configure `vim` for YAML editing.

---

## **3. The Problem**

By default, `vim`:

* Inserts real **tabs** when you press the Tab key
* Doesn’t maintain indentation automatically
* Has no syntax highlighting or line numbers

This leads to YAML errors in Ansible and Kubernetes.

---

## **4. The Solution – Configure `.vimrc`**

Your settings live inside the `.vimrc` file in your home directory.
If it doesn’t exist, create it:

```bash
vim ~/.vimrc
```

Add the following lines:

```vim
" ---------- YAML Editing Setup ----------
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set number
set syntax=on
set filetype=yaml
```

### **Explanation**

| Setting         | Description                                             |
| --------------- | ------------------------------------------------------- |
| `autoindent`    | Preserves indentation from the previous line            |
| `smartindent`   | Adjusts indentation automatically for new lines         |
| `expandtab`     | Converts tab key into spaces                            |
| `tabstop=2`     | Defines a tab as 2 spaces                               |
| `shiftwidth=2`  | Defines how many spaces are added per indentation level |
| `softtabstop=2` | Makes backspace delete 2 spaces at once                 |
| `number`        | Shows line numbers for easy debugging                   |
| `syntax=on`     | Enables color syntax highlighting                       |
| `filetype=yaml` | Enables YAML formatting rules                           |

---

## **5. Step-by-Step Demo**

1. Open a sample YAML file:

   ```bash
   vim site.yml
   ```

2. Try pressing **Enter** after a task — the cursor automatically indents correctly.

3. Press **Tab** — instead of a real tab, it inserts **2 spaces**.

4. Notice line numbers and syntax highlighting for clarity.

Before configuration:

```
- name: Install httpd
yum:
name: httpd
```

After configuration:

```
- name: Install httpd
  yum:
    name: httpd
```

✅ The indentation now stays consistent and correct.

---

## **6. Optional – Auto Configure YAML Files Only**

If you edit many file types, use **autocommands** to apply settings only for YAML:

```vim
autocmd FileType yaml setlocal ts=2 sw=2 expandtab autoindent
autocmd FileType yaml setlocal syntax=yaml
```

This ensures other file types (like `.py` or `.sh`) aren’t affected.

---

## **7. Verify Configuration**

To test if your `.vimrc` is loaded correctly:

```bash
vim --version | grep vimrc
```

Then open a `.yml` file and verify that:

* Tabs insert spaces
* Indentation continues automatically
* Line numbers and colors are visible

---

## **8. Why This Matters for DevOps**

In Ansible and Kubernetes:

* YAML indentation determines hierarchy (`play → task → module → parameters`)
* A single tab or missing space can break automation
* Configuring `vim` helps avoid human error and speeds up file editing

---

## **9. Practice Task for Students**

1. SSH into your Ansible control node
2. Create a `.vimrc` file with the settings above
3. Open `/etc/ansible/ansible.cfg` or a playbook like `site.yml`
4. Try adding new tasks and notice the indentation behavior
5. Save, exit, and verify your playbook syntax:

   ```bash
   ansible-playbook site.yml --syntax-check
   ```

---

## **10. Summary**

| Feature      | Purpose                             |
| ------------ | ----------------------------------- |
| `expandtab`  | Converts tab to spaces              |
| `autoindent` | Keeps indentation consistent        |
| `tabstop=2`  | Defines 2-space width per tab       |
| `syntax on`  | Enables highlighting                |
| `autocmd`    | Applies YAML settings automatically |

---

### **Result**

After configuration, `vim` becomes a **YAML-aware editor**, ideal for:

* Ansible playbooks (`.yml`)
* Kubernetes manifests (`.yaml`)
* Docker Compose files (`docker-compose.yml`)










# ** Exploring Ansible Modules and Using `ansible-doc`**



## **2. What Are Ansible Modules?**

* Modules are **building blocks** of Ansible playbooks.
* Each module performs one type of action (e.g., `copy`, `service`, `yum`, `user`, `file`, `ec2_instance`).
* Ansible comes with hundreds of **core modules** and thousands more as **collections** (community or vendor-provided).

When you install Ansible, it includes:

* **Core modules** → maintained by Ansible team
* **Connection plugins** → manage how Ansible connects (SSH, WinRM, etc.)
* **Become plugins** → manage privilege escalation (e.g., sudo, su)

---

## **3. How to Find Available Modules**

### **Command:**

```bash
ansible-doc -l
```

### **Description:**

* Lists all modules available in your current Ansible installation.
* Works **even offline** (no internet required).

If you haven’t installed any external collections yet, this will show only the **default modules**.

Example output:

```
archive                 Creates a compressed archive
unarchive               Extracts an archive file
yum                     Manages packages with yum
file                    Sets attributes of files, symlinks, and directories
```

---

## **4. Understanding Ansible Collections**

Modern Ansible uses **collections** to organize modules, roles, and plugins.
A collection is like a “package” of Ansible content for a specific platform or vendor.

Examples:

* `amazon.aws` – AWS-related modules
* `azure.azcollection` – Azure
* `community.general` – General-purpose modules

You can install a collection manually:

```bash
ansible-galaxy collection install amazon.aws
```

Then list its modules with:

```bash
ansible-doc -l | grep aws
```

---

## **5. Viewing Module Documentation**

To see **details, parameters, and examples** for any module, use:

```bash
ansible-doc <module_name>
```

Example:

```bash
ansible-doc archive
```

This command shows:

* Module location
* Description and usage
* Available parameters (options)
* Required or optional arguments
* Examples (ready-to-use YAML snippets)

---

## **6. Example – Viewing `archive` Module**

Command:

```bash
ansible-doc archive
```

Output shows:

```
> Module location: /usr/lib/python3.6/site-packages/ansible/modules/files/archive.py
> Options:
  path: (required) path to the files to compress
  dest: (required) path to save the archive file
```

Example:

```yaml
- name: Create archive
  archive:
    path: /tmp/logs
    dest: /tmp/logs.tar.gz
```

---

## **7. Example – Viewing `unarchive` Module**

Command:

```bash
ansible-doc unarchive
```

Output example:

```
path: /tmp/logs.tar.gz
dest: /var/www/html/
```

YAML Example:

```yaml
- name: Extract logs
  unarchive:
    src: /tmp/logs.tar.gz
    dest: /var/www/html/
    remote_src: yes
```

✅ **Tip:** Always check examples in `ansible-doc` — they’re the best templates for your playbooks.

---

## **8. Offline Documentation Use**

If your control node has **no internet access**, `ansible-doc` still works because all docs are stored **locally** under:

```
/usr/lib/python3.x/site-packages/ansible/modules/
```

So, you can explore modules offline with:

```bash
ansible-doc -l
ansible-doc <module_name>
```

---

## **9. Useful `ansible-doc` Options**

| Option | Description                                   | Example                          |
| ------ | --------------------------------------------- | -------------------------------- |
| `-l`   | List all modules                              | `ansible-doc -l`                 |
| `-s`   | Show short snippet view                       | `ansible-doc -s yum`             |
| `-t`   | Specify plugin type (like connection, become) | `ansible-doc -t connection -l`   |
| `-M`   | Specify module path manually                  | `ansible-doc -M /custom/path -l` |

Example:

```bash
ansible-doc -t become -l
```

Lists all **become plugins** (like `sudo`, `su`, etc.).

---

## **10. Checking Plugin Types**

You can explore more than modules — like **connection**, **lookup**, and **become** plugins.

### **Connection Plugins**

```bash
ansible-doc -t connection -l
```

Output might show:

```
ssh
docker
winrm
local
```

### **Become Plugins**

```bash
ansible-doc -t become -l
```

Output:

```
sudo
su
pbrun
```

### **Example – See Plugin Details**

```bash
ansible-doc -t become enable
```

Shows documentation for the “enable” privilege plugin.

---

## **11. Module Status and Support Information**

Every Ansible module is maintained by either:

* The **Ansible Core Team**
* The **Community Team**
* Or **External vendors**

To check who maintains a module and its stability level:

```bash
ansible-doc <module_name>
```

Scroll to the bottom — you’ll see:

```
Author: Ansible Core Team
Status: stable interface
```

Other possible statuses:

| Status             | Meaning                        |
| ------------------ | ------------------------------ |
| `stable interface` | Safe and production-ready      |
| `preview`          | Experimental or incomplete     |
| `deprecated`       | Will be removed soon           |
| `removed`          | Already deleted from main repo |

---

## **12. Finding Modules for Specific Technologies**

You can use keyword search to find modules:

```bash
ansible-doc -l | grep aws
ansible-doc -l | grep azure
ansible-doc -l | grep gcp
ansible-doc -l | grep vmware
```

This way, you’ll see which modules exist for your cloud platform.

---

## **13. Best Practice**

✅ Use `ansible-doc` before using any module in a playbook.
✅ Never rely on shell commands if a module exists.
✅ Always check:

* **Arguments**
* **Examples**
* **Status**
  ✅ Avoid deprecated modules — switch to newer replacements.

---

## **14. Summary**

| Topic                        | Command                               |           |
| ---------------------------- | ------------------------------------- | --------- |
| List all modules             | `ansible-doc -l`                      |           |
| View module documentation    | `ansible-doc <name>`                  |           |
| Show snippet (YAML example)  | `ansible-doc -s <name>`               |           |
| List connection plugins      | `ansible-doc -t connection -l`        |           |
| List become plugins          | `ansible-doc -t become -l`            |           |
| Search specific tech         | `ansible-doc -l                       | grep aws` |
| Check who maintains a module | Scroll bottom of `ansible-doc` output |           |

---

## **15. Hands-On Practice**

1. On your control node, run:

   ```bash
   ansible-doc -l | wc -l
   ```

   → Count how many modules you have installed.

2. Run:

   ```bash
   ansible-doc yum
   ansible-doc -s service
   ansible-doc -t connection -l
   ```

3. Create a playbook using one of the modules you just learned about.











# ** Ansible Variables and Variable Files**

---

## **1. Introduction**

In Ansible, **variables** make playbooks **dynamic**, **reusable**, and **flexible**.
Instead of hardcoding values like package names, usernames, or paths, we use variables that can be easily changed later without modifying the playbook logic.

---

## **2. What Are Variables?**

An **Ansible variable** is a placeholder that stores a value which can be reused throughout your playbook.
For example:

* Packages to install
* Users to create
* File paths or ports
* Passwords or secrets

### **Without variable:**

```yaml
- name: Install Apache
  yum:
    name: httpd
    state: present
```

### **With variable:**

```yaml
vars:
  web_package: httpd

tasks:
  - name: Install {{ web_package }}
    yum:
      name: "{{ web_package }}"
      state: present
```

Now you can change the web server by updating only one line — `web_package: nginx`.

---

## **3. Variable Naming Rules**

When defining variables in Ansible:

| ❌ Not Allowed                        | ✅ Recommended       |
| ------------------------------------ | ------------------- |
| Spaces in names                      | Use underscores `_` |
| Start with numbers                   | Use letters first   |
| Special characters except `_` or `-` | Use `_`             |
| Dots `.` in names                    | Avoid them          |

**Examples:**

```yaml
# Valid
web_server_1: nginx
router_ip_101: 192.168.0.10

# Invalid
1st_server: nginx
web.server: nginx
web server: nginx
```

---

## **4. Variable Scopes**

Variables in Ansible can exist in **three scopes**:

| Scope                | Where Defined                    | Usage Example                            |
| -------------------- | -------------------------------- | ---------------------------------------- |
| **Global**           | In `ansible.cfg` or command line | `ansible-playbook play.yml -e var=value` |
| **Play Scope**       | Inside playbook under `vars:`    | Used for one play                        |
| **Host/Group Scope** | In inventory or variable files   | Host-specific or group-specific          |

This lecture focuses on **Play scope** and **Variable files**.

---

## **5. Using Variables in a Playbook (Play Scope)**

Example playbook (`site.yml`):

```yaml
---
- name: Install and Configure Web Server
  hosts: nodes
  become: yes

  vars:
    web_package: httpd
    firewall_package: firewalld

  tasks:
    - name: Install required packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - "{{ web_package }}"
        - "{{ firewall_package }}"
```

When executed, Ansible replaces each `{{ variable_name }}` with its actual value.

---

## **6. Why Use Curly Braces?**

The double curly braces `{{ variable_name }}` tell Ansible that this is a variable that needs to be evaluated at runtime.

### Example:

```yaml
- name: Install {{ web_package }}
  yum:
    name: "{{ web_package }}"
```

**Important:**
If the variable starts at the beginning of a line, wrap it in quotes:

```yaml
msg: "{{ web_package }} installed"
```

---

## **7. Moving Variables to a Separate File**

When your playbook grows, managing all variables directly inside it becomes messy.
You can store them in a separate file.

Create a file named `vars.yml`:

```yaml
web_package: httpd
web_service: httpd
firewall_package: firewalld
firewall_service: firewalld
```

Now modify your playbook (`site.yml`):

```yaml
---
- name: Install and Configure Web Server
  hosts: nodes
  become: yes

  vars_files:
    - vars.yml

  tasks:
    - name: Install {{ web_package }}
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Enable and start {{ web_service }}
      service:
        name: "{{ web_service }}"
        state: started
        enabled: yes
```

✅ This approach makes playbooks clean and organized.

---

## **8. Including Variables Dynamically**

Instead of `vars_files`, you can include variable files dynamically using:

```yaml
tasks:
  - name: Include variables
    include_vars:
      file: vars.yml
```

This loads variables only when that task runs.

---

## **9. Running the Playbook**

Execute the playbook:

```bash
ansible-playbook site.yml
```

You’ll see:

```
TASK [Install httpd] **************************
ok: [node1]
ok: [node2]

TASK [Enable and start httpd] ****************
changed: [node1]
changed: [node2]
```

---

## **10. Summary of Variable Types**

| Type                      | Description                                    | Example                                            |
| ------------------------- | ---------------------------------------------- | -------------------------------------------------- |
| **vars**                  | Defined directly in the playbook               | `vars: web_package: httpd`                         |
| **vars_files**            | Stored in an external file                     | `vars_files: [vars.yml]`                           |
| **include_vars**          | Dynamically loaded during execution            | `include_vars: vars.yml`                           |
| **Extra vars (-e)**       | Passed from CLI                                | `ansible-playbook site.yml -e "web_package=nginx"` |
| **Facts/Registered vars** | Generated automatically or captured from tasks | `register: output`                                 |

---

## **11. Best Practices**

* Use **meaningful variable names**
* Use **underscores** for readability
* Store reusable variables in **`vars.yml`**
* Avoid hardcoding repeated values
* Use **`vars_files`** for cleaner structure

---

## **12. Hands-On Practice**

### **Step 1: Create project**

```bash
mkdir variable-demo
cd variable-demo
```

### **Step 2: Create `vars.yml`**

```yaml
web_package: httpd
web_service: httpd
firewall_package: firewalld
firewall_service: firewalld
```

### **Step 3: Create `site.yml`**

```yaml
---
- name: Variable demo playbook
  hosts: nodes
  become: yes

  vars_files:
    - vars.yml

  tasks:
    - name: Install {{ web_package }}
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Enable and start {{ web_service }}
      service:
        name: "{{ web_service }}"
        state: started
```

### **Step 4: Run playbook**

```bash
ansible-playbook site.yml
```

---

## **13. Key Takeaways**

| Concept              | Description                                     |
| -------------------- | ----------------------------------------------- |
| Variables            | Make playbooks reusable and dynamic             |
| Naming               | Use underscores `_`, no spaces or special chars |
| Scopes               | Global, Play, Host                              |
| Variable files       | Store variables separately                      |
| `vars_files`         | Include predefined variables                    |
| `include_vars`       | Load dynamically                                |
| Curly braces `{{ }}` | Used to access variables                        |

---

✅ **End Result:**
You can now manage large-scale playbooks easily by storing all dynamic data (package names, ports, users, etc.) in centralized variable files.












# ** Ansible Extra Variables (`--extra-vars` or `-e`)**



## **2. Why Use Extra Variables**

Imagine you have a playbook that installs **Apache (httpd)** using this variable:

```yaml
web_package: httpd
```

If you want to install **Nginx** instead, you would normally:

* Edit `vars.yml` or
* Modify the playbook manually

This becomes time-consuming and error-prone — especially if you share the same playbook with multiple teams or environments (dev, staging, prod).

✅ **Solution:** Use `--extra-vars (-e)` to pass new variable values during execution.

---

## **3. Example: Switching Packages Dynamically**

Let’s say your playbook (`site.yml`) uses these variables:

```yaml
---
- name: Install and configure web server
  hosts: nodes
  become: yes

  vars_files:
    - vars.yml

  tasks:
    - name: Install web package
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Enable and start web service
      service:
        name: "{{ web_service }}"
        state: started
        enabled: yes
```

Your `vars.yml` file:

```yaml
web_package: httpd
web_service: httpd
```

Now, instead of editing `vars.yml`, run the playbook like this:

```bash
ansible-playbook site.yml -e "web_package=nginx web_service=nginx"
```

### ✅ Result

* Ansible will **override** both variables.
* It installs and starts **Nginx** instead of **Apache**.
* You didn’t modify a single file.

---

## **4. Verify the Results**

You can SSH into the node and confirm:

```bash
ssh node1
sudo dnf list installed nginx
sudo systemctl status nginx
```

Output:

```
Installed Packages
nginx.x86_64 ...
Active: active (running)
```

✅ Confirmed — Nginx is installed and running.

---

## **5. How Variable Precedence Works**

Ansible follows a specific **variable precedence hierarchy** (from lowest to highest):

1. **Defaults** (lowest priority)
2. **Vars in roles**
3. **Vars in playbooks**
4. **Vars in included files**
5. **Extra vars (`-e`)** (highest priority)

That means any value you pass with `-e` will **override all others**, even if it was defined inside the playbook or in `vars.yml`.

---

## **6. Reverting to Default Behavior**

If you rerun the playbook **without** extra variables:

```bash
ansible-playbook site.yml
```

It will fall back to default values from `vars.yml`:

```
web_package: httpd
web_service: httpd
```

---

## **7. Removing Conflicting Packages**

If both Nginx and Apache are installed, they’ll conflict because both use port 80.
To fix that, remove Nginx first:

```bash
ansible nodes -m yum -a "name=nginx state=absent" -b
```

Then rerun the playbook:

```bash
ansible-playbook site.yml
```

✅ Apache (httpd) will reinstall and start normally.

---

## **8. Using Extra Vars for Ports or Other Configurations**

You can also override **port numbers, users, or paths** dynamically.

For example:

```bash
ansible-playbook site.yml -e "http_port=8080"
```

Or multiple values:

```bash
ansible-playbook site.yml -e "web_package=nginx http_port=443"
```

Then reference them in your tasks:

```yaml
firewalld:
  port: "{{ http_port }}/tcp"
  state: enabled
```

---

## **9. Overriding Host Groups Dynamically**

You can even use extra vars to **change the target hosts** dynamically instead of hardcoding `hosts: nodes` in the playbook.

Example:

```yaml
- name: Dynamic host targeting
  hosts: "{{ target }}"
  become: yes
  tasks:
    - name: Print hostname
      command: hostname
```

Run it dynamically:

```bash
ansible-playbook dynamic.yml -e "target=node1"
```

✅ Now the playbook runs **only on node1**.
You can switch to `node2`, `webservers`, or any inventory group without editing YAML.

---

## **10. Practical Scenarios for `--extra-vars`**

| Use Case                            | Example                    |
| ----------------------------------- | -------------------------- |
| Change package dynamically          | `-e "web_package=nginx"`   |
| Change environment (dev/stage/prod) | `-e "env=prod"`            |
| Set custom ports                    | `-e "http_port=8080"`      |
| Change hosts or groups              | `-e "target=webservers"`   |
| Override user credentials           | `-e "ansible_user=ubuntu"` |
| Trigger feature flags               | `-e "enable_tls=true"`     |

---

## **11. Passing JSON as Extra Vars**

You can also use JSON format for complex data:

```bash
ansible-playbook site.yml -e '{"web_package":"nginx","firewall_port":"8080"}'
```

---

## **12. Common Mistakes**

❌ Forgetting quotes:

```bash
ansible-playbook site.yml -e web_package=nginx
```

✅ Correct:

```bash
ansible-playbook site.yml -e "web_package=nginx"
```

❌ Using invalid variable names (`-e "1package=nginx"`)
✅ Use underscores and meaningful names: `-e "web_package=nginx"`

---

## **13. Summary**

| Concept               | Description                                      |
| --------------------- | ------------------------------------------------ |
| `--extra-vars` (`-e`) | Pass variables dynamically at runtime            |
| Purpose               | Override values from playbooks or vars files     |
| Format                | `-e "key=value key2=value2"`                     |
| Priority              | Highest variable precedence in Ansible           |
| Supports JSON         | `-e '{"key":"value"}'`                           |
| Use cases             | Change package, port, user, or hosts dynamically |

---

## **14. Hands-On Practice**

### **Step 1:** Run with default vars

```bash
ansible-playbook site.yml
```

### **Step 2:** Override vars for Nginx

```bash
ansible-playbook site.yml -e "web_package=nginx web_service=nginx"
```

### **Step 3:** Change target host

```bash
ansible-playbook site.yml -e "target=node1"
```

### **Step 4:** Revert to defaults

```bash
ansible nodes -m yum -a "name=nginx state=absent" -b
ansible-playbook site.yml
```

---

## **15. Key Takeaways**

* `--extra-vars` (`-e`) = Fastest way to customize playbook behavior at runtime.
* It’s ideal for **environment switching**, **testing**, or **parameterized deployments**.
* Always quote the variable string.
* Avoid editing your YAML files for every change — make them dynamic!











# ** Ansible Host and Group Variables**


## **2. Why Host and Group Variables Are Needed**

When you have:

* Different **users**, **ports**, **packages**, or **services** per host
* Different configurations for **environments** (e.g., dev, test, prod)

You can assign variables per host or per group instead of maintaining many playbooks.

---

## **3. Starting Point – Project Setup**

Your folder structure:

```
variable-demo/
├── ansible.cfg
├── inventory
├── site.yml
├── vars.yml
```

Inside **ansible.cfg**:

```ini
[defaults]
inventory = ./inventory
remote_user = devops
host_key_checking = False
```

Inside **inventory**:

```ini
[nodes]
node1
node2
localhost
```

Inside **vars.yml**:

```yaml
web_package: httpd
firewall_package: firewalld
```

Inside **site.yml**:

```yaml
---
- name: Install and configure web server
  hosts: nodes
  become: yes

  vars_files:
    - vars.yml

  tasks:
    - name: Install web package
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Enable and start service
      service:
        name: "{{ web_package }}"
        state: started
        enabled: yes
```

---

## **4. Defining Variables Inside Inventory**

You can directly define variables per host:

```ini
[nodes]
node1 ansible_user=devops
node2 ansible_user=vagrant
```

Now, when you run:

```bash
ansible nodes -m shell -a "id"
```

You’ll see:

```
node1 → devops
node2 → vagrant
```

✅ **Each host uses its own SSH user**, defined in the inventory.

---

## **5. Defining Group-Level Variables**

You can define variables for the entire group:

```ini
[nodes]
node1
node2

[nodes:vars]
ansible_user=devops
```

This means:

* Both nodes use the `devops` user.
* But if a **host variable** conflicts, host-specific values **override** group ones.

---

## **6. Variable Precedence Example**

Ansible checks variable values in a strict **order of precedence**:

| Priority | Source            | Example                         |
| -------- | ----------------- | ------------------------------- |
| 1️⃣      | Extra Vars (`-e`) | Highest priority                |
| 2️⃣      | Task vars         | Defined in task itself          |
| 3️⃣      | Host vars         | From `host_vars/` or inventory  |
| 4️⃣      | Group vars        | From `group_vars/` or inventory |
| 5️⃣      | Defaults in roles | Lowest priority                 |

So if you define:

```ini
[nodes:vars]
ansible_user=devops

node2 ansible_user=vagrant
```

Node2 will use **vagrant**, because host vars have higher precedence.

---

## **7. Moving Variables into Organized Files**

Instead of cluttering the inventory file, use dedicated directories:

```bash
mkdir group_vars
mkdir host_vars
```

New structure:

```
variable-demo/
├── ansible.cfg
├── inventory
├── site.yml
├── group_vars/
│   └── nodes.yml
├── host_vars/
│   ├── node1.yml
│   └── node2.yml
```

---

## **8. Defining Group Variables**

Inside **group_vars/nodes.yml**:

```yaml
web_package: httpd
web_service: httpd
firewall_package: firewalld
firewall_service: firewalld
```

✅ These apply to **all hosts in the “nodes” group**.

---

## **9. Defining Host-Specific Variables**

Inside **host_vars/node1.yml**:

```yaml
web_package: nginx
web_service: nginx
ansible_user: devops
```

Inside **host_vars/node2.yml**:

```yaml
web_package: httpd
web_service: httpd
ansible_user: vagrant
```

✅ Node1 installs **Nginx**, Node2 installs **Apache (httpd)** — using the same playbook!

---

## **10. Updating the Playbook**

Now you don’t need `vars.yml` anymore — remove it.

Simplified **site.yml**:

```yaml
---
- name: Install web server based on host/group vars
  hosts: nodes
  become: yes

  tasks:
    - name: Install web package
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Enable and start service
      service:
        name: "{{ web_service }}"
        state: started
        enabled: yes
```

---

## **11. Run and Observe**

Execute the playbook:

```bash
ansible-playbook site.yml -e "target=nodes"
```

You’ll see:

```
node1 → nginx installed
node2 → httpd installed
```

✅ Same playbook, different outcomes per host.

---

## **12. Clean Verification**

Check on Node1:

```bash
sudo systemctl status nginx
```

Check on Node2:

```bash
sudo systemctl status httpd
```

Both should show **active (running)** — proving host-specific configuration works.

---

## **13. Real-Life Use Cases**

| Scenario                            | Variable Type                 |
| ----------------------------------- | ----------------------------- |
| Different users per host            | `ansible_user` in `host_vars` |
| Different app ports per environment | `group_vars`                  |
| Separate package versions per OS    | `host_vars`                   |
| Shared database credentials         | `group_vars`                  |
| Temporary overrides                 | `--extra-vars`                |

---

## **14. Summary**

| Concept               | Description                                    |
| --------------------- | ---------------------------------------------- |
| **Host Vars**         | Variables defined for specific hosts           |
| **Group Vars**        | Variables defined for all hosts in a group     |
| **Precedence**        | Host vars override group vars                  |
| **File Structure**    | Use `host_vars/` and `group_vars/` directories |
| **Cleaner Inventory** | Keeps inventory organized and readable         |
| **Dynamic Behavior**  | Same playbook adapts per host automatically    |

---

## **15. Hands-On Practice**

### Step 1 – Create directories:

```bash
mkdir host_vars group_vars
```

### Step 2 – Create variable files:

`group_vars/nodes.yml`
`host_vars/node1.yml`
`host_vars/node2.yml`

### Step 3 – Run playbook:

```bash
ansible-playbook site.yml
```

### Step 4 – Verify:

```bash
ansible all -m shell -a "systemctl status nginx || systemctl status httpd"
```

---

## **16. Key Takeaway**

> Use **host_vars** and **group_vars** when you need per-host or per-group configuration,
> and keep playbooks simple, dynamic, and reusable across multiple environments.






























Perfect — this lecture covers **Ansible Variable Arrays (Lists and Dictionaries)**.
Below is your **Lecture 18 – Ansible Variable Arrays (Lists and Dictionaries)** for the DevOps Bootcamp Ansible module.

---

# ** Ansible Variable Arrays (Lists and Dictionaries)**

---



## **2. What Are Variable Arrays?**

Variable arrays allow you to store **multiple related values** in a single structured variable.

They are very useful when you have:

* Multiple users
* Multiple servers
* Multiple package configurations

Instead of creating separate variables like:

```yaml
user1_first_name: John
user1_last_name: Smith
user1_role: Admin
user2_first_name: Linda
user2_last_name: May
user2_role: Operator
```

You can organize this data using **dictionaries (key-value pairs)**:

```yaml
users:
  john:
    first_name: John
    last_name: Smith
    role: Admin
    location: London
  linda:
    first_name: Linda
    last_name: May
    role: Operator
    location: New York
```

✅ This makes your playbooks **cleaner**, **scalable**, and **easier to loop over**.

---

## **3. Creating the Variables File**

Let’s create a file named **`vars2.yml`**:

```yaml
users:
  john:
    first_name: John
    last_name: Smith
    designation: Admin
    location: London

  linda:
    first_name: Linda
    last_name: May
    designation: Operator
    location: New York
```

Here:

* `users` is the **main dictionary**.
* Each user (`john`, `linda`) is a **key** inside the dictionary.
* Each has **subkeys** (first_name, last_name, etc.) as nested key-value pairs.

---

## **4. Creating a Playbook**

Create a playbook called **`new_user.yml`**:

```yaml
---
- name: Create users from dictionary
  hosts: nodes
  become: yes

  vars_files:
    - vars2.yml

  tasks:
    - name: Display all users
      debug:
        var: users
```

### Run it:

```bash
ansible-playbook new_user.yml
```

✅ Output:

```yaml
ok: [node1] => {
    "users": {
        "john": {
            "first_name": "John",
            "last_name": "Smith",
            "designation": "Admin",
            "location": "London"
        },
        "linda": {
            "first_name": "Linda",
            "last_name": "May",
            "designation": "Operator",
            "location": "New York"
        }
    }
}
```

This confirms Ansible successfully read the **nested dictionary**.

---

## **5. Accessing Dictionary Elements**

You can access specific values using **dot notation** or **bracket notation**.

### **Example 1: Access John’s first name**

```yaml
- name: Show John's first name
  debug:
    msg: "{{ users.john.first_name }}"
```

### **Example 2: Using bracket notation (recommended)**

```yaml
- name: Show John's first name safely
  debug:
    msg: "{{ users['john']['first_name'] }}"
```

✅ **Why recommended:**
Bracket syntax avoids parsing errors if keys have spaces or special characters.

---

## **6. Looping Through the Dictionary**

If you want to **iterate** over all users and display their info:

```yaml
- name: List all users
  debug:
    msg: "User: {{ item.key }} - Role: {{ item.value.designation }} - Location: {{ item.value.location }}"
  loop: "{{ users | dict2items }}"
```

### Output:

```
User: john - Role: Admin - Location: London
User: linda - Role: Operator - Location: New York
```

✅ Explanation:

* `dict2items` converts the dictionary to a list of items.
* `item.key` → user name (john/linda)
* `item.value` → inner dictionary with properties (first_name, etc.)

---

## **7. Using Dictionary Data in Real Tasks**

You can now use the array to create users dynamically:

```yaml
- name: Create Linux users
  user:
    name: "{{ item.key }}"
    comment: "{{ item.value.first_name }} {{ item.value.last_name }}"
    state: present
  loop: "{{ users | dict2items }}"
```

This will create:

```
john (John Smith)
linda (Linda May)
```

✅ Perfect for managing multiple accounts, servers, or configs with a single playbook.

---

## **8. Accessing Specific User Attributes**

You can target a specific user:

```yaml
- name: Display Linda’s location
  debug:
    msg: "{{ users['linda']['location'] }}"
```

Or use variables dynamically:

```yaml
- name: Access user by variable
  vars:
    target_user: john
  debug:
    msg: "{{ users[target_user]['designation'] }}"
```

---

## **9. Best Practices**

| Best Practice                           | Why                                 |
| --------------------------------------- | ----------------------------------- |
| Use **dictionary variables**            | Easier to scale, cleaner YAML       |
| Use **bracket notation**                | Safer for special characters        |
| Keep **consistent indentation**         | YAML syntax requires strict spacing |
| Store arrays in **separate vars files** | Keeps playbooks clean               |
| Use **loops (`dict2items`)**            | For dynamic task generation         |

---

## **10. Comparison: Old vs New**

| Without Arrays               | With Arrays                     |
| ---------------------------- | ------------------------------- |
| user1_first_name: John       | users: john: first_name: John   |
| user2_first_name: Linda      | users: linda: first_name: Linda |
| Repetitive, hard to maintain | Clean, structured, reusable     |

---

## **11. Hands-On Practice**

### Step 1 – Create the vars file

```bash
nano vars2.yml
```

Paste:

```yaml
users:
  john:
    first_name: John
    last_name: Smith
    designation: Admin
    location: London
  linda:
    first_name: Linda
    last_name: May
    designation: Operator
    location: New York
```

### Step 2 – Create the playbook

```bash
nano new_user.yml
```

Paste:

```yaml
---
- name: Variable array demo
  hosts: nodes
  become: yes
  vars_files:
    - vars2.yml

  tasks:
    - name: List users
      debug:
        var: users

    - name: Display John's full info
      debug:
        msg: "{{ users['john'] }}"

    - name: Loop through all users
      debug:
        msg: "User {{ item.key }} from {{ item.value.location }}"
      loop: "{{ users | dict2items }}"
```

### Step 3 – Run it

```bash
ansible-playbook new_user.yml
```

✅ Observe structured output for all users.

---

## **12. Summary**

| Concept             | Description                                |
| ------------------- | ------------------------------------------ |
| **Variable Arrays** | Store related data in structured form      |
| **Dictionaries**    | Key-value format with nested data          |
| **Accessing Keys**  | Use `{{ users['john']['first_name'] }}`    |
| **Looping**         | Convert to items with `dict2items`         |
| **Use Cases**       | Managing users, services, apps, or configs |
| **Best Syntax**     | Bracket notation for safe parsing          |

---

## **13. Key Takeaway**

> Ansible variable arrays let you group related data logically.
> They simplify configuration management, reduce duplication, and make playbooks scalable.














# ** Registered Variables in Ansible**


## **2. What Is a Registered Variable?**

A **registered variable** allows you to **capture the result of a task** — such as a command, a module execution, or any playbook step — and reuse it later in the playbook.

### **Syntax:**

```yaml
- name: Example task
  shell: uptime
  register: result
```

After this task, Ansible stores all information (stdout, stderr, exit code, etc.) in a variable named `result`.

You can then use:

```yaml
- debug:
    var: result
```

---

## **3. Why Use Registered Variables?**

You need them when:

* You want to **use task outputs** later in the playbook
* You need **conditional logic** (e.g., if a package fails, take another action)
* You want to **analyze command results** dynamically

---

## **4. Example 1 – Registering Task Output**

Create a new folder for your practice:

```bash
mkdir day16_registered_variables
cd day16_registered_variables
```

Create a file **`site.yml`**:

```yaml
---
- name: Register variable demo
  hosts: nodes
  become: yes

  tasks:
    - name: Install nginx (intentionally wrong version)
      yum:
        name: nginx-v2
        state: latest
      register: pkg_output
      ignore_errors: yes

    - name: Display registered variable content
      debug:
        var: pkg_output
```

Run it:

```bash
ansible-playbook site.yml
```

✅ Output (trimmed):

```yaml
"pkg_output": {
    "changed": false,
    "failed": true,
    "msg": "No package nginx-v2 available.",
    "rc": 1
}
```

This means:

* The task **failed** (`failed: true`)
* Ansible still continued (because of `ignore_errors: yes`)
* You can now **access and use this result** later.

---

## **5. Example 2 – Conditional Logic with Registered Variables**

Add another task **after** the previous one:

```yaml
    - name: Notify if package installation failed
      debug:
        msg: "Package installation failed!"
      when: pkg_output.failed == true
```

Run again:

```bash
ansible-playbook site.yml
```

✅ Output:

```
TASK [Notify if package installation failed] ***
ok: [node1] => {
    "msg": "Package installation failed!"
}
```

Explanation:

* The condition checks if the registered variable’s `failed` property equals `true`.
* The debug task runs **only** when the package installation fails.

---

## **6. Example 3 – Successful Run**

Now, change the package name to a valid one:

```yaml
- name: Install nginx
  yum:
    name: nginx
    state: latest
  register: pkg_output
  ignore_errors: yes
```

Run again:

```bash
ansible-playbook site.yml
```

✅ Output:

```
"failed": false
"changed": true
```

And this time, the “failed” message is **skipped**, because the condition isn’t met.

---

## **7. Understanding the Registered Variable Structure**

A registered variable contains detailed information about the task result.
Example:

```yaml
{
  "changed": true,
  "cmd": ["yum", "-y", "install", "nginx"],
  "delta": "0:00:02.012",
  "end": "2025-10-17 21:00:00.000000",
  "failed": false,
  "rc": 0,
  "stdout": "Installed: nginx.x86_64 1.24.0",
  "stderr": "",
  "stdout_lines": ["Installed: nginx.x86_64 1.24.0"]
}
```

### Important keys:

| Key            | Meaning                           |
| -------------- | --------------------------------- |
| `changed`      | Whether the task changed anything |
| `failed`       | True if the task failed           |
| `rc`           | Return code of the command        |
| `stdout`       | Command output                    |
| `stderr`       | Error output                      |
| `stdout_lines` | Output split into lines (list)    |

---

## **8. Example 4 – Register Output from Shell Command**

Create a new playbook **`site2.yml`**:

```yaml
---
- name: Register variable with shell command
  hosts: nodes
  become: yes

  tasks:
    - name: Run uptime command
      shell: uptime
      register: shell_output
      ignore_errors: yes

    - name: Print entire output
      debug:
        var: shell_output

    - name: Print only uptime line
      debug:
        msg: "{{ shell_output.stdout_lines }}"
```

### Run it:

```bash
ansible-playbook site2.yml
```

✅ Output example:

```
"shell_output.stdout_lines": [
    " 21:11:15 up 3 days,  2:12,  2 users,  load average: 0.15, 0.10, 0.05"
]
```

---

## **9. Example 5 – Using Registered Output in a Decision**

You can use this variable to make decisions.

For example, run a command and check if it contains a keyword:

```yaml
- name: Check if nginx is running
  shell: systemctl status nginx
  register: status_output
  ignore_errors: yes

- name: Print message if running
  debug:
    msg: "Nginx service is running!"
  when: "'active (running)' in status_output.stdout"
```

---

## **10. Common Use Cases**

| Use Case                   | Description                                     |
| -------------------------- | ----------------------------------------------- |
| **Conditional execution**  | Run tasks only if a previous one succeeds/fails |
| **Dynamic branching**      | Control playbook flow based on outputs          |
| **Gathering data**         | Store command results for reporting             |
| **Combining with filters** | Use Jinja2 filters to clean and parse results   |
| **Debugging**              | Print outputs to understand execution flow      |

---

## **11. Combining Filters with Registered Variables**

You can refine your data using filters:

```yaml
- debug:
    msg: "{{ shell_output.stdout_lines | first }}"
```

or

```yaml
- debug:
    msg: "{{ pkg_output.msg | default('No error found') }}"
```

---

## **12. Summary**

| Concept                | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| **Register**           | Captures task result output                          |
| **Structure**          | Contains stdout, stderr, rc, failed, etc.            |
| **Usage**              | Used with `when`, `debug`, or later tasks            |
| **ignore_errors: yes** | Allows the playbook to continue even if a task fails |
| **stdout_lines**       | Best for readable command output                     |

---

## **13. Hands-On Practice**

### Step 1 – Create the playbook:

```bash
nano site.yml
```

Paste:

```yaml
---
- name: Demo registered variable
  hosts: nodes
  become: yes

  tasks:
    - name: Try installing invalid package
      yum:
        name: nginx-v2
        state: latest
      register: pkg_result
      ignore_errors: yes

    - name: Print error message if failed
      debug:
        msg: "Package installation failed!"
      when: pkg_result.failed == true
```

### Step 2 – Run:

```bash
ansible-playbook site.yml
```

✅ Observe conditional message on failure.

---

## **14. Key Takeaways**

> Registered variables let you **capture**, **analyze**, and **reuse** task outputs —
> forming the foundation for **dynamic**, **conditional**, and **intelligent automation** in Ansible.













# ** Ansible Facts**

---



## **2. What Are Ansible Facts?**

**Ansible Facts** are system information automatically **collected from managed hosts** before any task executes.

They include:

* Hostname and FQDN
* IP addresses and interfaces
* OS and distribution details
* Kernel version
* CPU, memory, and disk info
* Network, BIOS, and environment variables

All these are stored in a special dictionary variable called **`ansible_facts`**.

---

## **3. Why Are Facts Important?**

You can use facts to:

* Make playbooks dynamic (e.g., install different packages on Ubuntu vs CentOS)
* Use system data (like hostname or IP) in configuration templates
* Debug and monitor managed systems
* Perform conditional tasks (e.g., skip if not enough memory)

---

## **4. Facts Are Gathered Automatically**

When you run any playbook, Ansible automatically executes a hidden **setup task** at the start:

```yaml
TASK [Gathering Facts]
```

This task runs the **`setup` module** internally, collecting all system information from the remote host.

### Example:

```yaml
---
- name: Facts demo
  hosts: nodes

  tasks:
    - name: Print greeting
      debug:
        msg: "Hello from Ansible!"
```

When you run:

```bash
ansible-playbook site.yml
```

You’ll notice:

```
TASK [Gathering Facts] ***
ok: [node1]
ok: [node2]
```

✅ Even though you didn’t define it — Ansible gathered facts automatically.

---

## **5. Viewing All Facts**

You can manually run the **`setup` module** to see everything Ansible collects:

```bash
ansible node1 -m setup
```

✅ Output includes:

* `ansible_default_ipv4` (default IP info)
* `ansible_hostname` (system hostname)
* `ansible_distribution` (OS type)
* `ansible_memory_mb` (RAM info)
* `ansible_processor` (CPU details)
* `ansible_all_ipv4_addresses`
* `ansible_date_time`
* `ansible_kernel`

> Tip: The output is huge — you can filter it using `-a` (argument).

### Example: Show only network info

```bash
ansible node1 -m setup -a "filter=ansible_*ipv4*"
```

---

## **6. Using Facts in Playbooks**

You can use these facts directly as variables in your playbooks.

Example playbook **`facts_demo.yml`**:

```yaml
---
- name: Using Ansible Facts
  hosts: nodes
  gather_facts: yes

  tasks:
    - name: Print host name
      debug:
        msg: "Hostname: {{ ansible_hostname }}"

    - name: Print default IPv4 address
      debug:
        msg: "IP Address: {{ ansible_default_ipv4.address }}"

    - name: Print operating system
      debug:
        msg: "Distribution: {{ ansible_distribution }}"
```

Run it:

```bash
ansible-playbook facts_demo.yml
```

✅ Output:

```
Hostname: node1
IP Address: 172.31.42.18
Distribution: CentOS
```

---

## **7. Controlling Fact Gathering**

Sometimes you don’t need system facts — for example, when running simple tasks.
You can **disable automatic fact collection** to speed up your playbook.

```yaml
gather_facts: no
```

Example:

```yaml
---
- name: Skip fact gathering
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Print hello
      debug:
        msg: "Hello!"
```

✅ This runs **faster** because Ansible skips the fact-gathering phase.

---

## **8. Manually Gathering Facts When Needed**

If you disable `gather_facts`, you can still collect them **later in the playbook** using the `setup` module:

```yaml
---
- name: Manually gather facts
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Collect facts manually
      setup:

    - name: Print kernel version
      debug:
        msg: "{{ ansible_kernel }}"
```

---

## **9. Using Facts for Conditional Tasks**

You can use system facts to create **conditions** in your automation logic.

### Example 1 – OS-based Package Installation

```yaml
- name: Install web server based on OS
  hosts: nodes
  become: yes

  tasks:
    - name: Install Apache on RedHat
      yum:
        name: httpd
        state: present
      when: ansible_distribution == "CentOS" or ansible_distribution == "RedHat"

    - name: Install Apache on Ubuntu
      apt:
        name: apache2
        state: present
      when: ansible_distribution == "Ubuntu"
```

✅ This playbook automatically installs the correct package depending on the OS.

---

### Example 2 – Memory-Based Condition

```yaml
- name: Run task only if memory > 2 GB
  hosts: nodes
  tasks:
    - name: Print memory
      debug:
        msg: "System has enough memory."
      when: ansible_memory_mb.real.total > 2048
```

---

## **10. Commonly Used Facts**

| Fact Variable                  | Description                    |
| ------------------------------ | ------------------------------ |
| `ansible_hostname`             | Hostname of the node           |
| `ansible_distribution`         | OS name (e.g., Ubuntu, CentOS) |
| `ansible_distribution_version` | OS version                     |
| `ansible_kernel`               | Kernel version                 |
| `ansible_default_ipv4.address` | Default IP address             |
| `ansible_all_ipv4_addresses`   | List of all IPv4 addresses     |
| `ansible_processor`            | CPU details                    |
| `ansible_memory_mb.real.total` | RAM in MB                      |
| `ansible_date_time.date`       | Current date                   |
| `ansible_domain`               | Domain name                    |
| `ansible_fqdn`                 | Fully qualified domain name    |
| `ansible_mounts`               | Disk mount information         |

---

## **11. Filtering Facts**

If you only need specific facts, you can filter them to reduce load time:

```bash
ansible node1 -m setup -a "filter=ansible_distribution*"
```

✅ Output:

```
"ansible_distribution": "Ubuntu",
"ansible_distribution_major_version": "20",
"ansible_distribution_release": "focal"
```

---

## **12. When Facts Cause Errors**

If you **disable** fact gathering (`gather_facts: no`) and still use a fact variable, you’ll get:

```
fatal: [node1]: FAILED! => {"msg": "'ansible_distribution' is undefined"}
```

✅ Fix: Either set `gather_facts: yes` or use `setup:` to collect facts manually.

---

## **13. Performance Tip**

Fact gathering can slightly delay playbook start (1–2 seconds per host).
To speed up large deployments:

* Use `gather_facts: no`
* Use `setup:` selectively when needed
* Or limit collection:

  ```yaml
  - setup:
      gather_subset:
        - network
        - hardware
  ```

---

## **14. Summary**

| Concept               | Description                                    |
| --------------------- | ---------------------------------------------- |
| **Ansible Facts**     | System data automatically collected by Ansible |
| **Gathering Facts**   | Controlled with `gather_facts: yes/no`         |
| **Manual Collection** | Use the `setup` module                         |
| **Conditional Logic** | Facts can guide playbook flow                  |
| **Performance**       | Disable if not needed to speed up runs         |

---

## **15. Hands-On Practice**

### Step 1 – Create Playbook

```bash
nano facts_demo.yml
```

Paste:

```yaml
---
- name: Ansible Facts Example
  hosts: nodes
  gather_facts: yes

  tasks:
    - name: Display host details
      debug:
        msg:
          - "Hostname: {{ ansible_hostname }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
```

### Step 2 – Run it

```bash
ansible-playbook facts_demo.yml
```

✅ Output will show each host’s details.

---

## **16. Key Takeaway**

> Ansible Facts make your automation **intelligent** and **context-aware** —
> they help you adapt playbooks automatically to the environment.












# ** Ansible Facts (Gathering, Using, and Controlling Facts)**




Facts allow your playbooks to be **dynamic and environment-aware**.
For example:

* Install a specific package only on Ubuntu hosts.
* Run a task only if memory > 2 GB.
* Use a host’s IP address in configuration files.

---

## **3. How Ansible Gathers Facts**

When you run a playbook, the first task that appears is:

```
TASK [Gathering Facts]
```

This uses the **`setup` module**, which automatically collects all system information.

You can verify this manually:

```bash
ansible node1 -m setup
```

✅ Output includes hundreds of details like:

* `ansible_hostname`
* `ansible_distribution`
* `ansible_default_ipv4.address`
* `ansible_memory_mb`
* `ansible_kernel`

---

## **4. Example: Viewing Collected Facts**

You can filter the facts you need:

```bash
ansible node1 -m setup -a "filter=ansible_*ipv4*"
```

This returns only network-related facts (like IPs).

---

## **5. Demo: Using Facts in a Playbook**

Let’s create a demo playbook:

```yaml
---
- name: Ansible Facts Demo
  hosts: nodes
  gather_facts: yes

  tasks:
    - name: Display host name
      debug:
        msg: "Host Name: {{ ansible_hostname }}"

    - name: Display IP address
      debug:
        msg: "IP Address: {{ ansible_default_ipv4.address }}"

    - name: Display OS information
      debug:
        msg: "Operating System: {{ ansible_distribution }}"
```

### Run it:

```bash
ansible-playbook facts_demo.yml
```

✅ Output:

```
Host Name: node1
IP Address: 172.31.45.182
Operating System: CentOS
```

---

## **6. Disabling Fact Gathering**

Fact collection takes time, especially in large environments.
If your playbook doesn’t need facts, disable it:

```yaml
---
- name: Disable fact gathering
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Print message
      debug:
        msg: "Facts gathering skipped for speed."
```

✅ Runs much faster because the `setup` module is skipped.

---

## **7. Manually Gathering Facts**

If you disable automatic gathering, you can still collect facts later using the `setup` module:

```yaml
---
- name: Manual fact collection
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Collect facts when needed
      setup:

    - name: Display kernel version
      debug:
        msg: "Kernel: {{ ansible_kernel }}"
```

---

## **8. Using Facts in Conditional Logic**

Facts can be used to control playbook behavior dynamically.

### Example 1 – OS-based condition:

```yaml
- name: Install package based on OS
  hosts: nodes
  become: yes

  tasks:
    - name: Install httpd for CentOS
      yum:
        name: httpd
        state: present
      when: ansible_distribution == "CentOS"

    - name: Install apache2 for Ubuntu
      apt:
        name: apache2
        state: present
      when: ansible_distribution == "Ubuntu"
```

### Example 2 – Memory check:

```yaml
- name: Run task only if memory > 2GB
  hosts: nodes
  tasks:
    - name: Print memory check
      debug:
        msg: "Enough memory available"
      when: ansible_memory_mb.real.total > 2048
```

---

## **9. When Facts Are Undefined**

If you disable fact gathering and still try to use a fact variable, Ansible throws an error:

```
fatal: [node1]: FAILED! => {"msg": "'ansible_distribution' is undefined"}
```

✅ Fix: enable `gather_facts: yes` or manually use `setup:` to collect facts.

---

## **10. Performance Optimization**

Fact collection adds 1–2 seconds per host.
To optimize:

* Use `gather_facts: no` for lightweight playbooks.
* Collect only specific subsets:

  ```yaml
  - setup:
      gather_subset:
        - network
        - hardware
  ```
* Or use filters in CLI:

  ```bash
  ansible node1 -m setup -a "filter=ansible_distribution*"
  ```

---

## **11. Common Facts Reference**

| Fact Variable                  | Description                 |
| ------------------------------ | --------------------------- |
| `ansible_hostname`             | System hostname             |
| `ansible_distribution`         | OS name                     |
| `ansible_distribution_version` | OS version                  |
| `ansible_kernel`               | Kernel version              |
| `ansible_default_ipv4.address` | Primary IP address          |
| `ansible_all_ipv4_addresses`   | List of all IPs             |
| `ansible_processor`            | CPU info                    |
| `ansible_memory_mb.real.total` | RAM in MB                   |
| `ansible_date_time.date`       | Current date                |
| `ansible_fqdn`                 | Fully qualified domain name |

---

## **12. Key Takeaways**

| Concept               | Description                                   |
| --------------------- | --------------------------------------------- |
| **Facts**             | Automatically discovered host data            |
| **Setup module**      | Collects facts manually                       |
| **`gather_facts`**    | Enables or disables automatic fact collection |
| **Conditional logic** | Use facts to make smart automation decisions  |
| **Performance**       | Skip or limit facts to speed up runs          |

---

## **13. Hands-On Exercise**

### Step 1 – Create playbook

```bash
nano facts_demo.yml
```

Paste:

```yaml
---
- name: Facts Example
  hosts: nodes
  gather_facts: yes

  tasks:
    - debug:
        msg:
          - "Hostname: {{ ansible_hostname }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "OS: {{ ansible_distribution }}"
```

### Step 2 – Run:

```bash
ansible-playbook facts_demo.yml
```

✅ Observe dynamic output for each host.

---

## **14. Summary**

> Ansible Facts are **built-in dynamic variables** that make your automation smarter.
> You can **enable**, **disable**, or **manually control** fact gathering to optimize speed and precision in your playbooks.












 **Custom Facts**.

> **Custom Facts** are user-defined facts that you can create manually inside your managed hosts.
> They help you provide **organization-specific metadata** such as:
>
> * Server role (e.g., web, database, cache)
> * Application port
> * Environment (dev, stage, prod)
> * Business criticality (high, medium, low)

---

## **2. What Are Custom Facts?**

* Custom facts are **static or dynamic values** defined by the user.
* Stored in the managed host under:

  ```
  /etc/ansible/facts.d/
  ```
* Each fact file must have a `.fact` extension and contain **key=value** pairs.
* When you run a playbook with `gather_facts: yes`, Ansible automatically reads these custom facts and adds them under the variable:

  ```
  ansible_local
  ```

---

## **3. When to Use Custom Facts**

Use custom facts when:

* You need **data that Ansible doesn’t gather by default** (like business unit, application type, or environment).
* You want **per-host configuration** to be reusable in multiple playbooks.
* You need **stable variables** even if the host’s OS or inventory changes.

---

## **4. Creating Custom Facts on a Node**

### Step 1 – Log in to the managed node:

```bash
ssh ubuntu@node1
```

### Step 2 – Create the directory (if it doesn’t exist):

```bash
sudo mkdir -p /etc/ansible/facts.d
```

### Step 3 – Create a new fact file:

```bash
sudo vim /etc/ansible/facts.d/web.fact
```

### Step 4 – Add custom facts:

```ini
[web_details]
package=nginx
web_port=80

[business]
criticality=high
```

### Step 5 – Save and exit.

---

## **5. Verifying Custom Facts**

You can view the custom facts using the **`setup`** module with a filter.

```bash
ansible node1 -m setup -a "filter=ansible_local"
```

✅ Output:

```yaml
"ansible_local": {
    "web": {
        "web_details": {
            "package": "nginx",
            "web_port": "80"
        },
        "business": {
            "criticality": "high"
        }
    }
}
```

This means:

* The file `web.fact` was found and read.
* Its sections and keys are accessible through the `ansible_local` variable.

---

## **6. Using Custom Facts in a Playbook**

### Example Playbook

```yaml
---
- name: Test Custom Facts
  hosts: nodes
  gather_facts: yes

  tasks:
    - name: Display full custom fact
      debug:
        var: ansible_local

    - name: Display business criticality
      debug:
        msg: "Criticality: {{ ansible_local.web.business.criticality }}"

    - name: Display web server port
      debug:
        msg: "Web Port: {{ ansible_local.web.web_details.web_port }}"
```

### Run:

```bash
ansible-playbook custom_facts_demo.yml
```

✅ Output:

```
Criticality: high
Web Port: 80
```

---

## **7. Handling Missing Facts Gracefully**

If some hosts don’t have custom facts, Ansible will fail with an **undefined variable** error.

To prevent this, use the `when` condition:

```yaml
- name: Display custom fact only if defined
  debug:
    msg: "Criticality: {{ ansible_local.web.business.criticality }}"
  when: ansible_local.web.business.criticality is defined
```

✅ Now hosts without the fact will be skipped instead of failing.

---

## **8. Using Custom Facts to Control Tasks**

You can use custom facts to dynamically control playbook behavior.

### Example 1 – Install based on fact value

```yaml
- name: Install nginx only on web servers
  hosts: nodes
  become: yes

  tasks:
    - name: Install nginx package
      yum:
        name: nginx
        state: present
      when: ansible_local.web.web_details.package == "nginx"
```

### Example 2 – Skip tasks for non-critical servers

```yaml
- name: Run backup for high critical servers
  hosts: nodes
  tasks:
    - name: Perform backup
      shell: /usr/local/bin/backup.sh
      when: ansible_local.web.business.criticality == "high"
```

---

## **9. Directory and File Naming Rules**

| Path                    | Description                            |
| ----------------------- | -------------------------------------- |
| `/etc/ansible/facts.d/` | Default location for custom fact files |
| `*.fact`                | File extension must be `.fact`         |
| File format             | INI-style (`key=value`)                |
| Variable access path    | `ansible_local.<file>.<section>.<key>` |

> ⚠️ If you use a different directory for facts, you must set:
>
> ```ini
> [defaults]
> fact_path = /custom/facts/path
> ```
>
> inside your `ansible.cfg`.

---

## **10. Practical Use Cases**

| Scenario             | Example                                   |
| -------------------- | ----------------------------------------- |
| Role identification  | Define if host is “web”, “db”, or “proxy” |
| Environment tagging  | dev/staging/production                    |
| Port or service info | `web_port=8080`                           |
| Backup policies      | `backup_enabled=true`                     |
| Resource tier        | `tier=gold/silver/bronze`                 |
| Business priority    | `criticality=high`                        |

---

## **11. Full Demo Recap**

### On Node 1:

```bash
sudo mkdir -p /etc/ansible/facts.d
sudo vim /etc/ansible/facts.d/web.fact
```

Content:

```ini
[web_details]
package=nginx
web_port=80

[business]
criticality=high
```

### On Node 2:

(no facts added)

### On Control Node:

Create and run:

```yaml
---
- name: Use Custom Facts
  hosts: nodes
  gather_facts: yes

  tasks:
    - name: Print web port if defined
      debug:
        msg: "Web port is {{ ansible_local.web.web_details.web_port }}"
      when: ansible_local.web.web_details.web_port is defined
```

✅ Output:

```
node1 | SUCCESS => Web port is 80
node2 | SKIPPED
```

---

## **12. Key Takeaways**

| Concept             | Description                                            |
| ------------------- | ------------------------------------------------------ |
| **Custom Facts**    | User-defined variables stored on hosts                 |
| **Location**        | `/etc/ansible/facts.d/*.fact`                          |
| **Access Variable** | `ansible_local.<file>.<section>.<key>`                 |
| **Use Case**        | Extend host metadata for automation decisions          |
| **Safety**          | Always use `is defined` to prevent failure             |
| **Control**         | Allows per-host custom logic without editing playbooks |

---

## **13. Hands-On Practice**

1. Create a fact file on your EC2 node.
2. Define:

   ```ini
   [database]
   port=3306
   vendor=mysql
   ```
3. Run:

   ```bash
   ansible node1 -m setup -a "filter=ansible_local"
   ```
4. Access the value in a playbook:

   ```yaml
   {{ ansible_local.database.port }}
   ```
5. Add a condition:

   ```yaml
   when: ansible_local.database.vendor == "mysql"
   ```

---

## **14. Summary**

> **Custom Facts** make Ansible more powerful and flexible by allowing you to define your own static or dynamic metadata per host.
> They’re ideal for storing environment-specific information, improving automation logic, and keeping playbooks clean and reusable.











## **2. What Are Magic Variables?**

Magic variables:

* Are **built-in** and **always available** — no need to declare or gather them.
* Represent internal Ansible data, such as:

  * Hostnames
  * Groups and group membership
  * Inventory details
  * Execution modes (check mode, diff mode, etc.)

You can use them directly in playbooks for dynamic control, debugging, and conditional logic.

---

## **3. Example Playbook – Using Magic Variables**

Let’s create a playbook to explore these variables.

### `magic_vars.yml`

```yaml
---
- name: Learn Magic Variables
  hosts: nodes

  tasks:
    - name: Show inventory hostname
      debug:
        msg: "Inventory Hostname: {{ inventory_hostname }}"
```

### Run:

```bash
ansible-playbook magic_vars.yml
```

✅ Output:

```
Inventory Hostname: node1
Inventory Hostname: node2
```

Here:

* `inventory_hostname` comes directly from the **inventory file**, not from facts or host_vars.

---

## **4. Understanding `inventory_hostname`**

* Represents the **exact name** of the host as listed in your inventory file.
* Useful when you need to display or log which host is being executed.

For example, if your inventory has:

```
[nodes]
node1
node2
```

Then:

```
{{ inventory_hostname }}
```

→ prints `node1` or `node2` depending on which host is running.

---

## **5. Magic Variable: `groups`**

The `groups` variable stores **all inventory groups** and their members.

Add this task:

```yaml
- name: Show all groups
  debug:
    var: groups
```

✅ Output Example:

```yaml
"groups": {
  "all": ["node1", "node2"],
  "nodes": ["node1", "node2"],
  "ungrouped": []
}
```

Now you can access any specific group:

```yaml
{{ groups['nodes'] }}
```

→ `['node1', 'node2']`

---

## **6. Magic Variable: `group_names`**

This variable shows the list of groups that the **current host** belongs to.

Add this task:

```yaml
- name: Show groups current host belongs to
  debug:
    var: group_names
```

✅ Output:

```
ok: [node1] => (item=None) =>
  "group_names": ["nodes"]
ok: [node2] =>
  "group_names": ["nodes"]
```

If you modify your inventory like this:

```ini
[nodes]
node1
node2

[new_nodes]
node1
```

Then:

* `node1` → belongs to `["nodes", "new_nodes"]`
* `node2` → belongs to `["nodes"]`

---

## **7. Magic Variable: `hostvars`**

The `hostvars` variable gives access to **all variables (including facts)** of any host in the inventory.

Example:

```yaml
- name: Show all host variables
  debug:
    var: hostvars
```

This will print a **large dictionary** of variables, including:

* Facts (like `ansible_distribution`, `ansible_default_ipv4.address`)
* Custom facts
* Any `host_vars` defined

---

### Example – Accessing Another Host’s Variable

You can access variables of another host like this:

```yaml
{{ hostvars['node1']['ansible_hostname'] }}
```

This is extremely useful in:

* Multi-node orchestration
* Cluster deployments (e.g., sharing data between master and worker nodes)

---

## **8. Disabling Facts to See Magic Variables Clearly**

If you disable fact gathering:

```yaml
gather_facts: no
```

Then only magic variables remain visible:

```yaml
- name: Show only magic variables
  hosts: nodes
  gather_facts: no
  tasks:
    - name: Show host variables without facts
      debug:
        var: hostvars[inventory_hostname]
```

✅ Output will include:

* `ansible_check_mode`
* `group_names`
* `inventory_hostname`
* and other Ansible internal metadata.

---

## **9. Common Magic Variables**

| Magic Variable       | Description                                         |
| -------------------- | --------------------------------------------------- |
| `inventory_hostname` | Hostname as defined in inventory                    |
| `group_names`        | Groups the current host belongs to                  |
| `groups`             | All groups and their member hosts                   |
| `hostvars`           | All variables (facts, host_vars, etc.) of all hosts |
| `inventory_dir`      | Directory path of the loaded inventory file         |
| `inventory_file`     | Path to the actual inventory file used              |
| `playbook_dir`       | Directory of the current playbook file              |
| `ansible_check_mode` | True if running with `--check`                      |
| `ansible_diff_mode`  | True if running with `--diff`                       |
| `ansible_version`    | Version info of Ansible                             |
| `ansible_play_hosts` | List of hosts in the current play                   |
| `ansible_limit`      | Active limit pattern applied with `--limit`         |
| `ansible_play_batch` | Hosts being executed in the current batch           |

---

## **10. Example: Combining Magic Variables**

```yaml
---
- name: Magic Variable Example
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Display details
      debug:
        msg:
          - "Host: {{ inventory_hostname }}"
          - "Groups: {{ group_names }}"
          - "All nodes in 'nodes' group: {{ groups['nodes'] }}"
          - "Playbook directory: {{ playbook_dir }}"
```

✅ Output:

```
Host: node1
Groups: ['nodes', 'new_nodes']
All nodes in 'nodes' group: ['node1', 'node2']
Playbook directory: /home/ubuntu/ansible
```

---

## **11. Use Cases in Real Projects**

| Scenario                        | Example Magic Variable                               |
| ------------------------------- | ---------------------------------------------------- |
| Display dynamic host info       | `inventory_hostname`, `group_names`                  |
| Run task only on certain groups | `when: 'new_nodes' in group_names`                   |
| Access another host’s data      | `hostvars['db1']['ansible_default_ipv4']['address']` |
| Use path variables              | `playbook_dir`, `inventory_dir`                      |
| Conditional behavior            | `when: ansible_check_mode == false`                  |

---

## **12. Summary**

| Concept              | Description                                               |
| -------------------- | --------------------------------------------------------- |
| **Magic Variables**  | Internal variables created by Ansible during runtime      |
| **Not Facts**        | They are metadata about hosts, inventory, and playbooks   |
| **Examples**         | `inventory_hostname`, `groups`, `group_names`, `hostvars` |
| **Useful for**       | Debugging, dynamic logic, and orchestration               |
| **Always Available** | Even with `gather_facts: no`                              |

---

## **13. Hands-On Practice**

### Step 1 – Create playbook:

```bash
nano magic_demo.yml
```

Paste:

```yaml
---
- name: Explore Magic Variables
  hosts: nodes
  gather_facts: no

  tasks:
    - name: Show basic magic variables
      debug:
        msg:
          - "Inventory Hostname: {{ inventory_hostname }}"
          - "Groups: {{ group_names }}"
          - "All Hosts: {{ groups['all'] }}"
          - "Playbook Dir: {{ playbook_dir }}"
```

### Step 2 – Run:

```bash
ansible-playbook magic_demo.yml
```

✅ Observe how magic variables behave dynamically per host.

---

## **14. Key Takeaway**

> **Magic Variables** are Ansible’s built-in context variables.
> They help you understand “where” and “how” your playbooks are running — without writing or gathering extra data.











### Why Do We Need Secret Management?

Playbooks often contain **sensitive data**, such as:

* API keys
* Database credentials
* Cloud tokens
* SSH passwords
* Cluster certificates

You cannot safely store these secrets in plain YAML files or Git repositories.
That’s where **Ansible Vault** comes in.

---

## **2. What Is Ansible Vault?**

> **Ansible Vault** is a built-in encryption utility that allows you to **encrypt and decrypt sensitive data** in Ansible files.

### Key Features

* Encrypt any YAML or text file
* Decrypt files for reading or editing
* Re-encrypt with a new password
* Works natively with playbooks and roles
* Uses AES-256 encryption (secure and industry-standard)

Vault is included by default with Ansible — **no extra installation** is required.

---

## **3. Vault Command Syntax**

| Operation   | Command                            | Description                   |
| ----------- | ---------------------------------- | ----------------------------- |
| **Create**  | `ansible-vault create <filename>`  | Create and encrypt a new file |
| **View**    | `ansible-vault view <filename>`    | View encrypted contents       |
| **Edit**    | `ansible-vault edit <filename>`    | Edit contents securely        |
| **Encrypt** | `ansible-vault encrypt <filename>` | Encrypt an existing file      |
| **Decrypt** | `ansible-vault decrypt <filename>` | Decrypt a file to plain text  |
| **Re-key**  | `ansible-vault rekey <filename>`   | Change the Vault password     |

---

## **4. Demo: Creating a Secret File**

### Step 1 – Create an encrypted file:

```bash
ansible-vault create secret_data.yml
```

Ansible prompts for a password:

```
New Vault password: ********
Confirm Vault password: ********
```

> ⚠️ **Important:** Remember this password — you’ll need it to decrypt or use the file later.

---

### Step 2 – Add variables inside the Vault file

In your editor (usually `vim` or `nano`), enter:

```yaml
password: admin123
vmware_password: vm@123
```

Save and exit.

---

### Step 3 – Check the file content

```bash
cat secret_data.yml
```

✅ Output:

```
$ANSIBLE_VAULT;1.1;AES256
643936326464623165623962313339633534323532353565393034663636...
```

The contents are now **encrypted**, not readable as plain text.

---

## **5. Viewing Secrets**

Use:

```bash
ansible-vault view secret_data.yml
```

Ansible prompts for the password and then displays decrypted content **temporarily** in your terminal.

---

## **6. Editing Secrets**

You can securely modify Vault files without decrypting them manually.

```bash
ansible-vault edit secret_data.yml
```

Enter the password → file opens in your editor.

Add more variables, for example:

```yaml
vmware_token: mytoken123
```

Save and exit — it’s automatically re-encrypted.

---

## **7. Decrypting Files**

To permanently decrypt (convert back to plain text):

```bash
ansible-vault decrypt secret_data.yml
```

Enter the password → output:

```
Decryption successful
```

✅ File now becomes readable YAML:

```yaml
password: admin123
vmware_password: vm@123
vmware_token: mytoken123
```

---

## **8. Re-Encrypting Files**

To encrypt again:

```bash
ansible-vault encrypt secret_data.yml
```

Enter a Vault password → file is encrypted again with AES-256.

✅ Output:

```
Encryption successful
```

---

## **9. Changing Vault Password (Re-Key)**

If you suspect the Vault password was shared or compromised, change it easily:

```bash
ansible-vault rekey secret_data.yml
```

You’ll be asked for:

1. The **old password**
2. The **new password**

✅ Output:

```
Rekey successful
```

---

## **10. Summary of Core Operations**

| Action                    | Command Example                     | Result                     |
| ------------------------- | ----------------------------------- | -------------------------- |
| Create new encrypted file | `ansible-vault create secrets.yml`  | Creates & encrypts file    |
| View contents             | `ansible-vault view secrets.yml`    | Displays decrypted view    |
| Edit securely             | `ansible-vault edit secrets.yml`    | Opens file for secure edit |
| Decrypt file              | `ansible-vault decrypt secrets.yml` | Converts to plain YAML     |
| Encrypt file              | `ansible-vault encrypt secrets.yml` | Encrypts existing YAML     |
| Change password           | `ansible-vault rekey secrets.yml`   | Changes Vault password     |

---

## **11. Encryption Algorithm**

Ansible Vault uses:

* **AES-256** symmetric encryption
* Each file is encrypted with the password you provide
* Encryption header includes format version (`$ANSIBLE_VAULT;1.1;AES256`)

This ensures **strong protection** against unauthorized access, even if your files are stored in public repositories.

---

## **12. Best Practices for Using Vault**

✅ **Do**

* Store Vault password securely (not in Git)
* Use separate passwords per environment (dev, stage, prod)
* Add `.vault_pass.txt` to `.gitignore`
* Use Ansible’s Vault ID mechanism for multi-env passwords
* Limit decryption to specific CI/CD steps

❌ **Don’t**

* Commit decrypted files to source control
* Share the Vault password over chat or email
* Mix encrypted and unencrypted data in the same file unless necessary

---

## **13. Real-World Use Case**

### Example: Storing Database Credentials

```bash
ansible-vault create db_secrets.yml
```

Add:

```yaml
db_user: admin
db_password: secure@123
```

Then reference it in a playbook:

```yaml
---
- name: Use Vault Secrets
  hosts: db_servers
  vars_files:
    - db_secrets.yml

  tasks:
    - name: Show DB user
      debug:
        msg: "Database user is {{ db_user }}"
```

Run playbook with password prompt:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

---

## **14. Key Takeaways**

| Concept         | Description                                                              |
| --------------- | ------------------------------------------------------------------------ |
| **Purpose**     | Protect sensitive information (passwords, tokens, API keys)              |
| **Tool**        | Built-in `ansible-vault` command                                         |
| **Encryption**  | AES-256 symmetric encryption                                             |
| **Operations**  | Create, edit, view, encrypt, decrypt, rekey                              |
| **Integration** | Use `--ask-vault-pass` or `--vault-password-file` when running playbooks |
| **Security**    | Never share decrypted secrets or passwords in Git                        |

---

## **15. Hands-On Practice**

### Step 1 – Create vault file

```bash
ansible-vault create secret_data.yml
```

Add:

```yaml
password: devops@123
token: 9fabcde
```

### Step 2 – View and edit

```bash
ansible-vault view secret_data.yml
ansible-vault edit secret_data.yml
```

### Step 3 – Run with playbook

```bash
ansible-playbook secure_playbook.yml --ask-vault-pass
```

---

## **16. Summary**

> **Ansible Vault** allows DevOps engineers to manage sensitive information safely inside automation pipelines — eliminating the risk of accidental exposure of credentials in Git or CI/CD environments.












## **2. Use Case Scenario**

We’ll create a playbook that:

1. Creates a user account on remote nodes
2. Takes the username and password from an **encrypted Vault file**
3. Runs automatically using either `--ask-vault-pass` or a **vault password file**

---

## **3. Project Setup**

### Files Structure

```
inventory
ansible.cfg
site.yml
userpassword.yml  ←  (Vault-encrypted secrets)
```

### Inventory File

```ini
[nodes]
node1
node2
```

### Ansible Configuration (ansible.cfg)

```ini
[defaults]
inventory = ./inventory
host_key_checking = False
```

---

## **4. Step 1 – Create the Playbook**

Create `site.yml`:

```yaml
---
- name: Using Secrets in Playbook
  hosts: nodes
  become: true

  vars_files:
    - userpassword.yml   # encrypted file

  tasks:
    - name: Create user from secret vars
      user:
        name: "{{ username }}"
        password: "{{ password | password_hash('sha512') }}"
```

> 🔒 We hash the password using `password_hash('sha512')` because Ansible’s `user` module requires **hashed passwords**, not plain text — even if the Vault file is encrypted.

---

## **5. Step 2 – Create the Vault File**

```bash
ansible-vault create userpassword.yml
```

When prompted, enter a Vault password (for example `ansible`).

Then, inside the editor, add:

```yaml
username: newuser
password: mypassword
```

Save and exit.

Check:

```bash
cat userpassword.yml
```

✅ Output shows AES-256-encrypted text.

---

## **6. Step 3 – Run the Playbook (Interactive Password)**

### Option 1 – Prompt for Vault Password (legacy flag)

```bash
ansible-playbook site.yml --ask-vault-pass
```

### Option 2 – Using Vault ID (Prompt style)

```bash
ansible-playbook site.yml --vault-id prompt
```

You’ll be prompted:

```
Vault password: *****
```

✅ Ansible decrypts `userpassword.yml`, retrieves `username` and `password`, hashes it, and creates the user.

---

## **7. Step 4 – Verify User Creation**

```bash
ssh newuser@node1
```

Enter `mypassword`.
✅ Login successful → the user was created using Vault variables.

---

## **8. Step 5 – Avoid Typing Password Every Time**

Typing the Vault password for every run is inconvenient.
Instead, you can store the Vault password safely in a **hidden file** (with proper permissions).

### 1️⃣ Create Vault Password File

```bash
vim ~/.my_vault_pass
```

Content:

```
ansible
```

Set permissions:

```bash
chmod 600 ~/.my_vault_pass
```

### 2️⃣ Run Playbook Using Vault Password File

```bash
ansible-playbook site.yml --vault-password-file ~/.my_vault_pass
```

✅ Now Ansible automatically reads the password from the file — no prompt required.

---

## **9. How Vault Integration Works Internally**

When Ansible runs the playbook:

1. It detects an encrypted `vars_file`
2. Prompts for the Vault password (or uses the file)
3. Decrypts the content in memory only (during runtime)
4. Executes tasks using the decrypted values
5. Discards the plaintext after execution

This ensures secrets **never remain on disk in plain form**.

---

## **10. Handling Hashed Passwords**

If you use `user` module with a plain string password, you’ll get warnings.
Always hash it using the `password_hash()` filter:

```yaml
password: "{{ password | password_hash('sha512') }}"
```

✅ Generates a secure, salted hash:

```
$6$randomsalt$1fYsv...
```

---

## **11. Alternative: Vault ID for Multiple Passwords**

If you manage different Vaults (dev, prod, test), use Vault IDs.

Example:

```bash
ansible-playbook site.yml --vault-id dev@prompt --vault-id prod@~/.prod_vault
```

This lets Ansible use different passwords for different Vault files in the same run.

---

## **12. Best Practices**

| ✅ Do                                     | ❌ Don’t                                |
| ---------------------------------------- | -------------------------------------- |
| Keep Vault password files outside Git    | Commit password files to repo          |
| Use strong Vault passwords               | Use short or guessable Vault passwords |
| Restrict permissions (`chmod 600`)       | Leave Vault file world-readable        |
| Use different Vault IDs for environments | Reuse one password for all Vaults      |
| Use hash filters for user passwords      | Store plain passwords in variables     |

---

## **13. Troubleshooting**

| Issue                                             | Fix                                                             |
| ------------------------------------------------- | --------------------------------------------------------------- |
| “Attempting to decrypt but no vault secret found” | Add `--ask-vault-pass` or `--vault-password-file`               |
| “User module requires hashed password”            | Add `password_hash('sha512')`                                   |
| “Vault password mismatch”                         | Verify you’re using the correct Vault password                  |
| Vault file missing                                | Ensure path in `vars_files` is correct and relative to playbook |

---

## **14. Hands-On Practice**

### Exercise 1

Create `vault_vars.yml`:

```bash
ansible-vault create vault_vars.yml
```

Content:

```yaml
api_key: 12345-XYZ
token: abcd9999
```

### Exercise 2

Use in playbook:

```yaml
vars_files:
  - vault_vars.yml

tasks:
  - debug:
      msg: "Using API key {{ api_key }}"
```

Run:

```bash
ansible-playbook demo.yml --ask-vault-pass
```

✅ You’ll see the decrypted value displayed securely at runtime.

---

## **15. Summary**

| Concept                    | Description                                                    |
| -------------------------- | -------------------------------------------------------------- |
| **Vault in Playbooks**     | Securely include encrypted variables inside Ansible tasks      |
| **Execution Options**      | `--ask-vault-pass` or `--vault-password-file`                  |
| **Hashing Required**       | For modules like `user`, use `password_hash()`                 |
| **Automation**             | Store Vault password in a secure file for non-interactive runs |
| **Security Best Practice** | Never commit Vault password files to Git                       |












## **2. Why Do We Need Loops?**

Often, administrators repeat similar tasks — such as:

* Installing multiple packages
* Creating multiple users
* Enabling multiple services

Without loops, you would need to write **separate tasks** for each item.

✅ **Loops save time** and make your playbooks shorter, more dynamic, and easier to maintain.

---

## **3. Example: Installing Multiple Packages**

### Before (Without Loops)

```yaml
---
- name: Install packages
  hosts: nodes
  become: true

  tasks:
    - name: Install httpd
      yum:
        name: httpd
        state: present

    - name: Install firewalld
      yum:
        name: firewalld
        state: present
```

This works, but it’s repetitive — two nearly identical tasks.

---

## **4. Using Module’s Built-in Multiple Items Support**

Some modules like `yum` or `apt` **natively support multiple packages** as a list.

### Improved Version

```yaml
- name: Install multiple packages
  yum:
    name:
      - httpd
      - firewalld
    state: present
```

✅ Output:

```
TASK [Install multiple packages]
changed: [node1]
changed: [node2]
```

Now, one task installs both packages.

---

## **5. Controlling Services Without Repetition**

You now need to **start and enable** both services.
Unlike the `yum` module, the `service` module does **not** support multiple names.

### Without Loop

```yaml
- name: Enable httpd
  service:
    name: httpd
    state: started
    enabled: true

- name: Enable firewalld
  service:
    name: firewalld
    state: started
    enabled: true
```

✅ Works, but again — repetitive!

---

## **6. Using Loops with Services**

Let’s use a loop instead.

### Using `loop`

```yaml
- name: Start and enable services
  service:
    name: "{{ item }}"
    state: started
    enabled: true
  loop:
    - httpd
    - firewalld
```

✅ Output:

```
TASK [Start and enable services]
changed: [node1] => (item=httpd)
changed: [node1] => (item=firewalld)
changed: [node2] => (item=httpd)
changed: [node2] => (item=firewalld)
```

Now the same operation happens in **one task**, iterating over each service.

---

## **7. Understanding the `loop` Variable**

* The loop variable by default is named **`item`**
* You can rename it using `loop_control` (e.g., `loop_var`)

Example:

```yaml
- name: Enable services using custom loop var
  service:
    name: "{{ svc }}"
    state: started
    enabled: true
  loop:
    - httpd
    - firewalld
  loop_control:
    loop_var: svc
```

✅ Output:

```
TASK [Enable services using custom loop var]
ok: [node1] => (item=httpd)
ok: [node1] => (item=firewalld)
```

---

## **8. Example 2 – Using Loops with Lists**

Now let’s define a list variable and iterate through it.

### Variables

```yaml
vars:
  user_list:
    - user101
    - user102
    - user103
```

### Displaying List Items

```yaml
- name: Show user names
  debug:
    msg: "{{ item }}"
  loop: "{{ user_list }}"
```

✅ Output:

```
ok: [node1] => (item=user101) => "user101"
ok: [node1] => (item=user102) => "user102"
ok: [node1] => (item=user103) => "user103"
```

Each value in `user_list` is looped through and printed.

---

## **9. Example 3 – Creating Multiple Users with Loops**

Now we’ll create users dynamically instead of repeating tasks.

```yaml
---
- name: Create multiple users
  hosts: nodes
  become: true

  vars:
    user_list:
      - user101
      - user102
      - user103

  tasks:
    - name: Create users
      user:
        name: "{{ item }}"
        state: present
      loop: "{{ user_list }}"
```

✅ Output:

```
TASK [Create users]
changed: [node1] => (item=user101)
changed: [node1] => (item=user102)
changed: [node1] => (item=user103)
changed: [node2] => (item=user101)
changed: [node2] => (item=user102)
changed: [node2] => (item=user103)
```

Each username from the list is created on all nodes.

---

## **10. Legacy Loop Syntax (`with_items`)**

Before `loop:` was introduced, Ansible used `with_items:`.
It still works for backward compatibility.

```yaml
- name: Create users (old syntax)
  user:
    name: "{{ item }}"
    state: present
  with_items:
    - user101
    - user102
    - user103
```

✅ Recommended: always prefer **`loop:`** in modern playbooks.

---

## **11. Looping Over Dictionaries**

You can also loop through a dictionary (key-value pairs).

```yaml
vars:
  packages:
    httpd: present
    firewalld: latest

tasks:
  - name: Install packages with state
    yum:
      name: "{{ item.key }}"
      state: "{{ item.value }}"
    loop: "{{ packages | dict2items }}"
```

✅ Output:

```
TASK [Install packages with state]
changed: [node1] => (item={'key': 'httpd', 'value': 'present'})
changed: [node1] => (item={'key': 'firewalld', 'value': 'latest'})
```

---

## **12. Combining Loops and Conditionals**

You can use `when` with loops to filter certain items.

```yaml
vars:
  services:
    - httpd
    - firewalld
    - docker

tasks:
  - name: Start only httpd and firewalld
    service:
      name: "{{ item }}"
      state: started
    loop: "{{ services }}"
    when: item != 'docker'
```

✅ Output:

```
TASK [Start only httpd and firewalld]
ok: [node1] => (item=httpd)
ok: [node1] => (item=firewalld)
skipping: [node1] => (item=docker)
```

---

## **13. Summary of Loop Types**

| Type                 | Example                    | Use Case                    |                     |
| -------------------- | -------------------------- | --------------------------- | ------------------- |
| **Simple list loop** | `loop: "{{ list }}"`       | Repeating tasks with a list |                     |
| **Dictionary loop**  | `loop: "{{ dict            | dict2items }}"`             | Key-value iteration |
| **Nested loops**     | `subelements` or `product` | Complex relations           |                     |
| **File-based loop**  | `with_fileglob`            | Read items from files       |                     |
| **Until loops**      | `until:`                   | Retry until success         |                     |

---

## **14. When to Use Loops**

✅ Use loops when:

* The **task module does not support multiple inputs** (like `service`)
* You have a **list or dictionary** of similar items
* You want to **reduce repetitive code**

❌ Don’t use loops when:

* The module already accepts multiple items (like `yum`)

---

## **15. Real-World Use Cases**

| Use Case                    | Example                             |
| --------------------------- | ----------------------------------- |
| Create multiple Linux users | `user` module with `loop`           |
| Manage firewall rules       | `firewalld` module with `loop`      |
| Deploy multiple web servers | `template` or `copy` with `loop`    |
| Add SSH keys for users      | `authorized_key` module with `loop` |

---

## **16. Hands-On Practice**

### 🧠 Task 1:

Create a playbook to install and start three services (`httpd`, `firewalld`, `nginx`).

### 🧠 Task 2:

Create five users using a loop and verify with:

```bash
ansible nodes -a "cat /etc/passwd | grep user"
```

---

## **17. Key Takeaways**

| Concept                      | Description                                 |
| ---------------------------- | ------------------------------------------- |
| **Loop**                     | Repeats a single task for multiple items    |
| **Variable name**            | Default is `item`, can be renamed           |
| **`loop:` vs `with_items:`** | `loop:` is modern, preferred syntax         |
| **Can combine with `when`**  | To add conditional logic                    |
| **Simplifies playbooks**     | Reduces redundancy and improves readability |













## **2. What Are Conditionals in Ansible?**

Conditional execution allows you to:

* Run or skip tasks depending on **variable values**
* Make playbooks **dynamic** and **environment-aware**
* React to real-time system data like OS type, memory, or CPU

### Example Scenarios

* Install a package only on **RedHat-based systems**
* Create a user **only if it doesn’t exist**
* Restart a service **only when memory ≥ 512MB**
* Run a task **only if a variable is defined**

---

## **3. Syntax: Using `when`**

The keyword **`when`** is used to define conditions in Ansible.
It evaluates a **Jinja2 expression** that returns `true` or `false`.

### Basic Example

```yaml
tasks:
  - name: Install httpd only if condition is true
    yum:
      name: httpd
      state: present
    when: install_package
```

Here:

* If `install_package` = `true`, the task runs.
* If `install_package` = `false`, the task is **skipped**.

---

## **4. Boolean-Based Condition**

```yaml
vars:
  install_package: false

tasks:
  - name: Install Apache
    yum:
      name: httpd
      state: present
    when: install_package
```

✅ Output:

```
TASK [Install Apache]
skipping: [node1]
```

If you change it to `true`, the task executes:

```yaml
install_package: true
```

✅ Output:

```
TASK [Install Apache]
changed: [node1]
```

---

## **5. Using `not` Keyword**

You can invert the condition using `not`.

```yaml
when: not install_package
```

If `install_package` is `false`, this task will execute.

---

## **6. String Comparison**

You can compare string values directly.

```yaml
vars:
  install_package: "ok"

tasks:
  - name: Run task only if value equals 'ok'
    yum:
      name: httpd
      state: present
    when: install_package == "ok"
```

✅ Output:

```
TASK [Run task only if value equals 'ok']
changed: [node1]
```

If the string doesn’t match, the task will be skipped.

---

## **7. Multi-Condition Example (AND / OR)**

You can combine multiple conditions using:

* `and` → all must be true
* `or` → at least one must be true

### Example

```yaml
vars:
  install_package: true
  os_type: "RedHat"

tasks:
  - name: Install only on RedHat systems
    yum:
      name: httpd
      state: present
    when: install_package and os_type == "RedHat"
```

✅ Output:

```
TASK [Install only on RedHat systems]
changed: [node1]
```

---

## **8. Using Ansible Facts in Conditions**

Ansible automatically collects facts about the system (like OS, RAM, CPU).

You can access them with the `ansible_` prefix.

Example fact:

```yaml
ansible_distribution
```

---

### Example – Run only on RedHat or Fedora

```yaml
vars:
  install_package: true
  supported_os:
    - RedHat
    - Fedora

tasks:
  - name: Install only on supported OS
    yum:
      name: httpd
      state: present
    when:
      - install_package
      - ansible_distribution in supported_os
```

✅ Output (CentOS system):

```
TASK [Install only on supported OS]
skipping: [node1]
```

✅ Output (RedHat system):

```
TASK [Install only on supported OS]
changed: [node1]
```

---

## **9. Checking If a Variable Is Defined**

Sometimes you want to ensure a variable exists before using it.

### Example

```yaml
tasks:
  - name: Run only if variable is defined
    debug:
      msg: "The variable exists"
    when: min_memory is defined
```

If `min_memory` isn’t declared:

```
skipping: [node1]
```

Once you define it:

```yaml
vars:
  min_memory: 256
```

✅ Output:

```
TASK [Run only if variable is defined]
ok: [node1] => "The variable exists"
```

---

## **10. Comparing Numeric Values**

You can compare integers too.

```yaml
vars:
  memory_mb: 512

tasks:
  - name: Run only if memory is sufficient
    debug:
      msg: "Enough memory to continue"
    when: memory_mb >= 256
```

✅ Output:

```
ok: [node1] => "Enough memory to continue"
```

---

## **11. Complex Example – Multiple Conditions**

This combines boolean, list, and fact checks.

```yaml
vars:
  install_package: true
  supported_os: ["RedHat", "CentOS", "Fedora"]
  min_memory: 256

tasks:
  - name: Install Apache only on supported systems
    yum:
      name: httpd
      state: present
    when:
      - install_package
      - ansible_distribution in supported_os
      - min_memory is defined
```

✅ Output:

```
TASK [Install Apache only on supported systems]
changed: [node1]
```

If one condition fails, the task will be skipped.

---

## **12. Example – Using OR (`or`)**

```yaml
vars:
  env: "dev"

tasks:
  - name: Run on dev or test
    debug:
      msg: "Running for development or testing"
    when: env == "dev" or env == "test"
```

✅ Output:

```
ok: [node1] => "Running for development or testing"
```

---

## **13. Example – Using Facts for Memory Condition**

You can also use Ansible facts to check system memory.

```yaml
tasks:
  - name: Run only if node has enough RAM
    debug:
      msg: "System has enough memory"
    when: ansible_memtotal_mb >= 1024
```

✅ If node has 1GB+ memory → task runs
❌ Otherwise → task is skipped

---

## **14. Combining `when` With Loops**

You can apply conditions within loops too.

```yaml
vars:
  services:
    - httpd
    - firewalld
    - docker

tasks:
  - name: Start only httpd and firewalld
    service:
      name: "{{ item }}"
      state: started
    loop: "{{ services }}"
    when: item != "docker"
```

✅ Output:

```
TASK [Start only httpd and firewalld]
ok: [node1] => (item=httpd)
ok: [node1] => (item=firewalld)
skipping: [node1] => (item=docker)
```

---

## **15. Summary of Conditional Operators**

| Operator     | Description           | Example               |
| ------------ | --------------------- | --------------------- |
| `==`         | Equal to              | `os == 'RedHat'`      |
| `!=`         | Not equal to          | `os != 'Ubuntu'`      |
| `>` / `<`    | Greater / Less than   | `memory > 256`        |
| `>=` / `<=`  | Greater/less or equal | `memory >= 1024`      |
| `in`         | Value exists in list  | `os in supported_os`  |
| `is defined` | Variable exists       | `var is defined`      |
| `not`        | Logical NOT           | `not install_package` |
| `and` / `or` | Logical combination   | `a and b`, `a or b`   |

---

## **16. Real-World DevOps Use Cases**

| Use Case                        | Condition Example                         |
| ------------------------------- | ----------------------------------------- |
| Install packages only on RedHat | `ansible_distribution == 'RedHat'`        |
| Skip tasks on staging           | `env != 'staging'`                        |
| Run task only if file exists    | `ansible_facts['os_family'] == 'Debian'`  |
| Restart service only if updated | `when: service_changed`                   |
| Apply patch only for RHEL ≥ 8   | `ansible_distribution_major_version >= 8` |

---

## **17. Key Takeaways**

| Concept                       | Description                               |
| ----------------------------- | ----------------------------------------- |
| **`when` keyword**            | Controls whether a task executes          |
| **Supports all data types**   | Boolean, string, integer, lists           |
| **Works with facts**          | Example: `ansible_distribution`           |
| **Can use logical operators** | `and`, `or`, `not`                        |
| **Prevents errors**           | Check if variable `is defined` before use |

---

## **18. Practice Task**

### Create a playbook:

1. Install NGINX only if:

   * OS is Ubuntu or Debian
   * `install_package = true`
   * `ansible_memtotal_mb >= 1024`

2. Print `"Skipped due to insufficient memory"` when the condition fails.














## **2. What Is a Handler?**

A **handler** is a special type of Ansible task that runs **only when notified** by another task.

Handlers are most commonly used for:

* Restarting or reloading services
* Rebuilding configurations
* Sending notifications after a change

---

### **Key Concepts**

| Property              | Description                                     |
| --------------------- | ----------------------------------------------- |
| **Triggered**         | Only run when a task reports a change           |
| **Unique name**       | Each handler name must be unique                |
| **Executed once**     | Runs only once, even if notified multiple times |
| **Run order**         | Executes **after all tasks** in a play finish   |
| **Not auto-executed** | If no task calls it, it will not run            |

---

## **3. When Are Handlers Triggered?**

Handlers are triggered **only when a task reports “changed”** status.

For example:

* If you use `yum` to install a package that’s already installed → status is `ok`, **no handler runs**.
* If the package is newly installed → status is `changed`, **handler runs**.

---

## **4. Handler Workflow**

**Step-by-step flow:**

1. A task changes something and issues a `notify` directive.
2. Ansible marks the referenced handler for execution.
3. After all tasks complete, Ansible runs all triggered handlers once.

---

## **5. Basic Playbook Example**

```yaml
---
- name: Demo of Handlers
  hosts: nodes
  become: true

  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present
      notify: restart httpd

  handlers:
    - name: restart httpd
      service:
        name: httpd
        state: restarted
```

✅ **Explanation:**

* The `notify` line tells Ansible to trigger the handler.
* The handler runs **only if the task reports a change**.
* It restarts the `httpd` service after all tasks in the play finish.

---

## **6. Example: Multiple Tasks Triggering the Same Handler**

You can have multiple tasks notifying the same handler.

```yaml
tasks:
  - name: Install Apache
    yum:
      name: httpd
      state: present
    notify: restart httpd

  - name: Deploy web page
    copy:
      src: index.html
      dest: /var/www/html/index.html
    notify: restart httpd

handlers:
  - name: restart httpd
    service:
      name: httpd
      state: restarted
```

✅ Even though both tasks notify the same handler,
the handler will run **only once** and **at the end of the play**.

---

## **7. Handler Behavior Demo**

| Scenario                      | Result                |
| ----------------------------- | --------------------- |
| Package already installed     | Handler not triggered |
| Configuration file changed    | Handler triggered     |
| Two tasks notify same handler | Runs only once        |
| No task notifies handler      | Handler skipped       |

---

## **8. Example Output**

```
TASK [Install Apache]
changed: [node1]
ok: [node2]

TASK [Deploy web page]
changed: [node1]
ok: [node2]

RUNNING HANDLER [restart httpd]
changed: [node1]
skipping: [node2]
```

✅ Node1 restarted Apache (changed)
❌ Node2 did not (no change)

---

## **9. Multiple Handlers**

You can define and notify multiple handlers.

```yaml
tasks:
  - name: Install Nginx
    yum:
      name: nginx
      state: present
    notify:
      - restart nginx
      - reload firewall

handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted

  - name: reload firewall
    service:
      name: firewalld
      state: reloaded
```

✅ Both handlers run sequentially at the end of the play (if changes occur).

---

## **10. Example: Restart Triggered Only by Change**

```yaml
tasks:
  - name: Copy nginx config
    copy:
      src: nginx.conf
      dest: /etc/nginx/nginx.conf
    notify: restart nginx

handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
```

✅ If `nginx.conf` hasn’t changed, handler won’t run.

---

## **11. Important Rules About Handlers**

| Rule                           | Explanation                                   |
| ------------------------------ | --------------------------------------------- |
| **Handlers run once per play** | Even if notified many times                   |
| **Run after tasks**            | Executed only after all normal tasks finish   |
| **Name uniqueness**            | Handler names must be globally unique         |
| **Triggered by change**        | Run only when notified task changes state     |
| **Optional trigger**           | If no task notifies → handler skipped         |
| **Can be reused**              | Multiple tasks can reference the same handler |

---

## **12. Real-Life Use Cases**

| Use Case                               | Example                    |
| -------------------------------------- | -------------------------- |
| Restart web server after config update | `notify: restart httpd`    |
| Reload firewall after rule change      | `notify: reload firewalld` |
| Restart database after schema update   | `notify: restart mysql`    |
| Rebuild app after code deploy          | `notify: rebuild app`      |

---

## **13. Example: Combining Loops, Conditions, and Handlers**

```yaml
---
- name: Web service setup
  hosts: webservers
  become: true

  tasks:
    - name: Install packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - firewalld
      notify: restart web

    - name: Copy index.html
      copy:
        src: index.html
        dest: /var/www/html/index.html
      when: ansible_os_family == "RedHat"
      notify: restart web

  handlers:
    - name: restart web
      service:
        name: httpd
        state: restarted
```

✅ Handler runs once even though multiple tasks notify it.
✅ Executes only if something changed.

---

## **14. Advanced Example: Handler with Conditional Execution**

Handlers can also have conditions:

```yaml
handlers:
  - name: restart nginx
    service:
      name: nginx
      state: restarted
    when: ansible_os_family == "RedHat"
```

✅ Only runs on RedHat-based systems even if notified.

---

## **15. Forcing Immediate Execution**

By default, handlers run at the end of the play.
To run a handler **immediately**, use the `meta` module:

```yaml
- meta: flush_handlers
```

Example:

```yaml
tasks:
  - name: Copy new config
    copy:
      src: my.cnf
      dest: /etc/my.cnf
    notify: restart mysql

  - meta: flush_handlers
```

✅ Forces handler execution **immediately after this point**.

---

## **16. Troubleshooting Common Handler Issues**

| Issue                       | Reason                                   | Fix                                  |
| --------------------------- | ---------------------------------------- | ------------------------------------ |
| Handler doesn’t run         | Task didn’t report “changed”             | Verify module result or force change |
| Handler runs multiple times | Same handler name used in multiple plays | Use unique names                     |
| Handler not found           | Typo in notify name                      | Ensure handler name matches exactly  |
| Handler skipped             | No task triggered it                     | Check notify statements              |

---

## **17. Best Practices for Handlers**

✅ Keep handlers **simple** — only perform one action.
✅ Use **clear, descriptive names** (e.g., `restart nginx`, `reload firewall`).
✅ Place all handlers in a **dedicated section** at the end of the playbook.
✅ Use handlers only for **post-change actions**, not for regular tasks.
✅ Use `meta: flush_handlers` for immediate effects if necessary.

---

## **18. Hands-On Lab Exercise**

### Create a Playbook:

* Installs Apache (`httpd`)
* Copies a configuration file `/etc/httpd/conf/httpd.conf`
* Notifies a handler to restart Apache
* Verifies that handler only runs when configuration changes

Test by:

1. Running the playbook twice.
2. Observe that handler runs only during the first run (when file changes).

---

## **19. Summary**

| Concept                   | Description                               |
| ------------------------- | ----------------------------------------- |
| **Handler**               | Special task triggered by another task    |
| **Notify**                | Directive used to call a handler          |
| **Triggered on change**   | Runs only when task reports `changed`     |
| **Executes once**         | Even if multiple tasks notify it          |
| **Runs after play tasks** | Unless forced with `meta: flush_handlers` |














## **2. Why Task Failure Handling Matters**

| Scenario             | Behavior without handling  | Desired behavior                     |
| -------------------- | -------------------------- | ------------------------------------ |
| Wrong package name   | Playbook stops immediately | Skip and continue                    |
| Non-critical error   | Stops all subsequent tasks | Ignore and continue                  |
| Critical validation  | Continues executing        | Stop immediately with custom message |
| Handler notification | Skipped if a task fails    | Still run handlers if required       |

---

## **3. Default Behavior**

By default, **if one task fails**, Ansible:

* Stops executing further tasks on that host.
* Marks the play as **FAILED**.
* Skips the rest of the tasks for that host.

---

## **4. Option 1 – Ignoring Errors**

If you want the playbook to **continue even when a task fails**,
use the `ignore_errors` keyword.

```yaml
---
- name: Demo ignore_errors
  hosts: all
  become: true

  tasks:
    - name: Install invalid package
      yum:
        name: wrongpackage
        state: present
      ignore_errors: yes

    - name: Continue execution
      debug:
        msg: "Package installation failed, but playbook continues"
```

✅ **Result:**
Ansible prints “FAILED”, then “Ignoring”, and continues executing next tasks.

---

## **5. Option 2 – Force Handlers**

Normally, if a task fails, **handlers will not run**.

If you want to **force handlers to run** even after failure,
use the keyword `force_handlers: true` at the **play level**.

```yaml
---
- name: Force handler execution
  hosts: all
  become: true
  force_handlers: true

  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present
      notify: restart httpd

    - name: Fail on purpose
      yum:
        name: invalid-package
        state: present

  handlers:
    - name: restart httpd
      service:
        name: httpd
        state: restarted
```

✅ Even if one task fails, **handlers still run** if they were notified before failure.

---

## **6. Option 3 – Using the `fail` Module**

The `fail` module allows you to **intentionally stop** a playbook with a custom error message.

```yaml
- name: Stop playbook if conditions are not met
  fail:
    msg: "Playbook stopped because system does not meet requirements."
```

You can combine it with conditions:

```yaml
- name: Fail if variable is not defined
  fail:
    msg: "Variable 'my_var' is missing!"
  when: my_var is not defined
```

✅ This is useful for **validation checks**, such as:

* Missing required variables
* Unsupported OS
* Insufficient memory or CPU

---

## **7. Option 4 – Conditional Failure Based on Task Results**

You can register the result of one task and fail later based on it.

```yaml
---
- name: Conditional failure demo
  hosts: all
  become: true

  tasks:
    - name: Try installing invalid package
      yum:
        name: wrongpackage
        state: present
      ignore_errors: yes
      register: result

    - name: Display result
      debug:
        var: result

    - name: Fail if package installation failed
      fail:
        msg: "Playbook failed because package installation failed."
      when: result.failed
```

✅ **Explanation:**

* The first task fails but continues (`ignore_errors: yes`).
* The result is saved in the variable `result`.
* The next task checks `result.failed`.
* If it’s `true`, the playbook fails intentionally.

---

## **8. Option 5 – Controlling “Changed” Status with `changed_when`**

Sometimes, Ansible marks a task as *changed* even though it did not modify anything.
You can control this using `changed_when`.

```yaml
---
- name: Demo changed_when
  hosts: all
  become: true

  tasks:
    - name: Check uptime
      shell: uptime
      register: uptime_result
      changed_when: false

    - name: Print uptime
      debug:
        var: uptime_result.stdout
```

✅ **Explanation:**

* Even though the `shell` module runs a command, it didn’t change the system.
* So `changed_when: false` prevents Ansible from showing it as “changed”.

---

### **Example – Conditional Changed Status**

```yaml
- name: Example with condition
  shell: uptime
  register: output
  changed_when: "'success' in output.stdout"
```

✅ Task will only show “changed” if the word “success” appears in the command output.

---

## **9. Option 6 – Controlling Failure with `failed_when`**

You can also decide when a task should be **marked as failed**.

```yaml
---
- name: Fail when a variable is missing
  shell: uptime
  failed_when: my_variable is not defined
```

✅ Ansible will mark the task as failed even though the command succeeded.

---

## **10. Combining `changed_when` and `failed_when`**

You can control both simultaneously:

```yaml
---
- name: Execute uptime and manage status manually
  hosts: all
  become: true

  tasks:
    - name: Run uptime command
      shell: uptime
      register: result
      changed_when: "'load' in result.stdout"
      failed_when: "'error' in result.stderr"
```

✅ **Behavior:**

* Task marked as *changed* only if “load” appears in output.
* Task *fails* only if “error” appears in stderr.

---

## **11. Real-World Example: Deployment Logic**

```yaml
---
- name: Web Deployment with Error Handling
  hosts: webservers
  become: true
  force_handlers: true

  tasks:
    - name: Install web packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - php
        - mariadb-server
      ignore_errors: yes
      register: install_result

    - name: Fail if all installations failed
      fail:
        msg: "All packages failed to install."
      when: install_result.results | map(attribute='failed') | select('equalto', true) | list | length == 3

    - name: Copy config file
      copy:
        src: index.php
        dest: /var/www/html/index.php
      notify: restart apache

  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

✅ **Explanation:**

* Uses `ignore_errors` for non-critical packages.
* Uses a `fail` condition if all tasks fail.
* Ensures `httpd` restarts even after minor errors using `force_handlers`.

---

## **12. Quick Reference Table**

| Keyword            | Purpose                                  | Example                            |
| ------------------ | ---------------------------------------- | ---------------------------------- |
| **ignore_errors**  | Continue after failure                   | `ignore_errors: yes`               |
| **force_handlers** | Run handlers even after failure          | `force_handlers: true`             |
| **fail**           | Stop playbook with message               | `fail: msg: "Stopping now"`        |
| **changed_when**   | Customize when Ansible reports “changed” | `changed_when: false`              |
| **failed_when**    | Customize when Ansible reports “failed”  | `failed_when: my_var is undefined` |

---

## **13. Common Patterns**

| Situation                         | Solution                  |
| --------------------------------- | ------------------------- |
| Continue after non-critical error | `ignore_errors: yes`      |
| Fail if critical condition met    | `fail` module             |
| Always run restart handler        | `force_handlers: true`    |
| Avoid false “changed” status      | `changed_when: false`     |
| Detect custom failure condition   | `failed_when:` expression |

---

## **14. Practical Exercise for Students**

### Task:

Create a playbook that:

1. Installs a package that doesn’t exist.
2. Ignores the failure and continues.
3. Prints the result.
4. Fails intentionally if the task failed.
5. Logs output to a file.

Expected behavior:

* Ansible continues after failure.
* Logs error.
* Fails at the final check.

---

## **15. Summary**

| Concept            | Description                              |
| ------------------ | ---------------------------------------- |
| **ignore_errors**  | Continue execution after a failed task   |
| **force_handlers** | Run handlers even if a task fails        |
| **fail**           | Stop playbook with a custom message      |
| **changed_when**   | Control when a task is marked as changed |
| **failed_when**    | Control when a task is marked as failed  |













## **2. Why We Need Blocks**

In large playbooks you might:

* Execute 5–10 related tasks that depend on each other
* Need to recover gracefully if any task in that group fails
* Always run cleanup steps (restart services, remove temp files, etc.)

`block` groups multiple tasks together, and if any one fails, Ansible can:

* **Rescue:** run alternate steps or rollback logic
* **Always:** execute cleanup tasks regardless of success or failure

---

## **3. Basic Structure**

```yaml
tasks:
  - block:
      # main (try) section
      - name: Step 1 – Primary action
        yum:
          name: httpd
          state: present

      - name: Step 2 – Intentional error
        yum:
          name: wrongpackage
          state: present

    rescue:
      # runs only if any task in the block fails
      - name: Handle failure
        debug:
          msg: "Installation failed – rolling back"

    always:
      # runs whether block succeeds or fails
      - name: Cleanup phase
        debug:
          msg: "Playbook completed – cleanup done"
```

✅ **Behavior**

* The first task installs Apache.
* The second fails → Ansible jumps to `rescue`.
* After `rescue`, `always` runs.

---

## **4. Execution Flow**

| Stage      | Description                                  |
| ---------- | -------------------------------------------- |
| **block**  | Main tasks to try first                      |
| **rescue** | Executes only if anything inside block fails |
| **always** | Executes no matter what (success or failure) |

---

## **5. Example 1 – Simple Failure Recovery**

```yaml
---
- name: Demo block and rescue
  hosts: web
  become: true

  tasks:
    - block:
        - name: Install invalid package
          yum:
            name: wrongpackage
            state: present

      rescue:
        - name: Print error
          debug:
            msg: "Package not found – installing nginx instead"

        - name: Install nginx as backup
          yum:
            name: nginx
            state: present

      always:
        - name: Always execute
          debug:
            msg: "Execution finished (success or fail)"
```

✅ **Output**

* The first task fails.
* Rescue runs and installs nginx.
* Always runs at the end.

---

## **6. Example 2 – Successful Block**

```yaml
- block:
    - name: Install httpd
      yum:
        name: httpd
        state: present

  rescue:
    - debug: msg: "Rescue called only on failure"

  always:
    - debug: msg: "Always section runs"
```

✅ **Output:**

* `httpd` installs successfully → no rescue.
* `always` still runs.

---

## **7. Real-World Scenario**

Imagine a multi-step deployment:

```yaml
- block:
    - name: Stop old service
      service: {name: app, state: stopped}

    - name: Deploy new binary
      copy: {src: app.jar, dest: /opt/app/app.jar}

    - name: Start service
      service: {name: app, state: started}

  rescue:
    - name: Rollback deployment
      copy: {src: backup/app.jar, dest: /opt/app/app.jar}
    - service: {name: app, state: restarted}

  always:
    - name: Notify admin
      mail:
        to: devops@example.com
        subject: "Deployment completed with status {{ ansible_failed_task is defined | ternary('FAILED','SUCCESS') }}"
        body: "See logs for details."
```

✅ Ensures:

* Deployment runs fully or rolls back on error.
* Always notifies the team.

---

## **8. Indentation and Syntax Tips**

| Element  | Must Be                                   | Notes                        |
| -------- | ----------------------------------------- | ---------------------------- |
| `block`  | Same indent level as a regular task       | Has a list of tasks under it |
| `rescue` | Same indent level as `block`              | No hyphen before keyword     |
| `always` | Same indent level as `block` and `rescue` | Optional section             |

---

## **9. Multiple Tasks in Each Section**

```yaml
tasks:
  - block:
      - debug: msg: "Attempt to install httpd"
      - yum: {name: wrongpkg, state: present}
    rescue:
      - debug: msg: "Installing nginx as fallback"
      - yum: {name: nginx, state: present}
    always:
      - debug: msg: "Cleanup phase"
```

✅ You can add **any number of tasks** under each section.

---

## **10. Nested Blocks (Optional Advanced)**

Blocks can be nested for complex error control:

```yaml
- block:
    - block:
        - shell: cmd1
        - shell: cmd2
      rescue:
        - debug: msg: "Inner rescue"
  rescue:
    - debug: msg: "Outer rescue"
```

---

## **11. Best Practices**

✅ Use blocks for logically related tasks.
✅ Keep rescue actions idempotent (safe to rerun).
✅ Always log errors inside rescue.
✅ Use `always` for notification, cleanup or audit logging.
✅ Avoid mixing `ignore_errors` with blocks unless necessary.

---

## **12. Quick Reference Table**

| Keyword   | Purpose                  | Runs When                     |
| --------- | ------------------------ | ----------------------------- |
| `block:`  | Primary tasks to attempt | Always                        |
| `rescue:` | Error-handling tasks     | When any task in block fails  |
| `always:` | Cleanup tasks            | Always after block and rescue |

---

## **13. Hands-On Lab**

**Task:**
Create a playbook that:

1. Tries to install `wrongpackage` (first task).
2. If it fails, installs `nginx` in rescue.
3. Always prints “Playbook execution finished”.

✅ Expected Result:

* Failure handled gracefully.
* Nginx installed as backup.
* Always section executes.

---

## **14. Comparison with Programming Concepts**

| Ansible  | Equivalent in Python |
| -------- | -------------------- |
| `block`  | `try:`               |
| `rescue` | `except:`            |
| `always` | `finally:`           |

---

## **15. Key Takeaways**

| Concept           | Explanation                                           |
| ----------------- | ----------------------------------------------------- |
| **Blocks**        | Group tasks for error handling                        |
| **Rescue**        | Execute backup or recovery steps on failure           |
| **Always**        | Run cleanup logic regardless of result                |
| **Indentation**   | Must be consistent for Ansible to recognize structure |
| **Real Use Case** | Rollback deployments or handle service failures       |











## **2  |  What Is a Jinja2 Template?**

A **Jinja2 template** is a text file (usually ending `.j2`) containing:

* **Static text** (plain configuration or messages)
* **Dynamic placeholders** in `{{ … }}`
* Optional **logic blocks** in `{% … %}` (loops, ifs)

When rendered by Ansible, placeholders are replaced by **variable values** or **facts**.

---

## **3  |  Typical Use Cases**

| Use Case            | Example                                  |
| ------------------- | ---------------------------------------- |
| Login banner        | `/etc/motd`                              |
| Config file         | `nginx.conf`, `httpd.conf`, `/etc/hosts` |
| Report generation   | HTML or CSV from facts                   |
| Dynamic credentials | Per-host user, IP, port substitution     |

---

## **4  |  Simpler Alternatives vs Templates**

| Method         | Pros                     | Limits              |
| -------------- | ------------------------ | ------------------- |
| `lineinfile`   | Add/replace one line     | Only one line       |
| `blockinfile`  | Insert a text block      | No variable logic   |
| `copy`         | Copy entire static file  | No dynamic content  |
| **`template`** | Fully dynamic via Jinja2 | Slightly more setup |

---

## **5  |  Example 1 – Static Line Update**

```bash
ansible nodes -b -m lineinfile \
  -a "path=/etc/motd line='Welcome to Ansible Lab'"
```

✅ Works, but limited — can’t show hostnames or IPs dynamically.

---

## **6  |  Creating Your First Template**

### **Step 1 – Template File (`motd.j2`)**

```jinja2
Welcome to {{ ansible_hostname }}
IP Address: {{ ansible_facts.default_ipv4.address }}
This message is configured by Ansible.

Access is restricted. If you are not authorized, please logout.
For support, contact: {{ system_admin_email }}
```

### **Step 2 – Playbook (`site.yml`)**

```yaml
---
- name: Configure MOTD using Jinja2
  hosts: nodes
  become: true
  vars:
    system_admin_email: admin@lab.local

  tasks:
    - name: Deploy template
      template:
        src: motd.j2
        dest: /etc/motd
        owner: root
        group: root
        mode: '0644'
```

### **Step 3 – Run**

```bash
ansible-playbook site.yml
```

✅ The MOTD on each node now shows its own hostname & IP.

---

## **7  |  Common Facts Used in Templates**

| Variable                             | Description         |
| ------------------------------------ | ------------------- |
| `ansible_hostname`                   | Short host name     |
| `inventory_hostname`                 | Name from inventory |
| `ansible_facts.default_ipv4.address` | Primary IP address  |
| `ansible_facts.memtotal_mb`          | Total memory in MB  |
| `ansible_facts.processor_count`      | CPU core count      |

You can verify with:

```bash
ansible node1 -m setup | less
```

---

## **8  |  Variable Precedence & Definition**

If a template references `{{ system_admin_email }}`,
that variable must exist in one of:

* `vars:` section of playbook
* `group_vars/` or `host_vars/` files
* Inventory variables
* Registered output from a task

Undefined variables cause errors unless handled (see below).

---

## **9  |  Handling Undefined Variables**

```jinja2
Contact: {{ system_admin_email | default('support@example.com') }}
```

✅ Uses `default()` filter if variable is missing.

---

## **10  |  Example 2 – Decorative Login Banner**

```jinja2
#########################################################
# Welcome to {{ ansible_hostname }} – Ansible Managed #
# Primary IP: {{ ansible_facts.default_ipv4.address }} #
# CPU: {{ ansible_facts.processor_count }} Cores  RAM: {{ ansible_facts.memtotal_mb }} MB #
# Admin Contact: {{ system_admin_email }} #
#########################################################
```

Every node gets a unique, automatically generated banner.

---

## **11  |  Example 3 – Using Loops Inside Templates**

```jinja2
# /etc/hosts generated by Ansible
{% for host in groups['all'] %}
{{ hostvars[host].ansible_facts.default_ipv4.address }}  {{ host }}
{% endfor %}
```

✅ Generates a complete `/etc/hosts` file for all inventory members.

---

## **12  |  Template vs Copy Modules**

| Feature                  | `copy`      | `template`     |
| ------------------------ | ----------- | -------------- |
| Dynamic values           | ❌           | ✅              |
| Jinja2 support           | ❌           | ✅              |
| File permissions support | ✅           | ✅              |
| Common use               | Static file | Dynamic config |

---

## **13  |  Best Practices**

✅ Store templates in `templates/` directory inside your role.
✅ Keep variables in `group_vars/` or `host_vars/`.
✅ Use `default()` filter for optional fields.
✅ Test with `ansible -m template --check`.
✅ Comment templates with `# Ansible managed` to warn manual editors.

---

## **14  |  Advanced Features (to Explore Later)**

* `{% if … %}` conditionals inside templates
* `{% for item in list %}` loops
* Jinja2 filters (`upper`, `lower`, `join`, `regex_replace`)
* Template inheritance and custom macros
* Using `template` with `notify` handlers to restart services after config updates

---

## **15  |  Troubleshooting**

| Issue                        | Cause                   | Fix                                  |
| ---------------------------- | ----------------------- | ------------------------------------ |
| “Undefined variable”         | Missing vars definition | Use `default()` or define in `vars:` |
| “Permission denied”          | No `become: true`       | Add privilege escalation             |
| Template not rendering facts | `gather_facts: false`   | Enable fact collection               |

---

## **16  |  Hands-On Lab**

**Goal:**
Create a Jinja2 template that generates a system info report under `/etc/system_report.txt` containing:

* Hostname
* IP address
* Total memory
* CPU count
* Admin email

Then write a playbook to deploy it to all hosts.

---

## **17  |  Summary**

| Concept                | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| **Template**           | Generate dynamic files using variables       |
| **Jinja2 syntax**      | `{{ … }}` for variables, `{% … %}` for logic |
| **Facts**              | Provide host-specific data like IP or memory |
| **`default()`** filter | Prevent errors on undefined variables        |
| **Typical locations**  | `/templates` folder inside roles             |















# ** Loops, Conditions & Filters in Jinja2 Templates**

---



## **2  |  Why We Need Loops and Conditions**

In real projects:

* Not every host has all variables defined
* You might need to **print lists** (users, servers, IPs)
* You might want to **skip or include** sections conditionally

Jinja2 lets you control this with:

* **Filters** like `| default()`
* **Loops** using `{% for ... %}`
* **Conditionals** using `{% if ... %}`

---

## **3  |  Example 1 – Handling Missing Variables with `default()`**

### Template (`motd.j2`)

```jinja2
System Admin: {{ system_admin_email }}
Phone: {{ system_admin_phone | default('1800-111-2222') }}
```

If `system_admin_phone` isn’t defined, the **default value** is used.

### Playbook (`site.yml`)

```yaml
---
- name: MOTD Template with Default Filter
  hosts: nodes
  become: true
  vars:
    system_admin_email: admin@lab.local
    # system_admin_phone intentionally undefined

  tasks:
    - name: Deploy /etc/motd with Jinja2 template
      template:
        src: motd.j2
        dest: /etc/motd
```

✅ When executed, no error occurs — missing variables are replaced by the default.

---

## **4  |  Example 2 – Overriding the Default**

Now define the phone number:

```yaml
vars:
  system_admin_phone: 1800-000-0000
```

✅ Output now shows your custom number instead of the default.

---

## **5  |  Example 3 – Using Loops in Jinja2**

You can generate lists dynamically (e.g., usernames, IPs, or host entries).

### **Playbook (`site.yml`)**

```yaml
---
- name: Create a dynamic user list
  hosts: nodes
  become: true
  vars:
    users:
      - John
      - Lisa
      - Kevin
      - Maria
  tasks:
    - name: Deploy user list template
      template:
        src: user_list.j2
        dest: /tmp/user_list
```

### **Template (`user_list.j2`)**

```jinja2
# User list generated by Ansible
{% for user in users %}
{{ loop.index }}. {{ user }}
{% endfor %}
# End of list
```

✅ Output (`/tmp/user_list`):

```
# User list generated by Ansible
1. John
2. Lisa
3. Kevin
4. Maria
# End of list
```

---

## **6  |  Jinja2 Built-In Loop Variables**

| Variable      | Description                 |
| ------------- | --------------------------- |
| `loop.index`  | Current iteration (1-based) |
| `loop.index0` | Current iteration (0-based) |
| `loop.first`  | True if first item          |
| `loop.last`   | True if last item           |
| `loop.length` | Total number of items       |

**Example:**

```jinja2
{% for user in users %}
{% if loop.first %}--- Start of List ---{% endif %}
{{ loop.index }}. {{ user }}
{% if loop.last %}--- End of List ---{% endif %}
{% endfor %}
```

---

## **7  |  Example 4 – Using Conditions**

You can control rendering based on variable values.

```jinja2
{% if users %}
User list:
{% for user in users %}
- {{ user }}
{% endfor %}
{% else %}
No users found.
{% endif %}
```

✅ If the list is empty, the “No users found” message appears instead of a blank section.

---

## **8  |  Example 5 – Combining Loops & Facts**

You can combine **Ansible facts** with loops to generate reports:

```jinja2
# Network Interfaces
{% for iface, details in ansible_facts.interfaces.items() %}
Interface: {{ iface }}
{% if details.ipv4 %}
IP: {{ details.ipv4.address }}
{% endif %}
{% endfor %}
```

✅ Dynamically lists interfaces and IP addresses from each host.

---

## **9  |  Example 6 – Nested Loops**

You can loop inside another loop to handle grouped data.

```jinja2
{% for group, members in teams.items() %}
Team: {{ group }}
{% for user in members %}
  - {{ user }}
{% endfor %}
{% endfor %}
```

With variables:

```yaml
vars:
  teams:
    DevOps: ["John", "Lisa"]
    QA: ["Aisalkyn", "Raj"]
```

✅ Output:

```
Team: DevOps
  - John
  - Lisa
Team: QA
  - Aisalkyn
  - Raj
```

---

## **10  |  Example 7 – `default()` + Condition Combined**

```jinja2
Support: {{ support_email | default('helpdesk@example.com') }}
{% if support_email is defined %}
(Verified Contact)
{% else %}
(Default used)
{% endif %}
```

---

## **11  |  Common Mistakes**

| Issue                            | Cause                        | Fix                            |            |
| -------------------------------- | ---------------------------- | ------------------------------ | ---------- |
| Undefined variable error         | Missing var, no default      | Use `                          | default()` |
| Wrong indentation                | Incorrect spaces in template | Follow YAML/Jinja2 indentation |            |
| Loop prints `{% for ... %}` text | Missing `{% endfor %}`       | Always close loops             |            |
| No changes shown                 | Template unchanged           | Add or modify variables        |            |

---

## **12  |  Key Takeaways**

| Concept                      | Description              |               |
| ---------------------------- | ------------------------ | ------------- |
| **`{{ var }}`**              | Prints variable value    |               |
| **`                          | default('value')`**      | Sets fallback |
| **`{% for item in list %}`** | Iterates through list    |               |
| **`{% if condition %}`**     | Runs conditionally       |               |
| **`loop.index`**             | Returns iteration number |               |

---

## **13  |  Hands-On Lab**

**Task:**

1. Create a template `/templates/user_report.j2` to list usernames and email addresses from a variable.
2. Use loops to print them as numbered items.
3. Use `default()` for missing email fields.
4. Deploy it to `/tmp/user_report` using `template` module.

---

## **14  |  Summary**

You now know:

* How to use `default()` to prevent undefined variable errors
* How to use **for-loops** to iterate over lists or dictionaries
* How to apply **loop variables** like `loop.index`
* How to add **conditional rendering** (`if`, `else`)

















## **2  |  Why Use Roles**

Roles help you:

* Organize large playbooks into reusable components.
* Separate **tasks**, **handlers**, **variables**, and **templates** logically.
* Simplify sharing, versioning, and reusing automation.

Each role is a **self-contained mini-playbook**.

---

## **3  |  Ansible Role Directory Structure**

When you create a new role, Ansible auto-generates this structure:

```
roles/
└── myweb/
    ├── defaults/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── templates/
    ├── files/
    ├── vars/
    │   └── main.yml
    ├── meta/
    │   └── main.yml
    └── README.md
```

Each subfolder serves a purpose:

| Directory    | Purpose                                                     |
| ------------ | ----------------------------------------------------------- |
| `tasks/`     | Main logic (like installing packages, configuring services) |
| `handlers/`  | Restart/reload services when notified                       |
| `defaults/`  | Default variables                                           |
| `vars/`      | Hardcoded variables (higher priority than defaults)         |
| `templates/` | Jinja2 templates for dynamic files                          |
| `files/`     | Static files to copy                                        |
| `meta/`      | Role metadata (author, supported OS, dependencies)          |

---

## **4  |  Creating a Role**

Run:

```bash
ansible-galaxy init myweb
```

If offline:

```bash
ansible-galaxy init myweb --offline
```

✅ A `myweb/` directory is created under `roles/` with all subfolders.

---

## **5  |  Moving Existing Playbook Logic into the Role**

Suppose your old `site.yml` had tasks like installing HTTPD and FirewallD.
You’ll move them into `roles/myweb/tasks/main.yml`.

### **Example: `roles/myweb/tasks/main.yml`**

```yaml
---
- name: Install web package
  yum:
    name: "{{ web_package }}"
    state: present
  notify:
    - restart_web_service
    - restart_firewall

- name: Enable firewall service
  service:
    name: "{{ firewall_service }}"
    state: started
    enabled: true
  notify: restart_firewall

- name: Allow HTTP port 80
  firewalld:
    port: 80/tcp
    permanent: true
    state: enabled
    immediate: yes
```

---

## **6  |  Creating Handlers**

Handlers define what to do when notified by a task.

### **`roles/myweb/handlers/main.yml`**

```yaml
---
- name: restart_web_service
  service:
    name: "{{ web_service }}"
    state: restarted

- name: restart_firewall
  service:
    name: "{{ firewall_service }}"
    state: restarted
```

✅ Handlers are automatically available — you don’t need to import them manually.

---

## **7  |  Defining Default Variables**

You can set defaults for services or packages.

### **`roles/myweb/defaults/main.yml`**

```yaml
---
web_package: httpd
web_service: httpd
firewall_service: firewalld
```

You can override these values from the main playbook.

---

## **8  |  Using the Role in a Playbook**

### **Option 1 – Using `roles:`**

```yaml
---
- name: Deploy Web Server
  hosts: nodes
  become: true
  roles:
    - myweb
```

### **Option 2 – Using `include_role`:**

```yaml
---
- name: Deploy Web Server
  hosts: nodes
  become: true
  tasks:
    - name: Include role manually
      include_role:
        name: myweb
```

✅ Both work. `include_role` offers more control (looping, conditionals).

---

## **9  |  Testing the Role**

Run:

```bash
ansible-playbook myweb.yml
```

✅ Output shows:

```
TASK [myweb : Install web package] ...
TASK [myweb : Enable firewall service] ...
RUNNING HANDLER [myweb : restart_web_service]
```

---

## **10  |  Using Metadata**

### **`roles/myweb/meta/main.yml`**

```yaml
---
galaxy_info:
  author: Aisalkyn Aidarova
  description: Deploys and configures web servers.
  company: JumpToTech
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: EL
      versions:
        - 7
        - 8
dependencies: []
```

Use `ansible-galaxy list` to see installed roles.

---

## **11  |  Adding Dynamic Variables**

Let’s make the role flexible to support both **Apache** and **Nginx**.

### **Update `defaults/main.yml`:**

```yaml
web_package: httpd
web_service: httpd
firewall_service: firewalld
firewall_port: 80
```

### **Override in Playbook:**

```yaml
---
- name: Deploy Nginx Server
  hosts: nodes
  become: true
  vars:
    web_package: nginx
    web_service: nginx
  roles:
    - myweb
```

✅ The same role now installs Nginx instead of Apache — no code duplication.

---

## **12  |  Adding Cleanup Task**

Add a cleanup step to remove old packages before installation.

```yaml
- name: Remove conflicting packages
  yum:
    name:
      - httpd
      - nginx
    state: absent
```

This ensures only one web server is active.

---

## **13  |  How Variable Precedence Works in Roles**

| Source              | Priority (Low → High) |
| ------------------- | --------------------- |
| Role defaults       | 1️⃣ Lowest            |
| Inventory variables | 2️⃣                   |
| Playbook variables  | 3️⃣                   |
| Role vars/host vars | 4️⃣                   |
| Extra vars (`-e`)   | 🔝 Highest            |

---

## **14  |  Best Practices**

✅ Keep each role focused (e.g., `webserver`, `database`, `loadbalancer`)
✅ Use variables for flexibility (don’t hardcode names)
✅ Always include handlers in roles for services
✅ Use templates instead of static configs when possible
✅ Add metadata for version tracking and sharing

---

## **15  |  Hands-On Lab**

**Task:**

1. Create a role `myweb`.
2. Move HTTPD installation logic into it.
3. Add handlers to restart services.
4. Add variables for `web_package` and `web_service`.
5. Override defaults in a playbook to deploy Nginx.
6. Test that handlers run and services restart correctly.

---

## **16  |  Output Verification**

Check on the target nodes:

```bash
sudo systemctl status nginx
sudo systemctl status firewalld
```

✅ Should show both running and enabled.

---

## **17  |  Summary**

| Concept         | Description                                         |
| --------------- | --------------------------------------------------- |
| **Role**        | Reusable Ansible component with its own structure   |
| **Tasks**       | Actions inside the role                             |
| **Handlers**    | Triggered restarts or reloads                       |
| **Defaults**    | Base variables (overridable)                        |
| **Meta**        | Role information and dependencies                   |
| **Templates**   | Dynamic config support                              |
| **Flexibility** | Same role works for Apache or Nginx using variables |

---















## **2  |  Parallelism and the `forks` Parameter**

### **What it does**

* Each host connection = one SSH process.
* The `forks` setting defines the **maximum number of simultaneous connections**.

### **Defaults**

```ini
# in ansible.cfg
[defaults]
forks = 5
```

That means Ansible connects to 5 hosts at a time by default.

### **You can set it:**

1. **In `ansible.cfg`**

   ```ini
   [defaults]
   forks = 10
   ```
2. **In CLI**

   ```bash
   ansible-playbook site.yml --forks 10
   ```
3. **In playbook**
   (rare) but can be set with `serial:` logic instead (see below).

> ⚙️  Adjust `forks` based on your control-node resources — too high a value may overload CPU/RAM.

---

## **3  |  Rolling Updates with the `serial` Keyword**

When managing clusters (e.g., web servers behind a load balancer), you often can’t restart all servers together.
The `serial` directive tells Ansible how many hosts to process **per batch**.

### **Example**

```yaml
---
- name: Rolling patch of web servers
  hosts: webservers
  become: true
  serial: 1        # process one host at a time
  tasks:
    - name: Update package repo
      yum:
        name: httpd
        state: latest
```

**Behavior:**

* Executes on host 1 → completes
* Then moves to host 2, etc.
* Never runs on multiple hosts simultaneously.

---

## **4  |  Using Percentages for `serial`**

Instead of numbers, you can use percentages:

```yaml
serial: "25%"
```

✅ If you have 100 servers, 25 will run in parallel.
✅ If you have 4 servers, 1 server runs at a time.

---

## **5  |  Practical Examples**

### **Example 1 – Patch a Cluster Safely**

```yaml
- hosts: app_servers
  serial: 2
  tasks:
    - name: Apply security updates
      yum:
        name: "*"
        state: latest
```

➡ Updates 2 servers at a time, then moves to the next 2.

### **Example 2 – Rolling Restart**

```yaml
- hosts: web
  serial: 1
  tasks:
    - name: Restart nginx one by one
      service:
        name: nginx
        state: restarted
```

➡ Keeps the site online because only one instance is down at any moment.

---

## **6  |  Combining `forks` and `serial`**

* **`forks`** = how many parallel connections Ansible can open globally.
* **`serial`** = how many hosts to work on per play.

✅ You can limit the maximum concurrency with `forks` and still control batch execution with `serial`.

Example:

```bash
ansible-playbook site.yml --forks 20
```

and inside playbook:

```yaml
serial: 5
```

➡ 5 hosts per batch, but each batch can use up to 20 parallel SSH connections.

---

## **7  |  Real-World Use Cases**

| Scenario                                                | Recommended Setting                         |
| ------------------------------------------------------- | ------------------------------------------- |
| 10 small EC2 instances – install packages quickly       | `forks: 10`                                 |
| 200 web servers behind load balancer – no downtime      | `serial: 1` or `10%`                        |
| Large database cluster – one node maintenance at a time | `serial: 1`                                 |
| Mixed environments with limited CPU on controller       | reduce `forks` to avoid resource exhaustion |

---

## **8  |  Configuration Summary**

| Parameter             | Location                            | Purpose                                      |
| --------------------- | ----------------------------------- | -------------------------------------------- |
| `forks`               | `ansible.cfg` or CLI                | Total SSH sessions allowed                   |
| `serial`              | Inside playbook                     | Number/percentage of hosts processed at once |
| `strategy` (optional) | `linear` (default), `free`, `debug` | Execution order style                        |

---

## **9  |  Typical Production Pattern**

Example: Rolling Update of Nginx Cluster behind ELB

```yaml
---
- name: Rolling Nginx upgrade
  hosts: webservers
  become: true
  serial: 1
  tasks:
    - name: Drain host from load balancer
      command: /usr/local/bin/drain_from_lb.sh {{ inventory_hostname }}

    - name: Update nginx
      yum:
        name: nginx
        state: latest

    - name: Restart nginx
      service:
        name: nginx
        state: restarted

    - name: Re-add host to load balancer
      command: /usr/local/bin/add_to_lb.sh {{ inventory_hostname }}
```

✅ Ensures zero downtime deployment.

---

## **10  |  Key Takeaways**

| Concept            | Description                                                 |
| ------------------ | ----------------------------------------------------------- |
| **Parallelism**    | Run tasks on many hosts simultaneously                      |
| **Forks**          | Controls total parallel SSH connections                     |
| **Serial**         | Controls how many hosts to process per batch                |
| **Rolling Update** | Update nodes one by one or in small groups                  |
| **Use Case**       | Database patching, web server upgrades, cluster maintenance |












## **2  |  Understanding Host Patterns**

A **host pattern** tells Ansible which hosts to run against, based on names, groups, or matching rules.

### **Examples of inventory:**

```
[nodes]
node1
node2

[newnodes]
node1
node3

[labs]
test1.lab.local
test2.lab.local
```

---

## **3  |  Listing All Hosts**

You can view all inventory hosts with:

```bash
ansible all --list-hosts
```

Output:

```
  hosts (4):
    node1
    node2
    test1.lab.local
    test2.lab.local
```

---

## **4  |  Matching by IP Address**

You can select hosts using wildcards (`*`) in IP or name patterns.

```bash
ansible "192.168.2.*" -m ping
```

✅ Matches all hosts with IPs starting `192.168.2.`

---

## **5  |  Matching by Hostname Patterns**

You can use patterns like:

```bash
ansible "*.lab.local" -m ping
```

✅ Targets all hosts whose names end with `.lab.local`.

You can also mix or select multiple hosts:

```bash
ansible "node1,node2" -m ping
```

✅ Runs only on `node1` and `node2`.

---

## **6  |  Combining Groups and Patterns**

You can match by groups or even combine them:

```bash
ansible "webservers:dbservers" -m ping
```

➡ Run on all hosts in both groups.

```bash
ansible "webservers:&staging" -m ping
```

➡ Run only on hosts that belong to **both** groups.

---

## **7  |  Using Patterns in Playbooks**

In playbooks, you can use the same expressions under `hosts:`.

### **Example**

```yaml
---
- name: Update nodes matching pattern
  hosts: "*.lab.local"
  become: true
  tasks:
    - name: Update all packages
      yum:
        name: "*"
        state: latest
```

---

## **8  |  The `--limit` Option**

The **`--limit`** flag lets you restrict execution **without modifying the playbook**.

### **Example**

Playbook file (`site.yml`):

```yaml
- hosts: nodes
  become: true
  tasks:
    - name: Display hostname
      command: hostname
```

Run on all by default:

```bash
ansible-playbook site.yml
```

Limit to one host:

```bash
ansible-playbook site.yml --limit node1
```

Limit by pattern:

```bash
ansible-playbook site.yml --limit "*.lab.local"
```

Limit to specific IP:

```bash
ansible-playbook site.yml --limit 192.168.2.*
```

✅ You don’t need to edit `hosts:` — it overrides dynamically.

---

## **9  |  Multiple Limit Examples**

| Command                                      | Description                          |
| -------------------------------------------- | ------------------------------------ |
| `ansible-playbook site.yml -l node1`         | Run only on node1                    |
| `ansible-playbook site.yml -l node1,node2`   | Run on node1 and node2               |
| `ansible-playbook site.yml -l web*`          | Run on all hosts starting with “web” |
| `ansible-playbook site.yml -l 10.0.1.*`      | Run on IP pattern                    |
| `ansible-playbook site.yml -l "*.lab.local"` | Match DNS suffix                     |
| `ansible-playbook site.yml -l '!node3'`      | Exclude node3                        |

---

## **10  |  When to Use Patterns and Limits**

| Scenario                           | Solution                 |
| ---------------------------------- | ------------------------ |
| Test a playbook on one node        | `--limit node1`          |
| Patch only web servers             | `hosts: web*`            |
| Apply change to subset of nodes    | `--limit "*.prod.local"` |
| Emergency fix without editing YAML | `--limit node2`          |
| Mixed patterns                     | `--limit web*,db*`       |

---

## **11  |  Benefits for DevOps Engineers**

* No need to edit playbooks for testing
* Safer deployment (limit risky changes)
* Flexibility for ad-hoc tasks
* Supports wildcards and combinations

---

## **12  |  Practical Exercise**

**Task:**

1. Create inventory file with:

   ```
   node1
   node2
   web1.lab.local
   db1.lab.local
   ```
2. Create a playbook that prints the hostname.
3. Test using:

   * `--limit node1`
   * `--limit "*.lab.local"`
   * `--limit node1,node2`
4. Observe how each limits the scope of execution.

---

## **13  |  Summary**

| Concept                      | Description                                      |
| ---------------------------- | ------------------------------------------------ |
| **Host Pattern**             | String expression defining which hosts to target |
| **Wildcard `*`**             | Matches multiple hosts by name or IP             |
| **Comma-separated list**     | Runs on multiple specific hosts                  |
| **`--limit` flag**           | Temporarily restricts playbook scope             |
| **Groups and intersections** | Combine multiple host groups dynamically         |


