#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Catch errors in piped commands
set -u  # Treat unset variables as an error

echo "Checking if GCP IAM Workload Identity resources still exist..."

# Define variables
GCP_PROJECT_ID="cxp-gcp"
WORKLOAD_IDENTITY_POOL="kind-cxp-wi-pool"
WORKLOAD_IDENTITY_PROVIDER="kind-cxp-wi-provider"
GCP_IAM_SERVICE_ACCOUNT="kind-crossplane-sa"
GCP_IAM_SERVICE_ACCOUNT_EMAIL="${GCP_IAM_SERVICE_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
KIND_K8S_NAMESPACE="crossplane-system"

echo "Checking Workload Identity Pool..."
gcloud iam workload-identity-pools list --location="global" --format="table(name, state)" || echo "No Workload Identity Pools found."

echo "Checking Workload Identity Provider..."
gcloud iam workload-identity-pools providers list --workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" --location="global" --format="table(name, state)" || echo "No Workload Identity Providers found."

echo "Checking IAM Service Account..."
gcloud iam service-accounts list --filter="email:${GCP_IAM_SERVICE_ACCOUNT_EMAIL}" --format="table(email, disabled)" || echo "IAM Service Account not found."

echo "Checking Kubernetes Namespace..."
kubectl get ns ${KIND_K8S_NAMESPACE} || echo "Namespace ${KIND_K8S_NAMESPACE} not found."

echo "Verification complete. If no resources are listed, everything is clean."
