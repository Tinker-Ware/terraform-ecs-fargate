# -------------------------------------------------------------------
# General variables
# -------------------------------------------------------------------
variable "aws_region" {
  description = "AWS Region where all the infrastructure is being deployed"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain through which the content will be accessed"
}

variable "subdomain" {
  description = "Specific subdomain through which the content will be served"
}


# -------------------------------------------------------------------
# ECS variables
# -------------------------------------------------------------------
variable "ecr_repo" {
  description = "URL of the ECR repo on which the Docker image is hosted on"
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
}

variable "aws_cluster_id" {
  description = "ID attribute of the ECS cluster in AWS"
}

variable "service_name" {
  description = "Name of the ECS service"
}

variable "execution_role_arn" {
  description = "ARN attribute of the IAM execution role in AWS"
}

variable "task_definition_cpu" {
  description = "CPU units set for the task definition"
  type        = number
  default     = 256
}

variable "task_definition_ram" {
  description = "Memory units set for the task definition"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port where requests are being received"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Host port where requests are being received"
  type        = number
  default     = 80
}

variable "aws_security_group_id" {
  description = "ID attribute of the security group for ECS in AWS"
}

variable "public_subnets" {
  description = "Arrray of IDs from the public subnets"
}

# variable "role_execution_attachment" {
#   description = "IAM role execution attachment resource"
# }



# -------------------------------------------------------------------
# Load balancer variables
# -------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of the VPC the target group will be deployed in"
}

variable "alb_listener_arn" {
  description = "ARN of the HTTPS listener in which the rule is included and evaluated"
}

variable "https_listener" {
  description = "HTTPS listener which contains all the routing rules"
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol according to target group port selected"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type to which the target group is pointing to"
  type = string
  default = "ip"
}

variable "create_redirect_rule" {
  description = "Conditional variable to whether create a redirection listener rule"
  type = bool
}

variable "create_forward_rule" {
  description = "Conditional variable to whether create a forwarding listener rule"
  type = bool
}

variable "rule_priority" {
  description = "Priority given to the rule in which will be evaluated from the HTTPS listener"
}


# -------------------------------------------------------------------
# Auto Scaling variables
# -------------------------------------------------------------------
variable "aws_cluster_name" {
  description = "Name attribute of the ECS cluster in AWS"
}

# variable "aws_service_name" {
#   description = "Name attribute of the ECS service in AWS"
# }


# -------------------------------------------------------------------
# Route 53 variables
# -------------------------------------------------------------------
variable "hosted_zone_id" {
  description = "ID of the hosted zone in AWS"
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer in AWS"
}

variable "alb_zone_id" {
  description = "Availability Zone ID of the ALB in AWS"
}
