terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_secret_scope" "neon_postgres" {
  name = "neon-postgres"
}

resource "databricks_secret" "neon_host" {
  scope        = databricks_secret_scope.neon_postgres.id
  key          = "host"
  string_value = var.neon_host
}

resource "databricks_secret" "neon_database_name" {
  scope        = databricks_secret_scope.neon_postgres.id
  key          = "database_name"
  string_value = var.neon_database_name
}

resource "databricks_secret" "neon_role_name" {
  scope        = databricks_secret_scope.neon_postgres.id
  key          = "role_name"
  string_value = var.neon_role_name
}

resource "databricks_secret" "neon_password" {
  scope        = databricks_secret_scope.neon_postgres.id
  key          = "password"
  string_value = var.neon_password
}

resource "databricks_secret_scope" "atlas_mongodb" {
  name = "atlas-mongodb"
}

resource "databricks_secret" "atlas_connection_string" {
  scope        = databricks_secret_scope.atlas_mongodb.id
  key          = "connection_string"
  string_value = var.atlas_connection_string
}

resource "databricks_secret" "atlas_username" {
  scope        = databricks_secret_scope.atlas_mongodb.id
  key          = "username"
  string_value = var.atlas_username
}

resource "databricks_secret" "atlas_password" {
  scope        = databricks_secret_scope.atlas_mongodb.id
  key          = "password"
  string_value = var.atlas_password
}
