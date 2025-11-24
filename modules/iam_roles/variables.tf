variable "name_prefix" {
  description = "Prefix to use for role names"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Optional tags to apply to created IAM resources"
  type        = map(string)
  default     = {}
}
