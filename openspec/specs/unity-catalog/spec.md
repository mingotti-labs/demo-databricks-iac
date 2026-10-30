# unity-catalog Specification

## Purpose

Establishes the Unity Catalog structure — storage credential, external location, and catalogs/schemas — that all downstream ingestion and modeling write into.

## Requirements

### Requirement: Storage credential
A storage credential SHALL exist per environment catalog, each using the IAM role ARN from that environment's own cloud-storage bucket. Each credential SHALL be the only credential used for S3 access for its catalog, and SHALL NOT be shared with another catalog.

#### Scenario: Storage credential created
- **WHEN** the databricks-unity-catalog module is applied once per environment
- **THEN** three storage credentials exist, each referencing its own environment's IAM role ARN, and `terraform validate` passes

### Requirement: External location
An external location SHALL exist per environment catalog, pointing to that catalog's own S3 bucket via its own storage credential.

#### Scenario: External location visible and usable
- **WHEN** `databricks external-locations list` is run after apply
- **THEN** three external locations are listed — one pointing at `hoe-mdp-dev`, one at `hoe-mdp-tst`, one at `hoe-mdp-prd` — each via its own storage credential, and Databricks can read/write Delta tables at each

### Requirement: Environment catalogs
Three catalogs SHALL exist: `mdp_dev`, `mdp_tst`, `mdp_prd`, each with `storage_root` at the root of its own environment's S3 bucket rather than a prefix inside a bucket shared with the other catalogs.

#### Scenario: Catalogs present
- **WHEN** `databricks catalogs list` is run after apply
- **THEN** `mdp_dev`, `mdp_tst`, and `mdp_prd` are all listed

#### Scenario: Catalog storage roots are isolated per bucket
- **WHEN** each catalog's `storage_root` is inspected
- **THEN** `mdp_dev` points at `s3://hoe-mdp-dev/`, `mdp_tst` at `s3://hoe-mdp-tst/`, and `mdp_prd` at `s3://hoe-mdp-prd/` — no catalog shares a bucket with another

### Requirement: Bronze and gold schemas per catalog
Each catalog SHALL contain the schemas `bronze_neon`, `bronze_neon_publish`,
`bronze_atlas`, `bronze_atlas_publish`, `bronze_clickstream`,
`bronze_clickstream_publish`, `bronze_ungm`, `bronze_ungm_publish`,
`bronze_acnc`, `bronze_acnc_publish`, `bronze_nsw_spatial`,
`bronze_nsw_spatial_publish`, `bronze_airroi`, `bronze_airroi_publish`,
`bronze_iso`, `bronze_iso_publish`, `bronze_geonames`,
`bronze_geonames_publish`, `silver_landing_neon`,
`silver_landing_clickstream`, `silver_landing_ungm`, `silver_landing_acnc`,
`silver_landing_nsw_spatial`, `silver_landing_airroi`, `silver_landing_iso`,
`silver_landing_geonames`, `silver_normalised_airroi`,
`silver_normalised_acnc`, `gold_analytics_gateway`,
`gold_integration_gateway`, and `gold_ai_gateway`; and, for the dividend
portfolio story, `bronze_<s>`, `bronze_<s>_publish` and `silver_landing_<s>`
for each `<s>` of `wikipedia`, `sec`, `yahoo`, `rba`, `fred` and `portfolio`,
plus the Silver Domain schema `silver_investments`. No `fmp` or `reference`
schema SHALL exist (FMP was dropped after its probe; reference data lives in
`portfolio`). A Silver Domain schema SHALL exist only once a story defines its
domain; `silver_investments` is the first. No `bronze_<source>_history` schema
SHALL exist — full change history/CDC replay, where needed, is modeled as
`<table>_scd2` inside the source's `_publish` schema instead.

The `free_workspace` deployment differs, to stay under Free Edition's
50-schemas-per-catalog quota: its catalogs SHALL NOT contain `bronze_atlas`,
`bronze_atlas_publish`, `silver_landing_rba` or `silver_landing_fred`, and
SHALL contain one `silver_landing` schema for every source's Silver Landing
tables, each named `<source>__<entity>`. The other `silver_landing_<source>`
schemas remain in `free_workspace` until `demo-databricks-mdp` has moved their
tables into `silver_landing`. `single_workspace` keeps the list above.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each environment
  catalog of `single_workspace`
- **THEN** all fifty schemas listed above are present in each catalog, no
  `fmp` or `reference` schema is present, no Silver Domain schema other than
  `silver_investments` is present, and no `bronze_<source>_history` schema is
  present

#### Scenario: Free workspace has one Silver Landing schema for new sources
- **WHEN** `databricks schemas list mdp_dev` and `databricks schemas list
  mdp_prd` are run after apply
- **THEN** `silver_landing` is listed, and `bronze_atlas`,
  `bronze_atlas_publish`, `silver_landing_rba` and `silver_landing_fred` are
  not

#### Scenario: Free workspace catalogs are under the schema quota
- **WHEN** `databricks resource-quotas get-quota catalog <catalog>
  schema-quota` is run for `mdp_dev` and `mdp_prd`
- **THEN** `quota_count` is below `quota_limit` (50) for both

#### Scenario: CI/CD principal can build tables in the story's schemas
- **WHEN** `databricks grants get schema <catalog>.silver_investments` (or any
  of the story's new schemas, or `silver_landing`) is run
- **THEN** the CI/CD service principal holds `USE_SCHEMA`, `CREATE_TABLE` and
  `CREATE_MATERIALIZED_VIEW`, and the human account holds `SELECT`

### Requirement: Workspace-level resources only
All resources SHALL be workspace-level; no account-level Terraform resources are used, consistent with the Free Edition constraint.

#### Scenario: No account-level resources
- **WHEN** the Terraform configuration is reviewed
- **THEN** it contains no account-level Databricks resources, only workspace-level ones
