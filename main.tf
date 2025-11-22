provider "aws" {
  region = var.aws_region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for pipeline artifacts (created)
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = var.artifact_bucket_name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "daily-bible-emailer-artifacts"
    ManagedBy = "terraform"
  }
}

# Lambda IAM role
resource "aws_iam_role" "lambda_exec" {
  name = "daily_bible_lambda_exec_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "daily-bible-lambda-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid = "SES"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}

# Lambda function (code package must be present at lambda/daily_bible_emailer.zip when terraform apply runs)
resource "aws_lambda_function" "bible_emailer" {
  function_name = "daily-bible-emailer"
  filename      = "lambda/daily_bible_emailer.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("lambda/daily_bible_emailer.zip")

  environment {
    variables = {
      SENDER_EMAIL    = var.sender_email
      RECIPIENT_EMAIL = var.recipient_email
      AWS_REGION      = var.aws_region
    }
  }

  tags = {
    Project = "daily-bible-emailer"
  }
}

# EventBridge rule (scheduler)
resource "aws_cloudwatch_event_rule" "daily_schedule" {
  name                = "daily-bible-schedule"
  schedule_expression = var.schedule_expression
  description         = "Daily trigger for daily-bible-emailer Lambda"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_schedule.name
  target_id = "dailyBibleLambdaTarget"
  arn       = aws_lambda_function.bible_emailer.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bible_emailer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule.arn
}
