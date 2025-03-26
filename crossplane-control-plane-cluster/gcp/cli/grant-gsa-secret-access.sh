#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
GSA_NAME="gke-crossplane-sa"
PROJECT_ID="cxp-gcp"
GCP_SECRET_NAME="gcp-crossplane-creds"

GSA_EMAIL="$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "Granting GSA '$GSA_EMAIL' access to Secret Manager secret '$GCP_SECRET_NAME'..."

gcloud secrets add-iam-policy-binding "$GCP_SECRET_NAME" \
  --member="serviceAccount:$GSA_EMAIL" \
  --role="roles/secretmanager.secretAccessor" \
  --project="$PROJECT_ID"

echo "GSA access to secret granted successfully."
