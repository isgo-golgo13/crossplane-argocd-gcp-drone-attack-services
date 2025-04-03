// internal/api/handlers/handlers.go
package handlers

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"regexp"

	"github.com/go-chi/chi/v5"

	"cxp-api-server/internal/domain"
	"cxp-api-server/internal/services"
	"cxp-api-server/pkg/logger"
)

// ClusterHandler handles HTTP requests for EKS clusters
type ClusterHandler struct {
	clusterService services.ClusterService
	logger         logger.Logger
}

// NewClusterHandler creates a new ClusterHandler
func NewClusterHandler(clusterService services.ClusterService, logger logger.Logger) *ClusterHandler {
	return &ClusterHandler{
		clusterService: clusterService,
		logger:         logger,
	}
}

// ErrorResponse represents an API error response
type ErrorResponse struct {
	Error   string `json:"error"`
	Details string `json:"details,omitempty"`
}

// CreateClusterRequest represents a request to create a cluster
type CreateClusterRequest struct {
	ClusterType string `json:"cluster_type"`
	ClusterName string `json:"cluster_name"`
	NodeCount   *int   `json:"node_count,omitempty"`
	Region      string `json:"region"`
}

// CreateClusterResponse represents a response with the created cluster info
type CreateClusterResponse struct {
	RequestID string `json:"request_id"`
	Status    string `json:"status"`
	Message   string `json:"message,omitempty"`
}

// validateCreateRequest validates the create cluster request
func validateCreateRequest(req CreateClusterRequest) error {
	// Validate cluster type
	if req.ClusterType != "eks" && req.ClusterType != "fargate" {
		return fmt.Errorf("cluster_type must be either 'eks' or 'fargate'")
	}

	// Validate cluster name
	if req.ClusterName == "" {
		return fmt.Errorf("cluster_name is required")
	}
	if len(req.ClusterName) < 3 || len(req.ClusterName) > 40 {
		return fmt.Errorf("cluster_name must be between 3 and 40 characters")
	}
	matched, _ := regexp.MatchString("^[a-z0-9-]+$", req.ClusterName)
	if !matched {
		return fmt.Errorf("cluster_name must contain only lowercase letters, numbers, and hyphens")
	}

	// Validate node count for EKS clusters
	if req.ClusterType == "eks" {
		if req.NodeCount == nil {
			return fmt.Errorf("node_count is required for EKS clusters")
		}
		if *req.NodeCount < 1 || *req.NodeCount > 10 {
			return fmt.Errorf("node_count must be between 1 and 10")
		}
	}

	// Validate region
	if req.Region == "" {
		return fmt.Errorf("region is required")
	}
	// Add more region validation if needed

	return nil
}

// writeError writes an error response
func (h *ClusterHandler) writeError(w http.ResponseWriter, status int, message string, details string) {
	resp := ErrorResponse{
		Error:   message,
		Details: details,
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		h.logger.Error("Failed to encode error response", "error", err)
	}
}

// CreateCluster handles creating a new EKS cluster
// @Summary Create a new cluster
// @Description Creates a new EKS or Fargate cluster with the given configuration
// @Tags clusters
// @Accept json
// @Produce json
// @Param request body CreateClusterRequest true "Cluster configuration"
// @Success 202 {object} CreateClusterResponse
// @Failure 400 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/clusters [post]
func (h *ClusterHandler) CreateCluster(w http.ResponseWriter, r *http.Request) {
	var req CreateClusterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Error("Failed to decode request", "error", err)
		h.writeError(w, http.StatusBadRequest, "Invalid request format", "")
		return
	}

	// Validate request
	if err := validateCreateRequest(req); err != nil {
		h.logger.Error("Invalid request", "error", err)
		h.writeError(w, http.StatusBadRequest, err.Error(), "")
		return
	}

	// Create cluster configuration
	nodeCount := 0
	if req.NodeCount != nil {
		nodeCount = *req.NodeCount
	}

	config := domain.ClusterConfig{
		Type:      req.ClusterType,
		Name:      req.ClusterName,
		Region:    req.Region,
		NodeCount: nodeCount,
		Namespace: "appx", // Using default namespace for now
	}

	// Create the cluster
	requestID, err := h.clusterService.CreateCluster(r.Context(), config)
	if err != nil {
		h.logger.Error("Failed to create cluster", "error", err)
		h.writeError(w, http.StatusInternalServerError, "Failed to provision cluster", "")
		return
	}

	// Create response
	resp := CreateClusterResponse{
		RequestID: requestID.String(),
		Status:    "PROVISIONING",
		Message:   "Cluster provisioning has been initiated",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		h.logger.Error("Failed to encode response", "error", err)
	}
}

// GetCluster handles retrieving a specific EKS cluster
// @Summary Get a cluster by name
// @Description Retrieve details about a specific cluster by its name
// @Tags clusters
// @Accept json
// @Produce json
// @Param name path string true "Cluster name"
// @Success 200 {object} domain.ClusterDetails
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/clusters/{name} [get]
func (h *ClusterHandler) GetCluster(w http.ResponseWriter, r *http.Request) {
	clusterName := chi.URLParam(r, "name")
	if clusterName == "" {
		h.writeError(w, http.StatusBadRequest, "Cluster name is required", "")
		return
	}

	// Get cluster from service
	cluster, err := h.clusterService.GetCluster(r.Context(), "appx", clusterName)
	if err != nil {
		if errors.Is(err, services.ErrClusterNotFound) {
			h.writeError(w, http.StatusNotFound, "Cluster not found", "")
		} else {
			h.logger.Error("Failed to get cluster", "error", err)
			h.writeError(w, http.StatusInternalServerError, "Failed to retrieve cluster details", "")
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(cluster); err != nil {
		h.logger.Error("Failed to encode response", "error", err)
	}
}

// ListClusters handles retrieving all EKS clusters
// @Summary List all clusters
// @Description Retrieve a list of all clusters in the namespace
// @Tags clusters
// @Accept json
// @Produce json
// @Success 200 {array} domain.ClusterDetails
// @Failure 500 {object} ErrorResponse
// @Router /api/clusters [get]
func (h *ClusterHandler) ListClusters(w http.ResponseWriter, r *http.Request) {
	// Get clusters from service
	clusters, err := h.clusterService.ListClusters(r.Context(), "appx")
	if err != nil {
		h.logger.Error("Failed to list clusters", "error", err)
		h.writeError(w, http.StatusInternalServerError, "Failed to list clusters", "")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(clusters); err != nil {
		h.logger.Error("Failed to encode response", "error", err)
	}
}

// DeleteCluster handles deleting an EKS cluster
// @Summary Delete a cluster
// @Description Delete a specific cluster by its name
// @Tags clusters
// @Accept json
// @Produce json
// @Param name path string true "Cluster name"
// @Success 204 "No content"
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/clusters/{name} [delete]
func (h *ClusterHandler) DeleteCluster(w http.ResponseWriter, r *http.Request) {
	clusterName := chi.URLParam(r, "name")
	if clusterName == "" {
		h.writeError(w, http.StatusBadRequest, "Cluster name is required", "")
		return
	}

	// Delete cluster
	err := h.clusterService.DeleteCluster(r.Context(), "appx", clusterName)
	if err != nil {
		if errors.Is(err, services.ErrClusterNotFound) {
			h.writeError(w, http.StatusNotFound, "Cluster not found", "")
		} else {
			h.logger.Error("Failed to delete cluster", "error", err)
			h.writeError(w, http.StatusInternalServerError, "Failed to delete cluster", "")
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// HealthResponse represents the health check response
type HealthResponse struct {
	Status  string `json:"status"`
	Version string `json:"version"`
}

// Health handles the health check endpoint
// @Summary Health check endpoint
// @Description Returns a 200 OK if the API is running properly
// @Tags health
// @Accept json
// @Produce json
// @Success 200 {object} HealthResponse
// @Router /api/health [get]
func (h *ClusterHandler) Health(w http.ResponseWriter, r *http.Request) {
	resp := HealthResponse{
		Status:  "ok",
		Version: "1.0.0", // Would come from build info in a real implementation
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		h.logger.Error("Failed to encode response", "error", err)
	}
}
