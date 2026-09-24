## Context

See proposal.md - Why. Discovered via a real `prd` pipeline run triggered
right after `phase3h-airroi-market-summary-ingestion` merged to `main` in
`demo-databricks-mdp` and CI/CD deployed it to `tst`/`prd` — the `dev`
copy had run successfully many times, but only ever as the human identity
(local `bundle deploy`/`bundle run`, never routed through the CI/CD SP),
so this gap was never exercised until the first SP-owned run.

## Decisions

**`READ`, not `MANAGE`, for the CI/CD SP.**
The pipeline only ever calls `dbutils.secrets.get()` — it never creates,
updates, or deletes secrets, or manages the scope's own ACLs. `READ` is
the minimum privilege that unblocks the real failure; `MANAGE` would be
unnecessary over-grant.

**Applied directly to the `airroi` scope, not folded into a generic
"CI/CD SP gets read on every secret scope" grant.**
Unlike the schema-level grants (`cicd_schema_use`), which are applied
proactively across every bronze schema since any future MV-based source
hits the same `CREATE_MATERIALIZED_VIEW` gap, secret scopes are
credential-specific — a blanket grant across `neon-postgres`/
`atlas-mongodb` too would hand the CI/CD SP read access to database
passwords it has never needed and doesn't currently read. Scoped to
exactly the one secret a pipeline actually reads.

## Risks / Trade-offs

- [Neon/Atlas pipelines might someday read their secrets directly instead
  of via UC Connection] → Not true today (confirmed: no `dbutils.secrets.get`
  call exists for either in `demo-databricks-mdp`'s current code) — if that
  changes, the same gap would need the same fix, applied at that time, not
  speculatively now.

## Migration Plan

Apply directly via `terraform apply` (same as `phase3d-cicd-materialized-view-grant`).
Additive only — no destroy, no downtime. Verify by re-running the `prd`
AirROI ingestion pipeline that originally failed; expect `COMPLETED`.
