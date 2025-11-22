variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression (cron)"
  type        = string
  default     = "cron(0 7 * * ? *)" # 07:00 UTC daily
}

variable "sender_email" {
  description = "Verified SES sender email address"
  type        = string
  default     = ""
}

variable "recipient_email" {
  description = "Verified SES recipient email address (must be verified in SES if in sandbox)"
  type        = string
  default     = ""
}

variable "github_owner" {
  description = "GitHub repo owner (organization or user)"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "github_branch" {
  description = "Git branch to monitor"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "CodeStar Connections ARN for GitHub"
  type        = string
  default     = ""
}

variable "state_bucket" {
  description = "Terraform remote state S3 bucket (must exist prior to apply)"
  type        = string
  default     = ""
}

variable "artifact_bucket_name" {
  description = "S3 bucket name used by CodePipeline to store artifacts (will be created)"
  type        = string
  default     = "daily-bible-emailer-artifacts-${random_id.bucket_suffix.hex}"
}
