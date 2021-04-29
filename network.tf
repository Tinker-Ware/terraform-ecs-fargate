# module "vpc" {
#   source         = "terraform-aws-modules/vpc/aws"
#   name           = "${var.service_name}_vpc"
#   cidr           = "10.0.0.0/16"
#   azs            = ["us-east-1a", "us-east-1b"]
#   public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
# }

# data "aws_vpc" "main" {
#   id = module.vpc.vpc_id
# }

# Fetch AZs in the current region
# data "aws_availability_zones" "available" {
# }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


# Create var.az_count public subnets, each in a different AZ
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


# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# # Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
# resource "aws_eip" "gw" {
#   count      = var.az_count
#   vpc        = true
#   depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_nat_gateway" "gw" {
#   count         = var.az_count
#   subnet_id     = element(aws_subnet.public.*.id, count.index)
#   allocation_id = element(aws_eip.gw.*.id, count.index)
# }

# # Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
# resource "aws_route_table" "private" {
#   count  = var.az_count
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
#   }
# }

# # Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
# resource "aws_route_table_association" "private" {
#   count          = var.az_count
#   subnet_id      = element(aws_subnet.private.*.id, count.index)
#   route_table_id = element(aws_route_table.private.*.id, count.index)
# }