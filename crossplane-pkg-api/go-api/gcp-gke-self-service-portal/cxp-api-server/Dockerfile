# Build stage
FROM golang:1.22-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build with version information
ARG VERSION=development
ARG BUILD_TIME=unknown
ARG COMMIT_HASH=unknown

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME} -X main.CommitHash=${COMMIT_HASH}" \
    -o cxp-api-server ./svc/api

# Final stage
FROM alpine:3.19

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create app directory with correct permissions
WORKDIR /app
RUN chown appuser:appgroup /app

# Copy the binary from builder stage
COPY --from=builder --chown=appuser:appgroup /app/cxp-api-server /app/
COPY --from=builder --chown=appuser:appgroup /app/api/openapi.yaml /app/api/

# Use non-root user
USER appuser

# Expose API port
EXPOSE 8080

# Set environment variables
ENV PORT=8080
ENV LOG_LEVEL=info
ENV DEFAULT_NAMESPACE=appx

# Run the application
ENTRYPOINT ["/app/cxp-api-server"]
