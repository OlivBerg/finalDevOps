variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "group_number" {
  description = "Brightspace group number; used in the default resource group name."
  type        = string
}

variable "resource_group_name" {
  description = "Optional override for the resource group name. Defaults to cst8918-final-project-group-<group_number>."
  type        = string
  default     = null
}

variable "tags" {
  description = "Optional tags for resources."
  type        = map(string)
  default     = {}
}
