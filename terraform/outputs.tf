output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_container_name" {
  value = module.storage.storage_container_name
}

output "cosmos_account_name" {
  value = module.cosmos.cosmos_account_name
}

output "cosmos_database_name" {
  value = module.cosmos.cosmos_database_name
}

output "acr_login_server" {
  description = "Cible du docker push de l'image du pipeline."
  value       = azurerm_container_registry.acr.login_server
}

output "container_app_name" {
  value = module.containerapp.container_app_name
}
