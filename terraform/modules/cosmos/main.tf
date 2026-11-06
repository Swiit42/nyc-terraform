# Compte Cosmos DB (API NoSQL), une seule région, sans bascule automatique : le moins cher
resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = "${var.account_name_prefix}${var.suffix}"
  location            = var.cosmosdb_account_location
  resource_group_name = var.rg_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  automatic_failover_enabled = false

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
}

# Le débit est provisionné au niveau de la base et partagé par ses containers :
# un seul paiement de 400 RU/s au lieu d'un par container
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.sqldb_name
  resource_group_name = var.rg_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  throughput          = var.throughput
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = var.sql_container_name
  resource_group_name = var.rg_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_sql_database.main.name

  partition_key_paths   = ["/id"]
  partition_key_version = 2

  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
  }
}
