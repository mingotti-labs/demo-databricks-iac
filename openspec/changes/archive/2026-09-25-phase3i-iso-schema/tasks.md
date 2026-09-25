## 1. Schema map

- [x] 1.1 Add `bronze_iso` and `bronze_iso_publish` to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to destroy
      (combined with task 3.1's grants into one 12-resource plan/apply —
      both edits were made before the first plan; net result is identical)

## 2. Apply and verify

- [x] 2.1 Apply, after explicit go-ahead on the plan output — `Apply
      complete! Resources: 12 added, 0 changed, 0 destroyed.`
- [x] 2.2 `databricks schemas list mdp_<env>` confirms both new schemas
      present in `dev`/`tst`/`prd`

## 3. CI/CD SP grants (applied proactively)

- [x] 3.1 Add `bronze_iso`/`bronze_iso_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [x] 3.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy; apply (see task 1.2 — applied together)

## 4. Documentation

- [x] 4.1 Add a note to this repo's CLAUDE.md ("Bronze schema shape"
      section): the two new schemas exist, consumed by an upcoming
      `demo-databricks-mdp` change, and the sequencing relationship with
      `phase3j-geonames-schema`
