# Final Project

## Layout

- **`remix-codebase/`** — Remix Weather application source, `Dockerfile`, and `package.json` (use this path for CI/CD and Docker builds instead of `app/`).
- **`terraform/`** — Infrastructure as Code.
  - **`terraform/modules/backend/`** — Remote state storage (resource group, storage account, blob container). Reusable module.
  - **`terraform/bootstrap/`** — One-time manual apply with **local** state (`terraform init && apply`). Backend settings are **hardcoded** in `terraform/bootstrap/main.tf`: region **canadacentral**, RG **finaldevops-rg**, storage account **stateblob**, container **state-storage**. Then point your main stack’s `backend "azurerm"` at the outputs.
  - **`terraform/modules/app`** (when added) — Terraform **module name** for ACR/Redis/K8s, not the Remix source tree.
