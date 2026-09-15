## Purpose

Establishes the Unity Catalog structure — storage credential, external location, and catalogs/schemas — that all downstream ingestion and modeling write into.

## ADDED Requirements

### Requirement: Storage credential
A storage credential SHALL exist in Unity Catalog using the IAM role ARN from the cloud-storage module. It SHALL be the only credential used for S3 access.

#### Scenario: Storage credential created
- **WHEN** the databricks-unity-catalog module is applied
- **THEN** a storage credential exists referencing the cloud-storage module's IAM role ARN, and `terraform validate` passes

### Requirement: External location
An external location SHALL exist pointing to the S3 bucket via the storage credential, allowing Databricks to read and write Delta tables at that location.

#### Scenario: External location visible and usable
- **WHEN** `databricks external-locations list` is run after apply
- **THEN** the external location is listed, pointing at the `hoe-mdp-dev` bucket via the storage credential, and Databricks can read/write Delta tables there

### Requirement: Environment catalogs
Three catalogs SHALL exist: `mdp_dev`, `mdp_tst`, `mdp_prd`.

#### Scenario: Catalogs present
- **WHEN** `databricks catalogs list` is run after apply
- **THEN** `mdp_dev`, `mdp_tst`, and `mdp_prd` are all listed

### Requirement: Bronze and gold schemas per catalog
Each catalog SHALL contain the schemas `bronze_neon`, `bronze_neon_history`, `bronze_neon_publish`, `bronze_atlas`, `bronze_atlas_history`, `bronze_atlas_publish`, `gold_analytics_gateway`, `gold_integration_gateway`, and `gold_ai_gateway`. Silver schemas SHALL NOT be created in Phase 1, since domains are not yet defined.

#### Scenario: All nine schemas present per catalog
- **WHEN** `databricks schemas list <catalog>` is run for each of `mdp_dev`, `mdp_tst`, `mdp_prd`
- **THEN** all nine schemas listed above are present in each catalog, and no silver schema is present

### Requirement: Workspace-level resources only
All resources SHALL be workspace-level; no account-level Terraform resources are used, consistent with the Free Edition constraint.

#### Scenario: No account-level resources
- **WHEN** the Terraform configuration is reviewed
- **THEN** it contains no account-level Databricks resources, only workspace-level ones
