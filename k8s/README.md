# Kubernetes Manifests

This folder contains the Kubernetes configuration files that tell Azure how to run the Remix Weather App on the AKS clusters.

## What is Kubernetes?

Kubernetes (K8s) is a system that manages running containers in the cloud. Instead of manually starting Docker containers, you write YAML files that describe what you want running, and Kubernetes handles the rest — starting containers, restarting them if they crash, and routing traffic to them.

## What's in this folder?

```
k8s/
├── base/                    # The shared, common config for all environments
│   ├── deployment.yaml      # Tells Kubernetes how to run the app container
│   ├── service.yaml         # Exposes the app to the internet
│   └── kustomization.yaml   # Lists which files belong to the base
└── overlays/
    ├── test/                # Overrides for the test environment
    └── prod/                # Overrides for the production environment
```

We use a tool called **Kustomize** (built into `kubectl`) to avoid repeating ourselves. The `base/` folder has the common config, and each overlay only specifies what's different for that environment.

## The files explained

### `base/deployment.yaml`

This tells Kubernetes:
- Run a container using our Docker image from ACR (`cst8918group4acr.azurecr.io/weather-app`)
- The app listens on port 3000
- Inject environment variables (Redis connection info, weather API key) from a Kubernetes Secret
- Set CPU and memory limits so the app doesn't consume too many resources
- Run health checks to automatically restart the container if it stops responding

### `base/service.yaml`

This exposes the app to the internet:
- Type `LoadBalancer` means Azure will create a public IP address for this service
- External traffic on port 80 gets forwarded to the container on port 3000

### `overlays/test/` and `overlays/prod/`

These override the base config per environment:

| Setting | Test | Prod |
|---------|------|------|
| Replicas (copies of the app) | 1 | 2 |
| Resource name prefix | `test-` | `prod-` |

## The Kubernetes Secret

Before deploying, a Secret named `weather-app-secrets` must exist in the cluster. It holds sensitive values that the app reads at runtime:

| Key | Description |
|-----|-------------|
| `REDIS_HOST` | Hostname of the Azure Redis Cache |
| `REDIS_PORT` | Port for Redis (usually 6380 for SSL) |
| `REDIS_KEY` | Access key for Redis |
| `WEATHER_API_KEY` | API key for the weather data service |

The GitHub Actions deploy workflow creates this secret automatically using values stored as GitHub Secrets.

## How to deploy manually (if needed)

Make sure you have `kubectl` connected to the right cluster first.

**Deploy to test:**
```bash
kubectl apply -k k8s/overlays/test
```

**Deploy to prod:**
```bash
kubectl apply -k k8s/overlays/prod
```

To deploy a specific image version (replace `<SHA>` with the commit hash):
```bash
cd k8s/overlays/test
kustomize edit set image cst8918group4acr.azurecr.io/weather-app=cst8918group4acr.azurecr.io/weather-app:<SHA>
kubectl apply -k .
```

## How this fits into the bigger picture

1. A developer opens a PR → GitHub Actions builds the Docker image and tags it with the commit SHA
2. The image gets pushed to ACR (Azure Container Registry)
3. GitHub Actions deploys the new image to the **test** AKS cluster using these manifests
4. After the PR is merged to `main`, GitHub Actions deploys to the **prod** AKS cluster
