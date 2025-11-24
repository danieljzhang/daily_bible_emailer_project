provider "aws" {
  region = var.region
}

variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}
variable "bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state."
  type        = string
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name
  acl    = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = { Name = "terraform-backend-${var.bucket_name}" }
}
