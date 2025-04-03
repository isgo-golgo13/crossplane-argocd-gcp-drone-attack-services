package kubernetes

import (
	"fmt"
	"os"
	"path/filepath"

	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

// Client provides access to the Kubernetes API
type Client interface {
	// GetClientset returns a Kubernetes clientset
	GetClientset() (kubernetes.Interface, error)

	// GetDynamicClient returns a dynamic client for working with custom resources
	GetDynamicClient() (dynamic.Interface, error)
}

// ClientImpl implements the Client interface
type ClientImpl struct {
	kubeconfigPath string
	config         *rest.Config
}

// NewClient creates a new Kubernetes client
func NewClient(kubeconfigPath string) (Client, error) {
	client := &ClientImpl{
		kubeconfigPath: kubeconfigPath,
	}

	config, err := client.getConfig()
	if err != nil {
		return nil, err
	}

	client.config = config
	return client, nil
}

// getConfig returns a Kubernetes REST config
func (c *ClientImpl) getConfig() (*rest.Config, error) {
	if c.config != nil {
		return c.config, nil
	}

	// Try in-cluster config first
	config, err := rest.InClusterConfig()
	if err == nil {
		return config, nil
	}

	// Fall back to kubeconfig file
	kubeconfigPath := c.kubeconfigPath

	// If not specified, use default
	if kubeconfigPath == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return nil, fmt.Errorf("failed to get user home directory: %w", err)
		}
		kubeconfigPath = filepath.Join(home, ".kube", "config")
	}

	// Load the kubeconfig file
	config, err = clientcmd.BuildConfigFromFlags("", kubeconfigPath)
	if err != nil {
		return nil, fmt.Errorf("failed to build config from kubeconfig: %w", err)
	}

	return config, nil
}

// GetClientset returns a Kubernetes clientset
func (c *ClientImpl) GetClientset() (kubernetes.Interface, error) {
	config, err := c.getConfig()
	if err != nil {
		return nil, err
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create clientset: %w", err)
	}

	return clientset, nil
}

// GetDynamicClient returns a dynamic client for working with custom resources
func (c *ClientImpl) GetDynamicClient() (dynamic.Interface, error) {
	config, err := c.getConfig()
	if err != nil {
		return nil, err
	}

	dynamicClient, err := dynamic.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create dynamic client: %w", err)
	}

	return dynamicClient, nil
}
