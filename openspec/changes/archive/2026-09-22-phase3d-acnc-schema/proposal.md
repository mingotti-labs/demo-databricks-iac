## Why

Phase 3d adds a new ingestion pattern in `demo-databricks-mdp`: a reusable
custom PySpark Data Source connector (`spark.dataSource.register()`, built
on the Python Data Source API — not Lakeflow Connect's managed catalog)
pulling the ACNC (Australian Charities and Not-for-profits Commission)
Charity Register from data.gov.au's public CKAN Data API. Like every other
source system in this project, its landing schemas are Terraform's job, not
something created ad hoc from the mdp side.

## What Changes

- Add `bronze_acnc` and `bronze_acnc_publish` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf` — mirrors the
  `bronze_ungm`/`bronze_ungm_publish` pattern exactly, created in all three
  environment catalogs via the module's existing `for_each`
- No new bucket, storage credential, UC Connection, or volume — the ACNC
  Charity Register is published on data.gov.au's public CKAN Data API (no
  auth), and its ingestion pipeline is a Python custom data source reading
  over HTTPS, not a Lakeflow Connect connector or a file-drop source, so
  none of the credential/volume infrastructure the other source systems
  needed applies here
- Add `bronze_acnc` and `bronze_acnc_publish` to `local.cicd_writable_schemas`
  in `deployment/free_workspace/main.tf` — applying the `USE_SCHEMA`/
  `CREATE_TABLE` grant established in `phase3b-cicd-pipeline-grants`
  proactively, same as `phase3c-ungm-schema` did

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `bronze_acnc` and `bronze_acnc_publish`

## Cross-repo dependencies

Provides for an upcoming `demo-databricks-mdp` change (ACNC Charity
Register ingestion via a reusable CKAN custom data source connector, plus
SCD1/SCD2 modeling) that writes into `bronze_acnc`/`bronze_acnc_publish`.
That change should not deploy until this one has landed.

## Impact

- Adds 6 schema resources (`bronze_acnc` + `bronze_acnc_publish` × 3
  environments)
- Adds 6 more `cicd_schema_use` grant resources (same 2 schemas × 3
  environments)
- No impact on any existing schema, table, or grant
