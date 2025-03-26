#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PROJECT_ID="cxp-gcp"
CLUSTER_NAME="crossplane-control-plane"
ZONE="us-west4-a"

echo "Enabling public endpoint for GKE cluster '$CLUSTER_NAME'..."

gcloud container clusters update "$CLUSTER_NAME" \
  --project "$PROJECT_ID" \
  --zone "$ZONE" \
  --enable-public-endpoint

echo "Public endpoint is now enabled."
echo "You can now run 'kubectl' and 'helm' commands against your private GKE cluster."
echo "Remember to disable it when you're done for better security."
