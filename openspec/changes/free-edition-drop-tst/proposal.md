## Why

Databricks warned that the metastore is at 90% of the 500-table Unity Catalog
quota. Measured: `mdp_dev` 223, `mdp_prd` 120, `mdp_tst` 110 (98 after the
`demo-databricks-mdp` bundle's `tst` deployment was destroyed), 454 in total.
`demo-databricks-mdp` already dropped `tst` for the free edition
(`free-edition-config`); its `tst` catalog and tables are still here because
this repo owns catalogs, schemas, volumes and buckets, and its state still
expects them.

## What Changes

- The `free_workspace` root's `environments` default drops `tst`, leaving
  `dev` and `prd`. Everything per environment is already driven by
  `for_each = var.environments`, so removing the key removes, per the plan:
  the S3 bucket and IAM role, storage credential, external location, catalog
  `mdp_tst` with its 30 schemas, the clickstream volume, and their grants.
- A one-time, approval-gated preparation so that destroy can succeed (see
  design.md): drop the `mdp_tst` schemas with `CASCADE` and empty the
  `hoe-mdp-tst` bucket (all object versions). Neither is done by Terraform.
- No `config.json` and no new modules: the existing `environments` map is
  already the edition switch. A paid-edition root
  (`deployment/single_workspace/`, reserved) would keep three environments in
  its own variables.

## Capabilities

### New Capabilities
- `environment-selection`: which environments a deployment root provisions,
  and that nothing else varies by edition.

### Modified Capabilities
None.

## Model

Sonnet to propose and implement. One variable default changes; the care is in
the destroy preparation, not in design.

## Cross-repo dependencies

Follows `free-edition-config` in `demo-databricks-mdp` (merged), which removed
the `tst` target and workflows there. No ordering constraint remains: nothing
in that repo deploys to `tst` any more.

## Impact

- `deployment/free_workspace/variables.tf` (default) and README/CLAUDE.md
  mentions of `tst`.
- Destroys real resources in HCP Terraform on apply: bucket `hoe-mdp-tst`,
  its IAM role, `mdp_tst` catalog and everything in it. Irreversible; `tst`
  data is rebuildable from the sources by the standard edition.
- Projected table count after apply: about 344 of 500 (`dev` 223 + `prd` 120,
  plus 1 in `dbacademy`).
