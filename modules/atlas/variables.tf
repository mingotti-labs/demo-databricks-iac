variable "org_id" {
  description = "MongoDB Atlas organisation ID."
  type        = string
}

variable "project_name" {
  description = "MongoDB Atlas project name."
  type        = string
}

variable "cluster_name" {
  description = "MongoDB Atlas M0 cluster name."
  type        = string
  default     = "mdp-dev"
}

variable "backing_provider_name" {
  description = "Cloud provider backing the M0 tenant cluster."
  type        = string
  default     = "AWS"
}

variable "region_name" {
  description = "Atlas region name for the M0 tenant cluster (Atlas naming, e.g. AP_SOUTHEAST_2)."
  type        = string
  default     = "AP_SOUTHEAST_2"
}

variable "database_username" {
  description = "Username for the Atlas database user."
  type        = string
  default     = "app"
}
