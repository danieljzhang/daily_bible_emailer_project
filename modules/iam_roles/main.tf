# ------------------------------
# Lambda Assume Role Policy
# ------------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ------------------------------
# Lambda Execution Role
# ------------------------------
resource "aws_iam_role" "lambda_exec" {
  name               = length(trimspace(var.name_prefix)) > 0 ? "${var.name_prefix}-lambda-exec" : "daily-bible-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = var.tags
}

# ------------------------------
# Attach Basic Lambda Execution Policy
# ------------------------------
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ------------------------------
# Inline SES Policy for sending emails
# ------------------------------
data "aws_iam_policy_document" "ses_policy" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"] # scope down if possible
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_ses" {
  name   = "lambda-ses-send"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.ses_policy.json
}

# ------------------------------
# KMS Access Policy (Default Lambda Key)
# ------------------------------
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = [
      "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/lambda"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_kms" {
  name   = "lambda-kms-access"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_kms.json
}
