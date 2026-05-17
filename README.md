# FoodByte GitOps

This is the central orchestration repository for the FoodByte cluster. It utilizes the Flux Operator to manage the live state of the entire platform declaratively.

## Architecture
This repository provides a single control plane for cluster operations by synchronizing resources from multiple sources:

- Manager: The FluxInstance resource manages the lifecycle of the GitOps engine itself.
- Core Infrastructure: Synchronizes manifests from the foodbyte-gitops/infrastructure folder (Envoy Gateway, EBS StorageClass).
- Applications: Synchronizes HelmRelease manifests from the foodbyte-gitops/apps folder, linking back to the foodbyte-helm-charts repository for templates.

## Operational Standards
- Centralized Ingress: All routing rules are managed in infrastructure/gateway.yaml to prevent path collisions.
- Secret Management: Integrated with AWS Secrets Manager via the External Secrets Operator.
- Data Persistence: Configured to use Amazon EBS for stateful workloads.

## Bootstrap Sequence
1. Install the Flux Operator CLI.
2. Apply the FluxInstance manifest found in clusters/production/flux-system/instance.yaml.
3. Configure the GitHub authentication secret.
4. Flux will automatically reconcile the cluster state within 60 seconds of any commit.
