########################################
# WEB SERVER SECURITY GROUP
########################################

resource "aws_security_group" "neuefische_sg_web" {
  name        = "neuefische-sg-web"
  description = "Allow HTTP from ALB and SSH from Bastion"
  vpc_id      = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische-sg-web"
  }
}

# HTTP from ALB
resource "aws_vpc_security_group_ingress_rule" "neuefische-sg_web_http_from_alb" {
  security_group_id            = aws_security_group.neuefische_sg_web.id
  referenced_security_group_id = aws_security_group.neuefische_sg_alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# HTTPS from ALB
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_web_https_from_alb" {
  security_group_id            = aws_security_group.neuefische_sg_web.id
  referenced_security_group_id = aws_security_group.neuefische_sg_alb.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# SSH from Bastion
resource "aws_vpc_security_group_ingress_rule" "neuefische_web_ssh_from_bastion" {
  security_group_id            = aws_security_group.neuefische_sg_web.id
  referenced_security_group_id = aws_security_group.neuefische_sg_bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# NFS to EFS
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_web_nfs_to_efs" {
  security_group_id            = aws_security_group.neuefische_sg_web.id
  referenced_security_group_id = aws_security_group.neuefische_sg_efs.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}


# Outbound all IPv4
resource "aws_vpc_security_group_egress_rule" "neuefische_sg_web_allow_all_ipv4" {
  security_group_id = aws_security_group.neuefische_sg_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


########################################
# ALB SECURITY GROUP
########################################

resource "aws_security_group" "neuefische_sg_alb" {
  name        = "neuefische_sg_alb"
  description = "Allow HTTP from internet"
  vpc_id      = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische_sg-alb"
  }
}

# HTTP from internet
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_alb_http_anywhere" {
  security_group_id = aws_security_group.neuefische_sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_alb_https_anywhere" {
  security_group_id = aws_security_group.neuefische_sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Outbound all
resource "aws_vpc_security_group_egress_rule" "neuefische_sg_alb_allow_all_ipv4" {
  security_group_id = aws_security_group.neuefische_sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


########################################
# BASTION SECURITY GROUP
########################################

resource "aws_security_group" "neuefische_sg_bastion" {
  name        = "neuefische_sg-bastion"
  description = "SSH access to Bastion Host"
  vpc_id      = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische_sg-bastion"
  }
}

# SSH from anywhere (lab mode)
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_bastion_ssh_anywhere" {
  security_group_id = aws_security_group.neuefische_sg_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Outbound all
resource "aws_vpc_security_group_egress_rule" "neuefische_sg_bastion_allow_all_ipv4" {
  security_group_id = aws_security_group.neuefische_sg_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


########################################
# RDS SECURITY GROUP
########################################

resource "aws_security_group" "neuefische_sg_rds" {
  name        = "neuefische_sg-rds"
  description = "Allow MySQL from Webserver SG"
  vpc_id      = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische_sg-rds"
  }
}

# Allow MySQL from Web instances
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_rds_mysql_from_web" {
  security_group_id            = aws_security_group.neuefische_sg_rds.id
  referenced_security_group_id = aws_security_group.neuefische_sg_web.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

# Outbound all
resource "aws_vpc_security_group_egress_rule" "neuefische_sg_rds_allow_all_ipv4" {
  security_group_id = aws_security_group.neuefische_sg_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


########################################
# EFS SECURITY GROUP
########################################

resource "aws_security_group" "neuefische_sg_efs" {
  name        = "neuefische_sg-efs"
  description = "Allow NFS access from Webservers"
  vpc_id      = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische_sg-efs"
  }
}

# NFS from Web
resource "aws_vpc_security_group_ingress_rule" "neuefische_sg_efs_nfs_from_web" {
  security_group_id            = aws_security_group.neuefische_sg_efs.id
  referenced_security_group_id = aws_security_group.neuefische_sg_web.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}

# Outbound all
resource "aws_vpc_security_group_egress_rule" "neuefische_sg_efs_allow_all_ipv4" {
  security_group_id = aws_security_group.neuefische_sg_efs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
