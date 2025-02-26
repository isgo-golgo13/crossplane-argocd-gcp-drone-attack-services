# Stage 1: Build Rust App
FROM rust:1.74 AS builder

WORKDIR /app

# Add dependencies separately to leverage Docker caching
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo fetch

# Copy source and build
COPY . .
RUN cargo build --release

# Stage 2: Strip Down & Optimize Binary
FROM gcr.io/distroless/cc AS runtime

WORKDIR /app

# Create non-root user
RUN adduser --system --no-create-home --group drone

# Copy compiled binary
COPY --from=builder /app/target/release/drone-colony-dstar-gcp-gke /app/

# Ensure the app runs as non-root
USER drone

# Enforce security best practices
ENTRYPOINT ["/app/drone-colony-dstar-gcp-gke"]
