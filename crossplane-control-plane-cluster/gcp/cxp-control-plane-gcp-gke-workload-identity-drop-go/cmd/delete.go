package cmd

import (
	"cxp-gcp-control-plane-drop/internal/config"
	"cxp-gcp-control-plane-drop/pkg/gke"
	"cxp-gcp-control-plane-drop/pkg/identity"
	"fmt"

	"github.com/spf13/cobra"
)

var deleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "Deletes GKE cluster and GCP IAM bindings created for Crossplane",
	Run: func(cmd *cobra.Command, args []string) {
		cfg := config.LoadFromEnv()

		fmt.Println("Deleting GKE cluster...")
		gke.DeleteCluster(cfg)

		fmt.Println("Removing IAM policy bindings...")
		identity.RemoveIAMBindings(cfg)

		fmt.Println("Deleting GCP IAM Service Account...")
		identity.DeleteGSA(cfg)

		fmt.Println("Cleaning kubeconfig context...")
		gke.CleanupKubeconfig(cfg)

		fmt.Println("Teardown complete. All traces removed.")
	},
}
