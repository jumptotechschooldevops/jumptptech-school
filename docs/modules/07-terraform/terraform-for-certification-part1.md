---
title: "terraform for certification part#1"
description: "Authentication and Authorization in Terraform            Introduction   Before Terraform can..."
published: 2025-12-08
source: "https://dev.to/jumptotech/terraform-for-certification-part1-3g7h"
tags: []
---

# terraform for certification part#1





## Authentication and Authorization in Terraform

### Introduction

Before Terraform can create or manage any infrastructure, the **first and most critical step** is handling **authentication and authorization**.

Regardless of the provider (AWS, GitHub, Azure, Kubernetes, etc.), Terraform **must first prove who it is** and **what it is allowed to do**.

---

## High-Level Workflow

1. Terraform is installed on your local machine
2. You configure a provider (example: AWS)
3. Terraform attempts to create a resource
4. The provider **rejects the request** unless:

   * Terraform is authenticated
   * Terraform is authorized

This behavior is identical to how humans access cloud consoles.

---

## Console vs Terraform (Simple Analogy)

### Console Access

To create an EC2 instance via AWS Console:

1. You log in using credentials
2. AWS checks who you are
3. AWS checks what permissions you have
4. Resource is created if allowed

### Terraform Access

To create the same EC2 instance via Terraform:

1. Terraform supplies credentials
2. AWS verifies identity (authentication)
3. AWS verifies permissions (authorization)
4. Resource is created if allowed

---

## Authentication

### Definition

**Authentication** is the process of verifying **who the user is**.

The provider checks whether the identity exists.

### Examples

| Provider   | Authentication Method   |
| ---------- | ----------------------- |
| AWS        | Access Key + Secret Key |
| GitHub     | Personal Access Token   |
| Kubernetes | kubeconfig / certs      |
| Azure      | Service Principal       |

### Example (AWS)

If Terraform uses credentials for user **Alice**, AWS checks:

* Does user Alice exist?
* Are the credentials valid?

If yes → authentication succeeds.

---

## Authorization

### Definition

**Authorization** determines **what the authenticated user is allowed to do**.

Even if a user exists, they may:

* Have full access
* Have read-only access
* Have no permissions at all

---


---

## Key Terraform Learning

Terraform:

* Does **not bypass security**
* Uses **exactly the same permission model** as console users
* Will **fail immediately** if permissions are missing

---

## Provider-Specific Authentication Differences

Each Terraform provider defines its **own authentication requirements**.

### AWS Provider

Requires:

* Access Key
* Secret Key



### GitHub Provider

Requires:

* Personal Access Token (PAT)

You generate this token in:

```
GitHub → Settings → Developer Settings → Tokens
```

---

## Authorization in GitHub Tokens

When creating a GitHub token, you can control:

* Which repositories it can access
* Read vs write permissions
* Whether it can delete repositories
* Access to issues, pull requests, discussions, etc.

### Best Practice

Do **not** give Terraform unlimited GitHub permissions.

Grant **only** what Terraform needs.

Example:

* Repository creation → repo permissions
* No need for org-wide delete access

---

## Security Best Practices

* Principle of least privilege
* Separate tokens per project
* Avoid admin-level permissions unless necessary
* Rotate credentials regularly
* Never hardcode secrets in Terraform files

---

## Final Summary

* **Authentication** = Who you are
* **Authorization** = What you can do
* Terraform requires **both**
* Credentials and permissions vary by provider
* Terraform fails fast when permissions are missing
* Always scope permissions carefully







# Launching Your First EC2 Instance Using Terraform



## Virtual Machines Across Cloud Providers

Different cloud providers use different terminology for a virtual machine:

| Cloud Provider | VM Name                     |
| -------------- | --------------------------- |
| AWS            | EC2 (Elastic Compute Cloud) |
| DigitalOcean   | Droplet                     |
| Azure          | Virtual Machine             |
| GCP            | Compute Engine              |

In AWS, a virtual machine is called an **EC2 instance**, which essentially represents a **virtual server** running in the cloud.

---

## Important Considerations When Creating a Virtual Machine

### 1. Region Selection

Cloud providers operate in **multiple geographic regions** such as:

* US
* Europe
* Asia
* Australia
* South America

When creating any resource (like EC2), you must decide:

> **Which region should the resource be created in?**

Examples in AWS:

* us-east-1 (North Virginia)
* ap-southeast-1 (Singapore)
* eu-west-1 (Ireland)
* ap-south-1 (Mumbai)

This region selection will later be defined inside Terraform.

---

### 2. Virtual Machine Configuration

A virtual machine has multiple configuration parameters:

* Operating System (Linux, Windows, etc.)
* CPU
* Memory
* Storage
* Networking
* Authentication (Key Pair)

All these configurations must be specified when creating the VM — either manually or via Terraform.

---

## Manual EC2 Creation (For Understanding the Workflow)

> **Note:** This step is only for understanding.
> We do NOT recommend creating instances manually when using Terraform.

### Step 1: Open EC2 Service

Search for **EC2** in AWS Console.
You will see:

> “Virtual servers in the cloud”

---

### Step 2: Launch EC2 Instance

1. Click **Launch Instance**
2. Give it a name:

   ```
   manual-ec2
   ```

---

### Step 3: Choose Operating System (AMI)

AMI = Amazon Machine Image (Operating System)

Examples:

* Amazon Linux
* Ubuntu
* Windows
* macOS

For demo:

* Select **Amazon Linux**

---

### Step 4: Select Instance Type

Instance type defines **CPU + Memory**.

Example:

* `t2.micro` → 1 vCPU, 1 GiB RAM (Free Tier eligible)

Larger example:

* `c3.8xlarge` → 32 vCPU, 60 GiB RAM (Expensive)

For demo:

* Choose **t2.micro**

---

### Step 5: Key Pair

Key pair controls SSH login.

For simplicity:

* Select **Proceed without key pair**

---

### Step 6: Launch Instance

AWS will show:

> “Successfully initiated the launch of instance”

After a few seconds:

* Instance state becomes **Running**



## Setting Up Terraform Workspace

### Step 1: Create Project Folder

On Desktop, create:

```
terraform-jumptotech
```

---

### Step 2: Open in Visual Studio Code

Open the folder using:

* VS Code → Open Folder
  OR
* Right click → Open with Code

---

### Step 3: Create Terraform File

Create a new file:

```
first_ec2.tf
```

> Terraform files must end with `.tf`

---

## Configuring AWS Provider

### Step 1: Open Terraform AWS Provider Docs

From Terraform Registry:

* Provider: **AWS**

This documentation explains authentication and usage.

---

### Step 2: Add Provider Block

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}
```

#### Important Notes:

* Provider name changes depending on cloud (`aws`, `github`, `azure`, etc.)
* Region code must match AWS region
* Credentials were created earlier in IAM

---

## Defining the EC2 Resource

### Step 1: Find EC2 Resource

In AWS provider docs:

* Navigate to **EC2**
* Choose **aws_instance**

This resource represents an EC2 virtual machine.

---

### Step 2: Add EC2 Resource Code

```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
}
```

#### Explanation:

* `aws_instance` → Resource type
* `my_ec2` → Logical name inside Terraform
* `ami` → Operating system image (region-specific)
* `instance_type` → CPU and memory configuration

⚠️ AMI IDs are **region-specific**
If you change region, you must change the AMI ID.

---

## Running Terraform Commands

### Step 1: Navigate to Project Folder

Make sure terminal is in:

```
terraform-jumptotech
```

---

### Step 2: Initialize Terraform

```bash
terraform init
```

What this does:

* Downloads AWS provider plugins
* Prepares Terraform working directory

---

### Step 3: Review the Plan

```bash
terraform plan
```

Terraform shows:

* What resources will be created
* What configurations are applied

✅ No resources are created yet.

---

### Step 4: Apply the Configuration

```bash
terraform apply
```

Terraform will ask for confirmation:

```
Do you want to perform these actions?
```

Type:

```
yes
```

✅ EC2 instance is created in AWS.

---

## Verifying in AWS Console

* Go to EC2 Dashboard
* Instance is running
* Instance type: `t2.micro`
* Region: `us-east-1`

---

## Modifying the EC2 Instance (Adding a Name Tag)

### Update Terraform Code

```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  tags = {
    Name = "my first EC2"
  }
}
```

---

### Run Plan Again

```bash
terraform plan
```

You will see:

* **1 resource to change**

---

### Apply Changes

```bash
terraform apply
```

Type:

```
yes
```

✅ Name tag added successfully.

---

## Reverting Changes

* Remove the `tags` block
* Run `terraform apply` again

Terraform automatically:

* Removes the tag
* Keeps the instance running

---

## Key Terraform Concepts Learned

* Provider block remains constant for AWS
* Resources can be added, modified, or removed
* Terraform manages state and changes safely
* `plan` previews changes
* `apply` executes changes

---

## Summary

* Created EC2 manually to understand workflow
* Created EC2 using Terraform
* Modified EC2 using Terraform
* Understood provider vs resource
* Learned Terraform’s core workflow



# Providers and Resources in Terraform (In Detail)



## Why Providers Matter in Terraform

Terraform supports thousands of providers that allow it to manage infrastructure across different platforms.

Examples include:

* AWS
* Azure
* GCP
* Alibaba Cloud
* Kubernetes
* GitHub
* DigitalOcean
  …and many more.

Each provider allows Terraform to communicate with the **external API** of that platform.

---

## Terraform Registry

All providers are listed on the **Terraform Registry**:

```
https://registry.terraform.io
```

At present:

* There are **3000+ providers**
* Earlier this number was around **700**
* This growth shows Terraform’s **massive adoption worldwide**

You can browse:

* Providers
* Documentation
* Resource references
* Example usage

---

## Providers Are Plugins (Important Concept)

### What is a Provider Internally?

Behind the scenes:

> A Terraform provider is a **plugin** that lets Terraform manage an external API.

Terraform itself does not know how to talk to AWS, Azure, or Kubernetes.

Instead:

* Terraform downloads provider plugins
* Plugins handle API communication
* Terraform manages state and execution logic

---

## Provider Plugins and `terraform init`

Whenever you:

* Add a new provider block
* Change provider versions
* Add a new provider

You must run:

```bash
terraform init
```

### What Does `terraform init` Do?

* Downloads the required provider plugins
* Stores them locally
* Prepares the working directory

---

## Where Are Provider Plugins Stored?

Inside your project directory:

```text
.terraform/
└── providers/
```

### Example (AWS Provider)

```text
.terraform/providers/registry.terraform.io/hashicorp/aws/
```

* Plugin size: ~300 MB
* This plugin manages **all AWS resources**

---

## Working with Multiple Providers

Terraform allows **multiple providers in the same project**.

### Example Scenario

Today:

* You deploy EC2 in AWS

Tomorrow:

* You deploy Kubernetes in Azure

Terraform supports this seamlessly.

---

## Example: Adding Azure Provider

Add this to your `.tf` file:

```hcl
provider "azurerm" {
  features {}
}
```

Now run:

```bash
terraform init
```

Terraform will:

* Download Azure provider plugin
* Store it under `.terraform/providers`

---

## Key Learning #1: Provider Plugins

* Providers are plugins
* Plugins are downloaded during `terraform init`
* Plugins live inside `.terraform/`
* Multiple providers can coexist in one project

---

## Resource Blocks (Core Terraform Concept)

### What Is a Resource?

A **resource block** describes **infrastructure objects** managed by Terraform.

Examples:

* EC2 instance
* Load Balancer
* IAM User
* Database
* Kubernetes cluster

---

### Resource Block Syntax

```hcl
resource "<TYPE>" "<NAME>" {
  ...
}
```

Example:

```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"
}
```

---

## Understanding Resource Type and Name

### Resource Type

* `aws_instance`
* `aws_alb`
* `aws_iam_user`
* `digitalocean_droplet`
* `azurerm_kubernetes_cluster`

✅ **Must match provider documentation**
❌ Cannot be invented or modified

---

### Resource Name (Local Name)

* `my_ec2`
* `web`
* `db`
* `backend`

✅ Can be anything
✅ Used internally by Terraform
✅ Must be unique per resource type

---

## Resource Uniqueness Rule

The combination below must be **unique**:

```text
resource_type + local_name
```

❌ Invalid:

```hcl
resource "aws_instance" "my_ec2" { ... }
resource "aws_instance" "my_ec2" { ... }
```

✅ Valid:

```hcl
resource "aws_instance" "my_ec2" { ... }
resource "aws_instance" "web"   { ... }
```

---

## Practical Example: Duplicate Resource Error

If you define:

```hcl
resource "aws_instance" "my_ec2" { ... }
resource "aws_instance" "my_ec2" { ... }
```

Terraform error:

```
Error: Duplicate resource "aws_instance" "my_ec2"
```

Fix:

* Change the second resource name

---

## Provider and Resource Compatibility (Very Important)

### Rule

> A resource must be supported by its provider.

Example:

* `aws_instance` → handled by **AWS provider**
* `azurerm_kubernetes_fleet_manager` → handled by **Azure provider**

❌ Azure provider cannot create AWS resources
❌ AWS provider cannot create Azure resources

---

## Multiple Providers in One Project

You can have:

* AWS provider
* Azure provider
* Kubernetes provider

All inside the same Terraform directory.

Terraform automatically uses:

* AWS plugin for `aws_*` resources
* Azure plugin for `azurerm_*` resources

---

## Do You Need to Learn Terraform Again for Each Provider?

### Short Answer

✅ **No**

### Explanation

* Terraform syntax remains the same
* Commands remain the same
* Workflow remains the same

Only changes:

* Provider configuration
* Resource types
* Resource arguments

---




## Provider Bugs and Issues (Real-World Note)

Even officially maintained providers (like AWS) can:

* Have bugs
* Have unexpected behavior
* Require version upgrades

### What To Do?

* Check provider GitHub repository
* Look at **Issues**
* Review **Pull Requests**
* Wait for patches if needed

---

## Example: AWS Provider Popularity

* Millions of downloads monthly
* Large community usage
* Bugs are **rare**, but possible

GitHub repository includes:

* Bug reports
* Feature requests
* Documentation fixes

---

## Key Takeaways

* Providers are plugins
* `terraform init` downloads providers
* Resources define infrastructure
* Resource type is fixed
* Resource name must be unique
* Multiple providers can coexist
* Terraform core remains same across providers

---

## Conclusion

Understanding **providers and resources** is fundamental to Terraform.

Once you grasp these concepts:

* You can manage any infrastructure
* Across any cloud
* Using the same Terraform foundation





# Terraform Provider Tiers, GitHub Provider Demo & Resource Destruction



## Terraform Provider Tiers

Terraform providers are divided into:

### 1. Official Providers

* Owned and maintained by **HashiCorp**
* Most stable and reliable
* Fully tested and well documented

**Examples:**

* AWS
* Azure
* GCP
* Kubernetes
* Active Directory
* HashiCorp Vault

✅ **Recommended for production**

---

### 2. Partner Providers

* Maintained by **technology companies that partner with HashiCorp**
* Generally stable
* Good community support

**Examples:**

* Alibaba Cloud
* Oracle Cloud Infrastructure
* DigitalOcean
* GitHub
* MongoDB Atlas

✅ **Safe to use in most cases**

---

### 3. Community Providers

* Maintained by **individual contributors**
* Not officially backed by HashiCorp or large vendors
* May have bugs or slower fixes

⚠️ **Not recommended for production unless unavoidable**

---

## Provider Tiers in Terraform Registry

On the Terraform Registry (registry.terraform.io), providers are clearly labeled as:

* **Official**
* **Partner**
* **Community**

This helps you quickly assess which provider to use.

---

## Provider Namespaces (Important Concept)

Namespaces help Terraform identify **who owns the provider**.

### Official Provider Namespace

```text
hashicorp/<provider>
```

Examples:

* hashicorp/aws
* hashicorp/azurerm
* hashicorp/kubernetes

---

### Partner Provider Namespace

```text
<company>/<provider>
```

Examples:

* oracle/oci
* digitalocean/digitalocean
* integrations/github

---

### Community Provider Namespace

```text
<individual>/<provider>
```

Examples vary based on contributor name.

---

## Required Providers Block (Very Important)

For **non-HashiCorp providers**, Terraform requires an explicit provider source.

### Example: DigitalOcean Provider

```hcl
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}
```

❌ This will **not work**:

```hcl
provider "digitalocean" {}
```

✅ Always use `required_providers` for partner & community providers.

---

## HashiCorp Providers (Optional but Recommended)

HashiCorp providers **can work without** `required_providers`, but best practice is to use it.

Example (AWS):

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

---

## Key Takeaways (Provider Tiers)

* Prefer **official providers**
* Partner providers are usually safe
* Avoid community providers in production
* Namespaces identify provider ownership
* `required_providers` block is critical for non-HashiCorp providers

---

# Part 2: GitHub Provider – Practical Demo

## Objective

Create a **GitHub repository using Terraform** to prove that Terraform skills transfer easily across providers.

---

## GitHub Provider Overview

* GitHub provider is a **partner provider**
* Namespace:

```text
integrations/github
```

---

## Step 1: Create GitHub Provider Configuration

Create a file:

```text
github.tf
```

Add provider configuration:

```hcl
terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {
  token = "GITHUB_TOKEN"
}
```

---

## Step 2: Generate GitHub Token

1. GitHub → Settings
2. Developer Settings
3. Personal Access Tokens
4. Fine-grained token
5. Repository access: **All repositories**
6. Repository permissions:

   * Administration → Read & Write

⚠️ Token is shown **only once**

---

## Step 3: Create GitHub Repository Resource

```hcl
resource "github_repository" "example" {
  name       = "example"
  visibility = "public"
}
```

---

## Step 4: Deploy Using Terraform

```bash
terraform init
terraform plan
terraform apply
```

Type:

```text
yes
```

✅ GitHub repository is created successfully

---

## Key Learning from GitHub Demo

* Provider configuration is similar across providers
* Authentication always comes first
* Resources are provider-specific
* Terraform workflow stays the same:

  * init
  * plan
  * apply

---

# Part 3: Destroying Resources in Terraform

## Why Destruction Matters

Cloud resources cost money.

Best practice:

> **Destroy resources after testing**

---

## Resources Created So Far

* AWS EC2 instance
* GitHub repository

---

## Method 1: Destroy All Resources

```bash
terraform destroy
```

✅ Destroys **all resources** in the folder

Terraform will:

* Show what will be destroyed
* Ask for confirmation

---

## Method 2: Destroy a Specific Resource (Targeted)

Use:

```bash
terraform destroy -target=RESOURCE_TYPE.LOCAL_NAME
```

Example:

```bash
terraform destroy -target=aws_instance.my_ec2
```

✅ Only EC2 instance is destroyed
✅ GitHub repository remains

---

## Understanding `-target`

`-target` uses:

```text
resource_type.local_name
```

Examples:

* aws_instance.my_ec2
* github_repository.example

---

## Important Terraform Behavior

Even after destroying a resource:
✅ The **code still exists**

Terraform will:

* Recreate the resource on next `apply`

---

## Best Practice: Remove or Comment Code

### Option 1: Remove Resource Block

Terraform stops managing it.

---

### Option 2: Comment Resource Block

```hcl
# resource "aws_instance" "my_ec2" {
#   ami = "..."
# }
```

Terraform will plan to **destroy** it.

---

## Example: Destroying via Code Removal

1. Comment GitHub repository resource
2. Run:

```bash
terraform plan
```

3. Terraform detects resource removal
4. Run:

```bash
terraform apply
```

✅ Repository destroyed

---

## Key Takeaways (Destroying Resources)

* `terraform destroy` removes everything
* `-target` removes a specific resource
* Code presence controls resource lifecycle
* Removing code = resource removal
* Terraform is declarative, not imperative

---

## Final Summary

* Providers are tiered: official, partner, community
* Use official providers whenever possible
* Provider source matters
* Terraform syntax stays consistent across providers
* Resources can be destroyed in multiple controlled ways
* Always clean up infrastructure



# AWS Authentication Configuration in Terraform (Best Practices)


Example:

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA..."
  secret_key = "..."
}
```

While this works technically, **this approach is insecure and not recommended**.

---

## Why Hardcoding Credentials Is Dangerous

### Common Security Problems

* Developers commit Terraform code to GitHub with credentials included
* Repositories may be **public**
* Even private repos allow other teammates to read credentials
* If credentials are misused, **you are responsible**

### Real-World Consequences

* AWS account compromise
* Unexpected cloud bills
* Credential rotation and incident response

✅ **Best practice:**
Never store secrets directly in Terraform files.


We want Terraform to work **without** hard-coding credentials.

Example of an ideal provider block:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The question is:

> How does Terraform authenticate if credentials are not specified?

---

## Alternative Authentication Methods for AWS Provider

Terraform supports multiple secure authentication methods, including:

1. AWS shared credentials & config files (recommended)
2. Environment variables
3. IAM role assumption
4. AWS SSO / Okta / federated logins
5. EC2 instance profiles (later topics)


## Shared Credentials & Config Files

Terraform can read credentials from files stored **outside your Terraform project**.

### Default Locations Terraform Checks

#### Linux / macOS

```
~/.aws/credentials
~/.aws/config
```

#### Windows

```
%USERPROFILE%\.aws\credentials
%USERPROFILE%\.aws\config
```

If credentials exist here, Terraform will automatically use them **without any provider changes**.

---

## Why This Approach Is Better

* Credentials are never committed
* Each user has their own keys
* No path hard-coding
* Works across teams
* Matches AWS best practices

---

## AWS CLI and Terraform (Important Relationship)

AWS CLI:

* Manages AWS resources from command line
* Stores credentials in `.aws/credentials`
* Uses the **same locations** Terraform reads from

✅ If AWS CLI works, Terraform works.


### Existing Setup

We have a file:

```text
aws-provider-config.tf
```

It creates an IAM user:

```hcl
resource "aws_iam_user" "demo" {
  name = "kplabs-demo-user"
}
```

Initially, credentials were hardcoded.

---

### Step 1: Test Hardcoded Setup

```bash
terraform apply -auto-approve
```

✅ IAM user is created successfully.

---

### Step 2: Remove Credentials from Provider

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Run:

```bash
terraform plan
```

❌ Error:

```
No valid credential sources found for AWS provider
```

This is expected.

---

## Installing AWS CLI

### Installation

AWS CLI is available for:

* Windows (MSI installer)
* macOS (pkg installer)
* Linux

Download from official AWS documentation.

---

### Verify Installation

```bash
aws
```

✅ Help output confirms installation.

---

## Configuring AWS CLI Credentials

Run:

```bash
aws configure
```

Enter:

* Access Key
* Secret Key
* Default Region
* Output format (optional)

AWS CLI stores credentials here:

```
.aws/credentials
.aws/config
```

---

## Verifying Credential Storage (Windows Example)

```
C:\Users\<username>\.aws\
```

Files:

* credentials
* config

Terraform will **automatically read these files**.

---

## Retesting Terraform (Secure Way)

Run:

```bash
terraform plan
terraform apply -auto-approve
```

✅ Resources are created successfully
✅ No secrets in Terraform code
✅ Safe to commit publicly

---

## Other AWS Authentication Methods (Overview)

Terraform AWS provider also supports:

* ✅ Environment variables

  ```
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  ```
* ✅ IAM role assumption
* ✅ AWS SSO / Okta
* ✅ EC2 instance profiles

We focus on **AWS CLI approach** because:

* It integrates with SSO
* Works with enterprises
* Common in production setups

---





# Terraform State File – Introduction

## What Is Terraform State?

Terraform state is a **database** that tracks:

* Resources created
* Resource IDs
* Current configuration
* Dependencies

Terraform state is stored by default in:

```
terraform.tfstate
```

---

## Analogy: Application Database

Just like:

* A website stores users in a database
  Terraform stores infrastructure details in its **state file**.

If the database is lost:

* Users must re-register

If Terraform state is lost:

* Terraform forgets what it created

---

## Why State Is Critical

Example:

* Terraform creates an EC2 instance
* Instance ID is saved in state
* Later, you modify instance type

Terraform reads the state to know:

> Which EC2 instance should be modified?

Without state → Terraform guesses → errors & duplication.

---

## Practical Demo: Terraform State Creation

### Initial Condition

* No running EC2 instances
* No `terraform.tfstate` file

Run:

```bash
terraform apply
```

✅ EC2 instance created
✅ `terraform.tfstate` file generated automatically

---

## Viewing State File Contents

State file:

* JSON format
* Contains resource IDs, attributes

Example:

```json
"instance_id": "i-0fb40..."
```

---

## What Happens When State File Is Missing?

Rename:

```
terraform.tfstate → terraform.tfstate.old
```

Run:

```bash
terraform plan
```

Terraform output:

* Plans to create a **new EC2 instance**

❌ Terraform forgot existing infrastructure because state is missing.

---

## Important State File Rules

### 1️⃣ Terraform stores state in `terraform.tfstate`

### 2️⃣ Format is JSON

### 3️⃣ **Never modify state manually**

Manual changes can:

* Corrupt state
* Break Terraform
* Cause production issues

---

## Terraform State Backup

Terraform creates:

```
terraform.tfstate.backup
```

⚠️ Not sufficient for production
✅ Use remote state & backups (covered later)

---

## Restoring State File

Restore original state name:

```
terraform.tfstate
```

Run:

```bash
terraform plan
```

✅ Terraform correctly detects existing resources.

---

## Destroying Resources & State

Run:

```bash
terraform destroy
```

✅ Infrastructure is deleted
✅ State file remains (but empty of resources)

Terraform **never deletes state automatically**.

---

## Key Takeaways

### Authentication

* Never hardcode AWS credentials
* Use AWS CLI shared credentials
* Safe for teams and production

### State File

* Tracks managed infrastructure
* Required for updates & deletes
* Must be protected and backed up
* Never manually edited




# Provider Versioning in Terraform (In Detail)



## High-Level Provider Architecture

Let’s first understand how Terraform works with providers.

### Architecture Flow

1. You write Terraform code (`.tf` files)
2. Terraform initializes provider plugins
3. Provider plugins communicate with the cloud provider API
4. Infrastructure is created or modified

Example:

* Terraform file creates a **DigitalOcean droplet**
* Terraform uses **DigitalOcean provider plugin**
* Provider plugin calls DigitalOcean API
* Server is created successfully

Terraform **never talks directly to the cloud** — it always goes through **provider plugins**.

---

## Terraform Version vs Provider Version

✅ **Very important distinction**

* Terraform CLI has its **own version**
* Each provider plugin has its **own independent version**

They are:

* Released separately
* Developed independently
* Updated at different speeds

Example:

* Terraform version: `1.x`
* DigitalOcean provider: `1.0`, later `2.0`
* AWS provider: `3.x`, `4.x`, etc.

---

## Why Provider Versioning Is Critical

### Real-World Analogy: Windows OS

* Windows 7 → Stable, known behavior
* Windows 10 → New features, breaking changes possible

If you upgrade blindly:

* Applications may break
* Workflows may fail

Terraform providers behave the same way.

✅ **A newer provider version does not guarantee compatibility**

---

## What Happens If You Don’t Specify a Version?

If no version constraint is defined:

```bash
terraform init
```

Terraform will:

* Download the **latest provider version**
* Even in production

⚠️ This can introduce:

* Breaking changes
* Deprecated arguments
* Resource behavior changes

---

## Best Practice: Always Pin Provider Versions

Terraform allows you to control provider versions using:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

This ensures **stability and predictability**.

---

## Provider Version Constraints (Important)

Terraform supports multiple version constraint operators.

### 1️⃣ Greater Than or Equal To

```hcl
version = ">= 1.0"
```

* Allows **1.0 and above**
* Blocks older versions

---

### 2️⃣ Less Than or Equal To

```hcl
version = "<= 1.0"
```

* Allows versions **up to 1.0**
* Blocks newer versions

---

### 3️⃣ Tilde (`~>`) Operator (Most Common)

```hcl
version = "~> 3.0"
```

✅ Allows:

* 3.0
* 3.1
* 3.27
* 3.x

❌ Blocks:

* 4.0
* 2.x

👉 Meaning: **Any compatible patch/minor version within the same major release**

---

### 4️⃣ Range Constraint

```hcl
version = ">= 2.10, <= 2.30"
```

✅ Allows:

* 2.10 → 2.30

❌ Blocks:

* 2.9
* 2.31+
* 3.x

---

## Practical Demo: Provider Versioning

### Project Structure

* Folder: `provider-versioning`
* File: `provider_version.tf`
* No resources — only provider blocks

---

### Terraform Registry Example

When you click **“Use Provider”** in Terraform Registry:

```hcl
version = "3.27.0"
```

✅ This pins an **exact version**

---

## Using `~> 3.0` (Flexible but Controlled)

```hcl
version = "~> 3.0"
```

When running:

```bash
terraform init
```

Terraform:

* Downloads latest `3.x` version
* Example: `3.27.0`

⚠️ Later:

* `3.30.0` may be downloaded automatically
* Potentially breaking changes

---

## Dependency Lock File: `.terraform.lock.hcl`

After `terraform init`, Terraform creates:

```
.terraform.lock.hcl
```

This file:

* Locks **exact provider versions**
* Records checksums
* Prevents silent upgrades

---

### Example Lock Entry

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version     = "3.27.0"
  constraints = "~> 3.0"
}
```

✅ Terraform will **reuse this version** even if newer versions exist.

---

## What Happens If Constraints Change?

### Scenario

* Lock file contains `3.27.0`
* You change config to `~> 2.0`

Terraform result:
❌ **Error**

```
Locked provider version does not match constraints
```

✅ Lock file protects you from accidental downgrades/upgrades.

---

## Changing Provider Versions Properly

### Option 1: Delete Lock File (Not Recommended in Production)

```bash
rm .terraform.lock.hcl
terraform init
```

---

### Option 2: Use Upgrade Flag (Recommended)

```bash
terraform init -upgrade
```

Terraform:

* Re-evaluates constraints
* Installs matching newer versions
* Updates lock file safely

---

## Testing Different Version Constraints (Examples)

### Example 1

```hcl
version = "<= 2.60"
```

✅ Downloads `2.60.0`

---

### Example 2

```hcl
version = ">= 2.10, <= 2.30"
```

✅ Downloads `2.30.0`

---

## Should You Upgrade Provider Versions?

### Short Answer

👉 **Only when necessary**

### When You Must Upgrade

* New cloud service released
* New resource type needed
* Bug fix required

### When You Should Be Careful

* Existing infrastructure is stable
* Production environments
* No testing pipeline

⚠️ Many organizations break environments by blindly upgrading providers.

---

## Best Practices for Provider Versioning

✅ Always define version constraints
✅ Use `~>` instead of exact versions (most cases)
✅ Commit `.terraform.lock.hcl`
✅ Test upgrades in lower environments
✅ Use `terraform init -upgrade` intentionally
✅ Never auto-upgrade in production

---

## Key Takeaways

* Providers are versioned **independently** from Terraform
* Unpinned providers = risky
* Version constraints prevent breaking changes
* Lock file enforces consistency
* Upgrades should be deliberate and tested

---

## Final Summary

Terraform provider versioning is **not optional in production**.

Treat provider upgrades like:

* OS upgrades
* Database upgrades
* Application version changes

Controlled, tested, and intentional.


