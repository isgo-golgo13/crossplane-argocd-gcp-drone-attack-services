// svc/api/server.go
package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"cxp-api-server/internal/api/router"
	"cxp-api-server/internal/config"
	"cxp-api-server/internal/services"
	"cxp-api-server/pkg/logger"
)

// Version information (set during build)
var (
	Version    = "development"
	BuildTime  = "unknown"
	CommitHash = "unknown"
)

// @title Crossplane API Server
// @version 1.0.0
// @description API for provisioning and managing EKS clusters with Crossplane
// @contact.name DevOps Team
// @contact.email devops@example.com
// @license.name MIT
// @license.url https://opensource.org/licenses/MIT
// @host localhost:8080
// @BasePath /api
func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading configuration: %v\n", err)
		os.Exit(1)
	}

	// Initialize logger
	log := logger.NewLogger(cfg.LogLevel)
	log.Info("Starting Crossplane API Server",
		"version", Version,
		"build_time", BuildTime,
		"commit_hash", CommitHash,
	)

	// Initialize services
	clusterService := services.NewClusterService()

	// Initialize router
	r := router.NewRouter(clusterService, log)

	// Create HTTP server
	addr := fmt.Sprintf(":%d", cfg.Port)
	srv := &http.Server{
		Addr:         addr,
		Handler:      r,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Info("Server is listening", "addr", addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal("Server error", "error", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Info("Shutting down server...")

	// Create context with timeout for shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown server gracefully
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown", "error", err)
	}

	log.Info("Server exited properly")
}
