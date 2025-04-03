// internal/api/handlersproxy/log_handlers_proxy.go
package handlersproxy

import (
	"net/http"
	"time"

	"cxp-api-server/pkg/logger"

	"github.com/go-chi/chi/v5/middleware"
)

// LoggingMiddleware is middleware that logs HTTP requests
type LoggingMiddleware struct {
	logger logger.Logger
}

// NewLoggingMiddleware creates a new logging middleware
func NewLoggingMiddleware(logger logger.Logger) func(next http.Handler) http.Handler {
	return (&LoggingMiddleware{logger: logger}).Handler
}

// Handler implements the middleware pattern
func (m *LoggingMiddleware) Handler(next http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)

		requestID := middleware.GetReqID(r.Context())

		// Log request
		m.logger.Info("Request started",
			"request_id", requestID,
			"method", r.Method,
			"path", r.URL.Path,
			"remote_addr", r.RemoteAddr,
			"user_agent", r.UserAgent(),
		)

		defer func() {
			// Calculate request duration
			duration := time.Since(start)

			// Log response
			logFunc := m.logger.Info
			if ww.Status() >= 400 {
				logFunc = m.logger.Error
			}

			logFunc("Request completed",
				"request_id", requestID,
				"method", r.Method,
				"path", r.URL.Path,
				"status", ww.Status(),
				"bytes", ww.BytesWritten(),
				"duration", duration.String(),
			)
		}()

		next.ServeHTTP(ww, r)
	}

	return http.HandlerFunc(fn)
}
