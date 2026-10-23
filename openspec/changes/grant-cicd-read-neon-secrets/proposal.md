## Why

The CI/CD service principal cannot read the `neon-postgres` secret scope, so
anything it runs that connects to the Neon database directly fails with
`PERMISSION_DENIED: ... does not have secret-scopes.secrets/get permission on
scope neon-postgres`. Found 2026-10-23 when `demo-databricks-mdp`'s `run_neon`
job first ran as the service principal: the seed-data check and the
source-versus-bronze row-count check both read the Neon database and failed.
Those checks were left out of the automated neon verification as a stopgap;
they belong in it. The platform is meant to be demoed and to do what it should,
so the missing grant is the fix, not a reason to drop the checks.

The same gap already happened once for `airroi` (an ACL added after a prd
failure, `databricks_secret_acl.cicd_airroi_read`); the secret-scopes spec does
not record either grant.

## What Changes

- A `databricks_secret_acl` giving the CI/CD service principal `READ` on the
  `neon-postgres` scope, next to the airroi one, in `free_workspace` and
  `single_workspace` (same file content in both; `multiple_workspaces` is a
  reserved placeholder).
- The `secret-scopes` spec records the principle: the CI/CD service principal
  holds `READ` on every scope that pipeline or job code reads at runtime
  (airroi today, neon with this change).
- Not included: the `atlas-mongodb` scope. Nothing reads it at runtime; it backs
  a UC connection. It gets the same grant when a source needs it.

## Capabilities

### Modified Capabilities
- `secret-scopes`: the CI/CD service principal reads the scopes that code reads at runtime.

## Cross-repo dependencies

Depended on by `refactor-airroi-clickstream-neon` in `demo-databricks-mdp`: once
this is applied, its neon verification adds the seed-data and
source-versus-bronze checks back, run as the service principal.

## Model

Sonnet to implement: it repeats the existing airroi ACL.

## Impact

- The service principal can read the Neon dev branch's host, database name, role
  name and password. That is the credential the Neon UC connection already uses
  on its behalf, and the database holds synthetic data on the `dev` branch only.
- `terraform plan` shows one added resource per active deployment. Apply needs
  the user's explicit go-ahead.
