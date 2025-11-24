data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.name_prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:ListBucket"
    ]
    resources = var.artifact_bucket_arn != "" ? [var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"] : ["*"]
  }

  statement {
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = var.codestar_connection_arn != "" ? [var.codestar_connection_arn] : ["*"]
  }

  # Allow CodePipeline to pass the CodeBuild role to the CodeBuild service
  statement {
    sid       = "PassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.codebuild_role.arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.name_prefix}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# CodeBuild role
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.name_prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

# The CodeBuild role needs permissions to deploy the application infrastructure.
# For non-production environments, PowerUserAccess is a reasonable starting point.
# For production, this should be replaced with a custom, least-privilege policy.
resource "aws_iam_role_policy_attachment" "codebuild_poweruser" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Separate policy to allow CodePipeline to pass the CodeBuild role.
# This avoids a circular dependency within the main policy document.
resource "aws_iam_role_policy" "codepipeline_passrole" {
  name = "${var.name_prefix}-codepipeline-passrole"
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = "iam:PassRole", Effect = "Allow", Resource = aws_iam_role.codebuild_role.arn }
    ]
  })
}
