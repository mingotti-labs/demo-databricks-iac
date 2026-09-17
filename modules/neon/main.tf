terraform {
  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18"
    }
  }
}

resource "neon_project" "this" {
  name                       = var.project_name
  region_id                  = var.region_id
  org_id                     = var.org_id
  history_retention_seconds = var.history_retention_seconds

  branch {
    database_name = var.database_name
    role_name     = var.role_name
  }
}
