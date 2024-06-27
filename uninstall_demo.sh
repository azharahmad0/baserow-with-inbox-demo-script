#!/bin/bash

# Stop and remove Docker containers
cd ~/baserow_demo/baserow
docker-compose down

cd ~/baserow_demo/mattermost
docker-compose down

cd ~/baserow_demo/huginn
docker-compose down

# Remove Docker network
docker network rm baserow_network

# Remove Docker volumes
docker volume rm baserow_postgres_data baserow_backend_data mattermost_data huginn_postgres_data

# Remove project directory
rm -rf ~/baserow_demo

# Optional: Remove Docker images
docker rmi baserow/backend:latest baserow/web-frontend:latest postgres:13 mattermost/mattermost-team-edition:latest huginn/huginn-single-process

echo "Demo uninstalled and cleaned up successfully."
