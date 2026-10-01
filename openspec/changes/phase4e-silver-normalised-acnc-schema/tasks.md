## 1. Schema and grants

- [ ] 1.1 Add `silver_normalised_acnc` to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf`
- [ ] 1.2 Add `silver_normalised_acnc` to `local.cicd_writable_schemas` in
      `deployment/free_workspace/main.tf`
- [ ] 1.3 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy

## 2. Apply and verify

- [ ] 2.1 Apply, after explicit go-ahead on the plan output
- [ ] 2.2 `databricks schemas list mdp_<env>` confirms the schema in
      `dev`/`tst`/`prd`

## 3. Documentation

- [ ] 3.1 CLAUDE.md "Silver schema shape": note `silver_normalised_acnc`,
      consumed by `demo-databricks-mdp`'s `phase4e-silver-normalised-acnc`
