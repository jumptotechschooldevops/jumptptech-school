# Module 03 · Networking

You cannot debug a service mesh, configure an ingress controller, or understand why your container cannot reach another service without understanding the networking underneath. This module covers the concepts and tools that come up every day in DevOps work.

## What you will cover

**Lecture 1 — TCP/IP & DNS Fundamentals**
The OSI and TCP/IP models, IP addressing, subnets, TCP handshake, DNS resolution, HTTP basics.

**Lecture 2 — Network Tools & Troubleshooting**
`curl`, `dig`, `nmap`, `ss`, `tcpdump`, `iptables`, `traceroute` — the toolbox you reach for when something is not connecting.

**Lab 1 — Diagnostics & Inspection**
Hands-on with the full troubleshooting toolset: trace a request from DNS lookup to TCP connection to HTTP response.

## Time estimate

| Activity | Time |
|----------|------|
| Lecture 1 | 50 min |
| Lecture 2 | 50 min |
| Lab 1 | 75 min |

## Why this matters for DevOps

Every production incident involving connectivity comes down to one of these:

- DNS is returning the wrong IP (or not resolving at all)
- A firewall rule is blocking the connection
- The service is not listening on the expected port
- The connection is being established but requests are timing out (slow network, overloaded backend)
- TLS certificate mismatch or expiry

Each of these has a diagnostic tool and a fix. This module teaches you to reach for the right tool first.
