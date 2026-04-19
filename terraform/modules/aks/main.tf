resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # CRITICAL: limit API server access to specific IP ranges
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  default_node_pool {
    name                 = "default"
    node_count           = var.max_count > var.min_count ? null : var.node_count
    min_count            = var.max_count > var.min_count ? var.min_count : null
    max_count            = var.max_count > var.min_count ? var.max_count : null
    auto_scaling_enabled = var.max_count > var.min_count
    vm_size              = var.vm_size
    vnet_subnet_id       = var.subnet_id
  }

  # HIGH: enable RBAC
  role_based_access_control_enabled = true

  # HIGH: configure network policy
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  # MEDIUM: enable OMS agent logging
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
  }
}
