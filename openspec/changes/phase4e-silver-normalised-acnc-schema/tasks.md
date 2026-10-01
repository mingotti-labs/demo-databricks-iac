## 1. Schema and grants

- [x] 1.1 Add `silver_normalised_acnc` to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 Add `silver_normalised_acnc` to `local.cicd_writable_schemas` in
      `deployment/free_workspace/main.tf`
- [x] 1.3 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy (confirmed; no other drift)

## 2. Apply and verify

- [x] 2.1 Apply, after explicit go-ahead on the plan output -- `Apply
      complete! Resources: 6 added, 0 changed, 0 destroyed.`
- [x] 2.2 `databricks schemas list mdp_<env>` confirms the schema in
      `dev`/`tst`/`prd`

## 3. Documentation

- [x] 3.1 CLAUDE.md "Silver schema shape": note `silver_normalised_acnc`,
      consumed by `demo-databricks-mdp`'s `phase4e-silver-normalised-acnc`
