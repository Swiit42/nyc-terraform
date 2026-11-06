# Groupe de ressources fourni par la formation : lu, jamais créé ni détruit par ce projet
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Suffixe aléatoire commun : rend uniques les noms globaux (Storage, Cosmos DB, ACR)
module "naming" {
  source = "./modules/naming"
  length = 5
}

# Data lake : Storage Account + Blob Container des fichiers Parquet
module "storage" {
  source                 = "./modules/storage"
  rg_name                = data.azurerm_resource_group.rg.name
  location               = data.azurerm_resource_group.rg.location
  storage_account_prefix = var.storage_account_name
  storage_container_name = var.storage_container_name
  suffix                 = module.naming.suffix
  tags                   = var.tags
}

module "cosmos" {
  source                    = "./modules/cosmos"
  rg_name                   = data.azurerm_resource_group.rg.name
  location                  = var.location
  cosmosdb_account_location = var.cosmosdb_account_location
  account_name_prefix       = var.cosmosdb_account_name
  sqldb_name                = var.cosmosdb_sqldb_name
  sql_container_name        = var.sql_container_name
  throughput                = var.throughput
  suffix                    = module.naming.suffix
  tags                      = var.tags
}

# Le pipeline (image de l'ACR) dans une Container App
module "containerapp" {
  source   = "./modules/containerapp"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location
  project  = var.project_name
  env      = var.environment
  tags     = var.tags

  acr_login_server = azurerm_container_registry.acr.login_server
  acr_username     = azurerm_container_registry.acr.admin_username
  acr_password     = azurerm_container_registry.acr.admin_password

  cpu          = var.container_apps_cpu
  memory       = var.container_apps_memory
  min_replicas = var.container_apps_min_replicas
  max_replicas = var.container_apps_max_replicas

  storage_connection_string = module.storage.primary_connection_string
  storage_container_name    = module.storage.storage_container_name
  start_date                = var.start_date
  end_date                  = var.end_date
  postgres_password         = var.postgres_password
  env_vars                  = var.env_vars
}
