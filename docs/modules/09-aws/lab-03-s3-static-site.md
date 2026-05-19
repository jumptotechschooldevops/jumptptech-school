# Lab 3 · S3 Static Website

**Duration:** ~60 minutes  
**Goal:** Host a static website on S3, configure versioning, set up a lifecycle policy, and front it with CloudFront for HTTPS and global performance.

**Cost estimate:** S3 and CloudFront have a 12-month free tier. Under normal use this lab costs < $0.01.

**Prerequisites:**
- AWS CLI configured
- A domain name in Route 53 is optional (CloudFront gives you an `*.cloudfront.net` URL for free)

---

## Part 1 — Create the bucket

S3 bucket names must be globally unique across all AWS customers.

```bash
# Choose a unique name
BUCKET_NAME="my-static-site-$(aws sts get-caller-identity --query Account --output text)"
REGION="us-east-1"

echo "Bucket: $BUCKET_NAME"

# Create bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Verify
aws s3api get-bucket-versioning --bucket $BUCKET_NAME
```

---

## Part 2 — Build the website

Create a minimal static site locally:

```bash
mkdir -p ~/s3-lab/site
cd ~/s3-lab/site
```

**index.html**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DevOps School</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header>
    <h1>DevOps School</h1>
    <p>AWS Module — Static Website on S3 + CloudFront</p>
  </header>
  <main>
    <section>
      <h2>What we learned</h2>
      <ul>
        <li>IAM users, roles, and policies</li>
        <li>EC2 instances and security groups</li>
        <li>S3 object storage and static hosting</li>
        <li>CloudFront CDN distribution</li>
      </ul>
    </section>
  </main>
  <footer>
    <p>Hosted on Amazon S3 · Delivered by CloudFront</p>
  </footer>
  <script src="app.js"></script>
</body>
</html>
```

**style.css**:
```css
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; background: #f5f5f5; color: #333; }
header { background: #232f3e; color: white; padding: 2rem; text-align: center; }
header p { color: #ff9900; margin-top: 0.5rem; }
main { max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
section { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
h2 { margin-bottom: 1rem; color: #232f3e; }
ul { padding-left: 1.5rem; line-height: 2; }
footer { text-align: center; padding: 2rem; color: #666; font-size: 0.9rem; }
```

**404.html**:
```html
<!DOCTYPE html>
<html>
<head><title>Page Not Found</title></head>
<body>
  <h1>404 — Page Not Found</h1>
  <p><a href="/">Go home</a></p>
</body>
</html>
```

**app.js**:
```javascript
document.addEventListener('DOMContentLoaded', () => {
  const footer = document.querySelector('footer p');
  footer.textContent += ` · Loaded at ${new Date().toLocaleTimeString()}`;
});
```

---

## Part 3 — Upload to S3

```bash
cd ~/s3-lab

# Upload all files
aws s3 sync site/ s3://$BUCKET_NAME/ \
  --cache-control "max-age=86400" \
  --exclude "*.DS_Store"

# Verify upload
aws s3 ls s3://$BUCKET_NAME/
```

Check versioning is tracking objects:
```bash
aws s3api list-object-versions \
  --bucket $BUCKET_NAME \
  --query 'Versions[].{Key:Key,VersionId:VersionId,LastModified:LastModified}'
```

---

## Part 4 — Configure static website hosting

```bash
aws s3api put-bucket-website \
  --bucket $BUCKET_NAME \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "404.html"}
  }'

# Get the website endpoint
echo "Website URL: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
```

### Make objects public (for S3 website endpoint)

The S3 website endpoint does not support IAM authentication — objects must be publicly readable.

```bash
# Remove block public access (required before setting a public policy)
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Set bucket policy allowing public reads
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Principal\": \"*\",
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"arn:aws:s3:::${BUCKET_NAME}/*\"
    }]
  }"
```

Test the S3 website endpoint:
```bash
curl http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com
```

!!! note
    The S3 website endpoint only supports HTTP. In Part 5 we add CloudFront for HTTPS.

---

## Part 5 — Set up CloudFront

CloudFront is a CDN that caches content at edge locations worldwide. It also provides HTTPS (using an ACM certificate).

```bash
# Create the distribution
# Note: For CloudFront with S3 website as origin, use the website endpoint as origin domain
DISTRIBUTION=$(aws cloudfront create-distribution \
  --distribution-config "{
    \"CallerReference\": \"lab-$(date +%s)\",
    \"Comment\": \"DevOps school static site\",
    \"DefaultCacheBehavior\": {
      \"TargetOriginId\": \"S3WebsiteOrigin\",
      \"ViewerProtocolPolicy\": \"redirect-to-https\",
      \"CachePolicyId\": \"658327ea-f89d-4fab-a63d-7e88639e58f6\",
      \"Compress\": true
    },
    \"Origins\": {
      \"Quantity\": 1,
      \"Items\": [{
        \"Id\": \"S3WebsiteOrigin\",
        \"DomainName\": \"${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com\",
        \"CustomOriginConfig\": {
          \"HTTPPort\": 80,
          \"HTTPSPort\": 443,
          \"OriginProtocolPolicy\": \"http-only\"
        }
      }]
    },
    \"Enabled\": true,
    \"DefaultRootObject\": \"index.html\",
    \"PriceClass\": \"PriceClass_100\"
  }")

DIST_ID=$(echo $DISTRIBUTION | python3 -c "import sys,json; print(json.load(sys.stdin)['Distribution']['Id'])")
DIST_DOMAIN=$(echo $DISTRIBUTION | python3 -c "import sys,json; print(json.load(sys.stdin)['Distribution']['DomainName'])")

echo "Distribution ID: $DIST_ID"
echo "CloudFront URL: https://$DIST_DOMAIN"
```

Deployment takes 5–10 minutes. Check the status:

```bash
aws cloudfront get-distribution \
  --id $DIST_ID \
  --query 'Distribution.Status'
# Starts as "InProgress", becomes "Deployed"
```

Wait for deployment:
```bash
aws cloudfront wait distribution-deployed --id $DIST_ID
echo "CloudFront is live: https://$DIST_DOMAIN"
```

Test:
```bash
curl -I https://$DIST_DOMAIN
# Should show: HTTP/2 200 and x-cache: Miss from cloudfront (first request)

curl -I https://$DIST_DOMAIN
# Second request: x-cache: Hit from cloudfront
```

The `x-cache` header shows whether CloudFront served from cache or fetched from S3.

---

## Part 6 — Test versioning

Modify `index.html` and upload a new version:

```bash
# Edit the title
sed -i '' 's/DevOps School/DevOps School v2/' ~/s3-lab/site/index.html

# Upload
aws s3 cp ~/s3-lab/site/index.html s3://$BUCKET_NAME/index.html

# List versions — you now have 2
aws s3api list-object-versions \
  --bucket $BUCKET_NAME \
  --prefix index.html \
  --query 'Versions[].{VersionId:VersionId,LastModified:LastModified,IsLatest:IsLatest}'
```

### Roll back to the previous version

```bash
# Get the previous version ID (the one with IsLatest: false)
OLD_VERSION=$(aws s3api list-object-versions \
  --bucket $BUCKET_NAME \
  --prefix index.html \
  --query 'Versions[?IsLatest==`false`].VersionId' \
  --output text)

echo "Old version: $OLD_VERSION"

# Copy old version over current
aws s3api copy-object \
  --bucket $BUCKET_NAME \
  --copy-source "$BUCKET_NAME/index.html?versionId=$OLD_VERSION" \
  --key index.html

# Verify rollback
curl http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com | grep title
```

---

## Part 7 — Configure lifecycle policy

Add a policy to clean up old object versions after 30 days:

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket $BUCKET_NAME \
  --lifecycle-configuration '{
    "Rules": [
      {
        "ID": "delete-old-versions",
        "Status": "Enabled",
        "Filter": {},
        "NoncurrentVersionExpiration": {
          "NoncurrentDays": 30
        },
        "ExpiredObjectDeleteMarker": true
      }
    ]
  }'

# Verify
aws s3api get-bucket-lifecycle-configuration --bucket $BUCKET_NAME
```

---

## Part 8 — Invalidate the CloudFront cache

After updating content, the CDN edge caches may still serve old versions for up to 24 hours (or the TTL you set). Invalidate to force fresh fetches:

```bash
aws cloudfront create-invalidation \
  --distribution-id $DIST_ID \
  --paths "/*"
```

For CI/CD pipelines, run this after every deployment:

```bash
# In your deploy script
aws s3 sync dist/ s3://$BUCKET_NAME/ --delete
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

---

## Part 9 — Check access logs (optional)

Enable CloudFront access logging to an S3 bucket for traffic analysis:

```bash
# Create a logs bucket
LOGS_BUCKET="cf-logs-$(aws sts get-caller-identity --query Account --output text)"
aws s3api create-bucket --bucket $LOGS_BUCKET --region $REGION

# Enable ACLs on logs bucket (required by CloudFront logging)
aws s3api put-bucket-acl --bucket $LOGS_BUCKET --acl log-delivery-write

# Update distribution to enable logging
aws cloudfront update-distribution \
  --id $DIST_ID \
  --if-match $(aws cloudfront get-distribution --id $DIST_ID --query 'ETag' --output text) \
  --distribution-config "$(aws cloudfront get-distribution-config --id $DIST_ID \
    --query 'DistributionConfig' --output json | \
    python3 -c "
import sys, json
config = json.load(sys.stdin)
config['Logging'] = {
  'Enabled': True,
  'IncludeCookies': False,
  'Bucket': '${LOGS_BUCKET}.s3.amazonaws.com',
  'Prefix': 'cf-logs/'
}
print(json.dumps(config))
")"
```

---

## Verification checklist

- [ ] S3 bucket created with versioning enabled
- [ ] `index.html`, `style.css`, `app.js`, `404.html` uploaded
- [ ] S3 website endpoint returns HTML (HTTP)
- [ ] CloudFront distribution deployed and returns HTTPS
- [ ] `x-cache: Hit from cloudfront` after second request
- [ ] Updated `index.html`, second version visible in `list-object-versions`
- [ ] Rollback to previous version works
- [ ] Lifecycle policy configured to expire old versions after 30 days
- [ ] Cache invalidation runs after content update

---

## Cleanup

```bash
# Disable the CloudFront distribution first (must be disabled before deletion)
aws cloudfront update-distribution \
  --id $DIST_ID \
  --if-match $(aws cloudfront get-distribution --id $DIST_ID --query 'ETag' --output text) \
  --distribution-config "$(aws cloudfront get-distribution-config --id $DIST_ID \
    --query 'DistributionConfig' --output json | \
    python3 -c "import sys,json; c=json.load(sys.stdin); c['Enabled']=False; print(json.dumps(c))")"

# Wait for it to be disabled (5-10 min)
aws cloudfront wait distribution-deployed --id $DIST_ID

# Delete distribution
aws cloudfront delete-distribution \
  --id $DIST_ID \
  --if-match $(aws cloudfront get-distribution --id $DIST_ID --query 'ETag' --output text)

# Empty and delete S3 buckets
# Must delete all versions and delete markers before deleting a versioned bucket
aws s3api delete-objects \
  --bucket $BUCKET_NAME \
  --delete "$(aws s3api list-object-versions \
    --bucket $BUCKET_NAME \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
    --output json)"

aws s3api delete-objects \
  --bucket $BUCKET_NAME \
  --delete "$(aws s3api list-object-versions \
    --bucket $BUCKET_NAME \
    --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
    --output json)"

aws s3api delete-bucket --bucket $BUCKET_NAME
aws s3 rb s3://$LOGS_BUCKET --force 2>/dev/null || true
```
