 #Prod VPC in us-east-1
 resource "aws_vpc" "prod_vpc" {
   provider = aws.prod
   cidr_block = var.prod_vpc_cidr
   enable_dns_hostnames = true
   enable_dns_support = true

   tags = {
     Name = "Production-VPC-${var.prod_A}"
     Environment = var.Environment
     Purpose = "VPC-Peering-Demo"
   }
 }

 #test VPC in us-west-2
 resource "aws_vpc" "test_vpc" {
   provider = aws.test
   cidr_block = var.test_vpc_cidr
   enable_dns_hostnames = true
   enable_dns_support = true

   tags = {
     Name = "Testing-VPC-${var.test_B}"
     Environment = var.Environment
     Purpose = "VPC-Peering-Demo"
   }
 }

 #dev VPC in eu-west-2
 resource "aws_vpc" "dev_vpc" {
   provider = aws.dev
   cidr_block = var.dev_vpc_cidr
   enable_dns_hostnames = true
   enable_dns_support = true

   tags = {
     Name = "Development-VPC-${var.dev_C}"
     Environment = var.Environment
     Purpose = "VPC-Peering-Demo"
   }
 }

 #subnet in production vpc
 resource "aws_subnet" "prod_subnet" {
   provider = aws.prod
   vpc_id = aws_vpc.prod_vpc.id
   cidr_block = var.prod_vpc_cidr
   availability_zone = data.aws_availability_zones.prod.names[0]
   map_public_ip_on_launch = true

   tags = {
     Name = "Production-Subnet-${var.prod_A}"
     Environment = var.Environment
   }
 }

 #subnet in testing vpc
 resource "aws_subnet" "test_subnet" {
   provider = aws.test
   vpc_id = aws_vpc.test_vpc.id
   cidr_block = var.test_vpc_cidr
   availability_zone = data.aws_availability_zones.testing.names[0]
   map_public_ip_on_launch = true

   tags = {
     Name = "Testing-Subnet-${var.test_B}"
     Environment = var.Environment
   }
 }

 #subnet in dev vpc
 resource "aws_subnet" "dev_subnet" {
   provider = aws.dev
   vpc_id = aws_vpc.dev_vpc.id
   cidr_block = var.dev_vpc_cidr
   availability_zone = data.aws_availability_zones.dev.names[0]
   map_public_ip_on_launch = true

   tags = {
     Name = "Development-Subnet-${var.dev_C}"
     Environment = var.Environment
   }
 }

 #Internet Gateway for production VPC
 resource "aws_internet_gateway" "prod_igw" {
   provider = aws.prod
   vpc_id = aws_vpc.prod_vpc.id

   tags = {
     Name = "Production-IGW"
     Environment = var.Environment
   }
 }

 #Internet Gateway for testing VPC
 resource "aws_internet_gateway" "test_igw" {
   provider = aws.test
   vpc_id = aws_vpc.test_vpc.id

   tags = {
     Name = "Testing-IGW"
     Environment = var.Environment
   }
 }

 #Internet Gateway for dev VPC
 resource "aws_internet_gateway" "dev_igw" {
   provider = aws.dev
   vpc_id = aws_vpc.dev_vpc.id

   tags = {
     Name = " Dev-IGW"
     Environment = var.Environment
   }
 }

 #Route table for Production VPC
 resource "aws_route_table" "prod_rt" {
   provider = aws.prod
   vpc_id = aws_vpc.prod_vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.prod_igw.id
   }
   tags = {
     Name = "Production-Route-Table"
     Environment = var.Environment
   }
 }

 #Route table for Testing VPC
 resource "aws_route_table" "test_rt" {
   provider = aws.test
   vpc_id = aws_vpc.test_vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.test_igw.id
   }
   tags = {
     Name = "Testing-Route-Table"
     Environment = var.Environment
   }
 }

 #Route table for Dev VPC
 resource "aws_route_table" "dev_rt" {
   provider = aws.dev
   vpc_id = aws_vpc.dev_vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.dev_igw.id
   }
   tags = {
     Name = "Dev-Route-Table"
     Environment = var.Environment
   }
 }

 #Associate route table with Production subnet
 resource "aws_route_table_association" "prod_rta" {
   provider = aws.prod
   subnet_id = aws_subnet.prod_subnet.id
   route_table_id = aws_route_table.prod_rt.id
 }

 #Associate route table with Testing subnet
 resource "aws_route_table_association" "test_rta" {
   provider = aws.test
   subnet_id = aws_subnet.test_subnet.id
   route_table_id = aws_route_table.test_rt.id
 }

 #Associate route table with Dev subnet
 resource "aws_route_table_association" "dev_rta" {
   provider = aws.dev
   subnet_id = aws_subnet.dev_subnet.id
   route_table_id = aws_route_table.dev_rt.id
 }

 #VPC Peering Connection (Requester side - Production VPC)
 resource "aws_vpc_peering_connection" "production_to_testing" {
   provider = aws.prod
   peer_vpc_id = aws_vpc.test_vpc.id
   vpc_id      = aws_vpc.prod_vpc.id
   peer_region = var.test_B
   auto_accept = false

   tags = {
     Name = "Production-to-Testing-Peering"
     Environment = var.Environment
     Side = "Requester"
   }
 }

 #VPC Peering Connection Accepter (Accepter side - Testing VPC)
 resource "aws_vpc_peering_connection_accepter" "testing_to_production" {
   provider = aws.test
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_testing.id
   auto_accept = true

   tags = {
     Name = "Testing-Peering-Accepter"
     Environment = var.Environment
     Side = "Accepter"
   }
 }

 #VPC Peering Connection (Requester side - Production VPC)
 resource "aws_vpc_peering_connection" "production_to_dev" {
   provider = aws.prod
   peer_vpc_id = aws_vpc.dev_vpc.id
   vpc_id      = aws_vpc.prod_vpc.id
   peer_region = var.dev_C
   auto_accept = false

   tags = {
     Name = "Production-to-Dev-Peering"
     Environment = var.Environment
     Side = "Requester"
   }
 }

 #VPC Peering Connection Accepter (Accepter side - dev VPC)
 resource "aws_vpc_peering_connection_accepter" "production_to_dev" {
   provider = aws.dev
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_dev.id
   auto_accept = true

   tags = {
     Name = "Dev-Peering-Accepter"
     Environment = var.Environment
     Side = "Accepter"
   }
 }

 #VPC Peering Connection (Requester side - test VPC)
 resource "aws_vpc_peering_connection" "test_to_dev" {
   provider = aws.test
   peer_vpc_id = aws_vpc.dev_vpc.id
   vpc_id      = aws_vpc.test_vpc.id
   peer_region = var.dev_C
   auto_accept = false

   tags = {
     Name = "Testing-to-Dev-Peering"
     Environment = var.Environment
     Side = "Requester"
   }
 }

 #VPC Peering Connection Accepter (Accepter side - dev VPC)
 resource "aws_vpc_peering_connection_accepter" "test_to_dev" {
   provider = aws.dev
   vpc_peering_connection_id = aws_vpc_peering_connection.test_to_dev.id
   auto_accept = true

   tags = {
     Name = "Dev-Peering-Accepter"
     Environment = var.Environment
     Side = "Accepter"
   }
 }

 #Add route to test VPC in prod
 resource "aws_route" "prod_to_test" {
   provider = aws.prod
   route_table_id = aws_route_table.prod_rt.id
   destination_cidr_block = var.test_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_testing.id

   depends_on = [aws_vpc_peering_connection_accepter.testing_to_production]
 }

 #Add route to prod VPC in test
 resource "aws_route" "test_to_prod" {
   provider = aws.test
   route_table_id = aws_route_table.test_rt.id
   destination_cidr_block = var.prod_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_testing.id

   depends_on = [aws_vpc_peering_connection_accepter.testing_to_production]
 }

 #Add route to dev VPC in prod
 resource "aws_route" "prod_to_dev" {
   provider = aws.prod
   route_table_id = aws_route_table.prod_rt.id
   destination_cidr_block = var.dev_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_dev.id

   depends_on = [aws_vpc_peering_connection_accepter.production_to_dev]
 }

 #Add route to prod VPC in dev
 resource "aws_route" "dev_to_prod" {
   provider = aws.dev
   route_table_id = aws_route_table.dev_rt.id
   destination_cidr_block = var.prod_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.production_to_dev.id

   depends_on = [aws_vpc_peering_connection_accepter.production_to_dev]
 }

 #Add route to dev VPC in test
 resource "aws_route" "test_to_dev" {
   provider = aws.test
   route_table_id = aws_route_table.test_rt.id
   destination_cidr_block = var.dev_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.test_to_dev.id

   depends_on = [aws_vpc_peering_connection_accepter.test_to_dev]
 }

 #Add route to test VPC in dev
 resource "aws_route" "dev_to_test" {
   provider = aws.dev
   route_table_id = aws_route_table.dev_rt.id
   destination_cidr_block = var.test_vpc_cidr
   vpc_peering_connection_id = aws_vpc_peering_connection.test_to_dev.id

   depends_on = [aws_vpc_peering_connection_accepter.test_to_dev]
 }

 #Security Group for Prod VPC EC2 instance
 resource "aws_security_group" "production_sg" {
   provider = aws.prod
   name = "production-vpc-sg"
   description = "Security group for production VPC instance"
   vpc_id = aws_vpc.prod_vpc.id

   #SSH from anywhere VPC
   ingress {
     description = "SSH from Internet"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   #SSH from Test and Dev VPC
   ingress {
     description = "SSH from Test and Dev VPC"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = [
       var.test_vpc_cidr,
       var.dev_vpc_cidr
     ]
   }
   ingress {
     description = "ICMP from Test and Dev VPCs"
     from_port = -1
     to_port = -1
     protocol = "icmp"
     cidr_blocks = [
       var.test_vpc_cidr,
       var.dev_vpc_cidr]
   }
   egress {
     description = "Allow all outbound traffic"
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "Production-VPC-Sg"
     Environment = var.Environment
   }
 }

 #Security Group for test VPC EC2 instance
 resource "aws_security_group" "testing_sg" {
   provider = aws.test
   name = "testing-vpc-sg"
   description = "Security group for testing VPC instance"
   vpc_id = aws_vpc.test_vpc.id

   #SSH from anywhere VPC
   ingress {
     description = "SSH from Internet"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   #SSH from Prod and Dev VPC
   ingress {
     description = "SSH from Prod and Dev VPC"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = [
       var.prod_vpc_cidr,
       var.dev_vpc_cidr
     ]
   }

   ingress {
     description = "ICMP from Prod and Dev VPCs"
     from_port = -1
     to_port = -1
     protocol = "icmp"
     cidr_blocks = [
       var.prod_vpc_cidr,
       var.dev_vpc_cidr]
   }
   egress {
     description = "Allow all outbound traffic"
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "Testing-VPC-Sg"
     Environment = var.Environment
   }
 }

 #Security Group for Dev VPC EC2 instance
 resource "aws_security_group" "development_sg" {
   provider = aws.dev
   name = "development-vpc-sg"
   description = "Security group for development VPC instance"
   vpc_id = aws_vpc.dev_vpc.id

   #SSH from anywhere VPC
   ingress {
     description = "SSH from Internet"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   #SSH from Prod and Test VPC
   ingress {
     description = "SSH from Prod and Test VPC"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = [
       var.prod_vpc_cidr,
       var.test_vpc_cidr
     ]
   }

   ingress {
     description = "ICMP from Test and Prod VPCs"
     from_port = -1
     to_port = -1
     protocol = "icmp"
     cidr_blocks = [
       var.test_vpc_cidr,
       var.prod_vpc_cidr]
   }
   egress {
     description = "Allow all outbound traffic"
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "Development-VPC-Sg"
     Environment = var.Environment
   }
 }

 #EC2 Instance in Production VPC
 resource "aws_instance" "production_instance" {
   provider = aws.prod
   ami = data.aws_ami.prod_ami.id
   instance_type = var.instance_type
   subnet_id = aws_subnet.prod_subnet.id
   vpc_security_group_ids = [aws_security_group.production_sg.id]
   key_name = var.prod_key_name

   user_data = local.prod_user_data

   tags = {
     Name = "Production-VPC-Instance"
     Environment = var.Environment
     Region = var.prod_A
   }
   depends_on = [aws_vpc_peering_connection_accepter.testing_to_production]
 }

 #EC2 Instance in Testing VPC
 resource "aws_instance" "testing_instance" {
   provider = aws.test
   ami = data.aws_ami.test_ami.id
   instance_type = var.instance_type
   subnet_id = aws_subnet.test_subnet.id
   vpc_security_group_ids = [aws_security_group.testing_sg.id]
   key_name = var.test_key_name

   user_data = local.test_user_data

   tags = {
     Name = "Testing-VPC-Instance"
     Environment = var.Environment
     Region = var.test_B
   }
   depends_on = [
     aws_vpc_peering_connection_accepter.testing_to_production,
     aws_vpc_peering_connection_accepter.test_to_dev
   ]
 }

 #EC2 Instance in Development VPC
 resource "aws_instance" "development_instance" {
   provider = aws.dev
   ami = data.aws_ami.dev_ami.id
   instance_type = var.instance_type
   subnet_id = aws_subnet.dev_subnet.id
   vpc_security_group_ids = [aws_security_group.development_sg.id]
   key_name = var.dev_key_name

   user_data = local.dev_user_data

   tags = {
     Name = "Development-VPC-Instance"
     Environment = var.Environment
     Region = var.dev_C
   }
   depends_on = [
     aws_vpc_peering_connection_accepter.production_to_dev,
     aws_vpc_peering_connection_accepter.test_to_dev
   ]
 }