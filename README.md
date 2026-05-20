# FoodByte GitOps

This is the repo that runs the platform. Every change to the live cluster flows through here. Flux watches it and reconciles within 60 seconds of any commit, no manual deploys needed.

## The full picture

FoodByte is split across 8 repositories. Five for the services, three for infrastructure:

| Repo | What it does |
|---|---|
| [foodbyte-infra](https://github.com/ansuman-satapathy/foodbyte-infra) | Terraform for VPC, EKS, and IAM |
| [foodbyte-helm-charts](https://github.com/ansuman-satapathy/foodbyte-helm-charts) | Helm chart templates for all 5 services |
| [foodbyte-gitops](https://github.com/ansuman-satapathy/foodbyte-gitops) | This repo. Pins versions, owns cluster state |

Each service repo has its own CI pipeline that builds, scans with Grype, and pushes a container image to GHCR on every merge. This repo then pins those immutable SHAs so every deployment is fully traceable.

## Sync order

Flux applies changes in three waves so operators are always ready before the things that depend on them:

```
Wave 1   Envoy Gateway, External Secrets Operator, EBS CSI Driver
Wave 2   Gateway routes, SecretStore, StorageClass
Wave 3   All 5 application services
```

Each wave waits for the previous one to be fully healthy before proceeding. This was a hard lesson learned after hitting Flux sync deadlocks early on.

## Secrets

Nothing sensitive lives in Git. Credentials are stored in AWS Secrets Manager and synced into the cluster at runtime by the External Secrets Operator. Authentication uses EKS Pod Identity so there are no long-lived IAM keys anywhere.

## Bootstrapping a fresh cluster

```bash
# Provision the infrastructure
cd foodbyte-infra/terraform/live/dev && terraform apply

# Pull cluster credentials
aws eks update-kubeconfig --region us-east-1 --name foodbyte-dev-cluster

# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# Start Flux
flux-operator install -f clusters/production/flux-system/instance.yaml
```

Flux handles the rest automatically.