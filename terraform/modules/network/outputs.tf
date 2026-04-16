output "resource_group_name" {
  description = "Name of the project resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the project resource group."
  value       = azurerm_resource_group.main.id
}

output "virtual_network_id" {
  description = "ID of the virtual network (10.0.0.0/14)."
  value       = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "Map of environment key to subnet resource ID."
  value = {
    prod  = azurerm_subnet.prod.id
    test  = azurerm_subnet.test.id
    dev   = azurerm_subnet.dev.id
    admin = azurerm_subnet.admin.id
  }
}
