variable "aws_region" {
  description = "AWS region for the S3 bucket and Neon/Atlas resources."
  type        = string
}

variable "environment" {
  description = "Environment name, used to namespace cloud resources (e.g. Neon/Atlas project names)."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket used as the Unity Catalog external location."
  type        = string
}

variable "databricks_host" {
  description = "URL of the Databricks workspace."
  type        = string
}

variable "mongodbatlas_org_id" {
  description = "MongoDB Atlas organisation ID."
  type        = string
}

variable "neon_org_id" {
  description = "Neon organisation ID."
  type        = string
}

variable "uc_external_id" {
  description = "Unity Catalog storage credential external_id. Empty on first apply; set from `terraform output uc_external_id` after first apply to harden the IAM trust policy (see design.md)."
  type        = string
  default     = ""
}

variable "aws_access_key_id" {
  description = "AWS access key ID. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}

variable "databricks_token" {
  description = "Databricks personal access token. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}

variable "neon_api_key" {
  description = "Neon API key. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas Programmatic Access Key public key. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas Programmatic Access Key private key. Set via HCP Terraform variable set, never in a tfvars file."
  type        = string
  sensitive   = true
}
