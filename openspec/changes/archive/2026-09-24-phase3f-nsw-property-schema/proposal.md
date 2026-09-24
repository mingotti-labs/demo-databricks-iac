## Why

Phase 3f adds a fifth source system in `demo-databricks-mdp`: a reusable Esri
ArcGIS REST FeatureServer connector, first consumer NSW's "Land Parcel and
Property Theme" (`portal.spatial.nsw.gov.au`) — ~4.2 million properties,
confirmed live via a real query before this schema change was drafted. Like
every other source system in this project, its landing schemas are
Terraform's job, not something created ad hoc from the mdp side.

## What Changes

- Add `bronze_nsw_spatial` and `bronze_nsw_spatial_publish` to
  `local.schemas` in `modules/databricks-unity-catalog/main.tf` — mirrors the
  `bronze_acnc`/`bronze_acnc_publish` pattern exactly, created in all three
  environment catalogs via the module's existing `for_each`
- No new bucket, storage credential, UC Connection, or volume — the NSW
  ArcGIS FeatureServer is public (no auth for the layer being built now),
  and its ingestion pipeline is a Python custom data source reading over
  HTTPS, not a Lakeflow Connect connector or a file-drop source
- Add `bronze_nsw_spatial` and `bronze_nsw_spatial_publish` to
  `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf` —
  applying the `USE_SCHEMA`/`CREATE_TABLE`/`CREATE_MATERIALIZED_VIEW` grant
  established in `phase3b-cicd-pipeline-grants`/`phase3d-cicd-materialized-view-grant`
  proactively, same as every source system since UNGM

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `bronze_nsw_spatial` and `bronze_nsw_spatial_publish`

## Cross-repo dependencies

Provides for an upcoming `demo-databricks-mdp` change (NSW property
ingestion via a reusable ArcGIS FeatureServer connector, plus SCD1/SCD2
modeling) that writes into `bronze_nsw_spatial`/`bronze_nsw_spatial_publish`.
That change should not deploy until this one has landed.

## Impact

- Adds 6 schema resources (`bronze_nsw_spatial` + `bronze_nsw_spatial_publish`
  × 3 environments)
- Adds 6 more `cicd_schema_use` grant resources (same 2 schemas × 3
  environments)
- No impact on any existing schema, table, or grant
