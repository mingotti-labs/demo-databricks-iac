terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.132"
    }
  }
}

resource "databricks_group" "platform_engineering" {
  display_name = "FG Platform Engineering"
}

resource "databricks_group" "data_engineering" {
  display_name = "FG Data Engineering"
}

resource "databricks_group" "data_ops" {
  display_name = "FG Data Ops"
}

resource "databricks_service_principal" "cicd_github" {
  display_name = var.cicd_service_principal_name

  # Minimal entitlement a bundle deploy actually needs, per the 403 a real
  # `bundle deploy` attempt returned: "disabled for users without the
  # databricks-sql-access or workspace-access or workspace-consume entitlements".
  # workspace_access is the narrowest of the three that satisfies the check.
  workspace_access = true
}

resource "databricks_service_principal_secret" "cicd_github" {
  service_principal_id = databricks_service_principal.cicd_github.id
}

data "databricks_user" "human" {
  user_name = var.human_account_username
}

resource "databricks_group_member" "cicd_github_data_ops" {
  group_id  = databricks_group.data_ops.id
  member_id = databricks_service_principal.cicd_github.id
}

resource "databricks_group_member" "human_data_ops" {
  group_id  = databricks_group.data_ops.id
  member_id = data.databricks_user.human.id
}
