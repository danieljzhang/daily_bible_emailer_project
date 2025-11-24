variable "name_prefix" {
  description = "Prefix used for resource names"
  type        = string
  default     = "daily-bible"
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for GitHub source"
  type        = string
  default     = ""
}

variable "github_owner" {
  description = "GitHub repository owner (user or org)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Git branch to monitor"
  type        = string
  default     = "main"
}

variable "artifact_bucket_name" {
  description = "Optional artifact bucket name. If empty, a name will be created from prefix+region"
  type        = string
  default     = ""
}

variable "buildspec_path" {
  description = "Path to buildspec file inside repo or relative to module instantiation"
  type        = string
  default     = "buildspec.yml"
}
