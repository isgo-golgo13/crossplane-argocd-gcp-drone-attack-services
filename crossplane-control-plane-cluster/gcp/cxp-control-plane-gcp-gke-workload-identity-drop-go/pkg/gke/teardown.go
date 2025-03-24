package gke

import (
	"cxp-gcp-control-plane-drop/internal/config"
	"fmt"
	"os/exec"
)

func DeleteCluster(cfg config.Config) {
	exec.Command("gcloud", "container", "clusters", "delete", cfg.ClusterName,
		"--region", cfg.Region,
		"--quiet").Run()
}

func CleanupKubeconfig(cfg config.Config) {
	context := fmt.Sprintf("gke_%s_%s_%s", cfg.ProjectID, cfg.Region, cfg.ClusterName)

	exec.Command("kubectl", "config", "delete-context", context).Run()
	exec.Command("kubectl", "config", "unset", "contexts."+context).Run()
	exec.Command("kubectl", "config", "unset", "clusters."+context).Run()
	exec.Command("kubectl", "config", "unset", "users."+context).Run()
}
