package cmd

import (
	"cxpcli/internal/config"
	"cxpcli/pkg/gke"
	"cxpcli/pkg/identity"
	"fmt"

	"github.com/spf13/cobra"
)

var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create GKE cluster with IAM Workload Identity",
	Run: func(cmd *cobra.Command, args []string) {
		cfg := config.LoadFromEnv()

		fmt.Println("Setting GCP project...")
		config.SetProject(cfg)

		fmt.Println("Enabling required GCP APIs...")
		config.EnableRequiredAPIs(cfg)

		fmt.Println("Creating GKE cluster...")
		gke.CreateCluster(cfg)

		fmt.Println("Getting credentials...")
		gke.GetCredentials(cfg)

		fmt.Println("Creating IAM service account...")
		identity.CreateGSA(cfg)

		fmt.Println("Creating K8s namespace & service account...")
		identity.CreateKSA(cfg)

		fmt.Println("Creating IAM policy binding...")
		identity.BindKSAtoGSA(cfg)

		fmt.Println("Annotating KSA with GSA...")
		identity.AnnotateKSA(cfg)

		fmt.Println("Setup complete. Ready to deploy Crossplane.")
	},
}
