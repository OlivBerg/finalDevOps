variable "redis_name" {
  description = "Name of the Redis cache instance. Must be globally unique."
  type        = string
}

variable "location" {
  description = "Azure region for the Redis cache."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy the Redis cache into."
  type        = string
}

variable "capacity" {
  description = "The size of the Redis cache. For Basic/Standard SKU: 0 (C0) to 6 (C6)."
  type        = number
  default     = 1
}

variable "family" {
  description = "The SKU family. Use 'C' for Basic/Standard, 'P' for Premium."
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "The SKU of Redis to use. Options: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "environment" {
  description = "Environment tag (e.g. test, prod)."
  type        = string
}
