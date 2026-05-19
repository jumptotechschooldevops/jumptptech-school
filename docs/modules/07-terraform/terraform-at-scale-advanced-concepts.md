---
title: "Terraform at Scale + Advanced Concepts"
description: "🎯 Lab Goal   You will build a modular Terraform project that:   Creates IAM users + EC2 Uses..."
published: 2026-03-17
source: "https://dev.to/jumptotech/terraform-at-scale-advanced-concepts-355i"
tags: []
---

# Terraform at Scale + Advanced Concepts



 

## 🎯 Lab Goal

You will build a **modular Terraform project** that:

* Creates IAM users + EC2
* Uses `for_each`, `count`, `zipmap`
* Demonstrates lifecycle rules
* Shows dependency handling
* Simulates scale practices
* Uses targeting & refresh control

---

# 🧱 STEP 1 — Project Structure (Scaling Best Practice)

```bash
terraform-scale-lab/
│
├── iam/
│   └── main.tf
│
├── ec2/
│   └── main.tf
│
├── shared/
│   └── variables.tf
│
└── root/
    └── main.tf
```

✅ This simulates:

* Large infra split into modules
* Reduces API calls
* Used in real companies

---

# 🧩 STEP 2 — Shared Variables (Object + Map + Set)

📄 `shared/variables.tf`

```hcl
variable "users" {
  type = set(string)
  default = ["alice", "bob", "john"]
}

variable "amis" {
  type = map(string)
  default = {
    dev  = "ami-123456"
    prod = "ami-654321"
  }
}

variable "instance_config" {
  type = object({
    instance_type = string
    count         = number
  })

  default = {
    instance_type = "t2.micro"
    count         = 2
  }
}
```

✅ Covers:

* set
* map
* object

---

# 👤 STEP 3 — IAM Module (for_each + zipmap)

📄 `iam/main.tf`

```hcl
# Create IAM users using for_each
resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.value
}

# Output names
output "user_names" {
  value = [for u in aws_iam_user.users : u.name]
}

# Output ARNs
output "user_arns" {
  value = [for u in aws_iam_user.users : u.arn]
}

# ✅ zipmap usage (IMPORTANT FOR EXAM)
output "user_map" {
  value = zipmap(
    [for u in aws_iam_user.users : u.name],
    [for u in aws_iam_user.users : u.arn]
  )
}
```

✅ You just implemented:

* for_each
* splat alternative (for loop)
* zipmap()

---

# 🖥️ STEP 4 — EC2 Module (count + lifecycle + depends_on)

📄 `ec2/main.tf`

```hcl
# Security group
resource "aws_security_group" "web" {
  name = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instances using count
resource "aws_instance" "web" {
  count         = var.instance_config.count
  ami           = var.amis["dev"]
  instance_type = var.instance_config.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "web-${count.index}"
  }

  # ✅ lifecycle rules
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
```

✅ You covered:

* count
* lifecycle
* implicit dependency (SG → EC2)

---

# 🔗 STEP 5 — ROOT MODULE (Connect Everything)

📄 `root/main.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

# Import shared variables
module "iam" {
  source = "../iam"
  users  = var.users
}

module "ec2" {
  source = "../ec2"

  amis             = var.amis
  instance_config  = var.instance_config

  # Explicit dependency example
  depends_on = [module.iam]
}
```

---

# 🧪 STEP 6 — Initialize & Run

```bash
cd root

terraform init
terraform plan
terraform apply
```

---

# 🚨 STEP 7 — API THROTTLING SIMULATION

Now simulate large infra behavior:

```bash
terraform plan
```

👉 Terraform will:

* Refresh ALL resources
* Call AWS APIs multiple times

---

# ⚡ STEP 8 — SOLUTION 1: TARGETING

```bash
terraform apply -target=module.ec2
```

✅ Only EC2 runs
✅ Less API calls

---

# ⚡ STEP 9 — SOLUTION 2: DISABLE REFRESH

```bash
terraform plan -refresh=false
```

✅ Skips API calls
⚠️ Use only when state is trusted

---

# ⚡ STEP 10 — TEST LIFECYCLE (IMPORTANT)

### Change tag manually in AWS Console:

Add:

```properties
Env = production
```

Now run:

```bash
terraform apply
```

👉 Terraform will **NOT remove it**

✅ Because:

```hcl
ignore_changes = [tags]
```

---

# ⚡ STEP 11 — TEST create_before_destroy

Change AMI:

```hcl
ami = "new-ami-id"
```

Run:

```bash
terraform apply
```

👉 Terraform:

1. Creates new instance
2. Then destroys old

✅ No downtime

---

# ⚡ STEP 12 — TEST DEPENDENCY

Remove `depends_on` and observe order.

Then add back:

```hcl
depends_on = [module.iam]
```

👉 Forces IAM creation first

---

# ⚡ STEP 13 — COMMENTS PRACTICE

Add all types:

```hcl
# Single line comment

// Another comment

/*
Multi-line comment
for disabling resources
*/
```

---

# 🧠 STEP 14 — count vs for_each TEST

### Change IAM to count (bad practice test)

```hcl
count = 3
name  = "user-${count.index}"
```

👉 Then reorder list → resources recreated

✅ This is WHY for_each is better

---

# 🎯 FINAL 

You just practiced:

### Scaling & API

* Terraform refresh causes API throttling
* Split projects
* Use -target
* Use -refresh=false carefully

### Data Handling

* zipmap()
* map, set, object

### Resource Behavior

* lifecycle:

  * ignore_changes
  * create_before_destroy
  * prevent_destroy (concept)

### Dependencies

* implicit vs explicit

### Iteration

* count (risky)
* for_each (production-safe)

---



**Q:** Why does Terraform cause API throttling?

**Answer:**
Because every `plan` performs a **state refresh**, calling cloud APIs for every resource, which can exceed provider rate limits in large infrastructures.


