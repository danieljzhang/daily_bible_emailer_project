locals {
  artifact_bucket = var.artifact_bucket_name != "" ? var.artifact_bucket_name : "${var.name_prefix}-artifacts-${var.region}"
}

# Create or use artifact bucket (simple creation using s3_backend module)
module "artifact_bucket" {
  source      = "../s3_backend"
  bucket_name = local.artifact_bucket
  region      = var.region
}

# Create pipeline IAM roles (module) and pass the artifact bucket ARN
module "pipeline_iam" {
  source                  = "../pipeline_iam"
  name_prefix             = var.name_prefix
  codestar_connection_arn = var.codestar_connection_arn
  artifact_bucket_arn     = module.artifact_bucket.arn
}

# CodeBuild project
resource "aws_codebuild_project" "deployment_build" {
  name         = "${var.name_prefix}-terraform-deploy"
  service_role = module.pipeline_iam.codebuild_role_arn
  description  = "Build project to run terraform apply for daily bible emailer"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
    environment_variable {
      name  = "TF_VERSION"
      value = "1.7.0"
    }
    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = module.artifact_bucket.bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }
}

# CodePipeline
resource "aws_codepipeline" "pipeline" {
  name     = "${var.name_prefix}-codepipeline"
  role_arn = module.pipeline_iam.codepipeline_role_arn

  artifact_store {
    location = module.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name      = "Source"
      category  = "Source"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      version   = "1"
      run_order = 1
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
        DetectChanges    = true
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
