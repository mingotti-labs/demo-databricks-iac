terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_repo" "this" {
  url  = var.url
  path = var.path
}
