output "codepipeline_role_arn" {
  description = "ARN of the created CodePipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  description = "Name of the created CodePipeline role"
  value       = aws_iam_role.codepipeline_role.name
}

output "codebuild_role_arn" {
  description = "ARN of the created CodeBuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_name" {
  description = "Name of the created CodeBuild role"
  value       = aws_iam_role.codebuild_role.name
}
