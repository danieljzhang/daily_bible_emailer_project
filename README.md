# Daily Bible Emailer — Terraform, Serverless, and CI/CD

This repository contains a complete Infrastructure-as-Code project to deploy a **serverless daily devotional emailer** on AWS.

It uses Terraform to define all cloud resources and includes a fully automated CI/CD pipeline using AWS CodePipeline, which deploys changes on every `git push` to the main branch.

## Features

- **Serverless Application**: An AWS Lambda function written in Python 3.11, triggered daily by an Amazon EventBridge rule to send an email. (Note: Amazon SES integration requires identity verification).
- **Infrastructure as Code**: All AWS resources are defined using Terraform for reproducible and version-controlled infrastructure.
- **CI/CD Automation**: An AWS CodePipeline pipeline automatically deploys application changes from GitHub.
- **Scalable Structure**: The project is organized into environments (`dev`, `pipeline`) and reusable modules, making it easy to add more environments (e.g., `prod`) or regions.

## Project Structure

The repository is structured to separate concerns, promoting reusability and clarity.

```
├── envs/
│   ├── dev/                  # Contains infrastructure for the 'dev' application environment
│   │   └── us-east-1/
│   └── pipeline/             # Contains infrastructure for the CI/CD pipeline itself
│       └── us-east-1/
├── lambda/                   # Source code for the Python Lambda function
├── modules/                  # Reusable Terraform modules (IAM, Lambda, Pipeline, etc.)
├── .gitignore
└── README.md
```
*   **`envs/`**: This is the top-level directory for environment-specific Terraform configurations. Each sub-directory is a "root module" where you can run `terraform apply`.
    *   **`envs/pipeline/`**: Defines the CI/CD pipeline, CodeBuild project, and necessary IAM roles. This is the "factory" that builds your application. It is deployed **manually once** to bootstrap the system.
    *   **`envs/dev/`**: Defines the actual application resources for the development environment (Lambda function, S3 artifact bucket, IAM roles). This is the "product" built by the factory. It is deployed **automatically by the pipeline**.
*   **`modules/`**: Contains reusable Terraform modules. This avoids code duplication and makes the infrastructure easier to manage.
*   **`lambda/`**: Contains the Python source code and any dependencies for the Lambda function. The CI/CD pipeline automatically packages this code into a zip file for deployment.

## Deployment Guide

Follow these steps to deploy the entire system.

### Prerequisites

1.  **AWS Account & CLI**: An AWS account and the AWS CLI installed and configured with credentials.
2.  **Terraform**: The Terraform CLI installed locally.
3.  **GitHub Repository**: Your own GitHub repository containing the code from this project.
4.  **Terraform Backend Resources**:
    *   An **S3 bucket** to store the Terraform state file.
    *   A **DynamoDB table** for state locking to prevent concurrent modifications.
    *   These must be created manually or with a separate, one-time Terraform script. The table must have a primary key named `LockID` (Type: String).
5.  **AWS CodeStar Connection**: A connection to your GitHub account set up in the AWS CodePipeline console. Note its ARN.

### Step 1: Deploy the CI/CD Pipeline (Manual Bootstrap)

The pipeline cannot create itself. You must deploy it manually the first time.

1.  **Navigate to the pipeline directory**:
    ```bash
    cd envs/pipeline/us-east-1
    ```
2.  **Configure the Backend**: Create a `backend.hcl` file (you can copy `backend.hcl.example` if it exists) and fill in the name of your S3 bucket and DynamoDB table.
3.  **Configure Variables**: Create a `terraform.tfvars` file and provide values for the required variables (e.g., `codestar_connection_arn`, `github_owner`, `github_repo`).
4.  **Initialize and Apply Terraform**:
    ```bash
    # Initialize Terraform with the backend configuration
    terraform init -backend-config=backend.hcl

    # Review the plan and apply to create the pipeline
    terraform apply
    ```
After this step, the AWS CodePipeline will be created and will likely run for the first time.

### Step 2: Push a Change to Trigger the Automated Deployment

The pipeline is now active and will manage the application infrastructure defined in `envs/dev/`.

1.  **Configure the `dev` Backend**: In `envs/dev/us-east-1/`, create a `backend.hcl` file with the same S3 bucket and DynamoDB table details. The `key` should be different to store the state for the `dev` environment separately.
2.  **Commit and Push**: Commit the `backend.hcl` file and any other changes to your GitHub repository.
    ```bash
    git add .
    git commit -m "Configure dev backend and trigger pipeline"
    git push origin main
    ```

### How the CI/CD Automation Works

1.  **Trigger**: A `git push` to the configured branch (e.g., `main`) triggers the AWS CodePipeline.
2.  **Source Stage**: The pipeline's "Source" stage uses the CodeStar connection to download the latest source code from your GitHub repository into an S3 artifact bucket.
3.  **Deploy Stage**:
    *   The "Deploy" stage starts an AWS CodeBuild project.
    *   CodeBuild uses the `envs/pipeline/us-east-1/buildspec.yml` file as its instructions.
    *   The buildspec commands perform the following:
        1.  Install Terraform.
        2.  Package the `lambda/` directory into `lambda/daily_bible_emailer.zip`.
        3.  Change the working directory to `envs/dev/us-east-1`.
        4.  Run `terraform init` and `terraform apply -auto-approve`, using the backend configuration specified in `backend.hcl`.
4.  **Deployment**: Terraform creates or updates the AWS resources for the `dev` environment, including uploading the new Lambda zip file to S3 and updating the function.

From this point forward, you only need to push code changes. The pipeline will handle the rest.

## Security Notes
- For simplicity, this project may grant broader IAM permissions than necessary for a production environment. Always review and scope down IAM policies to follow the principle of least privilege.
- If using Amazon SES, you must verify sender and recipient email addresses while in the sandbox environment.
