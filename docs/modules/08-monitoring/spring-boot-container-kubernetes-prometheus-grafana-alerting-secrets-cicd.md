---
title: "Spring Boot Container Kubernetes Prometheus Grafana Alerting Secrets CI/CD"
description: "TOOLS YOU WILL INSTALL (with brew)      Tool Purpose     Homebrew Package manager   Java..."
published: 2025-10-31
source: "https://dev.to/jumptotech/spring-boot-container-kubernetes-prometheus-grafana-alerting-secrets-cicd-5d05"
tags: []
---

# Spring Boot Container Kubernetes Prometheus Grafana Alerting Secrets CI/CD




## **TOOLS YOU WILL INSTALL (with brew)**

| Tool                 | Purpose                        |
| -------------------- | ------------------------------ |
| Homebrew             | Package manager                |
| Java (Temurin)       | Runs Spring Boot               |
| Maven                | Builds the app                 |
| Kind                 | Local Kubernetes Cluster       |
| Kubectl              | Kubernetes CLI                 |
| Docker               | Container Runtime              |
| Helm                 | Package Manager for Kubernetes |
| Prometheus + Grafana | Observability Stack            |

---

## **STEP 1 — Install Required Tools**

Run on your **Mac Terminal**:

```bash
brew update
brew install temurin
brew install maven
brew install kubectl
brew install helm
brew install kind
```

**Verify:**

```bash
java -version
mvn -version
kubectl version --client
helm version
kind version
```

**Expected Output (What You Learn):**

* If version prints → tools installed correctly.
* You learn **how developer tooling layers stack together**.

---

## **STEP 2 — Create Kubernetes Cluster (Locally)**

```bash
kind create cluster --name devops-lab
```

**Verify Cluster:**

```bash
kubectl get nodes
```

**Expected Output:**

```
NAME           STATUS   ROLES                  AGE   VERSION
devops-lab     Ready    control-plane,master   10s   v1.28
```

**What You Learn:**

* Kubernetes is just another container (Kind runs it inside Docker).
* You don’t need AWS to start learning Kubernetes.

---

## **STEP 3 — Create Sample Spring Boot App With Metrics**

Run:

```bash
mkdir spring-metrics-app && cd spring-metrics-app
mvn archetype:generate -DgroupId=com.demo -DartifactId=metricsapp -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd metricsapp
```

Add **Micrometer + Actuator** dependencies to `pom.xml`:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<dependency>
  <groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Add to `application.properties`:

```
management.endpoints.web.exposure.include=*
management.endpoint.prometheus.enabled=true
```

**Run App:**

```bash
mvn spring-boot:run
```

**Test App:**

```
http://localhost:8080/actuator/prometheus
```

**Expected Output:**

* A long text page of metrics values.

**What You Learn:**

* Spring Boot automatically instruments JVM, Memory, HTTP.
* Micrometer **standardizes metrics** → Prometheus understands them.

---

## **STEP 4 — Containerize the App**

Create Dockerfile:

```dockerfile
FROM eclipse-temurin:17-jdk
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

Build Container:

```bash
mvn package
docker build -t spring-metrics-app:1.0 .
```

**Verify:**

```bash
docker run -p 8080:8080 spring-metrics-app:1.0
```

**What You Learn:**

* **Container ≠ VM** → It packages only the app environment.

---

## **STEP 5 — Deploy App Into Kubernetes**

Create Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
      - name: spring-app
        image: spring-metrics-app:1.0
        ports:
        - containerPort: 8080
```

Apply:

```bash
kubectl apply -f deployment.yaml
kubectl get pods
```

**What You Learn:**

* Kubernetes schedules pods.
* Declarative infrastructure model.

---

## **STEP 6 — Install Prometheus + Grafana**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-stack prometheus-community/kube-prometheus-stack
```

Get Grafana Password:

```bash
kubectl get secret --namespace default kube-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

Port-forward Grafana:

```bash
kubectl port-forward svc/kube-stack-grafana 3000:80
```

Open Browser:

```
http://localhost:3000
```

Login:

```
user: admin
pass: (password above)
```

**What You Learn:**

* Grafana connects to Prometheus automatically.
* You can visualize live CPU, RAM, request latency, error rates.

---

## **STEP 7 — What You Learned (Interview Language)**

Say this in interviews:

> I containerized a Spring Boot service, deployed it to Kubernetes, exposed Prometheus metrics using Micrometer, and visualized application and cluster performance through Grafana dashboards. I understand how observability detects performance bottlenecks across microservices.

---

## **STEP 8 — After This, We Upgrade to AWS**

When you're ready, we:
✅ Replace Kind → EKS
✅ Replace local Docker → ECR
✅ Replace local config → AWS Secrets Manager
✅ Add Jenkins CI/CD to deploy automatically






This step teaches **secure runtime secret access** in Kubernetes **without putting secrets in YAML**.

This is **very important for interviews** because it shows:

* **No plaintext secrets**
* **No .env files**
* **No Kubernetes secrets base64**
* **Proper cloud-native authentication**

---

# **Goal of This Part**

Your Spring Boot app **reads a secret from AWS Secrets Manager** using **IAM role**, not username/password stored in code.

We will do this in **3 phases**:

| Phase | Environment   | Purpose                                                                  |
| ----- | ------------- | ------------------------------------------------------------------------ |
| 1     | Local Mac     | Understand how app reads secrets                                         |
| 2     | Minikube/Kind | Understand pod identity model                                            |
| 3     | AWS EKS       | Use **IRSA** (IAM Role for Service Account) to retrieve secrets securely |

We start with **Local Testing** so learning is clear.

---

## **PHASE 1 — LOCAL SECRET RETRIEVAL (Mac)**

### **1. Create a Secret in AWS Secrets Manager**

```bash
aws secretsmanager create-secret \
  --name demo-db-password \
  --secret-string "mypassword123"
```

**Verify Secret Exists:**

```bash
aws secretsmanager get-secret-value --secret-id demo-db-password
```

**Output Example:**

```
"SecretString": "mypassword123"
```

### **2. Add AWS SDK + Secrets Manager Client to Spring Boot**

Add to `pom.xml`:

```xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>secretsmanager</artifactId>
</dependency>
```

### **3. Create Service to Fetch Secret**

Create file: `SecretService.java`

```java
package com.demo.metricsapp;

import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import org.springframework.stereotype.Service;

@Service
public class SecretService {

    public String getSecret() {
        SecretsManagerClient client = SecretsManagerClient.builder().build();

        var request = GetSecretValueRequest.builder()
                .secretId("demo-db-password")
                .build();

        return client.getSecretValue(request).secretString();
    }
}
```

### **4. Add a Controller Endpoint to Test**

`TestController.java`:

```java
@RestController
public class TestController {

    @Autowired
    SecretService secretService;

    @GetMapping("/secret")
    public String showSecret() {
        return secretService.getSecret();
    }
}
```

### **5. Run Locally**

```bash
mvn spring-boot:run
```

Visit:

```
http://localhost:8080/secret
```

**Expected Output:**

```
mypassword123
```

**What You Learned:**

* App directly integrates with AWS Secrets Manager
* No secret stored in code, YAML, environment variables

---

## **PHASE 2 — UNDERSTAND POD IDENTITY (BEFORE AWS)**

Right now, the Spring app uses **your laptop IAM credentials**.

But inside Kubernetes, pods **don’t** have AWS identities by default.

We solve this using:

### **IRSA = IAM Role for Service Account**

This assigns AWS permissions **to the Kubernetes Service Account**, not to the node or container.

Think of it as:

```
Pod → Service Account → IAM Role → Secrets Manager Access
```

---

## **PHASE 3 — IMPLEMENT IRSA (IN AWS EKS)**

### **1. Create IAM Policy to Access Secrets**

Save as `secrets-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
```

Create policy:

```bash
aws iam create-policy \
  --policy-name SecretsManagerAccess \
  --policy-document file://secrets-policy.json
```

### **2. Create Service Account with IAM Role**

```bash
eksctl create iamserviceaccount \
  --name app-sa \
  --namespace default \
  --cluster devops-lab \
  --attach-policy-arn arn:aws:iam::<YOUR-AWS-ID>:policy/SecretsManagerAccess \
  --approve
```

### **3. Update Deployment to Use ServiceAccount**

Add to deployment YAML:

```yaml
spec:
  serviceAccountName: app-sa
```

Apply:

```bash
kubectl apply -f deployment.yaml
```

### **4. Verify It Works**

Inside pod:

```bash
kubectl exec -it <pod> -- curl http://localhost:8080/secret
```

**Expected Output (same as before):**

```
mypassword123
```

---

# **WHAT YOU LEARNED (SAY THIS IN INTERVIEW)**

> I implemented secure secret retrieval using AWS Secrets Manager. Instead of storing secrets in Kubernetes or config files, I used IRSA so the pod authenticates via IAM roles. This allows secret rotation and eliminates plaintext exposure. This is the cloud-native best practice for secret management.

This is **exactly** what senior DevOps / SRE engineers say.













We will create a **real production-ready pipeline** that:

1. **Builds** the Spring Boot App
2. **Runs tests**
3. **Builds a Docker image**
4. **Pushes the image to a registry**
5. **Deploys to Kubernetes** (the same cluster you created earlier)
6. **Verifies the deployment**

We will use:

* **GitHub** = Code storage + Webhooks
* **Jenkins** = Pipeline automation

This is exactly what companies expect.

---

# **STEP 1 — Install Jenkins (with brew)**

```bash
brew install jenkins-lts
brew services start jenkins-lts
```

Open Jenkins UI in browser:

```
http://localhost:8080
```

Get the admin password:

```bash
cat /usr/local/var/jenkins_home/secrets/initialAdminPassword
```

Create admin user → Continue with default plugins.

**What You Learned:**

* Jenkins runs as a service on your Mac
* Jenkins stores configuration under `/usr/local/var/jenkins_home`

---

# **STEP 2 — Install Required Jenkins Plugins**

In Jenkins UI:

```
Manage Jenkins → Manage Plugins → Available
```

Install:

* **Docker Pipeline**
* **Kubernetes CLI**
* **GitHub Integration**
* **Credentials Binding**

Restart Jenkins after install.

---

# **STEP 3 — Add Credentials to Jenkins**

Navigate:

```
Manage Jenkins → Manage Credentials → (Global)
```

Add:

| Name             | Type                | Description                              |
| ---------------- | ------------------- | ---------------------------------------- |
| `dockerhub-cred` | Username + Password | To push Docker images                    |
| `aws-cred`       | AWS Access Key      | If deploying to EKS later (optional now) |

---

# **STEP 4 — Create `Jenkinsfile` in Project Repo**

Inside your Spring Boot app repo, create:

**Jenkinsfile**

```groovy
pipeline {
  agent any

  environment {
    IMAGE_NAME = "spring-metrics-app"
    IMAGE_TAG = "v1"
  }

  stages {

    stage('Checkout') {
      steps {
        git 'https://github.com/yourusername/spring-metrics-app.git'
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
      }
    }

    stage('Push Image to Local Registry') {
      steps {
        sh "docker tag $IMAGE_NAME:$IMAGE_TAG localhost:5000/$IMAGE_NAME:$IMAGE_TAG"
        sh "docker push localhost:5000/$IMAGE_NAME:$IMAGE_TAG"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh "kubectl set image deployment/spring-app spring-app=localhost:5000/$IMAGE_NAME:$IMAGE_TAG"
      }
    }

  }
}
```

> **Note:** Here we use **local Docker registry** and **your existing `spring-app` deployment**, no AWS yet — simple and real.

---

# **STEP 5 — Run Jenkins Pipeline**

In Jenkins UI:

```
New Item → Pipeline → Name it spring-ci → OK
```

In Pipeline configuration:

```
Definition → Pipeline Script from SCM
SCM → Git
Repository URL → your GitHub repo URL
```

Save → Run **Build Now**

---

# **EXPECTED OUTPUT (VERY IMPORTANT)**

In Jenkins Console Log you want to see:

```
[INFO] BUILD SUCCESS
Successfully built image spring-metrics-app:v1
Pushed: localhost:5000/spring-metrics-app:v1
deployment.apps/spring-app image updated
Finished: SUCCESS
```

This means:

* Jenkins **built your app**
* Packaged Docker image
* Pushed to registry
* Updated Kubernetes deployment
* Kubernetes **rolled out new version automatically**

---

# **HOW TO VERIFY DEPLOYMENT**

```bash
kubectl get pods
kubectl describe deployment spring-app
kubectl logs -l app=spring-app
```

You should see **new pod with new image**.

---

# **WHAT YOU LEARNED (Interview Answer)**

> I implemented a CI/CD pipeline using Jenkins and GitHub. When code is pushed to GitHub, Jenkins automatically builds and tests the application, creates a Docker image, pushes it to a registry, and then updates the Kubernetes deployment. This provides consistent and automated application delivery with zero manual steps.

This is **exactly** what interviewers want to hear.













This is **advanced** but we will make it **very clear** and interview-strong.

We will **NOT** deploy to two regions yet — first we learn the **concept and workflow**.
Then we do step-by-step commands to actually build it.

---

# **What We Are Building**

We will run the same app in **two AWS regions**, example:

| Region        | Cluster        | Purpose                |
| ------------- | -------------- | ---------------------- |
| **us-east-1** | EKS Cluster #1 | Primary                |
| **us-west-2** | EKS Cluster #2 | Secondary / Redundancy |

Users connect through **Route 53**, which chooses the **nearest or fastest** region automatically.

```
User → Route53 → Nearest Region → App
```

If one region fails:

```
Route53 automatically reroutes traffic → Healthy Region
```

This is **High Availability** + **Low Latency** + **Failover**.

---

# **Why Companies Care & You Must Say This in Interviews**

> “I can deploy services in multiple regions for high availability.
> Route 53 latency-based routing ensures users automatically access the closest region,
> while each region reads secrets locally from AWS Secrets Manager for low-latency secure access.”

This answer **hits all the Essential Functions** of the job.

---

# **Step-by-Step Plan (We will execute each soon)**

### **STEP 1 — Deploy EKS Cluster in Region 1 (us-east-1)**

(using Terraform — we’ll generate config)

### **STEP 2 — Deploy EKS Cluster in Region 2 (us-west-2)**

(same Terraform, different provider block)

### **STEP 3 — Deploy your Spring Boot App & Prometheus/Grafana to both clusters**

You already have:

* Docker Image
* Deployment YAML

We just switch Kube context:

```
kubectl config use-context cluster-east
kubectl apply -f deployment.yaml

kubectl config use-context cluster-west
kubectl apply -f deployment.yaml
```

### **STEP 4 — expose both apps with public Load Balancer**

Kubernetes Service type:

```yaml
type: LoadBalancer
```

You will get two DNS names:

```
app-east.elb.amazonaws.com
app-west.elb.amazonaws.com
```

### **STEP 5 — Create **Route 53 Hosted Zone** for your domain**

Example:

```
mysite.cloud
```

### **STEP 6 — Create Two Records With **Latency Routing**

| Record Name        | Value                      | Routing Policy | Region    |
| ------------------ | -------------------------- | -------------- | --------- |
| `app.mysite.cloud` | app-east.elb.amazonaws.com | **Latency**    | us-east-1 |
| `app.mysite.cloud` | app-west.elb.amazonaws.com | **Latency**    | us-west-2 |

### **STEP 7 — Optional (Recommended):**

Enable **Health Checks**:

If region fails → Route 53 removes it → users auto move to healthy region.

---

# **Expected Behavior (This is the “Output” you asked for)**

### **User in Chicago**

```
app.mysite.cloud → us-east-1 cluster
Latency ~20ms
```

### **User in San Francisco**

```
app.mysite.cloud → us-west-2 cluster
Latency ~18ms
```

### **If us-east-1 cluster goes down**

```
app.mysite.cloud → automatically routed to us-west-2
No intervention required.
```

This is real production **resiliency**.

---

# **What You Will Say in Interview**

(You can literally copy/paste this line)

> “I configured Route 53 latency-based routing to direct users to the closest regional deployment, using EKS clusters in multiple regions. Each region retrieves its secrets from local Secrets Manager copies and is monitored with Prometheus + Grafana. If one region becomes unhealthy, Route 53 automatically fails over to the remaining healthy region.”

This makes you sound **senior**.














# 0) Prereqs (Mac, Homebrew)

```bash
# Tools
brew update
brew install awscli terraform kubectl helm jq

# (Optional) Nice to have
brew install direnv
```

**Expect:** version prints (`aws --version`, `terraform -version`, etc).
**Learn:** You can provision infra (Terraform), deploy (kubectl/Helm), and configure AWS (awscli).

---

# 1) AWS Setup

```bash
aws configure
# Enter Access Key/Secret, region: us-east-1, output: json
aws sts get-caller-identity
```

**Expect:** Your AWS account/ARN shows.
**Learn:** Your CLI is authenticated.

---

# 2) Terraform Project Scaffolding

```bash
mkdir -p multi-region-eks/{env,modules}
cd multi-region-eks
```

## 2.1 `providers.tf`

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "YOUR-UNIQUE-TF-STATE-BUCKET"
    key    = "multi-region-eks/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-state-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}
```

**Expect:** On first `terraform init`, backend is configured (create S3 bucket + DynamoDB table beforehand or change to local backend during first run).
**Learn:** **State** enables drift detection/rollbacks and multi-engineer safety.

> Quick bootstrap (once):
>
> ```bash
> aws s3 mb s3://YOUR-UNIQUE-TF-STATE-BUCKET --region us-east-1
> aws dynamodb create-table --table-name tf-state-locks \
>   --attribute-definitions AttributeName=LockID,AttributeType=S \
>   --key-schema AttributeName=LockID,KeyType=HASH \
>   --billing-mode PAY_PER_REQUEST --region us-east-1
> ```

## 2.2 Variables `variables.tf`

```hcl
variable "project"   { default = "mr-eks" }
variable "domain"    { description = "Your Route53 hosted zone, e.g. example.com" }
variable "subdomain" { default = "app" }
```

## 2.3 VPC + EKS (both regions) using official modules

> Keep it readable/minimal; production adds private subnets, NAT, etc.

`main.tf`

```hcl
locals {
  tags = { Project = var.project }
}

# --- VPC use1 ---
module "vpc_use1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = { aws = aws.use1 }

  name = "${var.project}-use1"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]
  public_subnets  = ["10.10.1.0/24","10.10.2.0/24"]

  enable_nat_gateway   = false
  map_public_ip_on_launch = true
  tags = local.tags
}

# --- EKS use1 ---
module "eks_use1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = { aws = aws.use1 }

  cluster_name    = "${var.project}-use1"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_use1.public_subnets
  vpc_id          = module.vpc_use1.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = local.tags
}

# --- VPC usw2 ---
module "vpc_usw2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = { aws = aws.usw2 }

  name = "${var.project}-usw2"
  cidr = "10.20.0.0/16"

  azs             = ["us-west-2a","us-west-2b"]
  public_subnets  = ["10.20.1.0/24","10.20.2.0/24"]

  enable_nat_gateway   = false
  map_public_ip_on_launch = true
  tags = local.tags
}

# --- EKS usw2 ---
module "eks_usw2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = { aws = aws.usw2 }

  cluster_name    = "${var.project}-usw2"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_usw2.public_subnets
  vpc_id          = module.vpc_usw2.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = local.tags
}
```

## 2.4 Secrets Manager (replicated per region)

```hcl
# East
resource "aws_secretsmanager_secret" "db_use1" {
  provider = aws.use1
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_use1_v" {
  provider      = aws.use1
  secret_id     = aws_secretsmanager_secret.db_use1.id
  secret_string = "MySecurePassword!"
}

# West
resource "aws_secretsmanager_secret" "db_usw2" {
  provider = aws.usw2
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_usw2_v" {
  provider      = aws.usw2
  secret_id     = aws_secretsmanager_secret.db_usw2.id
  secret_string = "MySecurePassword!"
}
```

**Expect:** Terraform creates identical secrets in both regions.
**Learn:** **Regional** secrets, **IaC-driven replication**.

## 2.5 Route 53 latency records

**Assumption:** You already have a **public hosted zone** for `var.domain`. Get its Zone ID:

```bash
aws route53 list-hosted-zones | jq -r '.HostedZones[] | [.Name,.Id] | @tsv'
```

Put this in `variables.tf` or `terraform.tfvars`:

```hcl
variable "zone_id" { description = "Hosted Zone ID for your domain" }
```

We’ll later fill the ELB hostnames after we deploy the Services. To keep it IaC, we can **data-source** the ELBs or do a two-phase apply (apply clusters, deploy Services, then apply R53). Below is the **record shape** you’ll use once you have LB DNS names:

```hcl
# Example values (replace after Services exist)
variable "lb_dns_use1" { default = "abc123.use1.elb.amazonaws.com" }
variable "lb_dns_usw2" { default = "xyz456.usw2.elb.amazonaws.com" }

resource "aws_route53_record" "latency_east" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"  # e.g. app.example.com
  type    = "CNAME"
  ttl     = 60
  set_identifier         = "east"
  latency_routing_policy { region = "us-east-1" }
  records = [var.lb_dns_use1]
}

resource "aws_route53_record" "latency_west" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  set_identifier         = "west"
  latency_routing_policy { region = "us-west-2" }
  records = [var.lb_dns_usw2]
}
```

**Plan/Apply**

```bash
terraform init
terraform plan
terraform apply
```

**Expect:** Two EKS clusters + VPCs + secrets created (R53 records come after LB DNS is known).
**Learn:** Multi-region infra is **declarative and reproducible**.

---

# 3) Configure `kubectl` contexts

```bash
aws eks --region us-east-1 update-kubeconfig --name mr-eks-use1
aws eks --region us-west-2 update-kubeconfig --name mr-eks-usw2
kubectl config get-contexts
```

**Expect:** Two contexts appear.
**Learn:** You can target **each region** easily.

---

# 4) Deploy the App + LB in both clusters

Create `k8s/` with these files:

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  labels: { app: spring-app }
spec:
  replicas: 2
  selector:
    matchLabels: { app: spring-app }
  template:
    metadata:
      labels: { app: spring-app }
    spec:
      serviceAccountName: app-sa   # for IRSA step later
      containers:
      - name: spring-app
        image: YOUR_ECR_OR_DOCKER_IMAGE:tag
        ports:
        - containerPort: 8080
        env:
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef: { name: app-config, key: region }
```

`service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-app
  labels: { app: spring-app }
spec:
  type: LoadBalancer
  selector:
    app: spring-app
  ports:
  - port: 80
    targetPort: 8080
```

`configmap.yaml` (distinct per region)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  region: us-east-1
```

**Apply East:**

```bash
kubectl config use-context arn:aws:eks:us-east-1:...:cluster/mr-eks-use1
kubectl apply -f k8s/configmap.yaml   # region=us-east-1
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get svc spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Copy the **LB DNS** → save as `lb_dns_use1` for Terraform.

**Apply West:** (edit `configmap.yaml` region to `us-west-2`)

```bash
kubectl config use-context arn:aws:eks:us-west-2:...:cluster/mr-eks-usw2
# update the file value to us-west-2 first
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get svc spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Copy the **LB DNS** → save as `lb_dns_usw2`.

**Expect:** Two external LoadBalancer DNS names.
**Learn:** The same manifest, **two regions**, consistent delivery.

---

# 5) Finish Route 53 latency routing (Terraform)

Put the two LB hostnames into `terraform.tfvars`:

```hcl
domain        = "YOUR_DOMAIN.com"
zone_id       = "ZXXXXXXXXXXXXX"
subdomain     = "app"
lb_dns_use1   = "XXXX.use1.elb.amazonaws.com"
lb_dns_usw2   = "YYYY.usw2.elb.amazonaws.com"
```

Then:

```bash
terraform apply
```

**Expect:** `app.YOUR_DOMAIN.com` resolves differently based on user location/latency.
**Learn:** **Latency-based routing** + **regional HA**.

---

# 6) Health checks + automatic failover (optional, recommended)

Add Route 53 health checks so a failing region is withdrawn:

```hcl
resource "aws_route53_health_check" "east" {
  fqdn              = var.lb_dns_use1
  type              = "HTTPS"
  resource_path     = "/actuator/health"
  regions           = ["us-east-1","us-west-2"]
  insufficient_data_health_status = "Unhealthy"
}

resource "aws_route53_health_check" "west" {
  fqdn              = var.lb_dns_usw2
  type              = "HTTPS"
  resource_path     = "/actuator/health"
  regions           = ["us-east-1","us-west-2"]
  insufficient_data_health_status = "Unhealthy"
}

resource "aws_route53_record" "latency_east" {
  # ... same as before
  health_check_id = aws_route53_health_check.east.id
}

resource "aws_route53_record" "latency_west" {
  # ... same as before
  health_check_id = aws_route53_health_check.west.id
}
```

**Expect:** If `/actuator/health` in East fails, traffic flows West.
**Learn:** **Self-healing routing** at the DNS layer.

---

# 7) Observability (Prometheus + Grafana) per region

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl config use-context ...use1
helm install mon prometheus-community/kube-prometheus-stack
kubectl config use-context ...usw2
helm install mon prometheus-community/kube-prometheus-stack
```

Port-forward Grafana in each region to view metrics:

```bash
kubectl port-forward svc/mon-grafana 3000:80
# Login and import JVM / Micrometer dashboards
```

**Expect:** Live CPU/memory/latency/error-rate per region.
**Learn:** **Compare regions**, spot **bottlenecks**, validate **SLOs/alerts**.

---

# 8) IRSA (secure secrets at runtime) per region (recap)

Use the EKS module’s IRSA output or create SA + IAM role that allows `secretsmanager:GetSecretValue` in each region. Update `Deployment` with `serviceAccountName: app-sa` and app code uses AWS SDK to fetch `${var.project}/db_password`.
**Expect:** `/secret` endpoint returns secret value (don’t expose in prod, demo only).
**Learn:** **No plaintext secrets** in YAML; **regional, low-latency** access.

---

# 9) What to say in interviews (script)

* **Reliability/Scalability:** “I deployed the same service in **us-east-1/us-west-2** EKS clusters, fronted by **Route 53 latency routing** with health checks for automatic failover.”
* **Observability:** “Each region exports **Micrometer** → **Prometheus** metrics, visualized in **Grafana** with dashboards for latency, error rate, resource usage.”
* **Security:** “App secrets live in **AWS Secrets Manager** per region. Pods assume an **IRSA** role; no secrets in code or ConfigMaps.”
* **Automation:** “Everything is **Terraform**: VPC, EKS, Secrets, Route 53. CI/CD pushes new images and rolls deployments safely.”
* **Performance:** “We compare regional dashboards to detect bottlenecks and scale node groups or tune app configs.”

---

## Expected Outputs (quick checklist)

* `terraform apply` → 2 EKS clusters + VPCs + Secrets created ✅
* `kubectl get svc spring-app` (both contexts) → external LB hostnames ✅
* `curl http://app.YOUR_DOMAIN.com/hello` → responds from nearest region ✅
* Kill pods in east → Route 53 routes to west within health check TTL ✅
* Grafana → live metrics (per region), JVM + HTTP dashboards ✅












# 0) Prereqs (Mac, Homebrew)

```bash
# Tools
brew update
brew install awscli terraform kubectl helm jq

# (Optional) Nice to have
brew install direnv
```

**Expect:** version prints (`aws --version`, `terraform -version`, etc).
**Learn:** You can provision infra (Terraform), deploy (kubectl/Helm), and configure AWS (awscli).

---

# 1) AWS Setup

```bash
aws configure
# Enter Access Key/Secret, region: us-east-1, output: json
aws sts get-caller-identity
```

**Expect:** Your AWS account/ARN shows.
**Learn:** Your CLI is authenticated.

---

# 2) Terraform Project Scaffolding

```bash
mkdir -p multi-region-eks/{env,modules}
cd multi-region-eks
```

## 2.1 `providers.tf`

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "YOUR-UNIQUE-TF-STATE-BUCKET"
    key    = "multi-region-eks/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-state-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}
```

**Expect:** On first `terraform init`, backend is configured (create S3 bucket + DynamoDB table beforehand or change to local backend during first run).
**Learn:** **State** enables drift detection/rollbacks and multi-engineer safety.

> Quick bootstrap (once):
>
> ```bash
> aws s3 mb s3://YOUR-UNIQUE-TF-STATE-BUCKET --region us-east-1
> aws dynamodb create-table --table-name tf-state-locks \
>   --attribute-definitions AttributeName=LockID,AttributeType=S \
>   --key-schema AttributeName=LockID,KeyType=HASH \
>   --billing-mode PAY_PER_REQUEST --region us-east-1
> ```

## 2.2 Variables `variables.tf`

```hcl
variable "project"   { default = "mr-eks" }
variable "domain"    { description = "Your Route53 hosted zone, e.g. example.com" }
variable "subdomain" { default = "app" }
```

## 2.3 VPC + EKS (both regions) using official modules

> Keep it readable/minimal; production adds private subnets, NAT, etc.

`main.tf`

```hcl
locals {
  tags = { Project = var.project }
}

# --- VPC use1 ---
module "vpc_use1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = { aws = aws.use1 }

  name = "${var.project}-use1"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]
  public_subnets  = ["10.10.1.0/24","10.10.2.0/24"]

  enable_nat_gateway   = false
  map_public_ip_on_launch = true
  tags = local.tags
}

# --- EKS use1 ---
module "eks_use1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = { aws = aws.use1 }

  cluster_name    = "${var.project}-use1"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_use1.public_subnets
  vpc_id          = module.vpc_use1.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = local.tags
}

# --- VPC usw2 ---
module "vpc_usw2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = { aws = aws.usw2 }

  name = "${var.project}-usw2"
  cidr = "10.20.0.0/16"

  azs             = ["us-west-2a","us-west-2b"]
  public_subnets  = ["10.20.1.0/24","10.20.2.0/24"]

  enable_nat_gateway   = false
  map_public_ip_on_launch = true
  tags = local.tags
}

# --- EKS usw2 ---
module "eks_usw2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = { aws = aws.usw2 }

  cluster_name    = "${var.project}-usw2"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_usw2.public_subnets
  vpc_id          = module.vpc_usw2.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = local.tags
}
```

## 2.4 Secrets Manager (replicated per region)

```hcl
# East
resource "aws_secretsmanager_secret" "db_use1" {
  provider = aws.use1
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_use1_v" {
  provider      = aws.use1
  secret_id     = aws_secretsmanager_secret.db_use1.id
  secret_string = "MySecurePassword!"
}

# West
resource "aws_secretsmanager_secret" "db_usw2" {
  provider = aws.usw2
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_usw2_v" {
  provider      = aws.usw2
  secret_id     = aws_secretsmanager_secret.db_usw2.id
  secret_string = "MySecurePassword!"
}
```

**Expect:** Terraform creates identical secrets in both regions.
**Learn:** **Regional** secrets, **IaC-driven replication**.

## 2.5 Route 53 latency records

**Assumption:** You already have a **public hosted zone** for `var.domain`. Get its Zone ID:

```bash
aws route53 list-hosted-zones | jq -r '.HostedZones[] | [.Name,.Id] | @tsv'
```

Put this in `variables.tf` or `terraform.tfvars`:

```hcl
variable "zone_id" { description = "Hosted Zone ID for your domain" }
```

We’ll later fill the ELB hostnames after we deploy the Services. To keep it IaC, we can **data-source** the ELBs or do a two-phase apply (apply clusters, deploy Services, then apply R53). Below is the **record shape** you’ll use once you have LB DNS names:

```hcl
# Example values (replace after Services exist)
variable "lb_dns_use1" { default = "abc123.use1.elb.amazonaws.com" }
variable "lb_dns_usw2" { default = "xyz456.usw2.elb.amazonaws.com" }

resource "aws_route53_record" "latency_east" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"  # e.g. app.example.com
  type    = "CNAME"
  ttl     = 60
  set_identifier         = "east"
  latency_routing_policy { region = "us-east-1" }
  records = [var.lb_dns_use1]
}

resource "aws_route53_record" "latency_west" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  set_identifier         = "west"
  latency_routing_policy { region = "us-west-2" }
  records = [var.lb_dns_usw2]
}
```

**Plan/Apply**

```bash
terraform init
terraform plan
terraform apply
```

**Expect:** Two EKS clusters + VPCs + secrets created (R53 records come after LB DNS is known).
**Learn:** Multi-region infra is **declarative and reproducible**.

---

# 3) Configure `kubectl` contexts

```bash
aws eks --region us-east-1 update-kubeconfig --name mr-eks-use1
aws eks --region us-west-2 update-kubeconfig --name mr-eks-usw2
kubectl config get-contexts
```

**Expect:** Two contexts appear.
**Learn:** You can target **each region** easily.

---

# 4) Deploy the App + LB in both clusters

Create `k8s/` with these files:

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  labels: { app: spring-app }
spec:
  replicas: 2
  selector:
    matchLabels: { app: spring-app }
  template:
    metadata:
      labels: { app: spring-app }
    spec:
      serviceAccountName: app-sa   # for IRSA step later
      containers:
      - name: spring-app
        image: YOUR_ECR_OR_DOCKER_IMAGE:tag
        ports:
        - containerPort: 8080
        env:
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef: { name: app-config, key: region }
```

`service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-app
  labels: { app: spring-app }
spec:
  type: LoadBalancer
  selector:
    app: spring-app
  ports:
  - port: 80
    targetPort: 8080
```

`configmap.yaml` (distinct per region)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  region: us-east-1
```

**Apply East:**

```bash
kubectl config use-context arn:aws:eks:us-east-1:...:cluster/mr-eks-use1
kubectl apply -f k8s/configmap.yaml   # region=us-east-1
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get svc spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Copy the **LB DNS** → save as `lb_dns_use1` for Terraform.

**Apply West:** (edit `configmap.yaml` region to `us-west-2`)

```bash
kubectl config use-context arn:aws:eks:us-west-2:...:cluster/mr-eks-usw2
# update the file value to us-west-2 first
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get svc spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Copy the **LB DNS** → save as `lb_dns_usw2`.

**Expect:** Two external LoadBalancer DNS names.
**Learn:** The same manifest, **two regions**, consistent delivery.

---

# 5) Finish Route 53 latency routing (Terraform)

Put the two LB hostnames into `terraform.tfvars`:

```hcl
domain        = "YOUR_DOMAIN.com"
zone_id       = "ZXXXXXXXXXXXXX"
subdomain     = "app"
lb_dns_use1   = "XXXX.use1.elb.amazonaws.com"
lb_dns_usw2   = "YYYY.usw2.elb.amazonaws.com"
```

Then:

```bash
terraform apply
```

**Expect:** `app.YOUR_DOMAIN.com` resolves differently based on user location/latency.
**Learn:** **Latency-based routing** + **regional HA**.

---

# 6) Health checks + automatic failover (optional, recommended)

Add Route 53 health checks so a failing region is withdrawn:

```hcl
resource "aws_route53_health_check" "east" {
  fqdn              = var.lb_dns_use1
  type              = "HTTPS"
  resource_path     = "/actuator/health"
  regions           = ["us-east-1","us-west-2"]
  insufficient_data_health_status = "Unhealthy"
}

resource "aws_route53_health_check" "west" {
  fqdn              = var.lb_dns_usw2
  type              = "HTTPS"
  resource_path     = "/actuator/health"
  regions           = ["us-east-1","us-west-2"]
  insufficient_data_health_status = "Unhealthy"
}

resource "aws_route53_record" "latency_east" {
  # ... same as before
  health_check_id = aws_route53_health_check.east.id
}

resource "aws_route53_record" "latency_west" {
  # ... same as before
  health_check_id = aws_route53_health_check.west.id
}
```

**Expect:** If `/actuator/health` in East fails, traffic flows West.
**Learn:** **Self-healing routing** at the DNS layer.

---

# 7) Observability (Prometheus + Grafana) per region

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl config use-context ...use1
helm install mon prometheus-community/kube-prometheus-stack
kubectl config use-context ...usw2
helm install mon prometheus-community/kube-prometheus-stack
```

Port-forward Grafana in each region to view metrics:

```bash
kubectl port-forward svc/mon-grafana 3000:80
# Login and import JVM / Micrometer dashboards
```

**Expect:** Live CPU/memory/latency/error-rate per region.
**Learn:** **Compare regions**, spot **bottlenecks**, validate **SLOs/alerts**.

---

# 8) IRSA (secure secrets at runtime) per region (recap)

Use the EKS module’s IRSA output or create SA + IAM role that allows `secretsmanager:GetSecretValue` in each region. Update `Deployment` with `serviceAccountName: app-sa` and app code uses AWS SDK to fetch `${var.project}/db_password`.
**Expect:** `/secret` endpoint returns secret value (don’t expose in prod, demo only).
**Learn:** **No plaintext secrets** in YAML; **regional, low-latency** access.

---

# 9) What to say in interviews (script)

* **Reliability/Scalability:** “I deployed the same service in **us-east-1/us-west-2** EKS clusters, fronted by **Route 53 latency routing** with health checks for automatic failover.”
* **Observability:** “Each region exports **Micrometer** → **Prometheus** metrics, visualized in **Grafana** with dashboards for latency, error rate, resource usage.”
* **Security:** “App secrets live in **AWS Secrets Manager** per region. Pods assume an **IRSA** role; no secrets in code or ConfigMaps.”
* **Automation:** “Everything is **Terraform**: VPC, EKS, Secrets, Route 53. CI/CD pushes new images and rolls deployments safely.”
* **Performance:** “We compare regional dashboards to detect bottlenecks and scale node groups or tune app configs.”

---

## Expected Outputs (quick checklist)

* `terraform apply` → 2 EKS clusters + VPCs + Secrets created ✅
* `kubectl get svc spring-app` (both contexts) → external LB hostnames ✅
* `curl http://app.YOUR_DOMAIN.com/hello` → responds from nearest region ✅
* Kill pods in east → Route 53 routes to west within health check TTL ✅
* Grafana → live metrics (per region), JVM + HTTP dashboards ✅












## 0) Repository Layout

```
multi-region-eks/
├─ README.md
├─ terraform/
│  ├─ providers.tf
│  ├─ variables.tf
│  ├─ main.tf
│  ├─ outputs.tf
│  ├─ r53.tf                # created after LBs exist (2nd apply)
│  └─ secrets.tf
├─ k8s/
│  ├─ namespace.yaml
│  ├─ sa-irsa.yaml          # ServiceAccount (name: app-sa)
│  ├─ configmap-east.yaml   # region: us-east-1
│  ├─ configmap-west.yaml   # region: us-west-2
│  ├─ deployment.yaml
│  └─ service.yaml          # type LoadBalancer
├─ app/
│  ├─ pom.xml
│  └─ src/main/java/com/demo/metricsapp/
│     ├─ MetricsApp.java
│     ├─ SecretService.java
│     └─ TestController.java
├─ Dockerfile
├─ Jenkinsfile
└─ scripts/
   ├─ kind-up.sh
   ├─ aws-ecr-login.sh
   ├─ deploy-east.sh
   ├─ deploy-west.sh
   └─ port-forward-grafana.sh
```

---

## 1) Local tooling (Mac/Homebrew)

```bash
brew update
brew install awscli terraform kubectl helm jq temurin maven kind
aws --version; terraform -version; kubectl version --client; helm version
java -version; mvn -version; kind version
```

**You learn**: toolchain works; versions print.

---

## 2) Terraform – two EKS clusters (us‑east‑1 + us‑west‑2)

> Use local backend first for simplicity; later switch to S3 + DynamoDB locking.

**terraform/providers.tf**

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Local backend for first run
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}
```

**terraform/variables.tf**

```hcl
variable "project"   { default = "mr-eks" }
variable "domain"    { description = "Your Route53 zone, e.g. example.com" }
variable "zone_id"   { description = "Hosted Zone ID for the domain" }
variable "subdomain" { default = "app" }

# Filled after Services create ELBs (phase 2)
variable "lb_dns_use1" { default = "" }
variable "lb_dns_usw2" { default = "" }
```

**terraform/main.tf**

```hcl
locals { tags = { Project = var.project } }

# VPC East
module "vpc_use1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  providers = { aws = aws.use1 }

  name = "${var.project}-use1"
  cidr = "10.10.0.0/16"
  azs  = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway      = false
  tags = local.tags
}

# EKS East
module "eks_use1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  providers = { aws = aws.use1 }

  cluster_name    = "${var.project}-use1"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_use1.public_subnets
  vpc_id          = module.vpc_use1.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size  = 1
      min_size      = 1
      max_size      = 2
      instance_types = ["t3.medium"]
    }
  }
  tags = local.tags
}

# VPC West
module "vpc_usw2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  providers = { aws = aws.usw2 }

  name = "${var.project}-usw2"
  cidr = "10.20.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]
  public_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway      = false
  tags = local.tags
}

# EKS West
module "eks_usw2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  providers = { aws = aws.usw2 }

  cluster_name    = "${var.project}-usw2"
  cluster_version = "1.29"
  subnet_ids      = module.vpc_usw2.public_subnets
  vpc_id          = module.vpc_usw2.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size  = 1
      min_size      = 1
      max_size      = 2
      instance_types = ["t3.medium"]
    }
  }
  tags = local.tags
}
```

**terraform/secrets.tf** (regional Secrets Manager copies)

```hcl
resource "aws_secretsmanager_secret" "db_use1" {
  provider = aws.use1
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_use1_v" {
  provider      = aws.use1
  secret_id     = aws_secretsmanager_secret.db_use1.id
  secret_string = "MySecurePassword!"
}

resource "aws_secretsmanager_secret" "db_usw2" {
  provider = aws.usw2
  name     = "${var.project}/db_password"
  tags     = local.tags
}
resource "aws_secretsmanager_secret_version" "db_usw2_v" {
  provider      = aws.usw2
  secret_id     = aws_secretsmanager_secret.db_usw2.id
  secret_string = "MySecurePassword!"
}
```

**terraform/outputs.tf**

```hcl
output "cluster_names" {
  value = [module.eks_use1.cluster_name, module.eks_usw2.cluster_name]
}
output "region_contexts_note" {
  value = "Run: aws eks --region us-east-1 update-kubeconfig --name ${module.eks_use1.cluster_name}; aws eks --region us-west-2 update-kubeconfig --name ${module.eks_usw2.cluster_name}"
}
```

**Apply (phase 1)**

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

**You expect**: 2 EKS clusters + 2 VPCs + 2 secrets created.

---

## 3) Spring Boot app (Micrometer/Actuator + AWS SDK)

**app/pom.xml**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.demo</groupId>
  <artifactId>metricsapp</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.4</version>
  </parent>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
    <dependency>
      <groupId>software.amazon.awssdk</groupId>
      <artifactId>secretsmanager</artifactId>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
```

**app/src/main/java/com/demo/metricsapp/MetricsApp.java**

```java
package com.demo.metricsapp;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MetricsApp {
  public static void main(String[] args) {
    SpringApplication.run(MetricsApp.class, args);
  }
}
```

**app/src/main/java/com/demo/metricsapp/SecretService.java**

```java
package com.demo.metricsapp;

import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

@Service
public class SecretService {
  public String getSecret(String secretId) {
    SecretsManagerClient client = SecretsManagerClient.builder().build();
    var req = GetSecretValueRequest.builder().secretId(secretId).build();
    return client.getSecretValue(req).secretString();
  }
}
```

**app/src/main/java/com/demo/metricsapp/TestController.java**

```java
package com.demo.metricsapp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

  @Autowired private SecretService secretService;

  @GetMapping("/hello")
  public String hello() { return "Hello from app"; }

  @GetMapping("/secret")
  public String secret() {
    // same name in both regions
    return secretService.getSecret("mr-eks/db_password");
  }
}
```

**Application properties** (Actuator/Prometheus)

```
# app/src/main/resources/application.properties
management.endpoints.web.exposure.include=*
management.endpoint.prometheus.enabled=true
```

Build & run locally:

```bash
cd app
mvn clean package -DskipTests
java -jar target/metricsapp-0.0.1-SNAPSHOT.jar
# Test
curl localhost:8080/hello
curl localhost:8080/actuator/prometheus | head
```

---

## 4) Docker image

**Dockerfile**

```dockerfile
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY app/target/metricsapp-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
```

Build:

```bash
docker build -t spring-metrics-app:v1 .
```

(Optional) Push to ECR later (script provided below).

---

## 5) Kubernetes Manifests

**k8s/namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: app
```

**k8s/sa-irsa.yaml** (IRSA hook – IAM role must be created/linked later)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: app
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/mr-eks-secrets-role"
```

**k8s/configmap-east.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata: { name: app-config, namespace: app }
data:
  region: us-east-1
```

**k8s/configmap-west.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata: { name: app-config, namespace: app }
data:
  region: us-west-2
```

**k8s/deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  namespace: app
  labels: { app: spring-app }
spec:
  replicas: 2
  selector:
    matchLabels: { app: spring-app }
  template:
    metadata:
      labels: { app: spring-app }
    spec:
      serviceAccountName: app-sa
      containers:
      - name: spring-app
        image: spring-metrics-app:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef: { name: app-config, key: region }
        readinessProbe:
          httpGet: { path: /actuator/health, port: 8080 }
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet: { path: /actuator/health, port: 8080 }
          initialDelaySeconds: 15
          periodSeconds: 20
```

**k8s/service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-app
  namespace: app
spec:
  type: LoadBalancer
  selector:
    app: spring-app
  ports:
  - port: 80
    targetPort: 8080
```

---

## 6) Configure kubectl contexts & deploy to both regions

```bash
# Create kubeconfigs
aws eks --region us-east-1 update-kubeconfig --name mr-eks-use1
aws eks --region us-west-2 update-kubeconfig --name mr-eks-usw2
kubectl config get-contexts
```

**scripts/deploy-east.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail
CTX=$(kubectl config get-contexts -o name | grep us-east-1)
kubectl --context="$CTX" apply -f k8s/namespace.yaml
kubectl --context="$CTX" apply -f k8s/sa-irsa.yaml
kubectl --context="$CTX" apply -f k8s/configmap-east.yaml
kubectl --context="$CTX" apply -f k8s/deployment.yaml
kubectl --context="$CTX" apply -f k8s/service.yaml
kubectl --context="$CTX" get svc -n app spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

**scripts/deploy-west.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail
CTX=$(kubectl config get-contexts -o name | grep us-west-2)
kubectl --context="$CTX" apply -f k8s/namespace.yaml
kubectl --context="$CTX" apply -f k8s/sa-irsa.yaml
kubectl --context="$CTX" apply -f k8s/configmap-west.yaml
kubectl --context="$CTX" apply -f k8s/deployment.yaml
kubectl --context="$CTX" apply -f k8s/service.yaml
kubectl --context="$CTX" get svc -n app spring-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Make executable:

```bash
chmod +x scripts/*.sh
./scripts/deploy-east.sh
./scripts/deploy-west.sh
```

Copy the two printed ELB hostnames; put them into `terraform/terraform.tfvars` later.

---

## 7) Route 53 Latency Routing (2nd Terraform apply)

**terraform/r53.tf**

```hcl
resource "aws_route53_record" "latency_east" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  set_identifier = "east"
  latency_routing_policy { region = "us-east-1" }
  records = [var.lb_dns_use1]
}

resource "aws_route53_record" "latency_west" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  set_identifier = "west"
  latency_routing_policy { region = "us-west-2" }
  records = [var.lb_dns_usw2]
}
```

**terraform/terraform.tfvars** (example)

```hcl
project  = "mr-eks"
domain   = "YOUR_DOMAIN.com"
zone_id  = "Z123456ABCDEFG"
subdomain = "app"
lb_dns_use1 = "XXXX.elb.us-east-1.amazonaws.com"
lb_dns_usw2 = "YYYY.elb.us-west-2.amazonaws.com"
```

Apply (phase 2):

```bash
cd terraform
terraform apply -auto-approve
```

**Test**

```bash
nslookup app.YOUR_DOMAIN.com
curl http://app.YOUR_DOMAIN.com/hello
```

Expected: nearest region response; if you stop East pods, Route 53 sends you West after TTL.

---

## 8) Prometheus + Grafana per region

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# East
kubectl --context "$(kubectl config get-contexts -o name | grep us-east-1)" \
  create ns monitoring || true
helm --kube-context "$(kubectl config get-contexts -o name | grep us-east-1)" \
  install mon prometheus-community/kube-prometheus-stack -n monitoring

# West
kubectl --context "$(kubectl config get-contexts -o name | grep us-west-2)" \
  create ns monitoring || true
helm --kube-context "$(kubectl config get-contexts -o name | grep us-west-2)" \
  install mon prometheus-community/kube-prometheus-stack -n monitoring
```

**scripts/port-forward-grafana.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail
CTX=$1 # pass east or west context name
kubectl --context "$CTX" -n monitoring port-forward svc/mon-grafana 3000:80
```

Browse `http://localhost:3000` → import JVM/Micrometer dashboards.

**You learn**: live latency/error-rate/throughput per region.

---

## 9) IRSA – grant pod access to Secrets Manager

Create an IAM policy with `secretsmanager:GetSecretValue` (one per region), create an IAM role for service account (OIDC provider from EKS), and update `k8s/sa-irsa.yaml` with that role ARN.

**(Tip)** You can use `eksctl create iamserviceaccount ... --attach-policy-arn ... --approve` for each cluster.

Test:

```bash
# from a pod
kubectl exec -n app -it deploy/spring-app -- curl localhost:8080/secret
# expect: MySecurePassword!
```

---

## 10) Jenkins CI/CD

**Jenkinsfile** (two options: local Kind or ECR + EKS)

```groovy
pipeline {
  agent any
  environment {
    IMAGE        = "spring-metrics-app"
    TAG          = "${env.BUILD_NUMBER}"
    REGISTRY     = "${env.ECR ?: 'localhost:5000'}" // if ECR unset, use local
    KCTX_EAST    = sh(returnStdout: true, script: "kubectl config get-contexts -o name | grep us-east-1").trim()
    KCTX_WEST    = sh(returnStdout: true, script: "kubectl config get-contexts -o name | grep us-west-2").trim()
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build')    { steps { sh 'mvn -q -f app/pom.xml clean package -DskipTests' } }
    stage('Docker Build') { steps { sh 'docker build -t ${IMAGE}:${TAG} .' } }
    stage('Login & Push') {
      when { expression { return env.ECR != null } }
      steps {
        sh 'scripts/aws-ecr-login.sh'
        sh 'docker tag ${IMAGE}:${TAG} ${REGISTRY}/${IMAGE}:${TAG}'
        sh 'docker push ${REGISTRY}/${IMAGE}:${TAG}'
      }
    }
    stage('Deploy East & West') {
      steps {
        sh 'kubectl --context="$KCTX_EAST" -n app set image deploy/spring-app spring-app=${REGISTRY}/${IMAGE}:${TAG} --record'
        sh 'kubectl --context="$KCTX_WEST" -n app set image deploy/spring-app spring-app=${REGISTRY}/${IMAGE}:${TAG} --record'
      }
    }
    stage('Verify') {
      steps {
        sh 'kubectl --context="$KCTX_EAST" -n app rollout status deploy/spring-app --timeout=120s'
        sh 'kubectl --context="$KCTX_WEST" -n app rollout status deploy/spring-app --timeout=120s'
      }
    }
  }
}
```

**scripts/aws-ecr-login.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail
ACC=$(aws sts get-caller-identity --query Account --output text)
REG=${AWS_REGION:-us-east-1}
aws ecr get-login-password --region "$REG" | docker login --username AWS --password-stdin ${ACC}.dkr.ecr.${REG}.amazonaws.com
export ECR=${ACC}.dkr.ecr.${REG}.amazonaws.com
```

**You learn**: push‑button deployments to both regions from a single pipeline.

---

## 11) Expected outputs

* `terraform apply` → cluster names printed; secrets created.
* `scripts/deploy-*.sh` → two ELB hostnames printed.
* `terraform apply` (r53) → DNS records created. `nslookup app.YOUR_DOMAIN.com` shows answers.
* `curl app.YOUR_DOMAIN.com/hello` returns quickly; fail one region → traffic shifts.
* Grafana dashboards show live metrics per region.

---

## 12) What to say in interviews (copy‑ready)

> “I provisioned two EKS clusters with Terraform (us‑east‑1/us‑west‑2), deployed a Spring Boot service instrumented with Micrometer, exposed Prometheus metrics, and visualized everything in Grafana. Route 53 latency routing directs users to the closest region with health‑check failover. Secrets are regional via AWS Secrets Manager, accessed securely from pods using IRSA. CI/CD with Jenkins builds, pushes the image, and updates both clusters automatically.”

---

## 13) Stretch goals (optional)

* Add Alertmanager → Slack/PagerDuty notifications.
* HorizontalPodAutoscaler based on request latency or CPU.
* Canary/blue‑green with Argo Rollouts.
* Convert raw YAML → Helm chart.
* Switch Terraform backend to S3 + DynamoDB locking for team use.

---

## 14) Troubleshooting quick refs

* **No ELB hostname**: service type must be `LoadBalancer`; wait 2–5 minutes.
* **Pod can’t read secret**: IRSA role/annotation missing; check `aws-iam-authenticator` logs.
* **Route 53 doesn’t route**: record names/zone id/health checks; TTL cache.
* **Jenkins can’t push**: ECR repo missing; create repo and set `REGISTRY`.

```bash
aws ecr create-repository --repository-name spring-metrics-app --region us-east-1
```













