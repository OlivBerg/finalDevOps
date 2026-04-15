# Plan

## Person 1 -- Terraform Backend + Network Module + Repo Setup -> Me Olive

### Responsibilities

1. **Repository scaffolding**

- Create `.gitignore` (include `*.tfstate`, `*.tfstate.backup`, `.terraform/`, `node_modules/`, `app/build/`, `.env`)
- Create the folder structure outlined above
- Set up branch protection rules on `main`
- Add collaborators (team + `rlmckenney`)

1. **Terraform backend module** -- `[infra/backend/](infra/backend/)`

- `main.tf`: Create a resource group, storage account, and blob container for Terraform remote state
- `variables.tf`: location, resource group name, storage account name, container name
- `outputs.tf`: storage account name, container name, access key
- This module is applied **once manually** to bootstrap the backend

1. **Network module** -- `[infra/modules/network/](infra/modules/network/)`

- `main.tf`:
  - Resource group: `cst8918-final-project-group-<number>`
  - Virtual network: address space `10.0.0.0/14`
  - 4 subnets:
    - `prod-subnet`: `10.0.0.0/16`
    - `test-subnet`: `10.1.0.0/16`
    - `dev-subnet`: `10.2.0.0/16`
    - `admin-subnet`: `10.3.0.0/16`
- `variables.tf`: resource group name, location, group number
- `outputs.tf`: VNet ID, subnet IDs (map)

1. **Root Terraform configuration** -- `[infra/environments/](infra/environments/)`

- `providers.tf`: configure `azurerm` provider and backend block pointing to the blob storage
- `main.tf`: wire together all modules (network, AKS, Redis, ACR) -- initially just network; others add their module calls via PRs
- `variables.tf` / `terraform.tfvars`: shared variables (location, group number, etc.)

### Deliverables / PRs

- PR 1: Repo scaffolding + `.gitignore` + folder structure
- PR 2: Terraform backend module
- PR 3: Network module + root config wiring

---

## Person 2 -- AKS Cluster Module + Redis Module -> Faiz

### Responsibilities

1. **AKS cluster module** -- `[infra/modules/aks-cluster/](infra/modules/aks-cluster/)`

- Reusable module accepting parameters for environment name, node count, auto-scaling, subnet ID, etc.
- `main.tf`:
  - `azurerm_kubernetes_cluster` resource
  - Default node pool with configurable `node_count`, `min_count`, `max_count`, `vm_size` (Standard_B2s), `kubernetes_version` (1.32)
  - Enable auto-scaling only when `max_count > min_count` (prod)
  - Attach to the correct subnet via `vnet_subnet_id`
  - Identity block (SystemAssigned)
- `variables.tf`: cluster name, location, resource group, DNS prefix, subnet ID, node count, min/max nodes, VM size, k8s version, environment tag
- `outputs.tf`: cluster ID, kube_config (sensitive), host, client certificate

1. **Test AKS instance** -- wired in `[infra/environments/main.tf](infra/environments/main.tf)`

- Call the AKS module with:
  - `node_count = 1`, auto-scaling disabled
  - subnet = `test-subnet` (from Person 1's network module)
  - `vm_size = "Standard_B2s"`, `kubernetes_version = "1.32"`

1. **Prod AKS instance** -- wired in `[infra/environments/main.tf](infra/environments/main.tf)`

- Call the AKS module with:
  - `min_count = 1`, `max_count = 3`, auto-scaling enabled
  - subnet = `prod-subnet`
  - `vm_size = "Standard_B2s"`, `kubernetes_version = "1.32"`

1. **Redis module** -- `[infra/modules/redis/](infra/modules/redis/)`

- `main.tf`:
  - `azurerm_redis_cache` resource
  - SKU: Basic/Standard (C0 or C1 for cost)
  - Configure `family`, `capacity`, `sku_name`
- `variables.tf`: name, location, resource group, environment tag
- `outputs.tf`: hostname, port, primary access key (sensitive), connection string

1. **Redis instances** -- wired in root config

- Test Redis + Prod Redis, each in respective resource group / with respective naming

### Deliverables / PRs

- PR 1: AKS cluster module
- PR 2: AKS test + prod instances (root config additions)
- PR 3: Redis module
- PR 4: Redis test + prod instances (root config additions)

---

## Person 3 -- GitHub Actions Workflows (CI/CD) -> Desmond Bear

### Responsibilities

1. **Azure federated identity setup** (document steps or script)

- Create an Azure AD App Registration
- Create federated credentials for GitHub Actions (for `main` branch pushes and PR events)
- Store secrets in GitHub repo: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`

1. **Workflow: Terraform static checks** -- `[.github/workflows/tf-static-checks.yml](.github/workflows/tf-static-checks.yml)`

- Trigger: `push` to **any** branch
- Jobs:
  - `terraform fmt -check -recursive`
  - `terraform validate` (after `terraform init -backend=false`)
  - `tfsec` (use `aquasecurity/tfsec-action`)

1. **Workflow: Terraform plan + tflint** -- `[.github/workflows/tf-plan-lint.yml](.github/workflows/tf-plan-lint.yml)`

- Trigger: `pull_request` to `main`
- Jobs:
  - Run `tflint` (use `terraform-linters/setup-tflint` action)
  - Run `terraform init` then `terraform plan` (with Azure OIDC auth)
  - Post plan output as PR comment (optional but recommended)

1. **Workflow: Terraform apply** -- `[.github/workflows/tf-apply.yml](.github/workflows/tf-apply.yml)`

- Trigger: `push` to `main` (merge of PR)
- Condition: only when `infra/` files changed (use `paths` filter)
- Jobs:
  - `terraform init` + `terraform apply -auto-approve`
  - Use Azure OIDC authentication

1. **Workflow: Docker build + push** -- `[.github/workflows/docker-build-push.yml](.github/workflows/docker-build-push.yml)`

- Trigger: `pull_request` to `main`
- Condition: only when `app/` files changed (use `paths` filter)
- Jobs:
  - Login to ACR (`azure/docker-login` action)
  - Build Docker image from `app/Dockerfile`
  - Tag with commit SHA (`${{ github.sha }}`)
  - Push to ACR

1. **Workflow: Deploy app to AKS** -- `[.github/workflows/deploy-app.yml](.github/workflows/deploy-app.yml)`

- Trigger: `pull_request` to `main` AND `push` to `main`
- Condition: only when `app/` files changed
- Jobs:
  - On `pull_request`: deploy to **test** AKS cluster
    - `az aks get-credentials` for test cluster
    - `kubectl set image` or `kubectl apply` with updated image tag
  - On `push` (merge): deploy to **prod** AKS cluster
    - Same approach, targeting prod cluster

### Deliverables / PRs

- PR 1: Terraform static checks workflow
- PR 2: Terraform plan + tflint workflow
- PR 3: Terraform apply workflow
- PR 4: Docker build + push workflow
- PR 5: Deploy app to AKS workflow

---

## Person 4 -- Application Code, Dockerfile, ACR Module, K8s Manifests -> Dharti

### Responsibilities

1. **Remix Weather Application** -- `[app/](app/)`

- Copy/scaffold the Remix Weather App source code (from the week 3 assignment)
- Ensure it reads Redis connection info from environment variables (`REDIS_HOST`, `REDIS_PORT`, `REDIS_KEY`)
- Ensure it reads the weather API key from environment variables
- `package.json` with all dependencies

1. **Dockerfile** -- `[app/Dockerfile](app/Dockerfile)`

- Multi-stage build:
  - Stage 1: `node:20-alpine` -- install deps + build
  - Stage 2: `node:20-alpine` -- copy build output, run `remix-serve`
- Expose port 3000
- Reference image on Docker Hub: `olivtheolive/cst8918-a01-weather-app`

1. **ACR module** -- `[infra/modules/acr/](infra/modules/acr/)`

- `main.tf`:
  - `azurerm_container_registry` resource
  - SKU: Basic
  - `admin_enabled = true`
- `variables.tf`: name, location, resource group
- `outputs.tf`: login server, admin username, admin password (sensitive)
- Wire into root config `[infra/environments/main.tf](infra/environments/main.tf)`

1. **Kubernetes manifests** -- `[k8s/](k8s/)`

- `deployment.yaml`:
  - Deployment named `weather-app`
  - Container image from ACR (placeholder `<acr-name>.azurecr.io/weather-app:<tag>`)
  - Environment variables: `REDIS_HOST`, `REDIS_PORT`, `REDIS_KEY`, weather API key
  - Resource limits/requests
  - Replicas: 1 (test), managed by HPA or set to 2 (prod)
- `service.yaml`:
  - Service type `LoadBalancer`
  - Port 80 -> target port 3000
- Optionally use Kustomize overlays for test vs prod

1. **README.md** -- `[README.md](README.md)`

- Project description
- Team member names + GitHub profile links
- Architecture diagram (text or mermaid)
- Prerequisites (Azure CLI, Terraform, kubectl, Docker)
- Setup instructions (bootstrap backend, configure secrets, run workflows)
- How to run locally

### Deliverables / PRs

- PR 1: Remix Weather App source + Dockerfile
- PR 2: ACR Terraform module + root config wiring
- PR 3: Kubernetes manifests (deployment + service)
- PR 4: README.md with full documentation

---

## Key Coordination Notes

- Person 1 must merge the scaffold and backend PRs first -- everything else depends on the folder structure and backend config.
- Person 2 depends on Person 1's network module for subnet IDs (use Terraform output references).
- Person 3 can start the static checks workflow early (no Azure auth needed for `fmt`/`validate`), but plan/apply workflows need the federated identity and backend to exist.
- Person 4 can work on the app and Dockerfile in parallel from the start, but the ACR module and K8s manifests depend on naming conventions from Person 2's AKS and Redis outputs.
- All team members should review each other's PRs to satisfy the branch protection rules (at least 1 approving review, no self-approval).
