# GitFlow CLI for Crossplane

The following section provides a headless CLI API provisioning GCP resources indirectly to Git to
trigger ArgoCD to provision requested Crossplane GCP resources to GCP.

## Workflow for GitFlow CLI for Crossplane Claims Resource Requests

```shell
cd crossplane-pkg/crossplane-pkg-request-cli
cargo run -- request --project-name drone-colony --gke --cloudrun --spanner --firestore
```
