## Context

See proposal.md. Each story source has its schema entries in
`local.schemas` and `local.cicd_writable_schemas`
(`deployment/free_workspace/main.tf`), in the module default map
(`modules/databricks-unity-catalog/variables.tf`, used by `single_workspace`)
and in `single_workspace`'s `cicd_writable_schemas`. Its volume is a
`modules/databricks-uc-volume` call plus a `databricks_grants` resource.

## Goals / Non-Goals

**Goals:**
- `bronze_abs`, `bronze_abs_publish` and `bronze_abs.s3_raw` with the same
  grants as FRED's.

**Non-Goals:**
- A secret scope (no key); any change to other sources.

## Decisions

**Copy FRED's entries** next to FRED's in each list, and its volume block as
`module "abs_volume"` and `databricks_grants.abs_volume_use`. The volume
depends on the new schema existing; the module's `depends_on =
[module.unity_catalog]` already covers that, as it did for the other volumes.

## Risks / Trade-offs

- Schema quota lags after drops (minutes); no drops here, and both catalogs
  have room (38 and 36 of 50).

## Migration Plan

1. `terraform plan` on `free_workspace`: 12 to add, nothing else.
2. Apply with the user's go-ahead.
3. Check: `databricks schemas list mdp_dev` (and `mdp_prd`) shows `bronze_abs`
   and `bronze_abs_publish`; `databricks volumes list mdp_dev bronze_abs` shows
   `s3_raw`; `databricks grants get schema mdp_dev.bronze_abs` and
   `databricks grants get volume mdp_dev.bronze_abs.s3_raw` show both
   principals; a fresh plan shows no changes.

Rollback: remove the entries and blocks and apply (drops the volume with its
files and the schemas, which must be empty first).
