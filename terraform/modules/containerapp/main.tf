# Environnement Container Apps (réseau et logs partagés par les apps)
resource "azurerm_container_app_environment" "cae" {
  name                = "cae-${var.project}-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

# Le pipeline NYC Taxi : traitement batch, sans ingress (il n'écoute sur aucun port)
resource "azurerm_container_app" "app" {
  name                         = "ca-${var.project}-pipeline-${var.env}"
  resource_group_name          = var.rg_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  revision_mode                = "Single"
  tags                         = var.tags

  # Les valeurs sensibles passent par des secrets, jamais en clair dans les variables d'environnement
  secret {
    name  = "storage-conn"
    value = var.storage_connection_string
  }

  secret {
    name  = "pg-password"
    value = var.postgres_password
  }

  secret {
    name  = "acr-password"
    value = var.acr_password
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_username
    password_secret_name = "acr-password"
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "nyc-taxi-pipeline"
      image  = "${var.acr_login_server}/nyc-taxi-pipeline:latest"
      cpu    = var.cpu
      memory = var.memory

      # Noms attendus par le code Python (pipelines/ingestion, utils/)
      env {
        name        = "AZURE_STORAGE_CONNECTION_STRING"
        secret_name = "storage-conn"
      }

      env {
        name  = "AZURE_CONTAINER_NAME"
        value = var.storage_container_name
      }

      env {
        name  = "START_DATE"
        value = var.start_date
      }

      env {
        name  = "END_DATE"
        value = var.end_date
      }

      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "pg-password"
      }

      # Variables non sensibles supplémentaires (POSTGRES_HOST, POSTGRES_DB...)
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
}
