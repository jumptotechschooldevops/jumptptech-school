---
title: "batch #2 market ready interview questions and answers"
description: "1. Have you implemented a real production setup for containerized..."
published: 2025-11-08
source: "https://dev.to/jumptotech/interview-questions-and-answers-5535"
tags: []
---

# batch #2 market ready interview questions and answers




### 1. Have you implemented a real production setup for containerized applications?

**Answer:**
Yes. I led a production deployment of a containerized Flask/MySQL application on Amazon EKS. I built the infrastructure using Terraform, containerized the application with Docker, deployed via Helm, implemented CI/CD using GitHub Actions and CodePipeline, enabled HPA, integrated Secrets Manager, and implemented monitoring with Prometheus and Grafana.

---

### 2. When working with pipelines, Terraform, and Helm automation, what are your daily activities?

**Answer:**
Daily, I maintain and improve CI/CD pipelines, update and version Terraform modules, manage Helm chart releases, review merge requests, monitor deployments, troubleshoot infrastructure issues, validate security policies, and collaborate with developers to ensure stable releases across environments.

---

### 3. Are your deployment automation scripts common enterprise-wide templates, or are they application-specific?

**Answer:**
In enterprise environments, we build centralized reusable pipeline templates and Terraform/Helm modules. Applications consume those shared components using variables. The framework is standardized, while configurations remain application-specific.

---

### 4. Is Argo CD part of your CI/CD process?

**Answer:**
Yes. CI builds and scans the image, pushes it to the registry, and Argo CD handles CD by pulling updated manifests from Git and deploying automatically to Kubernetes using GitOps.

---

### 5. If you need to locate the shared part of a pipeline or automation script, how do you find it?

**Answer:**
Shared logic is stored in centralized repositories like Terraform modules, Helm charts, or CI template repositories. I locate them via Git version references and review module versions used by applications before making changes.

---

### 6. If you update a shared pipeline component, how do you roll it out across multiple applications?

**Answer:**
We version shared templates. When updating, we release a new version, test it, and applications upgrade by bumping the version reference through pull requests or automated dependency updates.

---

### 7. How do you ensure changes to shared templates do not break existing applications?

**Answer:**
We create a new version instead of modifying in place, validate in staging, test against representative sample applications, run integration tests, and then roll out gradually with monitoring and rollback capability.

---

### 8. Do you test every application, or only a few representative sample applications?

**Answer:**
We test representative applications that reflect different complexity levels. If those pass validation, we proceed with gradual rollout.

---

### 9. When you begin testing, are those representative applications part of a predefined list?

**Answer:**
Yes. We maintain a dedicated staging set of representative applications specifically for validating shared changes before broader deployment.

---

### 10. After implementation, how do you ensure no applications are negatively impacted?

**Answer:**
We monitor logs, metrics, alerts, and error rates immediately after deployment. If impact is detected, we roll back to the previous stable version using version control and redeploy.

---

### 11. What actions do you take to confirm the application is functioning correctly?

**Answer:**
I verify CI success, check pod health, validate service endpoints, review logs, run smoke tests, and confirm monitoring dashboards show no anomalies before confirming success.

---

### 12. If multiple applications are using a specific container image and you discover a vulnerability, how do you enforce upgrading to a secure version?

**Answer:**
I build and scan a secure image, tag it with a new version, update manifests in Git, deploy to staging first, validate, then promote to production. If urgent, I enforce policy to block old image versions and update all repositories via automated pull requests.

---

### 13. How do you determine how many applications are using a vulnerable image?

**Answer:**
I search across Git repositories for image references, check container registry metadata, and query running pods in clusters to identify exactly which applications and environments are using the vulnerable image.

---

### 14. If images are layered and derived from a vulnerable base image, how do you detect that dependency?

**Answer:**
I inspect the Dockerfile `FROM` directive, review image digests and parent layers using docker inspect or registry metadata, and use vulnerability scanners like Trivy to detect vulnerable base layers regardless of inheritance depth.

---

### 15. Is the Dockerfile located in the same repository as the application, or separate?

**Answer:**
Application Dockerfiles are usually in their own repositories, while base images are maintained centrally. Scanning is integrated into CI pipelines to automatically validate during build.

---

### 16. Are custom application images maintained separately from centralized base images?

**Answer:**
Yes. Base images are centrally managed, while application-specific Dockerfiles extend those approved base images in separate repositories.

---

### 17. How have you implemented blue-green deployment?

**Answer:**
I deploy blue and green versions as separate Kubernetes deployments. Production traffic routes to blue. Green is deployed and tested independently. Once validated, I switch the Service selector to route traffic to green for instant cutover.

---

### 18. Are blue and green deployments typically in the same cluster?

**Answer:**
Yes. Typically within the same Kubernetes cluster, using separate deployments distinguished by labels.

---

### 19. How do you differentiate between blue and green for routing purposes?

**Answer:**
Using labels like `version: blue` and `version: green`. The Service selector determines which version receives traffic.

---

### 20. What component controls routing in blue-green deployment?

**Answer:**
Routing is handled by Kubernetes Service selectors and optionally Ingress or LoadBalancer for external traffic.

---

### 21. How exactly does routing switch in blue-green deployment?

**Answer:**
Both versions run simultaneously. The Service selector points to one version. Switching the selector reroutes traffic instantly.

---

### 22. Does traffic gradually shift from blue to green?

**Answer:**
No. Blue-green switches traffic instantly. Gradual increase is canary deployment.

---

### 23. How do you test green if production traffic still goes to blue?

**Answer:**
Green is tested via a separate internal Service, temporary Ingress, or port-forwarding. Production traffic remains routed to blue until switch.

---

### 24. If both blue and green are running, why does the web client go to blue?

**Answer:**
Production clients go to blue because the Service selector matches blue. Green is only accessible via a test endpoint until switch.

---

### 25. Do you use a separate Ingress URL to test green?

**Answer:**
Yes. We create a temporary or internal Ingress pointing to green for QA validation while production remains on blue.

---

### 26. If you have 10 microservices, how do you manage blue-green?

**Answer:**
Each microservice is upgraded independently using blue-green per service, minimizing system-wide risk.

---

### 27. In a modern microservices architecture, do you create an Ingress per service?

**Answer:**
We typically use a single Ingress with path-based routing. Each microservice has its own Service internally.

---

### 28. If you have 100 services and only 10 are modified, do you deploy green for all?

**Answer:**
No. Only the modified services receive green deployments. Others remain unchanged.

---

### 29. How does routing work between modified and non-modified services?

**Answer:**
Routing remains unchanged for non-modified services. Only the Service selector for modified services is updated.

---

### 30. Have you worked with Apache HTTP Server?

**Answer:**
Yes. I’ve configured Apache as a reverse proxy, SSL terminator, and load balancer integrated with backend Kubernetes services.

---

### 31. How do you configure frontend services?

**Answer:**
I deploy frontend containers behind Kubernetes Service and Ingress, configure SSL, routing rules, environment variables, and validate DNS and load balancer setup.

---

### 32. How did you track request flow from client through Apache to Kubernetes backend services?

**Answer:**
Request flow: Client → Load Balancer → Ingress/Apache → Kubernetes Service → Pod → Backend services. We track via centralized logging, correlation IDs, and monitoring tools.

---

### 33. How do you implement distributed tracing?

**Answer:**
We implement distributed tracing using trace IDs propagated through headers. Each service logs the same ID. We use Jaeger or OpenTelemetry UI to visualize request flow.

---

### 34. If a request goes through multiple microservices, how do you trace the full route?

**Answer:**
The trace ID propagates across all downstream calls. Tracing tools display a full call graph showing latency and dependencies.

---

### 35. Is there a UI for tracing?

**Answer:**
Yes. Tools like Jaeger and Grafana Tempo provide a UI to visualize trace graphs and latency breakdown.

---

### 36. Have you worked with Linux services and batch processing?

**Answer:**
Yes. I manage Linux services via systemd, configure cron jobs, write automation scripts, and monitor system performance.

---

### 37. Have you performed patching?

**Answer:**
Yes. I perform automated Linux patching using Ansible, schedule maintenance windows, validate service health, and execute rolling updates.

---

### 38. Have you patched production systems?

**Answer:**
Yes. I’ve patched production systems including kernel updates and security fixes with rollback planning.

---

### 39. What does rollback mean in the context of upgrades?

**Answer:**
Rollback means restoring the previous stable version of packages, containers, or system state if an upgrade causes instability.

---

### 40. How do you back up a server?

**Answer:**
We use automated VM or EBS snapshots, database backups, and version-controlled infrastructure code for recovery capability.

---

### 41. If you are upgrading Linux and something fails, how do you recover?

**Answer:**
Before upgrade, I create a snapshot. If failure occurs, I restore from snapshot or redeploy from previous AMI, or downgrade affected packages.





















# **1. “What were your day-to-day responsibilities in your last projects?”**

**Answer:**

> “I worked mainly in Kafka/Confluent platform engineering.
> I designed and maintained Kafka clusters, set up Confluent Cloud environments, built topics, ACLs, schemas, connectors, monitored cluster health, and onboarded application teams.
>
> I also designed event-driven architectures, integrated SQL and NoSQL systems, built CI/CD automation for Kafka resources, and supported offshore teams.”

---

# **2. “Did you use any tool to monitor the Kafka cluster?”**

**Answer:**

> “Yes. I used Confluent Control Center, Confluent Metrics API, Grafana dashboards, CloudWatch logs, and Prometheus exporters to track consumer lag, throughput, partition skew, and latency.”

---

# **3. “If a user complains about slowness or delays in messages, how do you diagnose it?”**

**Answer:**

> “I break it into three layers:
> **Producer → Broker → Consumer.**
>
> I check producer retries and network latency, check broker health and partition hotspots in Confluent metrics, and then check consumer lag, poll delays, and rebalancing.
>
> Most delays come from slow consumers, network latency, or partition imbalance.”

---

# **4. “Can you elaborate on designing Kafka real-time pipelines with SQL and NoSQL?”**

**Answer:**

> “Yes. In my project we streamed data from microservices and Postgres (via JDBC Source Connector), processed it using ksqlDB streams and tables, and delivered enriched analytics into Couchbase (via Couchbase Sink Connector).
>
> I handled schema governance, AVRO versioning, partitioning strategies, connector deployment, and ensuring end-to-end reliability.”

---

# **5. “What challenges did you face when Couchbase was the final sink?”**

**Answer:**

> “Main challenges were:
> – Lag between Kafka and Couchbase during traffic spikes
> – Duplicate writes due to at-least-once delivery
> – Schema/document evolution issues
> – Index and query performance when data grew
>
> We solved these with upserts, backward-compatible schemas, connector scaling, and index tuning.”

---

# **6. “Which one do you prefer: Couchbase or MongoDB? Why?”**

**Answer:**

> “For real-time streaming workloads, Couchbase performed better for us because it’s memory-first, has fast KV operations, and supports SQL-like N1QL queries.
>
> MongoDB is great for general document storage, but for high-volume Kafka ingestion and low-latency analytics, Couchbase was a better match.”

---

# **7. “Did you use Confluent fully managed connectors or custom connectors?”**

**Answer:**

> “Wherever possible we used **fully managed connectors** because they auto-scale, self-heal, and require almost no operational overhead.
>
> For systems without a managed connector, we used **custom connectors** on self-managed Kafka Connect clusters.
>
> Downsides of custom: more ops work, manual scaling, harder monitoring.”

---

# **8. “What are the limitations of custom connectors in Confluent Cloud?”**

**Answer:**

> “Custom connectors require:
> – running and managing your own Connect cluster
> – manual scaling
> – updating and patching the connector yourself
> – more responsibility for monitoring, reliability, and security
>
> And they can’t leverage Confluent Cloud’s auto-scaling or SLAs.”

---

# **9. “If you have 4 partitions and the consumer group increases from 2 to 6, what happens?”**

**Answer:**

> “Kafka can only assign one consumer per partition, so only **4 consumers** will be active. The other two stay **idle**.
>
> To scale to 6 consumers, you must **increase partitions to at least 6**.”

---

# **10. “Have you seen cases where data volume spikes massively? How do you handle sudden scaling?”**

**Answer:**

> “Yes. When traffic increased 5–10x, we scaled partitions, added more consumer instances, tuned partitioning strategy to avoid hotspots, scaled connectors, and optimized downstream systems (Couchbase, RDS).
>
> We also revisited retention/storage policies and sometimes separated workloads into multiple Kafka clusters.”

---

# **11. “Was your Confluent cluster using private networking or public connectivity?”**

**Answer:**

> “We used **private networking** only — either AWS PrivateLink or VPC Peering, depending on the environment.”

---

# **12. “How did you implement private connectivity with Confluent Cloud?”**

**Answer (AWS PrivateLink example):**

> “High level steps:
>
> 1. Create a PrivateLink endpoint in our AWS VPC
> 2. Confluent provides service IDs for Kafka, Schema Registry, Connect
> 3. Approve endpoint from Confluent
> 4. Update routes, DNS, and security groups
> 5. Update client configs to use the new private bootstrap servers
>
> After that all traffic stays inside the private network.”

---

# **13. “Is your environment Confluent Cloud or self-managed Kafka?”**

**Answer:**

> “Confluent Cloud — mainly because of managed connectors, RBAC, metrics, and private networking.”

---

# **14. “Have you worked with Apache Flink?”**

**Answer:**

> “I haven’t used Flink heavily in production yet. My main focus has been Confluent Kafka + ksqlDB for stream processing.
>
> I understand the architecture and how Flink integrates with Kafka, but my hands-on experience is mostly with ksqlDB.”

---

# **15. “What happens if audit asks whether confidential data is flowing through Kafka?”**

**Answer:**

> “I inventory all topics/schemas, classify data via Schema Registry metadata, scan for PII patterns, enforce compatibility rules, apply topic-level ACLs, and produce a report showing exactly which topics carry sensitive fields and how they’re secured.”

---

# **16. “Have you participated in networking design between applications and Confluent?”**

**Answer:**

> “Yes — I worked closely with network/security teams to design VPC Peering or PrivateLink setups, define inbound/outbound rules, configure DNS overrides, and validate end-to-end connectivity for producers, consumers, and connectors.”

---

# **17. “Do you work more on the application side or admin side?”**

**Answer:**

> “More on the admin and architecture side — designing clusters, managing schemas, partitions, ACLs, connectors, networking, and platform governance.
>
> I also support application teams but my primary role is platform engineering.”






## **51. Describe your Terraform experience at a high level.**

I’ve used Terraform extensively to build **multi-account AWS environments**, including VPC networking, IAM, S3, EC2, EKS clusters, Config rules, and SCP deployments.
I design infrastructure using **modular architecture**, use remote state in S3 with DynamoDB locking, and integrate Terraform with CI/CD pipelines and OPA checks to enforce compliance.

---

## **52. How do you structure Terraform modules?**

I structure modules around **logical components**:

```
modules/
  vpc/
  subnets/
  iam/
  ec2/
  s3/
  eks/
  config/
  scp/
environments/
  dev/
  stage/
  prod/
```

This separation makes the code reusable, scalable, and easier to manage across multiple accounts.

---

## **53. How do you deploy SCPs with Terraform?**

I deploy SCPs from the **management account**, but the pipeline usually runs in a workload account.
So I use a **cross-account IAM role** and Terraform’s `assume_role`:

```hcl
provider "aws" {
  assume_role {
    role_arn = var.management_role_arn
  }
}
```

This lets Terraform manage AWS Organizations policies securely.

---

## **54. What is least privilege in Terraform IAM policies?**

Least privilege means giving a role only the **exact** actions required to perform a task.
Example for SCP deployment:

* organizations:CreatePolicy
* organizations:AttachPolicy
* organizations:ListRoots
* organizations:UpdatePolicy

No wildcards, no admin privileges.

---

## **55. How do you know what IAM permissions are needed?**

I follow a simple approach:

1. Start with AWS documentation
2. Run Terraform to see if AccessDenied appears
3. Add only the missing action
4. Validate using IAM Access Analyzer

This gives accurate and minimal permissions.

---

## **56. How do you manage Terraform remote state?**

I store state in:

* S3 bucket (encrypted, versioning enabled)
* DynamoDB table for state locking

This avoids conflicts and provides a reliable multi-developer workflow.

---

## **57. How do you handle Terraform drift?**

I use:

* `terraform plan` regularly
* AWS Config to detect out-of-band changes
* SecurityHub for high-risk drift

OPA prevents future drift; Config detects existing drift.

---

## **58. How do you validate Terraform code?**

Pipeline steps:

1. `terraform fmt`
2. `terraform validate`
3. `tflint`
4. **OPA/Conftest**
5. `terraform plan`

This ensures the code is syntactically correct, logically correct, and compliant.

---

## **59. How do you manage environment-specific values?**

Using:

* `tfvars` files
* Workspaces
* Environment directories

This prevents hardcoding.

---

## **60. How do you enforce tagging using Terraform?**

I create a tagging module OR enforce tags via OPA:

OPA example:

* If tags missing → deny the deployment.

This ensures all resources follow corporate tagging standards.

---

## **61. How do you deploy Kubernetes/EKS resources in Terraform?**

By using:

* `kubernetes` provider
* `helm` provider

Terraform can install EKS, nodes, add-ons, and even Gatekeeper.

---

## **62. What is the Terraform lifecycle meta-argument?**

Used to control behavior:

* `prevent_destroy` to protect critical resources
* `ignore_changes` to ignore drift
* `create_before_destroy` for replacements

---

## **63. How do you avoid long pipeline iteration cycles?**

I test locally using:

* Local Terraform plan
* Mocking AWS accounts
* `opa eval` on sample inputs

This reduces full pipeline runs.

---

## **64. Do you use Terragrunt? Why or why not?**

Yes, for complex multi-account projects.
Terragrunt simplifies:

* managing remote state
* DRY architecture
* multi-account stacks

---

## **65. How do you secure Terraform state?**

* Encrypt S3 bucket
* Enable versioning
* Deny public access
* Use IAM boundaries
* Use KMS encryption

---

## **66. How do you manage sensitive variables?**

Use:

* Terraform Cloud variable sets
* SSM Parameter Store
* Secrets Manager
* `.tfvars` excluded from Git

Never store secrets in repo.

---

## **67. What is count vs for_each? When do you use which?**

* **count** for simple repetition
* **for_each** when managing named entities or maps

for_each gives predictable ordering and better control.

---

## **68. What’s the difference between locals and variables?**

* **variables** are input
* **locals** are computed internal values

I use locals for data transformations.

---

## **69. How do you handle module versioning?**

Using Git tags or Terraform registry version numbers.

---

## **70. What’s your biggest challenge with Terraform?**

Long pipeline feedback loops and keeping modules consistent across 10–20 accounts.
OPA and module standardization help solve this.

---



## **71. What are Service Control Policies (SCPs)?**

SCPs are **organization-level guardrails**.
They do not grant permissions; they only restrict what IAM users/roles can do.

They ensure that even if IAM is misconfigured, the account stays safe.

---

## **72. What SCPs have you written?**

I’ve created SCPs for:

* Enforcing allowed AWS regions
* Denying public S3 buckets
* Denying disabling CloudTrail/Config
* Blocking IAM wildcard permissions
* Preventing root user API calls
* Restricting creation of Internet Gateways in prod

---

## **73. How do you deploy SCPs across accounts?**

Using Terraform with:

* A cross-account management role
* organizations provider
* GitOps workflow

This provides full automation.

---

## **74. How do you troubleshoot SCP issues?**

I check the **effective permissions**, which are:

IAM permissions

* Permission boundaries
* SCP
  = final effective permissions

Most issues come from SCP blocking an action IAM allows.

---

## **75. How do you restrict AWS regions with SCPs?**

Example:

```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "StringNotEquals": { "aws:RequestedRegion": ["us-east-1","us-west-2"] }
  }
}
```

---

## **76. How do you enforce encryption using SCPs?**

SCP can deny actions like:

* S3 `PutBucketEncryption` missing
* `kms:DisableKey`

But SCP is usually coarse, so OPA + Config handle specifics.

---

## **77. How do you protect CloudTrail with SCP?**

Deny:

* `cloudtrail:StopLogging`
* `cloudtrail:DeleteTrail`
* `s3:PutBucketPolicy` that would break logging

---

## **78. How do you prevent resource deletion using SCP?**

Set Deny on destructive actions in production accounts.

---

## **79. How do you ensure SCPs don’t break deployments?**

I validate using:

* Sandbox accounts
* Policy simulator
* CloudTrail logs

---

## **80. How do you integrate SCPs with OPA?**

OPA blocks non-compliant code *before* apply.
SCP blocks dangerous actions *at runtime*.

---


---

## **81. What is AWS EventBridge used for?**

EventBridge routes cloud events (Config, SecurityHub, IAM, CloudTrail) into automation pipelines.

---

## **82. What remediation workflows have you built?**

Examples:

* Auto-enable S3 encryption
* Auto-close public S3 access
* Remove 0.0.0.0/0 ingress from SG
* Restart unhealthy EC2 instances

Triggered by Config non-compliance.

---

## **83. How does the remediation pipeline work?**

Flow:

1. Config marks resource NON_COMPLIANT
2. EventBridge rule triggers
3. Lambda/SSM Automation fixes the resource
4. SecurityHub is updated

---

## **84. How do you avoid remediation loops?**

I add a condition in the Lambda:

If the resource is already remediated → skip.

---

## **85. How do you alert on non-compliance?**

EventBridge → SNS / Slack → CloudWatch alarm if repeated violations occur.

---

## **86. How do you record remediation actions?**

Using:

* CloudWatch Logs
* SecurityHub custom findings
* Tagging remediated resources

---

## **87. How do you handle high-volume events?**

Use:

* Filtering rules
* Dead-letter queues
* Batch processing

---

## **88. How do you test remediation?**

Replay sample events via CloudWatch.
Or manually mark a resource NON_COMPLIANT.

---

## **89. How do you secure EventBridge pipelines?**

IAM least privilege for targets, encrypted logs, KMS for secrets.

---

## **90. When should remediation be manual vs automatic?**

* High-risk issues → auto-remediate
* Business-impacting issues → manual approval

---


---

## **91. How do you secure Kubernetes clusters?**

Using multiple layers:

* RBAC
* Pod Security (OPA Gatekeeper)
* Network Policies
* IAM Roles for Service Accounts
* EKS control-plane logging
* Secret encryption

---

## **92. What is Gatekeeper?**

Gatekeeper is OPA integrated into Kubernetes.
It enforces rules at admission time.

---

## **93. What Gatekeeper constraints have you created?**

* No privileged containers
* runAsNonRoot required
* No hostPath volumes
* Mandatory resource limits
* Allowed registry whitelist

---

## **94. How do you deploy Gatekeeper?**

Using Helm or manifests.

Add ConstraintTemplates → Constraints → Sync.

---

## **95. How do you test Gatekeeper?**

Run:

```bash
kubectl apply -f bad-pod.yaml --dry-run=server
```

If policy works → admission is denied.

---

## **96. How do you debug Gatekeeper issues?**

Check:

* Gatekeeper audit logs
* Violations in `kubectl get k8sconstraints`
* OPA traces

---

## **97. How do you restrict container capabilities?**

Gatekeeper policy checks `securityContext.capabilities.drop`.

---

## **98. How do you enforce resource limits?**

Require CPU/memory limits on all containers.

---

## **99. How do you enforce image repository rules?**

Deny if image not from approved registries.

---

## **100. How do you manage Gatekeeper in multi-cluster environments?**

Using GitOps (ArgoCD / Flux) to sync the same policies across clusters.




## **1. What is Open Policy Agent (OPA)?**

OPA is a **policy decision engine** used to enforce rules before infrastructure is deployed.
I use it to implement “**shift-left security**,” meaning we validate compliance in CI/CD instead of after the resource is already deployed.

I typically use OPA to check Terraform, Kubernetes manifests, and cloud security controls.

---

## **2. What is Rego?**

Rego is OPA’s policy language.
It lets me write infrastructure rules in a declarative way.
Instead of describing *how* to evaluate the rule, I describe *what must be true*.

Example:
“If S3 bucket encryption is missing → deny.”

---

## **3. How do you use OPA with Terraform?**

I integrate OPA using **Conftest**, which evaluates a Terraform plan before apply.

Steps:

1. `terraform plan -out tfplan`
2. `terraform show -json tfplan > plan.json`
3. `conftest test plan.json`

Rego checks things like:

* encryption
* tags
* security groups
* IAM permissions
* region restrictions

If any policy fails → deployment is blocked.

---

## **4. What kinds of OPA policies have you written?**

I’ve written a full set of cloud security baseline policies, including:

* S3 encryption + versioning
* RDS encryption
* EC2 instance type whitelisting
* Mandatory tags like Environment/Owner
* Disallowing `0.0.0.0/0` on SSH
* Denying public S3 access
* Blocking IAM wildcard permissions
* Kubernetes pod security (no privileged containers, require runAsNonRoot)

These enforce consistent security across teams.

---

## **5. How do you test OPA policies?**

I test OPA in three ways:

* Local development with `conftest test`
* Unit tests using OPA’s built-in test framework (`opa test`)
* Dry-run mode in Gatekeeper for Kubernetes

This catches policy logic issues early.

---

## **6. How do you debug Rego policies?**

Tools I use:

* `opa eval` with sample input
* Add print statements inside the policy
* Terraform plan inspection
* Gatekeeper audit logs

Rego debugging is mostly about understanding the structure of your input data.

---

## **7. How do you integrate OPA with GitHub Actions / Jenkins?**

Pipeline stages:

1. `terraform fmt`
2. `terraform validate`
3. **OPA/Conftest** run
4. Then `terraform plan`
5. Manual approval
6. Deploy

If OPA fails, the code never moves forward.

---

## **8. What is the typical structure of a Rego policy?**

A Rego policy contains:

* package name
* deny rules
* conditions that describe violations
* output messages

Example:

```rego
package s3.encryption

deny[msg] {
  bucket := input.resource_changes[_]
  bucket.type == "aws_s3_bucket"
  not bucket.change.after.server_side_encryption_configuration
  msg = sprintf("Bucket %v must have encryption", [bucket.address])
}
```

---

## **9. What is the difference between allow and deny rules?**

* **Deny rules** list what should be blocked.
* **Allow rules** explicitly grant permission.

For infrastructure, **deny-based policies** are simpler and more common.

---

## **10. How do you access input data in Rego?**

`input` represents the Terraform plan or Kubernetes manifest.

Example:
`input.resource_changes` gives you all Terraform resources.

---

## **11. What is the default keyword for?**

It sets baseline behavior.

Example:

```rego
default deny = false
```

Which means:
If no deny rule matches → allow deployment.

---

## **12. How do you enforce mandatory tags using Rego?**

Example rule:

```rego
deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  not input.resource_changes[_].change.after.tags.Environment
  msg = "Missing Environment tag"
}
```

Simple but effective.

---

## **13. How do you enforce S3 encryption with OPA?**

Check if:

* encryption block exists
* algorithm is valid

If missing → deny.

OPA prevents insecure S3 buckets from being created.

---

## **14. How do you enforce security group rules with OPA?**

Check for:

* CIDR block 0.0.0.0/0
* Ports like 22/3389

If found → deny.

---

## **15. How do you restrict AWS regions using OPA?**

Whitelist the allowed regions.

If region not in list → deny.

---

## **16. How do you enforce runAsNonRoot for Kubernetes?**

Check the pod securityContext:

```rego
deny[msg] {
  not input.spec.containers[_].securityContext.runAsNonRoot
}
```

---

## **17. What Gatekeeper policies have you created?**

Examples:

* No privileged containers
* Must set CPU/memory limits
* Must set runAsNonRoot
* No hostPath mounts
* Restricted container capabilities

This enforces strong pod security.

---

## **18. How do you deploy Gatekeeper?**

Using Helm:

```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper/gatekeeper
```

Then create templates + constraints.

---

## **19. How do you store and version OPA policies?**

In Git repos with:

* Branch protection
* Pull request approval
* Git tags
* GitOps syncing

Everything is fully auditable.

---

## **20. How do you audit policy changes?**

I rely on:

* Git history
* CI/CD logs
* Gatekeeper audit
* Conftest logs

This makes compliance review easy.

---

## **21. How do you maintain hundreds of policies?**

I use a structured folder layout:

```
tags/
s3/
ec2/
iam/
networking/
kubernetes/
eks/
compliance/
```

Each domain has its own OPA bundle.

---

## **22. How do you optimize Rego performance?**

* Keep rules simple
* Avoid nested loops
* Use indexing
* Use audit mode for heavy evaluation
* Split large policies

---

## **23. How do you run OPA in microservices?**

Two patterns:

1. **Sidecar container**
2. **External authorization server** (Envoy)

For IaC, I mainly use OPA externally with Conftest or Gatekeeper.

---

## **24. How do you restrict IAM role creation via OPA?**

Block wildcard permissions:

```rego
deny[msg] {
  action := input.resource_changes[_].change.after.inline_policy.Statement[_].Action
  action == "*"
  msg = "Wildcard IAM actions not allowed"
}
```

---

## **25. What is the biggest challenge working with OPA?**

Staying in sync with **new AWS services and features**.
Policies evolve as the cloud evolves.

---



---

## **26. What is AWS Config?**

AWS Config is a **detective control** that tracks configuration changes and checks resources against compliance rules.

I use it to ensure:

* encryption
* tagging
* networking restrictions
* IAM security

---

## **27. Have you written custom AWS Config rules?**

Yes.
I write Lambda-based Config rules using Python to evaluate resources that managed rules can’t cover.

---

## **28. Example of a custom AWS Config rule you wrote?**

A rule that checks:

* If S3 bucket has encryption
* If versioning is enabled

If either is missing → NON_COMPLIANT.

---

## **29. What Python libraries did you use?**

Primarily:

* **boto3** for AWS APIs
* **json** for parsing input
* **logging** for audit logs

---

## **30. How do you return evaluations to AWS Config?**

Using:

```python
config.put_evaluations(
   Evaluations=[{...}],
   ResultToken=event['resultToken']
)
```

This returns COMPLIANT or NON_COMPLIANT.

---

## **31. How do you structure a Config rule Lambda?**

Flow:

1. Parse event
2. Get resource details
3. Check compliance
4. Return evaluation

Simple, predictable pattern.

---

## **32. How do you validate AWS Config rules?**

* Test events in Lambda console
* Deploy to sandbox account
* Trigger Config with sample bucket

---

## **33. How do you remediate Config violations?**

Using:

* **EventBridge** → Lambda
* **SSM Automation**
* **SecurityHub integration**

Remediation is automated.

---

## **34. Do you use Config Aggregators?**

Yes — they give centralized visibility across all AWS accounts.

---

## **35. How do you secure AWS Config?**

* Deny disabling Config via SCP
* Encrypt Config S3 bucket
* Enable Config in all regions

---

## **36. Example: custom rule for security groups?**

Check if:

* SG allows 0.0.0.0/0
* Port matches restricted ports

If yes → NON_COMPLIANT.

---

## **37. How do you detect unused IAM roles?**

Custom rule queries IAM:

* lastUsedDate
* role age

Old unused roles are NON_COMPLIANT.

---

## **38. How do you alert on Config violations?**

EventBridge → SNS / Slack / CloudWatch alarm.

---

## **39. How do you remediate S3 misconfigurations?**

Lambda:

* Enable encryption
* Enable versioning
* Block public access

---

## **40. How do you track compliance metrics?**

CloudWatch dashboards and aggregated Config reports.

---

## **41. How do you evaluate IAM compliance?**

Check:

* If policies contain `"*"`
* If MFA is disabled
* If admin access is overly broad

---

## **42. How do you test Config locally?**

Mock boto3 using `moto`.

---

## **43. How do you integrate Config with OPA?**

OPA prevents non-compliant resources in CI/CD.
Config detects drift after deployment.

---

## **44. What is your most-used custom rule?**

Tagging compliance — ensuring consistency across accounts.

---

## **45. What’s the hardest part about custom Config rules?**

Ensuring fast execution — Lambda has a time limit.

---

## **46. How do you run remediation workflows?**

EventBridge → SSM or Lambda → CloudWatch logs

---

## **47. How do you secure the Config delivery channel?**

* Use private S3 bucket
* Deny public access
* Encrypt with SSE-KMS

---

## **48. How do you handle Config in multi-account setup?**

Use Aggregators + Organization-level Config rules.

---

## **49. How do you use Config with SecurityHub?**

Config results feed into SecurityHub controls automatically.

---

## **50. What is your Config deployment method?**

Terraform modules + Lambda zip packaging + CI/CD.



# **What is OPA (Open Policy Agent)?**

OPA is a **Policy-as-Code** engine.
It allows you to write rules that **allow or deny** something.

Instead of manually checking security, access, or configuration, **OPA enforces rules automatically**.

Example real situations:

* "Do not allow public S3 buckets"
* "Do not allow SSH open to 0.0.0.0/0"
* "Only approved users can deploy to production"
* "Every resource must have cost and owner tags"

OPA works everywhere: Kubernetes, AWS services, microservices, APIs, etc.

---

# **What is Rego?**

Rego is the **language** used to write OPA policies.

If OPA is the engine,
**Rego is the language that tells the engine what to do.**

Rego reads:

* **input** = information about the request/resource
* **rules** = your conditions
* **decision** = allow or deny

---

# **Where OPA is Used in AWS**

| Location                          | Purpose                                               | Tool                               |
| --------------------------------- | ----------------------------------------------------- | ---------------------------------- |
| **EKS / Kubernetes**              | Block bad deployments                                 | **OPA Gatekeeper**                 |
| **Terraform Deployment Pipeline** | Block non-compliant AWS resources **before creation** | `opa eval` in CI/CD                |
| **AWS Accounts Compliance**       | Detect & auto-fix violations                          | **AWS Config + EventBridge + OPA** |
| **API Security**                  | Decide whether a request is allowed                   | OPA sidecar / Envoy                |

---

# **Real Interview-Ready Example (Clear & Simple)**

> **Most recent real example**

In my last project, I used OPA to enforce **no public S3 buckets** across multiple AWS accounts.

**Why?**
SecurityHub kept reporting public buckets → that is a major data leakage risk.

**What I did:**

1. Wrote a **Rego policy** that checks bucket ACL and encryption.
2. Integrated it with **AWS Config + EventBridge**.
3. If a bucket becomes public:

   * It **immediately triggers remediation**.
   * ACL is reset to private.
   * Encryption is enabled.

**Outcome:**

* Public buckets reduced to **zero**
* SecurityHub compliance scores increased
* Passed internal audit successfully

Say this in the interview — it is perfect.

---

# **What AWS Resources I Wrote OPA Policies For**

* **S3** (prevent public access, enforce encryption)
* **EC2** (enforce tags, restrict AMIs to approved ones)
* **Security Groups** (deny 0.0.0.0/0 for SSH or DB ports)
* **IAM Roles** (restrict privileged policies)
* **EKS** deployments (no privileged containers, required labels, prevent host networking)

---

# **How I Integrate OPA with EKS, API Gateway, IAM**

### **EKS**

I deploy **OPA Gatekeeper** → it checks Kubernetes manifests before they are applied.
If the manifest violates policy → deployment is blocked.

### **CI/CD (Terraform)**

OPA evaluates `terraform plan`.
If the plan tries to create a non-compliant resource → pipeline fails.

### **AWS Config + EventBridge**

Used for **continuous monitoring** and **auto-remediation** of live AWS resources.

---

# **How I Test and Validate OPA Policies**

| Step                           | What I Do                                | Purpose                            |
| ------------------------------ | ---------------------------------------- | ---------------------------------- |
| **1. Unit Tests (`opa test`)** | Test policy logic locally                | Find mistakes early                |
| **2. Dry-Run Mode**            | Run policy in **audit mode** first       | Avoid production impact            |
| **3. CI/CD Integration**       | Validate during Terraform/K8s deployment | Prevent bad infrastructure release |

This shows control and safe rollout — interviewers like that.

---

# **Tools I Use to Manage OPA**

* **Terraform** → to deploy OPA/Gatekeeper configurations
* **GitHub Actions / Jenkins** → to run policy checks in CI/CD
* **Argo CD** → to sync policies to multiple clusters
* **AWS Config / SecurityHub** → continuous evaluation

---

# **How I Version, Audit, and Roll Back Policies**

* All policies stored in **Git**
* Every change goes through **Pull Request review**
* CI automatically tests before merging
* Git history gives **traceability and audit record**
* If a policy causes issues → simply **rollback commit**

---

# **Debugging OPA (Important Answer)**

When a policy blocks something unexpectedly:

1. I use **opa eval --explain=full** to see why.
2. For Gatekeeper, I check **audit logs** to see which rule triggered.
3. I adjust conditions to be more specific.

This shows controlled troubleshooting.

---

# **Performance Optimization**

To keep OPA fast:

* Avoid nested loops
* Store lookup data in `data` (OPA's memory store)
* Reuse computed logic instead of recalculating

This prevents OPA becoming slow in high-traffic systems.

---

# **Deploying OPA in Microservices (API Security)**

* OPA runs **as a sidecar** or **Envoy external-auth**
* Microservice sends request metadata to OPA
* OPA returns **allow/deny**
* No central dependency → **very fast** and scalable

---

# **Using OPA in Kubernetes (Gatekeeper)**

To manage multiple clusters:

* We store policies in a **central Git repo**
* Use **Argo CD** to push updates to all clusters
* This ensures **same security rules everywhere**








## 1) **Tell Me About Your Role / Project**

**Answer:**

> I built a Profile Service application on AWS using EKS, DynamoDB, and Terraform. The application is a Python Flask API deployed on Kubernetes behind an AWS ALB. I used IRSA to allow the pods to securely access DynamoDB without storing any credentials. The entire infrastructure is provisioned using Terraform, and CI/CD is automated with GitHub Actions to build, test, and deploy changes. I enabled observability using Prometheus and Grafana and implemented DynamoDB Global Tables for multi-region active-active disaster recovery. This project demonstrates end-to-end DevOps and SRE practices including automation, security, scaling, monitoring, and reliability.

---

## 2) **Difference Between DevOps and SRE**

**Answer:**

> DevOps focuses on automation, CI/CD, and improving the speed of delivery.
> SRE focuses on reliability, stability, and uptime in production environments.
>
> DevOps = **Ship Faster**
> SRE = **Keep It Reliable**
>
> SRE uses **SLIs, SLOs, SLAs, and Error Budgets** to balance reliability with deployment velocity.

---

## 3) **SLI, SLO, SLA — and How They Tie Together**

**Answer:**

> **SLI** is the *metric* we measure (e.g., success rate, latency).
> **SLO** is the *target* we want to achieve for that metric (e.g., 99.9% success).
> **SLA** is the *external legal/business promise* we make to customers (e.g., 99.5% uptime or credits).
>
> So the relationship is:
>
> * SLI provides the **data**
> * SLO provides the **internal goal**
> * SLA provides the **external commitment**

---

## 4) **Three Important Functions of an SRE**

**Answer:**

1. **Reliability Management** — maintain availability & performance using SLIs/SLOs & error budgets.
2. **Monitoring & Incident Response** — implement observability, run on-call, troubleshoot production.
3. **Automation & Toil Reduction** — eliminate manual work through scripts, pipelines, and tooling.

---

## 5) **Encryption In-Transit vs At-Rest**

**Answer:**

> **In Transit:** I use **TLS/HTTPS** on the ALB to encrypt all traffic to the app, and pod-to-DynamoDB communication is encrypted via HTTPS.
>
> **At Rest:** DynamoDB is encrypted using **KMS**, EBS volumes are encrypted, and secrets are stored using **Secrets Manager or IRSA**—never in plain text.

---

## 6) **DynamoDB — How You Worked With It**

**Answer:**

> I provision DynamoDB using Terraform. I design the schema around access patterns, choose a partition key for scalability, and enable KMS encryption and TTL.
>
> I use **IAM Role for Service Accounts (IRSA)** to allow EKS pods to access DynamoDB securely without storing any credentials.
>
> For multi-region DR, I use **DynamoDB Global Tables** to achieve active-active replication across regions.

---

## 7) **Can DynamoDB Be Active-Active?**

**Answer:**

> Yes. DynamoDB supports active-active through **Global Tables**, which replicate data across multiple AWS regions automatically. Each region becomes a full read/write primary. This is commonly used in high-availability and multi-region architectures.

---

## 8) **Disaster Recovery Strategy (High-Critical Systems like Netflix)**

**Answer:**

> For mission-critical systems, I recommend an **Active-Active Multi-Region architecture**:
>
> * Deploy services in multiple AWS regions
> * Use **DynamoDB Global Tables** for data replication
> * Use **Route 53 latency routing** for automatic regional failover
> * Ensure **observability + health checks** for traffic shift decisions
>   This reduces downtime to near-zero and meets very low RPO/RTO requirements.

---

## 9) **Troubleshooting: Application Cannot Reach Database**

**Answer:**
I follow a **layered debugging** approach:

1. **Network:** `kubectl exec` into pod → `nslookup` + `nc -z <host> <port>`
2. **DNS:** Validate DB endpoint resolves
3. **IAM / IRSA:** Ensure the correct role is attached to ServiceAccount
4. **Configuration:** Validate env variables (TABLE_NAME, region, etc.)
5. **Logs / Flow Logs:** Check CloudWatch + DynamoDB metrics for errors

**This shows discipline & SRE troubleshooting mindset.**

---

## 10) **Python Automation in CI/CD**

**Answer:**

> Yes, I wrote Python automation that runs inside the CI/CD pipeline.
> The script validates configs, checks required environment variables, and prevents deploying misconfigured code.
> If the script fails, **it returns a non-zero exit code**, which causes the **pipeline to stop**, preventing bad deployments.

---

## 11) **What Happens if the Script Fails?**

**Answer:**

> The pipeline stops immediately. The deployment does not proceed. Logs indicate failure, we address the issue, and re-run. This ensures production remains in a safe, known good state.

---

## 12) **Why Are You Looking for a Change?**

**Answer:**

> I gained great experience working with large systems at Bank of America. However, the environment is process-heavy. I’m looking for a faster-moving engineering culture where I can have more hands-on technical ownership, especially around Kubernetes, Terraform, observability, and reliability automation.

---

# 🎤 **Closing Line to End the Interview Strong**

**Answer:**

> Thank you for the discussion. I really enjoyed this conversation. The role aligns very well with my experience in Kubernetes, Terraform, observability, and SRE mindset. I would be excited to contribute and continue growing with your team.


