# Docker MERN Vite Js

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

## Vite react config

```js
// package.json
  // add to scripts | --host
  "dev": "vite --host --port 3000",


// vite.config.js
// enable polling
export default {
  server: {
    watch: {
      usePolling: true,
    },
    host: true, // allows access from Docker
    port: 3000, // change default port
    strictPort: true, // fail instead of falling back to another port
  },
};
```

```js
// server.js

import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

const PORT = process.env.PORT || 4173;

// Serve static files from dist
app.use(express.static(path.join(__dirname, "dist")));

// Fallback to index.html for SPA routes
app.get(/.*/, (_, res) => {
  res.sendFile(path.join(__dirname, "dist", "index.html"));
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

```bash
# .env

VITE_API_URL=http://localhost:9000
PORT=4000
```

```bash
# .env.local

VITE_API_URL=http://localhost:8000
```

```bash
# with vite.config.js
docker run --rm --name react-js-dev -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules react-js

# set env
docker run --rm --name react-js-dev -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules -e CHOKIDAR_USEPOLLING=true react-js
```

## Backend

### Backend docker dev

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

EXPOSE 8000
CMD ["npm", "run", "dev"]
```

```yaml
# docker-compose-dev.yaml

name: mern-js-backend-dev
services:
  api:
    depends_on:
      - db
    image: mern-js-backend-dev
    container_name: mern-js-backend-dev-api
    build:
      context: ../
      dockerfile: docker/Dockerfile.dev
    ports:
      - "8000:8000"
    # environment:
    #   DB_URL: mongodb://db/anime
    env_file:
      - ../.env.local
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
    container_name: mern-js-backend-dev-db
    ports:
      # default local mongodb port 27017
      - 27017:27017
    volumes:
      # mount volume "anime" inside the container at /data/db directory
      - anime:/data/db

# define the volumes to be used by the services
volumes:
  anime:
```

```bash
# commands

# docker-compose
docker compose -f docker/docker-compose-dev.yaml up
docker compose -f docker/docker-compose-dev.yaml down --volumes
```

### Backend docker prod

```dockerfile
# Dockerfile.prod

# stage - build
FROM node:22-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# stage - prod
FROM node:22-alpine AS prod

WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN npm ci --omit=dev

EXPOSE 9000
CMD ["npm", "start"]
```

```yaml
# docker-compose-prod.yaml

name: mern-js-backend
services:
  api:
    image: mern-js-backend
    container_name: mern-js-backend-api
    build:
      context: ../
      dockerfile: docker/Dockerfile.prod
    ports:
      - "9000:9000"
    env_file:
      - ../.env
    command: npm start
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```bash
# commands

# docker-compose
docker compose -f docker/docker-compose-prod.yaml up --build -d
docker compose -f docker/docker-compose-prod.yaml down
```

### Backend Scripts

```json
"scripts": {
  "docker-dev:up": "docker compose -f docker/docker-compose-dev.yaml up",
  "docker-dev:down": "docker compose -f docker/docker-compose-dev.yaml down --volumes",
  "docker-prod:up": "docker compose -f docker/docker-compose-prod.yaml up --build -d",
  "docker-prod:down": "docker compose -f docker/docker-compose-prod.yaml down"
}
```

## Frontend

### Frontend docker dev

```dockerfile
# Dockerfile.dev

FROM node:22-alpine

# add user and group
# RUN addgroup app && adduser -S -G app app
# USER app

WORKDIR /app
ENV CHOKIDAR_USEPOLLING=true
# Env injection comes from compose file
ENV CHOKIDAR_USEPOLLING=$CHOKIDAR_USEPOLLING
COPY package*.json ./

# set permissions
# USER root
# RUN chown -R app:app .
# USER app

RUN npm install
COPY . .

# EXPOSE 5173
EXPOSE 3000
CMD ["npm", "run", "dev"]
```

```yaml
# docker-compose-dev.yaml

name: mern-js-frontend-dev
services:
  web:
    image: mern-js-frontend-dev
    container_name: mern-js-frontend-dev-web
    build:
      context: ../
      dockerfile: docker/Dockerfile.dev
      # args:
      #   CHOKIDAR_USEPOLLING: ${CHOKIDAR_USEPOLLING}
    ports:
      # - "5173:5173"
      - "3000:3000"
    environment:
      - CHOKIDAR_USEPOLLING=true
      - CHOKIDAR_USEPOLLING=${CHOKIDAR_USEPOLLING}
    env_file:
      - ../.env.local
    volumes:
      - ../:/app
      - /app/node_modules
```

```bash
# commands

# vite
vite --host --port 3000

# docker-compose
docker compose -f docker/docker-compose-dev.yaml up
docker compose -f docker/docker-compose-dev.yaml down --volumes
```

### Frontend docker prod

```dockerfile
# Dockerfile.prod

# stage - build
FROM node:22-alpine AS build

WORKDIR /app
COPY package*.json ./
# faster + reproducible installs
RUN npm ci

COPY . .
# runs `vite build` → generates /dist
RUN npm run build

# stage - prod
FROM node:22-alpine AS prod

WORKDIR /app
# Copy only built output and necessary files
COPY --from=build /app/dist ./dist
COPY package*.json ./
COPY server.js ./
RUN npm ci --omit=dev

# ENV PORT=4000
# EXPOSE 4173
# CMD ["node", "server.js"]

ENV PORT=4000
EXPOSE 4000
CMD ["npm", "start"]
```

```yaml
# docker-compose-prod.yaml

name: mern-js-frontend
services:
  web:
    image: mern-js-frontend
    container_name: mern-js-frontend-web
    build:
      context: ../
      dockerfile: docker/Dockerfile.prod
    ports:
      # - "4173:4173"
      - "4000:4000"
    env_file:
      - ../.env
```

```bash
# commands

# docker-compose
docker compose -f docker/docker-compose-prod.yaml up --build -d
docker compose -f docker/docker-compose-prod.yaml down
```

### Frontend Scripts

```json
"scripts": {
  "dev": "vite --host --port 3000",
  "start": "node server.js",
  "docker-dev:up": "docker compose -f docker/docker-compose-dev.yaml up",
  "docker-dev:down": "docker compose -f docker/docker-compose-dev.yaml down --volumes",
  "docker-prod:up": "docker compose -f docker/docker-compose-prod.yaml up --build -d",
  "docker-prod:down": "docker compose -f docker/docker-compose-prod.yaml down"
}
```

## App

### App docker dev

```yaml
# docker-compose-dev.yaml
# Setup: Default

name: mern-js-dev
services:
  web:
    depends_on:
      - api
    image: mern-js-dev-web
    container_name: mern-js-dev-web
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      # - 5173:5173
      - 3000:3000
    # environment:
    #   VITE_API_URL: http://localhost:8000
    env_file:
      - ./frontend/.env.local
    develop:
      watch:
        # dependencies
        - path: ./frontend/package.json
          action: rebuild
        - path: ./frontend/package-lock.json
          action: rebuild
        # app
        - path: ./frontend
          target: /app
          action: sync

  api:
    depends_on:
      - db
    image: mern-js-dev-api
    container_name: mern-js-dev-api
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    # environment:
    #   DB_URL: mongodb://db/anime
    env_file:
      - ./backend/.env.local
    # command: npm run dev
    develop:
      watch:
        # dependencies
        - path: ./backend/package.json
          action: rebuild
        - path: ./backend/package-lock.json
          action: rebuild
        # app
        - path: ./backend
          target: /app
          action: sync

  db:
    image: mongo:latest
    container_name: mern-js-dev-db
    ports:
      # default local mongodb port 27017
      - 27017:27017
    volumes:
      # mount volume "anime" inside the container at /data/db directory
      - anime:/data/db

# volumes
volumes:
  anime:
```

```yaml
# docker-compose-dev.yaml
# Setup: include

name: mern-js-dev
include:
  - ./backend/docker-compose-dev.yaml
  - ./frontend/docker-compose-dev.yaml
```

```yaml
# docker-compose-dev.yaml
# Setup: extends

services:
  web:
    extends:
      service: web
      file: ./frontend/docker-compose-dev.yaml
    depends_on:
      - api
    image: mern-js-dev-web
    container_name: mern-js-dev-web
    develop:
      watch:
        # dependencies
        - path: ./frontend/package.json
          action: rebuild
        - path: ./frontend/package-lock.json
          action: rebuild
        # app
        - path: ./frontend
          target: /app
          action: sync

  api:
    extends:
      service: api
      file: ./backend/docker-compose-dev.yaml
    depends_on:
      - db
    image: mern-js-dev-api
    container_name: mern-js-dev-api
    develop:
      watch:
        # dependencies
        - path: ./backend/package.json
          action: rebuild
        - path: ./backend/package-lock.json
          action: rebuild
        # app
        - path: ./backend
          target: /app
          action: sync

  db:
    extends:
      service: db
      file: ./backend/docker-compose-dev.yaml
    container_name: mern-js-dev-db

# volumes
volumes:
  anime:
```

```bash
# commands

# docker-compose
docker compose -f docker/docker-compose-dev.yaml up
docker compose -f docker/docker-compose-dev.yaml down --volumes
```

### App docker prod

```yaml
# docker-compose-prod.yaml
# Setup: Default

name: mern-js
services:
  web:
    depends_on:
      - api
    image: mern-js-web
    container_name: mern-js-web
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    ports:
      # - "4173:4173"
      - "4000:4000"
    # environment:
    #   VITE_API_URL: http://localhost:9000
    env_file:
      - ./frontend/.env

  api:
    image: mern-js-api
    container_name: mern-js-api
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    ports:
      - "9000:9000"
    env_file:
      - ./backend/.env
    command: npm start
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```yaml
# docker-compose-prod.yaml
# Setup: include

name: mern-js
include:
  - ./backend/docker/docker-compose-prod.yaml
  - ./frontend/docker/docker-compose-prod.yaml
```

```yaml
# docker-compose-prod.yaml
# Setup: extends

services:
  web:
    extends:
      service: web
      file: ./frontend/docker/docker-compose-prod.yaml
    depends_on:
      - api
    image: mern-js-web
    container_name: mern-js-web

  api:
    extends:
      service: api
      file: ./backend/docker/docker-compose-prod.yaml
    image: mern-js-api
    container_name: mern-js-api
```

```bash
# commands

# docker-compose
docker compose -f docker/docker-compose-prod.yaml up --build -d
docker compose -f docker/docker-compose-prod.yaml down
```

### App Scripts

```json
"scripts": {
  "docker-dev:up": "docker compose -f docker/docker-compose-dev.yaml up",
  "docker-dev:down": "docker compose -f docker/docker-compose-dev.yaml down --volumes",
  "docker-prod:up": "docker compose -f docker/docker-compose-prod.yaml up --build -d",
  "docker-prod:down": "docker compose -f docker/docker-compose-prod.yaml down"
}
```
