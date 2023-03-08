resource "aws_sns_topic" "user_updates" {
  name = "${var.stack_name}-user-updates-${var.env}"

  tags = {
    stack = var.stack_name
    env   = var.env
  }
}
