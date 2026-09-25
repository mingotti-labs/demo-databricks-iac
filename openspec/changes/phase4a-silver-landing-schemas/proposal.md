## Why

`demo-databricks-mdp`'s `phase4a-silver-landing` change lands all 10 Bronze
Publish entities across 6 source systems into source-aligned Silver Landing
materialized views, one schema per source. This repo owns catalog/schema
provisioning (per that repo's CLAUDE.md's Terraform-vs-app-repo split), so
those 6 schemas must exist here before that change's pipelines can deploy.

## What Changes

- Add `silver_landing_neon`, `silver_landing_clickstream`,
  `silver_landing_ungm`, `silver_landing_acnc`, `silver_landing_nsw_spatial`,
  and `silver_landing_airroi` to `local.schemas` in
  `modules/databricks-unity-catalog/main.tf` — one schema per source, mirrors
  every bronze source's own schema entry
- Add the same 6 schemas to `local.cicd_writable_schemas` in
  `deployment/free_workspace/main.tf`, including `CREATE_MATERIALIZED_VIEW`
  from the start — every Silver Landing table is a Materialized View (per
  `demo-databricks-mdp`'s `silver.md`), so this applies the
  `phase3d-cicd-materialized-view-grant`/`phase3f-nsw-property-schema`
  lesson proactively rather than waiting for a real pipeline failure

## Capabilities

### Modified Capabilities
- `unity-catalog`: the "Bronze and gold schemas per catalog" requirement's
  schema list gains the 6 new `silver_landing_*` schemas, and its "Silver
  schemas SHALL NOT be created" statement is corrected — source-aligned
  Silver Landing schemas now exist; only Silver Domain/Marts schemas remain
  deferred (domains still not yet defined)

## Cross-repo dependencies

Required by `demo-databricks-mdp`'s `phase4a-silver-landing` change — its 6
new Lakeflow Declarative Pipelines write into these schemas. That change's
pipelines should not be deployed until this one has landed.

## Impact

- Adds 18 schema resources (6 new schemas × 3 environments)
- Adds 18 more `cicd_schema_use` grant resources (same 6 schemas × 3
  environments)
- No impact on any existing schema, table, grant, or secret scope
