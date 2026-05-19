---
title: "Terraform Provisioners — Interview Q&A"
description: "1. What is a provisioner in Terraform?   Answer: Provisioners allow Terraform to execute..."
published: 2026-03-18
source: "https://dev.to/jumptotech/terraform-provisioners-interview-qa-1p0l"
tags: []
---

# Terraform Provisioners — Interview Q&A





## 1. What is a provisioner in Terraform?

**Answer:**
Provisioners allow Terraform to execute commands locally or on remote resources after infrastructure is created.

---

## 2. What problem do provisioners solve?

**Answer:**
Terraform creates infrastructure but does not configure it. Provisioners handle post-creation tasks like installing software and configuring servers.

---

## 3. What are the types of provisioners?

**Answer:**

* `local-exec` → runs on local machine
* `remote-exec` → runs on remote server via SSH
* `file` → copies files to remote server

---

## 4. Difference between local-exec and remote-exec?

**Answer:**
local-exec runs on the machine where Terraform executes, while remote-exec runs inside the created resource using SSH.

---

## 5. Does local-exec require SSH?

**Answer:**
No. It runs locally and does not connect to the remote server.

---

## 6. What is required for remote-exec?

**Answer:**

* SSH access
* Username
* Private key
* Public IP or hostname

---

## 7. What is the connection block?

**Answer:**
It defines how Terraform connects to a remote resource, including SSH details like user, key, and host.

---

## 8. Why do we use `self.public_ip`?

**Answer:**
`self` refers to the current resource, and `public_ip` is its attribute, so it dynamically uses the instance IP.

---

## 9. When do provisioners run?

**Answer:**
After resource creation by default (creation-time).

---

## 10. What is a destroy provisioner?

**Answer:**
A provisioner with `when = destroy` that runs before the resource is deleted.

---

## 11. Do provisioners run on every apply?

**Answer:**
No. They run only during resource creation unless the resource is recreated.

---

## 12. What happens if a provisioner fails?

**Answer:**
Terraform apply fails and the resource is marked as tainted.

---

## 13. What does “tainted” mean?

**Answer:**
Terraform marks the resource as unsafe and plans to destroy and recreate it on the next apply.

---

## 14. How to avoid failure stopping Terraform?

**Answer:**
Use:

```hcl
on_failure = continue
```

---

## 15. Where must provisioners be defined?

**Answer:**
Inside a resource block only.

---

## 16. Can you use multiple provisioners in one resource?

**Answer:**
Yes, and they execute in order (top to bottom).

---

## 17. Why are provisioners not recommended in production?

**Answer:**
They are not idempotent, hard to debug, and mix infrastructure with configuration.

---

## 18. What are better alternatives to provisioners?

**Answer:**

* `user_data` / cloud-init
* Ansible
* Packer
* Configuration management tools

---

## 19. What is `file()` function used for?

**Answer:**
To read a file from local system, such as a private key.

---

## 20. Why did we use `chmod 400`?

**Answer:**
SSH requires strict permissions; otherwise connection is refused.

---

## 21. Why must `key_name` match AWS?

**Answer:**
Because EC2 must be created with the same key pair used for SSH access.

---

## 22. What happens if SSH fails?

**Answer:**
remote-exec fails and Terraform apply fails.

---

## 23. Where does local-exec run in CI/CD?

**Answer:**
On the CI runner (e.g., Jenkins, GitHub Actions).

---

## 24. Can provisioners be used with resources other than EC2?

**Answer:**
Yes, any resource supports provisioners.

---

## 25. Why use dynamic AMI instead of hardcoding?

**Answer:**
To ensure the latest AMI is used and make the code reusable across regions.

---

## 26. What is the flow of Terraform with provisioners?

**Answer:**
Create resource → connect (SSH if remote) → execute provisioner → complete.

---

## 27. Can provisioners install applications?

**Answer:**
Yes, remote-exec can install and configure software on the instance.

---

## 28. What is the main risk of provisioners?

**Answer:**
They can leave infrastructure in a partially configured or inconsistent state.

---

## 29. How would you test if remote-exec will work?

**Answer:**
Manually SSH into the instance using the same key and user.

---

## 30. One-line summary (INTERVIEW GOLD)

**Answer:**
Provisioners allow Terraform to configure infrastructure after creation, but they should be avoided in production in favor of tools like user_data or configuration management systems.

---

# Bonus Scenario Question (VERY IMPORTANT)

## Q: You deployed EC2 but nginx is not working. What do you check?

**Answer:**

* SSH connectivity
* Security group (port 80 open)
* Provisioner logs
* nginx installation status
* systemctl status nginx


