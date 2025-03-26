#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PROJECT_ID="cxp-gcp"
CLUSTER_NAME="crossplane-control-plane"
ZONE="us-west4-a"

echo "Fetching kubeconfig for public GKE cluster '$CLUSTER_NAME'..."

# This command is all you need for public clusters to connect locally
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --project "$PROJECT_ID" \
  --zone "$ZONE"

echo "Kubeconfig updated. You can now run 'kubectl' and 'helm' commands against your public GKE
