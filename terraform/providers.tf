terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      # Le groupe de ressources est fourni (data source) : on ne le supprime jamais depuis ce projet
      prevent_deletion_if_contains_resources = false
    }
  }
  # Compte étudiant : les fournisseurs de ressources sont déjà enregistrés, pas les droits pour le faire
  skip_provider_registration = true
  storage_use_azuread        = true
}
