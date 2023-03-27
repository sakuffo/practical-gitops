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
