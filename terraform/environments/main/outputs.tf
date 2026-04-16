output "resource_group_name" {
  value = module.network.resource_group_name
}

output "virtual_network_id" {
  value = module.network.virtual_network_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}
