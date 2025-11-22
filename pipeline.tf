# CodeBuild project (used by pipeline)
resource "aws_codebuild_project" "deployment_build" {
  name          = "daily-bible-terraform-deploy"
  service_role  = aws_iam_role.codebuild_role.arn
  description   = "Build project to run terraform apply for daily bible emailer"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    environment_variable {
      name  = "TF_VERSION"
      value = "1.7.0"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec.yml")
  }
}

# CodePipeline
resource "aws_codepipeline" "pipeline" {
  name     = "daily-bible-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      run_order        = 1
      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName = var.github_branch
      }

      output_artifacts = ["source_output"]
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = []
      configuration = {
        ProjectName = aws_codebuild_project.deployment_build.name
      }
    }
  }
}
