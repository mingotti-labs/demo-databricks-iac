## Why

Both Free Edition catalogs have hit the 50-schemas-per-catalog quota
(2026-10-30: `mdp_dev` 52/50, `mdp_prd` 50/50), so no new schema can be
created and every new source adds three. The user decided to fold the
fourteen `silver_landing_<source>` schemas into one `silver_landing` schema,
with tables named `<source>__<entity>` (entity = today's table name). This
change is the first of three steps: it frees schemas and creates
`silver_landing`. mdp then moves its Landing tables; a later iac change drops
the old Landing schemas once they are empty.

Only the free deployment changes (decided by the user): `single_workspace`
keeps one `silver_landing_<source>` schema per source.

## What Changes

- **Schema list per deployment**: `modules/databricks-unity-catalog` takes the
  schema map as a variable `schemas`, whose default is today's map, so
  `single_workspace` (which passes nothing) is unchanged. `free_workspace`
  passes its own map, kept next to `local.cicd_writable_schemas`.
- **Drop four empty schemas** in both free catalogs (`mdp_dev`, `mdp_prd`),
  checked empty 2026-10-30:
  - `silver_landing_rba`, `silver_landing_fred`: RBA and FRED are not built
    yet; their Landing tables will go straight into `silver_landing`.
  - `bronze_atlas`, `bronze_atlas_publish`: no mdp code uses them. The MongoDB
    Atlas database, its module and secret scope stay.
- **Create `silver_landing`** in both free catalogs, with the usual CI/CD
  grants (`USE_SCHEMA`, `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW`) and
  `SELECT` for the human account, via `local.cicd_writable_schemas`.
- Not included: dropping the other twelve `silver_landing_<source>` schemas
  (they hold tables until mdp moves them; a later iac change), any change to
  `single_workspace` or `multiple_workspaces`.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the free deployment has one `silver_landing` schema and no
  Atlas schemas; the single-workspace list is unchanged.

## Cross-repo dependencies

Provides for the next `demo-databricks-mdp` change (moving every Landing table
to `silver_landing.<source>__<entity>`); that change cannot deploy until this
one is applied. A later iac change, after the mdp change, drops the twelve
remaining `silver_landing_<source>` schemas in `free_workspace`.

## Model

Sonnet to implement: a schema-list edit and a module variable, no new pattern.

## Impact

- `terraform plan` on `free_workspace` should show **4 to add, 0 to change,
  16 to destroy**: add `silver_landing` and its grant per catalog (2 + 2);
  destroy the four schemas and their four grants per catalog (8 + 8). Moving
  the map into a variable keeps every resource address, so nothing else moves.
- Schema count afterwards: `mdp_dev` 49 (52 - 4 + 1), `mdp_prd` 47
  (50 - 4 + 1). No tables, so the 500-table quota is untouched.
- Apply needs the user's explicit go-ahead.
