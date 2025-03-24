package identity

import (
	"cxp-gcp-control-plane/internal/config"
	"fmt"
	"os/exec"
)

func CreateGSA(cfg config.Config) {
	exec.Command("gcloud", "iam", "service-accounts", "create", cfg.GSAName,
		"--description=GSA for Crossplane to use Workload Identity",
		"--display-name=Crossplane GSA").Run()
}

func CreateKSA(cfg config.Config) {
	exec.Command("kubectl", "create", "namespace", cfg.Namespace).Run()
	exec.Command("kubectl", "create", "serviceaccount", cfg.KSAName, "-n", cfg.Namespace).Run()
}

func BindKSAtoGSA(cfg config.Config) {
	member := fmt.Sprintf("serviceAccount:%s[%s/%s]", cfg.WorkloadPool, cfg.Namespace, cfg.KSAName)
	gsaEmail := fmt.Sprintf("%s@%s.iam.gserviceaccount.com", cfg.GSAName, cfg.ProjectID)

	exec.Command("gcloud", "iam", "service-accounts", "add-iam-policy-binding", gsaEmail,
		"--role=roles/iam.workloadIdentityUser",
		"--member", member).Run()
}

func AnnotateKSA(cfg config.Config) {
	gsaEmail := fmt.Sprintf("%s@%s.iam.gserviceaccount.com", cfg.GSAName, cfg.ProjectID)
	exec.Command("kubectl", "annotate", "serviceaccount", cfg.KSAName,
		"--namespace", cfg.Namespace,
		"iam.gke.io/gcp-service-account="+gsaEmail, "--overwrite").Run()
}
