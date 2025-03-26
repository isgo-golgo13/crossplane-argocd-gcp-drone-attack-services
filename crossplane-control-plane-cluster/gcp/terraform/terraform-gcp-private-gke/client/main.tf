
provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke_private_cluster" {
  source       = "../modules/gke-cluster"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
}

module "gke_cluster_proxy_host" {
  source     = "../modules/gke-cluster-proxy-host"
  project_id = var.project_id
  region     = var.region
  gsa_email  = "gke-crossplane-sa@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [module.gke_private_cluster]
}
