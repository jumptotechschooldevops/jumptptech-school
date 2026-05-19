# Lab 2 · Multi-service App with Compose

**Duration:** ~90 minutes  
**Goal:** Build and run a realistic web application — API, database, cache — using Docker Compose with proper networking, volumes, and health checks.

---

## What you will build

A todo list API with:
- **PostgreSQL** — persistent storage
- **Redis** — caching layer
- **FastAPI** — Python REST API
- **nginx** — reverse proxy

```
Browser/curl → nginx(:80) → api(:8000) → postgres(:5432)
                                        → redis(:6379)
```

---

## Setup

```bash
mkdir -p ~/compose-lab
cd ~/compose-lab
mkdir -p api nginx
```

---

## Part 1 — The API

```bash
cat > api/requirements.txt << 'EOF'
fastapi==0.111.0
uvicorn[standard]==0.30.1
asyncpg==0.29.0
redis==5.0.4
psycopg2-binary==2.9.9
sqlalchemy==2.0.31
databases==0.9.0
EOF
```

```bash
cat > api/main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import databases
import sqlalchemy
import redis.asyncio as aioredis
import json
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@db:5432/todos")
REDIS_URL = os.getenv("REDIS_URL", "redis://cache:6379")

database = databases.Database(DATABASE_URL)
metadata = sqlalchemy.MetaData()

todos = sqlalchemy.Table(
    "todos",
    metadata,
    sqlalchemy.Column("id", sqlalchemy.Integer, primary_key=True),
    sqlalchemy.Column("title", sqlalchemy.String(200), nullable=False),
    sqlalchemy.Column("completed", sqlalchemy.Boolean, default=False),
)

engine = sqlalchemy.create_engine(DATABASE_URL)
metadata.create_all(engine)

app = FastAPI(title="Todo API")

@app.on_event("startup")
async def startup():
    await database.connect()
    app.state.redis = await aioredis.from_url(REDIS_URL)

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()
    await app.state.redis.close()

class TodoIn(BaseModel):
    title: str
    completed: bool = False

class Todo(TodoIn):
    id: int

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/todos", response_model=list[Todo])
async def list_todos():
    cache_key = "todos:all"
    cached = await app.state.redis.get(cache_key)
    if cached:
        return json.loads(cached)

    rows = await database.fetch_all(todos.select())
    result = [dict(r) for r in rows]
    await app.state.redis.setex(cache_key, 30, json.dumps(result))
    return result

@app.post("/todos", response_model=Todo, status_code=201)
async def create_todo(todo: TodoIn):
    query = todos.insert().values(**todo.model_dump())
    todo_id = await database.execute(query)
    await app.state.redis.delete("todos:all")
    return {**todo.model_dump(), "id": todo_id}

@app.patch("/todos/{todo_id}", response_model=Todo)
async def update_todo(todo_id: int, todo: TodoIn):
    query = todos.update().where(todos.c.id == todo_id).values(**todo.model_dump())
    rows_affected = await database.execute(query)
    if not rows_affected:
        raise HTTPException(status_code=404, detail="Todo not found")
    await app.state.redis.delete("todos:all")
    return {**todo.model_dump(), "id": todo_id}

@app.delete("/todos/{todo_id}", status_code=204)
async def delete_todo(todo_id: int):
    query = todos.delete().where(todos.c.id == todo_id)
    await database.execute(query)
    await app.state.redis.delete("todos:all")
EOF
```

```bash
cat > api/Dockerfile << 'EOF'
FROM python:3.12-slim

RUN groupadd -g 1001 appgroup && useradd -u 1001 -g appgroup -M appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appgroup . .

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=5 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
```

---

## Part 2 — nginx config

```bash
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api:8000;
    }

    server {
        listen 80;
        server_name _;

        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_read_timeout 60s;
        }

        location /health {
            proxy_pass http://api_backend/health;
        }

        location / {
            return 200 '{"message": "Todo API — use /api/ prefix"}';
            add_header Content-Type application/json;
        }
    }
}
EOF
```

---

## Part 3 — The compose file

```bash
cat > compose.yml << 'EOF'
services:

  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      api:
        condition: service_healthy
    networks:
      - frontend

  api:
    build: ./api
    environment:
      DATABASE_URL: postgresql://todouser:todopass@db:5432/todos
      REDIS_URL: redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    networks:
      - frontend
      - backend

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: todouser
      POSTGRES_PASSWORD: todopass
      POSTGRES_DB: todos
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U todouser -d todos"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    networks:
      - backend

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    networks:
      - backend

volumes:
  postgres_data:
  redis_data:

networks:
  frontend:
  backend:
    internal: true
EOF
```

---

## Part 4 — Start and test

### 4.1 Start the stack

```bash
docker compose up -d --build
```

Watch the startup sequence:

```bash
docker compose ps
docker compose logs -f
```

Wait until all services are healthy:

```bash
# Poll until nginx is up
until curl -sf http://localhost/health; do echo "Waiting..."; sleep 2; done
echo "Stack is ready!"
```

### 4.2 Test the API

```bash
# Create some todos
curl -X POST http://localhost/api/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Learn Docker Compose"}'

curl -X POST http://localhost/api/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Deploy to Kubernetes"}'

curl -X POST http://localhost/api/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Set up monitoring"}'

# List todos (first request — from database)
time curl -s http://localhost/api/todos | python3 -m json.tool

# List todos again (should be faster — from Redis cache)
time curl -s http://localhost/api/todos | python3 -m json.tool

# Update a todo
curl -X PATCH http://localhost/api/todos/1 \
     -H "Content-Type: application/json" \
     -d '{"title": "Learn Docker Compose", "completed": true}'

# Verify the update
curl -s http://localhost/api/todos | python3 -m json.tool

# Delete a todo
curl -X DELETE http://localhost/api/todos/3
```

### 4.3 Inspect the network isolation

```bash
# Can nginx reach the database directly? It should not be able to.
docker compose exec nginx ping db 2>&1 || echo "nginx cannot reach db — correct!"

# Can nginx reach the api? It can.
docker compose exec nginx ping api

# Can the api reach the database?
docker compose exec api ping db

# Can nginx reach redis directly? It should not.
docker compose exec nginx ping cache 2>&1 || echo "nginx cannot reach cache — correct!"
```

### 4.4 Watch Redis caching

```bash
# Open a Redis monitor in one terminal
docker compose exec cache redis-cli monitor &

# Make some API requests in another terminal
curl -s http://localhost/api/todos > /dev/null
curl -s http://localhost/api/todos > /dev/null   # cache hit
curl -X POST http://localhost/api/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Watch cache invalidation"}' > /dev/null
curl -s http://localhost/api/todos > /dev/null   # cache miss (invalidated on write)
curl -s http://localhost/api/todos > /dev/null   # cache hit again
```

---

## Part 5 — Operations

### 5.1 Scale the API

```bash
# Run 3 API instances
docker compose up -d --scale api=3

# nginx handles load balancing automatically
docker compose ps

# Each request might go to a different container
for i in $(seq 1 6); do
    curl -s http://localhost/api/todos > /dev/null
done

# Check logs — you will see requests spread across instances
docker compose logs api | tail -20
```

### 5.2 Database operations

```bash
# Connect directly to PostgreSQL
docker compose exec db psql -U todouser -d todos

# Inside psql:
\dt           # list tables
SELECT * FROM todos;
\q            # quit
```

### 5.3 Persistence test

```bash
# Create a todo
curl -X POST http://localhost/api/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "This should survive a restart"}'

# Stop and remove containers (but keep volumes)
docker compose down

# Verify volumes still exist
docker volume ls | grep compose-lab

# Start again
docker compose up -d

# Wait for healthy
until curl -sf http://localhost/health; do sleep 2; done

# Data should still be there
curl -s http://localhost/api/todos | python3 -m json.tool
```

---

## Part 6 — Cleanup

```bash
# Stop and remove containers
docker compose down

# Also remove volumes (WARNING: deletes all data)
docker compose down -v

# Remove built images
docker compose down --rmi local

# Full cleanup
docker compose down -v --rmi local
```

---

## Checkpoint

You have built a multi-tier application with:

- [x] Two isolated networks (frontend, backend)
- [x] Health checks and `depends_on` ordering
- [x] Named volumes for persistent data
- [x] Redis caching with cache invalidation on writes
- [x] nginx reverse proxy with upstream load balancing
- [x] Horizontal scaling of the API tier

**Discussion questions:**

1. Why is the `backend` network marked as `internal: true`?
2. What happens to todos if you run `docker compose down -v`?
3. Why did we use `service_healthy` condition for the database but not for Redis?
4. How would you add HTTPS to nginx in this setup?
