## 1. Schema map

- [x] 1.1 Added `bronze_nsw_spatial` and `bronze_nsw_spatial_publish` to
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 `terraform plan` showed exactly 12 to add (6 schemas + 6 CI/CD
      grants, both changes made before the first plan), 0 to change, 0 to
      destroy

## 2. Apply and verify

- [x] 2.1 Applied — confirmed via `databricks schemas list mdp_<env>`
      directly against the real workspace (not just the apply log)
- [x] 2.2 `databricks schemas list mdp_dev`/`mdp_tst`/`mdp_prd` confirmed
      both new schemas present in all three catalogs

## 3. CI/CD SP grants (applied proactively, including CREATE_MATERIALIZED_VIEW)

- [x] 3.1 Added `bronze_nsw_spatial`/`bronze_nsw_spatial_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [x] 3.2 Covered by the same plan/apply as step 1.2/2.1; confirmed via
      `databricks grants get schema mdp_dev.bronze_nsw_spatial` that the
      CI/CD SP has `USE_SCHEMA`, `CREATE_TABLE`, and
      `CREATE_MATERIALIZED_VIEW` from the start

## 4. Documentation

- [x] 4.1 Added a note to this repo's CLAUDE.md ("Bronze schema shape"
      section): the two new schemas exist, consumed by an upcoming
      `demo-databricks-mdp` change
