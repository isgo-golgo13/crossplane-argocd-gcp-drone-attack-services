// internal/config/config.go
package config

import (
	"os"
	"strconv"
)

// Config holds the application configuration
type Config struct {
	// Port for the HTTP server
	Port int

	// Logging level
	LogLevel string

	// Path to kubeconfig file
	KubeconfigPath string

	// Default namespace
	DefaultNamespace string

	// CORS allowed origins
	CorsAllowedOrigins []string
}

// LoadConfig loads configuration from environment variables
func LoadConfig() (*Config, error) {
	// Default configuration
	cfg := &Config{
		Port:               8080,
		LogLevel:           "info",
		KubeconfigPath:     "",
		DefaultNamespace:   "appx",
		CorsAllowedOrigins: []string{"*"},
	}

	// Override with environment variables
	if port := os.Getenv("PORT"); port != "" {
		if p, err := strconv.Atoi(port); err == nil {
			cfg.Port = p
		}
	}

	if logLevel := os.Getenv("LOG_LEVEL"); logLevel != "" {
		cfg.LogLevel = logLevel
	}

	if kubeconfigPath := os.Getenv("KUBECONFIG"); kubeconfigPath != "" {
		cfg.KubeconfigPath = kubeconfigPath
	}

	if namespace := os.Getenv("DEFAULT_NAMESPACE"); namespace != "" {
		cfg.DefaultNamespace = namespace
	}

	if cors := os.Getenv("CORS_ALLOWED_ORIGINS"); cors != "" {
		cfg.CorsAllowedOrigins = []string{cors}
	}

	return cfg, nil
}
