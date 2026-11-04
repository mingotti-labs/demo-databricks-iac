## Why

`demo-databricks-mdp`'s `market-climate-gold` (change 3 of the market climate story, planning
`docs/superpowers/specs/2026-11-04-market-climate-story-design.md`) builds the first gold tables, in
`gold_analytics_gateway`. The schema exists in both catalogs, but it is not in `cicd_writable_schemas`,
so the CI/CD service principal that runs mdp's pipelines cannot create tables there, and the human
account cannot read what it creates.

## What Changes

- Add `gold_analytics_gateway` to `cicd_writable_schemas` in `deployment/free_workspace/main.tf` and
  `deployment/single_workspace/main.tf` (kept identical). This gives the CI/CD principal `USE_SCHEMA`,
  `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW` and the human account `SELECT`, as for every other
  writable schema.
- No schema is created or removed; `gold_integration_gateway` and `gold_ai_gateway` stay without
  grants until a story uses them.

## Capabilities

### Modified Capabilities
- `unity-catalog`: the CI/CD principal can build tables in `gold_analytics_gateway`.

## Impact

- `terraform plan` on `free_workspace`: 2 grants to add (one per environment), nothing else.
- No table or schema quota change. Apply needs the user's explicit go-ahead.

## Cross-repo dependencies

Provides for `market-climate-gold` in `demo-databricks-mdp`: its gold pipeline writes into
`gold_analytics_gateway`, so this change must be applied before that one deploys to dev.

## Model

Sonnet: one entry added to an existing list in two files.
