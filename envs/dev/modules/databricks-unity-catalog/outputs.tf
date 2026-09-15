output "storage_credential_name" {
  value = databricks_storage_credential.this.id
}

output "external_location_name" {
  value = databricks_external_location.this.id
}

output "catalog_names" {
  value = [for c in databricks_catalog.this : c.name]
}

output "external_id" {
  description = "external_id generated for the storage credential's IAM trust policy. Use to harden the aws-s3 module's uc_external_id input on the second apply."
  value       = databricks_storage_credential.this.aws_iam_role[0].external_id
}
