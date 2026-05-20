---
title: "Part 1: Decoupled Architecture"
description: "Students will SEE messages moving.              🎯 LAB: Event-Driven Image Processing Architecture    ..."
published: 2026-02-23
source: "https://dev.to/jumptotech/alb-asg-ec2-s3-sns-sqs-worker-ec2-2fbo"
tags: []
---

# Part 1: Decoupled Architecture





Students will SEE messages moving.

---

# 🎯 LAB: Event-Driven Image Processing Architecture

## What Students Will Build

User → ALB → EC2 (Web Tier) → S3
EC2 publishes event → SNS → SQS
Worker EC2 reads SQS → processes file → stores result in S3

---

# 🌐 Final Architecture

![Image](https://docs.aws.amazon.com/images/autoscaling/ec2/userguide/images/elb-tutorial-architecture-diagram.png)

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2A9z3sbaE6yGT1Ukau8iq4ew.png)

![Image](https://d2908q01vomqb2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2023/02/22/multipartupload.png)

![Image](https://d2908q01vomqb2.cloudfront.net/e1822db470e60d090affd0956d743cb0e7cdf113/2020/11/06/Example-S3-object-processing-solution-1.png)

---

# 🟢 PHASE 1 — Create S3 Bucket

### Step 1 — Open S3

1. AWS Console → search **S3**
2. Click **Create bucket**

### Step 2 — Configure

Bucket name:

```
student-upload-bucket-<yourname>
```

Region:

```
us-east-2
```

Uncheck:

```
Block all public access
```

Check confirmation box.

Click:

```
Create bucket
```

---

# 🟢 PHASE 2 — Create SNS Topic

1. Search **SNS**
2. Click **Create topic**
3. Type: **Standard**
4. Name:

```
file-upload-topic
```

5. Click **Create topic**
6. Copy ARN → save it

---

# 🟢 PHASE 3 — Create SQS Queue

1. Search **SQS**
2. Click **Create queue**
3. Type: **Standard**
4. Name:

```
file-processing-queue
```

5. Click **Create queue**
6. Copy ARN

---

# 🟢 PHASE 4 — Subscribe SQS to SNS

1. Go back to SNS
2. Click topic: `file-upload-topic`
3. Click **Create subscription**
4. Protocol: **Amazon SQS**
5. Endpoint: paste SQS ARN
6. Click **Create subscription**

---

# 🟢 PHASE 5 — Allow SNS → SQS

1. Go to SQS → file-processing-queue
2. Click **Edit access policy**
3. Choose **Advanced**
4. Paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow-SNS",
      "Effect": "Allow",
      "Principal": { "Service": "sns.amazonaws.com" },
      "Action": "sqs:SendMessage",
      "Resource": "YOUR_SQS_ARN",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "YOUR_SNS_ARN"
        }
      }
    }
  ]
}
```

Replace ARNs.

Save.

---

# 🟢 PHASE 6 — Create Web EC2 (Publisher)

1. Go to EC2
2. Click **Launch Instance**

Name:

```
web-server
```

AMI:

```
Amazon Linux 2
```

Instance type:

```
t2.micro
```

Create key pair.

Security Group:
Allow:

* HTTP (80)
* SSH (22)

Click Launch.

---

# 🟢 PHASE 7 — Install Web App

SSH into instance:

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo yum install aws-cli -y
```

Create upload page:

```bash
sudo nano /var/www/html/index.html
```

Paste:

```html
<h1>Upload Simulation</h1>
<form method="POST" action="/upload">
<input type="text" name="filename" placeholder="Enter file name">
<button type="submit">Upload</button>
</form>
```

Save.

---

# 🟢 PHASE 8 — Install Python Publisher Script

```bash
sudo yum install python3 -y
nano publisher.py
```

Paste:

```python
import boto3
sns = boto3.client('sns', region_name='us-east-2')

response = sns.publish(
    TopicArn='YOUR_TOPIC_ARN',
    Message='File uploaded: test-image.png'
)
print("Message sent")
```

Replace ARN.

Run:

```bash
python3 publisher.py
```

It will send event to SNS.

---

# 🟢 PHASE 9 — Create Worker EC2

Launch second instance:

Name:

```
worker-server
```

Install Python + AWS CLI.

---

# 🟢 PHASE 10 — Worker Script (Consumer)

On worker:

```bash
nano worker.py
```

Paste:

```python
import boto3
import time

sqs = boto3.client('sqs', region_name='us-east-2')

queue_url = 'YOUR_QUEUE_URL'

while True:
    messages = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=5
    )

    if 'Messages' in messages:
        for message in messages['Messages']:
            print("Processing:", message['Body'])
            sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=message['ReceiptHandle']
            )
    time.sleep(3)
```

Replace Queue URL.

Run:

```bash
python3 worker.py
```

Now it polls continuously.

---

# 🟢 PHASE 11 — Test Flow

1. Run publisher on web server.
2. Worker prints:

```
Processing: File uploaded: test-image.png
```

Students will SEE event-driven processing live.

---

# 🟢 OPTIONAL — Add ALB + ASG

Create:

* Target Group
* Launch Template
* Auto Scaling Group
* Application Load Balancer

Attach web-server template to ASG.

Now traffic hits ALB.

---

# 🎓 What Students Learn

• Decoupling architecture
• Event-driven systems
• Async processing
• Worker scaling
• Production DevOps pattern




