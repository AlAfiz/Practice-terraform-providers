terraform {
  backend "s3" {
    bucket = "devopswithzacks-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "channel_name" {
  default = "dwz"
}

locals {
  bucket_name = "${var.channel_name}-bucket-${var.environment}-${var.region}"
  vpc_name = "${var.environment}-VPC"
}

variable "region" {
  default = "us-east-1"
}
# Create s3 bucket
resource "aws_s3_bucket" "first_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

# Create a vpc
resource "aws_vpc" "sample" {
  cidr_block = "10.0.1.0/24"
  region = var.region
  tags = {
    Environment = var.environment
    Name = local.vpc_name
  }
}

resource "aws_instance" "example" {
  ami = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"
  region = var.region
  tags = {
    Environment = var.environment
    Name = "${var.environment}-EC2-Instance"
  }
}
output "vpc_id" {
  value = aws_vpc.sample.id
}
output "ec2_id" {
  value = aws_instance.example.id
}
