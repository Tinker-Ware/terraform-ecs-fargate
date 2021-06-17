##Create VPC with public and private subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "public_1" {
  count                   = 1
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  count                   = 1
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]

  tags = {
    Name = "${var.cluster_name} public subnet group"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id 
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


##Create Nat gateway
#create elastic ip for nat gateway
resource "aws_eip" "eip_nat" {
  vpc      = true
}

#place NAT gateway inside a public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_1[0].id   
}

#update route table for private subnets
#for Destination 0.0.0.0/0
#for Target the id of the nat gateway

resource "aws_route_table" "rt_private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id

  }

}

resource "aws_route_table_association" "assoc_private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.rt_private_1.id
}

resource "aws_route_table" "rt_private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id

  }

}

resource "aws_route_table_association" "assoc_private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.rt_private_2.id
}