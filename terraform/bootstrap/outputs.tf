output "storage_account_name" {
  description = "Name of the storage account used for Terraform remote state."
  value       = module.backend.storage_account_name
}

output "container_name" {
  description = "Blob container name holding Terraform state."
  value       = module.backend.container_name
}

output "access_key" {
  description = "Primary access key for the storage account."
  value       = module.backend.access_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group containing the state storage."
  value       = module.backend.resource_group_name
}

output "backend_config_snippet" {
  description = "Values for the main stack backend.hcl (no secrets)."
  value       = <<-EOT
    resource_group_name  = "${module.backend.resource_group_name}"
    storage_account_name = "${module.backend.storage_account_name}"
    container_name       = "${module.backend.container_name}"
    key                  = "cst8918.tfstate"
  EOT
}
