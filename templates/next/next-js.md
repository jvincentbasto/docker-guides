# Docker Next Ts

## Dockerignore

```dockerfile
# Node / build outputs
node_modules
build
dist
.next
.cache

# Logs
npm-debug.log

# Environment & secrets
.env
secrets.dev.yaml
values.dev.yaml

# Git
.git
.gitignore

# IDE / editor files
.vscode
.vs
.project
.settings
.classpath
*.dbmdl
*.*proj.user
*.jfm
obj
charts

# Docker
docker-compose*
compose*

# Misc
LICENSE
README.md
```

## Next config

```js
// next.config.js

const nextConfig = {
  output: "standalone",
};

module.exports = nextConfig;
```

## App

### App docker dev

```dockerfile
# Dockerfile.dev

FROM node:22-alpine

# add user and group
# RUN addgroup app && adduser -S -G app app
# USER app

WORKDIR /app
COPY package*.json ./

# set permissions
# USER root
# RUN chown -R app:app .
# USER app

RUN npm install
COPY . .

EXPOSE 3000
CMD ["npm", "run", "dev"]
```

```yaml
# docker-compose-dev.yaml

name: next-js-dev
services:
  web:
    depends_on:
      - db
    image: next-js-dev
    container_name: next-js-dev-web
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    # environment:
    #   DB_URL: mongodb://db/tasked
    env_file:
      - .env.local
    # command: npm run dev
    develop:
      watch:
        # dependencies
        - path: package.json
          action: rebuild
        - path: package-lock.json
          action: rebuild
        # app
        - path: .
          target: /app
          action: sync

  db:
    image: mongo:latest
    container_name: next-js-dev-db
    ports:
      # default local mongodb port 27017
      - 27017:27017
    volumes:
      # mount volume "tasked" inside the container at /data/db directory
      - tasked:/data/db

# volumes
volumes:
  tasked:
```

```bash
# commands

# vite
vite --host --port 3000

# docker-compose
docker compose -f docker-compose-dev.yaml up
docker compose -f docker-compose-dev.yaml down --volumes
```

### App docker prod

```dockerfile
# Dockerfile.prod

# ---- Stage 1: Deps ----
FROM node:22-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

# ---- Stage 2: Build ----
FROM node:22-alpine AS build
WORKDIR /app

COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build

# ---- Stage 3: Prod ----
FROM node:22-alpine AS prod
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=4000

# Copy standalone output from build
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

EXPOSE 4000
CMD ["node", "server.js"]
```

```yaml
# docker-compose-prod.yaml

name: next-js
services:
  web:
    image: next-js
    container_name: next-js-web
    build:
      context: .
      dockerfile: Dockerfile.prod
    ports:
      - "4000:4000"
    env_file:
      - .env
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/api"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```bash
# commands

# docker-compose
docker compose -f docker-compose-prod.yaml up --build -d
docker compose -f docker-compose-prod.yaml down
```

### App Scripts

```json
"scripts": {
  "docker-dev:up": "docker compose -f docker-compose-dev.yaml up",
  "docker-dev:down": "docker compose -f docker-compose-dev.yaml down --volumes",
  "docker-prod:up": "docker compose -f docker-compose-prod.yaml up --build -d",
  "docker-prod:down": "docker compose -f docker-compose-prod.yaml down"
}
```
