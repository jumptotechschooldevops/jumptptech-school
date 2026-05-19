---
title: "AWS ECS Lab"
description: "Deploy Nginx Container Using Amazon ECS (Fargate)            Objective   In this lab we will..."
published: 2026-03-04
source: "https://dev.to/jumptotech/aws-ecs-lab-18li"
tags: []
---

# AWS ECS Lab





## Deploy Nginx Container Using Amazon ECS (Fargate)

### Objective

In this lab we will deploy a **Docker container** to **Amazon ECS (Elastic Container Service)** using **AWS Fargate** and access it from a **web browser**.

---

# What is Amazon ECS

**Amazon ECS (Elastic Container Service)** is a container orchestration service that allows you to run and scale Docker containers on AWS.

It manages:

* container deployment
* scaling
* networking
* load balancing
* monitoring

ECS can run containers using two compute options:

| Option      | Description                                 |
| ----------- | ------------------------------------------- |
| **Fargate** | Serverless containers (AWS manages servers) |
| **EC2**     | You manage EC2 instances                    |

In this lab we use:

```
AWS Fargate
```

because AWS manages the infrastructure.

---

# Architecture of This Lab

```
Internet
   ↓
Public IP
   ↓
ECS Service
   ↓
Fargate Task
   ↓
Docker Container (nginx)
```

Components used:

* ECS Cluster
* Task Definition
* ECS Service
* Fargate Compute
* Docker Container

---

# Step 1 — Open ECS

1. Log in to **AWS Console**
2. In the search bar type:

```
ECS
```

3. Open:

```
Elastic Container Service
```

---

# Step 2 — Create ECS Cluster

Clusters are logical groups where containers run.

Go to:

```
Clusters
```

Click:

```
Create Cluster
```

Fill the configuration:

Cluster name

```
jump-ecs-cluster
```

Infrastructure

```
Fargate only
```

Click:

```
Create
```

AWS will create the cluster.

---

# Step 3 — Create Task Definition

A **Task Definition** is a blueprint that tells ECS:

* what container image to run
* how much CPU and memory to use
* what ports to open

Go to:

```
Task definitions
```

Click:

```
Create new task definition
```

Configure the following.

---

## Task Definition Configuration

Task definition family

```
jump-nginx-task
```

Launch type

```
AWS Fargate
```

Operating system

```
Linux / X86_64
```

Network mode

```
awsvpc
```

---

## Task Size

Set the resources for the container.

CPU

```
0.25 vCPU
```

Memory

```
0.5 GB
```

---

## Task Execution Role

Click:

```
Create default role
```

AWS will create:

```
ecsTaskExecutionRole
```

This role allows ECS to:

* pull container images
* send logs to CloudWatch

---

# Step 4 — Add Container

Scroll to **Container configuration**.

Container name

```
nginx-container
```

Image URI

```
nginx
```

This pulls the public Docker image.

---

## Port Mapping

Add port mapping.

Container port

```
80
```

Protocol

```
TCP
```

---

# Step 5 — Enable Logging

Enable log collection.

Destination

```
CloudWatch
```

---

# Step 6 — Create Task Definition

Click:

```
Create
```

The task definition is now saved.

Important:

A **task definition does NOT run a container**.

It is only a **template**.

---

# Step 7 — Create ECS Service

Now we run the container.

Go to:

```
Clusters
```

Open your cluster.

```
jump-ecs-cluster
```

Click:

```
Create Service
```

---

## Service Configuration

Launch type

```
FARGATE
```

Task definition

```
jump-nginx-task
```

Service name

```
nginx-service
```

Desired tasks

```
1
```

---

# Step 8 — Configure Networking

Select:

VPC

```
Default VPC
```

Subnets

```
Public subnets
```

Enable:

```
Auto assign public IP
```

Security Group rule:

```
HTTP
Port 80
Source 0.0.0.0/0
```

---

# Step 9 — Deploy Service

Click:

```
Create Service
```

AWS will now:

* pull nginx image
* start the container
* attach networking
* assign public IP

Deployment takes about **30–60 seconds**.

---

# Step 10 — Find Public IP

Go to:

```
Cluster
→ Service
→ Tasks
```

Click the **Task ID**.

Scroll to **Networking**.

You will see:

```
Public IP
```

Example:

```
18.188.200.132
```

---

# Step 11 — Open in Browser

Open your browser and type:

```
http://PUBLIC-IP
```

Example:

```
http://18.188.200.132
```

You should see:

```
Welcome to nginx
```

This means the container is working.

---

# What We Built

We deployed a Docker container using ECS.

Final architecture:

```
Internet
   ↓
Public IP
   ↓
ECS Service
   ↓
Fargate Task
   ↓
nginx container
```

---

# Important DevOps Notes

In production environments we usually use:

```
Internet
   ↓
Application Load Balancer
   ↓
ECS Service
   ↓
Multiple Fargate Tasks
   ↓
Containers
```

Advantages:

* high availability
* auto scaling
* zero downtime deployments
* DNS instead of IP

---

# Key ECS Components

| Component       | Purpose                            |
| --------------- | ---------------------------------- |
| Cluster         | logical environment for containers |
| Task Definition | container blueprint                |
| Task            | running container                  |
| Service         | keeps tasks running                |
| Fargate         | serverless container compute       |


