## Why

The CI/CD service principal's `prd` AirROI ingestion pipeline
(`phase3h-airroi-market-summary-ingestion`, `demo-databricks-mdp`) failed
its first real run on `dbutils.secrets.get("airroi", "api_key")` — a
`SecretManagerClient` error, confirmed via a real run, not assumed.
`databricks secrets list-acls airroi` showed the scope's only ACL is
`MANAGE` for the human account (Terraform's default `databricks_secret_scope`
creator ACL) — the CI/CD SP has no access at all. AirROI is the first
source whose pipeline code actually calls `dbutils.secrets.get()` at
runtime: `neon-postgres`/`atlas-mongodb`'s secrets back Terraform-managed
UC Connections instead, never read directly by pipeline code, so this gap
never surfaced for either of them.

## What Changes

- Add a `databricks_secret_acl` granting the CI/CD SP `READ` on the
  `airroi` secret scope
- Add an `airroi_scope_name` output to `modules/databricks-secret-scopes/`
  (the module had no output for this scope yet)

## Capabilities

### Modified Capabilities
- `secret-scopes`: the "AirROI secret scope" requirement gains an explicit
  CI/CD SP read grant

## Cross-repo dependencies

Unblocks `demo-databricks-mdp`'s `phase3h-airroi-market-summary-ingestion`
running under the CI/CD SP in `tst`/`prd` — that pipeline's
`market_summary_raw`/`market_metrics_all_raw` both call
`dbutils.secrets.get("airroi", "api_key")`.

## Impact

- Adds one `databricks_secret_acl` resource and one module output — no
  resources destroyed, no impact on any other principal's access
