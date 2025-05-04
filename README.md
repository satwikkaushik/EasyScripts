# EasyScripts
A collection of scripts to automate repetitive tasks, such as setting up a fully containerized TypeScript-based Express server with minimal effort.

# Scripts

## express_initializer_ts

- Initializes a new express server with typescript configured in a docker container
- The system need not have node.js installed as everything is done inside a container
- Spins up a temporary container to initialize basic project and install dependencies
- Also creates dockerfile and docker-compose.yml file for later part

**Usage**

1. Run the initializer script:

```bash
./express_initializer.sh <project-name>
```

- `project_name` : should be replaced by the appropriate name for your project

2. Run Docker Compose

```bash
docker compose up
```

- This will automatically build the image if image not found

3. Edit the code files locally and changes will be reflected

**About Docker Container**

1. Exposed Ports:
    1. `3000`

2. Environment Variables: 
    1. `PORT=3000`
    2. `NODE_ENV=development`

3. Workdir: `/usr/src/app`
