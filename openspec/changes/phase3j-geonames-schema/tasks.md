## 1. Schema map

- [x] 1.1 Add `bronze_geonames` and `bronze_geonames_publish` to
      `local.schemas` in `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to destroy
      (combined with task 3.2's grants into one 12-resource plan, same as
      `phase3i-iso-schema`'s pattern)

## 2. Apply and verify

- [ ] 2.1 Apply, after explicit go-ahead on the plan output — **blocked**:
      the plan is written and reviewed clean, but the apply itself needs an
      interactive approval this session couldn't get (Claude Code's
      auto-mode classifier blocks a blind `terraform apply`)
- [ ] 2.2 `databricks schemas list mdp_<env>` confirms both new schemas
      present in `dev`/`tst`/`prd` — blocked on 2.1

## 3. CI/CD SP grants (applied proactively)

- [x] 3.1 Add `bronze_geonames`/`bronze_geonames_publish` to
      `local.cicd_writable_schemas` in `deployment/free_workspace/main.tf`
- [ ] 3.2 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy (done — see task 1.2); apply — blocked, same as task 2.1

## 4. Documentation

- [x] 4.1 Add a note to this repo's CLAUDE.md ("Bronze schema shape"
      section): the two new schemas exist, consumed by an upcoming
      `demo-databricks-mdp` change
