# Docker Cheatsheet

## Images

```bash
docker pull nginx:1.25             # pull image
docker images                      # list local images
docker image ls                    # same as above
docker image inspect nginx:1.25    # image details
docker image history nginx:1.25    # layer history
docker image rm nginx:1.25         # remove image
docker image prune                 # remove unused images
docker image prune -a              # remove all unused (including tagged)
docker tag myapp:local me/myapp:v1  # tag an image
docker push me/myapp:v1            # push to registry
docker save nginx:1.25 | gzip > nginx.tar.gz   # export image
docker load < nginx.tar.gz         # import image
```

## Containers

```bash
docker run nginx                              # run (foreground)
docker run -d nginx                           # run in background (detached)
docker run -it ubuntu bash                    # interactive terminal
docker run --rm python:3.12 python3 -c "..."  # auto-remove on exit
docker run -d --name web nginx                # named container
docker run -d -p 8080:80 nginx               # port mapping (host:container)
docker run -d -e MY_VAR=value nginx           # environment variable
docker run -d -v /host/path:/container/path nginx  # bind mount
docker run -d -v myvolume:/data nginx         # named volume
docker run -d --network mynet nginx           # specific network
docker run -d --memory=512m --cpus=0.5 nginx  # resource limits
docker run -d --restart=always nginx          # always restart on failure
```

```bash
docker ps                         # running containers
docker ps -a                      # all containers (including stopped)
docker ps -q                      # only IDs
docker start web                  # start stopped container
docker stop web                   # send SIGTERM (graceful)
docker kill web                   # send SIGKILL (immediate)
docker restart web                # stop + start
docker rm web                     # remove stopped container
docker rm -f web                  # force remove running container
docker container prune            # remove all stopped containers
```

## Logs & inspect

```bash
docker logs web                   # view logs
docker logs -f web                # follow logs
docker logs --tail 100 web        # last 100 lines
docker logs --since 1h web        # logs from last hour

docker inspect web                # full container details (JSON)
docker inspect web --format '{{.State.Status}}'      # specific field
docker inspect web --format '{{.NetworkSettings.IPAddress}}'

docker stats                      # live resource usage all containers
docker stats web                  # specific container
docker top web                    # processes in container
```

## Exec & copy

```bash
docker exec web ls /etc/nginx     # run command in running container
docker exec -it web bash          # interactive shell
docker exec -e VAR=val web cmd    # with environment variable

docker cp web:/etc/nginx/nginx.conf ./nginx.conf  # container → host
docker cp ./nginx.conf web:/etc/nginx/nginx.conf  # host → container
```

## Build

```bash
docker build .                          # build from Dockerfile in current dir
docker build -t myapp:v1 .              # with tag
docker build -f Dockerfile.prod .       # specific Dockerfile
docker build --no-cache .               # ignore cache
docker build --target builder .         # stop at specific stage
docker build --build-arg VERSION=1.2 .  # build argument
docker buildx build --platform linux/amd64,linux/arm64 . # multi-platform
```

## Networks

```bash
docker network ls                 # list networks
docker network create mynet       # create bridge network
docker network inspect mynet      # network details
docker network connect mynet web  # connect container to network
docker network disconnect mynet web
docker network rm mynet
docker network prune              # remove unused networks
```

## Volumes

```bash
docker volume ls                  # list volumes
docker volume create mydata       # create named volume
docker volume inspect mydata      # volume details
docker volume rm mydata           # remove volume
docker volume prune               # remove unused volumes
```

## Docker Compose

```bash
docker compose up                 # start stack (attach)
docker compose up -d              # start in background
docker compose up -d --build      # build images then start
docker compose down               # stop and remove containers
docker compose down -v            # also remove volumes
docker compose ps                 # status of services
docker compose logs               # all service logs
docker compose logs -f api        # follow specific service
docker compose exec api bash      # shell in running service
docker compose run --rm api pytest  # one-off command
docker compose stop               # stop without removing
docker compose start              # start stopped services
docker compose restart api        # restart service
docker compose build              # build/rebuild images
docker compose pull               # pull latest images
docker compose scale api=3        # scale service
docker compose config             # validate and show config
```

## Useful Dockerfile instructions

```dockerfile
FROM python:3.12-slim             # base image
WORKDIR /app                      # set working directory
COPY requirements.txt .           # copy files
COPY --chown=user:group src/ .    # copy with ownership
RUN pip install -r requirements.txt  # run command
ENV PYTHONUNBUFFERED=1            # environment variable
ARG BUILD_VERSION                 # build-time variable
EXPOSE 8000                       # document port (does not open it)
USER appuser                      # switch to user
ENTRYPOINT ["python3"]            # always runs
CMD ["-m", "uvicorn", "app:app"]  # default args (can be overridden)
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8000/health
VOLUME ["/data"]                  # mount point
```

## Cleanup

```bash
# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a

# Remove all unused volumes
docker volume prune

# Remove all unused networks
docker network prune

# Nuclear option — remove EVERYTHING unused
docker system prune -a --volumes

# Check disk usage
docker system df
```

## Common patterns

```bash
# Get IP of a container
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web

# Kill all running containers
docker kill $(docker ps -q)

# Remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Run a one-off Python script
docker run --rm -v $(pwd):/app -w /app python:3.12 python3 script.py

# Inspect image without running
docker run --rm -it --entrypoint sh nginx:1.25
```
