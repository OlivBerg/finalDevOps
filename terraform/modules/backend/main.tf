locals {
  # One Azure blob container per environment so dev / test / prod Terraform state stay isolated.
  state_environments = toset(["dev", "test", "prod"])
}

resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  for_each = local.state_environments

  name                  = "tfstate-${each.key}"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
