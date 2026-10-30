## Context

See proposal.md. `bronze_rba` exists in both catalogs (from
`dividend-portfolio-schemas`), empty. The SEC, Yahoo and Wikipedia volumes are
each a `modules/databricks-uc-volume` call plus a `databricks_grants` resource
in `deployment/<deployment>/main.tf`.

## Goals / Non-Goals

**Goals:**
- `bronze_rba.s3_raw` with the same grants as the other source volumes.

**Non-Goals:**
- A FRED volume; any schema change.

## Decisions

**Copy the Wikipedia block** as `module "rba_volume"` and
`databricks_grants.rba_volume_use` in both deployments. Rejected: folding the
source volumes into one `for_each` over source names. It would move every
existing volume's address (a destroy and recreate of volumes holding raw
files) for a small saving in lines.

## Risks / Trade-offs

- None beyond the usual apply: the plan only adds.

## Migration Plan

1. `terraform plan` on `free_workspace`: 4 to add, nothing else.
2. Apply with the user's go-ahead.
3. Check: `databricks volumes list mdp_dev bronze_rba` (and `mdp_prd`) shows
   `s3_raw`; `databricks grants get volume mdp_dev.bronze_rba.s3_raw` shows
   both principals; a fresh plan shows no changes.

Rollback: remove the blocks and apply (the volume is dropped with its files).
