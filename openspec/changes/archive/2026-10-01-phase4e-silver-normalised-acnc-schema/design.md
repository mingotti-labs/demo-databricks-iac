## Context

Same shape as `phase4d-silver-normalised-airroi-schema`: one entry in the
schema map, one in the CI/CD writable list. Naming per
`demo-databricks-mdp`'s NAMING.md: `silver_normalised_<source>`.

## Goals / Non-Goals

**Goals:** create `silver_normalised_acnc` in `mdp_dev`, `mdp_tst` and
`mdp_prd` with the grants its pipeline needs.

**Non-Goals:** Silver Normalised schemas for any other source; Silver
Domain/Marts schemas; governed tags or tag policies.

## Decisions

- **Same grants as `silver_normalised_airroi`**, including
  `CREATE_MATERIALIZED_VIEW` from the start.
- **No `APPLY TAG` grant.** Already confirmed unnecessary for airroi's tag
  step (table ownership is enough); the mechanism (post-refresh
  `ALTER MATERIALIZED VIEW … SET TAGS` as the pipeline's run-as identity)
  is identical for acnc, so this is not re-verified as an open question.

## Risks / Trade-offs

None beyond `phase4d-silver-normalised-airroi-schema`'s, already resolved.

## Migration Plan

`terraform plan` (expect 6 to add, 0 to change, 0 to destroy), apply after
explicit go-ahead, confirm with `databricks schemas list mdp_<env>`.
Rollback: remove the entries and apply (the schema must be empty, or the
mdp pipeline deleted first).
