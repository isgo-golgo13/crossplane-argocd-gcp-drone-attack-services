# Makefile for cxp-api-server

# Variables
BINARY_NAME=cxp-api-server
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
COMMIT_HASH=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -X main.CommitHash=$(COMMIT_HASH)"
GO_FILES=$(shell find . -type f -name '*.go' -not -path "./vendor/*")
GOBIN=$(shell go env GOPATH)/bin

# Tools
GOLINT=$(GOBIN)/golangci-lint
SWAG=$(GOBIN)/swag
MOCKERY=$(GOBIN)/mockery

# Default target
.PHONY: all
all: clean tools lint test build

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	rm -rf dist/
	rm -rf docs/swagger/

# Install development tools
.PHONY: tools
tools:
	@echo "Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/swaggo/swag/cmd/swag@latest
	go install github.com/vektra/mockery/v2@latest

# Run all linters
.PHONY: lint
lint:
	@echo "Running linters..."
	$(GOLINT) run

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	gofmt -s -w $(GO_FILES)

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	go test -race -coverprofile=coverage.txt -covermode=atomic ./...

# Run tests with coverage report
.PHONY: test-coverage
test-coverage: test
	@echo "Generating coverage report..."
	go tool cover -html=coverage.txt -o coverage.html

# Generate mocks for testing
.PHONY: mocks
mocks:
	@echo "Generating mocks..."
	$(MOCKERY) --all --keeptree --inpackage --case underscore

# Build for local development
.PHONY: build
build:
	@echo "Building binary..."
	mkdir -p bin
	CGO_ENABLED=0 go build $(LDFLAGS) -o bin/$(BINARY_NAME) ./svc/api

# Run locally
.PHONY: run
run: build
	@echo "Running API server..."
	./bin/$(BINARY_NAME)

# Cross-compile for multiple platforms
.PHONY: dist
dist:
	@echo "Creating distribution builds..."
	mkdir -p dist
	# Linux
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/$(BINARY_NAME)-linux-amd64 ./svc/api
	# macOS
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/$(BINARY_NAME)-darwin-amd64 ./svc/api
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/$(BINARY_NAME)-darwin-arm64 ./svc/api


# Build Docker image
.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	docker build -t $(BINARY_NAME):$(VERSION) -f Dockerfile .

# Generate Swagger documentation
.PHONY: swagger
swagger:
	@echo "Generating Swagger documentation..."
	$(SWAG) init -g ./svc/api/server.go -o ./docs/swagger

# Install the binary
.PHONY: install
install: build
	@echo "Installing binary..."
	cp ./bin/$(BINARY_NAME) $(GOBIN)/$(BINARY_NAME)

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all             : Clean, install tools, lint, test, and build"
	@echo "  clean           : Remove build artifacts"
	@echo "  tools           : Install development tools"
	@echo "  lint            : Run linters"
	@echo "  fmt             : Format code"
	@echo "  test            : Run tests"
	@echo "  test-coverage   : Run tests and generate coverage report"
	@echo "  mocks           : Generate mocks for testing"
	@echo "  build           : Build for local development"
	@echo "  run             : Build and run locally"
	@echo "  dist            : Cross-compile for multiple platforms"
	@echo "  docker-build    : Build Docker image"
	@echo "  swagger         : Generate Swagger documentation"
	@echo "  install         : Install the binary"
	@echo "  help            : Show this help message"

# Default to help if no target is specified
.DEFAULT_GOAL := help
