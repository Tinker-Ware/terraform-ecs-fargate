resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

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

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
