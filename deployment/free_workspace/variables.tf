variable "aws_region" {
  description = "AWS region for the S3 bucket and Neon/Atlas resources."
  type        = string
}

variable "environment" {
  description = "Environment name, used to namespace cloud resources (e.g. Neon/Atlas project names)."
  type        = string
}

variable "environments" {
  description = "Per-environment catalog name and S3 bucket name. Defaults match this project's existing naming."
  type = map(object({
    catalog_name = string
    bucket_name  = string
  }))
  default = {
    dev = { catalog_name = "mdp_dev", bucket_name = "hoe-mdp-dev" }
    tst = { catalog_name = "mdp_tst", bucket_name = "hoe-mdp-tst" }
    prd = { catalog_name = "mdp_prd", bucket_name = "hoe-mdp-prd" }
  }
}

variable "human_account_username" {
  description = "Username (email) of the human account to add to FG Data Ops alongside the CI/CD service principal."
  type        = string
  default     = "handsonessential@gmail.com"
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

variable "uc_external_ids" {
  description = "Per-environment storage credential external_id, keyed the same as `environments`. Empty on first apply; set from `terraform output uc_external_ids` after first apply to harden each IAM trust policy (see design.md)."
  type        = map(string)
  default     = {}
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
