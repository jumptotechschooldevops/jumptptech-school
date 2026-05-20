# API Cheatsheet

## HTTP Methods

| Method | Purpose | Has Body | Idempotent | Safe |
|--------|---------|----------|------------|------|
| `GET` | Read resource | No | Yes | Yes |
| `POST` | Create resource | Yes | No | No |
| `PUT` | Replace resource (full update) | Yes | Yes | No |
| `PATCH` | Partial update | Yes | No | No |
| `DELETE` | Delete resource | No | Yes | No |
| `HEAD` | Like GET, headers only | No | Yes | Yes |
| `OPTIONS` | List allowed methods | No | Yes | Yes |

```http
GET    /api/users/42
POST   /api/users
PUT    /api/users/42
PATCH  /api/users/42
DELETE /api/users/42
```

---

## HTTP Status Codes

### 2xx — Success
| Code | Meaning | Use case |
|------|---------|---------|
| `200 OK` | Request succeeded | GET, PUT, PATCH |
| `201 Created` | Resource created | POST |
| `202 Accepted` | Async accepted | Background jobs |
| `204 No Content` | Success, no body | DELETE |

### 3xx — Redirection
| Code | Meaning | Use case |
|------|---------|---------|
| `301 Moved Permanently` | New URL forever | SEO redirects |
| `302 Found` | Temporary redirect | Login flows |
| `304 Not Modified` | Use cached version | ETag/If-None-Match |

### 4xx — Client Errors
| Code | Meaning | Use case |
|------|---------|---------|
| `400 Bad Request` | Invalid input | Validation failure |
| `401 Unauthorized` | Not authenticated | Missing/bad token |
| `403 Forbidden` | Not authorized | Insufficient permissions |
| `404 Not Found` | Resource missing | Wrong ID/path |
| `405 Method Not Allowed` | Wrong HTTP verb | POST on read-only |
| `409 Conflict` | State conflict | Duplicate email |
| `410 Gone` | Deleted permanently | Removed resource |
| `422 Unprocessable Entity` | Semantic error | Failed business rule |
| `429 Too Many Requests` | Rate limited | Exceeded quota |

### 5xx — Server Errors
| Code | Meaning | Use case |
|------|---------|---------|
| `500 Internal Server Error` | Unhandled exception | Bug in server |
| `501 Not Implemented` | Feature missing | Stub endpoint |
| `502 Bad Gateway` | Upstream failure | Nginx → app crash |
| `503 Service Unavailable` | Down/overloaded | Maintenance, scaling |
| `504 Gateway Timeout` | Upstream too slow | DB timeout |

---

## REST URL Conventions

```
# Pattern: /api/v1/<resource>/<id>/<sub-resource>
GET    /api/v1/users              # list all users
GET    /api/v1/users/42           # single user
POST   /api/v1/users              # create user
PUT    /api/v1/users/42           # replace user 42
PATCH  /api/v1/users/42           # partial update
DELETE /api/v1/users/42           # delete user

# Nested resources
GET    /api/v1/users/42/posts     # posts belonging to user 42
GET    /api/v1/users/42/posts/7   # specific post of user 42
POST   /api/v1/users/42/posts     # create post for user 42
```

### Naming rules
- Plural nouns: `/users`, `/orders`, `/products` — not `/user`, `/getUsers`
- Lowercase, hyphen-separated: `/blog-posts` — not `/blogPosts`
- No verbs in URL: use HTTP method as the verb
- Version prefix: `/api/v1/`, `/api/v2/`
- No trailing slash: `/users/42` — not `/users/42/`

---

## curl Commands

### GET
```bash
# Basic GET
curl https://api.example.com/users

# With headers and pretty JSON
curl -s https://api.example.com/users | jq .

# With query params
curl "https://api.example.com/users?page=2&limit=20"

# With auth header
curl -H "Authorization: Bearer <token>" https://api.example.com/users/me
```

### POST (Create)
```bash
# JSON body
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'

# With auth + JSON + pretty response
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name": "Alice"}' \
  | jq .
```

### PUT (Full Replace)
```bash
curl -X PUT https://api.example.com/users/42 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name": "Alice Smith", "email": "alice@example.com", "role": "admin"}'
```

### PATCH (Partial Update)
```bash
curl -X PATCH https://api.example.com/users/42 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name": "Alice Updated"}'
```

### DELETE
```bash
curl -X DELETE https://api.example.com/users/42 \
  -H "Authorization: Bearer <token>"

# Show response code
curl -X DELETE https://api.example.com/users/42 \
  -H "Authorization: Bearer <token>" \
  -o /dev/null -w "%{http_code}\n"
```

### Useful curl flags
```bash
-s             # silent (no progress bar)
-i             # include response headers
-I             # HEAD request only (headers)
-v             # verbose (show request + response)
-o file.json   # save output to file
-w "%{http_code}"   # print HTTP status code
-L             # follow redirects
--max-time 10  # timeout in seconds
-k             # skip TLS verification (dev only)
--compressed   # request gzip compression
```

---

## Authentication Types

### Basic Auth
```bash
# Credentials in URL (not recommended for production)
curl https://user:password@api.example.com/data

# With -u flag (base64 encodes automatically)
curl -u username:password https://api.example.com/data

# Header format: "Basic <base64(user:pass)>"
curl -H "Authorization: Basic dXNlcjpwYXNz" https://api.example.com/data
```

### Bearer Token (JWT / OAuth2 Access Token)
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." \
  https://api.example.com/profile

# Store token in variable
TOKEN=$(curl -s -X POST https://api.example.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret"}' | jq -r '.token')

curl -H "Authorization: Bearer $TOKEN" https://api.example.com/me
```

### API Key
```bash
# In header (most common)
curl -H "X-API-Key: abc123secret" https://api.example.com/data
curl -H "api-key: abc123secret" https://api.example.com/data

# In query string (less secure, appears in logs)
curl "https://api.example.com/data?api_key=abc123secret"
```

### OAuth2 Client Credentials (machine-to-machine)
```bash
# Step 1: Get access token
curl -X POST https://auth.example.com/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=ID&client_secret=SECRET&scope=read"

# Step 2: Use access token
curl -H "Authorization: Bearer <access_token>" https://api.example.com/data
```

---

## Common Request Headers

| Header | Value example | Purpose |
|--------|--------------|---------|
| `Content-Type` | `application/json` | Body format being sent |
| `Accept` | `application/json` | Expected response format |
| `Authorization` | `Bearer <token>` | Auth credentials |
| `X-API-Key` | `abc123` | API key auth |
| `X-Request-ID` | `uuid-here` | Request tracing |
| `X-Correlation-ID` | `uuid-here` | Distributed tracing |
| `User-Agent` | `MyApp/1.0` | Client identification |
| `Cache-Control` | `no-cache` | Caching directives |
| `If-None-Match` | `"etag-value"` | Conditional GET (304) |
| `Content-Length` | `348` | Body byte size |

```bash
# Multiple headers in curl
curl https://api.example.com/data \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-Request-ID: $(uuidgen)"
```

---

## JSON Request / Response Examples

### Request body (POST /users)
```json
{
  "name": "Alice Smith",
  "email": "alice@example.com",
  "role": "developer",
  "team_id": 7
}
```

### Success response (201 Created)
```json
{
  "id": 42,
  "name": "Alice Smith",
  "email": "alice@example.com",
  "role": "developer",
  "team_id": 7,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Error response (400 Bad Request)
```json
{
  "error": "validation_failed",
  "message": "Email is already taken",
  "details": [
    {
      "field": "email",
      "code": "duplicate",
      "message": "alice@example.com is already registered"
    }
  ]
}
```

### Paginated list response
```json
{
  "data": [
    {"id": 1, "name": "Alice"},
    {"id": 2, "name": "Bob"}
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 143,
    "total_pages": 8,
    "next": "/api/v1/users?page=2",
    "prev": null
  }
}
```

---

## API Testing with curl — Real Examples

### Test a public API (no auth)
```bash
# JSONPlaceholder — free test API
curl -s https://jsonplaceholder.typicode.com/users/1 | jq .
curl -s https://jsonplaceholder.typicode.com/posts?userId=1 | jq '.[].title'
```

### Full CRUD test sequence
```bash
BASE="https://jsonplaceholder.typicode.com"

# Create
curl -s -X POST $BASE/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","body":"Hello","userId":1}' | jq .

# Read
curl -s $BASE/posts/1 | jq .

# Update
curl -s -X PUT $BASE/posts/1 \
  -H "Content-Type: application/json" \
  -d '{"id":1,"title":"Updated","body":"New content","userId":1}' | jq .

# Delete
curl -s -X DELETE $BASE/posts/1 -w "Status: %{http_code}\n"
```

### Check response headers
```bash
curl -I https://api.github.com/users/octocat
# Shows: Content-Type, X-RateLimit-Remaining, X-RateLimit-Reset, ETag, etc.
```

### GitHub API (real example)
```bash
# Public — no auth
curl -s https://api.github.com/repos/kubernetes/kubernetes | jq '{stars:.stargazers_count, forks:.forks_count}'

# With auth (higher rate limit)
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/user | jq '{login:.login, repos:.public_repos}'

# Create a repo
curl -X POST https://api.github.com/user/repos \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"my-new-repo","private":false}'
```

### Test rate limiting / errors
```bash
# Check status code only
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/users

# Time the request
curl -s -o /dev/null -w "DNS: %{time_namelookup}s  Connect: %{time_connect}s  Total: %{time_total}s\n" \
  https://api.example.com/users
```

---

## Postman / Newman Quick Reference

### Newman (CLI runner for Postman collections)

```bash
# Install
npm install -g newman

# Run a collection
newman run collection.json

# Run with environment
newman run collection.json -e environment.json

# Run with specific iteration count
newman run collection.json -n 5

# Export results (JUnit for CI)
newman run collection.json \
  -e environment.json \
  -r cli,junit \
  --reporter-junit-export results.xml

# Run from URL (Postman share link)
newman run "https://www.postman.com/collections/<id>" \
  -e environment.json \
  --bail  # stop on first failure

# Set environment variable via CLI
newman run collection.json \
  --env-var "baseUrl=https://staging.api.example.com" \
  --env-var "token=abc123"
```

### Postman test scripts (in Tests tab)
```javascript
// Assert status code
pm.test("Status 200", () => pm.response.to.have.status(200));

// Assert JSON field
pm.test("Has user id", () => {
    const body = pm.response.json();
    pm.expect(body.id).to.be.a('number');
});

// Save response value as environment variable
pm.environment.set("userId", pm.response.json().id);

// Assert response time
pm.test("Fast response", () => pm.expect(pm.response.responseTime).to.be.below(500));
```

### Postman pre-request scripts
```javascript
// Generate timestamp
pm.environment.set("timestamp", Date.now());

// Set dynamic auth header
pm.request.headers.add({key: "X-Request-ID", value: pm.variables.replaceIn("{{$guid}}")});
```

---

## Common API Patterns

### Pagination

```bash
# Offset-based (most common)
GET /api/v1/users?page=3&per_page=20
GET /api/v1/users?offset=40&limit=20

# Cursor-based (for large/real-time data)
GET /api/v1/events?cursor=eyJpZCI6MTAwfQ&limit=50
# Response includes: "next_cursor": "eyJpZCI6MTUwfQ"

# Link header (GitHub style)
# Link: <https://api.example.com/users?page=4>; rel="next",
#       <https://api.example.com/users?page=8>; rel="last"
```

### Filtering & Sorting
```bash
# Filter by field
GET /api/v1/users?role=admin&active=true

# Search
GET /api/v1/users?search=alice

# Sort
GET /api/v1/users?sort=created_at&order=desc
GET /api/v1/users?sort=-created_at       # minus prefix = descending

# Field selection (sparse fieldsets)
GET /api/v1/users?fields=id,name,email
```

### API Versioning
```bash
# URL path versioning (most common, most visible)
GET /api/v1/users
GET /api/v2/users

# Header versioning
curl -H "API-Version: 2024-01-01" https://api.example.com/users
curl -H "Accept: application/vnd.myapi.v2+json" https://api.example.com/users

# Query param versioning
GET /api/users?version=2
```

### Idempotency Keys (safe retries)
```bash
# Send same key on retry — server ignores duplicate
curl -X POST https://api.example.com/payments \
  -H "Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000" \
  -H "Content-Type: application/json" \
  -d '{"amount": 5000, "currency": "USD"}'
```

---

## GraphQL Basics vs REST

| | REST | GraphQL |
|--|------|---------|
| Endpoints | One per resource (`/users`, `/posts`) | Single endpoint (`/graphql`) |
| Data shape | Fixed by server | Client specifies exact fields |
| Over-fetching | Common | Eliminated |
| Under-fetching | Requires multiple requests | One query, multiple resources |
| Versioning | URL `/v1`, `/v2` | Evolve schema, deprecate fields |
| Caching | HTTP cache (GET) | Harder (all POST) |
| Learning curve | Low | Higher |

### GraphQL query (curl)
```bash
# Query
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "{ user(id: 42) { id name email posts { title } } }"
  }'

# Mutation (create/update)
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createUser(name: \"Alice\", email: \"alice@example.com\") { id name } }"
  }'

# With variables (cleaner)
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation CreateUser($name: String!, $email: String!) { createUser(name: $name, email: $email) { id } }",
    "variables": {"name": "Alice", "email": "alice@example.com"}
  }'
```

### GraphQL introspection
```bash
# List all types in the schema
curl -X POST https://api.example.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __schema { types { name } } }"}'
```

---

## Webhook Basics

A webhook is an HTTP POST that a server sends **to you** when an event happens.

```
Your server   <------   External service (GitHub, Stripe, etc.)
    ^                            |
    |                    Event occurs (push, payment)
    |                            |
    +---- POST /webhook ----------+
          Body: event payload (JSON)
```

### Receive a webhook (example endpoint)
```bash
# Quick test listener with netcat
nc -lk 8080

# Or with Python
python3 -m http.server 8080

# Expose local port to internet for testing
npx localtunnel --port 8080
# or
ngrok http 8080
```

### Verify webhook signature (security critical)
```bash
# GitHub example — HMAC-SHA256 signature in X-Hub-Signature-256 header
echo -n '<payload>' | openssl dgst -sha256 -hmac '<secret>'
# Compare output with header value (timing-safe compare in real code)
```

### GitHub webhook payload example
```json
{
  "action": "opened",
  "issue": {
    "id": 1,
    "number": 123,
    "title": "Bug: Login fails on mobile"
  },
  "repository": {
    "full_name": "org/repo"
  },
  "sender": {
    "login": "alice"
  }
}
```

### Webhook best practices
```
Always respond 200 quickly   → process async, respond immediately
Verify signature             → prevent spoofed events
Idempotent handler           → webhooks can be delivered multiple times
Log raw payload              → debug failed deliveries
Retry with exponential backoff → handle temporary failures
```

---

## Quick Reference Card

```
# Status code cheat
2xx = success       200=ok  201=created  204=no-content
3xx = redirect      301=moved  304=cached
4xx = client error  400=bad-req  401=unauth  403=forbidden  404=not-found  429=rate-limited
5xx = server error  500=crash  502=gateway  503=down  504=timeout

# curl one-liners
curl -s URL | jq .                           # GET + pretty print
curl -X POST URL -H 'Content-Type: application/json' -d '{}'  # POST JSON
curl -u user:pass URL                        # basic auth
curl -H 'Authorization: Bearer TOKEN' URL    # bearer auth
curl -o /dev/null -w '%{http_code}' URL      # status code only
curl -I URL                                  # headers only
curl -v URL 2>&1 | grep -E '^[<>]'          # request/response lines

# REST URL rules
plural nouns, lowercase, hyphens, versioned
/api/v1/users           /api/v1/users/42
/api/v1/users/42/posts  /api/v1/users/42/posts/7

# Auth header formats
Authorization: Basic <base64(user:pass)>
Authorization: Bearer <jwt-or-oauth-token>
X-API-Key: <key>
```
