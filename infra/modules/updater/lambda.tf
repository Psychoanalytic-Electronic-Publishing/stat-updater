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
    S3_ARCHIVE_BUCKET      = aws_s3_bucket.archive.id
    S3_BUCKET              = var.s3_bucket
    SNS_TOPIC              = aws_sns_topic.user_updates.arn
    USERNAME               = var.username
    UTILITIES_URL          = var.utilities_url
  }

  vpc_subnet_ids         = data.aws_subnets.vpc.ids
  vpc_security_group_ids = var.security_group_ids
  attach_network_policy  = true

  tags = {
    stage = var.env
    stack = var.stack_name
  }
}

resource "aws_iam_role_policy" "s3_policy" {
  role = module.stat_updater_lambda.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket}/*"
      },
    ]
  })
}

