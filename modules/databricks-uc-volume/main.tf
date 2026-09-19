terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_volume" "this" {
  catalog_name = var.catalog_name
  schema_name  = var.schema_name
  name         = var.volume_name
  volume_type  = "MANAGED"
  comment      = "Managed by Terraform"
}
