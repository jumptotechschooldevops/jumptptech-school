---
title: "IAM in AWS"
description: "🧩 AWS IAM (Identity and Access Management)            1. What Is IAM?   IAM stands for..."
published: 2025-10-06
source: "https://dev.to/jumptotech/iam-in-aws-4bf3"
tags: []
---

# IAM in AWS



# 🧩 AWS IAM (Identity and Access Management)

## 1. What Is IAM?

**IAM** stands for **Identity and Access Management**.
It’s a **global AWS service** that helps you securely control access to your AWS resources.

You use IAM to:

* Create and manage **users**, **groups**, and **permissions**.
* Control **who** can access AWS resources and **what** actions they can perform.

---

## 2. The Root User

When you first create your AWS account, AWS automatically creates a **root user** — the account owner.
Use it **only once** to:

* Set up billing
* Enable MFA (Multi-Factor Authentication)
* Create your **admin user**

After setup:

> ❌ Do not use or share the root account again.

---

## 3. Users and Groups

Each **user** represents a real person or application.
You can group users logically — for example:

| Group Name | Members             | Purpose        |
| ---------- | ------------------- | -------------- |
| Developers | Alice, Bob, Charles | Build & deploy |
| Operations | David, Edward       | Manage infra   |
| Audit Team | Charles, David      | Review access  |

**Notes:**

* Groups contain **only users** (no nested groups).
* Users can belong to **multiple groups**.
* Some users can exist **without a group**, though not best practice.

---

## 4. IAM Policies (Permissions)

To control what users can do, IAM uses **policies** — JSON documents that define **permissions**.

Example policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:Describe*",
        "cloudwatch:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```

This policy allows access to:

* **EC2** (describe instances)
* **Elastic Load Balancing**
* **CloudWatch**

---

## 5. Principle of Least Privilege

Always follow the **Least Privilege Principle**:

> Give each user **only the permissions** they need to perform their job — nothing more.

This reduces:

* **Security risks**
* **Unnecessary costs**

---

## 6. Summary

| Concept         | Description                                    |
| --------------- | ---------------------------------------------- |
| IAM             | Global service to manage identities and access |
| Root User       | Full access; use only for initial setup        |
| Users           | Represent people or apps                       |
| Groups          | Logical collections of users                   |
| Policies        | JSON permissions attached to users/groups      |
| Least Privilege | Give minimal access required                   |









# 🧩 **AWS IAM Hands-On: Creating Users and Groups**

## 🎯 Goal

You’ll create a new **IAM user** and **admin group** in AWS — instead of using the **root account**, which is unsafe for daily operations.

---

## 🪪 Step 1: Open the IAM Console

1. Sign in to your **AWS Management Console** using your **root account** (only for setup).
2. In the **search bar**, type **IAM**, then open **IAM**.

👉 You’ll land on the **IAM Dashboard**.

Notice:

* There’s **no region selector** (top-right corner).
  **IAM is a global service.**

---

## 👥 Step 2: Go to Users

1. On the left-hand menu → click **Users**.
2. Then click **“Create user.”**

---

## 🧍 Step 3: Add a User

1. **User name:** `stephane` (you can use your own name).
2. Select **“Provide user access to the AWS Management Console.”**

Then choose:

* **IAM user** (not Identity Center – simpler for now).
* Set a password:

  * Choose **Custom password**.
  * Uncheck “User must create a new password at next sign-in” if this is your own test user.

Click **Next**.

---

## 🧩 Step 4: Add Permissions (Create a Group)

1. Choose **“Add user to group.”**
2. Click **Create group.**
3. **Group name:** `admin`
4. Search for and attach the **AdministratorAccess** policy.
5. Create the group.

✅ Now your user `stephane` will belong to the **admin** group.

Click **Next**.

---

## 🏷️ Step 5: Add Tags (Optional)

Tags help you organize and track resources. Example:

| Key        | Value       |
| ---------- | ----------- |
| Department | Engineering |

Click **Next** → Review the configuration → **Create user**.

---

## 📄 Step 6: Save the Credentials

After creation, you’ll see:

* A link to **download a `.csv` file** with the credentials.
* Or **email sign-in instructions** to your user.

Save these securely.

---

## 🧑‍💻 Step 7: Verify the User and Group

* Go to **Users → stephane** → check **Permissions** tab.
  You’ll see **AdministratorAccess (inherited from group admin)**.

* Go to **User groups → admin** → check **Permissions** tab.
  You’ll see the **AdministratorAccess** policy.

✅ This confirms that `stephane` inherits permissions from the `admin` group.

---

## 🌐 Step 8: Create an Account Alias

To make login easier:

1. Go to **IAM Dashboard** → **Account alias** → Create alias.
   Example: `aws-stephane-v5`
2. The new **sign-in URL** will be:

   ```
   https://aws-stephane-v5.signin.aws.amazon.com/console
   ```

---

## 🔐 Step 9: Sign in as IAM User

1. Open a **private/incognito window** in your browser.
2. Paste the sign-in URL.
3. Choose **IAM user**.
4. Enter:

   * **Account alias** or **Account ID**
   * **Username:** `stephane`
   * **Password:** the one you set

You are now logged in as **IAM user stephane**.

In the top-right corner, you’ll see:

* `IAM user: stephane`
* Your **Account ID**

---

## ⚠️ Step 10: Keep Both Accounts Safe

| Account              | Usage                              |
| -------------------- | ---------------------------------- |
| **Root User**        | Only for initial setup and billing |
| **IAM User (Admin)** | For all daily AWS operations       |

> ❗ If you lose both credentials, only AWS Support can recover your account — so store them safely.

---

## ✅ Summary

| Concept   | Description                                        |
| --------- | -------------------------------------------------- |
| IAM       | Global service for managing users & permissions    |
| Root User | Full access — use only for setup                   |
| IAM User  | Individual identity for people or apps             |
| Groups    | Logical containers for users (simplify management) |
| Policies  | JSON documents defining permissions                |
| Alias     | Custom URL for easier login                        |







# 🧩 **AWS IAM Practice Lab — Creating a User and Group**

## 🎯 Goal

In this lab, you’ll learn how to:

* Create an **IAM user**
* Create an **admin group**
* Assign permissions through a **policy**
* Log in as the new user using a **custom sign-in URL**

---

## 🔹 Step 1 – Open the IAM Console

1. Sign in to AWS with your **root account**.
2. In the AWS search bar, type **IAM** → click **IAM**.
3. You’ll see the **IAM Dashboard**.

   * Some **security recommendations** appear — ignore for now.
   * Notice in the top-right corner: there’s **no Region selector**.

     > ✅ IAM is a **global service**, not tied to any region.

---

## 🔹 Step 2 – Check Current User

1. Look at the top-right corner of the console.
2. If it shows only the **account ID**, you’re signed in as the **root user**.

   > ⚠️ The root account has *unlimited power* and should be used **only for setup**.

We’ll now create an **admin IAM user** to use instead.

---

## 🔹 Step 3 – Create a New IAM User

1. In the left menu, click **Users → Create user**.
2. **User name:** `stephane` (or your own name).
3. Under **Console access**, select:

   * ✅ “Provide user access to the AWS Management Console”
   * Choose **IAM user** (not Identity Center – simpler for now).
4. Set a password:

   * Option A – Auto-generate (for other people)
   * Option B – Custom password (enter your own)
   * Uncheck “User must create a new password at next sign-in” if it’s your test account.
5. Click **Next**.

---

## 🔹 Step 4 – Create an Admin Group

1. Choose **Add user to group → Create group**.
2. **Group name:** `admin`
3. Search and attach the **AdministratorAccess** policy.
4. Click **Create group**.
5. Ensure your user (`stephane`) is added to that group.
6. Click **Next**.

---

## 🔹 Step 5 – Add Optional Tags

Tags add metadata for organization (optional).
Example:

| Key        | Value       |
| ---------- | ----------- |
| Department | Engineering |

Click **Next → Create user**.

---

## 🔹 Step 6 – Save the Credentials

* Download the **.csv file** (contains user credentials).
* Or **email the sign-in instructions**.
  Keep these safe — you’ll need them for login.

---

## 🔹 Step 7 – Verify User and Group

1. Go to **Users → stephane → Permissions**
   → You’ll see *AdministratorAccess (inherited from admin group)*.
2. Go to **User groups → admin → Permissions**
   → Confirms **AdministratorAccess** attached.

✅ The user inherits the group’s permissions.

---

## 🔹 Step 8 – Create an Account Alias

A custom alias makes sign-in easier.

1. On the IAM Dashboard → **Account alias → Create alias**
   Example: `aws-stephane-v5`
2. Now your console URL becomes:

   ```
   https://aws-stephane-v5.signin.aws.amazon.com/console
   ```

---

## 🔹 Step 9 – Sign In as IAM User

1. Open a **private/incognito window**.
2. Visit your sign-in URL.
3. Choose **IAM user**.
4. Enter:

   * **Account alias** or **Account ID**
   * **User name:** `stephane`
   * **Password:** the one you set.
5. Click **Sign In**.

Now, at the top-right corner you’ll see:
`Account ID | IAM user: stephane`

You can keep:

* **Root account** in one browser window (normal mode)
* **IAM user** in another (private mode)
  to work with both simultaneously.

---

## 🔹 Step 10 – Best Practices

| Account            | When to Use                      | Notes                             |
| ------------------ | -------------------------------- | --------------------------------- |
| **Root User**      | Only for billing & initial setup | Enable MFA, keep credentials safe |
| **IAM Admin User** | Everyday management              | Add more users and policies here  |

> ⚠️ Losing both the root and admin credentials requires AWS Support recovery.

---

## ✅ Summary

| Concept           | Description                                         |
| ----------------- | --------------------------------------------------- |
| **IAM**           | Global service to manage identities and permissions |
| **Root User**     | Highest-privilege account, use sparingly            |
| **IAM User**      | Individual identity for people or apps              |
| **Groups**        | Simplify permission management                      |
| **Policies**      | JSON rules that define allowed actions              |
| **Account Alias** | Friendly URL for sign-in                            |









# 🧩 **AWS Multi-Session Support (Multiple Accounts in One Browser)**

## 🎯 Goal

Learn how to use **multi-session support** in the AWS Console — a new feature that lets you stay signed in to **multiple AWS accounts or roles simultaneously** in the **same browser**.

---

## 🔹 Step 1 – Enable Multi-Session Support

1. In the AWS Management Console, look at the **top-right corner** of your screen.
2. Click on your **account name or ID**.
3. Select **Multi-Session Support → Turn on**.

> ✅ This allows you to manage **separate sessions** within one browser tab group.

---

## 🔹 Step 2 – Add a New Session

1. Click **Add session**.
2. You’ll be asked to **sign in again** — using:

   * Another **account ID**, **alias**, or **role**, and
   * The corresponding **IAM user credentials**.
3. Once logged in, AWS opens a **second session** within the same browser.

Now, at the top of your screen you’ll notice each session clearly labeled with a **different account ID or role name**.

---

## 🔹 Step 3 – Verify the Sessions

To confirm you’re truly using separate accounts:

1. In **Session 1**, open the **EC2 → Volumes** page.
2. Create a quick **EBS volume (1 GiB)** just for testing.

   > You don’t need to know EBS yet — this is just a proof of concept.
3. In **Session 2**, open **EC2 → Volumes** again.

   * You’ll see **no volumes listed**, because this is a **different account**.

✅ Result: Both sessions are independent — same browser, different accounts.

---

## 🔹 Step 4 – Why It’s Useful

Before multi-session support, engineers had to:

* Use **different browsers** (Chrome + Firefox + Safari), or
* Use **private/incognito windows** for each AWS account.

Now you can:

* Quickly **switch between accounts or roles**,
* Manage **dev / staging / prod** environments from one browser,
* Avoid repeated log-ins and MFA prompts.

> 💡 This is especially helpful for **DevOps engineers** or **admins** who manage multiple AWS environments or customer accounts.

---

## ✅ Summary

| Feature                   | Description                                              |
| ------------------------- | -------------------------------------------------------- |
| **Multi-Session Support** | Lets you open multiple AWS accounts/roles in one browser |
| **Enabled From**          | Account Menu → Multi-Session Support                     |
| **Use Case**              | Manage several AWS environments side-by-side             |
| **Old Method**            | Separate browsers / incognito windows                    |
| **Now**                   | Tabs or sessions in one browser with clear labels        |












# 🧩 **AWS IAM Policies — In Depth**

## 🎯 Goal

Understand how IAM **policies** work — how they are structured, attached, and evaluated across **users**, **groups**, and **roles**.

---

## 👥 Step 1 – How Policies Are Applied

Let’s start with an example organization:

| Group          | Members             | Description                 |
| -------------- | ------------------- | --------------------------- |
| **Developers** | Alice, Bob, Charles | Have developer-level access |
| **Operations** | David, Edward       | Manage infrastructure       |
| **Audit Team** | Charles, David      | Read-only audit access      |

Now:

* If you attach a **policy** to the **Developers group**,
  → **Alice**, **Bob**, and **Charles** all inherit that policy.
* The **Operations group** will have its own separate policy.
* A user like **Fred** may exist **without a group**,
  → but can still have permissions using an **inline policy**.

> 🔹 **Inline policy:** A policy attached *directly to one user* (not reusable).
> 🔹 **Managed policy:** A reusable policy you can attach to multiple users/groups.

### Example of Policy Inheritance

| User    | Gets Policy From              |
| ------- | ----------------------------- |
| Charles | Developers + Audit            |
| David   | Operations + Audit            |
| Fred    | Inline Policy only (optional) |

✅ This is how AWS permissions layer together.

---

## 🧩 Step 2 – IAM Policy Structure (JSON)

Every IAM policy is a **JSON document** that follows a standard format.
Here’s an example:

```json
{
  "Version": "2012-10-17",
  "Id": "PolicyExample1",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789012:root" },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-example-bucket"
    }
  ]
}
```

Let’s break it down 👇

| Key           | Meaning                                                     | Example                                                             |
| ------------- | ----------------------------------------------------------- | ------------------------------------------------------------------- |
| **Version**   | Defines the policy language version (always `"2012-10-17"`) | `"Version": "2012-10-17"`                                           |
| **Id**        | Optional identifier for the policy                          | `"Id": "PolicyExample1"`                                            |
| **Statement** | Main policy rules — one or more blocks                      | `[ {...} ]`                                                         |
| **Sid**       | Optional statement ID (for reference)                       | `"Sid": "1"`                                                        |
| **Effect**    | `"Allow"` or `"Deny"` the actions listed                    | `"Effect": "Allow"`                                                 |
| **Principal** | Who this policy applies to (user, account, or role)         | `"Principal": {"AWS": "arn:aws:iam::123456789012:root"}`            |
| **Action**    | The API actions being allowed or denied                     | `"Action": "s3:ListBucket"`                                         |
| **Resource**  | The resources these actions apply to                        | `"Resource": "arn:aws:s3:::my-example-bucket"`                      |
| **Condition** | *(Optional)* Adds logic for when to apply                   | e.g., `"Condition": {"Bool": {"aws:MultiFactorAuthPresent": true}}` |

---

## 🧠 Step 3 – The Most Important Four

For the **AWS Certified Solutions Architect** or **DevOps Engineer** exams,
you must clearly understand these 4 key fields:

| Element       | Description                                           |
| ------------- | ----------------------------------------------------- |
| **Effect**    | Whether access is **allowed** or **denied**           |
| **Principal** | The **identity** the policy applies to                |
| **Action**    | The specific **AWS API calls** allowed or denied      |
| **Resource**  | The specific **AWS resources** those actions apply to |

> 💡 AWS always evaluates policies by combining **explicit denies** and **allows**:
>
> * Explicit **deny** always wins.
> * Explicit **allow** grants permission if no deny exists.

---

## 🧩 Step 4 – Optional Elements

* **Condition:** Controls *when* a policy applies.
  Example: Allow access only if MFA is enabled or if access is from a specific IP.
* **Sid (Statement ID):** Label for identifying specific rules in a policy.

---

## ✅ Summary

| Concept               | Description                           |
| --------------------- | ------------------------------------- |
| **IAM Policy**        | JSON document defining permissions    |
| **Group Policy**      | Shared by all users in a group        |
| **Inline Policy**     | Attached to one user only             |
| **Managed Policy**    | Reusable policy managed by AWS or you |
| **Main Elements**     | Effect, Principal, Action, Resource   |
| **Optional Elements** | Condition, Sid                        |
| **Best Practice**     | Apply the *Least Privilege Principle* |

---








# 🧩 **AWS IAM Policies — Hands-On Lab**

## 🎯 Goal

In this lab, you will:

* Explore **how policies affect user permissions**
* Understand **policy inheritance** (from groups vs direct attachment)
* Create and test a **custom IAM policy**
* Verify **AdministratorAccess** and **ReadOnlyAccess** behaviors

---

## 🔹 Step 1 – Check Current User Permissions

1. Go to **IAM → Users**.
2. You’ll see the user **Stephane** — currently in the **admin group**.

   * The **admin group** has the **AdministratorAccess** policy.
   * So `Stephane` can do **anything** in AWS.

✅ As the **Stephane IAM user**, open **IAM Console → Users** — you’ll see your own user listed.

---

## 🔹 Step 2 – Remove the User from the Admin Group

1. From the **root account or another admin**, go to
   **IAM → User groups → admin → Users tab**.
2. **Remove** `Stephane` from this group.

Now refresh the **IAM → Users** page while logged in as Stephane.

> ❗ You’ll see:
> **“Access Denied: iam:ListUsers”**
> → Because Stephane no longer has permission to view users.

This demonstrates that **removing a user from a group immediately revokes its policies**.

---

## 🔹 Step 3 – Attach a Read-Only Policy

1. As an admin, open **IAM → Users → Stephane → Add permissions**.
2. Choose **Attach policies directly**.
3. Search for **IAMReadOnlyAccess** → **Add permission**.

Now, refresh the Stephane user’s IAM console.

✅ Stephane can **view** users, groups, and policies again.
❌ But cannot **create** or **modify** anything.

Try:

* **Create group → “developers”**
  → You’ll see *Access denied*.
  → This is exactly what **read-only** means.

---

## 🔹 Step 4 – Add the User to a New Group

Let’s test multiple policy sources.

1. Go to **IAM → User groups → Create group**

   * **Name:** `developers`
   * **Add user:** Stephane
   * **Attach any sample policy** (e.g., `AlexaForBusinessFullAccess`)
   * **Create group**

2. Go back to **admin group → Add user → Stephane**.

Now Stephane belongs to:

* `admin` (AdministratorAccess)
* `developers` (AlexaForBusiness)
* plus a directly attached policy (IAMReadOnlyAccess)

---

## 🔹 Step 5 – View Policy Inheritance

Go to **IAM → Users → Stephane → Permissions tab**

You’ll see:

1. **AdministratorAccess** (inherited from *admin* group)
2. **AlexaForBusinessFullAccess** (from *developers* group)
3. **IAMReadOnlyAccess** (attached directly)

✅ This shows how IAM merges permissions from **all attached sources**.

---

## 🔹 Step 6 – Inspect Built-in Policies

### a) AdministratorAccess

* Click on **Policies → AdministratorAccess → JSON tab**

```json
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}
```

⭐ `*` means **all actions** on **all resources** — full admin rights.

### b) IAMReadOnlyAccess

* Go to **Policies → IAMReadOnlyAccess → JSON**
* You’ll see:

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:Get*",
    "iam:List*"
  ],
  "Resource": "*"
}
```

⭐ `Get*` = any API starting with *Get*
⭐ `List*` = any API starting with *List*
→ Read-only access to IAM resources.

---

## 🔹 Step 7 – Create a Custom Policy

Let’s build one manually.

1. **IAM → Policies → Create policy**
2. Choose **Visual editor**
3. **Service:** IAM
4. **Actions:**

   * `ListUsers`
   * `GetUser`
5. **Resources:** All resources (`*`)
6. **Review → Name:** `MyIAMPermissions`
   → **Create policy**

Now open the **JSON** tab of your new policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:GetUser"
      ],
      "Resource": "*"
    }
  ]
}
```

✅ You just created a **custom IAM policy** that allows only two specific actions.

---

## 🔹 Step 8 – Clean Up

1. Delete the **developers** group.
2. Remove the **IAMReadOnlyAccess** policy directly from `Stephane`.
3. Keep `Stephane` only in the **admin** group (AdministratorAccess).

Refresh → all permissions restored. ✅

---

## ✅ Summary

| Concept                       | Description                                 |
| ----------------------------- | ------------------------------------------- |
| **Group Policies**            | Shared permissions for all users in a group |
| **Inline Policies**           | Attached directly to one user               |
| **Managed Policies**          | AWS-created or reusable policies            |
| **AdministratorAccess**       | `Action: *`, `Resource: *` → Full control   |
| **IAMReadOnlyAccess**         | Only `Get*` and `List*` actions             |
| **Custom Policy**             | Define your own actions & resources         |
| **Least Privilege Principle** | Always give minimal required permissions    |













# 🧩 **AWS IAM Password Policy & Multi-Factor Authentication (MFA)**

## 🎯 Goal

Learn how to:

* Enforce **strong password policies** for IAM users
* Understand and configure **Multi-Factor Authentication (MFA)**
* Recognize different types of MFA devices supported by AWS

---

## 🔹 Step 1 – IAM Password Policy

AWS lets you define a **password policy** for all IAM users.
This ensures passwords are **strong**, **regularly updated**, and **hard to guess**.

### 🔧 You can enforce:

1. **Minimum password length** (e.g., 8–12 characters)
2. **Character types**:

   * Uppercase letters
   * Lowercase letters
   * Numbers
   * Non-alphanumeric characters (e.g., `!@#$%`)
3. **Password expiration**:

   * Example: users must change their password **every 90 days**
4. **Password reuse prevention**:

   * Users cannot reuse previous passwords
5. **Allow or disallow password changes**:

   * Admins can restrict users from changing their own passwords

### 🛡️ Why it matters

A strong password policy protects your AWS environment from **brute-force attacks** and **unauthorized access**.

---

## 🔹 Step 2 – Multi-Factor Authentication (MFA)

Even strong passwords are not enough —
that’s where **Multi-Factor Authentication (MFA)** comes in.

### 🔐 What is MFA?

MFA adds a **second layer of security**:

* Something you **know** → your **password**
* Something you **have** → your **security device**

✅ Users must provide **both** to log in.

Example:

> Alice knows her password and has an MFA token on her phone.
> Even if her password is stolen, the hacker cannot log in without the device.

---

## 🔹 Step 3 – MFA Benefits

| Risk               | Without MFA         | With MFA             |
| ------------------ | ------------------- | -------------------- |
| Password stolen    | Account compromised | Still secure         |
| Shared workstation | Others can log in   | Protected            |
| Remote access      | High risk           | MFA required         |
| Compliance         | Weak security       | Meets best practices |

---

## 🔹 Step 4 – Types of MFA Devices in AWS

AWS supports several MFA device types. You **must know these for the exam**.

| Type                              | Description                               | Example                         |
| --------------------------------- | ----------------------------------------- | ------------------------------- |
| **Virtual MFA Device**            | App-based MFA using your smartphone       | *Google Authenticator*, *Authy* |
| **U2F Security Key**              | Physical USB security key                 | *YubiKey by Yubico*             |
| **Hardware Key Fob (Gemalto)**    | Physical device that generates codes      | Provided by *Gemalto*           |
| **GovCloud Key Fob (SurePassID)** | Specialized device for AWS GovCloud users | *SurePassID* hardware token     |

---

## 🔹 Step 5 – Virtual MFA (Most Common)

### 📱 Virtual MFA Device Examples

* **Google Authenticator** (one account per device)
* **Authy** (multiple accounts on a single device)

### 💡 Why Virtual MFA is Best

* Free and easy to set up
* Supports multiple users or accounts
* Works across all AWS account types (root & IAM)

---

## 🔹 Step 6 – Physical Security Key (U2F)

If you prefer hardware:

* Use a **U2F Security Key** (e.g., YubiKey)
* Plug it into your computer’s USB port when logging in
* Can be shared across **multiple AWS users or accounts**

This is ideal for **admins** managing multiple environments.

---

## 🔹 Step 7 – Government-Grade MFA

If your AWS account is part of **AWS GovCloud (U.S.)**,
you must use an **approved hardware MFA token** (e.g., SurePassID).

---

## ✅ Summary

| Concept                               | Description                                                                       |
| ------------------------------------- | --------------------------------------------------------------------------------- |
| **Password Policy**                   | Enforces strong password rules (length, characters, expiration, reuse prevention) |
| **MFA (Multi-Factor Authentication)** | Adds an extra verification layer beyond passwords                                 |
| **Virtual MFA**                       | App-based (Google Authenticator, Authy)                                           |
| **Physical MFA**                      | Hardware key fob (Gemalto, YubiKey)                                               |
| **Best Practice**                     | Enable MFA for **root** and **all IAM users**                                     |
| **Exam Tip**                          | Memorize the 4 MFA device types (Virtual, U2F, Gemalto, SurePassID)               |









# 🧩 **AWS IAM Hands-On: Password Policy & MFA Setup**

## 🎯 Goal

In this lab, you’ll:

1. Define a strong **password policy** for all IAM users
2. Enable **Multi-Factor Authentication (MFA)** for the **root user**
3. Understand how to use an **authenticator app** to secure your AWS account

---

## 🔹 Step 1 – Set a Password Policy

1. In the AWS Console, open **IAM**.
2. On the **left menu**, click **Account settings**.
3. Under **Password policy**, click **Edit**.

You can:

* ✅ Use the **default IAM policy**, or
* 🔧 **Customize** it yourself.

### Recommended settings

| Setting                            | Example / Description |
| ---------------------------------- | --------------------- |
| Minimum length                     | 8 – 12 characters     |
| Require uppercase                  | `A–Z`                 |
| Require lowercase                  | `a–z`                 |
| Require numbers                    | `0–9`                 |
| Require non-alphanumeric           | `!@#$%`               |
| Expire passwords                   | Every 90 days         |
| Prevent password reuse             | Yes                   |
| Allow users to change own password | Yes                   |

💡 *This helps protect against brute-force and dictionary attacks.*

Click **Save changes** when done.

---

## 🔹 Step 2 – Enable MFA for the Root Account

1. In the **top-right corner**, click your **account name** → choose **Security credentials**.
2. You’ll see: **“My security credentials (root user)”**.
3. Scroll to **Multi-factor authentication (MFA)** → click **Activate MFA**.

---

## 🔹 Step 3 – Select MFA Device Type

AWS offers several device types:

| Type                                | Example                                           | Use Case                       |
| ----------------------------------- | ------------------------------------------------- | ------------------------------ |
| **Authenticator app (Virtual MFA)** | Google Authenticator, Authy, Twilio Authenticator | Most common, free              |
| **Security key (U2F)**              | YubiKey USB key                                   | Hardware-based, very secure    |
| **Hardware TOTP token**             | Gemalto key fob                                   | Physical token for enterprises |

For this demo, select **Authenticator App** (virtual MFA).

---

## 🔹 Step 4 – Set Up the Authenticator App

1. Open your authenticator app (e.g., **Authy** or **Google Authenticator**).
2. Click **Show QR code** in AWS.
3. In your app, tap **Add account → Scan QR code**.
4. The app now displays a **6-digit code** that changes every 30 seconds.

---

## 🔹 Step 5 – Verify the MFA Setup

1. AWS will ask for **two consecutive codes** from your app:

   * Example:

     * First code → `301935`
     * Second code → `792843`
       *(Your codes will differ.)*
2. Enter both codes and click **Add MFA**.

✅ You’ll see the device listed, for example:
**MFA device:** `my iPhone`
You can register up to **8 MFA devices** per account.

---

## 🔹 Step 6 – Test the MFA Login

1. **Sign out** of AWS.
2. **Sign back in** with your **root email + password**.
3. You’ll now be prompted for your **MFA code**.
4. Open your authenticator app → enter the current 6-digit code → **Submit**.

✅ Login succeeds → MFA is working!

---

## ⚠️ Important Notes

* 🔒 Never lose access to your MFA device — you’ll need AWS Support to recover the account.
* 📱 If you replace your phone, **disable MFA first**, then re-enable it on the new device.
* 🧩 You can remove or replace MFA devices any time from the same Security Credentials page.

---

## ✅ Summary

| Concept                     | Description                                      |
| --------------------------- | ------------------------------------------------ |
| **Password Policy**         | Enforces strong passwords and expiration rules   |
| **MFA (Multi-Factor Auth)** | Adds a second layer of security                  |
| **Virtual MFA**             | App-based (Authy / Google Authenticator)         |
| **Physical MFA**            | Hardware key (YubiKey / Gemalto)                 |
| **Best Practice**           | Enable MFA for root and all admin users          |
| **Exam Tip**                | Know the different MFA types and their use cases |






# 🧩 **Accessing AWS: Console, CLI, and SDK**

## 🎯 Goal

Understand the **three main ways** to access and manage AWS resources:

* **AWS Management Console** (Web UI)
* **AWS CLI (Command Line Interface)**
* **AWS SDK (Software Development Kit)**

---

## 🔹 Step 1 – AWS Management Console (Web Interface)

The **AWS Management Console** is the web interface you’ve been using so far.

**How it works:**

* Accessed through your browser at [https://aws.amazon.com/console](https://aws.amazon.com/console)
* Protected by your **username**, **password**, and optionally **Multi-Factor Authentication (MFA)**
* Easiest option for beginners — graphical and intuitive

**Best for:**

* Visual learners
* Beginners exploring AWS
* Manual configurations and demonstrations

---

## 🔹 Step 2 – AWS CLI (Command Line Interface)

The **CLI (Command Line Interface)** allows you to interact with AWS directly from your terminal or command prompt.

### 🧠 What It Is

A tool that lets you **run commands** to manage AWS resources.
Every command starts with the word `aws`.

Example:

```bash
aws s3 ls
aws ec2 describe-instances
aws iam list-users
```

### 🔒 Authentication

The CLI uses **access keys**:

* **Access Key ID** → like your username
* **Secret Access Key** → like your password

You’ll generate these keys from the **Management Console**, under your IAM user settings.

> ⚠️ **Important:**
>
> * Never share your access keys.
> * Store them securely (they provide full programmatic access to AWS).
> * Each IAM user should have **their own** access keys.

Once created, you can download them **once** in `.csv` format.

You’ll configure them on your system using:

```bash
aws configure
```

and provide:

```
AWS Access Key ID: ***************
AWS Secret Access Key: ***************
Default region name: us-east-1
Default output format: json
```

After setup, you can use the CLI to automate deployments, run scripts, and manage services faster.

### 💡 Why Use the CLI?

* Automate repetitive tasks
* Manage infrastructure without using the web UI
* Integrate AWS commands into scripts (e.g., Bash, PowerShell)

---

## 🔹 Step 3 – AWS SDK (Software Development Kit)

The **SDK** is used by **developers** to call AWS services directly from within application code.

### ⚙️ What It Does

It provides **programming libraries** to integrate AWS services into your applications — the same APIs used by the console and CLI.

**Supported languages:**

* Python (`boto3`)
* JavaScript / Node.js
* Java
* Go
* C++
* .NET
* PHP
* Ruby

There are also **Mobile SDKs** (for Android/iOS) and **IoT SDKs** (for connected devices).

### Example

The AWS CLI itself is **built on the AWS SDK for Python**, called **Boto3**.

So when you use a command like:

```bash
aws s3 cp file.txt s3://mybucket/
```

you’re indirectly using the **AWS SDK for Python** behind the scenes.

---

## 🔹 Summary

| Access Method                      | Interface        | Authentication             | Use Case                      |
| ---------------------------------- | ---------------- | -------------------------- | ----------------------------- |
| **Management Console**             | Web UI           | Username + Password + MFA  | Visual management, beginners  |
| **CLI (Command Line Interface)**   | Terminal         | Access Key ID + Secret Key | Automation, scripting, DevOps |
| **SDK (Software Development Kit)** | Application Code | Access Keys                | Programmatic AWS integration  |

---

## ⚠️ Security Reminder

| Rule                          | Reason                                     |
| ----------------------------- | ------------------------------------------ |
| Never share access keys       | Equivalent to giving away full AWS control |
| Rotate keys regularly         | Reduces risk of compromise                 |
| Use IAM roles for apps        | Avoid hardcoding credentials               |
| Protect root account with MFA | Prevent unauthorized access                |

---

## ✅ Key Takeaways

* AWS can be accessed via **Console**, **CLI**, or **SDK**.
* **CLI** is ideal for automation.
* **SDK** is for integrating AWS into your applications.
* Always follow **least privilege** and **MFA** best practices.











# 🧩 **Installing AWS CLI (Version 2) on Windows**

## 🎯 Goal

Learn how to **download, install, and verify** the AWS Command Line Interface (CLI) on a Windows machine.

---

## 🔹 Step 1 – Search for the Installer

1. Open your browser and search for:
   **`aws cli install windows`**
2. Click the official AWS link:
   [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Find the section **“Install the AWS CLI version 2 on Windows.”**

---

## 🔹 Step 2 – Download the MSI Installer

* Scroll to **“Install or update the AWS CLI version 2 on Windows”**
* Click the **MSI installer** download link:

  ```
  https://awscli.amazonaws.com/AWSCLIV2.msi
  ```
* Once downloaded, open the file to begin installation.

---

## 🔹 Step 3 – Run the Installer

Follow the setup wizard:

1. **Next** → continue
2. **Accept License Agreement** → Next
3. **Install**
4. Confirm Windows security prompts (“Yes”)
5. Wait for installation to complete
6. Click **Finish**

✅ The AWS CLI is now installed.

---

## 🔹 Step 4 – Verify the Installation

1. Open **Command Prompt (cmd)**.

   * Press **Start** → type `cmd` → Enter.
2. Run the command:

   ```bash
   aws --version
   ```

✅ Expected output:

```
aws-cli/2.x.x Python/3.x.x Windows/10 botocore/2.x.x
```

If you see something like this, AWS CLI is correctly installed.

---

## 🔹 Step 5 – Upgrade (Optional)

If you want to upgrade to a newer version later:

* Simply **re-download** the latest MSI installer
* Run it again — it will automatically update your CLI version.

---

## 🔹 Step 6 – Verify the PATH (if command not found)

If `aws` isn’t recognized:

1. Restart your Command Prompt or PC.
2. If still not detected:

   * Add the following to your **Windows PATH**:

     ```
     C:\Program Files\Amazon\AWSCLIV2\
     ```
   * Then reopen Command Prompt and test again.

---

## ✅ Summary

| Step | Action                                      |
| ---- | ------------------------------------------- |
| 1    | Search for “aws cli install windows”        |
| 2    | Download the MSI installer (Version 2)      |
| 3    | Run the installer                           |
| 4    | Verify with `aws --version`                 |
| 5    | Optional: upgrade anytime with a re-install |

---









# 🧩 **Installing AWS CLI (Version 2) on macOS**

## 🎯 Goal

Install and verify the **AWS Command Line Interface (CLI)** on a Mac, so you can access AWS services from your terminal.

---

## 🔹 Step 1 – Find the Official Installer

1. Open your browser and search:
   **`install aws cli version 2 mac`**
2. Click the official AWS documentation link:
   [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Scroll to the **macOS section** titled:
   **“Install or update the AWS CLI version 2 on macOS.”**

---

## 🔹 Step 2 – Download the Installer

Click the `.pkg` installer link:

```
https://awscli.amazonaws.com/AWSCLIV2.pkg
```

This downloads a **graphical installer** for macOS.

---

## 🔹 Step 3 – Run the Installer

1. Open the downloaded `.pkg` file.
2. Follow the steps in the installation wizard:

   * **Continue**
   * **Continue**
   * **Agree** to the license
   * **Install for all users on this computer**
   * Click **Install**
3. Enter your **Mac password** if prompted.
4. Wait for installation to complete.
5. When finished, click **Close**, then **Move to Trash** to clean up.

✅ The AWS CLI is now installed.

---

## 🔹 Step 4 – Verify Installation

1. Open **Terminal** (or **iTerm2**, which is a free alternative).
2. Run this command:

   ```bash
   aws --version
   ```
3. You should see an output similar to:

   ```
   aws-cli/2.x.x Python/3.x.x Darwin/23.x.x botocore/2.x.x
   ```

✅ If you see a version number starting with **2**, the AWS CLI installed successfully.

---

## 🔹 Step 5 – Troubleshooting

If you get a “command not found” error:

1. Restart your terminal and try again.
2. If it still doesn’t work, check that AWS CLI is in your PATH:

   ```bash
   which aws
   ```

   It should return something like:

   ```
   /usr/local/bin/aws
   ```
3. If not, you can reinstall the `.pkg` file — it will automatically fix the path.

---

## 🔹 Step 6 – Upgrade Later (Optional)

To upgrade the CLI in the future:

* Simply **re-download** the latest `.pkg` installer.
* Run it again — it will **replace** the existing version.

---

## ✅ Summary

| Step | Action                            |
| ---- | --------------------------------- |
| 1    | Search “Install AWS CLI v2 macOS” |
| 2    | Download the `.pkg` installer     |
| 3    | Run the graphical installer       |
| 4    | Verify with `aws --version`       |
| 5    | Troubleshoot PATH if needed       |
| 6    | Reinstall to upgrade              |

---








# 🧩 **Installing AWS CLI (Version 2) on Linux**

## 🎯 Goal

Learn how to **download, install, and verify** the AWS Command Line Interface (CLI) on a Linux system (Ubuntu, Debian, Fedora, CentOS, or Amazon Linux).

---

## 🔹 Step 1 – Find the Official Installer

1. Open Google and search:
   **`install aws cli version 2 linux`**
2. Click the official AWS documentation link:
   [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Scroll to the section **“Install or update the AWS CLI version 2 on Linux.”**

---

## 🔹 Step 2 – Download the Installer

Run the following command in your **terminal** to download the AWS CLI zip file:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

> 💡 For ARM-based systems (like Raspberry Pi), use:
>
> ```bash
> curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
> ```

✅ This downloads the AWS CLI installer package.

---

## 🔹 Step 3 – Unzip the Installer

Next, unzip the downloaded file:

```bash
unzip awscliv2.zip
```

If `unzip` is not installed, use:

```bash
sudo apt install unzip -y
```

or on RHEL/CentOS:

```bash
sudo yum install unzip -y
```

---

## 🔹 Step 4 – Run the Installer

Now run the installer as **root**:

```bash
sudo ./aws/install
```

Enter your **password** when prompted.
The installer will copy all necessary files into `/usr/local/bin/aws`.

---

## 🔹 Step 5 – Verify the Installation

To make sure AWS CLI is correctly installed, run:

```bash
aws --version
```

✅ Expected output:

```
aws-cli/2.x.x Python/3.x.x Linux/5.x.x botocore/2.x.x
```

If you see version **2.x**, everything is working correctly.

---

## 🔹 Step 6 – (Optional) Upgrade AWS CLI

If you already have an older version and want to update:

```bash
sudo ./aws/install --update
```

---

## 🔹 Step 7 – Uninstall AWS CLI (Optional)

If you ever need to remove it:

```bash
sudo ./aws/uninstall
```

---

## ✅ Summary

| Step | Command                        | Description           |
| ---- | ------------------------------ | --------------------- |
| 1    | `curl "..." -o "awscliv2.zip"` | Download installer    |
| 2    | `unzip awscliv2.zip`           | Extract files         |
| 3    | `sudo ./aws/install`           | Install AWS CLI       |
| 4    | `aws --version`                | Verify installation   |
| 5    | `sudo ./aws/install --update`  | Update CLI (optional) |
| 6    | `sudo ./aws/uninstall`         | Remove CLI (optional) |

---

## 🧠 Tip

If you get `command not found`:

* Restart your terminal, or
* Check if `/usr/local/bin` is in your **PATH**:

  ```bash
  echo $PATH
  ```

  It should include `/usr/local/bin`.











# 🧩 **AWS Access Keys and CLI Configuration**

## 🎯 Goal

Learn how to:

* Create **Access Keys** for an IAM user
* Configure them using the **AWS CLI**
* Verify permissions and test CLI commands

---

## 🔹 Step 1 – Create Access Keys

1. Sign in to the **AWS Management Console** as your **IAM user** (`Stephane`).
2. Click on your **username (top right corner)** → select **Security credentials**.
3. Scroll down to **Access keys** and click **Create access key**.

---

## 🔹 Step 2 – Choose Key Purpose

When prompted:

* Select **Command Line Interface (CLI)** as your use case.
* AWS may suggest alternatives (like **AWS CloudShell** or **IAM Identity Center**) — you can ignore those for now.
* Check the box:
  ✅ *“I understand the above recommendation…”*
* Then click **Create access key**.

---

## 🔹 Step 3 – Save the Credentials

You’ll see two values:

* **Access Key ID** (like your username)
* **Secret Access Key** (like your password)

⚠️ This is the **only time** you can view or download them.

Click **Download .csv** or copy them securely to your password manager.

> Never share these keys — they grant direct access to your AWS account.

---

## 🔹 Step 4 – Configure the AWS CLI

Now open your terminal (on Windows, macOS, or Linux).

Run:

```bash
aws configure
```

You’ll be prompted to enter:

```
AWS Access Key ID [None]: <your-access-key-id>
AWS Secret Access Key [None]: <your-secret-access-key>
Default region name [None]: <your-region>
Default output format [None]: json
```

Example:

```
AWS Access Key ID [None]: AKIAEXAMPLE123
AWS Secret Access Key [None]: abCDeFghIjKLmnopQRstuVwxyz12345
Default region name [None]: eu-west-1
Default output format [None]: json
```

✅ CLI stores these settings under:

```
~/.aws/credentials
~/.aws/config
```

---

## 🔹 Step 5 – Test Your Connection

Run:

```bash
aws iam list-users
```

If your IAM user has permissions, you’ll see output similar to:

```json
{
    "Users": [
        {
            "UserName": "Stephane",
            "UserId": "AIDAEXAMPLE123",
            "Arn": "arn:aws:iam::123456789012:user/Stephane",
            "CreateDate": "2024-10-01T14:32:00Z"
        }
    ]
}
```

✅ This confirms your CLI setup works and your credentials are valid.

---

## 🔹 Step 6 – Permissions Check (Demo)

Now let’s test how permissions affect CLI access.

1. From your **root account**, remove `Stephane` from the **admin group**.

2. Try running:

   ```bash
   aws iam list-users
   ```

   You’ll get an **AccessDenied** error or no response:

   ```
   An error occurred (AccessDenied) when calling the ListUsers operation
   ```

   → This proves that **CLI permissions = IAM user permissions**.

3. Add `Stephane` back into the **admin group** to restore access:

   * Go to **IAM → Groups → admins → Add user**
   * Select `Stephane`
   * Click **Add to group**

✅ Permissions restored.

---

## 🔹 Step 7 – Key Takeaways

| Concept               | Description                                     |
| --------------------- | ----------------------------------------------- |
| **Access Key ID**     | Identifies your IAM user                        |
| **Secret Access Key** | Private credential (like a password)            |
| **aws configure**     | Stores credentials and default region locally   |
| **Permissions**       | Same in CLI and Console                         |
| **Best Practice**     | Never share access keys — rotate them regularly |

---

## 🧠 Quick Tip

If you ever lose or expose your access keys:

1. Delete them immediately from the **Security credentials** page.
2. Create a new key pair.
3. Update your CLI configuration using `aws configure`.









Perfect — this is your **AWS CloudShell lecture**, and it fits perfectly after your CLI configuration session.
Here’s the polished, ready-to-teach version — you can use it directly in your Bootcamp or post it as a full written tutorial.

---

# 🧩 **Using AWS CloudShell**

## 🎯 Goal

Learn how to use **AWS CloudShell** — a built-in, browser-based terminal that lets you run AWS CLI commands directly in the AWS Management Console without installing anything locally.

---

## 🔹 Step 1 – What Is CloudShell?

**AWS CloudShell** is a **browser-based command line environment** preconfigured with:

* The **AWS CLI (v2)**
* **Python**, **bash**, **zsh**, and **PowerShell**
* **Persistent storage** for your files and scripts

✅ It’s **free** to use and runs securely in your AWS account.

---

## 🔹 Step 2 – Launching CloudShell

1. In the AWS Management Console, look at the **top-right corner** for the **CloudShell icon** (a small terminal symbol).
2. Click it to **open a new CloudShell session**.

> ⚠️ If you don’t see the icon, CloudShell may not be available in your region.
> Visit: [AWS CloudShell Regional Availability](https://docs.aws.amazon.com/cloudshell/latest/userguide/supported-regions.html)
> Choose a region where it’s supported (for example, `us-east-1`, `us-west-2`, `eu-west-1`).

---

## 🔹 Step 3 – How CloudShell Works

When CloudShell starts:

* It automatically provisions a **Linux shell** inside your AWS account.
* It uses **temporary credentials** tied to your **logged-in IAM user or role**.
* The AWS CLI is already installed and ready to use.

To verify:

```bash
aws --version
```

Example output:

```
aws-cli/2.1.0 Python/3.8.8 Linux/5.10.0 botocore/2.0.0
```

✅ You can now run any AWS CLI command — no setup required!

---

## 🔹 Step 4 – Running AWS CLI Commands

Example:

```bash
aws iam list-users
```

This command works the same way as on your local CLI — using your **IAM credentials** for authentication.

> 💡 The **default region** in CloudShell matches the AWS region you’re currently logged into in the console.

You can change it anytime by adding:

```bash
--region <region-code>
```

Example:

```bash
aws s3 ls --region us-west-2
```

---

## 🔹 Step 5 – Persistent File Storage

CloudShell provides **1 GB of persistent storage per region**.

Try this:

```bash
echo "test file from CloudShell" > demo.txt
```

Now run:

```bash
ls
```

✅ You’ll see `demo.txt`.

Even if you **close or restart** CloudShell, this file remains saved.

---

## 🔹 Step 6 – Uploading and Downloading Files

CloudShell lets you easily **transfer files** between your computer and AWS.

### 📤 Upload a file:

Click the **Actions menu (⋮)** → **Upload file** → select a local file.

### 📥 Download a file:

1. Get the full path:

   ```bash
   pwd
   ```
2. Right-click the file in the CloudShell file list → **Download file**.

Example:

* File: `demo.txt`
* Path: `/home/cloudshell-user/demo.txt`
* Action: **Download** → file will be saved to your computer.

---

## 🔹 Step 7 – Customizing CloudShell

You can personalize CloudShell appearance and layout:

* **Themes**: Light or Dark mode
* **Font size**: Small, Medium, Large
* **Split panes**:

  * New tab
  * Split horizontally or vertically for multitasking

💡 Example: Split CloudShell into two panes — run `aws s3 ls` in one, and `aws ec2 describe-instances` in the other.

---

## 🔹 Step 8 – When to Use CloudShell

| Use Case                                                   | Recommendation                |
| ---------------------------------------------------------- | ----------------------------- |
| You need quick access to AWS CLI                           | ✅ Use CloudShell              |
| You don’t want to install the CLI locally                  | ✅ Use CloudShell              |
| You need automation or scripting on your local environment | ❌ Use AWS CLI on your machine |
| Your region doesn’t support CloudShell                     | ❌ Use local CLI instead       |

---

## ✅ Summary

| Feature                | Description                         |
| ---------------------- | ----------------------------------- |
| **CloudShell**         | Browser-based AWS CLI environment   |
| **Availability**       | Only in supported regions           |
| **Credentials**        | Automatically uses your IAM session |
| **Persistence**        | 1 GB of file storage per region     |
| **File Actions**       | Upload, download, and manage files  |
| **Customization**      | Adjustable font, theme, and tabs    |
| **Alternative to CLI** | No installation required            |

---

**Bottom Line:**

> You can use **CloudShell** or your **local CLI** — both work the same way.
> Choose whichever is more convenient for your workflow or available in your region.


