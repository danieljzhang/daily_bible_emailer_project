output "role_arn" {
  description = "ARN of the created Lambda execution role"
  value       = aws_iam_role.lambda_exec.arn
}

output "role_name" {
  description = "Name of the created Lambda execution role"
  value       = aws_iam_role.lambda_exec.name
}

output "role_id" {
  description = "ID of the created Lambda execution role"
  value       = aws_iam_role.lambda_exec.id
}
