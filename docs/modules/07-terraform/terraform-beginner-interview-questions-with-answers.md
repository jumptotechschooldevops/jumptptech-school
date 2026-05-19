---
title: "Terraform Beginner Interview Questions (with Answers)"
description: "1. What is Terraform?   Answer  Terraform is an Infrastructure as Code (IaC) tool created by..."
published: 2026-03-13
source: "https://dev.to/jumptotech/terraform-beginner-interview-questions-with-answers-58ce"
tags: []
---

# Terraform Beginner Interview Questions (with Answers)



# 1. What is Terraform?

**Answer**

Terraform is an **Infrastructure as Code (IaC) tool created by HashiCorp** that allows engineers to **create, modify, and manage infrastructure using code instead of manually using cloud consoles**.

It supports many providers:

* AWS
* Azure
* GCP
* Kubernetes
* GitHub
* Docker

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}
```

This code creates an EC2 instance.

---

# 2. What problem does Terraform solve?

**Answer**

Terraform solves problems like:

Manual infrastructure creation
Configuration drift
Infrastructure inconsistency
Lack of automation

Benefits:

* Infrastructure automation
* Version control
* Repeatable environments
* Team collaboration

---

# 3. What is Infrastructure as Code (IaC)?

**Answer**

Infrastructure as Code means **managing infrastructure using code instead of manual configuration**.

Example:

Instead of manually creating EC2 in AWS console:

You write code:

```hcl
resource "aws_instance" "web" {}
```

Terraform creates it automatically.

---

# 4. What is a Terraform provider?

**Answer**

A provider is a **plugin that allows Terraform to interact with APIs of cloud platforms or services**.

Example providers:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Terraform now knows it should work with AWS.

---

# 5. What is a Terraform resource?

**Answer**

A resource represents **an infrastructure object**.

Examples:

* EC2 instance
* S3 bucket
* VPC
* Security group

Example:

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}
```

This creates an S3 bucket.

---

# 6. What is a data source in Terraform?

**Answer**

A **data source reads existing infrastructure**.

It does **NOT create resources**.

Example:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
}
```

Terraform reads the latest AMI.

Used when:

* Resource already exists
* You only need information

---

# 7. What is `main.tf`?

**Answer**

`main.tf` is the **main configuration file where Terraform resources are defined**.

Example:

```hcl
main.tf
```

Usually contains:

* provider
* resources
* data sources

Example:

```hcl
provider "aws" {}

resource "aws_instance" "web" {}
```

---

# 8. What is `variables.tf`?

**Answer**

`variables.tf` defines **input variables used in Terraform configuration**.

Example:

```hcl
variable "instance_type" {
  type = string
}
```

Then used in `main.tf`:

```hcl
instance_type = var.instance_type
```

---

# 9. What is `terraform.tfvars`?

**Answer**

`terraform.tfvars` provides **actual values for variables**.

Example:

```hcl
instance_type = "t2.micro"
environment   = "dev"
```

Terraform automatically loads this file.

---

# 10. What is `outputs.tf`?

**Answer**

Outputs show **important information after infrastructure is created**.

Example:

```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

Output example after apply:

```plaintext
instance_ip = 54.20.100.2
```

---

# 11. What are Terraform attributes?

**Answer**

Attributes are **values of a resource returned after creation**.

Example:

```hcl
aws_instance.web.public_ip
aws_instance.web.id
aws_instance.web.arn
```

Example usage:

```hcl
output "ip" {
  value = aws_instance.web.public_ip
}
```

---

# 12. What is `count` in Terraform?

**Answer**

`count` creates **multiple copies of a resource**.

Example:

```hcl
resource "aws_instance" "web" {
  count = 3
}
```

Terraform creates:

```plaintext
web[0]
web[1]
web[2]
```

---

# 13. What is `count.index`?

**Answer**

`count.index` represents the **index number of the resource when using count**.

Example:

```hcl
resource "aws_instance" "web" {
  count = 3

  tags = {
    Name = "server-${count.index}"
  }
}
```

Result:

```plaintext
server-0
server-1
server-2
```

---

# 14. What is `for_each` in Terraform?

**Answer**

`for_each` creates resources **based on maps or sets**.

Example:

```hcl
resource "aws_instance" "web" {
  for_each = {
    server1 = "t2.micro"
    server2 = "t2.small"
  }

  instance_type = each.value
}
```

Creates two instances.

---

# 15. Difference between `count` and `for_each`?

| Feature         | count       | for_each              |
| --------------- | ----------- | --------------------- |
| Uses numbers    | Yes         | No                    |
| Uses maps       | No          | Yes                   |
| Index access    | count.index | each.key / each.value |
| Resource naming | Harder      | Easier                |

Example:

```plaintext
count → server-0
for_each → server1
```

---

# 16. What are Terraform locals?

**Answer**

Locals are **temporary variables used only inside the configuration**.

Example:

```hcl
locals {
  instance_name = "dev-server"
}
```

Use:

```hcl
Name = local.instance_name
```

Benefits:

* cleaner code
* reuse values
* avoid repetition

---

# 17. What are Terraform functions?

**Answer**

Functions are **built-in operations used to manipulate data**.

Examples:

| Function | Purpose         |
| -------- | --------------- |
| length() | count items     |
| upper()  | uppercase       |
| lower()  | lowercase       |
| concat() | combine lists   |
| lookup() | read map values |

Example:

```hcl
length(var.instances)
```

---

# 18. What Terraform commands do you use daily?

**Answer**

Common commands:

Initialize project

```console
terraform init
```

Check configuration

```console
terraform validate
```

See execution plan

```console
terraform plan
```

Apply infrastructure

```console
terraform apply
```

Destroy infrastructure

```console
terraform destroy
```

---

# 19. What is Terraform state?

**Answer**

Terraform state is a **file that stores the mapping between Terraform configuration and real infrastructure**.

File:

```json
terraform.tfstate
```

It tracks:

* created resources
* resource IDs
* infrastructure metadata

---

# 20. What is the Terraform workflow?

**Answer**

Typical workflow:

1. Write configuration

```plaintext
main.tf
variables.tf
```

2. Initialize Terraform

```console
terraform init
```

3. Preview infrastructure

```console
terraform plan
```

4. Apply infrastructure

```console
terraform apply
```

5. Destroy when not needed

```console
terraform destroy
```

---

# 21. What language does Terraform use?

**Answer**

Terraform uses **HCL (HashiCorp Configuration Language)**.

Example:

```hcl
resource "aws_instance" "web" {}
```

---

# 22. What is a Terraform module?

**Answer**

A module is a **reusable Terraform configuration**.

Example:

```plaintext
modules/
   ec2/
      main.tf
      variables.tf
```

Use module:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

---

# 23. What is `terraform init`?

**Answer**

`terraform init` initializes the Terraform project.

It:

* downloads providers
* creates `.terraform` folder
* prepares backend

---

# 24. What is `.terraform.lock.hcl`?

**Answer**

This file **locks provider versions** to ensure consistent builds.

Example:

```plaintext
aws provider version = 5.30
```

---

# 25. Why is Terraform popular in DevOps?

**Answer**

Because it provides:

* automation
* reproducibility
* version control
* multi-cloud support
* infrastructure management using code


