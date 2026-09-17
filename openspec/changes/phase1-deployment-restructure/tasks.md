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

- [ ] 4.1 Update the `demo-databricks-iac` HCP Terraform workspace's Terraform working directory setting from `envs/dev` to `deployment/free_workspace` — verify the next run in the HCP Terraform UI picks up the new path

## 5. Migration apply — destroys existing dev bucket/credential/location/catalogs, confirm before running

- [ ] 5.1 Run `terraform plan` against the restructured config and review the full destroy/create list — verify it matches design.md's Migration Plan (1 bucket/role/credential/location/3-catalogs/27-schemas destroyed; 3 buckets/roles/credentials/locations/3-catalogs/27-schemas created)
- [ ] 5.2 Get explicit go-ahead before applying (destructive on real AWS/Databricks resources) — verify approval is recorded before proceeding
- [ ] 5.3 First apply with empty `uc_external_ids` — verify all 3 buckets, roles, storage credentials, external locations, catalogs, and schemas are created
- [ ] 5.4 Set `uc_external_ids` from `terraform output` and re-apply — verify only the 3 IAM roles show an in-place trust-policy update, nothing else changes

## 6. Verification

- [ ] 6.1 `databricks catalogs list` shows `mdp_dev`/`mdp_tst`/`mdp_prd`; `databricks external-locations list` shows 3 locations, each pointing at a different bucket — verify against the actual workspace
- [ ] 6.2 Confirm `openspec/specs/cloud-storage/spec.md` and `openspec/specs/unity-catalog/spec.md` match deployed reality after archiving this change — verify by re-reading both against the applied state
