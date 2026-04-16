# Final Project

## Layout

- `**remix-codebase/**` — Remix Weather application source, `Dockerfile`, and `package.json` (use this path for CI/CD and Docker builds instead of `app/`).
- `**terraform/**` — Infrastructure as Code.
  - `**terraform/modules/backend/**` — Remote state storage (resource group, storage account, blob container). Reusable module.
  - `**terraform/bootstrap/**` — One-time manual apply with **local** state (`terraform init && apply`). Backend settings are **hardcoded** in `terraform/bootstrap/main.tf`: region **canadacentral**, RG **finaldevops-rg**, storage account **stateblob**, container **state-storage**. Then point your main stack’s `backend "azurerm"` at the outputs.
  - `**terraform/modules/network/`** — Resource group `cst8918-final-project-group-4`, VNet `10.0.0.0/14`, subnets **prod-subnet** `10.0.0.0/16`, **test-subnet** `10.1.0.0/16`, **dev-subnet** `10.2.0.0/16`, **admin-subnet** `10.3.0.0/16`. Outputs: `virtual_network_id`, `subnet_ids` (map).
  - `**terraform/environments/main/`** — Root stack: wires modules (currently **network** only). Use `terraform init -backend-config=backend.hcl` after copying `backend.hcl.example`, then `terraform plan` / `apply`.
  - `**terraform/modules/app`** (when added) — Terraform **module name** for ACR/Redis/K8s, not the Remix source tree.

