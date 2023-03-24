# Setting and locking the Dependencies

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10"
    }
  }

  required_version = ">= 1.1.0"
}


variable "environment" {
  description = "The environment e.g. dev, uat, prod"
  type        = string
}

variable "region" {
  description = "The region e.g. us-east-1, us-west-1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type e.g. t2.micro, t2.small, t2.medium"
  type        = string
}

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
# AWS Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Security Groups with ingress and egress rules

resource "aws_security_group" "public_http_sg" {
  name = "public_http_sg-${local.name-suffix}"

  # Allow on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment" = var.environment
    "visibility"  = "public"
  }
}

# AWS EC2 Resource creation
resource "aws_instance" "apache2_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.public_http_sg.id]
  user_data              = file("user_data.sh")
  tags = {
    "env"  = var.environment
    "Name" = "ec2-${local.name-suffix}"
  }
}

# Outputs

output "public_ip" {
  value = aws_instance.apache2_server.public_ip
}


