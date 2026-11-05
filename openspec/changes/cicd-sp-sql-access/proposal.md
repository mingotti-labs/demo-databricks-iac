## Why

`demo-databricks-mdp`'s `market-climate-genie` (change 5 of the market climate story) deploys a Genie agent
with the bundle. Creating it as the CI/CD service principal works, but the next deploy fails while planning:
the bundle reads the agent back and gets `403 PERMISSION_DENIED: You need the aclPath entitlement:
/sqlanalytics`. The principal has only `workspace-access`. Before this, the same missing entitlement
(`databricks-sql-access`) stopped the bundle from looking a SQL warehouse up by name, which the dashboard
change worked around with a literal warehouse id.

## What Changes

- `databricks_service_principal.cicd_github` in `modules/databricks-identity-governance/main.tf` gets
  `databricks_sql_access = true`, next to the existing `workspace_access = true`. The comment there is updated:
  `workspace-access` is enough for pipelines, jobs and dashboards; reading a Genie agent needs
  `databricks-sql-access`.
- The identity-governance spec says the principal has both entitlements.
- Nothing is removed. The principal's catalog and schema privileges do not change.

## Capabilities

### Modified Capabilities
- `identity-governance`: the CI/CD service principal's entitlements.

## Impact

- `terraform plan` on `free_workspace`: one in-place update of the service principal (its entitlements);
  nothing else. The OAuth secret and application id are unchanged, so no GitHub secret changes.
- Effect: the principal can read Genie agents and list SQL warehouses. It gets no new data privilege.
- No table or schema quota change. Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `market-climate-genie` in `demo-databricks-mdp` (PR #174, parked): its `deploy-dev` fails on the
second deploy until this is applied (probe P1, `references/docs/registers/probes.md` there). After the apply,
that change's deploy is re-run and a Genie agent redeploys cleanly; that is this change's last check.

## Model

Sonnet: one attribute on an existing resource and a spec edit, as `gold-analytics-gateway-grants`.
