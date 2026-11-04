## 1. Change

- [x] 1.1 Add `gold_analytics_gateway` to `cicd_writable_schemas` in `deployment/free_workspace/main.tf`
      and `deployment/single_workspace/main.tf`; `terraform validate` passes in both

## 2. Plan and apply

- [x] 2.1 `terraform plan` on `free_workspace` shown in full: only the 2 grants are added
- [x] 2.2 Apply after the user's go-ahead; a fresh plan shows no changes
- [x] 2.3 Verify with `databricks grants get schema` on `mdp_dev` and `mdp_prd`
