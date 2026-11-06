resource "random_string" "suffix" {
  length  = var.length
  lower   = true
  upper   = false
  numeric = false
  special = false
}
