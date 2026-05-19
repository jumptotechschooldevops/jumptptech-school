# Lecture 3 · Docker Compose

## The problem Compose solves

Running a single container with `docker run` is manageable. Running a real application — web server, API, database, cache, background workers — requires many containers that need to communicate, share configuration, and start in the right order.

You could manage this with shell scripts calling `docker run` many times. Docker Compose is the right tool instead.

---

## The docker-compose.yml file

A `docker-compose.yml` (or `compose.yml`) file describes your entire application stack as a set of services:

```yaml
services:
  web:
    image: nginx:1.25
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      api:
        condition: service_healthy

  api:
    build: ./api
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Core concepts

### Services

Each entry under `services:` is a service. Compose creates, starts, and manages one container per service by default (more with `deploy.replicas`).

### Networks

By default, Compose creates a single network for your project. Every service is on this network. Services can reach each other by their service name as the hostname.

In the example above, the `api` service connects to the database using `db:5432`. Docker's embedded DNS resolves `db` to the database container's IP address.

You can define custom networks:

```yaml
services:
  web:
    networks:
      - frontend
  api:
    networks:
      - frontend
      - backend
  db:
    networks:
      - backend

networks:
  frontend:
  backend:
    internal: true   # no external access
```

This network segmentation means `web` cannot directly reach `db` — it must go through `api`. This mirrors production security practices.

### Volumes

```yaml
services:
  db:
    volumes:
      # Named volume — Docker manages it, persists between container restarts
      - postgres_data:/var/lib/postgresql/data

      # Bind mount — maps host path to container path
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro

      # Anonymous volume — not reusable, mainly for performance
      - /app/node_modules

volumes:
  postgres_data:      # declares the named volume
    driver: local     # default driver, stored at /var/lib/docker/volumes/
```

Use named volumes for databases and caches. Use bind mounts for configuration files and development (so code changes on the host are immediately reflected in the container).

### Environment variables

```yaml
services:
  api:
    # Inline values
    environment:
      APP_ENV: production
      LOG_LEVEL: info

    # Reference from an .env file (or shell environment)
    environment:
      - DATABASE_URL    # reads from shell/host environment

    # Use an env file
    env_file:
      - .env.production
```

The `.env` file in the same directory as `docker-compose.yml` is automatically loaded for variable substitution:

```bash
# .env
POSTGRES_VERSION=16
APP_PORT=8080
```

```yaml
# docker-compose.yml uses ${VAR} syntax
db:
  image: postgres:${POSTGRES_VERSION:-16}
ports:
  - "${APP_PORT:-8080}:8000"
```

---

## Compose commands

```bash
# Start all services (build images first if needed)
docker compose up

# Start in the background
docker compose up -d

# Start specific services
docker compose up -d db cache

# Build images without starting
docker compose build

# Force rebuild (ignore cache)
docker compose build --no-cache

# Stop services (containers remain)
docker compose stop

# Stop and remove containers
docker compose down

# Stop, remove containers and volumes (WARNING: deletes data)
docker compose down -v

# View logs
docker compose logs
docker compose logs -f api     # follow a specific service

# Execute command in a running service
docker compose exec api bash
docker compose exec db psql -U user myapp

# Run a one-off command (new container, removed after)
docker compose run --rm api python manage.py migrate

# See running containers and their status
docker compose ps

# Scale a service
docker compose up -d --scale api=3

# View resource usage
docker compose top
```

---

## Profiles

Profiles let you include services only in certain contexts:

```yaml
services:
  api:
    build: .
    # No profile = always included

  db:
    image: postgres:16
    # No profile = always included

  test-runner:
    build:
      context: .
      target: test
    profiles: [testing]   # only started with --profile testing

  mailcatcher:
    image: mailcatcher/mailcatcher
    profiles: [dev]       # only started with --profile dev
```

```bash
docker compose up                       # starts api, db
docker compose --profile testing up     # starts api, db, test-runner
docker compose --profile dev up         # starts api, db, mailcatcher
```

---

## Development vs production

A common pattern is to have a base Compose file and overrides:

```yaml
# docker-compose.yml (base)
services:
  api:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp

  db:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

```yaml
# docker-compose.override.yml (development overrides — loaded automatically)
services:
  api:
    volumes:
      - ./src:/app/src   # bind mount source code for hot reload
    environment:
      - APP_ENV=development
      - LOG_LEVEL=debug
    ports:
      - "8000:8000"
      - "5678:5678"   # debugger port
    command: ["uvicorn", "src.main:app", "--reload", "--host", "0.0.0.0"]

  db:
    ports:
      - "5432:5432"    # expose DB port locally for direct access
```

```bash
# Development — uses base + override automatically
docker compose up

# Production — only use the base file (or a specific prod override)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

---

## Health checks and dependency ordering

`depends_on` controls startup order, but by default it only waits for the container to start, not for the service inside to be ready:

```yaml
depends_on:
  db:
    condition: service_started    # container exists (default)
  db:
    condition: service_healthy    # healthcheck passing
  db:
    condition: service_completed_successfully  # for init containers
```

Always use `service_healthy` for databases. A database container that is started but not yet accepting connections will cause your app to fail on startup.

---

## Summary

- Compose describes a multi-container application in a single YAML file.
- Services communicate by service name on the default project network.
- Use named volumes for persistent data, bind mounts for development code.
- `depends_on: condition: service_healthy` waits for health checks, not just container start.
- Profiles separate development tooling from production services.
- `.env` files provide variable substitution without hardcoding values.
