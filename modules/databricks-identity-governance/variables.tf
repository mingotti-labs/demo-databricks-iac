variable "cicd_service_principal_name" {
  description = "Display name of the CI/CD service principal used by GitHub Actions to run bundle deploy."
  type        = string
  default     = "svc-cicd-github"
}

variable "human_account_username" {
  description = "Username (email) of the existing human account to add to FG Data Ops alongside the CI/CD service principal."
  type        = string
}
