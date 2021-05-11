variable "aws_profile" {
  type        = string
  description = "Name of the credentials profile to use when accessing AWS"
  default     = "default"
}

variable "aws_region" {
  type        = string
  description = "Code for the AWS region where the infrastructure will be deployed"
  default     = "us-east-1"
}

variable "domain" {
  type        = string
  description = "Domain name for ACM certificate and Route 53 hosted zone"
}

variable "cluster_name" {
  type        = string
  description = "The name of AWS ECS cluster"
}

# ------------------------------------
# ECS Services
# ------------------------------------
variable "subdomains" {
  type        = list
  description = "List of subdomains for Route 53 records"
}

variable "service_names" {
  type        = list
  description = "List of names for the ECS services to be created"
}

variable "ecr_repos" {
  type        = list
  description = "List of URLs for the docker images which will be used, hosted on ECR"
}

# ------------------------------------
# DB
# ------------------------------------
variable "db_version" {
  type        = string
  description = "Engine version for MySQL"
}

variable "db_user" {
  type = string
  description = "Username to use to access the DB"
}

variable "db_password" {
  type = string
  description = "Password to use to access the DB"
}

variable "db_port" {
  type = number
  description = "Port on which the DB accepts connections"
}
