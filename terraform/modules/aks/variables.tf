variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy the AKS cluster into."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to attach the node pool to."
  type        = string
}

variable "node_count" {
  description = "Fixed node count (used when auto-scaling is disabled, i.e. min_count == max_count)."
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Minimum node count for auto-scaling. Set equal to max_count to disable auto-scaling."
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum node count for auto-scaling. Set equal to min_count to disable auto-scaling."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version (minor, e.g. 1.33). Use 1.33+ on standard tier; Azure 1.32.x is LTS-only (Premium)."
  type        = string
  default     = "1.33"
}

variable "environment" {
  description = "Environment tag (e.g. dev, test, prod)."
  type        = string
}

variable "api_server_authorized_ip_ranges" {
  description = "CIDRs allowed for AKS API server access. Empty = no IP filter (not 0.0.0.0/0 when non-empty)."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for OMS agent logging."
  type        = string
}
