#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -o pipefail  # Catch errors in piped commands.
set -u  # Treat unset variables as an error.

echo "Setting up GCP Provider and GKE Cluster with existing Crossplane..."

### Configure Required Variables
export GCP_PROJECT_ID="cxp-gcp"
export GCP_REGION="us-west4"
export GCP_IAM_SERVICE_ACCOUNT="kind-crossplane-sa"
export GCP_IAM_SERVICE_ACCOUNT_EMAIL="${GCP_IAM_SERVICE_ACCOUNT}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
export PROJECT_DIR="/Users/countbrapcula/Projects/Crossplane/crossplane-argocd-gcp-drone-attack-services/crossplane-control-plane-cluster"
export KEY_PATH="${PROJECT_DIR}/key.json"

echo "Environment Variables Configured."
echo "Using project directory: ${PROJECT_DIR}"
echo "Key will be saved at: ${KEY_PATH}"

### (1) Ensure GCP API services are enabled
echo "Enabling GCP APIs..."
gcloud services enable \
    iam.googleapis.com \
    container.googleapis.com \
    compute.googleapis.com \
    --project=$GCP_PROJECT_ID

### (2) Create/Check IAM Service Account
echo "Creating GCP IAM Service Account..."
if ! gcloud iam service-accounts describe $GCP_IAM_SERVICE_ACCOUNT_EMAIL --project=$GCP_PROJECT_ID &> /dev/null; then
  gcloud iam service-accounts create $GCP_IAM_SERVICE_ACCOUNT \
    --description="IAM Service Account for Crossplane" \
    --display-name="Crossplane SA"
  echo "IAM Service Account Created: $GCP_IAM_SERVICE_ACCOUNT"
else
  echo "IAM Service Account $GCP_IAM_SERVICE_ACCOUNT already exists."
fi

### (3) Assign IAM Roles to Service Account
echo "Assigning IAM Roles to Service Account..."
# Need container.admin for creating GKE clusters
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/container.admin" --quiet || true

# Need compute.admin for creating compute resources
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/compute.admin" --quiet || true

# Need iam.serviceAccountUser for GKE nodes
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$GCP_IAM_SERVICE_ACCOUNT_EMAIL" \
  --role="roles/iam.serviceAccountUser" --quiet || true

echo "IAM Roles Assigned."

### (4) Create service account key
echo "Creating service account key..."
gcloud iam service-accounts keys create ${KEY_PATH} \
  --iam-account=$GCP_IAM_SERVICE_ACCOUNT_EMAIL

### (5) Install GCP Provider
echo "Installing GCP provider for Crossplane..."
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-gcp
spec:
  package: "crossplane/provider-gcp:v0.21.0"
EOF

echo "Waiting for GCP provider to be installed..."
# Wait for the provider to be installed
kubectl wait --for=condition=healthy --timeout=180s provider.pkg.crossplane.io/provider-gcp || true

### (6) Create Kubernetes secret with GCP credentials
echo "Creating Kubernetes secret with GCP credentials..."
kubectl create secret generic gcp-creds \
  --namespace crossplane-system \
  --from-file=creds=${KEY_PATH} \
  --dry-run=client -o yaml | kubectl apply -f -

### (7) Create ProviderConfig
echo "Creating GCP ProviderConfig..."
cat <<EOF | kubectl apply -f -
apiVersion: gcp.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: ${GCP_PROJECT_ID}
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: gcp-creds
      key: creds
EOF

### (8) Create minimal GKE cluster definition
echo "Creating minimal GKE cluster definition..."
cat <<EOF > ${PROJECT_DIR}/gke-cluster.yaml
apiVersion: container.gcp.crossplane.io/v1beta1
kind: Cluster
metadata:
  name: minimal-gke-cluster
spec:
  forProvider:
    location: ${GCP_REGION}-a
    initialClusterVersion: "1.24"
    # Minimal configuration to save costs
    nodeConfig:
      machineType: e2-small
      diskSizeGb: 50
      diskType: pd-standard
      oauthScopes:
        - https://www.googleapis.com/auth/devstorage.read_only
        - https://www.googleapis.com/auth/logging.write
        - https://www.googleapis.com/auth/monitoring
    nodePools:
      - name: default-pool
        initialNodeCount: 1
  providerConfigRef:
    name: default
  writeConnectionSecretToRef:
    namespace: default
    name: gke-creds
EOF

echo "===================================="
echo "Setup complete! To create your minimal GKE cluster, run:"
echo "kubectl apply -f ${PROJECT_DIR}/gke-cluster.yaml"
echo ""
echo "You can track provisioning with:"
echo "kubectl get cluster.container.gcp.crossplane.io minimal-gke-cluster -o yaml"
echo ""
echo "To clean up and avoid charges:"
echo "kubectl delete cluster.container.gcp.crossplane.io minimal-gke-cluster"
echo "===================================="