resource "aws_security_group" "alb" {
  name        = "technova-aula11-alb"
  description = "Public HTTP access to the TechNova canary load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_lb" "api" {
  name               = "technova-aula11-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = var.tags
}

resource "aws_lb_target_group" "stable" {
  name        = "technova-stable"
  port        = var.instance_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_target_group" "canary" {
  name        = "technova-canary"
  port        = var.instance_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "stable" {
  target_group_arn = aws_lb_target_group.stable.arn
  target_id        = var.stable_instance_id
  port             = var.instance_port
}

resource "aws_lb_target_group_attachment" "canary" {
  target_group_arn = aws_lb_target_group.canary.arn
  target_id        = var.canary_instance_id
  port             = var.instance_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      stickiness {
        enabled  = true
        duration = 300
      }

      target_group {
        arn    = aws_lb_target_group.stable.arn
        weight = var.stable_weight
      }

      target_group {
        arn    = aws_lb_target_group.canary.arn
        weight = var.canary_weight
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.stable_weight + var.canary_weight == 100
      error_message = "stable_weight and canary_weight must add up to 100."
    }
  }
}
