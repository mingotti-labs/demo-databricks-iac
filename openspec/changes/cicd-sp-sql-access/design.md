## Context

`svc-cicd-github` was created with `workspace_access = true` only, "the narrowest of the three" entitlements
that a `bundle deploy` needs (identity-governance spec). That held for pipelines, jobs and dashboards. A
Genie agent is read through an API that checks the `/sqlanalytics` ACL path, which is the
`databricks-sql-access` entitlement; creating one passed, reading it back (every bundle plan after the first)
returns 403. Seen in `demo-databricks-mdp` PR #174, run 41974349497.

## Decisions

### D1. Add `databricks_sql_access`, keep `workspace_access`
The provider's `databricks_service_principal` has `databricks_sql_access` for exactly this entitlement.
`workspace_access` stays, so nothing the principal does today changes. Alternative: switch to `databricks_sql_access`
only. Not taken: the existing spec found `workspace-access` empirically for deploys; replacing it risks the
jobs and pipelines for no gain.

### D2. Minimal: no `allow_cluster_create`, no admin
Only the one entitlement the 403 names. Verified afterwards by the redeploy, not assumed.

## Risks / Trade-offs

- [The entitlement is not enough, because Genie also needs a permission on the agent] → the principal owns
  the agents it creates (it has `CAN_MANAGE`, seen in P1); the plan shows what the 403 is about, and the
  redeploy is the check. If it still fails, stop and report.
- [An in-place update recreates the principal] → the plan must show `~ update in-place`, not `-/+`; any
  replace stops the apply (it would change the application id and break the GitHub secrets).

## Migration Plan

Apply once on `free_workspace` (dev and prd share the workspace). Rollback: set the attribute back to `false`
and apply.
