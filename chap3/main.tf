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

# AWS Provider configuration
provider "aws" {
  region = "us-east-1"
}

# AWS EC2 Resource creation
resource "aws_instance" "apache2_servef" {
  ami           = "ami-0fd2c44049dd805b8"
  instance_type = "t2.micro"
  user_data     = file("user_data.sh")
  tags = {
    "env" = "dev"
  }
}
