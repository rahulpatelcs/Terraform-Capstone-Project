region          = "us-west-2"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
db_secret_name  = "wpsecrets"
key_name        = "your-ec2-key-pair"
