#!/bin/bash
# Script to initialize a Node.js project inside Docker container with proper permissions

# Check if a project name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME=$1

echo "Initializing project"

# Create project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Run Docker container for initialization
echo "Initializing Node.js project in a temporary Docker container"

docker run -it --rm \
  --user $(id -u):$(id -g) \
  --mount type=bind,source=$(pwd),target=/usr/src/app \
  -w /usr/src/app \
  node:22 bash -c "npm init -y && npm i express && npm i -D typescript ts-node-dev @types/express @types/node && npx tsc --init && npm pkg set scripts.dev='ts-node-dev --poll --respawn --transpile-only src/index.ts' scripts.build='tsc' scripts.start='node dist/index.js'"

# Create src directory and basic structure
echo "Creating source directory and basic structure"

mkdir -p src
touch src/app.ts
touch src/index.ts

# Creating basic Express server
echo "Creating basic Express server"

cat > src/index.ts << 'EOL'
import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
EOL

cat > src/app.ts << 'EOL'
import express, {Request, Response} from 'express';

const app = express();

app.get('/', (req: Request, res: Response) => {
    res.status(200).json({message: "Hello from Express!"});
});

app.get('/health', (req: Request, res: Response) => {
    res.status(200).json({status: "ok"});
});

export default app;
EOL

# Create Dockerfile
echo "Creating Dockerfile"

cat > Dockerfile << 'EOL'
# Development stage
FROM node:22 AS development

WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source files
COPY . .

# Build stage
FROM development AS build
RUN npm run build

# Production stage
FROM node:22-alpine AS production

WORKDIR /usr/src/app

# Install production dependencies only
COPY package*.json ./
RUN npm install --production

# Copy built application from build stage
COPY --from=build /usr/src/app/dist ./dist

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]
EOL

# Create docker-compose.yml
echo "Creating docker-compose.yml"
cat > docker-compose.yml << 'EOL'
version: '3'

services:
  app:
    build:
      context: .
      target: development
    ports:
      - "3000:3000"
    working_dir: /usr/src/app
    volumes:
      - ./src:/usr/src/app/src
      - ./package.json:/usr/src/app/package.json
      - ./tsconfig.json:/usr/src/app/tsconfig.json
    environment:
      - NODE_ENV=development
      - PORT=3000
    command: npm run dev
EOL

# Create .gitignore
echo "Creating .gitignore"

cat > .gitignore << 'EOL'
node_modules/
dist/
.env
*.log
EOL

# Create .dockerignore
echo "Creating .dockerignore"

cat > .dockerignore << 'EOL'
node_modules
npm-debug.log
dist
.git
.env
.vscode
EOL

# Done
echo "Project $PROJECT_NAME initialized successfully!"
echo "cd $PROJECT_NAME and start coding!"
