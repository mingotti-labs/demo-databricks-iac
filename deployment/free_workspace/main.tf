module "aws_s3" {
  source   = "../../modules/aws-s3"
  for_each = var.environments

  bucket_name    = each.value.bucket_name
  uc_external_id = lookup(var.uc_external_ids, each.key, "")
}

module "neon" {
  source = "../../modules/neon"

  project_name = "mdp"
  org_id       = var.neon_org_id
}

module "atlas" {
  source = "../../modules/atlas"

  org_id       = var.mongodbatlas_org_id
  project_name = "mdp-${var.environment}"
  cluster_name = "mdp-${var.environment}"
}

module "unity_catalog" {
  source   = "../../modules/databricks-unity-catalog"
  for_each = var.environments

  catalog_name = each.value.catalog_name
  bucket_name  = module.aws_s3[each.key].bucket_name
  iam_role_arn = module.aws_s3[each.key].iam_role_arn
}

module "identity_governance" {
  source = "../../modules/databricks-identity-governance"

  human_account_username = var.human_account_username
}

module "access_groups" {
  source   = "../../modules/databricks-access-groups"
  for_each = var.environments

  catalog_name = module.unity_catalog[each.key].catalog_name
}

resource "databricks_group_member" "data_ops_read_access" {
  for_each  = var.environments
  group_id  = module.access_groups[each.key].group_id
  member_id = module.identity_governance.group_ids.data_ops
}

# Real, working access mechanism for now -- see main.tf's access_groups comment and
# design.md's Migration Plan (phase1-access-governance) for why membership in the AG
# groups above doesn't grant anything on this workspace/edition.
resource "databricks_grants" "cicd_catalog_use" {
  for_each = var.environments
  catalog  = module.unity_catalog[each.key].catalog_name

  # BROWSE added after a real pipeline run failure: USE_CATALOG alone isn't
  # enough for a pipeline cluster to initialize against Unity Catalog --
  # "PERMISSION_DENIED: User does not have BROWSE on Catalog 'mdp_dev'"
  # (confirmed via a real bundle-deployed pipeline run as the CI/CD SP, not
  # assumed upfront -- same discovery pattern as neon_dev's USE_CONNECTION gap).
  grant {
    principal  = module.identity_governance.cicd_client_id
    privileges = ["USE_CATALOG", "BROWSE"]
  }
}

locals {
  # Bronze-family schemas any CI/CD-run pipeline in this project writes into.
  # Kept in sync manually with modules/databricks-unity-catalog's local.schemas
  # -- see that module for the authoritative schema list.
  cicd_writable_schemas = [
    "bronze_neon", "bronze_neon_publish",
    "bronze_atlas", "bronze_atlas_publish",
    "bronze_clickstream", "bronze_clickstream_publish",
    "bronze_ungm", "bronze_ungm_publish",
    "bronze_acnc", "bronze_acnc_publish",
    "bronze_nsw_spatial", "bronze_nsw_spatial_publish",
    "bronze_airroi", "bronze_airroi_publish",
    "silver_landing_neon", "silver_landing_clickstream",
    "silver_landing_ungm", "silver_landing_acnc",
    "silver_landing_nsw_spatial", "silver_landing_airroi",
  ]
  cicd_schema_grants = {
    for pair in setproduct(keys(var.environments), local.cicd_writable_schemas) :
    "${pair[0]}.${pair[1]}" => {
      catalog_name = module.unity_catalog[pair[0]].catalog_name
      schema_name  = pair[1]
    }
  }
}

# USE_SCHEMA + CREATE_TABLE added after a real pipeline run failure --
# "PERMISSION_DENIED: User does not have CREATE TABLE and USE SCHEMA on Schema
# 'mdp_dev.bronze_neon'" -- catalog-level USE_CATALOG/BROWSE alone isn't
# enough for a pipeline to create/write its own managed table. Granted across
# every bronze schema up front (not discovered once per schema) since every
# ingestion/SCD pipeline in this project needs the same access on its own
# target schema.
#
# CREATE_MATERIALIZED_VIEW added after a second real failure --
# "PERMISSION_DENIED: User does not have CREATE MATERIALIZED VIEW on Schema
# 'mdp_dev.bronze_acnc'" -- confirmed CREATE_TABLE does NOT cover Materialized
# Views in Unity Catalog (it's a genuinely separate privilege; Streaming
# Tables have no such separate privilege, they fall under CREATE_TABLE,
# confirmed via the provider's own privilege enum). UNGM's unspsc_public_raw
# is also a Materialized View and had never actually been run under the
# CI/CD SP before this was found (confirmed via an empty
# `pipelines list-updates` on its SP-owned copy) -- applied proactively here
# rather than per-schema, since any future MV-based source hits the same gap.
resource "databricks_grants" "cicd_schema_use" {
  for_each = local.cicd_schema_grants
  schema   = "${each.value.catalog_name}.${each.value.schema_name}"

  grant {
    principal  = module.identity_governance.cicd_client_id
    privileges = ["USE_SCHEMA", "CREATE_TABLE", "CREATE_MATERIALIZED_VIEW"]
  }

  # Read access for the human operator -- table ownership passes to whichever
  # identity's pipeline creates it (usually the CI/CD SP now), and Unity
  # Catalog doesn't extend implicit SELECT to workspace-admin group members
  # for objects they don't own (confirmed via a real query failure: even as a
  # workspace admin, SELECT on a CI/CD-SP-created table was denied).
  grant {
    principal  = var.human_account_username
    privileges = ["SELECT"]
  }
}

module "neon_dev_connection" {
  source = "../../modules/databricks-uc-connection-postgres"

  name     = "neon_dev"
  host     = module.neon.dev_host
  user     = module.neon.dev_role_name
  password = module.neon.dev_password
}

# UC Connections aren't visible to a principal by default (only the creator/admins).
# The CI/CD SP needs this to deploy demo-databricks-mdp's Lakeflow Connect pipeline
# that references neon_dev -- confirmed via a real deploy failure ("Failed to
# retrieve connection 'neon_dev' from Unity Catalog"), not assumed upfront.
resource "databricks_grants" "cicd_neon_dev_connection_use" {
  foreign_connection = module.neon_dev_connection.connection_name

  grant {
    principal  = module.identity_governance.cicd_client_id
    privileges = ["USE_CONNECTION"]
  }
}

module "clickstream_volume" {
  source   = "../../modules/databricks-uc-volume"
  for_each = var.environments

  catalog_name = module.unity_catalog[each.key].catalog_name
  schema_name  = "bronze_clickstream"
  volume_name  = "s3_clickstream_raw"

  depends_on = [module.unity_catalog]
}

# READ_VOLUME + WRITE_VOLUME added after a real job run failure --
# "PERMISSION_DENIED: User does not have READ VOLUME on Volume
# mdp_dev.bronze_clickstream.s3_clickstream_raw" -- the exact risk flagged as
# unverified in phase3b-clickstream-volume's design.md, now confirmed real.
# Catalog/schema-level grants don't extend to volume contents; volumes need
# their own explicit grant, same as UC Connections needed USE_CONNECTION.
resource "databricks_grants" "cicd_clickstream_volume_use" {
  for_each = var.environments
  volume   = "${module.unity_catalog[each.key].catalog_name}.bronze_clickstream.${module.clickstream_volume[each.key].volume_name}"

  grant {
    principal  = module.identity_governance.cicd_client_id
    privileges = ["READ_VOLUME", "WRITE_VOLUME"]
  }
}

module "git_repo_iac" {
  source = "../../modules/databricks-git-repo"

  url  = "https://github.com/mingotti-labs/demo-databricks-iac"
  path = "/Repos/Shared/demo-databricks-iac"
}

module "git_repo_mdp" {
  source = "../../modules/databricks-git-repo"

  url  = "https://github.com/mingotti-labs/demo-databricks-mdp"
  path = "/Repos/Shared/demo-databricks-mdp"
}

module "secret_scopes" {
  source = "../../modules/databricks-secret-scopes"

  neon_host          = module.neon.dev_host
  neon_database_name = module.neon.dev_database_name
  neon_role_name     = module.neon.dev_role_name
  neon_password      = module.neon.dev_password

  atlas_connection_string = module.atlas.connection_string
  atlas_username          = module.atlas.username
  atlas_password          = module.atlas.password

  airroi_api_key = var.airroi_api_key
}

# READ added after a real prd pipeline run failure -- a SecretManagerClient
# error on `dbutils.secrets.get("airroi", "api_key")`, since the scope's only
# ACL was MANAGE for the human account (Terraform's own creator default).
# AirROI is the first source whose pipeline code actually calls
# dbutils.secrets.get() at runtime (neon-postgres/atlas-mongodb's secrets
# back Terraform-managed UC Connections instead, never read by pipeline code
# directly) -- so this is the first time a secret scope needed an explicit
# CI/CD SP grant, same class of gap as CREATE_MATERIALIZED_VIEW (see
# "CI/CD service principal pipeline execution" in CLAUDE.md).
resource "databricks_secret_acl" "cicd_airroi_read" {
  scope      = module.secret_scopes.airroi_scope_name
  principal  = module.identity_governance.cicd_client_id
  permission = "READ"
}
