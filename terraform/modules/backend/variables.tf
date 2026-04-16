variable "location" {
  description = "Azure region for the Terraform state resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that will hold the state storage."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 lowercase letters and numbers only)."
  type        = string
}

variable "tags" {
  description = "Optional tags for resources."
  type        = map(string)
  default     = {}
}
