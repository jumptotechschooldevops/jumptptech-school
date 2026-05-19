# Lecture 7 · Serverless & Containers

Serverless means you run code without managing servers. You deploy a function, AWS handles everything else: provisioning, scaling, patching, availability. Containers on AWS sit between EC2 (full control) and serverless (no control) — you manage the application packaging, AWS manages the cluster.

---

## Lambda

Lambda runs your code in response to events. You pay only for the time your code runs (in 1ms increments). It scales automatically from zero to thousands of concurrent executions.

### Core concepts

- **Function**: your code + a runtime (Python, Node.js, Java, Go, Ruby, .NET, or custom)
- **Handler**: the entry point function Lambda calls
- **Event**: the trigger data passed to your function
- **Execution environment**: the container Lambda provisions for your function (128 MB – 10 GB RAM, up to 15 minutes)

### A minimal Lambda function

```python
import json
import boto3

s3 = boto3.client('s3')

def handler(event, context):
    # event contains trigger-specific data
    bucket = event['Records'][0]['s3']['bucket']['name']
    key    = event['Records'][0]['s3']['object']['key']
    
    response = s3.get_object(Bucket=bucket, Key=key)
    content  = response['Body'].read().decode('utf-8')
    
    print(f"Processing {key} from {bucket}: {len(content)} bytes")
    
    return {
        'statusCode': 200,
        'body': json.dumps({'processed': key})
    }
```

### Triggers (event sources)

| Trigger | Pattern |
|---------|---------|
| API Gateway / Function URL | HTTP request → Lambda |
| S3 | Object created/deleted → Lambda |
| DynamoDB Streams | Table change → Lambda |
| SQS | Message in queue → Lambda (batch) |
| SNS | Notification → Lambda |
| EventBridge | Scheduled or event-driven → Lambda |
| Kinesis | Data stream record → Lambda |
| CloudWatch Logs | Log subscription filter → Lambda |
| ALB | HTTP request → Lambda (target group) |

### Permissions

Lambda needs two types of permissions:

1. **Execution role** (IAM role): what the function can do (e.g., read from S3, write to DynamoDB)
2. **Resource-based policy**: who can invoke this function (e.g., S3 service, API Gateway)

```bash
# Create execution role
aws iam create-role \
  --role-name my-function-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach basic execution policy (CloudWatch Logs)
aws iam attach-role-policy \
  --role-name my-function-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Deploy function
aws lambda create-function \
  --function-name process-uploads \
  --runtime python3.12 \
  --role arn:aws:iam::123456789012:role/my-function-role \
  --handler app.handler \
  --zip-file fileb://function.zip \
  --timeout 30 \
  --memory-size 512
```

### Cold starts

When Lambda hasn't run recently (or needs to scale out), it provisions a new execution environment — this takes 100ms to several seconds. This is a **cold start**.

Mitigation strategies:
- **Provisioned Concurrency**: pre-warm a configurable number of environments (costs money even when idle)
- Use lightweight runtimes (Python, Node.js) over JVM-based (Java, .NET) for latency-sensitive code
- Keep functions small — smaller deployment packages initialise faster
- Lambda SnapStart (Java): takes a snapshot after initialisation, restores on cold start (< 1s)

### Concurrency

- **Reserved concurrency**: guarantee a minimum number of concurrent executions are available; also caps the function's maximum concurrency (throttle protection)
- **Provisioned concurrency**: pre-initialised environments — no cold starts, but costs money

Default account limit: 1,000 concurrent executions across all functions in a region. Request a quota increase for production.

### Lambda Layers

A layer is a ZIP archive containing shared code, libraries, or data. Layers are attached to functions at deploy time and appear at `/opt` in the execution environment.

```bash
# Create a layer with dependencies
pip install requests -t python/lib/python3.12/site-packages/
zip -r dependencies.zip python/

aws lambda publish-layer-version \
  --layer-name common-dependencies \
  --zip-file fileb://dependencies.zip \
  --compatible-runtimes python3.12
```

Use layers to share common dependencies across multiple functions without bundling them into each deployment package.

---

## API Gateway

API Gateway is a managed HTTP API service. It handles routing, authentication, rate limiting, and integration with backend services.

### API types

| Type | Use case | Key features |
|------|---------|-------------|
| HTTP API | Modern REST APIs | Cheapest, low latency, JWT/OIDC auth, Lambda/HTTP integrations |
| REST API | Legacy or complex routing | Request/response transformation, API keys, caching, WAF support |
| WebSocket API | Real-time two-way communication | Chat, dashboards, gaming |

HTTP API is the default choice for new projects — it's simpler and cheaper than REST API.

### Integrations

```
Client → API Gateway → Lambda (most common)
                    → HTTP endpoint (proxy to existing service)
                    → AWS service (SQS, DynamoDB directly)
```

### Rate limiting and throttling

- **Default throttling**: 10,000 req/s per account per region, burst limit 5,000
- **Stage throttling**: set limits per API stage
- **Usage plans + API keys**: rate limit and quota specific clients

### CORS

When a browser calls your API from a different origin, it sends a preflight OPTIONS request. Configure CORS in API Gateway:

```bash
aws apigatewayv2 update-api \
  --api-id abc123 \
  --cors-configuration '{
    "AllowOrigins": ["https://myapp.com"],
    "AllowMethods": ["GET", "POST", "PUT", "DELETE"],
    "AllowHeaders": ["Content-Type", "Authorization"]
  }'
```

---

## SQS (Simple Queue Service)

SQS is a managed message queue for decoupling components. Producers send messages; consumers poll and process them.

### Queue types

**Standard queue**:
- Nearly unlimited throughput
- At-least-once delivery (duplicates possible)
- Best-effort ordering

**FIFO queue**:
- Exactly-once processing
- Strict ordering (within a message group)
- Max 3,000 messages/second (300 without batching)

### Key settings

| Setting | Meaning |
|---------|---------|
| Visibility timeout | How long a message is hidden after being received (default 30s). If processing fails, it reappears. |
| Message retention | 1 minute – 14 days (default 4 days) |
| Dead-letter queue | Where messages go after `maxReceiveCount` failures |
| Long polling | Wait up to 20 seconds for a message instead of returning empty immediately (reduces API calls and cost) |
| Batch size | Receive up to 10 messages per API call |

### Lambda integration

When SQS triggers Lambda, Lambda polls the queue and processes messages in batches. Failed batches retry the entire batch (unless you configure `reportBatchItemFailures`).

---

## SNS (Simple Notification Service)

SNS is a pub/sub messaging service. Publishers send to a **topic**; all **subscribers** receive a copy.

Subscribers can be: Lambda, SQS, HTTP/HTTPS, email, SMS, mobile push.

### Fan-out pattern

A common pattern: one event triggers multiple downstream processes:

```
S3 Event → SNS Topic → SQS Queue A → Lambda (resize image)
                     → SQS Queue B → Lambda (update search index)
                     → SQS Queue C → Lambda (send notification)
```

Without SNS, S3 can only trigger one destination. With SNS as the intermediary, it can fan out to many.

### SNS FIFO

Like SQS FIFO: ordering and deduplication. Only SQS FIFO queues can subscribe to SNS FIFO topics.

---

## EventBridge

EventBridge is an event bus that routes events from AWS services, your applications, and SaaS providers to targets.

```
Source (EC2 state change, S3 upload, custom app event)
    → EventBridge Rule (filter by event pattern)
    → Target (Lambda, SQS, Step Functions, API Gateway, ...)
```

### Scheduled rules

Run code on a schedule without EC2 or cron:

```bash
aws events put-rule \
  --name daily-report \
  --schedule-expression "cron(0 8 * * ? *)" \  # 8am UTC daily
  --state ENABLED

aws events put-targets \
  --rule daily-report \
  --targets '[{
    "Id": "1",
    "Arn": "arn:aws:lambda:us-east-1:123456789012:function:generate-report"
  }]'
```

---

## Containers on AWS

### ECS (Elastic Container Service)

ECS is AWS's managed container orchestration service. You define tasks (containers to run) and services (how many copies to maintain).

**Launch types**:

- **Fargate**: serverless containers — AWS manages the underlying EC2 instances. You specify vCPU and memory per task. No cluster management.
- **EC2**: you manage the EC2 instances that run containers. More control, more responsibility. Better for GPU workloads or custom instance configs.

### Task Definition

A task definition is a JSON blueprint for how to run containers:

```json
{
  "family": "web-app",
  "cpu": "512",
  "memory": "1024",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/myTaskRole",
  "containerDefinitions": [{
    "name": "web",
    "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.2.3",
    "portMappings": [{"containerPort": 8080, "protocol": "tcp"}],
    "environment": [{"name": "ENV", "value": "production"}],
    "secrets": [{
      "name": "DB_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/web-app",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "web"
      }
    }
  }]
}
```

### ECR (Elastic Container Registry)

ECR is AWS's managed Docker registry. Images are stored in ECR repositories and pulled by ECS, EKS, or Lambda.

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker build -t myapp:1.2.3 .
docker tag myapp:1.2.3 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.2.3
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:1.2.3
```

ECR scans images for vulnerabilities using Clair/Inspector. Enable automatic scanning on push.

### EKS (Elastic Kubernetes Service)

EKS is managed Kubernetes. If your team already uses Kubernetes, EKS is the path to AWS — you get standard Kubernetes APIs, kubectl, Helm, and the ecosystem.

Compared to ECS:
- ECS is AWS-native and simpler to operate
- EKS is Kubernetes-compatible and more portable

EKS also supports Fargate node groups — serverless Kubernetes pods.

!!! tip "Exam tip"
    For "no server management" questions: if it's a function → Lambda. If it's a container without managing servers → Fargate. If it's Kubernetes without managing control plane → EKS managed node groups. The exam distinguishes these clearly.

!!! tip "Exam tip"
    SQS vs SNS: SQS is a queue (pull model, one consumer processes each message). SNS is pub/sub (push model, multiple subscribers each get a copy). The fan-out pattern uses both: SNS topic → multiple SQS queues.

!!! tip "Exam tip"
    Lambda has a maximum execution time of **15 minutes**. If a scenario requires processing that takes longer, Lambda is the wrong answer — use ECS/Fargate or EC2 with a batch service.
