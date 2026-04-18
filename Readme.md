# Final Project

## Access and collaboration

### Azure subscription

Each team member must be able to run Terraform and use the Azure Portal against the same subscription used for this project. A subscription **Owner** or **User Access Administrator** should assign the **Contributor** role at subscription scope (or on the project resource group, if you scope access that way):

1. Azure Portal → **Subscriptions** → select the subscription used for CST8918.
2. **Access control (IAM)** → **Add** → **Add role assignment**.
3. Role: **Contributor**.
4. Members: add each teammate’s Entra ID (Azure AD) user account.

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

Complete the browser sign-in if prompted. 2. **If you have more than one subscription**, list them and select the one your team uses for this course project:

```bash
 az account list --output table
 az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

3. **Confirm** the active subscription:

```bash
 az account show --output table
```

4. **Azure Portal:** open [portal.azure.com](https://portal.azure.com), ensure the correct **directory (tenant)** and **subscription** are selected in the top bar (same subscription as in `az account show`).
5. **Terraform and ARM:** Terraform’s Azure provider uses this CLI session by default (`az login`). Keep your CLI session valid; re-run `az login` when tokens expire.
6. **Coordination:** Everyone targets the **same subscription** so `terraform apply` creates and updates the **same** resources. Communicate before applies to avoid two people applying conflicting changes at once.

## Terraform remote state (shared state in Azure Blob Storage)

Terraform must remember what it created (resource IDs, dependencies). For a team, that **state** should live in **one shared place**, not only on someone’s laptop.

### What we use

- **Azure Storage Account** (blob) holds the state file(s).
- This repo bootstraps that storage under [`terraform/bootstrap/`](terraform/bootstrap) (applied **once**, with **local** `terraform.tfstate` only for that bootstrap folder).
- Bootstrap creates **three** blob containers so you can keep **separate Terraform states**: **`tfstate-dev`**, **`tfstate-test`**, and **`tfstate-prod`** (same storage account **`stateblob`**, RG **`finaldevops-rg`**).
- The stack in [`terraform/environments/main/`](terraform/environments/main) uses the **azurerm** backend; the example [`backend.hcl.example`](terraform/environments/main/backend.hcl.example) points at **`tfstate-prod`** by default. Use **`tfstate-dev`** or **`tfstate-test`** in `backend.hcl` when you want isolated state for experiments or staging (swap `container_name`, same pattern).

After bootstrap, teammates use the **same** storage account but **pick the container** that matches the environment they are managing — **dev**, **test**, and **prod** states do not overwrite each other.

### One-time: bootstrap remote state (if not already done)

From `**terraform/bootstrap/`\*\* (only someone with rights to create the storage account):

```bash
cd terraform/bootstrap
az login
terraform init
terraform apply
```

If this was already applied, skip to the next section.

### Day-to-day: main stack with remote state

From `**terraform/environments/main/**`:

1. **Sign in** (`az login`) and **select the correct subscription** (see above).
2. **Backend configuration:** copy the example and set **`container_name`** to **`tfstate-dev`**, **`tfstate-test`**, or **`tfstate-prod`** (`backend.hcl.example` defaults to **prod** for this root).

```bash
 cp backend.hcl.example backend.hcl
```

```hcl
# Then edit the backend.hcl directly, the default is prod so make sure to change it to dev
container_name = "tfstate-dev" # dev/test/prod
```

`backend.hcl` is **gitignored**; do not commit secrets. With **`az login`**, Terraform can use Azure AD to access the storage account (**Contributor** on the subscription usually covers it). For **GitHub Actions**, use OIDC and set `use_oidc = true` in `backend.hcl` (see your CI workflow). 3. **Initialize** (downloads providers and connects the backend; may prompt to migrate state if you switched backends):

```bash
 terraform init -backend-config=backend.hcl
```

4. **Optional:** copy `terraform.tfvars.example` → `terraform.tfvars` and edit.
5. **Plan / apply** as usual:

```bash
 terraform plan
 terraform apply
```

### Rules of thumb

- **Pull** latest `main` before planning or applying so your configuration matches the team’s.
- **Do not** commit `**terraform.tfstate`\*\* from the main stack (remote state lives in Azure; local file may appear in rare setups — follow `.gitignore`).
- The blob backend supports **state locking** so two applies do not corrupt state; still **coordinate** who runs `apply` and when.
- To **destroy** resources, use `terraform destroy` from the same directory/backend only when the team agrees (and before course deadlines if required).

## Layout

- `**remix-codebase/`\*\* — Remix Weather application source, `Dockerfile`, and `package.json` (use this path for CI/CD and Docker builds instead of `app/`).
- `**terraform/**` — Infrastructure as Code.
  - **`terraform/modules/backend/`** — Remote state storage: resource group, storage account, **three** blob containers (`tfstate-dev`, `tfstate-test`, `tfstate-prod`). Reusable module.
  - **`terraform/bootstrap/`** — One-time manual apply with **local** state (`terraform init && apply`). Hardcoded: region **canadacentral**, RG **finaldevops-rg**, storage account **stateblob**. Outputs list `backend_config_dev`, `backend_config_test`, `backend_config_prod` (see `terraform output` after apply).
  - `**terraform/modules/network/`** — Resource group `cst8918-final-project-group-4`, VNet `10.0.0.0/14`, subnets **prod-subnet** `10.0.0.0/16`, **test-subnet** `10.1.0.0/16`, **dev-subnet** `10.2.0.0/16`, **admin-subnet\*\* `10.3.0.0/16`. Outputs: `virtual_network_id`, `subnet_ids` (map).
  - `**terraform/environments/main/`** — Root stack: wires modules (currently **network\*\* only). Use `terraform init -backend-config=backend.hcl` after copying `backend.hcl.example`, then `terraform plan` / `apply`.
  - `**terraform/modules/app`** (when added) — Terraform **module name\*\* for ACR/Redis/K8s, not the Remix source tree.
