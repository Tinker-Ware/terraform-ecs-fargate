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


variable "cluster_name" {
  type        = string
  description = "The name of AWS ECS cluster"
}

# App 1
variable "service_name_1" {
  type        = string
  description = "The name of the default service to be created"
}

variable "ecr_repo_1" {
  type        = string
  description = "URL for the docker image which will be used, hosted on ECR"
}

variable "subdomain_1" {
  type        = string
  description = "Subdomain to use for the route 53 record and load balancer listener rule"
}

variable "create_front_redirect" {
  type        = bool
  description = "Condition to evaluate whether create a redirect listener rule or forward listener rule for frontoffice"
}


# App 2
variable "service_name_2" {
  type        = string
  description = "The name of the default service to be created"
}

variable "ecr_repo_2" {
  type        = string
  description = "URL for the docker image which will be used, hosted on ECR"
}

variable "subdomain_2" {
  type        = string
  description = "Subdomain to use for the route 53 record and load balancer listener rule"
}


# App 3
variable "service_name_3" {
  type        = string
  description = "The name of the default service to be created"
}

variable "ecr_repo_3" {
  type        = string
  description = "URL for the docker image which will be used, hosted on ECR"
}

variable "subdomain_3" {
  type        = string
  description = "Subdomain to use for the route 53 record and load balancer listener rule"
}


variable "domain" {
  type        = string
  description = "Domain name for ACM certificate"
}

variable "db_snapshot_identifier" {
  type        = string
  description = "Name of the snapshot to use to create the new DB"
}

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
