---
title: "LAB: Terraform Provisioners (EC2 + remote-exec + file)"
description: "Provision EC2 → upload script → execute script automatically              📁 Project..."
published: 2026-04-02
source: "https://dev.to/jumptotech/lab-terraform-provisioners-ec2-remote-exec-file-2jfb"
tags: []
---

# LAB: Terraform Provisioners (EC2 + remote-exec + file)





Provision EC2 → upload script → execute script automatically

---

# 📁 Project Structure

```plaintext
terraform-provisioners-lab/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
│
├── scripts/
│   └── install_nginx.sh
│
└── ssh/
    └── id_rsa.pub   # your public key
```

---

# 1️⃣ providers.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# 2️⃣ variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "public_key_path" {
  description = "Path to public key"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
}

variable "ami_owner" {
  description = "AMI owner"
  type        = string
  default     = "amazon"
}
```

---

# 3️⃣ terraform.tfvars (NO hardcoding in code)

```hcl
aws_region       = "us-east-2"
instance_type    = "t3.micro"
key_name         = "terraform-provisioner-key"
public_key_path  = "ssh/id_rsa.pub"
private_key_path = "ssh/id_rsa"
```

---

# 4️⃣ main.tf

### 🔹 Key Pair

```hcl
resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
```

---

### 🔹 Get Latest AMI (NO hardcoding)

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

---

### 🔹 Security Group

```hcl
resource "aws_security_group" "this" {
  name = "terraform-provisioner-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

### 🔹 EC2 + Provisioners

```hcl
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.this.key_name

  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "provisioner-lab"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  # 📁 FILE provisioner
  provisioner "file" {
    source      = "scripts/install_nginx.sh"
    destination = "/home/ec2-user/install_nginx.sh"
  }

  # ⚙️ REMOTE EXEC provisioner
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/install_nginx.sh",
      "sudo /home/ec2-user/install_nginx.sh"
    ]
  }
}
```

---

# 5️⃣ outputs.tf

```hcl
output "public_ip" {
  value = aws_instance.this.public_ip
}

output "url" {
  value = "http://${aws_instance.this.public_ip}"
}
```

---

# 6️⃣ scripts/install_nginx.sh

```bash
#!/bin/bash

sudo yum update -y
sudo yum install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1>Provisioner Lab Success</h1>" | sudo tee /usr/share/nginx/html/index.html
```

---

# 🚀 HOW TO RUN

```bash
terraform init
terraform plan
terraform apply
```

---

# ✅ VERIFY

Open browser:

```markdown
http://<PUBLIC_IP>
```

You should see:

```plaintext
Provisioner Lab Success
```





# ⚠️ IMPORTANT (INTERVIEW GOLD)

### ❗ Why provisioners are NOT recommended?

* Not idempotent
* Hard to debug
* Break Terraform model

### ✅ Better alternatives:

* user_data
* Packer (AMI baking)
* Ansible

---

# 💬 Interview Answer (SHORT)

“Provisioners in Terraform are used to execute scripts or commands on local or remote machines during resource creation. However, they are considered a last resort because they are not idempotent and can break declarative infrastructure principles. Preferred alternatives include user_data, configuration management tools, or pre-baked images.”


