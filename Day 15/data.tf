#data source to get available AZ's in Production Region
data "aws_availability_zones" "prod" {
  provider = aws.prod
  state = "available"
}

#data source to get available AZ's in Testing Region
data "aws_availability_zones" "testing" {
  provider = aws.test
  state = "available"
}

#data source to get available AZ's in Development Region
data "aws_availability_zones" "dev" {
  provider = aws.dev
  state = "available"
}

#data source for Production region AMI (Ubuntu 24.04 LTS)
data "aws_ami" "prod_ami" {
  provider = aws.prod
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

#data source for Testing region AMI (Ubuntu 24.04 LTS)
data "aws_ami" "test_ami" {
  provider = aws.test
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

#data source for Development region AMI (Ubuntu 24.04 LTS)
data "aws_ami" "dev_ami" {
  provider = aws.dev
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}