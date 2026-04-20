output "resource_group_name" {
  value = module.network.resource_group_name
}

output "virtual_network_id" {
  value = module.network.virtual_network_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

# ---------------------------------------------------------------------------
# AKS outputs
# ---------------------------------------------------------------------------

output "aks_test_cluster_name" {
  description = "Name of the test AKS cluster."
  value       = module.aks_test.cluster_name
}

output "aks_test_resource_group" {
  description = "Resource group of the test AKS cluster."
  value       = module.aks_test.resource_group_name
}

output "aks_prod_cluster_name" {
  description = "Name of the prod AKS cluster."
  value       = module.aks_prod.cluster_name
}

output "aks_prod_resource_group" {
  description = "Resource group of the prod AKS cluster."
  value       = module.aks_prod.resource_group_name
}


