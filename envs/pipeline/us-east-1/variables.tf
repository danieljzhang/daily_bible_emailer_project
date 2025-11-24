variable "codestar_connection_arn" {
  description = "CodeStar Connection ARN for GitHub (set in terraform.tfvars for the env)"
  type        = string
  default     = ""
}

variable "github_owner" {
  description = "GitHub owner/org"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to monitor"
  type        = string
  default     = "main"
}

variable "artifact_bucket_name" {
  description = "Optional artifact bucket name to use (if empty module will create one)"
  type        = string
  default     = ""
}
