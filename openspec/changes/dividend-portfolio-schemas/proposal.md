## Why

`demo-databricks-mdp` is starting its first end-to-end story: which S&P 500
companies are good dividend candidates for a Sydney-based investor who buys
monthly and reviews quarterly (design: `demo-databricks-planning`,
`docs/superpowers/specs/2026-10-24-dividend-portfolio-story-design.md`). It adds
seven sources, the first silver domain and the first gold tables. The user
decided that one iac change creates everything the story needs up front, so
every later change is mdp-only and the FMP probe can read the user's key from a
secret scope.

## What Changes

- **Schemas** (in `modules/databricks-unity-catalog`, both catalogs):
  `bronze_<s>`, `bronze_<s>_publish` and `silver_landing_<s>` for each of
  `fmp`, `wikipedia`, `sec`, `yahoo`, `rba`, `fred`, `portfolio` and
  `reference` (24 schemas), plus `silver_investments`, the first Silver
  Domain schema. `gold_analytics_gateway` already exists.
- **CI/CD grants**: the 25 new schemas join `local.cicd_writable_schemas`
  (`USE_SCHEMA`, `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW` for the CI/CD
  service principal, `SELECT` for the human account), in `free_workspace` and
  `single_workspace`.
- **Secret scopes** `fmp` and `fred`, each with one key `api_key`, from new
  sensitive variables `fmp_api_key` and `fred_api_key` set directly in HCP
  Terraform, each with `READ` for the CI/CD service principal.
- **Volume** `s3_portfolio_raw` in `bronze_portfolio` per catalog (the user's
  purchases CSV), with `READ_VOLUME`/`WRITE_VOLUME` for the CI/CD service
  principal and for the human account (who uploads the file).
- Not included: `silver_normalised_<s>` schemas (decided per source later),
  any gold schema (exists), anything in `multiple_workspaces` (placeholder).

## Capabilities

### Modified Capabilities
- `unity-catalog`: the schema list gains the 25 schemas; Silver Domain schemas
  are allowed from now on, starting with `silver_investments`.
- `secret-scopes`: new `fmp` and `fred` scopes; the CI/CD read requirement
  lists them.
- `uc-volumes`: new portfolio landing volume.

## Cross-repo dependencies

Depended on by every `demo-databricks-mdp` change of the dividend portfolio
story, starting with its probes (the FMP probe reads `fmp`/`api_key`). None of
them should deploy until this change is applied.

## Model

Sonnet to implement: it repeats the airroi schema, secret and ACL pattern and
the clickstream volume pattern.

## Impact

- `terraform plan` on `free_workspace` (the only applied deployment;
  `single_workspace` is an unapplied reference copy) should show about 112
  additions:
  50 schemas and 50 grants (25 × 2 catalogs), 2 scopes, 2 secrets, 2 ACLs,
  2 volumes, 2 volume grants, and nothing changed or destroyed.
- No tables, so nothing counts against the Free Edition 500-table limit.
- The user sets `fmp_api_key` (existing key) and `fred_api_key` (free key from
  FRED) in HCP Terraform before the plan. Apply needs the user's explicit
  go-ahead.
