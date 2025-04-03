## AWS EKS Self-Service Portal

This Git repository directory includes client-side JavaScript `SvelteKit` applicaiton to create the following AWS Cloud resources.

- AWS EKS Cluster **with**
  - Private Control-Plane Nodes
  - EKS NodeGroups
  - AWS IAM OIDC Federated Identity (IRSA)
  - 3 Control Plane Nodes
  - 3 Worker Plane Nodes
  - Kubernetes Add-Ons `Kyverno` Policy Controller, Cert-Manager
##
- AWS EKS Fargate Cluster **with**
  - Private Control-Plane Nodes
  - EKS NodeGroups
  - AWS IAM OIDC Federated Identity (IRSA)
  - 3 Control Plane Nodes
  - 3 Worker Plane Nodes
  - Kubernetes Add-Ons `Kyverno` Policy Controller, Cert-Manager

##
The client-side JavaScript application will collect Card inputs to create these AWS EKS resources and relay the JSON request to a Go OpenAPI service to deploy the requested Crossplane XR API Claim to the Kubernetes Server and return status of the creation process
to the client JavaScript UI.


The XR API Claims for this request flow look as follows (as created in the server-side).

```yaml
# EKS Cluster Claim request
apiVersion: eks.aws.crossplane.io/v1alpha1
kind: EKSClusterClaim
metadata:
  name: appx-eks-cluster
  namespace: appx
  labels:
    requestId: 3e4fd921-58c4-49c2-9a13-f42d0d0c8b52
spec:
  parameters:
    region: us-east-1
    clusterName: appx-eks-cluster
    nodeCount: 3
  compositionRef:
    name: eks-cluster-with-irsa

---
# EKS Fargate Profile Claim request
apiVersion: eks.aws.crossplane.io/v1alpha1
kind: EKSFargateProfileClaim
metadata:
  name: appx-fargate-cluster
  namespace: appx
  labels:
    requestId: 7a2fb932-68c5-49f2-8b34-e52d1d1c9c63
spec:
  parameters:
    region: us-east-1
    clusterName: appx-fargate-cluster
  compositionRef:
    name: eks-fargate-with-irsa
```


# Crossplane API Server

A Go API server that provides a RESTful interface for controlling Crossplane XR Claims for EKS and EKS Fargate clusters.

## Synopsis

This API server provides self-service provisioning of AWS EKS clusters through Crossplane Custom Resources. It hides away the complexity of Kubernetes and Crossplane configuration, providing a HTTP API that can get referenced from various clients (frontend web client UIs).

## Offerings

- Create and manage EKS clusters with managed node groups
- Create and manage EKS clusters with Fargate profiles
- Monitor cluster provisioning status
- Download kubeconfig files for cluster access
- OpenAPI/Swagger documentation
- Authentication and authorization
- Structured logging and monitoring

## Prerequisites

- Go 1.22 or later
- Access to a Kubernetes cluster with Crossplane installed
- Crossplane AWS Provider with EKS capability

## Compiling and Running

### Using Make

The project includes a Makefile with targets for building, testing, and running:

```bash
# Build the binary
make build
# Generate Swagger documentation
make swagger
# Run the server locally
make run
```


### Not using Make

```bash
# Build the binary
go build -o cxp-api-server ./svc/api

# Run the server
./cxp-api-server
```

### Docker

```bash
# Build the Docker image
docker build -t cxp-api-server:latest .

# Run the container
docker run -p 8080:8080 cxp-api-server:latest
```

## API Specifications

The API server provides a OpenAPI REST interface for controlling EKS clusters. The following are operations of the API

### Create an EKS Cluster with Managed Node Groups

```bash
curl -X POST http://localhost:8080/api/clusters \
  -H "Content-Type: application/json" \
  -d '{
    "cluster_type": "eks",
    "cluster_name": app-x-production-cluster",
    "node_count": 3,
    "region": "us-west-2"
  }'
```

**Response:**
```json
{
  "request_id": "3e4fd921-58c4-49c2-9a13-f42d0d0c8b52",
  "status": "PROVISIONING",
  "message": "Cluster provisioning has been initiated"
}
```

### Create an EKS Cluster with Fargate

```bash
curl -X POST http://localhost:8080/api/clusters \
  -H "Content-Type: application/json" \
  -d '{
    "cluster_type": "fargate",
    "cluster_name": "app-x-serverless-cluster",
    "region": "us-east-1"
  }'
```

**Response:**
```json
{
  "request_id": "7a2fb932-68c5-49f2-8b34-e52d1d1c9c63",
  "status": "PROVISIONING",
  "message": "Cluster provisioning has been initiated"
}
```

### Get Cluster Status

```bash
curl -X GET http://localhost:8080/api/clusters/app-x-production-cluster
```

**Response:**
```json
{
  "name": "app-x-production-cluster",
  "namespace": "appx",
  "cluster_type": "eks",
  "status": "READY",
  "request_id": "3e4fd921-58c4-49c2-9a13-f42d0d0c8b52",
  "region": "us-west-2",
  "node_count": 3,
  "kubeconfig": "apiVersion: v1\nclusters:\n- cluster:\n    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t...",
  "created_at": "2025-04-01T10:30:00Z"
}
```

### List All Clusters

```bash
curl -X GET http://localhost:8080/api/clusters
```

Example response:
```json
[
  {
    "name": "app-x-production-cluster",
    "namespace": "appx",
    "cluster_type": "eks",
    "status": "READY",
    "request_id": "3e4fd921-58c4-49c2-9a13-f42d0d0c8b52",
    "region": "us-west-2",
    "node_count": 3,
    "created_at": "2025-04-01T10:30:00Z"
  },
  {
    "name": "app-x-serverless-cluster",
    "namespace": "appx",
    "cluster_type": "fargate",
    "status": "PROVISIONING",
    "request_id": "7a2fb932-68c5-49f2-8b34-e52d1d1c9c63",
    "region": "us-east-1",
    "created_at": "2025-04-01T11:15:00Z"
  }
]
```

### Delete a Cluster

```bash
curl -X DELETE http://localhost:8080/api/clusters/app-x-production-cluster
```

No response body is returned for successful deletion (HTTP 204).

### Health Check

```bash
curl -X GET http://localhost:8080/api/health
```

Example response:
```json
{
  "status": "ok",
  "version": "0.1.0"
}
```

## API Documentation

The API documentation is available through Swagger UI when the server is running:

```
http://localhost:8080/swagger/index.html
```

You can also generate the Swagger documentation using:

```bash
make swagger
```




## Frontend Integration

The API is designed to work with any frontend platform. Here are the ways for integrating different frontend frameworks:

### React / Next.js

```javascript
// GET request
async function fetchClusters() {
  try {
    const response = await fetch('http://localhost:8080/api/clusters');
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching clusters:', error);
    throw error;
  }
}

// POST request
async function createCluster(clusterData) {
  try {
    const response = await fetch('http://localhost:8080/api/clusters', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(clusterData),
    });
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error creating cluster:', error);
    throw error;
  }
}
```

### SvelteKit (For Reference ONLY)

```javascript
// In a +page.server.js file
export async function load({ fetch }) {
  const response = await fetch('http://localhost:8080/api/clusters');
  const clusters = await response.json();
  return { clusters };
}

// Form action
export const actions = {
  createCluster: async ({ request }) => {
    const formData = await request.formData();
    const clusterData = {
      cluster_type: formData.get('cluster_type'),
      cluster_name: formData.get('cluster_name'),
      node_count: formData.get('node_count') ? parseInt(formData.get('node_count')) : undefined,
      region: formData.get('region')
    };

    const response = await fetch('http://localhost:8080/api/clusters', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(clusterData),
    });

    return await response.json();
  }
};
```

## Configuration

The API server can be configured using environment variables:

- `PORT`: HTTP port to listen on (default: 8080)
- `LOG_LEVEL`: Logging level (default: info)
- `KUBECONFIG`: Path to kubeconfig file (optional, uses in-cluster config if not provided)
- `NAMESPACE`: Default namespace for creating resources (default: appx)
