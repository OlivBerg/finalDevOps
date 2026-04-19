output "login_server" {
  description = "The URL of the ACR login server."
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "The admin username for the ACR."
  value       = azurerm_container_registry.main.admin_username
}

output "admin_password" {
  description = "The admin password for the ACR."
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}
