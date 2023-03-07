variable "env" {
  description = "Environment name"
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Root name for the stack"
  default     = "pep-stat-updater"
}

variable "archive_threshold_days" {
  description = "Number of days to archive"
  default     = 30
}

variable "host" {
  description = "Host name"
  default     = "ec2-54-210-185-163.compute-1.amazonaws.com"
}

variable "mysql_host" {
  description = "MySQL host name"
  default     = "staging.c6re6qczl2ae.us-east-1.rds.amazonaws.com"
}

variable "mysql_schema" {
  description = "MySQL schema"
  default     = "opascentral"
}

variable "mysql_username" {
  description = "MySQL user name"
  default     = "nrshapiro"
}

variable "mysql_password" {
  description = "MySQL password"
  sensitive   = true
}


variable "pem_key" {
  description = "PEM key"
  default     = "pep-build-machine.pem"
}

variable "s3_archive_bucket" {
  description = "S3 archive bucket"
  default     = "pep-sessions-archival/staging/"
}

variable "s3_bucket" {
  description = "S3 bucket"
  default     = "pep-configuration"
}

variable "sns_topic" {
  description = "SNS topic"
  default     = "arn:aws:sns:us-east-1:547758924192:pep-subscription-mailer-alarm"
}

variable "username" {
  description = "User name"
  default     = "ubuntu"
}

variable "utilities_url" {
  description = "Utilities URL"
  default     = "https://pep-gitlab-deployment.s3.amazonaws.com/data-migration/utilities.sh"
}