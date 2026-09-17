## 1. Module refactor

- [x] 1.1 Change `databricks-unity-catalog` module input from `catalog_names` (list) to `catalog_name` (single string), keeping the internal 9-schema `for_each` per catalog — verify `terraform validate` passes against a single test invocation
- [x] 1.2 Confirm `aws-s3` module needs no signature change (already one bucket per call) — verify by re-reading `variables.tf`, no edit required

## 2. Repo restructure

- [x] 2.1 Move `envs/dev/modules/{neon,atlas,aws-s3,databricks-unity-catalog,databricks-secret-scopes}` to a new top-level `modules/` — verify `find modules -maxdepth 1 -type d` lists all five
- [x] 2.2 Create `deployment/free_workspace/` and move `envs/dev/{main.tf,variables.tf,outputs.tf,terraform.tf,dev.tfvars,dev.tfvars.example,.terraform.lock.hcl}` into it, updating each module `source =` to point at `../../modules/*` — verify `terraform validate` from inside `deployment/free_workspace/` passes
- [x] 2.3 Create `deployment/single_workspace/.gitkeep` and `deployment/multiple_workspaces/.gitkeep` — verify both folders exist and contain only the placeholder file
- [x] 2.4 Remove the now-empty `envs/` tree — verify `envs/` no longer exists

## 3. Root composition (three buckets, three catalogs)

- [x] 3.1 In `deployment/free_workspace/main.tf`, replace `bucket_name`/single-catalog variables with an `environments` map (`dev` → `hoe-mdp-dev` / `mdp_dev`, `tst` → `hoe-mdp-tst` / `mdp_tst`, `prd` → `hoe-mdp-prd` / `mdp_prd`) and `for_each` both the `aws_s3` and `unity_catalog` module calls over it — verified with `terraform validate` (no credentials available in this session for a real `terraform plan`; that runs as part of task 5.1)
- [x] 3.2 Update `uc_external_id` from a single variable to a map keyed by environment (`uc_external_ids`), threaded into each `aws_s3` instance's trust-policy condition — verify `dev.tfvars.example` documents the two-pass bootstrap (empty map first apply, filled from `terraform output` second apply) per environment
- [x] 3.3 Update `outputs.tf` to expose per-environment `bucket_names`/`catalog_names`/`uc_external_ids` (map outputs instead of scalars) — real values confirmed by `terraform output` once task 5 applies; structure verified by `terraform validate` for now

## 4. HCP Terraform workspace

- [x] 4.1 Update the `demo-databricks-iac` HCP Terraform workspace's Terraform working directory setting to `deployment/free_workspace` — done via the HCP Terraform UI (setting was previously empty, not `envs/dev` as assumed in design.md; this workspace uses CLI-driven runs, where the local directory you run `terraform` from is what's actually uploaded, so the setting wasn't load-bearing before but is now accurate for VCS-driven runs going forward)

## 5. Migration apply — destroys existing dev bucket/credential/location/catalogs, confirm before running

- [x] 5.1 Run `terraform plan` against the restructured config and review the full destroy/create list — confirmed exactly 38 destroyed (old single bucket/role/credential/location/3 catalogs/27 schemas) and 54 created (3x bucket/role/credential/location/catalog/9 schemas), 0 changed, Neon/Atlas/secret-scopes untouched
- [x] 5.2 Get explicit go-ahead before applying (destructive on real AWS/Databricks resources) — user approved 2026-09-18
- [x] 5.3 First apply with empty `uc_external_ids` — hit a real incident: the `dev` bucket/role kept the same physical name as the old shared setup, and with no explicit dependency between the old (being destroyed) and new (`for_each`-keyed) addresses, Terraform raced create-before-destroy, hitting `EntityAlreadyExists`/`BucketAlreadyOwnedByYou`, then the old bucket's own destroy failed with `BucketNotEmpty` (leftover UC catalog metadata objects, `force_destroy = false`). All old catalogs/schemas/credential/external-location were destroyed successfully before the error; `tst`/`prd` buckets+roles were created; `dev`'s bucket/role were not. Root cause and lesson: design.md's rejected alternative (`state mv` to preserve the unchanged-shape `dev` bucket) was actually the right call — destroying it was unnecessary and caused this. Recovered by: temporarily adding a root-level `aws_s3_bucket` resource with `force_destroy = true`, `state mv`-ing the orphaned bucket onto it, applying (`-target`) to record the flag, then destroying (`-target`) to empty and remove it — each step isolated to avoid a repeat race — then removing the temporary block and re-running the full apply (50 added, 0 changed, 0 destroyed). All 3 buckets, roles, storage credentials, external locations, catalogs, and 27 schemas confirmed created.
- [x] 5.4 Set `uc_external_ids` from `terraform output` (all three identical — tied to the single shared metastore, not the individual credential) and re-apply — the 3 IAM roles updated in-place as expected; the 3 `time_sleep.iam_propagation` resources also replaced (their `triggers` include the trust-policy JSON by design, so they re-run the 20s AWS propagation wait whenever it changes — no real cloud resource, harmless). `terraform plan` now reports no changes.

## 6. Verification

- [x] 6.1 `databricks catalogs list` shows `mdp_dev`/`mdp_tst`/`mdp_prd`; `databricks external-locations list` shows 3 locations, each pointing at a different bucket — confirmed against the actual workspace (`--profile DEFAULT`): `mdp_dev-external-location` → `s3://hoe-mdp-dev/` via `mdp_dev-s3-credential`, same pattern for `tst`/`prd`
- [ ] 6.2 Confirm `openspec/specs/cloud-storage/spec.md` and `openspec/specs/unity-catalog/spec.md` match deployed reality after archiving this change — verify by re-reading both against the applied state
