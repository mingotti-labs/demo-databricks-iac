## Context

`deployment/free_workspace/main.tf` drives the bucket, Unity Catalog module
(storage credential, external location, catalog, schemas), access groups,
grants and the clickstream volume from `for_each = var.environments`. That map
is already the whole "which environments" decision.

## Decisions

- **Edit the default, not add a config file.** `free_workspace` is the Free
  Edition root by definition; a paid edition gets its own root
  (`single_workspace/`, reserved). The map's default in that root is the right
  place. A `config.json` plus edition folders (as in `demo-databricks-mdp`)
  would add machinery Terraform does not need.
- **No `force_destroy` flags in modules.** Adding them would make every
  environment, including `prd`, easier to destroy by accident, for a one-off
  need. Preparation is manual and approved instead.

## Destroy preparation (one-time, each step needs explicit approval)

Terraform destroys schemas before the catalog, and schemas before their
dependents, but will not remove a schema that still holds tables, nor a
non-empty versioned bucket (the modules set neither `force_destroy`).

1. `DROP SCHEMA mdp_tst.<schema> CASCADE` for the 30 Terraform-managed schemas
   (plus the leftover tables they hold, 98 at the last count). Unity Catalog
   keeps dropped managed-table data for a retention period, so the files stay
   in the bucket.
2. Empty `hoe-mdp-tst`: all objects and all versions and delete markers.
3. Then the apply can destroy the empty schemas, volume, catalog, external
   location, storage credential, IAM role and bucket.

If step 3 fails partway, state is partial but consistent; fix the blocker and
re-apply.

## Risks

- **HCP workspace variable override.** If the HCP Terraform workspace sets
  `environments` itself, the repo default is ignored. Terraform is run
  locally against the HCP backend (CLAUDE.md, "Running Terraform locally"),
  so the plan is a local `terraform plan`; it must list only `tst` resources.
- **Plan scope.** Anything keyed on `environments` that is not `tst`-specific
  must show no changes. Anything other than `tst` in the plan is a stop.
- **`uc_external_ids` must be passed in full** on that local plan/apply
  (current values from `terraform output -json uc_external_ids`, for `dev`
  and `prd`). Omitting it plans to strip the `sts:ExternalId` condition from
  every trust policy, as CLAUDE.md warns; the plan review catches this.
- Irreversible for `tst` data; accepted (rebuildable from sources, per
  `demo-databricks-mdp` CLAUDE.md).
- `uc_external_ids` is keyed like `environments`; a stale `tst` entry is
  harmless (looked up with a default) and is removed for tidiness.
