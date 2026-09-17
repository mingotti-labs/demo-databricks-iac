variable "project_name" {
  description = "Neon project name."
  type        = string
}

variable "org_id" {
  description = "Neon organisation ID."
  type        = string
}

variable "region_id" {
  description = "Neon deployment region."
  type        = string
  default     = "aws-ap-southeast-2"
}

variable "database_name" {
  description = "Name of the default database created in the project."
  type        = string
  default     = "app"
}

variable "role_name" {
  description = "Name of the default role created in the project."
  type        = string
  default     = "app"
}

variable "history_retention_seconds" {
  description = "Point-in-time restore history retention. This org's free-tier plan caps it at 21600 (6h)."
  type        = number
  default     = 21600
}
