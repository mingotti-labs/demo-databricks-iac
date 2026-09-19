## Why

The CI/CD service principal's dev-scoped `neon_ecommerce_ingestion` pipeline
had never successfully run since it was created — its only two grants were
`USE_CATALOG` (Phase 1) and, as of `phase3a-neon-uc-connection`,
`USE_CONNECTION` on `neon_dev`. Triggering it directly surfaced two further
gaps, one at a time, each confirmed via a real pipeline run failure rather
than guessed upfront: catalog-level `BROWSE` (needed for a pipeline cluster to
initialize against Unity Catalog at all) and schema-level `USE_SCHEMA` +
`CREATE_TABLE` (needed to actually create/write its managed table). This
surfaced during recovery from an unrelated incident: the *human*-identity dev
copy of the same pipeline had been deleted during an earlier cleanup, which
(confirmed via Databricks' own docs) drops a pipeline's managed tables by
default — emptying `bronze_neon` entirely. Running the CI/CD SP's copy instead
(same execution identity regardless of which human triggers it — confirmed
empirically) both fixed the immediate data loss and exposed these grant gaps.

## What Changes

- Add `BROWSE` to the CI/CD SP's existing catalog-level grant (alongside
  `USE_CATALOG`)
- Add a new schema-level grant (`USE_SCHEMA`, `CREATE_TABLE`) for the CI/CD SP
  across every bronze-family schema (`bronze_neon`, `bronze_neon_publish`,
  `bronze_atlas`, `bronze_atlas_publish`, `bronze_clickstream`,
  `bronze_clickstream_publish`) — granted up front across all of them, not
  discovered once per schema, since every ingestion/SCD pipeline in this
  project needs the same access on its own target schema

## Capabilities

### Modified Capabilities
- `identity-governance`: the "CI/CD service principal catalog access"
  requirement gains `BROWSE`, and a new "CI/CD service principal schema
  access" requirement is added

## Impact

- Adds `BROWSE` to `databricks_grants.cicd_catalog_use` (3 environments,
  in-place update)
- Adds new `databricks_grants.cicd_schema_use` (18 resources: 6 bronze
  schemas × 3 environments)
- No impact on any other principal's access
