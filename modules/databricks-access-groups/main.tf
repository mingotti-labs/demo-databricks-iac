terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

# NOTE: this group intentionally does NOT hold a databricks_grants resource.
# Unity Catalog grants resolve principals against ACCOUNT-level identities; a
# workspace-scoped databricks_group (the only kind Free Edition's API lets Terraform
# create -- account-level API returns Not Found) cannot be granted a UC privilege.
# Confirmed empirically: both a brand-new group and a long-established one
# ("FG Data Ops") failed identically with "Could not find principal with name ...",
# via the Databricks CLI directly (not a Terraform-provider quirk), while a manual
# grant to a genuine (unexplained) account-level group succeeded through the UI.
# Kept as a workspace-level group for now, structurally reserved for a future
# account-level migration -- see the phase1-access-governance change's design.md.
resource "databricks_group" "read_access" {
  display_name = "AG Catalog ${var.catalog_name} READ"
}
