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
`gold_analytics_gateway`, `gold_integration_gateway`, and `gold_ai_gateway`.
Silver schemas SHALL NOT be created in Phase 1, since domains are not yet
defined. No `bronze_<source>_history` schema SHALL exist — full change
history/CDC replay, where needed, is modeled as `<table>_scd2` inside the
source's `_publish` schema instead.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each of `mdp_dev`,
  `mdp_tst`, `mdp_prd`
- **THEN** all eleven schemas listed above are present in each catalog, no
  silver schema is present, and no `bronze_<source>_history` schema is present

### Requirement: Workspace-level resources only
All resources SHALL be workspace-level; no account-level Terraform resources are used, consistent with the Free Edition constraint.

#### Scenario: No account-level resources
- **WHEN** the Terraform configuration is reviewed
- **THEN** it contains no account-level Databricks resources, only workspace-level ones
