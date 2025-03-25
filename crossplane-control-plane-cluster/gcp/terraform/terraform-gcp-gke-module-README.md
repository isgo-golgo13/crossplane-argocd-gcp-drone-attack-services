## GCP GKE Terraform Module 

Pre-Step to Connect to the Cluster

```shell
gcloud container clusters get-credentials crossplane-control-plane --region us-west4
```

Followed with

```shell
helm dependency build ./crossplane-gcp-control-plane

helm install crossplane-gcp-control-plane \
  ./crossplane-gcp-control-plane \
  --namespace crossplane-system \
  --create-namespace \
  -f values-gcp-nonprod.yaml
````

