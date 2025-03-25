output "kubeconfig_command" {
  description = "Command to fetch kubeconfig for the new cluster"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region}"
}
