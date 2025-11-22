# Daily Bible Emailer — Terraform + Serverless + CI/CD

This repository contains a complete Infrastructure-as-Code project to deploy a **serverless daily devotional emailer** on AWS.

Features:
- AWS Lambda (Python 3.11) sends a daily HTML email via SES.
- EventBridge scheduled rule triggers the Lambda daily.
- CI/CD via AWS CodePipeline + CodeBuild using a CodeStar GitHub connection.
- All infrastructure declared in Terraform.

**TO DO BEFORE FIRST APPLY**
1. Create an S3 bucket for Terraform remote state and set its name into `var.state_bucket` (or via CLI -var).
2. Create an AWS CodeStar Connection (GitHub) and paste the ARN into `var.codestar_connection_arn`.
3. Verify `SENDER_EMAIL` and `RECIPIENT_EMAIL` in SES (if SES is in sandbox both must be verified).
4. Update `variables.tf` or pass variables on CLI for `sender_email`, `recipient_email`, `github_owner`, `github_repo`, and `state_bucket`.
5. Push this repository to GitHub and run the pipeline (CodePipeline will be triggered by commits).

**How it works in brief**
- CodePipeline pulls source from GitHub using the CodeStar connection.
- CodeBuild runs `buildspec.yml` which packages the lambda code (zip) and runs `terraform apply`.
- Terraform uploads the Lambda (from the zip located at `lambda/daily_bible_emailer.zip`) and creates EventBridge rule and wiring.

**Security notes**
- For simplicity this repo grants broad CodeBuild permissions. For production, narrow the policies by resource.
- SES requires identity verification; production SES may need to be moved out of sandbox.

