## Why

`demo-databricks-mdp`'s `phase4d-silver-normalised-framework` builds the
Silver Normalised run-time framework and normalises its first source,
airroi. Its pipeline writes into `silver_normalised_airroi`, which does not
exist yet. Silver Normalised is one schema per source, like Silver
Landing, and each schema is created just in time, when its source is
normalised.

## What Changes

- Add `silver_normalised_airroi` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf`.
- Add it to `local.cicd_writable_schemas` in
  `deployment/free_workspace/main.tf`: the CI/CD SP gets `USE_SCHEMA`,
  `CREATE_TABLE` and `CREATE_MATERIALIZED_VIEW` (every Silver Normalised
  table is a materialized view), and the human operator gets `SELECT`, the
  same grants as `silver_landing_airroi`.
- If the tag step in the mdp change turns out to need an explicit
  `APPLY TAG` grant beyond table ownership (checked in `dev`), it is added
  here, in this change's implementation PR.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `silver_normalised_airroi`.

## Cross-repo dependencies

Required by `phase4d-silver-normalised-framework` in `demo-databricks-mdp`:
its `silver_normalised_airroi` pipeline writes into this schema, so this
change is applied before that one deploys.

## Impact

- Adds 3 schema resources (1 schema × 3 environments) and 3
  `cicd_schema_use` grant resources.
- No impact on any existing schema, table or grant.

## Model

Sonnet — repeats the Silver Landing schema + CI/CD grant pattern
(`phase4b-silver-landing-iso-geonames-schemas`). Run on Opus here only
because it is part of the Opus mdp change's session.
