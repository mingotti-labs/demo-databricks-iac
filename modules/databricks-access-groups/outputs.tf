output "group_id" {
  value = databricks_group.read_access.id
}

output "group_display_name" {
  value = databricks_group.read_access.display_name
}
