########################################
# Application Load Balancer
########################################

resource "aws_lb" "neuefische-alb" {
  name               = "neuefische-alb"
  load_balancer_type = "application"
  internal           = false # internet-facing

  # ALB lives in the public subnets
  subnets = [
    aws_subnet.neuefische-public-1.id,
    aws_subnet.neuefische-public-2.id
  ]

  security_groups = [
    aws_security_group.neuefische_sg_alb.id
  ]

  tags = {
    Name = "neuefische-alb"
  }
}

########################################
# Target Group (for WordPress EC2 ASG)
########################################

resource "aws_lb_target_group" "neuefische-alb-tg" {
  name        = "neuefische-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.neuefische-vpc.id

  # Launchtemplate creates this path /var/www/html/health
  health_check {
    enabled             = true
    port                = 80
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30 # not so aggressive
    timeout             = 10 # not so aggressive
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "neuefische-alb-tg"
  }
}

########################################
# HTTP Listener (Port 80)
########################################

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.neuefische-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.neuefische-alb-tg.arn
  }
}

/*
########################################
# HTTPS Listener (Port 443)
########################################

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.neuefische-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

 # certificate_arn   = "arn:aws:acm:us-west-2:XXXX:certificate/XXXX"  # 👈 ADD THIS

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.neuefische-alb-tg.arn
  }
}

########################################
# HTTP Listener (Port 80 -> Redirect to HTTPS)
########################################

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.neuefische-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
*/