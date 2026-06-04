########################################
# Launch Template for WordPress EC2
########################################

resource "aws_launch_template" "neuefischelt" {
  depends_on = [
    aws_efs_file_system.neuefische-efs,
    aws_secretsmanager_secret_version.db_creds_update,
    aws_db_instance.neuefische-rds
  ]

  name_prefix   = "neuefischelt-"
  key_name      = var.key_name
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.neuefische_instance_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.neuefische_sg_web.id]
  }

  # Load User Data from file (base64 required by AWS)
  user_data = base64encode(templatefile("${path.module}/LaunchTemplateUserData.sh", {
    efs_id    = aws_efs_file_system.neuefische-efs.id
    efs_ap_id = aws_efs_access_point.neuefische_efs_ap.id
    alb_dns   = aws_lb.neuefische-alb.dns_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "neuefische-web"
    }
  }

  tags = {
    Name = "neuefischelt"
  }
}

########################################
# Auto Scaling Group
########################################

resource "aws_autoscaling_group" "neuefische-asg" {

  name             = "neuefische-asg"
  desired_capacity = 1 # 2 for production
  max_size         = 3 # 4 for production
  min_size         = 1 # 2 for production

  vpc_zone_identifier = [
    aws_subnet.neuefische-private-1.id,
    aws_subnet.neuefische-private-2.id
  ]

  target_group_arns = [
    aws_lb_target_group.neuefische-alb-tg.arn
  ]

  # Crucial: allows WordPress to fully boot before ALB health checks apply
  health_check_type         = "ELB"
  health_check_grace_period = 600 # long period for WordPress setup

  launch_template {
    id      = aws_launch_template.neuefischelt.id
    version = "$Latest"
  }

  # Make sure ALB listener exists first
  depends_on = [
    aws_lb_listener.http_listener,
    #aws_lb_listener.https_listener,
    #aws_lb_listener.http_redirect
  ]

  # Propagate Name tag to all instances
  tag {
    key                 = "Name"
    value               = "neuefische-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
