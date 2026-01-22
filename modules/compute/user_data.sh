#!/bin/bash
apt-get update -y
apt-get install -y nodejs npm git awscli jq

# Clone the application from GitHub
git clone https://github.com/AbrahamGyamfi/Todo-APP.git /var/www/todo-app
cd /var/www/todo-app

# Install dependencies
npm install

# Fetch secrets from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --region ${aws_region} --query SecretString --output text)
DB_USERNAME=$(echo $SECRET_JSON | jq -r '.username')
DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')

# Set environment variables for the app
cat > /etc/environment <<ENV
DB_HOST=${db_endpoint}
DB_USER=$DB_USERNAME
DB_PASS=$DB_PASSWORD
DB_NAME=${db_name}
PORT=80
ENV

cat > /etc/systemd/system/todo-app.service <<'SVC'
[Unit]
Description=Todo App
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/todo-app
EnvironmentFile=/etc/environment
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
SVC

systemctl daemon-reload
systemctl enable todo-app
systemctl start todo-app
