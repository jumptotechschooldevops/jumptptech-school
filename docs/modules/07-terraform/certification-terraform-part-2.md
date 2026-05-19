---
title: "certification Terraform part #2"
description: "🔐 Firewall Basics &amp; AWS Security Groups            1. What is a Port? (Very Important..."
published: 2025-12-09
source: "https://dev.to/jumptotech/certification-terraform-part-2-4p0b"
tags: []
---

# certification Terraform part #2


# 🔐 Firewall Basics & AWS Security Groups 

## 1. What is a Port? (Very Important Foundation)

### Simple definition

A **port** is like a **door** on a server that allows a specific application to communicate.

* Server = House
* IP address = House address
* Port = Door number
* Application = Person inside the house

Each application listens on a **specific port**.

### Common ports

| Service | Port | Purpose         |
| ------- | ---- | --------------- |
| SSH     | 22   | Login to server |
| HTTP    | 80   | Website         |
| HTTPS   | 443  | Secure website  |
| FTP     | 21   | File transfer   |

---

## 2. Why Ports Exist (Real Example)

Suppose a server has:

* **SSH** → Port `22`
* **NGINX (Website)** → Port `80`
* **FTP** → Port `21`

All services are running on **one IP address** (example: `1.2.3.4`), but ports tell the OS **which application should receive the traffic**.

### Example:

```
http://1.2.3.4:80  → Website
ssh 1.2.3.4        → SSH (port 22 by default)
```

If ports didn’t exist, the server wouldn’t know **which application** should answer.

---

## 3. Checking Open Ports on a Server



```bash
netstat -ntlp
```

This shows:

* Which ports are open
* Which application is using the port

Example output meaning:

* Port `80` → NGINX
* Port `22` → SSH
* Port `21` → FTP (vsftpd)

👉 Installing software usually **automatically binds it to a port** using its config file.

---

## 4. What is a Firewall?

### High-level definition

A **firewall** is a **security system** that controls:

* ✅ Who can connect **to** your server (inbound)
* ✅ Where your server can connect **to** (outbound)

It works using **rules**.

---

## 5. Why Firewalls Are Needed

Your server may have **multiple open ports**, but you **should not expose all of them**.

Example:

* ✅ Allow users to access the website (port 80)
* ❌ Block users from accessing SSH (port 22)

Without firewall:

* Anyone could try to log in via SSH
* Huge security risk

---

## 6. How Firewall Logic Works (Mentally Picture This)

```
User → Firewall → Server → Application
```

Firewall checks rules **before** traffic reaches the server.

### Sample rules:

* ❌ Deny port 22
* ✅ Allow port 80

Result:

* Website works
* SSH blocked from the internet

---

## 7. Firewall in AWS = Security Group

### Very important AWS concept

**AWS Security Group = Firewall**

Official definition:

> A security group acts as a virtual firewall for your EC2 instance, controlling inbound and outbound traffic.

---

## 8. AWS Security Group – Inbound Rules

Inbound rules control:
👉 **Who can connect to your EC2**

Example inbound rules:

| Port | Source       | Meaning                   |
| ---- | ------------ | ------------------------- |
| 80   | 0.0.0.0/0    | Anyone can access website |
| 22   | Your IP only | Only you can SSH          |

### `0.0.0.0/0` means:

✅ All IP addresses (entire internet)

---

## 9. What Happens If You Remove All Inbound Rules?

* No traffic allowed
* Website stops loading
* SSH stops working

This is exactly what happened in the demo when:

* “Allow all traffic” rule was removed
* Website became inaccessible

---

## 10. Allowing Only the Website (Best Practice)

Correct setup for public website:
✅ Inbound:

* Allow TCP `80` from `0.0.0.0/0`

❌ Do NOT allow SSH from everyone

Result:

* Website works
* Server login protected

---

## 11. Outbound Rules (Often Forgotten but Important)

Outbound rules control:
👉 **Where your server can connect**

Examples:

* Can EC2 access the internet?
* Can EC2 talk only to a database?
* Can EC2 download updates?

By default:
✅ AWS allows **all outbound traffic**

But security teams often **restrict outbound** traffic in production.

---

## 12. Firewalls Are the Same Everywhere (AWS, Azure, DigitalOcean)

Concept is **identical** across providers:

* AWS → Security Groups
* DigitalOcean → Firewall
* Azure → NSG (Network Security Group)

All use:

* Ports
* Allow/Deny rules
* Source & destination IPs

---

## 13. Key Takeaways (Very Important for Interviews)

✅ Ports identify applications
✅ Applications bind to ports
✅ Firewalls control traffic
✅ AWS firewall = Security Group
✅ Inbound = who can connect to me
✅ Outbound = where I can connect
✅ Never open SSH (22) to the world

---

## 14. One-Line Interview Answer

**Q:** What is a firewall in AWS?
**A:**

> A firewall in AWS is implemented using Security Groups, which control inbound and outbound traffic at the EC2 instance level based on port, protocol, and source/destination rules.











# AWS Security Groups – Console + Terraform 

## Part 1: Creating a Security Group from AWS Console

### 1. Security Group = Firewall

In AWS:

* **Firewall is called a Security Group**
* Every EC2 **must** have a security group attached

When launching an EC2 instance, AWS always asks:

* Key pair
* **Firewall (Security Group)**

---

### 2. Default Security Group (Auto-created)

If you don’t create one manually:

* AWS creates a **default security group**
* It contains **some default inbound & outbound rules**

But in real projects:

* You **always create your own security groups**

---

### 3. Creating a Security Group from Scratch (Console)

Steps:

1. Go to **EC2 → Network & Security → Security Groups**
2. Click **Create security group**
3. Example:

   * **Name:** `myfirst.sg`
   * **Description:** Firewall
   * **VPC:** Select your VPC

---

### 4. Inbound Rules (Who can connect TO your server)

Example rule:

* Type: SSH
* Port: 22
* Source: `0.0.0.0/0`

⚠️ **Important (Production Rule):**

> Never allow SSH (22) from `0.0.0.0/0` in production
> Allow only:

* Office IP
* VPN IP

---

### 5. Outbound Rules (Where server can connect TO)

Default outbound rule:

* **Allow All**
* Destination: `0.0.0.0/0`

This allows:

* OS updates
* API calls
* Internet access

---

### 6. Attaching Security Group to EC2

Steps:

1. EC2 → Instance → Actions → Security → Change security groups
2. Remove default SG
3. Attach `myfirst.sg`

✅ Now firewall rules apply to this EC2

---

### 7. Why Ping Didn’t Work (ICMP Explained)

* `ping` uses **ICMP protocol**
* ICMP is **not TCP**
* Security groups **block ICMP by default**


ICMP rule was added to:
❌ **Outbound**

Correct is:
✅ **Inbound**

---

### Correct ICMP Rule

* Type: ICMP – Echo Request
* Source: `0.0.0.0/0`

Now `ping <EC2-IP>` works.

---

## Part 2: Creating Security Group Using Terraform

---

## 8. Architecture to Implement (Terraform)

We want:

* Security Group name: `terraform-firewall`
* Inbound:

  * Allow **port 80** from `0.0.0.0/0`
* Outbound:

  * Allow **all traffic**

---

## 9. Terraform Resource Types (Very Important)

There are **two separate things**:

### 1️⃣ Security Group (container)

```hcl
resource "aws_security_group" "firewall" {
  name = "terraform-firewall"
}
```

This creates:
✅ Security group
❌ No rules yet

---

### 2️⃣ Security Group Rules (real firewall logic)

Terraform uses **separate resources**:

| Purpose  | Terraform Resource                    |
| -------- | ------------------------------------- |
| Inbound  | `aws_vpc_security_group_ingress_rule` |
| Outbound | `aws_vpc_security_group_egress_rule`  |

Ingress = inbound
Egress = outbound

---

## 10. Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

## 11. Full Terraform Code (Clean Version)

### 🔹 firewall.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "firewall" {
  name        = "terraform-firewall"
  description = "Managed from Terraform"
}
```

---

### 🔹 Inbound Rule – Allow HTTP

```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.firewall.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP from Internet"
}
```

---

### 🔹 Outbound Rule – Allow All

```hcl
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.firewall.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}
```

---

## 12. What Does `ip_protocol = "-1"` Mean?

`-1` means:
✅ **ALL protocols**
✅ **ALL ports**

Equivalent to:

* TCP
* UDP
* ICMP
* Any port

Used mainly in outbound rules.

---

## 13. Terraform Commands

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Expected result:

* Security group created
* Inbound rule: port 80
* Outbound rule: allow all

---

## 14. from_port & to_port (Port Range)

Single port:

```hcl
from_port = 80
to_port   = 80
```

Port range:

```hcl
from_port = 80
to_port   = 100
```

✅ Used when:

* Application uses multiple ports
* Load balancers
* Custom apps

---

## 15. security_group_id (Critical Concept)

```hcl
security_group_id = aws_security_group.firewall.id
```

This means:

> Attach this rule to that security group

Rules **do not live alone**
They always belong to **one security group**

---

## 16. Reassigning Rules to Another Security Group

If you change:

```hcl
security_group_id = "sg-DEFAULT_ID"
```

Terraform will:

* ❌ Remove rule from old SG
* ✅ Add rule to new SG

Terraform output:

```
1 to add, 1 to destroy
```

✅ This is expected behavior

---

## 17. Final Mental Model (Very Important)

```
Security Group
 ├── Ingress rules (Inbound)
 └── Egress rules (Outbound)
```

Terraform treats them as:

* **Separate resources**
* Connected using `security_group_id`

---

## 18. Interview-Ready Summary

**Q: How do you create AWS security groups using Terraform?**
**A:**

> First, create an `aws_security_group` resource. Then manage inbound and outbound rules separately using `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`, linking them using the security group ID.







# How to Deal with Terraform Documentation & Code Updates



When you work with Terraform long enough, you will notice:

* ✅ Terraform **documentation changes**
* ✅ Example code changes
* ✅ New “recommended” approaches appear
* ✅ Old working code no longer matches docs

This **does NOT mean** old Terraform code is broken.

---

## 2. Security Group Example: Old vs New Approach

### ✅ New (Recommended) Approach

Terraform **separates responsibilities**:

1. **Security group**
2. **Security group rules**

```hcl
aws_security_group
aws_vpc_security_group_ingress_rule
aws_vpc_security_group_egress_rule
```

This is:

* Cleaner
* More explicit
* Easier to manage at scale
* Current best practice

---

### ✅ Old (Legacy) Approach

Everything defined in **one resource**:

```hcl
resource "aws_security_group" "example" {
  ingress { ... }
  egress  { ... }
}
```

Important:

* ✅ Still works
* ✅ Supported by current providers
* ❌ No longer emphasized in latest docs

---

## 3. Key Learning: Docs ≠ Only Valid Way

**Very important mindset shift:**

> Terraform documentation shows the *recommended* way,
> not the *only working* way.

* HashiCorp **adds new patterns**
* They rarely **remove working ones**
* Backward compatibility is preserved

This is exactly what you saw:

* Provider version 5.38 still accepts **old security group syntax**
* `terraform apply` works without errors

---

## 4. Why This Matters in Real Jobs

In real companies:

* You will read **Terraform code written 2–5 years ago**
* It may **not match current documentation**
* The engineer who wrote it may be gone
* The code still works perfectly

👉 Your job is **to understand it**, not blindly rewrite it.

---

## 5. Terraform Versioning Strategy (Enterprise Reality)

### Enterprises usually:

* Pin Terraform versions
* Pin provider versions
* Avoid frequent upgrades

Why?

* Stability
* Predictability
* Reduced risk



> If Windows 10 works perfectly, why upgrade to Windows 11?

Same logic applies to Terraform.

---

## 6. How to Handle Documentation Changes Correctly

### ✅ Step 1: Identify Provider Version

Look at:

```hcl
required_providers
```

or `.terraform.lock.hcl`

---

### ✅ Step 2: Switch Documentation Version

Terraform docs allow:

* Version selector (top-right)
* Older provider versions (e.g., 5.31.0)

Result:

* Examples **match legacy code**
* Less confusion
* Faster understanding

---

### ✅ Step 3: Compare Approaches (Don’t Panic)

If you see old code:

* ✅ Check older docs
* ✅ Validate with `terraform plan`
* ✅ Don’t rewrite unless required

---

## 7. HashiCorp Did This on Purpose (Good Design)

Why Terraform docs are good:

* Provider version selector
* Clear version history
* Stable APIs
* Gradual improvements, not breaking changes

Many tools do **not** offer this level of backward compatibility.

---

## 8. When Should You Actually Upgrade?

Upgrade Terraform / providers only when:

* New AWS feature required
* Security fix needed
* Bug fix required
* Organization-wide migration planned

Never upgrade just because:
❌ Docs changed
❌ New syntax looks cleaner

---

## 9. Course & Learning Reality (Important for Students)



## 10. Interview-Ready Summary (Very Important)

**Q: How do you handle Terraform documentation changes?**

**Answer:**

> I check the provider version used in the codebase and refer to the corresponding documentation version. Terraform maintains backward compatibility, so older syntax usually continues to work even when newer recommended approaches are introduced.

---



# Part 1: Elastic IP (EIP) in AWS Using Terraform

## 1. What is an Elastic IP?

At a high level:

* **Elastic IP (EIP)** is a **static public IPv4 address** in AWS.
* It does **not change** even if:

  * EC2 stops/starts
  * EC2 gets recreated (if re-associated)

### Why it exists

Normal EC2 public IPs:

* Change on stop/start
* Are temporary

Elastic IP:

* Fixed
* Can be reassigned to another instance
* Useful for:

  * Bastion hosts
  * Production endpoints
  * NAT instances
  * Legacy systems needing static IPs

---

## 2. Elastic IP Lifecycle (Very Important)

1. Create Elastic IP
2. (Optional) Associate it with EC2
3. Use the same public IP permanently

⚠️ **Important cost note**
AWS **charges** if:

* EIP is allocated but **not attached** to a running resource

Always delete unused EIPs.

---

## 3. Creating Elastic IP from AWS Console (Concept)

Steps:

* EC2 → Elastic IPs
* Allocate Elastic IP
* AWS immediately assigns a public IP
* You may associate it with an EC2 instance

No complexity here — Terraform works the same way.

---

## 4. Creating Elastic IP Using Terraform

### Terraform Resource

```hcl
resource "aws_eip" "example" {
  domain = "vpc"
}
```

That’s it — **Elastic IP created**.

---

## 5. Terraform Code (Clean & Minimal)

### eip.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_eip" "example" {
  domain = "vpc"
}
```

Key points:

* `instance` argument is **optional**
* Without `instance`, EIP is just allocated
* Can be associated later

---

## 6. Terraform Commands

```bash
terraform plan
terraform apply -auto-approve
```

Result:

* Elastic IP created
* Visible in AWS console
* Stored in Terraform state

---

## 7. Terraform State & Elastic IP

In `terraform.tfstate`, you’ll see:

```json
"attributes": {
  "public_ip": "100.xxx.xxx.xxx",
  "id": "eipalloc-xxxx"
}
```

✅ You can get:

* Elastic IP address
* Allocation ID
  without visiting AWS Console

---

## 8. Cleanup (Very Important)

```bash
terraform destroy -auto-approve
```

Always:

* Destroy test EIPs
* Verify from AWS console

---

# Part 2: Terraform Attributes (Critical Concept)

## 9. What Are Attributes in Terraform?

**Definition (simple):**

> Attributes are values generated **after a resource is created**, and they are stored in the Terraform state file.

They represent:

* Resource IDs
* IP addresses
* DNS names
* ARNs
* Status information

---

## 10. Why Attributes Matter (Real Use Case)

Attributes allow:

* One resource to **depend on another**
* Passing values between resources
* Dynamic infrastructure wiring

Example:

* Use EC2 public IP in:

  * Outputs
  * Load balancers
  * Security groups
  * DNS records

---

## 11. Attributes vs Arguments (Must Know Difference)

| Type       | Meaning                       |
| ---------- | ----------------------------- |
| Arguments  | What you **give** Terraform   |
| Attributes | What Terraform **gives back** |

Example:

```hcl
ami = "ami-123"
```

✅ Argument (input)

```hcl
public_ip
```

✅ Attribute (output)

---

## 12. Where to Find Attributes?

In Terraform documentation:

* Scroll to **Attribute Reference**
* Listed per resource

Example:

* `aws_instance`
* `aws_eip`

---

## 13. Example: EC2 Attributes

After EC2 creation, state file contains:

| Attribute   | Meaning      |
| ----------- | ------------ |
| id          | Instance ID  |
| public_ip   | Public IPv4  |
| private_ip  | Internal IP  |
| private_dns | Internal DNS |
| arn         | AWS ARN      |

These are **auto-populated**.

---

## 14. Reading Attributes from State File

Example from `terraform.tfstate`:

```json
"public_ip": "3.xxx.xxx.xxx"
```

✅ Matches AWS console
✅ Terraform is the source of truth

---

## 15. Why Attributes Are Used Everywhere

Attributes are used for:

* Outputs
* Inter-resource connections
* Dynamic references

Example:

```hcl
aws_instance.web.public_ip
```

You’ll use this **constantly** in real projects.

---

## 16. Very Important Mental Model

```
Terraform Code  →  Resource Created  →  Attributes Generated  →  Stored in tfstate
```

Terraform state is:

* Not just tracking existence
* Also storing **real infrastructure values**

---

## 17. Interview-Ready Summary

### Q: What are attributes in Terraform?

**Answer:**

> Attributes are values automatically generated after a resource is created, such as IDs, IP addresses, and ARNs. They are stored in the Terraform state file and used to connect resources together.

---

## 18. Key Takeaways (Remember This)

✅ Elastic IP = static public IPv4
✅ Terraform creates EIP with `aws_eip`
✅ Unused EIPs cost money
✅ Attributes are resource outputs
✅ Attributes live in state file
✅ Attributes are used for integration







# Cross-Resource Attribute Reference in Terraform

## 1. Why This Concept Is Critical

In real Terraform projects:

* You **never** create isolated resources
* Resources **depend on values from other resources**
* Those values **do not exist before apply**

Example reality:

* EIP is created → public IP generated
* Security group must whitelist **that exact IP**
* You cannot hardcode it

👉 This problem is solved using **cross-resource attribute references**

---

## 2. The Problem We Are Solving

We want this workflow:

1. Terraform creates an **Elastic IP**
2. AWS assigns a **public IP**
3. Terraform automatically:

   * Reads that public IP
   * Adds it to a **Security Group rule**
   * Allows port **443** only from that IP

✅ No manual copying
✅ No hardcoding
✅ Fully automated

---

## 3. Key Terraform Feature Used

**Cross-Resource Attribute Reference**

General syntax:

```
resource_type.resource_name.attribute
```

Example:

```
aws_eip.lb.public_ip
```

Meaning:

* `aws_eip` → resource type
* `lb` → local resource name
* `public_ip` → attribute generated after creation

---

## 4. Resources Involved

We need **three resources**:

1. Elastic IP
2. Security Group
3. Security Group Ingress Rule

---

## 5. Step-by-Step Practical Code

### ✅ Provider

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### ✅ Elastic IP Resource

```hcl
resource "aws_eip" "lb" {
  domain = "vpc"
}
```

After creation, Terraform knows:

```hcl
aws_eip.lb.public_ip
```

---

### ✅ Security Group

```hcl
resource "aws_security_group" "attribute_sg" {
  name        = "attribute-sg"
  description = "Security group using cross-resource attributes"
}
```

---

### ✅ Security Group Ingress Rule (Important Part)

```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.attribute_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  cidr_ipv4 = "${aws_eip.lb.public_ip}/32"
}
```

✅ This is the **core learning**

---

## 6. Why `/32` Is Required (Very Important)

AWS security groups expect:

* **CIDR notation**
* NOT just an IP address

Examples:

* ✅ Single IP → `35.154.233.58/32`
* ✅ Network → `10.0.0.0/24`
* ❌ `35.154.233.58` → INVALID

Even if the IP is correct, AWS **will reject it** without CIDR.

---

## 7. Why Simple Reference Failed Before

This ❌ does **NOT** work:

```hcl
cidr_ipv4 = aws_eip.lb.public_ip
```

Why?

* That produces **only an IP**
* AWS expects **CIDR**

---

## 8. String Interpolation (Solution)

```hcl
cidr_ipv4 = "${aws_eip.lb.public_ip}/32"
```

What Terraform does internally:

1. Creates Elastic IP
2. Gets `public_ip`
3. Appends `/32`
4. Passes final CIDR to AWS

✅ This is **string interpolation**

---

## 9. Why `security_group_id` Also Uses Attributes

```hcl
security_group_id = aws_security_group.attribute_sg.id
```

* Security group ID **does not exist before apply**
* Terraform:

  * Creates security group
  * Reads its `id` attribute
  * Injects it into rule resource

This creates an **implicit dependency**

---

## 10. Terraform Dependency Handling (Important)

Terraform creates resources in this order automatically:

1. Elastic IP
2. Security Group
3. Security Group Rule

Because:

* Rule depends on EIP `public_ip`
* Rule depends on SG `id`

No `depends_on` needed — Terraform is smart.

---

## 11. Why Terraform Apply Failed First Time

Earlier:

* EIP created ✅
* SG created ✅
* Rule failed ❌ (invalid CIDR)

Result:

* Partial infrastructure

Terraform behavior:

* This is **normal**
* Terraform is **idempotent**

---

## 12. Best Practice (Very Important)

✅ Infrastructure **should succeed in one apply**

Good workflow:

1. Destroy everything
2. Fix code
3. Apply again cleanly

```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

---

## 13. Where String Interpolation Is Required vs Not Required

| Case                                           | Interpolation Needed |
| ---------------------------------------------- | -------------------- |
| `security_group_id = aws_security_group.sg.id` | ❌ No                 |
| `cidr_ipv4 = aws_eip.lb.public_ip`             | ❌ No                 |
| `cidr_ipv4 = aws_eip.lb.public_ip/32`          | ❌ Invalid            |
| `cidr_ipv4 = "${aws_eip.lb.public_ip}/32"`     | ✅ Yes                |

Rule:

* If **combining values + static text**, use interpolation

---

## 14. Mental Model (Memorize This)

```
Resource A creates value → attribute
Resource B consumes attribute → reference
Terraform resolves dependency automatically
```

---

## 15. Interview-Ready Answer

**Q: What is cross-resource attribute reference in Terraform?**

**Answer:**

> Cross-resource attribute reference allows one Terraform resource to use attributes generated by another resource, such as IDs or IP addresses, enabling dynamic dependencies and automated infrastructure wiring.

---

## 16. Key Takeaways

✅ Attributes are outputs of resources
✅ References use `resource.type.name.attribute`
✅ Terraform computes dependencies automatically
✅ CIDR requires `/32` for single IPs
✅ String interpolation is used when modifying values









# ⭐ PART 1: Output Values in Terraform

## 1. What Are Output Values?

Simple definition:

> **Terraform output values allow you to print important information to your CLI after applying your infrastructure.**

Examples of things you may want as output:

* EC2 public IP
* RDS endpoint
* Load balancer DNS
* EKS cluster name
* VPC ID

Outputs allow you to:

* Not open AWS Console
* Quickly copy the value
* Pass values to other Terraform projects

---

## 2. Why Do We Need Outputs?

### Without outputs:

1. You run `terraform apply`
2. Terraform creates EC2 / EIP / LB
3. You must go to AWS Console → find IP or DNS manually
   (time-consuming, annoying)

### With outputs:

Terraform prints directly in CLI:

```
Outputs:

public_ip = "3.91.122.180"
```

You copy-paste instantly.

---

## 3. How to Create an Output?

### Example resource

```hcl
resource "aws_eip" "lb" {
  domain = "vpc"
}
```

### Output block

```hcl
output "public_ip" {
  value = aws_eip.lb.public_ip
}
```

### Result

After `terraform apply`:

```
public_ip = "100.24.55.33"
```

---

## 4. Customize Output Strings

You can combine strings:

```hcl
output "https_url" {
  value = "https://${aws_eip.lb.public_ip}:8080"
}
```

CLI will show:

```
https_url = "https://100.24.55.33:8080"
```

This is VERY useful for:

* Testing services
* Giving URLs to developers
* Automation scripts

---

## 5. Output All Attributes of a Resource

```hcl
output "everything_for_eip" {
  value = aws_eip.lb
}
```

CLI will show:

* public_ip
* private_ip
* arn
* id
* domain

Very good for debugging.

---

## 6. Why Outputs Matter for Large Organizations

Outputs allow **cross-project data exchange**.

Example:

### Project A:

Creates EIP + outputs:

```
public_ip = "100.24.55.33"
```

### Project B:

Reads Project A’s state file
→ Uses that IP automatically.

This is used heavily in:

* Multi-team Terraform setups
* Multi-module systems
* Shared infrastructure components

---

# ⭐ PART 2: Terraform Variables

## 1. Why Do We Need Variables?

Imagine you hardcode values inside 100 resources:

```
cidr_ipv4 = "34.87.112.9/32"
```

If the VPN IP changes tomorrow:

* You must update *100 places manually*
* You WILL make mistakes
* Your apply will break

Variables solve this forever.

---

## 2. What Are Variables?

Simple definition:

> Variables allow you to store important values in one place and reuse them anywhere in your Terraform code.

Example:

```hcl
variable "vpn_ip" {
  type = string
  default = "34.87.112.9/32"
}
```

Use it:

```hcl
cidr_ipv4 = var.vpn_ip
```

Now when VPN IP changes:

* Edit it **once**
* Everything updates automatically

---

## 3. Example Without Variables (Bad)

```hcl
cidr_ipv4 = "34.87.112.9/32"
cidr_ipv4 = "34.87.112.9/32"
cidr_ipv4 = "34.87.112.9/32"
...
(100 more)
```

This is how people break production.

---

## 4. Example With Variables (Correct)

### Define variables

```hcl
variable "vpn_ip" {
  default = "34.87.112.9/32"
}

variable "app_port" {
  default = 8080
}
```

### Use variables

```hcl
cidr_ipv4 = var.vpn_ip
from_port = var.app_port
to_port   = var.app_port
```

Now:

* 1 change = updated everywhere
* Zero manual edits
* Safer code
* Professional Terraform practice

---

## 5. Demo Behavior (Important)

If you change:

```hcl
app_port = 22
```

Terraform plan will show:

```
~ from_port: 8080 → 22
~ to_port:   8080 → 22
```

Terraform automatically picks new values.

---

## 6. Benefits of Variables (Remember This)

✔ Centralized control
✔ No repeated static values
✔ No manual mistakes
✔ Faster code editing
✔ Cleaner Terraform code
✔ Essential for large organizations

---

# ⭐ Final Summary (Interview Answer Style)

### **Q: What are Terraform output values?**

> Terraform outputs allow you to expose resource attributes (such as IPs or DNS) on the CLI and make them available to other Terraform configurations.

---

### **Q: What are Terraform variables?**

> Terraform variables let you define values in a central place instead of hardcoding them everywhere. This makes code reusable, cleaner, and safer—especially in large environments.










# 1. Terraform Variables – Practical Understanding

## Why Variables Exist (Real Problem)

Hard-coding repeated values causes problems:

* VPN IP appears in **many security group rules**
* Ports appear repeatedly
* Change = manual edits everywhere
* High chance of mistakes in production

✅ **Variables solve this** by centralizing values.

---

## Identifying What Should Be a Variable

Rule of thumb:

> Any value repeated more than once → make it a variable

Examples:

* VPN IP
* Ports (22, 21, 8080)
* AMI IDs
* Instance types
* Region-specific values

---

# 2. Creating Variables (Practical Example)

### Step 1: Main Terraform code (resources)

Example:

```hcl
cidr_ipv4 = var.vpn_ip
from_port = var.app_port
to_port   = var.app_port
```

No hardcoded values.

---

### Step 2: Define variables (recommended: `variables.tf`)

```hcl
variable "vpn_ip" {
  description = "VPN server IP address"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
}
```

✅ No values yet
✅ Just definitions

---

### Step 3: Provide values centrally

You now decide **where** the values live.

That’s where `.tfvars` comes in.

---

# 3. `.tfvars` – Variable Definition File (VERY IMPORTANT)

## Purpose of `.tfvars`

* Holds **values**, not variable definitions
* Keeps environment-specific configuration separate
* Makes code reusable and safe

---

### Standard Files (Best Practice)

```
main.tf
variables.tf
terraform.tfvars
```

Example `terraform.tfvars`:

```hcl
vpn_ip    = "10.10.10.10/32"
app_port = 8080
ssh_port = 22
ftp_port = 21
```

✅ Terraform **automatically loads** `terraform.tfvars`

---

## Multiple Environments (Real Production Use)

```
dev.tfvars
stage.tfvars
prod.tfvars
```

Example:

```hcl
# dev.tfvars
instance_type = "t3.micro"

# prod.tfvars
instance_type = "m5.large"
```

Use with:

```bash
terraform plan -var-file=prod.tfvars
```

---

# 4. Defaults vs `.tfvars` – Who Wins?

### Variable with default:

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

### If value exists in `.tfvars`:

✅ `.tfvars` **overrides default**

Terraform precedence rule:

> **Explicit values always override defaults**

---

# 5. Variable Naming Best Practices

✅ Use `variables.tf` for variable definitions
✅ Use `.tfvars` for values
✅ Add **descriptions**
✅ Avoid touching core resource files in production

Example:

```hcl
variable "vpn_ip" {
  description = "Corporate VPN IP allowed in security groups"
}
```

---

# 6. What Happens If No Value Is Provided?

If:

* Variable defined
* No default
* No `.tfvars`
* No CLI / env value

👉 Terraform **prompts** for input:

```
var.instance_type
Enter a value:
```

This works, but **not ideal for automation**.

---

# 7. Ways to Assign Variable Values (IMPORTANT)

Terraform supports **4 main methods**.

## 1️⃣ Default Value

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

✅ Lowest priority

---

## 2️⃣ `.tfvars` File (Most Common)

```hcl
instance_type = "m5.large"
```

✅ Recommended for environments

---

## 3️⃣ Command Line `-var`

```bash
terraform plan -var="instance_type=m5.large"
```

✅ Overrides defaults
✅ Useful for quick tests

---

## 4️⃣ Environment Variables (CI/CD Friendly)

Naming rule (case-insensitive):

```
TF_VAR_<variable_name>
```

Example:

```
TF_VAR_instance_type=m5.large
```

✅ Great for pipelines
✅ No files needed

---

# 8. Environment Variables – Windows

### Create variable

```
TF_VAR_instance_type = t2.large
```

⚠️ Important:

* You must **restart terminal**
* Existing terminals won’t see new variables

Verify:

```powershell
echo %TF_VAR_instance_type%
```

---

# 9. Environment Variables – Linux / Mac

### Set variable

```bash
export TF_VAR_instance_type=m5.large
```

Verify:

```bash
echo $TF_VAR_instance_type
```

Terraform:

```bash
terraform plan
```

✅ Terraform picks it automatically

---

# 10. Variable Assignment Precedence (MEMORIZE)

From **highest → lowest priority**:

1. CLI `-var`
2. Environment variables `TF_VAR_*`
3. `.tfvars` file
4. Default value
5. Prompt (if nothing provided)

---

# 11. Production Guidelines (Very Important)

✅ Never hardcode repeated values
✅ Keep resource files **unchanged across environments**
✅ Store values in `.tfvars`
✅ Use env vars in CI/CD
✅ Always add variable descriptions

This minimizes:

* Human errors
* Risky edits
* Broken infrastructure

---

# 12. Interview-Ready Summary

### Q: How can you assign values to Terraform variables?

**Answer:**

> Terraform variables can be assigned using default values, `.tfvars` files, command-line `-var` flags, environment variables prefixed with `TF_VAR_`, or interactive prompts if no value is provided.










# ✅ PART 1 — VARIABLE DEFINITION PRECEDENCE (MOST IMPORTANT)

Terraform allows setting variable values in MANY places:

* **Default**
* **terraform.tfvars**
* **environment variables**
* **auto.tfvars**
* **CLI -var**
* **Prompts**

If values DIFFER, which one wins?

## ⭐ FINAL PRECEDENCE ORDER (from lowest → highest)

| Priority    | Source                    | Example                         |
| ----------- | ------------------------- | ------------------------------- |
| 1️⃣ Lowest  | **Default**               | `default = "t2.micro"`          |
| 2️⃣         | **Environment variables** | `TF_VAR_instance_type=t2.small` |
| 3️⃣         | **terraform.tfvars**      | `instance_type="t2.large"`      |
| 4️⃣         | **terraform.tfvars.json** | Same as above but JSON          |
| 5️⃣         | **auto.tfvars**           | `dev.auto.tfvars`               |
| 6️⃣ Highest | **CLI -var or -var-file** | `-var "instance_type=m5.large"` |

### ⭐ The LAST one wins

Terraform processes sources in order.
If multiple locations provide values → **last one overrides earlier values**.

---

## 🔥 EXAMPLES TO MAKE IT EASY

### Example 1:

```
default = "t2.micro"
TF_VAR_instance_type = "t2.small"
terraform.tfvars → "t2.large"
```

**Result:** Terraform uses `"t2.large"` → tfvars overrides env + default.

---

### Example 2:

```
default = "t2.micro"
terraform.tfvars → "t2.large"
CLI → -var="instance_type=m5.large"
```

**Result:** `"m5.large"` (CLI always wins)

---

# 🔧 PRACTICAL DEMO LOGIC (how lecturer showed it)

1. Default = `"t2.micro"`
2. Add environment variable:

```
TF_VAR_instance_type = "t2.small"
```

Terraform plan → **takes t2.small**

3. Add terraform.tfvars:

```
instance_type = "t2.large"
```

Terraform plan → **takes t2.large**

4. Use CLI:

```
terraform plan -var "instance_type=m5.large"
```

Terraform plan → **takes m5.large**

✔ Perfect understanding.

---

# ✅ PART 2 — LIST DATA TYPE (VERY COMMON WITH AWS)

## ⭐ What a LIST is:

* A **sequence of values**
* Written inside **square brackets**
* Comma-separated

Example:

```hcl
["Mumbai", "Bangalore", "Delhi"]
```

Terraform understands this as a **list of strings**.

---

## Why list is needed?

Because some AWS arguments expect **multiple values**.

Example:
EC2 → `vpc_security_group_ids`

Documentation says:

```
(Required) list of security group IDs
```

Meaning Terraform MUST receive:

```hcl
vpc_security_group_ids = [
  "sg-001",
  "sg-002"
]
```

If you write incorrect format:

```hcl
vpc_security_group_ids = "sg-001"
```

Terraform throws:

```
Incorrect attribute value type
```

---

## ⭐ List can contain only ONE value too such as:

```hcl
vpc_security_group_ids = ["sg-001"]
```

You STILL must keep list brackets because **argument type is list**, even if list length = 1.

---

# ✅ PART 3 — LIST WITH TYPE CONSTRAINTS

You can restrict what type goes inside a list.

Example:

```hcl
variable "ports" {
  type = list(number)
}
```

✔ Accepts: `[22, 8080]`
❌ Rejects: `["ssh", "http"]`

If user enters incorrect type → Terraform errors:

```
Invalid value for input variable
Number required
```

Very useful for **validation**.

---

# ✅ PART 4 — Terraform BASIC DATA TYPES

Terraform supports:

### **1. string**

```hcl
"hello"
```

### **2. number**

```hcl
45
10.5
```

### **3. bool**

```hcl
true
false
```

### **4. list**

Sequence of values:

```hcl
["a", "b", "c"]
```

### **5. set**

Unique unordered values:

```hcl
set(string)
```

### **6. map**

Key-value pairs:

```hcl
{
  Name = "web"
  Team = "devops"
}
```

### **7. object**

Structured schema:

```hcl
object({
  name   = string
  memory = number
})
```

### **8. tuple**

List with fixed types:

```hcl
tuple([string, number, bool])
```

---

# ⭐ Practical AWS Examples for Each Data Type

### String

```hcl
instance_type = "t3.micro"
```

### Number

```hcl
volume_size = 20
```

### List

```hcl
availability_zones = ["us-east-1a", "us-east-1b"]
```

### Map

```hcl
tags = {
  Name = "web"
  Env  = "dev"
}
```

---

# ⭐ FINAL INTERVIEW SUMMARY

If the interviewer asks:

### **“Explain Terraform variable precedence.”**

Your answer:

> Terraform loads variables from several sources. If the same variable is defined in multiple places, Terraform uses the value from the source with the highest precedence. The order from lowest to highest is: default values, environment variables, terraform.tfvars, terraform.tfvars.json, auto.tfvars files, and finally CLI options using `-var` or `-var-file`. CLI always wins.

---

### **“What is a list in Terraform?”**

> A list is a Terraform data type used to store multiple values in order, inside square brackets. Some AWS arguments, like `vpc_security_group_ids`, require a list even when you have only one value. Example: `["sg-123"]`. Lists can also be type-restricted, like `list(string)` or `list(number)`.

---

### **“What is the difference between data types like list, map, number, string?”**

> List is an ordered collection, map is key-value pairs, string is text, number is numeric value. Terraform determines the required type for each argument from documentation.










# ✅ PART 1 — MAP DATA TYPE (KEY–VALUE PAIRS)

## 1. What is a Map in Terraform?

A **map** is a collection of **key–value pairs**.

```hcl
variable "instance_tags" {
  type = map(string)

  default = {
    Name        = "app-server"
    Environment = "dev"
    Team        = "payments"
  }
}
```

* Each **key** is unique
* Each **key has exactly one value**
* Values are accessed by **key name**

---

## 2. When to Use Map (Very Important)

You use **map** when:

* Data is in **key → value** format
* Keys have meaning (not just position)

### 🔥 MOST COMMON USE CASE — AWS TAGS

AWS Tags are **not lists**.
They are **maps**.

AWS Console example:

```
Key: Name        → Value: web
Key: Environment → Value: dev
Key: Team        → Value: payments
```

Terraform:

```hcl
tags = {
  Name = "web"
  Env  = "dev"
}
```

📌 That’s why `tags` expects:

```
Map of tags to assign to the resource
```

---

## 3. Practical Map Demo Behavior

### ❌ Wrong (list instead of map)

```hcl
["team=payments"]
```

Terraform error ❌

### ✅ Correct

```hcl
{
  team     = "payments"
  location = "us"
}
```

---

## 4. Default Map Values

```hcl
variable "my_map" {
  type = map(string)

  default = {
    name = "Alice"
    team = "payments"
  }
}
```

Terraform will **not prompt** for values.

---

# ✅ PART 2 — REFERENCING VALUES FROM MAPS & LISTS

This is **VERY IMPORTANT** for exams and real production code.

---

## 1. Referencing a Map Value

### Map definition:

```hcl
variable "types" {
  type = map(string)

  default = {
    us-west-2  = "t2.nano"
    ap-south-1 = "t2.small"
  }
}
```

### Usage:

```hcl
instance_type = var.types["us-west-2"]
```

✅ Output:

```
instance_type = t2.nano
```

Change key → value changes automatically.

---

## 2. Referencing a List Value

### List definition:

```hcl
variable "sizes" {
  type = list(string)
  default = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}
```

### Indexing rules:

| Index | Value      |
| ----- | ---------- |
| 0     | m5.large   |
| 1     | m5.xlarge  |
| 2     | m5.2xlarge |

### Usage:

```hcl
instance_type = var.sizes[1]
```

✅ Output:

```
m5.xlarge
```

📌 **Lists use positions**, maps use **keys**

---

# ✅ PART 3 — COUNT META-ARGUMENT

## 1. What is `count`?

By default:

```hcl
resource "aws_instance" "example" { }
```

👉 Creates **ONE resource**

### With count:

```hcl
count = 3
```

👉 Creates **THREE identical resources**

---

## 2. Why `count` Exists?

Without count:

* You must copy the same resource block many times
* Code becomes huge and unmaintainable

With count:

* One block
* Clean code
* Dynamic scaling

---

## 3. Count Resource Addressing

If:

```hcl
resource "aws_instance" "my_ec2" {
  count = 3
}
```

Terraform creates:

```
aws_instance.my_ec2[0]
aws_instance.my_ec2[1]
aws_instance.my_ec2[2]
```

Indexes **always start from 0**.

---

## 4. Major Problem with `count` (Critical)

`count` creates **IDENTICAL COPIES**.

### Example problem:

```hcl
resource "aws_iam_user" "user" {
  name  = "payments-user"
  count = 3
}
```

AWS requires **unique usernames**.

Result:

* First user ✅ created
* Second ❌ fails
* Third ❌ fails

---

# ✅ PART 4 — COUNT.INDEX (SOLUTION TO REAL PROBLEMS)

## 1. What is `count.index`?

`count.index`:

* Starts from **0**
* Increments per resource
* Unique per instance

---

## 2. Using `count.index` for EC2 Names

### Problem:

All EC2s have same Name tag

### Solution:

```hcl
tags = {
  Name = "payments-system-${count.index}"
}
```

Results:

```
payments-system-0
payments-system-1
payments-system-2
```

✅ Human-friendly
✅ Debug-friendly

---

## 3. Fixing IAM User Uniqueness

```hcl
resource "aws_iam_user" "user" {
  count = 3
  name  = "payments-user-${count.index}"
}
```

Creates:

```
payments-user-0
payments-user-1
payments-user-2
```

✅ Works perfectly

---

## 4. Advanced Pattern — List + Count Index (REAL WORLD)

### Variable:

```hcl
variable "users" {
  type    = list(string)
  default = ["Alice", "Bob", "John"]
}
```

### Resource:

```hcl
resource "aws_iam_user" "users" {
  count = length(var.users)
  name  = var.users[count.index]
}
```

Creates:

```
Alice
Bob
John
```

📌 Very common in:

* IAM users
* EC2 hostnames
* Batch resources

---

## 5. Important Behavior to Remember

* `count` decides **how many**
* `count.index` decides **which one**
* If list has more items than count → extra ignored
* If count > list length → Terraform errors

---

# ✅ FINAL EXAM-READY SUMMARY

### **Map vs List**

| Type | Used for                        |
| ---- | ------------------------------- |
| map  | Key–value pairs (tags, configs) |
| list | Ordered values (SGs, AZs)       |

---

### **Referencing**

```hcl
var.map["key"]
var.list[index]
```

---

### **count**

* Creates multiple identical resources
* Index starts at **0**

---

### **count.index**

* Makes each instance unique
* Used for naming & customization










# ✅ PART 1 — CONDITIONAL EXPRESSIONS IN TERRAFORM

## 1. What is a Conditional Expression?

A **conditional expression** lets Terraform choose between **two values** based on a **condition**.

### General Syntax

```hcl
condition ? true_value : false_value
```

* If `condition` is **true** → `true_value` is used
* If `condition` is **false** → `false_value` is used

---

## 2. Real-World Example: Choosing Instance Type by Environment

### Variable:

```hcl
variable "environment" {
  default = "development"
}
```

### Conditional Expression inside EC2:

```hcl
instance_type = var.environment == "development" ?
                "t2.micro" :
                "m5.large"
```

### Result:

| environment                | instance_type |
| -------------------------- | ------------- |
| development                | t2.micro      |
| production / anything else | m5.large      |

---

## 3. Testing the Behavior

### Case 1 — Default “development”

```
terraform plan
→ instance_type = t2.micro
```

### Case 2 — Change to "production"

```
terraform plan
→ instance_type = m5.large
```

---

## 4. Using "not equal" (!=)

```hcl
instance_type = var.environment != "development" ?
                "t2.micro" :
                "m5.large"
```

Meaning:

* If environment **is NOT development** → t2.micro
* Otherwise → m5.large

---

## 5. Condition on Missing / Empty Values

If default is empty:

```hcl
variable "environment" {}
```

Then:

```hcl
instance_type = var.environment == "" ?
                "t2.micro" :
                "m5.large"
```

---

## 6. Using Multiple Conditions (Logical AND)

You can combine conditions:

```hcl
instance_type = (var.environment == "production" &&
                 var.region == "us-east-1") ?
                 "m5.large" :
                 "t2.micro"
```

### True only if:

* environment = production
  **AND**
* region = us-east-1

Otherwise → t2.micro

---

# 🧠 EXAM TIP

Conditional expressions are used heavily in module customization:

* region-specific defaults
* environment-based sizing
* enabling or disabling resources

Keep the syntax memorized:

```
condition ? true : false
```

---

# ✅ PART 2 — TERRAFORM FUNCTIONS

## 1. What is a Function?

A function in Terraform:

* accepts **input**
* returns **output**
* performs a **specific task**

This is the same concept you see in Python.

---

## 2. Example — max() Function

```hcl
max(10, 30, 20)  → 30
```

Terraform decides the **largest number**.

---

## 3. Example — file() Function

```hcl
file("random-file.txt")
```

Returns the **entire content** of the file as a string.

This is extremely useful for:

* IAM policies
* JSON configurations
* certificates
* shell scripts

---

# ✅ PART 3 — TERRAFORM CONSOLE (Testing Functions)

Run:

```
terraform console
```

Then test any function:

### max()

```
> max(10, 50, 20)
50
```

### file()

```
> file("random-file.txt")
"This is a test file"
```

Terraform console is powerful:

* test expressions
* test variables
* test functions
* avoid trial-and-error inside real plan/apply

---

# ✅ PART 4 — WHY FUNCTIONS MATTER (REAL WORLD)

## 1. The Problem (without functions)

A policy embedded directly inside `.tf` file:

```hcl
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    ...
  ]
}
EOF
```

Issues:

* makes Terraform file **huge**
* editing JSON inside HCL is error-prone
* no code reuse
* poor readability

---

## 2. The Solution — Use file() Function

Move JSON to a separate file:

```
iam-user-policy.json
```

Then reference:

```hcl
policy = file("iam-user-policy.json")
```

Benefits:

* cleaner Terraform code
* easier editing
* reusable
* reduces risk of JSON formatting errors
* separates logic from content

This is used **everywhere**:

* IAM JSON policies
* security configs
* Lambda zip handling
* template rendering

---

# 🧠 EXAM TIP

You **cannot create custom functions**.
Terraform only supports **built-in functions**.

Quote:

> Terraform language does not support user-defined functions.

Important categories to remember:

* **numeric functions** (max, min, ceil, floor)
* **string functions** (upper, lower, trimspace)
* **collection functions** (length, keys, values, contains, lookup)
* **filesystem functions** (file, templatefile)
* **encoding functions** (jsonencode, base64encode)

---

# 🧠 MOST IMPORTANT FUNCTIONS FOR EXAM & REAL JOB

### **jsonencode()**

Convert HCL map → JSON string
Used for IAM policies and Kubernetes manifests.

### **file()**

Load external file.

### **templatefile()**

Load file + replace variables.

### **lookup()**

Safe read from maps.

### **length()**

Length of list or map.

### **keys() / values()**

Extract keys/values.

### **element()**

Get list element with wrap-around.

### **coalesce()**

Return first non-null value.

---

# 🎯 FINAL SUMMARY (Quick Revision)

## Conditional Expressions

```hcl
condition ? true_value : false_value
```

Used for:

* choosing instance types
* enabling/disabling resources
* environment-based logic

---

## Terraform Functions

* Built-in helpers for logic, math, strings, file loading
* Cannot define your own
* Massive time-saver and code reducer

---

## file() Function

Loads external files → essential for:

* policies
* JSON configs
* templates








# ✅ **1. Terraform Functions — What They Are & How to Use Them**

### **Definition**

A function in Terraform:

* takes some **input**
* performs a **specific calculation or operation**
* returns **output**

Examples:

```hcl
max(10, 20, 30)         # → 30
file("demo.txt")       # → returns content of file
length(["a","b","c"])  # → 3
```

### **Where to use functions**

Functions appear inside:

* resource arguments
* variables
* locals
* outputs

Example:

```hcl
ami = lookup(var.ami, var.region)
```

---

## **Key Functions in the Challenge Code**

### **1. lookup()**

**Purpose:** Get a value from a map using a key.

```hcl
lookup(var.ami, var.region)
```

If:

```hcl
ami = {
  "us-east-1" = "ami-123"
  "us-west-2" = "ami-456"
}
region = "us-east-1"
```

Then:

```
lookup(var.ami, var.region) → "ami-123"
```

---

### **2. length()**

Returns the **number of items** in a list, string, or map.

```hcl
length(var.tags)   # If tags = ["a", "b"], result = 2
```

Often used with `count`:

```hcl
count = length(var.tags)
```

---

### **3. element()**

Returns item at index **from a list**.

```hcl
element(var.tags, count.index)
```

If:

```hcl
tags = ["first EC2", "second EC2"]
```

Then during creation:

* first EC2 instance → `first EC2`
* second EC2 instance → `second EC2`

---

### **4. timestamp()**

Returns the current time in RFC3339 format.

Example:

```
2024-06-17T10:52:01Z
```

---

### **5. formatdate()**

Converts timestamp to readable format:

```hcl
formatdate("DD/MM/YYYY", timestamp())
```

Output example:

```
17/06/2024
```

---

# ✅ **2. Local Values (locals)**

### **What are locals?**

Locals let you store **reusable expressions**, similar to variables, but:

* **cannot be overridden** (unlike variables)
* often store **computed values**
* allow functions inside

Example:

```hcl
locals {
  common_tags = {
    Team = "security-team"
    CreationDate = formatdate("YYYY-MM-DD", timestamp())
  }
}
```

Use in resources:

```hcl
tags = local.common_tags
```

### **Why locals instead of variables?**

Use **variables** when:

* users or pipelines need to overwrite values
* value is an input

Use **locals** when:

* you want to compute a value
* the value should NOT be overridden
* repeated expressions must be centralized

---

# 🔥 **Important Rule**

Definition uses **locals** (plural), but reference uses **local** (singular).

Example:

```hcl
locals { common_tags = {...} }

tags = local.common_tags
```

---

# ✅ **3. Data Sources — The Most Important Concept**

### **Definition**

Data sources let Terraform **read information that already exists** outside Terraform.

Terraform **does NOT create** anything with data sources.

Uses:

* fetch existing EC2 IDs
* get AMIs
* get VPC IDs
* read files
* fetch Azure/DigitalOcean metadata

---

## **Basic Format**

```hcl
data "<provider>_<type>" "<name>" {
  # optional filters
}
```

Example:

```hcl
data "aws_instances" "all" {}
```

Data is stored in `terraform.tfstate`.

---

# 🔍 **Examples Explained**

## **1. DigitalOcean Account Data Source**

```hcl
data "digitalocean_account" "info" {}
```

Fetches:

* email
* droplet limits
* floating IP limits

Stored in state, not printed unless you output it.

---

## **2. Read Local File**

```hcl
data "local_file" "demo" {
  filename = "${path.module}/demo.txt"
}
```

Outputs:

```hcl
data.local_file.demo.content
```

### **What is path.module?**

It returns the directory where the current `.tf` file is located.

---

## **3. AWS EC2 Instances**

### **Multiple instances**

```hcl
data "aws_instances" "all" {}
```

Retrieves:

* private_ips
* public_ips
* instance_ids

### **Single instance**

```hcl
data "aws_instance" "example" {
  instance_id = "i-123..."
}
```

⚠️ If more than one instance matches, Terraform errors until you filter.

---

# ✅ **4. Filters in Data Sources**

Filters are key to narrowing down resources.

### Example: Find EC2 instance by tag

```hcl
data "aws_instance" "prod" {
  filter {
    name   = "tag:team"
    values = ["production"]
  }
}
```

Now Terraform will fetch **only**:

```
instance where tag team = production
```

If more instances match, Terraform still throws an error — this data source supports **only one** match.

### For multiple EC2s → use:

```hcl
data "aws_instances" "prod" {
  filter {
    name   = "tag:team"
    values = ["production"]
  }
}
```

---

# 🚀 FINAL SUMMARY (fast revision)

### **Functions**

* lookup() → read from map
* length() → count items
* element() → pick from list
* timestamp() → current time
* formatdate() → readable date

### **Local Values**

* reusable computed expressions
* allow functions
* cannot be overridden

### **Data Sources**

* fetch information **outside** Terraform
* do NOT create resources
* stored in tfstate
* use filters for precision

### **Filters**

Allow you to fetch:

* by name
* by AMI
* by tags
* by attributes





# ✅ **1. Understanding Terraform Functions (Lookup / Length / Element / Formatdate / Timestamp)**

Terraform functions are used to calculate values dynamically **instead of hardcoding them**.

### Example Code

Inside an EC2 resource we may see:

```hcl
ami           = lookup(var.ami, var.region)
count         = length(var.tags)
tags = {
  Name         = element(var.tags, count.index)
  CreationDate = formatdate("DD MMM YYYY", timestamp())
}
```

Now break each function down.

---

## 🔹 **lookup(map, key, default)**

**Purpose:** Get a value from a map.

### Example:

```hcl
variable "ami" {
  type = map(string)
  default = {
    "us-east-1" = "ami-1111"
    "us-west-2" = "ami-2222"
  }
}

lookup(var.ami, "us-east-1")  →  "ami-1111"
```

If key doesn’t exist → return default.

---

## 🔹 **length(list/map/string)**

Returns number of items.

```hcl
length(["a","b"]) → 2
length("hello") → 5
```

Used for `count = length(var.tags)`.

---

## 🔹 **element(list, index)**

Retrieve item from list by index.

```hcl
element(["a", "b", "c"], 1) → "b"
```

When combined with `count.index`, it labels resources properly:

```
first EC2
second EC2
```

---

## 🔹 **timestamp()**

Returns UTC timestamp (not human friendly).

Example:

```
2024-07-11T14:17:30Z
```

---

## 🔹 **formatdate()**

Converts timestamp into readable format.

```hcl
formatdate("DD MM YYYY", timestamp())
```

This becomes something like:

```
11 07 2024
```

---

# ✅ **2. Local values (“locals”)**

Locals allow you to centralize repeated values.

### Example

```hcl
locals {
  common_tags = {
    Team = "security-team"
    CreationDate = formatdate("YYYY-MM-DD", timestamp())
  }
}
```

Then in resources:

```hcl
tags = local.common_tags
```

### **Difference between variables and locals**

| Feature                         | Variables              | Locals   |
| ------------------------------- | ---------------------- | -------- |
| Can be overwritten?             | YES (tfvars, CLI, env) | NO       |
| Useful for inputs               | YES                    | NO       |
| Useful for computed expressions | OK                     | **BEST** |

Use **locals** when value must not change outside code.

---

# ✅ **3. Data sources**

Data sources **fetch external information** that Terraform does not create.

Examples:

* fetch AMI IDs
* fetch existing VPCs
* read files
* get instance details

---

## 🔹 **Types of data sources**

### 1. **DigitalOcean Account**

```hcl
data "digitalocean_account" "do" {}
```

This fetches details about your DO account.

---

### 2. **Local File**

```hcl
data "local_file" "foo" {
  filename = "${path.module}/demo.txt"
}
```

Reads content of a file.

---

### 3. **AWS Instances**

```hcl
data "aws_instances" "all" {}
```

Returns IDs of all EC2s in region.

---

### Data source output stored in:

```
terraform.tfstate
```

---

# ✅ **4. Using Data Source to Get Latest AMI (MOST IMPORTANT PRACTICAL USE CASE)**

This is the most real-world task.
Goal: **Never hardcode AMI IDs. They differ per region.**

---

## 🔹 **Wrong / static approach**

```hcl
ami = "ami-12345678"
```

Fails if region changes.

---

## 🔹 **Correct approach using aws_ami data source**

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

Use in EC2:

```hcl
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t3.micro"
}
```

This works in *any region*.

---

# ✅ **5. Debugging Terraform**

Debug logs useful when things fail.

### Enable debug logs

**Linux / Mac**

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=terraform.log
```

**Windows**

```powershell
set TF_LOG=TRACE
set TF_LOG_PATH=terraform.log
```

Now run:

```bash
terraform plan
```

Logs will appear in `terraform.log`.

---

# ✅ **6. Troubleshooting Model**

4 types of Terraform errors:

1. **Language errors**

   * syntax errors
   * undeclared variables
   * unsupported arguments

2. **State errors**

   * lock issues
   * drift
   * corruption

3. **Core Terraform bugs**

   * in Terraform binary
   * check GitHub issues

4. **Provider plugin bugs**

   * AWS provider bugs
   * must update provider

---

# ✅ **7. Terraform fmt (formatting)**

Fixes messy code indentation.

```bash
terraform fmt
```

---

# ✅ **8. Load Order & File Organization**

Terraform loads all `.tf` files in the folder.

Best practice:

```
provider.tf
variables.tf
outputs.tf
ec2.tf
iam_user.tf
vpc.tf
```

---

# ✅ **9. Dynamic Blocks**

Used when a nested block repeats many times.

### Without dynamic block (bad):

```hcl
ingress {
  from_port = 8200
  to_port   = 8200
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port = 8201
  to_port   = 8201
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

### With dynamic block (best):

```hcl
variable "sg_ports" {
  type    = list(number)
  default = [8200, 8201, 8300, 9500]
}

resource "aws_security_group" "dynamic_sg" {
  dynamic "ingress" {
    for_each = var.sg_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

You can also use:

```hcl
iterator = port
from_port = port.value
```

---

# ✅ **10. terraform validate**

Check syntax without deploying:

```bash
terraform validate
```

It catches:

* undeclared variables
* unsupported arguments
* syntax issues

---

# ✅ **11. terraform taint / replace**

Old command:

```bash
terraform taint aws_instance.web
```

New recommended command:

```bash
terraform apply -replace="aws_instance.web"
```

Purpose:

* force recreate a resource (when manually changed, corrupted, or broken).








Below is a **clean, structured, beginner-friendly rewrite** of everything you shared, with **clear explanations, correct terminology, and practical examples**, exactly aligned with Terraform best practices.

I kept it **teachable**, **interview-ready**, and **production-oriented**.

---

# ✅ 1. Terraform **Splat Expression**

## What is a Splat Expression?

A **splat expression** is a shortcut that lets you **collect the same attribute from multiple resources** into a list.

This is most commonly used when:

* a resource is created using `count`
* you want output for **all instances**, not just one

---

## Example: IAM Users with `count`

```hcl
resource "aws_iam_user" "lb" {
  count = 3
  name  = "user-${count.index}"
}
```

Terraform creates:

* aws_iam_user.lb[0]
* aws_iam_user.lb[1]
* aws_iam_user.lb[2]

---

## Without splat (single resource)

```hcl
output "first_user_arn" {
  value = aws_iam_user.lb[0].arn
}
```

Outputs ARN of only **one user**.

---

## With splat (all resources)

```hcl
output "all_user_arns" {
  value = aws_iam_user.lb[*].arn
}
```

✅ Returns **list of all ARNs**, no matter how many users exist.

---

### ✅ Why splat is powerful

* Works for 3 resources or 300
* No manual indexing
* Perfect for outputs and cross-module usage

---

# ✅ 2. Terraform **Graph**

## What is `terraform graph`?

It generates a **dependency graph** showing how resources depend on each other.

Terraform uses this dependency tree internally to:

* decide creation order
* decide destruction order
* parallelize safely

---

## Example Dependencies

```
Provider (AWS)
│
├── EC2 instances
│
├── Load Balancer → depends on EC2
│
└── Route53 → depends on Load Balancer
```

---

## Generate Graph Output

```bash
terraform graph
```

This outputs **DOT language**, which looks unreadable.

---

## Visualize Graph (Online)

* Search: **graphviz online**
* Paste DOT output
* See dependency diagram

⚠️ Not recommended for sensitive infra

---

## Visualize Graph (Offline – Recommended)

### Install Graphviz

**Ubuntu / Debian**

```bash
sudo apt install graphviz
```

**Mac**

```bash
brew install graphviz
```

---

### Generate image

```bash
terraform graph | dot -Tpng graph.png
terraform graph | dot -Tsvg graph.svg
```

Open image locally → ✅ safe & secure.

---

## Why Terraform Graph matters

* Understand complex dependencies
* Debug destroy/apply issues
* Review infra architecture visually

---

# ✅ 3. Saving Terraform Plan to a File

## Standard Workflow (Risky in Production)

```bash
terraform plan
terraform apply
```

Problem:

* Code may change between plan & apply
* Results may differ

---

## ✅ Recommended Production Workflow

```bash
terraform plan -out=infra.plan
terraform apply infra.plan
```

✅ Apply uses **exact plan**, regardless of code changes.

---

## Example: Why it matters

1. Create plan:

```bash
terraform plan -out=infra.plan
```

2. Modify resource afterward
3. Apply saved plan:

```bash
terraform apply infra.plan
```

✅ Terraform **ignores new changes**
✅ Infrastructure matches approved plan

---

## Inspect Saved Plan

### Human-readable

```bash
terraform show infra.plan
```

### JSON (automation / auditing)

```bash
terraform show -json infra.plan | jq
```

✅ Required for:

* CI/CD pipelines
* Change management
* Security reviews

---

# ✅ 4. `terraform output` Command

## Purpose

Extract output values from **state file** without running `apply`.

---

## Example Output Block

```hcl
output "iam_names" {
  value = aws_iam_user.lb[*].name
}
```

---

## Retrieve Outputs Later

```bash
terraform output
terraform output iam_names
terraform output iam_arn
```

✅ No apply
✅ No re-creation
✅ Reads state safely

---

# ✅ 5. Terraform **Settings Block**

The `terraform` block controls **project behavior**, not resources.

---

## Example Terraform Block

```hcl
terraform {
  required_version = "= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
```

---

## Why this matters

Without settings:

* Terraform uses latest provider (may break)
* Version mismatch risk

With settings:

* Predictable builds
* Safe upgrades
* Production stability

---

## Lock file update

If provider version changes:

```bash
terraform init -upgrade
```

---

# ✅ 6. Resource Targeting (`-target`)

## Default Terraform Behavior

Applies **all resources** in folder.

---

## Target single resource

```bash
terraform plan -target=local_file.foo
terraform apply -target=local_file.foo
terraform destroy -target=local_file.foo
```

✅ Only that resource is affected
✅ Others untouched

---

## When to use `-target`

✅ Emergency fixes
✅ Debugging state issues
✅ Partial infra recovery

🚫 **Not for daily workflows**

---

# ✅ 7. Terraform at Scale – API Throttling Problem

## Real Problem in Large Infra

* Hundreds of resources
* Every `terraform plan` calls APIs
* Cloud provider rate limits exceeded
* Production impact

---

## Example Scenario

* CIS hardening rules
* Hundreds of AWS API calls
* Terraform refresh = excessive load

---

# ✅ 8. Solutions to Terraform Scale Issues

---

## ✅ Solution 1: Split Projects

Instead of one giant repo:

```
vpc/
iam/
security-groups/
ec2/
```

✅ Less API calls
✅ Faster plans
✅ Independent deployment

---

## ✅ Solution 2: Resource Targeting

Apply resources one-by-one:

```bash
terraform apply -target=aws_security_group.web
```

✅ Controlled API usage

---

## ✅ Solution 3: Disable Refresh (Advanced)

```bash
terraform plan -refresh=false
```

✅ Skips state refresh
✅ Reduces API calls
⚠️ Use only if state is trusted

---

## When to avoid `-refresh=false`

* State drift likely
* Manual console changes
* Non-production environments

---

# ✅ FINAL SUMMARY

You now understand:

✅ Splat expressions
✅ Terraform graph visualization
✅ Saving & applying plans safely
✅ terraform output usage
✅ Terraform project settings
✅ Resource targeting
✅ Handling large infra & API throttling








# Terraform `zipmap()` Function

## What is `zipmap()`?

`zipmap()` is a Terraform function that **creates a map by pairing two lists**:

* one list of **keys**
* one list of **values**

Each key is matched with the value at the same index.

---

## Basic Syntax

```hcl
zipmap(keys, values)
```

* `keys` → list of strings
* `values` → list of values
* Both lists **must have the same length**

---

## Simple Example

```hcl
zipmap(
  ["pineapple", "orange", "strawberry"],
  ["yellow", "orange", "red"]
)
```

### Output:

```hcl
{
  pineapple  = "yellow"
  orange     = "orange"
  strawberry = "red"
}
```

Terraform pairs elements **by index**:

* pineapple → yellow
* orange → orange
* strawberry → red

---

## Trying in Terraform Console

```bash
terraform console
```

```hcl
zipmap(["a", "b"], ["1", "2"])
```

Output:

```hcl
{
  "a" = "1"
  "b" = "2"
}
```

---

## Practical Use Case: IAM Users

### Problem

You create multiple IAM users using `count` and get:

* one output for names
* one output for ARNs

This becomes hard to read and correlate.

---

### IAM Resource

```hcl
resource "aws_iam_user" "iamuser" {
  count = 3
  name  = "iamuser.${count.index}"
}
```

---

### Separate Outputs (Hard to Read)

```hcl
output "iam_names" {
  value = aws_iam_user.iamuser[*].name
}

output "iam_arns" {
  value = aws_iam_user.iamuser[*].arn
}
```

Result:

* Names list
* ARNs list
  ❌ No clear mapping

---

### ✅ Better Output Using `zipmap`

```hcl
output "iam_name_to_arn" {
  value = zipmap(
    aws_iam_user.iamuser[*].name,
    aws_iam_user.iamuser[*].arn
  )
}
```

### Output:

```hcl
{
  iamuser.0 = "arn:aws:iam::123456789:user/iamuser.0"
  iamuser.1 = "arn:aws:iam::123456789:user/iamuser.1"
  iamuser.2 = "arn:aws:iam::123456789:user/iamuser.2"
}
```

✅ Easy to read
✅ Easy to consume in modules
✅ Very useful in large projects

---

# Comments in Terraform

Terraform supports **three comment styles**.

---

## 1. Hash (`#`) – Recommended

```hcl
# This creates an EC2 instance
resource "aws_instance" "example" {
  instance_type = "t2.micro"
}
```

✅ Most commonly used
✅ Clean and readable

---

## 2. Double Slash (`//`)

```hcl
// This is also a single-line comment
```

✅ Works like `#`
❌ Less commonly used

---

## 3. Multi-line Comments (`/* */`)

```hcl
/*
This is a multi-line comment.
Used for explanations or temporarily disabling code.
*/
```

---

### Commenting Out a Resource Temporarily

```hcl
/*
resource "aws_instance" "temp" {
  ami           = "ami-123"
  instance_type = "t2.micro"
}
*/
```

✅ Useful during testing
✅ Resource will NOT be created

⚠️ Remember to close `*/` or Terraform will comment everything below it.

---

# Terraform Meta-Arguments – Introduction

## What is a Meta-Argument?

Meta-arguments **change how Terraform behaves**, not what it creates.

They are added **inside resource blocks**.

---

## Default Terraform Resource Behavior

Terraform:

1. Creates resources present in config but missing in state
2. Destroys resources in state but missing from config
3. Updates resources **in-place** if possible
4. Destroys & recreates resources if in-place update is not possible

---

## Examples

### In-place Update

Changing a tag:

```hcl
tags = {
  Name = "HelloWorld"
}
```

→ Change to `"HelloEarth"`
✅ No destroy, just update

---

### Force Replacement

Changing AMI:

```hcl
ami = "linux-ami"
```

→ change to Windows AMI
❌ EC2 instance is destroyed and recreated

---

# Problem in Real Life

Someone manually updates a resource in AWS Console.

Example:

* Adds a tag: `Env=production`

Terraform behavior:

* Detects drift
* Removes the tag during next `terraform apply`

❌ Sometimes this is not what you want.

---

# Lifecycle Meta-Argument

## Purpose

Allows you to **customize Terraform’s default behavior**.

---

## Example: Ignore Manual Tag Changes

```hcl
resource "aws_instance" "example" {
  ami           = "ami-123"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
```

---

### What This Does

* Terraform will **ignore any manual tag changes**
* Tags added in AWS Console remain untouched
* Terraform will not try to revert them

✅ Very common in production

---

## Remove `lifecycle` Block

Terraform goes back to default behavior:

* Detects drift
* Fixes it

---

# Lifecycle Meta-Argument – All Options (Overview)

Inside `lifecycle {}` you can use:

---

## 1. `ignore_changes`

Ignore specific attribute changes.

✅ Most commonly used

---

## 2. `create_before_destroy`

Create new resource first, then destroy old one.

✅ Prevents downtime

---

## 3. `prevent_destroy`

Blocks accidental deletion.

```hcl
lifecycle {
  prevent_destroy = true
}
```

✅ Very useful for:

* Databases
* Production storage
* Critical infrastructure

---

## 4. `replace_triggered_by`

Forces replacement when a referenced resource changes.

✅ Useful for hard dependencies

---

# Other Important Meta-Arguments (Overview)

Terraform supports:

* `count`
* `for_each`
* `depends_on`
* `provider`
* `lifecycle`

⚠️ `provider` meta-argument is **not the same** as provider block
It overrides which provider is used **per resource**.

---

# Final Summary

You now understand:

✅ `zipmap()` and when to use it
✅ How to write clean Terraform comments
✅ Default Terraform resource behavior
✅ What meta-arguments are
✅ Why lifecycle meta-argument is critical
✅ All lifecycle options at a high level










# **Terraform Lifecycle + Meta-Arguments (Simple Explanations + Examples)**

---

## **1. `create_before_destroy`**

### **Purpose**

Make Terraform **create the new resource first**, and **destroy the old one later**.

### **Why needed?**

In production, you do **not** want downtime.
Default Terraform behavior is:

1. Destroy old
2. Create new

This causes downtime.

### **How to use**

```hcl
resource "aws_instance" "demo" {
  ami           = var.ami
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

### **Effect**

Terraform will:

1. Create new instance
2. Terminate old instance

---

## **2. `prevent_destroy`**

### **Purpose**

Stop Terraform from destroying a resource **at all**.

### **Use case**

* Prevent accidental deletion of:

  * Production databases
  * KMS keys
  * VPCs
  * S3 buckets with important data

### **How to use**

```hcl
lifecycle {
  prevent_destroy = true
}
```

### **Important**

If you delete the entire resource block from tf code → Terraform **WILL** destroy it.
Prevent_destroy only works if the block is still in configuration.

---

## **3. `ignore_changes`**

### **Purpose**

Tell Terraform to **ignore manual changes** done outside Terraform.

### **Use case**

* DevOps team changed EC2 instance type manually
* Someone added tags manually
* Auto-scaling updated some attributes

### **Examples**

#### **Ignore only Tags**

```hcl
lifecycle {
  ignore_changes = [tags]
}
```

#### **Ignore Tags + Instance Type**

```hcl
lifecycle {
  ignore_changes = [tags, instance_type]
}
```

#### **Ignore ALL changes**

```hcl
lifecycle {
  ignore_changes = [all]
}
```

> When using `[all]`, Terraform will **never update** the resource even if you modify the `.tf` file.

---

## **4. Resource Dependencies (`depends_on`)**

There are **two types**:

---

### **A) Explicit dependency (`depends_on`)**

Use when Terraform **cannot automatically understand** the relationship.

```hcl
resource "aws_instance" "app" {
  depends_on = [aws_s3_bucket.data]

  ami           = var.ami
  instance_type = "t2.micro"
}
```

### **Effect**

* Terraform creates S3 bucket **first**
* Then creates EC2 instance

### **Use case**

* S3 bucket must exist before EC2 starts
* IAM role must exist before Lambda
* SG must exist before RDS

---

### **B) Implicit dependency**

Terraform **automatically understands** dependency when a resource **references another** using attributes.

Example:

```hcl
vpc_security_group_ids = [aws_security_group.prod.id]
```

Because you referenced `.id`, Terraform will:

1. Create security group first
2. Create EC2 instance second

This is implicit ordering.

### **Use case**

Whenever one resource **needs an output** from another.

---

# **5. `count` vs `for_each`**

---

## **A) `count`**

### **When to use**

* When **all resources are identical**
* No differences in configuration

### **Example**

```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = var.ami
  instance_type = "t2.micro"
}
```

### **Problems with `count`**

If you change the order of list → Terraform will recreate resources.
Bad for production.

---

## **B) `for_each`** (better for production)

### **When to use**

* When **every item needs a unique config**
* When order **must not break resources**
* When input is:

  * set
  * map

### **Example 1: For each with Set**

```hcl
variable "users" {
  type = set(string)
  default = ["alice", "bob", "john"]
}

resource "aws_iam_user" "u" {
  for_each = var.users
  name     = each.value
}
```

### **Example 2: For each with Map**

```hcl
variable "amis" {
  type = map(string)
  default = {
    dev  = "ami-111"
    prod = "ami-222"
  }
}

resource "aws_instance" "vm" {
  for_each = var.amis
  ami      = each.value
  tags = {
    Name = each.key
  }
}
```

---

# **6. List vs Set (Very Simple)**

| Feature             | **List**     | **Set**      |
| ------------------- | ------------ | ------------ |
| Order matters       | Yes          | No           |
| Can have duplicates | Yes          | No           |
| Indexing            | Yes (0,1,2)  | No           |
| Best used for       | ordered data | unique items |

### Example

List:

```hcl
["a", "b", "b"]
```

Set:

```hcl
["a", "b"]
```

Terraform will remove duplicate "b".

---

# **7. Object Data Type**

### **Purpose**

Advanced structure with different types for each attribute.

### **Example**

```hcl
variable "user" {
  type = object({
    name    = string
    age     = number
    country = string
  })
}
```

### **Value example**

```hcl
user = {
  name    = "Alice"
  age     = 30
  country = "USA"
}
```

### **Extra attributes are ignored**

If user gives more fields → Terraform discards them.

---

# **8. Map Data Type**

### **Purpose**

Key/value data. **All values must have same type**.

### Example

```hcl
variable "details" {
  type = map(number)
}
```

Valid:

```
{ age = 30, salary = 5000 }
```

Not valid:

```
{ age = 30, name = "bob" }  # Wrong (string + number)
```



