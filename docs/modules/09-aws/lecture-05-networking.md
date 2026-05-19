# Lecture 5 · Networking — VPC & Route 53

Networking is often where cloud beginners struggle most. Understanding how traffic flows through a VPC — from the internet to a public subnet, from a public subnet to a private one, and back — is essential for both the exam and production architecture.

---

## VPC fundamentals

A **VPC (Virtual Private Cloud)** is a logically isolated section of the AWS cloud where you launch resources in a network you define. Every AWS account comes with a default VPC in each region. You should understand it but create your own for production workloads.

Key VPC properties:
- Spans all AZs in a region
- Has a **CIDR block** defining its IP address range (e.g., `10.0.0.0/16` = 65,536 addresses)
- Contains subnets, route tables, security groups, and gateways

```bash
# Create a VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Tag it
aws ec2 create-tags \
  --resources vpc-0abc123 \
  --tags Key=Name,Value=prod-vpc
```

---

## Subnets

A subnet is a range of IPs within a VPC, tied to a specific AZ.

- **Public subnet**: has a route to an Internet Gateway — instances can receive public traffic if they have a public IP
- **Private subnet**: no route to the internet — instances can only be reached from within the VPC (or via VPN/Direct Connect)

```
VPC: 10.0.0.0/16
├── us-east-1a
│   ├── Public subnet:  10.0.1.0/24  (256 addresses)
│   └── Private subnet: 10.0.10.0/24
└── us-east-1b
    ├── Public subnet:  10.0.2.0/24
    └── Private subnet: 10.0.20.0/24
```

AWS reserves 5 IPs per subnet: network address, VPC router, DNS, reserved for future use, broadcast. So a /24 gives you 251 usable IPs.

---

## Internet Gateway (IGW)

An IGW is a horizontally scaled, redundant VPC component that enables traffic between the VPC and the internet. It performs NAT for instances with public IPs.

```bash
# Create and attach an IGW
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway \
  --internet-gateway-id igw-0abc123 \
  --vpc-id vpc-0abc123
```

A subnet becomes "public" when its route table has `0.0.0.0/0 → igw-0abc123`.

---

## Route Tables

Every subnet is associated with a route table. The route table determines where traffic is directed.

```
Public Route Table:
  10.0.0.0/16 → local       (all VPC traffic stays local)
  0.0.0.0/0   → igw-0abc123 (everything else → internet)

Private Route Table:
  10.0.0.0/16 → local
  0.0.0.0/0   → nat-0abc123 (outbound only via NAT Gateway)
```

Create separate route tables for public and private subnets and associate the correct subnets.

---

## NAT Gateway

Instances in private subnets often need outbound internet access (to install packages, reach AWS APIs). A NAT Gateway in a public subnet provides this while keeping the instances unreachable from the internet.

NAT Gateway is:
- **AZ-specific** — create one per AZ for high availability
- Managed by AWS (no patching)
- Charged per hour plus per GB transferred

```bash
# Allocate an Elastic IP for the NAT Gateway
aws ec2 allocate-address --domain vpc

# Create NAT Gateway in public subnet
aws ec2 create-nat-gateway \
  --subnet-id subnet-public-1a \
  --allocation-id eipalloc-0abc123

# Add route in private route table
aws ec2 create-route \
  --route-table-id rtb-private \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id nat-0abc123
```

### NAT Instance vs NAT Gateway

| | NAT Instance | NAT Gateway |
|--|-------------|------------|
| Management | Self-managed EC2 | AWS managed |
| Availability | Single point of failure | Redundant within AZ |
| Bandwidth | Instance type dependent | Up to 100 Gbps |
| Cost | EC2 instance cost | Per hour + per GB |
| Port forwarding | Yes (iptables) | No |

Use NAT Gateway for production. NAT Instance is exam history and a cost-optimisation option for dev environments.

---

## Security Groups vs Network ACLs

These are two different layers of network access control. Both are tested heavily on the exam.

| | Security Group | Network ACL (NACL) |
|--|---------------|-------------------|
| Scope | Instance (ENI) | Subnet |
| Stateful? | Yes — return traffic automatic | No — both directions need rules |
| Rule types | Allow only | Allow and Deny |
| Rule evaluation | All rules evaluated | Rules evaluated in order (lowest number first) |
| Default | All inbound denied, all outbound allowed | Allow all inbound and outbound |

### Security Group example

```
Inbound:
  TCP 443  0.0.0.0/0   → allow HTTPS
  TCP 22   10.0.0.0/16 → allow SSH from VPC

Outbound:
  All traffic  0.0.0.0/0 → allow (default)
```

### NACL example

```
Rule 100: Allow TCP 80 inbound   0.0.0.0/0
Rule 110: Allow TCP 443 inbound  0.0.0.0/0
Rule 120: Allow TCP 1024-65535 inbound 0.0.0.0/0  ← ephemeral ports for responses
Rule *:   Deny all

Rule 100: Allow all outbound
Rule *:   Deny all
```

NACLs need explicit rules for **ephemeral ports** (1024-65535) because they are stateless. When a client connects on port 80, the server's response comes back on an ephemeral port from the client. Without the ephemeral port inbound rule, responses are blocked.

---

## VPC Endpoints

VPC Endpoints let you access AWS services (S3, DynamoDB, KMS, SSM) from within a VPC without going through the internet or NAT Gateway. Traffic stays on the AWS network.

### Gateway endpoints

For S3 and DynamoDB. Free. Add to route tables:

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-0abc123 \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids rtb-private
```

### Interface endpoints (PrivateLink)

For all other services (EC2 API, CloudWatch, Secrets Manager, etc.). Creates an ENI in your subnet with a private IP. Costs ~$0.01/hour per AZ plus data transfer.

---

## VPC Peering

Connects two VPCs (same or different accounts/regions) so that traffic routes between them using private IPs.

- Not transitive: if A peers with B and B peers with C, A cannot reach C through B
- CIDR ranges must not overlap
- Cross-account peering requires acceptance from both accounts

```
VPC A (10.0.0.0/16) ←→ VPC B (10.1.0.0/16)

Route in A: 10.1.0.0/16 → pcx-0abc123
Route in B: 10.0.0.0/16 → pcx-0abc123
```

---

## Transit Gateway

For connecting many VPCs and on-premises networks, VPC peering becomes unmanageable (O(n²) peering connections). Transit Gateway is a regional hub that centralises routing:

```
VPC A ─┐
VPC B ─┤── Transit Gateway ──── On-premises (VPN / Direct Connect)
VPC C ─┘
```

Transit Gateway supports routing between any attached network, inter-region peering, and route tables for network segmentation.

---

## AWS VPN and Direct Connect

### Site-to-Site VPN

Encrypted tunnel between your on-premises network and a VPC over the public internet. Fast to set up, low cost. Bandwidth limited to ~1.25 Gbps per tunnel.

- **Virtual Private Gateway** — the AWS side of the VPN
- **Customer Gateway** — represents your on-premises device

### AWS Direct Connect

A dedicated private network connection from your data centre to AWS. Not encrypted by default (add a VPN on top for encryption). 

- 1 Gbps, 10 Gbps, or 100 Gbps
- Lower latency, more consistent bandwidth than VPN
- Takes weeks to provision

For the exam: VPN = quick and cheap; Direct Connect = fast, reliable, expensive.

---

## Route 53

Route 53 is AWS's DNS service. It handles:
- Domain registration
- DNS record management
- Health checks and DNS failover

### Record types

| Type | Use | Example |
|------|-----|---------|
| A | IPv4 address | `api.example.com → 1.2.3.4` |
| AAAA | IPv6 address | `api.example.com → 2001:db8::1` |
| CNAME | Canonical name (alias) | `www.example.com → example.com` |
| Alias | AWS-specific extension of A/AAAA | `www.example.com → alb.amazonaws.com` |
| MX | Mail exchange | Mail routing |
| TXT | Text records | Domain verification, SPF |
| NS | Name servers | Delegates a zone |

**Alias records** are Route 53-specific. Unlike CNAME, they can point to the zone apex (`example.com`, not just `sub.example.com`). They are free to query (unlike CNAME which charges per query) and automatically reflect IP changes in the target.

### Routing policies

| Policy | How it works | Use case |
|--------|-------------|---------|
| Simple | Single record, returns one IP | Basic DNS |
| Weighted | Split traffic by weight (e.g., 90/10) | A/B testing, canary deploys |
| Latency | Route to region with lowest latency | Geographically distributed users |
| Failover | Primary/secondary — switches on health check failure | Active-passive DR |
| Geolocation | Route based on user's country/continent | Content localisation, compliance |
| Geoproximity | Route based on distance (with bias) | Fine-grained routing |
| Multi-value answer | Return up to 8 healthy IPs | Client-side load balancing |
| IP-based | Route based on source IP ranges | ISP or corporate network routing |

### Health checks

Route 53 health checks monitor endpoints and trigger DNS failover:

```bash
aws route53 create-health-check \
  --caller-reference "my-check-$(date +%s)" \
  --health-check-config '{
    "IPAddress": "1.2.3.4",
    "Port": 443,
    "Type": "HTTPS",
    "ResourcePath": "/health",
    "FailureThreshold": 3,
    "RequestInterval": 30
  }'
```

Health checks can also monitor CloudWatch alarms, which lets you fail over based on any metric (CPU, error rate, queue depth).

!!! tip "Exam tip"
    For active-passive failover with Route 53, use the **Failover** routing policy with health checks on the primary. If the primary health check fails, Route 53 automatically returns the secondary record. This does not require any code changes — it is pure DNS.

!!! tip "Exam tip"
    A NACL blocks traffic to an entire subnet. A security group blocks traffic to a specific instance. If a scenario says "block a specific IP from reaching any instance in the subnet," use a **NACL Deny rule**. Security groups cannot deny — they only allow.

!!! tip "Exam tip"
    For VPC cost optimisation: if instances in private subnets need to access **S3 or DynamoDB**, use a **Gateway VPC Endpoint** — it's free and avoids NAT Gateway data transfer fees. This is a common cost-optimisation question.
