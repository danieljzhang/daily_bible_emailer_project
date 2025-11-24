Bootstrap notes

This folder contains **one-shot** Terraform to create the S3 bucket and DynamoDB table used for Terraform remote state.

**Important**: run this from a secure admin account or create bucket/table manually before running other terraform.

Files:
- s3_backend.tf
- dynamodb.tf
