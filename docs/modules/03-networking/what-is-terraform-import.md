---
title: "lab:What is Terraform import?"
description: "Terraform import means:  You already have something that exists. Terraform did not create it. You..."
published: 2026-03-30
source: "https://dev.to/jumptotech/what-is-terraform-import-36ph"
tags: []
---

# lab:What is Terraform import?





**Terraform import** means:

You already have something that exists.
Terraform did **not** create it.
You want Terraform to start managing it.

So import connects:

* the **real existing object**
* to a **Terraform resource address**
* inside the **Terraform state**

Important point: the classic `terraform import` command imports the object into **state only**. It does **not automatically write your full configuration** for you. 

1. the **resource block**
2. the **state file**
3. the **import command** or **import block** ([HashiCorp Developer][2])

## 2) Why do we use import?

We use import when:

* a resource was created manually
* a team already has existing infrastructure
* we want to move from “clicking in UI” to “Infrastructure as Code”
* we want Terraform to manage something without recreating it

Examples in real companies:

* existing EC2 instance
* existing S3 bucket
* existing security group
* existing DNS record
* existing local file in a lab

Terraform also warns that one real object should map to only **one Terraform resource address**. Importing the same object multiple times can cause bad behavior. ([HashiCorp Developer][2])

## 3) Main components 

### A. Provider

The provider tells Terraform what API or platform it works with. In this lab we use the `local` provider. Provider requirements are declared inside the `terraform` block. ([HashiCorp Developer][3])

### B. Resource block

A `resource` block describes the object Terraform will manage. Terraform docs say the `resource` block defines a piece of infrastructure and its settings. ([HashiCorp Developer][4])

### C. State

State is Terraform’s mapping between real objects and Terraform addresses. Import writes that mapping into state. ([HashiCorp Developer][2])

### D. Resource address

Example:

```hcl
local_file.student_notes
```

Here:

* `local_file` = resource type
* `student_notes` = local Terraform name

This is the address Terraform uses during import. ([HashiCorp Developer][2])

### E. Import ID

Every resource type has its own import ID format. Terraform’s CLI docs say the ID depends on the resource type. For many resources it is a cloud ID; in our lab it will be the file path. ([HashiCorp Developer][2])

### F. Matching configuration

Terraform docs say before using CLI import, you must write the `resource` configuration block. For configuration-driven import, you use an `import` block plus a destination resource block. ([HashiCorp Developer][1])

---

# 4)  Import an existing local file

## Lab goal



1. manually create a text file on their laptop
2. write Terraform code for that file
3. import that existing file into Terraform state
4. run `terraform plan`
5. confirm Terraform now manages the file without creating it again



# 5) Project folder structure



```text
terraform-import-local-file/
├── versions.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── notes.txt
```

Important:

* `notes.txt` must exist **before** import


---

# 6) File-by-file skeleton

## File 1: `versions.tf`

Copy this exactly:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
```

### What this file does

* sets the Terraform version
* tells Terraform to install the `local` provider

---

## File 2: `variables.tf`

Copy this exactly:

```hcl
variable "file_name" {
  description = "Name of the existing file to import"
  type        = string
  default     = "notes.txt"
}

variable "file_content" {
  description = "Expected content of the file after import"
  type        = string
}
```

### What this file does

* `file_name` = the file Terraform will manage
* `file_content` = expected file content

---

## File 3: `main.tf`

Copy this exactly:

```hcl
resource "local_file" "student_notes" {
  filename = "${path.module}/${var.file_name}"
  content  = var.file_content
}
```

### What this file does

* defines the resource Terraform will manage
* the resource address is:

```hcl
local_file.student_notes
```



---

## File 4: `outputs.tf`

Copy this exactly:

```hcl
output "managed_file_path" {
  description = "Path of the imported file"
  value       = local_file.student_notes.filename
}

output "managed_file_content" {
  description = "Content Terraform expects in the file"
  value       = local_file.student_notes.content
}
```

### What this file does

* shows the file path
* shows the content Terraform manages

---

## File 5: `terraform.tfvars.example`

Copy this exactly:

```hcl
file_name    = "notes.txt"
file_content = "This file existed before Terraform import."
```

### What this file does

* gives students an example variable file
* they must rename it to `terraform.tfvars`

---

## File 6: `notes.txt`

Create this file manually and put this exact content inside:

```text
This file existed before Terraform import.
```

### Why this matters

The content in `notes.txt` must match the Terraform variable value. If it does not match, import may succeed, but `terraform plan` may show changes afterward because Terraform sees drift between configuration and the real file. Terraform’s file functions operate on files that already exist at the beginning of the run, and the `local_file` resource manages local files on disk. ([Terraform Registry][5])

---



## Step 1: Create project folder

```bash
mkdir terraform-import-local-file
cd terraform-import-local-file
```

## Step 2: Create all files

Create:

* `versions.tf`
* `variables.tf`
* `main.tf`
* `outputs.tf`
* `terraform.tfvars.example`
* `notes.txt`

Then paste the code exactly as shown above.

## Step 3: Rename the example vars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

## Step 4: Initialize Terraform

```bash
terraform init
```

### What should happen

Terraform downloads the `local` provider and prepares the working directory.

---

## Step 5: Check the resource before import

Run:

```bash
terraform plan
```



Terraform will likely say it plans to **create** `local_file.student_notes`.

Why?
Because Terraform configuration exists, but the resource is not yet in Terraform state.

The real file exists on disk, but Terraform does not yet know that this existing file should be connected to `local_file.student_notes`.

This is the key learning point.

---

## Step 6: Import the existing file

Run this exact command:

```bash
terraform import local_file.student_notes "$(pwd)/notes.txt"
```

### What this command means

* `local_file.student_notes` = Terraform resource address
* `"$(pwd)/notes.txt"` = the import ID for this lab, which is the file path

This attaches the existing file to the Terraform resource in state. Terraform’s CLI reference defines import usage as:

```bash
terraform import [options] ADDRESS ID
```

and explains that the command imports an existing object into state at the given address. ([HashiCorp Developer][2])

---

## Step 7: Verify state

Run:

```bash
terraform state list
```

Expected output:

```text
local_file.student_notes
```

### What this proves

Now Terraform state knows that `notes.txt` is managed as:

```hcl
local_file.student_notes
```

---

## Step 8: Run plan again

```bash
terraform plan
```

### Expected result

If all file contents match exactly, the plan should show:

```text
No changes. Your infrastructure matches the configuration.
```

That is the success condition for the lab.

---

## Step 9: Check outputs

Run:

```bash
terraform apply -auto-approve
```

Then:

```bash
terraform output
```

### Why apply here?

After import, `apply` should not create anything new if everything matches. It simply confirms state and configuration line up.

---



By the end of this project understand:

1. **Import does not create the object**
2. **Import connects an existing object to Terraform state**
3. **Terraform still needs configuration**
4. **The resource address matters**
5. **If configuration does not match the real object, Terraform shows drift**
6. **State is how Terraform remembers what it manages** ([HashiCorp Developer][2])

---

# 9) Common  mistakes

## Mistake 1: Running import before writing the resource block

Wrong idea:
“Let me import first, code later.”

Problem:
Terraform import needs the destination resource address and matching configuration workflow. Terraform docs explicitly say to write the resource block first for CLI import. ([HashiCorp Developer][6])

---

## Mistake 2: File content does not match

Example:

* `notes.txt` says one thing
* `terraform.tfvars` says another thing

Result:
Import succeeds, but `terraform plan` shows a change.

---

## Mistake 3: Wrong import address

Wrong:

```bash
terraform import local_file.notes notes.txt
```

If the actual resource block is:

```hcl
resource "local_file" "student_notes" { ... }
```

then the correct address is:

```bash
local_file.student_notes
```

---

## Mistake 4: Wrong path in import ID

Use the correct file path. In this lab, this command is the safest:

```bash
terraform import local_file.student_notes "$(pwd)/notes.txt"
```

---

## Mistake 5: Importing the same real object to more than one Terraform resource

Terraform warns against mapping one real object to multiple Terraform addresses. ([HashiCorp Developer][2])

---



“Terraform normally creates resources and then stores them in state.
But sometimes the resource already exists.
Terraform import tells Terraform:
‘Do not create this. It already exists. Start managing it from now on.’”

Very simple flow:

```text
Existing object -> Import -> Terraform state -> Terraform manages it
```

---

# 11) Modern Terraform: import block

 should also know the newer workflow.

Terraform documentation says modern import can use an `import` block, and Terraform can also generate configuration with `terraform plan -generate-config-out=...` in some workflows. ([HashiCorp Developer][1])

## Example `import.tf`

You can add this file:

```hcl
import {
  to = local_file.student_notes
  id = "${path.module}/notes.txt"
}
```



* this is the **configuration-driven** style
* you still need the destination resource block
* it is useful for automation and CI/CD workflows ([HashiCorp Developer][1])



 






