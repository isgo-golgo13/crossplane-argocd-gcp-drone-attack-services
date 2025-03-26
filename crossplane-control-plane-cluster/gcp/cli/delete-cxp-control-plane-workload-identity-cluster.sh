#!/usr/bin/env bash
set -euo pipefail

### === CONFIGURATION (MUST MATCH CREATE SCRIPT) === ###
PROJECT_ID="cxp-gcp"
REGION="us-west4"
CLUSTER_NAME="crossplane-control-plane"
GSA_NAME="gke-crossplane-sa"
NAMESPACE="crossplane-system"
KSA_NAME="crossplane-sa"
WORKLOAD_POOL="${PROJECT_ID}.svc.id.goog"

### Full GSA email
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Starting GCP cleanup for project: $PROJECT_ID"

### === STEP 1: Delete GKE Cluster === ###
echo "Deleting GKE cluster: $CLUSTER_NAME ..."
gcloud container clusters delete "$CLUSTER_NAME" \
  --region="$REGION" \
  --quiet || echo "Cluster already deleted or does not exist."

### === STEP 2: Remove IAM Policy Bindings from GSA === ###
echo "Removing IAM policy bindings from GSA..."
ROLES=(
  "roles/iam.workloadIdentityUser"
  "roles/container.admin"
  "roles/compute.admin"
  "roles/iam.serviceAccountUser"
)

for ROLE in "${ROLES[@]}"; do
  gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$GSA_EMAIL" \
    --role="$ROLE" \
    --quiet || true
done

### === STEP 3: Delete GSA (Service Account) === ###
echo "Deleting GCP IAM Service Account: $GSA_EMAIL ..."
gcloud iam service-accounts delete "$GSA_EMAIL" \
  --quiet || echo "Service account already deleted or not found."

### === STEP 4: Optionally Delete Workload Identity Pool and Provider (only if you created them) === ###
# If you created custom WIF resources in your create script, uncomment this:
# echo "🗑️ Deleting Workload Identity Pool and Provider..."
# gcloud iam workload-identity-pools delete crossplane-pool \
#   --location="global" \
#   --quiet || echo "WIF pool not found or already deleted."

### === STEP 5: Clean up local kubeconfig entries === ###
echo "Cleaning kubeconfig context..."
kubectl config delete-context "gke_${PROJECT_ID}_${REGION}_${CLUSTER_NAME}" || true
kubectl config unset "contexts.gke_${PROJECT_ID}_${REGION}_${CLUSTER_NAME}" || true
kubectl config unset "clusters.gke_${PROJECT_ID}_${REGION}_${CLUSTER_NAME}" || true
kubectl config unset "users.gke_${PROJECT_ID}_${REGION}_${CLUSTER_NAME}" || true

echo "GCP GKE + IAM cleanup complete. All traces removed."
