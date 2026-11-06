# Data lake : un Storage Account (LRS, le moins cher) et un Blob Container privé pour les Parquet
resource "azurerm_storage_account" "sa" {
  name                     = "${var.storage_account_prefix}${var.suffix}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
