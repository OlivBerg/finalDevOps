output "storage_account_name" {
  description = "Name of the storage account used for Terraform remote state."
  value       = module.tfstate_storage.storage_account_name
}

output "container_names" {
  description = "Blob container per environment — use one backend.hcl per Terraform root."
  value       = module.tfstate_storage.container_names
}

output "access_key" {
  description = "Primary access key for the storage account."
  value       = module.tfstate_storage.access_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group containing the state storage."
  value       = module.tfstate_storage.resource_group_name
}

output "state_blob_key_default" {
  description = "Default blob name inside each container for infrastructure state."
  value       = module.tfstate_storage.state_blob_key_default
}

output "backend_config_dev" {
  description = "backend.hcl fragment for dev state (terraform/environments/dev or local experiments)."
  value       = <<-EOT
    resource_group_name  = "${module.tfstate_storage.resource_group_name}"
    storage_account_name = "${module.tfstate_storage.storage_account_name}"
    container_name       = "${module.tfstate_storage.container_names["dev"]}"
    key                  = "${module.tfstate_storage.state_blob_key_default}"
  EOT
}

output "backend_config_test" {
  description = "backend.hcl fragment for test / staging infrastructure state."
  value       = <<-EOT
    resource_group_name  = "${module.tfstate_storage.resource_group_name}"
    storage_account_name = "${module.tfstate_storage.storage_account_name}"
    container_name       = "${module.tfstate_storage.container_names["test"]}"
    key                  = "${module.tfstate_storage.state_blob_key_default}"
  EOT
}

output "backend_config_prod" {
  description = "backend.hcl fragment for production infrastructure state."
  value       = <<-EOT
    resource_group_name  = "${module.tfstate_storage.resource_group_name}"
    storage_account_name = "${module.tfstate_storage.storage_account_name}"
    container_name       = "${module.tfstate_storage.container_names["prod"]}"
    key                  = "${module.tfstate_storage.state_blob_key_default}"
  EOT
}
