## MODIFIED Requirements

### Requirement: CI/CD service principal
A service principal SHALL exist for CI/CD bundle deployment, with an OAuth client
secret Terraform generates and exposes as a sensitive output, and the
`workspace_access` and `databricks_sql_access` entitlements. `workspace-access` is the minimum that a
`bundle deploy` of pipelines, jobs and dashboards requires (determined empirically, not guessed);
`databricks-sql-access` is also required to read a Genie agent back on a later deploy and to look a SQL warehouse
up by name (a 403 `aclPath entitlement: /sqlanalytics` without it).

#### Scenario: Service principal created
- **WHEN** the identity-governance resources are applied
- **THEN** a service principal named `svc-cicd-github` exists with `workspace_access =
  true` and `databricks_sql_access = true` and all other entitlement flags `false`, and `terraform output`
  exposes its `cicd_client_id` (plain) and `cicd_client_secret` (sensitive)

#### Scenario: A Genie agent redeploys
- **WHEN** a bundle that contains a Genie agent is deployed twice as the service principal
- **THEN** the second deploy plans and succeeds, with no `aclPath entitlement` error
