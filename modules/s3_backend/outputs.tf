output "bucket" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.backend.bucket
}

output "id" {
  description = "The resource id of the S3 bucket"
  value       = aws_s3_bucket.backend.id
}

output "arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.backend.arn
}
