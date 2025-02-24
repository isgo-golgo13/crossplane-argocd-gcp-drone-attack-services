# Crossplane API, Cluster API and ArgoCD (Control Plane) Cluster for Provisioning GCP Container App Platforms
Crossplane, Crossplane GCP Provider and ArgoCD Kubernetes-Native Provisioning of GCP GKE, GCP Cloud Run and GCP App Engine Drone Attack Sortie App Services (Rust and Go)



## Crossplane XRD API Structure (Helm)
```
├── crossplane
│   ├── Chart.yaml
│   ├── packages
│   │   ├── gcp-apigee
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-app-engine
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-cloudrun
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-databases
│   │   │   ├── templates
│   │   │   │   ├── gcp-firestore-claim.yaml
│   │   │   │   ├── gcp-firestore-composition.yaml
│   │   │   │   ├── gcp-firestore-xrd.yaml
│   │   │   │   ├── gcp-spanner-claim.yaml
│   │   │   │   ├── gcp-spanner-composition.yaml
│   │   │   │   └── gcp-spanner-xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-eventarc
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-gke
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   ├── gcp-networking
│   │   │   ├── templates
│   │   │   │   ├── claim.yaml
│   │   │   │   ├── composition.yaml
│   │   │   │   └── xrd.yaml
│   │   │   └── values.yaml
│   │   └── gcp-pubsub
│   │       ├── templates
│   │       │   ├── claim.yaml
│   │       │   ├── composition.yaml
│   │       │   └── xrd.yaml
│   │       └── values.yaml
│   ├── values-nonprod.yaml
│   ├── values-preprod.yaml
│   ├── values-prod.yaml
│   ├── values-uat.yaml
│   └── values.yaml
├── crossplane-pkg
│   ├── crossplane-pkg-request-cli
│   └── spec-README.md
```


## Crossplane XRD API Structure (Helm)
```
...
crossplane/
├── Chart.yaml                # Helm Chart metadata
├── values.yaml               # Global values for Helm templates
├── packages/
│   ├── networking/           # VPCs, Private Links, Firewall, IAM
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── apigee/               # Apigee API Gateway + Private Link
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── pubsub/               # GCP Pub/Sub
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── eventarc/             # EventArc Event Routing
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── gke/                  # Private GKE Cluster + Workload Identity
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── cloudrun/             # Cloud Run Service + Firestore
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── appengine/            # App Engine + Firestore
│   │   ├── templates/
│   │   │   ├── xrd.yaml
│   │   │   ├── composition.yaml
│   │   │   ├── claim.yaml
│   │   ├── values.yaml
│   ├── databases/            # Spanner (HA 3 AZs) + Firestore
│   │   ├── templates/
│   │   │   ├── spanner-xrd.yaml
│   │   │   ├── spanner-composition.yaml
│   │   │   ├── spanner-claim.yaml
│   │   │   ├── firestore-xrd.yaml
│   │   │   ├── firestore-composition.yaml
│   │   │   ├── firestore-claim.yaml
│   │   ├── values.yaml
...
```
