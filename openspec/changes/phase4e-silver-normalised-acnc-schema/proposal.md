## Why

`demo-databricks-mdp`'s `phase4e-silver-normalised-acnc` normalises acnc,
the second Silver Normalised source. Its pipeline writes into
`silver_normalised_acnc`, which does not exist yet. Silver Normalised is
one schema per source, added just in time when that source is normalised
(same pattern as `phase4d-silver-normalised-airroi-schema`).

## What Changes

- Add `silver_normalised_acnc` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf`.
- Add it to `local.cicd_writable_schemas` in
  `deployment/free_workspace/main.tf`: the CI/CD SP gets `USE_SCHEMA`,
  `CREATE_TABLE` and `CREATE_MATERIALIZED_VIEW`, and the human operator
  gets `SELECT` — the same grants as `silver_normalised_airroi`.
- No `APPLY TAG` grant: confirmed not needed for airroi's tag step (table
  ownership is enough), and the mechanism is identical for acnc.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains `silver_normalised_acnc`.

## Cross-repo dependencies

Required by `phase4e-silver-normalised-acnc` in `demo-databricks-mdp`: its
`silver_normalised_acnc` pipeline writes into this schema, so this change
is applied before that one deploys.

## Impact

- Adds 3 schema resources (1 schema × 3 environments) and 3
  `cicd_schema_use` grant resources.
- No impact on any existing schema, table or grant.

## Model

Sonnet — repeats the `phase4d-silver-normalised-airroi-schema` pattern
exactly, including the confirmed no-`APPLY TAG` finding.
