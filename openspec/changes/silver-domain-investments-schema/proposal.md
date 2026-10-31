## Why

`demo-databricks-mdp`'s `silver-domain-investments` builds the first Silver
Domain. The user decided (2026-10-31) that Silver Domain schemas are named
`silver_domain_<domain>`, so the empty `silver_investments` schema created by
`dividend-portfolio-schemas` is replaced by `silver_domain_investments`.

## What Changes

- **Add** schema `silver_domain_investments` per environment, with the same
  CI/CD grants (`USE_SCHEMA`, `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW`) and
  human `SELECT` that `silver_investments` has.
- **Remove** schema `silver_investments` (empty: nothing was ever built in it).
- Both deployments (`free_workspace`, `single_workspace`) and the module's
  default schema map, kept identical.
- CLAUDE.md and NAMING.md: Silver Domain schemas are `silver_domain_<domain>`.

## Capabilities

### New Capabilities

### Modified Capabilities
- `unity-catalog`: the Silver Domain schema is `silver_domain_investments`, and
  Silver Domain schemas are named `silver_domain_<domain>`.

## Impact

- `terraform plan` on `free_workspace` should only replace the one schema and
  its grants in each environment: about 4 to add, 0 to change, 4 to destroy
  (checked in full before apply). The destroy is of an empty schema.
- Schema quota unchanged (one schema replaces another): dev 37, prd 35 of 50.
- Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `silver-domain-investments` in `demo-databricks-mdp`: its pipeline
writes into `silver_domain_investments`, so this change must be applied before
that one deploys to dev.

## Model

Sonnet: a rename of one entry in three schema lists.
