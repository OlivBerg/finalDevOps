# Final Project

## Layout

- **`remix-codebase/`** — Remix Weather application source, `Dockerfile`, and `package.json` (use this path for CI/CD and Docker builds instead of `app/`).
- **`terraform/`** — Infrastructure as Code (modules include `terraform/modules/app` for ACR, Redis, and Kubernetes workloads — that folder is the Terraform **module name**, not the Remix source tree).
