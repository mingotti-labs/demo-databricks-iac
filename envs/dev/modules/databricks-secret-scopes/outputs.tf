output "neon_scope_name" {
  value = databricks_secret_scope.neon_postgres.name
}

output "atlas_scope_name" {
  value = databricks_secret_scope.atlas_mongodb.name
}
