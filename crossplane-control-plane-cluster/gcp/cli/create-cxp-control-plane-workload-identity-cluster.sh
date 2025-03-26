#!/usr/bin/env bash
set -euo pipefail

### === CONFIGURATION === ###
PROJECT_ID="cxp-gcp"
REGION="us-west4"
ZONE="${REGION}-a"
CLUSTER_NAME="crossplane-control-plane"
GSA_NAME="gke-crossplane-sa"
KSA_NAME="crossplane-sa"
NAMESPACE="crossplane-system"
WORKLOAD_POOL="${PROJECT_ID}.svc.id.goog"
WORKLOAD_IDENTITY_POOL="crossplane-pool"
WORKLOAD_IDENTITY_PROVIDER="crossplane-provider"
GCP_SECRET_NAME="gcp-crossplane-creds"  # Must exist in GCP Secret Manager

### === STEP 1: Set Project === ###
echo "Setting GCP project..."
gcloud config set project "$PROJECT_ID"

### === STEP 2: Enable Required APIs === ###
echo "Enabling required GCP APIs..."
gcloud services enable container.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    secretmanager.googleapis.com

### === STEP 3: Create GKE Public Cluster (Min Spec) === ###
echo "Creating public GKE cluster (min-spec, no SSD overages): $CLUSTER_NAME"
gcloud container clusters create "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --release-channel=regular \
    --enable-ip-alias \
    --enable-shielded-nodes \
    --disk-type=pd-standard \
    --disk-size=50 \
    --num-nodes=1 \
    --workload-pool="$WORKLOAD_POOL" \
    --enable-autoupgrade \
    --enable-autorepair \
    --no-enable-basic-auth \
    --no-issue-client-certificate \
    --metadata disable-legacy-endpoints=true

echo "GKE cluster created."

### === STEP 4: Get kubeconfig === ###
echo "Getting kubeconfig for GKE cluster..."
gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --zone "$ZONE"

### === STEP 5: Create GCP IAM Service Account (GSA) === ###
echo "Creating GCP IAM Service Account: $GSA_NAME"
gcloud iam service-accounts create "$GSA_NAME" \
    --description="GSA for Crossplane to use Workload Identity" \
    --display-name="Crossplane GSA"

### === STEP 6: Create Kubernetes Namespace & Service Account === ###
echo "Creating namespace and KSA: $KSA_NAME"
kubectl create namespace "$NAMESPACE" || true
kubectl create serviceaccount "$KSA_NAME" -n "$NAMESPACE" || true

### === STEP 7: Allow KSA to impersonate GSA === ###
GSA_EMAIL="$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
MEMBER="serviceAccount:$WORKLOAD_POOL[$NAMESPACE/$KSA_NAME]"

echo "Allowing KSA to impersonate GSA..."
gcloud iam service-accounts add-iam-policy-binding "$GSA_EMAIL" \
  --role="roles/iam.workloadIdentityUser" \
  --member="$MEMBER"

### === STEP 8: Annotate KSA with GSA === ###
echo "Annotating KSA with GSA email..."
kubectl annotate serviceaccount "$KSA_NAME" \
  --namespace "$NAMESPACE" \
  iam.gke.io/gcp-service-account="$GSA_EMAIL" --overwrite

### === STEP 9: Grant GSA access to Secret Manager secret === ###
echo "Granting GSA access to GCP Secret Manager secret: $GCP_SECRET_NAME"
gcloud secrets add-iam-policy-binding "$GCP_SECRET_NAME" \
  --member="serviceAccount:$GSA_EMAIL" \
  --role="roles/secretmanager.secretAccessor" \
  --project="$PROJECT_ID"

### === DONE === ###
echo ""
echo "Workload Identity binding and secret access are complete."
echo "GKE public cluster '$CLUSTER_NAME' created successfully in zone '$ZONE'."
echo ""
echo "You can now deploy the Helm chart using:"
echo ""
echo "  helm install crossplane-gcp-control-plane ./crossplane-gcp-control-plane \\"
echo "    --namespace crossplane-system \\"
echo "    -f values-gcp-nonprod.yaml"
