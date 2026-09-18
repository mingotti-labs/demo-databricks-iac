output "cicd_client_id" {
  description = "OAuth client_id (application_id) of the CI/CD service principal."
  value       = databricks_service_principal.cicd_github.application_id
}

output "cicd_service_principal_id" {
  description = "Internal Databricks id of the CI/CD service principal (for databricks_group_member, distinct from the OAuth application_id)."
  value       = databricks_service_principal.cicd_github.id
}

output "cicd_client_secret" {
  description = "OAuth client_secret of the CI/CD service principal. Hand off to GitHub Actions secrets only."
  value       = databricks_service_principal_secret.cicd_github.secret
  sensitive   = true
}

output "group_ids" {
  description = "Map of the three functional groups' Databricks IDs, keyed by short name."
  value = {
    platform_engineering = databricks_group.platform_engineering.id
    data_engineering     = databricks_group.data_engineering.id
    data_ops             = databricks_group.data_ops.id
  }
}
