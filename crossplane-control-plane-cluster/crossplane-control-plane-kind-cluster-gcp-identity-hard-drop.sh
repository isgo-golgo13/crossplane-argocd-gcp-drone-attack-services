#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -o pipefail  # Catch errors in piped commands.
set -u  # Treat unset variables as an error.

echo "Resetting GCP IAM Workload Identity for KinD Crossplane Control Plane..."

### Configure Required Variables
export GCP_PROJECT_ID="cxp-gcp"
export GCP_REGION="us-west4"

export WORKLOAD_IDENTITY_POOL="kind-cxp-wi-pool"
export WORKLOAD_IDENTITY_PROVIDER="kind-cxp-wi-provider"

export GCP_IAM_SERVICE_ACCOUNT="kind-crossplane-sa"
export GCP_IAM_SERVICE_ACCOUNT_EMAIL="${GCP_IAM_SERVICE_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

echo "Verifying Existing Resources Before Deletion..."

### (1) Assign IAM Role to Allow Service Account Deletion
echo "Granting 'iam.serviceAccountAdmin' role to user for deletion rights..."
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="user:$(gcloud config get-value core/account)" \
  --role="roles/iam.serviceAccountAdmin" --quiet || true

### (2) Revoke IAM Roles from Service Account
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

### (3) Delete Workload Identity Provider
echo "Deleting Workload Identity Provider..."
gcloud iam workload-identity-pools providers delete $WORKLOAD_IDENTITY_PROVIDER \
  --workload-identity-pool=$WORKLOAD_IDENTITY_POOL \
  --project=$GCP_PROJECT_ID \
  --location="global" --quiet || true

echo "Workload Identity Provider Deleted."

### (4) Delete Workload Identity Pool
echo "Deleting Workload Identity Pool..."
gcloud iam workload-identity-pools delete $WORKLOAD_IDENTITY_POOL \
  --project=$GCP_PROJECT_ID \
  --location="global" --quiet || true

echo "Workload Identity Pool Deleted."

### (5) Delete GCP IAM Service Account
echo "Deleting GCP IAM Service Account..."
gcloud iam service-accounts delete $GCP_IAM_SERVICE_ACCOUNT_EMAIL --quiet || true

echo "IAM Service Account Deleted."

### (6) Remove Temporary IAM Role
echo "Removing 'iam.serviceAccountAdmin' role from user (for security)..."
gcloud projects remove-iam-policy-binding $GCP_PROJECT_ID \
  --member="user:$(gcloud config get-value core/account)" \
  --role="roles/iam.serviceAccountAdmin" --quiet || true

echo "IAM Role Revoked."

### Done
echo "ALL RESOURCES CLEANED UP! You are now ready for a fresh setup."
