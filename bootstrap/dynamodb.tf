provider "aws" {
  region = var.region
}

variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}
variable "table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
