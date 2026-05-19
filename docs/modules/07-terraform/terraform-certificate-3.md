---
title: "Terraform certificate #3"
description: "Terraform Provisioners            1. What problem do provisioners solve?   Terraform is..."
published: 2025-12-18
source: "https://dev.to/jumptotech/terraform-certificate-3-2dga"
tags: []
---

# Terraform certificate #3



# Terraform Provisioners 

## 1. What problem do provisioners solve?

Terraform is **great at creating infrastructure**, but infrastructure alone is often **not enough**.

Example:

* Terraform creates an EC2 instance
* ❌ EC2 is empty
* ❌ No nginx, no app, no configuration
* ❌ You still need to log in manually

👉 **Provisioners solve this second step**

They allow Terraform to:

* Run commands
* Install software
* Configure the server
  **after** the resource is created

---

## 2. What is a provisioner? 

> A **provisioner** allows Terraform to execute commands or scripts
> on a **local machine** or a **remote resource**
> during **creation or destruction** of infrastructure.

Key idea:

* **Stage 1**: Terraform creates infrastructure
* **Stage 2**: Terraform configures it

---

## 3. Important exam & production note

### Exam

* ❌ Provisioners are **NOT part of new Terraform exams**
* You will **not be tested** on them

### Real-world

* ✅ Still heavily used in many companies
* ✅ Very common for:

  * Bootstrap scripts
  * Temporary automation
  * Legacy workflows
  * Learning environments

---

## 4. How provisioners work (execution flow)

Terraform follows **two clear phases**:

### Phase 1 – Create resource

```text
Terraform creates EC2 instance
```

### Phase 2 – Provision

```text
Terraform connects via SSH
Runs commands (install, configure, start services)
```

Terraform **waits** for provisioning to finish.

---

## 5. Types of provisioners (high level)

| Provisioner   | Runs where          | Use case                       |
| ------------- | ------------------- | ------------------------------ |
| `remote-exec` | On the EC2 / VM     | Install software, configure OS |
| `local-exec`  | On your laptop / CI | Run scripts, call APIs         |
| `file`        | Copy files to VM    | Upload config, scripts         |

---

## 6. Real, minimal working example (NGINX on EC2)

This example:

* Creates EC2
* SSHs into it
* Installs nginx
* Starts nginx
* You open browser → see **Welcome to nginx**

---

### 6.1 Requirements

* AWS key pair already created
* `.pem` file on your laptop
* Port **22** and **80** allowed in Security Group

---

### 6.2 Terraform code (single file)

```hcl
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0f5fcdfbd140e4ab7" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "terraform-key"

  vpc_security_group_ids = ["sg-xxxxxxxx"]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform-key.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "provisioner-demo"
  }
}
```

---

## 7. What happens when you run Terraform?

### Step 1

```bash
terraform init
```

### Step 2

```bash
terraform apply -auto-approve
```

### Terraform output flow

```text
1. EC2 instance is created
2. Terraform waits for SSH
3. SSH connection established
4. Commands executed:
   - yum install nginx
   - systemctl start nginx
5. Provisioning completed
```

---

## 8. How Terraform connects to EC2

Terraform uses **SSH**, just like you do manually.

It needs:

* Username → `ec2-user`
* Private key → `.pem` file
* IP address → `self.public_ip`

If **any of these fail**, provisioning fails.

---

## 9. Verifying the result

1. Copy EC2 **public IP**
2. Open browser:

```
http://<EC2_PUBLIC_IP>
```

You will see:

```
Welcome to nginx!
```

That confirms:

* EC2 created
* Software installed
* Service running

---

## 10. Why provisioners are controversial

Terraform **official recommendation**:

> Avoid provisioners when possible

Reasons:

* ❌ Hard to debug
* ❌ Not idempotent
* ❌ Failures can break `apply`
* ❌ Mixing infra + config

Preferred alternatives:

* `user_data`
* Ansible
* Cloud-init
* Packer
* Configuration management tools

---

## 11. When provisioners ARE acceptable

Use provisioners when:

* Learning Terraform
* Quick demos
* One-time bootstrap
* Legacy systems
* No config tool available

Avoid in:

* Large production systems
* Long-lived infrastructure

---

## 12. One-sentence summary for students

> **Provisioners allow Terraform to configure servers after creation by running commands locally or remotely, but they should be used carefully and are not recommended for large production systems.**








# Terraform Provisioners — Types & Definition Format 

## 1. What are provisioners? 

> **Provisioners allow Terraform to run commands or scripts**

* on the **local machine** (where Terraform runs)
* or on a **remote machine** (like an EC2 instance)
* during **resource creation or destruction**

They help achieve **end-to-end infrastructure setup**.

---

## 2. Types of provisioners in Terraform

Today, Terraform officially supports **three** provisioners:

| Provisioner   | Runs where     | Purpose                |
| ------------- | -------------- | ---------------------- |
| `local-exec`  | Local machine  | Run commands locally   |
| `remote-exec` | Remote server  | Run commands on server |
| `file`        | Local → Remote | Copy files             |

### Important note

* Older provisioners like **Chef, Puppet, Salt** were **removed**
* Only these **three** remain
* **Most commonly used**: `local-exec` and `remote-exec`

---

## 3. High-level difference (very important)

### local-exec

* Runs **on your laptop / CI / Jenkins**
* Does **NOT** touch the server
* Used for:

  * Saving IPs to files
  * Running curl, ping
  * Calling scripts or APIs

### remote-exec

* Runs **inside the server**
* Requires **SSH access**
* Used for:

  * Installing software
  * Configuring OS
  * Starting services

---

## 4. Rule #1 — Where provisioners are defined

> **Provisioners MUST be inside a resource block**

✅ Correct

```hcl
resource "aws_instance" "demo" {
  provisioner "local-exec" {
    command = "echo Hello"
  }
}
```

❌ Incorrect

```hcl
provisioner "local-exec" {
  command = "echo Hello"
}
```

Provisioners **cannot exist outside resources**.

---

## 5. General provisioner syntax

```hcl
resource "RESOURCE_TYPE" "NAME" {

  provisioner "TYPE" {
    ...
  }

}
```

Examples:

* `provisioner "local-exec"`
* `provisioner "remote-exec"`
* `provisioner "file"`

---

## 6. local-exec provisioner — format & example

### Purpose

Run commands **on the local system** where Terraform runs.

### Format

```hcl
provisioner "local-exec" {
  command = "some command"
}
```

---

### Example 1: Simple echo message

```hcl
resource "aws_instance" "demo" {

  ami           = "ami-0f5fcdfbd140e4ab7"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo Server has been created through Terraform"
  }
}
```

### What happens?

* EC2 is created
* Terraform prints:

```text
Server has been created through Terraform
```

---

### Example 2: Save EC2 public IP to file

```hcl
provisioner "local-exec" {
  command = "echo ${self.public_ip} > server_ip.txt"
}
```

Result:

* A file `server_ip.txt` is created locally
* It contains the EC2 public IP

---

## 7. remote-exec provisioner — format & explanation

### Purpose

Run commands **inside the remote server**.

### Key difference

👉 Requires **SSH connection**

---

### Format (very important)

```hcl
provisioner "remote-exec" {

  inline = [
    "command1",
    "command2"
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("terraform-key.pem")
    host        = self.public_ip
  }
}
```

---

## 8. remote-exec — real example (Install NGINX)

```hcl
resource "aws_instance" "web" {

  ami           = "ami-0f5fcdfbd140e4ab7"
  instance_type = "t2.micro"
  key_name      = "terraform-key"

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform-key.pem")
      host        = self.public_ip
    }
  }
}
```

### What happens?

1. EC2 is created
2. Terraform connects via SSH
3. NGINX is installed
4. Web server starts automatically

---

## 9. Using BOTH provisioners together (common pattern)

### Real-world flow

1. `remote-exec` → configure server
2. `local-exec` → save IP locally

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo yum install nginx -y",
    "sudo systemctl start nginx"
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("terraform-key.pem")
    host        = self.public_ip
  }
}

provisioner "local-exec" {
  command = "echo ${self.public_ip} > public_ip.txt"
}
```

Result:

* Website running
* IP saved locally
* Browser access works

---

## 10. Key takeaways for students

### Memorize this table

| Provisioner | Runs where    | Needs SSH |
| ----------- | ------------- | --------- |
| local-exec  | Local machine | ❌ No      |
| remote-exec | Remote server | ✅ Yes     |
| file        | Copy files    | ✅ Yes     |

---

## 11. One-sentence interview answer

> **local-exec runs commands on the machine where Terraform executes, while remote-exec runs commands inside the created server using SSH.**





# Terraform `local-exec` Provisioner — Practical Lab

## Goal of this lab

After an EC2 instance is created by Terraform:

* Capture the **IP address** of the instance
* Store it **locally** in a file called `server_ip.txt`
* Understand:

  * where `local-exec` runs
  * what `self` means
  * why provisioners must be inside resources

---

## Key rules to remember (before coding)

### Rule 1: Provisioners must be inside a resource

Provisioners **cannot** exist outside a resource block.

### Rule 2: Syntax format

```hcl
provisioner "local-exec" {
  command = "..."
}
```

### Rule 3: `local-exec` runs on **your machine**

Not on EC2.
Not over SSH.
Only on the system where Terraform runs.

---

## Lab file structure

```text
local-exec.tf
```

That’s all you need for this demo.

---

## Full working example: `local-exec.tf`

> **Region note:**
> This example uses **us-east-1**.
> If you use another region, update the AMI ID.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${self.private_ip} > server_ip.txt"
  }

  tags = {
    Name = "local-exec-demo"
  }
}
```

---

## Understanding the important parts

### 1. Why `self.private_ip`?

* `self` → refers to **this resource**
* `private_ip` → attribute of `aws_instance`

So:

```hcl
self.private_ip
```

means:

> “Give me the private IP of **this EC2 instance**”

You could also use:

```hcl
self.public_ip
```

---

### 2. Why `echo`?

`echo` prints text to output.
When combined with `>`:

```bash
echo VALUE > file.txt
```

It **writes the value into a file**.

So this line:

```hcl
command = "echo ${self.private_ip} > server_ip.txt"
```

Means:

> Save the EC2 private IP into `server_ip.txt` on my local machine

---

## Running the lab

### Step 1: Initialize Terraform

```bash
terraform init
```

---

### Step 2: Apply configuration

```bash
terraform apply -auto-approve
```

---

## What happens internally

1. Terraform creates EC2
2. EC2 gets a private IP
3. `local-exec` runs **on your laptop**
4. File `server_ip.txt` is created
5. IP address is written into the file

---

## Verifying the result

### Check file exists

```bash
ls
```

You should see:

```text
server_ip.txt
```

---

### View file content

```bash
cat server_ip.txt
```

Example output:

```text
172.31.25.213
```

---

### Verify in AWS Console

* Open EC2 → Instance → Networking
* Private IP should match the file content

---

## Important clarification (very common confusion)

| Question                        | Answer               |
| ------------------------------- | -------------------- |
| Where does `local-exec` run?    | On your local system |
| Does it use SSH?                | No                   |
| Can it install software on EC2? | No                   |
| Can it call Ansible locally?    | Yes                  |
| Can it save outputs to files?   | Yes                  |

---

## Real-world use cases of `local-exec`

* Save IPs or DNS names to files
* Run Ansible after infra creation
* Trigger shell scripts
* Call APIs (curl)
* Notify Slack / email
* Run tests from CI/CD

---

## Clean up (important)

Always destroy resources after practice:

```bash
terraform destroy -auto-approve
```

AWS Console flow:

```text
running → shutting-down → terminated
```

---

## One-sentence summary for students

> **The `local-exec` provisioner runs commands on the machine where Terraform executes, allowing us to perform local actions like saving instance IPs after resource creation.**









# Lesson 1: Terraform `remote-exec` Provisioner — Practical Guide

## Goal of this lab

* Create an EC2 instance
* Use **remote-exec** to:

  * Connect via **SSH**
  * Install **nginx**
  * Start nginx
* Access nginx via browser
* Understand **connection block**, **key pair**, and **common errors**

---

## Key concept recap (must be clear)

`remote-exec` has **TWO mandatory parts**:

1. **connection block** → how Terraform connects
2. **provisioner block** → what commands to run

Without **connection**, `remote-exec` will fail.

---

## Step 1: Prerequisites

### 1. Create an EC2 key pair

* Name: `terraform-key`
* Type: **PEM**
* Downloaded file: `terraform-key.pem`

### 2. Place key in Terraform folder

```text
remote-exec.tf
terraform-key.pem
```

### 3. Fix key permissions (Mac / Linux only)

```bash
chmod 400 terraform-key.pem
```

(Required, otherwise SSH fails)

---

## Step 2: Security Group requirements

Inbound rules **must allow**:

* SSH → port **22**
* HTTP → port **80**

You can create it manually or via Terraform.

Example:

```text
SSH   | 22 | 0.0.0.0/0
HTTP  | 80 | 0.0.0.0/0
```

---

## Step 3: Full working `remote-exec.tf`

> Region: `us-east-1`
> Update AMI if you use another region.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"

  key_name = "terraform-key"

  vpc_security_group_ids = [
    "sg-xxxxxxxx" # replace with your SG ID
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform-key.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "remote-exec-demo"
  }
}
```

---

## Step 4: Why each part matters

### `key_name`

* EC2 **must** be created using the same key
* Otherwise SSH login will fail

### `private_key = file(...)`

* Terraform expects **key contents**, not filename
* This is a **very common mistake**

❌ Wrong:

```hcl
private_key = "terraform-key.pem"
```

✅ Correct:

```hcl
private_key = file("terraform-key.pem")
```

---

### `user = "ec2-user"`

Depends on OS:

| OS           | Username                |
| ------------ | ----------------------- |
| Amazon Linux | `ec2-user`              |
| Ubuntu       | `ubuntu`                |
| CentOS       | `centos`                |
| Windows      | `Administrator` (WinRM) |

---

## Step 5: Run Terraform

```bash
terraform init
terraform apply -auto-approve
```

---

## Expected Terraform output flow

1. EC2 created
2. Terraform waits for SSH
3. SSH connected
4. Nginx installed
5. Nginx started
6. Provisioning completed

---

## Step 6: Verify in browser

Copy **public IP**:

```text
http://<EC2_PUBLIC_IP>
```

You should see:

```
Welcome to nginx!
```

---

## Step 7: Troubleshooting remote-exec (VERY IMPORTANT)

### Issue 1: SSH connection fails

👉 Manually test SSH using same values:

```bash
ssh -i terraform-key.pem ec2-user@<PUBLIC_IP>
```

If this fails, Terraform will also fail.

---

### Issue 2: Permission denied while installing packages

Reason:

* `ec2-user` is **not root**

Solution:

* Always use `sudo`

❌ Wrong:

```bash
yum install nginx -y
```

✅ Correct:

```bash
sudo yum install nginx -y
```

---

### Issue 3: Key permission error

Fix (Mac/Linux):

```bash
chmod 400 terraform-key.pem
```

---

## Cleanup (always do this)

```bash
terraform destroy -auto-approve
```

---

# Lesson 2: Important Provisioner Rules (Avoid Confusion)

## Rule 1: Provisioners are NOT limited to EC2

Provisioners can be used with **any resource**.

### Example: IAM user + local-exec

```hcl
resource "aws_iam_user" "demo" {
  name = "test-user"

  provisioner "local-exec" {
    command = "echo IAM user created"
  }
}
```

Output:

```text
IAM user created
```

---

## Rule 2: Multiple provisioners per resource are allowed

You can define **multiple provisioners** inside one resource.

### Example

```hcl
resource "aws_iam_user" "demo" {
  name = "multi-prov-user"

  provisioner "local-exec" {
    command = "echo First provisioner"
  }

  provisioner "local-exec" {
    command = "echo Second provisioner"
  }
}
```

Terraform output:

```text
First provisioner
Second provisioner
```

Execution order = **top to bottom**

---

## Rule 3: Provisioners run AFTER resource creation

Terraform flow:

```
Create resource
↓
Run provisioners
```

If provisioning fails:

* Resource **still exists**
* Terraform marks apply as failed

---

## Rule 4: Provisioners are NOT recommended for production

Why:

* Not idempotent
* Hard to debug
* Can break pipelines
* Mix infra + config

Preferred alternatives:

* `user_data`
* cloud-init
* Ansible
* Packer
* Configuration management tools

Provisioners are best for:

* Learning
* Demos
* Temporary automation
* Legacy workflows

---

## One-sentence summary for students

> **`remote-exec` runs commands on a remote server using SSH and requires a connection block, while provisioners can be attached to any Terraform resource and multiple provisioners can exist within a single resource.**









# Terraform Provisioners — Creation Time, Destroy Time & Failure Behavior

## 1. Creation-time provisioners (default behavior)

### Key rule

> **By default, all provisioners are creation-time provisioners.**

That means:

* They run **only once**
* They run **after the resource is created**
* They **do NOT run** on updates
* They **do NOT run** on every `apply`

---

### Example: Creation-time provisioner

```hcl
resource "aws_iam_user" "demo" {
  name = "creation-user"

  provisioner "local-exec" {
    command = "echo This is creation-time provisioner"
  }
}
```

### What happens?

| Action                         | Provisioner runs? |
| ------------------------------ | ----------------- |
| `terraform apply` (first time) | Yes               |
| Change user tags               | No                |
| Change resource attributes     | No                |
| `terraform destroy`            | No                |

Creation-time provisioners are **one-time setup actions**.

---

### Important clarification (common confusion)

If you:

* Change EC2 size
* Update tags
* Modify metadata

👉 **Creation-time provisioners will NOT re-run**

Terraform assumes provisioning already happened.

---

## 2. Destroy-time provisioners

### What are destroy-time provisioners?

> Destroy-time provisioners run **before Terraform destroys a resource**.

They are used for **cleanup tasks**.

---

### How to define a destroy-time provisioner

You add **one line only**:

```hcl
when = destroy
```

---

### Example: Creation + Destroy provisioners together

```hcl
resource "aws_iam_user" "demo" {
  name = "lifecycle-user"

  provisioner "local-exec" {
    command = "echo This is creation-time provisioner"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo This is destroy-time provisioner"
  }
}
```

---

### Execution behavior

| Terraform command   | What runs                 |
| ------------------- | ------------------------- |
| `terraform apply`   | Creation-time provisioner |
| `terraform destroy` | Destroy-time provisioner  |

They **never run together**.

---

### Real-world destroy-time use cases

* De-register EC2 from antivirus / monitoring
* Remove instance from CMDB
* Revoke licenses
* Notify external systems before deletion
* Cleanup external dependencies

---

## 3. What happens when a provisioner fails? (VERY IMPORTANT)

### Default behavior

> **If a provisioner fails, Terraform apply fails.**

And:

* Resource is marked as **tainted**
* Next `terraform apply` will **destroy & recreate** the resource

This is intentional.

---

### Why Terraform does this

Because a failed provisioner may leave a resource in a **half-configured (unsafe) state**.

Example:

* EC2 created
* Application installation failed
* Instance is useless

Terraform chooses **safety over convenience**.

---

## 4. What is “tainted”?

### Meaning of tainted

> Terraform believes the resource is unsafe and must be recreated.

Once tainted:

* Terraform plans **destroy + recreate**
* Happens automatically on next `apply`

You’ll see it in plan output or state.

---

### Example: Failed creation-time provisioner

```hcl
resource "aws_iam_user" "demo" {
  name = "tainted-user"

  provisioner "local-exec" {
    command = "echo1"   # invalid command
  }
}
```

### Result

* User **is created**
* Provisioner **fails**
* Resource marked **tainted**
* Terraform apply **fails**

Next apply → Terraform wants to recreate the user.

---

## 5. Can we allow provisioning to fail but continue?

### Yes — using `on_failure`

Provisioners support:

```hcl
on_failure = continue
```

---

### Default behavior (implicit)

```hcl
on_failure = fail   # default
```

This:

* Fails apply
* Marks resource tainted

---

### Override behavior: Continue on failure

```hcl
resource "aws_iam_user" "demo" {
  name = "non-tainted-user"

  provisioner "local-exec" {
    command     = "echo1"
    on_failure  = continue
  }
}
```

---

### Result

* Provisioner fails
* Terraform apply **continues**
* Resource **NOT tainted**
* Terraform state is clean

---

### When should you use `on_failure = continue`?

Use **carefully**, only when:

* Provisioner is **non-critical**
* Logging, notification, best-effort actions
* Optional integrations

Avoid for:

* Software installation
* Security setup
* Application configuration

---

## 6. Summary table (very important for students)

| Scenario                           | Apply fails | Resource tainted |
| ---------------------------------- | ----------- | ---------------- |
| Provisioner fails (default)        | Yes         | Yes              |
| Provisioner fails + continue       | No          | No               |
| Destroy-time provisioner fails     | Depends     | Depends          |
| Creation-time provisioner succeeds | No          | No               |

---

## 7. One-sentence exam / interview answer

> **Creation-time provisioners run only after initial resource creation, destroy-time provisioners run before deletion, and by default a failed provisioner taints the resource unless `on_failure = continue` is explicitly set.**

---

## 8. Final teaching advice (important)

Provisioners:

* Are powerful
* Are **not idempotent**
* Are **not recommended for large production systems**

Best practice:

* Use them for learning, demos, cleanup hooks
* Use **user_data, Ansible, cloud-init** for real production



