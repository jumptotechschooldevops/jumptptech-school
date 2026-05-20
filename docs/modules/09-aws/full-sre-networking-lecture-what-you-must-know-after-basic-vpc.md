---
title: "Full SRE Networking Lecture: What You Must Know After Basic VPC"
description: "1. DNS and Route 53   DNS is one of the most important networking topics for SRE. Many..."
published: 2026-04-30
source: "https://dev.to/jumptotech/full-sre-networking-lecture-what-you-must-know-after-basic-vpc-35op"
tags: []
---

# Full SRE Networking Lecture: What You Must Know After Basic VPC



# 

## 1. DNS and Route 53

DNS is one of the most important networking topics for SRE. Many production outages look like “application is down,” but the real issue is DNS.

DNS translates a name into an IP address or another DNS name.

Example:

```bash
jumptotech.com → ALB DNS name → EC2 targets
```

In AWS, the main DNS service is **Amazon Route 53**. Route 53 is used to manage domain records and route users to AWS resources like ALB, CloudFront, S3 static websites, or failover endpoints.

Important DNS record types:

```text
A record     → domain to IPv4 address
AAAA record  → domain to IPv6 address
CNAME        → domain to another domain
ALIAS        → Route 53 record pointing to AWS resources like ALB or CloudFront
TXT          → verification, SPF, DKIM, security records
MX           → email routing
```

In production, for an application, the flow is usually:

```text
User
 ↓
Route 53
 ↓
Application Load Balancer
 ↓
Private application servers
```

As an SRE, when a website is not reachable, you should not immediately check EC2. First check DNS.

Use:

```bash
nslookup example.com
dig example.com
dig example.com +short
```

Troubleshooting questions:

```text
Does the domain resolve?
Does it point to the correct ALB?
Was DNS changed recently?
Is TTL too long?
Is Route 53 health check failing?
Is the record public or private hosted zone?
```

Route 53 can also use health checks and failover routing. AWS recommends evaluating target health for alias records when using health-based DNS routing, otherwise Route 53 may still route traffic to unhealthy resources. ([AWS Documentation][1])

Interview answer:

Route 53 is AWS DNS service. I use it to route user traffic to AWS resources such as ALB or CloudFront. As an SRE, I troubleshoot DNS by checking resolution, record type, TTL, hosted zone, and whether the DNS target is healthy.

---

## 2. Load Balancing: ALB vs NLB

A load balancer distributes traffic across multiple targets. In production, users should not directly access EC2 instances. They should access a load balancer.

Main AWS load balancers:

```text
ALB = Application Load Balancer
NLB = Network Load Balancer
```

### Application Load Balancer

ALB works at Layer 7, the application layer. It understands HTTP and HTTPS.

Use ALB for:

```text
web applications
APIs
path-based routing
host-based routing
HTTPS termination
microservices
containerized apps
```

Example:

```text
app.example.com      → frontend target group
api.example.com      → backend target group
/example/orders      → orders service
/example/payments    → payment service
```

ALB uses:

```text
Listener
Rule
Target Group
Health Check
```

A listener receives traffic on a port, usually 80 or 443. A rule decides where to forward the request. A target group contains EC2, ECS tasks, IPs, or Lambda targets. Health checks decide whether the target should receive traffic. AWS documentation says ALB target groups route requests to registered targets and health checks are configured per target group. ([AWS Documentation][2])

Production flow:

```text
Internet
 ↓
Route 53
 ↓
ALB in public subnet
 ↓
EC2/ECS/EKS app in private subnet
 ↓
RDS database in private subnet
```

As an SRE, if ALB returns `503`, usually it means no healthy targets.

Check:

```text
Are targets registered?
Are targets healthy?
Is health check path correct?
Is app listening on correct port?
Does app security group allow traffic from ALB security group?
Is the app returning 200 on health check path?
```

Useful commands:

```bash
curl -I http://alb-dns-name
curl http://private-app-ip:8080/health
```

### Network Load Balancer

NLB works at Layer 4. It handles TCP, UDP, and TLS traffic.

Use NLB for:

```text
very high performance
TCP applications
static IP requirement
low latency
non-HTTP protocols
```

Examples:

```text
Kafka
database proxy
game servers
TCP services
```

NLB health checks determine whether targets are available. AWS documentation says NLB uses active and passive health checks and routes traffic only to healthy targets in enabled Availability Zones unless cross-zone load balancing is enabled. ([AWS Documentation][3])

Interview answer:

I use ALB for HTTP and HTTPS applications because it supports Layer 7 routing, TLS termination, host-based and path-based rules. I use NLB for high-performance TCP or UDP workloads where low latency or static IP is required.

---

## 3. Target Groups and Health Checks

Health checks are critical for reliability.

A load balancer should not send traffic to a broken server. That is why every target group has a health check.

Example health check:

```text
Protocol: HTTP
Path: /health
Success code: 200
Interval: 30 seconds
Healthy threshold: 3
Unhealthy threshold: 2
```

Bad health check:

```text
/
```

Why? Maybe homepage works but database connection is broken.

Better health check:

```text
/health
```

This endpoint should check:

```text
application running
database reachable
required dependencies available
```

But do not make health checks too heavy. If `/health` runs expensive database queries every few seconds, the health check itself can overload the app.

As an SRE, when deployment causes outage, check target group health first.

Troubleshooting:

```text
Target unhealthy because timeout?
Target unhealthy because 403?
Target unhealthy because 500?
Wrong port?
Wrong path?
Security group blocking ALB?
App binding to localhost only?
```

Common mistake:

Application listens on:

```text
127.0.0.1:8080
```

But it should listen on:

```text
0.0.0.0:8080
```

Interview answer:

Health checks allow the load balancer to remove unhealthy targets from rotation. As an SRE, I always verify the health check path, port, response code, security group, and application logs.

---

## 4. VPC Endpoints

VPC endpoints allow private resources to access AWS services without using the public internet.

AWS documentation says VPC endpoints privately connect your VPC to supported AWS services without requiring an internet gateway, NAT device, VPN, or Direct Connect. Traffic stays on the AWS network backbone. ([AWS Documentation][4])

Without VPC endpoint:

```text
Private EC2
 ↓
NAT Gateway
 ↓
Internet path
 ↓
S3
```

With VPC endpoint:

```text
Private EC2
 ↓
VPC Endpoint
 ↓
S3
```

Types:

```text
Gateway Endpoint   → S3, DynamoDB
Interface Endpoint → SSM, ECR, CloudWatch, Secrets Manager, STS, KMS
```

Why SRE uses VPC endpoints:

```text
increase security
reduce NAT Gateway dependency
reduce NAT data processing cost
allow private subnet access to AWS services
support private architecture
```

Very important real-world example:

You have private EC2 with no public IP. You want to connect using AWS Systems Manager Session Manager.

You may need interface endpoints for:

```text
ssm
ssmmessages
ec2messages
```

If your private EC2 needs to pull Docker images from ECR, you may need endpoints for:

```text
ecr.api
ecr.dkr
s3
CloudWatch Logs
```

Troubleshooting endpoint issues:

```text
Is endpoint created in correct VPC?
Is private DNS enabled?
Is security group allowing HTTPS 443 to endpoint?
Is route table configured for gateway endpoint?
Does IAM policy allow access?
Is endpoint policy blocking access?
```

Interview answer:

I use VPC endpoints when private workloads need to access AWS services without going through the public internet or NAT Gateway. This improves security and can reduce cost.

---

## 5. AWS PrivateLink

PrivateLink is related to VPC endpoints, but it is more advanced.

AWS PrivateLink allows private connectivity between VPCs, AWS services, services in other AWS accounts, and Marketplace services without using public internet, NAT, VPN, or Direct Connect. ([AWS Documentation][5])

Use case:

Company A exposes service privately.

Company B consumes it privately.

```text
Consumer VPC
 ↓
Interface Endpoint
 ↓
PrivateLink
 ↓
Provider NLB
 ↓
Provider service
```

PrivateLink is service-level access, not full network access.

This is very important.

Difference:

```text
VPC Peering     → connects networks
Transit Gateway → connects many networks
PrivateLink     → exposes only one service privately
```

Why this matters:

With VPC peering, VPCs can potentially route to many internal resources.

With PrivateLink, the consumer can access only the specific service exposed through the endpoint.

When to use PrivateLink:

```text
SaaS provider exposing private API
shared internal service
cross-account service access
security-sensitive architecture
avoid full VPC-to-VPC routing
```

Interview answer:

PrivateLink is used when we want to expose a specific service privately without giving full network access between VPCs. It is more controlled than VPC peering.

---

## 6. VPC Peering

VPC peering connects two VPCs using private IPs.

Example:

```text
VPC A: 10.0.0.0/16
VPC B: 10.1.0.0/16
```

After peering:

```text
EC2 in VPC A → private IP → EC2 in VPC B
```

Rules:

```text
CIDR blocks cannot overlap
Peering must be accepted
Routes must be added on both sides
Security groups must allow traffic
NACLs must allow traffic
Peering is not transitive
```

Not transitive means:

```text
VPC A peers with VPC B
VPC B peers with VPC C
VPC A cannot automatically reach VPC C
```

Use peering when:

```text
only two or a few VPCs need communication
simple architecture
low operational complexity
```

Do not use peering when you have many VPCs. It becomes hard to manage.

Troubleshooting peering:

```text
Is peering active?
Are CIDRs overlapping?
Does VPC A route table point to peering connection?
Does VPC B route table point back?
Do SG/NACL allow traffic?
Is DNS resolution enabled if using private DNS names?
```

Interview answer:

VPC peering is private connectivity between two VPCs. It is simple and low-latency, but it does not support transitive routing and does not scale well for many VPCs.

---

## 7. Transit Gateway

Transit Gateway is like a cloud router.

Instead of creating many VPC peering connections, you attach VPCs to one central hub.

Without Transit Gateway:

```text
VPC A ↔ VPC B
VPC A ↔ VPC C
VPC A ↔ VPC D
VPC B ↔ VPC C
...
```

This becomes messy.

With Transit Gateway:

```text
VPC A
  ↓
Transit Gateway
  ↑
VPC B
  ↑
VPC C
  ↑
VPN / Direct Connect
```

Use Transit Gateway for:

```text
many VPCs
multi-account architecture
shared services VPC
hybrid cloud
centralized firewall inspection
enterprise networks
```

AWS VPC connectivity documentation lists Transit Gateway, VPC peering, PrivateLink, VPN, and Direct Connect as major private connectivity options. ([AWS Documentation][6])

As an SRE, you need to know that Transit Gateway has route tables too.

Troubleshooting Transit Gateway:

```text
Is VPC attached to TGW?
Is attachment available?
Is route propagated?
Is route associated with correct TGW route table?
Do subnet route tables point to TGW?
Do SG/NACL allow traffic?
Is there asymmetric routing?
```

Interview answer:

Transit Gateway is used as a central network hub to connect many VPCs and hybrid networks. It is better than VPC peering when the environment has many VPCs or accounts.

---

## 8. VPN and Direct Connect

These are used for hybrid cloud: connecting on-premises data centers to AWS.

### Site-to-Site VPN

VPN creates encrypted tunnels over the public internet.

Flow:

```text
On-prem router/firewall
 ↓ encrypted tunnel
AWS VPN Gateway / Transit Gateway
 ↓
VPC
```

Use VPN when:

```text
quick setup
lower cost
backup connection
encrypted connection over internet
```

Limitations:

```text
internet-dependent
latency can vary
bandwidth limited compared to Direct Connect
```

### Direct Connect

Direct Connect is a dedicated private network connection from your data center or colocation to AWS.

Use Direct Connect when:

```text
stable latency required
large data transfer
enterprise hybrid cloud
more predictable performance
```

AWS documentation describes connectivity options using Direct Connect, Site-to-Site VPN, and Transit Gateway for remote network to VPC connectivity. ([AWS Documentation][7])

Production design often uses:

```text
Direct Connect as primary
VPN as backup
Transit Gateway as hub
```

Troubleshooting hybrid connectivity:

```text
Is tunnel up?
Is BGP established?
Are routes advertised?
Are security groups allowing traffic?
Are on-prem firewalls allowing traffic?
Is return route correct?
Is DNS resolving private names?
```

Interview answer:

VPN provides encrypted connectivity over the internet, while Direct Connect provides a dedicated private connection to AWS. In production, companies often use Direct Connect for stable performance and VPN as backup.

---

## 9. AWS WAF

WAF means Web Application Firewall.

Security Group controls ports and IP access.

NACL controls subnet-level traffic.

WAF protects web applications at Layer 7.

WAF can block:

```text
SQL injection
cross-site scripting
bad bots
malicious IPs
rate-based attacks
suspicious headers
```

Common placement:

```text
User
 ↓
Route 53
 ↓
CloudFront or ALB
 ↓
WAF
 ↓
Application
```

Use WAF when:

```text
public web application
API exposed to internet
compliance requirement
need Layer 7 protection
need rate limiting
```

Troubleshooting WAF:

```text
Is WAF blocking legitimate traffic?
Check WAF logs
Check rule priority
Check managed rule false positives
Check rate limit
Check IP reputation list
```

Interview answer:

WAF protects applications at Layer 7 from web attacks such as SQL injection, XSS, and bad bots. I use it in front of ALB or CloudFront for internet-facing applications.

---

## 10. CloudFront and CDN Basics

CloudFront is AWS CDN.

CDN means content delivery network.

It caches content close to users.

Example:

Without CloudFront:

```text
User in California → ALB in Virginia
```

With CloudFront:

```text
User in California → nearest edge location → origin
```

Use CloudFront for:

```text
static websites
images
videos
frontend apps
API acceleration
global users
DDoS protection with Shield
TLS termination
```

CloudFront origin can be:

```text
S3
ALB
EC2
API Gateway
custom domain
```

SRE troubleshooting:

```text
Is cache serving old content?
Is origin healthy?
Is behavior path correct?
Is HTTPS certificate valid?
Is WAF blocking request?
Is DNS pointing to CloudFront?
```

Common issue:

You deploy new frontend, but users still see old version.

Fix:

```text
CloudFront invalidation
```

Interview answer:

CloudFront improves performance by caching content at edge locations closer to users. As an SRE, I troubleshoot CloudFront by checking cache behavior, origin health, invalidations, certificates, WAF, and DNS.

---

## 11. Network Observability

SRE must prove what is happening in the network.

Important tools:

```text
VPC Flow Logs
ALB access logs
CloudWatch metrics
CloudTrail
Route 53 query logs
WAF logs
Transit Gateway flow logs
```

### VPC Flow Logs

VPC Flow Logs capture IP traffic metadata for network interfaces.

They help answer:

```text
Was traffic accepted or rejected?
Which source IP connected?
Which destination port?
Which ENI?
Which subnet?
```

Use VPC Flow Logs for:

```text
security investigation
NACL troubleshooting
SG troubleshooting
network visibility
unexpected traffic analysis
```

Example:

```text
REJECT TCP 10.0.3.10 10.0.5.20 5432
```

This tells you traffic to database port was rejected.

### ALB access logs

ALB logs show:

```text
client IP
request path
target status code
load balancer status code
response time
target processing time
```

Useful for:

```text
502
503
504
slow requests
bad target responses
```

### SRE book mindset

Google’s SRE book emphasizes that monitoring should help decide what should interrupt a human and what should not. Good monitoring is not collecting everything; good monitoring detects user-impacting issues. ([Google SRE][8])

Interview answer:

For network observability, I use VPC Flow Logs, ALB logs, Route 53 logs, WAF logs, and CloudWatch metrics. These help me identify whether the issue is DNS, routing, firewall, load balancer, target health, or application.

---

## 12. Full Production Network Architecture

This is the architecture you must be able to explain in interviews.

```text
Users
 ↓
Route 53
 ↓
CloudFront + WAF
 ↓
Application Load Balancer - public subnets
 ↓
Application servers / ECS / EKS - private app subnets
 ↓
RDS / ElastiCache - private DB subnets
```

Supporting components:

```text
NAT Gateway       → private outbound internet
VPC Endpoint      → private AWS service access
Transit Gateway   → multi-VPC connectivity
VPN/DX            → on-prem connectivity
VPC Flow Logs     → network observability
CloudWatch        → metrics and alarms
```

Production rules:

```text
ALB goes in public subnets
App goes in private subnets
DB goes in private subnets
NAT Gateway goes in public subnet
Private servers do not get public IPs
DB is never open to internet
Use SG references instead of hardcoded IPs
Use Multi-AZ for availability
Use VPC endpoints for private AWS service access
Use WAF for internet-facing apps
```

---

## 13. SRE Troubleshooting Framework

When production is down, do not guess.

Follow this order:

```text
1. DNS
2. CDN / WAF
3. Load Balancer
4. Security Groups
5. Route Tables
6. NACL
7. Target Health
8. Application Logs
9. Database
10. Dependencies
```

### Scenario 1: Website is down

Check:

```bash
dig app.example.com
curl -I https://app.example.com
```

Then:

```text
Is Route 53 pointing to correct ALB/CloudFront?
Is certificate valid?
Is WAF blocking?
Is ALB reachable?
Are targets healthy?
Is app running?
```

### Scenario 2: ALB returns 503

Meaning:

```text
No healthy targets
```

Check:

```text
Target group health
Health check path
Security group from ALB to app
App port
App logs
Deployment status
```

### Scenario 3: ALB returns 504

Meaning:

```text
Gateway timeout
```

Check:

```text
App too slow?
DB slow?
Target not responding?
Timeout configuration?
Network path blocked?
```

### Scenario 4: Private EC2 cannot access internet

Check:

```text
Private route table has 0.0.0.0/0 → NAT Gateway
NAT Gateway is available
NAT Gateway has Elastic IP
NAT is in public subnet
Public subnet routes 0.0.0.0/0 → IGW
SG allows outbound
NACL allows ephemeral ports
```

### Scenario 5: EC2 cannot access S3 privately

Check:

```text
Gateway endpoint exists?
Route table associated?
Bucket policy allows endpoint?
IAM role allows S3?
Region correct?
```

### Scenario 6: App cannot connect to RDS

Check:

```text
RDS running?
Correct endpoint?
Correct port?
DB SG allows app SG?
App subnet route table has local route?
NACL allows traffic both directions?
Credentials correct?
DB max connections reached?
```

### Scenario 7: VPC peering not working

Check:

```text
Peering active?
CIDR non-overlapping?
Routes added both sides?
SG allows remote CIDR or SG?
NACL allows?
DNS resolution enabled?
```

---

## 14. What You Must Memorize for Interview

You must know this table:

```text
Route 53        → DNS
CloudFront      → CDN / edge caching
WAF             → Layer 7 web protection
ALB             → HTTP/HTTPS load balancing
NLB             → TCP/UDP load balancing
VPC             → private network
Subnet          → network segment in one AZ
Route Table     → controls traffic direction
IGW             → internet access for public subnets
NAT Gateway     → outbound internet for private subnets
SG              → stateful resource firewall
NACL            → stateless subnet firewall
VPC Endpoint    → private access to AWS services
PrivateLink     → private service exposure
VPC Peering     → private VPC-to-VPC network connection
Transit Gateway → central router for many VPCs
VPN             → encrypted hybrid connection over internet
Direct Connect  → private dedicated hybrid connection
Flow Logs       → network traffic visibility
```

---

## 15. Strong Final Interview Answer

Use this answer:

I design AWS networking using layered architecture. I use Route 53 for DNS, CloudFront and WAF for edge performance and security, ALB for public application entry, private subnets for application workloads, and isolated private subnets for databases. I use NAT Gateway only for outbound internet from private subnets and VPC endpoints when private workloads need AWS service access without internet. For multi-VPC communication, I choose VPC peering for simple cases, Transit Gateway for large enterprise hub-and-spoke architecture, and PrivateLink when only one private service should be exposed. As an SRE, I troubleshoot from DNS to load balancer, route tables, security groups, NACLs, target health, logs, and application dependencies.

[1]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-complex-configs.html?utm_source=chatgpt.com "How health checks work in complex Amazon Route 53 ..."
[2]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html?utm_source=chatgpt.com "Target groups for your Application Load Balancers"
[3]: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-health-checks.html?utm_source=chatgpt.com "Health checks for Network Load Balancer target groups"
[4]: https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/centralized-access-to-vpc-private-endpoints.html?utm_source=chatgpt.com "Centralized access to VPC private endpoints"
[5]: https://docs.aws.amazon.com/vpc/latest/userguide/endpoint-services-overview.html?utm_source=chatgpt.com "Connect your VPC to services using AWS PrivateLink"
[6]: https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/amazon-vpc-to-amazon-vpc-connectivity-options.html?utm_source=chatgpt.com "Amazon VPC-to-Amazon VPC connectivity options"
[7]: https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/introduction.html?utm_source=chatgpt.com "Introduction - Amazon Virtual Private Cloud Connectivity ..."
[8]: https://sre.google/sre-book/monitoring-distributed-systems/?utm_source=chatgpt.com "Chapter 6 - Monitoring Distributed Systems"

