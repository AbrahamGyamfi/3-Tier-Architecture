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
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>3-Tier App - Instance $(hostname -f)</h1>" > /var/www/html/index.html
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