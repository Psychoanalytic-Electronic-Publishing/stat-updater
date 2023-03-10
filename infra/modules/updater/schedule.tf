module "schedule_stat_updates" {
  source               = "../schedule"
  lambda_function_arn  = module.stat_updater_lambda.lambda_function_arn
  lambda_function_name = module.stat_updater_lambda.lambda_function_name
  schedule             = "cron(0 03 * * ? *)" # 03:00 UTC
  description          = "Trigger stat update at 03:00 UTC each day"
  input                = jsonencode({ "eventType" : "stat_update" })
}

module "schedule_database_archival" {
  source               = "../schedule"
  lambda_function_arn  = module.stat_updater_lambda.lambda_function_arn
  lambda_function_name = module.stat_updater_lambda.lambda_function_name
  schedule             = "cron(0 06 * * ? *)" # 06:00 UTC
  description          = "Trigger database archival at 06:00 UTC each day"
  input                = jsonencode({ "eventType" : "database_archival" })
}
