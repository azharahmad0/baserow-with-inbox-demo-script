# Baserow, Mattermost, and Huginn Local Installation Guide

This guide will help you set up a local demo environment on your MacBook using Docker. You will install and run Baserow, Mattermost, and Huginn, and set up integrations for a centralized inbox.

## Prerequisites

1. **Docker Desktop**: Make sure Docker Desktop is installed on your MacBook. You can download it from [Docker's official website](https://www.docker.com/products/docker-desktop).

## Step 1: Download the Installation Script

1. Create a new directory on your MacBook where you want to set up the demo environment:

   1. Open the terminal.
   2. Run the following command to create a new directory: `mkdir ~/baserow_demo`
   3. Change the directory to the newly created one:`cd ~/baserow_demo`

2. Download the installation script from: [script](https://github.com/azharahmad0/baserow-with-inbox-demo-script).
## Step 2: Run the Installation Script

1. Open the terminal.
2. Make the script executable: `chmod +x install_and_configure_local.sh`
3. Run the script: `./install_and_configure_local.sh`  

### This script will install and configure Baserow, Mattermost, and Huginn on your local machine

## Step 3: Access the Services

### Baserow

  1. URL: <http://localhost:3000>

### Mattermost

  1. URL: <http://localhost:8065>

#### Default Login Credentials

   1. Username: `admin`
   2. Email: <admin@example.com>
   3. Password: `Admin@123`

### Huginn

   1. URL: <http://localhost:3001>
   2. Default Login Credentials:
   3. Username: `admin`
   4. Password: `password`

## Step 4: Configure Webhooks in Mattermost

  1. Log in to Mattermost.
  2. Go to Main Menu > Integrations > Incoming Webhooks.
  3. Create a new incoming webhook.
  4. Set the display name and select the channel.
  5. Copy the webhook URL.

## Step 5: Set Up Huginn Workflow

1. Log in to Huginn.

2. Create a new agent to fetch data from Baserow:
    - Type: Website Agent
    - URL: <http://localhost:3000/api/database/rows/table/{table_id}/?user_field_names=true>
    - Add necessary headers (e.g., Authorization if needed).

3. Create another agent to send data to the Mattermost webhook:

    - Type: Webhook Agent
    - URL: <http://localhost:8065/hooks/{webhook_id}>
  
    - Payload:
  
     ```json
     {
      "text": "New update in Baserow: \n Field1: {{ field1 }} \n Field2: {{ field2 }}"
     }```
  
4. Link the two agents to form a workflow.

## Step 6: Import Data from Airtable to Baserow

1. Export the data from Airtable to a CSV file.
2. Import the CSV file to Baserow.
3. Create a new table in Baserow.
4. Import the CSV file to the new table by clicking on the "Import" button.
