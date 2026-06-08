# devportal-infra
Terraform infrastructure for the DevPortal platform

# DevPortal Learning Journal

## Day 1 — Local setup and Terraform init

### What I did
- Installed all CLI tools: Terraform, AWS CLI, kubectl, Helm, k9s
- Configured AWS CLI with IAM user credentials
- Created three GitHub repos: devportal-infra, devportal-gitops, devportal-portal
- Created S3 bucket for Terraform remote state with versioning and encryption
- Wrote first Terraform configuration with S3 backend
- Successfully ran terraform init

### What I learned
- Terraform state should always be stored remotely in S3, not locally
- S3 bucket names are globally unique across all AWS accounts
- IAM users should have minimum required permissions, not root access

### Issues faced
No Issues faced today.
