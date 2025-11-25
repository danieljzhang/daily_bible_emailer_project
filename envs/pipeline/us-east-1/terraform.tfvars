## Terraform variables for envs/pipeline/us-east-1
# This file is ignored by git (see .gitignore). Edit values as needed.

# ARN of the CodeStar Connections connection (created earlier)
codestar_connection_arn = "arn:aws:codeconnections:us-east-1:960258040170:connection/804744b5-4c14-4086-a4cd-3bcb47a79592"

# GitHub owner and repo (update if different)
github_owner = "danieljzhang"
github_repo  = "daily_bible_emailer_project"

# Branch to monitor
github_branch = "main"

# Optional: use an existing artifact bucket name. Leave empty to let Terraform create one.
artifact_bucket_name = ""
