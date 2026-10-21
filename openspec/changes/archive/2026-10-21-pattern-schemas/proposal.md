## Why

`demo-databricks-mdp` now keeps pattern-only implementations in a separate,
dev-only bundle (`references/patterns/`, changes 1 and 2 of that repo's
design-pattern work). Its pipelines still write into `bronze_clickstream`, a
real source schema, because no pattern schema exists yet. This is change 3 of
4: give pattern output its own home, dev only, so it can never be mistaken for
live data.

## What Changes

- **New module `modules/databricks-uc-pattern-schemas/`** creating the pattern
  schemas in one catalog: `pattern_bronze` and `pattern_bronze_publish`.
  Further layers (`pattern_silver_landing` and so on) are added by adding a
  map entry when a pattern needs one.
- **Instantiated once, against the `dev` catalog only** in
  `deployment/free_workspace/main.tf`
  (`catalog_name = module.unity_catalog["dev"].catalog_name`), not with
  `for_each` over `environments`. `tst` is gone and `prd` never gets them.
- **Mirrored in `deployment/single_workspace/`** (the unapplied reference
  copy), so it stays a faithful picture of the composition.
- Docs: NAMING.md (`pattern_<layer>` schema rule, dev only) and CLAUDE.md
  (a short section next to "Silver schema shape").
- **No grants in this change.** The patterns bundle is deployed by hand in dev
  as the human operator, who owns the schemas Terraform creates. Grants for the
  CI/CD service principal are added when a CI deploy of that bundle exists.
- **Out of scope**: repointing the pattern pipelines in `demo-databricks-mdp`
  from `bronze_clickstream` to `pattern_bronze` (a small follow-up there), and
  moving the SQL twins.

## Capabilities

### New Capabilities
- `pattern-schemas`: the dev-only schemas that hold output of pattern-only
  implementations.

### Modified Capabilities
None. The `unity-catalog` capability's per-catalog schema list is untouched;
pattern schemas are deliberately outside it.

## Model

Sonnet to propose and implement. One small module and one call, following
`databricks-uc-volume`'s shape; no new convention beyond the naming rule.

## Cross-repo dependencies

Provides for a follow-up change in `demo-databricks-mdp` (after
`references-patterns-bundle`): repoint the seven pattern pipelines to
`pattern_bronze`. That change must not deploy until the schemas exist, so this
change is applied first.

## Impact

- Adds two schemas in `mdp_dev`; no tables, so no effect on the 500-table
  quota (tables created in them later do count).
- A normal additive `terraform plan`/`apply` (2 to add, 0 to change, 0 to
  destroy), run locally against the HCP backend, passing the full
  `uc_external_ids` for `dev` and `prd`.
- No effect on `prd` or on any live source schema.
