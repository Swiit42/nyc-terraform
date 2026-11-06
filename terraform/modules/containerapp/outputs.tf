output "container_app_name" {
  value = azurerm_container_app.app.name
}

output "acr_login_server" {
  value = var.acr_login_server
}

