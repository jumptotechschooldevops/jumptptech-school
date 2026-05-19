# Lecture 2 · Network Tools & Troubleshooting

## A systematic approach to connectivity problems

When a service is not reachable, work from the bottom of the network stack up:

```
1. DNS — can we resolve the name?
2. Route — can we reach the network?
3. Port — is something listening?
4. Firewall — is the connection allowed?
5. Application — is the app responding correctly?
```

Each layer has specific tools. Do not skip layers. "It must be a DNS issue" before you have checked anything is a guess, not a diagnosis.

---

## DNS tools

### dig

`dig` is the go-to tool for DNS queries:

```bash
# Basic A record lookup
dig api.example.com

# Short output
dig +short api.example.com

# Specific record type
dig MX example.com
dig TXT example.com
dig AAAA example.com
dig NS example.com

# Use a specific nameserver
dig @8.8.8.8 api.example.com       # Google's resolver
dig @1.1.1.1 api.example.com       # Cloudflare's resolver
dig @ns1.example.com api.example.com  # authoritative nameserver directly

# Reverse lookup (IP to hostname)
dig -x 8.8.8.8

# Trace the full resolution path
dig +trace api.example.com

# Check if a record exists (for monitoring)
dig +short api.example.com | grep -q . && echo "Resolves" || echo "NXDOMAIN"
```

Reading `dig` output:

```
;; ANSWER SECTION:
api.example.com.    300    IN    A    93.184.216.34
                    ^^^              ^   ^^^^^^^^^^^
                    TTL (seconds)    |   IP address
                              record type
```

The `300` TTL means this record is cached for 5 minutes. A TTL of 60 means the client will re-query every minute.

### host and nslookup

Simpler alternatives to dig:

```bash
host api.example.com           # simple lookup
host -t MX example.com        # specific type
nslookup api.example.com      # interactive or one-shot
```

---

## HTTP tools

### curl

`curl` is the most versatile HTTP testing tool:

```bash
# Basic GET
curl https://api.example.com/users

# Follow redirects
curl -L https://example.com

# Include response headers
curl -i https://api.example.com

# Show only headers (HEAD request)
curl -I https://api.example.com

# POST with JSON body
curl -X POST https://api.example.com/users \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer token123" \
     -d '{"name": "Alice", "email": "alice@example.com"}'

# Upload a file
curl -X POST https://api.example.com/upload \
     -F "file=@/path/to/file.csv"

# Save response to file
curl -o response.json https://api.example.com/data

# Time the request
curl -w "\n\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
     -s -o /dev/null https://api.example.com

# Test with a specific IP (bypass DNS — useful for testing behind a LB)
curl --resolve api.example.com:443:93.184.216.34 https://api.example.com

# Ignore TLS cert errors (testing only, never in production)
curl -k https://localhost

# Verbose — shows TLS handshake, headers, everything
curl -v https://api.example.com
```

The `-w` (write-out) flag for timing is extremely useful for performance debugging. TTFB (time to first byte) is your application response time; Connect time is TCP round trip; TLS time is the TLS overhead.

---

## Port and connection tools

### ss (socket statistics)

`ss` is the modern replacement for `netstat`:

```bash
# All listening TCP ports
ss -tlnp

# All established TCP connections
ss -tnp state established

# All connections to port 443
ss -tnp dst :443

# Connections from a specific IP
ss -tnp src 10.0.1.50

# Summary statistics
ss -s
```

Common flags: `-t` TCP, `-u` UDP, `-l` listening only, `-n` numeric (no DNS resolution), `-p` show process.

### netstat (older but still present)

```bash
netstat -tlnp    # listening TCP ports
netstat -an      # all connections
netstat -rn      # routing table
```

### nc (netcat)

Netcat is the Swiss Army knife of networking — creates TCP/UDP connections from the command line:

```bash
# Test if a port is open
nc -zv api.example.com 443

# Scan multiple ports
nc -zv api.example.com 80 443 8080

# Simple TCP server (for testing)
nc -l 1234     # listen on port 1234
nc localhost 1234   # connect to it (from another terminal)

# Test UDP
nc -zuv 8.8.8.8 53
```

---

## Network path tools

### ping

```bash
ping api.example.com          # ICMP echo (indefinite)
ping -c 4 api.example.com     # 4 packets
ping -i 0.2 api.example.com   # 0.2s interval (faster)

# Ping outputs round-trip time — useful for detecting packet loss
```

Note: some hosts block ICMP. No response to ping does not necessarily mean the host is down.

### traceroute / tracepath

```bash
traceroute api.example.com    # show each hop (uses UDP by default on Linux)
traceroute -T api.example.com # use TCP (works through more firewalls)
traceroute -I api.example.com # use ICMP
mtr api.example.com           # live updating traceroute (install: apt install mtr)
```

`mtr` is particularly useful — it shows packet loss and round-trip time for each hop, updating in real time.

---

## Packet capture

### tcpdump

`tcpdump` captures network packets. Essential for debugging protocols:

```bash
# Capture all traffic on eth0
sudo tcpdump -i eth0

# Specific host
sudo tcpdump -i eth0 host api.example.com

# Specific port
sudo tcpdump -i eth0 port 80

# HTTP traffic (port 80, print payload)
sudo tcpdump -i eth0 -A port 80

# DNS queries
sudo tcpdump -i eth0 port 53

# Save to file, open in Wireshark
sudo tcpdump -i eth0 -w capture.pcap
wireshark capture.pcap

# Specific source and destination
sudo tcpdump -i eth0 src 10.0.1.50 and dst port 443

# Show packet contents in hex and ASCII
sudo tcpdump -i eth0 -XX port 8080
```

Useful for:
- Confirming that requests are actually arriving at the server
- Inspecting unencrypted protocol conversations (HTTP, DNS)
- Debugging connection resets and timeouts

---

## Firewall rules

### iptables

```bash
# List all rules
sudo iptables -L -n -v

# List specific chain
sudo iptables -L INPUT -n -v

# Allow incoming SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow incoming HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Drop everything else to INPUT
sudo iptables -P INPUT DROP

# Allow established connections (important — without this, responses are blocked)
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Delete a rule
sudo iptables -D INPUT -p tcp --dport 80 -j ACCEPT

# Flush all rules (WARNING: locks you out if SSH isn't allowed)
sudo iptables -F
```

### ufw (simpler firewall management)

`ufw` (Uncomplicated Firewall) is a frontend for iptables common on Ubuntu:

```bash
sudo ufw status
sudo ufw enable
sudo ufw allow ssh          # port 22
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 3306          # block MySQL from outside
sudo ufw allow from 10.0.0.0/8 to any port 5432   # allow only internal IPs on Postgres
```

---

## TLS certificate inspection

```bash
# Check certificate details
openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null 2>/dev/null \
    | openssl x509 -noout -dates -subject -issuer

# Check expiry only
openssl s_client -connect api.example.com:443 </dev/null 2>/dev/null \
    | openssl x509 -noout -enddate

# Check certificate chain
openssl s_client -showcerts -connect api.example.com:443 </dev/null

# Check all certificates expiring within 30 days on a list of hosts
while read -r host; do
    expiry=$(openssl s_client -connect "$host:443" </dev/null 2>/dev/null \
             | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    echo "$host: $expiry"
done < hosts.txt
```

---

## Troubleshooting cookbook

### "curl: connection refused"
```bash
# Is the service listening on that port?
ss -tlnp | grep :80

# Is a firewall blocking it?
sudo iptables -L -n | grep 80
```

### "curl: could not resolve host"
```bash
# DNS problem — check the resolver
dig api.example.com
dig @8.8.8.8 api.example.com  # bypass local resolver

# Check /etc/resolv.conf
cat /etc/resolv.conf

# Check /etc/hosts
cat /etc/hosts | grep api
```

### "502 Bad Gateway"
```bash
# Is the upstream app running?
systemctl status myapp
journalctl -u myapp -n 50

# Is it listening on the expected port?
ss -tlnp | grep :8080
```

### "High latency / timeouts"
```bash
# Network path issues?
mtr api.example.com

# Slow DNS?
time dig api.example.com

# Time each phase of the HTTP request
curl -w "DNS:%{time_namelookup} Connect:%{time_connect} TTFB:%{time_starttransfer} Total:%{time_total}" \
     -s -o /dev/null https://api.example.com
```

---

## Summary

- Work from DNS → route → port → firewall → application. Do not skip steps.
- `dig` for DNS; `curl -v` for HTTP; `ss -tlnp` for listening ports; `tcpdump` for packet inspection.
- `nc -zv host port` is the fastest way to test if a port is open.
- TLS certificate expiry causes production outages. Monitor expiry dates.
- `mtr` combines ping and traceroute and shows packet loss per hop.
