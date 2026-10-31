## 1. Check

- [x] 1.1 `silver_investments` has no tables in `mdp_dev` and `mdp_prd`
      (`databricks tables list`)

## 2. Change

- [x] 2.1 Replace `silver_investments` with `silver_domain_investments` in
      `modules/databricks-unity-catalog/variables.tf`,
      `deployment/free_workspace/main.tf` and
      `deployment/single_workspace/main.tf`; `terraform validate` passes in
      both deployments
- [x] 2.2 CLAUDE.md and NAMING.md: Silver Domain schemas are
      `silver_domain_<domain>`

## 3. Plan and apply

- [x] 3.1 `terraform plan` on `free_workspace` shown in full: only the schema
      and its grants are replaced, nothing else changes
- [ ] 3.2 Apply after the user's go-ahead; a fresh plan shows no changes
- [ ] 3.3 Verify: `silver_domain_investments` listed and `silver_investments`
      not, in both catalogs; the CI/CD principal holds `USE_SCHEMA`,
      `CREATE_TABLE`, `CREATE_MATERIALIZED_VIEW`, the human account `SELECT`;
      schema quota unchanged
