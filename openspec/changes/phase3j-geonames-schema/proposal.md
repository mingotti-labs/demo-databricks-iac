## Why

Phase 3j onboards the second new reference-data source system decided in
`demo-databricks-planning`'s brainstorm
(`poc/reference-data-authoritative-sources-notes.md`): **GeoNames**, the
city/locality gazetteer sitting under ISO 3166's country/state backbone
(`phase3i-iso-schema`). Like every other source system, its landing
schemas are Terraform's job.

## What Changes

- Add `bronze_geonames` and `bronze_geonames_publish` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf`.
- No new bucket, storage credential, UC Connection, or volume — GeoNames'
  dump files are public, unauthenticated static downloads over plain HTTPS
  (confirmed via real fetches against `download.geonames.org`: `200` on
  every file, no WAF block), same "no extra infra" shape as ISO's.
- Add `bronze_geonames`/`bronze_geonames_publish` to
  `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`,
  including `CREATE_MATERIALIZED_VIEW` from the start.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `bronze_geonames` and `bronze_geonames_publish`

## Cross-repo dependencies

Provides for an upcoming `demo-databricks-mdp` change
(`phase3j-geonames-reference-ingestion`) that writes into
`bronze_geonames`/`bronze_geonames_publish`. That change should not deploy
until this one has landed.

## Sequencing note (intra-repo)

This change's spec delta is authored against the baseline
`phase3i-iso-schema` produces (25 schemas), not the schema count currently
live in `openspec/specs/unity-catalog/spec.md` (23). **Do not archive this
change before `phase3i-iso-schema` has been archived** — the resulting
schema list would otherwise silently drop `bronze_iso`/`bronze_iso_publish`
from the spec.

## Impact

- Adds 6 schema resources (`bronze_geonames` + `bronze_geonames_publish` ×
  3 environments)
- Adds 6 more `cicd_schema_use` grant resources
- No impact on any existing schema, table, or grant
