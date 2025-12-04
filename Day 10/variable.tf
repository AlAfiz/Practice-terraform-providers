  #General Variables
  /*variable "aws_region" {
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
  }*/
  variable "environment" {
    type    = string
    default = "dev"
  }
  variable "instance_count" {
    description = "Number of EC2 instances to create"
    type        = number
  }
  variable "region" {
    type    = string
    default = "us-east-1"
  }
  variable "monitoring_enabled" {
    description = "Enable detailed monitoring for EC2 instances"
    type        = bool
    default     = true
  }
  variable "associate_public_ip" {
    description = "Associate public IP address with EC2 instance"
    type        = bool
    default     = true
  }
  variable "cidr_block" {
    description = "CIDR block for the VPC"
    type        = list(string)
    default     = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }
  variable "allowed_vm_type" {
    description = "List of allowed VM types"
    type        = list(string)
    default     = ["t2.micro", "t2.small", "t3.micro", "t3.small"]
  }
  variable "allowed_region" {
    description = "List of allowed AWS regions"
    type        = set(string)
    default     = ["us-east-1", "us-west-2", "eu-west-1"]
  }
  variable "ingress_values" {
    type    = tuple([number, string, number])
    default = [443, "tcp", 443]
  }
  variable "config" {
    type = object({
      region         = string,
      monitoring     = bool,
      instance_count = number
    })
    default = {
      region         = "us-east-1",
      monitoring     = true,
      instance_count = 1
    }
  }*/
  variable "environment" {
    type    = string
    default = "dev"
  }
  variable "instance_count" {
    description = "Number of EC2 instances to create"
    type        = number
  }
  variable "tags" {
    type = map(string)
    default = {
      Environment = "dev"
      Name        = "dev-Instance"
    }
  }
  variable "ingress_rules" {
    description = "List of ingress rules for security group"
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
  {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "HTTP"
  }
    ]
  }