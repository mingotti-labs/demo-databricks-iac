## 1. Verify emptiness (before any config change)

- [x] 1.1 `databricks tables list mdp_<env> bronze_neon_history` and
      `bronze_atlas_history` for `dev`/`tst`/`prd` (6 checks) — all six
      confirmed empty
- [x] 1.2 Grep `demo-databricks-mdp` for any reference to
      `bronze_neon_history`/`bronze_atlas_history` — none found

## 2. Schema map

- [x] 2.1 Removed `bronze_neon_history` and `bronze_atlas_history` from
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`
- [x] 2.2 Added `bronze_clickstream_publish` to the same map; also updated
      `bronze_neon_publish`'s comment to mention it now holds SCD1/SCD2 tables
- [x] 2.3 `terraform plan` (with `-var="environment=dev"` and the current
      `uc_external_ids`) showed exactly 3 to add
      (`bronze_clickstream_publish` × 3 envs), 6 to destroy
      (`bronze_neon_history` + `bronze_atlas_history` × 3 envs), 3 to change
      (comment-only update on `bronze_neon_publish` × 3 envs) — matched
      expectations exactly

## 3. Apply and verify

- [x] 3.1 Applied — 3 added, 3 changed, 6 destroyed, confirmed in `terraform
      apply` output
- [x] 3.2 `databricks schemas list mdp_<env>` for `dev`/`tst`/`prd` — confirmed
      exactly the nine schemas in the updated spec (plus the built-in
      `information_schema`), no `_history` schema present,
      `bronze_clickstream_publish` present in all three

## 4. Documentation

- [x] 4.1 Added a "Bronze schema shape" section to this repo's CLAUDE.md
      explaining the raw+publish-only pattern and why `_history` was removed,
      cross-referencing this change's design.md
- [x] 4.2 Updated `demo-databricks-mdp`'s NAMING.md: removed the stale
      `bronze_<source>_history` row from its catalog/schema table, added a
      `<table>_scd1`/`<table>_scd2` table-naming entry referencing this
      change's design.md
