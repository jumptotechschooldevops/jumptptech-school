---
title: "How to Create and Log Into Microsoft Azure"
description: "This guide will help you:   Create an Azure account Activate your free subscription Log in to the..."
published: 2026-03-01
source: "https://dev.to/jumptotech/how-to-create-and-log-into-microsoft-azure-3239"
tags: []
---

# How to Create and Log Into Microsoft Azure







This guide will help you:

1. Create an Azure account
2. Activate your free subscription
3. Log in to the Azure Portal
4. Log in using Azure CLI
5. Verify everything works

If you already know AWS, think of this as:

Create AWS account → Login to Console → Configure AWS CLI.

---

# 1. What Is Azure?

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Microsoft_Azure_Logo.svg/1280px-Microsoft_Azure_Logo.svg.png)

![Image](https://learn.microsoft.com/en-us/azure/azure-portal/media/azure-portal-dashboards/portal-menu-dashboard.png)

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/media/check-free-service-usage/free-account-subscription-page.png)

![Image](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/media/create-free-services/billing-freeservices-grid.png)

Microsoft Azure is Microsoft’s cloud computing platform.

Just like:

Amazon Web Services AWS provides cloud services, Azure provides cloud services.

You do NOT install Azure on your computer.
Azure runs in Microsoft’s data centers.

What you install locally is:

* Azure CLI (optional, for command line usage)

---

# 2. Create an Azure Account (Free Trial)

## Step 1 – Open Azure Website

Go to:

[https://azure.microsoft.com/free](https://azure.microsoft.com/free)

Click:

**Start free**

---

## Step 2 – Sign In or Create Microsoft Account

If you do not have a Microsoft account:

Click **Create one**

Use:

* Gmail
* Outlook
* Any valid email

Create password and verify email.

---

## Step 3 – Activate Free Trial

Azure will ask for:

* Phone number (verification)
* Credit card (for identity verification only)
* Basic personal information

Important:
You will receive:

* $200 free credit (30 days)
* 12 months of limited free services

Azure will NOT charge you automatically unless you upgrade.

---

# 3. Understanding Tenant vs Subscription (Very Important)

Azure has two separate layers:

Tenant → Identity layer (Microsoft Entra ID)
Subscription → Billing and resources layer

In AWS:
These are combined into one account.

In Azure:
You can log in but still have NO subscription.

If CLI says:
“No subscriptions found”

It means:
You logged in successfully but did not activate Free Trial.

---

# 4. Log In to Azure Portal (Browser Method)

After activating free trial:

Go to:

[https://portal.azure.com](https://portal.azure.com)

Sign in with your Microsoft account.

You should see:

* Azure Dashboard
* Your subscription name
* Available services

---

## Verify Subscription in Portal

In search bar, type:

**Subscriptions**

Click it.

You should see something like:

Azure subscription 1
Status: Enabled

If you do not see a subscription:
You did not complete free trial activation.

---

# 5. Install Azure CLI (Mac Students)

Azure CLI allows managing Azure from terminal.

If you use Mac:

Open Terminal and run:

```bash
brew update
brew install azure-cli
```

Verify installation:

```bash
az version
```

If version appears → installed correctly.

Equivalent in AWS:

```bash
aws --version
```

---

# 6. Log In Using Azure CLI

In terminal, run:

```bash
az login
```

This will:

* Open browser automatically
* Ask you to sign in
* Connect CLI to your Azure account

After login, Azure CLI may ask:

Select a subscription and tenant (Type a number or Enter for no changes)

If your subscription has a `*` next to it, simply press:

Enter

---

## Verify CLI Is Connected

Run:

```bash
az account show --output table
```

You should see:

* Subscription name
* Subscription ID
* Tenant ID
* State: Enabled

If you see “Enabled”, your environment is ready.

---

# 7. Confirm You Have Access

Run:

```bash
az group list --output table
```

If no error appears, CLI is working.

---

# 8. Common Errors and Solutions

### Error:

No subscriptions found

Solution:
Go back to [https://azure.microsoft.com/free](https://azure.microsoft.com/free)
Activate free trial.

---

### Error:

Login opens browser but nothing happens

Try device login:

```bash
az login --use-device-code
```

Follow instructions in terminal.

---

### Error:

Subscription not selected

Run:

```bash
az account list --output table
az account set --subscription "Azure subscription 1"
```

---

# 9. What You Should Have After This Setup

By the end of this guide you must have:

✔ Azure account created
✔ Free Trial activated
✔ Azure Portal accessible
✔ Azure CLI installed
✔ CLI login successful
✔ Active subscription visible

If any of these fail, fix it before moving to next lecture.

---

# 10. Comparison with AWS Setup

AWS Setup:

1. Create AWS account
2. Login to console
3. Configure AWS CLI

Azure Setup:

1. Create Microsoft account
2. Activate Free Trial (Subscription)
3. Login to portal
4. Install Azure CLI
5. Run az login

The difference:
Azure separates identity and subscription.

---

# Important Reminder

Azure charges for running resources.

After each lab, you must delete resources.

Later in the course, you will learn how to delete everything safely using Resource Groups.

---

End of Setup Guide.


