FROM rust:1.74 AS builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo fetch

COPY . .
RUN cargo build --release

FROM gcr.io/distroless/cc AS runtime
WORKDIR /app
RUN adduser --system --no-create-home --group drone
COPY --from=builder /app/target/release/drone-colony-dstar-gcp-cloud-run /app/
USER drone
ENTRYPOINT ["/app/drone-colony-dstar-gcp-cloud-run"]
