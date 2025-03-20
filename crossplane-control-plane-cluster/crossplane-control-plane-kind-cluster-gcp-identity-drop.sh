#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -o pipefail  # Catch errors in piped commands.
set -u  # Treat unset variables as an error.

echo "Cleaning Up GCP IAM Workload Identity for KinD Crossplane Control Plane..."

### Configure Required Variables
export GCP_PROJECT_ID="cxp-gcp"
export GCP_REGION="us-west4"

export WORKLOAD_IDENTITY_POOL="kind-cxp-wi-pool"
export WORKLOAD_IDENTITY_PROVIDER="kind-cxp-wi-provider"

export GCP_IAM_SERVICE_ACCOUNT="kind-crossplane-sa"
export GCP_IAM_SERVICE_ACCOUNT_EMAIL="${GCP_IAM_SERVICE_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

export KIND_K8S_NAMESPACE="crossplane-system"
export KIND_K8S_SERVICE_ACCOUNT="crossplane-sa"

echo "Verifying Resources Prior To Deletion..."

### (1) Remove IAM Policy Bindings (Force Remove)
echo "Revoking IAM Roles from Service Account..."
gcloud projects remove-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/iam.workloadIdentityUser" --quiet || true

gcloud projects remove-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/secretmanager.secretAccessor" --quiet || true

gcloud projects remove-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/resourcemanager.projectIamAdmin" --quiet || true

echo "IAM Policy Bindings Removed."

### (2) Delete Workload Identity Provider (Force Remove)
echo "Deleting Workload Identity Provider..."
gcloud iam workload-identity-pools providers delete $WORKLOAD_IDENTITY_PROVIDER \
  --workload-identity-pool=$WORKLOAD_IDENTITY_POOL \
  --project=$GCP_PROJECT_ID \
  --location="global" --quiet || true

echo "Workload Identity Provider Deleted."

### (3) Delete Workload Identity Pool (Force Remove)
echo "Deleting Workload Identity Pool..."
gcloud iam workload-identity-pools delete $WORKLOAD_IDENTITY_POOL \
  --project=$GCP_PROJECT_ID \
  --location="global" --quiet || true

echo "Workload Identity Pool Deleted."

### (4) Delete GCP IAM Service Account (Force Remove)
echo "Deleting GCP IAM Service Account..."
gcloud iam service-accounts delete $GCP_IAM_SERVICE_ACCOUNT_EMAIL --quiet || true

echo "IAM Service Account Deleted."

### (5) Remove Kubernetes Service Account Annotations (Ensure Reset)
echo "Removing Kubernetes Service Account Annotations..."
kubectl annotate serviceaccount \
  --namespace $KIND_K8S_NAMESPACE $KIND_K8S_SERVICE_ACCOUNT \
  iam.gke.io/gcp-service-account- --overwrite || true

echo "Kubernetes Service Account Annotations Removed."

### (6) Final Verification of Cleanup
echo "Running Final Verification..."
gcloud iam workload-identity-pools list --location="global" || true
gcloud iam service-accounts list --filter="email:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" || true
kubectl get namespace $KIND_K8S_NAMESPACE || true

### Done
echo "ALL RESOURCES CLEANED UP! You are now ready for a fresh setup."
