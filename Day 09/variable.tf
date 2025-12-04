  #General Variables
  variable "aws_region" {
    description = "AWS region for resources"
    type = string
    default = "us-east-1"
  }
  variable "environment" {
    description = "Environment name (dev, staging, prod)"
    type = string
    default = "dev"
  }
  #S3 Bucket Variables
  variable "bucket_names" {
    description = "Set of S3 bucket names to create"
    type = set(string)
    default = ["demo-lifecycle-bucket-001", "demo-lifecycle-bucket-002"]
  }
  variable "allowed_regions" {
    description = "List of allowed regions"
    type = list(string)
    default = ["us-east-1", "us-west-2", "eu-wast-1", "ap-south-1"]
  }
  #EC2 Variables
  variable "instance_type" {
    description = "EC2 Instance type"
    type = string
    default = "t2.micro"
  }
  variable "instance_name" {
    description = "Name of tags for EC2 instance"
    type = string
    default = "lifecycle-demo-instance"
  }
