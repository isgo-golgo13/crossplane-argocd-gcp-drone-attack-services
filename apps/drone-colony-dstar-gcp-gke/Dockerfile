# Build Stage
FROM rust:1.74 AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

# Runtime Stage
FROM gcr.io/distroless/cc
WORKDIR /app
COPY --from=builder /app/target/release/drone-colony-dstar-gcp-gke /app/
CMD ["/app/drone-colony-dstar-gcp-gke"]
