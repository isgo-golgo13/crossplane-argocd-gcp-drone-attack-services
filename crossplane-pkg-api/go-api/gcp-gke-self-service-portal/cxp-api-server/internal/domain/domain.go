// internal/domain/domain.go
package domain

import (
	"time"
)

// ClusterType represents the type of cluster (EKS or Fargate)
type ClusterType string

const (
	// ClusterTypeEKS represents an EKS cluster with managed node groups
	ClusterTypeEKS ClusterType = "eks"
	// ClusterTypeFargate represents an EKS cluster with Fargate
	ClusterTypeFargate ClusterType = "fargate"
)

// ClusterStatus represents the status of a cluster
type ClusterStatus string

const (
	// ClusterStatusPending represents a cluster that is pending creation
	ClusterStatusPending ClusterStatus = "PENDING"
	// ClusterStatusProvisioning represents a cluster that is being provisioned
	ClusterStatusProvisioning ClusterStatus = "PROVISIONING"
	// ClusterStatusReady represents a cluster that is ready
	ClusterStatusReady ClusterStatus = "READY"
	// ClusterStatusFailed represents a cluster that failed to provision
	ClusterStatusFailed ClusterStatus = "FAILED"
)

// ClusterConfig represents configuration for creating a new cluster
type ClusterConfig struct {
	// Type of cluster (eks or fargate)
	Type string `json:"type"`
	// Name of the cluster
	Name string `json:"name"`
	// Namespace for the Crossplane XR Claim
	Namespace string `json:"namespace"`
	// Number of nodes (for EKS clusters)
	NodeCount int `json:"node_count,omitempty"`
	// AWS region
	Region string `json:"region"`
}

// ClusterDetails represents details about a cluster
type ClusterDetails struct {
	// Name of the cluster
	Name string `json:"name"`
	// Namespace where the cluster XR claim exists
	Namespace string `json:"namespace"`
	// Type of cluster (eks or fargate)
	Type string `json:"cluster_type"`
	// Current status (PENDING, PROVISIONING, READY, FAILED)
	Status string `json:"status"`
	// Unique identifier for the initial request
	RequestID string `json:"request_id"`
	// AWS region where the cluster is deployed
	Region string `json:"region"`
	// Number of nodes (for EKS clusters)
	NodeCount int `json:"node_count,omitempty"`
	// Kubeconfig for connecting to the cluster (when ready)
	Kubeconfig string `json:"kubeconfig,omitempty"`
	// When the cluster was created
	CreatedAt time.Time `json:"created_at"`
}
