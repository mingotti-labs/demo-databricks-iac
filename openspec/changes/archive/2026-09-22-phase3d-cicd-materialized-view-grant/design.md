## Context

See proposal.md - Why. Third real grant gap discovered against the CI/CD
SP's pipeline execution (after `BROWSE` and `USE_SCHEMA`/`CREATE_TABLE` in
`phase3b-cicd-pipeline-grants`), same discovery pattern: a real pipeline
run failure, not anticipated upfront.

## Goals / Non-Goals

**Goals:**
- Let the CI/CD SP create Materialized Views on its target bronze schemas,
  the same way it can already create (Streaming) Tables

**Non-Goals:**
- Auditing every other UC privilege the SP might eventually need for a
  dataset type not yet used in this project (e.g. views, functions) —
  fixed reactively as each is actually hit, per this project's established
  pattern, not preemptively enumerated here

## Decisions

**`CREATE_MATERIALIZED_VIEW` added to the existing schema grant, not a
separate grant resource.**
Same `databricks_grants.cicd_schema_use` resource already carries
`USE_SCHEMA`/`CREATE_TABLE` per bronze schema; adding the privilege to the
same `grant` block is an in-place update, not a new resource — simpler
than a parallel grant resource for one more privilege string.

**Applied to every bronze schema, not just `bronze_acnc`.**
Same reasoning `phase3b-cicd-pipeline-grants` used for `CREATE_TABLE`:
UNGM's `unspsc_public_raw` is also a Materialized View, confirmed never
actually run under the SP yet, so it would hit the identical gap on its
first real SP-owned run. Fixing proactively across all bronze schemas
avoids a second near-identical change once that happens.

## Risks / Trade-offs

None — additive privilege grant, no destructive Terraform action.

## Migration Plan

Apply, then re-run the CI/CD SP's ACNC ingestion pipeline (the update that
originally surfaced this) to confirm the fix. Rollback: remove the
privilege from the grant block; no data depends on the grant itself.
