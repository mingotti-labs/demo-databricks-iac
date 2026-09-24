## 1. Schema map

- [ ] 1.1 Add `bronze_nsw_property` and `bronze_nsw_property_publish` to
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`
- [ ] 1.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy

## 2. Apply and verify

- [ ] 2.1 Apply — 6 added, 0 changed, 0 destroyed
- [ ] 2.2 `databricks schemas list mdp_<env>` confirms both new schemas
      present in `dev`/`tst`/`prd`

## 3. CI/CD SP grants (applied proactively, including CREATE_MATERIALIZED_VIEW)

- [ ] 3.1 Add `bronze_nsw_property`/`bronze_nsw_property_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [ ] 3.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy; apply — 6 added

## 4. Documentation

- [ ] 4.1 Add a note to this repo's CLAUDE.md ("Bronze schema shape"
      section): the two new schemas exist, consumed by an upcoming
      `demo-databricks-mdp` change
