build:
	cargo build --release

run:
	cargo run

lint:
	cargo fmt -- --check && cargo clippy -- -D warnings

security-check:
	cargo audit

docker-build:
	docker build -t drone-colony-dstar-gke .

docker-run:
	docker run --rm --user=drone --read-only drone-colony-dstar-gke

kube-lint:
	helm lint helm/
