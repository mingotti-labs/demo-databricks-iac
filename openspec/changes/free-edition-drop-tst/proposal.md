## Why

Databricks warned that the metastore is at 90% of the 500-table Unity Catalog
quota. Measured: `mdp_dev` 223, `mdp_prd` 120, `mdp_tst` 110 (98 after the
`demo-databricks-mdp` bundle's `tst` deployment was destroyed), 454 in total.
`demo-databricks-mdp` already dropped `tst` for the free edition
(`free-edition-config`); its `tst` catalog and tables are still here because
this repo owns catalogs, schemas, volumes and buckets, and its state still
expects them.

What `deployment/free_workspace/` holds today (one workspace, three
environments as catalogs) is really the `single_workspace` shape with some
Free Edition workarounds on top. The three-environment version should be kept
as the reference for a paid edition, not lost when Free drops `tst`.

## What Changes

- **Copy `deployment/free_workspace/` to `deployment/single_workspace/`**
  (three environments, today's content), as an untested reference copy:
  - no binding to the real HCP workspace `demo-databricks-iac`: its `cloud`
    block is removed, so it cannot share or touch the Free state;
  - a README stating it has never been applied and that the Free Edition
    workarounds in it (workspace-level groups only, placeholder access
    groups, no account API) are probably wrong for a paid edition.
- **Trim `free_workspace`**: the `environments` default drops `tst`, leaving
  `dev` and `prd`. Everything per environment is already driven by
  `for_each = var.environments`, so removing the key removes the S3 bucket and
  IAM role, storage credential, external location, catalog `mdp_tst` with its
  30 schemas, the clickstream volume, and their grants.
- A one-time, approval-gated preparation so that destroy can succeed (see
  design.md): drop the `mdp_tst` schemas with `CASCADE` and empty the
  `hoe-mdp-tst` bucket (all object versions). Neither is done by Terraform.
- No `config.json` and no new modules: the existing `environments` map is
  already the edition switch. `multiple_workspaces/` stays an empty placeholder.
- Docs: CLAUDE.md repository-structure section and mentions of `tst`.

## Capabilities

### New Capabilities
- `environment-selection`: which environments a deployment root provisions,
  and that the single-workspace reference copy is isolated from live state.

### Modified Capabilities
None.

## Model

Sonnet to propose and implement. A copy, a variable default, and care around
the destroy preparation; no new convention.

## Cross-repo dependencies

Follows `free-edition-config` in `demo-databricks-mdp` (merged), which removed
the `tst` target and workflows there. No ordering constraint remains: nothing
in that repo deploys to `tst` any more.

## Impact

- New: `deployment/single_workspace/` (copy, isolated, unapplied).
- Changed: `deployment/free_workspace/variables.tf` default and its
  `dev.tfvars.example`; CLAUDE.md and NAMING.md.
- Destroys real resources on apply: bucket `hoe-mdp-tst`, its IAM role,
  `mdp_tst` catalog and everything in it. Irreversible; `tst` data is
  rebuildable from the sources by the standard edition.
- Projected table count after apply: about 344 of 500 (`dev` 223 + `prd` 120,
  plus 1 in `dbacademy`).
