---
title: "Serverless overview from a Solution Architect Perspective"
description: "What is Serverless? (Simple Explanation)   Serverless does NOT mean there are no servers. It..."
published: 2025-11-03
source: "https://dev.to/jumptotech/serverless-overview-from-a-solution-architect-perspective-4dbh"
tags: []
---

# Serverless overview from a Solution Architect Perspective


### **What is Serverless? (Simple Explanation)**

**Serverless does NOT mean there are no servers.**
It means **you don't manage the servers**.

* You don’t create EC2 instances.
* You don’t patch, maintain, or scale servers.
* The cloud provider (AWS) handles all of that for you.

You **only upload your code**, and AWS runs it **when needed**.

So instead of managing **infrastructure**, you focus on **business logic**.

---

### **Old Way (Before Serverless)**

| Task                                   | You do yourself |
| -------------------------------------- | --------------- |
| Create VM / Server                     | Yes             |
| Install OS, packages, runtime          | Yes             |
| Scale when traffic increases           | Yes             |
| Pay for server 24/7 even if no traffic | Yes             |

---

### **Serverless Way**

| Task                                        | Who does it?     |
| ------------------------------------------- | ---------------- |
| Manage servers, patching, scaling           | **AWS**          |
| You run code only when needed               | **You**          |
| Pay only while code runs (per request/time) | **You pay less** |

---

### **Originally Serverless = FaaS (Function as a Service)**

AWS introduced the idea with **AWS Lambda**:

* You upload your function.
* AWS runs it **when triggered**.
* You pay only for **execution time** (e.g., 200 ms).

This is the core of serverless.

---

### **But Today, “Serverless” Is Bigger**

Now serverless = **any AWS service where you don’t manage servers**.

Examples:

| AWS Service           | Serverless Role                                    |
| --------------------- | -------------------------------------------------- |
| **Lambda**            | Run code without servers                           |
| **DynamoDB**          | Serverless NoSQL Database                          |
| **API Gateway**       | Create APIs without servers                        |
| **Cognito**           | Serverless user authentication                     |
| **S3**                | Serverless static storage + static website hosting |
| **SNS / SQS**         | Serverless messaging / queues                      |
| **Kinesis Firehose**  | Serverless streaming data ingest                   |
| **Aurora Serverless** | Serverless relational DB                           |
| **Step Functions**    | Serverless workflow orchestration                  |
| **Fargate**           | Serverless containers (no EC2 needed)              |

---

### **Typical Serverless Architecture on AWS**

```
User → CloudFront → S3 (static website)
                         ↓
                      Cognito (login/auth)
                         ↓
                   API Gateway (REST API)
                         ↓
                     Lambda (application logic)
                         ↓
                   DynamoDB (database)
```

No EC2.
No servers to maintain.
All fully managed.
Scales automatically.
Pay only for usage.

---

### **Key Characteristics of Serverless**

| Feature                  | Description                   |
| ------------------------ | ----------------------------- |
| **No server management** | Nothing to patch or maintain  |
| **Scales automatically** | Handles 1 request or millions |
| **Pay-per-use**          | No idle cost                  |
| **Event-driven**         | Functions run on triggers     |

---

### **Why Serverless Matters in AWS Exams & Interviews**

* It **reduces cost**.
* It **improves scalability**.
* It **lets teams build faster**.
* AWS SAA exam has **many questions** on serverless architecture.

---

### **Simple Interview Answer**

**Serverless is a cloud computing model where you don’t manage servers. Instead, AWS automatically handles provisioning, scaling, and maintenance. You only write and deploy your code, and you pay only when it runs. Examples include AWS Lambda for compute, DynamoDB for database, API Gateway for APIs, S3 for storage, and Cognito for authentication.**









## **What is AWS Lambda?**

AWS Lambda is a **serverless compute service**.
That means **you upload your code**, and AWS runs it **automatically** when needed — **without provisioning or managing servers.**

So instead of having a server running all the time, Lambda only runs **when an event happens**.

---

## **EC2 vs Lambda (Simple Comparison)**

| Feature           | Amazon EC2                         | AWS Lambda                           |
| ----------------- | ---------------------------------- | ------------------------------------ |
| Server management | You manage server, OS, scaling     | **No servers to manage**             |
| Cost              | Pay 24/7 while instance is running | **Pay only when code runs**          |
| Scaling           | Manual or Auto Scaling needs setup | **Automatic scaling**                |
| Execution time    | Runs continuously                  | Runs only on demand (max 15 minutes) |
| Use case          | Long-running applications          | Short tasks / event-driven workloads |

---

## **Why Lambda Is Helpful**

### 1. **No servers to manage**

No patching, updating, securing, scaling EC2 machines.

### 2. **Scales automatically**

If one user triggers it → runs once.
If 10,000 users trigger it → runs 10,000 times.
No configuration needed.

### 3. **Pay only when it runs**

If your code runs for 200 ms, you pay for **200 ms only.**

### 4. **High integration with AWS**

Lambda can be triggered by:

* API Gateway
* S3 uploads
* DynamoDB Streams
* SNS
* SQS
* EventBridge (cron jobs)
* CloudWatch Logs
* Cognito (user sign-ups)
  … and many more.

This is why Lambda is used so heavily in **serverless architectures.**

---

## **Execution Limit**

Each Lambda invocation can run **up to 15 minutes.**

This is more than enough for:

* Processing files
* Running scheduled jobs
* Backend function logic

If you need long-running workloads → use **EC2, ECS, or Fargate** instead.

---

## **Lambda Pricing (How Costs Work)**

You pay for:

1. **Number of requests**
2. **Duration of execution**

And AWS gives a **huge free tier**:

* **1 million free requests per month**
* **400,000 GB-seconds of compute per month**

This makes Lambda extremely **cost-effective**.

---

## **Languages Supported**

Lambda supports many languages:

* Node.js (JavaScript)
* Python
* Java
* C# (.NET Core)
* Ruby
* PowerShell

You can also use **custom runtimes** (Go, Rust, etc.)
And Lambda can run **container images** (but for large container workloads, **ECS/Fargate** is preferred).

---

## **Examples of Lambda in Real Systems**

### **1. Image Thumbnail Generator**

```
S3 (new image uploaded) → triggers Lambda → Lambda creates thumbnail → stores thumbnail → optional: save metadata to DynamoDB
```

### **2. Serverless CRON Job**

```
EventBridge rule (“every hour”) → triggers Lambda → Lambda performs scheduled task
```

No EC2 instance needed.

---

## **Interview-Ready Summary (Say This)**

> AWS Lambda is a serverless compute service that lets you run code without provisioning or managing servers. Functions execute only when triggered, scale automatically, and you pay only for execution time. Lambda integrates deeply with services like API Gateway, S3, DynamoDB, EventBridge, SNS, and SQS, making it ideal for event-driven and microservices architectures.










## **Hands-On: Practicing AWS Lambda (Step-by-Step Explanation)**

### **Step 1 — Open the Lambda Console**

Go to:

```
https://console.aws.amazon.com/lambda
```

If you see a demo screen, add this to the URL:

```
/begin
```

This opens the **interactive Lambda introduction UI**.

---

### **Step 2 — Understand the Lambda Demo Screen**

In the UI, you see a **Lambda function box**.

Lambda functions can be written in many languages:

* Python
* Node.js (JavaScript)
* Java
* C#
* Ruby
  … and more (even custom runtimes).

Click **Run** → it shows:

```
Hello from Lambda
```

This simply demonstrates that Lambda runs code **without servers**.

---

### **Step 3 — See How Lambda Responds to Events**

Click **“Lambda Responds to Events”**.

This shows that **Lambda is event-driven** — it runs when something happens.

Examples of triggers:

* Mobile app sends data
* IoT device sends event
* Image uploaded to S3
* Stream message arrives (Kinesis)
* API request via API Gateway

If you click repeatedly on different event icons → you will see **Lambda scale automatically**.

More events → more Lambda executions → **automatic concurrency**, no servers needed.

---

### **Step 4 — Understand Cost Behavior**

As you trigger more events:

* At first → **free tier** covers ~1 million requests
* After that → more invocations = **more cost**

So **Lambda is cheap**, but costs depend on workload volume.

---

## **Now Let’s Create a Real Lambda Function**

### **Step 5 — Create Function**

Click:

```
Create function → Use a blueprint
```

Search blueprint:

```
hello-world
```

Select **Python** version.
Name the function:

```
HelloWorld
```

### **Execution Role**

Choose:

```
Create a new role with basic Lambda permissions
```

This IAM role allows Lambda to **write logs to CloudWatch**.

Click **Create Function**.

---

### **Step 6 — View & Understand the Code**

You’ll see auto-generated code.
Important part: the **handler** — this is what runs when Lambda is invoked.

Example input event:

```json
{"key1":"value1","key2":"value2","key3":"value3"}
```

The function returns only:

```
value1
```

You don’t need to know Python deeply here — just understand:

* Lambda receives **event input**
* Code **processes** it
* Returns a **response**

---

### **Step 7 — Test the Function**

Click:

```
Test → Create a test event → Save → Test again
```

Expected result:

```
value1
```

If you **remove key1** and test → function will **fail**.
This shows Lambda errors appear when event format changes.

---

### **Step 8 — View Logs**

Go to:

```
Monitor → View logs in CloudWatch
```

Here you can see:

* print() output
* errors
* execution details

This is how we **debug Lambda**.

---

### **Step 9 — Lambda Configuration Basics**

Go to **Configuration** → **General**:

* **Memory** (more memory = faster CPU & network)
* **Timeout** (max execution time, default 3 seconds)
* **Execution Role** (IAM permissions)

If your function later needs S3, DynamoDB, SNS, etc., you **add permissions to this IAM Role**.

---

### **Step 10 — Triggers (VERY IMPORTANT)**

Click **Add Trigger**.

This shows all services that **can invoke Lambda**, for example:

* **S3** (run when file uploaded)
* **API Gateway** (run when someone hits an API endpoint)
* **EventBridge** (scheduled jobs like cron)
* **SNS / SQS**
* **DynamoDB streams**

This is the power of Lambda → **event-driven automation**.

---

## **Summary You Can Say in Class**

> We created a Lambda function, tested it, debugged it in CloudWatch logs, explored configuration, and saw how triggers work. Lambda code runs only when needed, scales automatically, and requires no server management, making it ideal for serverless applications.










## **AWS Lambda Limits (Important for Exam)**

> *These limits are per AWS Region.*

### **Execution Limits**

| Item                           | Limit                                    | Notes                                                                |
| ------------------------------ | ---------------------------------------- | -------------------------------------------------------------------- |
| **Memory**                     | **128 MB → 10 GB** (in 64 MB increments) | Increasing memory also increases CPU + network speed                 |
| **Max Execution Time**         | **15 minutes** (900 seconds)             | Code must finish before timeout                                      |
| **Environment Variables Size** | **4 KB total**                           | Small → don’t store large secrets here                               |
| **/tmp Local Storage**         | **Up to 10 GB**                          | Used for temporary files or processing large objects                 |
| **Default Concurrency**        | **1,000 concurrent executions**          | Can request increase; use *reserved concurrency* to avoid throttling |

---

### **Deployment & Package Limits**

| Item                                        | Limit      | Notes                                   |
| ------------------------------------------- | ---------- | --------------------------------------- |
| **Compressed deployment package**           | **50 MB**  | This is your .zip upload size           |
| **Uncompressed package (including layers)** | **250 MB** | Package + dependencies combined         |
| **Container Image Size**                    | **10 GB**  | If deploying Lambda via container image |
| **Environment Variables**                   | **4 KB**   | Repeated because very commonly asked    |

---

### **When NOT to Use Lambda (Exam Trick)**

If your workload needs:

* More than **15 minutes** execution time
* More than **10 GB RAM**
* More than **250 MB code package**
* Large long-running background processing
* Constant CPU usage (not event-driven)

Then **Lambda is NOT suitable** → choose **EC2, ECS, or Fargate** instead.

---

## **Exam Memory Trick**

Use the phrase:

> **“15 minutes, 10 gigs memory, 10 gigs tmp, 1,000 concurrency, 4KB env vars, 50/250 MB packages.”**

---

## **Example Exam Traps and Answers**

| Question                            | Correct Answer                                               |
| ----------------------------------- | ------------------------------------------------------------ |
| Needs 30-minute execution           | **Use EC2 or ECS**, not Lambda                               |
| Needs to process 3GB binary locally | **Use /tmp (up to 10GB)** OR choose ECS if larger            |
| Deployment package is 400MB         | **Move to container image OR ECS**                           |
| Application needs 15GB RAM          | **Not possible on Lambda → use EC2/ECS**                     |
| Too many requests throttling Lambda | **Use Reserved Concurrency or request concurrency increase** |















# **Lambda Concurrency & Throttling (Clear Explanation)**

## **What is Concurrency?**

Concurrency = **how many Lambda function executions are happening at the same time.**

Example:

* If 5 users trigger Lambda at the same moment → **Concurrency = 5**
* If traffic increases to 500 users at the same moment → **Concurrency = 500**

AWS Lambda **scales automatically**, so concurrency grows based on demand.

---

## **Default Account Concurrency Limit**

* By default, **your account has 1,000 concurrent executions per Region**.
* All Lambda functions in that Region **share this number**.

### **Problem**

One Lambda can use all concurrency and **starve** your other Lambda functions.

---

## **Reserved Concurrency**

To prevent one Lambda from stealing all concurrency:

You can **assign a concurrency limit to a specific function**.

Example:

```
Function A → Reserved concurrency = 50
```

Now:

* Function A **can run up to 50 instances at once**
* Extra requests → **Throttled**
* Other Lambda functions **still have concurrency available**

### **Why Reserved Concurrency is Useful?**

Prevents:

* Outages
* Cascading failures
* Other Lambdas being throttled

---

## **What Happens When Lambda Is Throttled?**

| Invocation Type                          | Behavior When Throttled      | Result                                                            |
| ---------------------------------------- | ---------------------------- | ----------------------------------------------------------------- |
| **Synchronous** (e.g., API Gateway, ALB) | Returns error                | `429 ThrottlingException`                                         |
| **Asynchronous** (e.g., S3, EventBridge) | Lambda retries automatically | Retries up to **6 hours**, exponential backoff, may go to **DLQ** |

---

## **Asynchronous Retry Behavior**

If Lambda is invoked **asynchronously** (S3, EventBridge, SNS):

* Lambda pushes the event into an **internal queue**
* If throttled → Lambda **retries for up to 6 hours**
* Retry intervals grow gradually (exponential backoff)
* If still failing → event can be moved to **Dead Letter Queue (DLQ)**

**DLQ Options:**

* SQS
* SNS

---

## **Cold Starts**

A **cold start** happens when Lambda must **create a new execution environment**, including:

* Loading code
* Initializing libraries/SDKs
* Setting up runtime

Cold starts add **extra delay** (latency), especially when:

* Function has **many dependencies**
* Runs in a **VPC**

---

## **Provisioned Concurrency (To Avoid Cold Starts)**

**Provisioned Concurrency pre-warms Lambda instances** so they are always ready.

| Feature                       | Result                             |
| ----------------------------- | ---------------------------------- |
| Instances are pre-initialized | **No cold starts**                 |
| Lower latency                 | **Predictable performance**        |
| Cost slightly higher          | You pay for reserved warm capacity |

### When to Use Provisioned Concurrency:

* APIs with **real-time user traffic**
* User authentication systems
* Payment/checkout systems
* Low-latency mobile backends

---

# **Exam Traps & Answers**

| Scenario                                       | Correct Choice                                  |
| ---------------------------------------------- | ----------------------------------------------- |
| Need guaranteed response time / no latency     | **Provisioned Concurrency**                     |
| Need to ensure one Lambda doesn’t block others | **Reserved Concurrency**                        |
| Async triggers must not be lost when throttled | Use **DLQ (SQS or SNS)**                        |
| System needs > 1,000 concurrency               | **Request concurrency limit increase from AWS** |
| Function executes > 15 minutes                 | **Use EC2/ECS/Fargate, NOT Lambda**             |

---

# **Interview-Ready Summary (Say This)**

> Lambda concurrency means how many Lambda executions can run at the same time. There is a default limit of 1,000 concurrent executions per region. To prevent one function from using all capacity and throttling others, we use Reserved Concurrency. In synchronous requests, throttling returns a 429 error. In asynchronous requests, Lambda automatically retries for up to 6 hours and can forward failures to a DLQ. Cold starts occur when Lambda initializes new execution environments, and Provisioned Concurrency is used to eliminate cold start latency.















# **Lambda Concurrency Settings (Hands-On Explanation)**

### Where to Find It

In your Lambda function:

```
Configuration → Concurrency
```

You will see:

* **Unreserved Account Concurrency (Default Pool)**
  Your entire AWS account gets **1,000 concurrent executions per Region**, shared across all Lambda functions.

---

## **Reserved Concurrency (Per Function Limit)**

If you **do nothing** → your function uses the **shared pool** (up to 1,000).

But if you **set Reserved Concurrency**, for example:

```
Reserved concurrency = 20
```

It means:

* This function can run **up to 20 concurrent executions**
* No more than 20 at a time
* The remaining **980** concurrency stays available for **other functions**

This protects other Lambdas from being starved.

---

### **Testing Throttling (Important Demonstration)**

If you set:

```
Reserved concurrency = 0
```

That means **this function is always throttled**.

If you try to **Test** the function, you'll get:

```
429 - Rate Exceeded / ThrottlingException
```

This is useful for:

* Understanding throttling behavior
* Testing retry logic
* Preparing for exam questions

---

## **Provisioned Concurrency (To Avoid Cold Starts)**

### Cold Start Recap:

When Lambda starts a **new instance**, it:

* Loads your code
* Initializes runtime and dependencies
  → This causes **delay** (first request is slower).

To prevent this, use:

```
Provisioned Concurrency
```

This means:

* Lambda **keeps a certain number of instances warm**
* No cold starts
* Lower and predictable latency

---

### How to Configure It

You must apply it to a **published version or alias** — **not** the `$LATEST` version.

Steps (conceptual):

1. Publish a **version** of your Lambda
2. Assign **Provisioned Concurrency** to that version or alias
3. Set number of warm instances (e.g., 5)

Example:

```
Provisioned concurrency = 5
```

Meaning:
AWS will keep **5 Lambda execution environments ready at all times.**

### **Important:**

Provisioned Concurrency **costs money** (because Lambda stays warm).

Use it only when:

* You require **very low latency**
* You have **predictable traffic**

---

# **Quick Summary to Say in Class or Interview**

> In Lambda, concurrency controls how many executions run at once. The AWS account has a shared limit of 1,000 concurrent executions by default. To prevent one function from consuming all concurrency and causing throttling, we can configure Reserved Concurrency for specific functions. Cold starts happen when Lambda creates new environments; Provisioned Concurrency keeps functions pre-initialized to avoid latency but adds cost.











# **Lambda SnapStart (Simple Explanation)**

**AWS Lambda SnapStart** is a feature that **reduces cold start time**, especially for **Java**, **Python**, and **.NET** Lambda functions.

It can make Lambda functions **start up to 10x faster**.

**Important:** There is **no additional cost** to enable SnapStart.

---

## **Why SnapStart Exists**

Some runtimes (especially **Java**) take a long time to **initialize**:

* Loading libraries
* Creating objects
* Connecting to frameworks
* JVM startup overhead

This slow initialization causes **cold start latency**.

---

## **Normal Lambda Lifecycle (Without SnapStart)**

```
Invoke → Initialize → Run (Invoke) → Shutdown
```

The **Initialize** phase is often slow.

This is what causes **cold starts**.

---

## **What SnapStart Does**

When you **publish a Lambda version**, AWS will:

1. **Initialize the function ahead of time**
2. Take a **snapshot of memory + runtime state**
3. Store it
4. On invocation, Lambda **restores from the snapshot instantly**

So the Lambda **skips the slow initialization step**.

---

### **With SnapStart Enabled**

```
Invoke → Run (Invoke) → Shutdown
```

Initialization is already done **before the function ever runs**.

Cold starts become **almost zero**.

---

## **How It Works (Simple Visual)**

| Without SnapStart                                     | With SnapStart                                         |
| ----------------------------------------------------- | ------------------------------------------------------ |
| Initialize every time new Lambda container is created | Initialization done **once** when version is published |
| Slow cold starts                                      | **Fast starts (~10x faster)**                          |
| Works but slower for Java apps                        | **Great for Java, Python, .NET** microservices         |

---

## **When SnapStart Happens**

SnapStart is applied **only when you publish a Lambda Version**.

So:

* It **does not apply** to `$LATEST`
* Use SnapStart **with Versions + Aliases** (which we will learn next)

---

## **Exam + Interview Summary (Say This)**

> Lambda SnapStart reduces cold start latency by preinitializing the function at version publish time and restoring it from a memory snapshot during invocation. This speeds up startup performance by up to 10x and is especially effective for Java, Python, and .NET Lambda functions. SnapStart is free and improves invocation latency without increasing compute cost.









# **Customization at the Edge (CloudFront Functions vs Lambda@Edge)**

## **Why “Edge” Functions Exist**

Normally, your applications and Lambda functions run in a **Region** (e.g., `us-east-1`).
But your users may be all over the world.

**CloudFront edge locations** are close to users and help **reduce latency**.

Sometimes we want to **run logic before the request reaches our backend** — for example:

* Redirect users
* Apply security filters
* Modify headers
* Check authentication
* Personalize content

To do that, we run **code at the edge** → these are called **Edge Functions**.

---

## **Two Types of Edge Functions in AWS**

| Feature               | CloudFront Functions                 | Lambda@Edge                                     |
| --------------------- | ------------------------------------ | ----------------------------------------------- |
| Runtime               | **JavaScript only**                  | **Node.js + Python**                            |
| Performance           | **Ultra-fast (<1 ms)**               | Slower (up to **5–10 seconds**)                 |
| Scale                 | **Millions of requests/sec**         | **Thousands/sec**                               |
| Request phase support | Viewer **Request and Response only** | **Viewer + Origin** (all 4 stages)              |
| Complexity            | Simple logic                         | Can be complex logic, external calls, libraries |
| Cost                  | Very low cost                        | More expensive                                  |

---

## **Where They Run in the Request Flow**

```
 Client → (Viewer Request) → CloudFront → (Origin Request) → Origin
 Client ← (Viewer Response) ← CloudFront ← (Origin Response) ← Origin
```

| Event Stage     | CloudFront Functions | Lambda@Edge |
| --------------- | -------------------- | ----------- |
| Viewer Request  | ✅ Supported          | ✅ Supported |
| Origin Request  | ❌ Not Supported      | ✅ Supported |
| Origin Response | ❌ Not Supported      | ✅ Supported |
| Viewer Response | ✅ Supported          | ✅ Supported |

---

## **When to Use Which?**

### **Use CloudFront Functions when you need:**

* **Very fast execution**
* **Simple request modifications**
* No long processing or AWS service calls

Common use cases:

* URL rewrites or redirects
* Header modifications
* A/B testing decision
* Block IP or user-agent
* Simple authentication checks (e.g., JWT validation)

### **Use Lambda@Edge when you need:**

* More complex logic / slower processing
* Access to **request body**
* Call to external services / APIs
* Use of AWS SDK
* Personalized content based on cookies/sessions

Common use cases:

* Dynamic content rendering
* Real-time image transformation
* Geo-based routing logic
* API request authentication with external DB/service

---

## **Exam & Interview Summary (Say This)**

> Customization at the Edge means running code at CloudFront edge locations to modify requests and responses close to users. AWS provides two types of Edge compute: CloudFront Functions and Lambda@Edge. CloudFront Functions are ultra-fast JavaScript-only functions that modify viewer requests and responses. Lambda@Edge is more powerful, supports Node.js and Python, and can modify both viewer and origin traffic, but has higher latency and cost.













# **Does RDS / Aurora integrate directly with Lambda?**

### **Yes — but only in specific cases, and only for *data-level* triggers.**

Some database engines can **invoke Lambda directly when data inside the database changes**.

### Supported Engines:

| Database Engine         | Supports Lambda Triggers? |
| ----------------------- | ------------------------- |
| **RDS PostgreSQL**      | ✅ Yes                     |
| **Aurora MySQL**        | ✅ Yes                     |
| RDS MySQL / MariaDB     | ❌ No                      |
| Aurora PostgreSQL       | ❌ No (not currently)      |
| RDS SQL Server / Oracle | ❌ No                      |

---

## **How It Works (Data-Level Lambda Triggering)**

Example scenario:

```
User inserts a row → Database trigger/fxn calls Lambda → Lambda sends a welcome email
```

The **database itself** invokes the Lambda function.

This configuration is set **inside the database**, not in AWS Console.

### Requirements:

1. **Network connectivity**

   * The DB must be able to reach Lambda:

     * Public Lambda invoke endpoint
     * OR through VPC / NAT / VPC Endpoint

2. **IAM Permissions**

   * The **DB instance must have an IAM role** that allows:

     ```
     lambda:InvokeFunction
     ```
   * This is attached as a **Cluster or DB IAM role**, not to a user.

---

# **RDS Event Notifications (Very Different Feature!)**

**RDS Event Notifications** are *not* about data changes inside the database.

They notify you about the **health & lifecycle of the RDS instance itself**, for example:

* Instance started / stopped
* Backup completed
* Failover happened
* Storage full
* Snapshot created

### Delivery:

| Feature                 | Supported? |
| ----------------------- | ---------- |
| SNS Notification        | ✅ Yes      |
| EventBridge Integration | ✅ Yes      |
| Data row-level events   | ❌ No       |

### Performance:

* Near real-time, **up to 5 minutes delay**.

---

## **Common Exam Trap**

| Feature                        | Data Change Triggered? | Used For?                                 |
| ------------------------------ | ---------------------- | ----------------------------------------- |
| **DB Trigger invoking Lambda** | ✅ Yes                  | React to inserts/updates (business logic) |
| **RDS Event Notifications**    | ❌ No                   | Instance lifecycle / maintenance alerts   |

**If a question says:**

> User signup stored in DB should trigger a welcome email.

✅ Answer: **Use PostgreSQL or Aurora MySQL-based Lambda invocation (DB trigger)**.

**If a question says:**

> Notify DevOps team when failover occurs.

✅ Answer: **Use RDS Event Notifications → SNS or EventBridge**.

---

## **Interview-Ready Summary (Say This)**

> Aurora MySQL and RDS PostgreSQL can call Lambda functions directly from the database using stored procedures or triggers. This allows reacting to data changes in real time, such as sending notifications or processing inserted records. The DB instance must have network access to Lambda and an IAM role permitting `lambda:InvokeFunction`. This is different from RDS Event Notifications, which report infrastructure-level events like instance failover or snapshot completion, not table data changes.
















# **Hands-On: Creating a DynamoDB Table (Key Concepts)**

### **Important mindset:**

In DynamoDB, you **do NOT create a database first.**
DynamoDB **itself is the database** — you only create **tables**.

---

## **Step 1 — Create a Table**

When you click **Create Table**, you choose:

| Field                        | Meaning                                                     |
| ---------------------------- | ----------------------------------------------------------- |
| **Table Name**               | Name of your data container (example: `DemoTable`)          |
| **Partition Key (required)** | Main unique identifier for each item                        |
| **Sort Key (optional)**      | Used for grouping & ordering items under same partition key |

Example:

```
Partition Key: user_id
Sort Key: (none for now)
```

This means **each user_id must be unique**.

If we *did* use a sort key, the combination:

```
user_id + sort_key
```

would be unique instead.

---

## **Step 2 — Capacity Mode (VERY IMPORTANT FOR EXAM)**

When creating the table, you choose how DynamoDB handles **read and write throughput**:

### **Option 1 — On-Demand Mode**

* **No capacity planning**
* DynamoDB **auto-scales instantly**
* You **pay per request**

**Best for:**

* Unpredictable traffic
* Spiky workloads
* Low usage tables

**Exam trigger words:**
*“Unpredictable”, “spikes”, “variable”, “unknown usage” → Choose On-Demand.*

---

### **Option 2 — Provisioned Mode**

* You **decide capacity upfront**:

  * **RCU = Read Capacity Units**
  * **WCU = Write Capacity Units**
* Cheaper if workload is steady
* Can enable **Auto Scaling** to adjust capacity automatically

**Exam trigger words:**
*“Predictable workload”, “steady traffic”, “cost-optimized” → Choose Provisioned.*

---

## **Step 3 — Insert Items**

Click **View Items → Create Item**.

Example Item 1:

```
user_id = "stephane_123"
name = "Stephane Maarek"
favorite_movie = "Memento"
favorite_number = 42
```

Example Item 2:

```
user_id = "alice_456"
name = "Alice Doe"
favorite_movie = "Pocahontas"
age = 23
```

### Key DynamoDB Feature:

Items **do not need to have the same attributes.**

This is **schema flexibility**, and it is one of the biggest benefits of DynamoDB.

---

## **Exam Takeaways From This Lesson**

| Concept                                    | Remember                                           |
| ------------------------------------------ | -------------------------------------------------- |
| DynamoDB is **serverless**                 | No servers to manage, auto scales, no admin        |
| DynamoDB is **NoSQL**                      | Schema flexible, no fixed columns                  |
| **Primary Key Selected at Table Creation** | Cannot be changed later                            |
| **Item max size = 400 KB**                 | Store large files in S3, not DynamoDB              |
| **On-Demand Mode**                         | Best for unpredictable workloads                   |
| **Provisioned Mode + Auto Scaling**        | Best for predictable workloads / cost optimization |

---

## **Interview-Ready Summary (Say This)**

> DynamoDB is a fully managed, serverless NoSQL database where you only create tables, not databases. Each table has a primary key, either a partition key alone or a partition + sort key. DynamoDB supports flexible schemas, meaning items in the same table can have different attributes. You can choose Provisioned Mode with auto scaling for predictable workloads or On-Demand Mode for unpredictable workloads. It scales automatically and provides single-digit millisecond performance.











# **1. DynamoDB Accelerator (DAX)**

| Feature     | Explanation                                                   |
| ----------- | ------------------------------------------------------------- |
| What it is  | **In-memory cache** for DynamoDB                              |
| Purpose     | Reduce **read latency** — avoid repeated reads from DynamoDB  |
| Performance | **Microsecond-level** read times                              |
| Cost        | Fully managed, but you pay for the cluster nodes              |
| Integration | **No code changes needed** — DAX uses same DynamoDB API calls |

### **When to Use DAX**

* Your application performs **many repeated reads**
* You need **very low read latency**
* You want **seamless caching**

### **DAX vs ElastiCache**

| Use Case                                         | Service                           |
| ------------------------------------------------ | --------------------------------- |
| Cache DynamoDB item reads                        | **DAX**                           |
| Cache complex computations / aggregation results | **ElastiCache** (Redis/Memcached) |

**Exam Trigger Phrases:**
“Microsecond latency” → DAX
“Read-heavy workload” → DAX
“Drop-in replacement, no app changes” → DAX

---

# **2. DynamoDB Streams**

| Feature                 | Explanation                                         |
| ----------------------- | --------------------------------------------------- |
| What it captures        | **INSERTS, UPDATES, DELETES** from a DynamoDB table |
| Retention               | **24 hours** of change history                      |
| Primary Use Case        | Trigger **Lambda** when data changes                |
| Data Ordering Guarantee | **Per partition key**                               |

### Uses:

* Send **welcome emails** after new user inserts
* **Audit logging**
* **Real-time analytics**
* **Replicate data to other tables**
* **Consume with Lambda or Kinesis**

### **Two Options**

| Option                                       | Use When                                                       |
| -------------------------------------------- | -------------------------------------------------------------- |
| **DynamoDB Streams (default)**               | Simple Lambda processing                                       |
| **Kinesis Data Streams (via stream choice)** | Need **1+ year retention**, many consumers, advanced analytics |

---

# **3. DynamoDB Global Tables**

| Feature     | Explanation                                            |
| ----------- | ------------------------------------------------------ |
| Purpose     | Make DynamoDB available **globally, with low latency** |
| Replication | **Active-Active** (read/write in multiple regions)     |
| Requirement | **DynamoDB Streams must be enabled first**             |

### **When to Use**

* Multi-region applications
* Geo-distributed user base
* Disaster recovery scenarios

**Exam Trigger Phrases:**
“Global low-latency access” → Global Tables
“Active-active replication” → Global Tables

---

# **4. Time To Live (TTL)**

| Feature        | Explanation                                                   |
| -------------- | ------------------------------------------------------------- |
| What it does   | Automatically **expires and deletes** items after a timestamp |
| Field Required | Attribute containing Unix timestamp (`TTL`)                   |
| Cost           | **Free** (no extra charge)                                    |

### Use Cases:

* **Session expiration**
* **Expire temporary tokens**
* **Data retention compliance (delete after X days)**

**Exam Trigger Phrases:**
“Automatically remove old items” → TTL
“Session table” → TTL
“Regulatory data expiration” → TTL

---

# **Backup & Export**

| Feature                           | Explanation                                         |
| --------------------------------- | --------------------------------------------------- |
| **PITR (Point-In-Time Recovery)** | Restore table to **any second** in last **35 days** |
| **On-Demand Backups**             | Keep backups **indefinitely** until deleted         |
| **Restoring**                     | Always **creates a new table**                      |
| **Export to S3**                  | Uses **PITR snapshot**, does **not affect RCU/WCU** |
| **Formats**                       | DynamoDB JSON or ION (import supports CSV/JSON/ION) |

### Use Cases:

* Disaster recovery
* Analytics in Athena (after exporting to S3)
* Moving data between environments

---

# **Exam Summary (Say This)**

> DynamoDB DAX is an in-memory read cache providing microsecond latency. DynamoDB Streams capture item-level changes and commonly trigger Lambda. DynamoDB Global Tables provide multi-region active-active replication and require Streams. TTL automatically deletes expired data. DynamoDB supports PITR recovery for 35 days and allows exporting table data to S3 for analytics without impacting performance.










# **API Gateway + Lambda (Serverless API)**

We now want clients to be able to call our **Lambda functions** over the **internet**.

We could:

| Option                             | Problem                                                     |
| ---------------------------------- | ----------------------------------------------------------- |
| Client calls Lambda directly       | Client needs **IAM credentials** → Not good for public APIs |
| Application Load Balancer → Lambda | Works, but **limited features**                             |
| **API Gateway → Lambda**           | **Best**, gives many API features                           |

So we use **API Gateway** to act as the **front door** for our Lambda-powered application.

---

# **What is API Gateway?**

**API Gateway** is a **fully managed service** for creating **REST** or **WebSocket** APIs.

It:

* Receives requests from clients
* Applies **authentication / rate limits / request validation**
* Sends requests to **Lambda** or other AWS services

No servers to manage → fully serverless.

---

# **Why Use API Gateway?**

API Gateway provides **API-level features** that ALB does not:

| Feature                               | Available? |
| ------------------------------------- | ---------- |
| Authentication (Cognito, IAM, custom) | ✅          |
| Request Validation                    | ✅          |
| Throttling / Rate Limits              | ✅          |
| API Keys + Usage Plans                | ✅          |
| Request/Response Transformation       | ✅          |
| Caching responses                     | ✅          |
| Versioning + Stages (dev/test/prod)   | ✅          |
| WebSocket real-time APIs              | ✅          |

---

# **API Gateway Integrations**

API Gateway can forward requests to:

| Backend Type                                 | Use Case                                                                               |
| -------------------------------------------- | -------------------------------------------------------------------------------------- |
| **Lambda**                                   | Serverless CRUD apps (most common)                                                     |
| **HTTP endpoints** (ALB, EC2, On-prem)       | Add security, throttling, API keys to existing APIs                                    |
| **AWS Services** (via AWS Proxy Integration) | E.g., publish to SQS, write to DynamoDB, start Step Functions, send records to Kinesis |

---

# **Example: API Gateway → Kinesis**

```
Client → API Gateway → Kinesis Data Stream → Firehose → S3
```

Client never needs AWS credentials — **API Gateway handles auth and traffic control**.

---

# **API Gateway Endpoint Types (Exam MUST-KNOW)**

| Type                         | When to Use                                  | Behavior                                                               |
| ---------------------------- | -------------------------------------------- | ---------------------------------------------------------------------- |
| **Edge-Optimized** (Default) | **Global users**                             | Uses **CloudFront edge network** for low latency                       |
| **Regional**                 | Users are **in one region**                  | Calls go directly to region (no CloudFront unless you add it yourself) |
| **Private**                  | API should only be accessible **inside VPC** | Access via **VPC Endpoint + Resource Policy**                          |

---

# **API Gateway Security Options**

| Security Method                           | Use Case                                             |
| ----------------------------------------- | ---------------------------------------------------- |
| **IAM Authorization**                     | Internal AWS clients (e.g., EC2 calling API Gateway) |
| **Cognito User Pools**                    | Public users (mobile/web sign-in)                    |
| **Custom Authorizer (Lambda Authorizer)** | Fully custom logic (JWT validation, API tokens)      |

For **custom domains**, certificates are stored in **ACM**:

| Endpoint Type      | ACM Certificate Region |
| ------------------ | ---------------------- |
| **Edge-Optimized** | **us-east-1**          |
| **Regional**       | Same region as API     |

And Route 53 **CNAME / A-alias** points your domain to API Gateway.

---

# **Interview-Ready Summary (Say This)**

> API Gateway is a fully managed service for building and securing APIs. It integrates directly with Lambda to create serverless applications. It provides authentication (IAM, Cognito, custom authorizers), throttling, request validation, caching, usage plans, and stage/version management. Endpoint types are Edge-Optimized for global clients, Regional for local clients, and Private for VPC-only access.











# **Hands-On Summary: Creating an API Gateway → Lambda REST API**

## **Step 1 — Create the API**

Go to:

```
API Gateway Console → Create API → REST API → Build
```

Name the API:

```
MyFirstAPI
```

Choose **Endpoint Type**:

* **Regional**: API available in one region (we used this).
* **Edge-Optimized**: Uses CloudFront for global performance.
* **Private**: Only accessible inside VPC.

We chose **Regional**.

---

## **Step 2 — Create Lambda Function**

Go to:

```
Lambda Console → Create Function
```

Example function name:

```
api-gateway-route-gets
```

Runtime:

```
Python 3.x
```

Replace default code with a simple JSON response:

```python
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps("hello from Lambda"),
        "headers": {
            "Content-Type": "application/json"
        }
    }
```

Deploy and test to confirm it works.

---

## **Step 3 — Connect API Gateway to Lambda**

Back in API Gateway:

```
Actions → Create Method → GET
```

Integration Type:

```
Lambda Function
```

Paste Lambda ARN.

Make sure:
✅ **Use Lambda Proxy Integration** is checked
This allows full request details to be passed to Lambda.

AWS automatically adds permission in Lambda’s **resource policy**:

```
API Gateway is allowed to invoke this function
```

---

## **Step 4 — Test Inside API Gateway**

Use the **Test** button in API Gateway.

You should see output:

```
Status Code: 200
Body: "hello from Lambda"
```

---

## **Step 5 — View Event Payload in CloudWatch Logs**

Modify Lambda:

```python
print(event)
```

Deploy → Invoke via API Gateway → Check logs:

```
Lambda → Monitor → View Logs in CloudWatch
```

You see request info (path, headers, params).

---

## **Step 6 — Add More Endpoints (Optional Demo)**

Create a new resource:

```
/houses
```

Attach a new GET method → create new Lambda → return:

```
"hello from my pretty house"
```

Now we have:

```
GET /          → Returns "hello from Lambda"
GET /houses    → Returns "hello from my pretty house"
```

---

## **Step 7 — Deploy the API**

```
Actions → Deploy API → New Stage → dev
```

Copy the **Invoke URL**:

```
https://xxxx.execute-api.region.amazonaws.com/dev
```

Test in browser:

| URL           | Expected Output                                 |
| ------------- | ----------------------------------------------- |
| `/dev`        | hello from Lambda                               |
| `/dev/houses` | hello from my pretty house                      |
| `/dev/wrong`  | "Missing Authentication Token" (expected error) |

---

# **Key Exam Takeaways**

| Concept                               | Meaning                                                      |
| ------------------------------------- | ------------------------------------------------------------ |
| API Gateway exposes Lambda over HTTPS | No IAM required for clients                                  |
| Lambda Proxy Integration              | Full request details passed to Lambda                        |
| API Gateway timeout                   | **Max 29 seconds** (even if Lambda can run up to 15 minutes) |
| Deployment stages                     | **dev**, **test**, **prod**, etc.                            |
| Invoke URL                            | Based on stage + resource paths                              |

---

# **Interview-Ready Summary (Say This)**

> To expose Lambda publicly, we use API Gateway. API Gateway acts as an HTTP front end, allowing us to route requests to Lambda, add authentication, throttling, logging, versioning, and transform requests and responses. We created REST API methods mapped to Lambda functions, deployed them to a stage, and invoked the API over the internet.











# **AWS Step Functions (Simple Explanation)**

**Step Functions** is a **serverless orchestration service** that lets you **visually coordinate workflows** across AWS services.

You design workflows as a **state machine** where each step represents an action, usually a **Lambda function**, but Step Functions can also call many other AWS services directly.

---

## **Why Step Functions Are Useful**

Without Step Functions, your workflow logic (loops, retries, branching, dependencies) would need to be written **inside Lambda code** — making the application:

* Hard to maintain
* Hard to debug
* Hard to visualize

With Step Functions, your workflow is defined in **JSON (Amazon States Language)** and shown as a **visual diagram**.

---

## **What Step Functions Can Do**

| Feature                | Explanation                                    |
| ---------------------- | ---------------------------------------------- |
| **Sequence**           | Run tasks step-by-step in order                |
| **Parallel Execution** | Run multiple tasks at the same time            |
| **Choice / Branching** | If/Else logic based on input values            |
| **Wait / Delay**       | Pause execution for a set time                 |
| **Retry + Catch**      | Automatic error handling & retries             |
| **Timeouts**           | End a step if it runs too long                 |
| **Human approval**     | Pause workflow until a person approves/rejects |

---

## **Step Functions Can Integrate With**

Step Functions can trigger *many AWS services*, not only Lambda:

| Service Type | Examples                                                   |
| ------------ | ---------------------------------------------------------- |
| Compute      | Lambda, ECS tasks, EC2 systems manager                     |
| Messaging    | SQS, SNS, EventBridge                                      |
| Data         | DynamoDB, Athena, Glue, S3                                 |
| Application  | API Gateway, SageMaker, On-Prem Services via API endpoints |

**Key Point:** Step Functions can **call AWS Services directly**, even without Lambda.

---

## **Common Use Cases**

| Use Case                | Example                                                             |
| ----------------------- | ------------------------------------------------------------------- |
| **Order Processing**    | Validate order → Charge card → Update inventory → Send confirmation |
| **Data Workflows**      | Process S3 data → Transform → Load into data warehouse              |
| **Approval Workflows**  | HR onboarding / document signing                                    |
| **Serverless Web Apps** | Multi-step API processes managed through Lambda steps               |

---

## **Example (Simple Workflow Visual)**

```
Start
 ↓
Validate Input (Lambda)
 ↓ success
Process Payment (Lambda)
 ↓ success
Send Email Confirmation (Lambda)
 ↓
End
```

If any step **fails**, Step Functions can:

* Retry automatically
* Skip to error handler
* Send alert and stop

---

## **Interview / Exam Summary (Say This)**

> Step Functions is a serverless orchestration service that lets us define workflows as state machines. It coordinates Lambda functions and many other AWS services. Step Functions provides sequencing, branching, parallel execution, retries, and timeouts without writing custom orchestration logic in code. It is commonly used in multi-step business workflows like order processing and approvals.










# **Amazon Cognito (Clear & Simple)**

Amazon Cognito is used to **give identities and authentication** to **web and mobile application users** — users who are **outside** of AWS (unlike IAM users).

Cognito solves:

* **Sign up / sign in**
* **User authentication**
* **User identity management**
* **Temporary AWS access for users**

---

## **Cognito Has Two Main Components**

| Feature                                          | Purpose                                      | Think of it as                                                     |
| ------------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------------ |
| **Cognito User Pool (CUP)**                      | Authenticates users (login)                  | “The user database + login system”                                 |
| **Cognito Identity Pool (Federated Identities)** | Gives **temporary AWS credentials** to users | “The service that gives users permissions to access AWS resources” |

---

## **1. Cognito User Pool (CUP)**

Used for **Login + Authentication**.

Supports:

* Username/password login
* Email/phone verification
* Password reset
* Multi-factor authentication (MFA)
* Login with Google, Facebook, Apple, SAML, etc.

**Integrates directly with:**

| Integration                   | Meaning                                     |
| ----------------------------- | ------------------------------------------- |
| **API Gateway**               | Protect APIs (only logged-in users allowed) |
| **Application Load Balancer** | Protect web-apps behind ALB                 |

### **Example Flow (API Gateway + Lambda)**

```
User logs in → Gets token → Sends token to API Gateway → Verified → Passed to Lambda
```

Now Lambda **knows which user** is calling the app.

---

## **2. Cognito Identity Pools**

*(formerly Federated Identity)*

Purpose:
✅ **Give users temporary AWS credentials** (STS tokens)
✅ Allow users to directly access AWS services (S3, DynamoDB, etc.) **without going through a backend**

Example Use:

* A mobile app uploads images **directly to S3**
* Without exposing any AWS keys

### **How It Works**

```
User logs in (User Pool / Google / Facebook / etc.)
↓ sends token
Identity Pool validates the token
↓
Identity Pool returns temporary AWS credentials
↓
User directly accesses AWS resources (S3, DynamoDB, etc.)
```

---

## **Fine-Grained Permissions (Important for Exam)**

Identity Pool can generate a **custom IAM policy per user**, for example:

```
Allow the user to only access DynamoDB items where item.user_id == the user’s identity
```

This is called:

### ✅ **Row-Level Security in DynamoDB**

This WILL appear on the exam.

---

## **When to Use What (Simple Rule)**

| Use Case                                                        | Service to Choose                |
| --------------------------------------------------------------- | -------------------------------- |
| You need **login / signup / MFA**                               | **User Pool**                    |
| You want users to **call AWS services directly** (S3, DynamoDB) | **Identity Pool**                |
| You want to secure API Gateway or ALB routes                    | **User Pool** (token validation) |
| You need **temporary AWS credentials**                          | **Identity Pool**                |

---

## **Exam & Interview Summary (Say This)**

> Cognito provides authentication and identity management for web and mobile app users. Cognito User Pools handle user login and integrate with API Gateway and ALB for secure access. Cognito Identity Pools provide temporary AWS credentials so that authenticated users can directly access AWS resources such as S3 or DynamoDB, enabling fine-grained permissions like row-level security.














