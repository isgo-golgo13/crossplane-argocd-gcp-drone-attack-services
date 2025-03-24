package identity

import (
	"cxp-gcp-control-plane-drop/internal/config"
	"fmt"
	"os/exec"
)

func RemoveIAMBindings(cfg config.Config) {
	gsaEmail := fmt.Sprintf("%s@%s.iam.gserviceaccount.com", cfg.GSAName, cfg.ProjectID)

	roles := []string{
		"roles/iam.workloadIdentityUser",
		"roles/container.admin",
		"roles/compute.admin",
		"roles/iam.serviceAccountUser",
	}

	for _, role := range roles {
		exec.Command("gcloud", "projects", "remove-iam-policy-binding", cfg.ProjectID,
			"--member=serviceAccount:"+gsaEmail,
			"--role="+role,
			"--quiet").Run()
	}
}

func DeleteGSA(cfg config.Config) {
	gsaEmail := fmt.Sprintf("%s@%s.iam.gserviceaccount.com", cfg.GSAName, cfg.ProjectID)
	exec.Command("gcloud", "iam", "service-accounts", "delete", gsaEmail, "--quiet").Run()
}
