## 1. Free workspace schemas

- [x] 1.1 In `deployment/free_workspace/main.tf`, remove the twelve
      `silver_landing_<source>` entries from `local.schemas`
- [x] 1.2 Same twelve from `local.cicd_writable_schemas`
- [x] 1.3 `single_workspace` untouched (`git diff --stat` shows no file there)

## 2. Plan and apply

- [x] 2.1 Re-check the twelve schemas hold no tables, volumes or functions in
      `mdp_dev` and `mdp_prd`
- [x] 2.2 `terraform plan`: 0 to add, 0 to change, 48 to destroy, nothing else
- [x] 2.3 Apply with the user's go-ahead
- [x] 2.4 Run the checks in design.md's Migration Plan

## 3. Documentation

- [x] 3.1 CLAUDE.md "Silver schema shape": the per-source Landing schemas were
      dropped from the free workspace (this change); NAMING.md already
      describes only `silver_landing` for the free workspace
