variable "catalog_name" {
  description = "Name of the catalog to create (e.g. mdp_dev)."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket backing this catalog's external location."
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role Unity Catalog assumes to access this catalog's S3 bucket."
  type        = string
}
