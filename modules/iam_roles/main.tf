data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = length(trimspace(var.name_prefix)) > 0 ? "${var.name_prefix}-lambda-exec" : "daily-bible-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Minimal inline policy to allow SES sends (scope down if you can)
data "aws_iam_policy_document" "ses_policy" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_ses" {
  name   = "lambda-ses-send"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.ses_policy.json
}
