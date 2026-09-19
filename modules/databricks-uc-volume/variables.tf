variable "catalog_name" {
  description = "Catalog the volume's schema belongs to."
  type        = string
}

variable "schema_name" {
  description = "Schema the volume belongs to. The volume is not shared across schemas/source systems."
  type        = string
}

variable "volume_name" {
  description = "Name of the volume, e.g. s3_clickstream_raw."
  type        = string
}
