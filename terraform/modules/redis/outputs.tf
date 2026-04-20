output "hostname" {
  description = "The hostname of the Redis cache."
  value       = azurerm_redis_cache.main.hostname
}

output "port" {
  description = "The non-SSL port of the Redis cache (6379)."
  value       = azurerm_redis_cache.main.port
}

output "ssl_port" {
  description = "The SSL port of the Redis cache (6380)."
  value       = azurerm_redis_cache.main.ssl_port
}

output "primary_access_key" {
  description = "The primary access key for the Redis cache."
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "connection_string" {
  description = "Redis connection string."
  value       = "${azurerm_redis_cache.main.hostname}:${azurerm_redis_cache.main.ssl_port},password=${azurerm_redis_cache.main.primary_access_key},ssl=True,abortConnect=False"
  sensitive   = true
}
