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

variable "api_server_authorized_ip_ranges" {
  description = "CIDRs allowed to reach the AKS API server (kubectl). Empty = no IP restriction (public API). Set e.g. [\"203.0.113.1/32\"] for home/office IP only."
  type        = list(string)
  default     = []
}
