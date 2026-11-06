# ===================================================================== Général
variable "resource_group_name" {
  type        = string
  default     = "otymoshenkoRG"
  description = "Groupe de ressources existant (fourni par la formation), lu en data source."
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Région Azure des ressources."
}

variable "project_name" {
  type        = string
  description = "Nom court du projet, en minuscules (entre dans le nom des ressources)."
}

variable "environment" {
  type        = string
  description = "Environnement : dev, test ou prod."
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags posés sur toutes les ressources (Project, Owner, Environment, ManagedBy...)."
}

# ===================================================================== Storage (Blob)
variable "storage_account_name" {
  type        = string
  default     = "storageaccount"
  description = "Préfixe du Storage Account (minuscules et chiffres) ; un suffixe aléatoire le rend unique, 24 caractères au total."
}

variable "storage_container_name" {
  type        = string
  default     = "storagecontainer"
  description = "Nom du Blob Container qui reçoit les fichiers Parquet."
}

# ===================================================================== Cosmos DB
variable "cosmosdb_account_name" {
  type        = string
  default     = "cosmosdbaccount"
  description = "Préfixe du compte Cosmos DB ; un suffixe aléatoire le rend unique."
}

variable "cosmosdb_account_location" {
  type        = string
  default     = "francecentral"
  description = "Région du compte Cosmos DB."
}

variable "cosmosdb_sqldb_name" {
  type        = string
  default     = "default-cosmosdb-sqldb"
  description = "Nom de la base Cosmos DB."
}

variable "sql_container_name" {
  type        = string
  default     = "default-sql-container"
  description = "Nom du container de la base Cosmos DB."
}

variable "throughput" {
  type        = number
  default     = 400
  description = "Débit provisionné de la base Cosmos DB, en RU/s (400 = minimum, le moins cher)."
  validation {
    condition     = var.throughput >= 400 && var.throughput <= 1000000
    error_message = "Le débit doit être compris entre 400 et 1 000 000 RU/s."
  }
  validation {
    condition     = var.throughput % 100 == 0
    error_message = "Le débit doit être un multiple de 100."
  }
}

# ===================================================================== Container App (pipeline)
variable "start_date" {
  type        = string
  description = "Premier mois à ingérer, au format YYYY-MM (variable START_DATE du pipeline)."
}

variable "end_date" {
  type        = string
  description = "Dernier mois à ingérer, au format YYYY-MM (variable END_DATE du pipeline)."
}

variable "container_apps_cpu" {
  type        = number
  default     = 0.5
  description = "vCPU du container du pipeline."
}

variable "container_apps_memory" {
  type        = string
  default     = "1Gi"
  description = "Mémoire du container du pipeline (doit correspondre au CPU : 0.5 -> 1Gi, 1 -> 2Gi...)."
}

variable "container_apps_min_replicas" {
  type        = number
  default     = 0
  description = "Réplicas minimum (0 = aucun coût quand le pipeline ne tourne pas)."
}

variable "container_apps_max_replicas" {
  type        = number
  default     = 1
  description = "Réplicas maximum."
}

variable "postgres_password" {
  type        = string
  sensitive   = true
  description = "Mot de passe PostgreSQL, transmis au container comme secret (POSTGRES_PASSWORD)."
}

variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Variables d'environnement NON sensibles en plus pour le pipeline (POSTGRES_HOST, POSTGRES_DB...)."
}
