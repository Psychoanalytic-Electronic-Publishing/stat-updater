variable "lambda_function_arn" {
  description = "ARN of the lambda function to invoke"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the lambda function to invoke"
  type        = string
}

variable "schedule" {
  description = "Schedule expression"
  type        = string
}

variable "description" {
  description = "Description of the schedule"
  type        = string
}

variable "input" {
  description = "Input to the lambda function"
  type        = string
}
