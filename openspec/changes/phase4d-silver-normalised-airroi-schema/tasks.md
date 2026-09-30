## 1. Schema and grants

- [x] 1.1 Add `silver_normalised_airroi` to `local.schemas` in
      `modules/databricks-unity-catalog/main.tf`
- [x] 1.2 Add `silver_normalised_airroi` to `local.cicd_writable_schemas`
      in `deployment/free_workspace/main.tf`
- [x] 1.3 `terraform plan` shows exactly 6 to add, 0 to change, 0 to
      destroy (confirmed; no other drift, `uc_external_ids` passed)

## 2. Apply and verify

- [x] 2.1 Apply, after explicit go-ahead on the plan output
- [x] 2.2 `databricks schemas list mdp_<env>` confirms the schema in
      `dev`/`tst`/`prd`
- [x] 2.3 After the mdp change's tag step runs in `dev`, record whether
      `APPLY TAG` was needed; if so, add it and re-apply — not needed:
      the tag step ran as the tables' owner with no extra grant

## 3. Documentation

- [x] 3.1 CLAUDE.md "Silver schema shape": note `silver_normalised_airroi`,
      consumed by `demo-databricks-mdp`'s
      `phase4d-silver-normalised-framework`
