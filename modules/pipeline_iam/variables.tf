variable "name_prefix" {
  description = "Prefix for created role names"
  type        = string
  default     = "daily-bible"
}

variable "codestar_connection_arn" {
  description = "(Optional) CodeStar connection ARN used by CodePipeline Source action"
  type        = string
  default     = ""
}

variable "artifact_bucket_arn" {
  description = "(Optional) ARN of the S3 artifact bucket used by CodePipeline"
  type        = string
  default     = ""
}
