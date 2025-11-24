module "pipeline" {
  source                  = "../../../modules/pipeline"
  name_prefix             = "daily-bible"
  region                  = "us-east-1"
  codestar_connection_arn = var.codestar_connection_arn
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  github_branch           = var.github_branch
  artifact_bucket_name    = var.artifact_bucket_name
  # Path is relative to the repository root inside the source artifact.
  # For CodeBuild (run by CodePipeline) this should point to the buildspec
  # file location inside the repo (e.g. "buildspec.yml"). Do NOT use a
  # file system path like '../../../../buildspec.yml'.
  # Use a per-environment buildspec located inside the repo artifact.
  # This path is relative to the repo root inside the source artifact.
  buildspec_path = "envs/dev/us-east-1/buildspec.yml"
}

output "pipeline_name" {
  value = module.pipeline.pipeline_name
}
