#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -o pipefail  # Catch errors in piped commands.
set -u  # Treat unset variables as an error.

echo "Setting Up GCP IAM Workload Identity for KinD Crossplane Control Plane..."

### Configure Required Variables
export GCP_PROJECT_ID="cxp-gcp"
export GCP_REGION="us-west4"

export WORKLOAD_IDENTITY_POOL="kind-cxp-wi-pool"
export WORKLOAD_IDENTITY_PROVIDER="kind-cxp-wi-provider"

export GCP_IAM_SERVICE_ACCOUNT="kind-crossplane-sa"
export GCP_IAM_SERVICE_ACCOUNT_EMAIL="${GCP_IAM_SERVICE_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

export KIND_K8S_NAMESPACE="crossplane-system"
export KIND_K8S_SERVICE_ACCOUNT="crossplane-sa"

echo "Environment Variables Configured."

### (1) Authenticate & Set Project
gcloud auth login --quiet
gcloud config set project $GCP_PROJECT_ID
echo "GCP authentication complete."

### (2) Enable Required GCP APIs
echo "Enabling GCP APIs..."
gcloud services enable \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    serviceusage.googleapis.com \
    cloudbilling.googleapis.com \
    sqladmin.googleapis.com \
    dns.googleapis.com \
    compute.googleapis.com \
    pubsub.googleapis.com \
    storage.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    secretmanager.googleapis.com \
    --project=$GCP_PROJECT_ID

echo "Required GCP APIs enabled."

### (3) Create IAM Service Account
echo "Creating GCP IAM Service Account..."
gcloud iam service-accounts create $GCP_IAM_SERVICE_ACCOUNT \
  --description="IAM Service Account for KinD Crossplane Workload Identity" \
  --display-name="KinD-CXP Workload ID" || true

echo "IAM Service Account Created: $GCP_IAM_SERVICE_ACCOUNT"

### (4) Assign Permissions to IAM Service Account
echo "Assigning IAM Roles to Service Account..."
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/iam.workloadIdentityUser" --quiet || true

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/secretmanager.secretAccessor" --quiet || true

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/resourcemanager.projectIamAdmin" --quiet || true

# NEW: Allow the user to impersonate this service account!
gcloud iam service-accounts add-iam-policy-binding $GCP_IAM_SERVICE_ACCOUNT_EMAIL \
  --member="user:wallick.tom@gmail.com" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --project=$GCP_PROJECT_ID --quiet || true

echo "IAM Roles Assigned."

### (5) Configure Workload Identity Federation
echo "Configuring Workload Identity Federation..."
gcloud iam workload-identity-pools create $WORKLOAD_IDENTITY_POOL \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --display-name="KinD-CXP Workload ID Pool" || true

gcloud iam workload-identity-pools providers create-oidc $WORKLOAD_IDENTITY_PROVIDER \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --workload-identity-pool=$WORKLOAD_IDENTITY_POOL \
  --display-name="KinD-CXP OIDC Provider" \
  --attribute-mapping="google.subject=assertion.sub" \
  --issuer-uri="https://container.googleapis.com/v1/projects/${GCP_PROJECT_ID}/locations/${GCP_REGION}/clusters/kind-crossplane-cluster" || true

echo "Workload Identity Federation Configured."

### (6) Associate KinD Kubernetes Service Account with Workload Identity
echo "Associating KinD Kubernetes Service Account with Workload Identity..."
gcloud iam service-accounts add-iam-policy-binding $GCP_IAM_SERVICE_ACCOUNT_EMAIL \
  --project=$GCP_PROJECT_ID \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/$GCP_PROJECT_ID/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL/attribute.google.subject/${KIND_K8S_SERVICE_ACCOUNT}" --quiet || true

kubectl annotate serviceaccount \
  --namespace $KIND_K8S_NAMESPACE $KIND_K8S_SERVICE_ACCOUNT \
  iam.gke.io/gcp-service-account=$GCP_IAM_SERVICE_ACCOUNT_EMAIL --overwrite || true

echo "KinD Kubernetes Service Account is now linked to Workload Identity!"

### Done
echo "KinD Crossplane IAM Setup Complete! The KinD Cluster is now ready to deploy Crossplane."
