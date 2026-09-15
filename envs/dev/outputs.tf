output "uc_external_id" {
  description = "Storage credential external_id. Set as uc_external_id in dev.tfvars after first apply to harden the IAM trust policy."
  value       = module.unity_catalog.external_id
}

output "catalog_names" {
  value = module.unity_catalog.catalog_names
}

output "bucket_name" {
  value = module.aws_s3.bucket_name
}
