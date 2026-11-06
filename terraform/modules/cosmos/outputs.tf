output "cosmos_account_name" {
  value = azurerm_cosmosdb_account.cosmos_account.name
}

output "cosmos_database_name" {
  value = azurerm_cosmosdb_sql_database.main.name
}
