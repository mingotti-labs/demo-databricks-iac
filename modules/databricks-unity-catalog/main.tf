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

resource "databricks_schema" "this" {
  for_each     = var.schemas
  catalog_name = databricks_catalog.this.name
  name         = each.key
  comment      = each.value
}
