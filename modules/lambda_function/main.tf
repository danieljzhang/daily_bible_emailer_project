resource "aws_lambda_function" "this" {
  function_name    = var.name
  runtime          = var.runtime
  handler          = var.handler
  role             = var.role_arn
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash

  environment {
    variables = {
      SENDER_EMAIL    = var.sender_email
      RECIPIENT_EMAIL = var.recipient_email
    }
  }

  tags = {
    Project = "daily-bible-emailer"
  }
}
