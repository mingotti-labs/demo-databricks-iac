## Why

Phase 3i onboards a new source system in `demo-databricks-mdp`: ISO 3166-1/
3166-2 country and subdivision reference data — the country/state backbone
decided in `demo-databricks-planning`'s brainstorm
(`poc/reference-data-authoritative-sources-notes.md`). Like every other
source system, its landing schemas are Terraform's job, not something
created ad hoc from the mdp side.

## What Changes

- Add `bronze_iso` and `bronze_iso_publish` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf` — mirrors the
  `bronze_ungm`/`bronze_ungm_publish` pattern exactly, created in all three
  environment catalogs via the module's existing `for_each`.
- No new bucket, storage credential, UC Connection, or volume — the ISO
  3166 data is pulled over plain HTTPS from a public, unauthenticated
  GitHub-hosted CSV mirror (confirmed via a real fetch: `200`, no WAF
  block, unlike UNGM/ACNC/NSW Spatial's APIs), the same "no extra infra"
  shape UNGM's onboarding established.
- Add `bronze_iso`/`bronze_iso_publish` to `local.cicd_writable_schemas` in
  `deployment/free_workspace/main.tf`, including `CREATE_MATERIALIZED_VIEW`
  from the start — that gap was discovered reactively for ACNC and is now
  applied proactively by default, same as NSW Spatial's and AirROI's onboarding.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `bronze_iso` and `bronze_iso_publish`

## Cross-repo dependencies

Provides for an upcoming `demo-databricks-mdp` change
(`phase3i-iso-country-reference-ingestion`) that writes into
`bronze_iso`/`bronze_iso_publish`. That change should not deploy until this
one has landed.

## Sequencing note (intra-repo)

A sibling change, `phase3j-geonames-schema`, also modifies the "Bronze and
gold schemas per catalog" requirement. This change (`phase3i-iso-schema`)
is written and intended to land **first** — `phase3j-geonames-schema`'s
spec delta is authored assuming this one's schema list is already the
current baseline. Archive this one before archiving `phase3j-geonames-schema`.

## Impact

- Adds 6 schema resources (`bronze_iso` + `bronze_iso_publish` × 3
  environments)
- Adds 6 more `cicd_schema_use` grant resources (same 2 schemas × 3
  environments)
- No impact on any existing schema, table, or grant
