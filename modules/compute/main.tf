locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Launch Template for EC2 (t3.micro only)
resource "aws_launch_template" "app" {
  name_prefix            = "3tier-app-lt-"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  
  user_data = base64encode(<<-EOF
#!/bin/bash
apt-get update -y
apt-get install -y nodejs npm git awscli jq

# Clone the application from GitHub
git clone https://github.com/AbrahamGyamfi/Todo-APP.git /var/www/todo-app
cd /var/www/todo-app

# Install dependencies
npm install

# Fetch secrets from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${var.secret_name} --region ${var.aws_region} --query SecretString --output text)
DB_USERNAME=$(echo $SECRET_JSON | jq -r '.username')
DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')

# Set environment variables for the app
cat > /etc/environment <<ENV
DB_HOST=${var.db_endpoint}
DB_USER=$DB_USERNAME
DB_PASS=$DB_PASSWORD
DB_NAME=${var.db_name}
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
EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "3tier-app-instance"
    }, local.common_tags)
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "3tier-app-asg"
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = var.target_group_arns
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "3tier-app-instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_launch_template.app]
}