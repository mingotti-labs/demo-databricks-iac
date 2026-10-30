## Context

See proposal.md. On 2026-10-31, after mdp's prd run and the user's drop of the
old tables, `system.information_schema` showed no tables, volumes or functions
in any `silver_landing_<source>` schema of `mdp_dev` or `mdp_prd`. The human
dev pipelines that still defaulted to those schemas were deleted by the user,
and each mdp pipeline's event log moved with its default schema into
`silver_landing`.

## Goals / Non-Goals

**Goals:**
- The free workspace's schema list matches what mdp uses: one
  `silver_landing`.

**Non-Goals:**
- `single_workspace` (unchanged, user's decision).
- Folding other per-source schemas (`bronze_<s>_publish`,
  `silver_normalised_<s>`).

## Decisions

**Remove the twelve entries from both lists in `deployment/free_workspace/main.tf`.**
`local.schemas` drives the schemas and `local.cicd_writable_schemas` their
grants; both lose the same twelve names. Resource addresses of every other
schema stay the same, so the plan only destroys.

**No force destroy.** `databricks_schema` does not force-destroy, so a schema
that gained a table before apply fails the apply instead of losing data.

## Risks / Trade-offs

- [A pipeline recreates a table in an old schema] -> Nothing in mdp's free
  edition targets them any more (checked with grep at archive time); re-check
  the schemas are empty just before apply.

## Migration Plan

1. Re-check the twelve schemas hold no tables, volumes or functions in
   `mdp_dev` and `mdp_prd`.
2. `terraform plan` on `free_workspace`: 0 to add, 0 to change, 48 to destroy,
   nothing else.
3. Apply with the user's go-ahead.
4. Check: `databricks schemas list mdp_dev|mdp_prd` shows `silver_landing` and
   no `silver_landing_<source>`; schema quota reads 37 (dev) and 35 (prd)
   once the count catches up (it lags minutes); a final plan shows no changes.

Rollback: put the entries back and apply; the schemas come back empty.
