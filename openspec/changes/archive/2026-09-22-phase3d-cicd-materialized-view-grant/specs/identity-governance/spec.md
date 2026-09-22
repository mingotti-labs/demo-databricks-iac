## MODIFIED Requirements

### Requirement: CI/CD service principal schema access
The CI/CD service principal SHALL have `USE_SCHEMA`, `CREATE_TABLE`, and
`CREATE_MATERIALIZED_VIEW` on every bronze-family schema (`bronze_neon`,
`bronze_neon_publish`, `bronze_atlas`, `bronze_atlas_publish`,
`bronze_clickstream`, `bronze_clickstream_publish`, `bronze_ungm`,
`bronze_ungm_publish`, `bronze_acnc`, `bronze_acnc_publish`) in each of the
three environment catalogs, granted via Terraform. `CREATE_MATERIALIZED_VIEW`
is a privilege genuinely separate from `CREATE_TABLE` in Unity Catalog —
confirmed via a real pipeline run failure (`PERMISSION_DENIED: User does
not have CREATE MATERIALIZED VIEW on Schema 'mdp_dev.bronze_acnc'`); there
is no equivalent separate privilege for Streaming Tables, which fall under
`CREATE_TABLE`.

#### Scenario: Pipeline creates its managed table successfully
- **WHEN** a Lakeflow Declarative Pipeline run as the CI/CD service
  principal, targeting one of the bronze-family schemas above, is triggered
- **THEN** the run does not fail with `PERMISSION_DENIED: User does not have
  CREATE TABLE and USE SCHEMA on Schema '<catalog>.<schema>'` or
  `PERMISSION_DENIED: User does not have CREATE MATERIALIZED VIEW on
  Schema '<catalog>.<schema>'`, and the pipeline's managed table or
  materialized view is created in that schema
