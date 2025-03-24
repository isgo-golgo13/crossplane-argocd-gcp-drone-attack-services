# Build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o cxpcli-drop main.go

# Runtime
FROM alpine:latest
RUN adduser -D appuser
USER appuser
WORKDIR /home/appuser
COPY --from=builder /app/cxpcli-drop .
ENTRYPOINT ["./cxpcli-drop"]
