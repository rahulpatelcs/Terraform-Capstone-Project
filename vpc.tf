########################################
# VPC
########################################

resource "aws_vpc" "neuefische-vpc" {
  cidr_block           = var.vpc_cidr # 10.0.0.0/16
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "neuefische-vpc"
  }
}

########################################
# Internet Gateway
########################################

resource "aws_internet_gateway" "neuefische-igw" {
  vpc_id = aws_vpc.neuefische-vpc.id

  tags = {
    Name = "neuefische-igw"
  }
}

########################################
# PUBLIC SUBNETS
########################################

# us-west-2a
resource "aws_subnet" "neuefische-public-1" {
  vpc_id                  = aws_vpc.neuefische-vpc.id
  cidr_block              = var.public_subnets[0] # 10.0.1.0/24
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "neuefische-public-1"
  }
}

# us-west-2b
resource "aws_subnet" "neuefische-public-2" {
  vpc_id                  = aws_vpc.neuefische-vpc.id
  cidr_block              = var.public_subnets[1] # 10.0.2.0/24
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "neuefische-public-2"
  }
}

########################################
# PRIVATE SUBNETS
########################################

# us-west-2a
resource "aws_subnet" "neuefische-private-1" {
  vpc_id            = aws_vpc.neuefische-vpc.id
  cidr_block        = var.private_subnets[0] # 10.0.3.0/24
  availability_zone = "us-west-2a"

  tags = {
    Name = "neuefische-private-1"
  }
}

# us-west-2b
resource "aws_subnet" "neuefische-private-2" {
  vpc_id            = aws_vpc.neuefische-vpc.id
  cidr_block        = var.private_subnets[1] # 10.0.4.0/24
  availability_zone = "us-west-2b"

  tags = {
    Name = "neuefische-private-2"
  }
}

########################################
# NAT GATEWAY
########################################

resource "aws_eip" "neuefische-eip" {
  depends_on = [aws_internet_gateway.neuefische-igw]
  domain     = "vpc"

  tags = {
    Name = "neuefische-eip"
  }
}

resource "aws_nat_gateway" "neuefische-nat" {
  allocation_id = aws_eip.neuefische-eip.id
  subnet_id     = aws_subnet.neuefische-public-1.id # Launch NAT in us-west-2a

  tags = {
    Name = "neuefische-nat"
  }
}

########################################
# ROUTE TABLES
########################################

# Public Route Table
resource "aws_route_table" "neuefische-public-rt" {
  vpc_id = aws_vpc.neuefische-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.neuefische-igw.id
  }

  tags = {
    Name = "neuefische-public-rt"
  }
}

# Associate Public Subnets
resource "aws_route_table_association" "neuefische-public-1-rt-assoc" {
  subnet_id      = aws_subnet.neuefische-public-1.id
  route_table_id = aws_route_table.neuefische-public-rt.id
}

resource "aws_route_table_association" "neuefische-public-2-rt-assoc" {
  subnet_id      = aws_subnet.neuefische-public-2.id
  route_table_id = aws_route_table.neuefische-public-rt.id
}

# Private Route Table
resource "aws_route_table" "neuefische-private_rt" {
  vpc_id = aws_vpc.neuefische-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.neuefische-nat.id
  }

  tags = {
    Name = "neuefische-private_rt"
  }
}

# Associate Private Subnets
resource "aws_route_table_association" "neuefische-private-1-rt-assoc" {
  subnet_id      = aws_subnet.neuefische-private-1.id
  route_table_id = aws_route_table.neuefische-private_rt.id
}

resource "aws_route_table_association" "neuefische-private-2-rt-assoc" {
  subnet_id      = aws_subnet.neuefische-private-2.id
  route_table_id = aws_route_table.neuefische-private_rt.id
}
