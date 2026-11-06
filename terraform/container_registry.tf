# Registry privé de l'image du pipeline (docker push vers <login_server>/nyc-taxi-pipeline:latest)
resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.environment}${module.naming.suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  # Compte admin : la Container App s'authentifie avec lui (identité managée = amélioration possible)
  admin_enabled = true
  tags          = var.tags
}
