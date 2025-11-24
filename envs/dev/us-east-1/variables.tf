variable "artifact_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing deployment artifacts, passed from the pipeline."
}

variable "name_prefix" {
  type        = string
  description = "A prefix used for naming resources within this environment."
  default     = "daily-bible-dev"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function."
  default     = "daily-bible-emailer"
}

variable "lambda_handler" {
  type        = string
  description = "The handler for the Lambda function."
  default     = "app.lambda_handler"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime for the Lambda function."
  default     = "python3.11"
}

variable "schedule_expression" {
  type        = string
  description = "The cron expression for the EventBridge schedule."
  default     = "cron(0 12 * * ? *)"
}

variable "sender_email" {
  type        = string
  description = "The 'From' email address, which must be verified in SES."
  # This should be overridden in a .tfvars file for production
}

variable "recipient_email" {
  type        = string
  description = "The 'To' email address, which must be verified in SES sandbox mode."
}