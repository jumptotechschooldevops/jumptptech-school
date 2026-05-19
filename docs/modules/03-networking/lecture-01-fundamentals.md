# Lecture 1 · TCP/IP & DNS Fundamentals

## The networking model

The OSI model has seven layers. You will hear people reference it constantly. In practice, what matters for DevOps is the TCP/IP model, which collapses the seven layers into four:

| Layer | TCP/IP name | Protocols | What it does |
|-------|-------------|-----------|-------------|
| 1-2 | Network Access | Ethernet, Wi-Fi | Moves bits across a physical medium |
| 3 | Internet | IP, ICMP | Routes packets between networks |
| 4 | Transport | TCP, UDP | Provides end-to-end communication |
| 5-7 | Application | HTTP, DNS, SSH, TLS | Application-specific protocols |

When you make an HTTP request, all four layers are involved. Understanding where a problem lives tells you which tools to use.

---

## IP addressing

Every device on a network has an IP address. IPv4 addresses are 32 bits written as four decimal octets: `192.168.1.100`.

### Subnets and CIDR notation

A subnet is a range of IP addresses. CIDR notation combines the network address with the prefix length:

```
192.168.1.0/24
           ^^
           24 bits for the network, 8 bits for hosts
           Hosts: 192.168.1.1 - 192.168.1.254
           Broadcast: 192.168.1.255
           Usable hosts: 254
```

Common CIDR blocks:

| CIDR | Hosts | Use case |
|------|-------|----------|
| /8 | 16,777,214 | Large networks (10.0.0.0/8) |
| /16 | 65,534 | VPC ranges |
| /24 | 254 | Typical LAN subnet |
| /28 | 14 | Small subnet (e.g. database tier) |
| /32 | 1 | Single host (in firewall rules) |

### Private address ranges (RFC 1918)

These ranges are not routable on the public internet:

```
10.0.0.0/8         (10.x.x.x)
172.16.0.0/12      (172.16.x.x - 172.31.x.x)
192.168.0.0/16     (192.168.x.x)
```

Docker uses `172.17.0.0/16` by default. Kubernetes pods typically get addresses from `10.x.x.x` ranges. Your home network is probably on `192.168.x.x`.

### Loopback

`127.0.0.1` (and the entire `127.0.0.0/8` range) always refers to localhost — the current machine. `::1` is the IPv6 equivalent.

---

## TCP — how connections work

TCP is connection-oriented. Before any data is exchanged, a connection is established with a **three-way handshake**:

```
Client                          Server
  |                               |
  |  ─── SYN ─────────────────→  |  "I want to connect"
  |  ←── SYN-ACK ─────────────  |  "OK, acknowledged"
  |  ─── ACK ─────────────────→  |  "Acknowledged"
  |                               |
  |  ←──── data flowing ───────→  |
  |                               |
```

Each step has a sequence number that ensures packets arrive in order and none are lost.

**TCP connection states** (what you see in `ss` and `netstat`):

| State | Meaning |
|-------|---------|
| LISTEN | Server waiting for incoming connections |
| SYN_SENT | Client sent SYN, waiting for SYN-ACK |
| ESTABLISHED | Connection active |
| TIME_WAIT | Connection closed, waiting before freeing port |
| CLOSE_WAIT | Remote end closed, local still has data |

Many `TIME_WAIT` connections are normal under load — each closed connection spends ~60 seconds here. A large number of `CLOSE_WAIT` connections usually indicates a bug in the application (not properly closing connections).

### Ports

A port number (0–65535) identifies a specific service on a machine. The combination of IP + port is called a **socket**.

Well-known ports:

| Port | Service |
|------|---------|
| 22 | SSH |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 8080 | HTTP alternative |
| 27017 | MongoDB |

Ports below 1024 are **privileged ports** — only root can listen on them. This is why web servers either run as root (risky), use a proxy like nginx, or use `CAP_NET_BIND_SERVICE`.

### UDP

UDP is connectionless — packets are sent without establishing a connection. No handshake, no guarantee of delivery or ordering. Faster but unreliable. Used for DNS, DHCP, video streaming, and anything where latency matters more than reliability.

---

## DNS — Domain Name System

DNS translates human-readable names (`api.example.com`) to IP addresses. Without DNS, you would type IP addresses for every website.

### How resolution works

```
Browser asks: what is the IP for api.example.com?

1. Check local cache → not there
2. Check /etc/hosts → not there
3. Ask the recursive resolver (your ISP or 8.8.8.8)
   3a. Resolver asks a root nameserver: who handles .com?
   3b. Root says: ask the .com TLD nameserver
   3c. Resolver asks TLD: who handles example.com?
   3d. TLD says: ask ns1.example.com
   3e. Resolver asks ns1.example.com: what is api.example.com?
   3f. ns1.example.com says: 93.184.216.34  (TTL: 300s)
4. Resolver returns 93.184.216.34 and caches it for 300s
```

This whole process typically takes 10–200ms the first time, and is instant from cache on subsequent lookups.

### DNS record types

| Type | Purpose | Example |
|------|---------|---------|
| A | IPv4 address | `api.example.com → 93.184.216.34` |
| AAAA | IPv6 address | `api.example.com → 2606:2800::1` |
| CNAME | Alias (canonical name) | `www → example.com` |
| MX | Mail server | `example.com → mail.example.com` (priority 10) |
| TXT | Arbitrary text | SPF records, domain verification |
| NS | Nameserver for a zone | `example.com → ns1.example.com` |
| PTR | Reverse DNS (IP → name) | `34.216.184.93.in-addr.arpa → api.example.com` |
| SRV | Service location | `_http._tcp.example.com → host:port` |

### TTL

Every DNS record has a TTL (time to live) in seconds. This tells resolvers how long to cache the record. A TTL of 300 means the record is cached for 5 minutes before being re-queried.

**Before changing a DNS record**, lower the TTL to 60 seconds a few hours in advance. This minimises propagation delays when you make the change.

### /etc/hosts

The hosts file is checked before DNS. It maps hostnames to IPs directly:

```
127.0.0.1   localhost
::1         localhost

# Custom entries
192.168.1.50  dev.myapp.internal
```

This is how Docker and Kubernetes add entries for service discovery within containers.

---

## HTTP and HTTPS

HTTP is an application-layer protocol for transferring data. Every request has:

```
GET /api/users HTTP/1.1
Host: api.example.com
Accept: application/json
Authorization: Bearer eyJ...
```

And every response has:

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 142

{"users": [...]}
```

### HTTP methods

| Method | Purpose | Idempotent? |
|--------|---------|------------|
| GET | Retrieve data | Yes |
| POST | Create or submit | No |
| PUT | Replace entirely | Yes |
| PATCH | Partial update | No |
| DELETE | Remove | Yes |
| HEAD | GET without body | Yes |

### HTTP status codes

| Range | Meaning |
|-------|---------|
| 2xx | Success (200 OK, 201 Created, 204 No Content) |
| 3xx | Redirect (301 Permanent, 302 Temporary, 304 Not Modified) |
| 4xx | Client error (400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 429 Rate Limited) |
| 5xx | Server error (500 Internal, 502 Bad Gateway, 503 Unavailable, 504 Gateway Timeout) |

`502 Bad Gateway` usually means your load balancer reached your app but the app is crashing or not listening. `504 Gateway Timeout` means the app started to respond but took too long.

### HTTPS and TLS

HTTPS is HTTP over TLS. TLS provides:

1. **Encryption** — data in transit is unreadable to observers
2. **Authentication** — the server proves its identity with a certificate
3. **Integrity** — data cannot be tampered with undetected

The TLS handshake adds ~1 round trip of latency (reduced to ~0.5 with TLS 1.3). After the handshake, the connection is encrypted and fast.

Certificates are issued by Certificate Authorities (CAs). Let's Encrypt issues free, automatically-renewing certificates trusted by all major browsers.

---

## Summary

- IP addresses and CIDR notation: `/24` gives 254 hosts. Private ranges (10.x, 172.16-31.x, 192.168.x) are not internet-routable.
- TCP uses a three-way handshake. Ports identify services. Ports below 1024 require root.
- DNS translates names to IPs through a hierarchical system. TTL controls caching.
- HTTP methods and status codes: know what 502 and 504 mean.
- HTTPS = HTTP + TLS. TLS provides encryption, authentication, and integrity.
