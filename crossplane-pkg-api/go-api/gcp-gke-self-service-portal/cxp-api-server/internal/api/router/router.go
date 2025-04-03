// internal/api/router/router.go
package router

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	httpSwagger "github.com/swaggo/http-swagger"

	"cxp-api-server/internal/api/handlers"
	"cxp-api-server/internal/api/handlersproxy"
	"cxp-api-server/internal/services"
	"cxp-api-server/pkg/logger"
)

// NewRouter creates a new HTTP router
func NewRouter(clusterService services.ClusterService, logger logger.Logger) http.Handler {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(handlersproxy.NewLoggingMiddleware(logger))
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))

	// CORS configuration
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	// Create handlers
	clusterHandler := handlers.NewClusterHandler(clusterService, logger)

	// API routes
	r.Route("/api", func(r chi.Router) {
		// Cluster endpoints
		r.Route("/clusters", func(r chi.Router) {
			r.Get("/", clusterHandler.ListClusters)
			r.Post("/", clusterHandler.CreateCluster)
			r.Get("/{name}", clusterHandler.GetCluster)
			r.Delete("/{name}", clusterHandler.DeleteCluster)
		})

		// Health endpoint
		r.Get("/health", clusterHandler.Health)
	})

	// Swagger documentation
	r.Get("/swagger/*", httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"), // The URL pointing to API definition
	))

	return r
}
