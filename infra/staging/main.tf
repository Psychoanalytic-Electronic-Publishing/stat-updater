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



module "stat_updater_lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  function_name          = "${var.stack_name}-handler-${var.env}"
  source_path            = "../../app"
  handler                = "handler.handler"
  runtime                = "nodejs16.x"
  timeout                = 900
  memory_size            = 1024
  ephemeral_storage_size = 512

  environment_variables = {
    ARCHIVE_THRESHOLD_DAYS = 30
    ENVIRONMENT            = var.env
    HOST                   = var.host
    MYSQL_HOST             = var.mysql_host
    MYSQL_PASSWORD         = var.mysql_password
    MYSQL_SCHEMA           = var.mysql_schema
    MYSQL_USERNAME         = var.mysql_username
    PEM_KEY                = var.pem_key
    REGION                 = var.aws_region
    S3_ARCHIVE_BUCKET      = var.s3_archive_bucket
    S3_BUCKET              = var.s3_bucket
    SNS_TOPIC              = var.sns_topic
    USERNAME               = var.username
    UTILITIES_URL          = var.utilities_url
  }

  tags = {
    stage = var.env
    stack = var.stack_name
  }
}

