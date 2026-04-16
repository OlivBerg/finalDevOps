output "storage_account_name" {
  description = "Name of the storage account used for Terraform remote state."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container name holding Terraform state."
  value       = azurerm_storage_container.tfstate.name
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
