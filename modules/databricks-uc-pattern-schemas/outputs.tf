output "schema_names" {
  value = [for s in databricks_schema.this : s.name]
}
