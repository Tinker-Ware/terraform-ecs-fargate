provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = var.aws_profile
  region                  = var.aws_region
}

terraform {
  backend "s3" {
    profile = "default"
    bucket = "tw-tfstate-files"
    key    = "hv-test/terraform-hv-stage.tfstate"
    region = "us-east-1"
  }
}
