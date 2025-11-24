## Terraform variables for envs/pipeline/us-east-1
# This file is ignored by git (see .gitignore). Edit values as needed.

# ARN of the CodeStar Connections connection (created earlier)
codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:960258040170:connection/4a0ac050-2f18-4046-9ffe-593087dfdde7"

# GitHub owner and repo (update if different)
github_owner = "danieljzhang"
github_repo  = "daily_bible_emailer_project"

# Branch to monitor
github_branch = "main"

# Optional: use an existing artifact bucket name. Leave empty to let Terraform create one.
artifact_bucket_name = ""
