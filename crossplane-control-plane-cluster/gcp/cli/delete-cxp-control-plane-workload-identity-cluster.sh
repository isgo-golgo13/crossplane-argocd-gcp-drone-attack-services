#!/usr/bin/env bash
set -euo pipefail

### === CONFIGURATION === ###
PROJECT_ID="cxp-gcp"
ZONE="us-west4-a"
CLUSTER_NAME="crossplane-control-plane"
GSA_NAME="gke-crossplane-sa"
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KUBECONFIG_CONTEXT="gke_${PROJECT_ID}_${ZONE}_${CLUSTER_NAME}"

echo "Starting GCP cleanup for project: $PROJECT_ID"

### === STEP 1: Delete GKE cluster === ###
echo "Deleting GKE cluster: $CLUSTER_NAME ..."
if gcloud container clusters describe "$CLUSTER_NAME" --zone="$ZONE" &>/dev/null; then
  gcloud container clusters delete "$CLUSTER_NAME" --zone="$ZONE" --quiet
else
  echo "Cluster already deleted or does not exist in zone '$ZONE'. Skipping."
fi

### === STEP 2: Delete GSA === ###
echo "Deleting GCP IAM Service Account: $GSA_EMAIL ..."
if gcloud iam service-accounts describe "$GSA_EMAIL" &>/dev/null; then
  gcloud iam service-accounts delete "$GSA_EMAIL" --quiet
else
  echo "GSA already deleted or does not exist. Skipping."
fi

### === STEP 3: Clean up kubeconfig context === ###
echo "Cleaning kubeconfig context..."
kubectl config delete-context "$KUBECONFIG_CONTEXT" 2>/dev/null || echo "Context not found, skipping."
kubectl config unset "contexts.$KUBECONFIG_CONTEXT" 2>/dev/null || true
kubectl config unset "clusters.$KUBECONFIG_CONTEXT" 2>/dev/null || true
kubectl config unset "users.$KUBECONFIG_CONTEXT" 2>/dev/null || true

### === DONE === ###
echo ""
echo "GCP GKE + IAM cleanup complete for '$CLUSTER_NAME'."
echo "All cluster traces, IAM bindings, and kubeconfig context removed (if they existed)."
