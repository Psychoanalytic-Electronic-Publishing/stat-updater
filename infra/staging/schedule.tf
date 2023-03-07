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
  schedule_expression = "cron(0 06 * * ? *)" # 06:00 UTC
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
