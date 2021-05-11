provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = var.aws_profile
  region                  = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "tw-tfstate-files"
    key    = "hv-test/terraform.tfstate"
    region = "us-east-1"
  }
}

# Resources
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

data "aws_route53_zone" "selected" {
    name = var.domain
}


# Module instances
module "ecs_service_1" {
  source = "modules/ecs_service"

  domain = var.domain
  subdomain = var.subdomains[0]

  ecr_repo = var.ecr_repos[0]
  cluster_name = var.cluster_name
  aws_cluster_id = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  aws_security_group_id = aws_security_group.ecs_sg.id
  public_subnets = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]

  vpc_id = aws_vpc.main.id
  alb_listener_arn = aws_alb_listener.https_listener.arn

  depends_on = [
    aws_vpc.main.id,
    aws_ecs_cluster.main.id,
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecs_task_execution_role_attachment,
    aws_alb_listener.https_listener
  ]
}