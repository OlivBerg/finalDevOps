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
  description = "Kubernetes version to use for the cluster."
  type        = string
  default     = "1.32"
}

variable "environment" {
  description = "Environment tag (e.g. dev, test, prod)."
  type        = string
}
