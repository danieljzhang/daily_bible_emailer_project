variable "name" {
  type        = string
  description = "The name for the EventBridge rule."
}

variable "schedule_expression" {
  type        = string
  description = "The schedule expression for the rule (e.g., 'cron(0 12 * * ? *)')."
}

variable "lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function to trigger."
}