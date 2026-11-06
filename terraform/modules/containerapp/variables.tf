variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Registry
variable "acr_login_server" {
  type = string
}

variable "acr_username" {
  type = string
}

variable "acr_password" {
  type      = string
  sensitive = true
}

# Ressources du container
variable "cpu" {
  type = number
}

variable "memory" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

# Configuration du pipeline
variable "storage_connection_string" {
  type      = string
  sensitive = true
}

variable "storage_container_name" {
  type = string
}

variable "start_date" {
  type = string
}

variable "end_date" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "env_vars" {
  type    = map(string)
  default = {}
}
