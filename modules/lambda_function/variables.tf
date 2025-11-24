variable "name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "handler" {
  description = "The handler for the Lambda function."
  type        = string
  default     = "app.lambda_handler"
}

variable "runtime" {
  description = "The runtime for the Lambda function."
  type        = string
  default     = "python3.11"
}

variable "role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "filename" {
  description = "Local path to zip uploaded to S3 or artifact key."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "Artifact bucket name."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "Artifact key in S3."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Hash of the deployment package, used to trigger updates."
  type        = string
}

variable "sender_email" {
  description = "SES verified sender email."
  type        = string
  default     = ""
}

variable "recipient_email" {
  description = "SES verified recipient email."
  type        = string
  default     = ""
}