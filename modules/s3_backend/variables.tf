variable "bucket_name" {
  type        = string
  description = "The name for the S3 bucket."
}
variable "region" {
  type        = string
  description = "The AWS region where the S3 bucket will be created."
  default     = "us-east-1"
}
