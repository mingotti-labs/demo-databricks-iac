terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_storage_credential" "this" {
  name = "${var.catalog_name}-s3-credential"
  aws_iam_role {
    role_arn = var.iam_role_arn
  }
  comment = "Managed by Terraform"
}

resource "databricks_external_location" "this" {
  name            = "${var.catalog_name}-external-location"
  url             = "s3://${var.bucket_name}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "Managed by Terraform"
}

resource "databricks_catalog" "this" {
  name         = var.catalog_name
  comment      = "Managed by Terraform"
  storage_root = "s3://${var.bucket_name}/"

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
    bronze_clickstream       = "Raw clickstream file-drop ingestion landing zone"
    gold_analytics_gateway   = "Analytics-facing gold layer"
    gold_integration_gateway = "Integration-facing gold layer"
    gold_ai_gateway          = "AI/ML-facing gold layer"
  }
}

resource "databricks_schema" "this" {
  for_each     = local.schemas
  catalog_name = databricks_catalog.this.name
  name         = each.key
  comment      = each.value
}
