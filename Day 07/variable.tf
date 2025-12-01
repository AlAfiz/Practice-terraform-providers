variable "environment" {
  type = string
  default = "dev"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type = number
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "monitoring_enabled" {
  description = "Enable detailed monitoring for EC2 instances"
  type = bool
  default = true
}
variable "associate_public_ip" {
  description = "Associate public IP address with EC2 instance"
  type = bool
  default = true
}
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type = list(string)
  default = ["10.0.0.0/8","192.168.0.0/16", "172.16.0.0/12"]
}
variable "allowed_vm_type" {
  description = "List of allowed VM types"
  type = list(string)
  default = ["t2.micro", "t2.small","t3.micro", "t3.small"]
}
variable "allowed_region" {
  description = "List of allowed AWS regions"
  type = set(string)
  default = ["us-east-1","us-west-2","eu-west-1"]
}

variable "tags" {
  type = map(string)
  default = {
      Environment = "dev"
      Name        = "dev-Instance"
    }
  }
variable "ingress_values" {
  type = tuple([ number,string,number ])
  default = [ 443,"tcp",443 ]
}
variable "config" {
  type = object({
    region = string,
    monitoring = bool,
    instance_count = number
  })
  default = {
    region = "us-east-1",
    monitoring = true,
    instance_count = 1
  }
}