---
title: "Microsoft Azure #1"
description: "Azure Is Just Microsoft’s Version of AWS           Microsoft Azure is Microsoft’s cloud..."
published: 2026-03-01
source: "https://dev.to/jumptotech/microsoft-azure-1-24l6"
tags: []
---

# Microsoft Azure #1





# Azure Is Just Microsoft’s Version of AWS

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Microsoft_Azure_Logo.svg/1280px-Microsoft_Azure_Logo.svg.png)

![Image](https://learn.microsoft.com/en-us/azure/azure-portal/media/azure-portal-dashboards/portal-menu-dashboard.png)

![Image](https://media.licdn.com/dms/image/v2/D4D12AQHyVSyEz1ho4w/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1721488324500?e=2147483647\&t=CxnAGrKmWOjL1KOuWZ0wdc3WTI0b3b708_YCYTERHjI\&v=beta)

![Image](https://1.bp.blogspot.com/-B3FIJgQE9Fg/XhHydm-g6fI/AAAAAAAAtuI/XqFEShj_shAqPDWcZ03vHbsQIlt1sVhMACLcBGAsYHQ/s1600/Cloud%2Bcomparsion.jpg)

Microsoft Azure is Microsoft’s cloud platform.

Amazon Web Services AWS is Amazon’s cloud platform.

Both provide:

* Compute
* Storage
* Networking
* Identity
* Monitoring
* Kubernetes
* CI/CD tools

The difference is not capability.
The difference is structure and identity model.

---

# The First Big Difference: Azure Has a Strict Hierarchy

In AWS, you are used to this:

Account
→ Resources inside the account

Simple.

In Azure, the structure is deeper and more formal.

Azure hierarchy looks like this:

Management Group
→ Subscription
→ Resource Group
→ Resources

This structure is very important. If you don’t understand it, Azure will always feel confusing.

Let’s translate this into AWS language.

---

## Subscription = AWS Account

In AWS, your account is your billing and resource boundary.

In Azure, that boundary is called a Subscription.

A Subscription:

* Has billing attached
* Has quotas and limits
* Contains all resources
* Is a security boundary

If you worked in a company using multiple AWS accounts (dev, staging, prod), Azure does the same using multiple subscriptions.

So when someone says:

“Which subscription is this deployed in?”

Think:

“Which AWS account is this in?”

---

## Resource Group = Logical Infrastructure Container

This is where Azure becomes different.

AWS does not have an equivalent of Resource Group.

You might compare it loosely to:

* CloudFormation stack
* Or a tagging strategy

But Resource Group is more powerful and more mandatory.

In Azure, every single resource must belong to a Resource Group.

You cannot create a VM without selecting a Resource Group.

A Resource Group is simply a logical container for resources.

Example:

Resource Group: rg-dev-web

Inside it:

* Virtual Machine
* Virtual Network
* Public IP
* Network Security Group

If you delete the Resource Group, everything inside it gets deleted.

Think of it like deleting an entire CloudFormation stack — but it works for everything.

This makes environment management very clean.

In AWS, if you forget to tag something, it can live forever.
In Azure, grouping is enforced.

This is a big design philosophy difference.

---

# Identity in Azure vs AWS

![Image](https://learn.microsoft.com/en-us/entra/fundamentals/media/entra-admin-center/entra-admin-center-home.png)

![Image](https://learn.microsoft.com/en-us/azure/role-based-access-control/media/overview/rbac-overview.png)

![Image](https://d2908q01vomqb2.cloudfront.net/22d200f8670dbdb3e253a90eee5098477c95c23d/2022/06/09/Console-homepage-5.png)

![Image](https://media.amazonwebservices.com/blog/2014/new_iam_console_dash_2.png)

In AWS, identity is handled by:

IAM.

Users, Roles, Policies.

In Azure, identity is handled by:

Microsoft Entra ID

Previously called Azure Active Directory.

Here is the important difference:

In AWS, IAM feels like a service.

In Azure, identity feels like the foundation.

Everything in Azure depends heavily on identity.

---

## Users and Groups

In AWS, you might create IAM users and attach policies.

In Azure, you create Users in Entra ID.

But best practice is similar:

Do not assign permissions directly to users.
Assign permissions to Groups.

Example:

You create a group called Dev-Team.
You assign Contributor role to that group at Resource Group scope.

Now anyone inside that group can manage that Resource Group.

This is identical in logic to AWS IAM groups.

---

## RBAC in Azure vs IAM in AWS

In AWS, you attach policies to users or roles.

In Azure, you assign Roles at a specific Scope.

Scope can be:

* Subscription
* Resource Group
* Resource

Let’s compare:

In AWS:
You attach policy to IAM role that allows EC2 access.

In Azure:
You assign Contributor role at Resource Group level.

If assigned at Subscription level → affects everything.

If assigned at Resource Group level → affects only that group.

If assigned at Resource level → affects only that resource.

Azure’s RBAC feels simpler but more structured.

---

# Service Principal vs IAM Role

In AWS, when Terraform deploys infrastructure, it assumes an IAM role.

In Azure, Terraform uses a Service Principal.

A Service Principal is simply a non-human identity.

It has:

* Client ID
* Secret or certificate

It is used by:

* Terraform
* Azure DevOps
* GitHub Actions
* Automation scripts

Think:

Service Principal = IAM user for automation.

---

# Managed Identity vs IAM Role on EC2

In AWS, you attach an IAM role to an EC2 instance.

That instance can then access S3 without storing credentials.

In Azure, this concept is called Managed Identity.

When you enable Managed Identity on a VM:

Azure automatically creates identity for that VM.

Then you assign RBAC role to it.

Example:

VM needs to access Storage Account.

You assign “Storage Blob Data Reader” role to VM’s Managed Identity.

No secrets.
No passwords.
No key files.

Exactly like IAM Role on EC2 — but even more integrated.

---

# Networking in Azure vs AWS

![Image](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/_images/v-net.png)

![Image](https://docs.aws.amazon.com/images/vpc/latest/userguide/images/how-it-works.png)

![Image](https://learn.microsoft.com/en-us/azure/virtual-network/media/manage-network-security-group/view-security-rules.png)

![Image](https://learn.microsoft.com/en-us/azure/virtual-network/media/manage-network-security-group/view-security-rule-details.png)

In AWS, networking starts with VPC.

In Azure, networking starts with VNet (Virtual Network).

VPC = VNet.

Both define:

* IP address range
* Subnets
* Routing

Subnets work the same way.

Public and private subnets exist in both.

---

## Security Groups vs NSG

In AWS, you use Security Groups.

In Azure, you use Network Security Groups (NSG).

Both define:

* Inbound rules
* Outbound rules

But Azure adds priority numbers.

Lower number = higher priority.

Example:

Priority 100 → evaluated before 200.

AWS evaluates based on allow rules only.
Azure evaluates based on ordered rules.

Small difference, but important in troubleshooting.

---

# Creating a VM in Azure (Through AWS Lens)

When you create EC2 in AWS, you select:

* VPC
* Subnet
* Security Group
* Key Pair
* IAM Role

When you create VM in Azure, you select:

* Subscription
* Resource Group
* Region
* VNet
* Subnet
* NSG
* Public IP
* Identity

Notice the extra step: Resource Group.

Everything must be placed into that container.

Under the hood, Azure also creates:

* Network Interface
* Disk
* Public IP resource

Each of those is a separate resource inside the Resource Group.

Azure exposes everything as individual resources more clearly than AWS.

---

# What Actually Happens When You Deploy a VM

Let’s think like DevOps engineers.

When you click “Create VM”:

Azure creates:

* Virtual Machine resource
* OS disk
* Network Interface
* Public IP (if selected)
* NSG rules
* Possibly Managed Identity

All are stored as independent resources in the Resource Group.

This makes infrastructure dependency very visible.

In AWS, some of these feel more bundled.

In Azure, everything is a resource.


