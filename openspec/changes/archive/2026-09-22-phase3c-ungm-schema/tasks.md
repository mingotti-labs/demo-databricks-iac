## 1. Schema map

- [x] 1.1 Added `bronze_ungm` and `bronze_ungm_publish` to `local.schemas`
      in `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 `terraform plan` showed exactly 6 to add, 0 to change, 0 to
      destroy

## 2. Apply and verify

- [x] 2.1 Applied — 6 added, 0 changed, 0 destroyed
- [x] 2.2 `databricks schemas list mdp_<env>` confirmed both new schemas
      present in `dev`/`tst`/`prd`

## 3. CI/CD SP grants (applied proactively this time)

- [x] 3.1 Added `bronze_ungm`/`bronze_ungm_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [x] 3.2 `terraform plan` showed exactly 6 to add, 0 to change, 0 to
      destroy; applied — 6 added

## 4. Documentation

- [x] 4.1 Added a note to this repo's CLAUDE.md ("Bronze schema shape"
      section): the two new schemas exist, consumed by an upcoming
      `demo-databricks-mdp` change, and the CI/CD SP grants were applied
      proactively this time rather than discovered via a real failure
