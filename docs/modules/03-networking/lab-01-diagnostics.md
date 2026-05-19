# Lab 1 · Diagnostics & Inspection

**Duration:** ~75 minutes  
**Goal:** Trace a complete network request from DNS lookup to HTTP response using the tools from both lectures.

---

## Setup

```bash
sudo apt update && sudo apt install -y curl dig netcat-openbsd tcpdump mtr nmap
```

Create a working directory:

```bash
mkdir -p ~/networking-lab
cd ~/networking-lab
```

---

## Part 1 — DNS investigation

### 1.1 Basic lookups

Investigate `github.com` using multiple methods:

```bash
# A record
dig +short github.com

# Full output — note the TTL
dig github.com A

# What nameservers serve github.com?
dig NS github.com +short

# Query the authoritative nameserver directly
ns=$(dig NS github.com +short | head -1)
dig @$ns github.com A

# Compare with Google's resolver
dig @8.8.8.8 github.com A +short
```

**Questions to answer:**
- What is the TTL of the github.com A record?
- How many IP addresses does it return? (GitHub uses anycast)
- Is the answer from the authoritative nameserver the same as from 8.8.8.8?

### 1.2 Trace the full resolution

```bash
dig +trace github.com
```

Read through the trace. You will see it query:
1. The root nameservers (`.`)
2. The `.com` TLD nameservers
3. GitHub's authoritative nameservers

### 1.3 Reverse DNS

```bash
# Find what hostname is assigned to GitHub's IPs
github_ip=$(dig +short github.com | head -1)
echo "GitHub IP: $github_ip"
dig -x $github_ip +short
```

### 1.4 Inspect different record types

```bash
# Mail servers for gmail.com
dig MX gmail.com +short | sort -n

# TXT records (SPF, DKIM verification)
dig TXT github.com +short

# Check if a domain has IPv6
dig AAAA github.com +short
```

### 1.5 DNS caching

```bash
# First query — cold cache
time dig github.com

# Query again — should be faster (cached locally if you have a local resolver)
time dig github.com

# Bypass all caching
time dig @8.8.8.8 +norecurse github.com
```

---

## Part 2 — TCP connection testing

### 2.1 Test port availability

```bash
# Is port 443 open on github.com?
nc -zv github.com 443

# Is port 80 open?
nc -zv github.com 80

# Test a port that should be closed
nc -zv github.com 22    # SSH — probably blocked
nc -zv github.com 3306  # MySQL — definitely blocked

# Test with a timeout
nc -zv -w 3 github.com 443
```

### 2.2 Scan common ports

```bash
# nmap — network scanner
# Only scan machines you own or have permission to scan
sudo nmap -p 22,80,443 github.com

# Scan your own machine
sudo nmap -p 1-1024 localhost

# Service version detection (on localhost)
sudo nmap -sV -p 1-1024 localhost
```

### 2.3 Inspect local sockets

```bash
# What is listening on your machine?
ss -tlnp

# All TCP connections
ss -tnp

# Connection states
ss -tnp | awk '{print $1}' | sort | uniq -c | sort -rn

# What process is using port 8080 (if anything)?
ss -tlnp | grep :8080
lsof -i :8080
```

---

## Part 3 — HTTP inspection

### 3.1 Trace an HTTP request

```bash
# Verbose curl — shows DNS, TCP connect, TLS, headers
curl -v https://httpbin.org/get 2>&1 | head -60
```

Identify each phase in the output:
- `* Trying IP:PORT...` — TCP connection attempt
- `* Connected to ...` — TCP connected
- `* SSL connection using ...` — TLS negotiated
- `> GET /get HTTP/2` — request headers sent
- `< HTTP/2 200` — response status
- `< content-type: ...` — response headers

### 3.2 Time the request

```bash
curl -w "\n\
DNS lookup:    %{time_namelookup}s\n\
TCP connect:   %{time_connect}s\n\
TLS handshake: %{time_appconnect}s\n\
TTFB:          %{time_starttransfer}s\n\
Total:         %{time_total}s\n\
Response size: %{size_download} bytes\n" \
-s -o /dev/null https://httpbin.org/get
```

Run this 5 times and compare. The first run is typically slower due to DNS caching and TCP slow start.

### 3.3 Test redirects

```bash
# github.com redirects HTTP to HTTPS — follow it
curl -v http://github.com 2>&1 | grep -E "< HTTP|Location:"

# Follow redirects automatically
curl -L -v http://github.com 2>&1 | grep -E "< HTTP|^< [Ll]ocation"
```

### 3.4 HTTP headers

```bash
# Only request headers
curl -v -s -o /dev/null https://httpbin.org/headers 2>&1 | grep "^>"

# Only response headers
curl -I https://httpbin.org/get

# Add custom headers and see the server echo them back
curl https://httpbin.org/headers \
     -H "X-Custom-Header: hello-from-curl" \
     -H "Accept: application/json"
```

### 3.5 POST requests

```bash
# Send JSON, get JSON back
curl -X POST https://httpbin.org/post \
     -H "Content-Type: application/json" \
     -d '{"user": "alice", "action": "login"}' \
     | python3 -m json.tool
```

---

## Part 4 — Network path analysis

### 4.1 Traceroute

```bash
# Trace the path to a remote host
traceroute github.com

# Some hops may show * (firewall blocking ICMP/UDP)
# TCP-based traceroute often gets further
sudo traceroute -T -p 443 github.com
```

Count the hops. Note which ones have high latency — that is where slowness is being introduced.

### 4.2 mtr (live traceroute)

```bash
# Run for 30 seconds, then exit
mtr --report-cycles 30 --report github.com
```

The output shows:

```
HOST                Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. router.local    0.0%    30    0.5    0.5   0.4   0.6   0.0
 2. isp-hop1.net    0.0%    30    5.2    5.3   5.1   5.8   0.1
...
```

- **Loss%** — any packet loss here means network issues
- **Avg** — average round-trip time to this hop
- **StDev** — high standard deviation means variable latency (jitter)

---

## Part 5 — Packet capture

### 5.1 Capture DNS queries

In one terminal, start a capture:

```bash
sudo tcpdump -i any port 53 -n
```

In another terminal, trigger some DNS queries:

```bash
dig github.com
dig +short stackoverflow.com
dig @8.8.8.8 cloudflare.com
```

Watch the DNS packets appear in the capture. You can see the query and the response.

Stop with Ctrl+C.

### 5.2 Capture HTTP traffic

Start an HTTP server to capture:

```bash
# Terminal 1 — start a simple server
python3 -m http.server 8080 &

# Terminal 2 — capture on port 8080
sudo tcpdump -i lo -A port 8080 &
capture_pid=$!

# Terminal 3 — make requests
curl http://localhost:8080/
curl -H "X-Secret: mysecret" http://localhost:8080/

# Stop the capture
kill $capture_pid 2>/dev/null || true
```

Notice how you can read the headers, including `X-Secret: mysecret`, in the capture output. This is why HTTPS matters — without TLS, anyone on the network path can read this.

---

## Part 6 — TLS certificates

### 6.1 Inspect a certificate

```bash
# View certificate details for github.com
echo | openssl s_client -connect github.com:443 -servername github.com 2>/dev/null \
    | openssl x509 -noout -text | head -40
```

### 6.2 Check expiry

```bash
check_cert_expiry() {
    local host="$1"
    local expiry
    expiry=$(echo | openssl s_client -connect "${host}:443" -servername "$host" 2>/dev/null \
             | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    echo "$host: $expiry"
}

for host in github.com google.com cloudflare.com; do
    check_cert_expiry "$host"
done
```

### 6.3 Verify the certificate chain

```bash
# Show the full certificate chain
echo | openssl s_client -showcerts -connect github.com:443 2>/dev/null \
    | grep -E "^(subject|issuer)"
```

A proper chain goes from your certificate → intermediate CA → root CA. If the intermediate is missing, some clients will reject the certificate even though the certificate itself is valid.

---

## Capstone exercise — Full trace of a request

Trace a complete request to `https://api.github.com/zen` (a fun GitHub API endpoint):

1. **DNS** — what IP does api.github.com resolve to? Which nameserver is authoritative?
2. **Route** — how many hops to that IP? Where is the latency concentrated?
3. **TLS** — what certificate is presented? When does it expire? Which CA issued it?
4. **HTTP** — make the request with `curl -v`. How long does each phase take?
5. **Capture** — capture the TLS handshake with `tcpdump` (you will see encrypted data — this proves TLS works)

Write your findings as a brief report:

```bash
cat > ~/networking-lab/request-trace.txt << 'EOF'
Target: https://api.github.com/zen
Date:   2026-05-18

DNS:
  IP:              [fill in]
  TTL:             [fill in]
  Authoritative:   [fill in]

Route:
  Hops:            [fill in]
  Highest latency: [fill in]

TLS:
  Certificate CN:  [fill in]
  Expires:         [fill in]
  Issuer:          [fill in]

HTTP timing:
  DNS:    [fill in]
  TCP:    [fill in]
  TLS:    [fill in]
  TTFB:   [fill in]
  Total:  [fill in]

Response: [what did the zen endpoint return?]
EOF
```
