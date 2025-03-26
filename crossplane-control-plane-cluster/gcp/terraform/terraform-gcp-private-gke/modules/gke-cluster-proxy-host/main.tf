
resource "google_compute_instance" "proxy_host" {
  name         = "proxy-host"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y curl apt-transport-https ca-certificates gnupg
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    apt-get update && apt-get install -y google-cloud-sdk kubectl helm
  EOT

  service_account {
    email  = var.gsa_email
    scopes = ["cloud-platform"]
  }

  tags = ["proxy-host"]
}

output "proxy_host_ssh_command" {
  value = "gcloud compute ssh proxy-host --zone=${var.region}-a --project=${var.project_id}"
}
