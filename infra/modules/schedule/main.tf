resource "aws_cloudwatch_event_rule" "schedule" {
  description         = var.description
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "schedule_target" {
  rule  = aws_cloudwatch_event_rule.schedule.name
  arn   = var.lambda_function_arn
  input = var.input
}

resource "aws_lambda_permission" "schedule_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
