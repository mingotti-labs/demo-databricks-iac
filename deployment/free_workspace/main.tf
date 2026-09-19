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

  grant {
    principal  = module.identity_governance.cicd_client_id
    privileges = ["USE_CATALOG"]
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
}
