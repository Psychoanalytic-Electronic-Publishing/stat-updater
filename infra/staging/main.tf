terraform {
  backend "s3" {
    key = "global/s3/stat-updater-stage.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

module "updater" {
  source = "../modules/updater"

  env                    = var.env
  aws_region             = var.aws_region
  stack_name             = var.stack_name
  archive_threshold_days = var.archive_threshold_days
  host                   = var.host
  mysql_host             = var.mysql_host
  mysql_schema           = var.mysql_schema
  mysql_username         = var.mysql_username
  mysql_password         = var.mysql_password
  pem_key                = var.pem_key
  s3_archive_bucket      = var.s3_archive_bucket
  s3_bucket              = var.s3_bucket
  username               = var.username
  utilities_url          = var.utilities_url
  vpc_ids                = var.vpc_ids
  security_group_ids     = var.security_group_ids
}
