## Why

A review of the implemented Phase 1 change surfaced three problems before Phase 3 starts writing real data into it:

1. **One shared S3 bucket for all three catalogs.** `mdp_dev`, `mdp_tst`, and `mdp_prd` are isolated only by an S3 key prefix inside a single bucket (`hoe-mdp-dev`), behind one IAM role and one storage credential. That's weaker isolation than a real client engagement would use — prod should not share a bucket, an IAM role, or a storage credential with dev/tst.
2. **`envs/dev` implies environment scoping it doesn't have.** Databricks Free Edition is one workspace and one metastore, so this single Terraform root already provisions all three catalogs (`mdp_dev`/`tst`/`prd`) in one apply. Naming the folder `dev` misrepresents what applying it actually does.
3. **Modules aren't reusable.** They live under `envs/dev/modules/`, coupled to the one deployment root that exists today. There is no structure that signals "this is a single-workspace deployment" or that leaves room for a different deployment shape (a paid single workspace, or the corporate multi-workspace pattern from the roadmap's Appendix A) without duplicating module code.

## What Changes

- Split the shared S3 bucket into three: `hoe-mdp-dev`, `hoe-mdp-tst`, `hoe-mdp-prd` — each with its own IAM role, storage credential, and external location, scoped to exactly one catalog
- Refactor the `databricks-unity-catalog` module from "one credential/location, N catalogs via internal `for_each`" to "one credential/location/catalog per module call" — multiplicity moves to the root, one call per environment
- Promote `neon`, `atlas`, `aws-s3`, `databricks-unity-catalog`, and `databricks-secret-scopes` modules from `envs/dev/modules/` to a top-level `modules/`
- Replace `envs/dev/` with `deployment/free_workspace/` as the one real deployment root (Free Edition: single workspace, serverless-only, no account-level API)
- Add two placeholder deployment roots for future shapes, each holding only a `.gitkeep`: `deployment/single_workspace/` (a future paid single workspace, not Free-Edition-constrained) and `deployment/multiple_workspaces/` (the roadmap's corporate multi-workspace pattern)
- Update the HCP Terraform workspace's Terraform working directory from `envs/dev` to `deployment/free_workspace`
- Destroy and recreate the affected Phase 1 resources (bucket, IAM role, storage credential, external location, catalogs, schemas) under the new structure — no data exists yet, so this is a clean re-apply rather than a state migration

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `cloud-storage`: one bucket + IAM role per environment catalog instead of one shared bucket
- `unity-catalog`: one storage credential + external location per environment catalog, each backed by its own bucket; catalog `storage_root` points at the root of its own bucket instead of a prefix in a shared bucket

## Impact

- Destroys and recreates: the existing `hoe-mdp-dev` bucket/IAM role/storage credential/external location, and all three catalogs and their schemas (Neon/Atlas source databases and secret scopes are untouched — this change is scoped to storage and Unity Catalog structure)
- No data loss: Phase 3 (ingestion) hasn't started, so no Delta tables exist yet in any catalog
- Two new S3 buckets (`hoe-mdp-tst`, `hoe-mdp-prd`) and their IAM roles, all within free-tier limits
- Requires a manual, out-of-band update to the HCP Terraform workspace's working-directory setting (not something `terraform apply` itself can change)
- Requires a two-pass apply per environment for the hardened IAM trust policy (`uc_external_id`), same pattern as the original Phase 1 change, now repeated three times instead of once
