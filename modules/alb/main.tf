# ALB Module: main.tf

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_lb" "Abraham" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.web_sg_id]
  tags = merge({
    Name = var.alb_name
  }, local.common_tags)
}

resource "aws_lb_target_group" "Abraham" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = merge({
    Name = var.target_group_name
  }, local.common_tags)
}

resource "aws_lb_listener" "Abraham" {
  load_balancer_arn = aws_lb.Abraham.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Abraham.arn
  }
}

# Target attachment is done in root or compute module for flexibility
