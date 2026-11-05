## 1. Change

- [x] 1.1 `databricks_sql_access = true` on `databricks_service_principal.cicd_github` in
      `modules/databricks-identity-governance/main.tf`, comment updated; `terraform validate` passes in
      `deployment/free_workspace` and `deployment/single_workspace`

## 2. Plan and apply

- [x] 2.1 `terraform plan` on `free_workspace` shown in full: one in-place update of the service principal,
      no replace, nothing else
- [x] 2.2 Apply after the user's go-ahead; a fresh plan shows no changes
- [x] 2.3 Verify: `databricks service-principals get` lists `databricks-sql-access` and `workspace-access`

## 3. Confirm it fixes the Genie deploy

- [x] 3.1 Re-run `demo-databricks-mdp` PR #174's `deploy-dev`: it passes (the agent is read back and updated)
