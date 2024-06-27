
### Save the Installation Script (`install_and_configure_local.sh`)

Create a new file named `install_and_configure_local.sh` with the following content:

```bash
#!/bin/bash

# Ensure Docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: Docker is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: Docker Compose is not installed.' >&2
  exit 1
fi

# Create project directory
mkdir -p ~/baserow_demo
cd ~/baserow_demo

# Create Docker network
docker network create baserow_network

# Install Baserow
mkdir -p baserow
cd baserow
cat <<EOL > docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:13
    restart: always
    environment:
      POSTGRES_DB: baserow
      POSTGRES_USER: baserow
      POSTGRES_PASSWORD: baserow
    volumes:
      - baserow_postgres_data:/var/lib/postgresql/data

  backend:
    image: baserow/backend:latest
    restart: always
    environment:
      DATABASE_USER: baserow
      DATABASE_PASSWORD: baserow
      DATABASE_HOST: postgres
      DATABASE_NAME: baserow
    depends_on:
      - postgres
    volumes:
      - baserow_backend_data:/baserow/data
    networks:
      - baserow_network

  web-frontend:
    image: baserow/web-frontend:latest
    restart: always
    depends_on:
      - backend
    ports:
      - "3000:3000"
    networks:
      - baserow_network

volumes:
  baserow_postgres_data:
  baserow_backend_data:

networks:
  baserow_network:
    external: true
EOL

docker-compose up -d
cd ..

# Install Mattermost
mkdir -p mattermost
cd mattermost
cat <<EOL > docker-compose.yml
version: "3"

services:
  mattermost:
    image: mattermost/mattermost-team-edition:latest
    restart: always
    ports:
      - "8065:8065"
    volumes:
      - ./volumes/app/mattermost:/mattermost/data
    environment:
      - MM_USERNAME=admin
      - MM_EMAIL=admin@example.com
      - MM_PASSWORD=Admin@123
    networks:
      - baserow_network

volumes:
  mattermost_data:

networks:
  baserow_network:
    external: true
EOL

docker-compose up -d
cd ..

# Install Huginn
mkdir -p huginn
cd huginn
cat <<EOL > docker-compose.yml
version: '3'

services:
  huginn:
    image: huginn/huginn-single-process
    restart: always
    ports:
      - "3001:3001"
    environment:
      DATABASE_ADAPTER: postgresql
      DATABASE_HOST: db
      DATABASE_PORT: 5432
      DATABASE_NAME: huginn
      DATABASE_USERNAME: huginn
      DATABASE_PASSWORD: password
      APP_SECRET_TOKEN: $(openssl rand -hex 32)
      DOMAIN: 'localhost'
      INVITATION_CODE: 'password'
    depends_on:
      - db
    networks:
      - baserow_network

  db:
    image: postgres:13
    restart: always
    environment:
      POSTGRES_DB: huginn
      POSTGRES_USER: huginn
      POSTGRES_PASSWORD: password
    volumes:
      - huginn_postgres_data:/var/lib/postgresql/data
    networks:
      - baserow_network

volumes:
  huginn_postgres_data:

networks:
  baserow_network:
    external: true
EOL

docker-compose up -d

# Provide instructions for configuring webhooks
cat <<EOL > README.md
# Baserow, Mattermost, and Huginn Local Installation

## Baserow
Baserow is running on port 3000. Access it via:
\`\`\`
http://localhost:3000
\`\`\`

## Mattermost
Mattermost is running on port 8065. Access it via:
\`\`\`
http://localhost:8065
\`\`\`
Default login credentials:
- Username: admin
- Email: admin@example.com
- Password: Admin@123

### Setting up Webhooks in Mattermost
1. Log in to Mattermost.
2. Go to **Main Menu > Integrations > Incoming Webhooks**.
3. Create a new incoming webhook.
4. Set the display name and select the channel.
5. Copy the webhook URL.

## Huginn
Huginn is running on port 3001. Access it via:
\`\`\`
http://localhost:3001
\`\`\`
Default login credentials:
- Username: admin
- Password: password

### Setting up Huginn Workflow
1. Log in to Huginn.
2. Create a new agent to fetch data from Baserow:
   - **Type**: Website Agent
   - **URL**: \`http://localhost:3000/api/database/rows/table/{table_id}/?user_field_names=true\`
   - Add Authentication and Headers as needed for Baserow API.

3. Create another agent to send data to the Mattermost webhook:
   - **Type**: Webhook Agent
   - **URL**: \`http://localhost:8065/hooks/{webhook_id}\`
   - **Payload**:
     \`\`\`json
     {
       "text": "New update in Baserow: \\n Field1: {{ field1 }} \\n Field2: {{ field2 }}"
     }
     \`\`\`

4. Link the two agents to form a workflow.

### Example Huginn Workflow

1. **Website Agent (Baserow API)**:
   - Method: GET
   - URL: \`http://localhost:3000/api/database/rows/table/{table_id}/?user_field_names=true\`
   - Add Authentication and Headers as needed for Baserow API.

2. **Webhook Agent (Mattermost Webhook)**:
   - Method: POST
   - URL: \`http://localhost:8065/hooks/{webhook_id}\`
   - Payload:
     \`\`\`json
     {
       "text": "New update in Baserow: \\n Field1: {{ field1 }} \\n Field2: {{ field2 }}"
     }
     \`\`\`

EOL

echo "Installation complete. Please follow the instructions in README.md to configure webhooks."

