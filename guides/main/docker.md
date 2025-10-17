# 🐳 Docker Commands

## 🧱 Basic Commands

| Command | Description |
|----------|-------------|
| `docker --version` | Check installed Docker version |
| `docker info` | Show system-wide information |
| `docker help` | Show help for Docker commands |
| `docker login` | Login |
| `docker logout` | Logout |
| `docker init` | init |

---

## 📦 Images

| Command | Description |
|----------|-------------|
| opeartions |-------------|
| `docker pull <image>` | Download an image from Docker Hub |
| `docker images` | List all images on your system |
| `docker rmi <image>` | Remove an image |
| `docker build -t <name>:<tag> .` | Build an image from a Dockerfile |
| `docker tag <image> <repo>/<tag>` | Tag an image for a repository |
| `docker push <repo>:<tag>` | Push image to Docker Hub or registry |
| others |-------------|
| `docker history <image>` | Show image layers and history |
| `docker inspect <image>` | Display detailed image info |

---

## 🐋 Containers

| Command | Description |
|----------|-------------|
| run opeartions |-------------|
| `docker run <image>` | Run a new container |
| `docker run -d <image>` | Run container in detached (background) mode |
| `docker run --name <name> <image>` | Run a new container with a name |
| `docker run -p <host-port>:<container-port> <image>` | Run a new container with port |
| `docker run -v <path> <image>` | Run a new container with volume, sample: path = "$(pwd):/app", path = /app/node_modules  |
| `docker run --name <name> -p 3000:3000 -v "$(pwd):/app" -v /app/node_modules <image>` | sample |
| opeartions |-------------|
| `docker stop <container>` | Stop a running container |
| `docker start <container>` | Start a stopped container |
| `docker restart <container>` | Restart a container |
| `docker rm <container>` | Remove a stopped container |
| list |-------------|
| `docker ps` | List **running** containers |
| `docker ps -a` | List **all** containers (including stopped) |
| shell |-------------|
| `docker run -it <image>` | Run container interactively with shell |
| `docker run -it <image> sh` | Run container interactively with shell |
| others |-------------|
| `docker exec -it <container> <cmd>` | Run a command inside a running container |
| `docker inspect <container>` | View detailed container info |
| `docker logs <container>` | View logs from a container |
| `docker stats` | Show live CPU/memory usage of containers |
| `docker top <container>` | Display running processes inside container |

---

## 🗂 Volumes & Files

| Command | Description |
|----------|-------------|
| `docker volume ls` | List all volumes |
| `docker volume create <name>` | Create a volume |
| `docker volume rm <name>` | Remove a volume |
| `docker volume inspect <name>` | Inspect a volume |
| `docker cp <container>:<path> <local_path>` | Copy files from container to host |
| `docker cp <local_path> <container>:<path>` | Copy files from host to container |

---

## 🌐 Networks

| Command | Description |
|----------|-------------|
| `docker network ls` | List networks |
| `docker network create <name>` | Create a new network |
| `docker network inspect <name>` | View network details |
| `docker network rm <name>` | Remove a network |
| `docker network connect <network> <container>` | Connect container to network |
| `docker network disconnect <network> <container>` | Disconnect container from network |

---

## 🧹 Cleanup

| Command | Description |
|----------|-------------|
| `docker system df` | List docker core components info  |
| `docker system prune` | Remove all unused containers, networks, and images |
| `docker system prune -a` | Remove all containers, networks, and images |
| `docker system prune -af` | Force remove all containers, networks, and images |
| `docker image prune` | Remove unused images |
| `docker container prune` | Remove stopped containers |
| `docker volume prune` | Remove unused volumes |

---

## 🧩 Docker Compose (Multi-Container)

| Command | Description |
|----------|-------------|
| `docker compose up` | Start all services in `docker-compose.yml` |
| `docker compose -p <name> up` | start services with a name |
| `docker compose up -d` | Start in detached mode |
| `docker compose down` | Stop and remove containers/networks/volumes |
| `docker compose ps` | List containers managed by Compose |
| `docker compose logs -f` | Stream logs from Compose services |
| `docker compose build` | Build/rebuild services |
| `docker compose restart` | Restart all services |
