module "gcp_crossplane_control_plane" {
  source = "../"

  project_id       = "cxp-gcp"
  region           = "us-west4"
  cluster_name     = "crossplane-control-plane"
  gsa_name         = "gke-crossplane-sa"
  ksa_name         = "crossplane-sa"
  namespace        = "crossplane-system"
  gcp_secret_name  = "gcp-crossplane-creds"
}
