terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

locals {
  schemas = {
    pattern_bronze         = "Output of pattern-only bronze implementations (design-pattern reference, dev only)"
    pattern_bronze_publish = "Output of pattern-only bronze publish implementations (design-pattern reference, dev only)"
  }
}

resource "databricks_schema" "this" {
  for_each     = local.schemas
  catalog_name = var.catalog_name
  name         = each.key
  comment      = each.value
}
