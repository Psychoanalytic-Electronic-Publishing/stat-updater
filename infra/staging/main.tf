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

resource "aws_cloudwatch_event_rule" "schedule_stat_updates" {
  name                = "${var.stack_name}-stat-update-schedule-${var.env}"
  description         = "Trigger stat update at 03:00 UTC each day"
  schedule_expression = "cron(0 03 * * ? *)" # 03:00 UTC
}

resource "aws_cloudwatch_event_target" "schedule_state_updates_target" {
  rule  = aws_cloudwatch_event_rule.schedule_stat_updates.name
  arn   = module.stat_updater_lambda.lambda_function_arn
  input = jsonencode({ "eventType" : "stat_update" })
}

resource "aws_lambda_permission" "allow_stat_update_schedule_to_run_lambda" {
  statement_id  = "${var.stack_name}-allow-cloudwatch-stat-schedule-${var.env}"
  action        = "lambda:InvokeFunction"
  function_name = module.stat_updater_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_stat_updates.arn
}


resource "aws_cloudwatch_event_rule" "schedule_database_archival" {
  name                = "${var.stack_name}-database-archival-schedule-${var.env}"
  description         = "Trigger database archival at 06:00 UTC each day"
  schedule_expression = "cron(0 06 * * ? *)" # 03:00 UTC
}

resource "aws_cloudwatch_event_target" "schedule_database_archival_target" {
  rule  = aws_cloudwatch_event_rule.schedule_database_archival.name
  arn   = module.stat_updater_lambda.lambda_function_arn
  input = jsonencode({ "eventType" : "database_archival" })
}

resource "aws_lambda_permission" "allow_archival_schedule_to_run_lambda" {
  statement_id  = "${var.stack_name}-allow-cloudwatch-database-schedule-${var.env}"
  action        = "lambda:InvokeFunction"
  function_name = module.stat_updater_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_database_archival.arn
}
