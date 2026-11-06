variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "cosmosdb_account_location" {
  type = string
}

variable "account_name_prefix" {
  type = string
}

variable "sqldb_name" {
  type = string
}

variable "sql_container_name" {
  type = string
}

variable "throughput" {
  type = number
}

variable "suffix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
