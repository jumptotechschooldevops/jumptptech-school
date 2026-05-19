---
title: "Terraform Provisioners"
description: "🎯 Lab Goal   You will:   Create an EC2 instance Install NGINX using remote-exec  Save EC2 IP..."
published: 2026-03-17
source: "https://dev.to/jumptotech/terraform-provisioners-1ca9"
tags: []
---

# Terraform Provisioners

  
## 🎯 Lab Goal

You will:

* Create an EC2 instance
* Install NGINX using **remote-exec**
* Save EC2 IP locally using **local-exec**
* Upload a file using **file provisioner**
* Verify everything in browser

---

# 🧱 STEP 1 — Prerequisites (VERY IMPORTANT)

### ✅ You must have:

* AWS account
* Terraform installed
* Key pair created in AWS:

  * Name: `terraform-key`
  * Download: `terraform-key.pem`

### ✅ Place file in your project:

```bash
provisioner-lab/
  main.tf
  terraform-key.pem
  index.html
```

---

# 🧱 STEP 2 — Fix Key Permissions (Mac/Linux)

```bash
chmod 400 terraform-key.pem
```

❗ If you skip → SSH WILL FAIL

---

# 🧱 STEP 3 — Create index.html (file provisioner test)

📄 `index.html`

```html
<h1>Welcome from Terraform Provisioner Lab</h1>
```

---

# 🧱 STEP 4 — Security Group (AWS Console)

Allow:

| Type | Port | Source    |
| ---- | ---- | --------- |
| SSH  | 22   | 0.0.0.0/0 |
| HTTP | 80   | 0.0.0.0/0 |

Copy Security Group ID:

```plaintext
sg-xxxxxxxx
```

---

# 🧱 STEP 5 — Full Terraform Code

📄 `main.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"

  key_name = "terraform-key"

  vpc_security_group_ids = ["sg-xxxxxxxx"] # replace

  # ✅ FILE PROVISIONER (upload HTML)
  provisioner "file" {
    source      = "index.html"
    destination = "/home/ec2-user/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform-key.pem")
      host        = self.public_ip
    }
  }

  # ✅ REMOTE-EXEC (install nginx + deploy page)
  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo mv /home/ec2-user/index.html /usr/share/nginx/html/index.html"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("terraform-key.pem")
      host        = self.public_ip
    }
  }

  # ✅ LOCAL-EXEC (save IP locally)
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > public_ip.txt"
  }

  tags = {
    Name = "provisioner-lab"
  }
}
```

---

# 🧪 STEP 6 — Run Terraform

```bash
terraform init
terraform apply -auto-approve
```

---

# ⚙️ WHAT HAPPENS INTERNALLY

1. EC2 instance created
2. Terraform connects via SSH
3. File provisioner uploads HTML
4. Remote-exec installs nginx
5. HTML moved to nginx folder
6. local-exec saves IP to file

---

# 🔍 STEP 7 — VERIFY

## ✅ Check local file

```bash
cat public_ip.txt
```

Example:

```plaintext
3.145.23.10
```

---

## ✅ Open browser

```plaintext
http://<EC2_PUBLIC_IP>
```

👉 You should see:

```plaintext
Welcome from Terraform Provisioner Lab
```

---

# 🧪 STEP 8 — TEST & BREAK (IMPORTANT FOR INTERVIEW)

### ❌ Test 1: Wrong key

Change:

```hcl
private_key = file("wrong.pem")
```

👉 Result:

* SSH fails
* Provisioning fails

---

### ❌ Test 2: Remove port 22

👉 Result:

* Terraform hangs (waiting SSH)

---

### ❌ Test 3: Remove sudo

👉 Result:

* Permission denied
* NGINX not installed

---

# 🔁 STEP 9 — DESTROY

```bash
terraform destroy -auto-approve
```

---

# 🧠 WHAT YOU LEARNED

### Provisioners:

* file → copy file
* remote-exec → configure server
* local-exec → run locally

---

### Execution order:

1. Create EC2
2. file provisioner
3. remote-exec
4. local-exec

---

### Key concepts:

* `self.public_ip`
* SSH connection block
* Key permissions
* Provisioner dependency on resource

---

# 🎯 REAL DEVOPS TIP (IMPORTANT)

👉 In production, replace this with:

* `user_data` (bootstrap)
* Ansible (config)
* Packer (pre-built AMI)


