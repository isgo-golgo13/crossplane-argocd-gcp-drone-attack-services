build:
	cargo build --release

run:
	cargo run

lint:
	cargo fmt -- --check && cargo clippy -- -D warnings

security-check:
	cargo audit

docker-build:
	docker build -t gcr.io/cp-gcp-drone-svcs-project/drone-colony-dstar-gcp-cloud-run .

docker-push:
	docker push gcr.io/cp-gcp-drone-svcs-project/drone-colony-dstar-gcp-cloud-run

deploy-cloudrun:
	gcloud run deploy drone-ai \
		--image=gcr.io/cp-gcp-drone-svcs-project/drone-colony-dstar-gcp-cloud-run \
		--platform=managed \
		--region=us-west4 \
		--allow-unauthenticated
