terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM role for Lambda
module "iam" {
  source      = "../../../modules/iam_roles"
  name_prefix = var.name_prefix
}
# sample lambda (uses local file artifact for demonstration)
resource "aws_s3_object" "lambda_zip" {
  bucket = var.artifact_bucket_name
  key    = "lambda/daily_bible_emailer.zip"
  # Path is relative to the terraform working directory (envs/dev/us-east-1)
  source = "../../../lambda/daily_bible_emailer.zip"
  etag   = filemd5("../../../lambda/daily_bible_emailer.zip")
}

module "lambda" {
  source           = "../../../modules/lambda_function"
  name             = var.lambda_function_name
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  role_arn         = module.iam.role_arn
  s3_bucket        = var.artifact_bucket_name
  s3_key           = aws_s3_object.lambda_zip.key
  source_code_hash = aws_s3_object.lambda_zip.etag
  sender_email     = var.sender_email
  recipient_email  = var.recipient_email
}

# EventBridge rule to trigger the Lambda daily
# This assumes you have an 'eventbridge_schedule' module
module "eventbridge_schedule" {
  source = "../../../modules/eventbridge_schedule"

  name = "${var.lambda_function_name}-trigger"
  # This cron expression runs at 12:00 PM (noon) UTC every day.
  schedule_expression = var.schedule_expression
  lambda_function_arn = module.lambda.function_arn
}
