---
title: "Advanced Terraform Concepts"
description: "Step 1 — Create Project   Create a new project.    mkdir terraform-functions-lab cd..."
published: 2026-03-16
source: "https://dev.to/jumptotech/advanced-terraform-concepts-2cne"
tags: []
---

# Advanced Terraform Concepts




# Step 1 — Create Project

Create a new project.

```bash
mkdir terraform-functions-lab
cd terraform-functions-lab
```

Create files:

```hcl
main.tf
variables.tf
outputs.tf
terraform.tfvars
```

---

# Step 2 — Terraform Settings Block

This tells Terraform which providers to use.

### main.tf

```hcl
terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.4"
    }

  }
}
```

### Explanation

Settings block defines:

* Terraform version
* required providers
* provider versions

This ensures **consistent environments across teams**.

---

# Step 3 — Provider Configuration

Add AWS provider.

```hcl
provider "aws" {
  region = var.aws_region
}
```

---

# Step 4 — Variables

### variables.tf

```hcl
variable "aws_region" {
  default = "us-east-2"
}

variable "instance_types" {

  type = map(string)

  default = {
    dev  = "t2.micro"
    prod = "t2.small"
  }

}

variable "ports" {

  type = list(number)

  default = [22,80,443]

}

variable "servers" {

  type = list(string)

  default = [
    "web",
    "api",
    "worker"
  ]

}
```

---

# Step 5 — Terraform Functions

We will now use these functions:

```hcl
lookup()
length()
element()
format()
timestamp()
```

---

# Step 6 — Security Group with Dynamic Block

Dynamic blocks are useful when you want **Terraform to generate multiple blocks automatically**.

```hcl
resource "aws_security_group" "web" {

  name = "terraform-dynamic-sg"

  dynamic "ingress" {

    for_each = var.ports

    content {

      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }

}
```

### What dynamic block does

Instead of writing:

```hcl
ingress {22}
ingress {80}
ingress {443}
```

Terraform generates them automatically.

---

# Step 7 — Using count

Create multiple EC2 instances.

```hcl
resource "aws_instance" "count_servers" {

  count = length(var.servers)

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = lookup(var.instance_types,"dev")

  tags = {

    Name = format("count-server-%s", element(var.servers,count.index))

  }

}
```

### Functions used

#### length()

Counts number of elements.

```hcl
length(var.servers)
```

If servers list has **3 elements**, Terraform creates **3 instances**.

---

#### element()

Returns element from list.

```hcl
element(var.servers,count.index)
```

Example result:

```plaintext
web
api
worker
```

---

#### format()

Formats strings.

```hcl
format("count-server-%s",name)
```

Output example:

```plaintext
count-server-web
count-server-api
count-server-worker
```

---

#### lookup()

Gets value from map.

```hcl
lookup(var.instance_types,"dev")
```

Returns:

```plaintext
t2.micro
```

---

# Step 8 — Using for_each

Create instances using **for_each**.

```hcl
resource "aws_instance" "foreach_servers" {

  for_each = toset(var.servers)

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {

    Name = "foreach-${each.value}"

  }

}
```

### Difference

count

```plaintext
server[0]
server[1]
server[2]
```

for_each

```plaintext
server["web"]
server["api"]
server["worker"]
```

---

# Step 9 — Using timestamp()

Create file containing deployment time.

```hcl
resource "local_file" "deployment_info" {

  filename = "deployment.txt"

  content = "Deployment time: ${timestamp()}"

}
```

Example output file:

```plaintext
Deployment time: 2026-03-16T14:20:33Z
```

---

# Step 10 — Terraform Outputs

### outputs.tf

```hcl
output "server_count" {

  value = length(var.servers)

}

output "deployment_time" {

  value = timestamp()

}
```

Run:

```console
terraform output
```

---

# Step 11 — Initialize Terraform

Run:

```bash
terraform init -upgrade
```

### What -upgrade does

It upgrades providers to the **latest compatible version**.

Example:

```plaintext
aws v5.40 -> v5.55
```

---

# Step 12 — Terraform Plan with Output File

Run:

```console
terraform plan -out=infra.plan
```

This saves execution plan.

Benefits:

* review plan
* share plan with team
* ensure no changes occur before apply

Apply saved plan:

```console
terraform apply infra.plan
```

---

# Step 13 — Target Specific Resource

Plan only one resource.

```console
terraform plan -target=local_file.deployment_info
```

Apply only one resource.

```console
terraform apply -target=local_file.deployment_info
```

Destroy specific resource.

```console
terraform destroy -target=local_file.deployment_info
```

---

# Step 14 — Target Security Group

Example:

```console
terraform apply -target=aws_security_group.web
```

This creates **only security group**.

---

# Step 15 — Terraform Taint

Taint forces resource **recreation**.

Example:

```console
terraform taint aws_instance.count_servers[0]
```

Next apply:

```console
terraform apply
```

Terraform destroys and recreates that instance.

---

# Step 16 — Terraform Graph

Visualize Terraform infrastructure.

Run:

```console
terraform graph
```

Example output:

```dot
aws_security_group.web
        ↓
aws_instance.count_servers
        ↓
outputs
```

You can convert graph to image:

```console
terraform graph | dot -Tpng > graph.png
```

---

# Step 17 — Terraform Output Command

View outputs:

```console
terraform output
```

Example:

```hcl
server_count = 3
deployment_time = 2026-03-16T14:20:33Z
```

---

# Step 18 — Terraform at Scale (API Throttling)

When Terraform manages **hundreds or thousands of resources**, cloud providers may limit requests.

Example:

AWS allows limited API calls per second.

If Terraform sends too many requests:

```plaintext
API throttling
Rate exceeded
```

### Solutions

1️⃣ Reduce parallelism

```console
terraform apply -parallelism=5
```

Default is **10 parallel operations**.

---

2️⃣ Use modules

Split infrastructure into smaller deployments.

---

3️⃣ Use workspaces

Separate environments:

```plaintext
dev
stage
prod
```

---

4️⃣ Use remote state

Store state in:

```plaintext
S3
Terraform Cloud
Azure Storage
```

---

# Final Architecture Created

This lab creates:

```plaintext
Security Group
3 EC2 instances using count
3 EC2 instances using for_each
Local file with timestamp
Outputs
```

 also practice:

```console
terraform init -upgrade
terraform plan -out
terraform apply -target
terraform destroy -target
terraform graph
terraform taint
terraform output
```


