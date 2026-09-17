module "aws_s3" {
  source   = "../../modules/aws-s3"
  for_each = var.environments

  bucket_name    = each.value.bucket_name
  uc_external_id = lookup(var.uc_external_ids, each.key, "")
}

module "neon" {
  source = "../../modules/neon"

  project_name = "mdp-${var.environment}"
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

module "secret_scopes" {
  source = "../../modules/databricks-secret-scopes"

  neon_host          = module.neon.host
  neon_database_name = module.neon.database_name
  neon_role_name     = module.neon.role_name
  neon_password      = module.neon.password

  atlas_connection_string = module.atlas.connection_string
  atlas_username          = module.atlas.username
  atlas_password          = module.atlas.password
}
