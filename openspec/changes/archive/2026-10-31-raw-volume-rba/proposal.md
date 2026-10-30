## Why

`demo-databricks-mdp`'s `rba-rates` (step 7 of the dividend portfolio story)
keeps the RBA's exchange and money market rates as dated raw files that Auto
Loader appends, as SEC and Yahoo do. `raw-volumes-sec-yahoo-wikipedia` left
RBA's volume to its own change; this is it.

## What Changes

- **Add** a managed volume `s3_raw` in `bronze_rba`, per environment, with
  `READ_VOLUME`/`WRITE_VOLUME` for the CI/CD service principal and the human
  account (same shape as `bronze_wikipedia.s3_raw`).
- Both deployments (`free_workspace`, `single_workspace`), kept identical.
- Not included: FRED's volume (step 8 decides its raw shape).

## Capabilities

### New Capabilities

### Modified Capabilities
- `uc-volumes`: an RBA landing volume.

## Impact

- `terraform plan` on `free_workspace` should show **4 to add, 0 to change,
  0 to destroy**: one volume and one volume grant per environment.
- Volumes do not count against the 500-table or 50-schema quotas.
- Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `rba-rates` in `demo-databricks-mdp`: its fetch notebook writes
into `bronze_rba.s3_raw`, so this change must be applied before that one
deploys to dev.

## Model

Sonnet: copies the Wikipedia volume block.
