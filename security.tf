# ALB Security Group: Manages access to the application
resource "aws_security_group" "lb" {
  name        = "${var.cluster_name}-lb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_sg" {
  name        = "${var.cluster_name}-ecs-tasks-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_private_sg" {
  name        = "ecs-tasks-private-security-group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.ecs_sg.id]
  }
   ingress {
    protocol        = "tcp"
    from_port       = var.db_port
    to_port         = var.db_port
    cidr_blocks     = [aws_subnet.public_1[0].cidr_block, aws_subnet.public_2[0].cidr_block]
  }

  # ingress {
  #   protocol        = "tcp"
  #   from_port       = var.db_port
  #   to_port         = var.db_port
  #   security_groups = [aws_security_group.bastion_sg.id]
  # }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#bd security group
# resource "aws_security_group" "bd_sg" {
#   name        = "mysql-database-security-group"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     protocol        = "-1"
#     from_port       = 0
#     to_port         = 0
#     security_groups = [aws_security_group.ecs_private_sg.id]
#   }
  


# resource "aws_security_group" "bastion_sg" {
#   name = "${var.cluster_name}-bastion-sg"
#   vpc_id = aws_vpc.main.id

#   ingress {
#     protocol = "tcp"
#     from_port = 22
#     to_port = 22
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# }