# Data Element to fetch the latest AMI ID
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


locals {
  name-suffix = "${var.environment}-${var.region}"
}


# Security Groups with ingress and egress rules
module "http_sg_ingress" {
  source = "./modules/securitygroup"

  sg_name        = "http_sg_ingress"
  sg_description = "Allow Port 80 from anywhere"
  environment    = var.environment
  type           = "ingress"
  from_port      = 80
  to_port        = 80
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]
}

module "generic_sg_egress" {
  source = "./modules/securitygroup"

  sg_name        = "generic_sg_egress"
  sg_description = "Allow Server to connect to outbound internet"
  environment    = var.environment
  type           = "egress"
  from_port      = 0
  to_port        = 65535
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]
}

module "ssh_sh_ingress" {
  source = "./modules/securitygroup"

  sg_name        = "ssh_sh_ingress"
  sg_description = "Allow Port 22 from anywhere"
  environment    = var.environment
  type           = "ingress"
  from_port      = 22
  to_port        = 22
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]
}

# AWS EC2 Resource creation
resource "aws_instance" "apache2_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.http_sg_ingress.sg_id, module.generic_sg_egress.sg_id, module.ssh_sh_ingress.sg_id]
  user_data              = file("./scripts/user_data.sh")
  tags = {
    "env"  = var.environment
    "Name" = "ec2-${local.name-suffix}"
  }
}


