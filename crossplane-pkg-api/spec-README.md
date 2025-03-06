## Crossplane XR Package API (Go API Service Kit, Rust API Service Kit)

This Git directory holds the API-driven service kits to create, upgrade-create, get and delete Azure and GCP XR API provisioned resources providing kits in Go and Rust. 

The `crossplane-pkg` directory providing the `cli` will call into this API directly, the API will in-turn will create XR Claim or coordinated XR Claims using `Ranged XR Claims Pattern` collecting the high-level product groups input values declared in the Claims OpenAPI Schema, package this XR Claims and push to Git to trigger the GitOps deploy through ArgoCD. The lower-level input values to the XR are provided through Crossplane Compositional Functions that serve as the platform expertise processor calling on the provided Go or Rust service kits. 

The API does **NOT** serve as a passive API and does **NOT** side-step push flow to Git. This avoids unnecessary CI/CD workflows to drive the XR API to the live state (cloud platform target state). The Gitflow strictly pushes to Git and ArgoCD is triggered to deploy the resources. 

The **advantages** of this are.

- Git version tracking and auditing workflow
- 


## Architectural Workflow

Graphical Workflow In-Progres


## Service Kit Structure for the Go Crossplane Compositional Functions

In-Progress

## Service Kit Structure for the Rust Crossplane Compositional Functions

In-Progress

## Deploy Structure for Crossplane Compostional Functions

In-Progress