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



## Day 2 — VPC, EC2, k3s

### What I built
- VPC with public subnet, internet gateway, route table
- Security group with ports 22, 80, 443, 6443, 30000-32767
- EC2 t3.large with 30GB gp3 encrypted disk
- Elastic IP attached to instance
- k3s installed with Traefik and servicelb disabled
- kubeconfig copied to local Mac, kubectl working remotely

### What I learned
- Elastic IP prevents IP from changing when instance stops and starts
- k3s ships with Traefik by default — must disable it at install time
  otherwise it conflicts with NGINX Ingress later
- kubeconfig 127.0.0.1 must be replaced with public IP for remote access
- gp3 is cheaper and faster than gp2 for EBS volumes

### Issues faced
Today, while writing VPC file, the availablity zone error came because it was not appending a at the end attached with the var, fixed it with manual writing of the variable.


## Day 3 — ArgoCD installed, first GitOps deployment

### What I built
- Installed ArgoCD on k3s cluster in argocd namespace
- Accessed ArgoCD UI via port-forwarding
- Connected ArgoCD to devportal-gitops GitHub repo
- Created first Helm chart for nginx-test app
- ArgoCD automatically synced and deployed from GitHub

### What I learned
- ArgoCD stores initial admin password as a Kubernetes secret
- Port-forwarding creates a tunnel from localhost to a cluster service
  without exposing it to the internet
- An ArgoCD Application manifest tells ArgoCD what repo to watch,
  what path, and where to deploy
- syncPolicy automated means ArgoCD deploys without manual approval
- selfHeal means if someone manually changes the cluster ArgoCD
  reverts it back to what GitHub says

### Issues faced
Some syntax issues, nothing special


## Day 4 — GitHub Actions CI/CD + ECR

### What I built
- Created ECR repository with lifecycle policy (keep last 5 images)
- Created dedicated IAM user for GitHub Actions with ECR push permissions
- Written GitHub Actions workflow that builds Docker image on every
  push to sample-app folder
- Full GitOps loop working: code push → image build → ECR push →
  values.yaml updated → ArgoCD syncs → new pod running

### What I learned
- GitHub Actions GITHUB_TOKEN is automatic, no manual creation needed
  but needs Read/Write permission enabled in repo settings
- k3s does not have AWS credentials by default, needs explicit
  ECR pull secret to pull private images
- ECR pull secret needs to be recreated periodically because
  ECR tokens expire every 12 hours — we will automate this later
- containerPort in deployment must match the port the app actually
  listens on — mismatch causes connection refused
- Kubernetes resource names come from ArgoCD Application manifest
  not from package.json or app code

### Errors fixed today
- ECR lifecycle policy JSON syntax error — = instead of : in JSON
- GitHub Actions 403 — needed Read/Write workflow permissions enabled
- node:18/alpine became node:18-alpine — file creation corrupted hyphen
- ImagePullBackOff — k3s had no ECR credentials, fixed with docker-registry secret
- Container port mismatch — app listens on 3000, deployment said 80

### Important lesson — port-forward caching
After ArgoCD deploys a new pod, always kill the existing port-forward
and restart it. The old port-forward stays connected to the old pod
session and shows cached content even after new pod is running.
Always Ctrl+C the port-forward and rerun it after a new deployment.