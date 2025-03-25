variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy the cluster in"
  type        = string
  default     = "us-west4"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "crossplane-control-plane"
}

variable "gsa_name" {
  description = "Name of the Google Service Account (GSA)"
  type        = string
  default     = "gke-crossplane-sa"
}

variable "ksa_name" {
  description = "Name of the Kubernetes Service Account (KSA)"
  type        = string
  default     = "crossplane-sa"
}

variable "namespace" {
  description = "Namespace for the KSA"
  type        = string
  default     = "crossplane-system"
}

variable "gcp_secret_name" {
  description = "The name of the GCP Secret to grant access to"
  type        = string
  default     = "gcp-crossplane-creds"
}
