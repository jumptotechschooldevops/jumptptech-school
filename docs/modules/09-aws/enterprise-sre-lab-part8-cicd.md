---
title: "Part 8: GitHub Actions CI/CD Pipeline"
description: OIDC-authenticated GitHub Actions pipeline — build, test, scan, push to ECR, deploy to ECS with rollback
---

# Part 8: GitHub Actions CI/CD Pipeline

**← [Part 7: Monitoring](enterprise-sre-lab-part7-monitoring.md) | [Part 9: Runbooks →](enterprise-sre-lab-part9-runbooks.md)**

---

## Objective

Build a production-grade GitHub Actions pipeline for ShopFlow that uses OIDC authentication (no long-lived AWS credentials), runs tests and security scanning, pushes to ECR with immutable tags, deploys to ECS with blue/green support, and auto-rolls back on failure.

---

## Pipeline Architecture

```
Developer pushes to main
    │
    ▼
GitHub Actions
    │
    ├── 1. Test (unit + integration)
    │
    ├── 2. Security Scan (Trivy + SAST)
    │
    ├── 3. Build Docker image
    │
    ├── 4. Push to ECR (tag: sha + latest)
    │
    ├── 5. Deploy to Staging (ECS rolling update)
    │     └── smoke test
    │
    └── 6. Deploy to Production (approval gate)
          └── ECS rolling update + circuit breaker
          └── smoke test + rollback if fails
```

---

## Step 1 — AWS OIDC Setup

OIDC lets GitHub Actions assume an IAM role without storing long-lived credentials in GitHub Secrets.

### Terraform: OIDC Provider + Role

```hcl
# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "shopflow-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Only allow from your specific repo
            "token.actions.githubusercontent.com:sub" = "repo:your-org/shopflow:*"
          }
        }
      }
    ]
  })
}

# IAM Policy for CI/CD operations
resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeImages"
        ]
        Resource = [
          "arn:aws:ecr:us-east-1:${var.aws_account_id}:repository/shopflow/*"
        ]
      },
      {
        Sid    = "ECSDeployment"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]
        Resource = "*"
      },
      {
        Sid    = "PassExecutionRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/shopflow-ecs-execution-role",
          "arn:aws:iam::${var.aws_account_id}:role/shopflow-ecs-task-role"
        ]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}
```

---

## Step 2 — Main CI/CD Workflow

### .github/workflows/deploy.yml

```yaml
name: ShopFlow CI/CD Pipeline

on:
  push:
    branches: [main]
    paths:
      - 'services/api/**'
      - 'services/checkout/**'
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: 123456789012.dkr.ecr.us-east-1.amazonaws.com
  ECS_CLUSTER: shopflow-prod

permissions:
  id-token: write  # Required for OIDC
  contents: read
  security-events: write  # For Trivy SARIF upload

jobs:
  # ─── JOB 1: Tests ──────────────────────────────────────────
  test:
    name: Unit & Integration Tests
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: testpassword
          MYSQL_DATABASE: shopflow_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s

      redis:
        image: redis:7
        ports:
          - 6379:6379
        options: --health-cmd="redis-cli ping" --health-interval=5s

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: 'services/api/package-lock.json'

      - name: Install dependencies
        run: |
          cd services/api
          npm ci

      - name: Run unit tests
        run: |
          cd services/api
          npm run test:unit -- --coverage

      - name: Run integration tests
        env:
          DB_HOST: localhost
          DB_PORT: 3306
          DB_NAME: shopflow_test
          DB_PASSWORD: testpassword
          REDIS_HOST: localhost
          REDIS_PORT: 6379
        run: |
          cd services/api
          npm run test:integration

      - name: Upload test coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: services/api/coverage/

  # ─── JOB 2: Security Scanning ──────────────────────────────
  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    needs: test

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner (code scan)
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: './services/api'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'  # Fail pipeline on HIGH/CRITICAL vulnerabilities

      - name: Upload Trivy SARIF to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Run Checkov (IaC scanning)
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          soft_fail: true  # Don't fail pipeline, but report findings

  # ─── JOB 3: Build & Push ───────────────────────────────────
  build-and-push:
    name: Build & Push to ECR
    runs-on: ubuntu-latest
    needs: [test, security-scan]
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/shopflow-github-actions-role
          aws-region: ${{ env.AWS_REGION }}
          role-session-name: github-actions-build

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.ECR_REGISTRY }}/shopflow/api-service
          tags: |
            type=sha,prefix=,format=long
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build and push Docker image
        id: build
        uses: docker/build-push-action@v5
        with:
          context: ./services/api
          file: ./services/api/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          platforms: linux/arm64  # Graviton2
          cache-from: type=gha
          cache-to: type=gha,mode=max
          provenance: true  # SLSA provenance attestation

      - name: Run Trivy on built image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.ECR_REGISTRY }}/shopflow/api-service:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-image.sarif'
          severity: 'CRITICAL'
          exit-code: '1'

  # ─── JOB 4: Deploy to Staging ──────────────────────────────
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: staging

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::111111111111:role/shopflow-github-actions-role
          aws-region: ${{ env.AWS_REGION }}

      - name: Download ECS task definition
        run: |
          aws ecs describe-task-definition \
            --task-definition shopflow-staging-api \
            --query taskDefinition \
            > task-definition.json

      - name: Update ECS task definition with new image
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: api
          image: ${{ env.ECR_REGISTRY }}/shopflow/api-service:${{ github.sha }}

      - name: Deploy to ECS Staging
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: shopflow-staging-api
          cluster: shopflow-staging
          wait-for-service-stability: true
          wait-for-minutes: 10

      - name: Run smoke tests against staging
        run: |
          STAGING_URL="https://api-staging.shopflow.internal"
          
          # Wait for ALB to route to new tasks
          sleep 30
          
          # Health check
          curl -f "$STAGING_URL/health" || exit 1
          
          # Basic API functionality
          curl -f "$STAGING_URL/api/v1/products?limit=1" || exit 1
          
          echo "Smoke tests passed!"

  # ─── JOB 5: Deploy to Production ───────────────────────────
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment: production  # Requires manual approval in GitHub

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/shopflow-github-actions-role
          aws-region: ${{ env.AWS_REGION }}

      - name: Download production task definition
        run: |
          aws ecs describe-task-definition \
            --task-definition shopflow-prod-api \
            --query taskDefinition \
            > task-definition.json

      - name: Update task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: api
          image: ${{ env.ECR_REGISTRY }}/shopflow/api-service:${{ github.sha }}

      - name: Deploy to ECS Production
        id: deploy
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: shopflow-prod-api
          cluster: ${{ env.ECS_CLUSTER }}
          wait-for-service-stability: true
          wait-for-minutes: 15
          # Circuit breaker is enabled in Terraform (auto-rollback on failure)

      - name: Run production smoke tests
        run: |
          PROD_URL="https://api.shopflow.com"
          
          sleep 60  # Wait for new tasks to be fully serving
          
          # Health check
          curl -f "$PROD_URL/health" || exit 1
          
          # Check error rate for 60 seconds
          START=$(date +%s)
          while [ $(($(date +%s) - START)) -lt 60 ]; do
            STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$PROD_URL/api/v1/products?limit=1")
            if [ "$STATUS" != "200" ]; then
              echo "Health check failed with status: $STATUS"
              exit 1
            fi
            sleep 5
          done
          
          echo "Production smoke tests passed!"

      - name: Notify Slack on success
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: '#deploys'
          payload: |
            {
              "text": "✅ *shopflow/api* deployed to production\nCommit: ${{ github.sha }}\nAuthor: ${{ github.actor }}"
            }
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}

      - name: Notify Slack on failure + rollback info
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: '#incidents'
          payload: |
            {
              "text": "🚨 *DEPLOY FAILED* - shopflow/api production\nCommit: ${{ github.sha }}\nECS circuit breaker should have triggered rollback.\nRunbook: https://docs.shopflow.internal/runbooks/deploy-failure"
            }
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

---

## Step 3 — Terraform CI/CD Workflow

### .github/workflows/terraform.yml

```yaml
name: Terraform Plan & Apply

on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'
  pull_request:
    paths:
      - 'terraform/**'

jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/shopflow-terraform-role
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: '1.6.0'

      - name: Terraform Init
        run: |
          cd terraform/environments/${{ matrix.environment }}
          terraform init

      - name: Terraform Validate
        run: |
          cd terraform/environments/${{ matrix.environment }}
          terraform validate

      - name: Terraform Plan
        id: plan
        run: |
          cd terraform/environments/${{ matrix.environment }}
          terraform plan \
            -var-file=terraform.tfvars \
            -out=tfplan \
            -no-color 2>&1 | tee plan-output.txt

      - name: Comment PR with plan
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('terraform/environments/${{ matrix.environment }}/plan-output.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan — ${{ matrix.environment }}\n\`\`\`\n${plan.slice(-10000)}\n\`\`\``
            });

  terraform-apply-prod:
    name: Terraform Apply (prod)
    runs-on: ubuntu-latest
    needs: terraform-plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: terraform-prod  # Requires approval

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/shopflow-terraform-role
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: '1.6.0'

      - name: Terraform Init
        run: |
          cd terraform/environments/prod
          terraform init

      - name: Terraform Apply
        run: |
          cd terraform/environments/prod
          terraform apply \
            -var-file=terraform.tfvars \
            -auto-approve
```

---

## Step 4 — Rollback Procedure

If the ECS circuit breaker doesn't auto-rollback, use this manual procedure:

```bash
# 1. Identify the last stable task definition revision
aws ecs describe-services \
  --cluster shopflow-prod \
  --services shopflow-prod-api \
  --query 'services[0].deployments'

# 2. Find the previous task definition
aws ecs list-task-definitions \
  --family-prefix shopflow-prod-api \
  --sort DESC \
  --query 'taskDefinitionArns[:5]'

# 3. Roll back to previous revision
PREVIOUS_TASK_DEF="shopflow-prod-api:42"  # Replace with actual revision

aws ecs update-service \
  --cluster shopflow-prod \
  --service shopflow-prod-api \
  --task-definition $PREVIOUS_TASK_DEF \
  --force-new-deployment

# 4. Monitor the rollback
aws ecs wait services-stable \
  --cluster shopflow-prod \
  --services shopflow-prod-api

echo "Rollback complete"

# 5. Verify health
curl -f https://api.shopflow.com/health
```

---

## Step 5 — Environment Protection Rules (GitHub)

Configure these in GitHub → Settings → Environments:

| Environment | Rules |
|------------|-------|
| `staging` | None (auto-deploy on merge to main) |
| `production` | Required reviewers: 2 SRE engineers |
| `terraform-prod` | Required reviewers: 1 SRE lead |

---

## Verification Checklist — Part 8

```
[ ] OIDC provider created in AWS IAM
[ ] GitHub Actions IAM role with condition restricting to your org/repo
[ ] IAM policy scoped to ECR push, ECS deploy, PassRole (only execution/task roles)
[ ] CI workflow: unit tests + integration tests with real MySQL and Redis
[ ] Trivy filesystem scan fails on HIGH/CRITICAL CVEs
[ ] Trivy container image scan after build
[ ] Checkov scans Terraform code
[ ] Docker buildx builds for linux/arm64 (Graviton)
[ ] Images tagged with git SHA (immutable), not just 'latest'
[ ] Staging deployment with smoke test before prod gate
[ ] Production environment requires 2 approvers
[ ] ECS circuit breaker enabled (auto-rollback on failed deployment)
[ ] Smoke test runs for 60s monitoring error rate post-deploy
[ ] Slack notifications: success to #deploys, failure to #incidents
[ ] Manual rollback procedure documented and tested
[ ] Terraform CI: plan on PR, apply on merge with approval gate
```

---

**[Part 9: Production Runbooks →](enterprise-sre-lab-part9-runbooks.md)**
