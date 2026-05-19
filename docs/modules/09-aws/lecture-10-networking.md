# AWS Networking Full Lecture for DevOps/SRE

AWS networking starts with one main idea: we need to build a secure private network where some resources are public, some are private, traffic flows correctly, and we can troubleshoot when something breaks.

In traditional networking, you used switches, routers, VLANs, firewalls, and DMZ. In AWS, the same ideas exist, but they are software-defined. Instead of physical routers and switches, we use VPC, subnets, route tables, internet gateway, NAT gateway, security groups, network ACLs, VPC endpoints, and VPC peering.

##  1\. VPC 

A VPC, or Virtual Private Cloud, is your private network inside AWS. It is logically isolated from other customers. When you create a VPC, you choose a CIDR block, for example:  

[code] 
    10.0.0.0/16
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This means your AWS network has private IP addresses from the `10.0.x.x` range.

Think of VPC like your company building. Inside that building, you create rooms. Those rooms are subnets.

We use VPC because we need control over:  

[code] 
    IP ranges
    subnets
    routing
    security
    internet access
    private communication
    
[/code]

Enter fullscreen mode Exit fullscreen mode

In interviews, say:

A VPC is a logically isolated network in AWS where we define IP ranges, subnets, routing, and security rules.

AWS route tables control where traffic goes inside the VPC, and each subnet must be associated with a route table. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/subnet-route-tables.html?utm_source=chatgpt.com>))

##  2\. Subnet 

A subnet is a smaller network inside the VPC.

Example:  

[code] 
    VPC: 10.0.0.0/16
    
    Public subnet 1:  10.0.1.0/24
    Public subnet 2:  10.0.2.0/24
    Private subnet 1: 10.0.3.0/24
    Private subnet 2: 10.0.4.0/24
    
[/code]

Enter fullscreen mode Exit fullscreen mode

A subnet belongs to one Availability Zone.

We create multiple subnets because we want separation and high availability.

Public subnet is for resources that need internet access, like:  

[code] 
    Application Load Balancer
    Bastion host
    NAT Gateway
    Public web server for testing
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Private subnet is for resources that should not be directly accessible from the internet, like:  

[code] 
    Application servers
    Databases
    Internal APIs
    Backend services
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This is the AWS version of your Packet Tracer segmentation.

Packet Tracer VLAN = AWS subnet.

##  3\. Public Subnet vs Private Subnet 

A subnet is not automatically public or private because of its name. It becomes public or private based on its route table.

A public subnet has this route:  

[code] 
    0.0.0.0/0 → Internet Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

A private subnet does not route directly to the Internet Gateway. Usually it has:  

[code] 
    0.0.0.0/0 → NAT Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

So the real difference is routing.

Public subnet means resources can communicate with the internet if they also have a public IP.

Private subnet means resources cannot be reached directly from the internet.

##  4\. Route Table 

A route table is like the traffic controller for your VPC. AWS documentation describes it as rules that determine where traffic from your subnet or gateway is directed. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html?utm_source=chatgpt.com>))

Example public route table:  

[code] 
    10.0.0.0/16 → local
    0.0.0.0/0  → Internet Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

The `local` route allows resources inside the VPC to communicate with each other.

The `0.0.0.0/0` route means all unknown traffic, usually internet traffic, goes to the Internet Gateway.

Example private route table:  

[code] 
    10.0.0.0/16 → local
    0.0.0.0/0  → NAT Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This means private servers can talk inside the VPC and can go out to the internet through NAT, but the internet cannot start a connection back to them.

Troubleshooting route tables:

If public EC2 is not accessible, check:  

[code] 
    Does the subnet route table have 0.0.0.0/0 → Internet Gateway?
    Does the EC2 have public IP?
    Does the security group allow traffic?
    Is the instance running?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

If private EC2 cannot reach the internet, check:  

[code] 
    Does private route table have 0.0.0.0/0 → NAT Gateway?
    Is NAT Gateway available?
    Is NAT Gateway in public subnet?
    Does public subnet have route to Internet Gateway?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  5\. Internet Gateway 

An Internet Gateway allows communication between your VPC and the internet.

But just attaching an Internet Gateway is not enough. You must also update the public route table:  

[code] 
    0.0.0.0/0 → Internet Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

AWS documentation says public subnet route tables can use Internet Gateway as the target for traffic going to destinations not explicitly known, such as `0.0.0.0/0`. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html?utm_source=chatgpt.com>))

We use Internet Gateway when we want public resources, such as:  

[code] 
    Load balancer
    Public web server
    Bastion host
    NAT Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Correct design:  

[code] 
    Internet
       ↓
    Internet Gateway
       ↓
    Public Route Table
       ↓
    Public Subnet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Common issue:

People create an Internet Gateway but forget to associate the public subnet with the public route table. Then EC2 will not be reachable.

##  6\. NAT Gateway 

NAT Gateway is used for private subnet resources that need outbound internet access but should not be reachable from the internet.

Example:

Your private EC2 needs to run:  

[code] 
    sudo apt update
    sudo apt install nginx
    docker pull image
    
[/code]

Enter fullscreen mode Exit fullscreen mode

It needs internet access. But you do not want the internet to SSH into it.

That is why we use NAT Gateway.

AWS describes NAT Gateway as a NAT service that lets instances in private subnets connect to services outside the VPC while external services cannot initiate connections to those private instances. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html?utm_source=chatgpt.com>))

Correct NAT design:  

[code] 
    Private EC2
       ↓
    Private Route Table
       ↓
    NAT Gateway in Public Subnet
       ↓
    Internet Gateway
       ↓
    Internet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Important rule:

NAT Gateway must be in a public subnet.

Why?

Because NAT Gateway itself needs internet access through Internet Gateway.

Private route table should have:  

[code] 
    0.0.0.0/0 → NAT Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Public route table should have:  

[code] 
    0.0.0.0/0 → Internet Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

NAT Gateway is zonal. For production, best practice is one NAT Gateway per Availability Zone. If you have private subnet in AZ-a and private subnet in AZ-b, each private subnet should use NAT in the same AZ for reliability and to avoid cross-AZ dependency.

Troubleshooting NAT:

If private EC2 cannot access internet, check:  

[code] 
    Is NAT Gateway available?
    Is NAT Gateway in public subnet?
    Does NAT Gateway have Elastic IP?
    Does public subnet route to Internet Gateway?
    Does private subnet route to NAT Gateway?
    Does security group allow outbound traffic?
    Does NACL allow inbound/outbound ephemeral ports?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  7\. Elastic IP 

Elastic IP is a static public IPv4 address in AWS.

We use Elastic IP when we need a fixed public IP that does not change.

NAT Gateway requires Elastic IP because private instances going out to the internet need a stable public source IP.

Example:  

[code] 
    Private EC2 → NAT Gateway → Internet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

From the internet side, traffic appears to come from the NAT Gateway Elastic IP.

Use Elastic IP for:  

[code] 
    NAT Gateway
    Bastion host
    Static public server
    Allowlisting with external vendors
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Do not overuse Elastic IP. In production, most public application traffic should go through a Load Balancer, not directly to EC2.

##  8\. Firewall 

A firewall controls traffic based on rules.

In AWS, firewall behavior mainly comes from:  

[code] 
    Security Groups
    Network ACLs
    AWS Network Firewall
    
[/code]

Enter fullscreen mode Exit fullscreen mode

For most normal EC2-level access, you use security groups.

A firewall answers:  

[code] 
    Who can connect?
    From where?
    To which port?
    Using which protocol?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Example:

Web server security group:  

[code] 
    Inbound:
    HTTP 80 from 0.0.0.0/0
    HTTPS 443 from 0.0.0.0/0
    SSH 22 from my IP only
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Database security group:  

[code] 
    Inbound:
    PostgreSQL 5432 only from app server security group
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This is production thinking. Users should never directly access the database.

##  9\. Security Group 

Security Group is an instance-level firewall. It is attached to EC2, RDS, Load Balancer, and other resources.

Security Groups are stateful.

Stateful means if inbound traffic is allowed, return traffic is automatically allowed.

Example:

If user connects to web server on port 80, the response is automatically allowed back.

AWS explains that security groups control inbound and outbound traffic at the instance level. ([AWS Documentation](<https://docs.aws.amazon.com/whitepapers/latest/aws-best-practices-ddos-resiliency/security-groups-and-network-acls-bp5.html?utm_source=chatgpt.com>))

Good security group design:

Load Balancer SG:  

[code] 
    Inbound:
    80/443 from internet
    
    Outbound:
    To web/app servers
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Web/App Server SG:  

[code] 
    Inbound:
    App port only from Load Balancer SG
    SSH only from bastion or SSM
    
    Outbound:
    To database or internet through NAT
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Database SG:  

[code] 
    Inbound:
    DB port only from App Server SG
    
    Outbound:
    Default or restricted depending on company policy
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Very important SRE idea:

Use security group references instead of IP addresses when possible.

Example:

Instead of:  

[code] 
    Allow 10.0.3.10 on port 5432
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Use:  

[code] 
    Allow app-server-sg on port 5432
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This is better because EC2 IPs can change.

##  10\. Network ACL 

Network ACL, or NACL, is subnet-level firewall.

Security Group protects the instance.  
NACL protects the subnet.

AWS says Network ACLs control traffic in and out of one or more subnets and can be used as an additional layer of security. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html?utm_source=chatgpt.com>))

NACL is stateless.

Stateless means you must allow both inbound and outbound traffic separately.

Example:

If inbound HTTP is allowed but outbound response traffic is denied, connection fails.

NACL rules have numbers:  

[code] 
    100 allow HTTP
    110 allow HTTPS
    120 deny specific IP
    * deny all
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Lower number is evaluated first.

When to use NACL:

Use NACL for broad subnet-level guardrails, for example:  

[code] 
    Block known malicious IP
    Block traffic between subnet groups
    Add extra compliance layer
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Do not use NACL for every small application rule. Use Security Groups for that.

AWS also recommends security groups as the primary network control and NACLs as optional stateless subnet-level guardrails. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html?utm_source=chatgpt.com>))

##  11\. Security Group vs NACL 

Security Group:  

[code] 
    Instance level
    Stateful
    Only allow rules
    Commonly used
    Can reference another security group
    
[/code]

Enter fullscreen mode Exit fullscreen mode

NACL:  

[code] 
    Subnet level
    Stateless
    Allow and deny rules
    Rule number order matters
    Used for broad subnet control
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Interview answer:

Security Groups are stateful firewalls attached to resources, while NACLs are stateless firewalls applied at the subnet level.

##  12\. DMZ 

DMZ means demilitarized zone.

In networking, DMZ is the public-facing zone that sits between the internet and the private internal network.

In AWS, a DMZ is usually your public subnet.

DMZ contains:  

[code] 
    Application Load Balancer
    Bastion host
    NAT Gateway
    Sometimes public web servers
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Private resources like databases should not be in DMZ.

Correct design:  

[code] 
    Internet
       ↓
    Public Subnet / DMZ
       ↓
    Private App Subnet
       ↓
    Private DB Subnet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Why we use DMZ:

Because public-facing components need controlled exposure, but internal systems must stay private.

Example:

User can reach:  

[code] 
    User → ALB
    
[/code]

Enter fullscreen mode Exit fullscreen mode

ALB can reach:  

[code] 
    ALB → App Server
    
[/code]

Enter fullscreen mode Exit fullscreen mode

App server can reach:  

[code] 
    App Server → Database
    
[/code]

Enter fullscreen mode Exit fullscreen mode

User cannot reach:  

[code] 
    User → Database
    
[/code]

Enter fullscreen mode Exit fullscreen mode

That is production security.

##  13\. Proxy 

A proxy is an intermediate server that forwards traffic.

There are two common types:

Forward proxy:  

[code] 
    User → Proxy → Internet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Used when internal users access the internet through a controlled server.

Reverse proxy:  

[code] 
    User → Reverse Proxy → Backend Servers
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Used when external users access internal applications through a front layer.

In real DevOps/SRE, common reverse proxies are:  

[code] 
    Nginx
    HAProxy
    Application Load Balancer
    API Gateway
    Ingress Controller in Kubernetes
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Why use proxy:  

[code] 
    Hide backend servers
    Terminate SSL/TLS
    Route traffic
    Apply access control
    Load balance
    Log requests
    Protect backend
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Example:

User does not directly access app server.

Instead:  

[code] 
    User → ALB/Nginx → App Server
    
[/code]

Enter fullscreen mode Exit fullscreen mode

That is reverse proxy behavior.

Firewall vs Proxy:

Firewall decides allow or deny.

Proxy receives and forwards application traffic.

##  14\. VPC Endpoint 

You said “endpoint servers.” In AWS, the important concept is VPC Endpoint.

A VPC Endpoint allows private resources to access AWS services without going through the public internet.

Example:

Private EC2 needs to access S3.

Without endpoint:  

[code] 
    Private EC2 → NAT Gateway → Internet path → S3
    
[/code]

Enter fullscreen mode Exit fullscreen mode

With VPC endpoint:  

[code] 
    Private EC2 → VPC Endpoint → S3
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This is more secure and can reduce NAT traffic cost.

Types:

Gateway Endpoint:  

[code] 
    S3
    DynamoDB
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Interface Endpoint:  

[code] 
    SSM
    CloudWatch
    ECR
    Secrets Manager
    STS
    many AWS services
    
[/code]

Enter fullscreen mode Exit fullscreen mode

When to use VPC endpoints:  

[code] 
    Private subnet needs AWS service access
    You want to avoid internet path
    You want better security
    You want to reduce NAT dependency
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Example SRE use case:

Private EC2 has no public IP. You want to connect using SSM Session Manager. Then you may need interface endpoints for:  

[code] 
    ssm
    ssmmessages
    ec2messages
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  15\. VPC Peering 

VPC Peering connects two VPCs privately.

Example:  

[code] 
    VPC A: 10.0.0.0/16
    VPC B: 10.1.0.0/16
    
[/code]

Enter fullscreen mode Exit fullscreen mode

After peering, instances in VPC A can communicate with instances in VPC B using private IPs.

Use VPC peering when:  

[code] 
    Two applications are in different VPCs
    Shared services VPC needs to talk to app VPC
    Company has dev/prod/shared networks
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Important rules:

CIDR blocks cannot overlap.

If VPC A and VPC B both use:  

[code] 
    10.0.0.0/16
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Peering will not work.

Also, VPC peering is not transitive.

If:  

[code] 
    VPC A peers with VPC B
    VPC B peers with VPC C
    
[/code]

Enter fullscreen mode Exit fullscreen mode

That does not mean A can talk to C automatically.

For many VPCs, companies often use Transit Gateway instead of many peering connections.

##  16\. Routing Servers 

In AWS, you usually do not manage a routing server like in traditional networking. AWS provides an implicit router inside the VPC. You control routing using route tables.

AWS documentation says a VPC has an implicit router, and route tables control where traffic is directed. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/subnet-route-tables.html?utm_source=chatgpt.com>))

However, sometimes companies deploy routing or network appliances, such as:  

[code] 
    firewall appliance
    proxy appliance
    NAT instance
    VPN router
    inspection appliance
    
[/code]

Enter fullscreen mode Exit fullscreen mode

But for normal DevOps/SRE learning, focus first on:  

[code] 
    Route tables
    Internet Gateway
    NAT Gateway
    Transit Gateway
    VPC Peering
    VPC Endpoints
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  17\. How to Build Correct AWS Network Architecture 

For your lab, build this:  

[code] 
    VPC: 10.0.0.0/16
    
    Public Subnet 1: 10.0.1.0/24
    Public Subnet 2: 10.0.2.0/24
    
    Private App Subnet 1: 10.0.3.0/24
    Private App Subnet 2: 10.0.4.0/24
    
    Private DB Subnet 1: 10.0.5.0/24
    Private DB Subnet 2: 10.0.6.0/24
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Public route table:  

[code] 
    10.0.0.0/16 → local
    0.0.0.0/0  → Internet Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Private route table:  

[code] 
    10.0.0.0/16 → local
    0.0.0.0/0  → NAT Gateway
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Database subnet route table:  

[code] 
    10.0.0.0/16 → local
    
[/code]

Enter fullscreen mode Exit fullscreen mode

For stricter security, database subnet does not need internet access.

Architecture:  

[code] 
    Internet
       ↓
    Internet Gateway
       ↓
    Application Load Balancer in Public Subnets
       ↓
    App EC2 in Private Subnets
       ↓
    RDS Database in Private DB Subnets
    
[/code]

Enter fullscreen mode Exit fullscreen mode

This is real production design.

AWS also recommends using multiple Availability Zones for production applications because it improves high availability, fault tolerance, and scalability. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html?utm_source=chatgpt.com>))

##  18\. How to Create It in Console 

First create VPC:  

[code] 
    VPC → Create VPC
    Name: prod-vpc
    CIDR: 10.0.0.0/16
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create subnets:  

[code] 
    public-subnet-1   10.0.1.0/24  AZ-a
    public-subnet-2   10.0.2.0/24  AZ-b
    private-subnet-1  10.0.3.0/24  AZ-a
    private-subnet-2  10.0.4.0/24  AZ-b
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create Internet Gateway:  

[code] 
    VPC → Internet Gateways → Create
    Attach to prod-vpc
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create public route table:  

[code] 
    Route Tables → Create
    Name: public-rt
    Route: 0.0.0.0/0 → Internet Gateway
    Associate public subnets
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create NAT Gateway:  

[code] 
    VPC → NAT Gateways → Create
    Subnet: public-subnet-1
    Elastic IP: allocate
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create private route table:  

[code] 
    Route Tables → Create
    Name: private-rt
    Route: 0.0.0.0/0 → NAT Gateway
    Associate private subnets
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create EC2 in public subnet:  

[code] 
    Auto public IP: enabled
    Security Group: allow SSH from your IP, HTTP from internet
    
[/code]

Enter fullscreen mode Exit fullscreen mode

Create EC2 in private subnet:  

[code] 
    No public IP
    Security Group: allow SSH only from public/bastion SG or use SSM
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  19\. Correct Troubleshooting Method 

When something does not work, do not guess. Follow layers.

###  Problem: Public EC2 not reachable 

Check:  

[code] 
    1. Is EC2 running?
    2. Does EC2 have public IP?
    3. Is subnet associated with public route table?
    4. Does public route table have 0.0.0.0/0 → IGW?
    5. Is IGW attached to VPC?
    6. Does security group allow inbound port?
    7. Does NACL allow traffic?
    8. Is OS firewall blocking traffic?
    9. Is application running?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

###  Problem: Private EC2 cannot reach internet 

Check:  

[code] 
    1. Is private subnet associated with private route table?
    2. Does route table have 0.0.0.0/0 → NAT Gateway?
    3. Is NAT Gateway available?
    4. Is NAT Gateway in public subnet?
    5. Does NAT Gateway have Elastic IP?
    6. Does public subnet route to IGW?
    7. Does security group allow outbound?
    8. Does NACL allow outbound and return traffic?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

###  Problem: App cannot connect to database 

Check:  

[code] 
    1. Is DB running?
    2. Is DB in private subnet?
    3. Does DB security group allow app SG?
    4. Is correct DB port open?
    5. Are app and DB in same VPC or connected VPCs?
    6. Is route table allowing local VPC traffic?
    7. Is DNS name correct?
    8. Are credentials correct?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

###  Problem: VPC Peering not working 

Check:  

[code] 
    1. Are CIDRs non-overlapping?
    2. Is peering connection accepted?
    3. Does VPC A route table point to peering connection?
    4. Does VPC B route table point back?
    5. Do security groups allow traffic?
    6. Do NACLs allow traffic?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

##  20\. SRE Mindset 

An SRE does not only create VPC. An SRE proves that the network is reliable.

That means you must test:  

[code] 
    Can public users reach only what they should reach?
    Can private servers reach internet through NAT?
    Can database stay private?
    Can one AZ fail and application still work?
    Can logs show denied traffic?
    Can we troubleshoot quickly?
    
[/code]

Enter fullscreen mode Exit fullscreen mode

For observability, enable:  

[code] 
    VPC Flow Logs
    CloudWatch metrics
    ALB access logs
    Security group review
    NACL review
    
[/code]

Enter fullscreen mode Exit fullscreen mode

AWS VPC Flow Logs capture information about IP traffic going to and from network interfaces and can help diagnose security group and NACL problems. ([AWS Documentation](<https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html?utm_source=chatgpt.com>))

##  Final Interview Summary 

You can say:

I design AWS networks using VPCs, public and private subnets, route tables, Internet Gateway, NAT Gateway, security groups, and NACLs. Public subnets are used for internet-facing components like load balancers, while private subnets host application and database resources. NAT Gateway allows private resources to access the internet without being exposed. Security Groups protect resources at the instance level, and NACLs provide subnet-level control. For private AWS service access, I use VPC endpoints, and for private communication between VPCs, I use VPC peering or Transit Gateway depending on scale.
