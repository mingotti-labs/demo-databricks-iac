## Why

`demo-databricks-mdp`'s `phase4a-silver-landing` change gave every source
onboarded up to that point a source-aligned Silver Landing schema. ISO 3166
(`phase3i-iso-country-reference-ingestion`) and GeoNames
(`phase3j-geonames-reference-ingestion`) were onboarded afterward and have
no Silver Landing schema yet. This change closes that gap so their Bronze
Publish SCD2 objects can land in Silver the same way the original six
sources' did.

## What Changes

- Add `silver_landing_iso` and `silver_landing_geonames` to `local.schemas`
  in `modules/databricks-unity-catalog/main.tf` — same shape as
  `phase4a-silver-landing-schemas`'s six schemas, one per source.
- Add the same two schemas to `local.cicd_writable_schemas` in
  `deployment/free_workspace/main.tf`, including `CREATE_MATERIALIZED_VIEW`
  from the start — every Silver Landing table is a Materialized View.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `silver_landing_iso` and `silver_landing_geonames`

## Cross-repo dependencies

Required by an upcoming `demo-databricks-mdp` change extending
`silver-landing` to the ISO and GeoNames sources — its pipelines write into
these two schemas. That change should not deploy until this one has
landed.

## Impact

- Adds 6 schema resources (2 schemas × 3 environments)
- Adds 6 more `cicd_schema_use` grant resources
- No impact on any existing schema, table, or grant

## Model

Sonnet — repeats the established Silver Landing schema-pair + CI/CD grant pattern from `phase4a-silver-landing-schemas`.
