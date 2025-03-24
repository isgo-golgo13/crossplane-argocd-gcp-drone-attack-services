package config

import (
	"fmt"
	"os"
	"os/exec"
)

type Config struct {
	ProjectID    string
	Region       string
	ClusterName  string
	GSAName      string
	KSAName      string
	Namespace    string
	WorkloadPool string
}

func LoadFromEnv() Config {
	project := os.Getenv("GCP_PROJECT_ID")
	region := os.Getenv("GCP_REGION")
	cluster := os.Getenv("GCP_CLUSTER_NAME")
	gsa := os.Getenv("GCP_GSA_NAME")
	ksa := os.Getenv("GCP_KSA_NAME")
	ns := os.Getenv("GCP_NAMESPACE")

	if project == "" || region == "" || cluster == "" || gsa == "" || ksa == "" || ns == "" {
		fmt.Println("Missing required environment variables.")
		os.Exit(1)
	}

	return Config{
		ProjectID:    project,
		Region:       region,
		ClusterName:  cluster,
		GSAName:      gsa,
		KSAName:      ksa,
		Namespace:    ns,
		WorkloadPool: fmt.Sprintf("%s.svc.id.goog", project),
	}
}

func SetProject(cfg Config) {
	exec.Command("gcloud", "config", "set", "project", cfg.ProjectID).Run()
}

func EnableRequiredAPIs(cfg Config) {
	exec.Command("gcloud", "services", "enable",
		"container.googleapis.com",
		"iam.googleapis.com",
		"iamcredentials.googleapis.com",
		"cloudresourcemanager.googleapis.com",
	).Run()
}
