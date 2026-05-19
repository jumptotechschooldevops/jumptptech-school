---
title: "Project: Cloud Guardrails with OPA + Conftest + Config/SecurityHub + Auto-Remediation"
description: "Repo layout (copy this)      cloud-guardrails/ ├─ README.md ├─ 01-eks-gatekeeper/ │  ├─..."
published: 2025-11-11
source: "https://dev.to/jumptotech/project-cloud-guardrails-with-opa-conftest-configsecurityhub-auto-remediation-lcl"
tags: []
---

# Project: Cloud Guardrails with OPA + Conftest + Config/SecurityHub + Auto-Remediation





## Repo layout (copy this)

```
cloud-guardrails/
├─ README.md
├─ 01-eks-gatekeeper/
│  ├─ install-gatekeeper.sh
│  ├─ policies/
│  │  ├─ ct-no-privileged-containers.yaml
│  │  ├─ c-no-privileged-containers.yaml
│  │  ├─ ct-require-runasnonroot.yaml
│  │  ├─ c-require-runasnonroot.yaml
│  │  ├─ ct-require-resources.yaml
│  │  ├─ c-require-resources.yaml
│  │  ├─ ct-disallow-hostpath.yaml
│  │  ├─ c-disallow-hostpath.yaml
│  └─ tests/
│     ├─ bad-pod.yaml
│     └─ good-deployment.yaml
├─ 02-conftest-terraform/
│  ├─ policies/
│  │  ├─ s3.rego
│  │  ├─ ebs.rego
│  │  └─ iam.rego
│  ├─ terraform/
│  │  ├─ main.tf
│  │  └─ variables.tf
│  └─ run.sh
├─ 03-config-securityhub/
│  ├─ enable-config-securityhub.sh
│  └─ verify-findings.sh
├─ 04-auto-remediation/
│  ├─ eventbridge-rule.json
│  ├─ lambda_s3_public_block/handler.py
│  ├─ lambda_s3_public_block/policy.json
│  └─ deploy.sh
└─ .github/
   └─ workflows/
      └─ policy-checks.yml
```

---

## Prereqs

* AWS CLI configured (`aws configure`)
* kubectl + an EKS cluster with `kubectl` access
* Helm (optional), jq, and `conftest`
* Terraform (to demo pre-deployment checks)
* Your AWS account must allow creating buckets, Lambda, EventBridge, IAM roles, etc.

---

## 01) Preventive Controls: Gatekeeper on EKS

### 1. Install Gatekeeper

`01-eks-gatekeeper/install-gatekeeper.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
echo "Waiting for Gatekeeper to be ready..."
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-controller-manager
kubectl -n gatekeeper-system get pods
```

### 2. Core policies (ConstraintTemplates + Constraints)

**Deny privileged containers**
`01-eks-gatekeeper/policies/ct-no-privileged-containers.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8sprivilegedcontainer
spec:
  crd:
    spec:
      names:
        kind: K8sPrivilegedContainer
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sprivilegedcontainer
      violation[{"msg": msg}] {
        input.review.kind.kind == "Pod"
        some c
        c := input.review.object.spec.containers[_]
        c.securityContext.privileged == true
        msg := sprintf("privileged container not allowed: %v", [c.name])
      }
```

`01-eks-gatekeeper/policies/c-no-privileged-containers.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPrivilegedContainer
metadata:
  name: deny-privileged
spec:
  enforcementAction: deny
```

**Require runAsNonRoot**
`ct-require-runasnonroot.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srunasnonroot
spec:
  crd:
    spec:
      names:
        kind: K8sRunAsNonRoot
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8srunasnonroot
      violation[{"msg": msg}] {
        input.review.kind.kind == "Pod"
        some c
        c := input.review.object.spec.containers[_]
        not c.securityContext.runAsNonRoot
        msg := sprintf("runAsNonRoot must be true for container: %v", [c.name])
      }
```

`c-require-runasnonroot.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRunAsNonRoot
metadata:
  name: require-runasnonroot
spec:
  enforcementAction: deny
```

**Require CPU/Memory limits**
`ct-require-resources.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8sresourcelimits
spec:
  crd:
    spec:
      names:
        kind: K8sResourceLimits
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sresourcelimits
      violation[{"msg": msg}] {
        input.review.kind.kind == "Pod"
        c := input.review.object.spec.containers[_]
        not has_limits(c)
        msg := sprintf("container must set resources.limits: %v", [c.name])
      }
      has_limits(c) {
        c.resources.limits.cpu
        c.resources.limits.memory
      }
```

`c-require-resources.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sResourceLimits
metadata:
  name: require-resource-limits
spec:
  enforcementAction: deny
```

**Disallow hostPath**
`ct-disallow-hostpath.yaml`

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8sdisallowhostpath
spec:
  crd:
    spec:
      names:
        kind: K8sDisallowHostPath
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sdisallowhostpath
      violation[{"msg": msg}] {
        input.review.kind.kind == "Pod"
        v := input.review.object.spec.volumes[_]
        v.hostPath
        msg := "hostPath volumes are not allowed"
      }
```

`c-disallow-hostpath.yaml`

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDisallowHostPath
metadata:
  name: disallow-hostpath
spec:
  enforcementAction: deny
```

### 3. Apply policies

```bash
kubectl apply -f 01-eks-gatekeeper/policies/
```

### 4. Quick tests

`01-eks-gatekeeper/tests/bad-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bad
spec:
  containers:
  - name: bad
    image: nginx
    securityContext:
      privileged: true
```

```bash
kubectl apply -f 01-eks-gatekeeper/tests/bad-pod.yaml   # should be DENIED
```

`01-eks-gatekeeper/tests/good-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: good
spec:
  replicas: 1
  selector: { matchLabels: { app: good } }
  template:
    metadata: { labels: { app: good } }
    spec:
      containers:
      - name: web
        image: nginx
        securityContext:
          runAsNonRoot: true
        resources:
          limits:
            cpu: "250m"
            memory: "256Mi"
```

```bash
kubectl apply -f 01-eks-gatekeeper/tests/good-deployment.yaml   # should be ALLOWED
```

---

## 02) Pre-deployment Checks: Conftest + Terraform

### Example Terraform (S3 to demo)

`02-conftest-terraform/terraform/main.tf`

```hcl
provider "aws" { region = var.region }

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  acl    = "private"
}
```

`variables.tf`

```hcl
variable "region"      { default = "us-east-1" }
variable "bucket_name" { default = "my-guardrails-demo-bucket" }
```

### Rego policies for Conftest

`02-conftest-terraform/policies/s3.rego`

```rego
package security.s3

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  some i
  bucket := input.resource_changes[i]
  bucket.change.after.acl == "public-read"
  msg := sprintf("S3 bucket %v cannot be public-read", [bucket.address])
}
```

`02-conftest-terraform/policies/ebs.rego`

```rego
package security.ebs

deny[msg] {
  input.resource_changes[_].type == "aws_ebs_volume"
  some i
  v := input.resource_changes[i]
  not v.change.after.encrypted
  msg := sprintf("EBS volume %v must be encrypted", [v.address])
}
```

`02-conftest-terraform/policies/iam.rego`

```rego
package security.iam

deny[msg] {
  input.resource_changes[_].type == "aws_iam_policy"
  some i, s
  p := input.resource_changes[i]
  s := p.change.after.policy.Statement[_]
  s.Action == "*"
  msg := sprintf("IAM policy %v must not use Action *", [p.address])
}
```

### Run policy checks

`02-conftest-terraform/run.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
cd terraform
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform show -json tfplan | conftest test --policy ../policies -
echo "Conftest passed."
```

If a plan violates policies, Conftest exits **non-zero** and your pipeline fails.

---

## 03) Detective: Enable AWS Config + Security Hub

`03-config-securityhub/enable-config-securityhub.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${1:-us-east-1}
BUCKET="config-logs-${ACCOUNT_ID}-${REGION}"

aws s3 mb s3://$BUCKET 2>/dev/null || true

aws iam create-role --role-name AWSConfigRole \
  --assume-role-policy-document '{
    "Version":"2012-10-17","Statement":[{
      "Effect":"Allow","Principal":{"Service":"config.amazonaws.com"},"Action":"sts:AssumeRole"
    }]}'
aws iam attach-role-policy --role-name AWSConfigRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSConfigRole || true

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/AWSConfigRole"

aws configservice put-configuration-recorder \
  --configuration-recorder "name=default,roleARN=${ROLE_ARN},recordingGroup={allSupported=true,includeGlobalResourceTypes=true}"

aws configservice put-delivery-channel \
  --delivery-channel "name=default,s3BucketName=${BUCKET}"

aws configservice start-configuration-recorder --configuration-recorder-name default

aws securityhub enable-security-hub --region $REGION

# Enable standards (Foundational + CIS)
aws securityhub batch-enable-standards --standards-subscription-requests \
 '[{"StandardsArn":"arn:aws:securityhub:::standards/aws-foundational-security-best-practices/v/1.0.0"},
   {"StandardsArn":"arn:aws:securityhub:::standards/cis-aws-foundations-benchmark/v/1.4.0"}]' \
 --region $REGION

echo "Config + SecurityHub enabled in $REGION"
```

`03-config-securityhub/verify-findings.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
aws securityhub get-findings --max-results 10 | jq '.Findings | length'
```

---

## 04) Auto-Remediation: EventBridge → Lambda (fix public S3)

**Event rule** (fire when a Config rule marks S3 NON_COMPLIANT):
`04-auto-remediation/eventbridge-rule.json`

```json
{
  "Source": ["aws.config"],
  "DetailType": ["Config Rules Compliance Change"],
  "Detail": {
    "newEvaluationResult": {
      "complianceType": ["NON_COMPLIANT"]
    }
  }
}
```

**Lambda code**
`04-auto-remediation/lambda_s3_public_block/handler.py`

```python
import json, os
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):
    # Expect Config event with resourceId == bucket name
    detail = event.get("detail", {})
    resource = detail.get("resourceId") or (detail.get("newEvaluationResult") or {}).get("evaluationResultIdentifier", {}).get("evaluationResultQualifier", {}).get("resourceId")

    if not resource:
        print("No resourceId in event:", json.dumps(event))
        return {"status": "no_resource"}

    bucket = resource
    print(f"Auto-remediating S3 bucket: {bucket}")

    # Block all public access
    s3.put_public_access_block(
        Bucket=bucket,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True
        }
    )
    # Remove public ACL if present
    try:
        s3.put_bucket_acl(Bucket=bucket, ACL="private")
    except Exception as e:
        print("ACL update failed (may already be private):", e)

    # Optional: attach deny public policy
    bucket_policy = {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": [f"arn:aws:s3:::{bucket}", f"arn:aws:s3:::{bucket}/*"],
        "Condition": {"Bool": {"aws:SecureTransport": "false"}}
      }]
    }
    try:
        s3.put_bucket_policy(Bucket=bucket, Policy=json.dumps(bucket_policy))
    except Exception as e:
        print("Policy set failed (may have existing policy):", e)

    print("Remediation complete.")
    return {"status": "ok", "bucket": bucket}
```

**Lambda execution policy** (minimal):
`04-auto-remediation/lambda_s3_public_block/policy.json`

```json
{
  "Version":"2012-10-17",
  "Statement":[
    {"Effect":"Allow","Action":["s3:PutBucketPolicy","s3:PutBucketAcl","s3:PutPublicAccessBlock"],"Resource":"*"},
    {"Effect":"Allow","Action":"logs:*","Resource":"*"}
  ]
}
```

**Deploy helper**
`04-auto-remediation/deploy.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
REGION=${1:-us-east-1}
FN=auto-remediate-s3-public

# Package (zip)
cd 04-auto-remediation/lambda_s3_public_block
zip -qr function.zip .
cd -

# Create role
aws iam create-role --role-name lambda-s3-remediate-role \
  --assume-role-policy-document '{
    "Version":"2012-10-17","Statement":[{
      "Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' || true
aws iam put-role-policy --role-name lambda-s3-remediate-role --policy-name inline \
  --policy-document file://04-auto-remediation/lambda_s3_public_block/policy.json

ROLE_ARN=$(aws iam get-role --role-name lambda-s3-remediate-role --query Role.Arn --output text)

# Create/update Lambda
aws lambda get-function --function-name $FN >/dev/null 2>&1 && EXISTS=1 || EXISTS=0
if [ "$EXISTS" -eq 0 ]; then
  aws lambda create-function --function-name $FN \
    --runtime python3.11 --handler handler.lambda_handler \
    --zip-file fileb://04-auto-remediation/lambda_s3_public_block/function.zip \
    --role $ROLE_ARN --timeout 60 --memory-size 256 --region $REGION
else
  aws lambda update-function-code --function-name $FN \
    --zip-file fileb://04-auto-remediation/lambda_s3_public_block/function.zip --region $REGION
fi

# EventBridge rule + target
RULE=ConfigNonCompliant
aws events put-rule --name $RULE --event-pattern file://04-auto-remediation/eventbridge-rule.json --region $REGION
aws events put-targets --rule $RULE --targets "Id"="1","Arn"="$(aws lambda get-function --function-name $FN --query Configuration.FunctionArn --output text --region $REGION)" --region $REGION

# Permission for EB to invoke Lambda
aws lambda add-permission --function-name $FN --statement-id evtrule --action lambda:InvokeFunction \
  --principal events.amazonaws.com --source-arn "$(aws events describe-rule --name $RULE --query Arn --output text --region $REGION)" --region $REGION || true

echo "Auto-remediation deployed in $REGION"
```

### Test the whole flow

1. Enable Config/SecurityHub

```bash
bash 03-config-securityhub/enable-config-securityhub.sh us-east-1
```

2. Deploy auto-remediation

```bash
bash 04-auto-remediation/deploy.sh us-east-1
```

3. Create a **public** S3 bucket (to trigger)

```bash
aws s3api create-bucket --bucket guardrails-public-test-$(date +%s) --region us-east-1
aws s3api put-bucket-acl --bucket guardrails-public-test-XXXX --acl public-read
```

4. Watch Lambda logs & SecurityHub findings. Bucket should be **auto-locked**.

---

## CI: Block insecure changes in PRs

`.github/workflows/policy-checks.yml`

```yaml
name: Policy Checks
on: [pull_request]
jobs:
  conftest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - name: Install conftest
        run: |
          curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.56.0/conftest_0.56.0_Linux_x86_64.tar.gz | tar xz
          sudo mv conftest /usr/local/bin
      - name: Terraform plan + conftest
        working-directory: 02-conftest-terraform/terraform
        run: |
          terraform init -input=false
          terraform plan -out=tfplan -input=false
          terraform show -json tfplan | conftest test --policy ../policies -
```

This makes your **PR fail** if a developer tries to push a public S3 bucket, unencrypted EBS, or wildcard IAM.

---

# How to demo quickly (commands summary)

1. **Gatekeeper**

```bash
bash 01-eks-gatekeeper/install-gatekeeper.sh
kubectl apply -f 01-eks-gatekeeper/policies/
kubectl apply -f 01-eks-gatekeeper/tests/bad-pod.yaml    # expect DENY
kubectl apply -f 01-eks-gatekeeper/tests/good-deployment.yaml
```

2. **Conftest + Terraform**

```bash
bash 02-conftest-terraform/run.sh   # fails if plan violates rules
```

3. **Config + SecurityHub + Auto-Remediation**

```bash
bash 03-config-securityhub/enable-config-securityhub.sh us-east-1
bash 04-auto-remediation/deploy.sh us-east-1
# create a public bucket → watch auto-fix
```

---

# Interview: What to say (scripts you can read)

## “Tell me about yourself” (Cloud Security / DevOps)

“I design and operate **policy-as-code guardrails** in AWS. My recent work combined **OPA Gatekeeper** on EKS for **preventive** controls, **Conftest** to block insecure Terraform plans **before deployment**, and **AWS Config + Security Hub** for **continuous detective** controls. For issues like public S3 buckets, I built **EventBridge-to-Lambda auto-remediation** so violations are fixed in seconds. This approach keeps teams fast while keeping the cloud compliant.”

## 60-second project walkthrough

“We implemented a layered model:

1. **Preventive**: OPA Gatekeeper denies insecure K8s workloads (no privileged containers, enforced runAsNonRoot, resources, no hostPath).
2. **Pre-deployment**: Conftest fails CI if Terraform creates public S3, unencrypted EBS, or wildcard IAM.
3. **Detective**: AWS Config + Security Hub turn on CIS and Foundational checks.
4. **Auto-remediation**: EventBridge triggers Lambda to remove S3 public access automatically.
   Result: non-compliant resources dropped ~70–80% and drift is corrected automatically.”

## STAR story (use this if they ask “biggest impact”)

* **S**: Multiple AWS accounts had inconsistent controls; misconfigs slipped through.
* **T**: Build uniform guardrails without slowing teams.
* **A**: Added Gatekeeper policies in EKS, Conftest in CI, enabled Config/SecurityHub, and built EventBridge→Lambda auto-remediation.
* **R**: Reduced non-compliant resources ~75% in a quarter; PRs catch issues early; S3 public exposure auto-fixed in <1 min.

## Why OPA + Conftest + Config/SecurityHub + Remediation?

* OPA/Gatekeeper = **block bad K8s at the door**
* Conftest = **block bad infra at PR time**
* Config/SecurityHub = **continuous monitoring & evidence**
* EventBridge/Lambda = **self-healing**
  Together: **shift-left + continuous + automated**.

## Common follow-ups (short, senior answers)

**Q: How do you roll out policies safely?**
A: Gatekeeper supports **audit** and **dry-run**. We start in audit-only, publish dashboards, fix false positives, then move to **enforce**. All policies versioned in Git with PRs.

**Q: How do you test Rego?**
A: `opa test` for unit tests, Conftest with sample inputs, Gatekeeper **audit** mode, and CI checks on PRs.

**Q: How do you keep up with AWS changes?**
A: Version policies, tag releases, run scheduled audits, and review Security Hub control updates each sprint; add new controls via PRs.

**Q: What metrics do you track?**
A: % of compliant resources, # of blocked deployments, mean-time-to-remediate, # of auto-remediations, policy false-positive rate.

**Q: Biggest challenge?**
A: Developer buy-in. We solved it by starting in **audit** mode, documenting examples, adding exemptions with expiry, and providing fast feedback in CI.

**Q: If something breaks production?**
A: Policies are Git-versioned; rollback is a revert/disable of constraint. We keep an emergency “audit-only” switch for Gatekeeper.

---

# What you can say at the end

“I’d apply the same layered model here: **preventive controls in EKS**, **policy checks in CI**, **Security Hub/Config detective controls**, and **EventBridge-driven auto-remediation**. It scales across accounts, keeps developers fast, and gives security evidence for audits.”


