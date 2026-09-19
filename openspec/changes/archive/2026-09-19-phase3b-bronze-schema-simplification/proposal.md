## Why

Phase 1's `bronze_<source>_history` schemas (`bronze_neon_history`,
`bronze_atlas_history`) were provisioned as a reserved placeholder for full
change-history/CDC replay, but sit empty across all three environments —
nothing writes to them, and nothing consumes them. Rather than extend that
unused pattern to a third source (clickstream), simplify: each source keeps
only `bronze_<source>` (raw) and `bronze_<source>_publish` (governed, modeled
— SCD1/SCD2 tables, and future row/column security), and the `_history`
schemas are removed. Confirmed empty via `databricks tables list` against all
six (2 schemas × 3 environments) before proposing their removal.

## What Changes

- **BREAKING**: remove `bronze_neon_history` and `bronze_atlas_history` from
  `local.schemas` in `modules/databricks-unity-catalog/main.tf` — destroys
  these six schema resources (empty, confirmed) against real `dev`/`tst`/`prd`
  infra
- Add `bronze_clickstream_publish` to the same map — completes the
  raw+publish pair for clickstream, matching the simplified pattern
- End state per catalog: `bronze_neon`/`bronze_neon_publish`,
  `bronze_atlas`/`bronze_atlas_publish`,
  `bronze_clickstream`/`bronze_clickstream_publish`, plus the three
  `gold_*` schemas — nine schemas total, down from ten, restructured

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list drops `bronze_neon_history`/`bronze_atlas_history` and gains
  `bronze_clickstream_publish`

## Cross-repo dependencies

Provides for upcoming `demo-databricks-mdp` changes (Neon SCD1/SCD2 modeling,
clickstream SCD1) that write into `bronze_neon_publish` (already existed) and
`bronze_clickstream_publish` (created here). Those changes should not deploy
until this one has landed and `bronze_clickstream_publish` is confirmed
present.

## Impact

- Destroys 6 schema resources (`bronze_neon_history` + `bronze_atlas_history`
  × 3 environments) — confirmed empty first, no data loss
- Adds 3 schema resources (`bronze_clickstream_publish` × 3 environments)
- No impact on `bronze_neon`, `bronze_neon_publish`, `bronze_atlas`,
  `bronze_atlas_publish`, `bronze_clickstream`, or any `gold_*` schema
