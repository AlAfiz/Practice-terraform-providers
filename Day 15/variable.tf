variable "prod_A" {
  description = "Production AWS region for the first VPC"
  type = string
  default = "us-east-1"
}

variable "test_B" {
  description = "Testing AWS region for the first VPC"
  type = string
  default = "us-west-2"
}

variable "dev_C" {
  description = "Development AWS region for the first VPC"
  type = string
  default = "eu-west-2"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for production region"
  type = string
  default = "10.0.0.0/16"
}

variable "test_vpc_cidr" {
  description = "CIDR block for testing region"
  type = string
  default = "10.1.0.0/16"
}

variable "dev_vpc_cidr" {
  description = "CIDR block for development region"
  type = string
  default = "10.2.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}

variable "Environment" {
  description = "Environment declared for tags"
  type = string
  default = "Demo"
}

variable "prod_key_name" {
  description = "Name of the SSH key pair for production VPC instance (us-east-1)"
  type = string
  default = ""
}

variable "test_key_name" {
  description = "Name of the SSH key pair for testing VPC instance (us-west-2)"
  type = string
  default = ""
}

variable "dev_key_name" {
  description = "Name of the SSH key pair for development VPC instance (us-west-2)"
  type = string
  default = ""
}

variable "cidr_block" {
  type = string
  default = "0.0.0.0/0"
}