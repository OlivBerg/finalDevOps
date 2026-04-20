# CST8918 Final Project — Remix Weather App on Azure AKS

**Course:** CST8918 DevOps: Infrastructure as Code | Prof. Robert McKenney

## Team

| Name | GitHub |
|------|--------|
| Olivie Bergeron | [@OlivBerg](https://github.com/OlivBerg) |
| Desmond Murphy | [@murp0428](https://github.com/murp0428) |
| Dharti Patel | [@Patel-Creates](https://github.com/Patel-Creates) |
| Fayz Reshid | [@resh2024](https://github.com/resh2024) |

## Project Overview

This project deploys the Remix Weather Application to Azure Kubernetes Service (AKS) using Terraform for infrastructure and GitHub Actions for CI/CD automation.

The infrastructure is managed as code using Terraform modules and deployed across two environments — **test** and **prod**. The application is containerized with Docker, stored in Azure Container Registry (ACR), and deployed to AKS clusters. Redis (Azure Cache for Redis) is used to cache weather API responses.

## Architecture

```
GitHub Actions
    │
    ├── push to any branch  ──► Terraform static checks (fmt, validate, tfsec)
    ├── pull_request to main ──► Terraform plan + tflint
    │                            Docker build + push to ACR (app changes only)
    │                            Deploy to test AKS (app changes only)
    └── merge to main ───────► Terraform apply (infra changes)
                                Deploy to prod AKS (app changes only)

Azure Infrastructure
    │
    ├── Resource Group: cst8918-final-project-group-4
    ├── Virtual Network: 10.0.0.0/14
    │     ├── prod-subnet:  10.0.0.0/16
    │     ├── test-subnet:  10.1.0.0/16
    │     ├── dev-subnet:   10.2.0.0/16
    │     └── admin-subnet: 10.3.0.0/16
    ├── Azure Container Registry (ACR): cst8918group4acr
    ├── AKS Cluster (test): 1 node, Standard_B2s
    ├── AKS Cluster (prod): 1–3 nodes, Standard_B2s, autoscaling
    ├── Redis Cache (test)
    └── Redis Cache (prod)
```

## Prerequisites

Before running anything locally, make sure you have the following installed:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker](https://www.docker.com/get-started/)
- [Node.js](https://nodejs.org/) >= 20

## Setup Instructions

### 1. Bootstrap the Terraform backend (one-time, already done)

This creates the Azure Storage Account used to store Terraform state. Only needs to be run once by one team member.

```bash
cd terraform/bootstrap
az login
terraform init
terraform apply
```

### 2. Configure your local backend

```bash
cd terraform/environments/main
cp backend.hcl.example backend.hcl
# Edit backend.hcl — set container_name to tfstate-dev, tfstate-test, or tfstate-prod
```

### 3. Initialize and plan

```bash
az login
terraform init -backend-config=backend.hcl
terraform plan
```

### 4. Configure GitHub Secrets

The GitHub Actions workflows require the following secrets set in the repository:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App registration client ID (federated identity) |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `WEATHER_API_KEY` | API key for the weather data service |

### 5. Deploy K8s secrets to the cluster

Before deploying the app, create the Kubernetes secret in each cluster:

```bash
# Connect to test cluster
az aks get-credentials --resource-group cst8918-final-project-group-4 --name <test-cluster-name>

kubectl create secret generic weather-app-secrets \
  --from-literal=REDIS_HOST=<redis-host> \
  --from-literal=REDIS_PORT=6380 \
  --from-literal=REDIS_KEY=<redis-key> \
  --from-literal=WEATHER_API_KEY=<weather-api-key>
```

Repeat for the prod cluster.

## Running the App Locally

```bash
cd remix-codebase
npm install
cp .env.example .env   # add your WEATHER_API_KEY and Redis vars
npm run dev
```

App runs at `http://localhost:3000`.

## Kubernetes Manifests

The `k8s/` folder contains Kustomize-based manifests for deploying the app to AKS. See [`k8s/README.md`](k8s/README.md) for a full explanation.

```
k8s/
├── base/              # Shared Deployment + LoadBalancer Service
└── overlays/
    ├── test/          # 1 replica
    └── prod/          # 2 replicas
```

To deploy manually:

```bash
kubectl apply -k k8s/overlays/test   # test environment
kubectl apply -k k8s/overlays/prod   # prod environment
```

## GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `tf-static-checks.yml` | Push to any branch | `terraform fmt`, `validate`, `tfsec` |
| `tf-plan-lint.yml` | PR to main | `tflint` + `terraform plan` |
| `tf-apply.yml` | Merge to main | `terraform apply` |
| `docker-build-push.yml` | PR to main (app changes) | Build + push Docker image to ACR |
| `deploy-app.yml` | PR/merge to main (app changes) | Deploy to test / prod AKS |

<!-- Add screenshot of completed workflow runs here once all workflows are passing -->

---

## Access and collaboration

### Azure subscription

Each team member must be able to run Terraform and use the Azure Portal against the same subscription used for this project. A subscription **Owner** or **User Access Administrator** should assign the **Contributor** role at subscription scope (or on the project resource group, if you scope access that way):

1. Azure Portal → **Subscriptions** → select the subscription used for CST8918.
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. Role: **Contributor**.
4. Members: add each teammate's Entra ID (Azure AD) user account.

Confirm below once everyone has been added (update names to match your team):

| Team member       | GitHub collaborator | Azure subscription Contributor |
| ----------------- | ------------------- | ------------------------------ |
| _Olivie Bergeron_ | Yes                 | Yes                            |
| _Desmond Murphy_  | Yes                 | Yes                            |
| _Dharti Patel_    | Yes                 | Yes                            |
| _Fayz Reshid_     | Yes                 | Yes                            |

> **Note:** GitHub access and Azure RBAC are separate. Inviting someone to the repo does **not** grant them rights in Azure; both must be configured.

## Using the Azure subscription

After a teammate has the **Contributor** role on the subscription (or on the resource groups your team uses), they can manage the same cloud resources as everyone else.

1. **Sign in to Azure CLI** (uses your school/work Microsoft account that was granted access):

```bash
az login
```

Complete the browser sign-in if prompted.

2. **If you have more than one subscription**, list them and select the one your team uses for this course project:

```bash
az account list --output table
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

3. **Confirm** the active subscription:

```bash
az account show --output table
```

4. **Azure Portal:** open [portal.azure.com](https://portal.azure.com), ensure the correct **directory (tenant)** and **subscription** are selected in the top bar (same subscription as in `az account show`).
5. **Terraform and ARM:** Terraform's Azure provider uses this CLI session by default (`az login`). Keep your CLI session valid; re-run `az login` when tokens expire.
6. **Coordination:** Everyone targets the **same subscription** so `terraform apply` creates and updates the **same** resources. Communicate before applies to avoid two people applying conflicting changes at once.

## Terraform remote state (shared state in Azure Blob Storage)

Terraform must remember what it created (resource IDs, dependencies). For a team, that **state** should live in **one shared place**, not only on someone's laptop.

### What we use

- **Azure Storage Account** (blob) holds the state file(s).
- This repo bootstraps that storage under [`terraform/bootstrap/`](terraform/bootstrap) (applied **once**, with **local** `terraform.tfstate` only for that bootstrap folder).
- Bootstrap creates **three** blob containers so you can keep **separate Terraform states**: **`tfstate-dev`**, **`tfstate-test`**, and **`tfstate-prod`** (same storage account **`stateblob`**, RG **`finaldevops-rg`**).
- The stack in [`terraform/environments/main/`](terraform/environments/main) uses the **azurerm** backend; the example [`backend.hcl.example`](terraform/environments/main/backend.hcl.example) points at **`tfstate-prod`** by default. Use **`tfstate-dev`** or **`tfstate-test`** in `backend.hcl` when you want isolated state for experiments or staging (swap `container_name`, same pattern).

After bootstrap, teammates use the **same** storage account but **pick the container** that matches the environment they are managing — **dev**, **test**, and **prod** states do not overwrite each other.

### One-time: bootstrap remote state (if not already done)

From `terraform/bootstrap/` (only someone with rights to create the storage account):

```bash
cd terraform/bootstrap
az login
terraform init
terraform apply
```

If this was already applied, skip to the next section.

### Day-to-day: main stack with remote state

From `terraform/environments/main/`:

1. **Sign in** (`az login`) and **select the correct subscription** (see above).
2. **Backend configuration:** copy the example and set **`container_name`** to **`tfstate-dev`**, **`tfstate-test`**, or **`tfstate-prod`**.

```bash
cp backend.hcl.example backend.hcl
```

```hcl
# Edit backend.hcl — default is prod, change to dev for local work
container_name = "tfstate-dev"
```

`backend.hcl` is **gitignored**; do not commit secrets.

3. **Initialize:**

```bash
terraform init -backend-config=backend.hcl
```

4. **Optional:** copy `terraform.tfvars.example` → `terraform.tfvars` and edit.
5. **Plan / apply:**

```bash
terraform plan
terraform apply
```

### Rules of thumb

- **Pull** latest `main` before planning or applying so your configuration matches the team's.
- **Do not** commit `terraform.tfstate` from the main stack (remote state lives in Azure).
- The blob backend supports **state locking** so two applies do not corrupt state; still **coordinate** who runs `apply` and when.
- To **destroy** resources, use `terraform destroy` only when the team agrees.

## Repository Layout

```
.
├── remix-codebase/          # Remix Weather App source code + Dockerfile
├── terraform/
│   ├── bootstrap/           # One-time manual apply to create remote state storage
│   ├── environments/
│   │   └── main/            # Root Terraform config — wires all modules together
│   └── modules/
│       ├── backend/         # Azure Blob Storage for Terraform state
│       ├── network/         # Resource group, VNet, subnets
│       ├── aks/             # AKS cluster (reusable for test + prod)
│       ├── acr/             # Azure Container Registry
│       └── app/             # Redis + K8s deployment resources
├── k8s/                     # Kubernetes manifests (Kustomize)
│   ├── base/                # Shared Deployment + Service
│   └── overlays/            # test and prod environment overrides
└── .github/workflows/       # GitHub Actions CI/CD workflows
```
