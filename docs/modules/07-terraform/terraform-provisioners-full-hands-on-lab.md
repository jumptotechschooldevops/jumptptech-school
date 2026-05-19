---
title: "Terraform Provisioners — FULL HANDS-ON LAB"
description: "STEP 1 — Create AWS Key Pair (IMPORTANT)   Go to:   AWS → EC2 → Key Pairs → Create Key..."
published: 2026-03-18
source: "https://dev.to/jumptotech/terraform-provisioners-full-hands-on-lab-2b7l"
tags: []
---

# Terraform Provisioners — FULL HANDS-ON LAB


# STEP 1 — Create AWS Key Pair (IMPORTANT)


Go to:

* AWS → EC2 → Key Pairs → Create Key Pair

Fill:

* Name: `terraform-key`
* Type: RSA
* Format: `.pem`

Download file → it goes to:

```plaintext
~/Downloads/terraform-key.pem
```

---

## Move key to project folder

```bash
mkdir ~/terraform-provisioners
cd ~/terraform-provisioners
mv ~/Downloads/terraform-key.pem .
```

---

## Fix permissions (CRITICAL)

```bash
chmod 400 terraform-key.pem
```

### Why?

SSH will fail without this.

---

# STEP 2 — Create Terraform File

```bash
touch main.tf
```

---

# STEP 3 — Write CORRECT main.tf

Copy EXACTLY:

```hcl
provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# GET LATEST AMAZON LINUX AMI
# -----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -----------------------------
# SECURITY GROUP
# -----------------------------
resource "aws_security_group" "web_sg" {
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

# -----------------------------
# EC2 INSTANCE
# -----------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  key_name = "terraform-key"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # -----------------------------
  # REMOTE EXEC (on EC2)
  # -----------------------------
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

  # -----------------------------
  # LOCAL EXEC (on your machine)
  # -----------------------------
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > public_ip.txt"
  }

  # -----------------------------
  # DESTROY PROVISIONER
  # -----------------------------
  provisioner "local-exec" {
    when    = destroy
    command = "echo Destroying EC2 instance..."
  }

  tags = {
    Name = "provisioner-lab"
  }
}
```

---

# STEP 4 — Initialize Terraform

```bash
terraform init
```

---

# STEP 5 — Apply

```bash
terraform apply -auto-approve
```

---

# WHAT HAPPENS 
### Phase 1 — Infrastructure

* Terraform creates:

  * Security group
  * EC2 instance

---

### Phase 2 — Provisioning

#### remote-exec

* SSH into EC2
* Runs:

  * install nginx
  * start nginx

#### local-exec

* Runs on YOUR machine
* Creates:

```plaintext
public_ip.txt
```

---

# STEP 6 — Verify

## Get IP

```bash
cat public_ip.txt
```

---

## Open browser

```plaintext
http://<IP>
```

You should see:

```plaintext
Welcome to nginx!
```

---

# STEP 7 — Debug (VERY IMPORTANT SKILL)

## Test SSH manually

```bash
ssh -i terraform-key.pem ec2-user@<IP>
```

If this fails → Terraform would fail too.

---

# STEP 8 — Understand Provisioners

| Provisioner | Runs where    | Purpose          |
| ----------- | ------------- | ---------------- |
| remote-exec | EC2           | install software |
| local-exec  | local machine | save data        |
| destroy     | before delete | cleanup          |

---

# STEP 9 — Failure Demo (IMPORTANT)

Break command:

```hcl
"wrong-command"
```

Run:

```bash
terraform apply
```

### Result:

* Apply fails
* Resource becomes **TAINTED**

---

# STEP 10 — Fix failure behavior

```hcl
on_failure = continue
```

---

# STEP 11 — Destroy

```bash
terraform destroy -auto-approve
```

You will see:

```plaintext
Destroying EC2 instance...
```

---

# FINAL UNDERSTANDING

### Flow:

```text
Terraform → Create EC2
         → SSH (remote-exec)
         → Install nginx
         → Save IP (local-exec)
```

---

# MOST IMPORTANT RULES 

1. `.pem` must exist locally
2. `chmod 400` required
3. key_name must match AWS
4. SSH must work manually
5. Provisioners run AFTER creation

---

# INTERVIEW ANSWER (VERY IMPORTANT)

Provisioners allow Terraform to configure infrastructure after creation by executing commands locally or remotely, but they are not recommended for production due to lack of idempotency and debugging complexity.


