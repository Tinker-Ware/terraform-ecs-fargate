provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = var.aws_profile
  region                  = var.aws_region
}

terraform {
  backend "s3" {
    bucket = var.s3_tfstate_bucket
    key    = var.s3_backup_path
    region = var.aws_region
  }
}