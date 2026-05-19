---
title: "TERRAFORM INTERVIEW QUESTIONS (WITH ANSWERS)"
description: "🚨 API THROTTLING &amp; SCALE            1. What is API throttling in..."
published: 2026-03-17
source: "https://dev.to/jumptotech/terraform-interview-questions-with-answers-4db3"
tags: []
---

# TERRAFORM INTERVIEW QUESTIONS (WITH ANSWERS)





## 🚨 API THROTTLING & SCALE

### 1. What is API throttling in Terraform?

**Answer:**
API throttling happens when Terraform makes too many API calls (during `plan` or `apply`) and the cloud provider (AWS) limits or blocks requests.

---

### 2. Why does Terraform cause API throttling?

**Answer:**
Because Terraform performs a **state refresh**, calling APIs for every resource to check current state.

---

### 3. How do you reduce API calls in Terraform?

**Answer:**

* Split projects (modular structure)
* Use `-target`
* Use `-refresh=false` (carefully)

---

### 4. When should you NOT use `-refresh=false`?

**Answer:**

* When state drift is possible
* After manual console changes
* In non-production environments

---

### 5. What is the best practice for large Terraform projects?

**Answer:**
Split into smaller modules like:

* VPC
* IAM
* EC2
  This reduces API load and improves performance.

---

## 🎯 TARGETING & EXECUTION

### 6. What does `-target` do in Terraform?

**Answer:**
It applies changes only to a specific resource instead of the whole infrastructure.

---

### 7. When is `-target` useful?

**Answer:**

* Debugging
* Partial deployment
* Reducing API calls

---

## 📦 ZIPMAP FUNCTION

### 8. What does `zipmap()` do?

**Answer:**
Creates a map by combining two lists (keys + values).

---

### 9. Why is `zipmap()` useful?

**Answer:**
It helps map related data like:

* usernames → ARNs
  Makes outputs easier to read and use.

---

### 10. What happens if lists in `zipmap()` are different lengths?

**Answer:**
Terraform throws an error.

---

## 🧱 META-ARGUMENTS

### 11. What are Terraform meta-arguments?

**Answer:**
They change how Terraform behaves, not what it creates.

Examples:

* `count`
* `for_each`
* `depends_on`
* `lifecycle`

---

## 🔁 LIFECYCLE

### 12. What does `create_before_destroy` do?

**Answer:**
Creates new resource first, then deletes old → avoids downtime.

---

### 13. What does `prevent_destroy` do?

**Answer:**
Prevents Terraform from deleting a resource.

---

### 14. What does `ignore_changes` do?

**Answer:**
Ignores changes made outside Terraform (e.g., manual console changes).

---

### 15. What happens if you use `ignore_changes = [all]`?

**Answer:**
Terraform will never update the resource.

---

## 🔗 DEPENDENCIES

### 16. What is implicit dependency?

**Answer:**
Terraform automatically detects dependency when one resource references another.

Example:

```hcl
vpc_security_group_ids = [aws_security_group.web.id]
```

---

### 17. What is explicit dependency?

**Answer:**
Defined manually using `depends_on`.

---

### 18. When do you use `depends_on`?

**Answer:**
When Terraform cannot automatically detect dependency.

---

## 🔢 COUNT vs FOR_EACH

### 19. What is `count`?

**Answer:**
Creates multiple identical resources using an index.

---

### 20. What is the problem with `count`?

**Answer:**
Changing order can recreate resources → risky in production.

---

### 21. What is `for_each`?

**Answer:**
Creates resources using unique keys (map/set).

---

### 22. Why is `for_each` better than `count`?

**Answer:**
Stable resource identity → avoids unnecessary recreation.

---

## 📊 DATA TYPES

### 23. Difference between list and set?

**Answer:**

* List → ordered, allows duplicates
* Set → unordered, no duplicates

---

### 24. What is a map in Terraform?

**Answer:**
Key-value pair structure with same value type.

---

### 25. What is an object?

**Answer:**
Structured data with multiple attributes of different types.

---

## 💬 COMMENTS

### 26. What comment styles are supported in Terraform?

**Answer:**

* `#`
* `//`
* `/* */`

---

### 27. Which comment style is recommended?

**Answer:**
`#` (most commonly used)

---

## ⚙️ TERRAFORM BEHAVIOR

### 28. What happens during `terraform plan`?

**Answer:**
Terraform:

* Refreshes state (API calls)
* Compares config vs state
* Shows execution plan

---

### 29. What happens if you manually change AWS resource?

**Answer:**
Terraform detects drift and tries to revert it (unless ignored).

---

### 30. What is state drift?

**Answer:**
Difference between Terraform state and real infrastructure.

---

## 🧠 SCENARIO QUESTIONS (IMPORTANT)

---

### 31. Scenario:

Terraform is slow and failing with rate limits. What do you do?

**Answer:**

* Split project into modules
* Use `-target`
* Avoid full refresh
* Optimize resources

---

### 32. Scenario:

Someone added tags manually in AWS but Terraform removes them.

**Answer:**
Use:

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

---

### 33. Scenario:

You need zero downtime deployment.

**Answer:**
Use:

```hcl
create_before_destroy = true
```

---

### 34. Scenario:

You must ensure IAM role is created before EC2.

**Answer:**
Use:

```hcl
depends_on = [aws_iam_role.role]
```

---

### 35. Scenario:

You need stable resource creation with unique names.

**Answer:**
Use `for_each`, not `count`.









### 1. What problem do Terraform provisioners solve?

**Answer:**
Terraform creates infrastructure, but provisioners configure it by running scripts or commands after creation.

---

### 2. What is a provisioner in Terraform?

**Answer:**
A provisioner allows Terraform to execute commands locally or remotely during resource creation or destruction.

---

### 3. What are the main types of provisioners?

**Answer:**

* `local-exec`
* `remote-exec`
* `file`

---

### 4. Where must provisioners be defined?

**Answer:**
Inside a resource block only.

---

## ⚙️ EXECUTION FLOW

### 5. Explain how provisioners work step-by-step.

**Answer:**

1. Terraform creates resource
2. Terraform connects (if remote)
3. Executes commands
4. Waits until completion

---

### 6. When do provisioners run?

**Answer:**
After resource creation (or during destroy if configured).

---

## 🖥️ LOCAL-EXEC

### 7. What is `local-exec`?

**Answer:**
Runs commands on the machine where Terraform is executed.

---

### 8. Does `local-exec` require SSH?

**Answer:**
No.

---

### 9. Give a real use case of `local-exec`.

**Answer:**
Saving EC2 IP to a file:

```hcl
command = "echo ${self.public_ip} > ip.txt"
```

---

### 10. Can `local-exec` configure EC2 directly?

**Answer:**
No, it only runs locally.

---

## 🌐 REMOTE-EXEC

### 11. What is `remote-exec`?

**Answer:**
Runs commands inside a remote resource (like EC2) using SSH.

---

### 12. What is required for `remote-exec` to work?

**Answer:**

* SSH access
* Username
* Private key
* Host (IP/DNS)

---

### 13. What is the purpose of the `connection` block?

**Answer:**
Defines how Terraform connects to the remote server.

---

### 14. What happens if the connection fails?

**Answer:**
Provisioning fails and Terraform apply fails.

---

### 15. Why do we use `sudo` in remote-exec?

**Answer:**
Because default users (like `ec2-user`) are not root.

---

## 📂 FILE PROVISIONER

### 16. What does the file provisioner do?

**Answer:**
Copies files from local machine to remote server.

---

## 🔍 PRACTICAL QUESTIONS

---

### 17. Scenario:

EC2 is created but nginx is not installed. Why?

**Answer:**
Provisioner failed due to:

* SSH issue
* Wrong key
* Missing sudo
* Security group blocking port 22

---

### 18. Scenario:

Terraform apply hangs during provisioning.

**Answer:**
Likely waiting for SSH → check:

* Security group (port 22)
* Key permissions
* Instance readiness

---

### 19. Scenario:

You cannot SSH manually, what does it mean?

**Answer:**
Terraform remote-exec will also fail.

---

### 20. Scenario:

Wrong private key used in Terraform.

**Answer:**
SSH connection fails → provisioning fails.

---

## ⚠️ BEST PRACTICES

---

### 21. Why are provisioners discouraged?

**Answer:**

* Not idempotent
* Hard to debug
* Can break apply
* Mix infra + config

---

### 22. What are better alternatives to provisioners?

**Answer:**

* `user_data`
* Ansible
* Cloud-init
* Packer

---

### 23. When is it acceptable to use provisioners?

**Answer:**

* Learning
* Quick demos
* Bootstrap tasks
* Legacy systems

---

## 🧩 SYNTAX & COMMON MISTAKES

---

### 24. What is wrong with this?

```hcl
private_key = "terraform-key.pem"
```

**Answer:**
Wrong — must use:

```hcl
private_key = file("terraform-key.pem")
```

---

### 25. Why must key permissions be changed (chmod 400)?

**Answer:**
SSH requires strict permissions or connection fails.

---

### 26. What is `self.public_ip`?

**Answer:**
Refers to attribute of the current resource.

---

### 27. Difference between `self.public_ip` and `aws_instance.web.public_ip`?

**Answer:**

* `self` → inside same resource
* full reference → outside resource

---

## 🔄 COMBINED USAGE

---

### 28. Why use both local-exec and remote-exec together?

**Answer:**

* remote-exec → configure server
* local-exec → save outputs locally

---

## 🎯 ADVANCED / SENIOR QUESTIONS

---

### 29. Why are provisioners not idempotent?

**Answer:**
Because Terraform cannot track or re-run commands safely like infrastructure changes.

---

### 30. What happens if a provisioner fails?

**Answer:**
Terraform marks resource as failed and may stop execution.

---

### 31. How would you replace provisioners in production?

**Answer:**

* Use `user_data` for bootstrap
* Use Ansible for config
* Use Packer for images

---

### 32. What is the biggest risk of using provisioners?

**Answer:**
Unpredictable behavior and broken deployments.

---

## 🧠 ONE-LINE INTERVIEW ANSWERS (IMPORTANT)

---

### local-exec vs remote-exec

**Answer:**
local-exec runs commands on the machine where Terraform executes, while remote-exec runs commands inside the created server using SSH.

---

### Provisioners summary

**Answer:**
Provisioners allow Terraform to configure infrastructure after creation, but they should be avoided in production due to reliability and maintainability issues.

---



👉 “Do you use provisioners in production?”

**Best answer:**

> “I prefer not to. I use user_data or configuration tools like Ansible because provisioners are not idempotent and can cause unstable deployments.”






If they ask **ANY Terraform question**, structure your answer like:

👉 Behavior
👉 Problem
👉 Solution
👉 Example


