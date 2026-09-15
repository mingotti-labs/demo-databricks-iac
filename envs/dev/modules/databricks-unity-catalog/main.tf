terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_storage_credential" "this" {
  name = var.storage_credential_name
  aws_iam_role {
    role_arn = var.iam_role_arn
  }
  comment = "Managed by Terraform"
}

resource "databricks_external_location" "this" {
  name            = var.external_location_name
  url             = "s3://${var.bucket_name}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "Managed by Terraform"
}

resource "databricks_catalog" "this" {
  for_each     = toset(var.catalog_names)
  name         = each.value
  comment      = "Managed by Terraform"
  storage_root = "s3://${var.bucket_name}/${each.value}/"

  depends_on = [databricks_external_location.this]
}

locals {
  schemas = {
    bronze_neon              = "Raw Neon Postgres ingestion landing zone"
    bronze_neon_history      = "Full history / before-image records for Neon"
    bronze_neon_publish      = "Publish-ready view of Neon bronze data"
    bronze_atlas             = "Raw MongoDB Atlas ingestion landing zone"
    bronze_atlas_history     = "Full history / before-image records for Atlas"
    bronze_atlas_publish     = "Publish-ready view of Atlas bronze data"
    gold_analytics_gateway   = "Analytics-facing gold layer"
    gold_integration_gateway = "Integration-facing gold layer"
    gold_ai_gateway          = "AI/ML-facing gold layer"
  }

  catalog_schemas = {
    for pair in setproduct(var.catalog_names, keys(local.schemas)) :
    "${pair[0]}.${pair[1]}" => {
      catalog_name = pair[0]
      schema_name  = pair[1]
      comment      = local.schemas[pair[1]]
    }
  }
}

resource "databricks_schema" "this" {
  for_each     = local.catalog_schemas
  catalog_name = databricks_catalog.this[each.value.catalog_name].name
  name         = each.value.schema_name
  comment      = each.value.comment
}
