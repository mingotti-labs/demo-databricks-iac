output "volume_name" {
  value = databricks_volume.this.name
}

output "volume_path" {
  value = "/Volumes/${var.catalog_name}/${var.schema_name}/${var.volume_name}"
}
