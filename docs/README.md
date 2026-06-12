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


## Day 5 — NGINX Ingress + cert-manager + HTTPS

### What I built
- Installed NGINX Ingress Controller via Helm on k3s
- Used NodePort + hostNetwork because k3s has no cloud load balancer
- Created DuckDNS subdomain pointing to EC2 Elastic IP
- Added Ingress resource to Helm chart via values.yaml
- Installed cert-manager and configured Let's Encrypt ClusterIssuer
- App is now live on HTTPS with auto-renewing certificate

### What I learned
- NGINX Ingress on k3s needs NodePort because there is no AWS
  load balancer — hostNetwork binds directly to EC2 network interface
- Always test with Let's Encrypt staging first — production has
  rate limits of 5 certificates per domain per week
- ClusterIssuer is cluster-wide, Issuer is namespace-scoped —
  always use ClusterIssuer for simplicity
- cert-manager uses HTTP01 challenge — it temporarily creates a
  pod that Let's Encrypt contacts to verify domain ownership
- Deleting a certificate resource forces cert-manager to reissue it

### Issues faced
## SSL Certificate Issue & Fix

### Problem

After switching from Let's Encrypt staging to production issuer, the website still showed:

* “Not Secure”
* staging certificate warning

`kubectl describe certificate nginx-test-tls` showed:

```text id="4p0t5d"
order is in "invalid" state
DNS problem: SERVFAIL looking up A record
```

### Root Cause

Let's Encrypt failed to validate the domain because of temporary DNS resolution/propagation issues with DuckDNS.

### Debugging Steps

```bash id="g1l7xe"
kubectl describe certificate nginx-test-tls
kubectl get challenges,orders -A
kubectl describe challenge <challenge-name>
nslookup hardikdevportal.duckdns.org
```

### Fix

Deleted failed ACME resources:

```bash id="9k5xq2"
kubectl delete challenge --all -A
kubectl delete order --all -A
```

cert-manager retried automatically and generated a valid production certificate.

### Verification

```bash id="9n6ysh"
kubectl get certificate
```

Output:

```text id="m7v2la"
READY=True
```

HTTPS worked correctly after clearing Chrome SSL cache / testing in Incognito mode.



## Day 6 — SSM Parameter Store + External Secrets + ECR automation

### What I built
- Stored secrets in AWS SSM Parameter Store as SecureString
- Created dedicated IAM user with minimum permissions for
  External Secrets Operator
- Installed External Secrets Operator via Helm
- Created ClusterSecretStore connecting to AWS SSM
- Created ExternalSecret that syncs SSM parameters to
  Kubernetes secrets automatically every 1 hour
- Built CronJob that refreshes ECR pull secret every 6 hours
  so pods never fail with ImagePullBackOff after token expiry
- Added liveness and readiness probes to deployment

### What I learned
- SSM SecureString encrypts values at rest using KMS
- ExternalSecret refreshInterval controls how often it syncs
  from AWS — 1h means secrets rotate within 1 hour of SSM update
- ClusterSecretStore is cluster-wide, SecretStore is namespace-scoped
- Liveness probe — if this fails Kubernetes restarts the pod
- Readiness probe — if this fails Kubernetes stops sending
  traffic to the pod but does not restart it
- ECR tokens expire every 12 hours — automating refresh is
  essential for production reliability
- Never store secrets in Git — SSM + External Secrets is the
  correct production pattern

### Issues faced
You can keep it like this in your README:

### Issue: AWS CLI image missing kubectl

While running the ECR token refresh CronJob, the container had AWS CLI installed but `kubectl` was missing, causing Kubernetes secret creation to fail.

### Initial Fix

Installed `kubectl` manually inside the container:

```bash id="cmd7f2"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```

### Better Solution

Switched to:

```text id="txt8k1"
heyvaldemar/aws-kubectl
```

Docker image because it already includes:

* AWS CLI
* kubectl

Result:

* cleaner CronJob
* simpler maintenance
* no manual kubectl installation required
