terraform {
  required_version = ">= 1.16"

  cloud {
    organization = "hands-on-essential-mingotti"
    workspaces {
      name = "demo-databricks-iac"
    }
  }

  # Providers added in Phase 1 as modules are built
  required_providers {}
}
