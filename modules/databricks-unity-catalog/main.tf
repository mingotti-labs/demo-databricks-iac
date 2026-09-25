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
    bronze_neon                = "Raw Neon Postgres ingestion landing zone"
    bronze_neon_publish        = "Publish-ready view of Neon bronze data (incl. SCD1/SCD2 tables)"
    bronze_atlas               = "Raw MongoDB Atlas ingestion landing zone"
    bronze_atlas_publish       = "Publish-ready view of Atlas bronze data"
    bronze_clickstream         = "Raw clickstream file-drop ingestion landing zone"
    bronze_clickstream_publish = "Publish-ready view of clickstream bronze data (incl. SCD1 table)"
    bronze_ungm                = "Raw UNGM API ingestion landing zone"
    bronze_ungm_publish        = "Publish-ready view of UNGM bronze data (incl. SCD1/SCD2 tables)"
    bronze_acnc                = "Raw ACNC Charity Register ingestion landing zone"
    bronze_acnc_publish        = "Publish-ready view of ACNC bronze data (incl. SCD1/SCD2 tables)"
    bronze_nsw_spatial         = "Raw NSW Spatial Services ingestion landing zone"
    bronze_nsw_spatial_publish = "Publish-ready view of NSW Spatial Services bronze data (incl. SCD1/SCD2 tables)"
    bronze_airroi              = "Raw AirROI market intelligence ingestion landing zone"
    bronze_airroi_publish      = "Publish-ready view of AirROI bronze data (incl. SCD2 table)"
    bronze_iso                 = "Raw ISO 3166 country/subdivision reference ingestion landing zone"
    bronze_iso_publish         = "Publish-ready view of ISO 3166 bronze data (incl. SCD1/SCD2 tables)"
    bronze_geonames            = "Raw GeoNames gazetteer reference ingestion landing zone"
    bronze_geonames_publish    = "Publish-ready view of GeoNames bronze data (incl. SCD2 tables)"
    silver_landing_neon        = "Source-aligned Silver Landing for Neon (customers, products, orders, order_items)"
    silver_landing_clickstream = "Source-aligned Silver Landing for clickstream (web_events)"
    silver_landing_ungm        = "Source-aligned Silver Landing for UNGM (unspsc_public)"
    silver_landing_acnc        = "Source-aligned Silver Landing for ACNC (charity_register)"
    silver_landing_nsw_spatial = "Source-aligned Silver Landing for NSW Spatial Services (property)"
    silver_landing_airroi      = "Source-aligned Silver Landing for AirROI (market_metrics_all, market_summary)"
    gold_analytics_gateway     = "Analytics-facing gold layer"
    gold_integration_gateway   = "Integration-facing gold layer"
    gold_ai_gateway            = "AI/ML-facing gold layer"
  }
}

resource "databricks_schema" "this" {
  for_each     = local.schemas
  catalog_name = databricks_catalog.this.name
  name         = each.key
  comment      = each.value
}
