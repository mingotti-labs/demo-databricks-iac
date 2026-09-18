output "uc_external_ids" {
  description = "Per-environment storage credential external_id. Set as uc_external_ids in dev.tfvars after first apply to harden each IAM trust policy."
  value       = { for k, m in module.unity_catalog : k => m.external_id }
}

output "catalog_names" {
  value = { for k, m in module.unity_catalog : k => m.catalog_name }
}

output "bucket_names" {
  value = { for k, m in module.aws_s3 : k => m.bucket_name }
}

output "cicd_client_id" {
  description = "OAuth client_id of the CI/CD service principal. Hand off to GitHub Actions as DATABRICKS_CLIENT_ID."
  value       = module.identity_governance.cicd_client_id
}

output "cicd_client_secret" {
  description = "OAuth client_secret of the CI/CD service principal. Hand off to GitHub Actions as DATABRICKS_CLIENT_SECRET."
  value       = module.identity_governance.cicd_client_secret
  sensitive   = true
}
