module "aws_s3" {
  source = "./modules/aws-s3"

  bucket_name    = var.bucket_name
  uc_external_id = var.uc_external_id
}

module "neon" {
  source = "./modules/neon"

  project_name = "mdp-${var.environment}"
  org_id       = var.neon_org_id
}

module "atlas" {
  source = "./modules/atlas"

  org_id       = var.mongodbatlas_org_id
  project_name = "mdp-${var.environment}"
  cluster_name = "mdp-${var.environment}"
}

module "unity_catalog" {
  source = "./modules/databricks-unity-catalog"

  iam_role_arn = module.aws_s3.iam_role_arn
  bucket_name  = module.aws_s3.bucket_name
}

module "secret_scopes" {
  source = "./modules/databricks-secret-scopes"

  neon_host          = module.neon.host
  neon_database_name = module.neon.database_name
  neon_role_name     = module.neon.role_name
  neon_password      = module.neon.password

  atlas_connection_string = module.atlas.connection_string
  atlas_username          = module.atlas.username
  atlas_password          = module.atlas.password
}
