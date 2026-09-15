variable "iam_role_arn" {
  description = "ARN of the IAM role Unity Catalog assumes to access the external S3 bucket."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket backing the external location."
  type        = string
}

variable "storage_credential_name" {
  description = "Name of the Unity Catalog storage credential."
  type        = string
  default     = "mdp-s3-credential"
}

variable "external_location_name" {
  description = "Name of the Unity Catalog external location."
  type        = string
  default     = "mdp-external-location"
}

variable "catalog_names" {
  description = "Names of the catalogs to create."
  type        = list(string)
  default     = ["mdp_dev", "mdp_tst", "mdp_prd"]
}
