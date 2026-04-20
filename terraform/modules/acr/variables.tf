variable "name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy the ACR into."
  type        = string
}

variable "tags" {
  description = "Common tags for resources."
  type        = map(string)
  default     = {}
}
