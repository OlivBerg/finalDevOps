variable "location" {
  description = "Azure region."
  type        = string
  default     = "canadacentral"
}

variable "group_number" {
  description = "Brightspace group number (used in default resource group name: cst8918-final-project-group-<group_number>)."
  type        = string
  default     = "4"
}

variable "resource_group_name" {
  description = "Optional override for the network resource group name."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags for resources."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for AKS OMS agent logging."
  type        = string
}

variable "api_server_authorized_ip_ranges" {
  description = "List of IP ranges allowed to access the AKS API server."
  type        = list(string)
}
