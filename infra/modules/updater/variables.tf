variable "env" {
  description = "Environment name"
}

variable "aws_region" {
  description = "AWS region"
}


variable "stack_name" {
  description = "Root name for the stack"
}

variable "archive_threshold_days" {
  description = "Number of days to archive"
}

variable "host" {
  description = "Host name"
}

variable "mysql_host" {
  description = "MySQL host name"
}

variable "mysql_schema" {
  description = "MySQL schema"
}

variable "mysql_username" {
  description = "MySQL user name"
}

variable "mysql_password" {
  description = "MySQL password"
  sensitive   = true
}

variable "pem_key" {
  description = "PEM key"
}

variable "s3_bucket" {
  description = "S3 bucket containing pem key"
}

variable "username" {
  description = "User name"
}

variable "utilities_url" {
  description = "Utilities URL"
}

variable "vpc_ids" {
  description = "VPC ID"
}

variable "security_group_ids" {
  description = "Security group ID"
}
