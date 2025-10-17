# Docker React Jsx

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
  "dev": "vite --host",


// vite.config.js
// enable polling
export default {
  server: {
    watch: {
      usePolling: true,
    },
    host: true, // optional, but useful for Docker
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
# with vite.config.js
docker run --rm --name react-jsx-dev -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules react-jsx

# set env
docker run --rm --name react-jsx-dev -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules -e CHOKIDAR_USEPOLLING=true react-jsx
```

## Docker dev

```dockerfile
# Dockerfile.dev

FROM node:22-alpine

# add user and group
RUN addgroup app && adduser -S -G app app
USER app

WORKDIR /app
ENV CHOKIDAR_USEPOLLING=true
COPY package*.json ./

# set permissions
USER root
RUN chown -R app:app .
USER app

RUN npm install
COPY . .

EXPOSE 5173
CMD ["npm", "run", "dev"]
```

```yaml
# docker-compose-dev.yaml

name: react-jsx-dev
services:
  web:
    image: react-jsx-dev
    container_name: react-jsx-dev-web
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - CHOKIDAR_USEPOLLING=true
```

```bash
# commands

# Dockerfile
docker build -t react-jsx-dev .
docker build -f Dockerfile.dev -t react-jsx-dev .
docker run --rm -p 5173:5173 -v "$(pwd):/app" -v /app/node_modules react-jsx-dev
docker run --rm -p 5173:5173 -v %cd%:/app -v /app/node_modules react-jsx-dev
docker stop [image]

# docker-compose
docker compose up
docker compose -f docker-compose-dev.yaml up
docker compose down
docker compose -f docker-compose-dev.yaml down --volumes
```

## Docker prod

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

EXPOSE 4173
CMD ["node", "server.js"]
```

```yaml
# docker-compose-prod.yaml

name: react-jsx
services:
  web:
    image: react-jsx
    container_name: react-jsx-web
    build:
      context: .
      dockerfile: Dockerfile.prod
    ports:
      - "4173:4173"
```

```bash
# commands

# Dockerfile
docker build -t react-jsx .
docker build -f Dockerfile.prod -t react-jsx .
docker run --init --rm -it -p 4173:4173 react-jsx
docker stop [image]

# docker-compose
docker compose up
docker compose -f docker-compose-prod.yaml up --build -d
docker compose down
docker compose -f docker-compose-prod.yaml down
```

## Scripts

```json
"scripts": {
  "docker-dev:build": "docker build -f Dockerfile.dev -t react-jsx-dev .",
  "docker-dev:run": "docker run --rm -p 5173:5173 -v '$(pwd):/app' -v /app/node_modules react-jsx-dev",
  "docker-dev:run-win": "docker run --rm -p 5173:5173 -v %cd%:/app -v /app/node_modules react-jsx-dev",
  "docker-dev:up": "docker compose -f docker-compose-dev.yaml up",
  "docker-dev:down": "docker compose -f docker-compose-dev.yaml down --volumes",

  "docker-prod:build": "docker build -f Dockerfile.prod -t react-jsx .",
  "docker-prod:run": "docker run --init --rm -it -p 4173:4173 react-jsx",
  "docker-prod:up": "docker compose -f docker-compose-prod.yaml up --build -d",
  "docker-prod:down": "docker compose -f docker-compose-prod.yaml down"
}
```
