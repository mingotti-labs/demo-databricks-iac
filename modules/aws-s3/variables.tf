variable "bucket_name" {
  description = "Name of the S3 bucket used as the Unity Catalog external location."
  type        = string
}

variable "uc_external_id" {
  description = "Unity Catalog storage credential external_id. Empty on first apply (trust policy condition omitted); set after first apply to harden the trust policy."
  type        = string
  default     = ""
}

variable "databricks_account_iam_arn" {
  description = "IAM role ARN of the Databricks-managed AWS account allowed to assume this role. Databricks' published default for the standard AWS partition."
  type        = string
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}
