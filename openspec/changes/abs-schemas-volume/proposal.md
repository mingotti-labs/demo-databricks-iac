## Why

`demo-databricks-mdp`'s `abs-cpi` adds a new source: Australian CPI from the
ABS Data API (no key). Like RBA and FRED it keeps dated raw files in a volume
that Auto Loader appends. The source needs its bronze schemas and that volume
before it deploys to dev.

## What Changes

- **Add** schemas `bronze_abs` and `bronze_abs_publish` to both deployments, in
  the schema map and in `cicd_writable_schemas` (CI/CD `USE_SCHEMA`,
  `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW`; human `SELECT`).
- `single_workspace` also gets `silver_landing_abs` (it keeps one Landing schema
  per source); `free_workspace` uses the shared `silver_landing`.
- **Add** a managed volume `s3_raw` in `bronze_abs`, per environment, with
  `READ_VOLUME`/`WRITE_VOLUME` for the CI/CD service principal and the human
  account (copy of the FRED block).
- No secret scope: the ABS API needs no key.

## Capabilities

### New Capabilities

### Modified Capabilities
- `unity-catalog`: `abs` joins the story's sources.
- `uc-volumes`: an ABS landing volume.

## Impact

- `terraform plan` on `free_workspace` should show **12 to add, 0 to change,
  0 to destroy**: per environment, 2 schemas, 2 schema grants, 1 volume and
  1 volume grant.
- Schema quota: dev 38 -> 40, prd 36 -> 38 of 50.
- Schemas and volumes do not count against the 500-table quota.
- Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `abs-cpi` in `demo-databricks-mdp`: its fetch notebook writes into
`bronze_abs.s3_raw` and its pipelines write into `bronze_abs`,
`bronze_abs_publish` and `silver_landing`, so this change must be applied
before that one deploys to dev.

## Model

Sonnet: copies the FRED schema entries and volume block.
