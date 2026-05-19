---
title: "Part 2: Decoupled Architecture"
description: "🎬 SCENARIO: “You Upload a Movie to Netflix”   You upload:    Avengers.mp4        Enter..."
published: 2026-02-25
source: "https://dev.to/jumptotech/part-2-decoupled-architecture-45jp"
tags: []
---

# Part 2: Decoupled Architecture






# 🎬 SCENARIO: “You Upload a Movie to Netflix”

You upload:

```
Avengers.mp4
```

Now what happens behind the scenes?

---

# 🎥 STEP 1 — Upload Goes to Storage

Service used:
Amazon S3

![Image](https://www.researchgate.net/publication/322947330/figure/fig5/AS%3A1093451437350913%401637710546250/Flow-diagram-of-video-uploading-and-transcoding-for-proposed-Quick-response-with.ppm)

![Image](https://docs.aws.amazon.com/images/solutions/latest/live-streaming-on-aws-with-amazon-s3/images/live-streaming-on-aws-with-mediastore.png)

![Image](https://png.pngtree.com/png-vector/20260111/ourlarge/pngtree-cloud-upload-icon-in-simple-flat-style-vector-png-image_18481157.webp)

![Image](https://cdn.vectorstock.com/i/500p/24/13/upload-icon-cloud-storage-symbol-modern-simple-vector-29002413.jpg)

Flow:

User → S3

Explain:

S3 is like Netflix’s big digital warehouse.
It stores the raw movie file.

At this point:
Nothing is processed yet.

---

# 📢 STEP 2 — S3 Shouts: “New Video Arrived!”

Service used:
Amazon SNS

![Image](https://d2908q01vomqb2.cloudfront.net/fc074d501302eb2b93e2554793fcaf50b3bf7291/2023/02/13/adverse_1-1181x630.png)

![Image](https://d2908q01vomqb2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2022/05/23/fanout-S3-usecase-diagram.png)

![Image](https://www.ibm.com/content/adobe-cms/us/en/products/tutorials/using-event-notifications-in-your-deployed-solutions/jcr%3Acontent/root/table_of_contents/body-article-8/image.coreimg.jpeg/1763732521668/en1.jpeg)

![Image](https://support.huaweicloud.com/eu/ugobs-obs/en-us_image_0214436458.png)

Explain:

When movie is uploaded:

S3 sends event to SNS.

SNS is like:

📣 A loudspeaker announcement:

> “New movie uploaded!”

---

# 📬 STEP 3 — SNS Sends Task to Workers

Service used:
Amazon SQS

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AI2BvwlbD_wVlokjD9BE3Fg.jpeg)

![Image](https://systemdesignschool.io/concepts/amqp-style-task-queues/encountering-overload-of-server-to-service-data-flow-without-message-queues.png)

![Image](https://d2908q01vomqb2.cloudfront.net/fc074d501302eb2b93e2554793fcaf50b3bf7291/2024/08/20/fig5-wesfarmers-queue-1024x482.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2ANaHrUjS6rEFrm9reHLtfvA.png)

Explain:

SNS sends message to SQS.

SQS is like:

📬 A task mailbox.

Inside the mailbox:

```
Process Avengers.mp4
```

Why mailbox?

Because:

* Maybe 1 video
* Maybe 10,000 videos

Queue stores tasks safely.

---

# 🏭 STEP 4 — Workers Process the Movie

Service used:
Amazon EC2

![Image](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/patterns/images/pattern-img/9d1442c2-f3ee-47fd-8cce-90d9206ce4d4/images/a60e585f-27be-4dd6-897b-c38adf1d283f.png)

![Image](https://docs.particular.net/architecture/aws/images/aws-queue-based-architecture.png)

![Image](https://stack.convex.dev/_next/image?q=75\&url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fts10onj4%2Fproduction%2F60a0e6e7085c1e40e933683cfd40b7b0761c7b71-1904x1125.png\&w=3840)

![Image](https://miro.medium.com/0%2Ak9vCsZDxVn27YWV0.jpg)

Explain:

Workers (EC2 machines):

* Convert video to 1080p
* Create 720p version
* Add subtitles
* Compress file

They read tasks from SQS.

---

# 💥 LIVE DEMO MOMENT (What You Did)

You show:

1️⃣ Worker running
2️⃣ Upload file
3️⃣ File moves from uploads → processed

Students see:

System works.

---

# 🔴 DRAMATIC MOMENT — Worker Dies

You run:

```
pkill -f worker.py
```

Now upload new video.

What happens?

File stays in uploads.

Queue has message.

Processing stopped.

Pause.

Ask students:

> What if this was Netflix during a big movie release?

They understand impact immediately.

---

# 🛡 WHY WE NEED AUTO SCALING

Service used:
Auto Scaling Group

Explain:

Instead of 1 worker:

We use 5 workers.

If 1 dies:
ASG automatically launches new one.

Queue keeps tasks safe.

Processing continues.

This is:

High Availability.

---

# 🎯 WHEN DO WE NEED ALB?

Service used:
Elastic Load Balancing

ALB is for:

Users watching movies.

User → ALB → Web servers

But workers pulling from SQS do NOT need ALB.

Two different traffic types:

* Web traffic → ALB
* Queue traffic → ASG only

---

# 🎓 SIMPLE FINAL STORY

Tell them this:

> S3 stores the movie.
> SNS announces it.
> SQS remembers the task.
> EC2 workers process it.
> ASG keeps workers alive.
> ALB serves users.

That’s it.

---

# 🏁 FINAL PRODUCTION NETFLIX ARCHITECTURE

![Image](https://d2908q01vomqb2.cloudfront.net/972a67c48192728a34979d9a35164c1295401b71/2020/07/31/Netflix-SC-Architecture-Diagram-1260x613.png)

![Image](https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/product-categories/media-services/approved/images/91724e4c-5a1e-4130-b0b2-4f3a2b8059e4-aws-media-extraction-dynamic-content-policy-architecture-diagram-2941x1657.c5077ad300602d579dfdf701245c5b2837d5375d.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1200/1%2AZ-DC516_NPhaBhs3o0VXVg.png)

![Image](https://cloudbuilders.io/assets/1_1752735881232-WSOCo1qg.png)

Flow:

User
→ ALB
→ Web ASG
→ S3
→ SNS
→ SQS
→ Worker ASG

This is real enterprise architecture.








# 🚀 COMPLETE END-TO-END LAB

# S3 → SNS → SQS → EC2 Worker Architecture

---

# 🟢 PART 1 — Open Image in Browser from S3

Service used:
Amazon S3

---

## STEP 1 — Bucket Setup

Bucket name:

```
student-upload-bucket-aj
```

Region:

```
us-east-2
```

---

## STEP 2 — Disable Block Public Access (Demo Only)

Go to:

S3 → Bucket → Permissions → Block Public Access → Edit

Uncheck:

```
Block all public access
```

Save.

---

## STEP 3 — Add Bucket Policy (Public Read)

S3 → Bucket → Permissions → Bucket Policy

Paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::student-upload-bucket-aj/*"
    }
  ]
}
```

Save.

---

## STEP 4 — Upload Image

```bash
aws s3 cp myimage.jpg s3://student-upload-bucket-aj/uploads/myimage.jpg
```

---

## STEP 5 — Open in Browser

Use:

```
https://student-upload-bucket-aj.s3.us-east-2.amazonaws.com/uploads/myimage.jpg
```

Now image loads.

---


Viewing flow:

Browser → S3

No EC2 involved.








# 🟢 PART 6 — Demonstrate System Working

On EC2 #2:

```bash
echo "demo test" > test1.txt
aws s3 cp test1.txt s3://student-upload-bucket-aj/uploads/test1.txt
```

On EC2 #1 (Worker):

You should see:

```
Processing: uploads/test1.txt
Moved to: processed/test1.txt
```

Check:

```bash
aws s3 ls s3://student-upload-bucket-aj/processed/
```

File exists.

---

# 🔴 PART 7 — Demonstrate Failure

On EC2 #1:

```bash
pkill -f worker.py
```

Worker is stopped.

Now upload from EC2 #2:

```bash
echo "after kill demo" > fail.txt
aws s3 cp fail.txt s3://student-upload-bucket-aj/uploads/fail.txt
```

Check uploads:

```bash
aws s3 ls s3://student-upload-bucket-aj/uploads/
```

File stays there.

Check SQS:

```bash
aws sqs receive-message \
  --queue-url https://sqs.us-east-2.amazonaws.com/ACCOUNT-ID/devops-sqs-queue \
  --region us-east-2 \
  --max-number-of-messages 1
```

Message waiting.

---

# 🎯 Explain What Happened

* S3 worked
* SNS worked
* SQS stored message
* Worker EC2 failed
* Processing stopped

This is:

Single Point of Failure

---

# 🟢 PART 8 — Restart Worker

On EC2 #1:

```bash
python3 worker.py
```

It immediately processes:

```
Processing: uploads/fail.txt
Moved to: processed/fail.txt
```

This proves:

SQS keeps messages safely.

---

# 🏗 High Availability Discussion

For queue-based systems:

Use
Auto Scaling Group

Architecture becomes:

S3 → SNS → SQS → ASG (2+ workers)

If one worker dies:

ASG launches new one automatically.

No downtime.

---

# ❓ When Do We Use ALB?

Use
Elastic Load Balancing

Only when users connect to EC2 via HTTP.

Example:

User → ALB → EC2 Web Servers

Your lab is queue-based.

So:

✔ Need ASG
✖ Do NOT need ALB

---

# 🎓 Final Architecture

Viewing Flow:
Browser → S3

Processing Flow:
S3 → SNS → SQS → EC2 Worker

High Availability:
S3 → SNS → SQS → Auto Scaling Group Workers























# 🔥 FIRST — Important Understanding

Your system is **queue-based**, not web-based.

So:

✔ ASG is required
❌ ALB is NOT required for workers

ALB is only needed if users send HTTP traffic to EC2.

---

# 🏗 Final Production Architecture

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AOYabjH45N3YL7gLtEAIFSg.png)

![Image](https://docs.particular.net/architecture/aws/images/aws-queue-based-architecture.png)

![Image](https://media2.dev.to/dynamic/image/width%3D800%2Cheight%3D%2Cfit%3Dscale-down%2Cgravity%3Dauto%2Cformat%3Dauto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fu27i59r2gv47xkow0fpj.png)

![Image](https://d2908q01vomqb2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2017/06/19/CustomOrderQueue-1024x632.png)

Flow:

Browser → S3
S3 → SNS → SQS
SQS → Auto Scaling Group (2+ EC2 workers)

---

# 🟢 PART 1 — Convert Worker EC2 into Launch Template

Service used:
Amazon EC2

---

## Step 1 — Stop current worker EC2

We will use it as template.

---

## Step 2 — Create Launch Template

EC2 → Launch Templates → Create launch template

Use:

* Same AMI
* Same instance type
* Same IAM Role
* Same Security Group
* Same Key pair

---

## Step 3 — Add User Data (VERY IMPORTANT)

We must automatically start worker when instance launches.

In Launch Template → User Data → paste:

```bash
#!/bin/bash
apt update -y
apt install python3-pip -y
pip3 install boto3

cat <<EOF > /home/ubuntu/worker.py
# (paste your full worker.py code here)
EOF

chown ubuntu:ubuntu /home/ubuntu/worker.py
su - ubuntu -c "nohup python3 /home/ubuntu/worker.py > worker.log 2>&1 &"
```

Now every new EC2 automatically runs worker.

---

# 🟢 PART 2 — Create Auto Scaling Group

Service used:
Auto Scaling Group

---

## Step 1 — Create ASG

EC2 → Auto Scaling Groups → Create

Select:

Launch Template you created

Choose:

* At least 2 Availability Zones
* Min: 2
* Desired: 2
* Max: 4

No load balancer needed.

Create.

---

## Step 2 — Test It

Upload file:

```bash
aws s3 cp test.txt s3://student-upload-bucket-aj/uploads/test.txt
```

Check EC2 logs:

Both instances may process files.

---

# 🔴 PART 3 — Demonstrate Self-Healing

Terminate one instance manually.

ASG will:

* Detect unhealthy instance
* Launch new one automatically

Upload file again.

Processing continues.

This proves:

High availability.

---

# 🟡 When Do We Add ALB?

Service used:
Elastic Load Balancing

Add ALB only if:

You create a web application like:

User → EC2 web server

Then architecture becomes:

User → ALB → ASG → EC2 Web Servers

---

# 🎯 Example If You Want Web + Worker Combined

Architecture:

User → ALB → ASG (Web Servers)
S3 → SNS → SQS → ASG (Worker Servers)

Two separate ASGs.

---

# 🧠 Explain To Students

Queue-based system:

* No ALB required
* Workers pull messages

Web-based system:

* ALB required
* Traffic distributed

---

# 🚀 Advanced (Optional)

Add scaling policy:

Scale based on SQS metric:

ApproximateNumberOfMessagesVisible

If queue > 10 → Add instance

This is real production design.

---

# 🎓 Interview-Level Explanation

> We deployed worker instances inside an Auto Scaling Group across multiple AZs to ensure fault tolerance and scalability. Since the system was queue-driven and did not handle direct HTTP traffic, an Application Load Balancer was not required.


