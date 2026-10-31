## Why

`demo-databricks-mdp`'s `fred-rates` (step 8 of the dividend portfolio story)
keeps the US 10-year Treasury yield as dated raw files that Auto Loader appends,
as RBA, SEC and Yahoo do. `raw-volume-rba` left FRED's volume to its own
change; this is it. The `fred` secret scope, its `api_key` and the CI/CD
principal's READ on it already exist.

## What Changes

- **Add** a managed volume `s3_raw` in `bronze_fred`, per environment, with
  `READ_VOLUME`/`WRITE_VOLUME` for the CI/CD service principal and the human
  account (same shape as `bronze_rba.s3_raw`).
- Both deployments (`free_workspace`, `single_workspace`), kept identical.

## Capabilities

### New Capabilities

### Modified Capabilities
- `uc-volumes`: a FRED landing volume.

## Impact

- `terraform plan` on `free_workspace` should show **4 to add, 0 to change,
  0 to destroy**: one volume and one volume grant per environment.
- Volumes do not count against the 500-table or 50-schema quotas.
- Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `fred-rates` in `demo-databricks-mdp`: its fetch notebook writes
into `bronze_fred.s3_raw`, so this change must be applied before that one
deploys to dev.

## Model

Sonnet: copies the RBA volume block.
