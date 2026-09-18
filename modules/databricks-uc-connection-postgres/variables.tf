variable "name" {
  description = "Name of the UC Connection."
  type        = string
}

variable "host" {
  description = "PostgreSQL server hostname."
  type        = string
}

variable "port" {
  description = "PostgreSQL server port."
  type        = string
  default     = "5432"
}

variable "user" {
  description = "Database user for the connection."
  type        = string
}

variable "password" {
  description = "Database password for the connection."
  type        = string
  sensitive   = true
}
