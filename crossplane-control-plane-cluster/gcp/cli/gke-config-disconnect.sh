#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PROJECT_ID="cxp-gcp"
CLUSTER_NAME="crossplane-control-plane"
ZONE="us-west4-a"

echo "Disabling public endpoint for GKE cluster '$CLUSTER_NAME'..."

gcloud container clusters update "$CLUSTER_NAME" \
  --project "$PROJECT_ID" \
  --zone "$ZONE" \
  --no-enable-public-endpoint

echo "Public endpoint has been disabled."
echo "Cluster is now only accessible via internal VPC or private networking."
