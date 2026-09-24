variable "neon_host" {
  type = string
}

variable "neon_database_name" {
  type = string
}

variable "neon_role_name" {
  type = string
}

variable "neon_password" {
  type      = string
  sensitive = true
}

variable "atlas_connection_string" {
  type = string
}

variable "atlas_username" {
  type = string
}

variable "atlas_password" {
  type      = string
  sensitive = true
}

variable "airroi_api_key" {
  type      = string
  sensitive = true
}
