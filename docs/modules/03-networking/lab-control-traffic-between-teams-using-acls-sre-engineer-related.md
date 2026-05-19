---
title: "Lab: Control traffic between teams using ACLs, sre engineer related"
description: "First: what does an SRE do in a job?   SRE means Site Reliability Engineer.  An SRE helps..."
published: 2026-04-20
source: "https://dev.to/jumptotech/lab-control-traffic-between-teams-using-acls-sre-engineer-related-k94"
tags: []
---

# Lab: Control traffic between teams using ACLs, sre engineer related




# First: what does an SRE do in a job?

SRE means **Site Reliability Engineer**.

An SRE helps make systems:

* available
* reliable
* scalable
* observable
* recoverable

A developer may build the application.
An SRE makes sure the application:

* stays up
* is reachable
* responds fast enough
* recovers when something breaks
* can be monitored and debugged

---

# Main responsibilities of an SRE

## 1. Reliability

Make sure systems stay available.

Examples:

* application should not go down
* server should recover after failure
* traffic should reach the service
* database should stay reachable

## 2. Monitoring and alerting

SREs must know when something is broken before customers complain.

Examples:

* CPU too high
* memory too high
* disk almost full
* app returning 500 errors
* network timeout
* packet drops
* service unavailable

## 3. Incident response

When something breaks, SRE investigates and restores service.

Examples:

* website down
* internal API unreachable
* database connection failing
* Kubernetes pods crashing
* DNS issue
* TLS certificate expired
* bad deployment caused outage

## 4. Access control and safety

Not every team should access every system.

Examples:

* HR cannot access production database
* frontend can access backend but not database directly
* internal tools available only from office VPN
* only specific services allowed across environments

## 5. Automation

SREs reduce manual work.

Examples:

* automated restart
* automated deployment rollback
* infrastructure as code
* scripts for health checks
* dashboards
* auto-scaling

## 6. Capacity and performance

SRE checks whether systems can handle growth.

Examples:

* too many users
* database too slow
* API latency increasing
* server CPU saturation
* network congestion

## 7. Postmortems and prevention

After outage, SRE explains:

* what happened
* why it happened
* how it was fixed
* how to prevent it next time

---

# What does SRE do in daily work?

A real SRE day can include:

* checking alerts and dashboards
* responding to failed jobs
* troubleshooting connectivity
* reviewing logs
* validating deployments
* adjusting monitoring thresholds
* improving reliability scripts
* working with developers on production issues
* doing root cause analysis
* writing runbooks
* helping with incident calls

---

# How many SRE engineers are in companies?

There is no single fixed number, but this is a good realistic picture.

## Small company

Usually:

* 1 to 3 SREs
* sometimes no dedicated SRE at all
* sometimes DevOps and SRE responsibilities are mixed

In small companies, one engineer may do:

* cloud
* CI/CD
* monitoring
* incidents
* infrastructure
* access control

## Middle company

Usually:

* 3 to 10 SREs
* more specialization starts here

Possible split:

* incident/on-call engineer
* platform reliability engineer
* observability engineer
* infrastructure engineer

## Large company

Usually:

* 10, 20, 50+, sometimes hundreds across orgs
* many teams by domain

Examples:

* SRE for payments
* SRE for networking
* SRE for Kubernetes platform
* SRE for databases
* SRE for observability
* SRE for edge/CDN
* SRE for internal tools

---

# What does an SRE team usually look like?

A team may include:

## SRE manager or lead

Coordinates priorities, outages, standards

## Junior or mid SRE

Handles monitoring, simple fixes, runbooks, routine incidents

## Senior SRE

Handles architecture, deep outages, reliability strategy, mentoring

## Platform / infrastructure engineers

Build shared systems:

* Kubernetes
* load balancers
* CI/CD
* logging
* cloud networking

## Observability engineer

Focuses on:

* metrics
* logs
* traces
* dashboards
* alert quality

## Security or network partner

In some companies, SRE works closely with:

* network team
* security team
* cloud team
* application team

---

# Example SRE team in a medium company

Example:

* 1 SRE lead
* 2 mid-level SREs
* 1 observability engineer
* 1 platform engineer

They support:

* production apps
* Kubernetes cluster
* monitoring tools
* incident response
* networking and routing
* service health

---

# Example of real SRE work from your current lab

Your current VLAN lab already relates to SRE like this:

## What you did technically

* separated teams into VLANs
* configured routing
* tested connectivity
* troubleshot failures

## What that means in SRE language

* segmented traffic
* controlled communication paths
* validated service reachability
* performed incident investigation

This is exactly the kind of thinking SRE needs.

---

# Why the next lab should be ACL

Because after routing comes **control**.

In real companies, SRE often asks:

* should this service be reachable?
* who should access this environment?
* why is this app exposed too widely?
* how do we reduce risk?
* how do we isolate failure domains?

ACL lab teaches:

* reliability through control
* security through segmentation
* troubleshooting blocked vs allowed traffic
* expected vs unexpected connectivity

That is much closer to real SRE work.

---

# Next logical lab

# Lab: Control traffic between teams using ACLs

## Goal

You will extend your current network and simulate a real company rule:

* HR in VLAN 10 can talk to its own gateway
* IT in VLAN 20 can talk to everyone
* DevOps in VLAN 30 can access all
* HR must NOT access DevOps
* HR may or may not access IT depending on policy
* You will test, break, verify, and troubleshoot

This shows:

* routing
* policy enforcement
* outage investigation
* controlled access
* SRE style troubleshooting

---

# Real company scenario

Imagine this company:

## VLAN 10 = HR

Sensitive employee systems

## VLAN 20 = IT

Support tools, ticketing, admin services

## VLAN 30 = DevOps

Production tools, deployment systems, admin servers

A real company might say:

* HR should not access DevOps admin systems
* IT should be able to troubleshoot all networks
* DevOps needs broad access for maintenance
* some traffic should be blocked for safety

That is a real SRE concern.

---

# Lab topology

Use your same topology:

* Switch
* Router
* PCs in VLAN 10, 20, 30
* trunk from switch to router
* router-on-a-stick already configured

Now add policy using ACL.

---

# Lab objective

You will configure and verify:

1. Same VLAN communication works
2. Inter-VLAN routing works
3. ACL blocks HR from reaching DevOps
4. ACL still allows HR to reach its own gateway
5. ACL allows IT and DevOps as intended
6. You troubleshoot from ping results

---

# Step-by-step lab

## Step 1. Confirm current working state

Before ACL, test:

From VLAN 10 PC:

```bash
ping 192.168.10.1
ping 192.168.20.20
ping 192.168.30.30
```

From VLAN 20 PC:

```bash
ping 192.168.10.10
ping 192.168.30.30
```

From VLAN 30 PC:

```bash
ping 192.168.10.10
ping 192.168.20.20
```

This proves routing works before policy is applied.

---

## Step 2. Create the company policy

Policy:

* VLAN 10 cannot access VLAN 30
* VLAN 10 can still access VLAN 20
* VLAN 20 and VLAN 30 have normal routing

---

## Step 3. Configure ACL on router

Example:

* VLAN 10 = 192.168.10.0/24
* VLAN 30 = 192.168.30.0/24

On router:

```bash
enable
conf t
access-list 101 deny ip 192.168.10.0 0.0.0.255 192.168.30.0 0.0.0.255
access-list 101 permit ip any any
```

Now apply it to VLAN 10 subinterface inbound:

```bash
interface g0/0.10
ip access-group 101 in
end
```

---

# What this does

## `deny ip 192.168.10.0 ... 192.168.30.0 ...`

Blocks traffic from HR to DevOps

## `permit ip any any`

Allows everything else

## `ip access-group 101 in`

Applies the ACL to traffic entering from VLAN 10

This is important:

* users in VLAN 10 are checked as they enter router
* blocked traffic never gets routed onward

---

# Step 4. Test after ACL

From VLAN 10 PC:

```bash
ping 192.168.10.1
ping 192.168.20.20
ping 192.168.30.30
```

Expected:

* gateway ping works
* VLAN 20 ping works
* VLAN 30 ping fails

From VLAN 20 PC:

```bash
ping 192.168.10.10
ping 192.168.30.30
```

Expected:

* both should work

From VLAN 30 PC:

```bash
ping 192.168.10.10
```

Depending on your policy, this may still work unless you block return path too. That becomes a great discussion point.

---

# Step 5. Verify ACL

Run:

```bash
show access-lists
```

You should see hit counters increasing.

This is very important in real SRE work.

Why?
Because SREs do not only configure. They verify whether policy is actually matching traffic.

---

# Step 6. Troubleshoot as an SRE

If ping fails, ask:

## Question 1

Is this expected failure or outage?

Example:

* HR to DevOps fails after ACL
* this is expected
* not an outage

## Question 2

Can host reach its own gateway?

If yes:

* local VLAN and switch path are okay

## Question 3

Can other VLANs still communicate?

If yes:

* routing is okay
* policy is targeted

## Question 4

Does ACL show hits?

If yes:

* block is working as designed

This is exactly how SRE thinks:
not just “it failed”
but “did it fail correctly?”

---

# What this lab teaches about SRE

## 1. Controlled reliability

Not all traffic should work.
Correctly blocked traffic is part of reliability and safety.

## 2. Blast radius reduction

If HR cannot reach DevOps, one mistake in HR network cannot directly hit DevOps systems.

## 3. Policy verification

SRE validates:

* which flows should succeed
* which flows should fail

## 4. Troubleshooting by layers

* can reach gateway?
* can reach same VLAN?
* can reach other VLAN?
* does ACL block it?

---

# How this looks in a real company

Imagine:

* HR app subnet
* internal admin subnet
* CI/CD or production subnet

SRE may configure or validate:

* only approved access paths
* deployment systems only accessible from admin VLAN
* internal tools restricted to certain teams
* production APIs reachable only from trusted networks

This is not theory. This is real operational work.

---

# What SRE would document from this lab

A good SRE writes a simple runbook:

## Runbook example

**Issue:** HR users cannot access DevOps subnet
**Expected behavior:** blocked by ACL
**Validation:**

* verify gateway reachable
* verify ACL applied to g0/0.10
* verify hit counters
* verify IT subnet still reachable
  **Fix if accidental:** remove or adjust ACL

That is real SRE work.

---

# Small, medium, large company example with this lab

## Small company

One engineer may:

* configure VLANs
* build ACLs
* check pings
* investigate outage
* document results

## Medium company

Work may be split:

* network engineer configures switch/router
* SRE validates reachability and monitoring
* security reviews access rules

## Large company

More specialized:

* platform/network team manages routing
* security defines access policy
* SRE validates application availability and service dependencies

But SRE still must understand all of it.


