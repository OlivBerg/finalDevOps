module "network" {
  source = "../../modules/network"

  location            = var.location
  group_number        = var.group_number
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "law-aks-${var.group_number}"
  location            = var.location
  resource_group_name = module.network.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

module "aks_test" {
  source = "../../modules/aks"

  cluster_name                    = "aks-test-${var.group_number}"
  location                        = var.location
  resource_group_name             = module.network.resource_group_name
  dns_prefix                      = "aks-test-${var.group_number}"
  subnet_id                       = module.network.subnet_ids["test"]
  node_count                      = 1
  min_count                       = 1
  max_count                       = 1 # auto-scaling disabled for test
  vm_size                         = "Standard_B2s"
  kubernetes_version              = "1.33"
  environment                     = "test"
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  cluster_service_cidr            = "10.4.0.0/16"
  cluster_dns_service_ip          = "10.4.0.10"
}

module "aks_prod" {
  source = "../../modules/aks"

  cluster_name                    = "aks-prod-${var.group_number}"
  location                        = var.location
  resource_group_name             = module.network.resource_group_name
  dns_prefix                      = "aks-prod-${var.group_number}"
  subnet_id                       = module.network.subnet_ids["prod"]
  node_count                      = 1
  min_count                       = 1
  max_count                       = 3 # auto-scaling enabled for prod
  vm_size                         = "Standard_B2s"
  kubernetes_version              = "1.33"
  environment                     = "prod"
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  cluster_service_cidr            = "10.5.0.0/16"
  cluster_dns_service_ip          = "10.5.0.10"
}

module "acr" {
  source = "../../modules/acr"

  name                = "cst8918group${var.group_number}acr"
  location            = var.location
  resource_group_name = module.network.resource_group_name
  tags                = var.tags
}
