terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Configure the AWS Provider
}
provider "aws" {
  region = var.prod_A
  alias = "prod"
}
provider "aws" {
  region = var.test_B
  alias = "test"
}
provider "aws" {
  region = var.dev_C
  alias = "dev"
}