# Build stage
FROM golang:1.21-alpine as builder
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o cxpcli main.go

# Runtime stage
FROM alpine:latest
RUN adduser -D appuser
USER appuser
WORKDIR /home/appuser
COPY --from=builder /app/cxpcli .
ENTRYPOINT ["./cxpcli"]
