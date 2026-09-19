## Why

Phase 3b's Auto Loader ingestion pattern (built in `demo-databricks-mdp`) needs a
Unity Catalog-governed landing path for the synthetic clickstream files it reads —
a `bronze_clickstream` schema (mirroring the existing per-source-system pattern:
`bronze_neon`, `bronze_atlas`) plus a dedicated Volume Auto Loader can point at.
Volumes are UC governance objects, same family as the catalogs/schemas and the
`neon_dev` UC Connection this repo already provisions — Terraform's job, not
something created ad hoc from the mdp side.

## What Changes

- Add `bronze_clickstream` to the existing schema map in
  `modules/databricks-unity-catalog` — mirrors the `bronze_neon`/`bronze_atlas`
  pattern exactly, created in all three environment catalogs via the module's
  existing `for_each`, no special-casing
- New module `modules/databricks-uc-volume/`: one MANAGED `databricks_volume` per
  call — generic, not clickstream-specific, reusable for a future file-drop source
- Root composes one instance per environment, `s3_clickstream_raw`, inside each
  environment's `bronze_clickstream` schema — one volume per source system, not
  shared, so UC volume-level grants stay scoped to this source alone
- No new bucket, storage credential, or external location — volume storage reuses
  each environment's existing per-env bucket (the same one already backing that
  catalog's `storage_root`)

## Capabilities

### New Capabilities
- `uc-volumes`: UC Volume objects providing a governed landing path for file-drop
  ingestion sources (Auto Loader) — distinct from `uc-connections` (pull-based
  DB/SaaS credentials) and from `unity-catalog`'s catalog/schema structure

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement gains
  `bronze_clickstream` alongside the existing bronze/gold schema list

## Cross-repo dependencies

Provides for `phase3b-clickstream-autoloader` in `demo-databricks-mdp` — that
change's Auto Loader pipeline reads from the `s3_clickstream_raw` volume this
change creates. That change should not be deployed until this one has landed.

## Impact

- Adds `databricks_volume.this` (inside the new module, `for_each` across
  environments) to Terraform state
- Modifies `local.schemas` in `modules/databricks-unity-catalog` — one additional
  schema created per environment catalog
- No impact on existing `bronze_neon`/`bronze_atlas` schemas, tables, or grants
