## MODIFIED Requirements

### Requirement: CI/CD service principal catalog access
The CI/CD service principal SHALL have `USE_CATALOG` and `BROWSE` on each of
the three environment catalogs (`mdp_dev`, `mdp_tst`, `mdp_prd`) and no
broader catalog-level Unity Catalog privilege, granted via Terraform
(`databricks_grants`, composed at the root from the
`aws_s3`/`unity_catalog`/`identity_governance` modules' outputs). `BROWSE` is
required in addition to `USE_CATALOG` for a pipeline cluster to initialize
against Unity Catalog at all — confirmed via a real pipeline run failure
(`PERMISSION_DENIED: User does not have BROWSE on Catalog 'mdp_dev'`), not
assumed from `USE_CATALOG` alone being sufficient.

#### Scenario: Bundle-deployed job runs successfully
- **WHEN** a Lakeflow Declarative Pipeline deployed and run as the CI/CD
  service principal is triggered against its target catalog
- **THEN** the run does not fail with `PERMISSION_DENIED: User does not have
  BROWSE on Catalog '<name>'` or `PERMISSION_DENIED: User does not have USE
  CATALOG on Catalog '<name>'`

## ADDED Requirements

### Requirement: CI/CD service principal schema access
The CI/CD service principal SHALL have `USE_SCHEMA` and `CREATE_TABLE` on
every bronze-family schema (`bronze_neon`, `bronze_neon_publish`,
`bronze_atlas`, `bronze_atlas_publish`, `bronze_clickstream`,
`bronze_clickstream_publish`) in each of the three environment catalogs,
granted via Terraform. Catalog-level `USE_CATALOG`/`BROWSE` alone is not
sufficient for a pipeline to create or write its own managed table —
confirmed via a real pipeline run failure (`PERMISSION_DENIED: User does not
have CREATE TABLE and USE SCHEMA on Schema 'mdp_dev.bronze_neon'`).

#### Scenario: Pipeline creates its managed table successfully
- **WHEN** a Lakeflow Declarative Pipeline run as the CI/CD service principal,
  targeting one of the bronze-family schemas above, is triggered
- **THEN** the run does not fail with `PERMISSION_DENIED: User does not have
  CREATE TABLE and USE SCHEMA on Schema '<catalog>.<schema>'`, and the
  pipeline's managed table is created in that schema
