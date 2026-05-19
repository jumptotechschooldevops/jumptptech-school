---
title: "AWS Integration & Messaging using SNS + SQS"
description: "Lab: SNS → SQS Fanout            Part A — Create SNS Topic (Standard)            1) Open..."
published: 2026-02-21
source: "https://dev.to/jumptotech/aws-integration-messaging-using-sns-sqs-4lfo"
tags: []
---

# AWS Integration & Messaging using SNS + SQS



# Lab: SNS → SQS Fanout 

## Part A — Create SNS Topic (Standard)

### 1) Open SNS

1. AWS Console search bar → type **SNS**
2. Click **Simple Notification Service**

### 2) Create Topic

3. Left menu → **Topics**
4. Click **Create topic**

### 3) Configure Topic

5. **Type** → select **Standard**
6. **Name** → `devops-sns-topic`
7. Leave everything else default
8. Click **Create topic**

### 4) Copy Topic ARN

9. On topic page → copy **ARN**
10. Save it:

* `SNS_TOPIC_ARN = arn:aws:sns:us-east-2:021399177326:devops-sns-topic`

---

## Part B — Create SQS Queue (Standard)

### 5) Open SQS

11. AWS Console search bar → type **SQS**
12. Click **Simple Queue Service**

### 6) Create Queue

13. Click **Create queue**

### 7) Configure Queue

14. **Type** → select **Standard**
15. **Name** → `devops-sqs-queue`
16. Keep defaults for all Configuration fields
17. Encryption → leave default (your queue shows **SSE-SQS** enabled by AWS-managed key — that’s fine)
18. Access policy → leave default (owner-only)
19. DLQ / Redrive → leave disabled
20. Click **Create queue**

### 8) Copy Queue ARN + URL

21. Open the queue: click **devops-sqs-queue**
22. Copy **ARN** and **URL**
23. Save them:

* `SQS_QUEUE_ARN = arn:aws:sqs:us-east-2:021399177326:devops-sqs-queue`
* `SQS_QUEUE_URL = https://sqs.us-east-2.amazonaws.com/021399177326/devops-sqs-queue`

---

## Part C — Subscribe SQS to SNS

### 9) Go to SNS Topic

24. Go back to **SNS**
25. Click **Topics**
26. Click **devops-sns-topic**

### 10) Create Subscription

27. Scroll to **Subscriptions**
28. Click **Create subscription**

### 11) Subscription Settings

29. **Topic ARN** should already be filled
30. **Protocol** → select **Amazon SQS**
31. **Endpoint** → paste your queue ARN:

* `arn:aws:sqs:us-east-2:021399177326:devops-sqs-queue`

32. Click **Create subscription**

✅ After this you should see:

* **Subscriptions (1)**
* Protocol: **Amazon SQS**
* Status: usually **Confirmed**

---

## Part D — Allow SNS to Send Messages into SQS (Required)

If you skip this, messages often do **not** arrive.

### 12) Open SQS Queue Permissions

33. Go to **SQS**
34. Click **Queues**
35. Click **devops-sqs-queue**

### 13) Edit Access Policy

36. Scroll to **Access policy**
37. Click **Edit**
38. Choose **Advanced** (JSON)

### 14) Paste Policy (Use your real ARNs)

39. Replace the policy with this (exact values you have):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow-SNS-SendMessage",
      "Effect": "Allow",
      "Principal": { "Service": "sns.amazonaws.com" },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:us-east-2:021399177326:devops-sqs-queue",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:sns:us-east-2:021399177326:devops-sns-topic"
        }
      }
    }
  ]
}
```

40. Click **Save changes**

---

## Part E — Publish Message to SNS

### 15) Open SNS Topic Again

41. Go to **SNS → Topics**
42. Click **devops-sns-topic**

### 16) Publish Message

43. Click **Publish message**
44. Subject (optional): `test-message`
45. Message body:

```
Hello students!
SNS published this message.
SQS will store it until consumer reads it.
```

46. Click **Publish message**

---

## Part F — Receive Message from SQS

### 17) Open Queue to Read Messages

47. Go to **SQS → Queues**
48. Click **devops-sqs-queue**

### 18) Poll for Messages

49. Click **Send and receive messages**
50. Click **Poll for messages**
51. You should see the message appear

### 19) View Message Body

52. Click the message
53. Expand details
54. You will see SNS wraps the message in JSON (this is normal)

### 20) Delete Message

55. Select the message checkbox
56. Click **Delete**
57. Confirm **Delete**

---

# What Students Must Learn (Short)

## SNS (Topic)

* “I publish 1 message”
* “Many systems can receive it” (fanout)

## SQS (Queue)

* “I store messages safely”
* “Consumer can read later”
* Prevents loss if consumer is down

## Together

* Producer and consumer are decoupled
* More reliable and scalable systems

---

# Quick Troubleshooting (Fast Checks)

1. **No messages in SQS**

* Confirm you added SQS Access policy allowing SNS
* Confirm **topic ARN** in policy matches exactly
* Confirm SNS + SQS are in **same region** (us-east-2)

2. **Subscription exists but still nothing**

* Open subscription → verify it points to correct queue ARN
* Republish message
* Poll again

---

# Cleanup (Optional)

* SNS Topic → Subscriptions → delete subscription
* Delete SNS topic
* Delete SQS queue


