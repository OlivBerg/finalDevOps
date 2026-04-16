output "storage_account_name" {
  description = "Name of the storage account used for Terraform remote state."
  value       = azurerm_storage_account.tfstate.name
}

output "container_names" {
  description = "Blob container name per environment (dev, test, prod). Use one per Terraform root / backend.hcl."
  value       = { for env, ctr in azurerm_storage_container.tfstate : env => ctr.name }
}

output "access_key" {
  description = "Primary access key for the storage account (use for Terraform backend auth or rotate to Azure AD/OIDC)."
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group containing the state storage (needed for backend azurerm configuration)."
  value       = azurerm_resource_group.tfstate.name
}

output "state_blob_key_default" {
  description = "Recommended blob name (key) inside each container for the root module state file."
  value       = "cst8918.tfstate"
}
