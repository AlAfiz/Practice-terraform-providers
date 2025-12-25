terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

#IAM Role for Elastic Beanstalk EC2 instances
resource "aws_iam_role" "eb_ec2_role" {
  name = "${var.app_name}-eb-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

#attach the aws managed policy for web tier
resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  policy_arn         = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  role               = aws_iam_role.eb_ec2_role.name
}

#Attach the AWS managed policy for Multicontainer Docker
resource "aws_iam_role_policy_attachment" "eb_multicontainer_docker" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
  role       = aws_iam_role.eb_ec2_role.name
}

#Instance Profile
resource "aws_iam_instance_profile" "eb_ec2_profile" {
  name = "${var.app_name}-eb-ec2-profile"
  role = aws_iam_role.eb_ec2_role.name

  tags = var.tags
}

#IAM Role for Elastic Beanstalk Service
resource "aws_iam_role" "eb_service_role" {
  name = "${var.app_name}-eb-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

#Attach Core Service Role Policy
resource "aws_iam_role_policy_attachment" "eb_service_main" {
  policy_arn         = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
  role               = aws_iam_role.eb_service_role.name
}

#Attach Enhanced Health Reporting policy
resource "aws_iam_role_policy_attachment" "eb_service_health" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
  role       = aws_iam_role.eb_ec2_role.name
}

#Attach Managed updates policy
resource "aws_iam_role_policy_attachment" "eb_service_managed_updates" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
  role       = aws_iam_role.eb_ec2_role.name
}

#Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "app" {
  name = var.app_name
  description = "Blue-Green Deployment Demo Application"

  tags = var.tags
}

#S3 Bucket for application versions
resource "aws_s3_bucket" "app_versions" {
   bucket = "${var.app_name}-versions-${data.aws_caller_identity.current.account_id}"

  tags = var.tags
}

#Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "app_versions" {
  bucket = aws_s3_bucket.app_versions.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#Data source for current AWS account
data "aws_caller_identity" "current" {}