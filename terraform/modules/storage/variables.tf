variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_prefix" {
  type        = string
  description = "Préfixe du nom (minuscules et chiffres) ; avec le suffixe, 3 à 24 caractères."
}

variable "storage_container_name" {
  type = string
}

variable "suffix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
