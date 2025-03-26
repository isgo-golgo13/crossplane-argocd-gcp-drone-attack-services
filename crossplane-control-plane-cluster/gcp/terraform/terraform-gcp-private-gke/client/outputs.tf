
output "gke_cluster_name" {
  value = module.gke_private_cluster.google_container_cluster.private_gke.name
}

output "bastion_ssh" {
  value = module.bastion_host.bastion_ssh_command
}
