package gke

import (
	"cxpcli/internal/config"
	"os/exec"
)

func CreateCluster(cfg config.Config) {
	cmd := exec.Command("gcloud", "container", "clusters", "create", cfg.ClusterName,
		"--region", cfg.Region,
		"--release-channel=regular",
		"--enable-ip-alias",
		"--enable-private-nodes",
		"--enable-private-endpoint",
		"--enable-shielded-nodes",
		"--workload-pool", cfg.WorkloadPool,
		"--enable-autoupgrade",
		"--enable-autorepair",
		"--no-enable-basic-auth",
		"--no-issue-client-certificate",
		"--metadata=disable-legacy-endpoints=true",
	)
	cmd.Run()
}

func GetCredentials(cfg config.Config) {
	exec.Command("gcloud", "container", "clusters", "get-credentials", cfg.ClusterName,
		"--region", cfg.Region).Run()
}
